SET SERVEROUTPUT ON
SET PAGESIZE 200
SET LINESIZE 200
TTITLE 'Transactional Integrity Validation'

PROMPT === Sales ===
SELECT 'SALES: Orphaned details' AS check_name, COUNT(*) AS issue_count
FROM sales_detail sd
LEFT JOIN sales_master sm ON sd.invoice_id = sm.invoice_id
WHERE sm.invoice_id IS NULL;

SELECT 'SALES: Invalid customer refs' AS check_name, COUNT(*) AS issue_count
FROM sales_master sm
LEFT JOIN customers c ON sm.customer_id = c.customer_id
WHERE sm.customer_id IS NOT NULL AND c.customer_id IS NULL;

SELECT 'SALES: Invalid employee refs' AS check_name, COUNT(*) AS issue_count
FROM sales_master sm
LEFT JOIN employees e ON sm.sales_by = e.employee_id
WHERE sm.sales_by IS NOT NULL AND e.employee_id IS NULL;

SELECT 'SALES: Invalid product refs' AS check_name, COUNT(*) AS issue_count
FROM sales_detail sd
LEFT JOIN products p ON sd.product_id = p.product_id
WHERE p.product_id IS NULL;

PROMPT === Sales Returns ===
SELECT 'SALES_RETURN: Orphaned details' AS check_name, COUNT(*) AS issue_count
FROM sales_return_details srd
LEFT JOIN sales_return_master srm ON srd.sales_return_id = srm.sales_return_id
WHERE srm.sales_return_id IS NULL;

SELECT 'SALES_RETURN: Invalid customer refs' AS check_name, COUNT(*) AS issue_count
FROM sales_return_master srm
LEFT JOIN customers c ON srm.customer_id = c.customer_id
WHERE srm.customer_id IS NOT NULL AND c.customer_id IS NULL;

SELECT 'SALES_RETURN: Invalid invoice refs' AS check_name, COUNT(*) AS issue_count
FROM sales_return_master srm
LEFT JOIN sales_master sm ON srm.invoice_id = sm.invoice_id
WHERE srm.invoice_id IS NOT NULL AND sm.invoice_id IS NULL;

SELECT 'SALES_RETURN: Products not in orig sale' AS check_name, COUNT(*) AS issue_count
FROM sales_return_details srd
JOIN sales_return_master srm ON srd.sales_return_id = srm.sales_return_id
LEFT JOIN sales_detail sd ON sd.invoice_id = srm.invoice_id AND sd.product_id = srd.product_id
WHERE srm.invoice_id IS NOT NULL AND sd.product_id IS NULL;

PROMPT === Service ===
SELECT 'SERVICE: Orphaned details' AS check_name, COUNT(*) AS issue_count
FROM service_details sd
LEFT JOIN service_master sm ON sd.service_id = sm.service_id
WHERE sm.service_id IS NULL;

SELECT 'SERVICE: Invalid customer refs' AS check_name, COUNT(*) AS issue_count
FROM service_master sm
LEFT JOIN customers c ON sm.customer_id = c.customer_id
WHERE sm.customer_id IS NOT NULL AND c.customer_id IS NULL;

SELECT 'SERVICE: Invalid employee refs' AS check_name, COUNT(*) AS issue_count
FROM service_master sm
LEFT JOIN employees e ON sm.service_by = e.employee_id
WHERE sm.service_by IS NOT NULL AND e.employee_id IS NULL;

SELECT 'SERVICE: Invalid invoice refs' AS check_name, COUNT(*) AS issue_count
FROM service_master sm
LEFT JOIN sales_master sal ON sm.invoice_id = sal.invoice_id
WHERE sm.invoice_id IS NOT NULL AND sal.invoice_id IS NULL;

SELECT 'SERVICE: Invalid servicelist refs' AS check_name, COUNT(*) AS issue_count
FROM service_master sm
LEFT JOIN service_list sl ON sm.servicelist_id = sl.servicelist_id
WHERE sm.servicelist_id IS NOT NULL AND sl.servicelist_id IS NULL;

PROMPT === Expenses ===
SELECT 'EXPENSE: Orphaned details' AS check_name, COUNT(*) AS issue_count
FROM expense_details ed
LEFT JOIN expense_master em ON ed.expense_id = em.expense_id
WHERE em.expense_id IS NULL;

PROMPT === Damage ===
SELECT 'DAMAGE: Orphaned details' AS check_name, COUNT(*) AS issue_count
FROM damage_detail dd
LEFT JOIN damage dm ON dd.damage_id = dm.damage_id
WHERE dm.damage_id IS NULL;

PROMPT === Payments ===
SELECT 'PAYMENT: Invalid supplier refs' AS check_name, COUNT(*) AS issue_count
FROM payments p
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE p.supplier_id IS NOT NULL AND s.supplier_id IS NULL;

PROMPT === Supply Chain Cross-Form ===
SELECT 'Return supplier mismatch' AS check_name, COUNT(*) AS issue_count
FROM product_return_master prm
JOIN product_receive_master rm ON prm.receive_id = rm.receive_id
WHERE prm.supplier_id <> rm.supplier_id;

SELECT 'Receive supplier mismatch' AS check_name, COUNT(*) AS issue_count
FROM product_receive_master rm
JOIN product_order_master om ON rm.order_id = om.order_id
WHERE rm.supplier_id <> om.supplier_id;

SELECT 'Receive product not in order' AS check_name, COUNT(*) AS issue_count
FROM product_receive_details rd
JOIN product_receive_master rm ON rd.receive_id = rm.receive_id
LEFT JOIN product_order_detail od ON od.order_id = rm.order_id AND od.product_id = rd.product_id
WHERE od.product_id IS NULL;

SELECT 'Receive qty > order qty' AS check_name, COUNT(*) AS issue_count
FROM product_receive_details rd
JOIN product_receive_master rm ON rd.receive_id = rm.receive_id
JOIN product_order_detail od ON od.order_id = rm.order_id AND od.product_id = rd.product_id
WHERE rd.receive_quantity > od.quantity;

SELECT 'Return product not in receive' AS check_name, COUNT(*) AS issue_count
FROM product_return_details rdd
JOIN product_return_master prm ON rdd.return_id = prm.return_id
LEFT JOIN product_receive_details rcvd ON rcvd.receive_id = prm.receive_id AND rcvd.product_id = rdd.product_id
WHERE rcvd.product_id IS NULL;

PROMPT === Done ===
EXIT;
