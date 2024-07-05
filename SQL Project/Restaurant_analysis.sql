CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT * FROM compititors

SELECT * FROM members

select * from menu 
select * from sales 

--What is the total amount each customer spent at the restaurant?
select customer_id, sum(price) as total_spend
from sales 
join menu 
on sales.product_id = menu.product_id 
group by customer_id
order by customer_id

--How many days has each customer visited the restaurant?
select customer_id, count(Distinct order_date) from sales
group by customer_id 
order by customer_id

--What was the first item from the menu purchased by each customer?

with ct1 as (select customer_id, product_id, order_date,
	row_number() over (partition by customer_id order by order_date) as rw_num
	from sales)
	
select customer_id, product_name, order_date
	from ct1 join menu 
	on ct1.product_id = menu.product_id 
where rw_num=1
	
--What is the most purchased item on the menu and how many times was it purchased by all customers?
with ct1 as (
      select customer_id, product_name, order_date
	  from sales join menu
	  on sales.product_id = menu.product_id)
	
select product_name, count(*) as total_quan_purchased from ct1
group by product_name 
limit(1)	
		
	
	
--Which item was the most popular for each customer?
with ct1 as (
      select customer_id, product_name, count(order_date) as total_quan_purchased
	  from sales join menu
	  on sales.product_id = menu.product_id
	  group by customer_id, product_name)

	select customer_id, product_name
	from (select *,
			row_number() over (partition by customer_id order by total_quan_purchased desc) as rw_num
			from ct1)
	where rw_num=1

--Which item was purchased first by the customer after they became a member?
with ct1 as (
	select sales.customer_id,Date(join_date) as join_date,order_date,product_name
	from sales join members
	on sales.customer_id=members.customer_id
	join menu 
	on sales.product_id=menu.product_id
where order_date>=join_date)

select customer_id, product_name 
	from (select *,
	      row_number() over (partition by customer_id order by order_date) as rw_num
	      from ct1)
Where rw_num= 1


--Which item was purchased just before the customer became a member?
with ct1 as (
	select sales.customer_id,Date(join_date) as join_date,order_date,product_name
	from sales join members
	on sales.customer_id=members.customer_id
	join menu 
	on sales.product_id=menu.product_id
where order_date<join_date)

select customer_id, product_name 
	from (select *,
	      row_number() over (partition by customer_id order by order_date desc) as rw_num
	      from ct1)
Where rw_num= 1

--What is the total items and amount spent for each member before they became a member?
with ct1 as (
	select sales.customer_id,Date(join_date) as join_date,order_date,product_name,price
	from sales join members
	on sales.customer_id=members.customer_id
	join menu 
	on sales.product_id=menu.product_id
    where order_date<join_date)

select customer_id,count(*) as total_item,sum(price) as amount_spend
	from ct1
	group by customer_id
	order by customer_id
	
--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with ct1 as 
	(select sales.customer_id,product_name,SUM(price) as total
	from sales join menu 
	on sales.product_id=menu.product_id
    group by sales.customer_id,product_name)

SELECT customer_id,SUM(points_earned) as total_points
FROM (SELECT customer_id,product_name,
CASE WHEN product_name='sushi' THEN total*2*10 else total*10 END AS points_earned
FROM ct1)
GROUP BY customer_id
ORDER BY customer_id
	
/*In the first week after a customer joins the program 
(including their join date) they earn 2x points on all items, 
not just sushi - how many points do customer A and B have at the end of January?*/

with ct1 as (
	select sales.customer_id,order_date-Date(join_date) as datediff,price
	from sales join members
	on sales.customer_id=members.customer_id
	join menu 
	on sales.product_id=menu.product_id
    where order_date>=join_date)
select customer_id, sum(price*2) as points
from ct1 
where datediff<=7
group by customer_id
order by customer_id

