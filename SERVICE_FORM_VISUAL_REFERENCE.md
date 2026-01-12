# 🎨 Service Form Visual Quick Reference

**One-Page Visual Guide for Multi-Product Service Form**

---

## 📐 Data Model - Visual ERD

```
┌──────────────────────────┐
│   CUSTOMERS              │
│  ──────────────────────  │
│  • customer_id (PK)      │◄─────┐
│  • customer_name         │      │
│  • phone_no              │      │
└──────────────────────────┘      │
                                  │
┌──────────────────────────┐      │
│   SALES_MASTER           │      │
│  ──────────────────────  │      │
│  • invoice_id (PK)       │◄─────┼─────┐
│  • invoice_date          │      │     │
│  • customer_id (FK) ─────┘      │     │
└──────────────────────────┘      │     │
          │                       │     │
          │ Has Many              │     │
          ▼                       │     │
┌──────────────────────────┐      │     │
│   SALES_DETAIL           │      │     │
│  ──────────────────────  │      │     │
│  • detail_id (PK)        │      │     │
│  • invoice_id (FK) ───────┘     │     │
│  • product_id (FK) ────┐        │     │
└──────────────────────────┘     │     │
                                 │     │
┌──────────────────────────┐     │     │
│   PRODUCTS               │     │     │
│  ──────────────────────  │     │     │
│  • product_id (PK) ◄──────┼─────┼─────┼─┐
│  • product_name          │     │     │ │
│  • warranty_months       │     │     │ │
└──────────────────────────┘     │     │ │
                                 │     │ │
┌──────────────────────────┐     │     │ │
│   SERVICE_MASTER         │     │     │ │
│  ──────────────────────  │     │     │ │
│  • service_id (PK)       │     │     │ │
│  • invoice_id (FK) ───────┘     │     │ │
│  • customer_id (FK) ─────────────┘     │ │
│  • service_date          │             │ │
│  • grand_total           │             │ │
└──────────────────────────┘             │ │
          │                              │ │
          │ Has Many                     │ │
          ▼                              │ │
┌──────────────────────────┐             │ │
│   SERVICE_DETAILS        │             │ │
│  ──────────────────────  │             │ │
│  • service_det_id (PK)   │             │ │
│  • service_id (FK) ───────┘             │ │
│  • product_id (FK) ─────────────────────┘ │
│  • service_type_id (FK)  │◄──┐           │
│  • service_charge        │   │           │
│  • parts_total           │   │           │
│  • line_total            │   │           │
└──────────────────────────┘   │           │
          │                    │           │
          │ Has Many           │           │
          ▼                    │           │
┌──────────────────────────┐   │           │
│   SERVICE_PARTS (NEW!)   │   │           │
│  ──────────────────────  │   │           │
│  • service_parts_id (PK) │   │           │
│  • service_det_id (FK) ───┘   │           │
│  • parts_id (FK) ─────────────┼───┐       │
│  • quantity              │    │   │       │
│  • unit_price            │    │   │       │
│  • line_total            │    │   │       │
└──────────────────────────┘    │   │       │
                                │   │       │
┌──────────────────────────┐    │   │       │
│   SERVICE_LIST           │    │   │       │
│  ──────────────────────  │    │   │       │
│  • servicelist_id (PK) ◄──────┘   │       │
│  • service_name          │        │       │
│  • service_charge        │        │       │
└──────────────────────────┘        │       │
                                    │       │
┌──────────────────────────┐        │       │
│   PARTS                  │        │       │
│  ──────────────────────  │        │       │
│  • parts_id (PK) ◄──────────────┘       │
│  • parts_name            │              │
│  • unit_price            │              │
└──────────────────────────┘              │
                                          │
┌──────────────────────────┐              │
│   STOCK                  │              │
│  ──────────────────────  │              │
│  • stock_id (PK)         │              │
│  • product_id (FK) ◄──────────────────┘
│  • quantity              │ (Parts deducted from stock)
└──────────────────────────┘
```

---

