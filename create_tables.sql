-- JUNGLE LIBRARY DATABASE
-- Phase III: Table Creation (Q3)

-- 1. PERSON
CREATE TABLE PERSON (
    PersonID    CHAR(4)         NOT NULL,
    FName       VARCHAR(50)     NOT NULL,
    MName       VARCHAR(50),
    LName       VARCHAR(50)     NOT NULL,
    Address     VARCHAR(255),
    Gender      CHAR(1),
    DateOfBirth DATE            NOT NULL,
    CONSTRAINT pk_person        PRIMARY KEY (PersonID),
    CONSTRAINT chk_personid     CHECK (REGEXP_LIKE(PersonID, 'P[0-9]{3}'))
);

-- 2. PHONENUMBER
CREATE TABLE PHONENUMBER (
    PhoneNumber VARCHAR(15)     NOT NULL,
    PersonID    CHAR(4)         NOT NULL,
    PhoneType   VARCHAR(10),
    CONSTRAINT pk_phonenumber           PRIMARY KEY (PhoneNumber),
    CONSTRAINT fk_phonenumber_person    FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE
);

-- 3. EMPLOYEE
CREATE TABLE EMPLOYEE (
    PersonID    CHAR(4)         NOT NULL,
    StartDate   DATE            NOT NULL,
    CONSTRAINT pk_employee          PRIMARY KEY (PersonID),
    CONSTRAINT fk_employee_person   FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE RESTRICT
);

-- 4. MEMBER
CREATE TABLE MEMBER (
    PersonID    CHAR(4)         NOT NULL,
    CONSTRAINT pk_member        PRIMARY KEY (PersonID),
    CONSTRAINT fk_member_person FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE RESTRICT
);

-- 5. SUPERVISOR
CREATE TABLE SUPERVISOR (
    PersonID        CHAR(4)     NOT NULL,
    YearsExperience INT,
    CONSTRAINT pk_supervisor            PRIMARY KEY (PersonID),
    CONSTRAINT fk_supervisor_employee   FOREIGN KEY (PersonID)
        REFERENCES EMPLOYEE(PersonID)
        ON DELETE CASCADE
);

-- 6. CATALOGING_MANAGER
CREATE TABLE CATALOGING_MANAGER (
    PersonID        CHAR(4)     NOT NULL,
    ExpertiseArea   VARCHAR(50),
    CONSTRAINT pk_cataloging_manager            PRIMARY KEY (PersonID),
    CONSTRAINT fk_cataloging_manager_employee   FOREIGN KEY (PersonID)
        REFERENCES EMPLOYEE(PersonID)
        ON DELETE CASCADE
);

-- 7. LIBRARY_RECEPTIONIST
CREATE TABLE LIBRARY_RECEPTIONIST (
    PersonID    CHAR(4)         NOT NULL,
    TrainerID   CHAR(4)         NOT NULL,
    Shift       VARCHAR(10)     NOT NULL,
    CONSTRAINT pk_receptionist              PRIMARY KEY (PersonID),
    CONSTRAINT fk_receptionist_employee     FOREIGN KEY (PersonID)
        REFERENCES EMPLOYEE(PersonID)
        ON DELETE CASCADE,
    CONSTRAINT fk_receptionist_trainer      FOREIGN KEY (TrainerID)
        REFERENCES SUPERVISOR(PersonID)
        ON DELETE RESTRICT
);

-- 8. LIBRARY_CARD
CREATE TABLE LIBRARY_CARD (
    CardID          CHAR(10)    NOT NULL,
    PersonID        CHAR(4)     NOT NULL,
    MembershipLevel VARCHAR(10) NOT NULL,
    IssueDate       DATE        NOT NULL,
    CONSTRAINT pk_library_card          PRIMARY KEY (CardID),
    CONSTRAINT chk_membership_level     CHECK (MembershipLevel IN ('Silver', 'Gold')),
    CONSTRAINT fk_librarycard_member    FOREIGN KEY (PersonID)
        REFERENCES MEMBER(PersonID)
        ON DELETE RESTRICT
);

