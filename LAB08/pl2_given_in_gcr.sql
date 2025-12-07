set serveroutput on ;
-- loop
    declare 
    begin
    for user_record in  (select first_name , salary , hire_date from employees where department_id = 80)
    loop
    dbms_output.put_line('user name is ' || user_record.first_name || ' salary is ' || user_record.salary
    || ' and hire date is ' || user_record.hire_date);
    end loop;
    end;
    /
-- view 
    create view select_data as 
    select first_name , job_title , department_name from employees
    join departments
    on employees.DEPARTMENT_ID = departments.DEPARTMENT_ID
    join
    jobs
    on
    employees.job_id = jobs.job_id;
    /
    select * from select_data;
    GRANT CREATE MATERIALIZED VIEW TO HR;

CREATE MATERIALIZED VIEW emp_mv
REFRESH FAST ON COMMIT
AS
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id;



-- function
create function calculateSalary (dept_id int)
return number 
is 
total_salary int := 0 ;
Begin 
select sum(salary) into total_salary from employees where department_id = dept_id ;
return total_salary ;
end;
/
select  calculateSalary(80) from dual;
-- object type start
create  or replace type employees_type as object (
emp_id number ,
emp_name varchar(20),
hire_date date ,
member function year_of_service return number
)
/
create or replace type body employees_type as 
member function year_of_service return number is 
begin
return trunc(MONTHS_BETWEEN(sysdate,hire_date)/12);
end;
end;
/
-- object type end
-- we create table for object storage in database
CREATE TABLE employees_data OF employees_type (
    PRIMARY KEY (emp_id)
);
insert into employees_data values (employees_type(3, 'Aqsa',DATE '2023-8-13'));
insert into employees_data values (employees_type(4, 'Amna',DATE '2024-01-13'));


SELECT e.emp_id, e.emp_name, e.hire_date
FROM employees_data e;
SELECT * FROM EMPLOYEES_DATA;

SELECT e.emp_name,
       e.year_of_service() AS years_with_company
FROM EMPLOYEES_DATA e;

-- we can use object type without table in just pl/sql like temporary variable logic
DECLARE
    emp employees_type;  -- variable of object type
BEGIN
    emp := employees_type(101, 'Ali Khan', DATE '2018-03-10');

    DBMS_OUTPUT.PUT_LINE('Name: ' || emp.emp_name);
    DBMS_OUTPUT.PUT_LINE('Years of Service: ' || emp.year_of_service());
END;
/

-- procedure without parameters
create or replace  procedure select_all
as
begin
for c in(select * from employees)
loop
DBMS_OUTPUT.PUT_LINE('NAME IS '|| C.first_name );
DBMS_OUTPUT.PUT_LINE('NAME IS '|| C.salary );
end loop;
end;
/
execute select_all;

create or replace procedure insert_data(e_id  int , e_name in varchar2,hire_date date)
as
user_exist number ;
begin
 select count(*)  into user_exist from employees_data where emp_id = e_id;
 if user_exist = 0 then 
 insert into employees_data (emp_id ,emp_name , hire_date ) values (e_id , e_name , hire_date);
DBMS_OUTPUT.PUT_LINE('Employee ' || e_id || ' ' || e_name || ' inserted successfully.');
else 
DBMS_OUTPUT.PUT_LINE('Error ' || e_id ||  ' already exist.');
end if;
end;
/

begin
 insert_data(e_id => 6, e_name => 'RAFAY', hire_date => DATE '2023-8-12');
end;
/

-- CURSOR, A cursor is a temporary pointer that allows you to process query results row by row in PL/SQL.
-- cursor lifecycle
-- Declare – Define the cursor with a SELECT query.
-- Open – Execute the query and store result rows.
-- Fetch – Retrieve each row one by one.
-- Close – Release memory.
DECLARE
  CURSOR emp_cursor IS
    SELECT first_name, salary FROM employees WHERE department_id = 80;

  v_name employees.first_name%TYPE;
  v_salary employees.salary%TYPE;
BEGIN
  OPEN emp_cursor;  -- Step 1: Open the cursor this executes the SELECT query
  -- inside the cursor and stores the result set in memory
  LOOP
    FETCH emp_cursor INTO v_name, v_salary;  -- Step 2: Fetch each row
    EXIT WHEN emp_cursor%NOTFOUND;           -- Step 3: Exit when no more rows
    -- %NOTFOUND is a cursor attribute that becomes TRUE after the last row is fetched.
    DBMS_OUTPUT.PUT_LINE(v_name || ' earns ' || v_salary);
  END LOOP;
  CLOSE emp_cursor;         -- Step 4: Close the cursor
END;


