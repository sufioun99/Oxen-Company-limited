# Oracle Forms LOV - Quick Implementation Guide

## 🚀 Quick Start for Developers

### Step 1: Create LOV Object in Oracle Forms Builder

1. **Open Forms Builder** → Navigate to LOVs node
2. **Right-click** → Create LOV
3. **Name**: `PRODUCTS_LOV`
4. **Record Group Source**: Select "New Record Group from Query"

### Step 2: Copy Query from forms_lov.sql

```sql
-- Example: PRODUCTS_LOV
SELECT product_name || ' (' || product_code || ')' AS product_display, 
       product_id, mrp, purchase_price
FROM products
WHERE status = 1
ORDER BY product_name;
```

### Step 3: Configure LOV Properties

| Property | Value | Notes |
|----------|-------|-------|
| Title | Select Product | User-friendly title |
| Width | 600 | Adjust as needed |
| Height | 400 | Adjust as needed |
| Automatic Position | Yes | Center on screen |
| Automatic Refresh | Yes | Refresh on display |
| Automatic Select | No | For validation |
| Automatic Skip | No | For validation |

### Step 4: Map Columns

| Column Name | Title | Width | Display | Return |
|-------------|-------|-------|---------|--------|
| PRODUCT_DISPLAY | Product Name | 300 | Yes | No |
| PRODUCT_ID | ID | 100 | Yes | Yes |
| MRP | MRP | 80 | Yes | No |
| PURCHASE_PRICE | Cost | 80 | Yes | No |

---

## 📋 Most Common LOVs (Copy & Paste)

### 1. Products LOV (Most Used)
```sql
SELECT product_name || ' (' || product_code || ')' AS product_display, 
       product_id, mrp, purchase_price
FROM products
WHERE status = 1
ORDER BY product_name;
```
**Use in**: Sales forms, purchase forms, stock forms

---

### 2. Customers LOV
```sql
SELECT customer_name || ' - ' || NVL(phone_no, 'N/A') AS customer_display, 
       customer_id
FROM customers
WHERE status = 1
ORDER BY customer_name;
```
**Use in**: Sales forms, service forms

---

### 3. Suppliers LOV
```sql
SELECT supplier_name, supplier_id
FROM suppliers
WHERE status = 1
ORDER BY supplier_name;
```
**Use in**: Purchase orders, product receive forms

---

### 4. Employees LOV
```sql
SELECT first_name || ' ' || last_name AS employee_name, 
       employee_id
FROM employees
WHERE status = 1
ORDER BY last_name, first_name;
```
**Use in**: All transaction forms (sales_by, service_by, etc.)

---

### 5. Services LOV
```sql
SELECT service_name || ' (BDT ' || TO_CHAR(service_cost) || ')' AS service_display,
       servicelist_id, service_cost
FROM service_list
WHERE status = 1
ORDER BY service_name;
```
**Use in**: Service request forms

---

## 🔄 Cascading LOVs Implementation

### Example: Category → Sub-Category Cascade

**Step 1: Create Category LOV**
```sql
SELECT product_cat_name, product_cat_id
FROM product_categories
WHERE status = 1
ORDER BY product_cat_name;
```

**Step 2: Create Sub-Category LOV (Cascading)**
```sql
SELECT sub_cat_name, sub_cat_id
FROM sub_categories
WHERE status = 1
AND product_cat_id = :PRODUCTS.CATEGORY_ID  -- Bind variable!
ORDER BY sub_cat_name;
```

**Step 3: Add WHEN-LIST-CHANGED Trigger on CATEGORY_ID**
```plsql
-- Trigger: WHEN-LIST-CHANGED on PRODUCTS.CATEGORY_ID
DECLARE
   rg_subcats RecordGroup;
   nDummy NUMBER;
BEGIN
   -- Delete existing record group
   rg_subcats := Find_Group('RG_SUBCATS');
   IF NOT Id_Null(rg_subcats) THEN
      Delete_Group(rg_subcats);
   END IF;
   
   -- Recreate with filtered data
   rg_subcats := Create_Group_From_Query(
      'RG_SUBCATS',
      'SELECT sub_cat_name, sub_cat_id ' ||
      'FROM sub_categories ' ||
      'WHERE status = 1 ' ||
      'AND product_cat_id = ''' || :PRODUCTS.CATEGORY_ID || ''' ' ||
      'ORDER BY sub_cat_name'
   );
   
   nDummy := Populate_Group(rg_subcats);
   Clear_List('PRODUCTS.SUB_CAT_ID');
   Populate_List('PRODUCTS.SUB_CAT_ID', rg_subcats);
   
   -- Clear current selection
   :PRODUCTS.SUB_CAT_ID := NULL;
END;
```

