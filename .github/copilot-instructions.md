# Oxen Company Limited - Copilot Instructions

## Project Overview
This is an **Electronics Sales and Service Provider** database system built on **Oracle Database 11g+** using PL/SQL. The system manages inventory, sales, services, employees, and suppliers for electronics retail operations in Bangladesh. Designed for production use with **Oracle Forms 11g** and **Oracle APEX 5.x+** integration.

## Quick Start

### Prerequisites
**User Creation (One-time, requires SYSDBA)**:
```sql
-- Connect as SYSDBA first
sqlplus sys as sysdba

CREATE USER msp IDENTIFIED BY msp 
DEFAULT TABLESPACE users 
QUOTA UNLIMITED ON users;
GRANT CONNECT, RESOURCE TO msp;
```
See [LOCAL_SQL_SETUP_GUIDE.md](LOCAL_SQL_SETUP_GUIDE.md) for detailed setup if errors occur.

### Setup Database
```bash
# Fresh installation with all-in-one script (ONLY option available)
sqlplus sys as sysdba @clean_combined.sql
# This script creates 33 tables + sequences + triggers + sample data in one run
# Note: Schema.sql and "Insert data" files are referenced in guides but do NOT exist
# All functionality is consolidated in clean_combined.sql
```

### Connect as Application User
```sql
sqlplus msp/msp
```

### Verify Installation
```sql
-- Check tables created
SELECT COUNT(*) FROM user_tables;  -- Should return 33

-- Check sample data
SELECT company_id, company_name FROM company ROWNUM <= 2;
SELECT COUNT(*) as product_count FROM products;

-- Quick integrity check
@check_data_integrity.sql

-- Check automation package (if installed)
SELECT DISTINCT object_name FROM user_procedures WHERE object_type = 'PACKAGE';
```

### Post-Installation (Optional)
```bash
# Install automation package (PL/SQL business logic)
sqlplus msp/msp @automation_pkg.sql

# Install forms LOV queries (for Oracle Forms 11g)
sqlplus msp/msp @forms_lov.sql

# Note: apex_views.sql does NOT exist in this repository
# APEX integration is mentioned in docs but views are not yet implemented
```

## Architecture & Structure

### Core Entity Groups (33 Tables)
1. **Infrastructure**: `company`, `jobs`, `departments`, `employees`
2. **Product Management**: `product_categories`, `sub_categories`, `brand`, `products`, `parts_category`, `parts`
3. **Supply Chain**: `suppliers`, `product_order_master`, `product_order_detail`, `product_receive_master`, `product_receive_details`, `product_return_master`, `product_return_details`
4. **Sales Operations**: `customers`, `sales_master`, `sales_detail`, `sales_return_master`, `sales_return_details`
5. **Service Management**: `service_list`, `service_master`, `service_details`
6. **Financial**: `expense_list`, `expense_master`, `expense_details`, `payments`
7. **Inventory**: `stock`, `damage`, `damage_detail`
8. **Users**: `com_users`

### Master-Detail Pattern
Every transactional entity follows a **master-detail pattern**:
- Master tables: Hold header-level information (invoice, order, service ID, dates, totals)
- Detail tables: Hold line-item information (products, quantities, prices)
- Example pairs: `sales_master` ↔ `sales_detail`, `product_order_master` ↔ `product_order_detail`

**Example query joining master-detail**:
```sql
-- Get complete sales transaction
SELECT 
    m.invoice_id, m.invoice_date, m.grand_total,
    c.customer_name, c.phone_no,
    d.product_id, p.product_name, d.quantity, d.unit_price, d.total
FROM sales_master m
JOIN sales_detail d ON m.invoice_id = d.invoice_id
JOIN customers c ON m.customer_id = c.customer_id
JOIN products p ON d.product_id = p.product_id
WHERE m.status = 1
ORDER BY m.invoice_date DESC;
```

## Critical Database Conventions

### Trigger Design Pattern - CRITICAL for Data Integrity
**NEVER create multiple triggers of the same type on the same table** (e.g., two BEFORE INSERT triggers on `service_details`). This causes **ORA-40508** in Oracle 11g.

