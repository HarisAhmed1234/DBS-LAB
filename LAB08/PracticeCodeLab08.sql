SET SERVEROUTPUT ON;

DECLARE
    sec_name VARCHAR2(20) := 'Sec-A';
    course_name VARCHAR2(20) := 'Database Systems Lab';
BEGIN
    DBMS_OUTPUT.PUT_LINE('This is: ' || sec_name || ' and the course is ' || course_name);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

DECLARE
    num1 NUMBER := 95;
    num2 NUMBER := 85;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Outer Variable num1: ' || num1);
    DBMS_OUTPUT.PUT_LINE('Outer Variable num2: ' || num2);
    
    DECLARE
        e_id employees.EMPLOYEE_ID%TYPE := 100;
        e_name employees.FIRST_NAME%TYPE;
        e_lname employees.LAST_NAME%TYPE;
        d_name departments.DEPARTMENT_NAME%TYPE;
    BEGIN
        SELECT FIRST_NAME, LAST_NAME, DEPARTMENT_NAME INTO e_name, e_lname, d_name
        FROM employees JOIN departments USING (DEPARTMENT_ID)
        WHERE EMPLOYEE_ID = e_id;
        DBMS_OUTPUT.PUT_LINE('Employee ID: ' || e_id || ', Name: ' || e_name || ' ' || e_lname || ', Dept: ' || d_name);
    END;
END;
/

DECLARE
    e_id employees.EMPLOYEE_ID%TYPE := 100;
    e_sal employees.SALARY%TYPE;
    e_did employees.DEPARTMENT_ID%TYPE;
    e_com employees.COMMISSION_PCT%TYPE;
BEGIN
    SELECT SALARY, DEPARTMENT_ID, COMMISSION_PCT INTO e_sal, e_did, e_com
    FROM employees WHERE EMPLOYEE_ID = e_id;
    
    IF e_sal >= 20000 THEN
        DBMS_OUTPUT.PUT_LINE('High salary: ' || e_sal);
    ELSIF e_sal >= 10000 THEN
        DBMS_OUTPUT.PUT_LINE('Medium salary: ' || e_sal);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Low salary: ' || e_sal);
    END IF;
    
    CASE e_did
        WHEN 80 THEN DBMS_OUTPUT.PUT_LINE('Sales Dept');
        WHEN 50 THEN DBMS_OUTPUT.PUT_LINE('Shipping Dept');
        ELSE DBMS_OUTPUT.PUT_LINE('Other Dept');
    END CASE;
    
    IF e_did = 80 THEN
        IF e_sal >= 15000 THEN
            DBMS_OUTPUT.PUT_LINE('Updated Salary (nested): ' || (e_sal + 100) * (1 + NVL(e_com, 0)));
        ELSE
            DBMS_OUTPUT.PUT_LINE('No update needed');
        END IF;
    END IF;
END;
/

DECLARE
BEGIN
    FOR user_record IN (SELECT FIRST_NAME, SALARY, HIRE_DATE FROM employees WHERE DEPARTMENT_ID = 80)
    LOOP
        DBMS_OUTPUT.PUT_LINE('User name is ' || user_record.FIRST_NAME || ' salary is ' || user_record.SALARY || ' and hire date is ' || user_record.HIRE_DATE);
    END LOOP;
END;
/

CREATE OR REPLACE VIEW select_data AS
SELECT FIRST_NAME, JOB_TITLE, DEPARTMENT_NAME
FROM employees
JOIN departments ON employees.DEPARTMENT_ID = departments.DEPARTMENT_ID
JOIN jobs ON employees.JOB_ID = jobs.JOB_ID;
/
SELECT * FROM select_data;

CREATE MATERIALIZED VIEW emp_mv
REFRESH FAST ON COMMIT
AS
SELECT DEPARTMENT_ID, AVG(SALARY) AS avg_salary
FROM employees
GROUP BY DEPARTMENT_ID;
/

CREATE OR REPLACE FUNCTION calculateSalary (dept_id INT)
RETURN NUMBER IS
    total_salary INT := 0;
BEGIN
    SELECT SUM(SALARY) INTO total_salary FROM employees WHERE DEPARTMENT_ID = dept_id;
    RETURN total_salary;
END;
/
SELECT calculateSalary(80) FROM DUAL;

CREATE OR REPLACE TYPE employees_type AS OBJECT (
    emp_id NUMBER,
    emp_name VARCHAR2(20),
    hire_date DATE,
    MEMBER FUNCTION year_of_service RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY employees_type AS
    MEMBER FUNCTION year_of_service RETURN NUMBER IS
    BEGIN
        RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date)/12);
    END;
END;
/
CREATE TABLE employees_data OF employees_type (PRIMARY KEY (emp_id));
INSERT INTO employees_data VALUES (employees_type(3, 'Aqsa', DATE '2023-8-13'));
INSERT INTO employees_data VALUES (employees_type(4, 'Amna', DATE '2024-01-13'));
/
SELECT * FROM employees_data;
SELECT e.emp_name, e.year_of_service() AS years_with_company FROM employees_data e;

CREATE OR REPLACE TYPE emp_tbl_type AS TABLE OF employees_type;
/
CREATE OR REPLACE FUNCTION get_all_employees RETURN emp_tbl_type IS
    emp_details emp_tbl_type := emp_tbl_type();
BEGIN
    SELECT employees_type(EMPLOYEE_ID, FIRST_NAME, HIRE_DATE) BULK COLLECT INTO emp_details
    FROM employees WHERE ROWNUM <= 5;
    RETURN emp_details;
END;
/
SELECT * FROM TABLE(get_all_employees);

CREATE OR REPLACE PROCEDURE select_all AS
BEGIN
    FOR c IN (SELECT * FROM employees WHERE ROWNUM <= 5)
    LOOP
        DBMS_OUTPUT.PUT_LINE('NAME IS ' || c.FIRST_NAME || ', SALARY IS ' || c.SALARY);
    END LOOP;
END;
/
EXECUTE select_all;

CREATE OR REPLACE PROCEDURE insert_data(e_id INT, e_name IN VARCHAR2, hire_date DATE) AS
    user_exist NUMBER;
BEGIN
    SELECT COUNT(*) INTO user_exist FROM employees_data WHERE emp_id = e_id;
    IF user_exist = 0 THEN
        INSERT INTO employees_data (emp_id, emp_name, hire_date) VALUES (e_id, e_name, hire_date);
        DBMS_OUTPUT.PUT_LINE('Employee ' || e_id || ' ' || e_name || ' inserted successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error: ' || e_id || ' already exists.');
    END IF;
END;
/
BEGIN
    insert_data(e_id => 6, e_name => 'RAFAY', hire_date => DATE '2023-8-12');
END;
/

DECLARE
    CURSOR emp_cursor IS
        SELECT FIRST_NAME, SALARY FROM employees WHERE DEPARTMENT_ID = 80;
    v_name employees.FIRST_NAME%TYPE;
    v_salary employees.SALARY%TYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO v_name, v_salary;
        EXIT WHEN emp_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' earns ' || v_salary);
    END LOOP;
    CLOSE emp_cursor;
END;
/
