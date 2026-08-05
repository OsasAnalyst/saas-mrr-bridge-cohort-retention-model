SELECT * FROM mrr_movements;

CREATE TABLE mrr_bridge_monthly AS
WITH monthly_movement AS (
	SELECT
		month,
		SUM(CASE WHEN movement_type = "new" THEN mrr ELSE 0 END) AS new_mrr,
		SUM(CASE WHEN movement_type = "expansion" THEN (mrr - prev_mrr) ELSE 0 END) AS expansion_mrr,
		SUM(CASE WHEN movement_type = "contraction" THEN (mrr - prev_mrr) ELSE 0 END) AS contraction_mrr,
		SUM(CASE WHEN movement_type = "churned" THEN -prev_mrr ELSE 0 END) AS churned_mrr,
		SUM(CASE WHEN movement_type = "reactivated" THEN mrr ELSE 0 END) AS reactivated_mrr
	FROM mrr_movements
	GROUP BY month),
monthly_ending AS (
	SELECT
		month,
		sum(mrr) AS ending_mrr
	FROM subscription_monthly
	WHERE status = "active"
	GROUP BY month),
bridge AS (
	SELECT 
		e.month,
		LAG(e.ending_mrr) OVER (ORDER BY e.month) as starting_mrr,
		m.new_mrr,
		m.expansion_mrr,
		m.contraction_mrr,
		m.churned_mrr,
		m.reactivated_mrr,
		e.ending_mrr
	FROM monthly_ending e
	JOIN monthly_movement m ON e.month = m.month
)
SELECT
	*,
    (COALESCE(starting_mrr, 0) + new_mrr + expansion_mrr + contraction_mrr + churned_mrr + reactivated_mrr) AS calculated_ending,
    (COALESCE(starting_mrr, 0) + new_mrr + expansion_mrr + contraction_mrr + churned_mrr + reactivated_mrr) - ending_mrr AS diff
FROM bridge
ORDER BY month;
