--========================================================================================
-- ORACLE FORMS 11g - NEW SALES RECORD TRIGGER
-- File: FORMS_NEW_SALES_TRIGGER.sql
-- Purpose: WHEN-BUTTON-PRESSED trigger for creating new sales records in Forms
-- Date: 2026-01-11
-- 
-- OPTIONS PROVIDED:
--   Option A: Database Sequence Control (Recommended - matches current DB design)
--   Option B: Control Table Approach (If you need manual sequence management)
--   Option C: Hybrid Approach (Sequences + optional control table backup)
--========================================================================================

--========================================================================================
-- OPTION A: DATABASE SEQUENCE APPROACH (RECOMMENDED)
-- ✅ Aligns with current clean_combined.sql trigger pattern
-- ✅ Simplest, no additional tables needed
-- ✅ Thread-safe via database sequence mechanism
--========================================================================================

DECLARE
    v_next_invoice_id   VARCHAR2(50);
BEGIN
    -- Clear current form safely
    IF :SYSTEM.FORM_STATUS IN ('CHANGED', 'NEW') THEN
        CLEAR_FORM(NO_VALIDATE);
    ELSE
        CLEAR_FORM;
    END IF;

    -- Go to master block and create new record
    GO_BLOCK('SALES_MASTER');
    CREATE_RECORD;

    -- Get next sequence value from database
    -- The database trigger will auto-generate this, but Forms can show it to user immediately
    SELECT 'INV' || TO_CHAR(sales_seq.NEXTVAL)
      INTO v_next_invoice_id
      FROM DUAL;

    -- Set invoice_id (optional - database trigger will also generate if NULL)
    :SALES_MASTER.invoice_id := v_next_invoice_id;

    -- Default values (matching database trigger defaults)
    :SALES_MASTER.status           := 1;
    :SALES_MASTER.cre_by           := USER;
    :SALES_MASTER.cre_dt           := SYSDATE;
    :SALES_MASTER.invoice_date     := SYSDATE;
    :SALES_MASTER.discount         := 0;
    :SALES_MASTER.vat              := 0;
    :SALES_MASTER.adjust_amount    := 0;
    :SALES_MASTER.grand_total      := 0;

    -- Navigate to detail block if exists and user is ready to add items
    -- GO_BLOCK('SALES_DETAIL');
    -- FIRST_RECORD;

EXCEPTION
    WHEN OTHERS THEN
        MESSAGE('Error creating new sales record: ' || SQLERRM);
        RAISE FORM_TRIGGER_FAILURE;
END;
/

--========================================================================================
-- OPTION B: CONTROL TABLE APPROACH
-- Use if you need manual control or audit trail of invoice number generation
-- ⚠️  Requires additional INV_NUMBER_CONTROL table (see setup below)
-- ⚠️  Requires locking mechanism for multi-user environments
--========================================================================================

-- SETUP (Run once to create control table):
/*
CREATE TABLE inv_number_control (
    last_no         NUMBER,
    last_updated    DATE,
    updated_by      VARCHAR2(100),
    purpose         VARCHAR2(200)
);

INSERT INTO inv_number_control (last_no, last_updated, updated_by, purpose)
VALUES (0, SYSDATE, USER, 'Sales Invoice Number Control');
COMMIT;
*/

-- FORMS TRIGGER (Option B):
DECLARE
    v_max_inv       NUMBER;
    v_last_no       NUMBER;
    v_next_no       NUMBER;
BEGIN
    -- Clear current form safely
    IF :SYSTEM.FORM_STATUS IN ('CHANGED', 'NEW') THEN
        CLEAR_FORM(NO_VALIDATE);
    ELSE
        CLEAR_FORM;
    END IF;

    -- Go to master block and create new record
    GO_BLOCK('SALES_MASTER');
    CREATE_RECORD;

    -- Find max invoice number from existing sales (using REGEXP_LIKE)
    BEGIN
        SELECT NVL(MAX(TO_NUMBER(SUBSTR(invoice_id, 4))), 0)
          INTO v_max_inv
          FROM sales_master
         WHERE REGEXP_LIKE(INVOICE_ID, '^INV[0-9]+$');
    EXCEPTION
        WHEN OTHERS THEN
            v_max_inv := 0;
    END;

    -- Find last controlled number from INV_NUMBER_CONTROL table
    BEGIN
        SELECT NVL(MAX(last_no), 0)
          INTO v_last_no
          FROM inv_number_control;
    EXCEPTION
        WHEN OTHERS THEN
            v_last_no := 0;
    END;

    -- Take highest value and increment
    v_next_no := GREATEST(v_max_inv, v_last_no) + 1;

    -- Update control table (for audit trail)
    BEGIN
        UPDATE inv_number_control
           SET last_no = v_next_no,
               last_updated = SYSDATE,
               updated_by = USER
         WHERE purpose = 'Sales Invoice Number Control';
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;  -- Continue if control table update fails
    END;

    -- Generate invoice_id
    :SALES_MASTER.invoice_id := 'INV' || v_next_no;

    -- Default values
    :SALES_MASTER.status           := 1;
    :SALES_MASTER.cre_by           := USER;
    :SALES_MASTER.cre_dt           := SYSDATE;
    :SALES_MASTER.invoice_date     := SYSDATE;
    :SALES_MASTER.discount         := 0;
    :SALES_MASTER.vat              := 0;
    :SALES_MASTER.adjust_amount    := 0;
    :SALES_MASTER.grand_total      := 0;

