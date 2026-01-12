-- ============================================================================
-- SERVICE FORM ENHANCEMENT - Multi-Product & Multi-Parts Support
-- ============================================================================
-- Purpose: Upgrade service management system to handle multiple products
--          from one invoice, with multiple parts per product
-- Date: January 12, 2026
-- Database: Oracle 11g+
-- User: msp/msp
-- ============================================================================

PROMPT ============================================================================
PROMPT Creating SERVICE_PARTS table for multi-part support...
PROMPT ============================================================================

-- Create new bridge table for parts
CREATE TABLE service_parts (
    service_parts_id   VARCHAR2(50) PRIMARY KEY,
    service_det_id     VARCHAR2(50) NOT NULL,
    parts_id           VARCHAR2(50) NOT NULL,
    quantity           NUMBER DEFAULT 1,
    unit_price         NUMBER DEFAULT 0,
    line_total         NUMBER DEFAULT 0,
    status             NUMBER DEFAULT 1,
    cre_by             VARCHAR2(100),
    cre_dt             DATE,
    upd_by             VARCHAR2(100),
    upd_dt             DATE,
    CONSTRAINT fk_sp_det FOREIGN KEY (service_det_id) 
        REFERENCES service_details(service_det_id) ON DELETE CASCADE,
    CONSTRAINT fk_sp_part FOREIGN KEY (parts_id) 
        REFERENCES parts(parts_id)
);

PROMPT Creating sequence for SERVICE_PARTS...
CREATE SEQUENCE service_parts_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

PROMPT Creating trigger for SERVICE_PARTS ID generation...
CREATE OR REPLACE TRIGGER trg_service_parts_bi
BEFORE INSERT OR UPDATE ON service_parts FOR EACH ROW
BEGIN
    IF INSERTING THEN
        -- Generate ID
        IF :NEW.service_parts_id IS NULL THEN
            :NEW.service_parts_id := 'SPT' || TO_CHAR(service_parts_seq.NEXTVAL);
        END IF;
        
        -- Audit columns
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
    
    -- Auto-calculate line total
    :NEW.line_total := NVL(:NEW.quantity, 0) * NVL(:NEW.unit_price, 0);
END;
/

PROMPT ============================================================================
PROMPT Modifying SERVICE_DETAILS table structure...
PROMPT ============================================================================

-- Check if columns already exist before adding
DECLARE
    v_count NUMBER;
BEGIN
    -- Check service_type_id
    SELECT COUNT(*) INTO v_count
    FROM user_tab_columns
    WHERE table_name = 'SERVICE_DETAILS' AND column_name = 'SERVICE_TYPE_ID';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE service_details ADD service_type_id VARCHAR2(50)';
        DBMS_OUTPUT.PUT_LINE('Added column: service_type_id');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Column service_type_id already exists');
    END IF;
    
    -- Check service_charge
    SELECT COUNT(*) INTO v_count
    FROM user_tab_columns
    WHERE table_name = 'SERVICE_DETAILS' AND column_name = 'SERVICE_CHARGE';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE service_details ADD service_charge NUMBER DEFAULT 0';
        DBMS_OUTPUT.PUT_LINE('Added column: service_charge');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Column service_charge already exists');
    END IF;
    
    -- Check parts_total
    SELECT COUNT(*) INTO v_count
    FROM user_tab_columns
    WHERE table_name = 'SERVICE_DETAILS' AND column_name = 'PARTS_TOTAL';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE service_details ADD parts_total NUMBER DEFAULT 0';
        DBMS_OUTPUT.PUT_LINE('Added column: parts_total');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Column parts_total already exists');
    END IF;
END;
/

-- Add foreign key constraint
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_constraints
    WHERE constraint_name = 'FK_SD_STYPE';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE service_details ADD CONSTRAINT fk_sd_stype 
            FOREIGN KEY (service_type_id) REFERENCES service_list(servicelist_id)';
        DBMS_OUTPUT.PUT_LINE('Added foreign key: fk_sd_stype');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Foreign key fk_sd_stype already exists');
    END IF;
END;
/

PROMPT ============================================================================
PROMPT Creating calculation triggers...
PROMPT ============================================================================

PROMPT Creating trigger: trg_service_parts_calc
PROMPT Purpose: Calculate parts_total in SERVICE_DETAILS when parts change
CREATE OR REPLACE TRIGGER trg_service_parts_calc
AFTER INSERT OR UPDATE OR DELETE ON service_parts
FOR EACH ROW
DECLARE
    v_service_det_id VARCHAR2(50);
    v_parts_total NUMBER;
    v_service_charge NUMBER;
