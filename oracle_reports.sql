--------------------------------------------------------------------------------
-- OXEN COMPANY LIMITED - ORACLE REPORTS QUERIES
-- Compatible with: Oracle Reports 11g
-- Purpose: Ready-to-use report queries for business intelligence
-- Date: 2026-01-03
--------------------------------------------------------------------------------

/*
================================================================================
SECTION 1: SALES REPORTS
================================================================================
*/

/*
================================================================================
REPORT: Daily Sales Summary
Description: Daily sales with product-wise breakdown
Parameters: p_from_date, p_to_date
================================================================================
*/
-- Main Query:
SELECT 
    sm.invoice_id,
    sm.invoice_date,
    c.customer_name,
    c.phone_no,
    e.first_name || ' ' || e.last_name AS sales_person,
    sm.grand_total,
    sm.discount,
    sm.payment_status,
    sm.remarks
FROM sales_master sm
LEFT JOIN customers c ON sm.customer_id = c.customer_id
LEFT JOIN employees e ON sm.sales_by = e.employee_id
WHERE sm.invoice_date BETWEEN :p_from_date AND :p_to_date
AND sm.status = 1
ORDER BY sm.invoice_date DESC, sm.invoice_id;

-- Detail Query (Master-Detail):
SELECT 
    sd.invoice_id,
    p.product_name,
    p.product_code,
    sd.quantity,
    sd.unit_price AS mrp,
    sd.vat,
    sd.total,
    b.brand_name || ' - ' || b.model_name AS brand_model
FROM sales_detail sd
JOIN products p ON sd.product_id = p.product_id
LEFT JOIN brand b ON p.brand_id = b.brand_id
WHERE sd.invoice_id = :invoice_id
ORDER BY sd.salesd_id;

-- Summary Query (for report footer):
SELECT 
    COUNT(DISTINCT sm.invoice_id) AS total_invoices,
    COUNT(DISTINCT sm.customer_id) AS total_customers,
    SUM(sm.grand_total) AS total_sales_amount,
    SUM(sm.discount) AS total_discount,
    SUM(sm.grand_total - NVL(sm.discount, 0)) AS net_sales
FROM sales_master sm
WHERE sm.invoice_date BETWEEN :p_from_date AND :p_to_date
AND sm.status = 1;


/*
================================================================================
REPORT: Product-Wise Sales Report
Description: Sales performance by product
Parameters: p_from_date, p_to_date, p_category_id (optional)
================================================================================
*/
SELECT 
    p.product_id,
    p.product_code,
    p.product_name,
    pc.product_cat_name AS category,
    b.brand_name,
    COUNT(DISTINCT sd.invoice_id) AS invoice_count,
    SUM(sd.quantity) AS total_quantity_sold,
    SUM(sd.total) AS total_sales_value,
    AVG(sd.unit_price) AS avg_selling_price,
    p.mrp AS current_mrp,
    p.purchase_price AS current_cost
FROM sales_detail sd
JOIN products p ON sd.product_id = p.product_id
JOIN sales_master sm ON sd.invoice_id = sm.invoice_id
LEFT JOIN product_categories pc ON p.category_id = pc.product_cat_id
LEFT JOIN brand b ON p.brand_id = b.brand_id
WHERE sm.invoice_date BETWEEN :p_from_date AND :p_to_date
AND sm.status = 1
AND (:p_category_id IS NULL OR p.category_id = :p_category_id)
GROUP BY 
    p.product_id, p.product_code, p.product_name, 
    pc.product_cat_name, b.brand_name, p.mrp, p.purchase_price
ORDER BY total_sales_value DESC;


/*
================================================================================
REPORT: Customer-Wise Sales Report
Description: Sales analysis by customer
Parameters: p_from_date, p_to_date
================================================================================
*/
SELECT 
    c.customer_id,
    c.customer_name,
    c.phone_no,
    c.address,
    COUNT(sm.invoice_id) AS total_invoices,
    SUM(sm.grand_total) AS total_purchase_amount,
    AVG(sm.grand_total) AS avg_invoice_value,
    MAX(sm.invoice_date) AS last_purchase_date,
    c.rewards AS reward_points,
    CASE 
        WHEN SUM(sm.grand_total) >= 500000 THEN 'VIP'
        WHEN SUM(sm.grand_total) >= 200000 THEN 'Gold'
        WHEN SUM(sm.grand_total) >= 100000 THEN 'Silver'
        ELSE 'Regular'
    END AS customer_category
