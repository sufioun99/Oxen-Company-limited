--------------------------------------------------------------------------------
-- TEST SCRIPT FOR SERVICE FORMS DYNAMIC LISTS
-- Purpose: Validate that all queries work against the database
-- Run this in SQL*Plus or SQL Developer before deploying to Oracle Forms
-- Database: Oracle 11g+
--------------------------------------------------------------------------------

SET SERVEROUTPUT ON;
SET LINESIZE 200;
SET PAGESIZE 100;

PROMPT ================================================================================
PROMPT TESTING SERVICE FORMS DYNAMIC LIST QUERIES
PROMPT ================================================================================
PROMPT

PROMPT ================================================================================
PROMPT TEST 1: CUSTOMER LIST QUERY
PROMPT Expected: Customer names with phone numbers
PROMPT ================================================================================
SELECT customer_name || ' - ' || NVL(phone_no, 'N/A') AS customer_display, 
       customer_id
FROM customers
WHERE status = 1
ORDER BY customer_name;

PROMPT
PROMPT TEST 1 Result: Should show 10 customers with phone numbers
PROMPT

PROMPT ================================================================================
PROMPT TEST 2: SERVICE TYPE LIST QUERY
PROMPT Expected: Service names with costs in BDT
PROMPT ================================================================================
SELECT service_name || ' (BDT ' || TO_CHAR(service_cost) || ')' AS service_display,
       servicelist_id
FROM service_list
WHERE status = 1
ORDER BY service_name;

PROMPT
PROMPT TEST 2 Result: Should show service types with pricing
PROMPT

PROMPT ================================================================================
PROMPT TEST 3: TECHNICIAN LIST QUERY
PROMPT Expected: Employee names filtered by job code (TECH, CSUP, MGR)
PROMPT ================================================================================
SELECT e.first_name || ' ' || e.last_name AS tech_name,
       e.employee_id
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
WHERE e.status = 1
AND j.job_code IN ('TECH', 'CSUP', 'MGR')
ORDER BY e.first_name, e.last_name;

PROMPT
PROMPT TEST 3 Result: Should show technicians and managers only
PROMPT

PROMPT ================================================================================
PROMPT TEST 4: INVOICE LIST QUERY
PROMPT Expected: Invoice IDs with dates and grand totals
PROMPT ================================================================================
SELECT invoice_id || ' - ' || TO_CHAR(invoice_date, 'DD-MON-YYYY') || 
       ' (BDT ' || TO_CHAR(grand_total) || ')' AS invoice_display,
       invoice_id
FROM sales_master
WHERE status IN (1, 3)
ORDER BY invoice_date DESC;

PROMPT
PROMPT TEST 4 Result: Should show invoices sorted by recent date
PROMPT

PROMPT ================================================================================
PROMPT TEST 5: PRODUCT LIST QUERY
PROMPT Expected: Product names with product codes
PROMPT ================================================================================
SELECT product_name || ' (' || product_code || ')' AS product_display,
       product_id
FROM products
WHERE status = 1
ORDER BY product_name;

PROMPT
PROMPT TEST 5 Result: Should show all active products
PROMPT

PROMPT ================================================================================
PROMPT TEST 6: PARTS LIST QUERY
PROMPT Expected: Parts names with MRP prices
PROMPT ================================================================================
SELECT parts_name || ' (BDT ' || TO_CHAR(mrp) || ')' AS parts_display,
       parts_id
FROM parts
WHERE status = 1
ORDER BY parts_name;

PROMPT
PROMPT TEST 6 Result: Should show spare parts with pricing
PROMPT

PROMPT ================================================================================
PROMPT TEST 7: CASCADING INVOICE LIST QUERY (Customer Filter)
PROMPT Expected: Invoices for a specific customer
PROMPT Using first customer from database
PROMPT ================================================================================
DECLARE
   v_customer_id VARCHAR2(50);
BEGIN
   SELECT customer_id INTO v_customer_id
   FROM customers
   WHERE status = 1 AND ROWNUM = 1;
   
   DBMS_OUTPUT.PUT_LINE('Testing with customer_id: ' || v_customer_id);
   
   FOR rec IN (
      SELECT invoice_id || ' - ' || TO_CHAR(invoice_date, 'DD-MON-YYYY') AS invoice_display,
             invoice_id
      FROM sales_master
      WHERE status IN (1, 3)
      AND customer_id = v_customer_id
      ORDER BY invoice_date DESC
   ) LOOP
      DBMS_OUTPUT.PUT_LINE('  ' || rec.invoice_display || ' -> ' || rec.invoice_id);
   END LOOP;
END;
/

PROMPT
PROMPT TEST 7 Result: Should show invoices filtered by customer
PROMPT

PROMPT ================================================================================
PROMPT TEST 8: WARRANTY CALCULATION LOGIC
PROMPT Expected: Check if products are within warranty period
PROMPT ================================================================================
DECLARE
   v_invoice_id        VARCHAR2(50);
   v_invoice_date      DATE;
   v_warranty          NUMBER;
   v_warranty_end_date DATE;
   v_today             DATE := SYSDATE;
   v_status            VARCHAR2(50);
BEGIN
   DBMS_OUTPUT.PUT_LINE('Testing warranty calculation for all invoices:');
   DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
   
   FOR inv IN (
      SELECT DISTINCT m.invoice_id, m.invoice_date, p.warranty, p.product_name
      FROM sales_master m
      JOIN sales_detail d ON m.invoice_id = d.invoice_id
      JOIN products p ON d.product_id = p.product_id
      WHERE m.status IN (1, 3)
      ORDER BY m.invoice_date DESC
   ) LOOP
      v_warranty_end_date := inv.invoice_date + (inv.warranty * 30);
      
      IF v_warranty_end_date >= v_today THEN
         v_status := 'ACTIVE';
      ELSE
         v_status := 'EXPIRED';
      END IF;
      
      DBMS_OUTPUT.PUT_LINE(
         inv.invoice_id || ' | ' || 
         TO_CHAR(inv.invoice_date, 'DD-MON-YYYY') || ' | ' ||
         inv.product_name || ' | ' ||
         inv.warranty || ' months | ' ||
         'Warranty: ' || v_status
      );
   END LOOP;
