-- Comprehensive Data Integrity Validation
-- Run this to verify all master-detail relationships are correct

SET LINESIZE 250
SET PAGESIZE 100

PROMPT ============================================================
PROMPT INTEGRITY CHECK REPORT
PROMPT ============================================================

-- 1. Check if all receive details have matching order details
PROMPT ============================================================
PROMPT 1. RECEIVE DETAILS vs ORDER DETAILS
PROMPT ============================================================
SELECT 
    prd.receive_id,
    prd.product_id,
    p.product_code,
    prm.order_id,
    CASE WHEN pod.product_id IS NULL THEN '❌ MISSING' ELSE '✓ FOUND' END as status
FROM product_receive_details prd
JOIN product_receive_master prm ON prd.receive_id = prm.receive_id
JOIN products p ON prd.product_id = p.product_id
LEFT JOIN product_order_detail pod 
    ON prm.order_id = pod.order_id 
    AND prd.product_id = pod.product_id
ORDER BY prd.receive_id;

-- 2. Check stock table
PROMPT ============================================================
PROMPT 2. STOCK TABLE STATUS
PROMPT ============================================================
SELECT COUNT(*) as total_stock_rows FROM stock;
SELECT product_id, quantity FROM stock ORDER BY product_id;

-- 3. Check sales masters exist
PROMPT ============================================================
PROMPT 3. SALES MASTERS
PROMPT ============================================================
SELECT COUNT(*) as total_sales FROM sales_master;
SELECT invoice_id, customer_id FROM sales_master WHERE ROWNUM <= 5;

-- 4. Check sales details
PROMPT ============================================================
PROMPT 4. SALES DETAILS vs STOCK
PROMPT ============================================================
SELECT 
    sd.invoice_id,
    sd.product_id,
    p.product_code,
    sd.quantity as sales_qty,
    CASE WHEN s.stock_id IS NULL THEN '❌ NO STOCK' ELSE '✓ IN STOCK' END as stock_status,
    NVL(s.quantity, 0) as available_qty
FROM sales_detail sd
JOIN products p ON sd.product_id = p.product_id
LEFT JOIN stock s ON sd.product_id = s.product_id
ORDER BY sd.invoice_id;

-- 5. Summary
PROMPT ============================================================
PROMPT 5. DATA SUMMARY
PROMPT ============================================================
SELECT 'TABLES' as metric, COUNT(*) as value FROM user_tables
UNION ALL
SELECT 'PRODUCT ORDERS', COUNT(*) FROM product_order_master
UNION ALL
SELECT 'ORDER DETAILS', COUNT(*) FROM product_order_detail
UNION ALL
SELECT 'RECEIVES', COUNT(*) FROM product_receive_master
UNION ALL
SELECT 'RECEIVE DETAILS', COUNT(*) FROM product_receive_details
UNION ALL
SELECT 'STOCK ITEMS', COUNT(*) FROM stock
UNION ALL
SELECT 'SALES INVOICES', COUNT(*) FROM sales_master
UNION ALL
SELECT 'SALES DETAILS', COUNT(*) FROM sales_detail;

PROMPT ============================================================
PROMPT Validation Complete
PROMPT ============================================================
