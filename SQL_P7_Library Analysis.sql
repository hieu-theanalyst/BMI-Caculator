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
-- -------------------------------------PROJECT TASK-----------------------------------------
-- ------------------------------------------------------------------------------------------


-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

SELECT * FROM books;
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;



-- Task 2: Update an Existing Member's Address

SELECT * FROM members;
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;



-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status;
DELETE FROM issued_status
WHERE issued_id = 'IS121';
SELECT * FROM issued_status;



-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';



-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
	issued_emp_id,
	COUNT(issued_id) AS total_book_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1; 



-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE book_cnts
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) AS no_issued
FROM books AS b
JOIN
	issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, book_title;

SELECT * FROM book_cnts;



-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Fantasy'



-- Task 8: Find Total Rental Income by Category:

SELECT
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM books AS b
JOIN
issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1



-- Task 9: List Members Who Registered in the Last 180 Days:
-- I will insert more data:

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C123', 'Hieu', '999 Main St', '2024-06-01'),
('C124', 'Hoang', '331 Main St', '2024-05-01');

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'

	

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT 
    e1.*,
    b.manager_id,
    e2.emp_name AS manager
FROM employees AS e1
JOIN  
branch AS b
ON b.branch_id = e1.branch_id
JOIN
employees AS e2
ON b.manager_id = e2.emp_id;



-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold ($6):

CREATE TABLE books_price_greater_than_six
AS    
SELECT * FROM books
WHERE rental_price > 6;

SELECT * FROM 
books_price_greater_than_six;



-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
    DISTINCT ist.issued_book_name
FROM issued_status AS ist
LEFT JOIN
return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL

    
SELECT * FROM return_status

-- ------------------------------------------------------------------------------------------
-- -------------------------------------END PROJECT------------------------------------------
-- ------------------------------------------------------------------------------------------