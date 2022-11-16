use `restaurant`;
-- Table creation
CREATE TABLE sales (
  customer_id VARCHAR(20),
  order_date DATE,
  product_id INT
);
-- Value insertion
INSERT INTO sales
  (customer_id, order_date, product_id)
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
  product_id INT,
  product_name VARCHAR(5),
  price INT
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT * FROM members;
SELECT * FROM menu;
SELECT * FROM sales;

/*What is the total amount each customer spent at the restaurant?*/

SELECT
s.customer_id,
SUM(price) AS total_amount
FROM
sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY customer_id;

/*What was the first item from the menu purchased by each customer?*/

WITH ordered_sales_cte AS
(
 SELECT customer_id, order_date, product_name,
 DENSE_RANK() OVER(PARTITION BY s.customer_id
 ORDER BY s.order_date) AS ranks
 FROM sales AS s
 JOIN menu AS m
 ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM ordered_sales_cte
WHERE ranks = 1
GROUP BY customer_id, product_name;

/*How many days has each customer visited the restaurant?*/

SELECT
customer_id,
 COUNT(DISTINCT(order_date)) AS visit_count
FROM
sales
GROUP BY customer_id;
 
 /*What is the most purchased item on the menu and how many times was it purchased by all customers?*/
 
SELECT (COUNT(s.product_id)) AS most_purchased, product_name
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY most_purchased DESC
LIMIT 1;

/*Which item was the most popular one for each customer?*/

WITH fav_item_cte AS
(
 SELECT s.customer_id, m.product_name,
 COUNT(m.product_id) AS order_count,
 DENSE_RANK() OVER(PARTITION BY s.customer_id
 ORDER BY COUNT(m.product_id) DESC) AS toprank
FROM menu AS m
JOIN sales AS s
 ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM fav_item_cte
WHERE toprank = 1;

/*What is the total number of items and amount spent for each member before they became a member?*/

SELECT
s.customer_id,
 COUNT(DISTINCT s.product_id) AS unique_menu_item,
 SUM(mm.price) AS total_sales
FROM
sales AS s
JOIN
members AS m
 ON s.customer_id = m.customer_id
JOIN
menu AS mm
 ON s.product_id = mm.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;

/*If each customers’ $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer
have?*/

WITH price_points AS
 (
 SELECT *,
 CASE
 WHEN product_id = 1 THEN price * 20
 ELSE price * 10
 END AS points
 FROM
 menu
 )
 SELECT
s.customer_id,
 SUM(p.points) AS total_points
FROM
price_points AS p
JOIN
sales AS s
ON p.product_id = s.product_id
GROUP BY
s.customer_id
ORDER BY
customer_id;