-- 9. SILVER
CREATE TABLE SILVER (
    CardID  CHAR(10)    NOT NULL,
    CONSTRAINT pk_silver        PRIMARY KEY (CardID),
    CONSTRAINT fk_silver_card   FOREIGN KEY (CardID)
        REFERENCES LIBRARY_CARD(CardID)
        ON DELETE CASCADE
);

-- 10. GOLD
CREATE TABLE GOLD (
    CardID  CHAR(10)    NOT NULL,
    CONSTRAINT pk_gold      PRIMARY KEY (CardID),
    CONSTRAINT fk_gold_card FOREIGN KEY (CardID)
        REFERENCES LIBRARY_CARD(CardID)
        ON DELETE CASCADE
);

-- 11. GUEST_LOG
CREATE TABLE GUEST_LOG (
    GuestID         CHAR(10)        NOT NULL,
    CardID          CHAR(10)        NOT NULL,
    GuestName       VARCHAR(100)    NOT NULL,
    GuestAddress    VARCHAR(255),
    GuestContact    VARCHAR(15),
    VisitDate       DATE            NOT NULL,
    CONSTRAINT pk_guest_log         PRIMARY KEY (GuestID, CardID),
    CONSTRAINT fk_guestlog_gold     FOREIGN KEY (CardID)
        REFERENCES GOLD(CardID)
        ON DELETE CASCADE
);

-- 12. PROMOTION
CREATE TABLE PROMOTION (
    PromotionCode           CHAR(10)        NOT NULL,
    PromotionDescription    VARCHAR(255)    NOT NULL,
    ValidFrom               DATE            NOT NULL,
    ValidTo                 DATE            NOT NULL,
    CONSTRAINT pk_promotion PRIMARY KEY (PromotionCode)
);

-- 13. CARD_PROMOTION
CREATE TABLE CARD_PROMOTION (
    CardID          CHAR(10)    NOT NULL,
    PromotionCode   CHAR(10)    NOT NULL,
    DateApplied     DATE        NOT NULL,
    CONSTRAINT pk_card_promotion        PRIMARY KEY (CardID, PromotionCode),
    CONSTRAINT fk_cardpromo_card        FOREIGN KEY (CardID)
        REFERENCES LIBRARY_CARD(CardID)
        ON DELETE CASCADE,
    CONSTRAINT fk_cardpromo_promotion   FOREIGN KEY (PromotionCode)
        REFERENCES PROMOTION(PromotionCode)
        ON DELETE CASCADE
);

-- 14. PUBLISHER
CREATE TABLE PUBLISHER (
    PublisherID         CHAR(10)        NOT NULL,
    PublisherName       VARCHAR(100)    NOT NULL,
    PublisherAddress    VARCHAR(255),
    PublisherContact    VARCHAR(50),
    PublisherEmail      VARCHAR(100),
    CONSTRAINT pk_publisher PRIMARY KEY (PublisherID)
);

-- 15. BOOK
CREATE TABLE BOOK (
    BookID      CHAR(10)        NOT NULL,
    PublisherID CHAR(10)        NOT NULL,
    Title       VARCHAR(255)    NOT NULL,
    Category    VARCHAR(10)     NOT NULL,
    ISBN        VARCHAR(20)     NOT NULL,
    Edition     VARCHAR(20),
    CONSTRAINT pk_book              PRIMARY KEY (BookID),
    CONSTRAINT chk_book_category    CHECK (Category IN ('Cate.1', 'Cate.2', 'Cate.3')),
    CONSTRAINT fk_book_publisher    FOREIGN KEY (PublisherID)
        REFERENCES PUBLISHER(PublisherID)
        ON DELETE RESTRICT
);

-- 16. AUTHOR
CREATE TABLE AUTHOR (
    AuthorID    CHAR(10)    NOT NULL,
    AuthorFName VARCHAR(50) NOT NULL,
    AuthorLName VARCHAR(50) NOT NULL,
    DateOfBirth DATE,
    Nationality VARCHAR(50),
    CONSTRAINT pk_author PRIMARY KEY (AuthorID)
);

