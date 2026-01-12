# 📋 Service Tables - Complete Reference

**Oxen Company Limited - Service Management Database**

---

## 🎯 Overview

The service management system consists of **3 core tables**:

1. **SERVICE_LIST** - Service types and pricing (master reference)
2. **SERVICE_MASTER** - Service tickets (header/transaction)
3. **SERVICE_DETAILS** - Service items per ticket (line items)
4. **SERVICE_PARTS** (Optional) - Parts used per service item (bridge table)

---

## 📊 Table Hierarchy

```
SERVICE_LIST (Reference/Lookup)
    └─ Describes types of services (Repair, Maintenance, Installation, etc.)
        └─ Each has a standard service charge

SERVICE_MASTER (Transaction Header)
    └─ One service ticket per customer
        └─ Contains: customer, invoice, technician, dates, totals

SERVICE_DETAILS (Transaction Line Items)
    └─ Multiple products per service ticket
        └─ Each product can have different service type and warranty status

SERVICE_PARTS (Optional Bridge - for parts tracking)
    └─ Multiple parts per service detail line
        └─ Each part has quantity and unit price
```

---

## 1️⃣ SERVICE_LIST Table

### Purpose
Master reference table for types of services offered by the company.

### Current Structure
```sql
CREATE TABLE service_list (
    servicelist_id VARCHAR2(50) PRIMARY KEY,    -- SRV001, REP002, etc.
    service_name   VARCHAR2(150) NOT NULL,      -- "Screen Repair", "Maintenance", etc.
    service_desc   VARCHAR2(1000),              -- Detailed description
    service_cost   NUMBER DEFAULT 0,            -- Standard charge for this service
    status         NUMBER,                      -- 1=Active, 0=Inactive
    cre_by         VARCHAR2(100),               -- Created by (audit)
    cre_dt         DATE,                        -- Created date (audit)
    upd_by         VARCHAR2(100),               -- Updated by (audit)
    upd_dt         DATE                         -- Updated date (audit)
);
```

### Sequence
```sql
CREATE SEQUENCE service_list_seq 
    START WITH 1 
    INCREMENT BY 1 
    NOCACHE NOCYCLE;
```

### Trigger (Auto ID Generation)
```sql
CREATE OR REPLACE TRIGGER trg_service_list_bi
BEFORE INSERT OR UPDATE ON service_list FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate servicelist_id only if null during INSERT
    IF INSERTING AND :NEW.servicelist_id IS NULL THEN
        v_seq := service_list_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.service_name), 1, 3));
        :NEW.servicelist_id := NVL(v_code, 'SRV') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns
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
```

### Sample Data
```sql
INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Screen Repair', 'TV screen replacement and repair', 2000);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Maintenance', 'Regular maintenance and cleaning', 1500);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Component Replacement', 'Replace faulty components', 2500);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Installation', 'Install new equipment', 1000);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Warranty Service', 'Service covered by warranty', 0);
```

### Query Examples
```sql
-- Get all active service types
SELECT servicelist_id, service_name, service_cost
FROM service_list
WHERE status = 1
ORDER BY service_name;

-- Get service cost for specific service
SELECT service_cost
FROM service_list
WHERE servicelist_id = 'REP001';

-- Count services by type
SELECT service_name, COUNT(*) as service_count
FROM service_list
GROUP BY service_name;
```

---

## 2️⃣ SERVICE_MASTER Table

### Purpose
Main transaction table for service tickets/jobs. One record per service request.

