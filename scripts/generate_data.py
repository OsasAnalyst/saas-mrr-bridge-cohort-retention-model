"""
Synthetic SaaS subscription data generator.
Builds 36 months of a fictional B2B SaaS company's subscription base,
with realistic new customer growth, upgrades, downgrades, churn, and
reactivation. Output is a raw monthly snapshot table only - no
movement labels are included, since classifying new/expansion/
contraction/churn/reactivation is the SQL exercise this dataset feeds.
"""

import random
import csv
from datetime import date
from dateutil.relativedelta import relativedelta

random.seed(42)

N_MONTHS = 36
START_MONTH = date(2023, 1, 1)

PLANS = ["Starter", "Growth", "Scale"]
PLAN_MRR = {"Starter": 49, "Growth": 149, "Scale": 399}
PLAN_RANK = {"Starter": 0, "Growth": 1, "Scale": 2}

BASE_NEW_SIGNUPS = 35
SIGNUP_GROWTH = 0.025

SIGNUP_PLAN_WEIGHTS = {"Starter": 0.60, "Growth": 0.32, "Scale": 0.08}

CHURN_PROB = {"Starter": 0.032, "Growth": 0.020, "Scale": 0.012}

UPGRADE_PROB = {"Starter": 0.045, "Growth": 0.035, "Scale": 0.0}

DOWNGRADE_PROB = {"Starter": 0.0, "Growth": 0.018, "Scale": 0.022}

# Reactivation: probability per month a churned customer comes back,
# only within 6 months of churning, then treated as gone for good
REACTIVATION_PROB = 0.03
REACTIVATION_WINDOW_MONTHS = 6


def month_str(d):
    return d.strftime("%Y-%m")


def upgrade_plan(plan):
    order = ["Starter", "Growth", "Scale"]
    idx = order.index(plan)
    return order[idx + 1] if idx + 1 < len(order) else plan


def downgrade_plan(plan):
    order = ["Starter", "Growth", "Scale"]
    idx = order.index(plan)
    return order[idx - 1] if idx - 1 >= 0 else plan


def weighted_choice(weights_dict):
    plans = list(weights_dict.keys())
    weights = list(weights_dict.values())
    return random.choices(plans, weights=weights, k=1)[0]


def main():
    customers = {} 
    customer_records = [] 
    monthly_rows = [] 

    next_customer_id = 1
    expected_new = BASE_NEW_SIGNUPS

    for m in range(N_MONTHS):
        current_month_date = START_MONTH + relativedelta(months=m)
        current_month_label = month_str(current_month_date)

        # New signups this month
        n_new = max(0, round(random.gauss(expected_new, expected_new * 0.12)))
        for _ in range(n_new):
            cid = f"CUST{next_customer_id:05d}"
            next_customer_id += 1
            plan = weighted_choice(SIGNUP_PLAN_WEIGHTS)
            customers[cid] = {
                "plan": plan,
                "status": "active",
                "signup_month_idx": m,
                "churned_month_idx": None,
            }
            customer_records.append({
                "customer_id": cid,
                "signup_month": current_month_label,
                "initial_plan": plan,
            })

        expected_new *= (1 + SIGNUP_GROWTH)

        # Process existing customers: churn, upgrade, downgrade, reactivation
        for cid, rec in customers.items():
            if rec["status"] == "active" and rec["signup_month_idx"] < m:
                plan = rec["plan"]
                roll = random.random()
                if roll < CHURN_PROB[plan]:
                    rec["status"] = "churned"
                    rec["churned_month_idx"] = m
                elif roll < CHURN_PROB[plan] + UPGRADE_PROB[plan]:
                    rec["plan"] = upgrade_plan(plan)
                elif roll < CHURN_PROB[plan] + UPGRADE_PROB[plan] + DOWNGRADE_PROB[plan]:
                    rec["plan"] = downgrade_plan(plan)
            elif rec["status"] == "churned":
                months_since_churn = m - rec["churned_month_idx"]
                if 1 <= months_since_churn <= REACTIVATION_WINDOW_MONTHS:
                    if random.random() < REACTIVATION_PROB:
                        rec["status"] = "active"
                        rec["churned_month_idx"] = None
                        rec["plan"] = "Starter"

        # Emit this month's snapshot row for every customer who exists
        for cid, rec in customers.items():
            if rec["signup_month_idx"] <= m:
                is_active = (rec["status"] == "active")
                mrr = PLAN_MRR[rec["plan"]] if is_active else 0
                monthly_rows.append({
                    "customer_id": cid,
                    "month": current_month_label,
                    "plan": rec["plan"] if is_active else rec["plan"],
                    "mrr": mrr,
                    "status": "active" if is_active else "canceled",
                })

    # Write customers.csv
    with open("/home/claude/fpa_project/customers.csv", "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["customer_id", "signup_month", "initial_plan"])
        writer.writeheader()
        writer.writerows(customer_records)

    # Write subscription_monthly.csv
    with open("/home/claude/fpa_project/subscription_monthly.csv", "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["customer_id", "month", "plan", "mrr", "status"])
        writer.writeheader()
        writer.writerows(monthly_rows)

    print(f"Total customers ever signed up: {len(customers)}")
    print(f"Total monthly snapshot rows: {len(monthly_rows)}")
    active_end = sum(1 for r in customers.values() if r["status"] == "active")
    ending_mrr = sum(PLAN_MRR[r["plan"]] for r in customers.values() if r["status"] == "active")
    print(f"Active customers at end of month 36: {active_end}")
    print(f"Ending MRR at month 36: ${ending_mrr:,}")


if __name__ == "__main__":
    main()