FROM customers c
LEFT JOIN sales_master sm ON c.customer_id = sm.customer_id
    AND sm.invoice_date BETWEEN :p_from_date AND :p_to_date
    AND sm.status = 1
WHERE c.status = 1
GROUP BY 
    c.customer_id, c.customer_name, c.phone_no, 
    c.address, c.rewards
HAVING COUNT(sm.invoice_id) > 0
ORDER BY total_purchase_amount DESC;


/*
================================================================================
REPORT: Employee Sales Performance
Description: Sales person performance tracking
Parameters: p_from_date, p_to_date
================================================================================
*/
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    j.job_title,
    d.department_name,
    COUNT(sm.invoice_id) AS total_invoices,
    SUM(sm.grand_total) AS total_sales_amount,
    AVG(sm.grand_total) AS avg_invoice_value,
    COUNT(DISTINCT sm.customer_id) AS unique_customers,
    RANK() OVER (ORDER BY SUM(sm.grand_total) DESC) AS sales_rank
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN sales_master sm ON e.employee_id = sm.sales_by
    AND sm.invoice_date BETWEEN :p_from_date AND :p_to_date
    AND sm.status = 1
WHERE e.status = 1
GROUP BY 
    e.employee_id, e.first_name, e.last_name, 
    j.job_title, d.department_name
ORDER BY total_sales_amount DESC;


/*
================================================================================
REPORT: Sales Return Analysis
Description: Product returns and refunds
Parameters: p_from_date, p_to_date
================================================================================
*/
SELECT 
    srm.return_id,
    srm.return_date,
    srm.invoice_id,
    sm.invoice_date AS original_invoice_date,
    c.customer_name,
    srm.return_reason,
    COUNT(srd.salesrd_id) AS items_returned,
    SUM(srd.total) AS return_amount,
    srm.refund_status
FROM sales_return_master srm
JOIN sales_master sm ON srm.invoice_id = sm.invoice_id
LEFT JOIN customers c ON sm.customer_id = c.customer_id
LEFT JOIN sales_return_details srd ON srm.return_id = srd.return_id
WHERE srm.return_date BETWEEN :p_from_date AND :p_to_date
AND srm.status = 1
GROUP BY 
    srm.return_id, srm.return_date, srm.invoice_id, 
    sm.invoice_date, c.customer_name, 
    srm.return_reason, srm.refund_status
ORDER BY srm.return_date DESC;


/*
================================================================================
SECTION 2: INVENTORY REPORTS
================================================================================
*/

/*
================================================================================
REPORT: Current Stock Report
Description: Current stock levels with value
Parameters: p_category_id (optional), p_low_stock_only (Y/N)
================================================================================
*/
SELECT 
    p.product_id,
    p.product_code,
    p.product_name,
    pc.product_cat_name AS category,
    sc.sub_cat_name AS sub_category,
    b.brand_name || ' - ' || b.model_name AS brand_model,
    s.supplier_name AS primary_supplier,
    NVL(st.quantity, 0) AS current_stock,
    p.mrp,
    p.purchase_price,
    NVL(st.quantity, 0) * p.purchase_price AS stock_value,
    st.last_update,
    CASE 
        WHEN NVL(st.quantity, 0) = 0 THEN 'OUT OF STOCK'
        WHEN NVL(st.quantity, 0) <= 5 THEN 'LOW STOCK'
        WHEN NVL(st.quantity, 0) <= 20 THEN 'MEDIUM'
        ELSE 'GOOD'
    END AS stock_status
