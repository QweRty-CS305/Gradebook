-- addAttendanceMgmt.sql

-- Brian Bacon, Jake Homberg
-- Team Qwerty

-- This script adds in the functionality to allow instructors and students to
-- manage attendance records within the database
\o spoolAttendanceMgmt.txt

\qecho -n 'Script run on '
\qecho -n `date /t`
\qecho -n 'at '
\qecho -n `time /t`
\qecho -n ' by '
\qecho :USER
\qecho ' '

--This file has some issues related to formatting, clarity, and efficiency
-- fix after milestone M1: delete this comment block after fixing the issues

--Suppress messages below WARNING level for the duration of this script
SET LOCAL client_min_messages TO WARNING;


--Drop function from M1 that has since been renamed or removed
-- remove the DROP statement after M2
DROP FUNCTION IF EXISTS qwerty.datesFromSchedule(DATE, DATE, VARCHAR(7));


--Function to generate a list of dates for a class schedule, within a date range
-- startDate should not be past endDate
-- schedule is a string such as 'MWF' which means Mondays, Wednesdays, Fridays

--The following day codes are recognized:
--N = Sunday
--M = Monday
--T = Tuesday
--W = Wednesday
--R = Thursday
--F = Friday
--S = Saturday

--Example usage: get dates of Tuesdays and Thursdays b/w 2017-01-01 and 2017-05-01:
-- SELECT * FROM qwerty.getScheduleDates('2017-01-01', '2017-05-01', 'TR');

DROP FUNCTION IF EXISTS qwerty.getScheduleDates(DATE, DATE, VARCHAR(7));

CREATE FUNCTION qwerty.getScheduleDates(startDate DATE, endDate DATE,
                                           schedule VARCHAR(7)
                                          )
RETURNS TABLE (ScheduleDate DATE)
AS $$
   --enumerate all dates between startDate and endDate using a recursive CTE
   -- CTE can be eliminated by using the following call in the outer FROM clause
   -- generate_series(startDate, endDate, '1 day')
   WITH RECURSIVE EnumeratedDate AS
   (
      SELECT $1 sd --Start with startDate as long as it is not past the end date
      WHERE $1 <= $2
      UNION ALL
      SELECT sd + 1 --Increment by one day for each row
      FROM EnumeratedDate
      WHERE sd < $2 --End at endDate
   )
   SELECT sd
   FROM EnumeratedDate
   WHERE CASE --test match to schedule by extracting the day-of-week for the date
      WHEN EXTRACT(DOW FROM sd) = 0 THEN $3 LIKE '%N%'
      WHEN EXTRACT(DOW FROM sd) = 1 THEN $3 LIKE '%M%'
      WHEN EXTRACT(DOW FROM sd) = 2 THEN $3 LIKE '%T%'
      WHEN EXTRACT(DOW FROM sd) = 3 THEN $3 LIKE '%W%'
      WHEN EXTRACT(DOW FROM sd) = 4 THEN $3 LIKE '%R%'
      WHEN EXTRACT(DOW FROM sd) = 5 THEN $3 LIKE '%F%'
      WHEN EXTRACT(DOW FROM sd) = 6 THEN $3 LIKE '%S%'
   END;
$$ LANGUAGE sql
            IMMUTABLE
            RETURNS NULL ON NULL INPUT;


--Function to get attendance for a section ID
DROP FUNCTION IF EXISTS qwerty.getAttendance(INT);

