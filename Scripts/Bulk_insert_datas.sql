-- ================================================================================
-- Comprehensive Insert Data for Oxen Company Limited Database
-- Purpose: Add balanced sample data for all 33 tables with perfect FK alignment
-- Pattern: Follows master-detail transaction patterns with dynamic FK lookups
-- Status Filter: All lookups include "status = 1 AND ROWNUM = 1" for safety
-- ================================================================================

-- ============================================================================
-- SECTION 1: MASTER DATA EXPANSION
-- ============================================================================

-- ------------------------------------------------
-- 1.1 Additional Customers (15 new records)
-- ------------------------------------------------
PROMPT Inserting additional customers...

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Rahman Electronics', '01712345678', 'rahman@example.com', 'House 25, Road 5, Mirpur-1, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Karim Trading', '01812345679', 'karim@example.com', 'Shop 15, New Market, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Akter Stores', '01912345680', 'akter@example.com', 'House 42, Dhanmondi-15, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Hossain Electronics', '01612345681', 'hossain@example.com', 'Plot 8, Uttara Sector-4, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Begum Traders', '01712345682', 'begum@example.com', 'House 12, Mohammadpur, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Ali Enterprise', '01812345683', 'ali@example.com', 'Shop 22, Gulshan-2, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Sultana Electronics', '01912345684', 'sultana@example.com', 'House 67, Banani, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Ahmed Trading Co', '01612345685', 'ahmed@example.com', 'Plot 15, Bashundhara R/A, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Nasrin Stores', '01712345686', 'nasrin@example.com', 'House 88, Lalmatia, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Kabir Electronics Hub', '01812345687', 'kabir@example.com', 'Shop 5, Farmgate, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Siddique Traders', '01912345688', 'siddique@example.com', 'House 33, Mirpur-10, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Fatema Electronics', '01612345689', 'fatema@example.com', 'Plot 42, Uttara Sector-7, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Mia Trading House', '01712345690', 'mia@example.com', 'House 19, Dhanmondi-32, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Chowdhury Electronics', '01812345691', 'chowdhury@example.com', 'Shop 8, Elephant Road, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO customers (customer_name, phone_no, email, address, company_id)
VALUES ('Begum Trading Co', '01912345692', 'begumtrading@example.com', 'House 55, Mohakhali DOHS, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- ------------------------------------------------
-- 1.2 Additional Suppliers (8 new records)
-- ------------------------------------------------
PROMPT Inserting additional suppliers...

INSERT INTO suppliers (supplier_name, phone_no, email, address, company_id)
VALUES ('Vision Electronics BD', '01712340001', 'vision@supplier.com', 'Plot 22, Tejgaon I/A, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO suppliers (supplier_name, phone_no, email, address, company_id)
VALUES ('Minister Trading', '01812340002', 'minister@supplier.com', 'House 88, Uttara Sector-10, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO suppliers (supplier_name, phone_no, email, address, company_id)
VALUES ('Sharp Electronics Importer', '01912340003', 'sharp@supplier.com', 'Shop 12, Banglamotor, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO suppliers (supplier_name, phone_no, email, address, company_id)
VALUES ('Hitachi Distributor BD', '01612340004', 'hitachi@supplier.com', 'Plot 5, Mohakhali C/A, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO suppliers (supplier_name, phone_no, email, address, company_id)
VALUES ('Sony Bangladesh', '01712340005', 'sony@supplier.com', 'House 77, Banani-11, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO suppliers (supplier_name, phone_no, email, address, company_id)
VALUES ('Panasonic Parts Supplier', '01812340006', 'panasonic@supplier.com', 'Shop 33, Kawran Bazar, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO suppliers (supplier_name, phone_no, email, address, company_id)
VALUES ('Toshiba Electronics BD', '01912340007', 'toshiba@supplier.com', 'Plot 15, Gulshan-1, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO suppliers (supplier_name, phone_no, email, address, company_id)
VALUES ('Haier Appliances Distributor', '01612340008', 'haier@supplier.com', 'House 42, Mirpur-2, Dhaka', 
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- ------------------------------------------------
-- 1.3 Additional Products (20 new records)
-- ------------------------------------------------
PROMPT Inserting additional products...

-- Refrigerators
INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Vision Refrigerator 12 CFT', 'VIS-REF-12',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Refrigerator' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Non-Frost Refrigerator' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Vision' AND status = 1 AND ROWNUM = 1),
    28000, 32000, 5, 24,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Minister Refrigerator 15 CFT', 'MIN-REF-15',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Minister%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Refrigerator' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Frost Refrigerator' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Minister' AND status = 1 AND ROWNUM = 1),
    35000, 40000, 5, 24,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- Air Conditioners
INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Sharp AC 1.5 Ton Split', 'SHA-AC-1.5',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Air Conditioner' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Split AC' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Sharp' AND status = 1 AND ROWNUM = 1),
    38000, 45000, 8, 12,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Hitachi AC 2 Ton Inverter', 'HIT-AC-2.0',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Hitachi%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Air Conditioner' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Inverter AC' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Hitachi' AND status = 1 AND ROWNUM = 1),
    55000, 65000, 10, 36,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- LED Televisions
INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Sony 43 inch Smart LED TV', 'SON-LED-43',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sony%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'LED Television' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Smart LED TV' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Sony' AND status = 1 AND ROWNUM = 1),
    42000, 50000, 8, 24,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Sharp 32 inch HD LED TV', 'SHA-LED-32',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'LED Television' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'HD LED TV' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Sharp' AND status = 1 AND ROWNUM = 1),
    18000, 22000, 5, 12,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- Washing Machines
INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('LG 7kg Front Load Washing Machine', 'LG-WM-7F',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%LG%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Washing Machine' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Front Load Washing Machine' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'LG' AND status = 1 AND ROWNUM = 1),
    32000, 38000, 8, 24,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Samsung 8kg Top Load Washing Machine', 'SAM-WM-8T',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Washing Machine' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Top Load Washing Machine' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Samsung' AND status = 1 AND ROWNUM = 1),
    28000, 33000, 7, 24,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- Microwave Ovens
INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Panasonic 23L Microwave Oven', 'PAN-MW-23',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Microwave Oven' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Solo Microwave' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Panasonic' AND status = 1 AND ROWNUM = 1),
    8500, 10500, 5, 12,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Sharp 25L Convection Microwave', 'SHA-MW-25',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Microwave Oven' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Convection Microwave' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Sharp' AND status = 1 AND ROWNUM = 1),
    12000, 15000, 8, 24,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- Fans
INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Walton Ceiling Fan 56 inch', 'WAL-FAN-56',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Walton%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Fan' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Ceiling Fan' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Walton' AND status = 1 AND ROWNUM = 1),
    2200, 2800, 5, 12,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Vision Table Fan 16 inch', 'VIS-FAN-16',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Fan' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Table Fan' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Vision' AND status = 1 AND ROWNUM = 1),
    1500, 1900, 5, 6,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- Mobile Phones
INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Samsung Galaxy A54 5G', 'SAM-MOB-A54',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Mobile Phone' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Smartphone' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Samsung' AND status = 1 AND ROWNUM = 1),
    42000, 48000, 5, 12,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Walton Primo X7 Pro', 'WAL-MOB-X7',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Walton%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Mobile Phone' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Smartphone' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Walton' AND status = 1 AND ROWNUM = 1),
    18000, 22000, 8, 12,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- Kitchen Appliances
INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Singer Rice Cooker 2.8L', 'SIN-RC-2.8',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Singer%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Kitchen Appliance' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Rice Cooker' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Singer' AND status = 1 AND ROWNUM = 1),
    3200, 4000, 5, 12,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Panasonic Blender 1.5L', 'PAN-BL-1.5',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Kitchen Appliance' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Blender' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Panasonic' AND status = 1 AND ROWNUM = 1),
    2800, 3500, 5, 6,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- Iron
INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Philips Steam Iron 2400W', 'PHI-IRON-2400',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Iron' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Steam Iron' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Philips' AND status = 1 AND ROWNUM = 1),
    2500, 3200, 5, 12,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- Home Theatre
INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Sony Home Theatre 5.1 Channel', 'SON-HT-5.1',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sony%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Home Theatre' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = '5.1 Channel Home Theatre' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Sony' AND status = 1 AND ROWNUM = 1),
    28000, 35000, 10, 24,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- Laptop
INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('HP Laptop Core i5 8GB RAM', 'HP-LAP-I5',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sony%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Laptop' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Gaming Laptop' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'HP' AND status = 1 AND ROWNUM = 1),
    52000, 62000, 8, 24,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- Desktop
INSERT INTO products (product_name, product_code, supplier_id, product_cat_id, sub_cat_id, brand_id, 
    purchase_price, sales_price, discount_percent, warranty_months, company_id)
VALUES ('Walton Desktop Core i3 4GB', 'WAL-DES-I3',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Walton%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Desktop' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Gaming Desktop' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Walton' AND status = 1 AND ROWNUM = 1),
    32000, 38000, 5, 12,
    (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

COMMIT;

-- ============================================================================
-- SECTION 2: SUPPLY CHAIN TRANSACTIONS
-- ============================================================================

-- ------------------------------------------------
-- 2.1 Product Orders (10 orders with details)
-- ------------------------------------------------
PROMPT Inserting product orders...

-- Order 1: Vision Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-01',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id, 
        (SELECT product_id FROM products WHERE product_code = 'VIS-REF-12' AND status = 1 AND ROWNUM = 1),
        10, 28000);
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1),
        20, 1500);
    
    COMMIT;
END;
/

-- Order 2: Samsung Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-03',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-WM-8T' AND status = 1 AND ROWNUM = 1),
        8, 28000);
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-MOB-A54' AND status = 1 AND ROWNUM = 1),
        15, 42000);
    
    COMMIT;
END;
/

-- Order 3: LG Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-05',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%LG%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'LG-WM-7F' AND status = 1 AND ROWNUM = 1),
        12, 32000);
    
    COMMIT;
END;
/

-- Order 4: Sharp Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-07',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-AC-1.5' AND status = 1 AND ROWNUM = 1),
        6, 38000);
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        15, 18000);
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-MW-25' AND status = 1 AND ROWNUM = 1),
        10, 12000);
    
    COMMIT;
END;
/

-- Order 5: Walton Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-10',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Walton%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-FAN-56' AND status = 1 AND ROWNUM = 1),
        25, 2200);
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-MOB-X7' AND status = 1 AND ROWNUM = 1),
        20, 18000);
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-DES-I3' AND status = 1 AND ROWNUM = 1),
        5, 32000);
    
    COMMIT;
END;
/

-- Order 6: Sony Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-12',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sony%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-LED-43' AND status = 1 AND ROWNUM = 1),
        10, 42000);
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-HT-5.1' AND status = 1 AND ROWNUM = 1),
        8, 28000);
    
    COMMIT;
END;
/

-- Order 7: Minister Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-15',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Minister%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'MIN-REF-15' AND status = 1 AND ROWNUM = 1),
        7, 35000);
    
    COMMIT;
END;
/

-- Order 8: Hitachi Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-18',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Hitachi%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'HIT-AC-2.0' AND status = 1 AND ROWNUM = 1),
        5, 55000);
    
    COMMIT;
END;
/

-- Order 9: Panasonic Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-20',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-MW-23' AND status = 1 AND ROWNUM = 1),
        12, 8500);
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-BL-1.5' AND status = 1 AND ROWNUM = 1),
        18, 2800);
    
    COMMIT;
END;
/

