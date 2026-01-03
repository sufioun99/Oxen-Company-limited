--------------------------------------------------------------------------------
-- OXEN COMPANY LIMITED - ORACLE 11g FORMS LOV AND TRIGGERS
-- Compatible with: Oracle Forms 11g
-- Purpose: Ready-to-use LOV queries and form triggers for Oracle Forms
-- Date: 2026-01-02
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- SECTION 1: LOV QUERIES FOR ORACLE FORMS
-- Copy these queries into your Oracle Forms LOV (List of Values) objects
--------------------------------------------------------------------------------

/*
================================================================================
LOV: COMPANY_LOV
Description: Select active companies
Columns: COMPANY_NAME (Display), COMPANY_ID (Return)
================================================================================
*/
-- Query:
SELECT company_name, company_id
FROM company
WHERE status = 1
ORDER BY company_name;

/*
================================================================================
LOV: JOBS_LOV
Description: Select active job positions
Columns: JOB_DISPLAY (Display), JOB_ID (Return)
================================================================================
*/
-- Query:
SELECT job_title || ' (' || job_grade || ')' AS job_display, job_id
FROM jobs
WHERE status = 1
ORDER BY job_title;

/*
================================================================================
LOV: CUSTOMERS_LOV
Description: Select active customers with phone
Columns: CUSTOMER_DISPLAY (Display), CUSTOMER_ID (Return)
================================================================================
*/
-- Query:
SELECT customer_name || ' - ' || NVL(phone_no, 'N/A') AS customer_display, customer_id
FROM customers
WHERE status = 1
ORDER BY customer_name;

/*
================================================================================
LOV: SUPPLIERS_LOV
Description: Select active suppliers
Columns: SUPPLIER_NAME (Display), SUPPLIER_ID (Return)
================================================================================
*/
-- Query:
SELECT supplier_name, supplier_id
FROM suppliers
WHERE status = 1
ORDER BY supplier_name;

/*
================================================================================
LOV: PRODUCTS_LOV
Description: Select active products with code
Columns: PRODUCT_DISPLAY (Display), PRODUCT_ID (Return), MRP, PURCHASE_PRICE
================================================================================
*/
-- Query:
SELECT product_name || ' (' || product_code || ')' AS product_display, 
       product_id, mrp, purchase_price
FROM products
WHERE status = 1
ORDER BY product_name;

/*
================================================================================
LOV: PRODUCTS_BY_CATEGORY_LOV
Description: Select products filtered by category (cascading LOV)
Use :BLOCK.CATEGORY_ID as parameter
================================================================================
*/
-- Query:
SELECT product_name || ' (' || product_code || ')' AS product_display, 
       product_id, mrp, purchase_price
FROM products
WHERE status = 1
AND category_id = :BLOCK.CATEGORY_ID
ORDER BY product_name;

/*
================================================================================
LOV: PRODUCT_CATEGORIES_LOV
Description: Select product categories
Columns: CATEGORY_NAME (Display), CATEGORY_ID (Return)
================================================================================
*/
-- Query:
SELECT product_cat_name, product_cat_id
FROM product_categories
WHERE status = 1
ORDER BY product_cat_name;

/*
================================================================================
LOV: SUB_CATEGORIES_LOV
Description: Select sub-categories (cascading from category)
Use :BLOCK.CATEGORY_ID as parameter for cascading
================================================================================
*/
-- Query (Standalone):
SELECT sub_cat_name, sub_cat_id, product_cat_id
FROM sub_categories
WHERE status = 1
ORDER BY sub_cat_name;

-- Query (Cascading):
SELECT sub_cat_name, sub_cat_id
FROM sub_categories
WHERE status = 1
AND product_cat_id = :BLOCK.CATEGORY_ID
ORDER BY sub_cat_name;

/*
================================================================================
LOV: BRANDS_LOV
Description: Select brands with model
Columns: BRAND_DISPLAY (Display), BRAND_ID (Return)
================================================================================
*/
-- Query:
SELECT brand_name || ' - ' || model_name AS brand_display, brand_id
FROM brand
WHERE status = 1
ORDER BY brand_name, model_name;