EXCEPTION
    WHEN OTHERS THEN
        MESSAGE('Error creating new sales record: ' || SQLERRM);
        RAISE FORM_TRIGGER_FAILURE;
END;
/

--========================================================================================
-- OPTION C: HYBRID APPROACH (RECOMMENDED FOR PRODUCTION)
-- ✅ Uses database sequence as primary (thread-safe)
-- ⚠️  Validates against control table if available (for audit/recovery)
--========================================================================================

DECLARE
    v_next_invoice_id   VARCHAR2(50);
    v_seq_value         NUMBER;
    v_control_value     NUMBER := 0;
BEGIN
    -- Clear current form safely
    IF :SYSTEM.FORM_STATUS IN ('CHANGED', 'NEW') THEN
        CLEAR_FORM(NO_VALIDATE);
    ELSE
        CLEAR_FORM;
    END IF;

    -- Go to master block and create new record
    GO_BLOCK('SALES_MASTER');
    CREATE_RECORD;

    -- Get sequence value (primary method - thread-safe)
    SELECT sales_seq.NEXTVAL
      INTO v_seq_value
      FROM DUAL;

    -- Optionally check control table for sequence management
    BEGIN
        SELECT NVL(MAX(last_no), 0)
          INTO v_control_value
          FROM inv_number_control
         WHERE purpose = 'Sales Invoice Number Control';
    EXCEPTION
        WHEN OTHERS THEN
            v_control_value := 0;  -- Table may not exist
    END;

    -- If control table is ahead, use it instead (for recovery scenarios)
    IF v_control_value >= v_seq_value THEN
        v_seq_value := v_control_value + 1;
    END IF;

    -- Update control table for audit trail (non-critical)
    BEGIN
        UPDATE inv_number_control
           SET last_no = v_seq_value,
               last_updated = SYSDATE,
               updated_by = USER
         WHERE purpose = 'Sales Invoice Number Control';
        
        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO inv_number_control (last_no, last_updated, updated_by, purpose)
            VALUES (v_seq_value, SYSDATE, USER, 'Sales Invoice Number Control');
        END IF;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;  -- Continue - sequence is already assigned
    END;

    -- Generate invoice_id
    v_next_invoice_id := 'INV' || TO_CHAR(v_seq_value);
    :SALES_MASTER.invoice_id := v_next_invoice_id;

    -- Default values
    :SALES_MASTER.status           := 1;
    :SALES_MASTER.cre_by           := USER;
    :SALES_MASTER.cre_dt           := SYSDATE;
    :SALES_MASTER.invoice_date     := SYSDATE;
    :SALES_MASTER.discount         := 0;
    :SALES_MASTER.vat              := 0;
    :SALES_MASTER.adjust_amount    := 0;
    :SALES_MASTER.grand_total      := 0;

    -- Show generated invoice number to user
    MESSAGE('New Invoice: ' || v_next_invoice_id);

EXCEPTION
    WHEN OTHERS THEN
        MESSAGE('Error creating new sales record: ' || SQLERRM);
        RAISE FORM_TRIGGER_FAILURE;
END;
/

--========================================================================================
-- IMPLEMENTATION GUIDANCE
--========================================================================================

/*
STEP 1: COPY ONE OPTION ABOVE
- For most cases, use OPTION A (Database Sequence)
- If you need manual control, use OPTION B or C

STEP 2: ADAPT FOR YOUR FORM STRUCTURE
- Replace 'SALES_MASTER' and 'SALES_DETAIL' with your actual block names
- Adjust field names if different (e.g., :SALES_MASTER.invoice_id)
- Add any additional default values specific to your business logic

STEP 3: ATTACH TO FORM BUTTON
In Oracle Forms Builder:
1. Select your NEW RECORD button
2. Open PL/SQL Editor (right-click > PL/SQL Trigger)
3. Select trigger type: WHEN-BUTTON-PRESSED
4. Paste your chosen option above
5. Compile and save

STEP 4: TEST IN FORMS
- Click button and verify:
  ✓ Form clears properly
  ✓ New invoice_id displays (e.g., INV1, INV2)
  ✓ Default values are set
  ✓ Can navigate to detail block
  ✓ Record can be saved to database

STEP 5: VERIFY DATABASE CONSISTENCY
- Option A: Database trigger will auto-generate if invoice_id is NULL
  (Safe fallback if Forms code doesn't run)
- Option B/C: Keep Forms and database in sync
  (Run: SELECT MAX(TO_NUMBER(SUBSTR(invoice_id,4))) FROM sales_master;)
*/

--========================================================================================
-- KEY DIFFERENCES FROM YOUR PROVIDED CODE
--========================================================================================

/*
1. MATCHES YOUR DATABASE SEQUENCE PATTERN
   Your DB: :NEW.invoice_id := 'INV' || TO_CHAR(sales_seq.NEXTVAL);
   Forms A: Uses same sales_seq for consistency

2. INTEGRATED WITH AUDIT COLUMNS
   - Sets cre_by, cre_dt (auto-set by DB trigger too)
   - Sets status = 1 (matches DB trigger default)

3. SAFE FORM CLEARING
   - Checks FORM_STATUS before clearing
   - Uses NO_VALIDATE to preserve sequence counter

4. ERROR HANDLING
   - EXCEPTION block for robust error reporting
   - FORM_TRIGGER_FAILURE to prevent save if errors occur

5. OPTIONAL CONTROL TABLE
   - Not required (sequences handle it)
   - Available for audit trail if needed
   - Gracefully ignored if table doesn't exist (Option C)
*/
