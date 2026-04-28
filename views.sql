-- JUNGLE LIBRARY DATABASE
-- PHASE III: Create Views (Q4)

-- 1. TopGoldMember
CREATE VIEW TopGoldMember AS
SELECT P.FName,      -- first name of the member
       P.LName,      -- last name of the member
       LC.IssueDate  -- date enrolled in their membership
FROM PERSON P
JOIN LIBRARY_CARD LC ON P.PersonID = LC.PersonID  -- connect person to their library card
JOIN GOLD G          ON LC.CardID = G.CardID       -- confirm the card is Gold tier
JOIN BORROWING B     ON P.PersonID = B.PersonID    -- connect person to their borrow records
WHERE B.IssueDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR) -- only borrows from the past year
GROUP BY P.PersonID, P.FName, P.LName, LC.IssueDate       -- group results per person
HAVING COUNT(B.BorrowID) > 6;                             -- only include members who borrowed more than 6 books

-- 2. PopularBooks
CREATE VIEW PopularBooks AS
SELECT Bo.BookID,                        -- unique ID of the book
       Bo.PublisherID,                   -- publisher of the book
       Bo.Title,                         -- title of book
       Bo.Category,                      -- genre of the book
       Bo.ISBN,                          -- ISBN number
       Bo.Edition,                       -- edition of the book (i.e. 10th edition of x textbook)
       COUNT(Bw.BorrowID) AS BorrowCount -- total number of times the book was borrowed
FROM BOOK Bo
JOIN BORROWING Bw ON Bw.BookID = Bo.BookID                 -- connect each book to its borrow records
WHERE Bw.IssueDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR) -- only borrows from the past year
GROUP BY Bo.BookID, Bo.PublisherID, Bo.Title, Bo.Category, Bo.ISBN, Bo.Edition -- group results per book
ORDER BY BorrowCount DESC  -- sort by most borrowed first
LIMIT 10;                  -- return only the top 10

-- 3. BestRatingPublisher
CREATE VIEW BestRatingPublisher AS
SELECT P.PublisherName  -- Name of the publisher
FROM PUBLISHER P
JOIN BOOK B    ON B.PublisherID = P.PublisherID  -- connect publisher to their books
JOIN COMMENT C ON C.BookID = B.BookID            -- connect each book to its ratings
GROUP BY P.PublisherID, P.PublisherName          -- group results per publisher
HAVING COUNT(DISTINCT B.BookID) > 3             -- publisher must have more than 3 rated books
   AND AVG(C.RatingScore) >= 4.5;              -- average rating across all their books must be at least 4.5

-- 4. PotentialGoldMember
CREATE VIEW PotentialGoldMember AS
SELECT P.FName,      -- first name of the silver member
       P.LName,      -- last name of the silver member
       P.PersonID,   -- ID of the silver member
       (SELECT PN.PhoneNumber FROM PHONENUMBER PN
            WHERE PN.PersonID = P.PersonID LIMIT 1) AS PhoneNumber  -- get one phone number for the member
FROM PERSON P
JOIN LIBRARY_CARD LC ON P.PersonID = LC.PersonID  -- connect person to their library card
JOIN SILVER S        ON LC.CardID = S.CardID       -- confirm the card is ranked silver
JOIN BORROWING B     ON P.PersonID = B.PersonID    -- connect person to their borrow records
WHERE B.IssueDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR) -- only borrows from the past year
GROUP BY P.PersonID, P.FName, P.LName              -- group the results per person
HAVING COUNT(B.BorrowID) > 2;                     -- only include members who borrowed more than 2 books

-- 5. ActiveReceptionist
CREATE VIEW ActiveReceptionist AS
SELECT P.FName,  -- first name of the receptionist
       P.LName   -- last name of the receptionist
FROM PERSON P
JOIN LIBRARY_RECEPTIONIST LR ON P.PersonID = LR.PersonID  -- confirm the person is a receptionist
JOIN INQUIRY I               ON LR.PersonID = I.ReceptionistID  -- connect receptionist to inquiries they handled
WHERE I.ResolutionStatus = 'Resolved'                              -- onyl count resolved inquiries
  AND I.InquiryTime >= DATE_SUB(NOW(), INTERVAL 1 MONTH)          -- only inquiries from the past month
GROUP BY P.PersonID, P.FName, P.LName  -- group results per receptionist
HAVING COUNT(I.InquiryID) > 10;       -- only include receptionists who resolved more than 10 inquiries
