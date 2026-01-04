----------------------------------------------------------------------------------
-- DATABASE SETUP SCRIPT (33 TABLES)
-- IMPORTANT: Run this script as the MSP user (already created and connected)
-- If the user doesn't exist, connect as sys/sysdba first and execute:
--   CREATE USER msp IDENTIFIED BY msp DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
--   GRANT CONNECT, RESOURCE TO msp;
--------------------------------------------------------------------------------

DROP USER msp CASCADE;



CREATE USER msp IDENTIFIED BY msp
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT CONNECT, RESOURCE TO msp;


CONNECT msp/msp; 

--------------------------------------------------------------------------------
-- 01. COMPANY
--------------------------------------------------------------------------------
CREATE TABLE company (
    company_id          VARCHAR2(50) PRIMARY KEY,
    company_name        VARCHAR2(200) NOT NULL UNIQUE,
    company_proprietor  VARCHAR2(200),
    phone_no            VARCHAR2(50) NOT NULL UNIQUE,
    email               VARCHAR2(200) NOT NULL UNIQUE,
    address             VARCHAR2(300),
    website             VARCHAR2(200) UNIQUE,
    contact_person      VARCHAR2(200),
    cp_designation      VARCHAR2(200),
    cp_phone_no         VARCHAR2(50),
    tag_line            VARCHAR2(300),
    mission_vision      VARCHAR2(1000),
    status              NUMBER,
    cre_by              VARCHAR2(100),
    cre_dt              DATE,
    upd_by              VARCHAR2(100),
    upd_dt              DATE
);

CREATE SEQUENCE company_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_company_bi
BEFORE INSERT OR UPDATE ON company FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate company_id only if null during INSERT
    IF INSERTING AND :NEW.company_id IS NULL THEN
        v_seq := company_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.company_name),1,3));
        :NEW.company_id := NVL(v_code, 'COM') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        -- Always stamp updater to maintain audit integrity
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 02. JOBS
--------------------------------------------------------------------------------
CREATE TABLE jobs (
    job_id       VARCHAR2(50) PRIMARY KEY,
    job_code     VARCHAR2(50),
    job_title    VARCHAR2(150),
    job_grade    VARCHAR2(1),
    min_salary   NUMBER,
    max_salary   NUMBER,
    status       NUMBER,
    cre_by       VARCHAR2(100),
    cre_dt       DATE,
    upd_by       VARCHAR2(100),
    upd_dt       DATE,
    CONSTRAINT chk_job_grade CHECK (job_grade IN ('A','B','C') OR job_grade IS NULL)
);

CREATE SEQUENCE jobs_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_jobs_bi
BEFORE INSERT OR UPDATE ON jobs FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate job_id only if null during INSERT
    IF INSERTING AND :NEW.job_id IS NULL THEN
        v_seq := jobs_seq.NEXTVAL; 
        IF :NEW.job_code IS NOT NULL THEN
            v_code := UPPER(TRIM(:NEW.job_code));
            :NEW.job_id := v_code || TO_CHAR(v_seq);
        ELSE :NEW.job_id := TO_CHAR(v_seq); END IF;
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 03. CUSTOMERS
--------------------------------------------------------------------------------
CREATE TABLE customers (
    customer_id VARCHAR2(50) PRIMARY KEY,
    phone_no      VARCHAR2(50) UNIQUE, 
    customer_name VARCHAR2(150) NOT NULL,
    alt_phone_no  VARCHAR2(50),
    email         VARCHAR2(150),
    address       VARCHAR2(300),
    city          VARCHAR2(100),
    rewards       NUMBER DEFAULT 0,
    remarks       VARCHAR2(1000),
    status        NUMBER,
    cre_by        VARCHAR2(100),
    cre_dt        DATE,
    upd_by        VARCHAR2(100),
    upd_dt        DATE
);

CREATE SEQUENCE customers_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_customers_bi
BEFORE INSERT OR UPDATE ON customers
FOR EACH ROW
DECLARE
    v_seq  NUMBER;
    v_code VARCHAR2(10);
BEGIN
    IF INSERTING AND :NEW.customer_id IS NULL THEN
        IF :NEW.phone_no IS NOT NULL THEN
            :NEW.customer_id := :NEW.phone_no;
        ELSE
            v_seq  := customers_seq.NEXTVAL;
            v_code := UPPER(SUBSTR(TRIM(:NEW.customer_name),1,3));
            :NEW.customer_id := v_code || TO_CHAR(v_seq);
        END IF;
    END IF;

    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/


--------------------------------------------------------------------------------
-- 04. PARTS_CATEGORY
--------------------------------------------------------------------------------
CREATE TABLE parts_category (
    parts_cat_id    VARCHAR2(50) PRIMARY KEY,
    parts_cat_code  VARCHAR2(50),
    parts_cat_name  VARCHAR2(150) ,
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE
);

CREATE SEQUENCE parts_cat_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_parts_cat_bi
BEFORE INSERT OR UPDATE ON parts_category FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate parts_cat_id only if null during INSERT
    IF INSERTING AND :NEW.parts_cat_id IS NULL THEN
        v_seq := parts_cat_seq.NEXTVAL;
        IF :NEW.parts_cat_code IS NOT NULL THEN
            v_code := UPPER(TRIM(:NEW.parts_cat_code));
            :NEW.parts_cat_id := v_code || TO_CHAR(v_seq);
        ELSE :NEW.parts_cat_id := TO_CHAR(v_seq); END IF;
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 05. PRODUCT_CATEGORIES
--------------------------------------------------------------------------------
CREATE TABLE product_categories (
    product_cat_id    VARCHAR2(50) PRIMARY KEY,
    product_cat_name  VARCHAR2(150) ,
    status            NUMBER,
    cre_by            VARCHAR2(100),
    cre_dt            DATE,
    upd_by            VARCHAR2(100),
    upd_dt            DATE
);

CREATE SEQUENCE prod_cat_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_prod_cat_bi
BEFORE INSERT OR UPDATE ON product_categories FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate product_cat_id only if null during INSERT
    IF INSERTING AND :NEW.product_cat_id IS NULL THEN
        v_seq := prod_cat_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.product_cat_name),1,3));
        :NEW.product_cat_id := NVL(v_code, 'CAT') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 06. BRAND
--------------------------------------------------------------------------------
CREATE TABLE brand (
    brand_id      VARCHAR2(50) PRIMARY KEY,
    brand_name    VARCHAR2(150),
    model_name    VARCHAR2(150),
    brand_size    VARCHAR2(30),
    color         VARCHAR2(50),
    status        NUMBER,
    cre_by        VARCHAR2(100),
    cre_dt        DATE,
    upd_by        VARCHAR2(100),
    upd_dt        DATE
);

CREATE SEQUENCE brand_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_brand_bi
BEFORE INSERT OR UPDATE ON brand FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate brand_id only if null during INSERT
    IF INSERTING AND :NEW.brand_id IS NULL THEN
        v_seq := brand_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.brand_name),1,3));
        :NEW.brand_id := NVL(v_code, 'BRD') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 07. SUPPLIERS
--------------------------------------------------------------------------------
CREATE TABLE suppliers (
    supplier_id    VARCHAR2(50) PRIMARY KEY,
    supplier_name  VARCHAR2(150) NOT NULL,
    phone_no       VARCHAR2(30),
    email          VARCHAR2(150),
    address        VARCHAR2(300),
    contact_person VARCHAR2(100),
    cp_designation VARCHAR2(100),
    cp_phone_no    VARCHAR2(30),
    cp_email       VARCHAR2(150),
    purchase_total NUMBER DEFAULT 0,
    pay_total      NUMBER DEFAULT 0,
    due            NUMBER GENERATED ALWAYS AS (NVL(purchase_total,0) - NVL(pay_total,0)) VIRTUAL,
    status         NUMBER,
    cre_by         VARCHAR2(100),
    cre_dt         DATE,
    upd_by         VARCHAR2(100),
    upd_dt         DATE
);

CREATE SEQUENCE suppliers_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_suppliers_bi
BEFORE INSERT OR UPDATE ON suppliers FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate supplier_id only if null during INSERT
    IF INSERTING AND :NEW.supplier_id IS NULL THEN
        v_seq := suppliers_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.supplier_name),1,3));
        :NEW.supplier_id := NVL(v_code, 'SUP') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 08. SERVICE_LIST
--------------------------------------------------------------------------------
CREATE TABLE service_list (
    servicelist_id VARCHAR2(50) PRIMARY KEY,
    service_name   VARCHAR2(150) NOT NULL,
    service_desc   VARCHAR2(1000),
    service_cost   NUMBER DEFAULT 0,
    status         NUMBER,
    cre_by         VARCHAR2(100),
    cre_dt         DATE,
    upd_by         VARCHAR2(100),
    upd_dt         DATE
);

CREATE SEQUENCE service_list_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_service_list_bi
BEFORE INSERT OR UPDATE ON service_list FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate servicelist_id only if null during INSERT
    IF INSERTING AND :NEW.servicelist_id IS NULL THEN
        v_seq := service_list_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.service_name),1,3));
        :NEW.servicelist_id := NVL(v_code, 'SRV') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 09. EXPENSE_LIST
--------------------------------------------------------------------------------
CREATE TABLE expense_list (
    expense_type_id VARCHAR2(50) PRIMARY KEY,
    expense_code    VARCHAR2(50),
    type_name       VARCHAR2(200),
    description     VARCHAR2(1000),
    default_amount  NUMBER(15,2),
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE
);

CREATE SEQUENCE exp_list_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_exp_list_bi
BEFORE INSERT OR UPDATE ON expense_list FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate expense_type_id only if null during INSERT
    IF INSERTING AND :NEW.expense_type_id IS NULL THEN
        v_seq := exp_list_seq.NEXTVAL; 
        IF :NEW.expense_code IS NOT NULL THEN
            v_code := UPPER(TRIM(:NEW.expense_code));
            :NEW.expense_type_id := v_code || TO_CHAR(v_seq);
        ELSE :NEW.expense_type_id := TO_CHAR(v_seq); END IF;
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 10. SUB_CATEGORIES
--------------------------------------------------------------------------------
CREATE TABLE sub_categories (
    sub_cat_id       VARCHAR2(50) PRIMARY KEY,
    sub_cat_name     VARCHAR2(150),
    product_cat_id   VARCHAR2(50) NULL,
    status           NUMBER,
    cre_by           VARCHAR2(100),
    cre_dt           DATE,
    upd_by           VARCHAR2(100),
    upd_dt           DATE,
    CONSTRAINT fk_subcat_prodcat FOREIGN KEY (product_cat_id) REFERENCES product_categories(product_cat_id)
);

CREATE SEQUENCE sub_cat_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_sub_cat_bi
BEFORE INSERT OR UPDATE ON sub_categories FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    IF INSERTING AND :NEW.sub_cat_id IS NULL THEN
        v_seq := sub_cat_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.sub_cat_name),1,3));
        :NEW.sub_cat_id := NVL(v_code, 'SUB') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 11. PRODUCTS
--------------------------------------------------------------------------------
CREATE TABLE products (
    product_id      VARCHAR2(50) PRIMARY KEY,
    product_code    VARCHAR2(30) ,
    product_name    VARCHAR2(150) NOT NULL,
    supplier_id     VARCHAR2(50) NULL,
    category_id     VARCHAR2(50) NULL,
    sub_cat_id      VARCHAR2(50) NULL,
    brand_id        VARCHAR2(50) NULL,
    uom             VARCHAR2(20),
    mrp             NUMBER,
    purchase_price  NUMBER,
    warranty        NUMBER, 
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_p_sup FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_p_cat FOREIGN KEY (category_id) REFERENCES product_categories(product_cat_id),
    CONSTRAINT fk_p_sub FOREIGN KEY (sub_cat_id) REFERENCES sub_categories(sub_cat_id),
    CONSTRAINT fk_p_brd FOREIGN KEY (brand_id) REFERENCES brand(brand_id)
);

CREATE SEQUENCE products_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_products_bi
BEFORE INSERT OR UPDATE ON products
FOR EACH ROW
DECLARE
    v_seq  NUMBER;
    v_code VARCHAR2(100);
BEGIN
    IF INSERTING AND :NEW.product_id IS NULL THEN
        v_seq := products_seq.NEXTVAL;
        IF :NEW.product_code IS NOT NULL THEN
            v_code := UPPER(TRIM(:NEW.product_code));
            :NEW.product_id := v_code || TO_CHAR(v_seq);
        ELSE
            :NEW.product_id := TO_CHAR(v_seq);
        END IF;
    END IF;

    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/


--------------------------------------------------------------------------------
-- 12. PARTS
--------------------------------------------------------------------------------
CREATE TABLE parts (
    parts_id       VARCHAR2(50) PRIMARY KEY,
    parts_code     VARCHAR2(50),
    parts_name     VARCHAR2(150),
    purchase_price NUMBER,
    mrp            NUMBER,
    parts_cat_id   VARCHAR2(50) NULL,
    status         NUMBER,
    cre_by         VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_parts_cat FOREIGN KEY (parts_cat_id) REFERENCES parts_category(parts_cat_id)
);

CREATE SEQUENCE parts_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_parts_bi
BEFORE INSERT OR UPDATE ON parts FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    IF INSERTING AND :NEW.parts_id IS NULL THEN
        v_seq := parts_seq.NEXTVAL;
        IF :NEW.parts_code IS NOT NULL THEN
            v_code := UPPER(TRIM(:NEW.parts_code));
            :NEW.parts_id := v_code || TO_CHAR(v_seq);
        ELSE :NEW.parts_id := TO_CHAR(v_seq); END IF;
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 13. DEPARTMENTS
--------------------------------------------------------------------------------
CREATE TABLE departments (
    department_id   VARCHAR2(50) PRIMARY KEY,
    department_name VARCHAR2(100),
    manager_id      VARCHAR2(50), 
    company_id      VARCHAR2(50) NULL,
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_dept_company FOREIGN KEY (company_id) REFERENCES company(company_id)
);

CREATE SEQUENCE departments_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

--------------------------------------------------------------------------------
-- 14. EMPLOYEES
--------------------------------------------------------------------------------
CREATE TABLE employees (
    employee_id   VARCHAR2(50) PRIMARY KEY,
    first_name    VARCHAR2(50),
    last_name     VARCHAR2(50) NOT NULL,
    email         VARCHAR2(150),
    phone_no      VARCHAR2(30),
    address       VARCHAR2(4000),
    hire_date     DATE,
    salary        NUMBER,
    job_id        VARCHAR2(50) NULL,
    manager_id    VARCHAR2(50), 
    department_id VARCHAR2(50) NULL,
    photo         BLOB,
    status        NUMBER,
    cre_by        VARCHAR2(100),
    cre_dt        DATE,
    upd_by        VARCHAR2(100),
    upd_dt        DATE,
    CONSTRAINT fk_emp_job  FOREIGN KEY (job_id) REFERENCES jobs(job_id),
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE SEQUENCE employees_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

ALTER TABLE employees ADD CONSTRAINT fk_emp_mgr
FOREIGN KEY (manager_id)
REFERENCES employees(employee_id)
DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE departments ADD CONSTRAINT fk_dept_mgr FOREIGN KEY (manager_id) REFERENCES employees(employee_id) DEFERRABLE INITIALLY DEFERRED;

CREATE OR REPLACE TRIGGER trg_departments_bi
BEFORE INSERT OR UPDATE ON departments FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate department_id only if null during INSERT
    IF INSERTING AND :NEW.department_id IS NULL THEN
        v_seq := departments_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.department_name),1,3));
        :NEW.department_id := NVL(v_code, 'DEP') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_employees_bi
