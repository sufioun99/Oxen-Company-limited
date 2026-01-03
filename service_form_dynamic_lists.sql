--------------------------------------------------------------------------------
-- OXEN COMPANY LIMITED - SERVICE FORMS DYNAMIC LIST CREATION
-- Oracle Forms 11g - WHEN-NEW-FORM-INSTANCE Trigger
-- Purpose: Dynamically populate LOVs for Service Master and Service Details forms
-- Tables: service_master, service_details, customers, products, parts, service_list, employees
-- Date: 2026-01-03
--------------------------------------------------------------------------------

/*
================================================================================
INSTRUCTIONS FOR ORACLE FORMS DEVELOPER:
================================================================================
1. Open your Service Form in Oracle Forms Builder
2. Navigate to: Form Level > Triggers > WHEN-NEW-FORM-INSTANCE
3. Copy the ENTIRE code below into the trigger editor
4. Modify block/item names to match your form design (e.g., SERVICE_MASTER.CUSTOMER_ID)
5. Save and compile the form
6. Test by running the form - all lists should auto-populate

REQUIRED LIST ITEMS IN YOUR FORM:
==================================
Master Block (SERVICE_MASTER):
  - CUSTOMER_ID         (List Item - shows customer name with phone)
  - SERVICELIST_ID      (List Item - shows service name with cost)
  - SERVICE_BY          (List Item - shows technician name)
  - INVOICE_ID          (List Item - shows invoice ID with date)

Detail Block (SERVICE_DETAILS):
  - PRODUCT_ID          (List Item - shows product name with code)
  - PARTS_ID            (List Item - shows parts name with price)

ALTERNATIVE: Use LOV (Popup List) instead of List Items for better UX
================================================================================
*/

DECLARE
   -- Record Group variables
   rg_customers         RecordGroup;
   rg_services          RecordGroup;
   rg_technicians       RecordGroup;
   rg_invoices          RecordGroup;
   rg_products          RecordGroup;
   rg_parts             RecordGroup;
   rg_customer_invoices RecordGroup;
   rg_warranty_products RecordGroup;
   
   -- Error handling
   nDummy               NUMBER;
   v_error_msg          VARCHAR2(500);
   