---

## ⚡ Auto-Population Triggers

### Trigger 1: Auto-Fill Product Price
**Location**: WHEN-VALIDATE-ITEM on SALES_DETAIL.PRODUCT_ID

```plsql
DECLARE
   v_mrp            NUMBER;
   v_purchase_price NUMBER;
BEGIN
   IF :SALES_DETAIL.PRODUCT_ID IS NOT NULL THEN
      SELECT mrp, purchase_price
      INTO v_mrp, v_purchase_price
      FROM products
      WHERE product_id = :SALES_DETAIL.PRODUCT_ID;
      
      :SALES_DETAIL.MRP := v_mrp;
      :SALES_DETAIL.UNIT_PRICE := v_mrp;  -- Default to MRP
      
      -- Set default quantity
      IF :SALES_DETAIL.QUANTITY IS NULL THEN
         :SALES_DETAIL.QUANTITY := 1;
      END IF;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      Message('Product not found!');
      RAISE Form_Trigger_Failure;
END;
```

---

### Trigger 2: Stock Check Warning
**Location**: WHEN-VALIDATE-ITEM on SALES_DETAIL.QUANTITY

```plsql
DECLARE
   v_stock_qty NUMBER;
BEGIN
   IF :SALES_DETAIL.PRODUCT_ID IS NOT NULL AND 
      :SALES_DETAIL.QUANTITY IS NOT NULL THEN
      
      -- Use automation package function
      v_stock_qty := pkg_oxen_automation.check_stock(:SALES_DETAIL.PRODUCT_ID);
      
      IF v_stock_qty < :SALES_DETAIL.QUANTITY THEN
         Message('WARNING: Only ' || v_stock_qty || ' units available!');
         -- Show alert but don't fail (allow override)
      END IF;
   END IF;
END;
```

---

### Trigger 3: Customer Details Display
**Location**: WHEN-VALIDATE-ITEM on SALES_MASTER.CUSTOMER_ID

```plsql
DECLARE
   v_name    VARCHAR2(150);
   v_phone   VARCHAR2(50);
   v_rewards NUMBER;
BEGIN
   IF :SALES_MASTER.CUSTOMER_ID IS NOT NULL THEN
      SELECT customer_name, phone_no, NVL(rewards, 0)
      INTO v_name, v_phone, v_rewards
      FROM customers
      WHERE customer_id = :SALES_MASTER.CUSTOMER_ID;
      
      -- Display in non-database items
      :SALES_MASTER.CUSTOMER_NAME_DISPLAY := v_name;
      :SALES_MASTER.CUSTOMER_PHONE_DISPLAY := v_phone;
      :SALES_MASTER.CUSTOMER_REWARDS_DISPLAY := v_rewards;
      
      Message('Customer: ' || v_name || ' (Rewards: BDT ' || v_rewards || ')');
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      Message('Customer not found!');
END;
```

---

## 🎯 Button Triggers

### Calculate Total Button
```plsql
-- Trigger: WHEN-BUTTON-PRESSED on BTN_CALCULATE
DECLARE
   v_subtotal NUMBER := 0;
   v_vat      NUMBER := 0;
   v_discount NUMBER := 0;
   v_total    NUMBER := 0;
BEGIN
   -- Go to detail block
   Go_Block('SALES_DETAIL');
   First_Record;
   
   -- Loop through all detail records
   LOOP
      EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';
      
      v_subtotal := v_subtotal + 
                    (NVL(:SALES_DETAIL.UNIT_PRICE, 0) * 
                     NVL(:SALES_DETAIL.QUANTITY, 0));
      v_vat := v_vat + NVL(:SALES_DETAIL.VAT, 0);
      
      Next_Record;
   END LOOP;
   
   -- Process last record
   v_subtotal := v_subtotal + 
                 (NVL(:SALES_DETAIL.UNIT_PRICE, 0) * 
                  NVL(:SALES_DETAIL.QUANTITY, 0));
   v_vat := v_vat + NVL(:SALES_DETAIL.VAT, 0);
   
   -- Go back to master
   Go_Block('SALES_MASTER');
   v_discount := NVL(:SALES_MASTER.DISCOUNT, 0);
   v_total := v_subtotal + v_vat - v_discount;
   
   -- Update master fields
   :SALES_MASTER.GRAND_TOTAL := v_total;
   
   Message('Total calculated: BDT ' || TO_CHAR(v_total, 'FM999,999,990.00'));
END;
```

---

