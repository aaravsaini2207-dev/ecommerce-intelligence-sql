CREATE DATABASE ecommerce_intelligence;
USE ecommerce_intelligence;

DROP TABLE orders;
DROP TABLE order_items;
DROP TABLE customers;

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@order_id,
 @customer_id,
 @order_status,
 @order_purchase_timestamp,
 @order_approved_at,
 @order_delivered_carrier_date,
 @order_delivered_customer_date,
 @order_estimated_delivery_date)
SET
order_id = @order_id,
customer_id = @customer_id,
order_status = @order_status,
order_purchase_timestamp = NULLIF(@order_purchase_timestamp, ''),
order_approved_at = NULLIF(@order_approved_at, ''),
order_delivered_carrier_date = NULLIF(@order_delivered_carrier_date, ''),
order_delivered_customer_date = NULLIF(@order_delivered_customer_date, ''),
order_estimated_delivery_date = NULLIF(@order_estimated_delivery_date, '');

SELECT COUNT(*) FROM olist_orders_dataset;

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@order_id,
 @order_item_id,
 @product_id,
 @seller_id,
 @shipping_limit_date,
 @price,
 @freight_value)
SET
order_id = @order_id,
order_item_id = @order_item_id,
product_id = @product_id,
seller_id = @seller_id,
shipping_limit_date = NULLIF(@shipping_limit_date, ''),
price = @price,
freight_value = @freight_value;

SELECT COUNT(*) FROM olist_order_items_dataset;

CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DROP TABLE IF EXISTS olist_products_dataset;

CREATE TABLE olist_products_dataset (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@product_id,
 @product_category_name,
 @product_name_length,
 @product_description_length,
 @product_photos_qty,
 @product_weight_g,
 @product_length_cm,
 @product_height_cm,
 @product_width_cm)
SET
product_id = @product_id,
product_category_name = NULLIF(@product_category_name,''),
product_name_length = NULLIF(@product_name_length,''),
product_description_length = NULLIF(@product_description_length,''),
product_photos_qty = NULLIF(@product_photos_qty,''),
product_weight_g = NULLIF(@product_weight_g,''),
product_length_cm = NULLIF(@product_length_cm,''),
product_height_cm = NULLIF(@product_height_cm,''),
product_width_cm = NULLIF(@product_width_cm,'');

DROP TABLE IF EXISTS product_category_name_translation;

CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


DROP TABLE IF EXISTS olist_order_payments_dataset;

CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@order_id,
 @payment_sequential,
 @payment_type,
 @payment_installments,
 @payment_value)
SET
order_id = @order_id,
payment_sequential = NULLIF(@payment_sequential,''),
payment_type = NULLIF(@payment_type,''),
payment_installments = NULLIF(@payment_installments,''),
payment_value = NULLIF(@payment_value,'');





# order-level revenue table.
drop view if exists order_level_revenue;
create view order_level_revenue as
select o.order_id, o.customer_id, o.order_purchase_timestamp as order_date,
		ROUND(sum(oi.price),2) as total_revenue, ROUND(sum(oi.freight_value),2) as total_freight,
		ROUND(sum(oi.price + oi.freight_value ),2) as total_order_revenue
        from order_items as oi
        join orders as o
        on oi.order_id=o.order_id
        group by o.order_id, o.customer_id, order_date;
        
select *
from order_level_revenue
order  by  order_date 
;

# Create Customer Revenue Summary (TABLE)
drop view if exists customer_level_revenue;
create view customer_level_revenue as 
	select customer_id, count(distinct order_id) as total_orders, ROUND(SUM(total_revenue),2) as total_revenue_cus, sum(total_order_revenue) as total_order_value,
			AVG(total_order_revenue) as average_order_value,
			max(order_date) as last_buy, min(order_date) as first_buy,
            datediff(max(order_date), min(order_date)) as lifespan
            from order_level_revenue
            group by customer_id;
select *
from customer_level_revenue
order by total_order_value
;

# Build RFM Base Table
DROP TABLE IF EXISTS rfm_base;
CREATE TABLE rfm_base AS
SELECT 
    customer_id, total_orders AS frequency, total_revenue_cus AS monetary,
    DATEDIFF((SELECT MAX(order_date) FROM order_level_revenue),last_buy) AS recency
FROM customer_level_revenue;
;