**Correct approach**: Combine all BEFORE INSERT logic into ONE trigger:
```sql
-- ✅ CORRECT: Single trigger with multiple responsibilities
CREATE OR REPLACE TRIGGER trg_service_det_bi
BEFORE INSERT ON service_details FOR EACH ROW
BEGIN
    -- Generate ID
    IF :NEW.service_det_id IS NULL THEN
        :NEW.service_det_id := 'SDT' || TO_CHAR(service_det_seq.NEXTVAL);
    END IF;
    
    -- Audit columns
    IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
    IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
    IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
END;
/

-- ❌ WRONG: Multiple BEFORE INSERT triggers
-- This will cause ORA-40508 when insert occurs
CREATE OR REPLACE TRIGGER trg_service_det_bi ...  -- First trigger
CREATE OR REPLACE TRIGGER trg_service_det_line_no_bi ...  -- Second trigger - CONFLICT!
```

**IMPORTANT**: `line_no` columns were removed from all detail tables (Jan 2026) for Oracle Forms compatibility. Do NOT add line_no auto-generation triggers.

### Auto-ID Generation Pattern
**Every table uses triggers for auto-ID generation**. Primary key format: `PREFIX + SEQUENCE_NUMBER`
- Sequence naming: `<table>_seq` (e.g., `sales_seq`, `products_seq`)
- Trigger naming: `trg_<table>_bi` (before insert/update)
- ID prefixes are derived from either:
  - First 3 chars of name field (`UPPER(SUBSTR(TRIM(:NEW.field_name), 1, 3))`)
  - Explicit code field if provided
  - Hardcoded prefix (e.g., `'INV'`, `'ORD'`, `'RCV'`)

Example from [clean_combined.sql](clean_combined.sql) (line 683):
```sql
CREATE OR REPLACE TRIGGER trg_sales_master_bi
BEFORE INSERT OR UPDATE ON sales_master FOR EACH ROW
BEGIN
    IF INSERTING AND :NEW.invoice_id IS NULL THEN
        :NEW.invoice_id := 'INV' || TO_CHAR(sales_seq.NEXTVAL);
    END IF;
    -- Audit columns auto-populated
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER; :NEW.upd_dt := SYSDATE;
    END IF;
END;
/
```

### Audit Columns Standard
**Every table includes**: `status`, `cre_by`, `cre_dt`, `upd_by`, `upd_dt`
- Auto-populated by triggers using `USER` and `SYSDATE`
- Default status = `1` (active)

### Computed Columns
Some tables use **virtual generated columns** (auto-calculated, cannot be inserted/updated):
```sql
-- suppliers table (clean_combined.sql line ~313)
due NUMBER GENERATED ALWAYS AS (NVL(purchase_total,0) - NVL(pay_total,0)) VIRTUAL
```
**Important**: Virtual columns cannot be inserted/updated directly; they compute automatically from other columns.

### Deferred Constraints
Employee-Department circular references use **deferred constraints**:
```sql
ALTER TABLE employees ADD CONSTRAINT fk_emp_mgr 
FOREIGN KEY (manager_id) REFERENCES employees(employee_id) 
DEFERRABLE INITIALLY DEFERRED;
```
This allows inserting parent-child rows in the same transaction without FK violations.

## Data Insertion Patterns

### Always Use Dynamic FK Lookups
**Never hardcode IDs** in INSERT statements. Use subqueries:
```sql
INSERT INTO products (product_name, supplier_id, category_id, ...)
VALUES ('Samsung TV', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'LED Television'),
    ...
);
```

### Warranty Logic
Service requests check warranty automatically via triggers in [clean_combined.sql](clean_combined.sql):
- Compares `invoice_date + (warranty_months * 30)` against current date
- Sets `warranty_applicable` to `'Y'` or `'N'`
- Example: 12-month warranty = invoice_date + 360 days
- **Important**: When linking service to sales, ensure `invoice_id` exists in `sales_master` with valid `invoice_date`, or trigger will fail
- **Multi-product invoices**: See [SERVICE_FORM_COMPLETE_GUIDE.md](SERVICE_FORM_COMPLETE_GUIDE.md) for handling different warranty periods per product

### Stock Management (AUTOMATED - Active since Jan 2026)
**Stock updates are FULLY AUTOMATED** via AFTER triggers - no manual SQL needed:

