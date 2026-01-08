# Oxen Company Limited - Copilot Instructions

## Project Overview
This is an **Electronics Sales and Service Provider** database system built on **Oracle Database 11g+** using PL/SQL. The system manages inventory, sales, services, employees, and suppliers for electronics retail operations in Bangladesh. Designed for production use with **Oracle Forms 11g** and **Oracle APEX 5.x+** integration.

## Quick Start

### Setup Database (Choose One)
```bash
# Fresh installation (drops and recreates msp user)
sqlplus sys as sysdba @clean_combined.sql

# Or separate execution
sqlplus sys as sysdba
@Schema.sql      # Creates 33 tables, sequences, triggers
@"Insert data"   # Populates master tables
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
SELECT company_id, company_name FROM company;
SELECT product_id, product_name, warranty FROM products WHERE ROWNUM <= 5;

-- Check automation package (if installed)
SELECT DISTINCT object_name FROM user_procedures WHERE object_type = 'PACKAGE';
```

### Post-Installation (Optional)
```bash
# Install automation package (PL/SQL business logic)
sqlplus msp/msp @automation_pkg.sql

# Install forms LOV queries (for Oracle Forms 11g)
sqlplus msp/msp @forms_lov.sql

# Install APEX views (for Oracle APEX 5.x+)
sqlplus msp/msp @apex_views.sql
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

### Auto-ID Generation Pattern
**Every table uses triggers for auto-ID generation**. Primary key format: `PREFIX + SEQUENCE_NUMBER`
- Sequence naming: `<table>_seq` (e.g., `sales_seq`, `products_seq`)
- Trigger naming: `trg_<table>_bi` (before insert/update)
- ID prefixes are derived from either:
  - First 3 chars of name field (`UPPER(SUBSTR(TRIM(:NEW.field_name), 1, 3))`)
  - Explicit code field if provided
  - Hardcoded prefix (e.g., `'INV'`, `'ORD'`, `'RCV'`)

Example from [Schema.sql](Schema.sql#L616-L632):
```sql
CREATE OR REPLACE TRIGGER trg_sales_master_bi
BEFORE INSERT OR UPDATE ON sales_master FOR EACH ROW
BEGIN
    IF INSERTING AND :NEW.invoice_id IS NULL THEN
        :NEW.invoice_id := 'INV' || TO_CHAR(sales_seq.NEXTVAL);
    END IF;
    -- Audit columns auto-populated
END;
```

### Audit Columns Standard
**Every table includes**: `status`, `cre_by`, `cre_dt`, `upd_by`, `upd_dt`
- Auto-populated by triggers using `USER` and `SYSDATE`
- Default status = `1` (active)

### Computed Columns
Some tables use **virtual generated columns**:
```sql
-- suppliers table (line 272)
due NUMBER GENERATED ALWAYS AS (NVL(purchase_total,0) - NVL(pay_total,0)) VIRTUAL
```
**Important**: Virtual columns cannot be inserted/updated directly; they compute automatically.

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
Service requests check warranty automatically via trigger in [Schema.sql](Schema.sql#L1206-L1225):
- Compares `invoice_date + (warranty_months * 30)` against current date
- Sets `warranty_applicable` to `'Y'` or `'N'`
- Example: 12-month warranty = invoice_date + 360 days

### Stock Management
- Use `CHECK (quantity >= 0)` constraint prevents negative stock
- `last_update` auto-updates to `SYSTIMESTAMP` on any stock change via trigger
- Always verify stock before sales with: `SELECT quantity FROM stock WHERE product_id = ?`

## File Structure & Execution

### Core Files
- [clean_combined.sql](clean_combined.sql): **PRIMARY** - Single executable (~3,900 lines) - creates 33 tables + sequences + triggers + sample data in one run
- [Schema.sql](Schema.sql): DDL only (~2,546 lines) - tables, sequences, triggers (no data)
- [Insert data](Insert%20data): DML only (~1,318 lines) - sample master/transaction data

### Extension Modules (Optional)
- [automation_pkg.sql](automation_pkg.sql): PL/SQL package with business procedures (stock mgmt, sales workflows, service tickets, supplier payments)
- [forms_lov.sql](forms_lov.sql): Oracle Forms 11g List of Values (LOV) queries - dropdown data sources
- [apex_views.sql](apex_views.sql): Oracle APEX 5.x+ ready views (`lov_*`, `dashboard_*`, `*_report_v`)
- [service_form_setup.sql](service_form_setup.sql): Service management form-specific setup
- [validation_checks.sql](validation_checks.sql): Data integrity validation queries

### Utility Files
- [check_data_integrity.sql](check_data_integrity.sql): Run after data insertion to verify referential integrity
- [quick_check.sql](quick_check.sql): Rapid verification of core tables and record counts
- [oracle_reports.sql](oracle_reports.sql): Oracle Reports (RDF) compatible view definitions

**Note**: Some filenames contain spaces - use quotes when referencing:
```bash
sqlplus msp/msp @"Insert data"
sqlplus msp/msp @"DYNAMIC LIST CRATION"
```

### Execution Workflow
```bash
# Recommended: All-in-one approach (fresh setup)
sqlplus sys as sysdba @clean_combined.sql