END;
/

PROMPT
PROMPT TEST 8 Result: Should show warranty status for each invoice
PROMPT

PROMPT ================================================================================
PROMPT TEST 9: RECORD COUNT VALIDATION
PROMPT Expected: Verify sufficient data exists for all lists
PROMPT ================================================================================
DECLARE
   v_count NUMBER;
BEGIN
   SELECT COUNT(*) INTO v_count FROM customers WHERE status = 1;
   DBMS_OUTPUT.PUT_LINE('Active Customers: ' || v_count || ' (Expected: >= 10)');
   
   SELECT COUNT(*) INTO v_count FROM service_list WHERE status = 1;
   DBMS_OUTPUT.PUT_LINE('Service Types: ' || v_count || ' (Expected: >= 5)');
   
   SELECT COUNT(*) INTO v_count FROM employees e 
   JOIN jobs j ON e.job_id = j.job_id 
   WHERE e.status = 1 AND j.job_code IN ('TECH', 'CSUP', 'MGR');
   DBMS_OUTPUT.PUT_LINE('Technicians: ' || v_count || ' (Expected: >= 3)');
   
   SELECT COUNT(*) INTO v_count FROM sales_master WHERE status IN (1, 3);
   DBMS_OUTPUT.PUT_LINE('Sales Invoices: ' || v_count || ' (Expected: >= 10)');
   
   SELECT COUNT(*) INTO v_count FROM products WHERE status = 1;
   DBMS_OUTPUT.PUT_LINE('Products: ' || v_count || ' (Expected: >= 5)');
   
   SELECT COUNT(*) INTO v_count FROM parts WHERE status = 1;
   DBMS_OUTPUT.PUT_LINE('Spare Parts: ' || v_count || ' (Expected: >= 5)');
END;
/

PROMPT
PROMPT TEST 9 Result: All counts should be sufficient for dropdown lists
PROMPT

PROMPT ================================================================================
PROMPT TEST 10: COLUMN COMPATIBILITY CHECK
PROMPT Expected: Verify all columns exist and have correct data types
PROMPT ================================================================================
DECLARE
   v_exists NUMBER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Checking required columns...');
   
   SELECT COUNT(*) INTO v_exists FROM user_tab_columns 
   WHERE table_name = 'CUSTOMERS' AND column_name IN ('CUSTOMER_NAME', 'PHONE_NO', 'CUSTOMER_ID', 'STATUS');
   DBMS_OUTPUT.PUT_LINE('CUSTOMERS table columns: ' || v_exists || '/4');
   
   SELECT COUNT(*) INTO v_exists FROM user_tab_columns 
   WHERE table_name = 'SERVICE_LIST' AND column_name IN ('SERVICE_NAME', 'SERVICE_COST', 'SERVICELIST_ID', 'STATUS');
   DBMS_OUTPUT.PUT_LINE('SERVICE_LIST table columns: ' || v_exists || '/4');
   
   SELECT COUNT(*) INTO v_exists FROM user_tab_columns 
   WHERE table_name = 'EMPLOYEES' AND column_name IN ('FIRST_NAME', 'LAST_NAME', 'EMPLOYEE_ID', 'STATUS', 'JOB_ID');
   DBMS_OUTPUT.PUT_LINE('EMPLOYEES table columns: ' || v_exists || '/5');
   
   SELECT COUNT(*) INTO v_exists FROM user_tab_columns 
   WHERE table_name = 'SALES_MASTER' AND column_name IN ('INVOICE_ID', 'INVOICE_DATE', 'GRAND_TOTAL', 'STATUS', 'CUSTOMER_ID');
   DBMS_OUTPUT.PUT_LINE('SALES_MASTER table columns: ' || v_exists || '/5');
   
   SELECT COUNT(*) INTO v_exists FROM user_tab_columns 
   WHERE table_name = 'PRODUCTS' AND column_name IN ('PRODUCT_NAME', 'PRODUCT_CODE', 'PRODUCT_ID', 'STATUS', 'WARRANTY');
   DBMS_OUTPUT.PUT_LINE('PRODUCTS table columns: ' || v_exists || '/5');
   
   SELECT COUNT(*) INTO v_exists FROM user_tab_columns 
   WHERE table_name = 'PARTS' AND column_name IN ('PARTS_NAME', 'MRP', 'PARTS_ID', 'STATUS');
   DBMS_OUTPUT.PUT_LINE('PARTS table columns: ' || v_exists || '/4');
   
   DBMS_OUTPUT.PUT_LINE('All required columns should be present.');
END;
/

PROMPT
PROMPT ================================================================================
PROMPT TEST SUMMARY
PROMPT ================================================================================
PROMPT If all tests passed successfully:
PROMPT   ✓ Queries are syntactically correct
PROMPT   ✓ Tables and columns exist
PROMPT   ✓ Data is available for dropdown lists
PROMPT   ✓ Warranty calculation logic is valid
PROMPT   ✓ Cascading filters will work
PROMPT
PROMPT Next Steps:
PROMPT   1. Copy triggers from service_form_dynamic_lists.sql to Oracle Forms
PROMPT   2. Adjust block/item names to match your form design
PROMPT   3. Compile and test in Oracle Forms Builder
PROMPT   4. Deploy to production
PROMPT ================================================================================