1. **trg_stock_on_sales_det**: Auto-deducts stock on INSERT into `sales_detail`
2. **trg_stock_on_receive_det**: Auto-adds stock on INSERT into `product_receive_details`
3. **trg_validate_receive_direct**: Validates products were ordered before receiving
4. **trg_stock_on_prod_return_det**: Deducts stock when returning to supplier
5. **trg_stock_on_damage_det**: Writes off damaged stock automatically

**Key points**:
- Use `CHECK (quantity >= 0)` constraint prevents negative stock
- `last_update` auto-updates to `SYSTIMESTAMP` on any stock change
- INSERT/UPDATE/DELETE on detail tables triggers stock changes automatically
- No need to write manual `UPDATE stock` statements in forms or applications

## File Structure & Execution

### Core Files (Database)
- [clean_combined.sql](clean_combined.sql): **PRIMARY INSTALLATION FILE** - ~3,717 lines - creates 33 tables + sequences + 50+ triggers + sample data
- [automation_pkg.sql](automation_pkg.sql): PL/SQL package `pkg_oxen_automation` - 933 lines - business logic procedures for stock, sales, service

### Oracle Forms Integration Files
- [forms_lov.sql](forms_lov.sql): Oracle Forms 11g List of Values (LOV) queries - pre-built dropdown data sources
- [FORMS_NEW_SALES_TRIGGER.sql](FORMS_NEW_SALES_TRIGGER.sql): WHEN-BUTTON-PRESSED triggers for new transaction records (3 implementation options)
- [forms_invoice_control_setup.sql](forms_invoice_control_setup.sql): Optional control table for manual invoice number management
- [service_form_setup.sql](service_form_setup.sql): Service management form-specific setup
- [service_form_upgrade.sql](service_form_upgrade.sql): Service form enhancements and modifications

### Comprehensive Implementation Guides (Markdown)
- [FORMS_INTEGRATION_COMPLETE_GUIDE.md](FORMS_INTEGRATION_COMPLETE_GUIDE.md): 530 lines - Oracle Forms compatibility, multi-product patterns, LOV setup
- [FORMS_NEW_RECORD_GUIDE.md](FORMS_NEW_RECORD_GUIDE.md): Step-by-step guide for implementing new record triggers in forms
- [FORMS_LOV_QUICK_GUIDE.md](FORMS_LOV_QUICK_GUIDE.md): Quick reference for LOV implementation patterns
- [SERVICE_FORM_COMPLETE_GUIDE.md](SERVICE_FORM_COMPLETE_GUIDE.md): 1,616 lines - Multi-product service form implementation with visual layouts
- [SERVICE_FORM_VISUAL_REFERENCE.md](SERVICE_FORM_VISUAL_REFERENCE.md): Visual diagrams and form layouts for service management
- [SERVICE_DESIGN_CORRECTED.md](SERVICE_DESIGN_CORRECTED.md): Service module design patterns and corrections
- [SERVICE_TABLES_REFERENCE.md](SERVICE_TABLES_REFERENCE.md): Service table structure and relationships reference

### Database Documentation
- [complete_trigger_documentations](complete_trigger_documentations): HTML file (1,637 lines) - complete documentation of all 50+ triggers with naming conventions, categories, and usage patterns
- [DATABASE_CHANGES_LOG.md](DATABASE_CHANGES_LOG.md): 194 lines - tracks schema changes, trigger activations, modifications (critical for understanding evolution)
- [LOCAL_SQL_SETUP_GUIDE.md](LOCAL_SQL_SETUP_GUIDE.md): Step-by-step Oracle Database setup and troubleshooting

### Testing & Validation Files
- [check_data_integrity.sql](check_data_integrity.sql): Verify referential integrity after data insertion
- [quick_check.sql](quick_check.sql): Rapid verification of core tables and record counts
- [validation_checks.sql](validation_checks.sql): Comprehensive data integrity validation queries
- [FORMS_TEST_QUERIES.sql](FORMS_TEST_QUERIES.sql): Test queries for validating forms functionality

### Oracle Reports Integration
- [oracle_reports.sql](oracle_reports.sql): Oracle Reports (RDF) compatible view definitions

**Missing Files** (referenced in guides but do NOT exist):
- `Schema.sql` - consolidated into clean_combined.sql
- `Insert data` - consolidated into clean_combined.sql
- `apex_views.sql` - APEX integration not yet implemented
- `DYNAMIC LIST CRATION` - referenced but missing

