--------------------------------------------------------------------------------
-- ORACLE FORMS 11G - TEST QUERIES AND VALIDATION SCRIPTS
-- Oxen Company Limited - Electronics Sales & Service Provider
--------------------------------------------------------------------------------
-- Purpose: Test queries for validating schema and form development
-- Database: Oracle 11g+
-- Schema: msp/msp
-- Related: ORACLE_FORMS_11G_ARCHITECTURE_GUIDE.md
--------------------------------------------------------------------------------

-- Connect to database
CONNECT msp/msp;

SET SERVEROUTPUT ON;
SET LINESIZE 200;
SET PAGESIZE 100;

--------------------------------------------------------------------------------
-- SECTION 1: SCHEMA VALIDATION
--------------------------------------------------------------------------------

PROMPT ========================================
PROMPT Section 1: Schema Validation
PROMPT ========================================

-- 1.1 Count all tables (should be 33)
PROMPT
PROMPT 1.1 Verify all 33 tables exist:
SELECT COUNT(*) AS table_count FROM user_tables;

-- 1.2 List all tables
PROMPT
PROMPT 1.2 List of all tables:
SELECT table_name 
FROM user_tables 
ORDER BY table_name;

-- 1.3 List all sequences (should be 33)
PROMPT
PROMPT 1.3 List all sequences:
SELECT sequence_name 
FROM user_sequences 
ORDER BY sequence_name;

-- 1.4 List all triggers
PROMPT
PROMPT 1.4 List all triggers:
SELECT trigger_name, table_name, triggering_event, status
FROM user_triggers
ORDER BY table_name, trigger_name;

--------------------------------------------------------------------------------
-- SECTION 2: PRIMARY KEYS VALIDATION
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Section 2: Primary Keys Validation
PROMPT ========================================

-- 2.1 List all primary keys
PROMPT
PROMPT 2.1 All Primary Key Constraints:
SELECT 
    c.table_name,
    c.constraint_name,
    cc.column_name,
    c.status
FROM 
    user_constraints c
    JOIN user_cons_columns cc ON c.constraint_name = cc.constraint_name
WHERE 
    c.constraint_type = 'P'
ORDER BY 
    c.table_name;

-- 2.2 Tables without primary keys (should be empty)
PROMPT
PROMPT 2.2 Tables without Primary Keys (should return no rows):
SELECT table_name
FROM user_tables
WHERE table_name NOT IN (
    SELECT table_name 
    FROM user_constraints 
    WHERE constraint_type = 'P'
)
ORDER BY table_name;

--------------------------------------------------------------------------------
-- SECTION 3: FOREIGN KEY RELATIONSHIPS
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Section 3: Foreign Key Relationships
PROMPT ========================================

-- 3.1 List all foreign key relationships
PROMPT
PROMPT 3.1 All Foreign Key Relationships:
SELECT 
    c.table_name AS child_table,
    cc.column_name AS child_column,
    c.constraint_name,
    c.r_constraint_name,
    p.table_name AS parent_table,
    pc.column_name AS parent_column,
    c.delete_rule,
    c.status
FROM 
    user_constraints c
    JOIN user_cons_columns cc ON c.constraint_name = cc.constraint_name
    JOIN user_constraints p ON c.r_constraint_name = p.constraint_name
    JOIN user_cons_columns pc ON p.constraint_name = pc.constraint_name
WHERE 
    c.constraint_type = 'R'
ORDER BY 
    c.table_name, c.constraint_name;

-- 3.2 Count foreign keys per table
PROMPT
PROMPT 3.2 Foreign Key Count per Table:
SELECT 
    table_name,
    COUNT(*) AS fk_count
FROM 
    user_constraints
WHERE 
    constraint_type = 'R'
GROUP BY 
    table_name
ORDER BY 
    fk_count DESC, table_name;