FROM products p
LEFT JOIN product_categories pc ON p.category_id = pc.product_cat_id
LEFT JOIN sub_categories sc ON p.sub_cat_id = sc.sub_cat_id
LEFT JOIN brand b ON p.brand_id = b.brand_id
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN stock st ON p.product_id = st.product_id AND st.status = 1
WHERE p.status = 1
AND (:p_category_id IS NULL OR p.category_id = :p_category_id)
AND (:p_low_stock_only = 'N' OR NVL(st.quantity, 0) <= 5)
ORDER BY 
    CASE 
        WHEN NVL(st.quantity, 0) = 0 THEN 1
        WHEN NVL(st.quantity, 0) <= 5 THEN 2
        ELSE 3
    END,
    p.product_name;


/*
================================================================================
REPORT: Stock Movement Report
Description: Stock in and out transactions
Parameters: p_from_date, p_to_date, p_product_id (optional)
================================================================================
*/
-- Stock In (Receives)
SELECT 
    'RECEIVE' AS transaction_type,
    prm.receive_date AS transaction_date,
    prm.receive_id AS transaction_id,
    p.product_code,
    p.product_name,
    prd.quantity AS quantity_in,
    0 AS quantity_out,
    prd.unit_price,
    s.supplier_name AS party_name,
    prm.remarks
FROM product_receive_details prd
JOIN product_receive_master prm ON prd.receive_id = prm.receive_id
JOIN products p ON prd.product_id = p.product_id
LEFT JOIN suppliers s ON prm.supplier_id = s.supplier_id
WHERE prm.receive_date BETWEEN :p_from_date AND :p_to_date
AND prm.status IN (1, 3)
AND (:p_product_id IS NULL OR prd.product_id = :p_product_id)

UNION ALL

-- Stock Out (Sales)
SELECT 
    'SALE' AS transaction_type,
    sm.invoice_date AS transaction_date,
    sm.invoice_id AS transaction_id,
    p.product_code,
    p.product_name,
    0 AS quantity_in,
    sd.quantity AS quantity_out,
    sd.unit_price,
    c.customer_name AS party_name,
    sm.remarks
FROM sales_detail sd
JOIN sales_master sm ON sd.invoice_id = sm.invoice_id
JOIN products p ON sd.product_id = p.product_id
LEFT JOIN customers c ON sm.customer_id = c.customer_id
WHERE sm.invoice_date BETWEEN :p_from_date AND :p_to_date
AND sm.status = 1
AND (:p_product_id IS NULL OR sd.product_id = :p_product_id)

ORDER BY transaction_date DESC, transaction_id;


/*
================================================================================
REPORT: Damage and Loss Report
Description: Damaged products tracking
Parameters: p_from_date, p_to_date
================================================================================
*/
SELECT 
    dm.damage_id,
    dm.damage_date,
    p.product_code,
    p.product_name,
    dd.quantity AS damaged_quantity,
    p.purchase_price,
    dd.quantity * p.purchase_price AS loss_value,
    dm.damage_reason,
    e.first_name || ' ' || e.last_name AS reported_by,
    dm.remarks
FROM damage dm
JOIN damage_detail dd ON dm.damage_id = dd.damage_id
JOIN products p ON dd.product_id = p.product_id
LEFT JOIN employees e ON dm.employee_id = e.employee_id
WHERE dm.damage_date BETWEEN :p_from_date AND :p_to_date
AND dm.status = 1
ORDER BY dm.damage_date DESC, dm.damage_id;


/*
================================================================================
REPORT: Reorder Level Report
Description: Products that need reordering
Parameters: p_reorder_threshold (default 5)
================================================================================
*/
SELECT 
    p.product_id,
    p.product_code,
    p.product_name,
    pc.product_cat_name AS category,
    b.brand_name,
    NVL(st.quantity, 0) AS current_stock,
    :p_reorder_threshold AS reorder_level,
    CASE 
        WHEN NVL(st.quantity, 0) = 0 THEN 50
        ELSE 30
    END AS suggested_order_qty,
    s.supplier_name AS preferred_supplier,
    s.phone_no AS supplier_phone,
    p.purchase_price AS unit_cost,
    CASE 
        WHEN NVL(st.quantity, 0) = 0 THEN 50 * p.purchase_price
        ELSE 30 * p.purchase_price
    END AS estimated_order_value
