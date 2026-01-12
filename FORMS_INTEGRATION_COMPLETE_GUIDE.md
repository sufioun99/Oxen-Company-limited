# 📘 Oracle Forms Integration - Complete Guide

**Oxen Company Limited - Electronics Inventory Management System**

---

## 📑 Table of Contents

1. [Quick Start](#quick-start)
2. [Forms Compatibility Status](#forms-compatibility-status)
3. [Multi-Product Implementation](#multi-product-implementation)
4. [LOV (List of Values) Setup](#lov-setup)
5. [New Record Triggers](#new-record-triggers)
6. [Common Patterns](#common-patterns)
7. [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

### Database Compatibility Summary

✅ **100% Forms Compatible** - All database triggers use AFTER statements (no conflicts with Forms)

**Key Points:**
- BEFORE triggers: Only for ID generation and audit columns (Forms-safe)
- AFTER triggers: Stock automation, validations (no conflicts)
- All detail tables ready for master-detail blocks
- Auto-ID generation via sequences (no manual ID entry needed)

### Active Automation Features

✅ **Stock Management Triggers (Active)**
1. `trg_stock_on_sales_det` - Auto-deduct stock on sales
2. `trg_stock_on_receive_det` - Auto-add stock on product receive
3. `trg_validate_receive_direct` - Validate products were ordered
4. `trg_stock_on_prod_return_det` - Deduct stock on returns to supplier
5. `trg_stock_on_damage_det` - Write off damaged stock

✅ **Schema Improvements**
- ❌ Removed `line_no` columns from all detail tables (Forms-compatible)
- ✅ Master-detail relationships fully functional
- ✅ All sequences and triggers operational

---

## 🎯 Multi-Product Implementation

### Problem: Single Product Limitation

**Original Issue:** Forms triggers using `ROWNUM = 1` only fetch first product from multi-product invoices.

### Solution: Three Approaches

#### **Approach 1: Cursor Min/Max Warranty (30 min)**
Use cursor to find shortest warranty period.

```sql
-- WHEN-VALIDATE-ITEM on INVOICE_ID
DECLARE
    v_min_warranty NUMBER := 999;
    CURSOR c_products IS
        SELECT p.warranty_months
        FROM sales_detail sd
        JOIN products p ON sd.product_id = p.product_id
        WHERE sd.invoice_id = :SERVICE_MASTER.INVOICE_ID;
BEGIN
    FOR prod IN c_products LOOP
        IF prod.warranty_months < v_min_warranty THEN
            v_min_warranty := prod.warranty_months;
        END IF;
    END LOOP;
    
    -- Use minimum warranty for validation
    :SERVICE_MASTER.WARRANTY_MONTHS := v_min_warranty;
END;
```

#### **Approach 2: Product Selection LOV (2.5 hrs) ⭐ RECOMMENDED**
Show dropdown of all products from invoice.

```sql
-- WHEN-VALIDATE-ITEM on INVOICE_ID
DECLARE
    rg_id RECORDGROUP;
    v_selected_product VARCHAR2(50);
BEGIN
    -- Create dynamic record group from invoice products
    rg_id := CREATE_GROUP_FROM_QUERY(
        'RG_INVOICE_PRODUCTS',
        'SELECT p.product_name || '' (Warranty: '' || p.warranty_months || '' months)'' AS display, ' ||
        '       TO_CHAR(p.product_id) AS product_id, ' ||
        '       TO_CHAR(p.warranty_months) AS warranty ' ||
        'FROM sales_detail sd ' ||
        'JOIN products p ON sd.product_id = p.product_id ' ||
        'WHERE sd.invoice_id = ''' || :SERVICE_MASTER.INVOICE_ID || ''' ' ||
        'ORDER BY p.product_name'
    );
    
    POPULATE_GROUP(rg_id);
    
    -- Show LOV to user
    v_selected_product := SHOW_LOV('LOV_INVOICE_PRODUCTS', 100, 100);
    
    IF v_selected_product IS NOT NULL THEN
        :SERVICE_MASTER.PRODUCT_ID := v_selected_product;
        
        -- Get warranty months for selected product
        SELECT warranty_months INTO :SERVICE_MASTER.WARRANTY_MONTHS
        FROM products WHERE product_id = v_selected_product;
    END IF;
END;
```

**Benefits:**
- ✅ Professional UX - dropdown selection
- ✅ Shows all products with warranty info
- ✅ User controls which product they're servicing
- ✅ No database changes needed

---

## 📋 LOV (List of Values) Setup

### Standard LOV Queries

All LOV queries available in `forms_lov.sql`. Key patterns:

#### **Products LOV**
```sql
SELECT p.product_id,
       p.product_name || ' - ' || b.brand_name AS display_name,
       p.unit_price,
       s.quantity AS available_stock
FROM products p
LEFT JOIN brand b ON p.brand_id = b.brand_id
LEFT JOIN stock s ON p.product_id = s.product_id
WHERE p.status = 1
ORDER BY p.product_name;
```

#### **Customers LOV**
```sql
SELECT customer_id,
       customer_name || ' (' || phone_no || ')' AS display,
       phone_no,
       address
FROM customers
WHERE status = 1
ORDER BY customer_name;
```

#### **Suppliers LOV**
```sql
SELECT supplier_id,
       supplier_name,
       contact_person,
       phone_no,
       NVL(due, 0) AS outstanding_due
FROM suppliers
WHERE status = 1
ORDER BY supplier_name;
```

### Dynamic LOV Creation Pattern

**Use in WHEN-NEW-FORM-INSTANCE:**

```sql
DECLARE
    rg_products RECORDGROUP;
    nDummy NUMBER;
BEGIN
    -- Delete if exists
    BEGIN
        DELETE_GROUP('RG_PRODUCTS');
    EXCEPTION
        WHEN FORM_TRIGGER_FAILURE THEN NULL;
    END;
    
    -- Create from query
    rg_products := CREATE_GROUP_FROM_QUERY(
        'RG_PRODUCTS',
        'SELECT product_name, TO_CHAR(product_id) FROM products WHERE status = 1 ORDER BY product_name'
    );
    
    -- Populate
    nDummy := POPULATE_GROUP(rg_products);
    
    -- Attach to list item
    POPULATE_LIST('BLOCK_NAME.PRODUCT_ID', rg_products);
END;
```

---

## 🆕 New Record Triggers

### Pattern: Creating New Transaction Records

**Applied to:** sales_master, product_order_master, product_receive_master, service_master, expense_master

#### **Template: WHEN-BUTTON-PRESSED on "New" Button**

```sql
DECLARE
    v_next_id VARCHAR2(50);
BEGIN
    -- Clear form
    IF :SYSTEM.FORM_STATUS IN ('CHANGED', 'NEW') THEN
        CLEAR_FORM(NO_VALIDATE);
    ELSE
        CLEAR_FORM;
    END IF;
    
    GO_BLOCK('MASTER_BLOCK_NAME');
    CREATE_RECORD;
    
    -- Get next sequence (matches database trigger pattern)
    SELECT 'PREFIX' || TO_CHAR(sequence_name.NEXTVAL) 
    INTO v_next_id FROM DUAL;
    
    :MASTER_BLOCK.primary_key_field := v_next_id;
    :MASTER_BLOCK.status := 1;
    :MASTER_BLOCK.cre_by := USER;
    :MASTER_BLOCK.cre_dt := SYSDATE;
    
    -- Set defaults for transaction
    :MASTER_BLOCK.transaction_date := SYSDATE;
    :MASTER_BLOCK.discount := 0;
    :MASTER_BLOCK.vat := 0;
    :MASTER_BLOCK.grand_total := 0;
    
EXCEPTION
    WHEN OTHERS THEN
        MESSAGE('Error: ' || SQLERRM);
        RAISE FORM_TRIGGER_FAILURE;
END;
```

#### **Examples by Transaction Type**

**SALES_MASTER:**
```sql
SELECT 'INV' || TO_CHAR(sales_seq.NEXTVAL) INTO v_next_invoice_id FROM DUAL;
:SALES_MASTER.invoice_id := v_next_invoice_id;
```

**PRODUCT_ORDER_MASTER:**
```sql
SELECT 'ORD' || TO_CHAR(product_order_seq.NEXTVAL) INTO v_next_order_id FROM DUAL;
:PRODUCT_ORDER_MASTER.order_id := v_next_order_id;
```

**SERVICE_MASTER:**
```sql
SELECT 'SVM' || TO_CHAR(service_seq.NEXTVAL) INTO v_next_service_id FROM DUAL;
:SERVICE_MASTER.service_id := v_next_service_id;
```

---

## 🎯 Product Receive Multi-Product Implementation

### Database Structure

```
product_order_master (ORD0001)
├─ product_order_detail
   ├─ Samsung TV × 10
   ├─ Microwave × 5
   └─ Refrigerator × 8

product_receive_master (RCV0001)
└─ product_receive_details
   ├─ Samsung TV × 10
   ├─ Microwave × 5
   └─ Refrigerator × 8
```

### Auto-Populate from Order

**WHEN-VALIDATE-ITEM on ORDER_ID:**

```sql
DECLARE
    v_supplier_id VARCHAR2(50);
    CURSOR c_order_products IS
        SELECT pod.product_id, p.product_name,
               pod.quantity AS ordered_qty,
               pod.purchase_price, pod.mrp
        FROM product_order_detail pod
        JOIN products p ON pod.product_id = p.product_id
        WHERE pod.order_id = :PRODUCT_RECEIVE_MASTER.ORDER_ID
        ORDER BY p.product_name;
    v_line_no NUMBER := 0;
BEGIN
    IF :PRODUCT_RECEIVE_MASTER.ORDER_ID IS NOT NULL THEN
        
        -- Get supplier from order
        SELECT supplier_id INTO v_supplier_id
        FROM product_order_master
        WHERE order_id = :PRODUCT_RECEIVE_MASTER.ORDER_ID;
        
        :PRODUCT_RECEIVE_MASTER.SUPPLIER_ID := v_supplier_id;
        
        -- Clear existing detail records
        GO_BLOCK('PRODUCT_RECEIVE_DETAILS');
        FIRST_RECORD;
        LOOP
            EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';
            DELETE_RECORD;
        END LOOP;
        
        -- Load all products from order
        GO_BLOCK('PRODUCT_RECEIVE_DETAILS');
        FIRST_RECORD;
        
        FOR product_rec IN c_order_products LOOP
            v_line_no := v_line_no + 1;
            
            IF :SYSTEM.CURSOR_RECORD > 1 THEN
                CREATE_RECORD;
            END IF;
            
            :PRODUCT_RECEIVE_DETAILS.PRODUCT_ID := product_rec.product_id;
            :PRODUCT_RECEIVE_DETAILS.RECEIVE_QUANTITY := product_rec.ordered_qty;
            :PRODUCT_RECEIVE_DETAILS.PURCHASE_PRICE := product_rec.purchase_price;
            :PRODUCT_RECEIVE_DETAILS.MRP := product_rec.mrp;
            
            NEXT_RECORD;
        END LOOP;
        
        FIRST_RECORD;
        MESSAGE('Loaded ' || v_line_no || ' products from order');
        GO_BLOCK('PRODUCT_RECEIVE_MASTER');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        MESSAGE('Order not found');
        RAISE FORM_TRIGGER_FAILURE;
END;
```

---

## 🔧 Common Patterns

### Pattern 1: Master-Detail Block Setup

**Master Block Properties:**
- Database Data Block: Yes
- Query Data Source: table_name_master
- DML Target: table_name_master
- Records Displayed: 1

**Detail Block Properties:**
- Database Data Block: Yes
- Query Data Source: table_name_detail
- DML Target: table_name_detail
- Records Displayed: 10
- Scrollbar: Yes
- **Relationship:**
  - Master Block: MASTER_BLOCK_NAME
  - Join Condition: detail_table.master_id = :MASTER_BLOCK.master_id
  - Coordination: Auto-Query

### Pattern 2: Calculate Line Totals

**WHEN-VALIDATE-ITEM on QUANTITY or UNIT_PRICE:**

```sql
:DETAIL_BLOCK.TOTAL := NVL(:DETAIL_BLOCK.QUANTITY, 0) * NVL(:DETAIL_BLOCK.UNIT_PRICE, 0);
```

### Pattern 3: Calculate Master Totals

**POST-QUERY on Detail Block:**

```sql
DECLARE
    v_total NUMBER := 0;
BEGIN
    SELECT NVL(SUM(total), 0)
    INTO v_total
    FROM detail_table
    WHERE master_id = :MASTER_BLOCK.master_id;
    
    :MASTER_BLOCK.GRAND_TOTAL := v_total;
END;
```

### Pattern 4: Validate Stock Before Sales

**WHEN-VALIDATE-ITEM on SALES_DETAIL.QUANTITY:**

```sql
DECLARE
    v_available_stock NUMBER;
BEGIN
    SELECT NVL(quantity, 0)
    INTO v_available_stock
    FROM stock
    WHERE product_id = :SALES_DETAIL.PRODUCT_ID;
    
    IF :SALES_DETAIL.QUANTITY > v_available_stock THEN
        MESSAGE('Insufficient stock. Available: ' || v_available_stock);
        RAISE FORM_TRIGGER_FAILURE;
    END IF;
END;
```

---

## ❗ Troubleshooting

### Issue: "FRM-40735: Cannot insert NULL"

**Cause:** Primary key field not populated before insert.

**Solution:** Ensure WHEN-BUTTON-PRESSED trigger generates ID:
```sql
:MASTER_BLOCK.master_id := 'PREFIX' || sequence_name.NEXTVAL;
```

### Issue: Detail Records Not Saving

**Cause:** Master-detail relationship not configured.

**Solution:**
1. Check join condition in detail block properties
2. Verify foreign key field populated: `:DETAIL.master_id := :MASTER.master_id;`
3. Set "Delete Record Behavior" to "Cascading"

### Issue: Stock Not Updating

**Cause:** Database triggers disabled or not committed.

**Solution:**
```sql
-- Check trigger status
SELECT trigger_name, status FROM user_triggers WHERE trigger_name LIKE '%STOCK%';

-- If disabled, enable:
ALTER TRIGGER trg_stock_on_sales_det ENABLE;
```

### Issue: LOV Not Showing Data

**Cause:** Record group not populated.

**Solution:**
```sql
-- Check return value
nDummy := POPULATE_GROUP(rg_id);
IF nDummy <> 0 THEN
    MESSAGE('LOV query error: ' || nDummy);
END IF;
```

---

## 📊 Quick Reference

### Master-Detail Tables

| Master | Detail | Purpose |
|--------|--------|---------|
| sales_master | sales_detail | Sales transactions |
| service_master | service_details | Service requests |
| product_order_master | product_order_detail | Purchase orders |
| product_receive_master | product_receive_details | Product receiving |
| sales_return_master | sales_return_details | Customer returns |
| product_return_master | product_return_details | Supplier returns |
| expense_master | expense_details | Expenses |
| damage | damage_detail | Damaged stock |

### Sequence & Prefix Reference

| Table | Sequence | Prefix | Example |
|-------|----------|--------|---------|
| sales_master | sales_seq | INV | INV0001 |
| service_master | service_seq | SVM | SVM0001 |
| product_order_master | product_order_seq | ORD | ORD0001 |
| product_receive_master | product_receive_seq | RCV | RCV0001 |
| expense_master | expense_seq | EXP | EXP0001 |

### Stock Trigger Reference

| Trigger | When | Effect |
|---------|------|--------|
| trg_stock_on_sales_det | After sales | Stock - quantity |
| trg_stock_on_receive_det | After receive | Stock + quantity |
| trg_stock_on_prod_return_det | After return | Stock - quantity |
| trg_stock_on_damage_det | After damage | Stock - quantity |

---

## ✅ Implementation Checklist

### New Form Setup
- [ ] Create master block from database table
- [ ] Create detail block from database table
- [ ] Configure master-detail relationship
- [ ] Add LOVs for lookup fields
- [ ] Add "New Record" button with trigger
- [ ] Add validation triggers for business rules
- [ ] Add calculation triggers for totals
- [ ] Test insert/update/delete operations
- [ ] Test stock updates (if applicable)
- [ ] Test multi-record scenarios

### Production Deployment
- [ ] Test on development database
- [ ] Verify all triggers functional
- [ ] Check constraint validations
- [ ] Test edge cases (null values, duplicates)
- [ ] User acceptance testing
- [ ] Backup database before deployment
- [ ] Deploy to production
- [ ] Monitor error logs

---

**Last Updated:** January 12, 2026  
**Database:** Oracle 11g+  
**Forms Version:** Oracle Forms 11g+  
**Schema Owner:** msp

