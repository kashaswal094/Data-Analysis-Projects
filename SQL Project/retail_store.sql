CREATE TABLE orders(
	order_id int primary key, order_date date, ship_mode varchar(20), 
	segment varchar(20), country varchar(20), city varchar (20),
    state varchar (20), postal_code varchar(20), region varchar(20), 
	category varchar(20), sub_category varchar(20),
    product_id varchar(50), quantity int, 
	discount_amount decimal(7,2) , sale_price decimal(7,2), 
	profit decimal(7,2)
)
--import data from csv file	
--Select all columns from the table
SELECT * FROM orders

--find top 10 highest reveue generating products 
select product_id, sum(sale_price) as revenue 
from orders
group by product_id 
order by sum(sale_price) desc
limit 10;

--find top 5 highest selling products in each region
with ct1 as
	(select region,product_id, sum(sale_price) as total_sale
from orders 
group by region, product_id)
 select * from (select *,
dense_rank() over (partition by region order by total_sale desc) as rnk
from ct1)
where rnk<=5

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with ct1 as (select extract(year from order_date) as order_year,
	extract(month from order_date) as order_month,
	sum(sale_price) as total_sales from orders
	group by order_year,order_month)
select order_month,
	sum(case when order_year=2022 then total_sales else 0 end) as sales_2022,
	sum(case when order_year=2023 then total_sales else 0 end) as sales_2023
	from ct1
	group by order_month
	order by order_month
	
--for each category which month had highest sales 
with ct1 as 
	(select category, extract(month from order_date) as order_month,
	sum(sale_price) as total_sales
	from orders
	group by category, order_month)
 select category, order_month
	from (select *,
	row_number() over(partition by category order by total_sales desc) as rw_num
	from ct1)
where rw_num<2
--which sub category had highest growth by profit in 2023 compare to 2022

with ct1 as (
	select sub_category,extract(year from order_date) as order_year,
	sum(profit) as total
	from orders 
	group by sub_category,order_year)
	
select * 
	from (select sub_category, 
	sum(case when order_year=2023 then total else 0 end)- sum(case when order_year=2022 then total else 0 end) as growth
	from ct1
	group by sub_category)
order by growth desc 
limit(1)



