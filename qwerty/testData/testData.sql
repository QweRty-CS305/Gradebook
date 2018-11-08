--Brian Bacon, Jake Homberg
--Team QweRty

--Test Data for all tables within database
\o spoolTestData.txt

\qecho -n 'Script run on '
\qecho -n `date /t`
\qecho -n 'at '
\qecho -n `time /t`
\qecho -n ' by '
\qecho :USER
\qecho ' '

--Course table
INSERT INTO qwerty.Course
VALUES('CS140', 'Introduction to Programming');

INSERT INTO qwerty.Course
VALUES('', 'Introduction to C++');

INSERT INTO qwerty.Course
VALUES('CS221', 'Data Structures in C++');

INSERT INTO qwerty.Course
VALUES('CS205', 'Database Management');

INSERT INTO qwerty.Course
VALUES('CS215', 'Computer Architecture');

--Season table
INSERT INTO qwerty.Season
VALUES(0, 'Spring', 'S');

INSERT INTO qwerty.Season
VALUES(1, 'Summer', 'M');

INSERT INTO qwerty.Season
VALUES(2, 'Fall', 'F');

INSERT INTO qwerty.Season
VALUES(3, 'Winter', 'W');

--Term table
INSERT INTO qwerty.Term
VALUES(DEFAULT, 2017, 0, '2018-01-15', '2018-05-12');

INSERT INTO qwerty.Term
VALUES(DEFAULT, 2017, 2, '2017-08-28', '2018-12-12');

INSERT INTO qwerty.Term
VALUES(DEFAULT, 2017, 3, '2017-12-15', '2018-01-11');

INSERT INTO qwerty.Term
VALUES(DEFAULT, 2016, 1, '2016-05-28', '2018-06-15');

INSERT INTO qwerty.Term
VALUES(DEFAULT, 2016, 0, '2016-01-20', '2016-05-22');

--Should fail, violates foreign key restraint
INSERT INTO qwerty.Term
VALUES(DEFAULT, 2018, 4, '2018-01-23', '2018-05-24');

--Should fail, violates Uniqueness constraint
INSERT INTO qwerty.Term
VALUES(DEFAULT, 2017, 0, '2018-01-15', '2018-05-12');

--Instructor table
INSERT INTO qwerty.Instructor (ID, fName, lName, Department, Email)
VALUES(
     DEFAULT,
     'Sean',
     'Murthy',
     'Computer Science',
     'SeanMurthy@WCSU.edu'
);

INSERT INTO qwerty.Instructor (ID, fName, lName, Department, Email)
VALUES(
     DEFAULT,
     'Gancho',
     'Ganchev',
     'Computer Science',
     'GanchoGanchev@WCSU.edu'
);

INSERT INTO qwerty.Instructor (ID, fName, lName, Department, Email)
VALUES(
     DEFAULT,
     'Dan',
     'Coffman',
     'Computer Science',
     'DanCoffman@WCSU.edu'
);

INSERT INTO qwerty.Instructor (ID, fName, lName, Department, Email)
VALUES(
     DEFAULT,
     'Todor',
     'Ivanov',
     'Computer Science',
     'TodorIvanov@WCSU.edu'
);

INSERT INTO qwerty.Instructor (ID, fName, lName, Department, Email)
VALUES(
     DEFAULT,
     'William',
     'Joel',
     'Computer Science',
     'WilliamJoel@WCSU.edu'
);

--Should fail, violates uniqueness constraint
INSERT INTO qwerty.Instructor (ID, fName, lName, Department, Email)
VALUES(
     DEFAULT,
     'William',
     'Joel',
     'Computer Science',
     'WilliamJoel@WCSU.edu'
);

--Should fail, violates email check
INSERT INTO qwerty.Instructor (ID, fName, lName, Department, Email)
VALUES(
     DEFAULT,
     'Rona',
     'Gurkewitz',
     'Computer Science',
     'RonaGurkewitz#WCSU.edu'
);

--Section table
INSERT INTO qwerty.Section
VALUES(
     DEFAULT,
     1,
     'CS140',
     '01',
     '00001',
     'WS116',
     '2017-01-15',
     '2017-05-15',
     '2017-03-15',
     1,
     2
);

