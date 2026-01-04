# Data Integrity Report
**Date:** January 4, 2026  
**Database:** Oracle 11g XE - MSP Schema

## Executive Summary
Found **3 critical data integrity issues** that need to be fixed:

1. ✅ **Foreign Keys:** All valid (0 orphaned records)
2. ❌ **Duplicate Employees:** 20 employees inserted twice (40 total rows, should be 20)
3. ❌ **Salary Violations:** 4 employees with salaries outside job range
4. ✅ **Master-Detail Consistency:** All valid (0 orphans)
5. ✅ **Stock Constraints:** No negative quantities
6. ✅ **Unique Constraints:** Customers and users have no duplicates

---

## Critical Issues Requiring Fix

### 1. Duplicate Employee Records ❌
**Severity:** HIGH  
**Impact:** 40 employee rows for only 20 unique people

**Details:**
- All 20 employees are inserted twice in the seed data:
  - First insertion: Lines 2422-2539
  - **Duplicate insertion: Lines 3275-3392** ← **REMOVE THIS SECTION**
  
**Affected Employees:**
```
Rafiqul Hasan (HAS1, HAS21)
Zahid Hasib (HAS2, HAS22)
Rezaul Karim (KAR3, KAR23)
Tanvir Rahman (RAH4, RAH24)
Sharmin Begum (BEG5, BEG25)
Sadia Akter (AKT6, AKT26)
Kamal Hossain (HOS7, HOS27)
Nazmul Islam (ISL8, ISL28)
Jannat Ara (ARA9, ARA29)
Ahsan Kabir (KAB10, KAB30)
Fatima Zohra (ZOH11, ZOH31)
Sabbir Ahmed (AHM12, AHM32)
Mominul Haque (HAQ13, HAQ33)
Ariful Islam (ISL14, ISL34)
Lutfur Nahid (NAH15, NAH35)
Rumana Afroz (AFR16, AFR36)
Tariq Aziz (AZI17, AZI37)
Shohel Rana (RAN18, RAN38)
Keya Payel (PAY19, PAY39)
Imtiaz Bulbul (BUL20, BUL40)
```

**Fix:** Remove duplicate employee insertion block (lines ~3275-3392)

---

### 2. Salary Range Violations ❌
**Severity:** MEDIUM  
**Impact:** 4 employees with salaries outside their job's min/max range

**Details:**

| Employee ID | Name | Salary | Job Title | Min | Max | Issue |
|-------------|------|--------|-----------|-----|-----|-------|
| BUL20 | Imtiaz Bulbul | 27,000 | Delivery Man | 12,000 | 20,000 | +7,000 over max |
| BUL40 | Imtiaz Bulbul (dup) | 27,000 | Delivery Man | 12,000 | 20,000 | +7,000 over max |
| NAH15 | Lutfur Nahid | 29,000 | HR and Admin Officer | 35,000 | 55,000 | -6,000 below min |
| NAH35 | Lutfur Nahid (dup) | 29,000 | HR and Admin Officer | 35,000 | 55,000 | -6,000 below min |

**Fix Options:**
1. **Adjust salaries** to fit within job ranges:
   - Imtiaz Bulbul: 27,000 → 20,000 (or change job_id to match salary)
   - Lutfur Nahid: 29,000 → 35,000 (or change job_id to match salary)
2. **Or adjust job ranges** if these are intentional exceptions

**Recommended:** After removing duplicates, only 2 records need fixing (BUL20, NAH15)

---

## Passed Integrity Checks ✅

### Foreign Key Integrity
All foreign key relationships are valid:
- ✅ Employees → Departments (0 orphans)
- ✅ Employees → Managers (0 orphans)
- ✅ Employees → Jobs (0 orphans)
- ✅ Departments → Managers (0 orphans)
- ✅ Products → Suppliers (0 orphans)
- ✅ Products → Categories (0 orphans)
- ✅ Stock → Products (0 orphans)
- ✅ Stock → Suppliers (0 orphans)
- ✅ Sales Master → Customers (0 orphans)
- ✅ Sales Detail → Invoices (0 orphans)
- ✅ Sales Detail → Products (0 orphans)
- ✅ Service Master → Customers (0 orphans)
- ✅ Service Details → Service Master (0 orphans)
- ✅ Payments → Suppliers (0 orphans)
- ✅ Order Details → Order Master (0 orphans)
- ✅ Receive Details → Receive Master (0 orphans)

