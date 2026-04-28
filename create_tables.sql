-- JUNGLE LIBRARY DATABASE
-- Phase III: Table Creation (Q3)

-- 1. PERSON
CREATE TABLE PERSON (
    PersonID    CHAR(4)         NOT NULL,  -- unique ID for every person (e.g. P001)
    FName       VARCHAR(50)     NOT NULL,  -- first name
    MName       VARCHAR(50),               -- middle name (optional)
    LName       VARCHAR(50)     NOT NULL,  -- last name
    Address     VARCHAR(255),              -- home address (optional)
    Gender      CHAR(1),                   -- gender stored as a single character e.g. M or F (optional)
    DateOfBirth DATE            NOT NULL,  -- date of birth
    CONSTRAINT pk_person        PRIMARY KEY (PersonID),                        -- PersonID uniquely identifies each person
    CONSTRAINT chk_personid     CHECK (REGEXP_LIKE(PersonID, 'P[0-9]{3}'))    -- PersonID must follow the format P + 3 digits (e.g. P001)
);

-- 2. PHONENUMBER
CREATE TABLE PHONENUMBER (
    PhoneNumber VARCHAR(15)     NOT NULL,  -- the phone number itself (primary identifier)
    PersonID    CHAR(4)         NOT NULL,  -- the person this number belongs to
    PhoneType   VARCHAR(10),               -- type of number e.g. mobile, home, work (optional)
    CONSTRAINT pk_phonenumber           PRIMARY KEY (PhoneNumber),             -- each phone number is unique
    CONSTRAINT fk_phonenumber_person    FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE CASCADE                                                       -- if the person is deleted, remove their phone numbers too
);

-- 3. EMPLOYEE
CREATE TABLE EMPLOYEE (
    PersonID    CHAR(4)         NOT NULL,  -- links to the PERSON table (employee is also a person)
    StartDate   DATE            NOT NULL,  -- date they started working at the library
    CONSTRAINT pk_employee          PRIMARY KEY (PersonID),                    -- PersonID uniquely identifies each employee
    CONSTRAINT fk_employee_person   FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE RESTRICT                                                      -- cannot delete a person if they are still an employee
);

-- 4. MEMBER
CREATE TABLE MEMBER (
    PersonID    CHAR(4)         NOT NULL,  -- links to the PERSON table (member is also a person)
    CONSTRAINT pk_member        PRIMARY KEY (PersonID),                        -- PersonID uniquely identifies each member
    CONSTRAINT fk_member_person FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE RESTRICT                                                      -- cannot delete a person if they are still a member
);

-- 5. SUPERVISOR
CREATE TABLE SUPERVISOR (
    PersonID        CHAR(4)     NOT NULL,  -- links to the EMPLOYEE table (supervisor is also an employee)
    YearsExperience INT,                   -- how many years of experience they have (optional)
    CONSTRAINT pk_supervisor            PRIMARY KEY (PersonID),                -- PersonID uniquely identifies each supervisor
    CONSTRAINT fk_supervisor_employee   FOREIGN KEY (PersonID)
        REFERENCES EMPLOYEE(PersonID)
        ON DELETE CASCADE                                                       -- if the employee record is deleted, remove their supervisor record too
);

-- 6. CATALOGING_MANAGER
CREATE TABLE CATALOGING_MANAGER (
    PersonID        CHAR(4)     NOT NULL,  -- links to the EMPLOYEE table (cataloging manager is also an employee)
    ExpertiseArea   VARCHAR(50),           -- the subject area they specialize in (optional)
    CONSTRAINT pk_cataloging_manager            PRIMARY KEY (PersonID),        -- PersonID uniquely identifies each cataloging manager
    CONSTRAINT fk_cataloging_manager_employee   FOREIGN KEY (PersonID)
        REFERENCES EMPLOYEE(PersonID)
        ON DELETE CASCADE                                                       -- if the employee record is deleted, remove their cataloging manager record too
);

-- 7. LIBRARY_RECEPTIONIST
CREATE TABLE LIBRARY_RECEPTIONIST (
    PersonID    CHAR(4)         NOT NULL,  -- links to the EMPLOYEE table (receptionist is also an employee)
    TrainerID   CHAR(4)         NOT NULL,  -- the supervisor who trained this receptionist
    Shift       VARCHAR(10)     NOT NULL,  -- the shift they work e.g. morning, evening
    CONSTRAINT pk_receptionist              PRIMARY KEY (PersonID),            -- PersonID uniquely identifies each receptionist
    CONSTRAINT fk_receptionist_employee     FOREIGN KEY (PersonID)
        REFERENCES EMPLOYEE(PersonID)
        ON DELETE CASCADE,                                                      -- if the employee record is deleted, remove their receptionist record too
    CONSTRAINT fk_receptionist_trainer      FOREIGN KEY (TrainerID)
        REFERENCES SUPERVISOR(PersonID)
        ON DELETE RESTRICT                                                      -- cannot delete a supervisor if they are still listed as a trainer
);