INSERT INTO qwerty.Section
VALUES(
     DEFAULT,
     2,
     '',
     '01',
     '00010',
     'WS116',
     '2017-09-05',
     '2017-01-16',
     '2017-10-16',
     2
);

INSERT INTO qwerty.Section
VALUES(
     DEFAULT,
     2,
     'CS205',
     '01',
     '00011',
     'WS103',
     '2017-09-05',
     '2017-01-16',
     '2017-10-16',
     1
);

INSERT INTO qwerty.Section
VALUES(
     DEFAULT,
     1,
     'CS215',
     '01',
     '00111',
     'WS103',
     '2017-01-15',
     '2017-05-15',
     '2017-03-15',
     3
);

INSERT INTO qwerty.Section
VALUES(
     DEFAULT,
     1,
     'CS215',
     '71',
     '00112',
     'WS103',
     '2017-01-15',
     '2017-05-15',
     '2017-03-15',
     3
);

--Should fail, violates uniqueness constraint
INSERT INTO qwerty.Section
VALUES(
     DEFAULT,
     2,
     '',
     '01',
     '00010',
     'WS116',
     '2017-09-05',
     '2017-01-16',
     '2017-10-16',
     2
);

--Should fail, violates term FK
INSERT INTO qwerty.Section
VALUES(
     DEFAULT,
     10,
     '',
     '01',
     '00010',
     'WS116',
     '2017-09-05',
     '2017-01-16',
     '2017-10-16',
     2
);

--Should fail, violates Course FK
INSERT INTO qwerty.Section
VALUES(
     DEFAULT,
     1,
     'MAT100',
     '01',
     '00111',
     'WS103',
     '2017-01-15',
     '2017-05-15',
     '2017-03-15',
     3
);

--Section_Meeting
INSERT INTO qwerty.Section_Meeting
VALUES(
     DEFAULT,
     1,
     'M',
     '10:30:00.00',
     '12:00:00.00'
);

INSERT INTO qwerty.Section_Meeting
VALUES(
     DEFAULT,
     1,
     'W',
     '10:30:00.00',
     '12:00:00.00'
);

INSERT INTO qwerty.Section_Meeting
VALUES(
     DEFAULT,
     2,
     'T',
     '14:00:00.00',
     '15:30:00.00'
);

INSERT INTO qwerty.Section_Meeting
VALUES(
     DEFAULT,
     2,
     'Th',
     '14:00:00.00',
     '15:30:00.00'
);

INSERT INTO qwerty.Section_Meeting
VALUES(
     DEFAULT,
     3,
     'M',
     '09:00:00.00',
     '10:30:00.00'
);

INSERT INTO qwerty.Section_Meeting
VALUES(
     DEFAULT,
     3,
     'Th',
     '09:00:00.00',
     '10:30:00.00'
);

INSERT INTO qwerty.Section_Meeting
VALUES(
     DEFAULT,
     4,
     'T',
     '08:00:00.00',
     '09:30:00.00'
);

INSERT INTO qwerty.Section_Meeting
VALUES(
     DEFAULT,
     4,
     'F',
     '08:00:00.00',
     '09:30:00.00'
);

INSERT INTO qwerty.Section_Meeting
VALUES(
     DEFAULT,
     5,
     'M',
     '12:00:00.00',
     '13:30:00.00'
);

INSERT INTO qwerty.Section_Meeting
VALUES(
     DEFAULT,
     5,
     'W',
     '12:00:00.00',
     '13:30:00.00'
);

--Should fail, violates uniqueness constraint
INSERT INTO qwerty.Section_Meeting
VALUES(
     DEFAULT,
     1,
     'M',
     '10:30:00.00',
     '12:00:00.00'
);

--Should fail, violates Section FK
INSERT INTO qwerty.Section_Meeting
VALUES(
     DEFAULT,
     20,
     'M',
     '10:30:00.00',
     '12:00:00.00'
);

--Student
INSERT INTO qwerty.Student
VALUES(
     DEFAULT,
     'Brian',
     'Michael',
     'Bacon',
     '0001',
     'bbacon56@gmail.com',
     'Computer Science',
     'Senior'
);

INSERT INTO qwerty.Student
VALUES(
     DEFAULT,
     'Jake',
     'A',
     'Homberg',
     '0002',
     'Jhomberg@gmail.com',
     'Computer Science',
     'Junior'
);

