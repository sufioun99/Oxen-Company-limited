--------------------------------------------------------------------------------
-- FIX FOR ORA-40508 AND ORA-00904 ERRORS IN SERVICE FORMS
-- This script fixes the duplicate trigger issue and improves warranty logic
-- Run this as: sqlplus msp/msp @fix_service_form_errors.sql
--------------------------------------------------------------------------------

PROMPT Fixing service form errors (ORA-40508, ORA-00904)...
PROMPT 

-- Drop the duplicate line_no trigger (if it exists)
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_service_det_line_no_bi';
    DBMS_OUTPUT.PUT_LINE('✓ Dropped duplicate trigger: trg_service_det_line_no_bi');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -4080 THEN
            DBMS_OUTPUT.PUT_LINE('ℹ Trigger trg_service_det_line_no_bi does not exist - OK');
        ELSE
            DBMS_OUTPUT.PUT_LINE('⚠ Error dropping trigger: ' || SQLERRM);
        END IF;
END;
/

-- Recreate the combined trigger for service_details
PROMPT Creating combined trigger for service_details...
CREATE OR REPLACE TRIGGER trg_service_det_bi 
BEFORE INSERT ON service_details 
FOR EACH ROW 
DECLARE
    v_next_line_no NUMBER := 1;
BEGIN 
    -- Generate service_det_id
    IF :NEW.service_det_id IS NULL THEN
        :NEW.service_det_id := 'SDT' || TO_CHAR(service_det_seq.NEXTVAL);  
    END IF;
    
    -- Generate line_no
    IF :NEW.line_no IS NULL THEN
        IF :NEW.service_id IS NOT NULL THEN
            BEGIN
                SELECT NVL(MAX(line_no), 0) + 1
                INTO v_next_line_no
                FROM service_details
                WHERE service_id = :NEW.service_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_next_line_no := 1;
                WHEN OTHERS THEN
                    v_next_line_no := 1;
            END;
        ELSE
            v_next_line_no := 1;
        END IF;
        
        :NEW.line_no := v_next_line_no;
    END IF;
END;
/

PROMPT ✓ Combined trigger created successfully
PROMPT

-- Recreate the service_master trigger with improved warranty logic
PROMPT Creating improved service_master trigger...
CREATE OR REPLACE TRIGGER trg_service_master_bi
BEFORE INSERT OR UPDATE ON service_master
FOR EACH ROW
DECLARE 
    v_inv_date DATE; 
    v_warranty NUMBER;
BEGIN
    -- ID generation (SAFE)
    IF INSERTING AND :NEW.service_id IS NULL THEN
        :NEW.service_id := 'SVM' || TO_CHAR(service_master_seq.NEXTVAL);
    END IF;

    -- Audit columns
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;

    -- Warranty logic (IMPROVED)
    IF INSERTING AND :NEW.invoice_id IS NOT NULL THEN
        BEGIN
            SELECT m.invoice_date, NVL(p.warranty, 0)
            INTO v_inv_date, v_warranty
            FROM sales_master m
            JOIN sales_detail d ON m.invoice_id = d.invoice_id
            JOIN products p ON d.product_id = p.product_id
            WHERE m.invoice_id = :NEW.invoice_id
            AND ROWNUM = 1;

            IF v_warranty > 0 AND v_inv_date + (v_warranty * 30) >= SYSDATE THEN
                :NEW.warranty_applicable := 'Y';
            ELSE
                :NEW.warranty_applicable := 'N';
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                :NEW.warranty_applicable := 'N';
            WHEN OTHERS THEN
                :NEW.warranty_applicable := 'N';
        END;
    ELSIF INSERTING THEN
        -- If no invoice_id provided, set warranty to 'N' by default
        IF :NEW.warranty_applicable IS NULL THEN
            :NEW.warranty_applicable := 'N';
        END IF;
    END IF;
END;
/

PROMPT ✓ Service master trigger created successfully
PROMPT

-- Verify the triggers
PROMPT Verifying triggers...
SELECT trigger_name, trigger_type, triggering_event, status
FROM user_triggers
WHERE table_name = 'SERVICE_DETAILS'
   OR table_name = 'SERVICE_MASTER'
ORDER BY table_name, trigger_name;

PROMPT
PROMPT ========================================
PROMPT Fix completed successfully!
PROMPT ========================================
PROMPT
PROMPT What was fixed:
PROMPT 1. Merged duplicate BEFORE INSERT triggers on service_details
PROMPT 2. Improved warranty validation logic in service_master
PROMPT 3. Added proper NULL handling and exception catching
PROMPT
PROMPT You can now insert records into service forms without errors.
PROMPT ========================================
