
DROP TABLE Payment CASCADE CONSTRAINTS;
DROP TABLE Enrollment CASCADE CONSTRAINTS;
DROP TABLE Course CASCADE CONSTRAINTS;
DROP TABLE Faculty CASCADE CONSTRAINTS;
DROP TABLE Student CASCADE CONSTRAINTS;
DROP TABLE Department CASCADE CONSTRAINTS;
DROP TABLE HighFee_Students CASCADE CONSTRAINTS;
DROP TABLE Retired_Faculty CASCADE CONSTRAINTS;
DROP TABLE Unassigned_Faculty CASCADE CONSTRAINTS;


CREATE TABLE Department (
    dept_id NUMBER PRIMARY KEY,
    dept_name VARCHAR2(100) NOT NULL
);


CREATE TABLE Student (
    student_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    gpa NUMBER(3,2),
    dept_id NUMBER,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);


CREATE TABLE Faculty (
    faculty_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    salary NUMBER(10,2),
    joining_date DATE,
    dept_id NUMBER,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

CREATE TABLE Course (
    course_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    dept_id NUMBER,
    faculty_id NUMBER,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id) ON DELETE CASCADE,
    FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id) ON DELETE CASCADE
);


CREATE TABLE Enrollment (
    enrollment_id NUMBER PRIMARY KEY,
    student_id NUMBER,
    course_id NUMBER,
    FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE
);


CREATE TABLE Payment (
    payment_id NUMBER PRIMARY KEY,
    student_id NUMBER,
    course_id NUMBER,
    fee_amount NUMBER(10,2),
    dept_id NUMBER,
    FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id) ON DELETE CASCADE
);

CREATE TABLE HighFee_Students (
    student_id NUMBER,
    name VARCHAR2(100),
    gpa NUMBER(3,2),
    dept_id NUMBER
);

CREATE TABLE Retired_Faculty (
    faculty_id NUMBER,
    name VARCHAR2(100),
    salary NUMBER(10,2),
    joining_date DATE,
    dept_id NUMBER
);

CREATE TABLE Unassigned_Faculty (
    faculty_id NUMBER,
    name VARCHAR2(100),
    salary NUMBER(10,2),
    dept_id NUMBER
);

INSERT INTO Department (dept_id, dept_name) VALUES (1, 'CS');
INSERT INTO Department (dept_id, dept_name) VALUES (2, 'EE');
INSERT INTO Department (dept_id, dept_name) VALUES (3, 'Math');

INSERT INTO Student (student_id, name, gpa, dept_id) VALUES (1, 'Ali', 3.8, 1);
INSERT INTO Student (student_id, name, gpa, dept_id) VALUES (2, 'Bob', 2.9, 1);
INSERT INTO Student (student_id, name, gpa, dept_id) VALUES (3, 'Charlie', 3.2, 2);
INSERT INTO Student (student_id, name, gpa, dept_id) VALUES (4, 'Dana', 3.6, 1);
INSERT INTO Student (student_id, name, gpa, dept_id) VALUES (5, 'Eve', 4.0, 3);


INSERT INTO Faculty (faculty_id, name, salary, joining_date, dept_id) VALUES (1, 'Prof A', 120000, TO_DATE('2010-01-01', 'YYYY-MM-DD'), 1);
INSERT INTO Faculty (faculty_id, name, salary, joining_date, dept_id) VALUES (2, 'Prof B', 90000, TO_DATE('2015-05-15', 'YYYY-MM-DD'), 2);
INSERT INTO Faculty (faculty_id, name, salary, joining_date, dept_id) VALUES (3, 'Prof C', 150000, TO_DATE('2005-03-10', 'YYYY-MM-DD'), 1);
INSERT INTO Faculty (faculty_id, name, salary, joining_date, dept_id) VALUES (4, 'Prof D', 80000, TO_DATE('2020-07-20', 'YYYY-MM-DD'), 3);
INSERT INTO Faculty (faculty_id, name, salary, joining_date, dept_id) VALUES (5, 'Prof E', 110000, TO_DATE('2012-09-01', 'YYYY-MM-DD'), 1);


