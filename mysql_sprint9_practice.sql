use modelcarsdb;
select * from customers;
-- --------------------- TASK1-----------------------------------
-- TASK1_1 : TOP 10 CUSTOMERS BY CREDIT LIMITED
select customerName,creditLimit from customers
order by creditLimit desc
limit 10;

-- TASK1_2 Find average credit limit of a customer for country wise
SELECT country, AVG(creditLimit)  AS avgCreditLimit 
FROM customers
GROUP BY country
ORDER BY avgCreditLimit;

-- TASK1_3 Find the number of customers in each state.
Select state,count(*) as count_for_each_state from customers
group by state;

-- TASK1_4 FIND CUSTOMERS WHO HAVEN'T PLACED order 
select customerName,customerNumber from customers left join orders using(customerNumber)
where orderNumber is null;
-- or
select customerName from customers
where customerNumber not in(select customerNumber from orders);

-- TASK1_5 Calculate total sales for each customer.
SELECT customerNumber, customerName,SUM(quantityOrdered * priceEach) AS totalSales
FROM customers 
JOIN orders using(customerNumber)
JOIN orderdetails using(orderNumber)
GROUP BY customerNumber, customerName
ORDER BY customerNumber;


-- TASK1_6  List customers with their assigned sales representatives.
SELECT customerNumber,customerName,salesRepEmployeeNumber  FROM customers join employees on salesrepemployeenumber = employeenumber; 
select salesRepEmployeeNumber from customers;
select employeenumber from employees;
-- TASK1_7Retrieve customer information with their most recent payment details.
select * from payments;
select customerName,customerNumber,date(paymentDate) from customers left join payments using(customerNumber)
order by 3 desc;


-- TASK1_8 Identify the customers who have exceeded their credit limit.
SELECT customerNumber, customerName,creditLimit,amount,( amount-creditLimit) as excess
FROM customers 
join payments using(customerNumber)
order by customerNumber;



-- TASK1_9 Find the names of all customers who have placed an order for a product from a specific product line.
SELECT DISTINCT c.customerName
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
WHERE p.productLine = 'TRAINS'; 

-- TASK1_10 Find the names of all customers who have placed an order for the most expensive product.
SELECT c.customerNumber, c.customerName,p.productName,p.productline,p.MSRP
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
WHERE p.MSRP = (SELECT MAX(MSRP)FROM products)
ORDER BY c.customerName;



   -- ------------TASK2------------------------
SELECT * FROM EMPLOYEES;
-- TASK2_1 Count the number of employees working in each office.
SELECT officeCode,COUNT(*) AS NO_OF_EMPLOYYEES FROM EMPLOYEES
group by officeCode;

-- TASK2_2 Identify the offices with less than a certain number of employees.
SELECT officeCode , count(*) as no_of_employees FROM employees
group by officeCode
having count(*) <5;

-- TASK2_3 List offices along with their assigned territories.
select * from offices
order by officeCode,territory;

-- TASK2_4 Find the offices that have no employees assigned to them.
select officeCode from offices 
where officeCode in(select officeCode from employees where employeeNumber is null); 

-- or 
select * from offices
left join employees using (officeCode)
where employeeNumber is null;

-- TASK2_5 Retrieve the most profitable office based on total sales.
SELECT o.orderNumber,SUM(od.quantityOrdered * od.priceEach) AS totalSales,SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) AS totalProfit
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
GROUP BY o.orderNumber
ORDER BY totalSales DESC, totalProfit DESC
limit 1;


-- TASK2_6  Find the office with the highest number of employees.
SELECT officeCode,city,count(employeeNumber) as high_no_of_employees FROM employees join offices using(officeCode)
group by officeCode
order by 2 desc
limit 1;
USE modelcarsdb;
-- TASK2_7 Find the average credit limit for customers in each office
SELECT o.officeCode,avg(creditLimit) as average from customers c
join employees e on e.employeeNumber=c.salesRepEmployeeNumber
join offices o on o.officeCode=e.officeCode
group by o.officeCode ;

-- TASK2_8 Find the number of offices in each country
select country,count(*) as no_of_offices from offices
group by country;


-- --------------------------------- TASK3-----------

-- Task 3: Product Data Analysis
-- TASK3_1. Count the number of products in each product line.

select productLine,count(*) from products
group by productLine;

-- TASK3_2 .Find the product line with the highest average product price.
select productline,avg(buyprice) as averageprice from products
group by productline
order by averageprice desc
limit 1;

-- TASK3_3 Find all products with a price above or below a certain amount (MSRP should be between 50 and 100)
SELECT * FROM products
WHERE MSRP BETWEEN 50 AND 100;

-- TASK3_4 Find the total sales amount for each product line.
select p.productLine,sum(od.quantityOrdered * od.priceEach) AS totalSales from products p
join orderdetails od using(productCode)
group by 1;

-- TASK3_5 Identify products with low inventory levels (less than a specific threshold value of 10 for quantityInStock).
select *from products
where quantityinstock < 10;

-- TASK3_6 Retrieve the most expensive product based on MSRP.
SELECT productLine,MSRP,productName from products
order by 2 desc
limit 1;

-- TASK3_7  Calculate total sales for each product.
SELECT p.productCode,p.productName,p.productLine,SUM(od.quantityOrdered * od.priceEach) AS totalSales
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName,p.productLine
ORDER BY totalSales DESC;

-- TASK3_8 Identify the top selling products based on total quantity ordered using a stored procedure. The procedure should accept an input parameter to specify
DELIMITER //
CREATE PROCEDURE GetTopSellingProducts(IN topN INT)
BEGIN
    SELECT 
        p.productCode,
        p.productName,
        SUM(od.quantityOrdered) AS totalQuantityOrdered
    FROM 
        products p
    JOIN 
        orderdetails od ON p.productCode = od.productCode
    GROUP BY 
        p.productCode, p.productName
    ORDER BY 
        totalQuantityOrdered DESC
    LIMIT topN;
END //

DELIMITER ;
CALL GetTopSellingProducts(4);

-- TASK3_9 Retrieve products with low inventory levels (less than a threshold value of 10 for quantityInStock) within specific product lines ('Classic Cars', 'Motorcycles').
SELECT productName, productLine, quantityInStock
FROM products
WHERE productLine IN ('classic cars', 'motorcycles')
  AND quantityInStock < 10;

--  TASK3_10 Find the names of all products that have been ordered by more than 10 customers.
SELECT p.productName,p.productLine,od.quantityOrdered from products p
join orderdetails od using(productCode)
join orders o using(orderNumber)
join customers c using(customerNumber)
where od.quantityOrdered >10;

-- TASK3_11  Find the names of all products that have been ordered more than the average number of orders for 
-- their product line
USE modelcarsdb;
SELECT p.productLine, p.productName,od.quantityOrdered, AVG(od.quantityOrdered) AS total_quantityOrdered
FROM products p
JOIN orderdetails od USING(productCode)
JOIN orders o USING(orderNumber)
GROUP BY p.productLine, p.productName,od.quantityOrdered
HAVING (od.quantityOrdered) > (SELECT AVG(total_quantityOrdered)FROM (SELECT p.productLine,AVG(od.quantityOrdered) AS total_quantityOrdered
        FROM products p
        JOIN orderdetails od USING(productCode)
        JOIN orders o USING(orderNumber)
        GROUP BY p.productLine, p.productName
    ) subquery
    WHERE subquery.productLine = p.productLine
);











