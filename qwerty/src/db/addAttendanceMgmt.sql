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

START TRANSACTION;
--Suppress messages below WARNING level for the duration of this script
SET LOCAL client_min_messages TO WARNING;

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