-- 17. BOOK_AUTHOR
CREATE TABLE BOOK_AUTHOR (
    BookID      CHAR(10)    NOT NULL,
    AuthorID    CHAR(10)    NOT NULL,
    CONSTRAINT pk_book_author       PRIMARY KEY (BookID, AuthorID),
    CONSTRAINT fk_bookauthor_book   FOREIGN KEY (BookID)
        REFERENCES BOOK(BookID)
        ON DELETE CASCADE,
    CONSTRAINT fk_bookauthor_author FOREIGN KEY (AuthorID)
        REFERENCES AUTHOR(AuthorID)
        ON DELETE CASCADE
);

-- 18. PAYMENT
CREATE TABLE PAYMENT (
    PaymentID       CHAR(10)        NOT NULL,
    PaymentAmount   DECIMAL(10,2)   NOT NULL,
    PaymentMethod   VARCHAR(20)     NOT NULL,
    PaymentTime     TIMESTAMP       NOT NULL,
    CONSTRAINT pk_payment           PRIMARY KEY (PaymentID),
    CONSTRAINT chk_payment_method   CHECK (PaymentMethod IN ('Cash', 'Debit Card', 'Credit Card'))
);

-- 19. BORROWING
CREATE TABLE BORROWING (
    BorrowID        CHAR(10)    NOT NULL,
    BookID          CHAR(10)    NOT NULL,
    PersonID        CHAR(4)     NOT NULL,
    ReceptionistID  CHAR(4)     NOT NULL,
    PaymentID       CHAR(10)    NOT NULL,
    IssueDate       DATE        NOT NULL,
    DueDate         DATE        NOT NULL,
    ReturnDate      DATE,
    CONSTRAINT pk_borrowing                 PRIMARY KEY (BorrowID),
    CONSTRAINT chk_borrowing_dates          CHECK (DueDate > IssueDate),
    CONSTRAINT fk_borrowing_book            FOREIGN KEY (BookID)
        REFERENCES BOOK(BookID)
        ON DELETE RESTRICT,
    CONSTRAINT fk_borrowing_person          FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE RESTRICT,
    CONSTRAINT fk_borrowing_receptionist    FOREIGN KEY (ReceptionistID)
        REFERENCES LIBRARY_RECEPTIONIST(PersonID)
        ON DELETE RESTRICT,
    CONSTRAINT fk_borrowing_payment         FOREIGN KEY (PaymentID)
        REFERENCES PAYMENT(PaymentID)
        ON DELETE RESTRICT
);

-- 20. INQUIRY
CREATE TABLE INQUIRY (
    InquiryID           CHAR(10)    NOT NULL,
    MemberID            CHAR(4)     NOT NULL,
    ReceptionistID      CHAR(4)     NOT NULL,
    InquiryTime         TIMESTAMP   NOT NULL,
    ResolutionStatus    VARCHAR(10) DEFAULT 'Open' NOT NULL,
    MemberRating        INT,
    CONSTRAINT pk_inquiry               PRIMARY KEY (InquiryID),
    CONSTRAINT chk_resolution_status    CHECK (ResolutionStatus IN ('Open', 'Resolved')),
    CONSTRAINT chk_member_rating        CHECK (MemberRating BETWEEN 1 AND 5),
    CONSTRAINT fk_inquiry_member        FOREIGN KEY (MemberID)
        REFERENCES MEMBER(PersonID)
        ON DELETE RESTRICT,
    CONSTRAINT fk_inquiry_receptionist  FOREIGN KEY (ReceptionistID)
        REFERENCES LIBRARY_RECEPTIONIST(PersonID)
        ON DELETE RESTRICT
);

-- 21. COMMENT
CREATE TABLE COMMENT (
    CommentID       CHAR(10)    NOT NULL,
    PersonID        CHAR(4)     NOT NULL,
    BookID          CHAR(10)    NOT NULL,
    CommentTime     TIMESTAMP   DEFAULT CURRENT_TIMESTAMP NOT NULL,
    Rating          INT         NOT NULL,
    CommentContent  TEXT        NOT NULL,
    CONSTRAINT pk_comment           PRIMARY KEY (CommentID),
    CONSTRAINT chk_comment_rating   CHECK (Rating BETWEEN 1 AND 5),
    CONSTRAINT fk_comment_person    FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE RESTRICT,
    CONSTRAINT fk_comment_book      FOREIGN KEY (BookID)
        REFERENCES BOOK(BookID)
        ON DELETE RESTRICT
);