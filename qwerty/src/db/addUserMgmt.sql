-- addUserMgmt.sql

-- Brian Bacon, Jake Homberg
-- Team Qwerty

-- This script adds in the functionality to allow for the creation of
-- users and their corresponding instructor/student entries
\o spoolUserMgmt.txt

\qecho -n 'Script run on '
\qecho -n `date /t`
\qecho -n 'at '
\qecho -n `time /t`
\qecho -n ' by '
\qecho :USER
\qecho ' '



-- Drop the existing addUser function in the schema
DROP FUNCTION IF EXISTS qwerty.addUser(VARCHAR);

-- Create the addUser function with a boolean return type.
-- The function will run under the context of the definer.
CREATE FUNCTION qwerty.addUser(userIn VARCHAR)
RETURNS BOOLEAN AS
$$
BEGIN
  -- Create the database user with the same username and password.
  -- If it is successful, return true
  -- Note: The password is salted with the username
  EXECUTE FORMAT('CREATE USER %s WITH PASSWORD %L;', userIn, userIn);
  RETURN TRUE;
  -- Catch any exceptions to the CREATE USER statement. If we have
  -- met an exception, then we return false to allow the caller to
  -- know the user was not created
  EXCEPTION WHEN others THEN
  RETURN FALSE;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER;

-- Set the definer of the function to the postgres user
ALTER FUNCTION qwerty.addUser(VARCHAR) OWNER TO postgres;

-- Drop the addStudent function from the qwerty schema if one exists
DROP FUNCTION IF EXISTS qwerty.addStudent(INT, VARCHAR(50), VARCHAR(50), VARCHAR(50), VARCHAR(319), VARCHAR(50), VARCHAR(30));

-- Define the qwerty.addStudent function and have it return a boolean
-- representing wether or not it was successful in creating a student account
CREATE FUNCTION qwerty.addStudent(studentID INT,
                                  FName VARCHAR(50),
                                  MName VARCHAR(50),
                                  LName VARCHAR(50),
                                  Email VARCHAR(319),
                                  Major VARCHAR(50),
                                  Year VARCHAR(30))
RETURNS BOOLEAN AS
$$
DECLARE
  -- Declare the variables that we will use to store values for our dynamic queries
  query VARCHAR;
  newUser VARCHAR;
BEGIN
  -- Set the newUser variable to the first portion of the email.
  -- NOTE: The username part of the email must be alphanumeric
  newUser = SPLIT_PART(Email, '@', 1);
  -- If statement to check if we successfully create a user account.
  IF (SELECT qwerty.addUser(newUser)) THEN
    -- If so, grant the student role to the account
    EXECUTE FORMAT ('GRANT student TO %s;', newUser);
    -- Set up our dynamic SQL query and execute it given our values input
    query =
      'INSERT INTO qwerty.student '
      'VALUES($1, $2, $3, $4, $5, $6, $7);';
    EXECUTE query USING studentID, FName, MName, LName, Email, Major, Year;
    -- If we have had no exceptions so far, return true
    RETURN TRUE;
  ELSE
    -- If we cannot create a user account, return false
    RETURN FALSE;
  END IF;
  -- If we have met an exception, perform cleanup to ensure subsequent calls
  -- have a clean state to run on.
  EXCEPTION WHEN others THEN
    -- Drop the created user. At this point, we do not need to worry about
    -- cleanup of any table entries as that was the last item that could have
    -- failed. If it had passed, we would not be at this case. Return false
    EXECUTE FORMAT ('DROP USER %s;', newUser);
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER;

ALTER FUNCTION qwerty.addStudent(INT, VARCHAR(50), VARCHAR(50), VARCHAR(50), VARCHAR(319), VARCHAR(50), VARCHAR(30)) OWNER TO instructor;



DROP FUNCTION IF EXISTS qwerty.addInstructor(INT, VARCHAR(50), VARCHAR(50), VARCHAR(50), VARCHAR(30), VARCHAR(319));

CREATE OR REPLACE FUNCTION qwerty.addInstructor( ID INT,
                                                 FName VARCHAR(50),
                                                 MName VARCHAR(50),
                                                 LName VARCHAR(50),
                                                 Department VARCHAR(30),
                                                 Email VARCHAR(319))
RETURNS BOOLEAN AS
$$
DECLARE
-- Declare the variables that we will use to store values for our dynamic queries
query VARCHAR;
newUser VARCHAR;
BEGIN
  -- Set the newUser variable to the first portion of the email.
  -- NOTE: The username part of the email must be alphanumeric
  newUser = SPLIT_PART(Email, '@', 1);
  -- If statement to check if we successfully create a user account.
  IF (SELECT qwerty.addUser(newUser)) THEN
  -- If so, grant the instructor role to the account
  EXECUTE FORMAT ('GRANT instructor TO %s;', newUser);
  -- Set up our dynamic SQL query and execute it given our values input
  query =
    'INSERT INTO qwerty.instructor '
    'VALUES($1, $2, $3, $4, $5, $6);';
  EXECUTE query USING ID, FName, MName, LName, Department, Email;
  -- If we have had no exceptions so far, return true
  RETURN TRUE;
  ELSE
    -- If we cannot create a user account, return false
    RETURN FALSE;
  END IF;
  -- If we have met an exception, perform cleanup to ensure subsequent calls
  -- have a clean state to run on.
  EXCEPTION WHEN others THEN
    -- Drop the created user. At this point, we do not need to worry about
    -- cleanup of any table entries as that was the last item that could have
    -- failed. If it had passed, we would not be at this case. Return false
    EXECUTE FORMAT ('DROP USER %s;', newUser);
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

\o
