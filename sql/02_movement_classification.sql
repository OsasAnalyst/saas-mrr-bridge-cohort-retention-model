SELECT * FROM subscription_monthly;


CREATE TABLE mrr_movements AS
WITH movement_base AS (
    SELECT
        customer_id,
        month,
        plan,
        mrr,
        status,
        LAG(status) OVER (PARTITION BY customer_id ORDER BY month) AS prev_status,
        LAG(mrr) OVER (PARTITION BY customer_id ORDER BY month) AS prev_mrr
    FROM subscription_monthly
)
SELECT
    customer_id,
    month,
    plan,
    mrr,
    status,
    prev_status,
    prev_mrr,
    CASE
        WHEN prev_status IS NULL THEN 'new'
        WHEN prev_status = 'active' AND status = 'canceled' THEN 'churned'
        WHEN prev_status = 'canceled' AND status = 'active' THEN 'reactivated'
        WHEN prev_status = 'active' AND status = 'active' AND mrr > prev_mrr THEN 'expansion'
        WHEN prev_status = 'active' AND status = 'active' AND mrr < prev_mrr THEN 'contraction'
        WHEN prev_status IN ('active', 'canceled') AND status IN ('active', 'canceled') AND mrr = prev_mrr THEN 'no_change'
        ELSE 'unclassified'
    END AS movement_type
FROM movement_base;


SELECT movement_type, count(*)
FROM mrr_movements
GROUP BY movement_type;


SELECT COUNT(*)
FROM mrr_movements;
