-- 3. Write SQL statements to create relational database and all other structures.
-- Primary key and foreign keys must be defined as appropriate. 
-- Also specify data type and constraints for each attribute and in addition to specify the referential integrity.

-- TODOS:
-- Create 21 Tables
-- Refer to Phase III Diagram for that

CREATE TABLE PERSON (
    PersonID    CHAR(4)         NOT NULL,
    FName       VARCHAR(50)     NOT NULL,
    MName       VARCHAR(50),
    LName       VARCHAR(50)     NOT NULL,
    Address     VARCHAR(255),
    Gender      CHAR(1),
    DateOfBirth DATE            NOT NULL,
    CONSTRAINT pk_person PRIMARY KEY (PersonID),
    CONSTRAINT chk_personid CHECK (PersonID LIKE 'P[0-9][0-9][0-9]')
);