-- 8. LIBRARY_CARD
CREATE TABLE LIBRARY_CARD (
    CardID          CHAR(10)    NOT NULL,  -- unique ID for the library card
    PersonID        CHAR(4)     NOT NULL,  -- the member this card belongs to
    MembershipLevel VARCHAR(10) NOT NULL,  -- whether the card is Silver or Gold
    IssueDate       DATE        NOT NULL,  -- the date the card was issued (membership enrollment date)
    CONSTRAINT pk_library_card          PRIMARY KEY (CardID),                  -- CardID uniquely identifies each library card
    CONSTRAINT chk_membership_level     CHECK (MembershipLevel IN ('Silver', 'Gold')),  -- membership level can only be Silver or Gold
    CONSTRAINT fk_librarycard_member    FOREIGN KEY (PersonID)
        REFERENCES MEMBER(PersonID)
        ON DELETE RESTRICT                                                      -- cannot delete a member if they still have a library card
);

-- 9. SILVER
CREATE TABLE SILVER (
    CardID  CHAR(10)    NOT NULL,  -- links to a LIBRARY_CARD that is Silver tier
    CONSTRAINT pk_silver        PRIMARY KEY (CardID),                          -- CardID uniquely identifies each silver card
    CONSTRAINT fk_silver_card   FOREIGN KEY (CardID)
        REFERENCES LIBRARY_CARD(CardID)
        ON DELETE CASCADE                                                       -- if the library card is deleted, remove the silver record too
);

-- 10. GOLD
CREATE TABLE GOLD (
    CardID  CHAR(10)    NOT NULL,  -- links to a LIBRARY_CARD that is Gold tier
    CONSTRAINT pk_gold      PRIMARY KEY (CardID),                              -- CardID uniquely identifies each gold card
    CONSTRAINT fk_gold_card FOREIGN KEY (CardID)
        REFERENCES LIBRARY_CARD(CardID)
        ON DELETE CASCADE                                                       -- if the library card is deleted, remove the gold record too
);

-- 11. GUEST
CREATE TABLE GUEST (
    GuestID         CHAR(10)        NOT NULL,  -- unique ID for the guest
    CardID          CHAR(10)        NOT NULL,  -- the Gold card that sponsored this guest
    GuestName       VARCHAR(100)    NOT NULL,  -- full name of the guest
    GuestAddress    VARCHAR(255),              -- guest's home address (optional)
    GuestContact    VARCHAR(15),               -- guest's contact number (optional)
    CONSTRAINT pk_guest         PRIMARY KEY (GuestID, CardID),                 -- a guest is uniquely identified by their ID and the card that brought them in
    CONSTRAINT fk_guest_gold    FOREIGN KEY (CardID)
        REFERENCES GOLD(CardID)
        ON DELETE CASCADE                                                       -- if the gold card is deleted, remove the guest records linked to it
);

-- 12. GUEST_LOG
CREATE TABLE GUEST_LOG (
    LogID       CHAR(10)    NOT NULL,  -- unique ID for each log entry
    GuestID     CHAR(10)    NOT NULL,  -- the guest who visited
    CardID      CHAR(10)    NOT NULL,  -- the gold card that sponsored the visit
    VisitDate   DATE        NOT NULL,  -- the date of the guest's visit
    CONSTRAINT pk_guest_log         PRIMARY KEY (LogID),                       -- LogID uniquely identifies each visit log
    CONSTRAINT fk_guestlog_guest    FOREIGN KEY (GuestID, CardID)
        REFERENCES GUEST(GuestID, CardID)
        ON DELETE CASCADE                                                       -- if the guest record is deleted, remove their visit logs too
);

-- 13. PROMOTION
CREATE TABLE PROMOTION (
    PromotionCode           CHAR(10)        NOT NULL,  -- unique code identifying the promotion
    PromotionDescription    VARCHAR(255)    NOT NULL,  -- description of what the promotion offers
    ValidFrom               DATE            NOT NULL,  -- date the promotion starts
    ValidTo                 DATE            NOT NULL,  -- date the promotion ends
    CONSTRAINT pk_promotion PRIMARY KEY (PromotionCode)                        -- PromotionCode uniquely identifies each promotion
);

