--------------------------------------------------------------------------------
-- AUTOMATION PACKAGE FOR ORACLE 11G FORMS AND ORACLE APEX
-- File: automation_package.sql
-- Description: Contains views, packages, and triggers for maximum automation
-- Compatible with: Oracle 11g, Oracle Forms 11g, Oracle APEX 4.x and above
-- Author: System Enhancement for Oxen Company Limited
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- SECTION 1: LOV (LIST OF VALUES) VIEWS FOR FORMS AND APEX
-- These views provide standardized dropdowns for application development
--------------------------------------------------------------------------------

-- LOV View: Active Customers
CREATE OR REPLACE VIEW v_lov_customers AS
SELECT customer_id, 
       customer_name || ' - ' || NVL(phone_no, 'N/A') AS display_value,
       customer_id AS return_value
FROM customers
WHERE NVL(status, 1) = 1
ORDER BY customer_name;

-- LOV View: Active Suppliers  
CREATE OR REPLACE VIEW v_lov_suppliers AS
SELECT supplier_id,
       supplier_name || ' - ' || NVL(phone_no, 'N/A') AS display_value,
       supplier_id AS return_value
FROM suppliers
WHERE NVL(status, 1) = 1
ORDER BY supplier_name;

-- LOV View: Active Products
CREATE OR REPLACE VIEW v_lov_products AS
SELECT product_id,
       product_name || ' (' || NVL(product_code, 'N/A') || ')' AS display_value,
       product_id AS return_value,
       mrp,
       purchase_price
FROM products
WHERE NVL(status, 1) = 1
ORDER BY product_name;

-- LOV View: Active Employees
CREATE OR REPLACE VIEW v_lov_employees AS
SELECT employee_id,
       first_name || ' ' || last_name AS display_value,
       employee_id AS return_value
FROM employees
WHERE NVL(status, 1) = 1
ORDER BY last_name, first_name;

-- LOV View: Active Departments
CREATE OR REPLACE VIEW v_lov_departments AS
SELECT department_id,
       department_name AS display_value,
       department_id AS return_value
FROM departments
WHERE NVL(status, 1) = 1
ORDER BY department_name;

-- LOV View: Active Jobs
CREATE OR REPLACE VIEW v_lov_jobs AS
SELECT job_id,
       job_title || ' (Grade: ' || NVL(job_grade, 'N/A') || ')' AS display_value,
       job_id AS return_value
FROM jobs
WHERE NVL(status, 1) = 1
ORDER BY job_title;

-- LOV View: Product Categories
CREATE OR REPLACE VIEW v_lov_product_categories AS
SELECT product_cat_id,
       product_cat_name AS display_value,
       product_cat_id AS return_value
FROM product_categories
WHERE NVL(status, 1) = 1
ORDER BY product_cat_name;

-- LOV View: Sub Categories (with parent category filter capability)
CREATE OR REPLACE VIEW v_lov_sub_categories AS
SELECT sub_cat_id,
       sub_cat_name AS display_value,
       sub_cat_id AS return_value,
       product_cat_id
FROM sub_categories
WHERE NVL(status, 1) = 1
ORDER BY sub_cat_name;

-- LOV View: Brands
CREATE OR REPLACE VIEW v_lov_brands AS
SELECT brand_id,
       brand_name || ' - ' || NVL(model_name, 'N/A') AS display_value,
       brand_id AS return_value
FROM brand
WHERE NVL(status, 1) = 1
ORDER BY brand_name;

-- LOV View: Parts Categories
CREATE OR REPLACE VIEW v_lov_parts_categories AS
SELECT parts_cat_id,
       parts_cat_name AS display_value,
       parts_cat_id AS return_value
FROM parts_category
WHERE NVL(status, 1) = 1
ORDER BY parts_cat_name;

-- LOV View: Parts
CREATE OR REPLACE VIEW v_lov_parts AS
SELECT parts_id,
       parts_name || ' (' || NVL(parts_code, 'N/A') || ')' AS display_value,
       parts_id AS return_value,
       mrp,
       purchase_price
FROM parts
WHERE NVL(status, 1) = 1
ORDER BY parts_name;

-- LOV View: Service List
CREATE OR REPLACE VIEW v_lov_services AS
SELECT servicelist_id,
       service_name || ' - ' || TO_CHAR(service_cost) || ' BDT' AS display_value,
       servicelist_id AS return_value,
       service_cost
FROM service_list
WHERE NVL(status, 1) = 1
ORDER BY service_name;

-- LOV View: Expense Types
CREATE OR REPLACE VIEW v_lov_expense_types AS
SELECT expense_type_id,
       type_name || ' (' || NVL(expense_code, 'N/A') || ')' AS display_value,
       expense_type_id AS return_value,
       default_amount
FROM expense_list
WHERE NVL(status, 1) = 1
ORDER BY type_name;

-- LOV View: Companies
CREATE OR REPLACE VIEW v_lov_companies AS
SELECT company_id,
       company_name AS display_value,
       company_id AS return_value
FROM company
WHERE NVL(status, 1) = 1
ORDER BY company_name;

-- LOV View: Sales Invoices (for returns and service references)
CREATE OR REPLACE VIEW v_lov_sales_invoices AS
SELECT invoice_id,
       invoice_id || ' - ' || TO_CHAR(invoice_date, 'DD-MON-YYYY') || ' (' || 
       NVL((SELECT customer_name FROM customers c WHERE c.customer_id = s.customer_id), 'Walk-in') || ')' AS display_value,
       invoice_id AS return_value,
       customer_id,
       invoice_date,
       grand_total
FROM sales_master s
WHERE NVL(status, 1) = 1
ORDER BY invoice_date DESC;

-- LOV View: Product Orders (for receiving references)
CREATE OR REPLACE VIEW v_lov_product_orders AS
SELECT order_id,
       order_id || ' - ' || TO_CHAR(order_date, 'DD-MON-YYYY') AS display_value,
       order_id AS return_value,
       supplier_id,
       order_date
