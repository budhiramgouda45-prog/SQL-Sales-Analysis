# SQL Sales Analysis Project

## 📊 Project Overview
This SQL project analyzes sales, products, and customer data from a retail business.  
The goal is to extract insights on sales performance, product performance, and customer behavior to support data-driven decisions.

Key highlights:
- Analyze monthly and yearly sales trends.
- Identify high-performing products and categories.
- Segment customers based on spending behavior.
- Calculate cumulative sales and year-over-year performance.

---

## 🗄 Database Structure

### **Customer Table**
- `cst_id` → Customer ID (Primary Key)  
- `cst_name` → Customer Name  
- Other customer details (email, region, etc.)

### **Product Table**
- `prd_id` → Product ID (Primary Key)  
- `prd_nm` → Product Name  
- `category` → Product Category  

### **Sales Table**
- `sls_id` → Sales Transaction ID (Primary Key)  
- `sls_cust_id` → Customer ID (Foreign Key)  
- `sls_prd_id` → Product ID (Foreign Key)  
- `sls_sales` → Sales Amount  
- `sls_quantity` → Quantity Sold  
- `sls_order_dt` → Order Date  

---

## SQL Queries

### Monthly and Yearly Sales Performance
```sql
SELECT 
    YEAR(sls_order_dt) AS Year,
    MONTH(sls_order_dt) AS Month_Number,
    DATENAME(MONTH, sls_order_dt) AS Month_Name,
    SUM(sls_sales) AS Total_Sales
FROM sales
GROUP BY YEAR(sls_order_dt), MONTH(sls_order_dt), DATENAME(MONTH, sls_order_dt)
ORDER BY Year, Month_Number;
```

## Customer Segmentation by Spending Behavior

```
WITH overview AS (
    SELECT 
        c.cst_id,
        SUM(s.sls_sales) AS total_spending,
        MIN(s.sls_order_dt) AS first_order_date,
        MAX(s.sls_order_dt) AS last_order_date,
        DATEDIFF(MONTH, MIN(s.sls_order_dt), MAX(s.sls_order_dt)) AS lifespan
    FROM customer c
    LEFT JOIN sales s ON c.cst_id = s.sls_cust_id
    GROUP BY c.cst_id
),
cust_details AS (
    SELECT
        cst_id,
        total_spending,
        first_order_date,
        last_order_date,
        lifespan,
        CASE
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM overview
)
SELECT *
FROM cust_details
ORDER BY customer_segment, total_spending DESC;
```
