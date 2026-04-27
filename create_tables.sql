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

CREATE TABLE PHONENUMBER(
    PhoneNumber CHAR(22)    NOT NULL,
    PersonID    CHAR(4)     NOT NULL,
    PhoneType   VARCHAR(10)

    CONSTRAINT pk_phonenumber PRIMARY KEY (PhoneNumber),
    CONSTRAINT fk_phonenumber_person FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE --might delete, not sure if we talked about this in class
);

CREATE TABLE MEMBER(
    PersonID    CHAR(4)     NOT NULL

    CONSTRAINT fk_phonenumber_person FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE --might delete, not sure if we talked about this in class
);

CREATE TABLE EMPLOYEE(
    PersonID    CHAR(4)     NOT NULL,
    StartDate   DATE        NOT NULL

    CONSTRAINT fk_phonenumber_person FOREIGN KEY(PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE
);

CREATE TABLE LIBRARY_CARD(
    CardID              CHAR(10)    NOT NULL,
    PersonID            CHAR(4)     NOT NULL,
    MembershipLevel     VARCHAR(10)
    IssueDate           DATE        NOT NULL

    CONSTRAINT pk_card PRIMARY KEY (CardID),
    CONSTRAINT fk_phonenumber_person FOREIGN KEY(PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE
);

CREATE TABLE SILVER(
    CardID  CHAR(10)    NOT NULL

    CONSTRAINT fk_card FOREIGN KEY (CardID)
        REFERENCES CARD(CardID)
        ON DELETE CASCADE
);

CREATE TABLE GOLD(
    CardID  CHAR(10)    NOT NULL

    CONSTRAINT fk_card FOREIGN KEY (CardID)
        REFERENCES CARD(CardID)
        ON DELETE CASCADE
);

CREATE TABLE GUESTLOG(

);

CREATE TABLE PROMOTION(

);

CREATE TABLE CARD_PROMOTION(

);

CREATE TABLE SUPERVISOR(

);

CREATE TABLE CATALOGING_MANAGER(

);

CREATE TABLE LIBRARY_RECEPTIONIST(

);

CREATE TABLE PUBLISHER(

);

CREATE TABLE BOOK(

);

CREATE TABLE AUTHOR(

);

CREATE TABLE BOOK_AUTHOR(

);

CREATE TABLE PAYMENT(

);

CREATE TABLE BORROWING(

);

CREATE TABLE INQUIRY(

);

CREATE TABLE COMMENT(

);

CREATE TABLE CATALOGING_RECORD(

);