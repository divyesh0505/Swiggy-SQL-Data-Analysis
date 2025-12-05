📌 Swiggy SQL Data Analysis Project

An end-to-end SQL analytics project performed on Swiggy food delivery data. This project includes data cleaning, dimensional modelling (Star Schema), KPI creation, and business insights using SQL — following a complete data analyst workflow.

🚀 Project Overview

This project analyzes food delivery patterns across states, cities, restaurants, cuisines, and dishes.
Using SQL, the raw data is transformed into meaningful insights that help understand:

Order trends

Revenue patterns

Customer behaviour

Cuisine & restaurant performance

Rating analysis

The analysis is structured using a professional SQL analytics approach.

🧹 1. Data Cleaning & Validation

Performed essential cleaning tasks to prepare the dataset for reliable analytics:

Handling NULL values

Detecting blank/empty strings

Identifying duplicate rows

Removing duplicates using ROW_NUMBER()

Standardizing date formats

Ensuring consistency across categories and text fields

Script: scripts/01_data_cleaning.sql

🗂️ 2. Dimensional Modelling – Star Schema

To optimize analytical queries, the cleaned data is structured using a Star Schema with separate dimension tables and one fact table.

Dimension Tables

dim_date → Year, Month, Quarter, Day, Week

dim_location → State, City, Location

dim_restaurant → Restaurant_Name

dim_category → Cuisine / Category

dim_dish → Dish_Name

Fact Table

fact_swiggy_orders → Price, Rating, Rating_Count + foreign keys

This structure improves performance, reduces redundancy, and makes KPI reporting faster.

Script: scripts/02_dimensional_modelling.sql

📈 3. KPI Development

Key metrics computed:

Basic KPIs

Total Orders

Total Revenue (in INR Millions)

Average Dish Price

Average Rating

Trend & Performance KPIs

Monthly and quarterly order trends

Year-wise growth

Top-performing cities

Top restaurants

Most popular dishes

Category/cuisine performance

Customer Spending Buckets

<100

100–199

200–299

300–499

500+

Script: scripts/03_kpi_queries.sql

🔍 4. Business Insights

Insights derived from KPI analysis:

📅 Date-based insights

Month with highest orders

Quarter-wise growth trends

Weekday vs weekend patterns

🌍 Location-based insights

Cities with highest order volumes

Revenue contribution by states

🍽 Food & Restaurant Insights

Highest-selling cuisines

Top restaurants by rating & orders

Most frequently ordered dishes

⭐ Ratings Analysis

Rating distribution from 1 to 5

Correlation between price and ratings

Script: scripts/04_business_insights.sql

🛠️ Tech Stack

SQL (MySQL / PostgreSQL)

ERD Modelling

Data Cleaning & Transformation

Analytical Querying

KPI Dashboard Planning