BEFORE INSERT OR UPDATE ON employees FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate employee_id only if null during INSERT
    IF INSERTING AND :NEW.employee_id IS NULL THEN
        v_seq := employees_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.last_name),1,3));
        :NEW.employee_id := NVL(v_code, 'EMP') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 15. SALES_MASTER
--------------------------------------------------------------------------------
CREATE TABLE sales_master (
    invoice_id     VARCHAR2(50) PRIMARY KEY,
    invoice_date   DATE DEFAULT SYSDATE,
    discount       NUMBER DEFAULT 0,
    adjust_ref     VARCHAR2(50), 
    adjust_amount  NUMBER(20,4)DEFAULT 0,
    grand_total    NUMBER(20,4)DEFAULT 0,
    customer_id    VARCHAR2(50) NULL,
    sales_by       VARCHAR2(50) NULL,
    status         NUMBER,
    cre_by         VARCHAR2(100),
    cre_dt         DATE,
    upd_by         VARCHAR2(100),
    upd_dt         DATE,
    CONSTRAINT fk_sales_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_sales_emp  FOREIGN KEY (sales_by) REFERENCES employees(employee_id)
);

CREATE SEQUENCE sales_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_sales_master_bi
BEFORE INSERT OR UPDATE ON sales_master
FOR EACH ROW
BEGIN
    IF INSERTING AND :NEW.invoice_id IS NULL THEN
        :NEW.invoice_id := 'INV' || TO_CHAR(sales_seq.NEXTVAL);
    END IF;

    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/


