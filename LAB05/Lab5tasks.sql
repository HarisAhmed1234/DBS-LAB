-- Drop existing tables if needed
DROP TABLE Orders CASCADE CONSTRAINTS;
DROP TABLE Customers CASCADE CONSTRAINTS;
DROP TABLE Enrollments CASCADE CONSTRAINTS;
DROP TABLE Courses CASCADE CONSTRAINTS;
DROP TABLE Teachers CASCADE CONSTRAINTS;
DROP TABLE Subjects CASCADE CONSTRAINTS;
DROP TABLE Projects CASCADE CONSTRAINTS;
DROP TABLE Employees CASCADE CONSTRAINTS;
DROP TABLE Departments CASCADE CONSTRAINTS;
DROP TABLE Students CASCADE CONSTRAINTS;

-- Create Departments
CREATE TABLE Departments (
    dept_id NUMBER PRIMARY KEY,
    dept_name VARCHAR2(50)
);

-- Create Employees
CREATE TABLE Employees (
    employee_id NUMBER PRIMARY KEY,
    name VARCHAR2(50),
    salary NUMBER(10,2),
    hire_date DATE,
    dept_id NUMBER,
    manager_id NUMBER,
    project_id NUMBER,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES Employees(employee_id)
);

-- Create Projects
CREATE TABLE Projects (
    project_id NUMBER PRIMARY KEY,
    name VARCHAR2(50)
);

-- Alter Employees to reference Projects
ALTER TABLE Employees ADD FOREIGN KEY (project_id) REFERENCES Projects(project_id);

-- Create Teachers
CREATE TABLE Teachers (
    teacher_id NUMBER PRIMARY KEY,
    name VARCHAR2(50),
    city VARCHAR2(50)
);

-- Create Subjects
CREATE TABLE Subjects (
    subject_id NUMBER PRIMARY KEY,
    name VARCHAR2(50)
);

-- Create Courses
CREATE TABLE Courses (
    course_id NUMBER PRIMARY KEY,
    name VARCHAR2(50),
    teacher_id NUMBER,
    FOREIGN KEY (teacher_id) REFERENCES Teachers(teacher_id)
);

-- Create Students
CREATE TABLE Students (
    student_id NUMBER PRIMARY KEY,
    name VARCHAR2(50),
    city VARCHAR2(50)
);

