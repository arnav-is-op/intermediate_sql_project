WITH customer_ltv AS(

SELECT
customerkey,
cleaned_name,
SUM(total_net_revenue) AS total_ltv
-- as a guy with multiple purchaes ex id 180 will show up individually so we did total live time revenue in total_ltv as one value
FROM cohort_analysis
GROUP BY
customerkey,
cleaned_name
ORDER BY customerkey ASC
-- now to make them into high value low and mid val we must use percentile specially 25 and 75 percentile ie so this all must go inside a cte

) ,  customer_segments AS (

SELECT
PERCENTILE_CONT (0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile,
PERCENTILE_CONT (0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile
-- so less than 25 is low val and grater 75 is high val and between 25 to 75 is mid level
-- so then we can make this also as a cte and join both cte's then use case when statements to rank high,low or medium

FROM customer_ltv

) , segment_value AS (

SELECT
c.*,
CASE

  WHEN c.total_ltv < cs.ltv_25th_percentile THEN '1 - Low-Value'
  WHEN c.total_ltv <= cs.ltv_75th_percentile THEN '2- Mid-Value'
  ELSE '3 - High-Value'

END AS customer_segment

FROM customer_ltv c , customer_segments cs
-- no need to join we can use this simple , also
-- for 0.25 is 843 and for 0.75 its 5584 so ya our output is right
-- WE MAKE  another cte to find the total contributions of low,mid,high val customers so far in our sales so we need cte
)

SELECT
COUNT(customerkey) AS customer_count,
customer_segment,
SUM(total_ltv) AS total_1tv,
SUM(total_ltv) / COUNT(customerkey) AS avg_1tv

FROM segment_value

GROUP BY
customer_segment

ORDER BY
customer_segment DESC