--------------------------------------------------------------------------------
-- 16. SALES_RETURN_MASTER
--------------------------------------------------------------------------------
CREATE TABLE sales_return_master (
    sales_return_id VARCHAR2(50) PRIMARY KEY,
    invoice_id      VARCHAR2(50) NULL, 
    customer_id  VARCHAR2(50) NULL,
    return_date     DATE DEFAULT SYSDATE,
    total_amount    NUMBER(20,4)DEFAULT 0,
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_srm_inv   FOREIGN KEY (invoice_id) REFERENCES sales_master(invoice_id),
    CONSTRAINT fk_srm_cust  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE SEQUENCE sales_ret_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_sales_ret_bi
BEFORE INSERT OR UPDATE ON sales_return_master FOR EACH ROW
BEGIN
    -- Generate sales_return_id only if null during INSERT
    IF INSERTING AND :NEW.sales_return_id IS NULL THEN
        :NEW.sales_return_id := 'SRT' || TO_CHAR(sales_ret_seq.NEXTVAL);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

ALTER TABLE sales_master ADD CONSTRAINT fk_sales_adjust FOREIGN KEY (adjust_ref) REFERENCES sales_return_master(sales_return_id);

--------------------------------------------------------------------------------
-- 17. SERVICE_MASTER
--------------------------------------------------------------------------------
CREATE TABLE service_master (
    service_id          VARCHAR2(50) PRIMARY KEY,
    service_date        DATE DEFAULT SYSDATE,
    customer_id         VARCHAR2(50) NULL,
    invoice_id          VARCHAR2(50) NULL, 
    warranty_applicable CHAR(1),
    servicelist_id      VARCHAR2(50) NULL,
    service_by          VARCHAR2(50) NULL,
    service_charge      NUMBER DEFAULT 0,
    parts_price         NUMBER DEFAULT 0,
    total_price         NUMBER(20,4)DEFAULT 0,
    vat                 NUMBER(20,4)DEFAULT 0,
    grand_total         NUMBER(20,4)DEFAULT 0,
    status              NUMBER,
    cre_by              VARCHAR2(100),
    cre_dt              DATE,
    upd_by              VARCHAR2(100),
    upd_dt              DATE,
    CONSTRAINT fk_sm_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_sm_list FOREIGN KEY (servicelist_id) REFERENCES service_list(servicelist_id),
    CONSTRAINT fk_sm_emp  FOREIGN KEY (service_by) REFERENCES employees(employee_id),
    CONSTRAINT fk_sm_inv  FOREIGN KEY (invoice_id) REFERENCES sales_master(invoice_id)
);

CREATE SEQUENCE service_master_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

--------------------------------------------------------------------------------
-- 18. PRODUCT_ORDER_MASTER 
--------------------------------------------------------------------------------
CREATE TABLE product_order_master (
    order_id      VARCHAR2(50) PRIMARY KEY,
    order_date    DATE DEFAULT SYSDATE,
    supplier_id   VARCHAR2(50) NULL,
    expected_delivery_date DATE,
    order_by      VARCHAR2(50) NULL, 
    total_amount  NUMBER(20,4)DEFAULT 0,
    Vat           NUMBER(20,4)DEFAULT 0,
    Grand_total   NUMBER(20,4)DEFAULT 0,
    status        NUMBER,
    cre_by        VARCHAR2(100),
    cre_dt        DATE,
    upd_by        VARCHAR2(100),
    upd_dt        DATE,
    CONSTRAINT fk_pom_sup  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_pom_emp  FOREIGN KEY (order_by) REFERENCES employees(employee_id)
);

CREATE SEQUENCE order_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_prod_order_bi
BEFORE INSERT OR UPDATE ON product_order_master FOR EACH ROW
BEGIN
    -- Generate order_id only if null during INSERT
    IF INSERTING AND :NEW.order_id IS NULL THEN
        :NEW.order_id := 'ORD' || TO_CHAR(order_seq.NEXTVAL);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 19. PRODUCT_RECEIVE_MASTER 
--------------------------------------------------------------------------------
CREATE TABLE product_receive_master (
    receive_id      VARCHAR2(50) PRIMARY KEY,
    receive_date    DATE DEFAULT SYSDATE,
    order_id        VARCHAR2(50) NULL,
    sup_invoice_id  VARCHAR2(50) UNIQUE,
    supplier_id     VARCHAR2(50) NULL, 
    received_by     VARCHAR2(50) NULL, 
    total_amount    NUMBER(20,4)DEFAULT 0,
    vat             NUMBER(20,4)DEFAULT 0, 
    grand_total     NUMBER(20,4)DEFAULT 0,   
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_pr_emp FOREIGN KEY (received_by) REFERENCES employees(employee_id),
    CONSTRAINT fk_pr_sup FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_pr_order FOREIGN KEY (order_id) REFERENCES product_order_master(order_id)
);

CREATE SEQUENCE receive_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_prod_recv_bi
BEFORE INSERT OR UPDATE ON product_receive_master FOR EACH ROW
DECLARE
    v_seq NUMBER;
BEGIN
    -- Generate receive_id only if null during INSERT
    IF INSERTING AND :NEW.receive_id IS NULL THEN
        v_seq := receive_seq.NEXTVAL;
        :NEW.receive_id := 'RCV' || TO_CHAR(v_seq);
        -- Auto-generate supplier invoice ID if not provided
        IF :NEW.sup_invoice_id IS NULL THEN
            :NEW.sup_invoice_id := 'SINV' || TO_CHAR(v_seq);
        END IF;
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 20. PRODUCT_RETURN_MASTER 
--------------------------------------------------------------------------------
CREATE TABLE product_return_master (
    return_id       VARCHAR2(50) PRIMARY KEY,
    supplier_id     VARCHAR2(50) NULL,
    receive_id      VARCHAR2(50) NULL,
    order_id        VARCHAR2(50) NULL,
    return_date     DATE DEFAULT SYSDATE,
    return_by       VARCHAR2(50) NULL, 
    total_amount    NUMBER(20,4)DEFAULT 0,
    adjusted_vat    NUMBER(20,4)DEFAULT 0, 
    grand_total     NUMBER(20,4)DEFAULT 0,
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_pre_sup FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_pre_rcv FOREIGN KEY (receive_id) REFERENCES product_receive_master(receive_id),
    CONSTRAINT fk_pre_order FOREIGN KEY (order_id) REFERENCES product_order_master(order_id),
    CONSTRAINT fk_pre_emp FOREIGN KEY (return_by) REFERENCES employees(employee_id)
);

CREATE SEQUENCE prod_ret_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_prod_ret_bi
BEFORE INSERT OR UPDATE ON product_return_master FOR EACH ROW
BEGIN
    -- Generate return_id only if null during INSERT
    IF INSERTING AND :NEW.return_id IS NULL THEN
        :NEW.return_id := 'PRT' || TO_CHAR(prod_ret_seq.NEXTVAL);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 21. DAMAGE
--------------------------------------------------------------------------------
CREATE TABLE damage (
    damage_id    VARCHAR2(50) PRIMARY KEY,
    damage_date  DATE DEFAULT SYSDATE,
    total_loss   NUMBER DEFAULT 0,
    status       NUMBER,
    cre_by       VARCHAR2(100),
    cre_dt       DATE,
    upd_by       VARCHAR2(100),
    upd_dt       DATE
);

CREATE SEQUENCE damage_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_damage_bi
BEFORE INSERT OR UPDATE ON damage FOR EACH ROW
BEGIN
    -- Generate damage_id only if null during INSERT
    IF INSERTING AND :NEW.damage_id IS NULL THEN
        :NEW.damage_id := 'DMG' || TO_CHAR(damage_seq.NEXTVAL);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 22. STOCK
--------------------------------------------------------------------------------
CREATE TABLE stock (
    stock_id        VARCHAR2(50) PRIMARY KEY,
    product_id      VARCHAR2(50) NULL,
    supplier_id     VARCHAR2(50) NULL,
    product_cat_id  VARCHAR2(50) NULL,
    sub_cat_id      VARCHAR2(50) NULL,
    quantity        NUMBER DEFAULT 0,
    last_update     TIMESTAMP DEFAULT SYSTIMESTAMP,
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_s_p   FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_s_sup FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_prod_cat FOREIGN KEY (product_cat_id) REFERENCES product_categories(product_cat_id),
    CONSTRAINT chk_stock_qty CHECK (quantity >= 0)
);

CREATE SEQUENCE stock_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_stock_bi
BEFORE INSERT OR UPDATE ON stock FOR EACH ROW
BEGIN
    -- Generate stock_id only if null during INSERT
    IF INSERTING AND :NEW.stock_id IS NULL THEN
        :NEW.stock_id := 'STK' || TO_CHAR(stock_seq.NEXTVAL);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF; 
    ELSIF UPDATING THEN
        :NEW.last_update := SYSTIMESTAMP; 
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 23. SERVICE_DETAILS
--------------------------------------------------------------------------------
CREATE TABLE service_details (
    service_det_id     VARCHAR2(50) PRIMARY KEY,
    service_id         VARCHAR2(50) NULL,
    product_id         VARCHAR2(50) NULL, 
    parts_id           VARCHAR2(50) NULL,
    parts_price        NUMBER DEFAULT 0,
    quantity           NUMBER DEFAULT 1, 
    line_total         NUMBER DEFAULT 0,
    description        VARCHAR2(1000), 
    warranty_status    VARCHAR2(50),
    CONSTRAINT fk_sd_master FOREIGN KEY (service_id) REFERENCES service_master(service_id),
    CONSTRAINT fk_sd_parts  FOREIGN KEY (parts_id) REFERENCES parts(parts_id),
    CONSTRAINT fk_sd_prod   FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE service_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_service_det_bi BEFORE INSERT ON service_details FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.service_det_id IS NULL THEN
	:NEW.service_det_id := 'SDT' || TO_CHAR(service_det_seq.NEXTVAL);  
END IF;
END;
/

-- Keep service_master audit columns current when any service detail changes
CREATE OR REPLACE TRIGGER trg_service_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON service_details
FOR EACH ROW
DECLARE
    v_service_id service_details.service_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_service_id := :NEW.service_id;
    ELSE
        v_service_id := :OLD.service_id;
    END IF;

    UPDATE service_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE service_id = v_service_id;
END;
/

--------------------------------------------------------------------------------
-- 24. SALES_DETAIL
--------------------------------------------------------------------------------
CREATE TABLE sales_detail (
    sales_det_id   VARCHAR2(50) PRIMARY KEY,
    invoice_id     VARCHAR2(50) NULL,
    product_id     VARCHAR2(50) NULL,
    mrp            NUMBER,
    purchase_price NUMBER,
    quantity       NUMBER,
    vat            NUMBER(10,4) DEFAULT 0,
    description    VARCHAR2(1000), 
    CONSTRAINT fk_sdt_inv  FOREIGN KEY (invoice_id) REFERENCES sales_master(invoice_id) ON DELETE CASCADE,
    CONSTRAINT fk_sdt_prod FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE sales_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_sales_det_bi BEFORE INSERT ON sales_detail FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.sales_det_id IS NULL THEN
	:NEW.sales_det_id := 'SLD' || TO_CHAR(sales_det_seq.NEXTVAL); 
END IF;
END;
/

-- Keep sales_master audit columns current when any sales detail changes
CREATE OR REPLACE TRIGGER trg_sales_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON sales_detail
FOR EACH ROW
DECLARE
    v_invoice_id sales_detail.invoice_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_invoice_id := :NEW.invoice_id;
    ELSE
        v_invoice_id := :OLD.invoice_id;
    END IF;

    UPDATE sales_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE invoice_id = v_invoice_id;
END;
/

--------------------------------------------------------------------------------
-- 25. SALES_RETURN_DETAILS
--------------------------------------------------------------------------------
CREATE TABLE sales_return_details (
    sales_return_det_id VARCHAR2(50) PRIMARY KEY,
    sales_return_id     VARCHAR2(50) NULL,
    product_id          VARCHAR2(50) NULL,
    mrp                 NUMBER,
    purchase_price      NUMBER,
    qty_return          NUMBER,
    reason              VARCHAR2(4000),
    CONSTRAINT fk_srd_mst FOREIGN KEY (sales_return_id) REFERENCES sales_return_master(sales_return_id),
    CONSTRAINT fk_srd_prd FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE sales_ret_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_sales_ret_det_bi BEFORE INSERT ON sales_return_details FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.sales_return_det_id IS NULL THEN
	:NEW.sales_return_det_id := 'SRD' || TO_CHAR(sales_ret_det_seq.NEXTVAL); 
END IF;
END;
/

-- Keep sales_return_master audit columns current when any return detail changes
CREATE OR REPLACE TRIGGER trg_sales_ret_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON sales_return_details
FOR EACH ROW
DECLARE
    v_sales_return_id sales_return_details.sales_return_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_sales_return_id := :NEW.sales_return_id;
    ELSE
        v_sales_return_id := :OLD.sales_return_id;
    END IF;

    UPDATE sales_return_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE sales_return_id = v_sales_return_id;
END;
/

--------------------------------------------------------------------------------
-- 26. PRODUCT_ORDER_DETAIL
--------------------------------------------------------------------------------
CREATE TABLE product_order_detail (
    order_detail_id VARCHAR2(50) PRIMARY KEY,
    order_id        VARCHAR2(50) NULL,
    product_id      VARCHAR2(50) NULL,
    mrp             NUMBER, 
    purchase_price  NUMBER, 
    quantity        NUMBER,
    CONSTRAINT fk_pod_mst FOREIGN KEY (order_id) REFERENCES product_order_master(order_id),
    CONSTRAINT fk_pod_prd FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE order_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER trg_order_det_bi BEFORE INSERT ON product_order_detail FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.order_detail_id IS NULL THEN
	:NEW.order_detail_id := 'ODT' || TO_CHAR(order_det_seq.NEXTVAL); 
END IF;
END;
/

-- Keep product_order_master audit columns current when any order detail changes
CREATE OR REPLACE TRIGGER trg_order_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON product_order_detail
FOR EACH ROW
DECLARE
    v_order_id product_order_detail.order_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_order_id := :NEW.order_id;
    ELSE
        v_order_id := :OLD.order_id;
    END IF;

    UPDATE product_order_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE order_id = v_order_id;
END;
/

--------------------------------------------------------------------------------
-- 27. PRODUCT_RECEIVE_DETAILS
--------------------------------------------------------------------------------
CREATE TABLE product_receive_details (
    receive_det_id   VARCHAR2(50) PRIMARY KEY,
    receive_id       VARCHAR2(50) NULL,
    product_id       VARCHAR2(50) NULL,
    mrp              NUMBER,             
    purchase_price   NUMBER,             
    receive_quantity NUMBER,
    CONSTRAINT fk_prd_mst FOREIGN KEY (receive_id) REFERENCES product_receive_master(receive_id),
    CONSTRAINT fk_prd_prd FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE recv_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER trg_recv_det_bi BEFORE INSERT ON product_receive_details FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.receive_det_id IS NULL THEN
 :NEW.receive_det_id := 'RDT' || TO_CHAR(recv_det_seq.NEXTVAL); 
END IF;
END;
/

-- Keep product_receive_master audit columns current when any receive detail changes
CREATE OR REPLACE TRIGGER trg_recv_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON product_receive_details
FOR EACH ROW
DECLARE
    v_receive_id product_receive_details.receive_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_receive_id := :NEW.receive_id;
    ELSE
        v_receive_id := :OLD.receive_id;
    END IF;

    UPDATE product_receive_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE receive_id = v_receive_id;
END;
/

CREATE OR REPLACE TRIGGER trg_validate_receive_direct
BEFORE INSERT OR UPDATE ON product_receive_details
FOR EACH ROW
DECLARE
    v_order_qty NUMBER := 0;
    v_order_id VARCHAR2(50);
BEGIN
    -- 1. Get the order_id for this receive
    SELECT order_id INTO v_order_id
    FROM product_receive_master
    WHERE receive_id = :NEW.receive_id
    AND ROWNUM = 1;

    -- 2. Sum all quantities for this product in the order (handles multiple line items)
    SELECT NVL(SUM(quantity), 0)
    INTO   v_order_qty
    FROM   product_order_detail
    WHERE  order_id = v_order_id
    AND    product_id = :NEW.product_id;

    -- 3. Validate quantity
    IF v_order_qty = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error: This product was not found in the original order.');
    ELSIF :NEW.receive_quantity > v_order_qty THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Invalid Quantity! You cannot receive ' || :NEW.receive_quantity ||
            ' because the original order was only for ' || v_order_qty);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error: Receive record or order not found.');
END;
/

--------------------------------------------------------------------------------
-- 28. PRODUCT_RETURN_DETAILS
--------------------------------------------------------------------------------
CREATE TABLE product_return_details (
    return_detail_id VARCHAR2(50) PRIMARY KEY,
    return_id        VARCHAR2(50) NULL,
    product_id       VARCHAR2(50) NULL,
    mrp              NUMBER,             
    purchase_price   NUMBER,             
    return_quantity  NUMBER, 
    reason           VARCHAR2(1000),
    CONSTRAINT fk_prdet_mst FOREIGN KEY (return_id) REFERENCES product_return_master(return_id),
    CONSTRAINT fk_prdet_prd FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE prod_ret_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_prod_ret_det_bi BEFORE INSERT ON product_return_details FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.return_detail_id IS NULL THEN
:NEW.return_detail_id := 'PRD' || TO_CHAR(prod_ret_det_seq.NEXTVAL); 
END IF;
END;
/

-- Keep product_return_master audit columns current when any return detail changes
CREATE OR REPLACE TRIGGER trg_prod_ret_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON product_return_details
FOR EACH ROW
DECLARE
    v_return_id product_return_details.return_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_return_id := :NEW.return_id;
    ELSE
        v_return_id := :OLD.return_id;
    END IF;

    UPDATE product_return_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE return_id = v_return_id;
END;
/

--------------------------------------------------------------------------------
-- 29. EXPENSE_MASTER
--------------------------------------------------------------------------------
CREATE TABLE expense_master (
    expense_id      VARCHAR2(50) PRIMARY KEY,
    expense_date    DATE,
    expense_by      VARCHAR2(100) NULL,
    expense_type_id VARCHAR2(50) NULL,
    remarks         VARCHAR2(1000),
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_ex_mst FOREIGN KEY (expense_type_id) REFERENCES expense_list(expense_type_id)
);

CREATE SEQUENCE exp_mst_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER trg_exp_mst_bi BEFORE INSERT OR UPDATE ON expense_master FOR EACH ROW
BEGIN
    -- Generate expense_id only if null during INSERT
    IF INSERTING AND :NEW.expense_id IS NULL THEN
        :NEW.expense_id := 'EXM' || TO_CHAR(exp_mst_seq.NEXTVAL); 
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 30. EXPENSE_DETAILS
--------------------------------------------------------------------------------
CREATE TABLE expense_details (
    expense_det_id    VARCHAR2(50) PRIMARY KEY,
    expense_id        VARCHAR2(50) NOT NULL,
    expense_type_id   VARCHAR2(50) NOT NULL,
    description       VARCHAR2(1000),
    amount            NUMBER(15,2) DEFAULT 0,
    quantity          NUMBER DEFAULT 1,
    line_total        NUMBER(15,2),
    CONSTRAINT fk_ex_det_mst FOREIGN KEY (expense_id) REFERENCES expense_master(expense_id),
    CONSTRAINT fk_ex_det_typ FOREIGN KEY (expense_type_id) REFERENCES expense_list(expense_type_id)
);

CREATE SEQUENCE exp_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER trg_exp_det_bi BEFORE INSERT OR UPDATE ON expense_details FOR EACH ROW
DECLARE v_seq NUMBER;
BEGIN 
    IF INSERTING AND :NEW.expense_det_id IS NULL THEN
        v_seq := exp_det_seq.NEXTVAL;
        :NEW.expense_det_id := 'EXD' || TO_CHAR(v_seq);
    END IF;
    :NEW.line_total := NVL(:NEW.amount,0) * NVL(:NEW.quantity,1); 
END;
/

-- Keep expense_master audit columns current when any detail row changes
CREATE OR REPLACE TRIGGER trg_exp_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON expense_details
FOR EACH ROW
DECLARE
    v_expense_id expense_details.expense_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_expense_id := :NEW.expense_id;
    ELSE
        v_expense_id := :OLD.expense_id;
    END IF;

    UPDATE expense_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE expense_id = v_expense_id;
END;
/

--------------------------------------------------------------------------------
-- 31. DAMAGE_DETAIL 
--------------------------------------------------------------------------------
CREATE TABLE damage_detail (
    damage_detail_id VARCHAR2(50) PRIMARY KEY,
    damage_id        VARCHAR2(50),
    product_id       VARCHAR2(50),
    mrp              NUMBER,
    purchase_price   NUMBER,
    damage_quantity  NUMBER,
    reason           VARCHAR2(1000),
    CONSTRAINT fk_dmg_mst FOREIGN KEY (damage_id) REFERENCES damage(damage_id),
    CONSTRAINT fk_dmg_prd FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE damage_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER trg_damage_det_bi BEFORE INSERT ON damage_detail FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.damage_detail_id IS NULL THEN
:NEW.damage_detail_id := 'DDT' || TO_CHAR(damage_det_seq.NEXTVAL);
END IF; 
END;
/

-- Keep damage master audit columns current when any damage detail changes
CREATE OR REPLACE TRIGGER trg_damage_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON damage_detail
FOR EACH ROW
DECLARE
    v_damage_id damage_detail.damage_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_damage_id := :NEW.damage_id;
    ELSE
        v_damage_id := :OLD.damage_id;
    END IF;

    UPDATE damage
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE damage_id = v_damage_id;
END;
/

--------------------------------------------------------------------------------
-- 32. COM_USERS
--------------------------------------------------------------------------------
CREATE TABLE com_users (
    user_id     VARCHAR2(50) PRIMARY KEY,
    user_name   VARCHAR2(100) NOT NULL UNIQUE,
    password    VARCHAR2(200) NOT NULL,
    role        VARCHAR2(50) DEFAULT 'user' NOT NULL,
    employee_id VARCHAR2(50),
    status      NUMBER,
    cre_by      VARCHAR2(100),
    cre_dt      DATE,
    upd_by      VARCHAR2(100),
    upd_dt      DATE,
    CONSTRAINT fk_users_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE SET NULL
);

CREATE SEQUENCE users_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_users_bi
BEFORE INSERT OR UPDATE ON com_users FOR EACH ROW
DECLARE 
    v_seq NUMBER; 
    v_code VARCHAR2(100);
BEGIN
    -- Generate user_id only if null during INSERT
    IF INSERTING AND :NEW.user_id IS NULL THEN
        v_seq := users_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.user_name), 1, 3));
        :NEW.user_id := NVL(v_code, 'USR') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 33. PAYMENTS
--------------------------------------------------------------------------------
CREATE TABLE payments (
    payment_id   VARCHAR2(50) PRIMARY KEY,
    payment_date DATE NOT NULL,
    amount       NUMBER NOT NULL CHECK (amount > 0),
    supplier_id  VARCHAR2(50) REFERENCES suppliers(supplier_id),
    payment_type VARCHAR2(50),
    CONSTRAINT chk_payment_type CHECK (UPPER(payment_type) IN ('CASH','ONLINE','BANK'))
);

CREATE SEQUENCE payments_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER trg_payments_bi BEFORE INSERT OR UPDATE ON payments FOR EACH ROW
BEGIN
    IF INSERTING AND :NEW.payment_id IS NULL THEN
        :NEW.payment_id := 'PAY' || TO_CHAR(payments_seq.NEXTVAL);
    END IF;
END;
/

-- Keep suppliers audit columns current when any payment row changes
CREATE OR REPLACE TRIGGER trg_payments_supplier_audit
AFTER INSERT OR UPDATE OR DELETE ON payments
FOR EACH ROW
DECLARE
    v_supplier_id payments.supplier_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_supplier_id := :NEW.supplier_id;
    ELSE
        v_supplier_id := :OLD.supplier_id;
    END IF;

    IF v_supplier_id IS NOT NULL THEN
        UPDATE suppliers
        SET upd_by = USER,
            upd_dt = SYSDATE
        WHERE supplier_id = v_supplier_id;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 17(a).SERVICE MASTER TRIGGER HERE 
--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_service_master_bi
BEFORE INSERT OR UPDATE ON service_master
FOR EACH ROW
DECLARE 
    v_inv_date DATE; 
    v_warranty NUMBER;
BEGIN
    -- ID generation (SAFE)
    IF INSERTING AND :NEW.service_id IS NULL THEN
        :NEW.service_id := 'SVM' || TO_CHAR(service_master_seq.NEXTVAL);
    END IF;

    -- Audit columns
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;

    -- Warranty logic (SAFE)
    IF INSERTING AND :NEW.invoice_id IS NOT NULL THEN
        BEGIN
            SELECT m.invoice_date, p.warranty
            INTO v_inv_date, v_warranty
            FROM sales_master m
            JOIN sales_detail d ON m.invoice_id = d.invoice_id
            JOIN products p ON d.product_id = p.product_id
            WHERE m.invoice_id = :NEW.invoice_id
            AND ROWNUM = 1;

            IF v_inv_date + (v_warranty * 30) >= SYSDATE THEN
                :NEW.warranty_applicable := 'Y';
            ELSE
                :NEW.warranty_applicable := 'N';
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                :NEW.warranty_applicable := 'N';
        END;
    END IF;
END;
/
-------------------------------------------------------------

-- Infrastructure (01, 02, 13, 14)
INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Walton Plaza', 'Walton Hi-Tech Industries Ltd.', '01711000001', 'info@waltonplaza.com',
 'Plot-1088, Block-I, Bashundhara R/A, Dhaka', 'https://www.waltonplaza.com',
 'Rafiqul Islam', 'Regional Manager', '01711000091',
 'Your Trusted Electronics Partner',
 'To deliver advanced technology and reliable service nationwide.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Singer Bangladesh', 'Singer Bangladesh Ltd.', '01711000002', 'contact@singerbd.com',
 '89 Gulshan Avenue, Dhaka', 'https://www.singerbd.com',
 'Mahmud Hasan', 'Sales Manager', '01711000092',
 'Trusted Since 1905',
 'Providing quality electronics with after-sales excellence.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Vision Electronics', 'RFL Group', '01711000003', 'support@vision.com.bd',
 'PRAN-RFL Center, Badda, Dhaka', 'https://www.vision.com.bd',
 'Sajjad Hossain', 'Service Head', '01711000093',
 'Smart Life Smart Vision',
 'To bring innovative electronics to every home.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Jamuna Electronics', 'Jamuna Group', '01711000004', 'info@jamunaelectronics.com',
 'Jamuna Future Park, Dhaka', 'https://www.jamunaelectronics.com',
 'Abdul Karim', 'Area Manager', '01711000094',
 'Innovation for Better Life',
 'Expanding electronics solutions with nationwide coverage.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Minister Hi-Tech Park', 'Minister Group', '01711000005', 'service@ministerbd.com',
 'House-47, Road-35, Gulshan-2, Dhaka', 'https://www.ministerbd.com',
 'Shariful Islam', 'Service Coordinator', '01711000095',
 'Desh er TV',
 'To ensure quality electronics Made in Bangladesh.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('LG Electronics Bangladesh', 'LG Corporation', '01711000006', 'bd.info@lge.com',
 'Gulshan 1, Dhaka', 'https://www.lg.com/bd',
 'Tanvir Ahmed', 'Corporate Sales', '01711000096',
 'Life’s Good',
 'Enhancing lifestyle with smart electronics.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Samsung Consumer Electronics', 'Samsung Bangladesh', '01711000007', 'support@samsungbd.com',
 'Banani, Dhaka', 'https://www.samsung.com/bd',
 'Naeem Rahman', 'Channel Manager', '01711000097',
 'Inspire the World',
 'Delivering innovation and premium technology.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Sharp Electronics BD', 'Esquire Electronics Ltd.', '01711000008', 'info@sharpelectronics.com.bd',
 'Tejgaon I/A, Dhaka', 'https://www.sharpelectronicsbd.com',
 'Rezaul Karim', 'Service Manager', '01711000098',
 'Technology You Can Trust',
 'Delivering reliable consumer electronics nationwide.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Hitachi Home Appliances', 'Hitachi Bangladesh', '01711000009', 'contact@hitachibd.com',
 'Kawran Bazar, Dhaka', 'https://www.hitachibd.com',
 'Masud Rana', 'Key Account Manager', '01711000099',
 'Inspire the Next',
 'Delivering durable appliances with best service support.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Transtec Electronics', 'Bangladesh Lamps Ltd.', '01711000010', 'info@transtec.com.bd',
 'Tejgaon Industrial Area, Dhaka', 'https://www.transtec.com.bd',
 'Ahsan Kabir', 'Regional Supervisor', '01711000100',
 'Powering Everyday Life',
 'Providing affordable and quality electronics.', 1);

--JOBS

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('SALES', 'Sales Executive', 'B', 18000, 30000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('CSUP', 'Customer Support Officer', 'B', 20000, 35000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('TECH', 'Service Technician', 'B', 22000, 40000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('MGR', 'Branch Manager', 'A', 40000, 65000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('ASM', 'Assistant Manager', 'A', 32000, 50000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('ACC', 'Accounts Officer', 'B', 25000, 42000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('STOR', 'Store Keeper', 'C', 15000, 25000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('DLV', 'Delivery Man', 'C', 12000, 20000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('IT', 'IT Support Officer', 'B', 28000, 45000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('HR', 'HR and Admin Officer', 'A', 35000, 55000);

----
INSERT INTO customers (phone_no, customer_name, alt_phone_no, email, address, city, remarks)
VALUES ('01810000001','Md. Rakib Hasan','01820000001','rakib01@gmail.com','Mirpur-10, Dhaka','Dhaka','Regular customer');

INSERT INTO customers (phone_no, customer_name, alt_phone_no, email, address, city)
VALUES ('01810000002','Sadia Akter','01820000002','sadia.bd@gmail.com','Dhanmondi 32','Dhaka');

INSERT INTO customers (phone_no, customer_name, alt_phone_no, email, address, city)
VALUES ('01810000003','Mahmudul Hasan',NULL,'mahmud.hasan@yahoo.com','Uttara Sector 7','Dhaka');

INSERT INTO customers (phone_no, customer_name, email, address, city, remarks)
VALUES ('01810000004','Shafiq Ahmed','shafiq454@gmail.com','Nandan Park Road','Savar','Buys TV frequently');

INSERT INTO customers (phone_no, customer_name, email, address, city)
VALUES ('01810000005','Rumi Chowdhury','rumi.c@gmail.com','Halishahar','Chattogram');

INSERT INTO customers (phone_no, customer_name, alt_phone_no, email, address, city)
VALUES ('01810000006','Nazmul Islam','01820000006','nazmul_bd@gmail.com','Rajshahi City','Rajshahi');

INSERT INTO customers (phone_no, customer_name, email, address, city, remarks)
VALUES ('01810000007','Kamal Hossain','kamal.h@gmail.com','Khulna Sadar','Khulna','Warranty service user');

INSERT INTO customers (phone_no, customer_name, email, address, city)
VALUES ('01810000008','Farhana Yasmin','farhana88@gmail.com','Sylhet Ambarkhana','Sylhet');

INSERT INTO customers (phone_no, customer_name, email, address, city)
VALUES ('01810000009','Arif Mahmud','arifm@gmail.com','Cumilla Town','Cumilla');

INSERT INTO customers (phone_no, customer_name, email, address, city, remarks)
VALUES ('01810000010','Majedul Karim','majed.karim@gmail.com','Barisal Notun Bazar','Barisal','VIP Customer');
--------------------------------------------------------------------------------
-- 04. Parts_CATEGORIES (Master)
--------------------------------------------------------------------------------
INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('TV', 'Television Spare Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('FRG', 'Refrigerator Spare Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('AC', 'Air Conditioner Spare Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('WM', 'Washing Machine Spare Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('MIC', 'Microwave Oven Spare Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('MOB', 'Mobile Accessories and Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('LAP', 'Laptop and Computer Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('AUDIO', 'Audio System Spare Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('PWR', 'Power Supply and Boards');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('GEN', 'General Electronic Components');

--------------------------------------------------------------------------------
-- 05. PRODUCT_CATEGORIES (Master)
--------------------------------------------------------------------------------

INSERT INTO product_categories (product_cat_name)
VALUES ('LED Television');

INSERT INTO product_categories (product_cat_name)
VALUES ('Refrigerator and Freezer');

INSERT INTO product_categories (product_cat_name)
VALUES ('Air Conditioner');

INSERT INTO product_categories (product_cat_name)
VALUES ('Washing Machine');

INSERT INTO product_categories (product_cat_name)
VALUES ('Microwave Oven');

INSERT INTO product_categories (product_cat_name)
VALUES ('Smart Phone');

INSERT INTO product_categories (product_cat_name)
VALUES ('Laptop and Computer');

INSERT INTO product_categories (product_cat_name)
VALUES ('Home Theater and Sound System');

INSERT INTO product_categories (product_cat_name)
VALUES ('Small Home Appliances');

INSERT INTO product_categories (product_cat_name)
VALUES ('Generator and Power Products');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Walton', 'WD-LED32F', '32 Inch', 'Black');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Walton', 'WTM-RT240', '240 Liter', 'Silver');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Samsung', 'UA43T5400', '43 Inch', 'Black');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Samsung', 'AR12MVF', '1 Ton', 'White');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('LG', 'GL-B201SLBB', '190 Liter', 'Silver');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('LG', 'LG-WM140', '8 Kg', 'White');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Singer', 'Singer Smart 32', '32 Inch', 'Black');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Hitachi', 'RAS-F13CF', '1 Ton', 'White');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Vision', 'VIS-24UD', '24 Inch', 'Black');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Minister', 'M-DFR-240', '240 Liter', 'Red');


INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email, purchase_total, pay_total)
VALUES
('Walton Spare Parts Division','01715000001','spares@waltonbd.com','Bashundhara Industrial Area, Dhaka',
 'Abdul Karim','Procurement Manager','01716000001','karim@waltonbd.com', 500000, 350000);

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email, purchase_total, pay_total)
VALUES
('Samsung Authorized Distributor','01715000002','dist@samsungbd.com','Banani, Dhaka',
 'Tanvir Ahmed','Supply Lead','01716000002','tanvir@samsungbd.com', 650000, 400000);

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email, purchase_total, pay_total)
VALUES
('LG Electronics Supplier','01715000003','supplier@lgbd.com','Gulshan-1, Dhaka',
 'Ruhul Amin','Account Manager','01716000003','amin@lgbd.com', 300000, 200000);

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email, purchase_total, pay_total)
VALUES
('Vision / RFL Parts Supplier','01715000004','vision.parts@rfl.com','Badda, Dhaka',
 'Shahadat Hossain','Parts Coordinator','01716000004','shahadat@rfl.com', 250000, 150000);

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email, purchase_total, pay_total)
VALUES
('Minister Hi-Tech Supplier','01715000005','supplier@minister.com','Gulshan-2, Dhaka',
 'Nazmul Islam','Logistics Lead','01716000005','nazmul@minister.com', 180000, 70000);

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email, purchase_total, pay_total)
VALUES
('Jamuna Electronics Supplier','01715000006','jamuna.supplier@gmail.com','Jamuna Future Park, Dhaka',
 'Faruk Ahmed','Senior Buyer','01716000006','faruk@jamuna.com', 200000, 120000);

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email, purchase_total, pay_total)
VALUES
('Global Electronics Importer','01715000007','import@globalelec.com','Chawk Bazar, Dhaka',
 'Kamal Uddin','Import Manager','01716000007','kamal@globalelec.com', 450000, 250000);

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email, purchase_total, pay_total)
VALUES
('Asian Spare Parts House','01715000008','asianparts@gmail.com','Elephant Road, Dhaka',
 'Sharif Al Mamun','Owner','01716000008','sharif@asparts.com', 120000, 60000);

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email, purchase_total, pay_total)
VALUES
('Bangladesh Electronics Wholesale','01715000009','info@bdwholesale.com','Station Road, Chattogram',
 'Jahangir Alam','Wholesale Manager','01716000009','jahangir@bdwholesale.com', 350000, 230000);

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email, purchase_total, pay_total)
VALUES
('City Electronics Parts Supplier','01715000010','cityparts@gmail.com','Sylhet Amberkhana',
 'Shafiq Rahman','Parts Manager','01716000010','shafiq@cityparts.com', 160000, 100000);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('TV Installation', 'Wall mount / table stand TV installation service', 800);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('TV Repair Service', 'LED/LCD television diagnosis and repair service', 1500);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Refrigerator Repair', 'Cooling issue, compressor issue, gas refill and repair', 2000);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('AC Installation', 'Indoor and outdoor AC installation with basic setup', 3500);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('AC Servicing', 'AC cleaning, gas checking, maintenance and servicing', 1500);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Washing Machine Repair', 'Repair and maintenance of automatic/manual washing machines', 1800);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Microwave Oven Repair', 'Heating problem / board problem repair service', 1200);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Laptop / Computer Repair', 'Hardware, software, OS and chip level checkup', 2000);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Mobile Service and Repair', 'Smartphone software and hardware problem fixing', 1000);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Home Appliance Diagnosis', 'General diagnosis and checking charge for appliances', 500);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('OFF', 'Office Rent', 'Monthly office/shop rent expense', 30000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('SAL', 'Staff Salary', 'Technician, sales and support staff salary expense', 80000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('UTL', 'Utility Bills', 'Electricity, gas and water bill payment', 15000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('INT', 'Internet and Telephone Bill', 'Office internet and phone bills', 5000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('TRN', 'Transport and Delivery Cost', 'Product delivery and technician transport', 12000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('MKT', 'Marketing and Promotion', 'Advertisement, banner and promotion expense', 10000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('REP', 'Office Repair and Maintenance', 'Shop/office repairing and maintenance', 7000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('PUR', 'Purchase Misc Expense', 'Unplanned purchase, packaging, loading', 6000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('TEC', 'Technician Allowance', 'On-site service allowance for technicians', 8000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('OTH', 'Other General Expenses', 'Miscellaneous office related expenses', 3000);



-------------------------------------error free------------------------------

--------------------------------------------------------------------------------
-- 10. SUB_CATEGORIES (Automatic FK Linkage)
--------------------------------------------------------------------------------

-- LED Television Links
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Smart LED TV', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'LED Television'));
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Android TV', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'LED Television'));

-- Refrigerator Links
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Double Door Refrigerator', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Refrigerator and Freezer'));
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Deep Freezer', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Refrigerator and Freezer'));

-- Air Conditioner Links
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Split AC', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Air Conditioner'));
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Window AC', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Air Conditioner'));

-- Washing Machine Links
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Front Load Washing Machine', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Washing Machine'));
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Top Load Washing Machine', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Washing Machine'));

