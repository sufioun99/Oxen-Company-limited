--------------------------------------------------------------------------------
-- SERVICE TRANSACTION FORM - TEST DATA & QUERIES
-- Use these queries to populate LOVs and test the service form
--------------------------------------------------------------------------------

-- 1. SERVICES LOV (for servicelist_id dropdown)
SELECT servicelist_id, service_name, service_cost
FROM service_list
WHERE status = 1
ORDER BY service_name;

-- 2. CUSTOMERS LOV (for customer_id dropdown)
SELECT customer_id, customer_name, phone_no, address
FROM customers
WHERE status = 1
ORDER BY customer_name;

-- 3. CUSTOMER INVOICES LOV (cascading - shows invoices for selected customer)
-- Use this after customer is selected to check warranty
SELECT i.invoice_id, i.invoice_date, i.grand_total,
       CASE 
           WHEN MONTHS_BETWEEN(SYSDATE, i.invoice_date) <= 
                (SELECT MAX(p.warranty) FROM sales_detail sd 
                 JOIN products p ON sd.product_id = p.product_id 
                 WHERE sd.invoice_id = i.invoice_id) 
           THEN 'Y' 
           ELSE 'N' 
       END as warranty_status
FROM sales_master i
WHERE i.customer_id = :CUSTOMER_ID
  AND i.status = 1
ORDER BY i.invoice_date DESC;

-- 4. TECHNICIANS LOV (employees with TECH job code)
SELECT e.employee_id, e.first_name || ' ' || e.last_name as tech_name, 
       j.job_name, e.phone_no
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
WHERE j.job_code IN ('TECH', 'CSUP')
  AND e.status = 1
ORDER BY e.first_name;

-- 5. PARTS LOV (for service_details)
SELECT parts_id, parts_name, mrp, parts_cat_id
FROM parts
WHERE status = 1
ORDER BY parts_name;

-- 6. PRODUCTS LOV (for service_details - which product being serviced)
SELECT product_id, product_name, warranty, category_id
FROM products
WHERE status = 1
ORDER BY product_name;

--------------------------------------------------------------------------------
-- VALIDATION QUERIES (Use in WHEN-VALIDATE-ITEM triggers)
--------------------------------------------------------------------------------

-- Check if service charge is auto-filled when service type selected
SELECT service_cost 
FROM service_list 
WHERE servicelist_id = :SERVICELIST_ID;

-- Get customer details when customer selected
SELECT customer_name, phone_no, address, reward_points
FROM customers
WHERE customer_id = :CUSTOMER_ID;

-- Check warranty status for selected invoice and product
SELECT 
    CASE 
        WHEN MONTHS_BETWEEN(SYSDATE, sm.invoice_date) <= NVL(p.warranty, 0)
        THEN 'Y' 
        ELSE 'N' 
    END as warranty_applicable
FROM sales_master sm
JOIN sales_detail sd ON sm.invoice_id = sd.invoice_id
JOIN products p ON sd.product_id = p.product_id
WHERE sm.invoice_id = :INVOICE_ID
  AND sd.product_id = :PRODUCT_ID;

-- Get parts price when part selected (for service_details)
SELECT mrp
FROM parts
WHERE parts_id = :PARTS_ID;

--------------------------------------------------------------------------------
-- SAMPLE DATA INSERTS FOR TESTING
--------------------------------------------------------------------------------

-- Service Ticket 1: Screen Replacement (Out of Warranty)
INSERT INTO service_master (customer_id, invoice_id, servicelist_id, service_by, service_charge, warranty_applicable, status)
VALUES (
    (SELECT customer_id FROM customers WHERE ROWNUM = 1),
    (SELECT invoice_id FROM sales_master WHERE ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Screen Replacement' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE job_id IN (SELECT job_id FROM jobs WHERE job_code = 'TECH') AND ROWNUM = 1),
    1500,
    'N',
    1
);

-- Service Ticket 2: Battery Replacement (Under Warranty)
INSERT INTO service_master (customer_id, invoice_id, servicelist_id, service_by, service_charge, warranty_applicable, status)
VALUES (
    (SELECT customer_id FROM customers WHERE ROWNUM = 1),
    (SELECT invoice_id FROM sales_master WHERE ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Battery Replacement' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE job_id IN (SELECT job_id FROM jobs WHERE job_code = 'TECH') AND ROWNUM = 1),
    0,
    'Y',
    1
);

-- Add service details (parts used)
INSERT INTO service_details (service_id, parts_id, quantity, parts_price, line_total)
VALUES (
    (SELECT service_id FROM service_master WHERE ROWNUM = 1),
    (SELECT parts_id FROM parts WHERE ROWNUM = 1),
    1,
    (SELECT mrp FROM parts WHERE ROWNUM = 1),
    (SELECT mrp FROM parts WHERE ROWNUM = 1)
);

COMMIT;

--------------------------------------------------------------------------------
-- TEST QUERIES - Verify data before building form
--------------------------------------------------------------------------------

-- Test 1: Check service masters created
SELECT service_id, customer_id, servicelist_id, service_charge, warranty_applicable
FROM service_master
WHERE status = 1;

-- Test 2: Check service details
SELECT sd.service_det_id, sd.service_id, sd.parts_id, 
       p.parts_name, sd.quantity, sd.parts_price, sd.line_total
FROM service_details sd
JOIN parts p ON sd.parts_id = p.parts_id;

-- Test 3: Complete service view (master-detail join)
SELECT 
    sm.service_id,
    sm.service_date,
    c.customer_name,
    c.phone_no,
    sl.service_name,
    sm.service_charge,
    sm.parts_total,
    sm.total_price,
    sm.vat,
    sm.grand_total,
    sm.warranty_applicable,
    e.first_name || ' ' || e.last_name as technician,
    sd.parts_id,
    p.parts_name,
    sd.quantity,
    sd.parts_price,
    sd.line_total
FROM service_master sm
JOIN customers c ON sm.customer_id = c.customer_id
JOIN service_list sl ON sm.servicelist_id = sl.servicelist_id
JOIN employees e ON sm.service_by = e.employee_id
LEFT JOIN service_details sd ON sm.service_id = sd.service_id
LEFT JOIN parts p ON sd.parts_id = p.parts_id
WHERE sm.status = 1
ORDER BY sm.service_date DESC;