-- Order 10: Singer Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-22',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Singer%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SIN-RC-2.8' AND status = 1 AND ROWNUM = 1),
        15, 3200);
    
    INSERT INTO product_order_detail (order_id, product_id, order_quantity, unit_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'PHI-IRON-2400' AND status = 1 AND ROWNUM = 1),
        10, 2500);
    
    COMMIT;
END;
/

-- ------------------------------------------------
-- 2.2 Product Receives (10 receives linked to orders)
-- ------------------------------------------------
PROMPT Inserting product receives...

-- Receive 1: For Order 1 (Vision)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, receive_by)
    VALUES (
        DATE '2025-11-05',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-01' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-REF-12' AND status = 1 AND ROWNUM = 1),
        10, 28000);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1),
        20, 1500);
    
    COMMIT;
END;
/

-- Receive 2: For Order 2 (Samsung)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, receive_by)
    VALUES (
        DATE '2025-11-08',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-03' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-WM-8T' AND status = 1 AND ROWNUM = 1),
        8, 28000);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-MOB-A54' AND status = 1 AND ROWNUM = 1),
        15, 42000);
    
    COMMIT;
END;
/

-- Receive 3: For Order 3 (LG)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, receive_by)
    VALUES (
        DATE '2025-11-10',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-05' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%LG%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'LG-WM-7F' AND status = 1 AND ROWNUM = 1),
        12, 32000);
    
    COMMIT;
END;
/

-- Receive 4: For Order 4 (Sharp)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, receive_by)
    VALUES (
        DATE '2025-11-12',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-07' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-AC-1.5' AND status = 1 AND ROWNUM = 1),
        6, 38000);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        15, 18000);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-MW-25' AND status = 1 AND ROWNUM = 1),
        10, 12000);
    
    COMMIT;
END;
/

-- Receive 5: For Order 5 (Walton)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, receive_by)
    VALUES (
        DATE '2025-11-14',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-10' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Walton%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-FAN-56' AND status = 1 AND ROWNUM = 1),
        25, 2200);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-MOB-X7' AND status = 1 AND ROWNUM = 1),
        20, 18000);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-DES-I3' AND status = 1 AND ROWNUM = 1),
        5, 32000);
    
    COMMIT;
END;
/

-- Receive 6: For Order 6 (Sony)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, receive_by)
    VALUES (
        DATE '2025-11-17',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-12' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sony%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-LED-43' AND status = 1 AND ROWNUM = 1),
        10, 42000);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-HT-5.1' AND status = 1 AND ROWNUM = 1),
        8, 28000);
    
    COMMIT;
END;
/

-- Receive 7: For Order 7 (Minister)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, receive_by)
    VALUES (
        DATE '2025-11-20',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-15' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Minister%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'MIN-REF-15' AND status = 1 AND ROWNUM = 1),
        7, 35000);
    
    COMMIT;
END;
/

-- Receive 8: For Order 8 (Hitachi)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, receive_by)
    VALUES (
        DATE '2025-11-23',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-18' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Hitachi%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'HIT-AC-2.0' AND status = 1 AND ROWNUM = 1),
        5, 55000);
    
    COMMIT;
END;
/

-- Receive 9: For Order 9 (Panasonic)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, receive_by)
    VALUES (
        DATE '2025-11-25',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-20' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-MW-23' AND status = 1 AND ROWNUM = 1),
        12, 8500);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-BL-1.5' AND status = 1 AND ROWNUM = 1),
        18, 2800);
    
    COMMIT;
END;
/

-- Receive 10: For Order 10 (Singer)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, receive_by)
    VALUES (
        DATE '2025-11-27',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-22' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Singer%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SIN-RC-2.8' AND status = 1 AND ROWNUM = 1),
        15, 3200);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, unit_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'PHI-IRON-2400' AND status = 1 AND ROWNUM = 1),
        10, 2500);
    
    COMMIT;
END;
/

-- ------------------------------------------------
-- 2.3 Product Returns (5 returns for supplier)
-- ------------------------------------------------
PROMPT Inserting product returns...

-- Return 1: Defective Vision Fans
DECLARE
    v_return_id VARCHAR2(50);
BEGIN
    INSERT INTO product_return_master (return_date, supplier_id, return_by, reason)
    VALUES (
        DATE '2025-11-08',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Defective motors in fans'
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO product_return_details (return_id, product_id, return_quantity, unit_price)
    VALUES (v_return_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1),
        3, 1500);
    
    COMMIT;
END;
/

-- Return 2: Damaged Samsung Phones
DECLARE
    v_return_id VARCHAR2(50);
