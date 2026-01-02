--------------------------------------------------------------------------------
-- OXEN COMPANY LIMITED - ORACLE APEX READY VIEWS
-- Compatible with: Oracle 11g, Oracle APEX 5.x+
-- Purpose: Provides ready-to-use views for APEX LOV, Reports, and Dashboards
-- Date: 2026-01-02
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- SECTION 1: LOV (List of Values) VIEWS - For APEX Select Lists/Popups
--------------------------------------------------------------------------------

-- LOV: Active Companies
CREATE OR REPLACE VIEW lov_companies_v AS
SELECT company_id AS return_value,
       company_name AS display_value
FROM company
WHERE status = 1
ORDER BY company_name;

-- LOV: Active Jobs
CREATE OR REPLACE VIEW lov_jobs_v AS
SELECT job_id AS return_value,
       job_title || ' (' || job_grade || ')' AS display_value
FROM jobs
WHERE status = 1
ORDER BY job_title;

-- LOV: Active Customers
CREATE OR REPLACE VIEW lov_customers_v AS
SELECT customer_id AS return_value,
       customer_name || ' - ' || NVL(phone_no, 'N/A') AS display_value
FROM customers
WHERE status = 1
ORDER BY customer_name;

-- LOV: Active Suppliers
CREATE OR REPLACE VIEW lov_suppliers_v AS
SELECT supplier_id AS return_value,
       supplier_name AS display_value
FROM suppliers
WHERE status = 1
ORDER BY supplier_name;

-- LOV: Active Products
CREATE OR REPLACE VIEW lov_products_v AS
SELECT product_id AS return_value,
       product_name || ' (' || product_code || ')' AS display_value
FROM products
WHERE status = 1
ORDER BY product_name;

-- LOV: Product Categories
CREATE OR REPLACE VIEW lov_product_categories_v AS
SELECT product_cat_id AS return_value,
       product_cat_name AS display_value
FROM product_categories
WHERE status = 1
ORDER BY product_cat_name;

-- LOV: Sub Categories
CREATE OR REPLACE VIEW lov_sub_categories_v AS
SELECT sub_cat_id AS return_value,
       sub_cat_name AS display_value,
       product_cat_id AS parent_value
FROM sub_categories
WHERE status = 1
ORDER BY sub_cat_name;

-- LOV: Brands
CREATE OR REPLACE VIEW lov_brands_v AS
SELECT brand_id AS return_value,
       brand_name || ' - ' || model_name AS display_value
FROM brand
WHERE status = 1
ORDER BY brand_name, model_name;

-- LOV: Active Employees
CREATE OR REPLACE VIEW lov_employees_v AS
SELECT employee_id AS return_value,
       first_name || ' ' || last_name AS display_value
FROM employees
WHERE status = 1
ORDER BY last_name, first_name;

-- LOV: Sales Employees (for sales forms)
CREATE OR REPLACE VIEW lov_sales_employees_v AS
SELECT e.employee_id AS return_value,
       e.first_name || ' ' || e.last_name AS display_value
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
WHERE e.status = 1
AND j.job_code IN ('SALES', 'MGR', 'ASM')
ORDER BY e.last_name, e.first_name;

-- LOV: Technician Employees (for service forms)
CREATE OR REPLACE VIEW lov_technicians_v AS
SELECT e.employee_id AS return_value,
       e.first_name || ' ' || e.last_name AS display_value
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
WHERE e.status = 1
AND j.job_code IN ('TECH', 'CSUP')
ORDER BY e.last_name, e.first_name;

-- LOV: Departments
CREATE OR REPLACE VIEW lov_departments_v AS
SELECT department_id AS return_value,
       department_name AS display_value,
       company_id AS parent_value
FROM departments
WHERE status = 1
ORDER BY department_name;

-- LOV: Service List
CREATE OR REPLACE VIEW lov_services_v AS
SELECT servicelist_id AS return_value,
       service_name || ' (BDT ' || TO_CHAR(service_cost) || ')' AS display_value,
       service_cost
FROM service_list
WHERE status = 1
ORDER BY service_name;