FROM products p
LEFT JOIN stock st ON p.product_id = st.product_id AND st.status = 1
LEFT JOIN product_categories pc ON p.category_id = pc.product_cat_id
LEFT JOIN brand b ON p.brand_id = b.brand_id
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE p.status = 1
AND NVL(st.quantity, 0) <= :p_reorder_threshold
ORDER BY current_stock ASC, p.product_name;


/*
================================================================================
SECTION 3: PURCHASE & SUPPLIER REPORTS
================================================================================
*/

/*
================================================================================
REPORT: Purchase Order Report
Description: Purchase orders with details
Parameters: p_from_date, p_to_date, p_supplier_id (optional)
================================================================================
*/
-- Main Query:
SELECT 
    pom.order_id,
    pom.order_date,
    pom.expected_date,
    s.supplier_name,
    s.phone_no AS supplier_phone,
    pom.order_status,
    pom.grand_total,
    pom.remarks,
    e.first_name || ' ' || e.last_name AS ordered_by
FROM product_order_master pom
JOIN suppliers s ON pom.supplier_id = s.supplier_id
LEFT JOIN employees e ON pom.order_by = e.employee_id
WHERE pom.order_date BETWEEN :p_from_date AND :p_to_date
AND pom.status = 1
AND (:p_supplier_id IS NULL OR pom.supplier_id = :p_supplier_id)
ORDER BY pom.order_date DESC;

-- Detail Query:
SELECT 
    pod.order_id,
    p.product_code,
    p.product_name,
    pod.quantity,
    pod.unit_price,
    pod.total
FROM product_order_detail pod
JOIN products p ON pod.product_id = p.product_id
WHERE pod.order_id = :order_id
ORDER BY pod.orderd_id;


/*
================================================================================
REPORT: Product Receive Report
Description: Products received from suppliers
Parameters: p_from_date, p_to_date
================================================================================
*/
SELECT 
    prm.receive_id,
    prm.receive_date,
    prm.sup_invoice_id AS supplier_invoice,
    s.supplier_name,
    COUNT(prd.received_id) AS items_count,
    SUM(prd.total) AS total_amount,
    prm.order_id AS related_order,
    e.first_name || ' ' || e.last_name AS received_by,
    prm.remarks
FROM product_receive_master prm
JOIN suppliers s ON prm.supplier_id = s.supplier_id
LEFT JOIN product_receive_details prd ON prm.receive_id = prd.receive_id
LEFT JOIN employees e ON prm.received_by = e.employee_id
WHERE prm.receive_date BETWEEN :p_from_date AND :p_to_date
AND prm.status IN (1, 3)
GROUP BY 
    prm.receive_id, prm.receive_date, prm.sup_invoice_id,
    s.supplier_name, prm.order_id, 
    e.first_name, e.last_name, prm.remarks
ORDER BY prm.receive_date DESC;


/*
================================================================================
REPORT: Supplier Performance Report
Description: Supplier analysis with payments
Parameters: p_from_date, p_to_date
================================================================================
*/
SELECT 
    s.supplier_id,
    s.supplier_name,
    s.phone_no,
    s.address,
    COUNT(DISTINCT prm.receive_id) AS total_receives,
    SUM(CASE WHEN prm.receive_date BETWEEN :p_from_date AND :p_to_date 
        THEN NVL(prm.grand_total, 0) ELSE 0 END) AS period_purchases,
    s.purchase_total AS total_purchases,
    s.pay_total AS total_payments,
    s.due AS outstanding_due,
    CASE 
        WHEN s.due > 100000 THEN 'HIGH RISK'
        WHEN s.due > 50000 THEN 'MEDIUM RISK'
        WHEN s.due > 0 THEN 'LOW RISK'
        ELSE 'CLEAR'
    END AS payment_status
FROM suppliers s
LEFT JOIN product_receive_master prm ON s.supplier_id = prm.supplier_id
    AND prm.status IN (1, 3)
WHERE s.status = 1
GROUP BY 
    s.supplier_id, s.supplier_name, s.phone_no, s.address,
    s.purchase_total, s.pay_total, s.due
ORDER BY s.due DESC;


