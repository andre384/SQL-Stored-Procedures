

-- Examples of Stored Procedures using SQL server
-- SQL queries practiced from the Coursera Guided Project "Routines in SQL: Stored Procedures in SQL Server"
-- https://www.coursera.org/learn/routines-in-sql-stored-procedures-in-sql-server/home/module/1
-- Database and tables are created before using these SQL statements


-- Set database to use
USE projectdb;

-- Create synonyms for the tables
CREATE SYNONYM regions FOR dim.regions;
CREATE SYNONYM departments FOR dim.departments;
CREATE SYNONYM customers FOR dim.customers;
CREATE SYNONYM employees FOR  dim.employees;
CREATE SYNONYM sales FOR fact.sales;

-- Check that synonyms retrieve all the data in the tables
SELECT * FROM customers;
SELECT * FROM departments;
SELECT * FROM employees;
SELECT * FROM regions;
SELECT * FROM sales;


----------------------------------------
-- Stored procedure to retrieve 
-- the first 500 employees

-- Drop procedure if it exists
DROP Procedure IF EXISTS FirstEmployees; 

--Create procedure
Create Procedure FirstEmployees
As
Begin
Select Top 500 *
From employees;
End;

-- Call stored procedure
Exec FirstEmployees;



--------------------------------
-- Stored procedure with an input parameter that returns the 
-- details of an employee given the employee_id

-- Drop procedure if it exists
DROP Procedure IF EXISTS Employee_Details;

-- Create procedure
Create Procedure Employee_Details
@employee_id Int
As
Begin
Select employee_id, first_name, last_name, hire_date, salary
From employees
Where employee_id=@employee_id;
End;

-- Call procedure for employee_id 100
Exec Employee_Details @employee_id=100;


-------------------------
-- Stored Procedure emp_full_details that returns the details of an
-- employee including the region and country given the employee_id

-- Drop procedure if it exists
DROP PROCEDURE IF EXISTS emp_full_details;

-- Create procedure
Create Procedure emp_full_details
@employee_id INT
As
Begin
Select e.employee_id, e.first_name, e.last_name, e.hire_date, e.salary, r.region, r.country
From employees e Join regions r On e.region_id=r.region_id
Where e.employee_id=@employee_id;
End;

-- Call procedure for employee_id 100
Exec emp_full_details @employee_id=100;


-----------------------------
-- Stored procedure named total_profit_year to retrieve the total profit 
-- made from each product category for each year. 

-- Drop procedure if it exists
DROP PROCEDURE IF EXISTS total_profit_year;

-- Create stored procedure
Create Procedure total_profit_year
@Year Int
As
Begin
Select category, SUM(profit) AS total_profit
From sales
Where Year(Order_Date)=@Year
GROUP BY category
ORDER BY total_profit DESC;
End;

-- Call procedure for the year 2015
Exec total_profit_year @Year=2015;
    

-----------------------------
-- Stored procedure orders_year that returns details of sales
-- and customers given the year and product category

-- Drop procedure if it exists
DROP PROCEDURE IF EXISTS orders_year;

-- Create procedure
Create Procedure orders_year
@year Int, @category nvarchar(30)
As
Begin
Select s.order_date, s. customer_id, s.catergory, s.sub_category, s.quantity, c.customer_name, c.state, c.segment
From sales s Join customers c ON s.customer_id=c.customer_id
Where Year(s.Order_Date)=@year And s.category=@category;
End;


-- Call procedure for the year 2015 and Furniture category
Exec orders_year @year=2015, @category='Furniture';


-----------------------------------
-- Stored procedure cust_avg_sales that returns the average amount
-- in sales from a customer given the customer_id

-- Drop the procedure if it exists
DROP PROCEDURE IF EXISTS cust_avg_sales;

-- Create procedure
Create Procedure cust_avg_sales
@customer_id varchar(30),
@avg_sales Decimal(10,2) Output
As
Begin
SELECT @avg_sales=AVG(sales)
FROM sales	
WHERE customer_id = @customer_id;
End;

-- Call stored procedure for customer 'CG-12520'
Declare @out_avg_sales Decimal(10,2)
Exec cust_avg_sales @customer_id='CG-12520', @avg_sales=@out_avg_sales Output;
Select @out_avg_sales As AvgCustomerSales


--------------------------------
-- Stored procedure cust_name_avg_sales that returns the customer name and
-- the average amount in sales from a customer given the customer_id

-- Drop the procedure if it exists
DROP procedure IF EXISTS cust_name_avg_sales;

-- Create procedure
CREATE PROCEDURE cust_name_avg_sales
 @p_cust_id VARCHAR(10),
 @p_name VARCHAR(100) OUTPUT,
 @p_avg_sales DECIMAL(12, 2) OUTPUT
AS 
BEGIN
	SELECT @p_name = c.customer_name,
	@p_avg_sales = AVG(s.sales)
	FROM sales s
	JOIN customers c
	ON s.customer_id = c.customer_id
	WHERE s.customer_id = @p_cust_id
	GROUP BY c.customer_name;
END;

-- Call stored procedure for customer 'SO-20335'
DECLARE @v_name VARCHAR(100);
DECLARE @v_avg_sales DECIMAL(12,2);
EXEC cust_name_avg_sales @p_cust_id = 'SO-20335', @p_name = @v_name OUTPUT, @p_avg_sales = @v_avg_sales OUTPUT;
SELECT @v_name AS CustomerName, @v_avg_sales AS AverageSalesForCustomer;



-----------------------------
-- Stored Procedure top_customers_year to retrieve the top 5 customers 
-- from the sales table based on total sales for a specific year.

-- Drop the procedure if it exists
DROP procedure IF EXISTS top_customers_year;

-- Create Procedure
Create Procedure top_customers_year
@Year Int
As
Begin
Select Top 5 Customer_id, sum(Sales) As Total_sales
From Sales
Where Year(order_date)=@Year
Group By Customer_id 
Order by sum(Sales) Desc;
End;

-- Call stored procedure for the year 2015
Exec top_customers_year @Year=2015;

-------------------------
-- Stored procedure customer_sales_rank that returns the customer_id, name, segment, state 
-- of the top 5 customers based on the total amount made in sales in a specified year

-- Drop the procedure if it exists
DROP procedure IF EXISTS customer_sales_rank;

-- Create procedure
Create Procedure customer_sales_rank
@Year Int
As
Begin
Select Top 5 c.customer_id, c.Customer_name, c.Segment, c.State, Sum(s.Sales) As Total_Sales
From Customers c Join Sales s ON c.customer_id=s.customer_id
Where Year(s.order_date)=@Year
Group By c.customer_id, c.Customer_name, c.Segment, c.State
Order By Sum(s.sales) Desc
End;

-- Call the procedure for the year 2015
Exec customer_sales_rank @Year=2015;

----------------------------------
-- Stored procedure cust_salescat_rank to return the details of the top 5 customers 
-- as before based on the total amount made in sales in a specified year and product category.

-- Drop the procedure if it exists
DROP procedure IF EXISTS cust_salescat_rank;

-- Create procedure
Create Procedure cust_salescat_rank
@Year Int, @Category varchar(20)
As
Begin
Select Top 5 c.customer_id, c.Customer_name, c.Segment, c.State, Sum(s.Sales) As Total_Sales
From Customers c Join Sales s ON c.customer_id=s.customer_id
Where Year(order_date)=@Year And s.category=@Category
Group By c.customer_id, c.Customer_name, c.Segment, c.State
Order By Sum(s.sales) Desc 
End;

-- Call procedure for the year 2015 and the Technology category
Exec cust_salescat_rank @Year=2015, @Category='Technology';