FROM product_order_master
WHERE NVL(status, 1) = 1
ORDER BY order_date DESC;

-- LOV View: Receive Masters (for return references)
CREATE OR REPLACE VIEW v_lov_receive_masters AS
SELECT receive_id,
       receive_id || ' (' || NVL(sup_invoice_id, 'N/A') || ')' AS display_value,
       receive_id AS return_value,
       supplier_id,
       order_id
FROM product_receive_master
WHERE NVL(status, 1) = 1
ORDER BY receive_date DESC;

--------------------------------------------------------------------------------
-- SECTION 2: REPORT VIEWS FOR APEX INTERACTIVE REPORTS
-- These views provide comprehensive data for reporting
--------------------------------------------------------------------------------

-- Report View: Product Inventory with Stock
CREATE OR REPLACE VIEW v_rpt_product_inventory AS
SELECT 
    p.product_id,
    p.product_code,
    p.product_name,
    pc.product_cat_name AS category,
    sc.sub_cat_name AS sub_category,
    b.brand_name,
    b.model_name,
    s.supplier_name,
    p.uom,
    p.mrp,
    p.purchase_price,
    p.warranty,
    NVL(stk.quantity, 0) AS stock_quantity,
    CASE 
        WHEN NVL(stk.quantity, 0) = 0 THEN 'Out of Stock'
        WHEN NVL(stk.quantity, 0) < 5 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status,
    p.status,
    p.cre_dt
FROM products p
LEFT JOIN product_categories pc ON p.category_id = pc.product_cat_id
LEFT JOIN sub_categories sc ON p.sub_cat_id = sc.sub_cat_id
LEFT JOIN brand b ON p.brand_id = b.brand_id
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN stock stk ON p.product_id = stk.product_id;

-- Report View: Sales Summary
CREATE OR REPLACE VIEW v_rpt_sales_summary AS
SELECT 
    sm.invoice_id,
    sm.invoice_date,
    c.customer_name,
    c.phone_no AS customer_phone,
    e.first_name || ' ' || e.last_name AS sales_person,
    sm.discount,
    sm.adjust_amount,
    sm.grand_total,
    (SELECT COUNT(*) FROM sales_detail WHERE invoice_id = sm.invoice_id) AS item_count,
    sm.status,
    CASE sm.status 
        WHEN 1 THEN 'Active'
        WHEN 0 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS status_desc
FROM sales_master sm
LEFT JOIN customers c ON sm.customer_id = c.customer_id
LEFT JOIN employees e ON sm.sales_by = e.employee_id;

-- Report View: Service Tracking
CREATE OR REPLACE VIEW v_rpt_service_tracking AS
SELECT 
    sv.service_id,
    sv.service_date,
    c.customer_name,
    c.phone_no AS customer_phone,
    sl.service_name,
    sv.warranty_applicable,
    sm.invoice_id AS original_invoice,
    e.first_name || ' ' || e.last_name AS technician,
    sv.service_charge,
    sv.parts_price,
    sv.total_price,
    sv.status,
    CASE sv.status 
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'In Progress'
        WHEN 3 THEN 'Completed'
        WHEN 0 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS status_desc
FROM service_master sv
LEFT JOIN customers c ON sv.customer_id = c.customer_id
LEFT JOIN service_list sl ON sv.servicelist_id = sl.servicelist_id
LEFT JOIN employees e ON sv.service_by = e.employee_id
LEFT JOIN sales_master sm ON sv.invoice_id = sm.invoice_id;

-- Report View: Supplier Ledger
CREATE OR REPLACE VIEW v_rpt_supplier_ledger AS
SELECT 
    supplier_id,
    supplier_name,
    phone_no,
    email,
    contact_person,
    cp_phone_no,
    purchase_total,
    pay_total,
    (NVL(purchase_total, 0) - NVL(pay_total, 0)) AS due_amount,
    CASE 
        WHEN (NVL(purchase_total, 0) - NVL(pay_total, 0)) > 0 THEN 'Due'
        WHEN (NVL(purchase_total, 0) - NVL(pay_total, 0)) < 0 THEN 'Advance'
        ELSE 'Settled'
    END AS payment_status,
    status
FROM suppliers;

-- Report View: Employee Directory
CREATE OR REPLACE VIEW v_rpt_employee_directory AS
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.email,
    e.phone_no,
    e.address,
    e.hire_date,
    e.salary,
    j.job_title,
    j.job_grade,
    d.department_name,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    e.status,
    CASE e.status 
        WHEN 1 THEN 'Active'
        WHEN 0 THEN 'Inactive'
        ELSE 'Unknown'
    END AS status_desc
FROM employees e
LEFT JOIN jobs j ON e.job_id = j.job_id
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN employees mgr ON e.manager_id = mgr.employee_id;

-- Report View: Purchase Order Summary
CREATE OR REPLACE VIEW v_rpt_purchase_orders AS
SELECT 
    pom.order_id,
    pom.order_date,
    s.supplier_name,
    pom.expected_delivery_date,
    e.first_name || ' ' || e.last_name AS ordered_by,
    pom.total_amount,
    pom.vat,
    pom.grand_total,
    (SELECT COUNT(*) FROM product_order_detail WHERE order_id = pom.order_id) AS item_count,
    pom.status,
    CASE pom.status 
        WHEN 1 THEN 'Open'
        WHEN 2 THEN 'Partially Received'
        WHEN 3 THEN 'Fully Received'
        WHEN 0 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS status_desc
FROM product_order_master pom
LEFT JOIN suppliers s ON pom.supplier_id = s.supplier_id
LEFT JOIN employees e ON pom.order_by = e.employee_id;

-- Report View: Daily Sales
CREATE OR REPLACE VIEW v_rpt_daily_sales AS
SELECT 
    TRUNC(invoice_date) AS sales_date,
    COUNT(invoice_id) AS total_invoices,
    SUM(grand_total) AS total_sales,
    SUM(discount) AS total_discount,
    AVG(grand_total) AS avg_sale_value