-- 3.3 Master-Detail relationships
PROMPT
PROMPT 3.3 Master-Detail Table Pairs:
SELECT DISTINCT
    p.table_name AS master_table,
    c.table_name AS detail_table,
    c.constraint_name AS relationship
FROM 
    user_constraints c
    JOIN user_constraints p ON c.r_constraint_name = p.constraint_name
WHERE 
    c.constraint_type = 'R'
    AND (c.table_name LIKE '%_detail%' OR c.table_name LIKE '%_details')
ORDER BY 
    p.table_name, c.table_name;

--------------------------------------------------------------------------------
-- SECTION 4: USER AUTHENTICATION TABLE VALIDATION
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Section 4: User Authentication Validation
PROMPT ========================================

-- 4.1 Verify com_users table structure
PROMPT
PROMPT 4.1 COM_USERS table structure:
DESC com_users;

-- 4.2 Check if test users exist
PROMPT
PROMPT 4.2 Existing users in com_users table:
SELECT 
    user_id,
    user_name,
    role,
    employee_id,
    status,
    cre_dt
FROM 
    com_users
ORDER BY 
    cre_dt DESC;

-- 4.3 Insert test users if not exist
PROMPT
PROMPT 4.3 Creating test users...

-- Delete existing test users first
DELETE FROM com_users WHERE user_name IN ('admin', 'testuser', 'manager');
COMMIT;

-- Insert admin user
INSERT INTO com_users (user_name, password, role, status)
VALUES ('admin', 'admin123', 'administrator', 1);

-- Insert regular user
INSERT INTO com_users (user_name, password, role, status)
VALUES ('testuser', 'test123', 'user', 1);

-- Insert manager (if employees exist)
DECLARE
    v_emp_id VARCHAR2(50);
BEGIN
    -- Get first employee ID
    SELECT employee_id INTO v_emp_id
    FROM employees
    WHERE ROWNUM = 1;
    
    -- Insert manager user
    INSERT INTO com_users (user_name, password, role, employee_id, status)
    VALUES ('manager', 'manager123', 'manager', v_emp_id, 1);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Test users created successfully.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- No employees exist, insert without employee_id
        INSERT INTO com_users (user_name, password, role, status)
        VALUES ('manager', 'manager123', 'manager', 1);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Test users created (no employees found).');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error creating test users: ' || SQLERRM);
END;
/

-- Verify created users
PROMPT
PROMPT 4.4 Verify test users created:
SELECT 
    user_id,
    user_name,
    role,
    employee_id,
    status
FROM 
    com_users
WHERE 
    user_name IN ('admin', 'testuser', 'manager')
ORDER BY 
    user_name;

--------------------------------------------------------------------------------
-- SECTION 5: LOGIN FORM TEST QUERIES
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Section 5: Login Form Test Queries
PROMPT ========================================

-- 5.1 Test login query (valid user)
PROMPT
PROMPT 5.1 Test Login Query - Valid User (admin/admin123):
SELECT 
    u.user_id,
    u.user_name,
    u.role,
    u.employee_id,
    u.status,
    e.employee_name,
    d.department_name
FROM 
    com_users u
    LEFT JOIN employees e ON u.employee_id = e.employee_id
    LEFT JOIN departments d ON e.department_id = d.department_id
WHERE 
    UPPER(u.user_name) = UPPER('admin')
    AND u.password = 'admin123'
    AND u.status = 1;

-- 5.2 Test login query (invalid password)
PROMPT
PROMPT 5.2 Test Login Query - Invalid Password (should return no rows):
SELECT 
    u.user_id,
    u.user_name
FROM 
    com_users u
WHERE 
    UPPER(u.user_name) = UPPER('admin')
    AND u.password = 'wrongpassword'
    AND u.status = 1;