-- Microwave Oven Links
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Convection Microwave Oven', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Microwave Oven'));
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Solo Microwave Oven', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Microwave Oven'));

-- Smart Phone Links
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Android Smartphone', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Smart Phone'));
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Feature Phone', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Smart Phone'));

COMMIT;

--------------------------------------------------------------------------------
-- 11. PRODUCTS (Dynamic FK Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Product 1: Samsung Galaxy S24
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'SAM-S24-018', 'Samsung Galaxy S24', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Smart Phone'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Android Smartphone'),
    (SELECT brand_id FROM brand WHERE model_name = 'UA43T5400'),
    'Pcs', 95000, 82000, 12
);

-- Product 2: iPhone 15 Pro
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'IPH-15-029', 'iPhone 15 Pro', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Smart Phone'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Android Smartphone'),
    (SELECT brand_id FROM brand WHERE model_name = 'WD-LED32F'),
    'Pcs', 145000, 130000, 12
);

-- Product 3: Dell Latitude
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'DEL-LAT-0310', 'Dell Latitude 5420', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Laptop and Computer'),
    NULL, -- No laptop sub-category exists in current schema
    (SELECT brand_id FROM brand WHERE model_name = 'WTM-RT240'),
    'Unit', 85000, 75000, 36
);

-- Product 4: LG Double Door Refrigerator
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'LG-REF-0411', 'LG Double Door Refrigerator', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Refrigerator and Freezer'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Double Door Refrigerator'),
    (SELECT brand_id FROM brand WHERE model_name = 'GL-B201SLBB'),
    'Unit', 75000, 65000, 24
);

-- Product 5: Walton 42 Inch LED
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'WAL-TV-0512', 'Walton 42 Inch LED', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'LED Television'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Smart LED TV'),
    (SELECT brand_id FROM brand WHERE model_name = 'WD-LED32F'),
    'Unit', 35000, 28000, 60
);

-- Product 6: Midea Split AC
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'MIN-AC-0613', 'Midea Split AC 1.5 Ton', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Air Conditioner'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Split AC'),
    (SELECT brand_id FROM brand WHERE model_name = 'M-DFR-240'),
    'Unit', 48000, 42000, 12
);

-- Product 7: Panasonic Microwave
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'PAN-MIC-0714', 'Panasonic Microwave', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Global Electronics Importer'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Microwave Oven'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Android Smartphone'),
    (SELECT brand_id FROM brand WHERE model_name = 'Singer Smart 32'),
    'Pcs', 18000, 15000, 12
);

-- Product 8: Samsung Front Load Washer
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'SAM-WASH-0815', 'Samsung Front Load Washer', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Washing Machine'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Front Load Washing Machine'),
    (SELECT brand_id FROM brand WHERE model_name = 'AR12MVF'),
    'Unit', 55000, 48000, 24
);

-- Product 9: Hitachi Silent Generator
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'HIT-GEN-0916', 'Hitachi Silent Generator', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Generator and Power Products'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Solo Microwave Oven'),
    (SELECT brand_id FROM brand WHERE model_name = 'RAS-F13CF'),
    'Unit', 120000, 105000, 12
);

-- Product 10: LG Home Theater
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'LG-HOM-1017', 'LG Home Theater System', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Home Theater and Sound System'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Top Load Washing Machine'),
    (SELECT brand_id FROM brand WHERE model_name = 'LG-WM140'),
    'Set', 25000, 21000, 12
);

COMMIT;

--------------------------------------------------------------------------------
-- 12. PARTS (Dynamic Mapping to Parts Category)
--------------------------------------------------------------------------------