INSERT INTO Course (course_id, name, dept_id, faculty_id) VALUES (1, 'Databases', 1, 1);
INSERT INTO Course (course_id, name, dept_id, faculty_id) VALUES (2, 'Circuits', 2, 2);
INSERT INTO Course (course_id, name, dept_id, faculty_id) VALUES (3, 'Algebra', 3, 4);
INSERT INTO Course (course_id, name, dept_id, faculty_id) VALUES (4, 'AI', 1, 3);
INSERT INTO Course (course_id, name, dept_id, faculty_id) VALUES (5, 'Physics', 2, NULL);  


INSERT INTO Enrollment (enrollment_id, student_id, course_id) VALUES (1, 1, 1);
INSERT INTO Enrollment (enrollment_id, student_id, course_id) VALUES (2, 1, 4);
INSERT INTO Enrollment (enrollment_id, student_id, course_id) VALUES (3, 2, 1);
INSERT INTO Enrollment (enrollment_id, student_id, course_id) VALUES (4, 3, 2);
INSERT INTO Enrollment (enrollment_id, student_id, course_id) VALUES (5, 4, 1);
INSERT INTO Enrollment (enrollment_id, student_id, course_id) VALUES (6, 4, 4);
INSERT INTO Enrollment (enrollment_id, student_id, course_id) VALUES (7, 4, 3);
INSERT INTO Enrollment (enrollment_id, student_id, course_id) VALUES (8, 5, 3);
INSERT INTO Enrollment (enrollment_id, student_id, course_id) VALUES (9, 1, 3);  


INSERT INTO Payment (payment_id, student_id, course_id, fee_amount, dept_id) VALUES (1, 1, 1, 5000, 1);
INSERT INTO Payment (payment_id, student_id, course_id, fee_amount, dept_id) VALUES (2, 1, 4, 6000, 1);
INSERT INTO Payment (payment_id, student_id, course_id, fee_amount, dept_id) VALUES (3, 2, 1, 4000, 1);
INSERT INTO Payment (payment_id, student_id, course_id, fee_amount, dept_id) VALUES (4, 3, 2, 3000, 2);
INSERT INTO Payment (payment_id, student_id, course_id, fee_amount, dept_id) VALUES (5, 4, 1, 5000, 1);
INSERT INTO Payment (payment_id, student_id, course_id, fee_amount, dept_id) VALUES (6, 4, 4, 6000, 1);
INSERT INTO Payment (payment_id, student_id, course_id, fee_amount, dept_id) VALUES (7, 4, 3, 2000, 3);
INSERT INTO Payment (payment_id, student_id, course_id, fee_amount, dept_id) VALUES (8, 5, 3, 2000, 3);

COMMIT;

--part 1
SELECT d.dept_name, COUNT(s.student_id) AS num_students
FROM Department d
LEFT JOIN Student s ON d.dept_id = s.dept_id
GROUP BY d.dept_name;

--part 2
SELECT d.dept_name, AVG(s.gpa) AS avg_gpa
FROM Department d
JOIN Student s ON d.dept_id = s.dept_id
GROUP BY d.dept_name
HAVING AVG(s.gpa) > 3.0;

--part 3
SELECT c.name AS course_name, AVG(p.fee_amount) AS avg_fee
FROM Course c
JOIN Payment p ON c.course_id = p.course_id
GROUP BY c.name;

--part 4
SELECT d.dept_name, COUNT(f.faculty_id) AS num_faculty
FROM Department d
LEFT JOIN Faculty f ON d.dept_id = f.dept_id
GROUP BY d.dept_name;

--part 5
SELECT f.name, f.salary
FROM Faculty f
WHERE f.salary > (SELECT AVG(salary) FROM Faculty);

--part 6
SELECT s.name, s.gpa
FROM Student s
WHERE s.gpa > ANY (SELECT gpa FROM Student WHERE dept_id = (SELECT dept_id FROM Department WHERE dept_name = 'CS'));

