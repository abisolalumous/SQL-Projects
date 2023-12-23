-- 1. What is the total amount each customer spent at the restaurant?
/*SELECT customer_id,SUM(price)AS customer_spent
FROM sales S
JOIN menu M ON S.product_id=M.product_id
GROUP BY customer_id
ORDER BY customer_spent*/
-- ANSWER
-- Customer A spent $76 at dannys_diner
-- Customer B spent $74 at dannys_diner
-- Customer C spent $36 at dannys_diner

-- 2.How many days has each customer visited the restaurant?

/*SELECT customer_id,COUNT(DISTINCT order_date)AS number_of_days_visited
FROM sales
GROUP BY customer_id
*/
-- ANSWER
-- insert table
-- Customer A visited 4 times
-- Customer B visited 6 times
-- Customer A visited 2 times

-- 3. What was the first item from the menu purchased by each customer

/*WITH  ordered_sales AS(
SELECT 
customer_id,
product_name,
order_date,
DENSE_RANK() OVER(PARTITION BY customer_id
ORDER BY order_date) AS order_rank
FROM  sales S
JOIN menu M ON S.product_id=M.product_id)
SELECT customer_id,product_name
FROM  ordered_sales
WHERE order_rank=1
GROUP BY customer_id
,product_name*/
-- ANSWER
-- Customer A ordered sushi and curry first .There was no timstamp it was difficult to asertain what was ordered first between the two
-- Customer B ordered curry first
-- Customer C ramen first


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
/*SELECT product_name,COUNT(product_name)AS quantity
FROM sales S
JOIN menu M ON S.product_id=M.product_id
GROUP BY product_name
ORDER BY quantity DESC
LIMIT 1*/

-- ANSWER
-- The most purchases item on the menu is Ramen it was bought 8 times

-- 5.Which item was the most popular for each customer
/*WITH most_popular AS(
SELECT customer_id,
product_name,
COUNT(product_name) AS order_count,
DENSE_RANK() OVER(
PARTITION BY customer_id ORDER BY COUNT(customer_id)DESC) AS product_RANK
FROM sales S
JOIN menu M ON S.product_id=M.product_id
GROUP BY product_name,customer_id
)
SELECT
customer_id,
product_name,
order_count
FROM most_popular
WHERE product_rank =1*/
-- we can see that the customer A and Customer C have  1 favourite PRODUCT
-- Customer A  and Customer c favorite product is Ramen
-- While customer B loved all three meals


-- 6.Which item was purchased first by the customer after they became a member
	/*WITH join_as_member AS(
 SELECT members.customer_id,
 sales.product_id,
 ROW_NUMBER() OVER (PARTITION BY members.customer_id ORDER BY sales.order_date)
 AS row_num
 FROM  sales 
 JOIN members  ON Sales.customer_id=members.customer_id AND sales.order_date>members.join_date
 )
 SELECT customer_id,product_name
 FROM join_as_member JOIN menu ON join_as_member.product_id=menu.product_id
 WHERE  row_num=1
 ORDER BY customer_id ASC*/	
 -- ANSWER Customer A's first product was Ramen while Customer B's was sushi
 
 
 -- 7.Which item was purchased just before the customer became a member?
 /*WITH prior_to_member AS(
	 SELECT members.customer_id,
 sales.product_id,
 ROW_NUMBER() OVER (PARTITION BY members.customer_id ORDER BY sales.order_date DESC)
 AS   product_Rank
 FROM members 
 JOIN   sales ON Sales.customer_id=members.customer_id AND sales.order_date<members.join_date
 )
 SELECT customer_id,product_name
 FROM prior_to_member JOIN menu ON prior_to_member.product_id=menu.product_id
 WHERE  product_rank=1
 ORDER BY customer_id ASC	*/

-- ANSWER
-- Customer A and B puchase before becoming a mamber was SUSHI

-- 8.What is the total items and amount spent for each member before they became a member

/*SELECT members.customer_id,
 COUNT(sales.product_id) AS total_items,
 SUM(menu.price) AS total_price
 FROM members 
 JOIN   sales ON sales.customer_id=members.customer_id AND sales.order_date < members.join_date
 JOIN menu ON menu.product_id=sales.product_id
 GROUP BY members.customer_id
 ORDER BY members.customer_id*/
 
 -- ANSWER  Customer A spent $25 on two items while Customer B spent $40 on three items.
 
 
 -- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have
 /*WITH points_cte AS 
 (
 SELECT menu.product_id,
 CASE 
	WHEN product_id=1 THEN price * 20
    ELSE price *10
    END AS points
    FROM menu
 )
 SELECT
 sales.customer_id,
 SUM(points_cte.points) AS total_points
 FROM points_cte
 JOIN sales ON sales.product_id=points_cte.product_id
 GROUP BY sales.customer_id
 ORDER BY sales.customer_id*/
 
 -- ANSWER The total _points per customer is Customer A 860,Customer B 940,Customer C 360 
 
 -- 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
/*WITH dates_cte AS (
SELECT 
customer_id,
join_date,
join_date +6 AS valid_date,
LAST_DAY(DATE_ADD('2021-01-31',INTERVAL 1 MONTH))
			AS Last_date
FROM dannys_diner.members
)
SELECT sales.customer_id,
sum(CASE
	WHEN menu.product_name='sushi'THEN 2 * 10 *menu.price
    WHEN sales.order_date BETWEEN dates.join_date AND dates.valid_date THEN 2* 10*menu.price
    ELSE 10* menu.price END )AS Total_points
    FROM dannys_diner.sales
    JOIN dates_cte AS dates
    ON sales.customer_id=dates.customer_id
    AND sales.order_date <= dates.Last_date
    JOIN menu
    ON sales.product_id=menu.product_id
    GROUP BY sales.customer_id*/
    
    -- ANSWER 
    -- As of the end of January  Customer A had 1370 points and customer B has 940 points
    
    -- Bonus Questions
    SELECT sales.customer_id,
			sales.order_date,
            menu.product_name,
            menu.price,
            CASE WHEN members.join_date>sales.order_date THEN 'N'
				 WHEN members.join_date<=sales.order_date THEN 'Y'
                 ELSE'N'END AS member_status
FROM dannys_diner.sales
			LEFT JOIN members ON members.customer_id=sales.customer_id
            JOIN dannys_diner.menu ON menu.product_id=sales.product_id
            ORDER BY sales.customer_id,sales.order_date