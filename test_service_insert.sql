--------------------------------------------------------------------------------
-- TEST SCRIPT FOR SERVICE FORM INSERTS
-- This script tests inserting records into service_master and service_details
-- Run as: sqlplus msp/msp @test_service_insert.sql
--------------------------------------------------------------------------------

SET SERVEROUTPUT ON
SET VERIFY OFF
SET FEEDBACK ON

PROMPT ========================================
PROMPT Testing Service Form Inserts
PROMPT ========================================
PROMPT

-- Test 1: Insert service_master WITHOUT invoice_id (walk-in service)
PROMPT Test 1: Inserting service_master WITHOUT invoice_id...
DECLARE
    v_service_id VARCHAR2(50);
    v_customer_id VARCHAR2(50);
    v_service_list_id VARCHAR2(50);
    v_employee_id VARCHAR2(50);
BEGIN
    -- Get test data
    SELECT customer_id INTO v_customer_id FROM customers WHERE ROWNUM = 1;
    SELECT servicelist_id INTO v_service_list_id FROM service_list WHERE ROWNUM = 1;
    SELECT employee_id INTO v_employee_id FROM employees WHERE job_id IN 
        (SELECT job_id FROM jobs WHERE job_code IN ('TECH', 'CSUP')) AND ROWNUM = 1;
    
    -- Insert service master
    INSERT INTO service_master (
        customer_id, servicelist_id, service_by, 
        service_charge, service_date
    ) VALUES (
        v_customer_id, v_service_list_id, v_employee_id,
        1500, SYSDATE
    ) RETURNING service_id INTO v_service_id;
    
    DBMS_OUTPUT.PUT_LINE('✓ Service Master created: ' || v_service_id);
    DBMS_OUTPUT.PUT_LINE('  Warranty Applicable: ' || 
        (SELECT warranty_applicable FROM service_master WHERE service_id = v_service_id));
    
    ROLLBACK; -- Don't save test data
    DBMS_OUTPUT.PUT_LINE('✓ Test passed - rolled back');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Test 1 FAILED: ' || SQLERRM);
        ROLLBACK;
END;
/

PROMPT
PROMPT Test 2: Inserting service_master WITH valid invoice_id...
DECLARE
    v_service_id VARCHAR2(50);
    v_customer_id VARCHAR2(50);
    v_invoice_id VARCHAR2(50);
    v_service_list_id VARCHAR2(50);
    v_employee_id VARCHAR2(50);
BEGIN
    -- Get test data
    SELECT s.customer_id, s.invoice_id 
    INTO v_customer_id, v_invoice_id
    FROM sales_master s
    WHERE s.status = 1 AND ROWNUM = 1;
    
    SELECT servicelist_id INTO v_service_list_id FROM service_list WHERE ROWNUM = 1;
    SELECT employee_id INTO v_employee_id FROM employees WHERE job_id IN 
        (SELECT job_id FROM jobs WHERE job_code IN ('TECH', 'CSUP')) AND ROWNUM = 1;
    
    -- Insert service master
    INSERT INTO service_master (
        customer_id, invoice_id, servicelist_id, service_by,
        service_charge, service_date
    ) VALUES (
        v_customer_id, v_invoice_id, v_service_list_id, v_employee_id,
        2000, SYSDATE
    ) RETURNING service_id INTO v_service_id;
    
    DBMS_OUTPUT.PUT_LINE('✓ Service Master created: ' || v_service_id);
    DBMS_OUTPUT.PUT_LINE('  Invoice ID: ' || v_invoice_id);
    DBMS_OUTPUT.PUT_LINE('  Warranty Applicable: ' || 
        (SELECT warranty_applicable FROM service_master WHERE service_id = v_service_id));
    
    ROLLBACK; -- Don't save test data
    DBMS_OUTPUT.PUT_LINE('✓ Test passed - rolled back');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Test 2 FAILED: ' || SQLERRM);
        ROLLBACK;
END;
/

PROMPT
PROMPT Test 3: Inserting service_details records...
DECLARE
    v_service_id VARCHAR2(50);
    v_detail_id1 VARCHAR2(50);
    v_detail_id2 VARCHAR2(50);
    v_product_id VARCHAR2(50);
    v_parts_id VARCHAR2(50);
    v_customer_id VARCHAR2(50);
    v_service_list_id VARCHAR2(50);
    v_employee_id VARCHAR2(50);
BEGIN
    -- Get test data
    SELECT customer_id INTO v_customer_id FROM customers WHERE ROWNUM = 1;
    SELECT servicelist_id INTO v_service_list_id FROM service_list WHERE ROWNUM = 1;
    SELECT employee_id INTO v_employee_id FROM employees WHERE job_id IN 
        (SELECT job_id FROM jobs WHERE job_code IN ('TECH', 'CSUP')) AND ROWNUM = 1;
    SELECT product_id INTO v_product_id FROM products WHERE ROWNUM = 1;
    SELECT parts_id INTO v_parts_id FROM parts WHERE ROWNUM = 1;
    
    -- Create service master
    INSERT INTO service_master (
        customer_id, servicelist_id, service_by, service_charge
    ) VALUES (
        v_customer_id, v_service_list_id, v_employee_id, 1500
    ) RETURNING service_id INTO v_service_id;
    
    DBMS_OUTPUT.PUT_LINE('✓ Service Master created: ' || v_service_id);
    
    -- Insert first detail record
    INSERT INTO service_details (
        service_id, product_id, parts_id, quantity, 
        parts_price, description
    ) VALUES (
        v_service_id, v_product_id, v_parts_id, 1,
        500, 'Screen replacement part'
    ) RETURNING service_det_id INTO v_detail_id1;
    
    DBMS_OUTPUT.PUT_LINE('✓ Detail 1 created: ' || v_detail_id1);
    DBMS_OUTPUT.PUT_LINE('  Line No: ' || 
        (SELECT line_no FROM service_details WHERE service_det_id = v_detail_id1));
    
    -- Insert second detail record
    INSERT INTO service_details (
        service_id, product_id, parts_id, quantity,
        parts_price, description
    ) VALUES (
        v_service_id, v_product_id, v_parts_id, 2,
        300, 'Additional screws and adhesive'
    ) RETURNING service_det_id INTO v_detail_id2;
    
    DBMS_OUTPUT.PUT_LINE('✓ Detail 2 created: ' || v_detail_id2);
    DBMS_OUTPUT.PUT_LINE('  Line No: ' || 
        (SELECT line_no FROM service_details WHERE service_det_id = v_detail_id2));
    
    ROLLBACK; -- Don't save test data
    DBMS_OUTPUT.PUT_LINE('✓ Test passed - rolled back');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Test 3 FAILED: ' || SQLERRM);
        ROLLBACK;
END;
/

PROMPT
PROMPT ========================================
PROMPT All tests completed!
PROMPT ========================================
PROMPT
PROMPT If all tests passed, the service form errors are fixed.
PROMPT You can now proceed with normal service form operations.
PROMPT ========================================