BEGIN
   /*
   ============================================================================
   SECTION 1: CUSTOMER LIST (For SERVICE_MASTER.CUSTOMER_ID)
   Display: Customer Name - Phone Number
   Return: customer_id
   ============================================================================
   */
   BEGIN
      rg_customers := Find_Group('RG_SERVICE_CUSTOMERS');
      IF NOT Id_Null(rg_customers) THEN
         Delete_Group(rg_customers);
      END IF;

      rg_customers := Create_Group_From_Query(
                         'RG_SERVICE_CUSTOMERS',
                         'SELECT customer_name || '' - '' || NVL(phone_no, ''N/A'') AS customer_display, 
                                 customer_id
                            FROM customers
                            WHERE status = 1
                            ORDER BY customer_name'
                      );

      nDummy := Populate_Group(rg_customers);
      
      -- Populate Customer LOV in Master block
      IF NOT ID_NULL(Find_Item('SERVICE_MASTER.CUSTOMER_ID')) THEN
         Clear_List('SERVICE_MASTER.CUSTOMER_ID');
         Populate_List('SERVICE_MASTER.CUSTOMER_ID', rg_customers);
      END IF;
      
   EXCEPTION
      WHEN OTHERS THEN
         v_error_msg := 'Error creating Customer list: ' || SQLERRM;
         Message(v_error_msg);
         RAISE Form_Trigger_Failure;
   END;

   /*
   ============================================================================
   SECTION 2: SERVICE LIST (For SERVICE_MASTER.SERVICELIST_ID)
   Display: Service Name (Service Cost)
   Return: servicelist_id
   ============================================================================
   */
   BEGIN
      rg_services := Find_Group('RG_SERVICE_TYPES');
      IF NOT Id_Null(rg_services) THEN
         Delete_Group(rg_services);
      END IF;

      rg_services := Create_Group_From_Query(
                        'RG_SERVICE_TYPES',
                        'SELECT service_name || '' (BDT '' || TO_CHAR(service_cost) || '')'' AS service_display,
                                servicelist_id
                           FROM service_list
                           WHERE status = 1
                           ORDER BY service_name'
                     );

      nDummy := Populate_Group(rg_services);
      
      IF NOT ID_NULL(Find_Item('SERVICE_MASTER.SERVICELIST_ID')) THEN
         Clear_List('SERVICE_MASTER.SERVICELIST_ID');
         Populate_List('SERVICE_MASTER.SERVICELIST_ID', rg_services);
      END IF;
      
   EXCEPTION
      WHEN OTHERS THEN
         v_error_msg := 'Error creating Service Type list: ' || SQLERRM;
         Message(v_error_msg);
         RAISE Form_Trigger_Failure;
   END;

   /*
   ============================================================================
   SECTION 3: TECHNICIAN/SERVICE_BY LIST (For SERVICE_MASTER.SERVICE_BY)
   Display: Employee Full Name (Technicians only)
   Return: employee_id
   ============================================================================
   */
   BEGIN
      rg_technicians := Find_Group('RG_TECHNICIANS');
      IF NOT Id_Null(rg_technicians) THEN
         Delete_Group(rg_technicians);
      END IF;

      rg_technicians := Create_Group_From_Query(
                           'RG_TECHNICIANS',
                           'SELECT e.first_name || '' '' || e.last_name AS tech_name,
                                   e.employee_id
                              FROM employees e
                              JOIN jobs j ON e.job_id = j.job_id
                              WHERE e.status = 1
                              AND j.job_code IN (''TECH'', ''CSUP'', ''MGR'')
                              ORDER BY e.first_name, e.last_name'
                        );

      nDummy := Populate_Group(rg_technicians);
      
      IF NOT ID_NULL(Find_Item('SERVICE_MASTER.SERVICE_BY')) THEN
         Clear_List('SERVICE_MASTER.SERVICE_BY');
         Populate_List('SERVICE_MASTER.SERVICE_BY', rg_technicians);
      END IF;
      
   EXCEPTION
      WHEN OTHERS THEN
         v_error_msg := 'Error creating Technician list: ' || SQLERRM;
         Message(v_error_msg);
         RAISE Form_Trigger_Failure;
   END;

   /*
   ============================================================================
   SECTION 4: INVOICE LIST (For SERVICE_MASTER.INVOICE_ID)
   Display: Invoice ID - Date (Grand Total)
   Return: invoice_id
   Note: Shows all invoices initially, use cascading for customer filter
   ============================================================================
   */
   BEGIN
      rg_invoices := Find_Group('RG_SERVICE_INVOICES');
      IF NOT Id_Null(rg_invoices) THEN
         Delete_Group(rg_invoices);
      END IF;

      rg_invoices := Create_Group_From_Query(
                        'RG_SERVICE_INVOICES',
                        'SELECT invoice_id || '' - '' || TO_CHAR(invoice_date, ''DD-MON-YYYY'') || 
                                '' (BDT '' || TO_CHAR(grand_total) || '')'' AS invoice_display,
                                invoice_id
                           FROM sales_master
                           WHERE status IN (1, 3)
                           ORDER BY invoice_date DESC'
                     );

      nDummy := Populate_Group(rg_invoices);
      
      IF NOT ID_NULL(Find_Item('SERVICE_MASTER.INVOICE_ID')) THEN
         Clear_List('SERVICE_MASTER.INVOICE_ID');
         Populate_List('SERVICE_MASTER.INVOICE_ID', rg_invoices);
      END IF;
      
   EXCEPTION
      WHEN OTHERS THEN
         v_error_msg := 'Error creating Invoice list: ' || SQLERRM;
         Message(v_error_msg);
         RAISE Form_Trigger_Failure;
   END;

   /*
   ============================================================================
   SECTION 5: PRODUCT LIST (For SERVICE_DETAILS.PRODUCT_ID)
   Display: Product Name (Product Code)
   Return: product_id
   ============================================================================
   */
   BEGIN
      rg_products := Find_Group('RG_SERVICE_PRODUCTS');
      IF NOT Id_Null(rg_products) THEN
         Delete_Group(rg_products);
      END IF;

      rg_products := Create_Group_From_Query(
                        'RG_SERVICE_PRODUCTS',
                        'SELECT product_name || '' ('' || product_code || '')'' AS product_display,
                                product_id
                           FROM products
                           WHERE status = 1
                           ORDER BY product_name'
                     );

      nDummy := Populate_Group(rg_products);
      
      IF NOT ID_NULL(Find_Item('SERVICE_DETAILS.PRODUCT_ID')) THEN
         Clear_List('SERVICE_DETAILS.PRODUCT_ID');
         Populate_List('SERVICE_DETAILS.PRODUCT_ID', rg_products);
      END IF;
      
   EXCEPTION
      WHEN OTHERS THEN
         v_error_msg := 'Error creating Product list: ' || SQLERRM;
         Message(v_error_msg);
         RAISE Form_Trigger_Failure;
   END;

   /*
   ============================================================================
   SECTION 6: PARTS/SPARE PARTS LIST (For SERVICE_DETAILS.PARTS_ID)
   Display: Parts Name (MRP)
   Return: parts_id
   ============================================================================
   */
   BEGIN
      rg_parts := Find_Group('RG_SERVICE_PARTS');
      IF NOT Id_Null(rg_parts) THEN
         Delete_Group(rg_parts);
      END IF;

      rg_parts := Create_Group_From_Query(
                     'RG_SERVICE_PARTS',
                     'SELECT parts_name || '' (BDT '' || TO_CHAR(mrp) || '')'' AS parts_display,
                             parts_id
                        FROM parts
                        WHERE status = 1
                        ORDER BY parts_name'
                  );

      nDummy := Populate_Group(rg_parts);
      
      IF NOT ID_NULL(Find_Item('SERVICE_DETAILS.PARTS_ID')) THEN
         Clear_List('SERVICE_DETAILS.PARTS_ID');
         Populate_List('SERVICE_DETAILS.PARTS_ID', rg_parts);
      END IF;
      
   EXCEPTION
      WHEN OTHERS THEN
         v_error_msg := 'Error creating Parts list: ' || SQLERRM;
         Message(v_error_msg);
         RAISE Form_Trigger_Failure;
   END;

   /*
   ============================================================================
   SUCCESS MESSAGE
   ============================================================================
   */
   Message('Service form lists populated successfully.');
   
