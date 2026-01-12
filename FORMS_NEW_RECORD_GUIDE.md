# Oracle Forms 11g - New Record Transaction Triggers

## Quick Reference

### When to Use
- **WHEN-BUTTON-PRESSED trigger** on "New Record" button in transaction forms
- **Applies to**: `sales_master`, `product_order_master`, `product_receive_master`, `service_master`, `expense_master`, `sales_return_master`, etc.
- **Purpose**: Initialize transaction header with auto-generated ID and default values matching database triggers

---

## Three Implementation Options

| Option | Approach | Use When | Complexity | File |
|--------|----------|----------|-----------|------|
| **A** | Database Sequence | Using current DB design (✓ RECOMMENDED) | Simple | [FORMS_NEW_SALES_TRIGGER.sql](FORMS_NEW_SALES_TRIGGER.sql) - Option A |
| **B** | Control Table | Need manual number management/audit | Medium | [FORMS_NEW_SALES_TRIGGER.sql](FORMS_NEW_SALES_TRIGGER.sql) - Option B |
| **C** | Hybrid | Production with audit + fallback safety | Medium | [FORMS_NEW_SALES_TRIGGER.sql](FORMS_NEW_SALES_TRIGGER.sql) - Option C |

---

## Implementation Steps

### 1. Choose Your Option
Most users should use **Option A** (Database Sequence):
- Matches current `clean_combined.sql` design
- Thread-safe through Oracle sequences
- Zero additional tables required
- Database trigger provides fallback

### 2. Copy Code to Forms
In **Oracle Forms 11g Builder**:
1. Open form → Go to desired block (e.g., SALES_MASTER)
2. Find your "New Record" button
3. Right-click → PL/SQL Trigger
4. Select **WHEN-BUTTON-PRESSED** trigger type
5. Copy code from [FORMS_NEW_SALES_TRIGGER.sql](FORMS_NEW_SALES_TRIGGER.sql)
6. Paste and adjust block/field names if different
7. Compile (Ctrl+K)

### 3. Verify Consistency

**Database Sequences (all transaction masters)**:
```sql
-- Verify all transaction sequences exist
SELECT sequence_name, min_value, max_value
FROM user_sequences
WHERE sequence_name LIKE '%SEQ'
ORDER BY sequence_name;
```

**Expected sequences** (from clean_combined.sql):
- `sales_seq` → Forms uses `'INV' || sales_seq.NEXTVAL`
- `product_order_seq` → Forms uses `'PO' || product_order_seq.NEXTVAL`
- `product_receive_seq` → Forms uses `'RCV' || product_receive_seq.NEXTVAL`
- `service_seq` → Forms uses `'SVC' || service_seq.NEXTVAL`
- `expense_seq` → Forms uses `'EXP' || expense_seq.NEXTVAL`

---

## Customization by Transaction Type

### Sales Master (sales_master)
```sql
SELECT 'INV' || TO_CHAR(sales_seq.NEXTVAL) INTO v_next_id FROM DUAL;
:SALES_MASTER.invoice_id := v_next_id;
:SALES_MASTER.invoice_date := SYSDATE;
:SALES_MASTER.discount := 0;
:SALES_MASTER.vat := 0;
:SALES_MASTER.grand_total := 0;
```

### Purchase Order (product_order_master)
```sql
SELECT 'PO' || TO_CHAR(product_order_seq.NEXTVAL) INTO v_next_id FROM DUAL;
:PRODUCT_ORDER_MASTER.po_id := v_next_id;
:PRODUCT_ORDER_MASTER.po_date := SYSDATE;
:PRODUCT_ORDER_MASTER.total_amount := 0;
```

### Service Ticket (service_master)
```sql
SELECT 'SVC' || TO_CHAR(service_seq.NEXTVAL) INTO v_next_id FROM DUAL;
:SERVICE_MASTER.service_id := v_next_id;
:SERVICE_MASTER.service_date := SYSDATE;
-- Note: warranty_applicable auto-set by DB trigger if invoice_id provided
```

