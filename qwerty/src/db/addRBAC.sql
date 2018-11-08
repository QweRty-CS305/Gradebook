-- addRBAC.sql

-- Brian Bacon, Jake Homberg
-- Team Qwerty

-- This script adds RBAC for all tables within the DB

\o spooladdRBAC.txt

\qecho -n 'Script run on '
\qecho -n `date /t`
\qecho -n 'at '
\qecho -n `time /t`
\qecho -n ' by '
\qecho :USER
\qecho ' '

-- Grant privileges for Course
REVOKE ALL PRIVILEGES ON TABLE qwerty.Course FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Course TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Course TO instructor;
GRANT SELECT ON TABLE qwerty.Course TO student;

--Grant privileges for Season
REVOKE ALL PRIVILEGES ON TABLE qwerty.Season FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Season TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Season TO instructor;
GRANT SELECT ON TABLE qwerty.Season TO student;

--Grant privileges for term
REVOKE ALL PRIVILEGES ON TABLE qwerty.Term FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Term TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Term TO instructor;
GRANT SELECT ON TABLE qwerty.Term TO student;

--Grant privileges for Instructor
REVOKE ALL PRIVILEGES ON TABLE qwerty.Instructor FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Instructor TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Instructor TO instructor;
GRANT SELECT ON TABLE qwerty.Instructor TO student;

--Grant prvileges for Section
REVOKE ALL PRIVILEGES ON TABLE qwerty.Section FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Section TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Section TO instructor;
GRANT SELECT ON TABLE qwerty.Section TO student;

--Grant privileges for Section_Meeting
REVOKE ALL PRIVILEGES ON TABLE qwerty.Section_Meeting FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Section_Meeting TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Section_Meeting TO instructor;
GRANT SELECT ON TABLE qwerty.Section_Meeting TO student;

--Grant privileges for Grade
REVOKE ALL PRIVILEGES ON TABLE qwerty.Grade FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Grade TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Grade TO instructor;
GRANT SELECT ON TABLE qwerty.Grade TO student;

--Grant privileges for Section_GradeTier
REVOKE ALL PRIVILEGES ON TABLE qwerty.Section_GradeTier FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Section_GradeTier TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Section_GradeTier TO instructor;
GRANT SELECT ON TABLE qwerty.Section_GradeTier TO student;

--Grant privileges for Student
REVOKE ALL PRIVILEGES ON TABLE qwerty.Student FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Student TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Student TO instructor;
GRANT SELECT ON TABLE qwerty.Student TO student;

--Grant privileges for Enrollee
REVOKE ALL PRIVILEGES ON TABLE qwerty.Enrollee FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Enrollee TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Enrollee TO instructor;
GRANT SELECT ON TABLE qwerty.Enrollee TO student;

--Grant privileges for AttendanceStatus
REVOKE ALL PRIVILEGES ON TABLE qwerty.AttendanceStatus FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.AttendanceStatus TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.AttendanceStatus TO instructor;
GRANT SELECT ON TABLE qwerty.AttendanceStatus TO student;


--Grant privileges for AttendanceRecord
REVOKE ALL PRIVILEGES ON TABLE qwerty.AttendanceRecord FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.AttendanceRecord TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.AttendanceRecord TO instructor;
GRANT SELECT ON TABLE qwerty.AttendanceRecord TO student;

--Grant privileges for Section_AssessmentComponent
REVOKE ALL PRIVILEGES ON TABLE qwerty.Section_AssessmentComponent FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Section_AssessmentComponent TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Section_AssessmentComponent TO instructor;
GRANT SELECT ON TABLE qwerty.Section_AssessmentComponent TO student;

--Grant privileges for Section_AssessmentItem
REVOKE ALL PRIVILEGES ON TABLE qwerty.Section_AssessmentItem FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Section_AssessmentItem TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Section_AssessmentItem TO instructor;
GRANT SELECT ON TABLE qwerty.Section_AssessmentItem TO student;

--Grant privileges for Section_AssessmentItem
REVOKE ALL PRIVILEGES ON TABLE qwerty.Enrollee_AssessmentItem FROM public;
GRANT ALL PRIVILEGES ON TABLE qwerty.Enrollee_AssessmentItem TO postgres;
GRANT ALL PRIVILEGES ON TABLE qwerty.Enrollee_AssessmentItem TO instructor;
GRANT SELECT ON TABLE qwerty.Enrollee_AssessmentItem TO student;

\o
