--------------------------------------------------------------------------------
-- ANALYSIS: ORDER DETAIL TRIGGER (trg_order_det_bi)
-- File: clean_combined.sql (Lines 997-1005)
-- Purpose: Analyze and improve the product_order_detail trigger
--------------------------------------------------------------------------------

================================================================================
CURRENT TRIGGER
================================================================================

CREATE OR REPLACE TRIGGER trg_order_det_bi 
BEFORE INSERT ON product_order_detail FOR EACH ROW 
BEGIN 
   IF INSERTING AND :NEW.order_detail_id IS NULL THEN
      :NEW.order_detail_id := 'ODT' || TO_CHAR(order_det_seq.NEXTVAL); 
   END IF;
END;
/

================================================================================
ANALYSIS - WHAT IT DOES
================================================================================

✓ CORRECT BEHAVIOR:
  - Automatically generates unique order_detail_id for new detail records
  - Format: 'ODT' prefix + sequence number (e.g., ODT1, ODT2, ODT3)
  - Only triggers on INSERT operation
  - Respects manually-provided order_detail_id if supplied

✓ STRENGTHS:
  - Simple and clean implementation
  - Uses BEFORE INSERT trigger (good for ID generation)
  - Sequence NEXTVAL ensures uniqueness
  - No dependency on parent record


================================================================================
PROBLEM: MISSING ORDER_ID ASSIGNMENT
================================================================================

❌ ISSUE #1: No order_id Assignment

The original trigger shown in the request has this line:
   :NEW.order_id := 'ORD' || TO_CHAR(order_seq.CURRVAL);

This is PROBLEMATIC for several reasons:

1. **CURRVAL vs NEXTVAL Confusion**
   - CURRVAL gets the last value from order_seq sequence
   - But order_seq belongs to product_order_master table
   - product_order_detail should reference existing order_id, not generate new ones

2. **Race Condition Risk**
   - If multiple order masters are inserted concurrently, CURRVAL becomes unreliable
   - The sequence value may not match the actual parent order_id

3. **Hardcoded Prefix Problem**
   - Trigger hardcodes 'ORD' prefix, but parent uses 'ORD' || sequence number
   - This creates ordering confusion

4. **Should Not Generate order_id**
   - Detail records should RECEIVE order_id from parent master, not generate it
   - This is a foreign key relationship

✓ CORRECT APPROACH:

The current trigger in clean_combined.sql (lines 997-1005) is CORRECT:
   - It only generates order_detail_id
   - It does NOT try to generate or modify order_id
   - order_id must be provided by the application when inserting detail records


================================================================================
ISSUE #2: Missing Audit Columns
================================================================================

⚠️  NOTICE: The trigger does NOT populate audit columns

The detail table likely has these columns:
   - status (record status)
   - cre_by (created by)
   - cre_dt (created date)
   - upd_by (updated by)
   - upd_dt (updated date)

Current trigger only sets:
   - order_detail_id (Primary Key)

RECOMMENDATION: Enhance trigger to include audit column population:

```sql
CREATE OR REPLACE TRIGGER trg_order_det_bi 
BEFORE INSERT ON product_order_detail FOR EACH ROW 
BEGIN 
   -- Generate primary key
   IF INSERTING AND :NEW.order_detail_id IS NULL THEN
      :NEW.order_detail_id := 'ODT' || TO_CHAR(order_det_seq.NEXTVAL); 
   END IF;
   
   -- Populate audit columns (if they exist)
   IF INSERTING THEN
      IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
      IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
      IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
   ELSIF UPDATING THEN
      :NEW.upd_by := USER;
      :NEW.upd_dt := SYSDATE;
   END IF;
END;
/
```


================================================================================
HOW TO USE THIS TRIGGER CORRECTLY
================================================================================

1. INSERT PARENT (Order Master):
   
   INSERT INTO product_order_master (supplier_id, order_date, ...)
   VALUES (...);
   -- Trigger auto-generates: order_id = 'ORD1', 'ORD2', etc.

2. GET THE GENERATED ORDER_ID:
   
   SELECT order_id INTO v_order_id
   FROM product_order_master
   WHERE supplier_id = '...'
   ORDER BY cre_dt DESC
   FETCH FIRST 1 ROW ONLY;

3. INSERT CHILD DETAILS:
   
   INSERT INTO product_order_detail (order_id, product_id, quantity, ...)
   VALUES (v_order_id, 'PROD123', 10, ...);
   -- order_detail_id auto-generated: 'ODT1', 'ODT2', etc.
   -- order_id comes from parent


================================================================================
INTEGRATION WITH SERVICE FORMS DYNAMIC LISTS
================================================================================