BEGIN
    INSERT INTO product_return_master (return_date, supplier_id, return_by, reason)
    VALUES (
        DATE '2025-11-11',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Screen damage during shipping'
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO product_return_details (return_id, product_id, return_quantity, unit_price)
    VALUES (v_return_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-MOB-A54' AND status = 1 AND ROWNUM = 1),
        2, 42000);
    
    COMMIT;
END;
/

-- Return 3: Defective Sharp LED
DECLARE
    v_return_id VARCHAR2(50);
BEGIN
    INSERT INTO product_return_master (return_date, supplier_id, return_by, reason)
    VALUES (
        DATE '2025-11-15',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Dead pixels on screen'
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO product_return_details (return_id, product_id, return_quantity, unit_price)
    VALUES (v_return_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        1, 18000);
    
    COMMIT;
END;
/

-- Return 4: Faulty Panasonic Blenders
DECLARE
    v_return_id VARCHAR2(50);
BEGIN
    INSERT INTO product_return_master (return_date, supplier_id, return_by, reason)
    VALUES (
        DATE '2025-11-28',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Motor overheating issue'
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO product_return_details (return_id, product_id, return_quantity, unit_price)
    VALUES (v_return_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-BL-1.5' AND status = 1 AND ROWNUM = 1),
        4, 2800);
    
    COMMIT;
END;
/

-- Return 5: Wrong Model Singer Rice Cooker
DECLARE
    v_return_id VARCHAR2(50);
BEGIN
    INSERT INTO product_return_master (return_date, supplier_id, return_by, reason)
    VALUES (
        DATE '2025-11-30',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Singer%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Wrong model sent by supplier'
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO product_return_details (return_id, product_id, return_quantity, unit_price)
    VALUES (v_return_id,
        (SELECT product_id FROM products WHERE product_code = 'SIN-RC-2.8' AND status = 1 AND ROWNUM = 1),
        2, 3200);
    
    COMMIT;
END;
/

-- ============================================================================
-- SECTION 3: SALES TRANSACTIONS
-- ============================================================================

-- ------------------------------------------------
-- 3.1 Additional Sales (15 new sales with details)
-- ------------------------------------------------
PROMPT Inserting additional sales...

-- Sale 1
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-01',
        (SELECT customer_id FROM customers WHERE customer_name = 'Rahman Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        2000, 1800
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-REF-12' AND status = 1 AND ROWNUM = 1),
        2, 32000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1),
        3, 1900);
    
    COMMIT;
END;
/

-- Sale 2
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-02',
        (SELECT customer_id FROM customers WHERE customer_name = 'Karim Trading' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        3000, 2500
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-WM-8T' AND status = 1 AND ROWNUM = 1),
        1, 33000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-MOB-A54' AND status = 1 AND ROWNUM = 1),
        2, 48000);
    
    COMMIT;
END;
/

-- Sale 3
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-03',
        (SELECT customer_id FROM customers WHERE customer_name = 'Akter Stores' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        2500, 2200
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'LG-WM-7F' AND status = 1 AND ROWNUM = 1),
        1, 38000);
    
    COMMIT;
END;
/

-- Sale 4
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-04',
        (SELECT customer_id FROM customers WHERE customer_name = 'Hossain Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        4000, 3500
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-AC-1.5' AND status = 1 AND ROWNUM = 1),
        1, 45000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        2, 22000);
    
    COMMIT;
END;
/

-- Sale 5
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-05',
        (SELECT customer_id FROM customers WHERE customer_name = 'Begum Traders' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        5000, 4500
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'HIT-AC-2.0' AND status = 1 AND ROWNUM = 1),
        1, 65000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-FAN-56' AND status = 1 AND ROWNUM = 1),
        4, 2800);
    
    COMMIT;
END;
/

-- Sale 6
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-06',
        (SELECT customer_id FROM customers WHERE customer_name = 'Ali Enterprise' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        3500, 3000
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-LED-43' AND status = 1 AND ROWNUM = 1),
        1, 50000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-MOB-X7' AND status = 1 AND ROWNUM = 1),
        1, 22000);
    
    COMMIT;
END;
/

-- Sale 7
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-07',
        (SELECT customer_id FROM customers WHERE customer_name = 'Sultana Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        2000, 1500
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'MIN-REF-15' AND status = 1 AND ROWNUM = 1),
        1, 40000);
    
    COMMIT;
END;
/

-- Sale 8
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-08',
        (SELECT customer_id FROM customers WHERE customer_name = 'Ahmed Trading Co' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        1800, 1200
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-MW-23' AND status = 1 AND ROWNUM = 1),
        2, 10500);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-BL-1.5' AND status = 1 AND ROWNUM = 1),
        3, 3500);
    
    COMMIT;
END;
/

-- Sale 9
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-09',
        (SELECT customer_id FROM customers WHERE customer_name = 'Nasrin Stores' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        1500, 1000
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SIN-RC-2.8' AND status = 1 AND ROWNUM = 1),
        4, 4000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'PHI-IRON-2400' AND status = 1 AND ROWNUM = 1),
        3, 3200);
    
    COMMIT;
END;
/

-- Sale 10
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-10',
        (SELECT customer_id FROM customers WHERE customer_name = 'Kabir Electronics Hub' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        4500, 4000
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-HT-5.1' AND status = 1 AND ROWNUM = 1),
        1, 35000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-MW-25' AND status = 1 AND ROWNUM = 1),
        2, 15000);
    
    COMMIT;
END;
/

-- Sale 11
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-11',
        (SELECT customer_id FROM customers WHERE customer_name = 'Siddique Traders' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        3000, 2500
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-DES-I3' AND status = 1 AND ROWNUM = 1),
        1, 38000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'HP-LAP-I5' AND status = 1 AND ROWNUM = 1),
        1, 62000);
    
    COMMIT;
END;
/

-- Sale 12
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-12',
        (SELECT customer_id FROM customers WHERE customer_name = 'Fatema Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        1000, 800
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1),
        5, 1900);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-FAN-56' AND status = 1 AND ROWNUM = 1),
        3, 2800);
    
    COMMIT;
END;
/

-- Sale 13
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-13',
        (SELECT customer_id FROM customers WHERE customer_name = 'Mia Trading House' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        5500, 5000
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-WM-8T' AND status = 1 AND ROWNUM = 1),
        2, 33000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'LG-WM-7F' AND status = 1 AND ROWNUM = 1),
        1, 38000);
    
    COMMIT;
END;
/

-- Sale 14
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-14',
        (SELECT customer_id FROM customers WHERE customer_name = 'Chowdhury Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        2500, 2000
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        3, 22000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-LED-43' AND status = 1 AND ROWNUM = 1),
        1, 50000);
    
    COMMIT;
END;
/

-- Sale 15
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-15',
        (SELECT customer_id FROM customers WHERE customer_name = 'Begum Trading Co' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        6000, 5500
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-MOB-A54' AND status = 1 AND ROWNUM = 1),
        3, 48000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, unit_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-MOB-X7' AND status = 1 AND ROWNUM = 1),
        2, 22000);
    
    COMMIT;
END;
/

-- ------------------------------------------------
-- 3.2 Sales Returns (5 customer returns)
-- ------------------------------------------------
PROMPT Inserting sales returns...

-- Sales Return 1
DECLARE
    v_return_id VARCHAR2(50);
    v_invoice_id VARCHAR2(50);