/*
================================================================================
LOV: EMPLOYEES_LOV
Description: Select active employees
Columns: EMPLOYEE_NAME (Display), EMPLOYEE_ID (Return)
================================================================================
*/
-- Query:
SELECT first_name || ' ' || last_name AS employee_name, employee_id
FROM employees
WHERE status = 1
ORDER BY last_name, first_name;

/*
================================================================================
LOV: SALES_EMPLOYEES_LOV
Description: Select sales staff only
================================================================================
*/
-- Query:
SELECT e.first_name || ' ' || e.last_name AS employee_name, e.employee_id
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
WHERE e.status = 1
AND j.job_code IN ('SALES', 'MGR', 'ASM')
ORDER BY e.last_name, e.first_name;

/*
================================================================================
LOV: TECHNICIANS_LOV
Description: Select technician employees for service forms
================================================================================
*/
-- Query:
SELECT e.first_name || ' ' || e.last_name AS employee_name, e.employee_id
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
WHERE e.status = 1
AND j.job_code IN ('TECH', 'CSUP')
ORDER BY e.last_name, e.first_name;

/*
================================================================================
LOV: DEPARTMENTS_LOV
Description: Select departments (optionally by company)
================================================================================
*/
-- Query (All):
SELECT department_name, department_id, company_id
FROM departments
WHERE status = 1
ORDER BY department_name;

-- Query (By Company - Cascading):
SELECT department_name, department_id
FROM departments
WHERE status = 1
AND company_id = :BLOCK.COMPANY_ID
ORDER BY department_name;

/*
================================================================================
LOV: SERVICES_LOV
Description: Select service types with cost
================================================================================
*/
-- Query:
SELECT service_name || ' (BDT ' || TO_CHAR(service_cost) || ')' AS service_display,
       servicelist_id, service_cost
FROM service_list
WHERE status = 1
ORDER BY service_name;

/*
================================================================================
LOV: EXPENSE_TYPES_LOV
Description: Select expense types with default amount
================================================================================
*/
-- Query:
SELECT type_name || ' (' || expense_code || ')' AS expense_display,
       expense_type_id, default_amount
FROM expense_list
WHERE status = 1
ORDER BY type_name;

/*
================================================================================
LOV: PARTS_LOV
Description: Select spare parts
================================================================================
*/
-- Query:
SELECT parts_name || ' (BDT ' || TO_CHAR(mrp) || ')' AS parts_display,
       parts_id, mrp, purchase_price, parts_cat_id
FROM parts
WHERE status = 1
ORDER BY parts_name;

/*
================================================================================
LOV: PARTS_BY_CATEGORY_LOV
Description: Select parts filtered by category (cascading)
================================================================================
*/
-- Query:
SELECT parts_name || ' (BDT ' || TO_CHAR(mrp) || ')' AS parts_display,
       parts_id, mrp, purchase_price
FROM parts
WHERE status = 1
AND parts_cat_id = :BLOCK.PARTS_CAT_ID
ORDER BY parts_name;

/*
================================================================================
LOV: INVOICES_LOV
Description: Select sales invoices for reference
================================================================================
*/
-- Query:
SELECT invoice_id || ' - ' || TO_CHAR(invoice_date, 'DD-MON-YYYY') || 
       ' (BDT ' || TO_CHAR(grand_total) || ')' AS invoice_display,
       invoice_id, customer_id
FROM sales_master
WHERE status IN (1, 3)
ORDER BY invoice_date DESC;

/*
================================================================================
LOV: CUSTOMER_INVOICES_LOV
Description: Select invoices for specific customer (cascading)
================================================================================
*/
-- Query:
SELECT invoice_id || ' - ' || TO_CHAR(invoice_date, 'DD-MON-YYYY') AS invoice_display,
       invoice_id, grand_total
FROM sales_master
WHERE status IN (1, 3)
AND customer_id = :BLOCK.CUSTOMER_ID
ORDER BY invoice_date DESC;