CREATE FUNCTION qwerty.getAttendance(sectionID INT)
RETURNS TABLE(AttendanceCsvWithHeader TEXT) AS
$$

   WITH
   --get all dates the section meets: each date will be unique
   SectionDate AS
   (
      SELECT ScheduleDate
      FROM qwerty.Section,
           qwerty.getScheduleDates(StartDate, EndDate, Schedule)
      WHERE ID = $1
   ),
   --combine every student enrolled in section w/ each meeting date of section
   Enrollee_Date AS
   (
      SELECT Student, ScheduleDate
      FROM qwerty.Enrollee, SectionDate
      WHERE Section = $1
   ),
   --get the recorded attendance for each enrollee, marking as "Present" if
   --attendance is not recorded for an enrollee-date combo
   sdar AS
   (
      SELECT ed.Student, ScheduleDate, COALESCE(ar.Status, 'P') c
      FROM Enrollee_Date ed
           LEFT OUTER JOIN qwerty.AttendanceRecord ar
           ON ed.Student = ar.Student
              AND ed.ScheduleDate = ar.Date
              AND ar.Section = $1 --can't move test on section to WHERE clause
   )
   --generate attendance data as CSV data with headers
   -- order columns in each row by meeting date;
   -- order rows in the data portion by student name;
   -- function concat_ws is used to easily generate CSV strings
   SELECT concat_ws(',', 'Last', 'First', 'Middle',
                     string_agg(to_char(ScheduleDate, 'MM-DD-YYYY'), ','
                                ORDER BY ScheduleDate
                               )
                    ) csv_header
   FROM SectionDate
   UNION ALL
   (
      SELECT concat_ws(',', st.LName, st.FName, COALESCE(st.MName, ''),
                      string_agg(c, ',' ORDER BY ScheduleDate)
                     )
      FROM sdar JOIN qwerty.Student st ON sdar.Student = st.ID
      GROUP BY st.ID
      ORDER BY st.LName, st.FName, COALESCE(st.MName, '')
   );

$$ LANGUAGE sql;


--Function to get attendance for a year-season-course-section# combo
DROP FUNCTION IF EXISTS qwerty.getAttendance(NUMERIC(4,0), VARCHAR(20),
                                                VARCHAR(8), VARCHAR(3)
                                               );

CREATE FUNCTION qwerty.getAttendance(year NUMERIC(4,0),
                                                   seasonIdentification VARCHAR(20),
                                                   course VARCHAR(8),
                                                   sectionNumber VARCHAR(3)
                                                  )
RETURNS TABLE(AttendanceCsvWithHeader TEXT) AS
$$
   SELECT qwerty.getAttendance(qwerty.getSectionID($1, $2, $3, $4));
$$ LANGUAGE sql;

-- Clean up an existing isInstructor function
DROP FUNCTION IF EXISTS qwerty.isInstructor();

-- Create a new isInstructor function to return a boolean
-- that expresses if the session user is an instructor
CREATE FUNCTION qwerty.isInstructor()
RETURNS BOOLEAN AS
$$
BEGIN
  -- If there is an entry or more in the instructor table that corresponds
  -- to the session user, then return true
  IF ((SELECT COUNT(ID) FROM qwerty.Instructor WHERE EMAIL LIKE CONCAT(SESSION_USER, '@%')) > 0) THEN
    RETURN TRUE;
  -- If there is not, return false
  ELSE
    RETURN FALSE;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Clean up an existing isStudent function
DROP FUNCTION IF EXISTS qwerty.isStudent();

-- Create a new isStudent function to return a boolean
-- that expresses if a session user is a student
CREATE FUNCTION qwerty.isStudent()
RETURNS BOOLEAN AS
$$
BEGIN
  -- if there is a student entry for the given session user, then return true
  IF ((SELECT COUNT(ID) FROM qwerty.Student WHERE EMAIL LIKE CONCAT(SESSION_USER, '@%')) > 1) THEN
    RETURN TRUE;
  -- Else, return false
  ELSE
    RETURN FALSE;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Clean up existing isTardy function
DROP FUNCTION IF EXISTS qwerty.isTardy(INT, INT);

-- Create new isTardy function to return a boolean value expressing wether or not
-- the student is late to their section
CREATE FUNCTION qwerty.isTardy( studentID INT,
                                sectionMeetingID INT)
RETURNS BOOLEAN AS
$$
DECLARE
  timeDifference INT;
  timeStartVar TIME;
BEGIN
  -- Get the expected time the section meetings start at.
  timeStartVar = (SELECT TimeStart FROM qwerty.Section_Meeting WHERE ID = sectionMeetingID)::time;

  -- Get the difference between the start of class and now.
  timeDifference = (SELECT DATE_PART('hour', NOW()::time - timeStartVar::time) * 60 + DATE_PART('minute', NOW()::time - timeStartVar::time))::INT;
  -- If the time difference is less than the allowed attendance window, return false
  IF (timeDifference <= (SELECT AttendanceWindow FROM qwerty.Section WHERE ID = (SELECT SectionID FROM qwerty.Section_Meeting WHERE ID = sectionMeetingID))) THEN
    RETURN FALSE;
  -- Else, return true
  ELSE
    RETURN TRUE;
