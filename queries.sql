--  5. Write SQL statements for the following queries:

-- TODOS:
-- [1] List the names and membership levels of members who have borrwed at least one book in each of the past 6 months.
SELECT P.FName, P.LName, LC.MembershipLevel
FROM PERSON P
JOIN MEMBER M ON P.PersonID = M.PersonID -- link person to member
JOIN LIBRARY_CARD LC ON M.PersonID = LC.PersonID -- get their membership level
WHERE (
    -- count how many distinct months this person borrowed in
    SELECT COUNT(DISTINCT DATE_FORMAT(B.IssueDate, '%Y-%m'))
    FROM BORROWING B
    WHERE B.PersonID = P.PersonID -- match to outer person
      AND B.IssueDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) -- within last 6 months
      AND B.IssueDate < CURDATE() -- up to today
) = 6; -- must have borrowed in all 6 months

-- [2] Find the top three Gold Members who have borrowed the largest number of distinct books in the past year.
SELECT P.FName, P.LName, COUNT(DISTINCT B.BookID) AS DistinctBooks
FROM PERSON P
JOIN MEMBER M ON P.PersonID = M.PersonID -- link person to member
JOIN LIBRARY_CARD LC ON M.PersonID = LC.PersonID -- get their card
JOIN GOLD G ON LC.CardID = G.CardID -- ensure they are gold members only
JOIN BORROWING B ON P.PersonID = B.PersonID -- get their borrowing records
WHERE B.IssueDate >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH) -- within the past year
GROUP BY P.PersonID, P.FName, P.LName -- group per person
ORDER BY DistinctBooks DESC -- highest borrowers first
LIMIT 3; -- return only top 3

-- [3] List the Book ID and title of books that have been borrowed fewer than 3 times in total, including books that were never borrowed.
SELECT BK.BookID, BK.Title, COUNT(B.BorrowID) AS TotalBorrows
FROM BOOK BK
LEFT JOIN BORROWING B ON BK.BookID = B.BookID -- LEFT JOIN keeps books with 0 borrows
GROUP BY BK.BookID, BK.Title -- one row per book
HAVING COUNT(B.BorrowID) < 3 -- only books borrowed fewer than 3 times
ORDER BY TotalBorrows ASC; -- show least borrowed first

-- [4] For each publisher, return the publisher name and the total number of books borrowed from that publisher in the past year.
SELECT P.PublisherName, COUNT(B.BorrowID) AS TotalBorrowed
FROM PUBLISHER P
JOIN BOOK BK ON P.PublisherID = BK.PublisherID -- link publisher to their books
LEFT JOIN BORROWING B ON BK.BookID = B.BookID -- LEFT JOIN keeps publishers with 0 borrows
    AND B.IssueDate >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH) -- filter borrows to past year
GROUP BY P.PublisherID, P.PublisherName -- one row per publisher
ORDER BY TotalBorrowed DESC; -- most borrowed publisher first

-- [5] Find the author(s) whose books have been borrowed the greatest total number of times across the entire library
SELECT A.AuthorFName, A.AuthorLName, COUNT(B.BorrowID) AS TotalBorrows
FROM AUTHOR A
JOIN BOOK_AUTHOR BA ON A.AuthorID = BA.AuthorID -- link author to their books
JOIN BOOK BK ON BA.BookID = BK.BookID -- get the book details
LEFT JOIN BORROWING B ON BK.BookID = B.BookID -- LEFT JOIN to count all borrows
GROUP BY A.AuthorID, A.AuthorFName, A.AuthorLName -- one row per author
HAVING COUNT(B.BorrowID) = (
    -- find the highest borrow count among all authors
    SELECT MAX(BorrowCount)
    FROM (
        SELECT COUNT(B2.BorrowID) AS BorrowCount -- count borrows per author
        FROM BOOK_AUTHOR BA2
        LEFT JOIN BORROWING B2 ON BA2.BookID = B2.BookID
        GROUP BY BA2.AuthorID -- group by author in subquery
    ) AS AuthorTotals -- alias required by MySQL
)
ORDER BY TotalBorrows DESC; -- highest borrow count first

