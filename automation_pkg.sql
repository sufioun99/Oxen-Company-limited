--------------------------------------------------------------------------------
-- OXEN COMPANY LIMITED - AUTOMATION PACKAGE
-- Compatible with: Oracle 11g, Oracle Forms, Oracle APEX
-- Purpose: Business logic procedures and functions for automation
-- Date: 2026-01-02
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- PACKAGE SPECIFICATION
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_oxen_automation AS
    
    -- Exception declarations
    e_invalid_input EXCEPTION;
    e_insufficient_stock EXCEPTION;
    e_duplicate_entry EXCEPTION;
    
    -- Type declarations
    TYPE t_result_rec IS RECORD (
        success     BOOLEAN,
        message     VARCHAR2(4000),
        ref_id      VARCHAR2(50)
    );
    
    -----------------------------------------------------------------------
    -- STOCK MANAGEMENT PROCEDURES
    -----------------------------------------------------------------------
    
    -- Add stock when products are received
    PROCEDURE add_stock(
        p_product_id    IN VARCHAR2,
        p_supplier_id   IN VARCHAR2,
        p_quantity      IN NUMBER,
        p_result        OUT VARCHAR2
    );
    
    -- Reduce stock when products are sold
    PROCEDURE reduce_stock(
        p_product_id    IN VARCHAR2,
        p_quantity      IN NUMBER,
        p_result        OUT VARCHAR2
    );
    
    -- Check stock availability
    FUNCTION check_stock(
        p_product_id    IN VARCHAR2
    ) RETURN NUMBER;
    
    -- Get low stock items
    PROCEDURE get_low_stock_items(
        p_threshold     IN NUMBER DEFAULT 5,
        p_cursor        OUT SYS_REFCURSOR
    );
    
    -----------------------------------------------------------------------
    -- SALES PROCEDURES
    -----------------------------------------------------------------------
    
    -- Create new sales invoice
    PROCEDURE create_sales_invoice(
        p_customer_id   IN VARCHAR2,
        p_sales_by      IN VARCHAR2,
        p_discount      IN NUMBER DEFAULT 0,
        p_invoice_id    OUT VARCHAR2,
        p_result        OUT VARCHAR2
    );
    
    -- Add item to sales invoice
    PROCEDURE add_sales_item(
        p_invoice_id    IN VARCHAR2,
        p_product_id    IN VARCHAR2,
        p_quantity      IN NUMBER,
        p_mrp           IN NUMBER DEFAULT NULL,
        p_vat           IN NUMBER DEFAULT 0,
        p_result        OUT VARCHAR2
    );
    
    -- Finalize sales invoice (update totals, reduce stock)
    PROCEDURE finalize_sales(
        p_invoice_id    IN VARCHAR2,
        p_result        OUT VARCHAR2
    );
    
    -- Calculate sales total
    FUNCTION calculate_sales_total(
        p_invoice_id    IN VARCHAR2
    ) RETURN NUMBER;
    
    -----------------------------------------------------------------------
    -- PURCHASE/RECEIVE PROCEDURES
    -----------------------------------------------------------------------
    
    -- Create purchase order
    PROCEDURE create_purchase_order(
        p_supplier_id           IN VARCHAR2,
        p_order_by              IN VARCHAR2,
        p_expected_delivery     IN DATE,
        p_order_id              OUT VARCHAR2,
        p_result                OUT VARCHAR2
    );
    
    -- Process product receive
    PROCEDURE process_product_receive(
        p_receive_id    IN VARCHAR2,
        p_result        OUT VARCHAR2
    );
    
    -- Update purchase order totals
    PROCEDURE update_order_totals(
        p_order_id      IN VARCHAR2,
        p_result        OUT VARCHAR2
    );
    
    -----------------------------------------------------------------------
    -- SERVICE PROCEDURES
    -----------------------------------------------------------------------
    
    -- Create service ticket
    PROCEDURE create_service_ticket(
        p_customer_id   IN VARCHAR2,
        p_invoice_id    IN VARCHAR2 DEFAULT NULL,
        p_service_by    IN VARCHAR2,
        p_servicelist_id IN VARCHAR2,
        p_service_id    OUT VARCHAR2,
        p_result        OUT VARCHAR2
    );
    
    -- Complete service and calculate total
    PROCEDURE complete_service(
        p_service_id    IN VARCHAR2,
        p_result        OUT VARCHAR2
    );
    
    -----------------------------------------------------------------------
    -- SUPPLIER PAYMENT PROCEDURES
    -----------------------------------------------------------------------
    
    -- Record supplier payment
    PROCEDURE record_supplier_payment(
        p_supplier_id   IN VARCHAR2,
        p_amount        IN NUMBER,
        p_payment_id    OUT VARCHAR2,
        p_result        OUT VARCHAR2
    );
    
    -- Get supplier due amount
    FUNCTION get_supplier_due(
        p_supplier_id   IN VARCHAR2
    ) RETURN NUMBER;
    
    -----------------------------------------------------------------------
    -- CUSTOMER PROCEDURES
    -----------------------------------------------------------------------
    
    -- Update customer rewards
    PROCEDURE update_customer_rewards(
        p_customer_id   IN VARCHAR2,
        p_points        IN NUMBER,
        p_result        OUT VARCHAR2
    );
    
    -- Get customer purchase history
    PROCEDURE get_customer_history(
        p_customer_id   IN VARCHAR2,
        p_cursor        OUT SYS_REFCURSOR
    );
    
    -----------------------------------------------------------------------
    -- UTILITY FUNCTIONS
    -----------------------------------------------------------------------
    
    -- Generate unique reference number
    FUNCTION generate_ref_number(
        p_prefix        IN VARCHAR2,
        p_sequence_name IN VARCHAR2
    ) RETURN VARCHAR2;
    
    -- Check warranty status
    FUNCTION check_warranty_status(
        p_invoice_id    IN VARCHAR2,
        p_product_id    IN VARCHAR2
    ) RETURN VARCHAR2;
    
    -- Get next business day
    FUNCTION get_next_business_day(
        p_date          IN DATE DEFAULT SYSDATE
    ) RETURN DATE;
    
