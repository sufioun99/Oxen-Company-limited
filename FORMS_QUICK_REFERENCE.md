# Oracle Forms 11g - Quick Reference Code Snippets
## Oxen Company Limited - Ready-to-Use Code Templates

---

## Table of Contents
1. [Form-Level Triggers](#form-level-triggers)
2. [Button Triggers](#button-triggers)
3. [Item-Level Triggers](#item-level-triggers)
4. [LOV Queries](#lov-queries)
5. [Navigation Code](#navigation-code)
6. [Validation Functions](#validation-functions)
7. [Common Utilities](#common-utilities)

---

## Form-Level Triggers

### ON-ERROR (Form Level)
```sql
DECLARE
    v_error_code NUMBER := ERROR_CODE;
    v_error_text VARCHAR2(200) := ERROR_TEXT;
    v_custom_msg VARCHAR2(500);
BEGIN
    IF v_error_code = 40508 THEN
        v_custom_msg := 'Unable to save. Check for duplicate entries or missing fields.';
    ELSIF v_error_code = 40509 THEN
        v_custom_msg := 'Unable to update. Record may have been modified by another user.';
    ELSIF v_error_code = 40510 THEN
        v_custom_msg := 'Cannot delete. This record is referenced by other data.';
    ELSIF v_error_code = 40505 THEN
        v_custom_msg := 'Unable to retrieve data. Check your search criteria.';
    ELSIF v_error_code = 40350 THEN
        v_custom_msg := 'No records found matching your criteria.';
    ELSIF v_error_text LIKE '%ORA-00001%' THEN
        v_custom_msg := 'This record already exists. Please enter unique values.';
    ELSIF v_error_text LIKE '%ORA-01400%' THEN
        v_custom_msg := 'Required field is missing. Please fill all mandatory fields.';
    ELSIF v_error_text LIKE '%ORA-02291%' THEN
        v_custom_msg := 'Invalid reference. Select a valid value from the list.';
    ELSIF v_error_text LIKE '%ORA-02292%' THEN
        v_custom_msg := 'Cannot delete. This record is being used by other records.';
    ELSE
        v_custom_msg := 'Error: ' || v_error_text;
    END IF;
    MESSAGE(v_custom_msg);
    RAISE FORM_TRIGGER_FAILURE;
END;
```

### ON-MESSAGE (Form Level)
```sql
DECLARE
    v_msg_code NUMBER := MESSAGE_CODE;
    v_msg_text VARCHAR2(200) := MESSAGE_TEXT;
BEGIN
    -- Suppress standard save messages
    IF v_msg_code IN (40400, 40401, 40202) THEN
        NULL; -- Suppress
    ELSE
        MESSAGE(v_msg_text);
    END IF;
END;
```

### WHEN-NEW-FORM-INSTANCE (Form Level)
```sql
BEGIN
    -- Set form title
    SET_WINDOW_PROPERTY(FORMS_MDI_WINDOW, TITLE, 'Oxen Company Limited - Sales Form');
    
    -- Navigate to first item
    GO_BLOCK('BLOCK_NAME');
    
    -- Initialize variables
    :GLOBAL.G_FORM_NAME := 'SALES_FORM';
    
    -- Display welcome message
    MESSAGE('Form loaded. Press F7 to search or F6 to create new record.');
END;
```

### PRE-FORM (Form Level)
```sql
BEGIN
    -- Validate user is logged in
    IF :GLOBAL.G_USERNAME IS NULL THEN
        MESSAGE('Please login first.');
        RAISE FORM_TRIGGER_FAILURE;
    END IF;
    
    -- Set application properties
    :GLOBAL.G_CURRENT_FORM := 'HOME_FORM';
END;
```

---

## Button Triggers

### Save Button (WHEN-BUTTON-PRESSED)
```sql
BEGIN
    IF :SYSTEM.FORM_STATUS = 'CHANGED' OR 
       :SYSTEM.RECORD_STATUS IN ('CHANGED', 'NEW') THEN
        VALIDATE(FORM_SCOPE);
        COMMIT_FORM;
        MESSAGE('Saved successfully.');
    ELSE
        MESSAGE('No changes to save.');
    END IF;
EXCEPTION
    WHEN FORM_TRIGGER_FAILURE THEN
        ROLLBACK;
        MESSAGE('Save cancelled.');
        RAISE FORM_TRIGGER_FAILURE;
END;
```

### Delete Button (WHEN-BUTTON-PRESSED)
```sql
DECLARE
    v_alert_button NUMBER;
BEGIN
    IF :SYSTEM.RECORD_STATUS IN ('NEW', 'INSERT') THEN
        MESSAGE('No record to delete.');
        RETURN;
    END IF;
    
    v_alert_button := SHOW_ALERT('ALERT_CONFIRM_DELETE');
    
    IF v_alert_button = ALERT_BUTTON1 THEN
        DELETE_RECORD;
        COMMIT_FORM;
        MESSAGE('Record deleted successfully.');
    ELSE
        MESSAGE('Delete cancelled.');
    END IF;
EXCEPTION
    WHEN FORM_TRIGGER_FAILURE THEN
        ROLLBACK;
        MESSAGE('Cannot delete: Record is referenced by other data.');
        RAISE FORM_TRIGGER_FAILURE;
END;
```

### Exit Button (WHEN-BUTTON-PRESSED)
```sql
DECLARE
    v_alert_button NUMBER;
BEGIN
    IF :SYSTEM.FORM_STATUS = 'CHANGED' THEN
        v_alert_button := SHOW_ALERT('ALERT_UNSAVED_CHANGES');
        IF v_alert_button = ALERT_BUTTON1 THEN
            COMMIT_FORM;
        ELSIF v_alert_button = ALERT_BUTTON2 THEN
            ROLLBACK;
        ELSE
            RETURN; -- Cancel
        END IF;
    END IF;
    EXIT_FORM(NO_VALIDATE);
END;
```

### Query Button (WHEN-BUTTON-PRESSED)
```sql
BEGIN
    ENTER_QUERY;
    MESSAGE('Enter search criteria and press Ctrl+F11 to execute.');
END;
```

### Clear Button (WHEN-BUTTON-PRESSED)
```sql
BEGIN
    IF :SYSTEM.MODE = 'ENTER-QUERY' THEN
        EXIT_QUERY;
    END IF;
    CLEAR_FORM(NO_COMMIT);
    GO_BLOCK('BLOCK_NAME');
    MESSAGE('Form cleared.');
END;
```

### Print Button (WHEN-BUTTON-PRESSED)
```sql
DECLARE
    v_report_params PARAMLIST;
    v_report_id     REPORT_OBJECT;
BEGIN
    -- Create parameter list
    v_report_params := CREATE_PARAMETER_LIST('REPORT_PARAMS');
    ADD_PARAMETER(v_report_params, 'P_INVOICE_ID', TEXT_PARAMETER, :BLOCK.INVOICE_ID);
    
    -- Run report
    RUN_PRODUCT(REPORTS, 'invoice_report', SYNCHRONOUS, RUNTIME, FILESYSTEM, v_report_params, NULL);
    
    -- Destroy parameter list
    DESTROY_PARAMETER_LIST(v_report_params);
END;
```

---

## Item-Level Triggers

### WHEN-VALIDATE-ITEM (Check if value exists in master table)
```sql
-- For Product ID field
DECLARE
    v_count NUMBER;
BEGIN
    IF :BLOCK.PRODUCT_ID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count
        FROM products
        WHERE product_id = :BLOCK.PRODUCT_ID
        AND status = 1;
        
        IF v_count = 0 THEN
            MESSAGE('Invalid product ID. Please select from list.');
            RAISE FORM_TRIGGER_FAILURE;
        END IF;
    END IF;
END;
```

### POST-TEXT-ITEM (Auto-populate related fields)
```sql
-- When Product ID is entered, populate product details
DECLARE
    v_product_name VARCHAR2(200);
    v_unit_price   NUMBER;
    v_stock_qty    NUMBER;
BEGIN
    IF :BLOCK.PRODUCT_ID IS NOT NULL THEN
        SELECT p.product_name, p.mrp, NVL(s.quantity, 0)
        INTO v_product_name, v_unit_price, v_stock_qty
        FROM products p
        LEFT JOIN stock s ON p.product_id = s.product_id
        WHERE p.product_id = :BLOCK.PRODUCT_ID
        AND p.status = 1;
        
        :BLOCK.PRODUCT_NAME := v_product_name;
        :BLOCK.UNIT_PRICE := v_unit_price;
        :BLOCK.STOCK_AVAILABLE := v_stock_qty;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        MESSAGE('Product not found.');
        RAISE FORM_TRIGGER_FAILURE;
END;
```

### WHEN-LIST-CHANGED (For cascading LOVs)
```sql
-- When Category is changed, populate Sub-Category list
DECLARE
    rg_subcat   RECORDGROUP;
    v_status    NUMBER;
BEGIN
    -- Delete existing record group if exists
    rg_subcat := FIND_GROUP('RG_SUBCATEGORY');
    IF NOT ID_NULL(rg_subcat) THEN
        DELETE_GROUP(rg_subcat);
    END IF;
    
    -- Create new record group based on selected category
    rg_subcat := CREATE_GROUP_FROM_QUERY(
        'RG_SUBCATEGORY',
        'SELECT sub_cat_name, sub_cat_id 
         FROM sub_categories 
         WHERE product_cat_id = ''' || :BLOCK.CATEGORY_ID || '''
         AND status = 1
         ORDER BY sub_cat_name'
    );
    
    -- Populate record group
    v_status := POPULATE_GROUP(rg_subcat);
    
    -- Populate list item
    POPULATE_LIST('BLOCK.SUB_CATEGORY_ID', rg_subcat);
    
    -- Clear current sub-category selection
    :BLOCK.SUB_CATEGORY_ID := NULL;
END;
```

### WHEN-NEW-ITEM-INSTANCE (Display help text)
```sql
BEGIN
    IF :SYSTEM.CURSOR_ITEM = 'BLOCK.PRODUCT_ID' THEN
        MESSAGE('Press F9 to open product list or enter product ID manually.');
    ELSIF :SYSTEM.CURSOR_ITEM = 'BLOCK.QUANTITY' THEN
        MESSAGE('Available stock: ' || :BLOCK.STOCK_AVAILABLE);
    END IF;
END;
```

### KEY-LISTVAL (F9 - Open LOV)
```sql
-- Open custom LOV window
BEGIN
    GO_ITEM('BLOCK.PRODUCT_ID');
    LIST_VALUES;
END;
```

---

## LOV Queries

### Customers LOV
```sql
SELECT 
    customer_id,
    customer_name || ' (' || phone_no || ')' AS display_value
FROM customers
WHERE status = 1
ORDER BY customer_name
```

### Products LOV (with stock)
```sql
SELECT 
    p.product_id,
    p.product_name,
    b.brand_name,
    p.mrp,
    NVL(s.quantity, 0) AS stock
FROM products p
LEFT JOIN brand b ON p.brand_id = b.brand_id
LEFT JOIN stock s ON p.product_id = s.product_id
WHERE p.status = 1
ORDER BY p.product_name
```

### Employees LOV
```sql
SELECT 
    employee_id,
    employee_name || ' - ' || phone_no AS display_value
FROM employees
WHERE status = 1
ORDER BY employee_name
```

### Suppliers LOV
```sql
SELECT 
    supplier_id,
    supplier_name || ' (' || phone_no || ')' AS display_value
FROM suppliers
WHERE status = 1
ORDER BY supplier_name
```

### Product Categories LOV
```sql
SELECT 
    product_cat_id,
    product_cat_name
FROM product_categories
WHERE status = 1
ORDER BY product_cat_name
```

### Sub-Categories LOV (Cascading - based on category)
```sql
SELECT 
    sub_cat_id,
    sub_cat_name
FROM sub_categories
WHERE product_cat_id = :BLOCK.CATEGORY_ID
AND status = 1
ORDER BY sub_cat_name
```

---

## Navigation Code

### Open Form with Parameters
```sql
-- Using CALL_FORM
DECLARE
    v_params PARAMLIST;
BEGIN
    v_params := CREATE_PARAMETER_LIST('FORM_PARAMS');
    ADD_PARAMETER(v_params, 'P_CUSTOMER_ID', TEXT_PARAMETER, :BLOCK.CUSTOMER_ID);
    CALL_FORM('CUSTOMER_DETAIL', NO_HIDE, DO_REPLACE, NO_QUERY_ONLY, v_params);
END;
```

### Open Report
```sql
-- Run Oracle Report
DECLARE
    v_params PARAMLIST;
BEGIN
    v_params := CREATE_PARAMETER_LIST('RPT_PARAMS');
    ADD_PARAMETER(v_params, 'P_FROM_DATE', TEXT_PARAMETER, TO_CHAR(:BLOCK.FROM_DATE, 'DD-MON-YYYY'));
    ADD_PARAMETER(v_params, 'P_TO_DATE', TEXT_PARAMETER, TO_CHAR(:BLOCK.TO_DATE, 'DD-MON-YYYY'));
    
    RUN_PRODUCT(REPORTS, 'sales_report', SYNCHRONOUS, RUNTIME, FILESYSTEM, v_params, NULL);
    
    DESTROY_PARAMETER_LIST(v_params);
END;
```

### Navigate Between Records
```sql
-- Next Record
BEGIN
    NEXT_RECORD;
END;

-- Previous Record
BEGIN
    PREVIOUS_RECORD;
END;

-- First Record
BEGIN
    FIRST_RECORD;
END;

-- Last Record
BEGIN
    LAST_RECORD;
END;
```

---

## Validation Functions

### Check Stock Availability
```sql
-- As Function (create in Program Units)
FUNCTION check_stock_available(p_product_id VARCHAR2, p_quantity NUMBER) 
RETURN BOOLEAN IS
    v_stock NUMBER;
BEGIN
    SELECT NVL(quantity, 0) INTO v_stock
    FROM stock
    WHERE product_id = p_product_id;
    
    RETURN (v_stock >= p_quantity);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END;

-- Usage in trigger
IF NOT check_stock_available(:BLOCK.PRODUCT_ID, :BLOCK.QUANTITY) THEN
    MESSAGE('Insufficient stock available.');
    RAISE FORM_TRIGGER_FAILURE;
END IF;
```

### Validate Date Range
```sql
PROCEDURE validate_date_range(p_from_date DATE, p_to_date DATE) IS
BEGIN
    IF p_from_date IS NULL OR p_to_date IS NULL THEN
        MESSAGE('Please enter both from and to dates.');
        RAISE FORM_TRIGGER_FAILURE;
    END IF;
    
    IF p_from_date > p_to_date THEN
        MESSAGE('From date cannot be later than to date.');
        RAISE FORM_TRIGGER_FAILURE;
    END IF;
END;
```

### Calculate Total Amount
```sql
FUNCTION calculate_total RETURN NUMBER IS
    v_total NUMBER := 0;
BEGIN
    GO_BLOCK('DETAIL_BLOCK');
    FIRST_RECORD;
    
    LOOP
        v_total := v_total + NVL(:DETAIL_BLOCK.LINE_TOTAL, 0);
        NEXT_RECORD;
        EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';
    END LOOP;
    
    RETURN v_total;
END;
```

---

## Common Utilities

### Show Custom Message
```sql
PROCEDURE show_message(p_message VARCHAR2, p_type VARCHAR2 DEFAULT 'INFO') IS
BEGIN
    MESSAGE(p_message);
    -- Optional: Log to table
    -- INSERT INTO message_log (message_text, message_type, logged_by, log_date)
    -- VALUES (p_message, p_type, USER, SYSDATE);
END;
```

### Confirm Action
```sql
FUNCTION confirm_action(p_message VARCHAR2) RETURN BOOLEAN IS
    v_alert_button NUMBER;
    v_alert_id ALERT;
BEGIN
    v_alert_id := FIND_ALERT('ALERT_CONFIRM');
    SET_ALERT_PROPERTY(v_alert_id, TITLE, 'Confirm Action');
    SET_ALERT_PROPERTY(v_alert_id, ALERT_MESSAGE_TEXT, p_message);
    
    v_alert_button := SHOW_ALERT(v_alert_id);
    
    RETURN (v_alert_button = ALERT_BUTTON1);
END;

-- Usage
IF confirm_action('Are you sure you want to proceed?') THEN
    -- Proceed with action
    NULL;
END IF;
```

### Get Next Sequence Value
```sql
FUNCTION get_next_id(p_sequence_name VARCHAR2) RETURN NUMBER IS
    v_sql VARCHAR2(200);
    v_next_val NUMBER;
BEGIN
    v_sql := 'SELECT ' || p_sequence_name || '.NEXTVAL FROM DUAL';
    EXECUTE IMMEDIATE v_sql INTO v_next_val;
    RETURN v_next_val;
END;
```

### Format Currency
```sql
FUNCTION format_currency(p_amount NUMBER) RETURN VARCHAR2 IS
BEGIN
    RETURN TO_CHAR(p_amount, '999,999,990.00');
END;
```

### Audit Stamp (for manual record creation)
```sql
PROCEDURE set_audit_fields IS
BEGIN
    IF :SYSTEM.RECORD_STATUS = 'NEW' THEN
        :BLOCK.STATUS := 1;
        :BLOCK.CRE_BY := USER;
        :BLOCK.CRE_DT := SYSDATE;
    ELSIF :SYSTEM.RECORD_STATUS = 'CHANGED' THEN
        :BLOCK.UPD_BY := USER;
        :BLOCK.UPD_DT := SYSDATE;
    END IF;
END;
```

### Export to Excel (Using Web Util)
```sql
-- Requires Oracle Forms WebUtil
DECLARE
    v_filename VARCHAR2(200);
    v_file TEXT_IO.FILE_TYPE;
BEGIN
    v_filename := CLIENT_GET_FILE_NAME('*.csv', NULL, 'Save As', NULL, SAVE_FILE);
    
    IF v_filename IS NOT NULL THEN
        v_file := TEXT_IO.FOPEN(v_filename, 'W');
        
        -- Write header
        TEXT_IO.PUT_LINE(v_file, 'Customer ID,Customer Name,Phone');
        
        -- Write data (loop through records)
        GO_BLOCK('CUSTOMER_BLOCK');
        FIRST_RECORD;
        LOOP
            TEXT_IO.PUT_LINE(v_file, 
                :CUSTOMER_BLOCK.CUSTOMER_ID || ',' ||
                :CUSTOMER_BLOCK.CUSTOMER_NAME || ',' ||
                :CUSTOMER_BLOCK.PHONE_NO
            );
            NEXT_RECORD;
            EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';
        END LOOP;
        
        TEXT_IO.FCLOSE(v_file);
        MESSAGE('Data exported successfully.');
    END IF;
END;
```

---

## Master-Detail Coordination

### POST-QUERY (Master Block)
```sql
-- Calculate detail totals when master record is queried
DECLARE
    v_total NUMBER := 0;
BEGIN
    GO_BLOCK('DETAIL_BLOCK');
    FIRST_RECORD;
    
    LOOP
        v_total := v_total + NVL(:DETAIL_BLOCK.LINE_TOTAL, 0);
        NEXT_RECORD;
        EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';
    END LOOP;
    
    GO_BLOCK('MASTER_BLOCK');
    :MASTER_BLOCK.GRAND_TOTAL := v_total;
END;
```

### WHEN-CREATE-RECORD (Detail Block)
```sql
-- Auto-populate master key in detail
BEGIN
    :DETAIL_BLOCK.INVOICE_ID := :MASTER_BLOCK.INVOICE_ID;
    :DETAIL_BLOCK.STATUS := 1;
END;
```

### ON-POPULATE-DETAILS (Master Block - Auto-Query Details)
```sql
BEGIN
    GO_BLOCK('DETAIL_BLOCK');
    EXECUTE_QUERY;
    GO_BLOCK('MASTER_BLOCK');
END;
```

---

## Login Form Complete Code

### WHEN-BUTTON-PRESSED (Login Button)
```sql
DECLARE
    v_username    VARCHAR2(100);
    v_password    VARCHAR2(200);
    v_user_id     VARCHAR2(50);
    v_role        VARCHAR2(50);
    v_employee_id VARCHAR2(50);
    v_emp_name    VARCHAR2(200);
BEGIN
    v_username := UPPER(TRIM(:BLK_LOGIN.TXT_USERNAME));
    v_password := :BLK_LOGIN.TXT_PASSWORD;
    
    IF v_username IS NULL OR v_password IS NULL THEN
        MESSAGE('Please enter both username and password.');
        RAISE FORM_TRIGGER_FAILURE;
    END IF;
    
    BEGIN
        SELECT u.user_id, u.user_name, u.role, u.employee_id, e.employee_name
        INTO v_user_id, v_username, v_role, v_employee_id, v_emp_name
        FROM com_users u
        LEFT JOIN employees e ON u.employee_id = e.employee_id
        WHERE UPPER(u.user_name) = v_username
        AND u.password = v_password
        AND u.status = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            MESSAGE('Invalid username or password.');
            :BLK_LOGIN.TXT_PASSWORD := NULL;
            GO_ITEM('BLK_LOGIN.TXT_PASSWORD');
            RAISE FORM_TRIGGER_FAILURE;
    END;
    
    :GLOBAL.G_USER_ID := v_user_id;
    :GLOBAL.G_USERNAME := v_username;
    :GLOBAL.G_USER_ROLE := v_role;
    :GLOBAL.G_EMPLOYEE_ID := v_employee_id;
    :GLOBAL.G_EMPLOYEE_NAME := v_emp_name;
    
    MESSAGE('Login successful! Welcome, ' || v_emp_name);
    
    HIDE_WINDOW('WIN_LOGIN');
    CALL_FORM('HOME_FORM', NO_HIDE, DO_REPLACE, NO_QUERY_ONLY, NULL);
    
EXCEPTION
    WHEN FORM_TRIGGER_FAILURE THEN
        RAISE;
    WHEN OTHERS THEN
        MESSAGE('Database error: ' || SQLERRM);
        RAISE FORM_TRIGGER_FAILURE;
END;
```

---

## Sales Form Example (Master-Detail)

### Sales Master Block - POST-BLOCK
```sql
-- Calculate totals before leaving master block
BEGIN
    :SALES_MASTER.SUBTOTAL := 0;
    :SALES_MASTER.VAT := 0;
    :SALES_MASTER.GRAND_TOTAL := 0;
    
    GO_BLOCK('SALES_DETAIL');
    FIRST_RECORD;
    
    LOOP
        :SALES_MASTER.SUBTOTAL := :SALES_MASTER.SUBTOTAL + NVL(:SALES_DETAIL.TOTAL, 0);
        :SALES_MASTER.VAT := :SALES_MASTER.VAT + NVL(:SALES_DETAIL.VAT, 0);
        NEXT_RECORD;
        EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';
    END LOOP;
    
    GO_BLOCK('SALES_MASTER');
    :SALES_MASTER.GRAND_TOTAL := :SALES_MASTER.SUBTOTAL + :SALES_MASTER.VAT - NVL(:SALES_MASTER.DISCOUNT, 0);
END;
```

### Sales Detail Block - WHEN-VALIDATE-ITEM (Quantity)
```sql
DECLARE
    v_stock NUMBER;
BEGIN
    IF :SALES_DETAIL.QUANTITY IS NOT NULL THEN
        SELECT NVL(quantity, 0) INTO v_stock
        FROM stock
        WHERE product_id = :SALES_DETAIL.PRODUCT_ID;
        
        IF :SALES_DETAIL.QUANTITY > v_stock THEN
            MESSAGE('Insufficient stock. Available: ' || v_stock);
            RAISE FORM_TRIGGER_FAILURE;
        END IF;
        
        -- Calculate line total
        :SALES_DETAIL.TOTAL := :SALES_DETAIL.QUANTITY * :SALES_DETAIL.UNIT_PRICE;
        :SALES_DETAIL.VAT := :SALES_DETAIL.TOTAL * 0.15; -- 15% VAT
        :SALES_DETAIL.TOTAL := :SALES_DETAIL.TOTAL + :SALES_DETAIL.VAT;
    END IF;
END;
```

---

## Quick Tips

### 1. Navigation Shortcuts
- **F6**: Create new record
- **F7**: Enter query mode
- **F8**: Execute query
- **F9**: Open LOV
- **F10**: Commit changes
- **Ctrl+F11**: Execute query (alternate)
- **Shift+F7**: Clear record

### 2. Performance Tips
- Use POST before COMMIT_FORM for validation
- Create indexes on foreign key columns
- Use WHERE clause in block properties for filtering
- Limit records fetched with Array Fetch property

### 3. Security Best Practices
- Never store plain text passwords
- Always check user status (status = 1)
- Use role-based access control
- Log all critical operations

### 4. Error Handling
- Always include EXCEPTION block in triggers
- Use RAISE FORM_TRIGGER_FAILURE to stop processing
- Log errors to a table for debugging
- Provide user-friendly messages

---

## Alert Definitions

### ALERT_CONFIRM_DELETE
- **Title**: Confirm Delete
- **Message**: Are you sure you want to delete this record?
- **Style**: Caution
- **Button 1**: Yes
- **Button 2**: No
- **Default**: Button 2

### ALERT_UNSAVED_CHANGES
- **Title**: Unsaved Changes
- **Message**: You have unsaved changes. Do you want to save?
- **Style**: Caution
- **Button 1**: Save
- **Button 2**: Don't Save
- **Button 3**: Cancel
- **Default**: Button 1

### ALERT_CONFIRM_EXIT
- **Title**: Exit Application
- **Message**: Are you sure you want to exit?
- **Style**: Caution
- **Button 1**: Yes
- **Button 2**: No
- **Default**: Button 2

---

## Database Connection Settings

### Form Properties
- **Database**: Oracle Database 11g+
- **Connect String**: `msp/msp@localhost:1521/orcl`
- **User ID**: msp
- **Password**: msp
- **Connect Mode**: Default

### Form Module Properties
- **Console Window**: NULL
- **First Navigation Block**: Set to your first data block
- **Validation Unit**: FORM
- **Savepoint Mode**: ON
- **Transaction Mode**: POST

---

**Document Version**: 1.0  
**Last Updated**: January 2026  
**Related**: ORACLE_FORMS_11G_ARCHITECTURE_GUIDE.md  
**Database**: Oracle 11g+ (msp/msp)

---
