# Oxen Company Limited

An Electronics Sales and Service Provider Company Database System

## 🆕 What's New (January 2026)

✨ **Complete Forms Implementation Guide Released!**

We've added comprehensive, step-by-step implementation guidelines for creating Oracle Forms 11g applications for all 33 database tables:

- 📖 **[COMPLETE_FORMS_GUIDELINES.md](COMPLETE_FORMS_GUIDELINES.md)** - 3,159 lines of detailed implementation instructions
  - Every table covered with form layouts, triggers, LOVs, and validations
  - Master-detail transaction forms with complete automation
  - Stock management integration explained
  - Testing checklists for quality assurance

- 🔍 **[FORMS_INDEX.md](FORMS_INDEX.md)** - Quick navigation guide
  - Search any form by table name
  - Complexity ratings for all forms
  - Recommended learning path from beginner to expert

**Now you can create error-free, fully automated Oracle Forms with no complications!**

---

## Overview

This repository contains a comprehensive Oracle database schema for managing an electronics sales and service business. The system is designed to be compatible with both **Oracle 11g Forms** and **Oracle APEX**, with maximum automation features.

## Features

- **33 Database Tables** covering all business operations
- **Automatic ID Generation** via sequences and triggers
- **Audit Trail** with created_by, created_date, updated_by, updated_date columns
- **Oracle Forms 11g Ready** with LOV queries and form triggers (compatible with Oracle Forms 11g Builder and Oracle Database 11g+)
- **Oracle APEX Ready** with pre-built views for LOV, reports, and dashboards (APEX 5.x and later)
- **Automation Package** for business logic and stock management

## File Structure

### 🗄️ Database Scripts
| File | Description |
|------|-------------|
| `clean_combined.sql` | Complete database setup script (33 tables with sample data) |
| `Schema.sql` | Original database schema with 33 tables |
| `Insert data` | Sample data insertion scripts |
| `automation_pkg.sql` | PL/SQL package for business automation |

### 📚 Complete Form Implementation Guides (NEW!)
| File | Description | Size |
|------|-------------|------|
| **`COMPLETE_FORMS_GUIDELINES.md`** | **🎯 Complete step-by-step implementation guide for all 33 tables** | 102 KB, 3,159 lines |
| **`FORMS_INDEX.md`** | **🔍 Quick navigation index to find any form by table name** | 9.8 KB, 237 lines |
| **`ORACLE_FORMS_11G_ARCHITECTURE_GUIDE.md`** | **📘 Oracle Forms 11g architecture and development guide** | 40 KB |
| **`FORMS_QUICK_REFERENCE.md`** | **⚡ Quick reference code snippets for Forms development** | 20 KB |
| **`FORMS_LOV_QUICK_GUIDE.md`** | **📋 LOV implementation quick guide** | 12 KB |

### 🧪 Testing & Automation
| File | Description |
|------|-------------|
| `FORMS_TEST_QUERIES.sql` | Test queries and validation scripts |
| `forms_lov.sql` | Oracle 11g Forms LOV queries and triggers |
| `oracle_reports.sql` | Oracle Reports templates and queries |
| `DYNAMIC LIST CRATION` | Oracle Forms dynamic list creation trigger |
| `complete_trigger_documentations` | Detailed trigger documentation for all 50+ triggers |

## Database Tables

### Master Tables
1. **company** - Company information
2. **jobs** - Job positions and grades
3. **customers** - Customer management
4. **suppliers** - Supplier management
5. **employees** - Employee records
6. **departments** - Department structure

### Product Management
7. **product_categories** - Product category master
8. **sub_categories** - Product sub-categories
9. **brand** - Brand and model information
10. **products** - Product catalog
11. **stock** - Inventory management
12. **parts_category** - Spare parts categories
13. **parts** - Spare parts catalog

### Sales & Returns
14. **sales_master** - Sales invoice header
15. **sales_detail** - Sales invoice line items
16. **sales_return_master** - Sales return header
17. **sales_return_details** - Sales return line items

### Purchasing
18. **product_order_master** - Purchase order header
19. **product_order_detail** - Purchase order line items
20. **product_receive_master** - Goods receipt header
21. **product_receive_details** - Goods receipt line items
22. **product_return_master** - Purchase return header
23. **product_return_details** - Purchase return line items

### Service Management
24. **service_list** - Service types and pricing
25. **service_master** - Service ticket header
26. **service_details** - Service ticket details

### Finance
27. **expense_list** - Expense types
28. **expense_master** - Expense header
29. **expense_details** - Expense line items
30. **payments** - Supplier payments

### Other
31. **damage** - Damaged goods header
32. **damage_detail** - Damaged goods details
33. **com_users** - Application users

## Installation

### Prerequisites
- Oracle Database 11g Release 2 or higher
- Oracle SQL*Plus or SQL Developer
- (Optional) Oracle Forms 11g (11.1.1.x or later) for Forms features
- (Optional) Oracle APEX 5.x or later for APEX features

### Setup Steps

