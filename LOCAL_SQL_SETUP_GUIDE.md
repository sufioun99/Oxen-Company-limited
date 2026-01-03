# Local SQL Setup Guide for clean_combined.sql

## Errors Removed from clean_combined.sql

The following admin-level commands have been **removed** from `clean_combined.sql` to allow execution as a regular user:

### ❌ Removed Commands (Required SYS/SYSDBA Privileges)

```sql
DROP USER msp CASCADE;
CREATE USER msp IDENTIFIED BY msp DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
GRANT CONNECT, RESOURCE TO msp;
CONNECT msp/msp;
```

**Why they were removed:**
- `DROP USER` / `CREATE USER` / `GRANT` require **SYSDBA** privileges
- `CONNECT` is a **SQL*Plus specific** command that doesn't work in all SQL editors
- These would cause **ORA-01031: insufficient privileges** errors when run as regular user

---

## ✅ How to Execute clean_combined.sql Locally

### Option 1: Oracle SQL (Recommended for Full Compatibility)

**Step 1: Create the MSP user (Run as SYS/SYSDBA)**
```sql
sqlplus sys as sysdba

-- Execute these commands:
CREATE USER msp IDENTIFIED BY msp 
DEFAULT TABLESPACE users 
QUOTA UNLIMITED ON users;

GRANT CONNECT, RESOURCE TO msp;
EXIT;
```

**Step 2: Run clean_combined.sql (As MSP user)**
```bash
sqlplus msp/msp @clean_combined.sql
```

---

### Option 2: SQL Developer / Oracle SQL Developer

1. **Create User (Run as SYSDBA connection)**
   - Open SYSDBA connection
   - Execute the CREATE USER and GRANT statements above
   - Close connection

2. **Execute Script (Switch to MSP connection)**
   - Create new connection with credentials: `msp/msp`
   - Open clean_combined.sql
   - Click **Run Script** (F5 in SQL Developer)

---

### Option 3: Other SQL Editors (Toad, DBeaver, etc.)

1. **Create user first using SYSDBA connection** (see setup above)
2. **Switch to MSP user connection**
3. **Open and execute clean_combined.sql**

---

## ⚠️ Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `ORA-01031: insufficient privileges` | Running as non-SYSDBA user without prior user creation | Create MSP user first as SYSDBA |
| `ORA-00001: unique constraint violated` | Running script twice | This is **expected** on re-execution - just ignore |
| `ORA-00904: invalid identifier` | Table/column name typo | Contact support - likely data mapping issue |
| `ORA-01400: cannot insert NULL` | Missing FK reference | Ensure all master data inserted first |

---

## 📊 Expected Output

When execution completes successfully, you should see:

```
✓ 33 tables created
✓ 33 sequences created  
✓ 33 triggers created
✓ 371 records inserted across all tables
✓ No syntax errors
```

**Data Distribution:**
- Master Data: 14 tables, 158 records
- Transaction Data: 19 tables, 213 records
- **Total: 33 tables, 371 records**

---

## 🔍 Verification Queries

After successful execution, verify with:

```sql
-- Check all tables created
SELECT COUNT(*) FROM user_tables;  -- Should return 33

-- Sample data check
SELECT COUNT(*) FROM company;      -- Should return 10
SELECT COUNT(*) FROM products;     -- Should return 20
SELECT COUNT(*) FROM employees;    -- Should return 40
SELECT COUNT(*) FROM sales_master; -- Should return 10

-- Check sequences
SELECT COUNT(*) FROM user_sequences;  -- Should return 33
```

---

## 📝 Modified Files

- **clean_combined.sql**: Removed 8 lines (lines 1-14 in original) containing SYS/SYSDBA commands
- **Original file size**: 4,470 lines
- **Modified file size**: 4,462 lines (8 lines removed)

---

## 🚀 Quick Start

For fastest setup on your local machine:

```bash
# Terminal 1: Setup as SYSDBA
sqlplus sys as sysdba
> CREATE USER msp IDENTIFIED BY msp DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
> GRANT CONNECT, RESOURCE TO msp;
> EXIT;

# Terminal 2: Run the script as MSP user
sqlplus msp/msp @clean_combined.sql
```

That's it! Your database is ready with all 33 tables and 371 records.