FROM sales_master
WHERE NVL(status, 1) = 1
GROUP BY TRUNC(invoice_date)
ORDER BY sales_date DESC;

-- Report View: Expense Summary
CREATE OR REPLACE VIEW v_rpt_expense_summary AS
SELECT 
    em.expense_id,
    em.expense_date,
    el.type_name AS expense_type,
    el.expense_code,
    em.expense_by,
    em.remarks,
    (SELECT SUM(NVL(line_total, 0)) FROM expense_details WHERE expense_id = em.expense_id) AS total_amount,
    em.status
FROM expense_master em
LEFT JOIN expense_list el ON em.expense_type_id = el.expense_type_id;

-- Report View: Stock Movement
CREATE OR REPLACE VIEW v_rpt_stock_movement AS
SELECT 
    s.stock_id,
    p.product_code,
    p.product_name,
    sup.supplier_name,
    pc.product_cat_name AS category,
    s.quantity,
    s.last_update,
    CASE 
        WHEN s.quantity = 0 THEN 'Out of Stock'
        WHEN s.quantity < 5 THEN 'Critical'
        WHEN s.quantity < 10 THEN 'Low'
        ELSE 'Normal'
    END AS stock_level,
    s.status
FROM stock s
LEFT JOIN products p ON s.product_id = p.product_id
LEFT JOIN suppliers sup ON s.supplier_id = sup.supplier_id
LEFT JOIN product_categories pc ON s.product_cat_id = pc.product_cat_id;

--------------------------------------------------------------------------------
-- SECTION 3: AUTOMATION PACKAGE FOR BUSINESS LOGIC
-- Provides standardized procedures for CRUD and business operations
--------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_automation AS
    -- Constants for status values
    c_status_active   CONSTANT NUMBER := 1;
    c_status_inactive CONSTANT NUMBER := 0;
    
    -- Procedure to calculate and update sales master totals
    PROCEDURE calc_sales_total(p_invoice_id IN VARCHAR2);
    
    -- Procedure to calculate and update order master totals
    PROCEDURE calc_order_total(p_order_id IN VARCHAR2);
    
    -- Procedure to calculate and update receive master totals
    PROCEDURE calc_receive_total(p_receive_id IN VARCHAR2);
    
    -- Procedure to calculate and update return master totals
    PROCEDURE calc_return_total(p_return_id IN VARCHAR2);
    
    -- Procedure to calculate and update service master totals
    PROCEDURE calc_service_total(p_service_id IN VARCHAR2);
    
    -- Procedure to update stock after product receive
    PROCEDURE update_stock_on_receive(p_product_id IN VARCHAR2, p_quantity IN NUMBER, p_supplier_id IN VARCHAR2);
    
    -- Procedure to update stock after sales
    PROCEDURE update_stock_on_sale(p_product_id IN VARCHAR2, p_quantity IN NUMBER);
    
    -- Procedure to update stock after sales return
    PROCEDURE update_stock_on_sales_return(p_product_id IN VARCHAR2, p_quantity IN NUMBER);
    
    -- Procedure to update stock after product return to supplier
    PROCEDURE update_stock_on_product_return(p_product_id IN VARCHAR2, p_quantity IN NUMBER);
    
    -- Procedure to update stock after damage
    PROCEDURE update_stock_on_damage(p_product_id IN VARCHAR2, p_quantity IN NUMBER);
    
    -- Procedure to update supplier totals after payment
    PROCEDURE update_supplier_on_payment(p_supplier_id IN VARCHAR2, p_amount IN NUMBER);
    
    -- Function to get next sequence value with prefix
    FUNCTION get_next_id(p_seq_name IN VARCHAR2, p_prefix IN VARCHAR2) RETURN VARCHAR2;
    
    -- Function to check if product is in stock
    FUNCTION is_in_stock(p_product_id IN VARCHAR2, p_quantity IN NUMBER) RETURN BOOLEAN;
    
    -- Function to get current stock quantity
    FUNCTION get_stock_quantity(p_product_id IN VARCHAR2) RETURN NUMBER;
    
    -- Procedure to recalculate expense master totals
    PROCEDURE calc_expense_total(p_expense_id IN VARCHAR2);

END pkg_automation;
/