### Master-Detail Consistency
All master-detail relationships are properly linked:
- ✅ 0 sales masters without details
- ✅ 0 sales details without master
- ✅ 0 service masters without details
- ✅ 0 expense masters without details
- ✅ 0 damage masters without details

### Check Constraints
- ✅ Stock quantity: 0 negative values
- ✅ Job salary ranges: 0 inverted ranges (max >= min)
- ✅ Product warranty: 0 negative warranty periods

### Required Relationships
All required FKs are populated:
- ✅ All products have suppliers
- ✅ All products have categories
- ✅ All employees have departments
- ✅ All employees have jobs

### Unique Constraints
- ✅ Customer phone numbers are unique
- ✅ User names are unique
- ❌ Employee emails: 20 duplicates (due to duplicate employee records)

---

## Database Statistics

| Metric | Count |
|--------|-------|
| Total Tables | 33 |
| Total Employees | 40 (should be 20) |
| Total Products | 20 |
| Total Suppliers | 10 |
| Total Customers | 10 |
| Total Stock Rows | 10 |
| Total Sales | 10 |
| Total Services | 10 |
| Total Orders | 20 |
| Total Receives | 10 |
| Total Payments | 5 |

---

## Recommendations

### Immediate Actions (Priority 1)
1. **Remove duplicate employee seed data** (lines ~3275-3392 in clean_combined.sql)
2. **Fix salary violations** for Imtiaz Bulbul and Lutfur Nahid
3. **Re-run script** to verify clean state

### Data Validation Enhancements (Priority 2)
1. Add **UNIQUE constraint** on employee email column
2. Add **CHECK constraint** on employees to enforce salary within job range
3. Consider adding **audit triggers** to log salary changes outside range

### Preventive Measures (Priority 3)
1. Add unique constraint: `ALTER TABLE employees ADD CONSTRAINT uq_emp_email UNIQUE (email);`
2. Add salary check: 
   ```sql
   ALTER TABLE employees ADD CONSTRAINT chk_emp_salary_range 
   CHECK (salary >= (SELECT min_salary FROM jobs WHERE job_id = employees.job_id) 
      AND salary <= (SELECT max_salary FROM jobs WHERE job_id = employees.job_id));
   ```
   Note: Subquery in CHECK constraint not supported in Oracle 11g, would need trigger instead.

---

## Test Queries Used

```sql
-- 1. Check for orphaned FK records
SELECT COUNT(*) FROM employees e
WHERE e.department_id IS NOT NULL 
  AND NOT EXISTS (SELECT 1 FROM departments d WHERE d.department_id = e.department_id);

-- 2. Check for duplicate employees
SELECT first_name, last_name, COUNT(*) as count
FROM employees
GROUP BY first_name, last_name
HAVING COUNT(*) > 1;

-- 3. Check salary violations
SELECT e.employee_id, e.first_name, e.last_name, e.salary, 
       j.job_title, j.min_salary, j.max_salary
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
WHERE e.salary < j.min_salary OR e.salary > j.max_salary;

-- 4. Check master-detail consistency
SELECT COUNT(*) FROM sales_master sm
WHERE NOT EXISTS (SELECT 1 FROM sales_detail sd WHERE sd.invoice_id = sm.invoice_id);

-- 5. Check stock constraints
SELECT COUNT(*) FROM stock WHERE quantity < 0;
```

---

## Conclusion
The database has **strong foundational integrity** with all foreign keys and master-detail relationships valid. The two critical issues (duplicate employees and salary violations) are **data seeding errors** rather than structural problems, and can be fixed by cleaning up the seed data in clean_combined.sql.
