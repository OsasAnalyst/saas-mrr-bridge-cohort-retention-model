SELECT * FROM mrr_bridge_monthly;
SELECT * FROM subscription_monthly;
SELECT * FROM mrr_movements;


-- Net Revenue Retention (NRR)
SELECT
	month,
	ROUND(100.0 * (starting_mrr + expansion_mrr + contraction_mrr + churned_mrr + reactivated_mrr) / starting_mrr, 1) AS nrr_pct
FROM mrr_bridge_monthly;


-- Gross Revenue Retention (GRR)
SELECT
	month,
	ROUND(100 * (starting_mrr + contraction_mrr + churned_mrr) / starting_mrr, 1) AS grr_pct
FROM mrr_bridge_monthly;


-- ARPU (Average Revenue Per Active Customer)
SELECT
	month,
    SUM(mrr) AS active_mrr,
	COUNT(*) AS active_customers,
    ROUND(SUM(mrr) / COUNT(*), 2) AS arpu
FROM subscription_monthly
WHERE status = "active"
GROUP BY month;


-- Logo churn rate
CREATE TABLE key_metrics AS
WITH active_count AS (
	SELECT
		month,
		SUM(mrr) AS active_mrr,
		COUNT(*) AS active_customers
	FROM subscription_monthly
	WHERE status = "active"
    GROUP BY month
),
churn_counts AS (
SELECT
	month,
    COUNT(*) AS churned_customers
FROM mrr_movements
WHERE movement_type = "churned"
GROUP BY month
),
combined AS (
	SELECT 
		b.month,
		b.starting_mrr,
		b.new_mrr,
		b.expansion_mrr,
		b.contraction_mrr,
		b.churned_mrr,
		b.reactivated_mrr,
		b.ending_mrr,
		a.active_mrr,
		a.active_customers,
		LAG(a.active_customers) OVER(ORDER BY b.month) AS prev_active_customers,
		c.churned_customers
	FROM mrr_bridge_monthly b
	JOIN active_count a ON b.month = a.month
	LEFT JOIN churn_counts c ON c.month = b.month
)
SELECT
	month,
    ROUND(100 * (starting_mrr + expansion_mrr + contraction_mrr + churned_mrr + reactivated_mrr) / NULLIF(starting_mrr,0), 1) AS nrr_pct,
    ROUND(100 * (starting_mrr + contraction_mrr + churned_mrr) / NULLIF(starting_mrr,0), 1) AS grr_pct,
    ROUND(active_mrr / active_customers, 1) AS arpu,
    ROUND(100.0 * COALESCE(churned_customers,0) / NULLIF(prev_active_customers,0), 1) AS logo_churn_pct
FROM combined
ORDER BY month;