END IF;
END;
$$ LANGUAGE plpgsql;

-- Clean up existing instrcutorCheckIn function
DROP FUNCTION IF EXISTS qwerty.instructorCheckIn(INT, INT, DATE, INT, CHAR(1));

-- Create an instructorCheckIn function that will return a boolean expressing
-- if the insert query has run successfully
CREATE FUNCTION qwerty.instructorCheckIn(studentID INT,
                                         sectionID INT,
                                         checkInDate DATE,
                                         MeetingID INT,
                                         attendanceValue CHAR(1)
                                       )
RETURNS BOOLEAN AS
$$
DECLARE
query VARCHAR;
BEGIN
  -- Set up the query for the insert into attendanceRecord
  query =
    'INSERT INTO qwerty.attendanceRecord '
    'VALUES($1, $2, $3, $4, $5);';
  -- Execute the query using the parameters from the function
  EXECUTE query USING studentID, sectionID, checkInDate, MeetingID, attendanceValue;
  -- Return true to let the caller know it has completed without error.
  RETURN TRUE;
-- On an exception, return false
EXCEPTION WHEN others THEN
  RETURN FALSE;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER;

-- Set the owner of the function to the instructor role. The function will run in
-- the context of the instructor role because SECURITY DEFINER is set.
ALTER FUNCTION qwerty.instructorCheckIn(INT, INT, DATE, INT, CHAR(1)) OWNER TO instructor;


-- studentCheckIn Function goes here once it is finished

-- Clean up any existing studentCheckIn function
DROP FUNCTION IF EXISTS qwerty.studentCheckIn(INT, INT, VARCHAR(50));

--
CREATE FUNCTION qwerty.studentCheckIn(sectionID INT,
                                      CourseMeetingID INT,
                                      Reason VARCHAR(50))
RETURNS BOOLEAN AS
$$
DECLARE
  studentID INT;
BEGIN
  studentID = (SELECT ID FROM qwerty.Student WHERE Email LIKE CONCAT(SESSION_USER, '@%'));
  -- Check to see if the difference between the current time and the start of the class
  -- is greater than the attendanceWindow value for the section.
  IF (SELECT qwerty.isTardy(studentID, sectionID)) THEN
    -- If it is greater, create an attendanceRecord with a tardy entry
    INSERT INTO qwerty.attendanceRecord VALUES(studentID, sectionID, CURRENT_DATE, CourseMeetingID, 'T', Reason);
    RETURN TRUE;
  ELSE
    -- Else mark the student as present
    INSERT INTO qwerty.attendanceRecord VALUES(studentID, sectionID, CURRENT_DATE, CourseMeetingID, 'P');
    RETURN TRUE;
  END IF;
EXCEPTION WHEN others THEN
  RETURN FALSE;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER;

-- Alter the owner of the studentCheckIn so we have access to insert values into the attendanceRecord table
-- within the context of this function only
ALTER FUNCTION qwerty.studentCheckIn(INT, INT, VARCHAR(50)) OWNER TO instructor;




-- Clean up the existing setAttendanceRecord
DROP FUNCTION IF EXISTS qwerty.setAttendanceRecord(INT, INT, DATE, INT, CHAR(1), VARCHAR(50));

CREATE FUNCTION qwerty.setAttendanceRecord(studentID INT,
                                          sectionID INT,
                                          dateAttended DATE,
                                          courseMeetingID INT,
                                          attendanceStatus CHAR(1),
                                          reason VARCHAR(50)
                                        )
RETURNS BOOLEAN AS
$$
BEGIN
  -- Check to see if the session user is an instructor
  IF (SELECT qwerty.isInstructor()) THEN
    -- If it is, return the result of the instructorCheckIn
    RETURN (SELECT qwerty.instructorCheckIn(studentID, sectionID, dateAttended, courseMeetingID, attendanceStatus));
  -- Else check to see if session user is a student
  ELSEIF (SELECT qwerty.isStudent()) THEN
    -- If it is, return the result of the studentCheckIn
    RETURN (SELECT qwerty.studentCheckIn(studentID, sectionID, courseMeetingID, reason));
  ELSE
    RETURN FALSE;
  END IF;
END;
$$ LANGUAGE plpgsql;


\o