-- LOV: Expense Types
CREATE OR REPLACE VIEW lov_expense_types_v AS
SELECT expense_type_id AS return_value,
       type_name || ' (' || expense_code || ')' AS display_value,
       default_amount
FROM expense_list
WHERE status = 1
ORDER BY type_name;

-- LOV: Parts Categories
CREATE OR REPLACE VIEW lov_parts_categories_v AS
SELECT parts_cat_id AS return_value,
       parts_cat_name AS display_value
FROM parts_category
WHERE status = 1
ORDER BY parts_cat_name;

-- LOV: Parts
CREATE OR REPLACE VIEW lov_parts_v AS
SELECT parts_id AS return_value,
       parts_name || ' (BDT ' || TO_CHAR(mrp) || ')' AS display_value,
       parts_cat_id AS parent_value,
       mrp,
       purchase_price
FROM parts
WHERE status = 1
ORDER BY parts_name;

-- LOV: Status Values
CREATE OR REPLACE VIEW lov_status_v AS
SELECT 1 AS return_value, 'Active' AS display_value FROM DUAL
UNION ALL
SELECT 0, 'Inactive' FROM DUAL
UNION ALL
SELECT 2, 'Pending' FROM DUAL
UNION ALL
SELECT 3, 'Completed' FROM DUAL
UNION ALL
SELECT 4, 'Cancelled' FROM DUAL
ORDER BY return_value;

-- LOV: User Roles
CREATE OR REPLACE VIEW lov_user_roles_v AS
SELECT 'admin' AS return_value, 'Administrator' AS display_value FROM DUAL
UNION ALL
SELECT 'manager', 'Manager' FROM DUAL
UNION ALL
SELECT 'sales', 'Sales Executive' FROM DUAL
UNION ALL
SELECT 'technician', 'Technician' FROM DUAL
UNION ALL
SELECT 'accountant', 'Accountant' FROM DUAL
UNION ALL
SELECT 'user', 'Standard User' FROM DUAL
ORDER BY display_value;

--------------------------------------------------------------------------------
-- SECTION 2: REPORT VIEWS - For APEX Interactive Reports
--------------------------------------------------------------------------------

-- Suppliers with calculated due amount (replaces virtual column)
CREATE OR REPLACE VIEW suppliers_with_due_v AS
SELECT supplier_id,
       supplier_name,
       phone_no,
       email,
       address,
       contact_person,
       cp_phone_no,
       cp_email,
       purchase_total,
       pay_total,
       NVL(purchase_total, 0) - NVL(pay_total, 0) AS due_amount,
       status,
       cre_by,
       cre_dt,
       upd_by,
       upd_dt
FROM suppliers;

-- Products with full details
CREATE OR REPLACE VIEW products_full_v AS
SELECT p.product_id,
       p.product_code,
       p.product_name,
       p.uom,
       p.mrp,
       p.purchase_price,
       p.warranty,
       p.status,
       s.supplier_name,
       pc.product_cat_name AS category_name,
       sc.sub_cat_name,
       b.brand_name,
       b.model_name,
       p.cre_dt,
       p.cre_by
FROM products p
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN product_categories pc ON p.category_id = pc.product_cat_id
LEFT JOIN sub_categories sc ON p.sub_cat_id = sc.sub_cat_id
LEFT JOIN brand b ON p.brand_id = b.brand_id;

-- Employees with full details
CREATE OR REPLACE VIEW employees_full_v AS
SELECT e.employee_id,
       e.first_name,
       e.last_name,
       e.first_name || ' ' || e.last_name AS full_name,
       e.email,
       e.phone_no,
       e.address,
       e.hire_date,
       e.salary,
       e.status,
       j.job_title,
       j.job_grade,
       d.department_name,
       c.company_name,
       m.first_name || ' ' || m.last_name AS manager_name
FROM employees e
LEFT JOIN jobs j ON e.job_id = j.job_id
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN company c ON d.company_id = c.company_id
LEFT JOIN employees m ON e.manager_id = m.employee_id;

