# Service Tables: Corrected Design

## 🎯 The Key Insight

**servicelist_id** (service type) and **service_charge** should be **PER PRODUCT**, not per ticket.

---

## 📊 Entity Relationship Diagram

```
┌─────────────────────────────┐
│      SERVICE_MASTER         │
├─────────────────────────────┤
│ service_id (PK)    ◄─────┐  │
│ service_date           │  │  │
│ customer_id            │  │  │
│ invoice_id         ┌────┘  │  │
│ service_by         │       │  │
│ warranty_applicable│       │  │
│                    │       │  │
│ service_charge     │ ◄──┐  │  │
│ parts_price        │    │  │  │
│ total_price        │    │  │  │
│ vat                │    │  │  │
│ grand_total        │    │  │  │
└─────────────────────────┬───┘  │
        ▲                 │      │
        │ 1:N             │      │
        │                 │      │
┌───────┴──────────────────┘      │
│                                 │
│  ┌──────────────────────────────┤
│  │   SERVICE_DETAILS        ◄───┘
│  ├──────────────────────────────┤
│  │ service_det_id (PK)
│  │ service_id (FK)      ────────► SERVICE_MASTER
│  │ product_id (FK)      ────────► PRODUCTS
│  │ servicelist_id (FK)  ────────► SERVICE_LIST  ← ✅ NOW HERE!
│  │                                            
│  │ service_charge       ← ✅ NOW HERE! (per product)
│  │ parts_price
│  │ parts_id (FK)        ────────► PARTS
│  │ quantity
│  │ line_total           ◄─ Auto-calculated
│  │ warranty_status
│  │
│  │ status, cre_by, cre_dt, upd_by, upd_dt (audit)
│  └──────────────────────────────┘
└─────────────────────────────────┘
```

---

## 📑 Data Flow Example

### Service Ticket with 3 Products

```
CUSTOMER: John Smith (C001)
INVOICE: INV0001 (Samsung TV, Microwave, Refrigerator)
═══════════════════════════════════════════════════════════

SERVICE_MASTER: SVM0001
├─ service_date: 2024-12-15
├─ service_by: Rahim (E005)
├─ warranty_applicable: Y
│
├─ service_charge: 5,500  ◄─ SUM of details below
├─ parts_price: 4,000     ◄─ SUM of details below
├─ total_price: 9,500
├─ vat: 950
└─ grand_total: 10,450

    SERVICE_DETAILS
    ├─ SDT0001: Samsung TV 55"
    │  ├─ servicelist_id: REP001 (Screen Repair)
    │  ├─ service_charge: 2,000  ◄─ PER PRODUCT
    │  ├─ parts_id: PART001 (LED Panel)
    │  ├─ parts_price: 1,500
    │  ├─ quantity: 1
    │  └─ line_total: 3,500  ◄─ (2000 + 1500*1)
    │
    ├─ SDT0002: Samsung Microwave
    │  ├─ servicelist_id: REM001 (Component Replacement)
    │  ├─ service_charge: 1,500  ◄─ PER PRODUCT (different!)
    │  ├─ parts_id: PART002 (Magnetron)
    │  ├─ parts_price: 2,000
    │  ├─ quantity: 1
    │  └─ line_total: 3,500  ◄─ (1500 + 2000*1)
    │
    └─ SDT0003: Samsung Refrigerator
       ├─ servicelist_id: MAI001 (Maintenance)
       ├─ service_charge: 2,000  ◄─ PER PRODUCT (different!)
       ├─ parts_id: PART003 (Compressor Oil)
       ├─ parts_price: 500
       ├─ quantity: 1
       └─ line_total: 2,500  ◄─ (2000 + 500*1)

TOTALS:
────────────────────────────────────────────────────
service_charge = 2,000 + 1,500 + 2,000 = 5,500
parts_price    = 1,500 + 2,000 + 500   = 4,000
total_price    = 5,500 + 4,000         = 9,500
vat (10%)      = 9,500 * 0.10          = 950
grand_total    = 9,500 + 950           = 10,450
═══════════════════════════════════════════════════════════
```

---

## 🔧 Database Columns Checklist

### SERVICE_MASTER
```
✅ service_id          - Primary key (SVM0001)
✅ service_date        - When service was created
✅ customer_id         - Who is being served
✅ invoice_id          - Original purchase invoice
✅ warranty_applicable - Overall (Y/N)
✅ service_by          - Technician
❌ servicelist_id      - REMOVED (now in details)
❌ service_charge      - REMOVED (now summed from details)
✅ parts_price         - SUM of detail parts
✅ total_price         - service_charge + parts_price
✅ vat                 - Tax amount
✅ grand_total         - Final amount
✅ status              - 1=Active, 0=Cancelled
✅ cre_by, cre_dt      - Created by/date
✅ upd_by, upd_dt      - Updated by/date
```