## 🖼️ Form Layout - Block Hierarchy

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  🎫 SERVICE TICKET FORM                            ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                                     ┃
┃  📄 BLOCK 1: SERVICE_MASTER                        ┃
┃  ┌─────────────────────────────────────────────┐  ┃
┃  │ Service#: SVM0001    Date: 12-JAN-2026     │  ┃
┃  │                                             │  ┃
┃  │ Invoice:  [INV0001] 🔍 [Load Products]     │  ┃
┃  │ Customer: John Smith - 01712345678          │  ┃
┃  │ Warranty: ◉ Yes  ○ No                       │  ┃
┃  │ Tech:     Abdullah Rahman 🔍                │  ┃
┃  └─────────────────────────────────────────────┘  ┃
┃           ▲                                        ┃
┃           │ Master Record (1)                      ┃
┃           │                                        ┃
┃           ├──────────────────────────────┐         ┃
┃           │ Relationship: service_id     │         ┃
┃           └──────────────────────────────┘         ┃
┃           ▼                                        ┃
┃  📋 BLOCK 2: SERVICE_DETAILS (Scrollable)          ┃
┃  ┌─────────────────────────────────────────────┐  ┃
┃  │ # │ Product        │ Service │ Warranty │ $ │  ┃
┃  ├───┼────────────────┼─────────┼──────────┼───┤  ┃
┃  │ 1 │ Samsung TV     │ Repair  │ IN ✓     │3.5│  ┃◄─┐
┃  │ 2 │ Microwave      │ Replace │ OUT ✗    │4.0│  ┃  │
┃  │ 3 │ Refrigerator   │ Maint.  │ IN ✓     │4.0│  ┃  │
┃  └─────────────────────────────────────────────┘  ┃  │
┃           ▲                                        ┃  │
┃           │ Detail Records (Many)                  ┃  │
┃           │                                        ┃  │
┃           ├──────────────────────────────┐         ┃  │
┃           │ Relationship: service_det_id │         ┃  │
┃           └──────────────────────────────┘         ┃  │
┃           ▼                                        ┃  │
┃  🔧 BLOCK 3: SERVICE_PARTS (For Selected Product)  ┃  │
┃  ┌─────────────────────────────────────────────┐  ┃  │
┃  │ 🔹 Parts for: Samsung TV                    │  ┃  │
┃  ├───┬─────────────────┬─────┬───────┬─────────┤  ┃  │
┃  │ # │ Part Name       │ Qty │ Price │  Total  │  ┃  │
┃  ├───┼─────────────────┼─────┼───────┼─────────┤  ┃  │
┃  │ 1 │ LED Panel 55"   │  1  │ 1,200 │  1,200  │  ┃  │
┃  │ 2 │ Remote Control  │  1  │   300 │    300  │  ┃  │
┃  │ 3 │ HDMI Cable      │  2  │    50 │    100  │  ┃  │
┃  └─────────────────────────────────────────────┘  ┃  │
┃           ▲                                        ┃  │
┃           │ Parts Records (Many per product)       ┃  │
┃           │                                        ┃  │
┃  💰 TOTALS (Auto-calculated)                       ┃  │
┃  ┌─────────────────────────────────────────────┐  ┃  │
┃  │ Service Charges:           5,500.00         │  ┃  │
┃  │ Parts Cost:                5,000.00         │  ┃  │
┃  │ ─────────────────────────────────────       │  ┃  │
┃  │ Subtotal:                 10,500.00         │  ┃  │
┃  │ VAT (15%):                 1,575.00         │  ┃  │
┃  │ ═════════════════════════════════════       │  ┃  │
┃  │ GRAND TOTAL:              12,075.00         │  ┃  │
┃  └─────────────────────────────────────────────┘  ┃  │
┃                                                     ┃  │
┃  [New] [Save] [Query] [Delete] [Exit]              ┃  │
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  │
                                                        │
  Navigating between blocks:                            │
  • Down Arrow: Master → Details → Parts                │
  • Up Arrow: Parts → Details → Master ─────────────────┘
  • Mouse Click: Direct navigation
```

---

## 🔄 Data Flow - Calculation Cascade

```
USER ACTION                    TRIGGER                    CALCULATION
═══════════════════════════════════════════════════════════════════════

