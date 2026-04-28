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
    PhoneType   VARCHAR(10),

    CONSTRAINT pk_phonenumber PRIMARY KEY (PhoneNumber),
    CONSTRAINT fk_phonenumber_person FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE --might delete, not sure if we talked about this in class
);

CREATE TABLE MEMBER(
    PersonID    CHAR(4)     NOT NULL,

    CONSTRAINT fk_phonenumber_person FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE --might delete, not sure if we talked about this in class
);

CREATE TABLE EMPLOYEE(
    PersonID    CHAR(4)     NOT NULL,
    StartDate   DATE        NOT NULL,

    CONSTRAINT fk_phonenumber_person FOREIGN KEY(PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE
);

CREATE TABLE LIBRARY_CARD(
    CardID              CHAR(10)    NOT NULL,
    PersonID            CHAR(4)     NOT NULL,
    MembershipLevel     VARCHAR(10),
    IssueDate           DATE        NOT NULL,

    CONSTRAINT pk_card PRIMARY KEY (CardID),
    CONSTRAINT fk_phonenumber_person FOREIGN KEY(PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE
);

CREATE TABLE SILVER(
    CardID  CHAR(10)    NOT NULL,

    CONSTRAINT fk_card FOREIGN KEY (CardID),
        REFERENCES CARD(CardID)
        ON DELETE CASCADE
);

CREATE TABLE GOLD(
    CardID  CHAR(10)    NOT NULL,

    CONSTRAINT fk_card FOREIGN KEY (CardID)
        REFERENCES CARD(CardID)
        ON DELETE CASCADE
);

CREATE TABLE GUESTLOG(
    GuestID         CHAR(10)    NOT NULL,
    CardID          CHAR(10)    NOT NULL,
    GuestName       VARCHAR(50) NOT NULL,
    GuestAddress    VARCHAR(255),
    GuestContact    VARCHAR(22),
    VisitDate       DATE        NOT NULL,

    CONSTRAINT pk_guest PRIMARY KEY (GuestID),
    CONSTRAINT fk_card FOREIGN KEY (CardID)
        REFERENCES CARD(CardID)
        ON DELETE CASCADE
);

CREATE TABLE PROMOTION(
    PromotionCode           CHAR(10)       NOT NULL,
    PromotionDescription    VARCHAR(255)   NOT NULL, 
    ValidFrom               DATE           NOT NULL,
    ValidTo                 DATE           NOT NULL,

    CONSTRAINT pk_promotioncode PRIMARY KEY (PromotionCode)
);

CREATE TABLE CARD_PROMOTION(
    CardID              CHAR(10)    NOT NULL,
    PromotionCode       CHAR(10)    NOT NULL,
    DateApplied         DATE        NOT NULL,

    CONSTRAINT fk_card FOREIGN KEY (CardID)
        REFERENCES CARD(CardID)
        ON DELETE CASCADE
);

CREATE TABLE SUPERVISOR(
    PersonID            CHAR(4) NOT NULL,
    YearsExperience     CHAR(3) NOT NULL,

    CONSTRAINT fk_person FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE
);

CREATE TABLE CATALOGING_MANAGER(
    PersonID        CHAR(4)  NOT NULL,
    ExpertiseArea   CHAR(15)

    CONSTRAINT fk_person FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE
);

CREATE TABLE LIBRARY_RECEPTIONIST(
    PersonID    CHAR(4)     NOT NULL,
    TrainerID   CHAR(4)     NOT NULL,
    Shift       VARCHAR(10) NOT NULL

    CONSTRAINT fk_person FOREIGN KEY(PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE
);

CREATE TABLE PUBLISHER(
    PublisherID         CHAR(10)     NOT NULL,
    PublisherName       VARCHAR(50)  NOT NULL,
    PublisherAddress    VARCHAR(255),
    PublisherContact    VARCHAR(255) NOT NULL
    PublisherEmail      VARCHAR(50)

    CONSTRAINT pk_publisher PRIMARY KEY (PublisherID)
);

CREATE TABLE BOOK(
    BookID              CHAR(10)    NOT NULL,
    PublisherID         CHAR(10)    NOT NULL,
    Title               VARCHAR(50) NOT NULL,
    Category            VARCHAR(50) NOT NULL,
    ISBN                VARCHAR(50) NOT NULL,
    Edition             VARCHAR(50) NOT NULL,

    CONSTRAINT pk_book PRIMARY KEY (BookID),
    CONSTRAINT fk_publisher FOREIGN KEY (PublisherID)
        REFERENCES PUBLISHER(PublisherID)
        ON DELETE CASCADE
);

CREATE TABLE AUTHOR(
    AuthorID       CHAR(10)     NOT NULL,
    AuthorFName    VARCHAR(50)  NOT NULL,
    AuthorLName    VARCHAR(50)  NOT NULL,
    DateOfBirth     DATE        NOT NULL,
    Nationality     VARCHAR(50) NOT NULL,

    CONSTRAINT pk_author PRIMARY KEY(AuthorID)
);

CREATE TABLE BOOK_AUTHOR(
    BookID          CHAR(10)    NOT NULL,
    AuthorID        CHAR(10)    NOT NULL,
    AuthorFName     VARCHAR(50) NOT NULL,
    AuthorLName     VARCHAR(50) NOT NULL,

    CONSTRAINT fk_book  FOREIGN KEY(BookID),
        REFERENCES BOOK(BookID)
        ON DELETE CASCADE
    CONSTRAINT fk_author FOREIGN KEY(AuthorID)
        REFERENCES AUTHOR(AuthorID)
        ON DELETE CASCADE
);

CREATE TABLE PAYMENT(
    PaymentID       CHAR(10)        NOT NULL,
    PaymentAmount   DECIMAL(10,2)   NOT NULL,
    PaymentMethod   VARCHAR(50)     NOT NULL,
    PaymentTime     TIMESTAMP       NOT NULL,

    CONSTRAINT pk_payment PRIMARY KEY(PaymentID)
);

CREATE TABLE BORROWING(
    BorrowID        CHAR(10)        NOT NULL,
    BookID          CHAR(10)        NOT NULL,
    PersonID        CHAR(4)         NOT NULL,
    ReceptionistID  CHAR(10)        NOT NULL,
    PaymentID       CHAR(10)        NOT NULL,
    IssueDate       DATE            NOT NULL,
    DueDate         DATE            NOT NULL,
    ReturnDate      DATE,
    
    CONSTRAINT pk_borrow PRIMARY KEY(BorrowID),
    CONSTRAINT fk_book  FOREIGN KEY(BookID),
        REFERENCES BOOK(BookID)
        ON DELETE CASCADE
    CONSTRAINT fk_person FOREIGN KEY(PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE
    CONSTRAINT fk_receptionist  FOREIGN KEY(ReceptionistID),
        REFERENCES LIBRARY_RECEPTIONIST(ReceptionistID)
        ON DELETE CASCADE
    CONSTRAINT fk_payment FOREIGN KEY(PaymentID)
        REFERENCES PAYMENT(PaymentID)
        ON DELETE CASCADE
    
);

CREATE TABLE INQUIRY(
    InquiryID           CHAR(10)    NOT NULL,
    MemberID            CHAR(10)    NOT NULL,
    ReceptionistID      CHAR(10)    NOT NULL,
    InquiryTime         TIMESTAMP   NOT NULL,
    ResolutionStatus    VARCHAR(10) NOT NULL,
    MemberRating        INT         NOT NULL

    CONSTRAINT pk_inquiry PRIMARY KEY(InquiryID),
    CONSTRAINT fk_member  FOREIGN KEY(MemberID),
        REFERENCES MEMBER(MemberID)
        ON DELETE CASCADE
    CONSTRAINT fk_receptionist FOREIGN KEY(ReceptionistID)
        REFERENCES LIBRARY_RECEPTIONIST(ReceptionistID)
        ON DELETE CASCADE
);

CREATE TABLE COMMENT(
    CommentID       CHAR(10)       NOT NULL,
    PersonID        CHAR(4)        NOT NULL,
    BookID          CHAR(10)       NOT NULL,
    CommentTime     TIMESTAMP      NOT NULL,
    CommentContent  TEXT           NOT NULL           

    CONSTRAINT pk_comment PRIMARY KEY(CommentID),
    CONSTRAINT fk_person FOREIGN KEY(PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE    
    CONSTRAINT fk_book  FOREIGN KEY(BookID),
        REFERENCES BOOK(BookID)
        ON DELETE CASCADE
);

CREATE TABLE CATALOGING_RECORD(
    CatalogingRecordID      CHAR(10)    NOT NULL,
    CatalogingManagerID     CHAR(10)    NOT NULL,
    BookID                  CHAR(10)    NOT NULL,
    WorkDate                DATE        NOT NULL,
    CategoryWorked          VARCHAR(10) NOT NULL,
    Notes                   TEXT

    CONSTRAINT pk_cataloging_record PRIMARY KEY (CatalogingRecordID)
    CONSTRAINT fk_cataloging_manager FOREIGN KEY(CatalogingManagerID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE
    CONSTRAINT fk_book FOREIGN KEY(BookID)
        REFERENCES BOOK(BookID)
        ON DELETE CASCADE
);