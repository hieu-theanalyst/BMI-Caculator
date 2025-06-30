-- ------------------------------------------------------------------------------------------
-- ----------------------------------CREATE DATABASE-----------------------------------------
-- ------------------------------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS library_project;

-- ------------------------------------------------------------------------------------------
-- ----------------------------------CREATE TABLE--------------------------------------------
-- ------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS branch;

CREATE TABLE IF NOT EXISTS 
	branch(
		branch_id VARCHAR(10) PRIMARY KEY,	
        manager_id VARCHAR(10), 
        branch_address VARCHAR(100), 
        contact_no VARCHAR(10)
		);
		
ALTER TABLE branch
ALTER COLUMN contact_no TYPE VARCHAR(20);
  
DROP TABLE IF EXISTS employees;    
CREATE TABLE IF NOT EXISTS 
	employees(
		emp_id VARCHAR(10) PRIMARY KEY,	
        emp_name VARCHAR(25),
        position VARCHAR(15),	
        salary INT,
        branch_id VARCHAR(25) -- FK
        );

ALTER TABLE employees
ALTER COLUMN salary TYPE FLOAT;
  		
  
DROP TABLE IF EXISTS books;    
CREATE TABLE IF NOT EXISTS 
	books(
		isbn VARCHAR(20) PRIMARY KEY,
        book_title VARCHAR(75),
        category VARCHAR(10),
        rental_price FLOAT,
        status VARCHAR(15),
        author VARCHAR(35),	
        publisher VARCHAR(55)
        );

ALTER TABLE books
ALTER COLUMN category TYPE VARCHAR(20);
        
DROP TABLE IF EXISTS members;    
CREATE TABLE IF NOT EXISTS 
	members(        
		member_id VARCHAR(20) PRIMARY KEY,
		member_name VARCHAR(25),
		member_address VARCHAR(75),	
		reg_date DATE
        );

DROP TABLE IF EXISTS issued_status;    
CREATE TABLE IF NOT EXISTS 
	issued_status(        
		issued_id VARCHAR(10) PRIMARY KEY,	
        issued_member_id VARCHAR(10), -- FK
        issued_book_name VARCHAR(75),
        issued_date	DATE,
        issued_book_isbn VARCHAR(25), -- FK
        issued_emp_id VARCHAR (10) -- FK
        );
 
DROP TABLE IF EXISTS return_status;    
CREATE TABLE IF NOT EXISTS 
	return_status(        
		return_id VARCHAR(10) PRIMARY KEY,	
        issued_id VARCHAR(10),	-- FK
        return_book_name VARCHAR(75),	
        return_date	DATE,
        return_book_isbn VARCHAR(20)
        );

-- FOREIGN KEY
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);


SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;



-- ------------------------------------------------------------------------------------------
-- -------------------------INSERT INTO book_issued in last 30 days--------------------------
-- ------------------------------------------------------------------------------------------


INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
	('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
	('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
	('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
	('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');


-- ------------------------------------------------------------------------------------------
-- --------------------------------ADD COLUMN in return_status-------------------------------
-- ------------------------------------------------------------------------------------------


ALTER TABLE return_status
	ADD COLUMN book_quality VARCHAR(15) DEFAULT('Good');
SELECT * FROM issued_status;

UPDATE return_status
	SET book_quality = 'Damaged'
	WHERE issued_id 
    	IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;


/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
-- issued_status == members == books == return_status
-- filter books which is return
-- overdue > 30 


SELECT CURRENT_DATE;

SELECT 
	ist.issued_member_id,
	m.member_name,
	bk.book_title,
	ist.issued_date,
	rs.return_date,
	CURRENT_DATE - ist.issued_date AS overdue
FROM issued_status AS ist
JOIN members AS m
	ON m.member_id = ist.issued_member_id
JOIN books AS bk
	ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs
	ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL
	AND (CURRENT_DATE - ist.issued_date) > 30
ORDER BY ist.issued_member_id
	;


-- 
/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/


SELECT * FROM books;
SELECT * FROM issued_status;

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';

SELECT * FROM return_status
WHERE issued_id = 'IS130';

-- 
INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
VALUES
('RS125', 'IS130', CURRENT_DATE, 'Good');

SELECT * FROM return_status
WHERE issued_id = 'IS130';



/*
-- Store Procedures
CREATE OR REPLACE PROCEDURE add_return_records()
LANGUAGE plpgsql
AS $$
DECLARE 

BEGIN

-- put logic and code here

;

END;
$$ 
*/



-- Store Procedures

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10),p_issued_id VARCHAR(10),p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$
DECLARE 
	v_isbn VARCHAR(50);
	v_book_name VARCHAR(50);
BEGIN

	INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
	VALUES
	(p_return_id,p_issued_id,CURRENT_DATE,p_book_quality);

	SELECT
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,
		v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;

	UPDATE books
	SET status = 'Yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank you for return the book %', v_book_name;

END;
$$ 

CALL add_return_records();


SELECT * 
FROM issued_status
WHERE issued_id = 'IS135'


-- Testing FUNCTION add_return_records whether the particular record has been returned or not. 


issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- Calling FUNCTION
CALL add_return_records('RS138','IS135','Good');



/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/



SELECT * FROM branch;

SELECT * FROM issued_status;

SELECT * FROM employees;

SELECT * FROM books; 

SELECT * FROM return_status;


CREATE TABLE branch_reports
AS
SELECT 
	b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id) AS number_book_issued,
	COUNT(rs.return_id) AS number_of_book_return,
	SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist 
JOIN employees AS e 
	ON e.emp_id =  ist.issued_emp_id
JOIN branch AS b
	ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs
	ON rs.issued_id = ist.issued_id
JOIN books AS bk
	ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id, b.manager_id;

SELECT * FROM branch_reports;



-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.



CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN
	(
	SELECT 
		issued_member_id
	FROM issued_status
	WHERE 
		issued_date > CURRENT_DATE - INTERVAL '2 month'
	);

SELECT * FROM active_members;



-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.


SELECT 
	e.emp_name,
	b.*,
	COUNT(ist.issued_id) AS no_book_issued	
FROM issued_status AS ist
JOIN employees AS e 
	ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
	ON e.branch_id = b.branch_id
GROUP BY 1,2



/*
Task 18: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/


CREATE OR REPLACE PROCEDURE issued_books(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS 
$$

DECLARE
-- all the variable
	v_status VARCHAR(10);

BEGIN
-- all the code
	-- checking if book is available 'yes'
	SELECT 
		status
		INTO v_status
	FROM books
	WHERE isbn = p_issued_book_isbn;

	IF v_status = 'yes' THEN 
		INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		VALUES
		(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_book_isbn;

		RAISE NOTICE 'Book records added succesfully for book isbn : %', p_issued_book_isbn;

	ELSE
		RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
	
	END IF;

END;
$$


-- TESTING 
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issued_books('IS155', 'C108', '978-0-553-29698-2', 'E104');


CALL issued_books('IS156', 'C108', '978-0-375-41398-8', 'E104');


SELECT * FROM books
WHERE isbn = '978-0-553-29698-2';

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';