BEGIN
    /* Get service_det_id */
    IF INSERTING OR UPDATING THEN
        v_service_det_id := :NEW.service_det_id;
    ELSE
        v_service_det_id := :OLD.service_det_id;
    END IF;
    
    /* Calculate total parts cost for this product */
    SELECT NVL(SUM(line_total), 0)
    INTO v_parts_total
    FROM service_parts
    WHERE service_det_id = v_service_det_id
      AND status = 1;
    
    /* Get current service charge */
    SELECT NVL(service_charge, 0)
    INTO v_service_charge
    FROM service_details
    WHERE service_det_id = v_service_det_id;
    
    /* Update parent SERVICE_DETAILS */
    UPDATE service_details
    SET parts_total = v_parts_total,
        line_total = v_service_charge + v_parts_total,
        upd_by = USER,
        upd_dt = SYSDATE
    WHERE service_det_id = v_service_det_id;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail transaction
        DBMS_OUTPUT.PUT_LINE('Error in trg_service_parts_calc: ' || SQLERRM);
END;
/

PROMPT Creating trigger: trg_service_det_totals
PROMPT Purpose: Calculate grand total in SERVICE_MASTER when details change
CREATE OR REPLACE TRIGGER trg_service_det_totals
AFTER INSERT OR UPDATE OR DELETE ON service_details
FOR EACH ROW
DECLARE
    v_service_id VARCHAR2(50);
    v_service_charge_total NUMBER;
    v_parts_total NUMBER;
    v_subtotal NUMBER;
    v_vat NUMBER;
    v_grand_total NUMBER;
    v_vat_rate CONSTANT NUMBER := 0.15;  -- 15% VAT
BEGIN
    /* Get service_id */
    IF INSERTING OR UPDATING THEN
        v_service_id := :NEW.service_id;
    ELSE
        v_service_id := :OLD.service_id;
    END IF;
    
    /* Calculate totals from all service details */
    SELECT 
        NVL(SUM(service_charge), 0),
        NVL(SUM(parts_total), 0)
    INTO 
        v_service_charge_total,
        v_parts_total
    FROM service_details
    WHERE service_id = v_service_id
      AND status = 1;
    
    /* Calculate final amounts */
    v_subtotal := v_service_charge_total + v_parts_total;
    v_vat := v_subtotal * v_vat_rate;
    v_grand_total := v_subtotal + v_vat;
    
    /* Update master totals */
    UPDATE service_master
    SET service_charge = v_service_charge_total,
        parts_price = v_parts_total,
        total_price = v_subtotal,
        vat = v_vat,
        grand_total = v_grand_total,
        upd_by = USER,
        upd_dt = SYSDATE
    WHERE service_id = v_service_id;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail transaction
        DBMS_OUTPUT.PUT_LINE('Error in trg_service_det_totals: ' || SQLERRM);
END;
/

PROMPT ============================================================================
PROMPT Creating stock deduction trigger for parts...
PROMPT ============================================================================

CREATE OR REPLACE TRIGGER trg_stock_on_service_parts
AFTER INSERT OR UPDATE OR DELETE ON service_parts
FOR EACH ROW
DECLARE
    v_parts_id VARCHAR2(50);
    v_old_qty NUMBER := 0;
    v_new_qty NUMBER := 0;
    v_qty_change NUMBER;
BEGIN
    /* Determine quantity changes */
    IF INSERTING THEN
        v_parts_id := :NEW.parts_id;
        v_new_qty := NVL(:NEW.quantity, 0);
        v_qty_change := -v_new_qty;  -- Negative = deduct from stock
        
    ELSIF UPDATING THEN
        v_parts_id := :NEW.parts_id;
        v_old_qty := NVL(:OLD.quantity, 0);
        v_new_qty := NVL(:NEW.quantity, 0);
        v_qty_change := v_old_qty - v_new_qty;  -- Restore old, deduct new
        
    ELSIF DELETING THEN
        v_parts_id := :OLD.parts_id;
        v_old_qty := NVL(:OLD.quantity, 0);
        v_qty_change := v_old_qty;  -- Positive = restore to stock
    END IF;
    
    /* Update stock if quantity changed */
    IF v_qty_change != 0 THEN
        UPDATE stock
        SET quantity = quantity + v_qty_change,
            last_update = SYSTIMESTAMP
        WHERE product_id = v_parts_id;
        
        -- If no stock record exists, create one
        IF SQL%ROWCOUNT = 0 AND (INSERTING OR UPDATING) THEN
            INSERT INTO stock (stock_id, product_id, quantity, last_update)
            VALUES ('STK' || stock_seq.NEXTVAL, v_parts_id, -v_qty_change, SYSTIMESTAMP);
        END IF;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log but don't fail (stock adjustment can be manual if needed)
        DBMS_OUTPUT.PUT_LINE('Warning in stock update: ' || SQLERRM);
END;
/

PROMPT ============================================================================
PROMPT Verification - Checking installation...
PROMPT ============================================================================