-- 14. CARD_PROMOTION
CREATE TABLE CARD_PROMOTION (
    CardID          CHAR(10)    NOT NULL,  -- the library card the promotion was applied to
    PromotionCode   CHAR(10)    NOT NULL,  -- the promotion that was applied
    DateApplied     DATE        NOT NULL,  -- the date the promotion was applied to the card
    CONSTRAINT pk_card_promotion        PRIMARY KEY (CardID, PromotionCode),   -- a promotion can only be applied once per card
    CONSTRAINT fk_cardpromo_card        FOREIGN KEY (CardID)
        REFERENCES LIBRARY_CARD(CardID)
        ON DELETE CASCADE,                                                      -- if the card is deleted, remove its promotion records too
    CONSTRAINT fk_cardpromo_promotion   FOREIGN KEY (PromotionCode)
        REFERENCES PROMOTION(PromotionCode)
        ON DELETE CASCADE                                                       -- if the promotion is deleted, remove its card links too
);

-- 15. PUBLISHER
CREATE TABLE PUBLISHER (
    PublisherID         CHAR(10)        NOT NULL,  -- unique ID for the publisher
    PublisherName       VARCHAR(100)    NOT NULL,  -- name of the publishing company
    PublisherAddress    VARCHAR(255),              -- publisher's address (optional)
    PublisherContact    VARCHAR(50),               -- publisher's contact number (optional)
    PublisherEmail      VARCHAR(100),              -- publisher's email address (optional)
    CONSTRAINT pk_publisher PRIMARY KEY (PublisherID)                          -- PublisherID uniquely identifies each publisher
);

-- 16. BOOK
CREATE TABLE BOOK (
    BookID      CHAR(10)        NOT NULL,  -- unique ID for the book
    PublisherID CHAR(10)        NOT NULL,  -- the publisher who published this book
    Title       VARCHAR(255)    NOT NULL,  -- title of the book
    Category    VARCHAR(10)     NOT NULL,  -- category/genre of the book
    ISBN        VARCHAR(20)     NOT NULL,  -- ISBN number of the book
    Edition     VARCHAR(20),               -- edition of the book e.g. 3rd edition (optional)
    CONSTRAINT pk_book              PRIMARY KEY (BookID),                      -- BookID uniquely identifies each book
    CONSTRAINT chk_book_category    CHECK (Category IN ('Cate.1', 'Cate.2', 'Cate.3')),  -- category must be one of the three defined values
    CONSTRAINT fk_book_publisher    FOREIGN KEY (PublisherID)
        REFERENCES PUBLISHER(PublisherID)
        ON DELETE RESTRICT                                                      -- cannot delete a publisher if they still have books in the system
);

-- 17. AUTHOR
CREATE TABLE AUTHOR (
    AuthorID    CHAR(10)    NOT NULL,  -- unique ID for the author
    AuthorFName VARCHAR(50) NOT NULL,  -- author's first name
    AuthorLName VARCHAR(50) NOT NULL,  -- author's last name
    DateOfBirth DATE,                  -- author's date of birth (optional)
    Nationality VARCHAR(50),           -- author's nationality (optional)
    CONSTRAINT pk_author PRIMARY KEY (AuthorID)                                -- AuthorID uniquely identifies each author
);

-- 18. BOOK_AUTHOR
CREATE TABLE BOOK_AUTHOR (
    BookID      CHAR(10)    NOT NULL,  -- the book being linked
    AuthorID    CHAR(10)    NOT NULL,  -- the author being linked
    CONSTRAINT pk_book_author       PRIMARY KEY (BookID, AuthorID),            -- a book-author pair is unique (handles co-authored books)
    CONSTRAINT fk_bookauthor_book   FOREIGN KEY (BookID)
        REFERENCES BOOK(BookID)
        ON DELETE CASCADE,                                                      -- if the book is deleted, remove its author links too
    CONSTRAINT fk_bookauthor_author FOREIGN KEY (AuthorID)
        REFERENCES AUTHOR(AuthorID)
        ON DELETE CASCADE                                                       -- if the author is deleted, remove their book links too
);

-- 19. PAYMENT
CREATE TABLE PAYMENT (
    PaymentID       CHAR(10)        NOT NULL,  -- unique ID for the payment
    PaymentAmount   DECIMAL(10,2)   NOT NULL,  -- amount paid (up to 10 digits, 2 decimal places)
    PaymentMethod   VARCHAR(20)     NOT NULL,  -- how they paid e.g. Cash, Debit Card, Credit Card
    PaymentTime     TIMESTAMP       NOT NULL,  -- exact date and time the payment was made
    CONSTRAINT pk_payment           PRIMARY KEY (PaymentID),                   -- PaymentID uniquely identifies each payment
    CONSTRAINT chk_payment_method   CHECK (PaymentMethod IN ('Cash', 'Debit Card', 'Credit Card'))  -- payment method must be one of the three accepted types
);

