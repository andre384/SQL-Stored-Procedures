
# SQL Stored Procedure Examples
This file demonstrates Stored Procedures using SQL Server syntax. The SQL queries are practiced on the Coursera Guided Project: "Routines in SQL: Stored Procedures in SQL Server"
https://www.coursera.org/learn/routines-in-sql-stored-procedures-in-sql-server/home/module/1

There are 3 tables (employees, customers, sales) representing sales data from a fictional company. 
Database and tables are created before the SQL queries located in the project file.

### Data Dictionary
Column list for each table.

### employees
employee_id INT, first_name NVARCHAR(50), last_name NVARCHAR(50), email NVARCHAR(50),
hire_date DATE, department NVARCHAR(17), gender NVARCHAR(1), salary INT, region_id INT,
primary key (employee_id)

### customers
Customer_ID NVARCHAR(8) PRIMARY KEY, Customer_Name NVARCHAR(255), Segment NVARCHAR(255),
Age INT, Country NVARCHAR(255), City NVARCHAR(255), State NVARCHAR(255), Postal_Code INT,
Region NVARCHAR(255)

### sales
Order_line INT, Order_ID NVARCHAR(255), Order_Date DATE, Ship_Date DATE, Ship_Mode NVARCHAR(255), 
Customer_ID CHAR(8), Product_ID NVARCHAR(255), Category NVARCHAR(255), Sub_Category NVARCHAR(255),
Sales DECIMAL(10,5), Quantity INT, Discount DECIMAL(4,2), Profit DECIMAL(10,5)



## SQL Store Procedures:


### Procedure: emp_full_details
```sql
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
```


### Procedure: cust_avg_sales

```sql
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
```


### Procedure: cust_salescat_rank
```sql
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
```
