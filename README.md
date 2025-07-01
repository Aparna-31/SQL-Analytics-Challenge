This project is part of a SQL assessment challenge designed for a Data Analyst internship opportunity with Pupilfirst/OHC. The task involved working with a relational schema and nested JSONB fields in PostgreSQL to answer real-world analytical questions.

---

## 📦 What This Project Includes

- Full **schema creation** and **data seeding** using `CREATE TABLE` and `INSERT` statements.
- 5 SQL queries that answer business-style questions involving:
  - Total sales and net revenue
  - Top-selling product categories
  - Customer behavior analysis
  - Monthly KPI tracking
  - Country-level payment method and basket size insights

---

## 🛠️ Skills Used

- **SQL Joins** – across customers, orders, products, and order lines
- **JSONB Operators** – extracting nested fields like payment methods and discounts
- **CTEs (WITH)** – for building clean and modular queries
- **Aggregations** – `SUM()`, `AVG()`, `COUNT()`
- **Filtering** – using `WHERE` and `HAVING`
- **Window Functions** – `ROW_NUMBER()` to determine most frequent payment method

---

## 📈 Sample Questions Solved

1. What is the net revenue per order after applying discounts and adding shipping?
2. Which product category generated the most revenue?
3. Which customers used more than one card brand?
4. What does the monthly order funnel look like (orders, distinct customers, gross and net)?
5. For each country, what is the average items per order and preferred payment method?

---

## 🧩 Technologies Used

- **PostgreSQL**
- **SQL**
- Written and tested in **online PostgreSQL environments** and **VS Code**