### Execution Workflow
```bash
# Fresh installation (ONLY option - drops and recreates msp user)
sqlplus sys as sysdba @clean_combined.sql

# Verify installation
sqlplus msp/msp @check_data_integrity.sql
sqlplus msp/msp @quick_check.sql

# Production: Add automation & forms support
sqlplus msp/msp @automation_pkg.sql
sqlplus msp/msp @forms_lov.sql
sqlplus msp/msp @service_form_setup.sql  # If using service forms
```

**Important**: `clean_combined.sql` automatically drops and recreates the `msp` user, deleting ALL existing data. For incremental changes, extract relevant sections from the script or comment out the `DROP USER msp CASCADE;` line (line 9).

## Development Guidelines

### Adding New Transactions
1. Create master table with `_master` suffix
2. Create detail table with `_detail(s)` suffix (note: inconsistent pluralization exists in codebase)
3. Add sequence: `<table>_seq`
4. Create before insert/update trigger following existing patterns
5. Include all standard audit columns
6. Add FK constraints using `CONSTRAINT fk_<abbrev>` naming convention

**Template for new master-detail pair**:
```sql
-- Master table
CREATE TABLE my_transaction_master (
    trans_id VARCHAR2(50) PRIMARY KEY,
    trans_date DATE DEFAULT SYSDATE,
    total_amount NUMBER(20,4) DEFAULT 0,
    -- Standard audit columns
    status NUMBER,
    cre_by VARCHAR2(100),
    cre_dt DATE,
    upd_by VARCHAR2(100),
    upd_dt DATE
);

CREATE SEQUENCE my_trans_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_my_trans_bi
BEFORE INSERT OR UPDATE ON my_transaction_master FOR EACH ROW
BEGIN
    IF INSERTING AND :NEW.trans_id IS NULL THEN
        :NEW.trans_id := 'TXN' || TO_CHAR(my_trans_seq.NEXTVAL);
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        IF :NEW.upd_by IS NULL THEN :NEW.upd_by := USER; END IF;
        IF :NEW.upd_dt IS NULL THEN :NEW.upd_dt := SYSDATE; END IF;
    END IF;
END;
/
```

### Constraint Naming Standards
- Primary keys: `<table>(<column>)` (Oracle default or explicit)
- Foreign keys: `CONSTRAINT fk_<table_abbrev>_<ref_table_abbrev>` (e.g., `fk_emp_dept`, `fk_p_sup`)
- Check constraints: `CONSTRAINT chk_<table>_<column>` (e.g., `chk_job_grade`)
- Unique constraints: `UNIQUE` keyword on column definition

### Modifying Schema
- Check for circular dependencies (employees ↔ departments)
- Update corresponding detail tables when changing master
- Maintain trigger consistency for audit columns
- Use `DEFERRABLE INITIALLY DEFERRED` for circular FKs

### Querying Data
- Always join master-detail tables to get complete transaction views
- Use `ROWNUM = 1` when expecting single row from subquery (e.g., FK lookups)
- Check `status = 1` for active records
- Remember virtual columns cannot be inserted/updated directly

### Testing Database Scripts
```bash
# Full reset (use this for testing schema changes)
sqlplus sys as sysdba @clean_combined.sql

# Verify with integrity checks
sqlplus msp/msp @check_data_integrity.sql
sqlplus msp/msp @validation_checks.sql

# Test specific forms functionality
sqlplus msp/msp @FORMS_TEST_QUERIES.sql
```

**Testing tip**: To test individual schema changes without full reset:
1. Extract relevant CREATE TABLE and trigger sections from clean_combined.sql
2. Test DDL changes in isolation: `sqlplus msp/msp @your_test_changes.sql`
3. Run `check_data_integrity.sql` to verify no broken references
4. Once validated, merge changes back into clean_combined.sql

### Oracle Database Connection
**Default user**: `msp` / `msp`
- Tablespace: `users` (unlimited quota)
- Temp tablespace: `temp`
- Privileges: `CONNECT`, `RESOURCE`

**Connection strings**:
```sql
-- As system admin (for setup)
sqlplus sys as sysdba

-- As application user (for queries)
sqlplus msp/msp
```

