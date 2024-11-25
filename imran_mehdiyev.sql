-- Step 1: Create the unnormalized table with appropriate column data types
CREATE TABLE unnormalized (
    CRN INTEGER,               -- Course Registration Number (Primary Key candidate in 1NF)
    ISBN INTEGER,              -- International Standard Book Number (Primary Key candidate in 1NF)
    Title TEXT,                -- Book title
    Authors TEXT,              -- Authors listed as a comma-separated string
    Edition INTEGER,           -- Book edition
    Publisher TEXT,            -- Publisher name
    Publisher_address TEXT,    -- Publisher address
    Pages INTEGER,             -- Number of pages in the book
    Years INTEGER,             -- Year of publication
    Course_name TEXT           -- Course name related to the book
);

-- Step 2: Connect to the PostgreSQL database from the command line
-- Command:
--psql -U postgres -d assignment3

-- Step 3: From cmd load data into the unnormalized table from a CSV file
-- Ensure the file uses '=' as the delimiter
--\COPY unnormalized (crn, isbn, title, authors, edition, publisher, publisher_address, pages, years, course_name) FROM 'C:/Users/LENOVO/Desktop/imran_mehdiyev.csv' DELIMITER '=';

-- Step 4: First Normal Form (1NF)
CREATE TABLE first_normal AS
SELECT crn, isbn, title, 
       UNNEST(STRING_TO_ARRAY(authors, ',')) AS author_name, -- Split authors into separate rows
       edition, publisher, publisher_address, pages, years, course_name
FROM unnormalized;

-- Remove unnecessary spaces from author names
UPDATE first_normal
SET author_name = TRIM(author_name);

-- Step 5: Second Normal Form (2NF)
-- Eliminate partial dependencies by creating separate tables for courses, books, and their relationships

-- Create the Courses table with CRN as the primary key
CREATE TABLE courses (
    crn INT PRIMARY KEY,           -- Course Registration Number
    course_name VARCHAR(255)       -- Course Name
);

-- Populate the Courses table with unique course data
INSERT INTO courses (crn, course_name)
SELECT DISTINCT crn, course_name
FROM first_normal;

-- Create the Books table with ISBN as the primary key
CREATE TABLE books (
    isbn VARCHAR(20) PRIMARY KEY,  -- International Standard Book Number
    title VARCHAR(255),            -- Book title
    edition VARCHAR(50),           -- Book edition
    publisher VARCHAR(255),        -- Publisher name
    publisher_address VARCHAR(255),-- Publisher address
    pages INT,                     -- Number of pages
    years INT                      -- Year of publication
);

-- Populate the Books table with unique book data
INSERT INTO books (isbn, title, edition, publisher, publisher_address, pages, years)
SELECT DISTINCT isbn, title, edition, publisher, publisher_address, pages, years
FROM first_normal;

-- Create a junction table to associate courses with books (many-to-many relationship)
CREATE TABLE course_books (
    crn INT,                       -- Foreign key to Courses
    isbn VARCHAR(20),              -- Foreign key to Books
    PRIMARY KEY (crn, isbn),       -- Composite primary key
    FOREIGN KEY (crn) REFERENCES courses(crn),
    FOREIGN KEY (isbn) REFERENCES books(isbn)
);

-- Populate the Course_Books table
INSERT INTO course_books (crn, isbn)
SELECT DISTINCT crn, isbn
FROM first_normal;

-- Create the Authors table with Author ID as the primary key
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,  -- Unique ID for each author
    author_name VARCHAR(255) NOT NULL -- Author name
);

-- Populate the Authors table with unique author names
INSERT INTO authors (author_name)
SELECT DISTINCT author_name
FROM first_normal;

-- Create a junction table to associate books with authors (many-to-many relationship)
CREATE TABLE books_authors (
    isbn VARCHAR(20),              -- Foreign key to Books
    author_id INT,                 -- Foreign key to Authors
    PRIMARY KEY (isbn, author_id), -- Composite primary key
    FOREIGN KEY (isbn) REFERENCES books(isbn),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

-- Populate the Books_Authors table
INSERT INTO books_authors (isbn, author_id)
SELECT DISTINCT 
    f.isbn,                        -- ISBN from first_normal
    a.author_id                    -- Author ID from Authors table
FROM first_normal f
JOIN authors a ON f.author_name = a.author_name; -- Match authors by name

-- Step 6: Third Normal Form (3NF)
-- Remove transitive dependencies by creating a separate table for publishers

-- Create the Publishers table
CREATE TABLE publishers (
    publisher_id SERIAL PRIMARY KEY, -- Unique ID for each publisher
    publisher_name VARCHAR(255) NOT NULL, -- Publisher name
    publisher_address VARCHAR(255) NOT NULL -- Publisher address
);

-- Populate the Publishers table with unique publisher data
INSERT INTO publishers (publisher_name, publisher_address)
SELECT DISTINCT publisher, publisher_address
FROM books;

-- Add a foreign key column for Publisher ID in the Books table
ALTER TABLE books
ADD COLUMN publisher_id INT REFERENCES publishers(publisher_id);

-- Update the Books table to associate each book with its publisher
UPDATE books b
SET publisher_id = p.publisher_id
FROM publishers p
WHERE b.publisher = p.publisher_name AND b.publisher_address = p.publisher_address;

-- Drop the Publisher and Publisher_Address columns from the Books table (no longer needed)
ALTER TABLE books
DROP COLUMN publisher,
DROP COLUMN publisher_address;