EXCEPTION
   WHEN OTHERS THEN
      Message('Critical error initializing form lists: ' || SQLERRM);
      RAISE Form_Trigger_Failure;
END;


--------------------------------------------------------------------------------
-- SECTION 2: CASCADING LIST TRIGGERS
-- Use these triggers for dynamic filtering based on parent values
--------------------------------------------------------------------------------

/*
================================================================================
TRIGGER: WHEN-LIST-CHANGED on SERVICE_MASTER.CUSTOMER_ID
Purpose: Filter invoice list to show only invoices for selected customer
================================================================================
*/
-- Copy into: SERVICE_MASTER.CUSTOMER_ID > WHEN-LIST-CHANGED trigger

DECLARE
   rg_customer_invoices RecordGroup;
   v_customer_id        VARCHAR2(50);
   nDummy               NUMBER;
BEGIN
   v_customer_id := :SERVICE_MASTER.CUSTOMER_ID;
   
   IF v_customer_id IS NOT NULL THEN
      -- Recreate invoice record group filtered by customer
      rg_customer_invoices := Find_Group('RG_CUSTOMER_INVOICES');
      IF NOT Id_Null(rg_customer_invoices) THEN
         Delete_Group(rg_customer_invoices);
      END IF;

      rg_customer_invoices := Create_Group_From_Query(
                                 'RG_CUSTOMER_INVOICES',
                                 'SELECT invoice_id || '' - '' || TO_CHAR(invoice_date, ''DD-MON-YYYY'') AS invoice_display,
                                         invoice_id
                                    FROM sales_master
                                    WHERE status IN (1, 3)
                                    AND customer_id = ''' || v_customer_id || '''
                                    ORDER BY invoice_date DESC'
                              );

      nDummy := Populate_Group(rg_customer_invoices);
      
      IF NOT ID_NULL(Find_Item('SERVICE_MASTER.INVOICE_ID')) THEN
         Clear_List('SERVICE_MASTER.INVOICE_ID');
         Populate_List('SERVICE_MASTER.INVOICE_ID', rg_customer_invoices);
      END IF;
      
      Message('Invoice list filtered for selected customer');
   END IF;
   
EXCEPTION
   WHEN OTHERS THEN
      Message('Error filtering invoices: ' || SQLERRM);
END;


/*
================================================================================
TRIGGER: WHEN-VALIDATE-ITEM on SERVICE_MASTER.INVOICE_ID
Purpose: Auto-populate warranty_applicable based on invoice date and product warranty
================================================================================
*/
-- Copy into: SERVICE_MASTER.INVOICE_ID > WHEN-VALIDATE-ITEM trigger