# Alternative: Schema only (for modifications)
sqlplus sys as sysdba @Schema.sql
sqlplus msp/msp @"Insert data"

# Production: With automation & forms support
sqlplus sys as sysdba @clean_combined.sql
sqlplus msp/msp @automation_pkg.sql
sqlplus msp/msp @forms_lov.sql
sqlplus msp/msp @check_data_integrity.sql  # Verify success
```

**Important**: Scripts automatically drop and recreate the `msp` user. All objects are created in the `msp` schema.

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
Run scripts in this order:
1. Drop user: `DROP USER msp CASCADE;`
2. [Schema.sql](Schema.sql) - Creates structure
3. [Insert data](Insert%20data) - Populates masters
4. Or use [clean_combined.sql](clean_combined.sql) - All-in-one

**Testing tip**: After modifying [Schema.sql](Schema.sql), run it independently before re-running the combined script to catch DDL errors early.

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
1. **LOV Views**: All `lov_*_v` views return `(return_value, display_value)` columns for dropdowns
2. **Dashboard Views**: Query `dashboard_*_v` for pre-aggregated KPIs (sales, stock, supplier due)
3. **Report Views**: Use `*_report_v` views for transaction reports (no manual joins needed)
4. **Example APEX Source**:
   ```sql
   SELECT display_value AS d, return_value AS r
   FROM lov_customers_v
   WHERE status = 1
   ORDER BY d
   ```

### Oracle Forms LOV Setup
Configure LOVs from [forms_lov.sql](forms_lov.sql) queries:
1. Copy LOV query for your control (e.g., PRODUCTS_LOV)
2. Map return columns: First column is `return_value`, second is display
3. Set LOV property "Automatic Skip" based on validation requirements
4. For multi-column LOVs (product + price), map additional columns as non-return values

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
- Run [Schema.sql](Schema.sql) before [Insert data](Insert%20data)
- Sequences are created alongside tables
- If adding new tables, create sequence before trigger

### "ORA-01031: insufficient privileges"
- Running [clean_combined.sql](clean_combined.sql) requires SYSDBA: `sqlplus sys as sysdba`
- For regular user scripts, connect as `msp/msp`
- User must be created first: see [LOCAL_SQL_SETUP_GUIDE.md](LOCAL_SQL_SETUP_GUIDE.md)

### Duplicate data on re-run
- Scripts include `DROP USER msp CASCADE;` which removes all existing data
- For incremental changes, comment out the DROP statement
- Use [check_data_integrity.sql](check_data_integrity.sql) to validate after changes