-- 5.3 Test login query (inactive user)
PROMPT
PROMPT 5.3 Test Login Query - Inactive User (should return no rows):
-- First, create an inactive user
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM com_users WHERE user_name = 'inactive_user';
    IF v_count = 0 THEN
        INSERT INTO com_users (user_name, password, role, status)
        VALUES ('inactive_user', 'test123', 'user', 0);
        COMMIT;
    END IF;
END;
/

SELECT 
    u.user_id,
    u.user_name,
    u.status
FROM 
    com_users u
WHERE 
    UPPER(u.user_name) = UPPER('inactive_user')
    AND u.password = 'test123'
    AND u.status = 1;

--------------------------------------------------------------------------------
-- SECTION 6: EMPLOYEE AND DEPARTMENT RELATIONSHIPS
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Section 6: Employee & Department Data
PROMPT ========================================

-- 6.1 List employees with their departments
PROMPT
PROMPT 6.1 Employees with Departments:
SELECT 
    e.employee_id,
    e.employee_name,
    e.phone_no,
    d.department_name,
    j.job_title,
    c.company_name
FROM 
    employees e
    LEFT JOIN departments d ON e.department_id = d.department_id
    LEFT JOIN jobs j ON e.job_id = j.job_id
    LEFT JOIN company c ON d.company_id = c.company_id
WHERE 
    e.status = 1
ORDER BY 
    e.employee_name;

-- 6.2 Employees with user accounts
PROMPT
PROMPT 6.2 Employees with User Accounts:
SELECT 
    e.employee_id,
    e.employee_name,
    u.user_name,
    u.role,
    u.status AS user_status
FROM 
    employees e
    JOIN com_users u ON e.employee_id = u.employee_id
WHERE 
    e.status = 1
    AND u.status = 1
ORDER BY 
    e.employee_name;

--------------------------------------------------------------------------------
-- SECTION 7: PRODUCT AND STOCK VALIDATION
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Section 7: Product & Stock Data
PROMPT ========================================

-- 7.1 Products with stock levels
PROMPT
PROMPT 7.1 Products with Current Stock:
SELECT 
    p.product_id,
    p.product_name,
    pc.product_cat_name,
    b.brand_name,
    s.quantity AS stock_quantity,
    s.purchase_price,
    s.last_update
FROM 
    products p
    LEFT JOIN product_categories pc ON p.category_id = pc.product_cat_id
    LEFT JOIN brand b ON p.brand_id = b.brand_id
    LEFT JOIN stock s ON p.product_id = s.product_id
WHERE 
    p.status = 1
ORDER BY 
    p.product_name;

-- 7.2 Low stock alert
PROMPT
PROMPT 7.2 Low Stock Alert (quantity < 10):
SELECT 
    p.product_id,
    p.product_name,
    s.quantity,
    p.reorder_level
FROM 
    products p
    JOIN stock s ON p.product_id = s.product_id
WHERE 
    p.status = 1
    AND s.quantity < 10
ORDER BY 
    s.quantity ASC;

-- 7.3 Product hierarchy (category → sub-category → products)
PROMPT
PROMPT 7.3 Product Hierarchy:
SELECT 
    pc.product_cat_name AS category,
    sc.sub_cat_name AS sub_category,
    COUNT(p.product_id) AS product_count
FROM 
    product_categories pc
    LEFT JOIN sub_categories sc ON pc.product_cat_id = sc.product_cat_id
    LEFT JOIN products p ON sc.sub_cat_id = p.sub_cat_id
WHERE 
    pc.status = 1
GROUP BY 
    pc.product_cat_name, sc.sub_cat_name
ORDER BY 
    pc.product_cat_name, sc.sub_cat_name;

--------------------------------------------------------------------------------
-- SECTION 8: SALES AND SERVICE DATA
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Section 8: Sales & Service Data
PROMPT ========================================

-- 8.1 Recent sales invoices
PROMPT
PROMPT 8.1 Recent Sales Invoices (Last 10):
SELECT 
    sm.invoice_id,
    sm.invoice_date,
    c.customer_name,
    c.phone_no,
    sm.subtotal,
    sm.vat,
    sm.discount,
    sm.grand_total,
    e.employee_name AS sales_person
