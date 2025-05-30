--- How many customers has ReelShot ever had?
SELECT COUNT (DISTINCT customer_id) AS total_customers
FROM subscriptions;

---What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?
SELECT
  DATE_TRUNC('month', start_date) AS start_of_month,
  COUNT(*) AS trial_count
FROM subscriptions
WHERE plan_id = 0
GROUP BY start_of_month
ORDER BY start_of_month;

--- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT plan_name, COUNT (*) as plan_count
FROM plans P
LEFT JOIN subscriptions S
ON P.plan_id = S.plan_id
WHERE S.start_date >= '2021-01-01'
GROUP BY P.plan_name
ORDER BY plan_count;

--- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT COUNT(DISTINCT customer_id),
    ROUND(
        COUNT(CASE WHEN plan_id = 4 THEN customer_id END)::decimal 
        / COUNT(DISTINCT customer_id), 1) AS churn_rate
FROM subscriptions;

--- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
SELECT COUNT (*) AS churn_after_trial, ROUND(COUNT(*)::numeric/1000, 2) AS churn_after_trial_percentage
FROM (
SELECT customer_id
FROM subscriptions
GROUP BY customer_id
HAVING COUNT(DISTINCT plan_id) = 2
  		AND COUNT( DISTINCT CASE WHEN plan_id IN (0, 4) THEN plan_id END) = 2
) as sub;

--- What is the number and percentage of customer plans after their initial free trial?
SELECT plan_id, COUNT(plan_id) AS number, ROUND(COUNT(plan_id)::numeric/1343, 2) AS after_trial_percentage
FROM subscriptions
WHERE plan_id IN (1,2,3)
GROUP BY plan_id;

--- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
SELECT 
  p.plan_name,
  COUNT(*) AS customer_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM (
  SELECT DISTINCT customer_id, 
         FIRST_VALUE(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS latest_plan
  FROM subscriptions
  WHERE start_date <= '2020-12-31'
) latest
JOIN plans p ON latest.latest_plan = p.plan_id
WHERE p.plan_name != 'churn'
GROUP BY p.plan_name
ORDER BY customer_count DESC;

--- How many customers have upgraded to an annual plan in 2020?
SELECT p.plan_name, COUNT (*) AS customer_count
FROM (
  SELECT DISTINCT customer_id, 
         FIRST_VALUE(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS latest_plan
  FROM subscriptions
  WHERE start_date <= '2020-12-31'
) latest
JOIN plans p ON p.plan_id = latest.latest_plan
WHERE P.plan_name = 'pro annual'
GROUP BY p.plan_name;

--- How many days on average does it take for a customer to an annual plan from the day they join ReelShot?
SELECT 
  AVG(s_annual.start_date - s_first.start_date) AS avg_days_to_annual
FROM 
  subscriptions s_annual
JOIN 
  (
    SELECT customer_id, MIN(start_date) AS start_date
    FROM subscriptions
    GROUP BY customer_id
  ) s_first
  ON s_annual.customer_id = s_first.customer_id
WHERE 
  s_annual.plan_id = 3;

--- Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
SELECT
  CONCAT((bin - 1) * 30 + 1, '–', bin * 30) AS bin_label,
  COUNT(*) AS number_customers,
  ROUND(AVG(diff_days), 1) AS avg_days
FROM (
  SELECT
    s1.customer_id,
    s2.start_date - s1.start_date AS diff_days,
    width_bucket(s2.start_date - s1.start_date, 0, 360, 12) AS bin
  FROM subscriptions s1
  JOIN subscriptions s2
    ON s1.customer_id = s2.customer_id
   AND s1.plan_id = 0 -- trial plan
   AND s2.plan_id = 3 -- pro annual
   AND s2.start_date > s1.start_date
) AS sub
GROUP BY bin
ORDER BY bin;

--- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
SELECT COUNT(DISTINCT s1.customer_id) AS downgraded_customers
FROM subscriptions s1
JOIN subscriptions s2
  ON s1.customer_id = s2.customer_id
WHERE s1.plan_id = 2 
  AND s2.plan_id = 1  
  AND s2.start_date > s1.start_date
  AND EXTRACT(YEAR FROM s2.start_date) = 2020;

--- Challenging Payment Question

WITH plan_prices AS (
  SELECT * FROM (
    VALUES
      (1, 9.90),
      (2, 19.90), 
      (3, 199.00) 
  ) AS p(plan_id, price)
),

--Add next plan date to stop billing at upgrade/churn
subscriptions_with_next AS (
  SELECT *,
         LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_start
  FROM subscriptions
),

-- Expand each plan into payment rows
payment_dates AS (
  SELECT
    s.customer_id,
    s.plan_id,
    (s.start_date + (i * interval '1 month'))::date AS payment_date,
    p.price
  FROM subscriptions_with_next s
  JOIN plan_prices p ON s.plan_id = p.plan_id
  JOIN generate_series(0, 11) AS i ON s.plan_id IN (1, 2)
  WHERE (s.start_date + (i * interval '1 month')) < COALESCE(s.next_start, DATE '2021-01-01')
),

-- Annual payments (one-off)
annual_payments AS (
  SELECT
    s.customer_id,
    s.plan_id,
    s.start_date AS payment_date,
    p.price
  FROM subscriptions s
  JOIN plan_prices p ON s.plan_id = p.plan_id
  WHERE s.plan_id = 3 AND s.start_date BETWEEN '2020-01-01' AND '2020-12-31'
)

-- Final union of payments
SELECT * FROM payment_dates
UNION ALL
SELECT * FROM annual_payments
ORDER BY customer_id, payment_date;