### Current Structure
```sql
CREATE TABLE service_master (
    service_id          VARCHAR2(50) PRIMARY KEY,      -- SVM0001, SVM0002, etc.
    service_date        DATE DEFAULT SYSDATE,          -- Date of service
    customer_id         VARCHAR2(50) NULL,             -- Who requested the service (FK)
    invoice_id          VARCHAR2(50) NULL,             -- Original purchase invoice (FK)
    warranty_applicable CHAR(1),                       -- 'Y' or 'N' (all products combined)
    servicelist_id      VARCHAR2(50) NULL,             -- Type of service (FK)
    service_by          VARCHAR2(50) NULL,             -- Technician assigned (FK)
    service_charge      NUMBER DEFAULT 0,              -- Total service charges
    parts_price         NUMBER DEFAULT 0,              -- Total parts cost
    total_price         NUMBER(20,4) DEFAULT 0,        -- Subtotal (service + parts)
    vat                 NUMBER(20,4) DEFAULT 0,        -- VAT/Tax amount
    grand_total         NUMBER(20,4) DEFAULT 0,        -- Final total
    status              NUMBER,                        -- 1=Active, 0=Cancelled
    cre_by              VARCHAR2(100),                 -- Created by (audit)
    cre_dt              DATE,                          -- Created date (audit)
    upd_by              VARCHAR2(100),                 -- Updated by (audit)
    upd_dt              DATE,                          -- Updated date (audit)
    
    -- Foreign Keys
    CONSTRAINT fk_sm_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_sm_list FOREIGN KEY (servicelist_id) REFERENCES service_list(servicelist_id),
    CONSTRAINT fk_sm_emp FOREIGN KEY (service_by) REFERENCES employees(employee_id),
    CONSTRAINT fk_sm_inv FOREIGN KEY (invoice_id) REFERENCES sales_master(invoice_id)
);
```

### Sequence
```sql
CREATE SEQUENCE service_master_seq 
    START WITH 1 
    INCREMENT BY 1 
    NOCACHE NOCYCLE;
```

### Trigger (Auto ID Generation)
```sql
CREATE OR REPLACE TRIGGER trg_service_master_bi
BEFORE INSERT OR UPDATE ON service_master FOR EACH ROW
BEGIN
    -- Generate service_id only if null during INSERT
    IF INSERTING AND :NEW.service_id IS NULL THEN
        :NEW.service_id := 'SVM' || TO_CHAR(service_master_seq.NEXTVAL);
    END IF;
    
    -- Populate audit columns
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
```

### Relationships
| Column | References | Purpose |
|--------|------------|---------|
| `customer_id` | customers(customer_id) | Who requested the service |
| `invoice_id` | sales_master(invoice_id) | Original purchase (for warranty check) |
| `servicelist_id` | service_list(servicelist_id) | Type of service |
| `service_by` | employees(employee_id) | Technician performing service |

### Sample Data
```sql
INSERT INTO service_master (
    service_date, 
    customer_id, 
    invoice_id, 
    warranty_applicable,
    service_by,
    status
)
SELECT
    SYSDATE,
    c.customer_id,
    sm.invoice_id,
    'Y',
    e.employee_id,
    1
FROM customers c, sales_master sm, employees e
WHERE c.customer_id = sm.customer_id
  AND e.job_id = (SELECT job_id FROM jobs WHERE job_title = 'Technician')
  AND ROWNUM <= 5;
```

### Query Examples
```sql
-- Get service tickets for customer
SELECT service_id, service_date, grand_total, status
FROM service_master
WHERE customer_id = 'C001'
ORDER BY service_date DESC;

-- Get pending service tickets (today)
SELECT sm.service_id, c.customer_name, sm.service_date, sm.grand_total
FROM service_master sm
JOIN customers c ON sm.customer_id = c.customer_id
WHERE TRUNC(sm.service_date) = TRUNC(SYSDATE)
  AND sm.status = 1;

-- Get service revenue by technician
SELECT e.first_name || ' ' || e.last_name as technician, 
       SUM(sm.grand_total) as total_revenue,
       COUNT(sm.service_id) as ticket_count
FROM service_master sm
JOIN employees e ON sm.service_by = e.employee_id
WHERE sm.service_date >= ADD_MONTHS(SYSDATE, -1)
GROUP BY e.first_name, e.last_name
ORDER BY total_revenue DESC;
```

---

## 3️⃣ SERVICE_DETAILS Table

### Purpose
Line items for service master. Multiple products/services per ticket.