-- Sales Invoice Report
CREATE OR REPLACE VIEW sales_invoice_report_v AS
SELECT sm.invoice_id,
       sm.invoice_date,
       c.customer_name,
       c.phone_no AS customer_phone,
       e.first_name || ' ' || e.last_name AS sales_person,
       sm.discount,
       sm.adjust_amount,
       sm.grand_total,
       sm.status,
       (SELECT COUNT(*) FROM sales_detail WHERE invoice_id = sm.invoice_id) AS item_count
FROM sales_master sm
LEFT JOIN customers c ON sm.customer_id = c.customer_id
LEFT JOIN employees e ON sm.sales_by = e.employee_id;

-- Sales Detail Report
CREATE OR REPLACE VIEW sales_detail_report_v AS
SELECT sd.sales_det_id,
       sd.invoice_id,
       sm.invoice_date,
       c.customer_name,
       p.product_code,
       p.product_name,
       sd.mrp,
       sd.purchase_price,
       sd.quantity,
       sd.vat,
       (sd.mrp * sd.quantity) AS line_total,
       ((sd.mrp * sd.quantity) + NVL(sd.vat, 0)) AS line_total_with_vat
FROM sales_detail sd
JOIN sales_master sm ON sd.invoice_id = sm.invoice_id
LEFT JOIN customers c ON sm.customer_id = c.customer_id
LEFT JOIN products p ON sd.product_id = p.product_id;

-- Purchase Order Report
CREATE OR REPLACE VIEW purchase_order_report_v AS
SELECT pom.order_id,
       pom.order_date,
       pom.expected_delivery_date,
       s.supplier_name,
       e.first_name || ' ' || e.last_name AS ordered_by,
       pom.total_amount,
       pom.vat,
       pom.grand_total,
       pom.status,
       (SELECT COUNT(*) FROM product_order_detail WHERE order_id = pom.order_id) AS item_count
FROM product_order_master pom
LEFT JOIN suppliers s ON pom.supplier_id = s.supplier_id
LEFT JOIN employees e ON pom.order_by = e.employee_id;

-- Product Receive Report
CREATE OR REPLACE VIEW product_receive_report_v AS
SELECT prm.receive_id,
       prm.receive_date,
       prm.sup_invoice_id,
       s.supplier_name,
       pom.order_id,
       e.first_name || ' ' || e.last_name AS received_by,
       prm.total_amount,
       prm.vat,
       prm.grand_total,
       prm.status
FROM product_receive_master prm
LEFT JOIN suppliers s ON prm.supplier_id = s.supplier_id
LEFT JOIN product_order_master pom ON prm.order_id = pom.order_id
LEFT JOIN employees e ON prm.received_by = e.employee_id;

-- Service Report
CREATE OR REPLACE VIEW service_report_v AS
SELECT sm.service_id,
       sm.service_date,
       c.customer_name,
       c.phone_no AS customer_phone,
       sl.service_name,
       sm.warranty_applicable,
       e.first_name || ' ' || e.last_name AS serviced_by,
       sm.service_charge,
       sm.parts_price,
       sm.total_price,
       sm.status,
       inv.invoice_id AS original_invoice
FROM service_master sm
LEFT JOIN customers c ON sm.customer_id = c.customer_id
LEFT JOIN service_list sl ON sm.servicelist_id = sl.servicelist_id
LEFT JOIN employees e ON sm.service_by = e.employee_id
LEFT JOIN sales_master inv ON sm.invoice_id = inv.invoice_id;

-- Stock Report
CREATE OR REPLACE VIEW stock_report_v AS
SELECT s.stock_id,
       p.product_code,
       p.product_name,
       pc.product_cat_name,
       sup.supplier_name,
       s.quantity,
       p.mrp,
       (s.quantity * p.mrp) AS stock_value_mrp,
       (s.quantity * p.purchase_price) AS stock_value_cost,
       s.last_update,
       CASE 
           WHEN s.quantity = 0 THEN 'OUT OF STOCK'
           WHEN s.quantity < 5 THEN 'LOW STOCK'
           ELSE 'IN STOCK'
       END AS stock_status
FROM stock s
JOIN products p ON s.product_id = p.product_id
LEFT JOIN product_categories pc ON s.product_cat_id = pc.product_cat_id
LEFT JOIN suppliers sup ON s.supplier_id = sup.supplier_id
WHERE s.status = 1;