1. Enter INVOICE_ID
   └─► WHEN-VALIDATE-ITEM ──► Fetch all products
                               ├─► Load into SERVICE_DETAILS
                               ├─► Check warranty per product
                               └─► Set warranty_applicable

2. Select Product (go to SERVICE_DETAILS)
   └─► WHEN-NEW-RECORD-INSTANCE ──► Clear SERVICE_PARTS
                                     Show parts for this product only

3. Select Service Type
   └─► WHEN-VALIDATE-ITEM ──► Auto-fill service_charge
                               └─► Calculate line_total
                                   = service_charge + parts_total

4. Add Parts (go to SERVICE_PARTS)
   ├─► Select PARTS_ID
   │   └─► WHEN-VALIDATE-ITEM ──► Fetch unit_price
   │                               Check stock availability
   │
   ├─► Enter QUANTITY
   │   └─► WHEN-VALIDATE-ITEM ──► Calculate line_total
   │                               = quantity × unit_price
   │
   └─► POST-INSERT ──► Database Trigger ──► Update stock
                       trg_stock_on_service_parts   └─► quantity - qty

5. Calculate Parts Total (per product)
   └─► After any SERVICE_PARTS change
       └─► Database Trigger ──► SUM all parts for product
           trg_service_parts_calc   └─► Update SERVICE_DETAILS.parts_total
                                        └─► Update line_total

6. Calculate Grand Total
   └─► After any SERVICE_DETAILS change
       └─► Database Trigger ──► SUM all products
           trg_service_det_totals   ├─► service_charge total
                                    ├─► parts_price total
                                    ├─► Calculate VAT (15%)
                                    └─► Update SERVICE_MASTER.grand_total
```

---

## 🎯 Trigger Placement Map

```
BLOCK: SERVICE_MASTER
┌──────────────────────────────────────────────────────┐
│ Item: INVOICE_ID                                     │
│   └─► WHEN-VALIDATE-ITEM                            │
│       • Validate invoice exists                      │
│       • Fetch customer_id                            │
│       • Load all products into SERVICE_DETAILS       │
│       • Calculate warranty per product               │
│                                                      │
│ Item: CUSTOMER_ID                                    │
│   └─► WHEN-VALIDATE-ITEM                            │
│       • Validate customer exists                     │
│       • Display customer name                        │
│                                                      │
│ Item: SERVICE_BY (Technician)                        │
│   └─► WHEN-VALIDATE-ITEM                            │
│       • Validate employee exists                     │
│       • Check job_title = Technician                 │
│                                                      │
│ Block Level:                                         │
│   └─► WHEN-VALIDATE-RECORD                          │
│       • Ensure invoice or customer filled            │
│       • Ensure technician assigned                   │
│       • Validate at least one product                │
│                                                      │
│   └─► POST-QUERY                                     │
│       • Recalculate totals from details              │
└──────────────────────────────────────────────────────┘

BLOCK: SERVICE_DETAILS
┌──────────────────────────────────────────────────────┐
│ Item: PRODUCT_ID                                     │
│   └─► WHEN-VALIDATE-ITEM                            │
│       • Validate product exists                      │
│       • Fetch product_name                           │
│       • Check warranty status                        │
│       • Display product info                         │
│                                                      │
│ Item: SERVICE_TYPE_ID                                │
│   └─► WHEN-VALIDATE-ITEM                            │
│       • Fetch service_charge from service_list       │
│       • Auto-fill service_charge field               │
│       • Recalculate line_total                       │
│                                                      │
│ Item: SERVICE_CHARGE                                 │
│   └─► WHEN-VALIDATE-ITEM                            │
│       • Recalculate line_total                       │
│       • Trigger master recalculation                 │
│                                                      │
│ Block Level:                                         │
│   └─► WHEN-VALIDATE-RECORD                          │
│       • Ensure service_type_id filled                │
│       • Validate service_charge > 0                  │
│                                                      │
│   └─► WHEN-NEW-RECORD-INSTANCE                      │
│       • Clear SERVICE_PARTS for new product          │
│       • Set focus to product_id                      │
└──────────────────────────────────────────────────────┘

