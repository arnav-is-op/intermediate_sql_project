-- optimised view( it take less execution time)
-- EXPLAIN ANALYZE

CREATE VIEW cohort_analysis AS

WITH customer_revenue AS (

SELECT
s.customerkey,
s.orderdate,
SUM(s.quantity*s.netprice*s.exchangerate) AS total_net_revenue,
COUNT(s.orderkey) AS num_orders,
MAX(c.countryfull) AS countryfull,
MAX(c.age) AS age,
MAX(c.givenname) AS givenname,
MAX(c.surname) AS surname
-- but as we removed group by now we must assign an agg to those values orelse error will come.. so its recommended to use max agg function
FROM
sales s
INNER JOIN customer c ON s.customerkey = c.customerkey
-- In some cases inner join makes query fast but
GROUP BY
s.customerkey,
s.orderdate
-- c.countryfull,
-- c.age,
-- c.givenname,
-- c.surname
-- we see that even if we remove these group by nothing is changing that much we are getting out data.. so we remove this and make eour query optimised
)

SELECT
customerkey,
orderdate,
total_net_revenue,
CONCAT(TRIM(givenname), ' ' , TRIM(surname)) AS cleaned_name,
countryfull,
age,
MIN(cr.orderdate) OVER(PARTITION BY cr.customerkey) AS first_purchase_date,
EXTRACT(YEAR FROM MIN(cr.orderdate) OVER(PARTITION BY cr.customerkey) ) AS cohort_year
FROM
customer_revenue cr





/*

NOT OPTIMISED VIEW :-
ie taking more execution time.. so we made some adjustments and got an optimised one above that take less execution time

-- creating a view for adv analysis and other project questions.

-- DROP VIEW cohort_analysis 
CREATE VIEW cohort_analysis AS

WITH customer_revenue AS (

SELECT
s.customerkey,
s.orderdate,
SUM(s.quantity*s.netprice*s.exchangerate) AS total_net_revenue,
COUNT(s.orderkey) AS num_orders,
--c.* -- it indicate all info from c table.. as we are joining na..  using this we seee the table and find out what values we need and so we keep that only here
c.countryfull,
c.age,
c.givenname,
c.surname
FROM
sales s
LEFT JOIN customer c ON s.customerkey = c.customerkey
GROUP BY
s.customerkey,
s.orderdate,
c.countryfull,
c.age,
c.givenname,
c.surname

-- now for all these customers we need to make a cohort na so we need window function so keep this all inside a cte..

)

SELECT
-- cr.*, we can use this or
customerkey,
orderdate,
total_net_revenue,
CONCAT(TRIM(givenname), ' ' , TRIM(surname)) AS cleaned_name,
-- that single quotes are for giving space between two letters ie given name and surname.. we used trim to eleminate any existing soaces between two names
countryfull,
age,
MIN(cr.orderdate) OVER(PARTITION BY cr.customerkey) AS first_purchase_date,
-- this line of code is for cohort date
EXTRACT(YEAR FROM MIN(cr.orderdate) OVER(PARTITION BY cr.customerkey) ) AS cohort_year
-- this line gives first purchase year ie cohort year
FROM
customer_revenue cr

*/