CREATE OR REPLACE PACKAGE BODY pkg_automation AS

    -- Calculate and update sales master totals
    PROCEDURE calc_sales_total(p_invoice_id IN VARCHAR2) IS
        v_total NUMBER := 0;
        v_vat_total NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(NVL(mrp, 0) * NVL(quantity, 0)), 0),
               NVL(SUM(NVL(vat, 0)), 0)
        INTO v_total, v_vat_total
        FROM sales_detail
        WHERE invoice_id = p_invoice_id;
        
        UPDATE sales_master
        SET grand_total = v_total + v_vat_total - NVL(discount, 0) - NVL(adjust_amount, 0),
            upd_dt = SYSDATE,
            upd_by = USER
        WHERE invoice_id = p_invoice_id;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error calculating sales total: ' || SQLERRM);
    END calc_sales_total;

    -- Calculate and update order master totals
    PROCEDURE calc_order_total(p_order_id IN VARCHAR2) IS
        v_total NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(NVL(purchase_price, 0) * NVL(quantity, 0)), 0)
        INTO v_total
        FROM product_order_detail
        WHERE order_id = p_order_id;
        
        UPDATE product_order_master
        SET total_amount = v_total,
            grand_total = v_total + NVL(vat, 0),
            upd_dt = SYSDATE,
            upd_by = USER
        WHERE order_id = p_order_id;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Error calculating order total: ' || SQLERRM);
    END calc_order_total;

    -- Calculate and update receive master totals
    PROCEDURE calc_receive_total(p_receive_id IN VARCHAR2) IS
        v_total NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(NVL(purchase_price, 0) * NVL(receive_quantity, 0)), 0)
        INTO v_total
        FROM product_receive_details
        WHERE receive_id = p_receive_id;
        
        UPDATE product_receive_master
        SET total_amount = v_total,
            grand_total = v_total + NVL(vat, 0),
            upd_dt = SYSDATE,
            upd_by = USER
        WHERE receive_id = p_receive_id;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20003, 'Error calculating receive total: ' || SQLERRM);
    END calc_receive_total;

    -- Calculate and update return master totals
    PROCEDURE calc_return_total(p_return_id IN VARCHAR2) IS
        v_total NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(NVL(purchase_price, 0) * NVL(return_quantity, 0)), 0)
        INTO v_total
        FROM product_return_details
        WHERE return_id = p_return_id;
        
        UPDATE product_return_master
        SET total_amount = v_total,
            grand_total = v_total - NVL(adjusted_vat, 0),
            upd_dt = SYSDATE,
            upd_by = USER
        WHERE return_id = p_return_id;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20004, 'Error calculating return total: ' || SQLERRM);
    END calc_return_total;

    -- Calculate and update service master totals
    PROCEDURE calc_service_total(p_service_id IN VARCHAR2) IS
        v_parts_total NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(NVL(total_service_cost, 0)), 0)
        INTO v_parts_total
        FROM service_details
        WHERE service_id = p_service_id;
        
        UPDATE service_master
        SET parts_price = v_parts_total,
            total_price = NVL(service_charge, 0) + v_parts_total,
            upd_dt = SYSDATE,
            upd_by = USER
        WHERE service_id = p_service_id;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20005, 'Error calculating service total: ' || SQLERRM);
    END calc_service_total;

    -- Update stock on product receive
    PROCEDURE update_stock_on_receive(p_product_id IN VARCHAR2, p_quantity IN NUMBER, p_supplier_id IN VARCHAR2) IS
        v_stock_exists NUMBER;
        v_product_cat_id VARCHAR2(50);
        v_sub_cat_id VARCHAR2(50);
    BEGIN
        -- Get product category info
        SELECT category_id, sub_cat_id 
        INTO v_product_cat_id, v_sub_cat_id
        FROM products 
        WHERE product_id = p_product_id;
        
        SELECT COUNT(*) INTO v_stock_exists
        FROM stock
        WHERE product_id = p_product_id;
        
        IF v_stock_exists > 0 THEN
            UPDATE stock
            SET quantity = quantity + p_quantity,
                last_update = SYSTIMESTAMP,
                upd_dt = SYSDATE,
                upd_by = USER
            WHERE product_id = p_product_id;
        ELSE
            INSERT INTO stock (product_id, supplier_id, product_cat_id, sub_cat_id, quantity)
            VALUES (p_product_id, p_supplier_id, v_product_cat_id, v_sub_cat_id, p_quantity);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20006, 'Error updating stock on receive: ' || SQLERRM);
    END update_stock_on_receive;

    -- Update stock on sale
    PROCEDURE update_stock_on_sale(p_product_id IN VARCHAR2, p_quantity IN NUMBER) IS
        v_current_stock NUMBER;
    BEGIN
        SELECT NVL(quantity, 0) INTO v_current_stock
        FROM stock
        WHERE product_id = p_product_id;
        
        IF v_current_stock < p_quantity THEN
            RAISE_APPLICATION_ERROR(-20010, 'Insufficient stock for product: ' || p_product_id);
        END IF;
        
        UPDATE stock
        SET quantity = quantity - p_quantity,
            last_update = SYSTIMESTAMP,
            upd_dt = SYSDATE,
            upd_by = USER
        WHERE product_id = p_product_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20011, 'Product not found in stock: ' || p_product_id);
        WHEN OTHERS THEN
            RAISE;
    END update_stock_on_sale;

    -- Update stock on sales return
    PROCEDURE update_stock_on_sales_return(p_product_id IN VARCHAR2, p_quantity IN NUMBER) IS
    BEGIN
        UPDATE stock
        SET quantity = quantity + p_quantity,
            last_update = SYSTIMESTAMP,
            upd_dt = SYSDATE,
            upd_by = USER
        WHERE product_id = p_product_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20012, 'Product not found in stock: ' || p_product_id);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END update_stock_on_sales_return;

    -- Update stock on product return to supplier
    PROCEDURE update_stock_on_product_return(p_product_id IN VARCHAR2, p_quantity IN NUMBER) IS
        v_current_stock NUMBER;
    BEGIN
        SELECT NVL(quantity, 0) INTO v_current_stock
        FROM stock
        WHERE product_id = p_product_id;
        
        IF v_current_stock < p_quantity THEN
            RAISE_APPLICATION_ERROR(-20013, 'Insufficient stock for return: ' || p_product_id);
        END IF;
        
        UPDATE stock
        SET quantity = quantity - p_quantity,
            last_update = SYSTIMESTAMP,
            upd_dt = SYSDATE,
            upd_by = USER
        WHERE product_id = p_product_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20014, 'Product not found in stock: ' || p_product_id);
        WHEN OTHERS THEN
            RAISE;
    END update_stock_on_product_return;

    -- Update stock on damage
    PROCEDURE update_stock_on_damage(p_product_id IN VARCHAR2, p_quantity IN NUMBER) IS
        v_current_stock NUMBER;
    BEGIN
        SELECT NVL(quantity, 0) INTO v_current_stock
        FROM stock
        WHERE product_id = p_product_id;
        
        IF v_current_stock < p_quantity THEN
            RAISE_APPLICATION_ERROR(-20015, 'Insufficient stock for damage record: ' || p_product_id);
        END IF;
        
        UPDATE stock
        SET quantity = quantity - p_quantity,
            last_update = SYSTIMESTAMP,
            upd_dt = SYSDATE,
            upd_by = USER
        WHERE product_id = p_product_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20016, 'Product not found in stock: ' || p_product_id);
        WHEN OTHERS THEN
            RAISE;
    END update_stock_on_damage;

    -- Update supplier totals after payment
    PROCEDURE update_supplier_on_payment(p_supplier_id IN VARCHAR2, p_amount IN NUMBER) IS
    BEGIN
        UPDATE suppliers
        SET pay_total = NVL(pay_total, 0) + p_amount,
            upd_dt = SYSDATE,
            upd_by = USER
        WHERE supplier_id = p_supplier_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20017, 'Supplier not found: ' || p_supplier_id);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END update_supplier_on_payment;

    -- Get next sequence value with prefix
    FUNCTION get_next_id(p_seq_name IN VARCHAR2, p_prefix IN VARCHAR2) RETURN VARCHAR2 IS
        v_next_val NUMBER;
        v_sql VARCHAR2(200);
    BEGIN
        v_sql := 'SELECT ' || p_seq_name || '.NEXTVAL FROM DUAL';
        EXECUTE IMMEDIATE v_sql INTO v_next_val;
        RETURN p_prefix || TO_CHAR(v_next_val);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END get_next_id;

    -- Check if product is in stock
    FUNCTION is_in_stock(p_product_id IN VARCHAR2, p_quantity IN NUMBER) RETURN BOOLEAN IS
        v_stock NUMBER;
    BEGIN
        SELECT NVL(quantity, 0) INTO v_stock
        FROM stock
        WHERE product_id = p_product_id;
        
        RETURN v_stock >= p_quantity;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_in_stock;

    -- Get current stock quantity
    FUNCTION get_stock_quantity(p_product_id IN VARCHAR2) RETURN NUMBER IS
        v_stock NUMBER;
    BEGIN
        SELECT NVL(quantity, 0) INTO v_stock
        FROM stock
        WHERE product_id = p_product_id;
        
        RETURN v_stock;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN 0;
    END get_stock_quantity;

    -- Calculate expense totals
    PROCEDURE calc_expense_total(p_expense_id IN VARCHAR2) IS
        -- Note: expense_master doesn't have a total column, 
        -- but this procedure is ready if one is added
        v_total NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(NVL(line_total, 0)), 0)
        INTO v_total
        FROM expense_details
        WHERE expense_id = p_expense_id;
        
        -- If a total column is added to expense_master, uncomment:
        -- UPDATE expense_master
        -- SET total_amount = v_total,
        --     upd_dt = SYSDATE,
        --     upd_by = USER
        -- WHERE expense_id = p_expense_id;
        
        NULL; -- Placeholder
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20018, 'Error calculating expense total: ' || SQLERRM);
    END calc_expense_total;