-- Television Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('TV-MB', 'LED TV Motherboard', 2500, 4000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Television Spare Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('TV-DSP', 'LED TV Display Panel', 8000, 12000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Television Spare Parts' AND ROWNUM=1));

-- Refrigerator Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('FRG-COMP', 'Refrigerator Compressor Unit', 6500, 9500,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Refrigerator Spare Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('FRG-THERM', 'Refrigerator Thermostat', 1200, 2000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Refrigerator Spare Parts' AND ROWNUM=1));

-- Air Conditioner Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('AC-FAN', 'AC Outdoor Fan Motor', 3500, 5000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Air Conditioner Spare Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('AC-REMOTE', 'AC Remote Controller', 700, 1200,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Air Conditioner Spare Parts' AND ROWNUM=1));

-- Washing Machine Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('WM-BELT', 'Washing Machine Drum Belt', 400, 800,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Washing Machine Spare Parts' AND ROWNUM=1));

-- Microwave Oven Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('MIC-MAG', 'Microwave Oven Magnetron Tube', 2600, 4000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Microwave Oven Spare Parts' AND ROWNUM=1));

-- Laptop and Computer Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('LAP-ADPT', 'Laptop Charger Adapter', 900, 1800,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Laptop and Computer Parts' AND ROWNUM=1));

-- Power Supply and Boards
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('PWR-BOARD', 'LED TV Power Supply Board', 1500, 2500,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Power Supply and Boards' AND ROWNUM=1));


--------------------------------------------------------------------------------
-- 13. DEPARTMENTS (Matching Employee FKs)
--------------------------------------------------------------------------------
-- Data referenced by first set of employees
INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('PRO101', 'Procurement and Sourcing', (SELECT company_id FROM company WHERE ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('LOG116', 'Logistics and Supply Chain', (SELECT company_id FROM company WHERE ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('IT 106', 'IT Operations', (SELECT company_id FROM company WHERE ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('HUM111', 'Human Resources', (SELECT company_id FROM company WHERE ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('ACC96', 'Finance and Accounting', (SELECT company_id FROM company WHERE ROWNUM = 1));

-- Data referenced by second set of employees
INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('SAL41', 'Sales Department', (SELECT company_id FROM company WHERE ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('CUS46', 'Customer Support', (SELECT company_id FROM company WHERE ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('SER51', 'After Sales Service', (SELECT company_id FROM company WHERE ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('ACC56', 'Corporate Accounts', (SELECT company_id FROM company WHERE ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('PRO61', 'General Procurement', (SELECT company_id FROM company WHERE ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('IT 66', 'IT Infrastructure', (SELECT company_id FROM company WHERE ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('HUM71', 'Human Capital Management', (SELECT company_id FROM company WHERE ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('LOG76', 'Shipping and Delivery', (SELECT company_id FROM company WHERE ROWNUM = 1));



--------------------------------------------------------------------------------
-- 14. EMPLOYEES (Populated with your provided Job and Dept IDs)
--------------------------------------------------------------------------------

-- 1. The Manager (Insert first so others can reference as manager_id)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Rafiqul', 'Hasan', 'rafiqul.hasan@walton.com', '01711100001', 'Bashundhara, Dhaka', SYSDATE-800, 60000, 
        'MGR4', 'SAL41');

-- 2. Procurement Officer (References ASM5)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Zahid', 'Hasib', 'zahid.hasib@walton.com', '01711110010', 'Banani, Dhaka', SYSDATE-150, 33000, 
        'ASM5', 'PRO101');

-- 3. Store Keeper (References STOR7)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Rezaul', 'Karim', 'rezaul.karim@walton.com', '01711110005', 'Badda, Dhaka', SYSDATE-400, 22000, 
        'STOR7', 'LOG116');

-- 4. IT Support Officer (References IT9)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Tanvir', 'Rahman', 'tanvir.rahman@walton.com', '01711110006', 'Mohakhali, Dhaka', SYSDATE-350, 40000, 
        'IT9', 'IT 106');

-- 5. HR Officer (References HR10)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Sharmin', 'Begum', 'sharmin.begum@walton.com', '01711110007', 'Khilgaon, Dhaka', SYSDATE-300, 45000, 
        'HR10', 'HUM111');

-- 6. Sales Executive (References SALES1 and Manager Rafiqul)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Sadia', 'Akter', 'sadia.akter@walton.com', '01711100002', 'Mirpur, Dhaka', SYSDATE-500, 25000, 
        'SALES1', 'SAL41', (SELECT employee_id FROM employees WHERE last_name='Hasan' AND ROWNUM=1));

-- 7. Customer Support (References CSUP2)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Kamal', 'Hossain', 'kamal.hossain@walton.com', '01711100003', 'Banani, Dhaka', SYSDATE-600, 28000, 
        'CSUP2', 'CUS46', (SELECT employee_id FROM employees WHERE last_name='Hasan' AND ROWNUM=1));

-- 8. Service Technician (References TECH3)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Nazmul', 'Islam', 'nazmul.islam@walton.com', '01711100004', 'Uttara, Dhaka', SYSDATE-450, 35000, 
        'TECH3', 'SER51');

-- 9. Accounting Assistant (References ACC6)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Jannat', 'Ara', 'jannat.ara@walton.com', '01711110009', 'Tejgaon, Dhaka', SYSDATE-180, 26000, 
        'ACC6', 'ACC96');

-- 10. Delivery Staff (References DLV8)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Ahsan', 'Kabir', 'ahsan.kabir@walton.com', '01711110008', 'Khilkhet, Dhaka', SYSDATE-200, 15000, 
        'DLV8', 'LOG76');



UPDATE employees
SET manager_id = (SELECT employee_id FROM employees WHERE last_name='Hasan')
WHERE last_name <> 'Hasan';
UPDATE departments
SET manager_id = (SELECT employee_id FROM employees WHERE last_name='Hasan');


--------------------------------------------------------------------------------
-- 14. EMPLOYEES (Additional Data Set)
--------------------------------------------------------------------------------

-- 11. Senior Accountant
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Fatima', 'Zohra', 'fatima.z@walton.com', '01722200011', 'Lalmatia, Dhaka', SYSDATE-700, 42000, 
        'ACC6', 'ACC56');

-- 12. Junior Sales Rep (Reporting to Rafiqul Hasan)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Sabbir', 'Ahmed', 'sabbir.a@walton.com', '01722200012', 'Farmgate, Dhaka', SYSDATE-120, 22000, 
        'SALES1', 'SAL41', (SELECT employee_id FROM employees WHERE last_name='Hasan' AND ROWNUM=1));

-- 13. Senior Technician
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Mominul', 'Haque', 'momin.h@walton.com', '01722200013', 'Tongi, Gazipur', SYSDATE-950, 38000, 
        'TECH3', 'SER51');

-- 14. IT Security Specialist
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Ariful', 'Islam', 'arif.i@walton.com', '01722200014', 'Dhanmondi, Dhaka', SYSDATE-400, 45000, 
        'IT9', 'IT 66');

-- 15. HR Assistant
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Lutfur', 'Nahid', 'lutfur.n@walton.com', '01722200015', 'Malibagh, Dhaka', SYSDATE-280, 29000, 
        'HR10', 'HUM71');

-- 16. Customer Support Lead
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Rumana', 'Afroz', 'rumana.a@walton.com', '01722200016', 'Banani, Dhaka', SYSDATE-550, 31000, 
        'CSUP2', 'CUS46');

-- 17. Procurement Specialist
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Tariq', 'Aziz', 'tariq.a@walton.com', '01722200017', 'Uttara Sector 4, Dhaka', SYSDATE-320, 37000, 
        'ASM5', 'PRO61');

-- 18. Warehouse Assistant
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Shohel', 'Rana', 'shohel.r@walton.com', '01722200018', 'Savar, Dhaka', SYSDATE-100, 19000, 
        'STOR7', 'LOG76');

-- 19. Inventory Controller
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Keya', 'Payel', 'keya.p@walton.com', '01722200019', 'Nikunja, Dhaka', SYSDATE-480, 24000, 
        'STOR7', 'LOG116');

-- 20. Logistics Coordinator
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Imtiaz', 'Bulbul', 'imtiaz.b@walton.com', '01722200020', 'Rampura, Dhaka', SYSDATE-600, 27000, 
        'DLV8', 'LOG116');

--------------------------------------------------------------------------------
-- 18. PRODUCT_ORDER_MASTER (Dynamic Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Order 1: Placed by Rafiqul Hasan (MGR) to Samsung Authorized Distributor
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Rafiqul' AND last_name = 'Hasan' AND ROWNUM = 1),
    SYSDATE + 5, 
    1
);

-- Order 2: Placed by Ariful Islam (IT) to LG Electronics Supplier
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    SYSDATE + 7, 
    1
);

-- Order 3: Placed by Fatima Zohra (Accounts) to Walton Spare Parts Division
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    SYSDATE + 3, 
    1
);

-- Order 4: Placed by Zahid Hasib (Procurement) to Global Electronics Importer
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Global Electronics Importer' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND ROWNUM = 1),
    SYSDATE + 10, 
    1
);

-- Order 5: Placed by Tariq Aziz (Procurement) to Asian Spare Parts House
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Tariq' AND last_name = 'Aziz' AND ROWNUM = 1),
    SYSDATE + 4, 
    1
);

-- Order 6: Placed by Rumana Afroz (Support) to Vision / RFL Parts Supplier
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Vision / RFL Parts Supplier' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Rumana' AND last_name = 'Afroz' AND ROWNUM = 1),
    SYSDATE + 6, 
    1
);

-- Order 7: Placed by Mominul Haque (Tech) to Jamuna Electronics Supplier
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND ROWNUM = 1),
    SYSDATE + 8, 
    1
);

-- Order 8: Placed by Ariful Islam to Minister Hi-Tech Supplier
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    SYSDATE + 2, 
    1
);

-- Order 9: Placed by Fatima Zohra to City Electronics Parts Supplier
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    SYSDATE + 9, 
    1
);

-- Order 10: Placed by Zahid Hasib to Bangladesh Electronics Wholesale
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Bangladesh Electronics Wholesale' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND ROWNUM = 1),
    SYSDATE + 12, 
    1
);

COMMIT;


--------------------------------------------------------------------------------
-- 19. PRODUCT_RECEIVE_MASTER (Dynamic Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Receiving for Order from Samsung Distributor
INSERT INTO product_receive_master (order_id, received_by, supplier_id, sup_invoice_id, status)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor') AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    'SAM-INV-501', 1
);

-- Receiving for Order from LG Electronics Supplier
INSERT INTO product_receive_master (order_id, received_by, supplier_id, sup_invoice_id, status)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier') AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Rezaul' AND last_name = 'Karim' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    'LG-INV-882', 1
);

-- Receiving for Order from Walton Spare Parts Division
INSERT INTO product_receive_master (order_id, received_by, supplier_id, sup_invoice_id, status)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division') AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ahsan' AND last_name = 'Kabir' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division' AND ROWNUM = 1),
    'WAL-INV-301', 1
);

-- Receiving for Order from Samsung (Second Shipment)
INSERT INTO product_receive_master (order_id, received_by, supplier_id, sup_invoice_id, status)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor') AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Keya' AND last_name = 'Payel' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    'SAM-INV-502', 1
);

-- Receiving for Order from Asian Spare Parts House
INSERT INTO product_receive_master (order_id, received_by, supplier_id, sup_invoice_id, status)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House') AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House' AND ROWNUM = 1),
    'ASI-INV-109', 1
);

-- Receiving for Order from LG Electronics Supplier (Second Shipment)
INSERT INTO product_receive_master (order_id, received_by, supplier_id, sup_invoice_id, status)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier') AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Imtiaz' AND last_name = 'Bulbul' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    'LG-INV-885', 1
);

-- Receiving for Order from Jamuna Electronics Supplier
INSERT INTO product_receive_master (order_id, received_by, supplier_id, sup_invoice_id, status)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier') AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier' AND ROWNUM = 1),
    'JAM-INV-441', 1
);

-- Receiving for Order from Minister Hi-Tech Supplier
INSERT INTO product_receive_master (order_id, received_by, supplier_id, sup_invoice_id, status)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier') AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier' AND ROWNUM = 1),
    'MIN-INV-221', 1
);

-- Receiving for Order from City Electronics Parts Supplier
INSERT INTO product_receive_master (order_id, received_by, supplier_id, sup_invoice_id, status)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier') AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier' AND ROWNUM = 1),
    'CIT-INV-667', 1
);

-- Receiving for Order from Bangladesh Electronics Wholesale
INSERT INTO product_receive_master (order_id, received_by, supplier_id, sup_invoice_id, status)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Bangladesh Electronics Wholesale') AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Bangladesh Electronics Wholesale' AND ROWNUM = 1),
    'BAN-INV-990', 1
);

COMMIT;

--------------------------------------------------------------------------------
-- 20. PRODUCT_RETURN_MASTER (Dynamic Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Return 1: Returning items from Samsung shipment (SAM-INV-501)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'SAM-INV-501'),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'SAM-INV-501'),
    (SELECT employee_id FROM employees WHERE first_name = 'Ahsan' AND last_name = 'Kabir' AND ROWNUM = 1),
    150, 1
);

-- Return 2: Returning items from LG shipment (LG-INV-882)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'LG-INV-882'),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'LG-INV-882'),
    (SELECT employee_id FROM employees WHERE first_name = 'Rezaul' AND last_name = 'Karim' AND ROWNUM = 1),
    200, 1
);

-- Return 3: Returning items from Walton shipment (WAL-INV-301)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'WAL-INV-301'),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'WAL-INV-301'),
    (SELECT employee_id FROM employees WHERE first_name = 'Ahsan' AND last_name = 'Kabir' AND ROWNUM = 1),
    50, 1
);

-- Return 4: Returning items from second Samsung shipment (SAM-INV-502)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'SAM-INV-502'),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'SAM-INV-502'),
    (SELECT employee_id FROM employees WHERE first_name = 'Keya' AND last_name = 'Payel' AND ROWNUM = 1),
    100, 1
);

-- Return 5: Returning items from Asian Tech (ASI-INV-109)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'ASI-INV-109'),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'ASI-INV-109'),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    300, 1
);

-- Return 6: Returning items from second LG shipment (LG-INV-885)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'LG-INV-885'),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'LG-INV-885'),
    (SELECT employee_id FROM employees WHERE first_name = 'Imtiaz' AND last_name = 'Bulbul' AND ROWNUM = 1),
    180, 1
);

-- Return 7: Returning items from Singer (JAM-INV-441)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'JAM-INV-441'),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'JAM-INV-441'),
    (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND ROWNUM = 1),
    400, 1
);

-- Return 8: Returning items from Midea (MIN-INV-221)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'MIN-INV-221'),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'MIN-INV-221'),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    120, 1
);

-- Return 9: Returning items from City IT (CIT-INV-667)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'CIT-INV-667'),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'CIT-INV-667'),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    250, 1
);

-- Return 10: Returning items from Bangla Tech (BAN-INV-990)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Bangladesh Electronics Wholesale' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'BAN-INV-990'),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'BAN-INV-990'),
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND ROWNUM = 1),
    90, 1
);

COMMIT;

--------------------------------------------------------------------------------
-- 26. PRODUCT_ORDER_DETAIL (Dynamic Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Order 1: Samsung Galaxy S24
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor') AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'SAM-S24-018'),
    95000, 82000, 10
);

