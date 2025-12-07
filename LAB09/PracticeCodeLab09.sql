SET SERVEROUTPUT ON;

-- Create sample table for DML triggers
CREATE TABLE student (
    student_id NUMBER PRIMARY KEY,
    student_name VARCHAR2(20),
    faculty_id NUMBER,
    h_pay NUMBER,
    y_pay NUMBER
);

-- Insert sample data
INSERT INTO student (student_id, student_name, faculty_id) VALUES (101, 'Ali', 1);
INSERT INTO student (student_id, student_name, faculty_id) VALUES (102, 'Ahmed', 2);
INSERT INTO student (student_id, student_name, faculty_id) VALUES (103, 'sana', 1);
COMMIT;

SELECT * FROM student;

-- Before Insert Trigger: Set default faculty_id if null
CREATE OR REPLACE TRIGGER insert_data
BEFORE INSERT ON student
FOR EACH ROW
BEGIN
    IF :NEW.faculty_id IS NULL THEN
        :NEW.faculty_id := 1;
    END IF;
END;
/

INSERT INTO student (student_id, student_name) VALUES (112, 'Kinza');
SELECT * FROM student;

-- Before Update Trigger: Calculate y_pay = h_pay * 1920
CREATE OR REPLACE TRIGGER update_salary
BEFORE UPDATE ON student
FOR EACH ROW
BEGIN
    :NEW.y_pay := :NEW.h_pay * 1920;
END;
/

UPDATE student SET h_pay = 250 WHERE student_id = 102;
SELECT * FROM student;

-- Before Delete Trigger: Prevent deletion if student_name = 'sana'
CREATE OR REPLACE TRIGGER prevent_Record
BEFORE DELETE ON student
FOR EACH ROW
BEGIN
    IF :OLD.student_name = 'sana' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot delete record: student_name is sana!');
    END IF;
END;
/

-- Test delete (should fail for 'sana')
DELETE FROM student WHERE student_name = 'sana';

-- After Insert Trigger: Log insertions
CREATE TABLE student_logs (
    student_id NUMBER,
    student_name VARCHAR2(20),
    inserted_by VARCHAR2(20),
    inserted_on DATE
);

CREATE OR REPLACE TRIGGER after_ins
AFTER INSERT ON student
FOR EACH ROW
BEGIN
    INSERT INTO student_logs (student_id, student_name, inserted_by, inserted_on)
    VALUES (:NEW.student_id, :NEW.student_name, SYS_CONTEXT('USERENV', 'SESSION_USER'), SYSDATE);
END;
/

INSERT INTO student (student_id, student_name, faculty_id) VALUES (113, 'Test', 1);
SELECT * FROM student_logs;

-- Combined DML Trigger Example (Insert/Update/Delete)
CREATE TABLE superheroes (
    sh_name VARCHAR2(15)
);

CREATE OR REPLACE TRIGGER tr_superheroes
BEFORE INSERT OR DELETE OR UPDATE ON superheroes
FOR EACH ROW
DECLARE
    v_user VARCHAR2(15);
BEGIN
    SELECT user INTO v_user FROM dual;
    IF INSERTING THEN
        DBMS_OUTPUT.PUT_LINE('one line inserted by ' || v_user);
    ELSIF DELETING THEN
        DBMS_OUTPUT.PUT_LINE('one line Deleted by ' || v_user);
    ELSIF UPDATING THEN
        DBMS_OUTPUT.PUT_LINE('one line Updated by ' || v_user);
    END IF;
END;
/

-- Test combined trigger
INSERT INTO superheroes VALUES ('Superman');
UPDATE superheroes SET sh_name = 'Batman' WHERE sh_name = 'Superman';
DELETE FROM superheroes WHERE sh_name = 'Batman';

-- Table Auditing Example
CREATE TABLE sh_audit (
    new_name VARCHAR2(30),
    old_name VARCHAR2(30),
    user_name VARCHAR2(30),
    entry_date VARCHAR2(30),
    operation VARCHAR2(30)
);

CREATE OR REPLACE TRIGGER superheroes_audit
BEFORE INSERT OR DELETE OR UPDATE ON superheroes
FOR EACH ROW
DECLARE
    v_user VARCHAR2(30);
    v_date VARCHAR2(30);
BEGIN
    SELECT user, TO_CHAR(sysdate, 'DD/MON/YYYY HH24:MI:SS') INTO v_user, v_date FROM dual;
    IF INSERTING THEN
        INSERT INTO sh_audit (new_name, old_name, user_name, entry_date, operation)
        VALUES (:NEW.sh_name, NULL, v_user, v_date, 'Insert');
    ELSIF DELETING THEN
        INSERT INTO sh_audit (new_name, old_name, user_name, entry_date, operation)
        VALUES (NULL, :OLD.sh_name, v_user, v_date, 'Delete');
    ELSIF UPDATING THEN
        INSERT INTO sh_audit (new_name, old_name, user_name, entry_date, operation)
        VALUES (:NEW.sh_name, :OLD.sh_name, v_user, v_date, 'Update');
    END IF;
END;
/

-- Test auditing
INSERT INTO superheroes VALUES ('Ironman');
UPDATE superheroes SET sh_name = 'Spiderman' WHERE sh_name = 'Ironman';
DELETE FROM superheroes WHERE sh_name = 'Spiderman';
SELECT * FROM sh_audit;