END pkg_automation;
/

--------------------------------------------------------------------------------
-- SECTION 4: AUTOMATION TRIGGERS FOR MASTER-DETAIL CALCULATIONS
-- These triggers automatically update totals when detail records change
--------------------------------------------------------------------------------

-- Trigger: Auto-calculate sales totals after detail changes
CREATE OR REPLACE TRIGGER trg_sales_detail_calc
AFTER INSERT OR UPDATE OR DELETE ON sales_detail
FOR EACH ROW
BEGIN
    IF INSERTING OR UPDATING THEN
        pkg_automation.calc_sales_total(:NEW.invoice_id);
    ELSIF DELETING THEN
        pkg_automation.calc_sales_total(:OLD.invoice_id);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Suppress errors to avoid transaction issues
END;
/

-- Trigger: Auto-calculate order totals after detail changes
CREATE OR REPLACE TRIGGER trg_order_detail_calc
AFTER INSERT OR UPDATE OR DELETE ON product_order_detail
FOR EACH ROW
BEGIN
    IF INSERTING OR UPDATING THEN
        pkg_automation.calc_order_total(:NEW.order_id);
    ELSIF DELETING THEN
        pkg_automation.calc_order_total(:OLD.order_id);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Trigger: Auto-calculate receive totals and update stock after detail changes
CREATE OR REPLACE TRIGGER trg_receive_detail_calc
AFTER INSERT OR UPDATE OR DELETE ON product_receive_details
FOR EACH ROW
DECLARE
    v_supplier_id VARCHAR2(50);
BEGIN
    IF INSERTING THEN
        -- Get supplier ID from master
        SELECT supplier_id INTO v_supplier_id
        FROM product_receive_master
        WHERE receive_id = :NEW.receive_id;
        
        -- Update stock
        pkg_automation.update_stock_on_receive(:NEW.product_id, :NEW.receive_quantity, v_supplier_id);
        -- Calculate total
        pkg_automation.calc_receive_total(:NEW.receive_id);
        
    ELSIF UPDATING THEN
        -- Get supplier ID
        SELECT supplier_id INTO v_supplier_id
        FROM product_receive_master
        WHERE receive_id = :NEW.receive_id;
        
        -- Adjust stock for difference
        IF :NEW.receive_quantity <> :OLD.receive_quantity THEN
            IF :NEW.receive_quantity > :OLD.receive_quantity THEN
                pkg_automation.update_stock_on_receive(:NEW.product_id, :NEW.receive_quantity - :OLD.receive_quantity, v_supplier_id);
            ELSE
                pkg_automation.update_stock_on_product_return(:OLD.product_id, :OLD.receive_quantity - :NEW.receive_quantity);
            END IF;
        END IF;
        pkg_automation.calc_receive_total(:NEW.receive_id);
        
    ELSIF DELETING THEN
        -- Reduce stock
        pkg_automation.update_stock_on_product_return(:OLD.product_id, :OLD.receive_quantity);
        pkg_automation.calc_receive_total(:OLD.receive_id);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Trigger: Auto-calculate return totals and update stock after detail changes
