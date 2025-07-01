CREATE TABLE customers(
customer_id SERIAL PRIMARY KEY,
full_name TEXT NOT NULL,
country TEXT NOT NULL
);


CREATE TABLE products(
product_id SERIAL PRIMARY KEY,
product_name TEXT NOT NULL,
category TEXT NOT NULL,
unit_price_usd NUMERIC(8,2));

CREATE TABLE orders (
order_id   SERIAL PRIMARY KEY,
customer_id  INT  REFERENCES customers(customer_id),
order_date  DATE   NOT NULL,
 order_meta JSONB  NOT NULL  
);


CREATE TABLE order_lines (
order_id  INT REFERENCES orders(order_id),
product_id INT REFERENCES products(product_id),
qty  INT  NOT NULL,
line_price_usd NUMERIC(10,2)  NOT NULL,
 PRIMARY KEY (order_id, product_id)
);


INSERT INTO customers (full_name, country) VALUES
  ('Alice Smith',   'USA'),
  ('Bala Iyer',     'India'),
  ('Chen Wei',      'Singapore');
  
INSERT INTO products (product_name, category, unit_price_usd) VALUES
  ('Blood Glucose Monitor',  'Medical Devices',  40.00),
  ('N95 Mask Box (20)',      'PPE',             25.00),
  ('Tele-consult Credit',    'Services',        15.00);


INSERT INTO orders (customer_id, order_date, order_meta) VALUES
  (1, '2025-05-01',
   '{
      "payment": { "method": "card", "card_type": "AMEX" },
      "promo":   { "code": "NEW10", "discount_usd": 5 },
      "ship":    { "mode": "ground", "cost_usd": 8.5 }
    }'::jsonb);
    
INSERT INTO orders (customer_id, order_date, order_meta) VALUES
  (2, '2025-05-02',
   '{
      "payment": { "method": "upi", "provider": "GPay" },
      "ship":    { "mode": "air", "cost_usd": 15 }
    }'::jsonb);
    
INSERT INTO order_lines VALUES
  (1, 1, 2, 80.00),  
  (1, 3, 1, 15.00),  
  (2, 2, 4, 100.00); 
  
-- Q1. Net total per order (after promo, plus shipping)
  
  
WITH g_totals AS (
SELECT order_id, SUM(line_price_usd) AS gross_line_total
FROM order_lines
GROUP BY order_id),
m_info AS(
SELECT order_id,
coalesce(order_meta->'promo'->>'discount_usd', '0')::numeric AS promo_discount,
coalesce(order_meta->'ship'->> 'cost_usd', '0'):: numeric AS shipping_cost
FROM orders)
SELECT g.order_id, g.gross_line_total, m.promo_discount,m.shipping_cost,
(g.gross_line_total - m.promo_discount + m.shipping_cost) AS net_total
FROM g_totals g JOIN m_info m ON 
g.order_id = m.order_id;


-- Q2. Top-selling product category (by revenue)

SELECT p.category, SUM(ol.line_price_usd-(ol.line_price_usd/t.total_line_price)*coalesce(o.order_meta->'promo'->>'discount_usd', '0')::numeric)
AS total_revenue
FROM order_lines ol
JOIN products p on ol.product_id = p.product_id
JOIN orders o on ol.order_id= o.order_id
JOIN(SELECT order_id, sum(line_price_usd) AS total_line_price
FROM order_lines
GROUP BY order_id) t on ol.order_id=t.order_id
GROUP BY p.category
ORDER BY total_revenue desc
LIMIT 1;

-- Q3. Customers with >1 card brand used

SELECT customer_id
FROM orders
WHERE order_meta->'payment'->>'method' = 'card'
GROUP BY customer_id
HAVING COUNT(distinct order_meta->'payment'->>'card_type')>=2;

-- Q4. Monthly order funnel view

WITH order_info  AS(
SELECT order_id,COALESCE(order_meta -> 'promo' ->> 'discount_usd', '0')::numeric AS discount_usd, COALESCE(order_meta -> 'ship'  ->> 'cost_usd', '0')::numeric AS shipping_usd, order_date,
customer_id FROM orders) 
SELECT DATE_TRUNC('month',o.order_date) as month,
COUNT(*) AS orders,
COUNT(distinct o.customer_id)AS distict_customers,
SUM( ol.line_price_usd) AS total_gross,
SUM(ol.line_price_usd)-SUM(oi.discount_usd) + SUM(oi.shipping_usd) AS total_net FROM orders o
JOIN order_lines ol ON o.order_id= ol.order_id
JOIN order_info oi ON o.order_id= oi.order_id
WHERE DATE_TRUNC('month', o.order_date)= DATE '2025-05-01'
GROUP BY month
ORDER BY month;

-- Q5. Country-level basket analysis

WITH data_of_orders AS(
SELECT c.country,o.order_id,sum(ol.qty) AS total_items, o.order_meta->'payment'->>'method' AS pay_method
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id JOIN order_lines ol ON o.order_id = ol.order_id
GROUP BY c.country,o.order_id,pay_method),

avg_items AS (SELECT country, AVG(total_items) AS avg_per_order FROM data_of_orders GROUP BY country),
pre_payment AS( SELECT country,pay_method ,ROW_NUMBER() OVER (PARTITION BY country ORDER BY COUNT(*) DESC, pay_method) AS rn FROM data_of_orders
GROUP BY country, pay_method)
SELECT a.country,a.avg_per_order,p.pay_method AS pre_payment FROM avg_items a JOIN pre_payment p ON a.country=p.country WHERE p.rn=1 ORDER BY a.country;