FROM 
    sales_master sm
    LEFT JOIN customers c ON sm.customer_id = c.customer_id
    LEFT JOIN employees e ON sm.sales_by = e.employee_id
WHERE 
    sm.status = 1
ORDER BY 
    sm.invoice_date DESC
FETCH FIRST 10 ROWS ONLY;

-- 8.2 Sales detail with products
PROMPT
PROMPT 8.2 Sales Details (Last 20 line items):
SELECT 
    sm.invoice_id,
    sm.invoice_date,
    sd.product_id,
    p.product_name,
    sd.quantity,
    sd.unit_price,
    sd.vat,
    sd.total
FROM 
    sales_master sm
    JOIN sales_detail sd ON sm.invoice_id = sd.invoice_id
    JOIN products p ON sd.product_id = p.product_id
WHERE 
    sm.status = 1
ORDER BY 
    sm.invoice_date DESC, sd.invoice_id
FETCH FIRST 20 ROWS ONLY;

-- 8.3 Service tickets
PROMPT
PROMPT 8.3 Recent Service Tickets:
SELECT 
    sm.service_id,
    sm.service_date,
    c.customer_name,
    sl.service_name,
    sm.warranty_applicable,
    sm.service_charge,
    sm.status
FROM 
    service_master sm
    LEFT JOIN customers c ON sm.customer_id = c.customer_id
    LEFT JOIN service_list sl ON sm.servicelist_id = sl.servicelist_id
WHERE 
    sm.status = 1
ORDER BY 
    sm.service_date DESC
FETCH FIRST 10 ROWS ONLY;

--------------------------------------------------------------------------------
-- SECTION 9: SUPPLIER AND PURCHASE DATA
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Section 9: Supplier & Purchase Data
PROMPT ========================================

-- 9.1 Supplier list with purchase totals
PROMPT
PROMPT 9.1 Suppliers with Purchase Summary:
SELECT 
    s.supplier_id,
    s.supplier_name,
    s.phone_no,
    s.purchase_total,
    s.pay_total,
    s.due,
    s.status
FROM 
    suppliers s
WHERE 
    s.status = 1
ORDER BY 
    s.supplier_name;

-- 9.2 Recent purchase orders
PROMPT
PROMPT 9.2 Recent Purchase Orders:
SELECT 
    pom.order_id,
    pom.order_date,
    s.supplier_name,
    pom.total_items,
    pom.grand_total,
    e.employee_name AS ordered_by,
    pom.status
FROM 
    product_order_master pom
    LEFT JOIN suppliers s ON pom.supplier_id = s.supplier_id
    LEFT JOIN employees e ON pom.order_by = e.employee_id
WHERE 
    pom.status = 1
ORDER BY 
    pom.order_date DESC
FETCH FIRST 10 ROWS ONLY;

-- 9.3 Recent goods receipts
PROMPT
PROMPT 9.3 Recent Goods Receipts:
SELECT 
    prm.receive_id,
    prm.receive_date,
    s.supplier_name,
    prm.order_id,
    prm.grand_total,
    e.employee_name AS received_by
FROM 
    product_receive_master prm
    LEFT JOIN suppliers s ON prm.supplier_id = s.supplier_id
    LEFT JOIN employees e ON prm.received_by = e.employee_id
WHERE 
    prm.status = 1
ORDER BY 
    prm.receive_date DESC
FETCH FIRST 10 ROWS ONLY;

--------------------------------------------------------------------------------
-- SECTION 10: FORM DEVELOPMENT HELPER QUERIES
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Section 10: Form Development Helpers
PROMPT ========================================

-- 10.1 LOV Query for Customers
PROMPT
PROMPT 10.1 LOV Query - Customers:
SELECT 
    customer_id AS return_value,
    customer_name || ' (' || phone_no || ')' AS display_value