END pkg_oxen_automation;
/

--------------------------------------------------------------------------------
-- PACKAGE BODY
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY pkg_oxen_automation AS

    -----------------------------------------------------------------------
    -- STOCK MANAGEMENT PROCEDURES
    -----------------------------------------------------------------------
    
    PROCEDURE add_stock(
        p_product_id    IN VARCHAR2,
        p_supplier_id   IN VARCHAR2,
        p_quantity      IN NUMBER,
        p_result        OUT VARCHAR2
    ) IS
        v_stock_id      stock.stock_id%TYPE;
        v_current_qty   NUMBER;
        v_cat_id        products.category_id%TYPE;
        v_sub_cat_id    products.sub_cat_id%TYPE;
    BEGIN
        IF p_product_id IS NULL OR p_quantity IS NULL OR p_quantity <= 0 THEN
            p_result := 'ERROR: Invalid product ID or quantity';
            RETURN;
        END IF;
        
        -- Get product category info
        SELECT category_id, sub_cat_id 
        INTO v_cat_id, v_sub_cat_id
        FROM products 
        WHERE product_id = p_product_id;
        
        -- Check if stock record exists
        BEGIN
            SELECT stock_id, quantity 
            INTO v_stock_id, v_current_qty
            FROM stock 
            WHERE product_id = p_product_id
            AND status = 1
            FOR UPDATE;
            
            -- Update existing stock
            UPDATE stock 
            SET quantity = quantity + p_quantity,
                last_update = SYSTIMESTAMP,
                upd_by = USER,
                upd_dt = SYSDATE
            WHERE stock_id = v_stock_id;
            
            p_result := 'SUCCESS: Stock updated. New quantity: ' || TO_CHAR(v_current_qty + p_quantity);
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Insert new stock record
                INSERT INTO stock (product_id, supplier_id, product_cat_id, sub_cat_id, quantity)
                VALUES (p_product_id, p_supplier_id, v_cat_id, v_sub_cat_id, p_quantity);
                
                p_result := 'SUCCESS: New stock record created. Quantity: ' || TO_CHAR(p_quantity);
        END;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'ERROR: ' || SQLERRM;
    END add_stock;
    
    
    PROCEDURE reduce_stock(
        p_product_id    IN VARCHAR2,
        p_quantity      IN NUMBER,
        p_result        OUT VARCHAR2
    ) IS
        v_stock_id      stock.stock_id%TYPE;
        v_current_qty   NUMBER;
    BEGIN
        IF p_product_id IS NULL OR p_quantity IS NULL OR p_quantity <= 0 THEN
            p_result := 'ERROR: Invalid product ID or quantity';
            RETURN;
        END IF;
        
        -- Check current stock
        BEGIN
            SELECT stock_id, quantity 
            INTO v_stock_id, v_current_qty
            FROM stock 
            WHERE product_id = p_product_id
            AND status = 1
            FOR UPDATE;
            
            IF v_current_qty < p_quantity THEN
                p_result := 'ERROR: Insufficient stock. Available: ' || TO_CHAR(v_current_qty);
                RETURN;
            END IF;
            
            -- Reduce stock
            UPDATE stock 
            SET quantity = quantity - p_quantity,
                last_update = SYSTIMESTAMP,
                upd_by = USER,
                upd_dt = SYSDATE
            WHERE stock_id = v_stock_id;
            
            p_result := 'SUCCESS: Stock reduced. New quantity: ' || TO_CHAR(v_current_qty - p_quantity);
            
            COMMIT;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_result := 'ERROR: No stock record found for product';
        END;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'ERROR: ' || SQLERRM;
    END reduce_stock;
    
    
    FUNCTION check_stock(
        p_product_id    IN VARCHAR2
    ) RETURN NUMBER IS
        v_quantity NUMBER := 0;
    BEGIN
        SELECT NVL(quantity, 0) 
        INTO v_quantity
        FROM stock 
        WHERE product_id = p_product_id
        AND status = 1;
        
        RETURN v_quantity;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN -1;
    END check_stock;
    
    
    PROCEDURE get_low_stock_items(
        p_threshold     IN NUMBER DEFAULT 5,
        p_cursor        OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT p.product_id,
                   p.product_code,
                   p.product_name,
                   NVL(s.quantity, 0) AS current_stock,
                   p.mrp,
                   p.purchase_price
            FROM products p
            LEFT JOIN stock s ON p.product_id = s.product_id AND s.status = 1
            WHERE p.status = 1
            AND NVL(s.quantity, 0) <= p_threshold
            ORDER BY NVL(s.quantity, 0) ASC;
    END get_low_stock_items;
    
    -----------------------------------------------------------------------
    -- SALES PROCEDURES
    -----------------------------------------------------------------------
    
    PROCEDURE create_sales_invoice(
        p_customer_id   IN VARCHAR2,
        p_sales_by      IN VARCHAR2,
        p_discount      IN NUMBER DEFAULT 0,
        p_invoice_id    OUT VARCHAR2,
        p_result        OUT VARCHAR2
    ) IS
    BEGIN
        INSERT INTO sales_master (customer_id, sales_by, discount, invoice_date)
        VALUES (p_customer_id, p_sales_by, NVL(p_discount, 0), SYSDATE)
        RETURNING invoice_id INTO p_invoice_id;
        
        COMMIT;
        p_result := 'SUCCESS: Invoice ' || p_invoice_id || ' created';
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'ERROR: ' || SQLERRM;
    END create_sales_invoice;
    
    
    PROCEDURE add_sales_item(
        p_invoice_id    IN VARCHAR2,
        p_product_id    IN VARCHAR2,
        p_quantity      IN NUMBER,
        p_mrp           IN NUMBER DEFAULT NULL,
        p_vat           IN NUMBER DEFAULT 0,
        p_result        OUT VARCHAR2
    ) IS
        v_mrp           NUMBER;
        v_purchase_price NUMBER;
        v_stock_qty     NUMBER;
    BEGIN
        -- Validate inputs
        IF p_invoice_id IS NULL OR p_product_id IS NULL OR p_quantity <= 0 THEN
            p_result := 'ERROR: Invalid input parameters';
            RETURN;
        END IF;
        
        -- Get product prices
        SELECT mrp, purchase_price 
        INTO v_mrp, v_purchase_price
        FROM products 
        WHERE product_id = p_product_id;
        
        -- Use provided MRP or product MRP
        v_mrp := NVL(p_mrp, v_mrp);
        
        -- Check stock availability
        v_stock_qty := check_stock(p_product_id);
        IF v_stock_qty < p_quantity THEN
            p_result := 'WARNING: Insufficient stock. Available: ' || TO_CHAR(v_stock_qty) || '. Item added anyway.';
        END IF;
        
        -- Insert sales detail
        INSERT INTO sales_detail (invoice_id, product_id, mrp, purchase_price, quantity, vat)
        VALUES (p_invoice_id, p_product_id, v_mrp, v_purchase_price, p_quantity, NVL(p_vat, 0));
        
        COMMIT;
        
        IF p_result IS NULL THEN
            p_result := 'SUCCESS: Item added to invoice';
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_result := 'ERROR: Product not found';
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'ERROR: ' || SQLERRM;
    END add_sales_item;
    
    
    PROCEDURE finalize_sales(
        p_invoice_id    IN VARCHAR2,
        p_result        OUT VARCHAR2
    ) IS
        v_total         NUMBER;
        v_discount      NUMBER;
        v_stock_result  VARCHAR2(4000);
        CURSOR c_items IS
            SELECT product_id, quantity 
            FROM sales_detail 
            WHERE invoice_id = p_invoice_id;
    BEGIN
        -- Calculate total
        v_total := calculate_sales_total(p_invoice_id);
        
        -- Get discount
        SELECT NVL(discount, 0) INTO v_discount
        FROM sales_master WHERE invoice_id = p_invoice_id;
        
        -- Update grand total
        UPDATE sales_master 
        SET grand_total = v_total - v_discount,
            status = 3, -- Completed
            upd_by = USER,
            upd_dt = SYSDATE
        WHERE invoice_id = p_invoice_id;
        
        -- Reduce stock for each item
        FOR r_item IN c_items LOOP
            reduce_stock(r_item.product_id, r_item.quantity, v_stock_result);
        END LOOP;
        
        COMMIT;
        p_result := 'SUCCESS: Invoice finalized. Total: BDT ' || TO_CHAR(v_total - v_discount);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'ERROR: ' || SQLERRM;
    END finalize_sales;
    
    
    FUNCTION calculate_sales_total(
        p_invoice_id    IN VARCHAR2
    ) RETURN NUMBER IS
        v_total NUMBER := 0;
    BEGIN
        SELECT NVL(SUM((mrp * quantity) + NVL(vat, 0)), 0)
        INTO v_total
        FROM sales_detail
        WHERE invoice_id = p_invoice_id;
        
        RETURN v_total;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END calculate_sales_total;
    
    -----------------------------------------------------------------------
    -- PURCHASE/RECEIVE PROCEDURES
    -----------------------------------------------------------------------
    
    PROCEDURE create_purchase_order(
        p_supplier_id           IN VARCHAR2,
        p_order_by              IN VARCHAR2,
        p_expected_delivery     IN DATE,
        p_order_id              OUT VARCHAR2,
        p_result                OUT VARCHAR2
    ) IS
    BEGIN
        INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, order_date)
        VALUES (p_supplier_id, p_order_by, p_expected_delivery, SYSDATE)
        RETURNING order_id INTO p_order_id;
        
        COMMIT;
        p_result := 'SUCCESS: Purchase Order ' || p_order_id || ' created';
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'ERROR: ' || SQLERRM;
    END create_purchase_order;
    
    
    PROCEDURE process_product_receive(
        p_receive_id    IN VARCHAR2,
        p_result        OUT VARCHAR2
    ) IS
        v_supplier_id   VARCHAR2(50);
        v_total         NUMBER := 0;
        v_vat           NUMBER := 0;
        v_stock_result  VARCHAR2(4000);
        
        CURSOR c_items IS
            SELECT product_id, receive_quantity, purchase_price
            FROM product_receive_details
            WHERE receive_id = p_receive_id;
    BEGIN
        -- Get supplier
        SELECT supplier_id, NVL(vat, 0)
        INTO v_supplier_id, v_vat
        FROM product_receive_master
        WHERE receive_id = p_receive_id;
        
        -- Process each item
        FOR r_item IN c_items LOOP
            -- Add to stock
            add_stock(r_item.product_id, v_supplier_id, r_item.receive_quantity, v_stock_result);
            
            -- Calculate total
            v_total := v_total + (r_item.purchase_price * r_item.receive_quantity);
        END LOOP;
        
        -- Update receive master
        UPDATE product_receive_master
        SET total_amount = v_total,
            grand_total = v_total + v_vat,
            status = 3, -- Completed
            upd_by = USER,
            upd_dt = SYSDATE
        WHERE receive_id = p_receive_id;
        
        -- Update supplier purchase total
        UPDATE suppliers
        SET purchase_total = NVL(purchase_total, 0) + v_total + v_vat,
            upd_by = USER,
            upd_dt = SYSDATE
        WHERE supplier_id = v_supplier_id;
        
        COMMIT;
        p_result := 'SUCCESS: Products received and stock updated. Total: BDT ' || TO_CHAR(v_total + v_vat);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'ERROR: ' || SQLERRM;
    END process_product_receive;
    
    
    PROCEDURE update_order_totals(
        p_order_id      IN VARCHAR2,
        p_result        OUT VARCHAR2
    ) IS
        v_total NUMBER := 0;
        v_vat   NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(purchase_price * quantity), 0)
        INTO v_total
        FROM product_order_detail
        WHERE order_id = p_order_id;
        
        SELECT NVL(vat, 0) INTO v_vat
        FROM product_order_master
        WHERE order_id = p_order_id;
        
        UPDATE product_order_master
        SET total_amount = v_total,
            grand_total = v_total + v_vat,
            upd_by = USER,
            upd_dt = SYSDATE
        WHERE order_id = p_order_id;
        
        COMMIT;
        p_result := 'SUCCESS: Order totals updated. Grand Total: BDT ' || TO_CHAR(v_total + v_vat);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'ERROR: ' || SQLERRM;
    END update_order_totals;
    
    -----------------------------------------------------------------------
    -- SERVICE PROCEDURES
    -----------------------------------------------------------------------
    
    PROCEDURE create_service_ticket(
        p_customer_id   IN VARCHAR2,
        p_invoice_id    IN VARCHAR2 DEFAULT NULL,
        p_service_by    IN VARCHAR2,
        p_servicelist_id IN VARCHAR2,
        p_service_id    OUT VARCHAR2,
        p_result        OUT VARCHAR2
    ) IS
        v_service_cost  NUMBER := 0;
    BEGIN
        -- Get service cost
        SELECT NVL(service_cost, 0) INTO v_service_cost
        FROM service_list
        WHERE servicelist_id = p_servicelist_id;
        
        INSERT INTO service_master (customer_id, invoice_id, service_by, servicelist_id, 
                                   service_charge, service_date)
        VALUES (p_customer_id, p_invoice_id, p_service_by, p_servicelist_id,
               v_service_cost, SYSDATE)
        RETURNING service_id INTO p_service_id;
        
        COMMIT;
        p_result := 'SUCCESS: Service ticket ' || p_service_id || ' created';
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'ERROR: ' || SQLERRM;
    END create_service_ticket;
    
    
    PROCEDURE complete_service(
        p_service_id    IN VARCHAR2,
        p_result        OUT VARCHAR2
    ) IS
        v_service_charge NUMBER := 0;
        v_parts_price    NUMBER := 0;
        v_total          NUMBER := 0;
    BEGIN
        -- Get service charge
        SELECT NVL(service_charge, 0) INTO v_service_charge
        FROM service_master
        WHERE service_id = p_service_id;
        
        -- Calculate parts price
        SELECT NVL(SUM(total_service_cost), 0) INTO v_parts_price
        FROM service_details
        WHERE service_id = p_service_id;
        
        v_total := v_service_charge + v_parts_price;
        
        -- Update service master
        UPDATE service_master
        SET parts_price = v_parts_price,
            total_price = v_total,
            status = 3, -- Completed
            upd_by = USER,
            upd_dt = SYSDATE
        WHERE service_id = p_service_id;
        
        COMMIT;
        p_result := 'SUCCESS: Service completed. Total: BDT ' || TO_CHAR(v_total);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'ERROR: ' || SQLERRM;
    END complete_service;
    
    -----------------------------------------------------------------------
    -- SUPPLIER PAYMENT PROCEDURES
    -----------------------------------------------------------------------
    
    PROCEDURE record_supplier_payment(
        p_supplier_id   IN VARCHAR2,
        p_amount        IN NUMBER,
        p_payment_id    OUT VARCHAR2,
        p_result        OUT VARCHAR2
    ) IS
    BEGIN
        IF p_amount <= 0 THEN
            p_result := 'ERROR: Invalid payment amount';
            RETURN;
        END IF;
        
        -- Insert payment record
        INSERT INTO payments (payment_date, amount, supplier_id)
        VALUES (SYSDATE, p_amount, p_supplier_id)
        RETURNING payment_id INTO p_payment_id;
        
        -- Update supplier pay_total
        UPDATE suppliers
        SET pay_total = NVL(pay_total, 0) + p_amount,
            upd_by = USER,
            upd_dt = SYSDATE
        WHERE supplier_id = p_supplier_id;
        
        COMMIT;
        p_result := 'SUCCESS: Payment ' || p_payment_id || ' recorded. Amount: BDT ' || TO_CHAR(p_amount);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'ERROR: ' || SQLERRM;
    END record_supplier_payment;
    
    
    FUNCTION get_supplier_due(
        p_supplier_id   IN VARCHAR2
    ) RETURN NUMBER IS
        v_due NUMBER := 0;
    BEGIN
        SELECT NVL(purchase_total, 0) - NVL(pay_total, 0)
        INTO v_due
        FROM suppliers
        WHERE supplier_id = p_supplier_id;
        
        RETURN v_due;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END get_supplier_due;
    
    -----------------------------------------------------------------------
    -- CUSTOMER PROCEDURES
    -----------------------------------------------------------------------
    
    PROCEDURE update_customer_rewards(
        p_customer_id   IN VARCHAR2,
        p_points        IN NUMBER,
        p_result        OUT VARCHAR2
    ) IS
    BEGIN
        UPDATE customers
        SET rewards = NVL(rewards, 0) + p_points,
            upd_by = USER,
            upd_dt = SYSDATE
        WHERE customer_id = p_customer_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            p_result := 'ERROR: Customer not found';
        ELSE
            COMMIT;
            p_result := 'SUCCESS: Rewards updated';
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'ERROR: ' || SQLERRM;
    END update_customer_rewards;
    
    
    PROCEDURE get_customer_history(
        p_customer_id   IN VARCHAR2,
        p_cursor        OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT sm.invoice_id,
                   sm.invoice_date,
                   sm.grand_total,
                   e.first_name || ' ' || e.last_name AS sales_by,
                   sm.status
            FROM sales_master sm
            LEFT JOIN employees e ON sm.sales_by = e.employee_id
            WHERE sm.customer_id = p_customer_id
            ORDER BY sm.invoice_date DESC;
    END get_customer_history;
    
    -----------------------------------------------------------------------
    -- UTILITY FUNCTIONS
    -----------------------------------------------------------------------
    
    FUNCTION generate_ref_number(
        p_prefix        IN VARCHAR2,
        p_sequence_name IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_seq_val NUMBER;
        v_ref     VARCHAR2(50);
    BEGIN
        EXECUTE IMMEDIATE 'SELECT ' || p_sequence_name || '.NEXTVAL FROM DUAL' INTO v_seq_val;
        v_ref := p_prefix || TO_CHAR(v_seq_val);
        RETURN v_ref;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN p_prefix || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF3');
    END generate_ref_number;
    
    
    FUNCTION check_warranty_status(
        p_invoice_id    IN VARCHAR2,
        p_product_id    IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_invoice_date  DATE;
        v_warranty      NUMBER;
        v_expiry_date   DATE;
    BEGIN
        SELECT sm.invoice_date, p.warranty
        INTO v_invoice_date, v_warranty
        FROM sales_master sm
        JOIN sales_detail sd ON sm.invoice_id = sd.invoice_id
        JOIN products p ON sd.product_id = p.product_id
        WHERE sm.invoice_id = p_invoice_id
        AND sd.product_id = p_product_id
        AND ROWNUM = 1;
        
        v_expiry_date := v_invoice_date + (v_warranty * 30);
        
        IF v_expiry_date >= SYSDATE THEN
            RETURN 'VALID - Expires: ' || TO_CHAR(v_expiry_date, 'DD-MON-YYYY');
        ELSE
            RETURN 'EXPIRED - Was valid until: ' || TO_CHAR(v_expiry_date, 'DD-MON-YYYY');
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'NO WARRANTY INFO FOUND';
        WHEN OTHERS THEN
            RETURN 'ERROR: ' || SQLERRM;
    END check_warranty_status;
    
    
    FUNCTION get_next_business_day(
        p_date          IN DATE DEFAULT SYSDATE
    ) RETURN DATE IS
        v_date DATE := p_date + 1;
    BEGIN
        -- Skip Saturday (7) and Sunday (1)
        WHILE TO_CHAR(v_date, 'D') IN ('1', '7') LOOP
            v_date := v_date + 1;
        END LOOP;
        RETURN v_date;
    END get_next_business_day;

END pkg_oxen_automation;
/

--------------------------------------------------------------------------------
-- ADDITIONAL AUTOMATION TRIGGERS
--------------------------------------------------------------------------------

-- Trigger: Auto-update sales master total when detail changes
CREATE OR REPLACE TRIGGER trg_sales_detail_au
AFTER INSERT OR UPDATE OR DELETE ON sales_detail
FOR EACH ROW
DECLARE
    v_invoice_id VARCHAR2(50);
    v_total      NUMBER;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_invoice_id := :NEW.invoice_id;
    ELSE
        v_invoice_id := :OLD.invoice_id;
    END IF;
    
    -- Calculate new total
    SELECT NVL(SUM((mrp * quantity) + NVL(vat, 0)), 0)
    INTO v_total
    FROM sales_detail
    WHERE invoice_id = v_invoice_id;
    
    -- Update sales master (don't update if status is completed)
    UPDATE sales_master
    SET grand_total = v_total - NVL(discount, 0)
    WHERE invoice_id = v_invoice_id
    AND status != 3;
    
END;
/

-- Trigger: Auto-update expense master total when detail changes
CREATE OR REPLACE TRIGGER trg_expense_detail_au
AFTER INSERT OR UPDATE OR DELETE ON expense_details
FOR EACH ROW
DECLARE
    v_expense_id VARCHAR2(50);
    v_total      NUMBER;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_expense_id := :NEW.expense_id;
    ELSE
        v_expense_id := :OLD.expense_id;
    END IF;
    
    -- This would be used if expense_master had a total column
    -- For now, just a placeholder for future enhancement
    NULL;
END;
/

-- Trigger: Auto-update order master total when detail changes
CREATE OR REPLACE TRIGGER trg_order_detail_au
AFTER INSERT OR UPDATE OR DELETE ON product_order_detail
FOR EACH ROW
DECLARE
    v_order_id VARCHAR2(50);
    v_total    NUMBER;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_order_id := :NEW.order_id;
    ELSE
        v_order_id := :OLD.order_id;
    END IF;
    
    -- Calculate new total
    SELECT NVL(SUM(purchase_price * quantity), 0)
    INTO v_total
    FROM product_order_detail
    WHERE order_id = v_order_id;
    
    -- Update order master
    UPDATE product_order_master
    SET total_amount = v_total,
        grand_total = v_total + NVL(vat, 0)
    WHERE order_id = v_order_id
    AND status = 1;
    
END;
/

COMMIT;

--------------------------------------------------------------------------------
-- END OF AUTOMATION PACKAGE
--------------------------------------------------------------------------------