### Pattern Template (for any transaction)
```sql
-- Get next ID
SELECT '<PREFIX>' || TO_CHAR(<table>_seq.NEXTVAL) INTO v_next_id FROM DUAL;
:<BLOCK>.<pk_column> := v_next_id;

-- Set common defaults
:<BLOCK>.status := 1;
:<BLOCK>.cre_by := USER;
:<BLOCK>.cre_dt := SYSDATE;

-- Set transaction-specific defaults
:<BLOCK>.<amount_column> := 0;
-- ... other defaults
```

---

## Safe Form Clearing

All three options include form clearing logic that checks status:

```sql
-- Safe approach - preserves sequence if form modified but not saved
IF :SYSTEM.FORM_STATUS IN ('CHANGED', 'NEW') THEN
    CLEAR_FORM(NO_VALIDATE);  -- Don't validate, just clear
ELSE
    CLEAR_FORM;                -- Normal clear
END IF;
```

---

## Database Trigger Fallback

**Important**: Your database triggers still generate IDs if Forms doesn't:

From [clean_combined.sql](clean_combined.sql#L681-L686):
```sql
CREATE OR REPLACE TRIGGER trg_sales_master_bi
BEFORE INSERT OR UPDATE ON sales_master FOR EACH ROW
BEGIN
    IF INSERTING AND :NEW.invoice_id IS NULL THEN
        :NEW.invoice_id := 'INV' || TO_CHAR(sales_seq.NEXTVAL);
    END IF;
    -- ... rest of trigger
END;
```

**Result**: Even if Forms code doesn't run, saving a blank record will auto-generate the ID. Forms just makes it visible to the user during entry.

---

## Testing Checklist

- ✓ Click "New Record" button
- ✓ Form clears and displays blank detail block
- ✓ invoice_id (or relevant ID) field shows auto-generated value (e.g., INV1234)
- ✓ Default values appear in amount fields (0.00)
- ✓ Can enter data and navigate to detail block
- ✓ Save record successfully
- ✓ Query shows record with correct ID in database

---

## Troubleshooting

### "PLS-00904: invalid identifier" in Forms
- Verify block name matches your form block exactly
- Verify field names are spelled correctly
- Check that `<block>.<field>` references match your form design

### "sequence does not exist" error
- Ensure [Schema.sql](Schema.sql) or [clean_combined.sql](clean_combined.sql) was executed
- Verify sequence exists: `SELECT * FROM user_sequences WHERE sequence_name = 'SALES_SEQ';`
- Create sequence if missing: `CREATE SEQUENCE sales_seq START WITH 1 INCREMENT BY 1;`

### Button does nothing (no error message)
- Check trigger exists on button: Right-click button → PL/SQL Trigger
- Verify trigger type is WHEN-BUTTON-PRESSED (not KEY-COMMIT, etc.)
- Check for EXCEPTION block - might be silencing errors
- Try removing `RAISE FORM_TRIGGER_FAILURE` temporarily to see actual error

### Invoice numbers have gaps
- Normal if sequences are used (they skip numbers for thread-safety)
- If using Option B/C, check `inv_number_control` table

---

## Multi-Transaction Form Example

If one form has multiple blocks (e.g., SALES and RETURNS):

```sql
-- New Sales Button
GO_BLOCK('SALES_MASTER');
CREATE_RECORD;
SELECT 'INV' || TO_CHAR(sales_seq.NEXTVAL) INTO v_id FROM DUAL;
:SALES_MASTER.invoice_id := v_id;

-- New Return Button (different trigger)
GO_BLOCK('SALES_RETURN_MASTER');
CREATE_RECORD;
SELECT 'RET' || TO_CHAR(sales_return_seq.NEXTVAL) INTO v_id FROM DUAL;
:SALES_RETURN_MASTER.sales_return_id := v_id;
```

---

## Files Reference

| File | Purpose | When Needed |
|------|---------|-------------|
| [FORMS_NEW_SALES_TRIGGER.sql](FORMS_NEW_SALES_TRIGGER.sql) | Three options for new record triggers | Always (reference) |
| [forms_invoice_control_setup.sql](forms_invoice_control_setup.sql) | Optional control table for audit trail | Only if using Option B/C |
| [forms_lov.sql](forms_lov.sql) | LOV queries for dropdowns | Always (in Forms LOVs) |
| [clean_combined.sql](clean_combined.sql) | Database sequences/triggers | Referenced for consistency |