DECLARE
   v_invoice_id        VARCHAR2(50);
   v_invoice_date      DATE;
   v_warranty          NUMBER;
   v_warranty_end_date DATE;
   v_today             DATE := SYSDATE;
BEGIN
   v_invoice_id := :SERVICE_MASTER.INVOICE_ID;
   
   IF v_invoice_id IS NOT NULL THEN
      BEGIN
         -- Get invoice date and product warranty
         SELECT m.invoice_date, p.warranty
         INTO v_invoice_date, v_warranty
         FROM sales_master m
         JOIN sales_detail d ON m.invoice_id = d.invoice_id
         JOIN products p ON d.product_id = p.product_id
         WHERE m.invoice_id = v_invoice_id
         AND ROWNUM = 1;
         
         -- Calculate warranty end date (warranty months * 30 days)
         v_warranty_end_date := v_invoice_date + (v_warranty * 30);
         
         -- Set warranty_applicable flag
         IF v_warranty_end_date >= v_today THEN
            :SERVICE_MASTER.WARRANTY_APPLICABLE := 'Y';
            Message('Product is within warranty period');
         ELSE
            :SERVICE_MASTER.WARRANTY_APPLICABLE := 'N';
            Message('WARNING: Product warranty has expired!');
         END IF;
         
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            Message('No product found for this invoice');
            :SERVICE_MASTER.WARRANTY_APPLICABLE := 'N';
         WHEN TOO_MANY_ROWS THEN
            -- Multiple products in invoice, use first one
            Message('Multiple products found - using first product warranty');
      END;
   END IF;
   
EXCEPTION
   WHEN OTHERS THEN
      Message('Error checking warranty: ' || SQLERRM);
END;


/*
================================================================================
TRIGGER: POST-QUERY on SERVICE_MASTER (Block Level)
Purpose: Display customer name, service name, and technician name instead of IDs
================================================================================
*/
-- Copy into: SERVICE_MASTER block > POST-QUERY trigger

DECLARE
   v_customer_name  VARCHAR2(200);
   v_service_name   VARCHAR2(200);
   v_tech_name      VARCHAR2(200);
BEGIN
   -- Get customer name
   IF :SERVICE_MASTER.CUSTOMER_ID IS NOT NULL THEN
      BEGIN
         SELECT customer_name || ' - ' || phone_no
         INTO v_customer_name
         FROM customers
         WHERE customer_id = :SERVICE_MASTER.CUSTOMER_ID;
         
         -- Store in non-database display item (create item: CUSTOMER_NAME_DISPLAY)
         :SERVICE_MASTER.CUSTOMER_NAME_DISPLAY := v_customer_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            :SERVICE_MASTER.CUSTOMER_NAME_DISPLAY := 'Unknown Customer';
      END;
   END IF;
   
   -- Get service name
   IF :SERVICE_MASTER.SERVICELIST_ID IS NOT NULL THEN
      BEGIN
         SELECT service_name
         INTO v_service_name
         FROM service_list
         WHERE servicelist_id = :SERVICE_MASTER.SERVICELIST_ID;
         
         :SERVICE_MASTER.SERVICE_NAME_DISPLAY := v_service_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            :SERVICE_MASTER.SERVICE_NAME_DISPLAY := 'Unknown Service';
      END;
   END IF;
   
   -- Get technician name
   IF :SERVICE_MASTER.SERVICE_BY IS NOT NULL THEN
      BEGIN
         SELECT first_name || ' ' || last_name
         INTO v_tech_name
         FROM employees
         WHERE employee_id = :SERVICE_MASTER.SERVICE_BY;
         
         :SERVICE_MASTER.TECHNICIAN_NAME_DISPLAY := v_tech_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            :SERVICE_MASTER.TECHNICIAN_NAME_DISPLAY := 'Unknown Tech';
      END;
   END IF;
   
EXCEPTION
   WHEN OTHERS THEN
      Message('Error loading display names: ' || SQLERRM);
END;


/*
================================================================================
TRIGGER: POST-QUERY on SERVICE_DETAILS (Block Level)
Purpose: Display product name and parts name instead of IDs
================================================================================
*/
-- Copy into: SERVICE_DETAILS block > POST-QUERY trigger

DECLARE
   v_product_name  VARCHAR2(200);
   v_parts_name    VARCHAR2(200);