SET SERVEROUTPUT ON
DECLARE
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== VERIFICATION REPORT ===');
    DBMS_OUTPUT.PUT_LINE(' ');
    
    -- Check SERVICE_PARTS table
    SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name = 'SERVICE_PARTS';
    DBMS_OUTPUT.PUT_LINE('1. SERVICE_PARTS table: ' || 
        CASE WHEN v_count = 1 THEN '✓ EXISTS' ELSE '✗ MISSING' END);
    
    -- Check sequence
    SELECT COUNT(*) INTO v_count FROM user_sequences WHERE sequence_name = 'SERVICE_PARTS_SEQ';
    DBMS_OUTPUT.PUT_LINE('2. SERVICE_PARTS_SEQ sequence: ' || 
        CASE WHEN v_count = 1 THEN '✓ EXISTS' ELSE '✗ MISSING' END);
    
    -- Check new columns in SERVICE_DETAILS
    SELECT COUNT(*) INTO v_count FROM user_tab_columns 
    WHERE table_name = 'SERVICE_DETAILS' AND column_name IN ('SERVICE_TYPE_ID', 'SERVICE_CHARGE', 'PARTS_TOTAL');
    DBMS_OUTPUT.PUT_LINE('3. New columns in SERVICE_DETAILS: ' || v_count || '/3 ' ||
        CASE WHEN v_count = 3 THEN '✓ ALL ADDED' ELSE '✗ INCOMPLETE' END);
    
    -- Check triggers
    SELECT COUNT(*) INTO v_count FROM user_triggers 
    WHERE trigger_name IN ('TRG_SERVICE_PARTS_BI', 'TRG_SERVICE_PARTS_CALC', 
                           'TRG_SERVICE_DET_TOTALS', 'TRG_STOCK_ON_SERVICE_PARTS')
      AND status = 'ENABLED';
    DBMS_OUTPUT.PUT_LINE('4. Service triggers enabled: ' || v_count || '/4 ' ||
        CASE WHEN v_count = 4 THEN '✓ ALL ENABLED' ELSE '✗ CHECK STATUS' END);
    
    -- Check foreign keys
    SELECT COUNT(*) INTO v_count FROM user_constraints 
    WHERE constraint_name IN ('FK_SP_DET', 'FK_SP_PART', 'FK_SD_STYPE')
      AND status = 'ENABLED';
    DBMS_OUTPUT.PUT_LINE('5. Foreign key constraints: ' || v_count || '/3 ' ||
        CASE WHEN v_count = 3 THEN '✓ ALL VALID' ELSE '✗ CHECK CONSTRAINTS' END);
    
    DBMS_OUTPUT.PUT_LINE(' ');
    
    IF v_count >= 3 THEN
        DBMS_OUTPUT.PUT_LINE('=== ✓ INSTALLATION SUCCESSFUL ===');
        DBMS_OUTPUT.PUT_LINE('Multi-product service form ready to use!');
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('Next Steps:');
        DBMS_OUTPUT.PUT_LINE('1. Open Oracle Forms Builder');
        DBMS_OUTPUT.PUT_LINE('2. Create blocks: SERVICE_MASTER, SERVICE_DETAILS, SERVICE_PARTS');
        DBMS_OUTPUT.PUT_LINE('3. Follow guide: SERVICE_FORM_COMPLETE_GUIDE.md');
    ELSE
        DBMS_OUTPUT.PUT_LINE('=== ✗ INSTALLATION INCOMPLETE ===');
        DBMS_OUTPUT.PUT_LINE('Please review errors above and re-run script.');
    END IF;
END;
/

PROMPT ============================================================================
PROMPT Sample data for testing (optional)...
PROMPT ============================================================================

-- Uncomment below to insert sample service ticket
/*
DECLARE
    v_service_id VARCHAR2(50);
    v_det_id1 VARCHAR2(50);
    v_det_id2 VARCHAR2(50);
BEGIN
    -- Insert service master
    INSERT INTO service_master (
        service_id, service_date, customer_id, invoice_id, 
        warranty_applicable, service_by, status
    ) VALUES (
        'SVM' || service_master_seq.NEXTVAL,
        SYSDATE,
        (SELECT customer_id FROM customers WHERE ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE ROWNUM = 1),
        'Y',
        (SELECT employee_id FROM employees WHERE ROWNUM = 1),
        1
    ) RETURNING service_id INTO v_service_id;
    
    -- Insert first product service
    INSERT INTO service_details (
        service_det_id, service_id, product_id, service_type_id,
        service_charge, warranty_status, status
    ) VALUES (
        'SDT' || service_det_seq.NEXTVAL,
        v_service_id,
        (SELECT product_id FROM products WHERE ROWNUM = 1),
        (SELECT servicelist_id FROM service_list WHERE ROWNUM = 1),
        2000,
        'IN WARRANTY',
        1
    ) RETURNING service_det_id INTO v_det_id1;
    
    -- Add parts to first product
    INSERT INTO service_parts (parts_id, service_det_id, quantity, unit_price)
    SELECT parts_id, v_det_id1, 1, unit_price
    FROM parts WHERE ROWNUM <= 2;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Sample service ticket created: ' || v_service_id);
END;
/
*/

PROMPT ============================================================================
PROMPT Installation complete!
PROMPT See SERVICE_FORM_COMPLETE_GUIDE.md for Forms implementation details.
PROMPT ============================================================================

-- End of script