/*
================================================================================
LOV: ORDERS_LOV
Description: Select purchase orders
================================================================================
*/
-- Query:
SELECT order_id || ' - ' || s.supplier_name || ' (' || TO_CHAR(pom.order_date, 'DD-MON-YYYY') || ')' AS order_display,
       pom.order_id, pom.supplier_id
FROM product_order_master pom
JOIN suppliers s ON pom.supplier_id = s.supplier_id
WHERE pom.status = 1
ORDER BY pom.order_date DESC;

/*
================================================================================
LOV: RECEIVE_MASTERS_LOV
Description: Select product receives for return reference
================================================================================
*/
-- Query:
SELECT prm.receive_id || ' - ' || s.supplier_name || ' (' || prm.sup_invoice_id || ')' AS receive_display,
       prm.receive_id, prm.supplier_id
FROM product_receive_master prm
JOIN suppliers s ON prm.supplier_id = s.supplier_id
WHERE prm.status IN (1, 3)
ORDER BY prm.receive_date DESC;


--------------------------------------------------------------------------------
-- SECTION 2: FORM-LEVEL TRIGGERS FOR ORACLE FORMS
-- Copy these PL/SQL blocks into your Oracle Forms triggers
--------------------------------------------------------------------------------

/*
================================================================================
TRIGGER: WHEN-NEW-FORM-INSTANCE (Form Level)
Description: Initialize all record groups and populate LOVs when form opens
================================================================================
*/
-- Copy this into WHEN-NEW-FORM-INSTANCE trigger:

DECLARE
   rg_products      RecordGroup;
   rg_suppliers     RecordGroup;
   rg_employees     RecordGroup;
   rg_customers     RecordGroup;
   rg_categories    RecordGroup;
   rg_brands        RecordGroup;
   rg_services      RecordGroup;
   rg_parts         RecordGroup;
   nDummy           NUMBER;
