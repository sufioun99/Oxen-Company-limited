# Oxen Company Limited

An Electronics Sales and Service Provider Company Database System

## Overview

This repository contains a comprehensive Oracle database schema for managing an electronics sales and service business. The system is designed to be compatible with both **Oracle 11g Forms** and **Oracle APEX**, with maximum automation features.

## Features

- **33 Database Tables** covering all business operations
- **Automatic ID Generation** via sequences and triggers
- **Audit Trail** with created_by, created_date, updated_by, updated_date columns
- **Oracle 11g Forms Ready** with LOV queries and form triggers
- **Oracle APEX Ready** with pre-built views for LOV, reports, and dashboards
- **Automation Package** for business logic and stock management

## File Structure

| File | Description |
|------|-------------|
| `Schema.sql` | Original database schema with 33 tables |
| `combined schema with insert data` | Full schema with sample data (combined file) |
| `Insert data` | Sample data insertion scripts |
| `DYNAMIC LIST CRATION` | Oracle Forms dynamic list creation trigger |
| `apex_views.sql` | **NEW** - Oracle APEX ready views for LOV, reports, dashboards |
| `automation_pkg.sql` | **NEW** - PL/SQL package for business automation |
| `forms_lov.sql` | **NEW** - Oracle 11g Forms LOV queries and triggers |

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
- Oracle Database 11g or higher
- Oracle SQL*Plus or SQL Developer
- (Optional) Oracle Forms 11g for Forms features
- (Optional) Oracle APEX 5.x+ for APEX features

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
@Schema.sql
-- OR for combined schema with data:
@"combined schema with insert data"
```

3. **Install APEX Views (Optional)**
```sql
@apex_views.sql
```

4. **Install Automation Package (Optional)**
```sql
@automation_pkg.sql
```

## Oracle APEX Usage

### LOV (List of Values) Views
All LOV views are prefixed with `lov_` and return two columns:
- `return_value` - The ID to store
- `display_value` - The text to display

Example usage in APEX:
```sql
SELECT display_value AS d, return_value AS r
FROM lov_products_v
ORDER BY 1
```

### Dashboard Views
Dashboard views are prefixed with `dashboard_` and provide pre-aggregated data:
- `dashboard_sales_summary_v` - Daily sales summary
- `dashboard_sales_monthly_v` - Monthly sales trends
- `dashboard_top_products_v` - Top selling products
- `dashboard_top_customers_v` - Top customers by revenue
- `dashboard_stock_alerts_v` - Low stock alerts
- `dashboard_supplier_due_v` - Supplier payment dues
- `dashboard_kpi_v` - Key performance indicators

### Report Views
Report views are suffixed with `_report_v`:
- `sales_invoice_report_v` - Sales invoice listing
- `sales_detail_report_v` - Sales detail with calculations
- `purchase_order_report_v` - Purchase orders
- `product_receive_report_v` - Goods receipts
- `service_report_v` - Service tickets
- `stock_report_v` - Stock status with valuation

## Oracle Forms Usage

### Dynamic LOV Initialization
Copy the trigger code from `forms_lov.sql` into your form's `WHEN-NEW-FORM-INSTANCE` trigger to automatically populate all LOVs.

### Cascading LOVs
The file includes code for cascading LOVs (e.g., sub-categories based on category selection).

### Form Triggers
Pre-built triggers for:
- Product price auto-population
- Stock availability checking
- Invoice total calculation
- Service charge auto-fill

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