CREATE OR REPLACE TRIGGER trg_return_detail_calc
AFTER INSERT OR UPDATE OR DELETE ON product_return_details
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        pkg_automation.update_stock_on_product_return(:NEW.product_id, :NEW.return_quantity);
        pkg_automation.calc_return_total(:NEW.return_id);
    ELSIF UPDATING THEN
        -- Adjust stock for difference
        IF :NEW.return_quantity <> :OLD.return_quantity THEN
            IF :NEW.return_quantity > :OLD.return_quantity THEN
                pkg_automation.update_stock_on_product_return(:NEW.product_id, :NEW.return_quantity - :OLD.return_quantity);
            ELSE
                pkg_automation.update_stock_on_receive(:OLD.product_id, :OLD.return_quantity - :NEW.return_quantity, NULL);
            END IF;
        END IF;
        pkg_automation.calc_return_total(:NEW.return_id);
    ELSIF DELETING THEN
        -- Restore stock
        pkg_automation.update_stock_on_receive(:OLD.product_id, :OLD.return_quantity, NULL);
        pkg_automation.calc_return_total(:OLD.return_id);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Trigger: Auto-calculate service totals after detail changes
CREATE OR REPLACE TRIGGER trg_service_detail_calc
AFTER INSERT OR UPDATE OR DELETE ON service_details
FOR EACH ROW
BEGIN
    IF INSERTING OR UPDATING THEN
        pkg_automation.calc_service_total(:NEW.service_id);
    ELSIF DELETING THEN
        pkg_automation.calc_service_total(:OLD.service_id);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Trigger: Auto-update stock on damage detail
CREATE OR REPLACE TRIGGER trg_damage_detail_stock
AFTER INSERT OR UPDATE OR DELETE ON damage_detail
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        pkg_automation.update_stock_on_damage(:NEW.product_id, :NEW.damage_quantity);
    ELSIF UPDATING THEN
        IF :NEW.damage_quantity <> :OLD.damage_quantity THEN
            IF :NEW.damage_quantity > :OLD.damage_quantity THEN
                pkg_automation.update_stock_on_damage(:NEW.product_id, :NEW.damage_quantity - :OLD.damage_quantity);
            ELSE
                pkg_automation.update_stock_on_receive(:OLD.product_id, :OLD.damage_quantity - :NEW.damage_quantity, NULL);
            END IF;
        END IF;
    ELSIF DELETING THEN
        -- Restore stock (damage cancelled)
        pkg_automation.update_stock_on_receive(:OLD.product_id, :OLD.damage_quantity, NULL);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Trigger: Update supplier payment totals
CREATE OR REPLACE TRIGGER trg_payment_supplier
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    IF :NEW.supplier_id IS NOT NULL THEN
        pkg_automation.update_supplier_on_payment(:NEW.supplier_id, :NEW.amount);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Trigger: Update supplier purchase totals after receive
CREATE OR REPLACE TRIGGER trg_receive_supplier_total
AFTER INSERT OR UPDATE ON product_receive_master
FOR EACH ROW
BEGIN
    IF INSERTING AND :NEW.supplier_id IS NOT NULL THEN
        UPDATE suppliers
        SET purchase_total = NVL(purchase_total, 0) + NVL(:NEW.grand_total, 0),
            upd_dt = SYSDATE,
            upd_by = USER
        WHERE supplier_id = :NEW.supplier_id;
    ELSIF UPDATING AND :NEW.supplier_id IS NOT NULL THEN
        UPDATE suppliers
        SET purchase_total = NVL(purchase_total, 0) + NVL(:NEW.grand_total, 0) - NVL(:OLD.grand_total, 0),
            upd_dt = SYSDATE,
            upd_by = USER
        WHERE supplier_id = :NEW.supplier_id;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

--------------------------------------------------------------------------------
-- SECTION 5: UTILITY VIEWS FOR ORACLE FORMS
-- These views support specific Forms functionality like master-detail blocks
--------------------------------------------------------------------------------

-- View: Sales Invoice with Details (for Forms master-detail)
CREATE OR REPLACE VIEW v_sales_invoice_detail AS
SELECT 
    sm.invoice_id,
    sm.invoice_date,
    sm.customer_id,
    c.customer_name,
    sm.discount,
    sm.grand_total AS invoice_total,
    sd.sales_det_id,
    sd.product_id,
    p.product_name,
    sd.mrp,
    sd.purchase_price,
    sd.quantity,
    sd.vat,
    (NVL(sd.mrp, 0) * NVL(sd.quantity, 0)) AS line_total,
    sd.description AS item_description
FROM sales_master sm
LEFT JOIN customers c ON sm.customer_id = c.customer_id
LEFT JOIN sales_detail sd ON sm.invoice_id = sd.invoice_id
LEFT JOIN products p ON sd.product_id = p.product_id;

-- View: Purchase Order with Details
CREATE OR REPLACE VIEW v_order_with_detail AS
SELECT 
    pom.order_id,
    pom.order_date,
    pom.supplier_id,
    s.supplier_name,
    pom.expected_delivery_date,
    pom.grand_total AS order_total,
    pod.order_detail_id,
    pod.product_id,
    p.product_name,
    pod.mrp,
    pod.purchase_price,
    pod.quantity,
    (NVL(pod.purchase_price, 0) * NVL(pod.quantity, 0)) AS line_total
FROM product_order_master pom
LEFT JOIN suppliers s ON pom.supplier_id = s.supplier_id
LEFT JOIN product_order_detail pod ON pom.order_id = pod.order_id
LEFT JOIN products p ON pod.product_id = p.product_id;

-- View: Product Receive with Details
CREATE OR REPLACE VIEW v_receive_with_detail AS
SELECT 
    prm.receive_id,
    prm.receive_date,
    prm.order_id,
    prm.sup_invoice_id,
    prm.supplier_id,
    s.supplier_name,
    prm.grand_total AS receive_total,
    prd.receive_det_id,
    prd.product_id,
    p.product_name,
    prd.mrp,
    prd.purchase_price,
    prd.receive_quantity,
    (NVL(prd.purchase_price, 0) * NVL(prd.receive_quantity, 0)) AS line_total