-- Expense Report
CREATE OR REPLACE VIEW expense_report_v AS
SELECT em.expense_id,
       em.expense_date,
       em.expense_code,
       el.type_name AS expense_type,
       em.expense_by,
       em.remarks,
       (SELECT SUM(line_total) FROM expense_details WHERE expense_id = em.expense_id) AS total_expense,
       em.status
FROM expense_master em
LEFT JOIN expense_list el ON em.expense_type_id = el.expense_type_id;

--------------------------------------------------------------------------------
-- SECTION 3: DASHBOARD VIEWS - For APEX Dashboard Cards/Charts
--------------------------------------------------------------------------------

-- Dashboard: Sales Summary by Date
CREATE OR REPLACE VIEW dashboard_sales_summary_v AS
SELECT TRUNC(invoice_date) AS sale_date,
       COUNT(*) AS invoice_count,
       SUM(grand_total) AS total_sales,
       AVG(grand_total) AS avg_sale_value
FROM sales_master
WHERE status = 1
GROUP BY TRUNC(invoice_date)
ORDER BY sale_date DESC;

-- Dashboard: Sales by Month
CREATE OR REPLACE VIEW dashboard_sales_monthly_v AS
SELECT TO_CHAR(invoice_date, 'YYYY-MM') AS sale_month,
       TO_CHAR(invoice_date, 'Mon YYYY') AS display_month,
       COUNT(*) AS invoice_count,
       SUM(grand_total) AS total_sales
FROM sales_master
WHERE status = 1
GROUP BY TO_CHAR(invoice_date, 'YYYY-MM'), TO_CHAR(invoice_date, 'Mon YYYY')
ORDER BY sale_month DESC;

-- Dashboard: Top Selling Products
CREATE OR REPLACE VIEW dashboard_top_products_v AS
SELECT p.product_id,
       p.product_name,
       p.product_code,
       SUM(sd.quantity) AS total_qty_sold,
       SUM(sd.mrp * sd.quantity) AS total_revenue
FROM sales_detail sd
JOIN products p ON sd.product_id = p.product_id
JOIN sales_master sm ON sd.invoice_id = sm.invoice_id
WHERE sm.status = 1
GROUP BY p.product_id, p.product_name, p.product_code
ORDER BY total_qty_sold DESC;

-- Dashboard: Top Customers
CREATE OR REPLACE VIEW dashboard_top_customers_v AS
SELECT c.customer_id,
       c.customer_name,
       c.phone_no,
       COUNT(sm.invoice_id) AS total_purchases,
       SUM(sm.grand_total) AS total_spent
FROM customers c
JOIN sales_master sm ON c.customer_id = sm.customer_id
WHERE sm.status = 1
GROUP BY c.customer_id, c.customer_name, c.phone_no
ORDER BY total_spent DESC;

-- Dashboard: Stock Alerts
CREATE OR REPLACE VIEW dashboard_stock_alerts_v AS
SELECT p.product_id,
       p.product_name,
       p.product_code,
       NVL(s.quantity, 0) AS current_stock,
       CASE 
           WHEN NVL(s.quantity, 0) = 0 THEN 'OUT OF STOCK'
           WHEN NVL(s.quantity, 0) < 5 THEN 'LOW STOCK'
           ELSE 'NORMAL'
       END AS alert_type
FROM products p
LEFT JOIN stock s ON p.product_id = s.product_id
WHERE p.status = 1
AND NVL(s.quantity, 0) < 5
ORDER BY s.quantity ASC;

-- Dashboard: Supplier Due Summary (uses suppliers_with_due_v to avoid duplication)
CREATE OR REPLACE VIEW dashboard_supplier_due_v AS
SELECT supplier_id,
       supplier_name,
       purchase_total,
       pay_total,
       due_amount
FROM suppliers_with_due_v
WHERE status = 1
AND due_amount > 0
ORDER BY due_amount DESC;

-- Dashboard: Service Summary
CREATE OR REPLACE VIEW dashboard_service_summary_v AS
SELECT TO_CHAR(service_date, 'YYYY-MM') AS service_month,
       COUNT(*) AS total_services,
       SUM(CASE WHEN warranty_applicable = 'Y' THEN 1 ELSE 0 END) AS warranty_services,
       SUM(CASE WHEN warranty_applicable = 'N' THEN 1 ELSE 0 END) AS paid_services,
       SUM(total_price) AS total_revenue
