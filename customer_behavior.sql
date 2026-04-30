show tables;
select *from customers;
select*from customers limit 20;
DROP TABLE customers;
create database customer_behavior;
use customer_behavior;
desc customers;
#--1.total revenue by male vs female?
select gender,SUM(purchase_amount) as revenue from customers group by gender;

#--2.which customer used a discount but still spent more than avg purchase amt?
select customer_id,purchase_amount
from customers
where discount_applied = 'yes'and purchase_amount >=(select avg(purchase_amount)from customers);

#--3.which are the top 5 products with highest avg review rating?
SELECT item_purchased,
ROUND(AVG(review_rating), 2) AS average_product_rating
FROM customers
GROUP BY item_purchased
order by avg(review_rating)desc
limit 5;

#--4.compare the avg purchase amt between standard and express shiping?
select shipping_type,round(avg(purchase_amount),2)
from customers
where shipping_type in ('standard','express')
group by shipping_type; 

#--5.do subscribed customers spend more? 
#--compare avg spend and tot revenue between subscribes and non-subscribes?
select subscription_status,count(customer_id)as total_customers,
round(avg(purchase_amount),2) as avg_spend,
round(sum(purchase_amount),2) as total_revenue
from customers 
group by subscription_status
order by total_revenue,avg_spend desc;

#--6.which 5 products have highest percentage of purchases with discounts applied?
select item_purchased,
round(100 *sum(case when discount_applied='yes' then 1 else 0 end )/count(*) ,2) as discount_rate
from customers
group by item_purchased
order by discount_rate desc
limit 5;


#--7.segment customers into new,returning, and loyal based on previous purchases and count of each segment?
with customer_type as(
select customer_id,previous_purchases,
case
     when previous_purchases =1 then 'new'
     when previous_purchases  between 2 and 10 then 'returning'
     else 'loyal'
     end as customer_segment
from customers
)
select customer_segment,count(*) as "num of cus"
from customer_type
group by customer_segment;
select*from customers;
#--8.what are top 3 most purchase products within each category?
with item_counts as(
select category ,item_purchased,count(customer_id) as total_orders,
row_number() over (partition by category order by count(customer_id)desc )as item_rank
from customers
group by category,item_purchased
)
select item_rank,category,item_purchased ,total_orders from item_counts where item_rank <=3;

#--9.are customers who are repeat buyers (more than 5 previous purchases)also likely to subscribe?
select subscription_status,
count(customer_id)as repeat_buyers
from customers
where previous_purchases >5
group by subscription_status;

#--10.what is the revenue by age group?

select age_group ,sum(purchase_amount)as total_revenue
from customers
group by age_group
order  by total_revenue desc;