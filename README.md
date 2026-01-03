# Oxen Company Limited - Database

Electronics sales and service provider company database for Bangladesh market.

## Quick Start

### Database Setup

Choose one of these options:

**Option 1: All-in-one script (Recommended)**
```bash
sqlplus sys as sysdba @clean_combined.sql
```

**Option 2: Separate execution**
```bash
sqlplus sys as sysdba @Schema.sql
sqlplus msp/msp @"Insert data"
```

### Connect to Database
```bash
sqlplus msp/msp
```

### Verify Installation
```sql
SELECT COUNT(*) as table_count FROM user_tables;  -- Should return 33
SELECT * FROM company;
SELECT * FROM products WHERE ROWNUM <= 5;
```

## File Structure

| File | Purpose |
|------|---------|
| **Schema.sql** | Complete database schema (33 tables, triggers, sequences) |
| **Insert data** | Sample master data for testing |
| **clean_combined.sql** | All-in-one script (Schema + Insert data combined) |
| **DYNAMIC LIST CRATION** | Oracle Forms integration code for dynamic lists |
| **.github/copilot-instructions.md** | AI agent guidance for development |

## Database Details

- **DBMS**: Oracle Database 11g+
- **Scope**: 33 tables with master-detail patterns
- **User**: msp / msp
- **Tablespace**: users (unlimited quota)

## Key Features

✅ Auto-ID generation via triggers  
✅ Audit columns (status, cre_by, cre_dt, upd_by, upd_dt)  
✅ Virtual computed columns  
✅ Deferred constraints for circular relationships  
✅ Dynamic FK lookups with ROWNUM protection  

## Architecture

### Master-Detail Pattern
Every transaction (sales, orders, services) follows:
- **Master table**: Header information (invoice ID, date, total)
- **Detail table**: Line items (products, quantities, prices)

### Entity Groups
1. **Infrastructure**: company, jobs, departments, employees
2. **Products**: product_categories, sub_categories, brand, products, parts
3. **Supply Chain**: suppliers, product_order_master/detail, product_receive_master/detail
4. **Sales**: customers, sales_master/detail, sales_return_master/detail
5. **Services**: service_list, service_master/detail
6. **Financial**: expense_list, expense_master/detail, payments
7. **Inventory**: stock, damage, damage_detail

## Testing

Sample query to verify data:
```sql
SELECT c.company_name, COUNT(p.product_id) as product_count
FROM company c
LEFT JOIN products p ON 1=1
GROUP BY c.company_name;
```

## Documentation

See `.github/copilot-instructions.md` for detailed:
- Schema conventions
- Trigger patterns
- Data insertion best practices
- Common troubleshooting