BEGIN
   /* ================= PRODUCTS ================= */
   rg_products := Find_Group('RG_PRODUCTS');
   IF NOT Id_Null(rg_products) THEN
      Delete_Group(rg_products);
   END IF;

   rg_products := Create_Group_From_Query(
                     'RG_PRODUCTS',
                     'SELECT product_name || '' ('' || product_code || '')'' AS display_val, 
                             TO_CHAR(product_id) AS return_val
                        FROM products
                        WHERE status = 1
                        ORDER BY product_name'
                  );

   nDummy := Populate_Group(rg_products);
   
   -- Populate all product LOV items in the form
   -- Modify block.item names as per your form design
   IF Find_Item('SALES_DETAIL.PRODUCT_ID') IS NOT NULL THEN
      Clear_List('SALES_DETAIL.PRODUCT_ID');
      Populate_List('SALES_DETAIL.PRODUCT_ID', rg_products);
   END IF;
   
   IF Find_Item('PRODUCT_RECEIVE_DETAILS.PRODUCT_ID') IS NOT NULL THEN
      Clear_List('PRODUCT_RECEIVE_DETAILS.PRODUCT_ID');
      Populate_List('PRODUCT_RECEIVE_DETAILS.PRODUCT_ID', rg_products);
   END IF;

   /* ================= SUPPLIERS ================= */
   rg_suppliers := Find_Group('RG_SUPPLIERS');
   IF NOT Id_Null(rg_suppliers) THEN
      Delete_Group(rg_suppliers);
   END IF;

   rg_suppliers := Create_Group_From_Query(
                      'RG_SUPPLIERS',
                      'SELECT supplier_name, TO_CHAR(supplier_id)
                         FROM suppliers
                         WHERE status = 1
                         ORDER BY supplier_name'
                   );

   nDummy := Populate_Group(rg_suppliers);
   
   IF Find_Item('PRODUCT_ORDER_MASTER.SUPPLIER_ID') IS NOT NULL THEN
      Clear_List('PRODUCT_ORDER_MASTER.SUPPLIER_ID');
      Populate_List('PRODUCT_ORDER_MASTER.SUPPLIER_ID', rg_suppliers);
   END IF;
   
   IF Find_Item('PRODUCT_RECEIVE_MASTER.SUPPLIER_ID') IS NOT NULL THEN
      Clear_List('PRODUCT_RECEIVE_MASTER.SUPPLIER_ID');
      Populate_List('PRODUCT_RECEIVE_MASTER.SUPPLIER_ID', rg_suppliers);
   END IF;

   /* ================= EMPLOYEES ================= */
   rg_employees := Find_Group('RG_EMPLOYEES');
   IF NOT Id_Null(rg_employees) THEN
      Delete_Group(rg_employees);
   END IF;

   rg_employees := Create_Group_From_Query(
                      'RG_EMPLOYEES',
                      'SELECT first_name || '' '' || last_name AS emp_name, 
                              TO_CHAR(employee_id)
                         FROM employees
                         WHERE status = 1
                         ORDER BY last_name'
                   );

   nDummy := Populate_Group(rg_employees);
   
   IF Find_Item('SALES_MASTER.SALES_BY') IS NOT NULL THEN
      Clear_List('SALES_MASTER.SALES_BY');
      Populate_List('SALES_MASTER.SALES_BY', rg_employees);
   END IF;
   
   IF Find_Item('SERVICE_MASTER.SERVICE_BY') IS NOT NULL THEN
      Clear_List('SERVICE_MASTER.SERVICE_BY');
      Populate_List('SERVICE_MASTER.SERVICE_BY', rg_employees);
   END IF;
   
   IF Find_Item('PRODUCT_RECEIVE_MASTER.RECEIVED_BY') IS NOT NULL THEN
      Clear_List('PRODUCT_RECEIVE_MASTER.RECEIVED_BY');
      Populate_List('PRODUCT_RECEIVE_MASTER.RECEIVED_BY', rg_employees);
   END IF;

   /* ================= CUSTOMERS ================= */
   rg_customers := Find_Group('RG_CUSTOMERS');
   IF NOT Id_Null(rg_customers) THEN
      Delete_Group(rg_customers);
   END IF;

   rg_customers := Create_Group_From_Query(
                      'RG_CUSTOMERS',
                      'SELECT customer_name || '' - '' || NVL(phone_no, ''N/A''), 
                              TO_CHAR(customer_id)
                         FROM customers
                         WHERE status = 1
                         ORDER BY customer_name'
                   );

   nDummy := Populate_Group(rg_customers);
   
   IF Find_Item('SALES_MASTER.CUSTOMER_ID') IS NOT NULL THEN
      Clear_List('SALES_MASTER.CUSTOMER_ID');
      Populate_List('SALES_MASTER.CUSTOMER_ID', rg_customers);
   END IF;
   
   IF Find_Item('SERVICE_MASTER.CUSTOMER_ID') IS NOT NULL THEN
      Clear_List('SERVICE_MASTER.CUSTOMER_ID');
      Populate_List('SERVICE_MASTER.CUSTOMER_ID', rg_customers);
   END IF;

   /* ================= PRODUCT CATEGORIES ================= */
   rg_categories := Find_Group('RG_CATEGORIES');
   IF NOT Id_Null(rg_categories) THEN
      Delete_Group(rg_categories);
   END IF;

   rg_categories := Create_Group_From_Query(
                       'RG_CATEGORIES',
                       'SELECT product_cat_name, TO_CHAR(product_cat_id)
                          FROM product_categories
                          WHERE status = 1
                          ORDER BY product_cat_name'
                    );

   nDummy := Populate_Group(rg_categories);
   
   IF Find_Item('PRODUCTS.CATEGORY_ID') IS NOT NULL THEN
      Clear_List('PRODUCTS.CATEGORY_ID');
      Populate_List('PRODUCTS.CATEGORY_ID', rg_categories);
   END IF;

   /* ================= BRANDS ================= */
   rg_brands := Find_Group('RG_BRANDS');
   IF NOT Id_Null(rg_brands) THEN
      Delete_Group(rg_brands);
   END IF;

   rg_brands := Create_Group_From_Query(
                   'RG_BRANDS',
                   'SELECT brand_name || '' - '' || model_name, TO_CHAR(brand_id)
                      FROM brand
                      WHERE status = 1
                      ORDER BY brand_name'
                );

   nDummy := Populate_Group(rg_brands);
   
   IF Find_Item('PRODUCTS.BRAND_ID') IS NOT NULL THEN
      Clear_List('PRODUCTS.BRAND_ID');
      Populate_List('PRODUCTS.BRAND_ID', rg_brands);
   END IF;

   /* ================= SERVICES ================= */
   rg_services := Find_Group('RG_SERVICES');
   IF NOT Id_Null(rg_services) THEN
      Delete_Group(rg_services);
   END IF;

   rg_services := Create_Group_From_Query(
                     'RG_SERVICES',
                     'SELECT service_name || '' (BDT '' || TO_CHAR(service_cost) || '')'', 
                             TO_CHAR(servicelist_id)
                        FROM service_list
                        WHERE status = 1
                        ORDER BY service_name'
                  );

   nDummy := Populate_Group(rg_services);
   
   IF Find_Item('SERVICE_MASTER.SERVICELIST_ID') IS NOT NULL THEN
      Clear_List('SERVICE_MASTER.SERVICELIST_ID');
      Populate_List('SERVICE_MASTER.SERVICELIST_ID', rg_services);
   END IF;

   /* ================= PARTS ================= */
   rg_parts := Find_Group('RG_PARTS');
   IF NOT Id_Null(rg_parts) THEN
      Delete_Group(rg_parts);
   END IF;

   rg_parts := Create_Group_From_Query(
                  'RG_PARTS',
                  'SELECT parts_name || '' (BDT '' || TO_CHAR(mrp) || '')'', 
                          TO_CHAR(parts_id)
                     FROM parts
                     WHERE status = 1
                     ORDER BY parts_name'
               );

   nDummy := Populate_Group(rg_parts);
   
   IF Find_Item('SERVICE_DETAILS.PARTS_ID') IS NOT NULL THEN
      Clear_List('SERVICE_DETAILS.PARTS_ID');
      Populate_List('SERVICE_DETAILS.PARTS_ID', rg_parts);
   END IF;