FROM product_receive_master prm
LEFT JOIN suppliers s ON prm.supplier_id = s.supplier_id
LEFT JOIN product_receive_details prd ON prm.receive_id = prd.receive_id
LEFT JOIN products p ON prd.product_id = p.product_id;

-- View: Service with Details
CREATE OR REPLACE VIEW v_service_with_detail AS
SELECT 
    sv.service_id,
    sv.service_date,
    sv.customer_id,
    c.customer_name,
    sv.warranty_applicable,
    sv.service_charge,
    sv.total_price,
    sd.service_det_id,
    sd.product_id,
    p.product_name,
    sd.parts_id,
    pt.parts_name,
    sd.quantity,
    sd.total_service_cost,
    sd.warranty_status,
    sd.description
FROM service_master sv
LEFT JOIN customers c ON sv.customer_id = c.customer_id
LEFT JOIN service_details sd ON sv.service_id = sd.service_id
LEFT JOIN products p ON sd.product_id = p.product_id
LEFT JOIN parts pt ON sd.parts_id = pt.parts_id;

--------------------------------------------------------------------------------
-- SECTION 6: DASHBOARD VIEWS FOR ORACLE APEX
-- These views provide summary data for APEX dashboard regions
--------------------------------------------------------------------------------

-- Dashboard: Sales Overview (Today, This Week, This Month)
CREATE OR REPLACE VIEW v_dash_sales_overview AS
SELECT 
    'Today' AS period,
    COUNT(invoice_id) AS total_invoices,
    NVL(SUM(grand_total), 0) AS total_sales
FROM sales_master
WHERE TRUNC(invoice_date) = TRUNC(SYSDATE)
AND NVL(status, 1) = 1
UNION ALL
SELECT 
    'This Week' AS period,
    COUNT(invoice_id) AS total_invoices,
    NVL(SUM(grand_total), 0) AS total_sales
FROM sales_master
WHERE invoice_date >= TRUNC(SYSDATE, 'IW')
AND NVL(status, 1) = 1
UNION ALL
SELECT 
    'This Month' AS period,
    COUNT(invoice_id) AS total_invoices,
    NVL(SUM(grand_total), 0) AS total_sales
FROM sales_master
WHERE invoice_date >= TRUNC(SYSDATE, 'MM')
AND NVL(status, 1) = 1;

-- Dashboard: Low Stock Alert
CREATE OR REPLACE VIEW v_dash_low_stock AS
SELECT 
    p.product_id,
    p.product_code,
    p.product_name,
    pc.product_cat_name AS category,
    NVL(s.quantity, 0) AS current_stock,
    CASE 
        WHEN NVL(s.quantity, 0) = 0 THEN 'OUT OF STOCK'
        WHEN NVL(s.quantity, 0) < 5 THEN 'CRITICAL'
        ELSE 'LOW'
    END AS alert_level
FROM products p
LEFT JOIN stock s ON p.product_id = s.product_id
LEFT JOIN product_categories pc ON p.category_id = pc.product_cat_id
WHERE NVL(s.quantity, 0) < 10
AND NVL(p.status, 1) = 1
ORDER BY NVL(s.quantity, 0);

-- Dashboard: Top Selling Products (Last 30 Days)
CREATE OR REPLACE VIEW v_dash_top_products AS
SELECT * FROM (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(sd.quantity) AS total_sold,
        SUM(NVL(sd.mrp, 0) * NVL(sd.quantity, 0)) AS total_revenue
    FROM sales_detail sd
    JOIN products p ON sd.product_id = p.product_id
    JOIN sales_master sm ON sd.invoice_id = sm.invoice_id
    WHERE sm.invoice_date >= SYSDATE - 30
    AND NVL(sm.status, 1) = 1
    GROUP BY p.product_id, p.product_name
    ORDER BY total_sold DESC
) WHERE ROWNUM <= 10;

-- Dashboard: Pending Orders
CREATE OR REPLACE VIEW v_dash_pending_orders AS
SELECT 
    order_id,
    order_date,
    supplier_id,
    (SELECT supplier_name FROM suppliers WHERE supplier_id = pom.supplier_id) AS supplier_name,
    expected_delivery_date,
    grand_total,
    CASE 
        WHEN expected_delivery_date < SYSDATE THEN 'OVERDUE'
        WHEN expected_delivery_date <= SYSDATE + 3 THEN 'DUE SOON'
        ELSE 'ON TRACK'
    END AS delivery_status
FROM product_order_master pom
WHERE status = 1  -- Open orders
ORDER BY expected_delivery_date;

-- Dashboard: Service Statistics
CREATE OR REPLACE VIEW v_dash_service_stats AS
SELECT 
    'Total Services' AS metric,
    TO_CHAR(COUNT(*)) AS value
FROM service_master
WHERE TRUNC(service_date, 'MM') = TRUNC(SYSDATE, 'MM')
UNION ALL
SELECT 
    'Warranty Services' AS metric,
    TO_CHAR(COUNT(*)) AS value
FROM service_master
WHERE warranty_applicable = 'Y'
AND TRUNC(service_date, 'MM') = TRUNC(SYSDATE, 'MM')
UNION ALL
SELECT 
    'Total Revenue' AS metric,
    TO_CHAR(NVL(SUM(total_price), 0), '999,999,999') AS value
FROM service_master
WHERE TRUNC(service_date, 'MM') = TRUNC(SYSDATE, 'MM');

-- Dashboard: Supplier Due Summary
CREATE OR REPLACE VIEW v_dash_supplier_dues AS
SELECT 
    supplier_id,
    supplier_name,
    purchase_total,
    pay_total,
    (NVL(purchase_total, 0) - NVL(pay_total, 0)) AS due_amount
FROM suppliers
WHERE (NVL(purchase_total, 0) - NVL(pay_total, 0)) > 0
AND NVL(status, 1) = 1
ORDER BY due_amount DESC;

--------------------------------------------------------------------------------
-- SECTION 7: FORMS TRIGGER CODE TEMPLATES
-- These are PL/SQL blocks for common Oracle Forms triggers
--------------------------------------------------------------------------------