### Current Structure
```sql
CREATE TABLE service_details (
    service_det_id     VARCHAR2(50) PRIMARY KEY,      -- SDT0001, SDT0002, etc.
    service_id         VARCHAR2(50) NULL,             -- Link to master (FK)
    product_id         VARCHAR2(50) NULL,             -- Product being serviced (FK)
    parts_id           VARCHAR2(50) NULL,             -- Part used (optional) (FK)
    parts_price        NUMBER DEFAULT 0,              -- Cost of parts
    quantity           NUMBER DEFAULT 1,              -- Quantity of parts
    line_total         NUMBER DEFAULT 0,              -- parts_price * quantity
    description        VARCHAR2(1000),                -- Service notes
    warranty_status    VARCHAR2(50),                  -- IN WARRANTY / OUT OF WARRANTY
    
    -- Foreign Keys
    CONSTRAINT fk_sd_master FOREIGN KEY (service_id) REFERENCES service_master(service_id),
    CONSTRAINT fk_sd_parts FOREIGN KEY (parts_id) REFERENCES parts(parts_id),
    CONSTRAINT fk_sd_prod FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

### Sequence
```sql
CREATE SEQUENCE service_det_seq 
    START WITH 1 
    INCREMENT BY 1 
    NOCACHE NOCYCLE;
```

### Triggers
```sql
-- ID Generation
CREATE OR REPLACE TRIGGER trg_service_det_bi 
BEFORE INSERT ON service_details 
FOR EACH ROW 
BEGIN 
    -- Generate service_det_id
    IF :NEW.service_det_id IS NULL THEN
        :NEW.service_det_id := 'SDT' || TO_CHAR(service_det_seq.NEXTVAL);  
    END IF;
END;
/

-- Keep master audit columns current
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
```

### Relationships
| Column | References | Purpose |
|--------|------------|---------|
| `service_id` | service_master(service_id) | Which service ticket |
| `product_id` | products(product_id) | Which product being serviced |
| `parts_id` | parts(parts_id) | Which spare part used |

### Sample Data
```sql
INSERT INTO service_details (
    service_id, 
    product_id, 
    parts_id,
    parts_price,
    quantity,
    description,
    warranty_status
)
VALUES (
    'SVM0001',
    'P001',
    'PART001',
    1200,
    1,
    'LED Panel replacement for 55-inch TV',
    'IN WARRANTY'
);
```

### Query Examples
```sql
-- Get all services for a specific service ticket
SELECT sd.service_det_id, p.product_name, pt.parts_name, sd.warranty_status
FROM service_details sd
LEFT JOIN products p ON sd.product_id = p.product_id
LEFT JOIN parts pt ON sd.parts_id = pt.parts_id
WHERE sd.service_id = 'SVM0001';

-- Get warranty vs non-warranty service revenue
SELECT sd.warranty_status, COUNT(*) as service_count, SUM(sd.line_total) as revenue
FROM service_details sd
WHERE sd.service_id IN (
    SELECT service_id FROM service_master WHERE service_date >= ADD_MONTHS(SYSDATE, -3)
)
GROUP BY sd.warranty_status;

-- Get most serviced products
SELECT p.product_name, COUNT(sd.service_det_id) as service_count
FROM service_details sd
JOIN products p ON sd.product_id = p.product_id
WHERE sd.service_id IN (
    SELECT service_id FROM service_master WHERE service_date >= ADD_MONTHS(SYSDATE, -6)
)
GROUP BY p.product_name
ORDER BY service_count DESC;
```

---

## 4️⃣ SERVICE_PARTS Table (Optional Enhancement)

### Purpose
Bridge table for handling multiple parts per service detail (when you want detailed parts tracking).

### Structure (from service_form_upgrade.sql)
```sql
CREATE TABLE service_parts (
    service_parts_id   VARCHAR2(50) PRIMARY KEY,      -- SPT0001, SPT0002, etc.
    service_det_id     VARCHAR2(50) NOT NULL,         -- Link to detail (FK)
    parts_id           VARCHAR2(50) NOT NULL,         -- Part used (FK)
    quantity           NUMBER DEFAULT 1,              -- How many parts
    unit_price         NUMBER DEFAULT 0,              -- Price per part
    line_total         NUMBER DEFAULT 0,              -- qty * price (auto-calculated)
    status             NUMBER DEFAULT 1,              -- 1=Active, 0=Voided
    cre_by             VARCHAR2(100),                 -- Audit
    cre_dt             DATE,                          -- Audit
    upd_by             VARCHAR2(100),                 -- Audit
    upd_dt             DATE,                          -- Audit
    
    -- Foreign Keys
    CONSTRAINT fk_sp_det FOREIGN KEY (service_det_id) 
        REFERENCES service_details(service_det_id) ON DELETE CASCADE,
    CONSTRAINT fk_sp_part FOREIGN KEY (parts_id) 
        REFERENCES parts(parts_id)
);
```

### When to Use SERVICE_PARTS
- When you need **detailed parts tracking** per service item
- When one service might use **multiple parts**
- When you need **stock deduction** per part used
- When you want **detailed reports** on parts consumption

### Sequence & Trigger
```sql
CREATE SEQUENCE service_parts_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_service_parts_bi
BEFORE INSERT OR UPDATE ON service_parts FOR EACH ROW
BEGIN
    IF INSERTING THEN
        IF :NEW.service_parts_id IS NULL THEN
            :NEW.service_parts_id := 'SPT' || TO_CHAR(service_parts_seq.NEXTVAL);
        END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
    
    -- Auto-calculate line total
    :NEW.line_total := NVL(:NEW.quantity, 0) * NVL(:NEW.unit_price, 0);