FROM 
    customers
WHERE 
    status = 1
ORDER BY 
    customer_name;

-- 10.2 LOV Query for Employees
PROMPT
PROMPT 10.2 LOV Query - Employees:
SELECT 
    employee_id AS return_value,
    employee_name || ' - ' || phone_no AS display_value
FROM 
    employees
WHERE 
    status = 1
ORDER BY 
    employee_name;

-- 10.3 LOV Query for Products
PROMPT
PROMPT 10.3 LOV Query - Products:
SELECT 
    p.product_id AS return_value,
    p.product_name || ' [' || b.brand_name || ']' AS display_value,
    s.quantity AS stock_quantity,
    p.mrp AS unit_price
FROM 
    products p
    LEFT JOIN brand b ON p.brand_id = b.brand_id
    LEFT JOIN stock s ON p.product_id = s.product_id
WHERE 
    p.status = 1
ORDER BY 
    p.product_name;

-- 10.4 LOV Query for Suppliers
PROMPT
PROMPT 10.4 LOV Query - Suppliers:
SELECT 
    supplier_id AS return_value,
    supplier_name || ' (' || phone_no || ')' AS display_value
FROM 
    suppliers
WHERE 
    status = 1
ORDER BY 
    supplier_name;

-- 10.5 LOV Query for Product Categories
PROMPT
PROMPT 10.5 LOV Query - Product Categories:
SELECT 
    product_cat_id AS return_value,
    product_cat_name AS display_value
FROM 
    product_categories
WHERE 
    status = 1
ORDER BY 
    product_cat_name;

-- 10.6 Cascading LOV - Sub-Categories by Category
PROMPT
PROMPT 10.6 Cascading LOV - Sub-Categories (example for first category):
DECLARE
    v_cat_id VARCHAR2(50);
BEGIN
    SELECT product_cat_id INTO v_cat_id 
    FROM product_categories 
    WHERE status = 1 
    AND ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('Sample query for category: ' || v_cat_id);
END;
/

SELECT 
    sub_cat_id AS return_value,
    sub_cat_name AS display_value
FROM 
    sub_categories
WHERE 
    status = 1
    AND product_cat_id = (SELECT product_cat_id FROM product_categories WHERE status = 1 AND ROWNUM = 1)
ORDER BY 
    sub_cat_name;

--------------------------------------------------------------------------------
-- SECTION 11: DATA INTEGRITY CHECKS
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Section 11: Data Integrity Checks
PROMPT ========================================

-- 11.1 Orphaned records check (products without stock)
PROMPT
PROMPT 11.1 Products without Stock Records:
SELECT 
    p.product_id,
    p.product_name,
    p.status
FROM 
    products p
WHERE 
    p.status = 1
    AND NOT EXISTS (SELECT 1 FROM stock s WHERE s.product_id = p.product_id);

-- 11.2 Sales details without master
PROMPT
PROMPT 11.2 Sales Details without Master (should be empty):
SELECT 
    sd.invoice_id,
    sd.product_id,
    sd.quantity
FROM 
    sales_detail sd
WHERE 
    NOT EXISTS (SELECT 1 FROM sales_master sm WHERE sm.invoice_id = sd.invoice_id);

-- 11.3 Users without valid employees
PROMPT
PROMPT 11.3 Users without Valid Employees:
SELECT 
    u.user_id,
    u.user_name,
    u.employee_id
FROM 
    com_users u
WHERE 
    u.employee_id IS NOT NULL
    AND u.status = 1
    AND NOT EXISTS (SELECT 1 FROM employees e WHERE e.employee_id = u.employee_id);

-- 11.4 Constraint validation
PROMPT
PROMPT 11.4 Invalid/Disabled Constraints:
SELECT 
    constraint_name,
    table_name,
    constraint_type,
    status
FROM 
    user_constraints
