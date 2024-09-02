USE Bike_sales;

SELECT * FROM bike_sales.sales;

#Total revenue by Product category
SELECT 
    Product_Category,
    SUM(Revenue) AS Total_Revenue
FROM 
    sales
GROUP BY 
    Product_Category
ORDER BY 
    Total_Revenue DESC;

#Average Profit by Country
SELECT 
    Country,
    AVG(Profit) AS Average_Profit
FROM 
    sales
GROUP BY 
    Country
ORDER BY 
    Average_Profit DESC;
    
#Top 5 Highest Sales orders
SELECT 
    Sales_order,
    Date,
    Country,
    Revenue
FROM 
    sales
ORDER BY 
    Revenue DESC
LIMIT 5;

#Total Sales and Profit by Customer Age Group
SELECT 
    CASE 
        WHEN Customer_Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Customer_Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Customer_Age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '46+'
    END AS Age_Group,
    SUM(Order_Quantity) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM 
    sales
GROUP BY 
    Age_Group
ORDER BY 
    Age_Group;

#Revenue Trends Over Time
SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS Month,
    SUM(Revenue) AS Total_Revenue
FROM 
    sales
GROUP BY 
    Month
ORDER BY 
    Month;
    
# Top Countries by Total Revenue
    SELECT 
    Country,
    SUM(Revenue) AS Total_Revenue
FROM 
    sales
GROUP BY 
    Country
ORDER BY 
    Total_Revenue DESC;
    
    # Profitability by State
    SELECT 
    States,
    SUM(Profit) AS Total_Profit
FROM 
    sales
GROUP BY 
    States
ORDER BY 
    Total_Profit DESC;

#Customer Gender Distribution
SELECT 
    Customer_Gender,
    COUNT(*) AS Number_of_Sales
FROM 
    sales
GROUP BY 
    Customer_Gender;

#Average Order Quantity by Product Category
SELECT 
    Product_Category,
    AVG(Order_Quantity) AS Average_Order_Quantity
FROM 
    sales
GROUP BY 
    Product_Category
ORDER BY 
    Average_Order_Quantity DESC;
    
#Revenue per Sale
SELECT 
    AVG(Revenue) AS Average_Revenue_Per_Sale
FROM 
    sales;