## Business Context
The system models a **Bangladesh electronics retail chain** dealing with brands like Walton, Samsung, LG, Singer, Vision, Minister, Sharp, Hitachi. Phone numbers follow Bangladesh format (`017xx`, `018xx`). Addresses reference Dhaka divisions (Mirpur, Dhanmondi, Uttara, etc.).

## Oracle Forms Integration

### Dynamic List of Values (LOV) Setup
[DYNAMIC LIST CRATION](DYNAMIC%20LIST%20CRATION) shows Oracle Forms `WHEN-NEW-FORM-INSTANCE` trigger pattern:
- Creates record groups dynamically from queries
- Populates list items (dropdowns) for products, suppliers, employees
- Uses `Populate_List()` and `Populate_Group()` built-ins

**Example pattern**:
```sql
-- Create dynamic LOV for products
rg_products := Create_Group_From_Query(
    'RG_PRODUCTS',
    'SELECT product_name, TO_CHAR(product_id)
     FROM products
     ORDER BY product_name'
);
nDummy := Populate_Group(rg_products);
Populate_List('PRODUCT_receive_DETAILS.PRODUCT_ID', rg_products);
```

### New Record Transaction Trigger (Master Tables)
Use [FORMS_NEW_SALES_TRIGGER.sql](FORMS_NEW_SALES_TRIGGER.sql) pattern for creating new transaction records:
- **Option A (Recommended)**: Database sequence approach - aligns with `sales_seq`, `product_order_seq` patterns
- **Option B**: Control table approach - if manual number management required
- **Option C (Production)**: Hybrid - sequences + optional audit trail

**Example for SALES_MASTER WHEN-BUTTON-PRESSED**:
```sql
DECLARE
    v_next_invoice_id VARCHAR2(50);
BEGIN
    -- Clear form and initialize new record
    IF :SYSTEM.FORM_STATUS IN ('CHANGED', 'NEW') THEN
        CLEAR_FORM(NO_VALIDATE);
    ELSE
        CLEAR_FORM;
    END IF;
    
    GO_BLOCK('SALES_MASTER');
    CREATE_RECORD;
    
    -- Get next sequence and set defaults (matches DB trigger)
    SELECT 'INV' || TO_CHAR(sales_seq.NEXTVAL) INTO v_next_invoice_id FROM DUAL;
    :SALES_MASTER.invoice_id := v_next_invoice_id;
    :SALES_MASTER.status := 1;
    :SALES_MASTER.cre_by := USER;
    :SALES_MASTER.cre_dt := SYSDATE;
    :SALES_MASTER.discount := 0;
    :SALES_MASTER.vat := 0;
    :SALES_MASTER.grand_total := 0;
    
EXCEPTION
    WHEN OTHERS THEN
        MESSAGE('Error: ' || SQLERRM);
        RAISE FORM_TRIGGER_FAILURE;
END;
```

**Apply same pattern to other transaction masters**: `product_order_master`, `product_receive_master`, `service_master`, `expense_master` - each uses its own `*_seq` sequence.

For detailed implementation steps, customizations, and multi-block form examples, see [FORMS_NEW_RECORD_GUIDE.md](FORMS_NEW_RECORD_GUIDE.md).

## Development Workflows

### Adding New Transaction Tables
When creating new master-detail pairs (e.g., quotations, RFQs):
```sql
-- 1. Create master table with auto-ID trigger
CREATE TABLE quotation_master (
    quotation_id VARCHAR2(50) PRIMARY KEY,
    quotation_date DATE DEFAULT SYSDATE,
    customer_id VARCHAR2(50) NOT NULL,
    total_amount NUMBER(20,4),
    status NUMBER DEFAULT 1,
    cre_by VARCHAR2(100), cre_dt DATE,
    upd_by VARCHAR2(100), upd_dt DATE,
    CONSTRAINT fk_quot_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 2. Add sequence and trigger (following existing pattern)
CREATE SEQUENCE quotation_seq;
CREATE OR REPLACE TRIGGER trg_quotation_master_bi
BEFORE INSERT OR UPDATE ON quotation_master FOR EACH ROW
BEGIN
    IF INSERTING AND :NEW.quotation_id IS NULL THEN
        :NEW.quotation_id := 'QT' || TO_CHAR(quotation_seq.NEXTVAL);
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER; :NEW.upd_dt := SYSDATE;
    END IF;
END;
/
```

