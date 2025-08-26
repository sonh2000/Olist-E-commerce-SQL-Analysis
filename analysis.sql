---fetching  payments table :
SELECT * from olist_order_payments WHERE payment_installments=0;

--- Look at orders with multiple payments to check payment_squential is rigth  or wrong :

SELECT *
FROM olist_order_payments
WHERE order_id IN (
    SELECT order_id
    FROM olist_order_payments
    GROUP BY order_id
    HAVING COUNT(*) > 1
)
ORDER BY order_id, payment_sequential;

--updating payments table :

-- PostgreSQL
ALTER TABLE olist_orders
ALTER COLUMN order_purchase_timestamp
TYPE TIMESTAMP
USING order_purchase_timestamp::timestamp;

ALTER TABLE olist_orders
ALTER COLUMN order_delivered_customer_date
TYPE TIMESTAMP
USING order_delivered_customer_date::timestamp;

ALTER TABLE olist_orders
ALTER COLUMN order_estimated_delivery_date
TYPE TIMESTAMP
USING order_estimated_delivery_date::timestamp;

UPDATE olist_order_payments SET payment_installments=1 WHERE payment_installments=0;
---fetching orders table :




---📈 Sales Metrics 
--total revnue and average order value (AOV)
select 
    round(sum(order_total),0)||' '||'$' as total_revenue,
    round(avg(order_total),0) ||' '||'$' as AOV
from (
    select order_id, sum(payment_value::numeric) as order_total
    from olist_order_payments
    group by order_id
) as order_payments_summary;

--number of orders per month
SELECT 
    DATE_TRUNC('month', order_purchase_timestamp) AS month,
    COUNT(DISTINCT order_id) AS num_orders
FROM olist_orders
GROUP BY 1
ORDER BY 1;

--Revenue per Product Category
SELECT 
    p.product_category_name,
    SUM(pay.payment_value) AS revenue
FROM olist_order_items i
JOIN olist_products p ON i.product_id = p.product_id
JOIN olist_order_payments pay ON i.order_id = pay.order_id
GROUP BY p.product_category_name
ORDER BY revenue DESC;







---👥 Customer Metrics

--retention rate (CRR)
CREATE TEMP TABLE customer_orders AS
SELECT 
    customer_unique_id,
    COUNT(DISTINCT order_id) AS order_count
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
GROUP BY customer_unique_id;



SELECT 
    round((SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)::decimal / COUNT(*))*100,0)|| ' %' AS retention_rate_CRR
FROM customer_orders;


SELECT 
    SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers
FROM customer_orders;


--Customer Lifetime Value CLV
WITH customer_spend AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT o.order_id) AS num_orders,
           SUM(p.payment_value) AS total_spent
    FROM olist_customers c
    JOIN olist_orders o ON c.customer_id = o.customer_id
    JOIN olist_order_payments p ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
)
SELECT 
    AVG(total_spent) AS avg_customer_value,
    AVG(total_spent / NULLIF(num_orders,0)) AS avg_order_value_per_customer
FROM customer_spend;





---📦 Operations Metrics
--Average Delivery Time
SELECT 
    AVG(order_delivered_customer_date - order_purchase_timestamp) AS avg_delivery_days
FROM olist_orders
WHERE order_status = 'delivered';

--late delivery rate    
SELECT 
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END)::decimal 
    / COUNT(*) AS late_delivery_rate
FROM olist_orders
WHERE order_status = 'delivered';

--Freight % of Total Order Cost
SELECT 
    SUM(freight_value) / SUM(price + freight_value) AS freight_pct
FROM olist_order_items;

---⭐ Experience Metrics
--Average Review Score by Category
SELECT 
    p.product_category_name,
    AVG(r.review_score) AS avg_review_score
FROM olist_order_items i
JOIN olist_products p ON i.product_id = p.product_id
JOIN olist_order_reviews r ON i.order_id = r.order_id
GROUP BY p.product_category_name
ORDER BY avg_review_score DESC;
