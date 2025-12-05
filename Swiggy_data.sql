create database Swiggy_Database

select * from [dbo].[swiggy_data]

--Data Validation & Claeaning

--Null Check

SELECT

SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,

SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,

SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,

SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant,

SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,

SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,

SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish,

SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price,

SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,

SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_rating_count

FROM swiggy_data;



-- Blank or Empty Strings
SELECT *
FROM swiggy_data
WHERE
    State = '' 
    OR City = '' 
    OR Restaurant_Name = '' 
    OR Location = '' 
    OR Category = '' 
    OR Dish_Name = '';


-- Duplicate Detection
SELECT
    State,
    City,
    order_date,
    restaurant_name,
    location,
    category,
    dish_name,
    price_INR,
    rating,
    rating_count,
    COUNT(*) AS CNT
FROM swiggy_data
GROUP BY
    State,
    City,
    order_date,
    restaurant_name,
    location,
    category,
    dish_name,
    price_INR,
    rating,
    rating_count
HAVING COUNT(*) > 1;


-- CREATING SCHEMA
-- DIMENSION TABLES
-- DATE TABLE
CREATE TABLE dim_date (
    date_id INT IDENTITY(1,1) PRIMARY KEY,
    Full_Date DATE,
    Year INT,
    Month INT,
    Month_Name VARCHAR(20),
    Quarter INT,
    Day INT,
    Week INT
);

SELECT * FROM dim_date;

-- dim_location
CREATE TABLE dim_location (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    State VARCHAR(100),
    City VARCHAR(100),
    Location VARCHAR(200)
);
SELECT * FROM dim_location;

-- dim_restaurant
CREATE TABLE dim_restaurant (
    restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
    Restaurant_Name VARCHAR(200)
);

-- dim_category
CREATE TABLE dim_category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    Category VARCHAR(200)
);

-- dim_dish
CREATE TABLE dim_dish (
    dish_id INT IDENTITY(1,1) PRIMARY KEY,
    Dish_Name VARCHAR(200)
);

-- FACT TABLE
CREATE TABLE fact_swiggy_orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,

    date_id INT,
    Price_INR DECIMAL(10,2),
    Rating DECIMAL(4,2),
    Rating_Count INT,

    location_id INT,
    restaurant_id INT,
    category_id INT,
    dish_id INT,

    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
    FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);


-- INSERT DATA IN TABLES
-- dim_date
INSERT INTO dim_date (Full_Date, Year, Month, Month_Name, Quarter, Day, Week)
SELECT DISTINCT
    Order_Date,
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATENAME(MONTH, Order_Date),
    DATEPART(QUARTER, Order_Date),
    DAY(Order_Date),
    DATEPART(WEEK, Order_Date)
FROM swiggy_data
WHERE Order_Date IS NOT NULL;

select * from dim_date

-- dim_location
INSERT INTO dim_location (State, City, Location)
SELECT DISTINCT
    State,
    City,
    Location
FROM swiggy_data;

-- dim_restaurant
INSERT INTO dim_restaurant (Restaurant_Name)
SELECT DISTINCT
    Restaurant_Name
FROM swiggy_data;

-- dim_category
INSERT INTO dim_category (Category)
SELECT DISTINCT
    Category
FROM swiggy_data;

-- dim_dish
INSERT INTO dim_dish (Dish_Name)
SELECT DISTINCT
    Dish_Name
FROM swiggy_data;

-- INSERT INTO FACT TABLE
INSERT INTO fact_swiggy_orders
(
    date_id,
    Price_INR,
    Rating,
    Rating_Count,
    location_id,
    restaurant_id,
    category_id,
    dish_id
)
SELECT
    dd.date_id,
    s.Price_INR,
    s.Rating,
    s.Rating_Count,
    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
FROM swiggy_data s
JOIN dim_date dd
    ON dd.Full_Date = s.Order_Date
JOIN dim_location dl
    ON dl.State = s.State
    AND dl.City = s.City
    AND dl.Location = s.Location
JOIN dim_restaurant dr
    ON dr.Restaurant_Name = s.Restaurant_Name
JOIN dim_category dc
    ON dc.Category = s.Category
JOIN dim_dish dsh
    ON dsh.Dish_Name = s.Dish_Name;
    
select * from fact_swiggy_orders

SELECT * FROM dim_date;
SELECT * FROM dim_location;
SELECT * FROM dim_restaurant;
SELECT * FROM dim_category;
SELECT * FROM dim_dish;
SELECT * FROM fact_swiggy_orders;

SELECT *
FROM fact_swiggy_orders f
JOIN dim_date d
    ON f.date_id = d.date_id
JOIN dim_location l
    ON f.location_id = l.location_id
JOIN dim_restaurant r
    ON f.restaurant_id = r.restaurant_id