# Convert Into RFM Scores (1–5)
drop table if exists rfm_score;
CREATE TABLE rfm_score as 
select *,
		NTILE(5) over(order by recency desc) as r_score,
        NTILE(5) over(order by frequency asc) as f_score,
        NTILE(5) over(order by monetary asc) as m_score
from rfm_base;

select *
from rfm_score;

# Create Customer Segments
create table customer_segment as
select *,
	case when r_score>=4 and f_score>=4 and m_score>=4
			then 'CHAMPIONS'
            when r_score>=3 and f_score>=4 
			then 'LOYAL CUSTOMERS'
            when r_score<=2  and m_score>=3
			then 'AT RISK'
            when r_score=1 and f_score<=2
			then 'LOST CUSTOMERS'
            when m_score=5
			then 'BIG SPENDERS'
            ELSE 'REGULAR'
            END AS segment
from rfm_score;

# Check RFM Score Distribution
SELECT r_score, COUNT(*) 
FROM rfm_score
GROUP BY r_score
ORDER BY r_score;

select segment, count(*) as total_customers
from customer_segment
group by segment
order by total_customers desc;
# Champions → Retain & Reward , Loyal → Upsell , At Risk → Target with offers , Lost → Win-back campaigns , Big Spenders → Premium targeting

# Customer Lifetime VALUE= total_revenue / total_days
drop table  customer_clv ;
create table customer_clv as 
select customer_id, total_orders, total_revenue_cus ,average_order_value, lifespan,
		(total_revenue_cus/NULLIF (lifespan,0)) as revenue_per_day,
        (average_order_value*total_orders) as simple_clvs                #same as total_revenue_cus
        from customer_level_revenue;
     
SHOW TABLES LIKE 'customer_clv';
 
 select *
 from customer_clv
 order by revenue_per_day desc;

# High-Value Customers (Top 10%)
select *
from( select *, NTILE(10) OVER(ORDER BY simple_clvs) as clv_percentile
		from customer_clv) t
where clv_percentile=1;

# Build Churn Risk Table
drop table if exists churn_analysis ;
create table churn_analysis as
select customer_id, recency,
case when recency> 180 then 'HIGH RISK'
 WHEN 	recency> 90 then 'MEDIUM RISK'
 else 'ACTIVE' END AS churn_risk
 from rfm_base;

show tables like 'churn_analysis' ;

select churn_risk, count(*) as total_customers_churns
from churn_analysis
group by churn_risk
order by total_customers_churns desc;

# Calculate Order Z-Score
SELECT *
FROM (
    SELECT 
        order_id,
        total_revenue,
        (total_revenue - AVG(total_revenue) OVER()) /
        STDDEV(total_revenue) OVER() AS z_score
    FROM order_level_revenue
) t
WHERE ABS(z_score) > 3;




# COHORT RETENTION ANALYSIS

# Create Customer First Purchase Month
create table cohort_month as 
select customer_id, MIN(DATE_FORMAT(order_date, '%Y-%m')) as cohort_month
		from order_level_revenue
        group by customer_id;
 
 # Create Monthly Activity
create table customer_monthly_activity as
	select customer_id, (DATE_FORMAT(order_date, '%Y-%m')) as order_month
    from order_level_revenue;
 
 # Join & Calculate Month Difference
SELECT 
    c.cohort_month,
    a.order_month,
   datediff(a.order_month, c.cohort_month),
    COUNT(DISTINCT a.customer_id) AS active_customers
FROM cohort_month c
JOIN customer_monthly_activity a
    ON c.customer_id = a.customer_id
GROUP BY cohort_month, order_month
ORDER BY cohort_month, month_number;

# Get Recency Distribution
select recency, count(*) as total_customers
from rfm_base 
group by recency
order by recency;

# Survival Probability
select recency, count(*) as remaining_customers,
		count(*) / sum(count(*)) over() as survival_probability
        from rfm_base
        group by recency
        order by recency;                                       #Lower slope = healthier business.


# Create Churn Score
create TABLE churn_scoring as
select *, (recency*0.5) - (frequency*10) - (monetary*0.01) as churn_score
from rfm_base
; 
# Higher score = more likely to churn
select *
from churn_scoring
order by churn_score desc;                   #Lower slope = healthier business.




# Category-Level Profitability Analysis
select p.product_category_name , sum(oi.price) as total_revenue, sum(freight_value) as total_frieght , sum(oi.price-oi.freight_value) as profit
from order_items as oi
join products as p
on oi.product_id=p.product_id
group by product_category_name
order by profit desc;