-- 20. BORROWING
CREATE TABLE BORROWING (
    BorrowID        CHAR(10)    NOT NULL,  -- unique ID for the borrow transaction
    BookID          CHAR(10)    NOT NULL,  -- the book being borrowed
    PersonID        CHAR(4)     NOT NULL,  -- the person borrowing the book
    ReceptionistID  CHAR(4)     NOT NULL,  -- the receptionist who processed the borrowing
    PaymentID       CHAR(10)    NOT NULL,  -- the payment associated with this borrowing
    IssueDate       DATE        NOT NULL,  -- the date the book was borrowed
    DueDate         DATE        NOT NULL,  -- the date the book must be returned by
    ReturnDate      DATE,                  -- the date the book was actually returned (null if not yet returned)
    CONSTRAINT pk_borrowing                 PRIMARY KEY (BorrowID),            -- BorrowID uniquely identifies each borrow transaction
    CONSTRAINT chk_borrowing_dates          CHECK (DueDate > IssueDate),       -- due date must be after the issue date
    CONSTRAINT fk_borrowing_book            FOREIGN KEY (BookID)
        REFERENCES BOOK(BookID)
        ON DELETE RESTRICT,                                                     -- cannot delete a book that has borrow records
    CONSTRAINT fk_borrowing_person          FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE RESTRICT,                                                     -- cannot delete a person who has borrow records
    CONSTRAINT fk_borrowing_receptionist    FOREIGN KEY (ReceptionistID)
        REFERENCES LIBRARY_RECEPTIONIST(PersonID)
        ON DELETE RESTRICT,                                                     -- cannot delete a receptionist who processed a borrowing
    CONSTRAINT fk_borrowing_payment         FOREIGN KEY (PaymentID)
        REFERENCES PAYMENT(PaymentID)
        ON DELETE RESTRICT                                                      -- cannot delete a payment that is linked to a borrowing
);

-- 21. INQUIRY
CREATE TABLE INQUIRY (
    InquiryID           CHAR(10)    NOT NULL,              -- unique ID for the inquiry
    MemberID            CHAR(4)     NOT NULL,              -- the member who submitted the inquiry
    ReceptionistID      CHAR(4)     NOT NULL,              -- the receptionist who handled the inquiry
    InquiryTime         TIMESTAMP   NOT NULL,              -- exact date and time the inquiry was submitted
    ResolutionStatus    VARCHAR(10) DEFAULT 'Open' NOT NULL,  -- whether the inquiry is Open or Resolved (defaults to Open)
    MemberRating        INT,                               -- rating the member gave the receptionist (1-5, optional)
    CONSTRAINT pk_inquiry               PRIMARY KEY (InquiryID),               -- InquiryID uniquely identifies each inquiry
    CONSTRAINT chk_resolution_status    CHECK (ResolutionStatus IN ('Open', 'Resolved')),  -- status can only be Open or Resolved
    CONSTRAINT chk_member_rating        CHECK (MemberRating BETWEEN 1 AND 5),  -- rating must be between 1 and 5
    CONSTRAINT fk_inquiry_member        FOREIGN KEY (MemberID)
        REFERENCES MEMBER(PersonID)
        ON DELETE RESTRICT,                                                     -- cannot delete a member who has submitted inquiries
    CONSTRAINT fk_inquiry_receptionist  FOREIGN KEY (ReceptionistID)
        REFERENCES LIBRARY_RECEPTIONIST(PersonID)
        ON DELETE RESTRICT                                                      -- cannot delete a receptionist who has handled inquiries
);

-- 22. COMMENT
CREATE TABLE COMMENT (
    CommentID       CHAR(10)    NOT NULL,                          -- unique ID for the comment
    PersonID        CHAR(4)     NOT NULL,                          -- the person who wrote the comment
    BookID          CHAR(10)    NOT NULL,                          -- the book being commented on
    CommentTime     TIMESTAMP   DEFAULT CURRENT_TIMESTAMP NOT NULL, -- date and time the comment was posted (defaults to now)
    RatingScore     INT         NOT NULL,                          -- rating given to the book (1-5)
    CommentContent  TEXT        NOT NULL,                          -- the written content of the comment
    CONSTRAINT pk_comment           PRIMARY KEY (CommentID),                   -- CommentID uniquely identifies each comment
    CONSTRAINT chk_comment_rating   CHECK (Rating BETWEEN 1 AND 5),            -- rating must be between 1 and 5
    CONSTRAINT fk_comment_person    FOREIGN KEY (PersonID)
        REFERENCES PERSON(PersonID)
        ON DELETE RESTRICT,                                                     -- cannot delete a person who has written comments
    CONSTRAINT fk_comment_book      FOREIGN KEY (BookID)
        REFERENCES BOOK(BookID)
        ON DELETE RESTRICT                                                      -- cannot delete a book that has comments
);