INSERT INTO qwerty.Student
VALUES(
     DEFAULT,
     'Bobby',
     'B',
     'Bonilla',
     '0003',
     'BBonilla@gmail.com',
     'Accounting',
     'Freshman'
);

INSERT INTO qwerty.Student
VALUES(
     DEFAULT,
     'Chris',
     'C',
     'Smith',
     '0004',
     'CSmith@gmail.com',
     'Marketing',
     'Sophmore'
);

INSERT INTO qwerty.Student
VALUES(
     DEFAULT,
     'Timmy',
     'T',
     'Turner',
     '0005',
     'TTurner@gmail.com',
     'English',
     'Senior'
);

--Should fail, violates Uniqueness constraint
INSERT INTO qwerty.Student
VALUES(
     DEFAULT,
     'Brian',
     'Michael',
     'Bacon',
     '0001',
     'bbacon56@gmail.com',
     'Computer Science',
     'Senior'
);

--Should fail, violates email check
INSERT INTO qwerty.Student
VALUES(
     DEFAULT,
     'Timmy',
     'T',
     'Turner',
     '0005',
     'TTurner&gmail.com',
     'English',
     'Senior'
);

--Enrollee
INSERT INTO qwerty.Enrollee (Student, Section, DateEnrolled, YearEnrolled, MajorEnrolled)
VALUES(
     1,
     1,
     '2016-11-05',
     '2016',
     'Computer Science'
);

INSERT INTO qwerty.Enrollee (Student, Section, DateEnrolled, YearEnrolled, MajorEnrolled)
VALUES(
     1,
     4,
     '2016-11-05',
     '2016',
     'Computer Science'
);

INSERT INTO qwerty.Enrollee (Student, Section, DateEnrolled, YearEnrolled, MajorEnrolled)
VALUES(
     2,
     1,
     '2016-11-05',
     '2016',
     'Computer Science'
);

INSERT INTO qwerty.Enrollee (Student, Section, DateEnrolled, YearEnrolled, MajorEnrolled)
VALUES(
     2,
     4,
     '2016-11-05',
     '2016',
     'Computer Science'
);

INSERT INTO qwerty.Enrollee (Student, Section, DateEnrolled, YearEnrolled, MajorEnrolled)
VALUES(
     3,
     3,
     '2017-05-05',
     '2017',
     'Computer Science'
);

INSERT INTO qwerty.Enrollee (Student, Section, DateEnrolled, YearEnrolled, MajorEnrolled)
VALUES(
     3,
     1,
     '2016-11-05',
     '2016',
     'Computer Science'
);

--Should fail, violates student FK
INSERT INTO qwerty.Enrollee (Student, Section, DateEnrolled, YearEnrolled, MajorEnrolled)
VALUES(
     6,
     1,
     '2016-11-05',
     '2016',
     'Computer Science'
);

--Should fail, violates Section FK
INSERT INTO qwerty.Enrollee (Student, Section, DateEnrolled, YearEnrolled, MajorEnrolled)
VALUES(
     1,
     20,
     '2016-11-05',
     '2016',
     'Computer Science'
);

--AttendanceStatus
INSERT INTO qwerty.AttendanceStatus
VALUES('P', 'Present');

INSERT INTO qwerty.AttendanceStatus
VALUES('T', 'Tardy');

INSERT INTO qwerty.AttendanceStatus
VALUES('A', 'Absent');

--AttendanceRecord
INSERT INTO qwerty.AttendanceRecord
VALUES(
     1,
     1,
     '2017-01-20',
     '1',
     'A'
);

INSERT INTO qwerty.AttendanceRecord
VALUES(
     1,
     1,
     '2017-01-25',
     '1',
     'T'
);

INSERT INTO qwerty.AttendanceRecord
VALUES(
     1,
     1,
     '2017-01-30',
     1,
     'P'
);

--Should violate foreign key, no 2,2 in enrollee
INSERT INTO qwerty.AttendanceRecord
VALUES(
     2,
     2,
     '2017-09-20',
     4,
     'A'
);

INSERT INTO qwerty.AttendanceRecord
VALUES(
     2,
     1,
     '2017-12-25',
     3,
     'T'
);

--Should violate foreign key, no 5, 10 in enrollee
INSERT INTO qwerty.AttendanceRecord
VALUES(
     5,
     10,
     '2017-03-03',
     3,
     'T'
);

\o