-- Order 2: LG Double Door Refrigerator
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier') AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-REF-0411'),
    75000, 65000, 5
);

-- Order 3: Walton 42 Inch LED
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division') AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512'),
    35000, 28000, 15
);

-- Order 4: Samsung Front Load Washer
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor') AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'SAM-WASH-0815'),
    55000, 48000, 8
);

-- Order 5: Dell Latitude 5420
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House') AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'DEL-LAT-0310'),
    85000, 75000, 12
);

-- Order 6: LG Home Theater System
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier') AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-HOM-1017'),
    25000, 21000, 20
);

-- Order 7: Hitachi Silent Generator
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier') AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'HIT-GEN-0916'),
    120000, 105000, 3
);

-- Order 8: Midea Split AC
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier') AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613'),
    48000, 42000, 10
);

-- Order 9: iPhone 15 Pro
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier') AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'IPH-15-029'),
    145000, 130000, 7
);

-- Order 10: Panasonic Microwave
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Bangladesh Electronics Wholesale') AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'PAN-MIC-0714'),
    18000, 15000, 10
);

COMMIT;


--------------------------------------------------------------------------------
-- 27. PRODUCT_RECEIVE_DETAILS (Dynamic Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Receiving for Order from Samsung (SAM-INV-501)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'SAM-INV-501'),
    (SELECT product_id FROM products WHERE product_code = 'SAM-S24-018'),
    95000, 82000, 10
);

-- Receiving for Order from LG (LG-INV-882)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'LG-INV-882'),
    (SELECT product_id FROM products WHERE product_code = 'LG-REF-0411'),
    75000, 65000, 5
);

-- Receiving for Order from Walton (WAL-INV-301)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'WAL-INV-301'),
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512'),
    35000, 28000, 15
);

-- Receiving for Order from Samsung (SAM-INV-502)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'SAM-INV-502'),
    (SELECT product_id FROM products WHERE product_code = 'SAM-WASH-0815'),
    55000, 48000, 8
);

-- Receiving for Order from Asian Tech (ASI-INV-109)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'ASI-INV-109'),
    (SELECT product_id FROM products WHERE product_code = 'DEL-LAT-0310'),
    85000, 75000, 12
);

-- Receiving for Order from LG (LG-INV-885)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'LG-INV-885'),
    (SELECT product_id FROM products WHERE product_code = 'LG-HOM-1017'),
    25000, 21000, 20
);

-- Receiving for Order from Jamuna (JAM-INV-441)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'JAM-INV-441'),
    (SELECT product_id FROM products WHERE product_code = 'HIT-GEN-0916'),
    120000, 105000, 3
);

-- Receiving for Order from Midea (MIN-INV-221)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'MIN-INV-221'),
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613'),
    48000, 42000, 10
);

-- Receiving for Order from City IT (CIT-INV-667)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'CIT-INV-667'),
    (SELECT product_id FROM products WHERE product_code = 'IPH-15-029'),
    145000, 130000, 7
);

-- Receiving for Order from Bangla Tech (BAN-INV-990)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'BAN-INV-990'),
    (SELECT product_id FROM products WHERE product_code = 'PAN-MIC-0714'),
    18000, 15000, 10
);

COMMIT;


--------------------------------------------------------------------------------
-- 28. PRODUCT_RETURN_DETAILS (Dynamic Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Return for Samsung S24s (Linked via Samsung Return Master)
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'SAM-S24-018'),
    95000, 82000, 2, 'Damaged screen during transit'
);

-- Return for LG Refrigerator
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-REF-0411'),
    75000, 65000, 1, 'Compressor noise issue'
);

-- Return for Walton TVs
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512'),
    35000, 28000, 3, 'Dead pixels on panel'
);

-- Return for Samsung Washer
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'SAM-WASH-0815'),
    55000, 48000, 1, 'Water leakage from door'
);

-- Return for Dell Latitude Laptops
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'DEL-LAT-0310'),
    85000, 75000, 2, 'Motherboard failure'
);

-- Return for LG Home Theater Systems
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-HOM-1017'),
    25000, 21000, 5, 'Remote control missing in boxes'
);

-- Return for Hitachi Generator
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'HIT-GEN-0916'),
    120000, 105000, 1, 'Fuel tank dented'
);

-- Return for Midea Split ACs
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613'),
    48000, 42000, 2, 'Incomplete installation kit'
);

-- Return for iPhone 15 Pro
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'IPH-15-029'),
    145000, 130000, 1, 'FaceID sensor not working'
);

-- Return for Panasonic Microwaves
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Bangladesh Electronics Wholesale' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'PAN-MIC-0714'),
    18000, 15000, 2, 'Glass tray broken'
);

COMMIT;

-- 11. PRODUCTS (Dynamic FK Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Product 1: Samsung Galaxy S24
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'SAM-S24-018', 'Samsung Galaxy S24', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Smart Phone' AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Android Smartphone' AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE model_name = 'UA43T5400' AND ROWNUM = 1),
    'Pcs', 95000, 82000, 12
);

-- Product 2: iPhone 15 Pro
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'IPH-15-029', 'iPhone 15 Pro', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier' AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Smart Phone' AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Android Smartphone' AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE model_name = 'WD-LED32F' AND ROWNUM = 1),
    'Pcs', 145000, 130000, 12
);

-- Product 3: Dell Latitude
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'DEL-LAT-0310', 'Dell Latitude 5420', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House' AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Laptop and Computer' AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Laptop' AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE model_name = 'WTM-RT240' AND ROWNUM = 1),
    'Unit', 85000, 75000, 36
);

-- Product 4: LG Double Door Refrigerator
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'LG-REF-0411', 'LG Double Door Refrigerator', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Refrigerator and Freezer' AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Double Door Refrigerator' AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE model_name = 'GL-B201SLBB' AND ROWNUM = 1),
    'Unit', 75000, 65000, 24
);

-- Product 5: Walton 42 Inch LED
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'WAL-TV-0512', 'Walton 42 Inch LED', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division' AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'LED Television' AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Smart LED TV' AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE model_name = 'WD-LED32F' AND ROWNUM = 1),
    'Unit', 35000, 28000, 60
);

-- Product 6: Midea Split AC
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'MIN-AC-0613', 'Midea Split AC 1.5 Ton', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier' AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Air Conditioner' AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Split AC' AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE model_name = 'M-DFR-240' AND ROWNUM = 1),
    'Unit', 48000, 42000, 12
);

-- Product 7: Panasonic Microwave
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'PAN-MIC-0714', 'Panasonic Microwave', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Global Electronics Importer' AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Microwave Oven' AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Android Smartphone' AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE model_name = 'Singer Smart 32' AND ROWNUM = 1),
    'Pcs', 18000, 15000, 12
);

-- Product 8: Samsung Front Load Washer
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'SAM-WASH-0815', 'Samsung Front Load Washer', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Washing Machine' AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Front Load Washing Machine' AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE model_name = 'AR12MVF' AND ROWNUM = 1),
    'Unit', 55000, 48000, 24
);

-- Product 9: Hitachi Silent Generator
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'HIT-GEN-0916', 'Hitachi Silent Generator', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier' AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Generator and Power Products' AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Solo Microwave Oven' AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE model_name = 'RAS-F13CF' AND ROWNUM = 1),
    'Unit', 120000, 105000, 12
);

-- Product 10: LG Home Theater
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'LG-HOM-1017', 'LG Home Theater System', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Home Theater and Sound System' AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Top Load Washing Machine' AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE model_name = 'LG-WM140' AND ROWNUM = 1),
    'Set', 25000, 21000, 12
);

COMMIT;

--------------------------------------------------------------------------------
-- 12. PARTS (Dynamic Mapping to Parts Category)
--------------------------------------------------------------------------------

-- Television Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('TV-MB', 'LED TV Motherboard', 2500, 4000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Television Spare Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('TV-DSP', 'LED TV Display Panel', 8000, 12000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Television Spare Parts' AND ROWNUM=1));

-- Refrigerator Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('FRG-COMP', 'Refrigerator Compressor Unit', 6500, 9500,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Refrigerator Spare Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('FRG-THERM', 'Refrigerator Thermostat', 1200, 2000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Refrigerator Spare Parts' AND ROWNUM=1));

-- Air Conditioner Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('AC-FAN', 'AC Outdoor Fan Motor', 3500, 5000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Air Conditioner Spare Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('AC-REMOTE', 'AC Remote Controller', 700, 1200,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Air Conditioner Spare Parts' AND ROWNUM=1));

-- Washing Machine Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('WM-BELT', 'Washing Machine Drum Belt', 400, 800,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Washing Machine Spare Parts' AND ROWNUM=1));

-- Microwave Oven Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('MIC-MAG', 'Microwave Oven Magnetron Tube', 2600, 4000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Microwave Oven Spare Parts' AND ROWNUM=1));

-- Laptop and Computer Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('LAP-ADPT', 'Laptop Charger Adapter', 900, 1800,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Laptop and Computer Parts' AND ROWNUM=1));

-- Power Supply and Boards
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('PWR-BOARD', 'LED TV Power Supply Board', 1500, 2500,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Power Supply and Boards' AND ROWNUM=1));


--------------------------------------------------------------------------------
-- 14. EMPLOYEES (Populated with your provided Job and Dept IDs)
--------------------------------------------------------------------------------

-- 1. The Manager (Insert first so others can reference as manager_id)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Rafiqul', 'Hasan', 'rafiqul.hasan@walton.com', '01711100001', 'Bashundhara, Dhaka', SYSDATE-800, 60000, 
        'MGR4', 'SAL41');

-- 2. Procurement Officer (References ASM5)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Zahid', 'Hasib', 'zahid.hasib@walton.com', '01711110010', 'Banani, Dhaka', SYSDATE-150, 33000, 
        'ASM5', 'PRO101');

-- 3. Store Keeper (References STOR7)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Rezaul', 'Karim', 'rezaul.karim@walton.com', '01711110005', 'Badda, Dhaka', SYSDATE-400, 22000, 
        'STOR7', 'LOG116');

-- 4. IT Support Officer (References IT9)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Tanvir', 'Rahman', 'tanvir.rahman@walton.com', '01711110006', 'Mohakhali, Dhaka', SYSDATE-350, 40000, 
        'IT9', 'IT 106');

-- 5. HR Officer (References HR10)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Sharmin', 'Begum', 'sharmin.begum@walton.com', '01711110007', 'Khilgaon, Dhaka', SYSDATE-300, 45000, 
        'HR10', 'HUM111');

-- 6. Sales Executive (References SALES1 and Manager Rafiqul)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Sadia', 'Akter', 'sadia.akter@walton.com', '01711100002', 'Mirpur, Dhaka', SYSDATE-500, 25000, 
        'SALES1', 'SAL41', (SELECT employee_id FROM employees WHERE last_name='Hasan' AND ROWNUM=1));

-- 7. Customer Support (References CSUP2)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Kamal', 'Hossain', 'kamal.hossain@walton.com', '01711100003', 'Banani, Dhaka', SYSDATE-600, 28000, 
        'CSUP2', 'CUS46', (SELECT employee_id FROM employees WHERE last_name='Hasan' AND ROWNUM=1));

-- 8. Service Technician (References TECH3)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Nazmul', 'Islam', 'nazmul.islam@walton.com', '01711100004', 'Uttara, Dhaka', SYSDATE-450, 35000, 
        'TECH3', 'SER51');

-- 9. Accounting Assistant (References ACC6)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Jannat', 'Ara', 'jannat.ara@walton.com', '01711110009', 'Tejgaon, Dhaka', SYSDATE-180, 26000, 
        'ACC6', 'ACC96');

-- 10. Delivery Staff (References DLV8)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Ahsan', 'Kabir', 'ahsan.kabir@walton.com', '01711110008', 'Khilkhet, Dhaka', SYSDATE-200, 15000, 
        'DLV8', 'LOG76');



UPDATE employees
SET manager_id = (SELECT employee_id FROM employees WHERE last_name='Hasan' AND ROWNUM = 1)
WHERE last_name <> 'Hasan';
UPDATE departments
SET manager_id = (SELECT employee_id FROM employees WHERE last_name='Hasan' AND ROWNUM = 1);


--------------------------------------------------------------------------------
-- 14. EMPLOYEES (Additional Data Set)
--------------------------------------------------------------------------------

-- 11. Senior Accountant
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Fatima', 'Zohra', 'fatima.z@walton.com', '01722200011', 'Lalmatia, Dhaka', SYSDATE-700, 42000, 
        'ACC6', 'ACC56');

-- 12. Junior Sales Rep (Reporting to Rafiqul Hasan)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Sabbir', 'Ahmed', 'sabbir.a@walton.com', '01722200012', 'Farmgate, Dhaka', SYSDATE-120, 22000, 
        'SALES1', 'SAL41', (SELECT employee_id FROM employees WHERE last_name='Hasan' AND ROWNUM=1));

-- 13. Senior Technician
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Mominul', 'Haque', 'momin.h@walton.com', '01722200013', 'Tongi, Gazipur', SYSDATE-950, 38000, 
        'TECH3', 'SER51');

-- 14. IT Security Specialist
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Ariful', 'Islam', 'arif.i@walton.com', '01722200014', 'Dhanmondi, Dhaka', SYSDATE-400, 45000, 
        'IT9', 'IT 66');

-- 15. HR Assistant
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Lutfur', 'Nahid', 'lutfur.n@walton.com', '01722200015', 'Malibagh, Dhaka', SYSDATE-280, 29000, 
        'HR10', 'HUM71');

-- 16. Customer Support Lead
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Rumana', 'Afroz', 'rumana.a@walton.com', '01722200016', 'Banani, Dhaka', SYSDATE-550, 31000, 
        'CSUP2', 'CUS46');

-- 17. Procurement Specialist
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Tariq', 'Aziz', 'tariq.a@walton.com', '01722200017', 'Uttara Sector 4, Dhaka', SYSDATE-320, 37000, 
        'ASM5', 'PRO61');

-- 18. Warehouse Assistant
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Shohel', 'Rana', 'shohel.r@walton.com', '01722200018', 'Savar, Dhaka', SYSDATE-100, 19000, 
        'STOR7', 'LOG76');

-- 19. Inventory Controller
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Keya', 'Payel', 'keya.p@walton.com', '01722200019', 'Nikunja, Dhaka', SYSDATE-480, 24000, 
        'STOR7', 'LOG116');

-- 20. Logistics Coordinator
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Imtiaz', 'Bulbul', 'imtiaz.b@walton.com', '01722200020', 'Rampura, Dhaka', SYSDATE-600, 27000, 
        'DLV8', 'LOG116');

--------------------------------------------------------------------------------
-- 18. PRODUCT_ORDER_MASTER (Dynamic Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Order 1: Placed by Rafiqul Hasan (MGR) to Samsung Authorized Distributor
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Rafiqul' AND last_name = 'Hasan' AND ROWNUM = 1),
    SYSDATE + 5, 
    1
);

-- Order 2: Placed by Ariful Islam (IT) to LG Electronics Supplier
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    SYSDATE + 7, 
    1
);

