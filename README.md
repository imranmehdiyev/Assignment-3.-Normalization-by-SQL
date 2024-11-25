# Assignment-3.-Normalization-by-SQL
-This project demonstrates how to normalize a relational database using PostgreSQL. It automates the process of transforming unnormalized data into 1NF, 2NF, and 3NF through SQL commands.

# Project Features
-Create an unnormalized table from a CSV file.
-Perform first, second, and third normalization steps.
-Automate the entire process using SQL scripts.

# Files Included
-imran_mehdiyev.csv: Raw unnormalized dataset.
-imran_mehdiyev.sql: SQL script to automate table creation, data insertion, and normalization.

# Steps to Run
-Create a PostgreSQL database named assignment3
-Creata  a table named unnormalized and add their headers and their types.
-Open the database using psql from command line
-Use the \COPY command and write this code: \COPY unnormalized (crn, isbn, title, authors, edition, publisher, publisher_address, pages, years, course_name)  
FROM 'C:/Users/USERNAME/Desktop/imran_mehdiyev.csv' DELIMITER '='
-Run the SQL Script

# Output Tables
-courses: Stores course information.
-books: Contains book details.
-authors: A table of unique authors.
-publishers: A table for publisher details.
-course_books: Links books to courses.
-books_authors: Links books to authors.