# Calculate Customer Lifetime Month
create table customer_live as 
select customer_id, DATEDIFF( MAX(order_purchase_timestamp), MIN(order_purchase_timestamp)) AS lifetime_months
from orders
group by customer_id
;
# Rolling Retention Curve
select lifetime_months, count(*) as remaining_customers, 
		count(*) / sum(count(*)) over() as retention_rate
        from customer_live
        group by lifetime_months
        order by lifetime_months desc;
# Steep drop early → weak product retention , Flat curve → strong repeat purchase behavior



# LTV Forecasting  , Predicted LTV=Revenue Per Day×Expected Future Lifetime
# Predict Future LTV
with data as (
select customer_id, avg(total_revenue_cus) as avg_rev_per_day, avg(lifespan) as avg_lifespan
from customer_level_revenue
group by customer_id )

select avg_lifespan, avg_rev_per_day, 
		avg_rev_per_day*(avg_lifespan-lifespan) as future_ltv
        from data
        group by customer_id
        order by future_ltv desc;



# Create Order Discount Table
drop table if exists order_discount_analyses;
create table order_discount_analyses as
select  o.customer_id, o.order_id, sum(oi.price) as mrp, sum(p.payment_value) as selling_price,
 sum(oi.price)-sum(p.payment_value) as discount_value, (sum(oi.price)-sum(p.payment_value))/NULLIF(sum(oi.price),0) as discount_ratio
from orders as o
join order_payments p
on o.order_id=p.order_id
join order_items oi
on p.order_id=oi.order_id 
group by o.customer_id, o.order_id;

# Customer-Level Discount Exposure
drop table if exists customer_discount;
create table customer_discount as
select customer_id, AVG(discount_ratio) AS avg_discount_ratio
from order_discount_analyses
group by customer_id ;

#Revenue Elasticity vs Discount Analysis
select d.customer_id, d.avg_discount_ratio,  c.simple_clvs
from customer_discount as d
join customer_clv as c
on d.customer_id=c.customer_id;


# Combine With CLV
select discount_ratio, AVG(mrp) as avg_order_value
from order_discount_analyses
group by discount_ratio
order by discount_ratio;
# # If higher discount bucket → lower revenue 👉 Discounts are destroying margin.


# Segment by Discount Level
with data as(
select customer_id, avg_discount_ratio , NTILE(4) OVER(ORDER BY avg_discount_ratio desc) as discount_percentile
from customer_discount
 )

select d.customer_id, d.avg_discount_ratio,  avg(c.simple_clvs) avg_clv
from data as d
join customer_clv as c
on d.customer_id=c.customer_id
where discount_percentile=1
group by d.customer_id, avg_discount_ratio
order by avg_clv desc;

# High discount quartile → low CLV 👉 Discounts are attracting low-value customers.
# High discount quartile → high CLV 👉 Discounts are driving long-term loyalty.

# Time-Series Forecasting Prep (Moving Avg + Trend Detection)
DROP TABLE IF exists monthly_revenue;
create TABLE monthly_revenue as
select DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') as months, sum(oi.price) as total_revenue
from orders as o
join order_items as oi
on o.order_id= oi.order_id
group by months
order by months;

# 3-Month Moving Average
select months, total_revenue, 
ROUND(AVG(total_revenue) OVER (ORDER BY months rows between 2 preceding and current row),2) as past_three_month_avg
from monthly_revenue
group by months, total_revenue
order by months;

# Growth Detection
SELECT 
    months,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY months) AS prev_revenue,
   CONCAT( ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY months)) /
        LAG(total_revenue) OVER (ORDER BY months) * 100,2
    ), '%') AS growth_percent
FROM monthly_revenue;


# Marketplace Seller Performance Analytics
# Seller Revenue + Profitability
# Identify Risky Sellers (High Freight %)

with data as (
select seller_id, sum(oi.price) as revenue ,sum(oi.freight_value) as total_freight, sum(oi.price-oi.freight_value) as estimated_profit
from order_items as oi
group by seller_id
order by estimated_profit desc)

select seller_id, total_freight, revenue,
CONCAT( ROUND ((total_freight)/(revenue)*100,2), '%') as freight_percentage
from data
group by seller_id
having freight_percentage > 0.4
order by freight_percentage desc;

# High freight ratio sellers hurt margins.
































































































