/*
================================================================================
REPORT: Supplier Payment Ledger
Description: Payment history by supplier
Parameters: p_supplier_id, p_from_date, p_to_date
================================================================================
*/
SELECT 
    p.payment_id,
    p.payment_date,
    p.amount AS payment_amount,
    p.payment_method,
    p.reference AS payment_reference,
    e.first_name || ' ' || e.last_name AS processed_by,
    p.remarks
FROM payments p
LEFT JOIN employees e ON p.employee_id = e.employee_id
WHERE p.supplier_id = :p_supplier_id
AND p.payment_date BETWEEN :p_from_date AND :p_to_date
AND p.status = 1
ORDER BY p.payment_date DESC;


/*
================================================================================
SECTION 4: SERVICE REPORTS
================================================================================
*/

/*
================================================================================
REPORT: Service Request Report
Description: Service tickets and status
Parameters: p_from_date, p_to_date, p_service_status (optional)
================================================================================
*/
SELECT 
    sm.service_id,
    sm.service_date,
    c.customer_name,
    c.phone_no,
    p.product_name,
    sl.service_name AS service_type,
    sm.service_charge,
    sm.service_status,
    sm.warranty_applicable,
    e.first_name || ' ' || e.last_name AS technician,
    sm.start_date,
    sm.end_date,
    CASE 
        WHEN sm.end_date IS NOT NULL 
        THEN TRUNC(sm.end_date - sm.start_date) || ' days'
        ELSE 'Pending'
    END AS turnaround_time,
    sm.remarks
FROM service_master sm
LEFT JOIN customers c ON sm.customer_id = c.customer_id
LEFT JOIN products p ON sm.product_id = p.product_id
LEFT JOIN service_list sl ON sm.servicelist_id = sl.servicelist_id
LEFT JOIN employees e ON sm.service_by = e.employee_id
WHERE sm.service_date BETWEEN :p_from_date AND :p_to_date
AND sm.status = 1
AND (:p_service_status IS NULL OR sm.service_status = :p_service_status)
ORDER BY sm.service_date DESC;


/*
================================================================================
REPORT: Service Revenue Report
Description: Service income analysis
Parameters: p_from_date, p_to_date
================================================================================
*/
SELECT 
    sl.service_name,
    sl.service_code,
    COUNT(sm.service_id) AS service_count,
    SUM(sm.service_charge) AS total_service_revenue,
    AVG(sm.service_charge) AS avg_service_charge,
    SUM(CASE WHEN sm.warranty_applicable = 'Y' 
        THEN 1 ELSE 0 END) AS warranty_services,
    SUM(CASE WHEN sm.warranty_applicable = 'N' 
        THEN 1 ELSE 0 END) AS paid_services
FROM service_list sl
LEFT JOIN service_master sm ON sl.servicelist_id = sm.servicelist_id
    AND sm.service_date BETWEEN :p_from_date AND :p_to_date
    AND sm.status = 1
WHERE sl.status = 1
GROUP BY sl.service_name, sl.service_code
ORDER BY total_service_revenue DESC;


/*
================================================================================
REPORT: Parts Usage Report
Description: Spare parts used in services
Parameters: p_from_date, p_to_date
================================================================================
*/
SELECT 
    p.parts_name,
    pc.parts_cat_name AS category,
    COUNT(sd.serviced_id) AS times_used,
    SUM(sd.quantity) AS total_quantity_used,
    AVG(sd.unit_price) AS avg_price,
    SUM(sd.total) AS total_parts_revenue
FROM parts p
LEFT JOIN parts_category pc ON p.parts_cat_id = pc.parts_cat_id
LEFT JOIN service_details sd ON p.parts_id = sd.parts_id
LEFT JOIN service_master sm ON sd.service_id = sm.service_id
    AND sm.service_date BETWEEN :p_from_date AND :p_to_date
    AND sm.status = 1
WHERE p.status = 1
GROUP BY p.parts_name, pc.parts_cat_name
HAVING COUNT(sd.serviced_id) > 0
ORDER BY total_parts_revenue DESC;