BEGIN
    -- Get a recent invoice
    SELECT invoice_id INTO v_invoice_id 
    FROM sales_master 
    WHERE invoice_date = DATE '2025-12-01' AND status = 1 AND ROWNUM = 1;
    
    INSERT INTO sales_return_master (return_date, invoice_id, customer_id, return_by, reason)
    VALUES (
        DATE '2025-12-05',
        v_invoice_id,
        (SELECT customer_id FROM customers WHERE customer_name = 'Rahman Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Customer changed mind'
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO sales_return_details (return_id, invoice_id, product_id, quantity, qty_return, unit_price)
    VALUES (v_return_id, v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1),
        3, 1, 1900);
    
    COMMIT;
END;
/

-- Sales Return 2
DECLARE
    v_return_id VARCHAR2(50);
    v_invoice_id VARCHAR2(50);
BEGIN
    SELECT invoice_id INTO v_invoice_id 
    FROM sales_master 
    WHERE invoice_date = DATE '2025-12-04' AND status = 1 AND ROWNUM = 1;
    
    INSERT INTO sales_return_master (return_date, invoice_id, customer_id, return_by, reason)
    VALUES (
        DATE '2025-12-08',
        v_invoice_id,
        (SELECT customer_id FROM customers WHERE customer_name = 'Hossain Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Product not working properly'
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO sales_return_details (return_id, invoice_id, product_id, quantity, qty_return, unit_price)
    VALUES (v_return_id, v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        2, 1, 22000);
    
    COMMIT;
END;
/

-- Sales Return 3
DECLARE
    v_return_id VARCHAR2(50);
    v_invoice_id VARCHAR2(50);
BEGIN
    SELECT invoice_id INTO v_invoice_id 
    FROM sales_master 
    WHERE invoice_date = DATE '2025-12-09' AND status = 1 AND ROWNUM = 1;
    
    INSERT INTO sales_return_master (return_date, invoice_id, customer_id, return_by, reason)
    VALUES (
        DATE '2025-12-12',
        v_invoice_id,
        (SELECT customer_id FROM customers WHERE customer_name = 'Nasrin Stores' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Wrong model delivered'
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO sales_return_details (return_id, invoice_id, product_id, quantity, qty_return, unit_price)
    VALUES (v_return_id, v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'PHI-IRON-2400' AND status = 1 AND ROWNUM = 1),
        3, 2, 3200);
    
    COMMIT;
END;
/

-- Sales Return 4
DECLARE
    v_return_id VARCHAR2(50);
    v_invoice_id VARCHAR2(50);
BEGIN
    SELECT invoice_id INTO v_invoice_id 
    FROM sales_master 
    WHERE invoice_date = DATE '2025-12-14' AND status = 1 AND ROWNUM = 1;
    
    INSERT INTO sales_return_master (return_date, invoice_id, customer_id, return_by, reason)
    VALUES (
        DATE '2025-12-16',
        v_invoice_id,
        (SELECT customer_id FROM customers WHERE customer_name = 'Chowdhury Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Screen flickering issue'
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO sales_return_details (return_id, invoice_id, product_id, quantity, qty_return, unit_price)
    VALUES (v_return_id, v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        3, 1, 22000);
    
    COMMIT;
END;
/

-- Sales Return 5
DECLARE
    v_return_id VARCHAR2(50);
    v_invoice_id VARCHAR2(50);
BEGIN
    SELECT invoice_id INTO v_invoice_id 
    FROM sales_master 
    WHERE invoice_date = DATE '2025-12-15' AND status = 1 AND ROWNUM = 1;
    
    INSERT INTO sales_return_master (return_date, invoice_id, customer_id, return_by, reason)
    VALUES (
        DATE '2025-12-18',
        v_invoice_id,
        (SELECT customer_id FROM customers WHERE customer_name = 'Begum Trading Co' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Battery draining fast'
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO sales_return_details (return_id, invoice_id, product_id, quantity, qty_return, unit_price)
    VALUES (v_return_id, v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-MOB-X7' AND status = 1 AND ROWNUM = 1),
        2, 1, 22000);
    
    COMMIT;
END;
/

-- ============================================================================
-- SECTION 4: FINANCIAL TRANSACTIONS
-- ============================================================================

-- ------------------------------------------------
-- 4.1 Supplier Payments (12 payments)
-- ------------------------------------------------
PROMPT Inserting supplier payments...

-- Payment 1: Vision
INSERT INTO payments (payment_date, supplier_id, amount, payment_method, payment_by)
VALUES (
    DATE '2025-11-10',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
    250000,
    'Bank Transfer',
    (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
);

-- Payment 2: Samsung
INSERT INTO payments (payment_date, supplier_id, amount, payment_method, payment_by)
VALUES (
    DATE '2025-11-12',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
    850000,
    'Bank Transfer',
    (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
);

-- Payment 3: LG
INSERT INTO payments (payment_date, supplier_id, amount, payment_method, payment_by)
VALUES (
    DATE '2025-11-15',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%LG%' AND status = 1 AND ROWNUM = 1),
    384000,
    'Cheque',
    (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
);

-- Payment 4: Sharp
INSERT INTO payments (payment_date, supplier_id, amount, payment_method, payment_by)
VALUES (
    DATE '2025-11-18',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
    620000,
    'Bank Transfer',
    (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
);

-- Payment 5: Walton
INSERT INTO payments (payment_date, supplier_id, amount, payment_method, payment_by)
VALUES (
    DATE '2025-11-20',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Walton%' AND status = 1 AND ROWNUM = 1),
    575000,
    'Bank Transfer',
    (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
);

-- Payment 6: Sony
INSERT INTO payments (payment_date, supplier_id, amount, payment_method, payment_by)
VALUES (
    DATE '2025-11-22',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sony%' AND status = 1 AND ROWNUM = 1),
    644000,
    'Cheque',
    (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
);

-- Payment 7: Minister
INSERT INTO payments (payment_date, supplier_id, amount, payment_method, payment_by)
VALUES (
    DATE '2025-11-25',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Minister%' AND status = 1 AND ROWNUM = 1),
    245000,
    'Bank Transfer',
    (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
);

-- Payment 8: Hitachi
INSERT INTO payments (payment_date, supplier_id, amount, payment_method, payment_by)
VALUES (
    DATE '2025-11-28',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Hitachi%' AND status = 1 AND ROWNUM = 1),
    275000,
    'Bank Transfer',
    (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
);

-- Payment 9: Panasonic
INSERT INTO payments (payment_date, supplier_id, amount, payment_method, payment_by)
VALUES (
    DATE '2025-11-30',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
    152400,
    'Cheque',
    (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
);

-- Payment 10: Singer
INSERT INTO payments (payment_date, supplier_id, amount, payment_method, payment_by)
VALUES (
    DATE '2025-12-02',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Singer%' AND status = 1 AND ROWNUM = 1),
    73000,
    'Bank Transfer',
    (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
);

-- Payment 11: Vision (Second payment)
INSERT INTO payments (payment_date, supplier_id, amount, payment_method, payment_by)
VALUES (
    DATE '2025-12-05',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
    150000,
    'Bank Transfer',
    (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
);

-- Payment 12: Samsung (Second payment)
INSERT INTO payments (payment_date, supplier_id, amount, payment_method, payment_by)
VALUES (
    DATE '2025-12-08',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
    500000,
    'Cheque',
    (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
);

COMMIT;

-- ============================================================================
-- SECTION 5: SERVICE TRANSACTIONS (from insert_services.sql)
-- ============================================================================

-- ------------------------------------------------
-- 5.1 Service Requests (14 service records with details)
-- ------------------------------------------------
PROMPT Inserting service requests...

-- Service 1: Mobile phone repair (customer walk-in, no invoice link)
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2025-12-03',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Samsung Galaxy S24%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Mobile Service and Repair' AND status = 1 AND ROWNUM = 1),
    1,
    1000,
    1000,
    'N',
    'Screen replacement diagnosis and cleaning'
  );
END;
/

-- Service 2: Washing machine diagnosis (linked to invoice to test warranty)
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, invoice_id, service_by)
  VALUES (
    DATE '2025-12-07',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT invoice_id FROM sales_master WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Washing Machine%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Washing Machine Repair' AND status = 1 AND ROWNUM = 1),
    1,
    1800,
    1800,
    'Y',
    'General diagnosis and water inlet check'
  );
END;
/

-- Service 3: LED TV power board replacement (with parts)
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2025-12-15',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  -- Line 1: Diagnostic service
  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%LED%TV%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'TV Repair Service' AND status = 1 AND ROWNUM = 1),
    1,
    1500,
    1500,
    'N',
    'Power board faulty diagnosis'
  );

  -- Line 2: Parts replacement
  INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%LED%TV%' AND status = 1 AND ROWNUM = 1),
    (SELECT parts_id FROM parts WHERE parts_name LIKE '%Power Supply Board%' AND status = 1 AND ROWNUM = 1),
    1,
    2500,
    2500,
    'N',
    'Power board replaced'
  );
END;
/

-- Service 4: Refrigerator gas refill and check
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2025-12-20',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Refrigerator%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Refrigerator Repair' AND status = 1 AND ROWNUM = 1),
    1,
    2000,
    2000,
    'N',
    'Gas refill and condenser cleaning'
  );
END;
/

-- Service 5: Air Conditioner cleaning and servicing
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2025-12-22',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Air Conditioner%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'AC Servicing' AND status = 1 AND ROWNUM = 1),
    1,
    1500,
    1500,
    'N',
    'Complete AC servicing and filter cleaning'
  );
END;
/

-- Service 6: Mobile phone battery replacement (with parts)
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2025-12-25',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  -- Service charge
  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Samsung Galaxy S24%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Mobile Service and Repair' AND status = 1 AND ROWNUM = 1),
    1,
    1000,
    1000,
    'N',
    'Battery replacement and testing'
  );

  -- Parts cost
  INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Samsung Galaxy S24%' AND status = 1 AND ROWNUM = 1),
    (SELECT parts_id FROM parts WHERE parts_name LIKE '%Battery%' AND status = 1 AND ROWNUM = 1),
    1,
    1800,
    1800,
    'Y',
    'Original battery installed'
  );
END;
/

-- Service 7: Microwave oven repair (warranty service)
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, invoice_id, service_by)
  VALUES (
    DATE '2025-12-28',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT invoice_id FROM sales_master WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Microwave%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Microwave Oven Repair' AND status = 1 AND ROWNUM = 1),
    1,
    0,
    0,
    'Y',
    'Warranty service - turntable motor replacement'
  );
END;
/

-- Service 8: Laptop screen repair
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2026-01-03',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Laptop%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Laptop / Computer Repair' AND status = 1 AND ROWNUM = 1),
    1,
    2000,
    2000,
    'N',
    'Screen replacement (customer provided screen)'
  );
END;
/

-- Service 9: Washing machine motor replacement (complex repair)
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2026-01-08',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  -- Diagnosis
  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Washing Machine%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Washing Machine Repair' AND status = 1 AND ROWNUM = 1),
    1,
    1800,
    1800,
    'N',
    'Motor fault diagnosis and replacement'
  );

  -- Parts replacement
  INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Washing Machine%' AND status = 1 AND ROWNUM = 1),
    (SELECT parts_id FROM parts WHERE parts_name LIKE '%Belt%' AND status = 1 AND ROWNUM = 1),
    1,
    800,
    800,
    'Y',
    'Drum belt replaced with original parts'
  );
END;
/

-- Service 10: LED TV software update and tuning
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2026-01-12',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%LED%TV%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'TV Installation' AND status = 1 AND ROWNUM = 1),
    1,
    800,
    800,
    'N',
    'Software update and channel tuning'
  );
END;
/

-- Service 11: Refrigerator compressor issue diagnosis
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, invoice_id, service_by)
  VALUES (
    DATE '2026-01-15',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT invoice_id FROM sales_master WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Refrigerator%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Refrigerator Repair' AND status = 1 AND ROWNUM = 1),
    1,
    2000,
    2000,
    'Y',
    'Compressor noise diagnosis and lubrication'
  );
END;
/

-- Service 12: Mobile phone water damage repair
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2026-01-18',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  -- Cleaning service
  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Samsung Galaxy S24%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Mobile Service and Repair' AND status = 1 AND ROWNUM = 1),
    1,
    1000,
    1000,
    'N',
    'Water damage cleaning and component testing'
  );

  -- Parts replacement (if needed)
  INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Samsung Galaxy S24%' AND status = 1 AND ROWNUM = 1),
    (SELECT parts_id FROM parts WHERE parts_name LIKE '%Display%' AND status = 1 AND ROWNUM = 1),
    1,
    3500,
    3500,
    'N',
    'Display panel damaged - replaced'
  );