### SERVICE_DETAILS
```
✅ service_det_id      - Primary key (SDT0001)
✅ service_id          - Link to master
✅ product_id          - Which product
✅ servicelist_id      - ADDED ✅ Service type PER PRODUCT
✅ parts_id            - Part used
✅ service_charge      - ADDED ✅ Charge PER PRODUCT
✅ parts_price         - Cost of part
✅ quantity            - Number of parts
✅ line_total          - Auto-calculated
✅ description         - Notes
✅ warranty_status     - Per-product warranty
✅ status              - 1=Active, 0=Cancelled
✅ cre_by, cre_dt      - Created by/date
✅ upd_by, upd_dt      - Updated by/date
```

---

## 🔗 Foreign Key Relationships

### SERVICE_MASTER

| FK Name | References | Purpose |
|---------|-----------|---------|
| `fk_sm_cust` | customers(customer_id) | Who owns the service ticket |
| `fk_sm_emp` | employees(employee_id) | Technician performing service |
| `fk_sm_inv` | sales_master(invoice_id) | Original purchase reference |

### SERVICE_DETAILS

| FK Name | References | Purpose |
|---------|-----------|---------|
| `fk_sd_master` | service_master(service_id) | Which service ticket |
| `fk_sd_list` | service_list(servicelist_id) | Service type (NEW ✅) |
| `fk_sd_prod` | products(product_id) | Which product |
| `fk_sd_parts` | parts(parts_id) | Which part used |

---

## 📝 Trigger Logic

### trg_service_det_bi (BEFORE INSERT/UPDATE)

```
WHEN record is inserted/updated in SERVICE_DETAILS:

1. Generate ID
   IF :NEW.service_det_id IS NULL THEN
      :NEW.service_det_id := 'SDT' || sequence

2. Calculate line total
   :NEW.line_total := service_charge + (parts_price × quantity)
   Example: 2000 + (1500 × 1) = 3500

3. Populate audit columns
   IF INSERTING: set status=1, cre_by=USER, cre_dt=SYSDATE
   IF UPDATING: set upd_by=USER, upd_dt=SYSDATE
```

### trg_service_det_master_audit (AFTER INSERT/UPDATE/DELETE)

```
WHEN any SERVICE_DETAILS record changes:
   UPDATE SERVICE_MASTER
   SET upd_by = USER, upd_dt = SYSDATE
   WHERE service_id = (newly inserted/deleted detail's service_id)
   
   → Keeps master record timestamp current
```

---

## 📊 Calculation Examples

### Example 1: TV Screen Repair
```
service_charge: 2,000
parts_id: LED Panel
parts_price: 1,500
quantity: 1

line_total = 2,000 + (1,500 × 1) = 3,500
```

### Example 2: Microwave Component Replacement with 2 Magnetrons
```
service_charge: 1,500
parts_id: Magnetron
parts_price: 2,000
quantity: 2

line_total = 1,500 + (2,000 × 2) = 5,500
```

### Example 3: Refrigerator Maintenance (no parts)
```
service_charge: 2,000
parts_id: NULL
parts_price: 0
quantity: 0

line_total = 2,000 + (0 × 0) = 2,000
```

---

## ✅ Verification Queries

### Check table structure
```sql
DESC service_master;
DESC service_details;
```

### Check sample service with multiple products
```sql
SELECT 
    m.service_id,
    m.customer_id,
    m.service_charge,
    d.service_det_id,
    d.product_id,
    d.servicelist_id,
    d.service_charge as detail_charge,
    d.line_total
FROM service_master m
JOIN service_details d ON m.service_id = d.service_id
WHERE m.service_id = 'SVM0001'
ORDER BY d.service_det_id;
```

---

## 🎓 Benefits of This Design

| Aspect | Benefit |
|--------|---------|
| **Flexibility** | Each product can have different service type |
| **Accuracy** | Each product has correct charge |
| **Auditability** | Each detail is tracked separately |
| **Real-world match** | Reflects actual business process |
| **Maintainability** | Clear separation of concerns |
| **Scalability** | Easy to add more products |
| **Reporting** | Can analyze per-product service patterns |

---

**Last Updated:** January 12, 2026  
**Status:** ✅ Schema Updated & Tested  
**Next:** Ready for production deployment