/*
================================================================================
REPORT: Warranty Status Report
Description: Products under warranty
Parameters: p_customer_id (optional)
================================================================================
*/
SELECT 
    sm.invoice_id,
    sm.invoice_date,
    c.customer_name,
    c.phone_no,
    p.product_name,
    p.warranty AS warranty_months,
    ADD_MONTHS(sm.invoice_date, p.warranty) AS warranty_expiry,
    TRUNC(ADD_MONTHS(sm.invoice_date, p.warranty) - SYSDATE) AS days_remaining,
    CASE 
        WHEN ADD_MONTHS(sm.invoice_date, p.warranty) < SYSDATE THEN 'EXPIRED'
        WHEN ADD_MONTHS(sm.invoice_date, p.warranty) < SYSDATE + 30 THEN 'EXPIRING SOON'
        ELSE 'ACTIVE'
    END AS warranty_status,
    sd.quantity,
    sd.total AS purchase_value
FROM sales_master sm
JOIN sales_detail sd ON sm.invoice_id = sd.invoice_id
JOIN products p ON sd.product_id = p.product_id
LEFT JOIN customers c ON sm.customer_id = c.customer_id
WHERE sm.status = 1
AND p.warranty > 0
AND ADD_MONTHS(sm.invoice_date, p.warranty) >= SYSDATE
AND (:p_customer_id IS NULL OR sm.customer_id = :p_customer_id)
ORDER BY warranty_expiry;


/*
================================================================================
SECTION 5: FINANCIAL REPORTS
================================================================================
*/

/*
================================================================================
REPORT: Expense Report
Description: Company expenses tracking
Parameters: p_from_date, p_to_date, p_expense_type (optional)
================================================================================
*/
SELECT 
    em.expense_id,
    em.expense_date,
    el.type_name AS expense_type,
    el.expense_code,
    SUM(ed.amount) AS total_amount,
    e.first_name || ' ' || e.last_name AS approved_by,
    em.payment_method,
    em.remarks
FROM expense_master em
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
LEFT JOIN expense_details ed ON em.expense_id = ed.expense_id
LEFT JOIN employees e ON em.employee_id = e.employee_id
WHERE em.expense_date BETWEEN :p_from_date AND :p_to_date
AND em.status = 1
AND (:p_expense_type IS NULL OR em.expense_type_id = :p_expense_type)
GROUP BY 
    em.expense_id, em.expense_date, el.type_name, el.expense_code,
    e.first_name, e.last_name, em.payment_method, em.remarks
ORDER BY em.expense_date DESC;


/*
================================================================================
REPORT: Profit & Loss Statement
Description: P&L for period
Parameters: p_from_date, p_to_date
================================================================================
*/
-- Revenue Section
SELECT 
    'REVENUE' AS section,
    'Sales Revenue' AS line_item,
    SUM(sm.grand_total) AS amount,
    1 AS sort_order
FROM sales_master sm
WHERE sm.invoice_date BETWEEN :p_from_date AND :p_to_date
AND sm.status = 1

UNION ALL

SELECT 
    'REVENUE' AS section,
    'Service Revenue' AS line_item,
    SUM(sm.service_charge) AS amount,
    2 AS sort_order
FROM service_master sm
WHERE sm.service_date BETWEEN :p_from_date AND :p_to_date
AND sm.status = 1

UNION ALL

-- Cost of Goods Sold
SELECT 
    'COGS' AS section,
    'Cost of Products Sold' AS line_item,
    SUM(sd.quantity * p.purchase_price) AS amount,
    3 AS sort_order
FROM sales_detail sd
JOIN sales_master sm ON sd.invoice_id = sm.invoice_id
JOIN products p ON sd.product_id = p.product_id
WHERE sm.invoice_date BETWEEN :p_from_date AND :p_to_date
AND sm.status = 1

UNION ALL

-- Operating Expenses
SELECT 
    'EXPENSES' AS section,
    el.type_name AS line_item,
    SUM(ed.amount) AS amount,
    4 AS sort_order
FROM expense_master em
JOIN expense_details ed ON em.expense_id = ed.expense_id
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
WHERE em.expense_date BETWEEN :p_from_date AND :p_to_date
AND em.status = 1
GROUP BY el.type_name

ORDER BY sort_order, line_item;


