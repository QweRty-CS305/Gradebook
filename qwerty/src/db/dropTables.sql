-- dropTables.sql

-- Brian Bacon, Jake Homberg
-- Team Qwerty

-- Script to drop all tables from the database

\o spooldropTables.txt

\qecho -n 'Script run on '
\qecho -n `date /t`
\qecho -n 'at '
\qecho -n `time /t`
\qecho -n ' by '
\qecho :USER
\qecho ' '

START TRANSACTION;


--Remove the following line to drop tables from default schema instead
SET LOCAL SCHEMA 'qwerty';


DROP TABLE IF EXISTS Course CASCADE;
DROP TABLE IF EXISTS Season CASCADE;
DROP TABLE IF EXISTS Term CASCADE;
DROP TABLE IF EXISTS Instructor CASCADE;
DROP TABLE IF EXISTS Section CASCADE;
DROP TABLE IF EXISTS Section_Meeting CASCADE;
DROP TABLE IF EXISTS Grade CASCADE;
DROP TABLE IF EXISTS Section_GradeTier CASCADE;
DROP TABLE IF EXISTS Student CASCADE;
DROP TABLE IF EXISTS Enrollee CASCADE;
DROP TABLE IF EXISTS AttendanceStatus CASCADE;
DROP TABLE IF EXISTS AttendanceRecord CASCADE;
DROP TABLE IF EXISTS Section_AssessmentComponent CASCADE;
DROP TABLE IF EXISTS Section_AssessmentItem CASCADE;
DROP TABLE IF EXISTS Enrollee_AssessmentItem CASCADE;
DROP TABLE IF EXISTS openCloseStaging CASCADE;


COMMIT;

\o