BLOCK: SERVICE_PARTS
┌──────────────────────────────────────────────────────┐
│ Item: PARTS_ID                                       │
│   └─► WHEN-VALIDATE-ITEM                            │
│       • Validate part exists                         │
│       • Fetch unit_price                             │
│       • Check stock availability                     │
│       • Warn if out of stock                         │
│       • Calculate line_total                         │
│                                                      │
│ Item: QUANTITY                                       │
│   └─► WHEN-VALIDATE-ITEM                            │
│       • Validate qty > 0                             │
│       • Check stock availability                     │
│       • Recalculate line_total                       │
│       • Update parent parts_total                    │
│                                                      │
│ Item: UNIT_PRICE                                     │
│   └─► WHEN-VALIDATE-ITEM                            │
│       • Validate price > 0                           │
│       • Recalculate line_total                       │
│                                                      │
│ Block Level:                                         │
│   └─► WHEN-VALIDATE-RECORD                          │
│       • Check stock before save                      │
│       • Validate all required fields                 │
│                                                      │
│   └─► POST-INSERT / POST-UPDATE                     │
│       • Trigger parent recalculation                 │
└──────────────────────────────────────────────────────┘
```

---

## 📊 LOV Quick Reference

```
LOV NAME              RETURN ITEM               COLUMNS SHOWN
════════════════════════════════════════════════════════════════
LOV_INVOICE          SERVICE_MASTER.           • Invoice ID
                     INVOICE_ID                • Invoice Date
                                               • Customer Name
                                               • Total Amount
                                               • Product Count
────────────────────────────────────────────────────────────────
LOV_CUSTOMER         SERVICE_MASTER.           • Customer Name
                     CUSTOMER_ID               • Phone Number
                                               • Address
────────────────────────────────────────────────────────────────
LOV_TECHNICIAN       SERVICE_MASTER.           • Employee Name
                     SERVICE_BY                • Job Title
                                               • Department
                                               • Phone
────────────────────────────────────────────────────────────────
LOV_SERVICE_TYPE     SERVICE_DETAILS.          • Service Name
                     SERVICE_TYPE_ID           • Charge Amount
                     + SERVICE_CHARGE          • Description
────────────────────────────────────────────────────────────────
LOV_PRODUCTS         SERVICE_DETAILS.          • Product Name
(from invoice)       PRODUCT_ID                • Brand
                                               • Warranty Status
                                               • Quantity Sold
────────────────────────────────────────────────────────────────
LOV_PARTS            SERVICE_PARTS.            • Part Name
                     PARTS_ID                  • Category
                     + UNIT_PRICE              • Price
                                               • Stock Qty
                                               • Availability
════════════════════════════════════════════════════════════════
```

---

## ⚡ Calculation Formulas

```
LEVEL 1: SERVICE_PARTS (per part)
═══════════════════════════════════════════════════════════════
line_total = quantity × unit_price

Example:
  LED Panel: 1 × 1,200 = 1,200
  Remote:    1 ×   300 =   300
  ────────────────────────────
  Total Parts:         1,500


LEVEL 2: SERVICE_DETAILS (per product)
═══════════════════════════════════════════════════════════════
parts_total = SUM(service_parts.line_total)
              WHERE service_det_id = current_detail

line_total = service_charge + parts_total

Example:
  Service Charge:      2,000
  Parts Total:       + 1,500
  ────────────────────────────
  Line Total:          3,500


LEVEL 3: SERVICE_MASTER (grand total)
═══════════════════════════════════════════════════════════════
service_charge = SUM(service_details.service_charge)
parts_price    = SUM(service_details.parts_total)
total_price    = service_charge + parts_price
vat            = total_price × 0.15
grand_total    = total_price + vat

Example:
  Product 1:           3,500
  Product 2:           4,000
  Product 3:         + 4,000
  ────────────────────────────
  Subtotal:           11,500
  VAT (15%):        +  1,725
  ════════════════════════════
  GRAND TOTAL:        13,225
```

---

## 🚦 Validation Checklist

```
BEFORE SAVE - All These Must Pass:
═══════════════════════════════════════════════════════════════
☐ SERVICE_MASTER
  ☐ Invoice or Customer selected
  ☐ Technician assigned
  ☐ Service date filled
  ☐ At least one product in details

