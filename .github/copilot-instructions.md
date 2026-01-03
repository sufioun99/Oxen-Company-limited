# Oxen Company Limited - Copilot Instructions

## Project Overview
This is an **Electronics Sales and Service Provider** database system built on **Oracle Database 11g+** using PL/SQL. The system manages inventory, sales, services, employees, and suppliers for electronics retail operations in Bangladesh.

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

### Test Installation
```sql
-- Verify tables created
SELECT COUNT(*) FROM user_tables;  -- Should return 33

-- Check sample data
SELECT company_id, company_name FROM company;
SELECT product_id, product_name, warranty FROM products WHERE ROWNUM <= 5;
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
- [Schema.sql](Schema.sql): Complete DDL (tables, sequences, triggers) - **2,546 lines**
- [Insert data](Insert%20data): Sample DML for all master tables - **1,318 lines**
- [clean_combined.sql](clean_combined.sql): Single executable script combining both - **3,864 lines**
- [DYNAMIC LIST CRATION](DYNAMIC%20LIST%20CRATION): Oracle Forms trigger code for populating dynamic LOVs (List of Values)

**Note**: Some filenames contain spaces - use quotes when referencing:
```bash
sqlplus msp/msp @"Insert data"
```

### Execution Workflow
Connect to Oracle Database (11g+) and execute scripts:
```bash
# Option 1: All-in-one approach (recommended for fresh setup)
sqlplus sys as sysdba @clean_combined.sql

# Option 2: Separate execution (for schema changes only)
sqlplus sys as sysdba
@Schema.sql
# Then optionally run:
@"Insert data"
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

## Common Troubleshooting

### "Table or view does not exist"
- Ensure you're connected as `msp` user, not `sys`
- Run: `SELECT username FROM user_users;` to verify current user

### "Integrity constraint violated"
- Check foreign key exists: Use subquery lookups instead of hardcoded IDs
- For circular dependencies (employees ↔ departments), use `SET CONSTRAINTS ALL DEFERRED;` before INSERTs

### "Cannot insert NULL into..."
- Triggers auto-populate IDs - don't specify them in INSERT statements
- Audit columns (`status`, `cre_by`, `cre_dt`) are auto-populated

### "Sequence does not exist"
- Run [Schema.sql](Schema.sql) before [Insert data](Insert%20data)
- Sequences are created alongside tables

### Duplicate data on re-run
- Scripts include `DROP USER msp CASCADE;` which removes all existing data
- For incremental changes, comment out the DROP statement