FROM service_master
WHERE status IN (1, 3) -- Active or Completed
GROUP BY TO_CHAR(service_date, 'YYYY-MM')
ORDER BY service_month DESC;

-- Dashboard: Employee Performance (Sales)
CREATE OR REPLACE VIEW dashboard_employee_sales_v AS
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS employee_name,
       COUNT(sm.invoice_id) AS total_sales,
       SUM(sm.grand_total) AS total_revenue,
       ROUND(AVG(sm.grand_total), 2) AS avg_sale_value
FROM employees e
JOIN sales_master sm ON e.employee_id = sm.sales_by
WHERE sm.status = 1
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_revenue DESC;

-- Dashboard: Overall KPIs
CREATE OR REPLACE VIEW dashboard_kpi_v AS
SELECT 
    (SELECT COUNT(*) FROM customers WHERE status = 1) AS total_customers,
    (SELECT COUNT(*) FROM products WHERE status = 1) AS total_products,
    (SELECT COUNT(*) FROM employees WHERE status = 1) AS total_employees,
    (SELECT COUNT(*) FROM suppliers WHERE status = 1) AS total_suppliers,
    (SELECT NVL(SUM(grand_total), 0) FROM sales_master WHERE status = 1 AND TRUNC(invoice_date) = TRUNC(SYSDATE)) AS today_sales,
    (SELECT NVL(SUM(grand_total), 0) FROM sales_master WHERE status = 1 AND TO_CHAR(invoice_date, 'YYYY-MM') = TO_CHAR(SYSDATE, 'YYYY-MM')) AS month_sales,
    (SELECT COUNT(*) FROM sales_master WHERE status = 1 AND TRUNC(invoice_date) = TRUNC(SYSDATE)) AS today_invoices,
    (SELECT COUNT(*) FROM service_master WHERE status = 1 AND TRUNC(service_date) = TRUNC(SYSDATE)) AS today_services
FROM DUAL;

--------------------------------------------------------------------------------
-- SECTION 4: UTILITY VIEWS
--------------------------------------------------------------------------------

-- Audit Log View
CREATE OR REPLACE VIEW audit_log_v AS
SELECT 'COMPANY' AS table_name, company_id AS record_id, cre_by, cre_dt, upd_by, upd_dt FROM company
UNION ALL
SELECT 'CUSTOMERS', customer_id, cre_by, cre_dt, upd_by, upd_dt FROM customers
UNION ALL
SELECT 'PRODUCTS', product_id, cre_by, cre_dt, upd_by, upd_dt FROM products
UNION ALL
SELECT 'SALES_MASTER', invoice_id, cre_by, cre_dt, upd_by, upd_dt FROM sales_master
UNION ALL
SELECT 'SERVICE_MASTER', service_id, cre_by, cre_dt, upd_by, upd_dt FROM service_master;

-- Recent Activity View
CREATE OR REPLACE VIEW recent_activity_v AS
SELECT * FROM (
    SELECT 'SALE' AS activity_type, 
           invoice_id AS reference_id, 
           'Invoice ' || invoice_id || ' - BDT ' || TO_CHAR(grand_total) AS description,
           cre_dt AS activity_date,
           cre_by AS activity_by
    FROM sales_master
    WHERE status = 1
    UNION ALL
    SELECT 'SERVICE', 
           service_id, 
           'Service ' || service_id AS description,
           cre_dt,
           cre_by
    FROM service_master
    WHERE status = 1
    UNION ALL
    SELECT 'PURCHASE', 
           receive_id, 
           'Received ' || receive_id || ' - BDT ' || TO_CHAR(grand_total) AS description,
           cre_dt,
           cre_by
    FROM product_receive_master
    WHERE status = 1
    ORDER BY activity_date DESC
)
WHERE ROWNUM <= 50;

COMMIT;

--------------------------------------------------------------------------------
-- END OF APEX VIEWS
--------------------------------------------------------------------------------