END;


/*
================================================================================
TRIGGER: WHEN-LIST-CHANGED (On CATEGORY_ID Item)
Description: Cascade sub-categories when category changes
================================================================================
*/
-- Copy this into WHEN-LIST-CHANGED trigger on CATEGORY_ID item:

DECLARE
   rg_subcats   RecordGroup;
   nDummy       NUMBER;
   v_category   VARCHAR2(50);
BEGIN
   v_category := :BLOCK.CATEGORY_ID; -- Replace BLOCK with your block name
   
   rg_subcats := Find_Group('RG_SUBCATS');
   IF NOT Id_Null(rg_subcats) THEN
      Delete_Group(rg_subcats);
   END IF;

   IF v_category IS NOT NULL THEN
      rg_subcats := Create_Group_From_Query(
                       'RG_SUBCATS',
                       'SELECT sub_cat_name, TO_CHAR(sub_cat_id)
                          FROM sub_categories
                          WHERE status = 1
                          AND product_cat_id = ''' || v_category || '''
                          ORDER BY sub_cat_name'
                    );
   ELSE
      rg_subcats := Create_Group_From_Query(
                       'RG_SUBCATS',
                       'SELECT sub_cat_name, TO_CHAR(sub_cat_id)
                          FROM sub_categories
                          WHERE status = 1
                          ORDER BY sub_cat_name'
                    );
   END IF;

   nDummy := Populate_Group(rg_subcats);
   Clear_List('BLOCK.SUB_CAT_ID'); -- Replace BLOCK with your block name
   Populate_List('BLOCK.SUB_CAT_ID', rg_subcats);
   
   -- Clear current selection
   :BLOCK.SUB_CAT_ID := NULL;
END;


/*
================================================================================
TRIGGER: WHEN-VALIDATE-ITEM (On PRODUCT_ID in Sales Detail)
Description: Auto-populate price when product selected
================================================================================
*/
-- Copy this into WHEN-VALIDATE-ITEM trigger on PRODUCT_ID item:

DECLARE
   v_mrp            NUMBER;
   v_purchase_price NUMBER;
   v_product_name   VARCHAR2(150);
BEGIN
   IF :SALES_DETAIL.PRODUCT_ID IS NOT NULL THEN
      SELECT mrp, purchase_price, product_name
      INTO v_mrp, v_purchase_price, v_product_name
      FROM products
      WHERE product_id = :SALES_DETAIL.PRODUCT_ID;
      
      :SALES_DETAIL.MRP := v_mrp;
      :SALES_DETAIL.PURCHASE_PRICE := v_purchase_price;
      
      -- Optionally set default quantity
      IF :SALES_DETAIL.QUANTITY IS NULL THEN
         :SALES_DETAIL.QUANTITY := 1;
      END IF;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      Message('Product not found!');
      RAISE Form_Trigger_Failure;
END;


/*
================================================================================
TRIGGER: WHEN-VALIDATE-ITEM (On QUANTITY in Sales Detail)
Description: Check stock availability
================================================================================
*/
-- Copy this into WHEN-VALIDATE-ITEM trigger on QUANTITY item:

DECLARE
   v_stock_qty NUMBER;
BEGIN
   IF :SALES_DETAIL.PRODUCT_ID IS NOT NULL AND :SALES_DETAIL.QUANTITY IS NOT NULL THEN
      -- Get current stock
      BEGIN
         SELECT NVL(quantity, 0)
         INTO v_stock_qty
         FROM stock
         WHERE product_id = :SALES_DETAIL.PRODUCT_ID
         AND status = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_stock_qty := 0;
      END;
      
      IF v_stock_qty < :SALES_DETAIL.QUANTITY THEN
         Message('Warning: Requested quantity (' || :SALES_DETAIL.QUANTITY || 
                 ') exceeds available stock (' || v_stock_qty || ')');
         -- Optionally prevent the entry:
         -- RAISE Form_Trigger_Failure;
      END IF;
   END IF;
END;


/*
================================================================================
TRIGGER: POST-QUERY (On SALES_MASTER Block)
Description: Calculate and display sales totals
================================================================================
*/
-- Copy this into POST-QUERY trigger on SALES_MASTER block:

DECLARE
   v_total NUMBER;
BEGIN
   SELECT NVL(SUM((mrp * quantity) + NVL(vat, 0)), 0)
   INTO v_total
   FROM sales_detail
   WHERE invoice_id = :SALES_MASTER.INVOICE_ID;
   
   :SALES_MASTER.CALC_TOTAL := v_total;
   :SALES_MASTER.NET_TOTAL := v_total - NVL(:SALES_MASTER.DISCOUNT, 0);
EXCEPTION
   WHEN OTHERS THEN
      :SALES_MASTER.CALC_TOTAL := 0;
      :SALES_MASTER.NET_TOTAL := 0;
END;


/*
================================================================================
TRIGGER: WHEN-VALIDATE-ITEM (On SERVICE_LIST_ID in Service Master)
Description: Auto-populate service charge when service type selected
================================================================================
*/
-- Copy this into WHEN-VALIDATE-ITEM trigger on SERVICELIST_ID item:

DECLARE
   v_service_cost NUMBER;
   v_service_name VARCHAR2(150);
BEGIN
   IF :SERVICE_MASTER.SERVICELIST_ID IS NOT NULL THEN
      SELECT service_cost, service_name
      INTO v_service_cost, v_service_name
      FROM service_list
      WHERE servicelist_id = :SERVICE_MASTER.SERVICELIST_ID;
      
      :SERVICE_MASTER.SERVICE_CHARGE := v_service_cost;
      :SERVICE_MASTER.SERVICE_NAME_DISPLAY := v_service_name;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      :SERVICE_MASTER.SERVICE_CHARGE := 0;
END;


/*
================================================================================
TRIGGER: WHEN-VALIDATE-ITEM (On CUSTOMER_ID)
Description: Display customer details when selected
================================================================================
*/
-- Copy this into WHEN-VALIDATE-ITEM trigger on CUSTOMER_ID item:

DECLARE
   v_name    VARCHAR2(150);
   v_phone   VARCHAR2(50);
   v_address VARCHAR2(300);
   v_rewards NUMBER;
BEGIN
   IF :BLOCK.CUSTOMER_ID IS NOT NULL THEN -- Replace BLOCK with actual block name
      SELECT customer_name, phone_no, address, NVL(rewards, 0)
      INTO v_name, v_phone, v_address, v_rewards
      FROM customers
      WHERE customer_id = :BLOCK.CUSTOMER_ID;
      
      -- Display in non-database items (create these in your form)
      :BLOCK.CUSTOMER_NAME_DISPLAY := v_name;
      :BLOCK.CUSTOMER_PHONE_DISPLAY := v_phone;
      :BLOCK.CUSTOMER_ADDRESS_DISPLAY := v_address;
      :BLOCK.CUSTOMER_REWARDS_DISPLAY := v_rewards;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      Message('Customer not found!');
END;


/*
================================================================================
TRIGGER: WHEN-VALIDATE-ITEM (On SUPPLIER_ID)
Description: Display supplier details and due amount
================================================================================
*/
-- Copy this into WHEN-VALIDATE-ITEM trigger on SUPPLIER_ID item:

DECLARE
   v_name       VARCHAR2(150);
   v_phone      VARCHAR2(50);
   v_due_amount NUMBER;
BEGIN
   IF :BLOCK.SUPPLIER_ID IS NOT NULL THEN -- Replace BLOCK with actual block name
      SELECT supplier_name, phone_no, 
             NVL(purchase_total, 0) - NVL(pay_total, 0)
      INTO v_name, v_phone, v_due_amount
      FROM suppliers
      WHERE supplier_id = :BLOCK.SUPPLIER_ID;
      
      -- Display in non-database items
      :BLOCK.SUPPLIER_NAME_DISPLAY := v_name;
      :BLOCK.SUPPLIER_PHONE_DISPLAY := v_phone;
      :BLOCK.SUPPLIER_DUE_DISPLAY := v_due_amount;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      Message('Supplier not found!');
END;


/*
================================================================================
TRIGGER: PRE-INSERT (Form Level or Block Level)
Description: Auto-generate IDs before insert
Note: This is backup if database triggers don't fire
================================================================================
*/
-- Usually not needed as database triggers handle this, but can be used as backup:

DECLARE
   v_new_id VARCHAR2(50);
BEGIN
   -- For SALES_MASTER block
   IF :SYSTEM.TRIGGER_BLOCK = 'SALES_MASTER' THEN
      IF :SALES_MASTER.INVOICE_ID IS NULL THEN
         SELECT 'INV' || TO_CHAR(sales_seq.NEXTVAL)
         INTO v_new_id
         FROM DUAL;
         :SALES_MASTER.INVOICE_ID := v_new_id;
      END IF;
   END IF;
   
   -- Add similar logic for other blocks as needed
END;


/*
================================================================================
BUTTON TRIGGER: CALCULATE_TOTAL (On Calculate Button)
Description: Calculate and display invoice total
================================================================================
*/
-- Copy this into WHEN-BUTTON-PRESSED trigger on Calculate button:

DECLARE
   v_subtotal NUMBER := 0;
   v_discount NUMBER := 0;
   v_vat      NUMBER := 0;
   v_total    NUMBER := 0;
BEGIN
   -- Calculate subtotal from detail records
   Go_Block('SALES_DETAIL');
   First_Record;
   
   WHILE :SYSTEM.LAST_RECORD = 'FALSE' LOOP
      v_subtotal := v_subtotal + (NVL(:SALES_DETAIL.MRP, 0) * NVL(:SALES_DETAIL.QUANTITY, 0));
      v_vat := v_vat + NVL(:SALES_DETAIL.VAT, 0);
      Next_Record;
   END LOOP;
   -- Don't forget last record
   v_subtotal := v_subtotal + (NVL(:SALES_DETAIL.MRP, 0) * NVL(:SALES_DETAIL.QUANTITY, 0));
   v_vat := v_vat + NVL(:SALES_DETAIL.VAT, 0);
   
   Go_Block('SALES_MASTER');
   v_discount := NVL(:SALES_MASTER.DISCOUNT, 0);
   
   v_total := v_subtotal + v_vat - v_discount;
   
   :SALES_MASTER.GRAND_TOTAL := v_total;
   :SALES_MASTER.CALC_SUBTOTAL := v_subtotal;
   :SALES_MASTER.CALC_VAT := v_vat;
   
   Message('Total calculated: BDT ' || TO_CHAR(v_total));