-- Order 3: Placed by Fatima Zohra (Accounts) to Walton Spare Parts Division
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    SYSDATE + 3, 
    1
);

-- Order 4: Placed by Zahid Hasib (Procurement) to Global Electronics Importer
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Global Electronics Importer' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND ROWNUM = 1),
    SYSDATE + 10, 
    1
);

-- Order 5: Placed by Tariq Aziz (Procurement) to Asian Spare Parts House
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Tariq' AND last_name = 'Aziz' AND ROWNUM = 1),
    SYSDATE + 4, 
    1
);

-- Order 6: Placed by Rumana Afroz (Support) to Vision / RFL Parts Supplier
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Vision / RFL Parts Supplier' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Rumana' AND last_name = 'Afroz' AND ROWNUM = 1),
    SYSDATE + 6, 
    1
);

-- Order 7: Placed by Mominul Haque (Tech) to Jamuna Electronics Supplier
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND ROWNUM = 1),
    SYSDATE + 8, 
    1
);

-- Order 8: Placed by Ariful Islam to Minister Hi-Tech Supplier
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    SYSDATE + 2, 
    1
);

-- Order 9: Placed by Fatima Zohra to City Electronics Parts Supplier
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    SYSDATE + 9, 
    1
);

-- Order 10: Placed by Zahid Hasib to Bangladesh Electronics Wholesale
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Bangladesh Electronics Wholesale' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND ROWNUM = 1),
    SYSDATE + 12, 
    1
);

COMMIT;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Return 1: Returning items from Samsung shipment (SAM-INV-501)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'SAM-INV-501' AND ROWNUM = 1),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'SAM-INV-501' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ahsan' AND last_name = 'Kabir' AND ROWNUM = 1),
    150, 1
);

-- Return 2: Returning items from LG shipment (LG-INV-882)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'LG-INV-882' AND ROWNUM = 1),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'LG-INV-882' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Rezaul' AND last_name = 'Karim' AND ROWNUM = 1),
    200, 1
);

-- Return 3: Returning items from Walton shipment (WAL-INV-301)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'WAL-INV-301' AND ROWNUM = 1),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'WAL-INV-301' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ahsan' AND last_name = 'Kabir' AND ROWNUM = 1),
    50, 1
);

-- Return 4: Returning items from second Samsung shipment (SAM-INV-502)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'SAM-INV-502' AND ROWNUM = 1),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'SAM-INV-502' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Keya' AND last_name = 'Payel' AND ROWNUM = 1),
    100, 1
);

-- Return 5: Returning items from Asian Tech (ASI-INV-109)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'ASI-INV-109' AND ROWNUM = 1),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'ASI-INV-109' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    300, 1
);

-- Return 6: Returning items from second LG shipment (LG-INV-885)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'LG-INV-885' AND ROWNUM = 1),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'LG-INV-885' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Imtiaz' AND last_name = 'Bulbul' AND ROWNUM = 1),
    180, 1
);

-- Return 7: Returning items from Singer (JAM-INV-441)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'JAM-INV-441' AND ROWNUM = 1),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'JAM-INV-441' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND ROWNUM = 1),
    400, 1
);

-- Return 8: Returning items from Midea (MIN-INV-221)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'MIN-INV-221' AND ROWNUM = 1),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'MIN-INV-221' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    120, 1
);

-- Return 9: Returning items from City IT (CIT-INV-667)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'CIT-INV-667' AND ROWNUM = 1),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'CIT-INV-667' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    250, 1
);

-- Return 10: Returning items from Bangla Tech (BAN-INV-990)
INSERT INTO product_return_master (supplier_id, receive_id, order_id, return_by, adjusted_vat, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Bangladesh Electronics Wholesale' AND ROWNUM = 1),
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'BAN-INV-990' AND ROWNUM = 1),
    (SELECT order_id FROM product_receive_master WHERE sup_invoice_id = 'BAN-INV-990' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND ROWNUM = 1),
    90, 1
);

COMMIT;

--------------------------------------------------------------------------------
-- 26. PRODUCT_ORDER_DETAIL (Dynamic Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Order 1: Samsung Galaxy S24
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'SAM-S24-018' AND ROWNUM = 1),
    95000, 82000, 10
);

-- Order 2: LG Double Door Refrigerator
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-REF-0411' AND ROWNUM = 1),
    75000, 65000, 5
);

-- Order 3: Walton 42 Inch LED
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND ROWNUM = 1),
    35000, 28000, 15
);

-- Order 4: Samsung Front Load Washer
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'SAM-WASH-0815' AND ROWNUM = 1),
    55000, 48000, 8
);

-- Order 5: Dell Latitude 5420
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'DEL-LAT-0310' AND ROWNUM = 1),
    85000, 75000, 12
);

-- Order 6: LG Home Theater System
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-HOM-1017' AND ROWNUM = 1),
    25000, 21000, 20
);

-- Order 7: Hitachi Silent Generator
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'HIT-GEN-0916' AND ROWNUM = 1),
    120000, 105000, 3
);

-- Order 8: Midea Split AC
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613' AND ROWNUM = 1),
    48000, 42000, 10
);

-- Order 9: iPhone 15 Pro
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'IPH-15-029' AND ROWNUM = 1),
    145000, 130000, 7
);

-- Order 10: Panasonic Microwave
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES (
    (SELECT order_id FROM product_order_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Bangladesh Electronics Wholesale' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'PAN-MIC-0714' AND ROWNUM = 1),
    18000, 15000, 10
);

COMMIT;


--------------------------------------------------------------------------------
-- 27. PRODUCT_RECEIVE_DETAILS (Dynamic Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Receiving for Order from Samsung (SAM-INV-501)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'SAM-INV-501' AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'SAM-S24-018' AND ROWNUM = 1),
    95000, 82000, 10
);

-- Receiving for Order from LG (LG-INV-882)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'LG-INV-882' AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-REF-0411' AND ROWNUM = 1),
    75000, 65000, 5
);

-- Receiving for Order from Walton (WAL-INV-301)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'WAL-INV-301' AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND ROWNUM = 1),
    35000, 28000, 15
);

-- Receiving for Order from Samsung (SAM-INV-502)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'SAM-INV-502' AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'SAM-WASH-0815' AND ROWNUM = 1),
    55000, 48000, 8
);

-- Receiving for Order from Asian Tech (ASI-INV-109)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'ASI-INV-109' AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'DEL-LAT-0310' AND ROWNUM = 1),
    85000, 75000, 12
);

-- Receiving for Order from LG (LG-INV-885)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'LG-INV-885' AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-HOM-1017' AND ROWNUM = 1),
    25000, 21000, 20
);

-- Receiving for Order from Jamuna (JAM-INV-441)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'JAM-INV-441' AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'HIT-GEN-0916' AND ROWNUM = 1),
    120000, 105000, 3
);

-- Receiving for Order from Midea (MIN-INV-221)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'MIN-INV-221' AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613' AND ROWNUM = 1),
    48000, 42000, 10
);

-- Receiving for Order from City IT (CIT-INV-667)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'CIT-INV-667' AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'IPH-15-029' AND ROWNUM = 1),
    145000, 130000, 7
);

-- Receiving for Order from Bangla Tech (BAN-INV-990)
INSERT INTO product_receive_details (receive_id, product_id, mrp, purchase_price, receive_quantity)
VALUES (
    (SELECT receive_id FROM product_receive_master WHERE sup_invoice_id = 'BAN-INV-990' AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'PAN-MIC-0714' AND ROWNUM = 1),
    18000, 15000, 10
);

COMMIT;


--------------------------------------------------------------------------------
-- 28. PRODUCT_RETURN_DETAILS (Dynamic Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Return for Samsung S24s (Linked via Samsung Return Master)
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'SAM-S24-018' AND ROWNUM = 1),
    95000, 82000, 2, 'Damaged screen during transit'
);

-- Return for LG Refrigerator
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-REF-0411' AND ROWNUM = 1),
    75000, 65000, 1, 'Compressor noise issue'
);

-- Return for Walton TVs
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND ROWNUM = 1),
    35000, 28000, 3, 'Dead pixels on panel'
);

-- Return for Samsung Washer
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'SAM-WASH-0815' AND ROWNUM = 1),
    55000, 48000, 1, 'Water leakage from door'
);

-- Return for Dell Latitude Laptops
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'DEL-LAT-0310' AND ROWNUM = 1),
    85000, 75000, 2, 'Motherboard failure'
);

-- Return for LG Home Theater Systems
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-HOM-1017' AND ROWNUM = 1),
    25000, 21000, 5, 'Remote control missing in boxes'
);

-- Return for Hitachi Generator
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'HIT-GEN-0916' AND ROWNUM = 1),
    120000, 105000, 1, 'Fuel tank dented'
);

-- Return for Midea Split ACs
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613' AND ROWNUM = 1),
    48000, 42000, 2, 'Incomplete installation kit'
);

-- Return for iPhone 15 Pro
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'IPH-15-029' AND ROWNUM = 1),
    145000, 130000, 1, 'FaceID sensor not working'
);

-- Return for Panasonic Microwaves
INSERT INTO product_return_details (return_id, product_id, mrp, purchase_price, return_quantity, reason)
VALUES (
    (SELECT return_id FROM product_return_master WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Bangladesh Electronics Wholesale' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'PAN-MIC-0714' AND ROWNUM = 1),
    18000, 15000, 2, 'Glass tray broken'
);

COMMIT;

--------------------------------------------------------------------------------
-- ADDITIONAL DATA: SALES, SERVICE, AND OPERATIONAL RECORDS
--------------------------------------------------------------------------------

-- 30. STOCK (Inventory Management)
--------------------------------------------------------------------------------
INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'SAM-S24-018' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    25
);

INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'LG-REF-0411' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    15
);

INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division' AND ROWNUM = 1),
    20
);

INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'SAM-WASH-0815' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    12
);

INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'DEL-LAT-0310' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House' AND ROWNUM = 1),
    18
);

INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'LG-HOM-1017' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    30
);

INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'HIT-GEN-0916' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier' AND ROWNUM = 1),
    8
);

INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier' AND ROWNUM = 1),
    14
);

INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'IPH-15-029' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier' AND ROWNUM = 1),
    9
);

INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'PAN-MIC-0714' AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Bangladesh Electronics Wholesale' AND ROWNUM = 1),
    16
);

COMMIT;


--------------------------------------------------------------------------------
-- 31. SALES_MASTER (Customer Sales Invoices)
--------------------------------------------------------------------------------

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000001' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Rafiqul' AND last_name = 'Hasan' AND ROWNUM = 1),
    SYSDATE - 20,
    2000
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000002' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    SYSDATE - 30,
    3000
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000003' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    SYSDATE - 750,
    1500
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000004' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND ROWNUM = 1),
    SYSDATE - 740,
    5000
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000005' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Tariq' AND last_name = 'Aziz' AND ROWNUM = 1),
    SYSDATE - 60,
    2500
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000006' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Rumana' AND last_name = 'Afroz' AND ROWNUM = 1),
    SYSDATE - 100,
    1000
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000007' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND ROWNUM = 1),
    SYSDATE - 50,
    3000
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000008' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Rafiqul' AND last_name = 'Hasan' AND ROWNUM = 1),
    SYSDATE - 380,
    2000
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000009' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    SYSDATE - 90,
    500
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000010' AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    SYSDATE - 400,
    8000
);

COMMIT;


--------------------------------------------------------------------------------
-- 32. SALES_DETAIL (Sales Line Items)
--------------------------------------------------------------------------------

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp, vat)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000001' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND ROWNUM = 1),
    1, 35000, 2000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp, vat)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000002' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613' AND ROWNUM = 1),
    1, 48000, 3000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp, vat)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000003' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-REF-0411' AND ROWNUM = 1),
    1, 75000, 3500
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp, vat)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000004' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'SAM-WASH-0815' AND ROWNUM = 1),
    1, 55000, 3000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp, vat)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000005' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'DEL-LAT-0310' AND ROWNUM = 1),
    1, 85000, 4500
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp, vat)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000006' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND ROWNUM = 1),
    1, 35000, 2000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp, vat)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000007' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613' AND ROWNUM = 1),
    1, 48000, 3000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp, vat)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000008' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'PAN-MIC-0714' AND ROWNUM = 1),
    1, 18000, 1000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp, vat)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000009' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'IPH-15-029' AND ROWNUM = 1),
    1, 145000, 7500
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp, vat)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000010' AND ROWNUM = 1) AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-HOM-1017' AND ROWNUM = 1),
    1, 25000, 1500
);

COMMIT;


--------------------------------------------------------------------------------
-- 33. SALES_RETURN_MASTER (Returns from Customers)
--------------------------------------------------------------------------------

INSERT INTO sales_return_master (invoice_id, return_date)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000001' AND ROWNUM = 1) AND ROWNUM = 1),
    SYSDATE - 5
);

INSERT INTO sales_return_master (invoice_id, return_date)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000009' AND ROWNUM = 1) AND ROWNUM = 1),
    SYSDATE
);

COMMIT;


--------------------------------------------------------------------------------
-- 34. SERVICE_MASTER (Service Requests)
--------------------------------------------------------------------------------

-- Service 1: TV Repair Service with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    -- Insert master record
    INSERT INTO service_master (customer_id, invoice_id, service_date, servicelist_id, service_by, service_charge, parts_price, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000001' AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000001' AND ROWNUM = 1) AND ROWNUM = 1),
        SYSDATE - 5,
        (SELECT servicelist_id FROM service_list WHERE service_name = 'TV Repair Service' AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND ROWNUM = 1),
        2500,
        3500,
        900,
        6900,
        'Y'
    )
    RETURNING service_id INTO v_service_id;
    
    -- Insert detail records
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'LED TV Motherboard' AND ROWNUM = 1), 1, 2000, 2000, 'Y', 'Replaced defective LED TV motherboard due to power surge damage');
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'LED TV Display Panel' AND ROWNUM = 1), 1, 1500, 1500, 'Y', 'Replaced cracked display panel after physical impact');
    
    COMMIT;
END;
/

-- Service 2: AC Servicing with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    -- Insert master record
    INSERT INTO service_master (customer_id, invoice_id, service_date, servicelist_id, service_by, service_charge, parts_price, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000002' AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000002' AND ROWNUM = 1) AND ROWNUM = 1),
        SYSDATE - 3,
        (SELECT servicelist_id FROM service_list WHERE service_name = 'AC Servicing' AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
        1800,
        2200,
        600,
        4600,
        'N'
    )
    RETURNING service_id INTO v_service_id;
    
    -- Insert detail records
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT d.product_id FROM sales_detail d 
         JOIN sales_master m ON d.invoice_id = m.invoice_id 
         JOIN products p ON d.product_id = p.product_id
         JOIN product_categories pc ON p.category_id = pc.product_cat_id
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000002' AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Air Conditioner%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'AC Outdoor Fan Motor' AND ROWNUM = 1), 1, 1200, 1200, 'N', 'Replaced outdoor fan motor - warranty void due to improper installation by unauthorized technician');
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT d.product_id FROM sales_detail d 
         JOIN sales_master m ON d.invoice_id = m.invoice_id 
         JOIN products p ON d.product_id = p.product_id
         JOIN product_categories pc ON p.category_id = pc.product_cat_id
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000002' AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Air Conditioner%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'AC Remote Controller' AND ROWNUM = 1), 1, 1000, 1000, 'N', 'Remote replacement not covered - physical damage due to customer mishandling');
    
    COMMIT;
