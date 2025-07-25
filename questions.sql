-- Case Study Questions

select * from members
select * from sales
select * from menu


-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
    customer_id, SUM(price) AS Total_Amount
FROM
    menu
        JOIN
    sales ON menu.product_id = sales.product_id
GROUP BY customer_id

-- 2. How many days has each customer visited the restaurant?
SELECT 
    customer_id, COUNT(DISTINCT order_date) AS visit_days
FROM
    sales
GROUP BY customer_id
 

-- 3. What was the first item from the menu purchased by each customer?
SELECT 
    product_name, customer_id, order_date, ROW_NUMBER() OVER 
    (PARTITION BY customer_id ORDER BY order_date) as rank_

FROM
    menu
        JOIN
    sales ON menu.product_id = sales.product_id


-- 4. What is the most purchased item on the menu and how many 
-- times was it purchased by all customers?
SELECT 
    product_name, COUNT(*) AS Total_Purchases
FROM
    menu
        JOIN
    sales ON menu.product_id = sales.product_id
GROUP BY product_name
ORDER BY Total_Purchases DESC
LIMIT 1


-- 5. Which item was the most popular for each customer?
select customer_id, product_name, order_count
from
(
SELECT 
    customer_id, product_name, count(*) as order_count, row_number() 
    over (partition by customer_id order by count(*)  desc) as rank_
FROM
    menu
        JOIN
    sales ON menu.product_id = sales.product_id
group by customer_id, product_name ) as t1
where rank_ = 1


-- 6. Which item was purchased first by the customer after they became a member?
SELECT customer_id, order_date, product_name
FROM
(
SELECT 
    s.customer_id, mem.join_date, m.product_name, s.order_date, row_number() 
    over(partition by s.customer_id order by s.order_date) as rank_
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
    join 
    members mem on s.customer_id = mem.customer_id
WHERE s.order_date >= mem.join_date ) as t1
where rank_ = 1


-- 7. Which item was purchased just before the customer became a member?
SELECT customer_id, order_date, product_name
FROM
(
SELECT 
    s.customer_id, mem.join_date, m.product_name, s.order_date, row_number() 
    over(partition by s.customer_id order by s.order_date desc) as rank_
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
    join 
    members mem on s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date ) as t1
where rank_ = 1

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
    s.customer_id, Count(*) as Total_Item, SUM(m.price) as Total_Amount 
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
    join 
    members mem on s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date 
group by s.customer_id


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
    s.customer_id, 
    SUM( 
    CASE 
    WHEN m.product_name = 'sushi' THEN m.price * 20
    ELSE m.price * 10
    END
    ) AS Total_point
FROM
    menu m
        JOIN
    sales s ON m.product_id = s.product_id
GROUP BY s.customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT 
    s.customer_id,
    SUM(
        CASE 
            -- Double points for all items in the first 7 days after joining
            WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY)
            THEN m.price * 20

            -- Double points only for sushi outside of first 7 days
            WHEN m.product_name = 'sushi' THEN m.price * 20

            -- Regular points otherwise
            ELSE m.price * 10
        END
    ) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY s.customer_id;
