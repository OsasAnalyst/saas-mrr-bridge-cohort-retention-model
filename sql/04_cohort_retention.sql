SELECT * FROM customers;
SELECT * FROM subscription_monthly;


SELECT
	cohort_month,
    months_since_signup,
    SUM(CASE WHEN status = "active" THEN mrr ELSE 0 END) AS active_mrr
FROM (
	SELECT
		c.signup_month AS cohort_month,
		s.customer_id,
		s.month,
		s.plan,
		s.mrr,
		s.status,
		TIMESTAMPDIFF(MONTH, c.signup_month, s.month) AS months_since_signup
	FROM subscription_monthly s
	JOIN customers c ON s.customer_id = c.customer_id
) x
GROUP BY cohort_month, months_since_signup
ORDER BY cohort_month, months_since_signup;


CREATE TABLE cohort_retention AS 
WITH cohort_mrr AS (
	SELECT
		c.signup_month AS cohort_month,
		TIMESTAMPDIFF(MONTH, c.signup_month, s.month) AS months_since_signup,
		SUM(CASE WHEN s.status = 'active' THEN s.mrr ELSE 0 END) AS active_mrr
	FROM subscription_monthly s
	JOIN customers c ON s.customer_id = c.customer_id
	GROUP BY c.signup_month, TIMESTAMPDIFF(MONTH, c.signup_month, s.month)
)
SELECT 
	cohort_month,
    months_since_signup,
    active_mrr,
    FIRST_VALUE(active_mrr) OVER(PARTITION BY cohort_month ORDER BY months_since_signup)  AS starting_mrr,
    ROUND(100 * active_mrr / FIRST_VALUE(active_mrr) OVER(PARTITION BY cohort_month ORDER BY months_since_signup), 1) AS retention_pct
FROM cohort_mrr
ORDER BY cohort_month, months_since_signup;
    