END;
/
```

---

## 🔄 Table Relationships Diagram

```
SERVICE_LIST (Reference)
    ↓
    └─ SERVICE_MASTER
        (1 service ticket)
        ├─ customer_id → CUSTOMERS
        ├─ invoice_id → SALES_MASTER
        ├─ service_by → EMPLOYEES
        └─ servicelist_id → SERVICE_LIST
            ↓
            └─ SERVICE_DETAILS (Many products)
                ├─ product_id → PRODUCTS
                ├─ parts_id → PARTS
                └─ service_id → SERVICE_MASTER
                    ↓
                    └─ SERVICE_PARTS (Optional - Many parts)
                        ├─ parts_id → PARTS
                        ├─ service_det_id → SERVICE_DETAILS
                        └─ stock tracking
```

---

## 📋 Column Descriptions

### SERVICE_MASTER Columns

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `service_id` | VARCHAR2(50) | Unique ticket ID | PRIMARY KEY |
| `service_date` | DATE | When service performed | Defaults to SYSDATE |
| `customer_id` | VARCHAR2(50) | Customer requesting service | FK to customers |
| `invoice_id` | VARCHAR2(50) | Original purchase invoice | FK to sales_master |
| `warranty_applicable` | CHAR(1) | Is service under warranty? | Y/N |
| `servicelist_id` | VARCHAR2(50) | Service type | FK to service_list |
| `service_by` | VARCHAR2(50) | Technician assigned | FK to employees |
| `service_charge` | NUMBER | Total service charges | ≥ 0 |
| `parts_price` | NUMBER | Total parts cost | ≥ 0 |
| `total_price` | NUMBER(20,4) | Subtotal | Calculated |
| `vat` | NUMBER(20,4) | Tax (15%) | Calculated |
| `grand_total` | NUMBER(20,4) | Final amount | Calculated |
| `status` | NUMBER | Record status | 1=Active, 0=Inactive |
| `cre_by` | VARCHAR2(100) | Created by | Auto from trigger |
| `cre_dt` | DATE | Created date | Auto from trigger |
| `upd_by` | VARCHAR2(100) | Updated by | Auto from trigger |
| `upd_dt` | DATE | Updated date | Auto from trigger |

---

## 🎯 Common Operations

### Create Service Ticket
```sql
-- Insert master record
INSERT INTO service_master (
    customer_id,
    invoice_id,
    warranty_applicable,
    service_by,
    status
) VALUES (
    'C001',
    'INV0001',
    'Y',
    'EMP001',
    1
);

-- service_id auto-generated as SVM0001

-- Insert detail records
INSERT INTO service_details (
    service_id,
    product_id,
    warranty_status,
    description
) VALUES (
    'SVM0001',
    'P001',
    'IN WARRANTY',
    'TV screen repair'
);
```

### Update Service Total
```sql
UPDATE service_master
SET service_charge = 5000,
    parts_price = 2000,
    total_price = 7000,
    vat = 1050,
    grand_total = 8050