☐ SERVICE_DETAILS (for each product)
  ☐ Product selected
  ☐ Service type selected
  ☐ Service charge > 0
  ☐ Warranty status determined

☐ SERVICE_PARTS (for each part)
  ☐ Part selected
  ☐ Quantity > 0
  ☐ Stock available
  ☐ Unit price > 0

☐ CALCULATIONS
  ☐ All line totals calculated
  ☐ Parts totals summed
  ☐ Grand total includes VAT
  ☐ All amounts display correctly
```

---

## 🎬 User Workflow - Step by Step

```
STEP 1: Open Form
   └─► Click [New Service] button
       └─► Form clears, ready for new ticket

STEP 2: Enter Invoice ID
   └─► Type: INV0001
   └─► Tab out (WHEN-VALIDATE-ITEM fires)
       ├─► Customer auto-fills
       ├─► All products load into detail block
       └─► Warranty status per product shown

STEP 3: Assign Technician
   └─► Press F9 on SERVICE_BY field
   └─► Select technician from LOV
       └─► Name displays

STEP 4: For Each Product in SERVICE_DETAILS
   ├─► Navigate to product line
   ├─► Press F9 on SERVICE_TYPE_ID
   │   └─► Select service type
   │       └─► Service charge auto-fills
   │
   └─► Press Down Arrow to go to SERVICE_PARTS
       ├─► Press F9 on PARTS_ID
       │   └─► Select part from LOV
       │       ├─► Unit price auto-fills
       │       └─► Stock checked
       │
       ├─► Enter QUANTITY
       │   └─► Line total calculates
       │
       ├─► Add more parts (CREATE_RECORD)
       │   └─► Repeat for each part
       │
       └─► Up Arrow returns to SERVICE_DETAILS
           └─► Parts total auto-updates

STEP 5: Review Totals
   └─► Navigate to SERVICE_MASTER
       ├─► Service Charges: auto-calculated
       ├─► Parts Price: auto-calculated
       ├─► VAT: auto-calculated
       └─► Grand Total: auto-calculated

STEP 6: Save
   └─► Click [Save] or Ctrl+S
       ├─► Validations run
       ├─► Database triggers execute
       ├─► Stock deducted
       └─► Success message

STEP 7: Print (optional)
   └─► Click [Print]
       └─► Service ticket report generates
```

---

## 🔍 Quick Troubleshooting

```
PROBLEM                          SOLUTION
═══════════════════════════════════════════════════════════════
Products not loading             • Check invoice_id exists
from invoice                     • Verify WHEN-VALIDATE-ITEM trigger
                                 • Check sales_detail has products

Parts not showing for            • Ensure SERVICE_DETAILS selected
selected product                 • Check master-detail relationship
                                 • Verify service_det_id populated

Calculations not working         • Check database triggers enabled
                                 • Verify formulas in triggers
                                 • Test manually: UPDATE and check

Stock not deducting              • Check trg_stock_on_service_parts
                                 • Verify trigger enabled
                                 • Check stock table has record

LOV not showing data             • Test query in SQL*Plus
                                 • Check LOV record group populated
                                 • Verify return item mapping

Form won't save                  • Check WHEN-VALIDATE-RECORD
                                 • Review error message
                                 • Validate all required fields filled
═══════════════════════════════════════════════════════════════
```

---

## 📦 Files Required

```
DATABASE SCRIPTS:
├─ service_form_upgrade.sql       (Table & trigger setup)
├─ clean_combined.sql             (Base database)
└─ check_data_integrity.sql       (Validation)

DOCUMENTATION:
├─ SERVICE_FORM_COMPLETE_GUIDE.md (Full implementation)
└─ SERVICE_FORM_VISUAL_REFERENCE.md (This file)

FORMS:
└─ SERVICE_TICKET_FORM.fmb        (Oracle Forms 11g)
```

---

**Implementation Time:** 4-6 hours  
**Complexity Level:** ⭐⭐⭐⭐ (Advanced)  
**Prerequisites:** Oracle Forms 11g knowledge, PL/SQL basics  

**Last Updated:** January 12, 2026  
**Version:** 2.0 (Multi-Product + Multi-Parts)