/*
================================================================================
ORACLE FORMS TRIGGER CODE TEMPLATES
Copy these to your Oracle Forms triggers as needed
================================================================================

-- WHEN-NEW-FORM-INSTANCE (For populating all LOVs)
DECLARE
   rg_lov       RecordGroup;
   nDummy       NUMBER;
   
   PROCEDURE populate_lov(p_list_name VARCHAR2, p_query VARCHAR2, p_rg_name VARCHAR2) IS
      rg RecordGroup;
   BEGIN
      rg := Find_Group(p_rg_name);
      IF NOT Id_Null(rg) THEN
         Delete_Group(rg);
      END IF;
      rg := Create_Group_From_Query(p_rg_name, p_query);
      Clear_List(p_list_name);
      nDummy := Populate_Group(rg);
      Populate_List(p_list_name, rg);
   END;
BEGIN
   -- Populate Customer LOV
   populate_lov('BLOCK.CUSTOMER_ID', 
                'SELECT display_value, return_value FROM v_lov_customers', 
                'RG_CUSTOMERS');
   
   -- Populate Supplier LOV
   populate_lov('BLOCK.SUPPLIER_ID', 
                'SELECT display_value, return_value FROM v_lov_suppliers', 
                'RG_SUPPLIERS');
   
   -- Populate Product LOV
   populate_lov('BLOCK.PRODUCT_ID', 
                'SELECT display_value, return_value FROM v_lov_products', 
                'RG_PRODUCTS');
   
   -- Populate Employee LOV
   populate_lov('BLOCK.EMPLOYEE_ID', 
                'SELECT display_value, return_value FROM v_lov_employees', 
                'RG_EMPLOYEES');
END;

-- WHEN-VALIDATE-ITEM (For Product selection - auto-fill prices)
DECLARE
   v_mrp NUMBER;
   v_purchase_price NUMBER;
BEGIN
   SELECT mrp, purchase_price
   INTO v_mrp, v_purchase_price
   FROM v_lov_products
   WHERE return_value = :BLOCK.PRODUCT_ID;
   
   :BLOCK.MRP := v_mrp;
   :BLOCK.PURCHASE_PRICE := v_purchase_price;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
END;

-- POST-QUERY (For calculating line totals)
BEGIN
   :BLOCK.LINE_TOTAL := NVL(:BLOCK.MRP, 0) * NVL(:BLOCK.QUANTITY, 0);
END;

-- WHEN-VALIDATE-ITEM on QUANTITY (Recalculate line total)
BEGIN
   :BLOCK.LINE_TOTAL := NVL(:BLOCK.MRP, 0) * NVL(:BLOCK.QUANTITY, 0);
   
   -- Optionally call package to recalculate master total
   -- pkg_automation.calc_sales_total(:MASTER_BLOCK.INVOICE_ID);
END;

-- PRE-INSERT (Set audit columns)
BEGIN
   :BLOCK.CRE_BY := USER;
   :BLOCK.CRE_DT := SYSDATE;
   :BLOCK.STATUS := 1;
END;

-- PRE-UPDATE (Set audit columns)
BEGIN
   :BLOCK.UPD_BY := USER;
   :BLOCK.UPD_DT := SYSDATE;
END;

================================================================================
*/

--------------------------------------------------------------------------------
-- GRANT STATEMENTS (Run as DBA if needed)
-- Uncomment and modify schema name as needed
--------------------------------------------------------------------------------

/*
-- Grant execute on package to application user
GRANT EXECUTE ON pkg_automation TO app_user;

-- Grant select on views to application user
GRANT SELECT ON v_lov_customers TO app_user;
GRANT SELECT ON v_lov_suppliers TO app_user;
GRANT SELECT ON v_lov_products TO app_user;
GRANT SELECT ON v_lov_employees TO app_user;
GRANT SELECT ON v_lov_departments TO app_user;
GRANT SELECT ON v_lov_jobs TO app_user;
GRANT SELECT ON v_lov_product_categories TO app_user;
GRANT SELECT ON v_lov_sub_categories TO app_user;
GRANT SELECT ON v_lov_brands TO app_user;
GRANT SELECT ON v_lov_parts_categories TO app_user;
GRANT SELECT ON v_lov_parts TO app_user;
GRANT SELECT ON v_lov_services TO app_user;
GRANT SELECT ON v_lov_expense_types TO app_user;
GRANT SELECT ON v_lov_companies TO app_user;
GRANT SELECT ON v_lov_sales_invoices TO app_user;
GRANT SELECT ON v_lov_product_orders TO app_user;
GRANT SELECT ON v_lov_receive_masters TO app_user;

-- Grant select on report views
GRANT SELECT ON v_rpt_product_inventory TO app_user;
GRANT SELECT ON v_rpt_sales_summary TO app_user;
GRANT SELECT ON v_rpt_service_tracking TO app_user;
GRANT SELECT ON v_rpt_supplier_ledger TO app_user;
GRANT SELECT ON v_rpt_employee_directory TO app_user;
GRANT SELECT ON v_rpt_purchase_orders TO app_user;
GRANT SELECT ON v_rpt_daily_sales TO app_user;
GRANT SELECT ON v_rpt_expense_summary TO app_user;
GRANT SELECT ON v_rpt_stock_movement TO app_user;

-- Grant select on dashboard views
GRANT SELECT ON v_dash_sales_overview TO app_user;
GRANT SELECT ON v_dash_low_stock TO app_user;
GRANT SELECT ON v_dash_top_products TO app_user;
GRANT SELECT ON v_dash_pending_orders TO app_user;
GRANT SELECT ON v_dash_service_stats TO app_user;
GRANT SELECT ON v_dash_supplier_dues TO app_user;
*/

--------------------------------------------------------------------------------
-- END OF AUTOMATION PACKAGE
--------------------------------------------------------------------------------

COMMIT;