BEGIN
   -- Get product name
   IF :SERVICE_DETAILS.PRODUCT_ID IS NOT NULL THEN
      BEGIN
         SELECT product_name || ' (' || product_code || ')'
         INTO v_product_name
         FROM products
         WHERE product_id = :SERVICE_DETAILS.PRODUCT_ID;
         
         :SERVICE_DETAILS.PRODUCT_NAME_DISPLAY := v_product_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            :SERVICE_DETAILS.PRODUCT_NAME_DISPLAY := 'Unknown Product';
      END;
   END IF;
   
   -- Get parts name
   IF :SERVICE_DETAILS.PARTS_ID IS NOT NULL THEN
      BEGIN
         SELECT parts_name
         INTO v_parts_name
         FROM parts
         WHERE parts_id = :SERVICE_DETAILS.PARTS_ID;
         
         :SERVICE_DETAILS.PARTS_NAME_DISPLAY := v_parts_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            :SERVICE_DETAILS.PARTS_NAME_DISPLAY := 'Unknown Part';
      END;
   END IF;
   
EXCEPTION
   WHEN OTHERS THEN
      Message('Error loading product/parts names: ' || SQLERRM);
END;


--------------------------------------------------------------------------------
-- SECTION 3: VALIDATION TRIGGERS
--------------------------------------------------------------------------------

/*
================================================================================
TRIGGER: WHEN-VALIDATE-ITEM on SERVICE_DETAILS.PARTS_ID
Purpose: Auto-populate parts_price from parts table
================================================================================
*/
-- Copy into: SERVICE_DETAILS.PARTS_ID > WHEN-VALIDATE-ITEM trigger

DECLARE
   v_parts_id    VARCHAR2(50);
   v_mrp         NUMBER;
BEGIN
   v_parts_id := :SERVICE_DETAILS.PARTS_ID;
   
   IF v_parts_id IS NOT NULL THEN
      BEGIN
         SELECT mrp
         INTO v_mrp
         FROM parts
         WHERE parts_id = v_parts_id;
         
         :SERVICE_DETAILS.PARTS_PRICE := v_mrp;
         
         -- Calculate line total
         :SERVICE_DETAILS.LINE_TOTAL := NVL(:SERVICE_DETAILS.QUANTITY, 1) * v_mrp;
         
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            Message('Parts not found in database');
            RAISE Form_Trigger_Failure;
      END;
   END IF;
   
EXCEPTION
   WHEN OTHERS THEN
      Message('Error fetching parts price: ' || SQLERRM);
      RAISE Form_Trigger_Failure;
END;


/*
================================================================================
TRIGGER: WHEN-VALIDATE-ITEM on SERVICE_DETAILS.QUANTITY
Purpose: Recalculate line_total when quantity changes
================================================================================
*/
-- Copy into: SERVICE_DETAILS.QUANTITY > WHEN-VALIDATE-ITEM trigger

BEGIN
   :SERVICE_DETAILS.LINE_TOTAL := NVL(:SERVICE_DETAILS.QUANTITY, 1) * 
                                   NVL(:SERVICE_DETAILS.PARTS_PRICE, 0);
END;


--------------------------------------------------------------------------------
-- END OF SERVICE FORMS DYNAMIC LIST CREATION SCRIPT
--------------------------------------------------------------------------------

/*
================================================================================
DEPLOYMENT CHECKLIST:
================================================================================
[ ] Create all list items in Oracle Forms with proper data types
[ ] Add display items: CUSTOMER_NAME_DISPLAY, SERVICE_NAME_DISPLAY, 
    TECHNICIAN_NAME_DISPLAY, PRODUCT_NAME_DISPLAY, PARTS_NAME_DISPLAY
[ ] Set list item properties: List Style = Popup List (recommended)
[ ] Copy WHEN-NEW-FORM-INSTANCE trigger code
[ ] Copy cascading triggers for CUSTOMER_ID and INVOICE_ID
[ ] Copy POST-QUERY triggers for name display
[ ] Copy validation triggers for price population
[ ] Compile and test form
[ ] Verify warranty calculation works correctly

TESTING STEPS:
==============
1. Open form - verify all lists populate automatically
2. Select customer - verify invoice list filters to that customer
3. Select invoice - verify warranty status auto-calculates
4. Query existing records - verify names display instead of IDs
5. Enter new service - verify parts price auto-populates
6. Change quantity - verify line_total recalculates

For support contact: Database Administrator
================================================================================
*/