END;
/

-- Service 3: Refrigerator Repair with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, servicelist_id, service_by, service_charge, parts_price, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000003' AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000003' AND ROWNUM = 1) AND ROWNUM = 1),
        SYSDATE - 2,
        (SELECT servicelist_id FROM service_list WHERE service_name = 'Refrigerator Repair' AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE first_name = 'Keya' AND last_name = 'Payel' AND ROWNUM = 1),
        2200,
        4500,
        1005,
        7705,
        'N'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT d.product_id FROM sales_detail d 
         JOIN sales_master m ON d.invoice_id = m.invoice_id 
         JOIN products p ON d.product_id = p.product_id
         JOIN product_categories pc ON p.category_id = pc.product_cat_id
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000003' AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Refrigerator%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'Refrigerator Compressor Unit' AND ROWNUM = 1), 1, 3000, 3000, 'N', 'Replaced faulty compressor unit - refrigerator not cooling properly');
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT d.product_id FROM sales_detail d 
         JOIN sales_master m ON d.invoice_id = m.invoice_id 
         JOIN products p ON d.product_id = p.product_id
         JOIN product_categories pc ON p.category_id = pc.product_cat_id
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000003' AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Refrigerator%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'Refrigerator Thermostat' AND ROWNUM = 1), 1, 1500, 1500, 'N', 'Replaced malfunctioning thermostat for better temperature control');
    
    COMMIT;
END;
/

-- Service 4: Washing Machine Repair with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, servicelist_id, service_by, service_charge, parts_price, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000004' AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000004' AND ROWNUM = 1) AND ROWNUM = 1),
        SYSDATE - 1,
        (SELECT servicelist_id FROM service_list WHERE service_name = 'Washing Machine Repair' AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE first_name = 'Imtiaz' AND last_name = 'Bulbul' AND ROWNUM = 1),
        1500,
        1800,
        495,
        3795,
        'N'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT d.product_id FROM sales_detail d 
         JOIN sales_master m ON d.invoice_id = m.invoice_id 
         JOIN products p ON d.product_id = p.product_id
         JOIN product_categories pc ON p.category_id = pc.product_cat_id
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000004' AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Washing Machine%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'Washing Machine Drum Belt' AND ROWNUM = 1), 1, 1800, 1800, 'N', 'Replaced worn-out drum belt - machine drum was not spinning');
    
    COMMIT;
END;
/

-- Service 5: Laptop/Computer Repair with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, servicelist_id, service_by, service_charge, parts_price, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000005' AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000005' AND ROWNUM = 1) AND ROWNUM = 1),
        SYSDATE - 4,
        (SELECT servicelist_id FROM service_list WHERE service_name = 'Laptop / Computer Repair' AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
        3000,
        2500,
        825,
        6325,
        'N'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT d.product_id FROM sales_detail d 
         JOIN sales_master m ON d.invoice_id = m.invoice_id 
         JOIN products p ON d.product_id = p.product_id
         JOIN product_categories pc ON p.category_id = pc.product_cat_id
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000005' AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Laptop%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'Laptop Charger Adapter' AND ROWNUM = 1), 1, 1500, 1500, 'N', 'Charger damage not covered - warranty void due to liquid spill damage');
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT d.product_id FROM sales_detail d 
         JOIN sales_master m ON d.invoice_id = m.invoice_id 
         JOIN products p ON d.product_id = p.product_id
         JOIN product_categories pc ON p.category_id = pc.product_cat_id
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000005' AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Laptop%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'LED TV Power Supply Board' AND ROWNUM = 1), 1, 1000, 1000, 'N', 'Power supply failure caused by liquid damage - warranty not applicable');
    
    COMMIT;
END;
/

-- Service 6: TV Installation with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, servicelist_id, service_by, service_charge, parts_price, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000006' AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000006' AND ROWNUM = 1) AND ROWNUM = 1),
        SYSDATE - 10,
        (SELECT servicelist_id FROM service_list WHERE service_name = 'TV Installation' AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND ROWNUM = 1),
        1200,
        1500,
        405,
        3105,
        'Y'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'LED TV Display Panel' AND ROWNUM = 1), 1, 1500, 1500, 'Y', 'TV wall mount installation with display panel setup and cable management');
    
    COMMIT;
END;
/

-- Service 7: AC Installation with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, servicelist_id, service_by, service_charge, parts_price, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000007' AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000007' AND ROWNUM = 1) AND ROWNUM = 1),
        SYSDATE - 8,
        (SELECT servicelist_id FROM service_list WHERE service_name = 'AC Installation' AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE first_name = 'Keya' AND last_name = 'Payel' AND ROWNUM = 1),
        2500,
        2000,
        675,
        5175,
        'Y'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT d.product_id FROM sales_detail d 
         JOIN sales_master m ON d.invoice_id = m.invoice_id 
         JOIN products p ON d.product_id = p.product_id
         JOIN product_categories pc ON p.category_id = pc.product_cat_id
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000007' AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Air Conditioner%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'AC Outdoor Fan Motor' AND ROWNUM = 1), 2, 1000, 2000, 'Y', 'Complete AC installation with outdoor unit setup and dual fan motor installation');
    
    COMMIT;
END;
/

-- Service 8: Microwave Oven Repair with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, servicelist_id, service_by, service_charge, parts_price, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000008' AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000008' AND ROWNUM = 1) AND ROWNUM = 1),
        SYSDATE - 6,
        (SELECT servicelist_id FROM service_list WHERE service_name = 'Microwave Oven Repair' AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE first_name = 'Imtiaz' AND last_name = 'Bulbul' AND ROWNUM = 1),
        1200,
        2800,
        600,
        4600,
        'N'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT d.product_id FROM sales_detail d 
         JOIN sales_master m ON d.invoice_id = m.invoice_id 
         JOIN products p ON d.product_id = p.product_id
         JOIN product_categories pc ON p.category_id = pc.product_cat_id
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000008' AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Microwave%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'Microwave Oven Magnetron Tube' AND ROWNUM = 1), 1, 2800, 2800, 'N', 'Replaced burnt magnetron tube - microwave not heating food properly');
    
    COMMIT;
END;
/

-- Service 9: Mobile Service and Repair with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, servicelist_id, service_by, service_charge, parts_price, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000009' AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000009' AND ROWNUM = 1) AND ROWNUM = 1),
        SYSDATE - 7,
        (SELECT servicelist_id FROM service_list WHERE service_name = 'Mobile Service and Repair' AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
        2200,
        1500,
        555,
        4255,
        'Y'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT d.product_id FROM sales_detail d 
         JOIN sales_master m ON d.invoice_id = m.invoice_id 
         JOIN products p ON d.product_id = p.product_id
         JOIN product_categories pc ON p.category_id = pc.product_cat_id
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000009' AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Phone%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'Laptop Charger Adapter' AND ROWNUM = 1), 1, 1500, 1500, 'Y', 'Mobile phone charging port repair and compatible charger replacement');
    
    COMMIT;
END;
/

-- Service 10: Home Appliance Diagnosis with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, servicelist_id, service_by, service_charge, parts_price, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000010' AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000010' AND ROWNUM = 1) AND ROWNUM = 1),
        SYSDATE - 9,
        (SELECT servicelist_id FROM service_list WHERE service_name = 'Home Appliance Diagnosis' AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND ROWNUM = 1),
        800,
        1200,
        300,
        2300,
        'N'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (v_service_id, 
        (SELECT d.product_id FROM sales_detail d 
         JOIN sales_master m ON d.invoice_id = m.invoice_id 
         JOIN products p ON d.product_id = p.product_id
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000010' AND ROWNUM = 1)
         AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'LED TV Motherboard' AND ROWNUM = 1), 1, 1200, 1200, 'N', 'Complete diagnostic testing and motherboard inspection for home theater system');
    
    COMMIT;
END;
/


--------------------------------------------------------------------------------
-- 35. DAMAGE (Damaged Goods)
--------------------------------------------------------------------------------

INSERT INTO damage (damage_date, total_loss)
VALUES (
    SYSDATE - 7,
    45000
);

INSERT INTO damage (damage_date, total_loss)
VALUES (
    SYSDATE - 3,
    28500
);

COMMIT;


--------------------------------------------------------------------------------
-- 36. EXPENSE_MASTER (Business Expenses)
--------------------------------------------------------------------------------

INSERT INTO expense_master (expense_date, expense_by, remarks)
VALUES (
    SYSDATE - 15,
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    'Monthly rent payment'
);

INSERT INTO expense_master (expense_date, expense_by, remarks)
VALUES (
    SYSDATE - 10,
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    'Utility bills - electricity and water'
);

INSERT INTO expense_master (expense_date, expense_by, remarks)
VALUES (
    SYSDATE - 5,
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND ROWNUM = 1),
    'Marketing campaign - digital media'
);

INSERT INTO expense_master (expense_date, expense_by, remarks)
VALUES (
    SYSDATE - 1,
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    'Monthly payroll - all staff salaries'
);

COMMIT;


--------------------------------------------------------------------------------
-- 37. PAYMENTS (Supplier Payments)
--------------------------------------------------------------------------------

INSERT INTO payments (supplier_id, payment_date, amount, payment_type)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND ROWNUM = 1),
    SYSDATE - 10,
    500000,
    'BANK'
);

INSERT INTO payments (supplier_id, payment_date, amount, payment_type)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND ROWNUM = 1),
    SYSDATE - 8,
    400000,
    'ONLINE'
);

INSERT INTO payments (supplier_id, payment_date, amount, payment_type)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division' AND ROWNUM = 1),
    SYSDATE - 6,
    300000,
    'CASH'
);

INSERT INTO payments (supplier_id, payment_date, amount, payment_type)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier' AND ROWNUM = 1),
    SYSDATE - 4,
    250000,
    'ONLINE'
);

INSERT INTO payments (supplier_id, payment_date, amount, payment_type)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House' AND ROWNUM = 1),
    SYSDATE - 2,
    600000,
    'BANK'
);

COMMIT;


--------------------------------------------------------------------------------
-- 38. COM_USERS (Application Users)
--------------------------------------------------------------------------------

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'rafiqul.admin',
    'admin@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Rafiqul' AND last_name = 'Hasan' AND ROWNUM = 1),
    'ADMIN'
);

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'ariful.sales',
    'sales@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND ROWNUM = 1),
    'SALES_MANAGER'
);

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'fatima.accounts',
    'account@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND ROWNUM = 1),
    'ACCOUNTANT'
);

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'zahid.procurement',
    'purchase@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND ROWNUM = 1),
    'PROCUREMENT'
);

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'mominul.service',
    'service@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND ROWNUM = 1),
    'SERVICE_TECH'
);

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'tariq.sales',
    'sales@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Tariq' AND last_name = 'Aziz' AND ROWNUM = 1),
    'SALES_EXECUTIVE'
);

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'rumana.support',
    'support@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Rumana' AND last_name = 'Afroz' AND ROWNUM = 1),
    'CUSTOMER_SUPPORT'
);

COMMIT;


--------------------------------------------------------------------------------
-- 39. SALES_RETURN_DETAILS (Return Details for Sales Returns)
--------------------------------------------------------------------------------

INSERT INTO sales_return_details (sales_return_id, product_id, mrp, purchase_price, qty_return, reason)
VALUES (
    (SELECT sales_return_id FROM sales_return_master WHERE ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_name = 'Samsung 65" 4K LED TV' AND ROWNUM = 1),
    95000, 76000, 1, 'Unit found to have dead pixels in display'
);

INSERT INTO sales_return_details (sales_return_id, product_id, mrp, purchase_price, qty_return, reason)
VALUES (
    (SELECT sales_return_id FROM sales_return_master WHERE ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_name = 'Walton 2-Door Refrigerator (300L)' AND ROWNUM = 1),
    35000, 28000, 1, 'Compressor making unusual noise'
);

COMMIT;


--------------------------------------------------------------------------------
-- 40. SERVICE_DETAILS (Integrated with SERVICE_MASTER above)
--------------------------------------------------------------------------------
-- Note: Service details are now integrated with their master records in PL/SQL blocks above
-- This eliminates the need for separate INSERT statements and ensures proper FK relationships


--------------------------------------------------------------------------------
-- 41. EXPENSE_DETAILS (Expense Line Items)
--------------------------------------------------------------------------------

INSERT INTO expense_details (expense_id, expense_type_id, description, amount, quantity, line_total)
VALUES (
    'EXM1',
    (SELECT expense_type_id FROM expense_list WHERE type_name = 'Staff Salary' AND ROWNUM = 1),
    'Monthly salary for 10 sales staff',
    45000,
    10,
    450000
);

INSERT INTO expense_details (expense_id, expense_type_id, description, amount, quantity, line_total)
VALUES (
    'EXM2',
    (SELECT expense_type_id FROM expense_list WHERE type_name = 'Utility Bills' AND ROWNUM = 1),
    'Electricity, water, internet for December',
    8000,
    1,
    8000
);

INSERT INTO expense_details (expense_id, expense_type_id, description, amount, quantity, line_total)
VALUES (
    'EXM3',
    (SELECT expense_type_id FROM expense_list WHERE type_name = 'Office Rent' AND ROWNUM = 1),
    'Monthly shop rent - Mirpur location',
    50000,
    1,
    50000
);

INSERT INTO expense_details (expense_id, expense_type_id, description, amount, quantity, line_total)
VALUES (
    'EXM4',
    (SELECT expense_type_id FROM expense_list WHERE type_name = 'Transport and Delivery Cost' AND ROWNUM = 1),
    'Courier charges for product delivery',
    500,
    8,
    4000
);

COMMIT;


--------------------------------------------------------------------------------
-- 42. DAMAGE_DETAIL (Damage Details for Damaged Goods)
--------------------------------------------------------------------------------

INSERT INTO damage_detail (damage_id, product_id, mrp, purchase_price, damage_quantity, reason)
VALUES (
    (SELECT damage_id FROM damage WHERE ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_name = 'Walton 2-Door Refrigerator (300L)' AND ROWNUM = 1),
    35000,
    28000,
    1,
    'Unit dropped during warehouse handling - compressor damaged'
);

INSERT INTO damage_detail (damage_id, product_id, mrp, purchase_price, damage_quantity, reason)
VALUES (
    (SELECT damage_id FROM damage WHERE ROWNUM = 2),
    (SELECT product_id FROM products WHERE product_name = 'LG Washing Machine (7kg)' AND ROWNUM = 1),
    28000,
    22400,
    1,
    'Water ingress during monsoon - motor short circuit'
);

COMMIT;


--------------------------------------------------------------------------------