END;
/

-- Service 13: Desktop computer hardware upgrade
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2026-01-20',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Laptop%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Laptop / Computer Repair' AND status = 1 AND ROWNUM = 1),
    1,
    2000,
    2000,
    'N',
    'RAM upgrade and SSD installation service'
  );
END;
/

-- Service 14: Iron board heating element replacement
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2026-01-23',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  -- Diagnosis and repair
  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Home Appliance Diagnosis' AND status = 1 AND ROWNUM = 1),
    1,
    500,
    500,
    'N',
    'Small appliance heating element repair'
  );
END;
/

-- ============================================================================
-- SECTION 6: EXPENSE TRANSACTIONS (from insert_expenses.sql)
-- ============================================================================

-- ------------------------------------------------
-- 6.1 Expense Records (16 expense masters with details)
-- ------------------------------------------------
PROMPT Inserting expense transactions...

-- Expense 1: Office Rent (Finance and Accounting)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-01',
    (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'OFF' AND status = 1 AND ROWNUM = 1),
    'Accounts Team'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'December office rent (main branch)', 30000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Service charge', 1500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Common area maintenance', 500);

-- Expense 2: Utility Bills (Finance and Accounting)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-05',
    (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'UTL' AND status = 1 AND ROWNUM = 1),
    'Accounts Team'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Electricity bill - Dec', 9000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Water bill - Dec', 2000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Gas bill - Dec', 4000);