### Finalize Invoice Button
```plsql
-- Trigger: WHEN-BUTTON-PRESSED on BTN_FINALIZE
DECLARE
   v_result VARCHAR2(4000);
BEGIN
   -- Validate required fields
   IF :SALES_MASTER.INVOICE_ID IS NULL THEN
      Message('Please save the invoice first!');
      RAISE Form_Trigger_Failure;
   END IF;
   
   IF :SALES_MASTER.CUSTOMER_ID IS NULL THEN
      Message('Customer is required!');
      RAISE Form_Trigger_Failure;
   END IF;
   
   -- Commit pending changes
   Commit_Form;
   
   -- Call automation package
   pkg_oxen_automation.finalize_sales(
      :SALES_MASTER.INVOICE_ID,
      v_result
   );
   
   IF v_result LIKE 'SUCCESS%' THEN
      Message(v_result || ' - Stock updated!');
      
      -- Refresh form
      Clear_Block(NO_VALIDATE);
      Execute_Query;
   ELSE
      Message('Error: ' || v_result);
      RAISE Form_Trigger_Failure;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      Message('Error finalizing invoice: ' || SQLERRM);
      RAISE Form_Trigger_Failure;
END;
```

---

## 📦 Complete Form Example: Sales Invoice

### Data Blocks Required:
1. **SALES_MASTER** (Master)
   - Database: sales_master table
   - Items: invoice_id, invoice_date, customer_id, sales_by, discount, grand_total
   - Non-DB items: customer_name_display, customer_phone_display

2. **SALES_DETAIL** (Detail)
   - Database: sales_detail table
   - Items: salesd_id, invoice_id, product_id, quantity, unit_price, vat, total
   - Master-Detail Relationship: invoice_id

### LOVs Required:
1. CUSTOMERS_LOV → customer_id
2. EMPLOYEES_LOV → sales_by
3. PRODUCTS_LOV → product_id (in detail block)

### Triggers Required:
1. WHEN-NEW-FORM-INSTANCE (Form-level)
2. WHEN-VALIDATE-ITEM on customer_id
3. WHEN-VALIDATE-ITEM on product_id
4. WHEN-VALIDATE-ITEM on quantity
5. WHEN-BUTTON-PRESSED on Calculate button
6. WHEN-BUTTON-PRESSED on Finalize button

---

## 🔍 Testing Checklist

### LOV Testing:
- [ ] LOV opens and displays data correctly
- [ ] Search functionality works (F9 or Ctrl+L)
- [ ] Columns are properly aligned
- [ ] Return value populates correct field
- [ ] LOV closes after selection

### Cascading LOV Testing:
- [ ] Parent LOV selection triggers child LOV refresh
- [ ] Child LOV shows filtered data
- [ ] Child LOV clears when parent changes
- [ ] No errors when parent is null

### Auto-Population Testing:
- [ ] Prices auto-fill when product selected
- [ ] Customer details display correctly
- [ ] Stock warnings appear when needed
- [ ] Calculations update automatically

### Button Testing:
- [ ] Calculate button computes correct total
- [ ] Finalize button commits and updates stock
- [ ] Error messages display properly
- [ ] Form refreshes after finalize

---

## 🛠️ Troubleshooting

### Problem: LOV doesn't display data
**Solution**: Check status = 1 filter, verify table has data

### Problem: Cascading LOV doesn't refresh
**Solution**: Ensure Delete_Group() before Create_Group_From_Query()

### Problem: Auto-population doesn't work
**Solution**: Check exact field names, case-sensitive: :BLOCK.FIELD

### Problem: "FRM-40735: WHEN-VALIDATE-ITEM trigger raised unhandled exception"
**Solution**: Add proper exception handling with WHEN OTHERS

### Problem: Stock not updating after finalize
**Solution**: Verify automation package is compiled, check commit_form before calling package

---

## 📚 Additional Resources

### In This Repository:
- **forms_lov.sql** - Complete LOV queries and triggers
- **automation_pkg.sql** - Business logic package
- **clean_combined.sql** - Complete database setup
- **LOV_TEST_RESULTS.md** - Test results and validation

### Oracle Forms Documentation:
- LOV Properties
- Record Groups
- Trigger Reference
- Built-in Packages

---

## ✅ Production Checklist

Before deploying forms to production:

- [ ] All LOVs tested with real data
- [ ] Cascading LOVs work correctly
- [ ] Auto-population triggers validated
- [ ] Button triggers tested end-to-end
- [ ] Error handling implemented
- [ ] User messages are clear and helpful
- [ ] Performance tested with large datasets
- [ ] Security validated (user permissions)
- [ ] Forms compiled (.fmx files generated)
- [ ] Forms deployed to server
- [ ] User training completed

---

**Last Updated**: January 3, 2026  
**Status**: Production Ready ✅  
**Database**: Oracle 11g XE  
**Forms Version**: Oracle Forms 11g