JOIN dim_category c
    ON f.category_id = c.category_id
JOIN dim_dish di
    ON f.dish_id = di.dish_id;

--KPI requirement
--Total Orders

SELECT COUNT(*) AS Total_Orders
FROM fact_swiggy_orders;

--Total Revenue (INR and INR Million)
SELECT
    SUM(Price_INR) AS Total_Revenue_INR,
    SUM(Price_INR) / 1000000.0 AS Total_Revenue_Million_INR
FROM fact_swiggy_orders;

--Average Dish Price
SELECT
    AVG(Price_INR) AS Average_Dish_Price
FROM fact_swiggy_orders;


--Average Rating (simple average of ratings)
SELECT
    AVG(Rating) AS Average_Rating
FROM fact_swiggy_orders
WHERE Rating IS NOT NULL;

--Monthly order trends (orders + revenue by Year-Month)
SELECT
    d.Year,
    d.Month,
    CONCAT(d.Year, '-', RIGHT('0' + CAST(d.Month AS VARCHAR(2)), 2)) AS Year_Month,
    COUNT(*) AS Orders,
    SUM(f.Price_INR) AS Revenue_INR,
    AVG(f.Price_INR) AS Avg_Dish_Price,
    AVG(f.Rating) AS Avg_Rating
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.Year, d.Month
ORDER BY d.Year, d.Month;


-- Quarterly Trend
SELECT
    d.Year,
    d.Quarter,
    CONCAT(d.Year, '-Q', d.Quarter) AS Year_Quarter,
    COUNT(*) AS Total_Orders,
    SUM(f.Price_INR) AS Revenue_INR,
    AVG(f.Price_INR) AS Avg_Dish_Price,
    AVG(f.Rating) AS Avg_Rating
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.Year, d.Quarter
ORDER BY d.Year, d.Quarter;   -- chronological order


-- Yearly Trend (chronological)
SELECT
    d.Year,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.Year
ORDER BY d.Year;    -- chronological order


-- Orders by Day of Week (Mon–Sun)
SELECT
    DATENAME(WEEKDAY, d.Full_Date) AS day_name,
    DATEPART(WEEKDAY, d.Full_Date) AS day_number,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY 
    DATENAME(WEEKDAY, d.Full_Date),
    DATEPART(WEEKDAY, d.Full_Date)
ORDER BY 
    DATEPART(WEEKDAY, d.Full_Date);


-- Top 10 cities by order volume
SELECT TOP 10
    l.City,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_location l 
    ON l.location_id = f.location_id
GROUP BY 
    l.City
ORDER BY 
    COUNT(*) DESC;


-- Revenue contribution by states
SELECT
    l.State,
    SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_location l
    ON l.location_id = f.location_id
GROUP BY 
    l.State
ORDER BY 
    SUM(f.Price_INR) DESC;


-- Top 10 restaurants by orders
SELECT TOP 10
    r.Restaurant_Name,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_restaurant r
    ON r.restaurant_id = f.restaurant_id
GROUP BY 
    r.Restaurant_Name
ORDER BY 
    COUNT(*) DESC;


-- Top Categories by Order Volume
SELECT
    c.Category,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_category c 
    ON f.category_id = c.category_id
GROUP BY 
    c.Category
ORDER BY 
    Total_Orders DESC;


-- Most Ordered Dishes
SELECT TOP 10
    d.Dish_Name,
    COUNT(*) AS Order_Count
FROM fact_swiggy_orders f
JOIN dim_dish d 
    ON f.dish_id = d.dish_id
GROUP BY 
    d.Dish_Name
ORDER BY 
    Order_Count DESC;


-- Cuisine Performance (Orders + Avg Rating)
SELECT
    c.Category,
    COUNT(*) AS Total_Orders,
    AVG(f.Rating) AS Avg_Rating
FROM fact_swiggy_orders f
JOIN dim_category c 
    ON f.category_id = c.category_id
GROUP BY 
    c.Category
ORDER BY 
    Total_Orders DESC;


-- Total Orders by Price Range
SELECT
    CASE 
        WHEN f.Price_INR < 100 THEN 'Under 100'
        WHEN f.Price_INR BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN f.Price_INR BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN f.Price_INR BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+'
    END AS Price_Range,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
GROUP BY
    CASE 
        WHEN f.Price_INR < 100 THEN 'Under 100'
        WHEN f.Price_INR BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN f.Price_INR BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN f.Price_INR BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+'
    END
ORDER BY 
    Total_Orders DESC;


-- Rating Count Distribution (1–5)
SELECT
    Rating,
    COUNT(*) AS Rating_Count
FROM fact_swiggy_orders
WHERE Rating IS NOT NULL
GROUP BY 
    Rating
ORDER BY 
    Rating;