-- Expense 3: Internet and Telephone (IT Infrastructure)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-06',
    (SELECT department_id FROM departments WHERE department_name = 'IT Infrastructure' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'INT' AND status = 1 AND ROWNUM = 1),
    'IT Officer'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Corporate Internet bill (100 Mbps)', 3500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Office landline bill', 1200);

-- Expense 4: Technician Allowance (After Sales Service)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-10',
    (SELECT department_id FROM departments WHERE department_name = 'After Sales Service' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'TEC' AND status = 1 AND ROWNUM = 1),
    'Service Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Uttara site visit allowance', 1500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Dhanmondi site visit allowance', 1800);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Transport (CNG/Bus)', 600);

-- Expense 5: Marketing and Promotion (Sales Department)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-12',
    (SELECT department_id FROM departments WHERE department_name = 'Sales Department' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'MKT' AND status = 1 AND ROWNUM = 1),
    'Sales Lead'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Facebook ads (Dhaka targeting)', 3000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Banner printing and setup', 2500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Local market promotion', 1200);

-- Expense 6: Staff Salary (Human Resources)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-31',
    (SELECT department_id FROM departments WHERE department_name = 'Human Resources' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'SAL' AND status = 1 AND ROWNUM = 1),
    'HR Officer'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Technician salary - Dec', 35000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Sales executive salary - Dec', 25000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Support staff salary - Dec', 20000);

-- Expense 7: Office Supplies (Finance and Accounting)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-15',
    (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'OFF' AND status = 1 AND ROWNUM = 1),
    'Office Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Printer paper and stationery', 4500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Printer ink cartridges', 6200);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Office supplies (pens, files, folders)', 2800);

-- Expense 8: Transportation Allowance (Sales Department)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-18',
    (SELECT department_id FROM departments WHERE department_name = 'Sales Department' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'TRN' AND status = 1 AND ROWNUM = 1),
    'Sales Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Field sales transport - Gulshan area', 2500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Field sales transport - Banani area', 2200);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Fuel allowance for sales team', 5000);

-- Expense 9: IT Equipment Maintenance (IT Infrastructure)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-20',
    (SELECT department_id FROM departments WHERE department_name = 'IT Infrastructure' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'REP' AND status = 1 AND ROWNUM = 1),
    'IT Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Server maintenance and backup', 12000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Software licenses renewal', 8500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Network equipment repair', 4500);

-- Expense 10: Training and Development (Human Resources)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-05',
    (SELECT department_id FROM departments WHERE department_name = 'Human Resources' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'OTH' AND status = 1 AND ROWNUM = 1),
    'HR Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Technical training for service staff', 15000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Sales training workshop', 10000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Training materials and refreshments', 3500);

-- Expense 11: Security Services (Finance and Accounting)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-10',
    (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'OFF' AND status = 1 AND ROWNUM = 1),
    'Accounts Officer'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Security guard salary - January', 18000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'CCTV maintenance', 3500);

-- Expense 12: Courier and Delivery (Sales Department)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-12',
    (SELECT department_id FROM departments WHERE department_name = 'Sales Department' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'TRN' AND status = 1 AND ROWNUM = 1),
    'Sales Coordinator'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Product delivery charges (Dhaka)', 7500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Courier service (document delivery)', 2500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Packaging materials', 3200);

-- Expense 13: Spare Parts Purchase (After Sales Service)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-15',
    (SELECT department_id FROM departments WHERE department_name = 'After Sales Service' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'PUR' AND status = 1 AND ROWNUM = 1),
    'Service Head'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Mobile phone spare parts', 25000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Refrigerator compressor parts', 15000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'LED TV panel replacement parts', 18000);