--part 7
SELECT student_id, name, gpa
FROM (SELECT student_id, name, gpa FROM Student ORDER BY gpa DESC)
WHERE ROWNUM <= 3;

--part 8
SELECT s.name
FROM Student s
WHERE NOT EXISTS (
    SELECT course_id FROM Enrollment WHERE student_id = (SELECT student_id FROM Student WHERE name = 'Ali')
    MINUS
    SELECT course_id FROM Enrollment WHERE student_id = s.student_id
)
AND s.name != 'Ali';

--part 9
SELECT d.dept_name, SUM(p.fee_amount) AS total_fees
FROM Department d
JOIN Payment p ON d.dept_id = p.dept_id
GROUP BY d.dept_name;

--part 10
SELECT DISTINCT c.name AS course_name
FROM Course c
JOIN Enrollment e ON c.course_id = e.course_id
JOIN Student s ON e.student_id = s.student_id
WHERE s.gpa > 3.5;

--part 11
SELECT d.dept_name, SUM(p.fee_amount) AS total_fees
FROM Department d
JOIN Payment p ON d.dept_id = p.dept_id
GROUP BY d.dept_name
HAVING SUM(p.fee_amount) > 1000000;

--part 12
SELECT d.dept_name
FROM Department d
JOIN Faculty f ON d.dept_id = f.dept_id
WHERE f.salary > 100000
GROUP BY d.dept_name
HAVING COUNT(f.faculty_id) > 5;

--part 13
DELETE FROM Student
WHERE gpa < (SELECT AVG(gpa) FROM Student s2);

--part 14
DELETE FROM Course c
WHERE NOT EXISTS (SELECT 1 FROM Enrollment e WHERE e.course_id = c.course_id);
SELECT * FROM Course
--part 15
INSERT INTO HighFee_Students (student_id, name, gpa, dept_id)
SELECT s.student_id, s.name, s.gpa, s.dept_id
FROM Student s
JOIN Payment p ON s.student_id = p.student_id
GROUP BY s.student_id, s.name, s.gpa, s.dept_id
HAVING SUM(p.fee_amount) > (SELECT AVG(fee_amount) FROM Payment);
SELECT * FROM HighFee_Students

--part 16
INSERT INTO Retired_Faculty (faculty_id, name, salary, joining_date, dept_id)
SELECT faculty_id, name, salary, joining_date, dept_id
FROM Faculty
WHERE joining_date < (SELECT MIN(joining_date) FROM Faculty);

--part 17
SELECT dept_name, total_fees
FROM (
    SELECT d.dept_name, SUM(p.fee_amount) AS total_fees,
           RANK() OVER (ORDER BY SUM(p.fee_amount) DESC) AS rnk
    FROM Department d
    JOIN Payment p ON d.dept_id = p.dept_id
    GROUP BY d.dept_name
)
WHERE rnk = 1;

--part 18
SELECT course_name, num_enrollments
FROM (
    SELECT c.name AS course_name, COUNT(e.enrollment_id) AS num_enrollments
    FROM Course c
    LEFT JOIN Enrollment e ON c.course_id = e.course_id
    GROUP BY c.name
    ORDER BY num_enrollments DESC
)
WHERE ROWNUM <= 3;

--part 19
SELECT s.name, s.gpa
FROM Student s
WHERE s.gpa > (SELECT AVG(gpa) FROM Student)
AND s.student_id IN (
    SELECT student_id
    FROM Enrollment
    GROUP BY student_id
    HAVING COUNT(course_id) > 3
);

--part 20
INSERT INTO Unassigned_Faculty (faculty_id, name, salary, dept_id)
SELECT f.faculty_id, f.name, f.salary, f.dept_id
FROM Faculty f
WHERE NOT EXISTS (SELECT 1 FROM Course c WHERE c.faculty_id = f.faculty_id);
SELECT * FROM Unassigned_Faculty