For Oracle Forms, you need to capture the order_id when inserting:

DECLARE
   v_order_id VARCHAR2(50);
BEGIN
   -- Insert master
   INSERT INTO product_order_master (supplier_id, order_date, ...)
   VALUES (...) RETURNING order_id INTO v_order_id;
   
   -- Insert details with returned order_id
   INSERT INTO product_order_detail (order_id, product_id, ...)
   VALUES (v_order_id, :PRODUCT_DETAILS.PRODUCT_ID, ...);
END;


================================================================================
TESTING THE TRIGGER
================================================================================

Test Script to Verify Trigger Works:

```sql
-- Clear existing data
TRUNCATE TABLE product_order_detail;
TRUNCATE TABLE product_order_master;

-- Insert parent record
INSERT INTO product_order_master (supplier_id, order_date)
VALUES ('SUP1', SYSDATE);

-- Get auto-generated order_id
DECLARE v_order_id VARCHAR2(50);
BEGIN
   SELECT order_id INTO v_order_id
   FROM product_order_master
   WHERE ROWNUM = 1
   ORDER BY cre_dt DESC;
   
   -- Insert first detail
   INSERT INTO product_order_detail (order_id, product_id, quantity)
   VALUES (v_order_id, 'PROD1', 10);
   
   -- Insert second detail
   INSERT INTO product_order_detail (order_id, product_id, quantity)
   VALUES (v_order_id, 'PROD2', 5);
   
   COMMIT;
END;

-- Query results
SELECT * FROM product_order_master;
-- Expected: order_id = 'ORD1'

SELECT * FROM product_order_detail;
-- Expected: order_detail_id = 'ODT1', 'ODT2'
--           order_id = 'ORD1', 'ORD1'
```

Expected Output:
   order_id  | supplier_id | order_date | ...
   ORD1      | SUP1        | 04-JAN-26  | ...

   order_detail_id | order_id | product_id | quantity
   ODT1            | ORD1     | PROD1      | 10
   ODT2            | ORD1     | PROD2      | 5


================================================================================
COMPARISON WITH OTHER DETAIL TRIGGERS
================================================================================

Sales Detail Trigger (trg_sales_det_bi):
   - Only generates sales_det_id
   - Does NOT modify invoice_id
   - Pattern: Detail receives FK from parent

Product Receive Detail Trigger (trg_prod_recv_det_bi):
   - Only generates receive_det_id
   - Does NOT modify receive_id
   - Pattern: Detail receives FK from parent

Service Detail Trigger (trg_service_det_bi):
   - Only generates service_det_id
   - Does NOT modify service_id
   - Pattern: Detail receives FK from parent via RETURNING clause

ORDER DETAIL follows this same CORRECT pattern ✓


================================================================================
RECOMMENDATION: ENHANCED TRIGGER VERSION
================================================================================

Replace the current trigger with this improved version:

```sql
CREATE OR REPLACE TRIGGER trg_order_det_bi 
BEFORE INSERT OR UPDATE ON product_order_detail 
FOR EACH ROW 
BEGIN
   -- Generate primary key on INSERT only
   IF INSERTING AND :NEW.order_detail_id IS NULL THEN
      :NEW.order_detail_id := 'ODT' || TO_CHAR(order_det_seq.NEXTVAL); 
   END IF;
   
   -- Validate foreign key
   IF :NEW.order_id IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'order_id is required for order detail');
   END IF;
   
   -- Populate audit columns
   IF INSERTING THEN
      IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
      IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
      IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
   ELSIF UPDATING THEN
      :NEW.upd_by := USER;
      :NEW.upd_dt := SYSDATE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, 'Trigger error: ' || SQLERRM);
END;
/
```

This improved version:
   ✓ Generates order_detail_id (PK)
   ✓ Validates order_id (FK) is provided
   ✓ Handles UPDATE operations
   ✓ Populates audit columns
   ✓ Includes error handling
   ✓ Prevents orphan records


================================================================================
SUMMARY
================================================================================

CURRENT TRIGGER:        ✓ CORRECT
   - Only generates order_detail_id
   - Properly uses sequence NEXTVAL
   - Does NOT interfere with order_id FK
   - Follows detail table pattern

POTENTIAL ISSUE:        ⚠️  INCOMPLETE
   - Missing audit column population
   - No validation of required order_id
   - No UPDATE operation handling

RECOMMENDATION:         ✓ IMPLEMENT ENHANCED VERSION
   - Add audit column population
   - Add FK validation
   - Add UPDATE handling
   - Add error handling
   - Ensure consistency with other detail triggers


================================================================================
