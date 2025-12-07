
select * from student;
--before insert 
create or replace trigger insert_data
before insert on student
for each row 
begin
if :new.faculty_id IS  NULL
THEN 
:new.faculty_id := 1 ;
end if;
end;
/
select * from student;
insert into student (student_id,student_name)values(112,'Kinza');
alter table student add (h_pay int , y_pay int);

-- before update
create or replace trigger update_salary
before update ON student
for each row
declare 
begin
:new.y_pay := :new.h_pay*1920;
end;
/
update student set h_pay = 250 where student_id = 102 ;

set serveroutput on;
-- before delete 
create or  replace trigger prevent_Record
before delete on student 
for each row
begin
IF :OLD.student_name = 'sana' then
RAISE_APPLICATION_ERROR(-20001, 'Cannot delete record: student_name is sana!');
end if;
end;
/
DELETE FROM student
WHERE student_name = 'sana';



-- after insert
create table student_logs(
student_id int ,
student_name varchar(20),
inserted_by varchar(20),
inserted_on  date 
);

create or replace trigger after_ins
after insert on student for each row
begin
insert into student_logs(student_id,student_name,inserted_by,inserted_on) values
(:NEW.student_id ,:NEW.student_name,SYS_CONTEXT('USERENV','SESSION_USER'),SYSDATE);
end;
/




SELECT * FROM STUDENT_LOGS;

drop table superheroes;
create table HELLO(
h_name varchar(20)
);
-- 
create or replace trigger prevent_table
before drop on database
begin
RAISE_APPLICATION_ERROR (
      num => -20000,
      msg => 'Cannot drop object');
  END;
/

--ddl trigger 