WHERE service_id = 'SVM0001';
```

### Query Service Summary
```sql
SELECT 
    sm.service_id,
    sm.service_date,
    c.customer_name,
    e.first_name || ' ' || e.last_name as technician,
    sm.warranty_applicable,
    sm.grand_total
FROM service_master sm
LEFT JOIN customers c ON sm.customer_id = c.customer_id
LEFT JOIN employees e ON sm.service_by = e.employee_id
WHERE sm.status = 1
ORDER BY sm.service_date DESC;
```

---

## 📊 Data Integrity Rules

### Mandatory Fields
- ✅ `service_id` - Auto-generated
- ✅ `service_date` - Defaults to today
- ✅ At least one of: `customer_id` OR `invoice_id`
- ✅ `service_by` - Technician required
- ✅ At least one `service_details` record

### Constraints
- ⚠️ `service_charge` ≥ 0
- ⚠️ `parts_price` ≥ 0
- ⚠️ `grand_total` = `total_price` + `vat`
- ⚠️ `warranty_applicable` must be 'Y' or 'N'
- ⚠️ `status` must be 1 or 0

### Foreign Key Rules
- ✅ `customer_id` must exist in CUSTOMERS (if provided)
- ✅ `invoice_id` must exist in SALES_MASTER (if provided)
- ✅ `service_by` must exist in EMPLOYEES
- ✅ `servicelist_id` must exist in SERVICE_LIST
- ✅ `product_id` must exist in PRODUCTS
- ✅ `parts_id` must exist in PARTS

---

## 🔐 Audit Trail

All service tables automatically track:
- **Created by**: `cre_by` (from USER function)
- **Created date**: `cre_dt` (from SYSDATE)
- **Updated by**: `upd_by` (from USER function)
- **Updated date**: `upd_dt` (from SYSDATE)

Updated automatically by triggers on INSERT/UPDATE.

---

## 📈 Growth Estimates

### Typical Data Volume
```
SERVICE_LIST:      10-50 records (master reference, static)
SERVICE_MASTER:    100-1,000 records/month (transactional)
SERVICE_DETAILS:   200-5,000 records/month (line items)
SERVICE_PARTS:     500-15,000 records/month (detail parts - if used)
```

### Performance Considerations
- Index on `SERVICE_MASTER(service_date)` for time-range queries
- Index on `SERVICE_MASTER(customer_id)` for customer lookups
- Index on `SERVICE_DETAILS(service_id)` for detail lookups
- Index on `SERVICE_DETAILS(product_id)` for product analysis

---

## 🔧 Maintenance Operations

### Archive Old Service Records
```sql
-- Archive service records older than 2 years
CREATE TABLE service_master_archive AS
SELECT * FROM service_master
WHERE service_date < ADD_MONTHS(SYSDATE, -24)
  AND status = 1;

-- Delete archived records (optional)
DELETE FROM service_master
WHERE service_date < ADD_MONTHS(SYSDATE, -24)
  AND status = 1;

COMMIT;
```

### Validate Data Integrity
```sql
-- Check for orphaned service details
SELECT sd.service_det_id
FROM service_details sd
LEFT JOIN service_master sm ON sd.service_id = sm.service_id
WHERE sm.service_id IS NULL;

-- Check for invalid customer references
SELECT service_id
FROM service_master
WHERE customer_id IS NOT NULL
  AND customer_id NOT IN (SELECT customer_id FROM customers);
```

---

## 📚 Related Documentation

- **SERVICE_FORM_COMPLETE_GUIDE.md** - How to build Forms for service
- **SERVICE_FORM_VISUAL_REFERENCE.md** - Visual diagrams
- **service_form_upgrade.sql** - SQL script to add SERVICE_PARTS table
- **FORMS_INTEGRATION_COMPLETE_GUIDE.md** - General Forms patterns

---

**Last Updated:** January 12, 2026  
**Database:** Oracle 11g+  
**Tables:** 3 main + 1 optional (SERVICE_PARTS)  
**Status:** Production-Ready

