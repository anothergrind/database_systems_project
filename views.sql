-- JUNGLE LIBRARY DATABASE
-- PHASE III: Create Views (Q4)

-- 1. TopGoldMember
CREATE VIEW TopGoldMember AS
SELECT P.FName, P.LName, LC.IssueDate
FROM PERSON P
JOIN LIBRARY_CARD LC ON P.PersonID = LC.PersonID
JOIN GOLD G          ON LC.CardID = G.CardID
JOIN BORROWING B     ON P.PersonID = B.PersonID
WHERE B.IssueDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY P.PersonID, P.FName, P.LName, LC.IssueDate
HAVING COUNT(B.BorrowID) > 6;

-- 2. PopularBooks
CREATE VIEW PopularBooks AS
SELECT Bo.BookID, Bo.PublisherID, Bo.Title, Bo.Category, Bo.ISBN, Bo.Edition, COUNT(Bw.BorrowID) AS BorrowCount
FROM BOOK Bo
JOIN BORROWING Bw ON Bw.BookID = Bo.BookID
WHERE Bw.IssueDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY Bo.BookID, Bo.PublisherID, Bo.Title, Bo.Category, Bo.ISBN, Bo.Edition
ORDER BY BorrowCount DESC
LIMIT 10;

-- 3. BestRatingPublisher
CREATE VIEW BestRatingPublisher AS
SELECT P.PublisherName
FROM PUBLISHER P
JOIN BOOK B    ON B.PublisherID = P.PublisherID
JOIN COMMENT C ON C.BookID = B.BookID
GROUP BY P.PublisherID, P.PublisherName
HAVING COUNT(DISTINCT B.BookID) > 3 AND AVG(C.RatingScore) >= 4.5;

-- 4. PotentialGoldMember
CREATE VIEW PotentialGoldMember AS
SELECT P.FName, P.LName, P.PersonID,
       (SELECT PN.PhoneNumber FROM PHONENUMBER PN
            WHERE PN.PersonID = P.PersonID LIMIT 1) AS PhoneNumber
FROM PERSON P
JOIN LIBRARY_CARD LC ON P.PersonID = LC.PersonID
JOIN SILVER S        ON LC.CardID = S.CardID
JOIN BORROWING B     ON P.PersonID = B.PersonID
WHERE B.IssueDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY P.PersonID, P.FName, P.LName
HAVING COUNT(B.BorrowID) > 2;

-- 5. ActiveReceptionist
CREATE VIEW ActiveReceptionist AS
SELECT P.FName, P.LName
FROM PERSON P
JOIN LIBRARY_RECEPTIONIST LR ON P.PersonID = LR.PersonID
JOIN INQUIRY I               ON LR.PersonID = I.ReceptionistID
WHERE I.ResolutionStatus = 'Resolved' AND I.InquiryTime >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
GROUP BY P.PersonID, P.FName, P.LName
HAVING COUNT(I.InquiryID) > 10;