-- Create Enrollments
CREATE TABLE Enrollments (
    enrollment_id NUMBER PRIMARY KEY,
    student_id NUMBER,
    course_id NUMBER,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- Create Customers
CREATE TABLE Customers (
    customer_id NUMBER PRIMARY KEY,
    name VARCHAR2(50)
);

-- Create Orders
CREATE TABLE Orders (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Insert data into Departments
INSERT INTO Departments VALUES (1, 'HR');
INSERT INTO Departments VALUES (2, 'IT');
INSERT INTO Departments VALUES (3, 'Sales');
INSERT INTO Departments VALUES (4, 'EmptyDept');

-- Insert data into Projects
INSERT INTO Projects VALUES (1, 'Project A');
INSERT INTO Projects VALUES (2, 'Project B');

-- Insert data into Employees
INSERT INTO Employees (employee_id, name, salary, hire_date, dept_id, manager_id, project_id) VALUES (1, 'Alice', 60000, TO_DATE('2019-01-01', 'YYYY-MM-DD'), 1, NULL, 1);
INSERT INTO Employees (employee_id, name, salary, hire_date, dept_id, manager_id, project_id) VALUES (2, 'Bob', 50000, TO_DATE('2020-06-15', 'YYYY-MM-DD'), 1, 1, 1);
INSERT INTO Employees (employee_id, name, salary, hire_date, dept_id, manager_id, project_id) VALUES (3, 'Charlie', 70000, TO_DATE('2021-03-10', 'YYYY-MM-DD'), 2, 1, NULL);
INSERT INTO Employees (employee_id, name, salary, hire_date, dept_id, manager_id, project_id) VALUES (4, 'David', 40000, TO_DATE('2022-07-20', 'YYYY-MM-DD'), 2, 3, NULL);
INSERT INTO Employees (employee_id, name, salary, hire_date, dept_id, manager_id, project_id) VALUES (5, 'Eve', 45000, TO_DATE('2018-09-01', 'YYYY-MM-DD'), 3, NULL, 2);
INSERT INTO Employees (employee_id, name, salary, hire_date, dept_id, manager_id, project_id) VALUES (6, 'Frank', 55000, TO_DATE('2023-02-05', 'YYYY-MM-DD'), NULL, NULL, NULL);


-- Insert data into Teachers
INSERT INTO Teachers VALUES (1, 'Sir Ali', 'Lahore');
INSERT INTO Teachers VALUES (2, 'Ms Bob', 'Karachi');
INSERT INTO Teachers VALUES (3, 'Dr Charlie', 'Islamabad');

-- Insert data into Subjects
INSERT INTO Subjects VALUES (1, 'Algebra');
INSERT INTO Subjects VALUES (2, 'Quantum');

-- Insert data into Courses
INSERT INTO Courses VALUES (1, 'Math', 1);
INSERT INTO Courses VALUES (2, 'Physics', 2);
INSERT INTO Courses VALUES (3, 'Chemistry', 1);
INSERT INTO Courses VALUES (4, 'Biology', 3);

-- Insert data into Students
INSERT INTO Students VALUES (1, 'Student1', 'Lahore');
INSERT INTO Students VALUES (2, 'Student2', 'Karachi');
INSERT INTO Students VALUES (3, 'Student3', 'Lahore');

-- Insert data into Enrollments
INSERT INTO Enrollments VALUES (1, 1, 1);
INSERT INTO Enrollments VALUES (2, 1, 3);
INSERT INTO Enrollments VALUES (3, 2, 2);
INSERT INTO Enrollments VALUES (4, 3, 1);
INSERT INTO Enrollments VALUES (5, 3, 4);

-- Insert data into Customers
INSERT INTO Customers VALUES (1, 'Cust1');
INSERT INTO Customers VALUES (2, 'Cust2');
INSERT INTO Customers VALUES (3, 'Cust3');

-- Insert data into Orders
INSERT INTO Orders VALUES (1, 1);
INSERT INTO Orders VALUES (2, 2);

COMMIT;

--part 1
SELECT e.name AS employee, d.dept_name AS department
FROM Employees e
CROSS JOIN Departments d;

--part 2
SELECT d.dept_name, e.name
FROM Departments d
LEFT OUTER JOIN Employees e ON d.dept_id = e.dept_id;

--part 3
SELECT e.name AS employee, m.name AS manager
FROM Employees e
JOIN Employees m ON e.manager_id = m.employee_id;

--part 4
SELECT e.name
FROM Employees e
LEFT OUTER JOIN Projects p ON e.project_id = p.project_id
WHERE p.project_id IS NULL;

--part 5
SELECT s.name, c.name
FROM Students s
JOIN Enrollments e USING (student_id)
JOIN Courses c USING (course_id);

--part 6
SELECT c.name AS customer, o.order_id
FROM Customers c
LEFT OUTER JOIN Orders o ON c.customer_id = o.customer_id;

--part 7
SELECT d.dept_name, e.name
FROM Departments d
LEFT OUTER JOIN Employees e ON d.dept_id = e.dept_id;

--part 8
SELECT t.name AS teacher, s.name AS subject
FROM Teachers t
CROSS JOIN Subjects s;

--part 9
SELECT d.dept_name, COUNT(e.employee_id) AS total_employees
FROM Departments d
LEFT OUTER JOIN Employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

--part 10
SELECT s.name AS student, c.name AS course, t.name AS teacher
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_id = c.course_id
JOIN Teachers t ON c.teacher_id = t.teacher_id;

--part 11
SELECT s.name AS student, t.name AS teacher
FROM Students s
JOIN Teachers t ON s.city = t.city;

--part 12
SELECT e.name AS employee, m.name AS manager
FROM Employees e
LEFT OUTER JOIN Employees m ON e.manager_id = m.employee_id;

--part 13
SELECT e.name
FROM Employees e
WHERE e.dept_id IS NULL;

--part 14
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM Departments d
JOIN Employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name
HAVING AVG(e.salary) > 50000;

--part 15
SELECT e.name, e.salary, d.dept_name
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
WHERE e.salary > (SELECT AVG(salary) FROM Employees WHERE dept_id = e.dept_id);

--part 16
SELECT d.dept_name
FROM Departments d
JOIN Employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name
HAVING MIN(e.salary) >= 30000;

--part 17
SELECT s.name AS student, c.name AS course
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_id = c.course_id
WHERE s.city = 'Lahore';

--part 18
SELECT e.name AS employee, m.name AS manager, d.dept_name
FROM Employees e
LEFT OUTER JOIN Employees m ON e.manager_id = m.employee_id
JOIN Departments d ON e.dept_id = d.dept_id
WHERE e.hire_date BETWEEN TO_DATE('2020-01-01', 'YYYY-MM-DD')
                      AND TO_DATE('2023-01-01', 'YYYY-MM-DD');


--part 19
SELECT s.name
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_id = c.course_id
JOIN Teachers t ON c.teacher_id = t.teacher_id
WHERE t.name = 'Sir Ali';

--part 20
SELECT e.name AS employee, m.name AS manager, d.dept_name
FROM Employees e
JOIN Employees m ON e.manager_id = m.employee_id
JOIN Departments d ON e.dept_id = d.dept_id
WHERE e.dept_id = m.dept_id;