-- Synchronized Backup Example
CREATE TABLE superheroes_backup AS SELECT * FROM superheroes WHERE 1=2;

CREATE OR REPLACE TRIGGER Sh_Backup
BEFORE INSERT OR DELETE OR UPDATE ON superheroes
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO superheroes_backup (sh_name) VALUES (:NEW.sh_name);
    ELSIF DELETING THEN
        DELETE FROM superheroes_backup WHERE sh_name = :OLD.sh_name;
    ELSIF UPDATING THEN
        UPDATE superheroes_backup SET sh_name = :NEW.sh_name WHERE sh_name = :OLD.sh_name;
    END IF;
END;
/

-- Test backup
INSERT INTO superheroes VALUES ('Thor');
UPDATE superheroes SET sh_name = 'Loki' WHERE sh_name = 'Thor';
DELETE FROM superheroes WHERE sh_name = 'Loki';
SELECT * FROM superheroes_backup;

-- DDL Trigger for Schema Auditing
CREATE TABLE schema_audit (
    ddl_date DATE,
    ddl_user VARCHAR2(15),
    object_created VARCHAR2(15),
    object_name VARCHAR2(15),
    ddl_operation VARCHAR2(15)
);

CREATE OR REPLACE TRIGGER hr_audit_tr
AFTER DDL ON SCHEMA
BEGIN
    INSERT INTO schema_audit VALUES (
        sysdate,
        sys_context('USERENV', 'CURRENT_USER'),
        ora_dict_obj_type,
        ora_dict_obj_name,
        ora_sysevent
    );
END;
/

-- Test DDL trigger
CREATE TABLE ddl_test (col1 NUMBER);
DROP TABLE ddl_test;
SELECT * FROM schema_audit;

-- System Event Trigger: Schema Logon
CREATE TABLE hr_evnt_audit (
    event_type VARCHAR2(30),
    logon_date DATE,
    logon_time VARCHAR2(15),
    logoff_date DATE,
    logoff_time VARCHAR2(15)
);

CREATE OR REPLACE TRIGGER hr_lgon_audit
AFTER LOGON ON SCHEMA
BEGIN
    INSERT INTO hr_evnt_audit VALUES (
        ora_sysevent,
        sysdate,
        TO_CHAR(sysdate, 'hh24:mi:ss'),
        NULL,
        NULL
    );
    COMMIT;
END;
/

-- Schema Logoff
CREATE OR REPLACE TRIGGER log_off_audit
BEFORE LOGOFF ON SCHEMA
BEGIN
    INSERT INTO hr_evnt_audit VALUES (
        ora_sysevent,
        NULL,
        NULL,
        SYSDATE,
        TO_CHAR(sysdate, 'hh24:mi:ss')
    );
    COMMIT;
END;
/

-- Instead-of Trigger Example
CREATE TABLE trainer (
    full_name VARCHAR2(20)
);

CREATE TABLE subject (
    subject_name VARCHAR2(15)
);

INSERT INTO trainer VALUES ('Sohail Ahmed');
INSERT INTO subject VALUES ('Database Systems');
COMMIT;

CREATE VIEW db_lab_09_view AS
SELECT full_name, subject_name FROM trainer, subject;

-- Instead-of Insert
CREATE OR REPLACE TRIGGER tr_Io_Insert
INSTEAD OF INSERT ON db_lab_09_view
FOR EACH ROW
BEGIN
    INSERT INTO trainer (full_name) VALUES (:NEW.full_name);
    INSERT INTO subject (subject_name) VALUES (:NEW.subject_name);
END;
/

-- Test insert on view
INSERT INTO db_lab_09_view (full_name, subject_name) VALUES ('New Trainer', 'New Subject');

-- Instead-of Update
CREATE OR REPLACE TRIGGER io_update
INSTEAD OF UPDATE ON db_lab_09_view
FOR EACH ROW
BEGIN
    UPDATE trainer SET full_name = :NEW.full_name WHERE full_name = :OLD.full_name;
    UPDATE subject SET subject_name = :NEW.subject_name WHERE subject_name = :OLD.subject_name;
END;
/

-- Test update on view
UPDATE db_lab_09_view SET full_name = 'Updated Trainer' WHERE full_name = 'Sohail Ahmed';

-- Instead-of Delete
CREATE OR REPLACE TRIGGER io_delete
INSTEAD OF DELETE ON db_lab_09_view
FOR EACH ROW
BEGIN
    DELETE FROM trainer WHERE full_name = :OLD.full_name;
    DELETE FROM subject WHERE subject_name = :OLD.subject_name;
END;
/

-- Test delete on view
DELETE FROM db_lab_09_view WHERE full_name = 'Updated Trainer';

-- Compound Trigger Example
CREATE TABLE compound_test (
    id NUMBER,
    description VARCHAR2(50)
);

CREATE OR REPLACE TRIGGER compound_trigger
FOR INSERT OR UPDATE OR DELETE ON compound_test
COMPOUND TRIGGER
    BEFORE STATEMENT IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Before Statement');
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Before Row');
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('After Row');
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('After Statement');
    END AFTER STATEMENT;
END;
/

-- Test compound trigger
INSERT INTO compound_test VALUES (1, 'Test Insert');
UPDATE compound_test SET description = 'Updated' WHERE id = 1;
DELETE FROM compound_test WHERE id = 1;