WHERE 
    status = 'DISABLED'
ORDER BY 
    table_name, constraint_name;

--------------------------------------------------------------------------------
-- SECTION 12: PERFORMANCE STATISTICS
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Section 12: Database Statistics
PROMPT ========================================

-- 12.1 Row counts for all tables
PROMPT
PROMPT 12.1 Row Counts for All Tables:
SELECT 
    'company' AS table_name, COUNT(*) AS row_count FROM company
UNION ALL
SELECT 'jobs', COUNT(*) FROM jobs
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'departments', COUNT(*) FROM departments
UNION ALL
SELECT 'product_categories', COUNT(*) FROM product_categories
UNION ALL
SELECT 'sub_categories', COUNT(*) FROM sub_categories
UNION ALL
SELECT 'brand', COUNT(*) FROM brand
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'stock', COUNT(*) FROM stock
UNION ALL
SELECT 'com_users', COUNT(*) FROM com_users
UNION ALL
SELECT 'sales_master', COUNT(*) FROM sales_master
UNION ALL
SELECT 'sales_detail', COUNT(*) FROM sales_detail
UNION ALL
SELECT 'service_master', COUNT(*) FROM service_master
UNION ALL
SELECT 'service_details', COUNT(*) FROM service_details
ORDER BY 
    row_count DESC;

-- 12.2 Database size summary
PROMPT
PROMPT 12.2 Database Objects Summary:
SELECT 
    'Tables' AS object_type, COUNT(*) AS count FROM user_tables
UNION ALL
SELECT 'Sequences', COUNT(*) FROM user_sequences
UNION ALL
SELECT 'Triggers', COUNT(*) FROM user_triggers
UNION ALL
SELECT 'Constraints', COUNT(*) FROM user_constraints
UNION ALL
SELECT 'Indexes', COUNT(*) FROM user_indexes;

--------------------------------------------------------------------------------
-- SECTION 13: SAMPLE DATA INSERTION
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Section 13: Sample Data for Testing
PROMPT ========================================

-- 13.1 Insert sample customer if not exists
PROMPT
PROMPT 13.1 Creating sample customer...
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM customers WHERE phone_no = '01712345678';
    IF v_count = 0 THEN
        INSERT INTO customers (customer_name, phone_no, email, address, status)
        VALUES ('Test Customer', '01712345678', 'test@customer.com', 'Dhaka, Bangladesh', 1);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Sample customer created.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Sample customer already exists.');
    END IF;
END;
/

-- 13.2 Verify sample data
PROMPT
PROMPT 13.2 Verify Sample Data:
SELECT 'Customers' AS entity, COUNT(*) AS count FROM customers WHERE status = 1
UNION ALL
SELECT 'Suppliers', COUNT(*) FROM suppliers WHERE status = 1
UNION ALL
SELECT 'Products', COUNT(*) FROM products WHERE status = 1
UNION ALL
SELECT 'Employees', COUNT(*) FROM employees WHERE status = 1
UNION ALL
SELECT 'Users', COUNT(*) FROM com_users WHERE status = 1;

--------------------------------------------------------------------------------
-- END OF TEST QUERIES
--------------------------------------------------------------------------------

PROMPT
PROMPT ========================================
PROMPT Test Queries Completed Successfully!
PROMPT ========================================
PROMPT
PROMPT Next Steps:
PROMPT 1. Review the results above to verify schema integrity
PROMPT 2. Use test users: admin/admin123, testuser/test123, manager/manager123
PROMPT 3. Refer to ORACLE_FORMS_11G_ARCHITECTURE_GUIDE.md for form development
PROMPT 4. Use Section 10 LOV queries in your Oracle Forms
PROMPT
PROMPT Database: Oracle 11g+
PROMPT Schema: msp/msp
PROMPT Tables: 33
PROMPT Status: Ready for Forms 11g Development
PROMPT ========================================
