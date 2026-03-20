Create Database Warehouse
Use Warehouse

Select * From customer
Select * From product
Select * From sales


Alter Table sales Add Constraint fk_customer Foreign Key (sls_cust_id) References customer(cst_id)

Alter Table sales Add Constraint fk_product Foreign Key (sls_prd_id) References product(prd_id)


--What is the monthly and yearly sales performance?

Select 
	Year(sls_order_dt) As Year,
	Month(sls_order_dt) As Month_Number,
	DateName(Month,sls_order_dt) As Month_Name,
	Sum(sls_sales) As Total_Sales
From sales 
Group By 
	year(sls_order_dt),
	Month(sls_order_dt),
	DateName(Month,sls_order_dt)
order by 
	Year(sls_order_dt),
	Month(sls_order_dt)

--How does cumulative (running total) sales grow over time?

select 
	Year,
	Month_Number,
	Month_Name,
	Total_Sales,
	sum(Total_Sales) over(partition by year Order By Month_Number) as Running_Total
from 
(Select 
	Year(sls_order_dt) As Year,
	Month(sls_order_dt) as Month_Number,
	DateName(Month,sls_order_dt) As Month_Name,
	Sum(sls_sales) As Total_Sales 
	From sales 
	Group By 
	Year(sls_order_dt),
	Month(sls_order_dt),
	DateName(Month,sls_order_dt)) t


--How do products perform year-over-year and vs average sales?


With yearly_product_sales As 
(Select
	Year(s.sls_order_dt) As order_year,
	p.prd_nm,
	Sum(s.sls_sales) As current_sales
	From sales s 
	Left Join product p on s.sls_prd_id=p.prd_id
	Group by 
	Year(s.sls_order_dt),
	p.prd_nm
)
Select 
	order_year,
	prd_nm,
	current_sales,
	Avg(current_sales) Over(Partition By prd_nm) As avg_sales,
	current_sales-Avg(current_sales) Over(Partition By prd_nm) As avg_diff ,
	Lag(current_sales) Over(Partition By prd_nm Order By order_year) As py_sales,
	current_sales-Lag(current_sales) Over(Partition By prd_nm Order By order_year) As yoy_diff
	From yearly_product_sales
	Order By order_year,prd_nm




--Which categories contribute the most to total sales?
Select * From customer
Select * From product
Select * From sales

;With details as 
(Select p.category,
Sum(s.sls_sales) As Total_Sales
From product p Left Join sales s On p.prd_id=s.sls_prd_id
Group by p.category)
select 
category,
Total_Sales,
sum(Total_Sales) over() as overall_sales,
convert(decimal(10,2),(Total_Sales*100.0)/sum(Total_Sales) over()) as Percentage from details
order by percentage desc

--How are customers segmented based on spending behavior?


;with overview as 
(select 
c.cst_id,
sum(s.sls_sales) as total_spending,
min(s.sls_order_dt) as first_order_date,
max(s.sls_order_dt) as last_order_date,
datediff(month,min(s.sls_order_dt),max(s.sls_order_dt)) as lifespan
from customer c left join sales s on 
c.cst_id=s.sls_cust_id group by c.cst_id
),
cust_details as 
(select 
cst_id,
total_spending,
first_order_date,
last_order_date,
lifespan,
case 
when lifespan>=12 and total_spending>5000 then 'VIP'
when lifespan>=12 and total_spending<=5000 then 'Regular'
else 'New'
end as customer_segment
from overview 
)
select 
cst_id,
total_spending,
first_order_date,
last_order_date,
lifespan,
customer_segment
from cust_details 
order by customer_segment,total_spending desc


--Which products are high-performing vs low-performing?

select * from customer
select * from sales
select * from product

;with product_metrics as 
(select
	p.prd_id,
	p.prd_nm as product_name,
	p.category,
	sum(s.sls_sales) as Total_Sales,
	sum(s.sls_quantity) as Total_Quantity,
	count(distinct s.sls_cust_id) as Total_Customers,
	datediff(month,min(s.sls_order_dt),max(s.sls_order_dt)) as lifespan
from product p left join sales s
on p.prd_id=s.sls_prd_id
group by p.prd_id,p.prd_nm,p.category
)
	select 
		prd_id,
		product_name,
		category,
		Total_Sales,
		Total_Quantity,
		Total_Customers,
		lifespan,
	case
		when Total_Sales>50000 then 'High-Performer'
		when Total_Sales between 10000 and 50000 then 'Mid-Range'
		else 'Low-Performer'
	end as product_segment
from product_metrics
order by product_segment desc,Total_Sales DESC


