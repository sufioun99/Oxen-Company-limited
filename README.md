# Oxen-Company-limited
An Electronics sales and service provider company

## Database Overview

This repository contains the Oracle database schema and automation scripts for a comprehensive Electronics Sales and Service Management System. The schema is designed to be compatible with **Oracle 11g**, **Oracle Forms 11g**, and **Oracle APEX**.

## Files Description

| File | Description |
|------|-------------|
| `Schema.sql` | Complete database schema with 33 tables, sequences, triggers, and sample data |
| `Insert data` | Sample data insertion scripts (standalone) |
| `automation_package.sql` | Automation package with LOV views, report views, dashboard views, and business logic |
| `DYNAMIC LIST CRATION` | Oracle Forms trigger code for dynamic list population |
| `combined schema with insert data` | Combined file with schema and insert data |

## Database Structure

### Tables (33 Total)

#### Master Tables
- `company` - Company information
- `jobs` - Job positions and grades
- `customers` - Customer master data
- `suppliers` - Supplier master data
- `employees` - Employee records
- `departments` - Department structure
- `products` - Product catalog
- `parts` - Spare parts inventory
- `brand` - Brand and model information
- `product_categories` - Product category master
- `sub_categories` - Product sub-categories
- `parts_category` - Spare parts categories
- `service_list` - Available services
- `expense_list` - Expense types
- `stock` - Inventory stock levels

#### Transaction Tables
- `sales_master` / `sales_detail` - Sales invoices
- `sales_return_master` / `sales_return_details` - Sales returns
- `service_master` / `service_details` - Service records
- `product_order_master` / `product_order_detail` - Purchase orders
- `product_receive_master` / `product_receive_details` - Goods receiving
- `product_return_master` / `product_return_details` - Supplier returns
- `expense_master` / `expense_details` - Expense tracking
- `damage` / `damage_detail` - Damage records
- `payments` - Supplier payments
- `com_users` - Application users

## Installation

### Prerequisites
- Oracle Database 11g or higher
- Oracle SQL*Plus or SQL Developer

### Step 1: Create Database Schema
```sql
-- Connect as SYSDBA
@Schema.sql
```

### Step 2: Install Automation Package
```sql
-- Connect as schema owner (msp)
CONNECT msp/msp;
@automation_package.sql
```

## Automation Features

### LOV (List of Values) Views
Pre-built views for Oracle Forms and APEX dropdowns:
- `v_lov_customers` - Customer selection
- `v_lov_suppliers` - Supplier selection
- `v_lov_products` - Product selection with prices
- `v_lov_employees` - Employee selection
- `v_lov_departments` - Department selection
- `v_lov_jobs` - Job position selection
- `v_lov_product_categories` - Category selection
- `v_lov_sub_categories` - Sub-category selection (filterable)
- `v_lov_brands` - Brand selection
- `v_lov_parts` - Spare parts selection
- `v_lov_services` - Service selection with costs
- `v_lov_expense_types` - Expense type selection

### Report Views
Ready-to-use views for APEX Interactive Reports:
- `v_rpt_product_inventory` - Product inventory with stock status
- `v_rpt_sales_summary` - Sales transaction summary
- `v_rpt_service_tracking` - Service order tracking
- `v_rpt_supplier_ledger` - Supplier accounts with dues
- `v_rpt_employee_directory` - Employee listing
- `v_rpt_purchase_orders` - Purchase order summary
- `v_rpt_daily_sales` - Daily sales aggregation
- `v_rpt_expense_summary` - Expense tracking
- `v_rpt_stock_movement` - Stock level monitoring

### Dashboard Views (For APEX)
- `v_dash_sales_overview` - Sales KPIs (Today/Week/Month)
- `v_dash_low_stock` - Low stock alerts
- `v_dash_top_products` - Top selling products
- `v_dash_pending_orders` - Pending purchase orders
- `v_dash_service_stats` - Service statistics
- `v_dash_supplier_dues` - Supplier payment dues

### Automation Package (pkg_automation)
Business logic procedures:
- `calc_sales_total()` - Auto-calculate invoice totals
- `calc_order_total()` - Auto-calculate order totals
- `calc_receive_total()` - Auto-calculate receive totals
- `calc_return_total()` - Auto-calculate return totals
- `calc_service_total()` - Auto-calculate service totals
- `update_stock_on_receive()` - Update stock after receiving
- `update_stock_on_sale()` - Reduce stock after sales
- `update_stock_on_sales_return()` - Restore stock on returns
- `update_stock_on_damage()` - Reduce stock for damages
- `update_supplier_on_payment()` - Update supplier payment totals
- `is_in_stock()` - Check stock availability
- `get_stock_quantity()` - Get current stock level

### Automation Triggers
Auto-triggered operations:
- Master-detail total calculations
- Stock updates on receive/sale/return/damage
- Supplier purchase total updates
- Audit column population (cre_by, cre_dt, upd_by, upd_dt)

## Oracle Forms Integration

### Dynamic List Population
Use the `DYNAMIC LIST CRATION` file for populating LOVs in Forms:
```plsql
-- In WHEN-NEW-FORM-INSTANCE trigger
-- Copy code from 'DYNAMIC LIST CRATION' file
```

### Using LOV Views in Forms
```plsql
-- Create Record Group from LOV view
rg := Create_Group_From_Query('RG_PRODUCTS',
   'SELECT display_value, return_value FROM v_lov_products');
Populate_List('BLOCK.PRODUCT_ID', rg);
```

## Oracle APEX Integration

### Creating LOVs
1. Go to Shared Components > List of Values
2. Create from SQL Query
3. Use: `SELECT display_value d, return_value r FROM v_lov_products`

### Creating Interactive Reports
1. Create new page with Interactive Report
2. Select source as SQL Query
3. Use: `SELECT * FROM v_rpt_sales_summary`

### Dashboard Regions
Use dashboard views for chart and report regions:
```sql
SELECT * FROM v_dash_sales_overview
SELECT * FROM v_dash_low_stock
```

## Key Features

- **Oracle 11g Compatible** - Uses features available in Oracle 11g
- **Audit Columns** - Automatic tracking of created/updated by and date
- **Auto ID Generation** - Sequences and triggers for primary keys
- **Referential Integrity** - Foreign key constraints with proper relationships
- **Virtual Columns** - Calculated columns (e.g., supplier due amount)
- **Stock Management** - Automatic stock updates via triggers
- **Master-Detail Automation** - Auto-calculation of totals

## License

This project is proprietary to Oxen Company Limited.

## Support

For support and customization requests, contact the IT department.