END;


/*
================================================================================
BUTTON TRIGGER: FINALIZE_INVOICE (On Finalize/Save Button)
Description: Finalize invoice and update stock
================================================================================
*/
-- Copy this into WHEN-BUTTON-PRESSED trigger on Finalize button:

DECLARE
   v_result   VARCHAR2(4000);
   v_invoice  VARCHAR2(50);
BEGIN
   -- Commit pending changes first
   Commit_Form;
   
   v_invoice := :SALES_MASTER.INVOICE_ID;
   
   -- Call automation package to finalize
   pkg_oxen_automation.finalize_sales(v_invoice, v_result);
   
   IF v_result LIKE 'SUCCESS%' THEN
      Message(v_result);
      -- Refresh the form
      Execute_Query;
   ELSE
      Message(v_result);
      RAISE Form_Trigger_Failure;
   END IF;
END;


--------------------------------------------------------------------------------
-- SECTION 3: PROGRAM UNITS (Stored in Form)
-- These are reusable procedures/functions stored in the Forms module
--------------------------------------------------------------------------------

/*
================================================================================
PROGRAM UNIT: REFRESH_ALL_LOVS
Description: Procedure to refresh all LOVs (call after data changes)
================================================================================
*/
PROCEDURE REFRESH_ALL_LOVS IS
   rg_temp RecordGroup;
   nDummy  NUMBER;
BEGIN
   -- This procedure can be called to refresh LOVs after data changes
   -- Implementation would be similar to WHEN-NEW-FORM-INSTANCE
   
   -- Products
   rg_temp := Find_Group('RG_PRODUCTS');
   IF NOT Id_Null(rg_temp) THEN
      nDummy := Populate_Group(rg_temp);
   END IF;
   
   -- Customers
   rg_temp := Find_Group('RG_CUSTOMERS');
   IF NOT Id_Null(rg_temp) THEN
      nDummy := Populate_Group(rg_temp);
   END IF;
   
   -- Suppliers
   rg_temp := Find_Group('RG_SUPPLIERS');
   IF NOT Id_Null(rg_temp) THEN
      nDummy := Populate_Group(rg_temp);
   END IF;
   
   -- Employees
   rg_temp := Find_Group('RG_EMPLOYEES');
   IF NOT Id_Null(rg_temp) THEN
      nDummy := Populate_Group(rg_temp);
   END IF;
   
   Message('All LOVs refreshed successfully.');
END;


/*
================================================================================
PROGRAM UNIT: CHECK_STOCK_AVAILABILITY
Description: Function to check if product has sufficient stock
================================================================================
*/
FUNCTION CHECK_STOCK_AVAILABILITY(
   p_product_id IN VARCHAR2,
   p_quantity   IN NUMBER
) RETURN BOOLEAN IS
   v_stock NUMBER;
BEGIN
   SELECT NVL(quantity, 0)
   INTO v_stock
   FROM stock
   WHERE product_id = p_product_id
   AND status = 1;
   
   RETURN (v_stock >= p_quantity);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
   WHEN OTHERS THEN
      RETURN FALSE;
END;


/*
================================================================================
PROGRAM UNIT: FORMAT_CURRENCY
Description: Function to format number as currency
================================================================================
*/
FUNCTION FORMAT_CURRENCY(p_amount IN NUMBER) RETURN VARCHAR2 IS
BEGIN
   RETURN 'BDT ' || TO_CHAR(NVL(p_amount, 0), 'FM99,99,99,990.00');
END;


--------------------------------------------------------------------------------
-- END OF ORACLE FORMS LOV AND TRIGGERS
--------------------------------------------------------------------------------