### Extending Automation Package
The `pkg_oxen_automation` package provides reusable business logic. Add new procedures following this pattern:
```sql
PROCEDURE your_procedure_name(
    p_param1 IN VARCHAR2,
    p_param2 IN NUMBER,
    p_result OUT VARCHAR2
) AS
    v_id VARCHAR2(50);
BEGIN
    -- Implementation
    p_result := 'Success: ' || v_id;
EXCEPTION
    WHEN OTHERS THEN
        p_result := 'Error: ' || SQLERRM;
END your_procedure_name;
```

### Oracle APEX Integration Workflow
**Note**: APEX views (`apex_views.sql`) are referenced in documentation but NOT YET IMPLEMENTED in this repository.

When implementing APEX views, follow this pattern:
1. **LOV Views**: Create `lov_*_v` views returning `(return_value, display_value)` columns for dropdowns
2. **Dashboard Views**: Create `dashboard_*_v` for pre-aggregated KPIs (sales, stock, supplier due)
3. **Report Views**: Create `*_report_v` views for transaction reports (pre-joined master-detail tables)
4. **Example APEX LOV Source**:
   ```sql
   -- Create view first (doesn't exist yet)
   CREATE OR REPLACE VIEW lov_customers_v AS
   SELECT customer_id AS return_value,
          customer_name || ' (' || phone_no || ')' AS display_value,
          status
   FROM customers
   WHERE status = 1;
   
   -- Then use in APEX
   SELECT display_value AS d, return_value AS r
   FROM lov_customers_v
   ORDER BY d;
   ```

### Oracle Forms LOV Setup
Configure LOVs from [forms_lov.sql](forms_lov.sql) queries:
1. Copy LOV query for your control (e.g., PRODUCTS_LOV)
2. Map return columns: First column is `return_value`, second is display
3. Set LOV property "Automatic Skip" based on validation requirements
4. For multi-column LOVs (product + price), map additional columns as non-return values

**Comprehensive guides available**:
- [FORMS_LOV_QUICK_GUIDE.md](FORMS_LOV_QUICK_GUIDE.md): Quick reference for LOV patterns
- [FORMS_INTEGRATION_COMPLETE_GUIDE.md](FORMS_INTEGRATION_COMPLETE_GUIDE.md): Complete forms integration patterns
- [SERVICE_FORM_COMPLETE_GUIDE.md](SERVICE_FORM_COMPLETE_GUIDE.md): Service-specific LOV implementations with multi-product support

## Common Troubleshooting

### "Table or view does not exist"
- Ensure you're connected as `msp` user, not `sys`
- Run: `SELECT username FROM user_users;` to verify current user
- If using APEX views, ensure [apex_views.sql](apex_views.sql) has been executed

### "Integrity constraint violated"
- Check foreign key exists: Use subquery lookups instead of hardcoded IDs
- For circular dependencies (employees ↔ departments), use `SET CONSTRAINTS ALL DEFERRED;` before INSERTs
- Verify `status = 1` for all referenced records

### "Cannot insert NULL into..."
- Triggers auto-populate IDs - don't specify them in INSERT statements
- Audit columns (`status`, `cre_by`, `cre_dt`) are auto-populated
- Ensure all NOT NULL columns have values or defaults

### "Sequence does not exist"
- Ensure [clean_combined.sql](clean_combined.sql) ran successfully (sequences created with tables)
- Check sequence exists: `SELECT sequence_name FROM user_sequences WHERE sequence_name LIKE '%_SEQ';`
- If adding new tables, create sequence before trigger following pattern: `CREATE SEQUENCE <table>_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;`

### "ORA-01031: insufficient privileges"
- Running [clean_combined.sql](clean_combined.sql) requires SYSDBA: `sqlplus sys as sysdba`
- Script creates the `msp` user automatically (lines 9-19), so no pre-creation needed
- For other scripts (automation_pkg.sql, forms_lov.sql), connect as `msp/msp`
- If manual user creation needed, see [LOCAL_SQL_SETUP_GUIDE.md](LOCAL_SQL_SETUP_GUIDE.md)

### Duplicate data on re-run
- Scripts include `DROP USER msp CASCADE;` which removes all existing data
- For incremental changes, comment out the DROP statement
- Use [check_data_integrity.sql](check_data_integrity.sql) to validate after changes