/*
================================================================================
REPORT: Cash Flow Summary
Description: Cash in and out summary
Parameters: p_from_date, p_to_date
================================================================================
*/
-- Cash In
SELECT 
    'CASH IN' AS flow_type,
    'Sales' AS source,
    sm.invoice_date AS transaction_date,
    sm.invoice_id AS reference,
    sm.grand_total AS amount,
    sm.payment_method
FROM sales_master sm
WHERE sm.invoice_date BETWEEN :p_from_date AND :p_to_date
AND sm.status = 1
AND sm.payment_status = 'PAID'

UNION ALL

-- Cash Out - Purchases
SELECT 
    'CASH OUT' AS flow_type,
    'Purchase Payment' AS source,
    p.payment_date AS transaction_date,
    p.payment_id AS reference,
    p.amount AS amount,
    p.payment_method
FROM payments p
WHERE p.payment_date BETWEEN :p_from_date AND :p_to_date
AND p.status = 1

UNION ALL

-- Cash Out - Expenses
SELECT 
    'CASH OUT' AS flow_type,
    'Expense: ' || el.type_name AS source,
    em.expense_date AS transaction_date,
    em.expense_id AS reference,
    SUM(ed.amount) AS amount,
    em.payment_method
FROM expense_master em
JOIN expense_details ed ON em.expense_id = ed.expense_id
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
WHERE em.expense_date BETWEEN :p_from_date AND :p_to_date
AND em.status = 1
GROUP BY 
    el.type_name, em.expense_date, em.expense_id, em.payment_method

ORDER BY transaction_date DESC, flow_type;


/*
================================================================================
SECTION 6: SUMMARY DASHBOARDS
================================================================================
*/

/*
================================================================================
REPORT: Executive Dashboard
Description: High-level KPIs
Parameters: p_from_date, p_to_date
================================================================================
*/
-- Sales KPIs
SELECT 
    'Sales' AS metric_category,
    COUNT(DISTINCT invoice_id) AS total_transactions,
    SUM(grand_total) AS total_value,
    AVG(grand_total) AS average_value
FROM sales_master
WHERE invoice_date BETWEEN :p_from_date AND :p_to_date
AND status = 1

UNION ALL

-- Inventory KPIs
SELECT 
    'Inventory' AS metric_category,
    COUNT(*) AS total_products,
    SUM(NVL(quantity, 0) * purchase_price) AS total_stock_value,
    AVG(NVL(quantity, 0)) AS avg_stock_level
FROM products p
LEFT JOIN stock s ON p.product_id = s.product_id AND s.status = 1
WHERE p.status = 1

UNION ALL

-- Service KPIs
SELECT 
    'Service' AS metric_category,
    COUNT(*) AS total_services,
    SUM(service_charge) AS total_service_revenue,
    AVG(service_charge) AS avg_service_charge
FROM service_master
WHERE service_date BETWEEN :p_from_date AND :p_to_date
AND status = 1

UNION ALL

-- Customer KPIs
SELECT 
    'Customers' AS metric_category,
    COUNT(*) AS total_active_customers,
    NULL AS total_value,
    NULL AS average_value
FROM customers
WHERE status = 1;


/*
================================================================================
REPORT: Top Performers Report
Description: Top products, customers, employees
Parameters: p_from_date, p_to_date, p_top_n (default 10)
================================================================================
*/
-- Top Products
SELECT 
    'PRODUCT' AS category,
    p.product_name AS name,
    SUM(sd.quantity) AS quantity,
    SUM(sd.total) AS value,
    RANK() OVER (ORDER BY SUM(sd.total) DESC) AS rank
FROM sales_detail sd
JOIN sales_master sm ON sd.invoice_id = sm.invoice_id
JOIN products p ON sd.product_id = p.product_id
WHERE sm.invoice_date BETWEEN :p_from_date AND :p_to_date
AND sm.status = 1
GROUP BY p.product_name
HAVING RANK() OVER (ORDER BY SUM(sd.total) DESC) <= :p_top_n

UNION ALL

-- Top Customers
SELECT 
    'CUSTOMER' AS category,
    c.customer_name AS name,
    COUNT(sm.invoice_id) AS quantity,
    SUM(sm.grand_total) AS value,
    RANK() OVER (ORDER BY SUM(sm.grand_total) DESC) AS rank