1. **Create Database User**
```sql
-- Connect as SYSDBA
CREATE USER msp IDENTIFIED BY msp
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE PROCEDURE TO msp;
```

2. **Run Schema Script**
```sql
-- Connect as msp user
sqlplus msp/msp @clean_combined.sql
-- This creates all 33 tables with sample data
```

3. **Verify Installation**
```sql
-- Test queries provided in FORMS_TEST_QUERIES.sql
sqlplus msp/msp @FORMS_TEST_QUERIES.sql
```

4. **Install Automation Package (Optional)**
```sql
@automation_pkg.sql
```

## Oracle Forms 11g Development

### 🎯 NEW: Complete Implementation Guide (All 33 Tables)
See **[COMPLETE_FORMS_GUIDELINES.md](COMPLETE_FORMS_GUIDELINES.md)** for comprehensive step-by-step implementation guide covering:
- ✅ **All 33 tables** with detailed form specifications
- ✅ **Step-by-step instructions** for each form creation
- ✅ **Complete trigger implementations** with error handling
- ✅ **LOV configurations** for all foreign keys
- ✅ **Business logic validation** for all transactions
- ✅ **Automation integration** with database triggers
- ✅ **Stock management** automation explained
- ✅ **Master-detail coordination** for complex forms
- ✅ **Testing checklists** for each form
- ✅ **Best practices** and common pitfalls

**Quick Navigation**: Use **[FORMS_INDEX.md](FORMS_INDEX.md)** to quickly find any form by table name.

### 📘 Complete Architecture Guide
See **[ORACLE_FORMS_11G_ARCHITECTURE_GUIDE.md](ORACLE_FORMS_11G_ARCHITECTURE_GUIDE.md)** for comprehensive documentation including:
- Complete schema analysis with all 33 tables
- Primary keys and foreign key relationships
- Form-level triggers (ON-ERROR, ON-MESSAGE)
- Save/Delete button implementations
- Login form step-by-step guide with authentication
- Parameter passing between forms
- Best practices and troubleshooting

### ⚡ Quick Reference
See **[FORMS_QUICK_REFERENCE.md](FORMS_QUICK_REFERENCE.md)** for ready-to-use code snippets:
- Form-level triggers (ON-ERROR, ON-MESSAGE, WHEN-NEW-FORM-INSTANCE)
- Button triggers (Save, Delete, Query, Exit)
- Item-level triggers and validations
- LOV queries for all master tables
- Navigation and utility functions
- Master-detail coordination examples

### 🧪 Testing & Validation
Run **[FORMS_TEST_QUERIES.sql](FORMS_TEST_QUERIES.sql)** to:
- Validate schema integrity (all 33 tables)
- Test user authentication queries
- Create test users (admin/admin123, testuser/test123)
- Verify foreign key relationships
- Get LOV queries for forms development

### Dynamic LOV Initialization
Copy the trigger code from `forms_lov.sql` into your form's `WHEN-NEW-FORM-INSTANCE` trigger to automatically populate all LOVs.

### Key Features for Forms Development
- **Seamless Save**: Bypass standard Oracle alerts with custom ON-MESSAGE trigger
- **User-Friendly Errors**: ON-ERROR trigger converts ORA- codes to readable messages
- **Authentication**: Complete login form with credential validation against `com_users` table
- **Parameter Passing**: Examples using CALL_FORM, global variables, and parameter lists
- **Master-Detail**: Pre-built coordination for sales, purchases, and service forms

## Automation Package

### Stock Management
```sql
-- Add stock
pkg_oxen_automation.add_stock(p_product_id, p_supplier_id, p_quantity, v_result);

-- Reduce stock
pkg_oxen_automation.reduce_stock(p_product_id, p_quantity, v_result);

-- Check stock
v_qty := pkg_oxen_automation.check_stock(p_product_id);
```

### Sales Processing
```sql
-- Create invoice
pkg_oxen_automation.create_sales_invoice(p_customer_id, p_sales_by, p_discount, v_invoice_id, v_result);

-- Add item
pkg_oxen_automation.add_sales_item(v_invoice_id, p_product_id, p_quantity, p_mrp, p_vat, v_result);

-- Finalize (updates totals and reduces stock)
pkg_oxen_automation.finalize_sales(v_invoice_id, v_result);
```

### Supplier Payments
```sql
-- Record payment
pkg_oxen_automation.record_supplier_payment(p_supplier_id, p_amount, v_payment_id, v_result);

-- Check due
v_due := pkg_oxen_automation.get_supplier_due(p_supplier_id);
```

## Sample Data

The repository includes sample data for testing:
- 10 Companies (Walton, Samsung, LG, etc.)
- 10 Jobs
- 10 Customers
- 10 Suppliers
- 10 Products
- 20 Employees
- Sample purchase orders, receipts, and returns

## License

This project is provided for educational and commercial use.

## Contributing

Contributions are welcome. Please submit pull requests for any improvements.

## Contact

For questions or support, please open an issue in this repository.
