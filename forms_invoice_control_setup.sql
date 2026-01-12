--========================================================================================
-- DATABASE SETUP FOR FORMS - Optional Invoice Number Control Table
-- File: forms_invoice_control_table.sql
-- Purpose: Creates optional control table for tracking invoice numbers
-- Use with: OPTION B or OPTION C from FORMS_NEW_SALES_TRIGGER.sql
--========================================================================================

-- Only create if you want manual control/audit trail of invoice numbering
-- NOT REQUIRED if using OPTION A (recommended - database sequences)

CREATE TABLE inv_number_control (
    control_id      VARCHAR2(50) PRIMARY KEY,
    last_no         NUMBER,
    last_updated    DATE,
    updated_by      VARCHAR2(100),
    purpose         VARCHAR2(200),
    status          NUMBER DEFAULT 1,
    CONSTRAINT chk_inv_ctrl_last_no CHECK (last_no >= 0)
);

CREATE SEQUENCE inv_number_control_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_inv_control_bi
BEFORE INSERT OR UPDATE ON inv_number_control FOR EACH ROW
BEGIN
    IF INSERTING AND :NEW.control_id IS NULL THEN
        :NEW.control_id := 'INVC' || TO_CHAR(inv_number_control_seq.NEXTVAL);
    END IF;
    
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.last_updated IS NULL THEN :NEW.last_updated := SYSDATE; END IF;
        IF :NEW.updated_by IS NULL THEN :NEW.updated_by := USER; END IF;
    ELSIF UPDATING THEN
        :NEW.last_updated := SYSDATE;
        :NEW.updated_by := USER;
    END IF;
END;
/

-- Initialize with current maximum
INSERT INTO inv_number_control (last_no, purpose)
SELECT GREATEST(
    NVL(MAX(TO_NUMBER(SUBSTR(invoice_id, 4))), 0),
    0
) AS next_number,
'Sales Invoice Number Control'
FROM sales_master
WHERE REGEXP_LIKE(INVOICE_ID, '^INV[0-9]+$');

COMMIT;

-- Verification query
SELECT * FROM inv_number_control;

-- To check current invoice numbering status:
-- SELECT 'Next Invoice Number Would Be: INV' || (last_no + 1) FROM inv_number_control;