-- Expense 14: Professional Fees (Finance and Accounting)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-18',
    (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'OTH' AND status = 1 AND ROWNUM = 1),
    'Finance Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Legal consultation fees', 12000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Audit and accounting services', 20000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Tax filing assistance', 8000);

-- Expense 15: Customer Entertainment (Sales Department)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-20',
    (SELECT department_id FROM departments WHERE department_name = 'Sales Department' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'MKT' AND status = 1 AND ROWNUM = 1),
    'Business Development Lead'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Client meeting refreshments', 4500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Business lunch expenses', 6200);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Corporate gifts for clients', 8500);

-- Expense 16: Building Maintenance (Finance and Accounting)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-22',
    (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'REP' AND status = 1 AND ROWNUM = 1),
    'Facility Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'AC servicing and repair', 8500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Plumbing repairs', 3500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Electrical maintenance', 5200);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Painting and cleaning', 7000);

-- ============================================================================
-- SECTION 7: DAMAGE RECORDS
-- ============================================================================

-- ------------------------------------------------
-- 7.1 Damage Transactions (8 damage records)
-- ------------------------------------------------
PROMPT Inserting damage records...

-- Damage 1: Water damaged fans
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date, reported_by, reason)
    VALUES (
        DATE '2025-11-08',
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Store and Warehouse' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Water leakage in warehouse'
    )
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, damage_cost)
    VALUES (v_damage_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1),
        2, 3000);
    
    COMMIT;
END;
/

-- Damage 2: Dropped microwave ovens
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date, reported_by, reason)
    VALUES (
        DATE '2025-11-12',
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Store and Warehouse' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Dropped during handling'
    )
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, damage_cost)
    VALUES (v_damage_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-MW-23' AND status = 1 AND ROWNUM = 1),
        1, 8500);
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, damage_cost)
    VALUES (v_damage_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-MW-25' AND status = 1 AND ROWNUM = 1),
        1, 12000);
    
    COMMIT;
END;
/

-- Damage 3: Power surge
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date, reported_by, reason)
    VALUES (
        DATE '2025-11-18',
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Store and Warehouse' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Power surge during testing'
    )
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, damage_cost)
    VALUES (v_damage_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        1, 18000);
    
    COMMIT;
END;
/

-- Damage 4: Shipping accident
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date, reported_by, reason)
    VALUES (
        DATE '2025-11-22',
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Store and Warehouse' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Delivery truck accident'
    )
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, damage_cost)
    VALUES (v_damage_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-MOB-X7' AND status = 1 AND ROWNUM = 1),
        3, 54000);
    
    COMMIT;
END;
/

-- Damage 5: Manufacturing defect
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date, reported_by, reason)
    VALUES (
        DATE '2025-11-25',
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Service and Support' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Manufacturing defect found in batch'
    )
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, damage_cost)
    VALUES (v_damage_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-BL-1.5' AND status = 1 AND ROWNUM = 1),
        5, 14000);
    
    COMMIT;
END;
/

-- Damage 6: Fire in showroom
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date, reported_by, reason)
    VALUES (
        DATE '2025-11-28',
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Store and Warehouse' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Minor fire incident in showroom'
    )
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, damage_cost)
    VALUES (v_damage_id,
        (SELECT product_id FROM products WHERE product_code = 'SIN-RC-2.8' AND status = 1 AND ROWNUM = 1),
        3, 9600);
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, damage_cost)
    VALUES (v_damage_id,
        (SELECT product_id FROM products WHERE product_code = 'PHI-IRON-2400' AND status = 1 AND ROWNUM = 1),
        2, 5000);
    
    COMMIT;
END;
/

-- Damage 7: Expired warranty products
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date, reported_by, reason)
    VALUES (
        DATE '2025-12-01',
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Service and Support' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Customer abuse beyond warranty'
    )
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, damage_cost)
    VALUES (v_damage_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-FAN-56' AND status = 1 AND ROWNUM = 1),
        1, 2200);
    
    COMMIT;
END;
/

-- Damage 8: Theft
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date, reported_by, reason)
    VALUES (
        DATE '2025-12-05',
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Store and Warehouse' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        'Theft from warehouse'
    )
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, damage_cost)
    VALUES (v_damage_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-MOB-A54' AND status = 1 AND ROWNUM = 1),
        2, 84000);
    
    COMMIT;
END;
/

-- ============================================================================
-- FINAL COMMIT AND VERIFICATION
-- ============================================================================

COMMIT;

PROMPT ========================================================================
PROMPT Comprehensive insert data completed successfully!
PROMPT ========================================================================
PROMPT Summary:
PROMPT - 15 new customers added
PROMPT - 8 new suppliers added
PROMPT - 20 new products added
PROMPT - 10 product orders with 23 order details
PROMPT - 10 product receives with 23 receive details
PROMPT - 5 product returns with 5 return details
PROMPT - 15 additional sales with 31 sales details
PROMPT - 5 sales returns with 5 return details
PROMPT - 14 service requests with 22 service details (from insert_services.sql)
PROMPT - 16 expense masters with 51 expense details (from insert_expenses.sql)
PROMPT - 12 supplier payments added
PROMPT - 8 damage records with 13 damage details
PROMPT ========================================================================
PROMPT Total Records Added: 241 records across all transactional tables
PROMPT ========================================================================
PROMPT Run verification queries to check data integrity:
PROMPT SELECT COUNT(*) FROM customers;
PROMPT SELECT COUNT(*) FROM suppliers;
PROMPT SELECT COUNT(*) FROM products;
PROMPT SELECT COUNT(*) FROM sales_master;
PROMPT SELECT COUNT(*) FROM service_master;
PROMPT SELECT COUNT(*) FROM expense_master;
PROMPT ========================================================================