FROM customers c
JOIN sales_master sm ON c.customer_id = sm.customer_id
WHERE sm.invoice_date BETWEEN :p_from_date AND :p_to_date
AND sm.status = 1
GROUP BY c.customer_name
HAVING RANK() OVER (ORDER BY SUM(sm.grand_total) DESC) <= :p_top_n

UNION ALL

-- Top Employees
SELECT 
    'EMPLOYEE' AS category,
    e.first_name || ' ' || e.last_name AS name,
    COUNT(sm.invoice_id) AS quantity,
    SUM(sm.grand_total) AS value,
    RANK() OVER (ORDER BY SUM(sm.grand_total) DESC) AS rank
FROM employees e
JOIN sales_master sm ON e.employee_id = sm.sales_by
WHERE sm.invoice_date BETWEEN :p_from_date AND :p_to_date
AND sm.status = 1
GROUP BY e.first_name, e.last_name
HAVING RANK() OVER (ORDER BY SUM(sm.grand_total) DESC) <= :p_top_n

ORDER BY category, rank;


/*
================================================================================
SECTION 7: REPORT PARAMETERS DEFINITIONS
================================================================================
*/

/*
Parameter Name: p_from_date
Data Type: DATE
Default Value: TRUNC(SYSDATE, 'MM')  -- First day of current month
Display: Date Field
Format: DD-MON-YYYY
*/

/*
Parameter Name: p_to_date
Data Type: DATE
Default Value: SYSDATE
Display: Date Field
Format: DD-MON-YYYY
*/

/*
Parameter Name: p_category_id
Data Type: VARCHAR2(50)
Default Value: NULL (All Categories)
Display: List of Values
LOV Query:
    SELECT product_cat_name, product_cat_id
    FROM product_categories
    WHERE status = 1
    ORDER BY product_cat_name
*/

/*
Parameter Name: p_supplier_id
Data Type: VARCHAR2(50)
Default Value: NULL (All Suppliers)
Display: List of Values
LOV Query:
    SELECT supplier_name, supplier_id
    FROM suppliers
    WHERE status = 1
    ORDER BY supplier_name
*/

/*
Parameter Name: p_customer_id
Data Type: VARCHAR2(50)
Default Value: NULL (All Customers)
Display: List of Values
LOV Query:
    SELECT customer_name || ' - ' || phone_no, customer_id
    FROM customers
    WHERE status = 1
    ORDER BY customer_name
*/

/*
Parameter Name: p_service_status
Data Type: VARCHAR2(20)
Default Value: NULL (All Statuses)
Display: List of Values
Static Values:
    PENDING
    IN PROGRESS
    COMPLETED
    CANCELLED
*/

/*
Parameter Name: p_low_stock_only
Data Type: VARCHAR2(1)
Default Value: N
Display: Radio Group
Static Values:
    Y - Yes (Show only low stock)
    N - No (Show all products)
*/

/*
Parameter Name: p_top_n
Data Type: NUMBER
Default Value: 10
Display: Text Field
*/


/*
================================================================================
SECTION 8: REPORT FORMATTING GUIDELINES
================================================================================
*/

/*
-- Currency Format: BDT 999,999,990.00
-- Date Format: DD-MON-YYYY
-- Percentage Format: 990.99%

-- Report Header Fields:
Company Name: Oxen Company Limited
Report Period: From &p_from_date To &p_to_date
Generated Date: &SYSDATE
Generated By: &USER

-- Page Footer:
Page &P of &T
Confidential - For Internal Use Only

-- Color Coding:
Negative/Loss Values: Red
Warning/Alert Values: Orange
Positive/Profit Values: Green
Neutral/Info Values: Blue

-- Column Alignments:
Text: Left Aligned
Numbers: Right Aligned
Dates: Center Aligned
Currency: Right Aligned

-- Grouping:
Use breaks for master-detail reports
Show group summaries
Grand totals in report footer
*/


--------------------------------------------------------------------------------
-- END OF ORACLE REPORTS QUERIES
--------------------------------------------------------------------------------
