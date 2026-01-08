-- Quick diagnostic to show order-receive relationships
-- Run this to see if the data is correct after executing clean_combined.sql

SET LINESIZE 200;
SET PAGESIZE 50;

PROMPT === CRITICAL CHECK: Order-Receive Mapping ===
PROMPT

SELECT 
    p.product_code,
    p.product_name,
    pod.order_id AS order_with_product,
    prm.order_id AS receive_order_id,
    prm.sup_invoice_id,
    CASE 
        WHEN pod.order_id = prm.order_id THEN 'OK'
        WHEN prm.order_id IS NULL THEN 'ERROR: receive_master.order_id IS NULL'
        WHEN pod.order_id IS NULL THEN 'ERROR: No order_detail for this product'  
        ELSE 'ERROR: MISMATCH - Receive points to wrong order!'
    END AS status
FROM products p
LEFT JOIN product_order_detail pod ON pod.product_id = p.product_id
LEFT JOIN (
    SELECT prm.order_id, prm.sup_invoice_id, prd.product_id
    FROM product_receive_master prm
    JOIN product_receive_details prd ON prm.receive_id = prd.receive_id
) prm ON prm.product_id = p.product_id
WHERE p.product_code IN (
    'SAM-S24-018', 'LG-REF-0411', 'WAL-TV-0512', 'SAM-WASH-0815', 'DEL-LAT-0310',
    'LG-HOM-1017', 'HIT-GEN-0916', 'MIN-AC-0613', 'IPH-15-029', 'PAN-MIC-0714'
)
ORDER BY p.product_code;

PROMPT
PROMPT === If you see ANY errors above, the data is incorrect ===
PROMPT === All rows should show 'OK' ===