-- [6] List the names of employees who are also members and who have borrowed at least one book they did not help process or manage.
SELECT DISTINCT P.FName, P.LName
FROM PERSON P
JOIN EMPLOYEE E ON P.PersonID = E.PersonID -- is employee
JOIN MEMBER M ON P.PersonID = M.PersonID -- is also member
JOIN BORROWING B ON P.PersonID = B.PersonID -- borrowed a book
WHERE NOT EXISTS (
    SELECT 1
    FROM BORROWING B2
    WHERE B2.BorrowID = B.BorrowID
      AND (
          B2.ReceptionistID = P.PersonID --was the receptionist
          OR EXISTS (
              SELECT 1 FROM CATALOGING_RECORD CR
              WHERE CR.BookID = B2.BookID
                AND CR.CatalogingManagerID = P.PersonID -- cataloged the book
          )
          OR EXISTS (
              SELECT 1 FROM LIBRARY_RECEPTIONIST LR
              WHERE LR.PersonID = B2.ReceptionistID
                AND LR.TrainerID = P.PersonID -- trained the receptionist
          )
      )
)
ORDER BY P.LName, P.FName;

-- [7] Find the names of receptionists who have resolved at least 5 inquiries and whose average inquiry rating is greater than or equal to 4.5.
SELECT P.FName, P.LName
FROM PERSON P
JOIN LIBRARY_RECEPTIONIST LR ON P.PersonID = LR.PersonID -- is receptionist
JOIN INQUIRY I ON P.PersonID = I.ReceptionistID -- inquiries they handled
WHERE I.ResolutionStatus = 'Resolved' -- only resolved
  AND I.MemberRating IS NOT NULL -- has rating
GROUP BY P.PersonID, P.FName, P.LName
HAVING COUNT(I.InquiryID) >= 5 -- at least 5
   AND AVG(I.MemberRating) >= 4.5 -- avg rating high
ORDER BY AVG(I.MemberRating) DESC;

-- [8] List the names and contact information of Silver Members who have: Borrowed books in at least 10 different months, and Borrowed at least 20 books in total.
SELECT P.FName, P.LName, P.Address, 
       GROUP_CONCAT(DISTINCT PN.PhoneNumber SEPARATOR ', ') AS PhoneNumbers
FROM PERSON P
JOIN MEMBER M ON P.PersonID = M.PersonID -- is member
JOIN LIBRARY_CARD LC ON M.PersonID = LC.PersonID -- has card
JOIN SILVER S ON LC.CardID = S.CardID -- is silver
JOIN BORROWING B ON P.PersonID = B.PersonID -- borrowing records
LEFT JOIN PHONENUMBER PN ON P.PersonID = PN.PersonID -- phone numbers
GROUP BY P.PersonID, P.FName, P.LName, P.Address
HAVING COUNT(DISTINCT DATE_FORMAT(B.IssueDate, '%Y-%m')) >= 10 -- 10+ months
   AND COUNT(B.BorrowID) >= 20 -- 20+ books
ORDER BY COUNT(B.BorrowID) DESC;

-- [9] Find the books that were borrowed at least once in every month of the past year.
SELECT BK.BookID, BK.Title
FROM BOOK BK
WHERE (
    -- Count how many distinct months this book was borrowed in the past year
    SELECT COUNT(DISTINCT DATE_FORMAT(B.IssueDate, '%Y-%m'))
    FROM BORROWING B
    WHERE B.BookID = BK.BookID -- Match the outer book
      AND B.IssueDate >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH) -- Past 12 months only
) = 12 -- Must be all 12 months
ORDER BY BK.Title;

-- [10] For each trainer (Library Supervisor), return the trainer's name and the number of receptionists they have trained who later resolved at least 10 inquiries.
SELECT P.FName, P.LName, 
       COUNT(DISTINCT GoodReceptionists.PersonID) AS ReceptionistsWith10Plus
FROM SUPERVISOR S
JOIN PERSON P ON S.PersonID = P.PersonID -- Get trainer's name from PERSON table
LEFT JOIN (
    -- Find all receptionists who have resolved at least 10 inquiries
    SELECT LR.PersonID, LR.TrainerID
    FROM LIBRARY_RECEPTIONIST LR
    JOIN INQUIRY I ON LR.PersonID = I.ReceptionistID -- Inquiries handled by receptionist
    WHERE I.ResolutionStatus = 'Resolved' -- Only count resolved inquiries
    GROUP BY LR.PersonID, LR.TrainerID -- Group by each receptionist
    HAVING COUNT(I.InquiryID) >= 10 -- Only keep if 10+ resolved
) AS GoodReceptionists ON S.PersonID = GoodReceptionists.TrainerID -- Match trainer ID
GROUP BY S.PersonID, P.FName, P.LName -- Group by trainer to calculate count per trainer
ORDER BY ReceptionistsWith10Plus DESC, P.LName;