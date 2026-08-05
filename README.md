# SaaS Revenue Bridge & Retention Analysis

**Meridian Cloud Solutions** - portfolio case study using synthetically generated subscription data.

A complete FP&A workflow that builds a monthly revenue bridge, tracks cohort retention, and translates the results into a leadership-facing deck and memo.

## The Problem

SaaS finance teams need to answer one question every month: what moved MRR, and why. Answering it well means classifying every customer-month as new, expansion, contraction, churn, or reactivation, aggregating those movements into a bridge, calculating retention metrics, and presenting a clear narrative to leadership. This project replicates that workflow end to end.

## The Approach

- Generated synthetic subscription data in Python covering 36 months of customer activity
- Built SQL logic to classify monthly MRR movements using window functions
- Aggregated movements into a monthly bridge, cohort retention curves, and key metrics
- Connected the processed tables to Excel for a dashboard with a waterfall chart and KPI cards
- Synthesized findings into a board deck and a one-page interpretive memo with a recommendation

## Key Findings

Findings below cover December 2025 and the full 36-month history.

- Ending MRR of $252,915, up $13,483 on the month. New business ($11,656 from 94 customers) and expansion ($7,100 from 44 accounts) covered churn and contraction.
- NRR at 100.8%, GRR at 97.7%. Both are healthy and stable, with GRR holding a 96-98% band across the full period.
- Dollar churn is rising even though the rate isn't. Logo churn has stayed flat at 1.5-3.0%, but churn in dollar terms has grown from $150-500 a month in early 2023 to $3,000-4,400 by late 2025, a scaling effect new business has to outrun every month.
- One cohort, October 2023, never recovered above 100% retention, sitting in an 81-91% band through month 12 while every other cohort climbed past 100% and kept growing.

## Skills Demonstrated

- SaaS metrics: MRR, NRR, GRR, logo churn, cohort retention, expansion versus contraction
- SQL: window functions, movement classification, cohort grouping, aggregated reporting
- Data workflow: Python data generation, MySQL staging, Excel dashboarding, PowerPoint narrative
- FP&A communication: executive summary, bridge commentary, risk identification, a recommendation grounded in the data
- Accounting discipline: traceability from raw transactions to summarized financials, consistent movement classification logic

## Next Steps

Natural extensions of this model: layering in budget data for a variance analysis view, and building a churn propensity model to flag at-risk accounts before they leave rather than explaining it after.

## Repository Structure

```
saas-mrr-bridge-cohort-retention-model/
├── README.md
├── data/
│   ├── raw/
│   │   ├── customers.csv
│   │   └── subscription_monthly.csv
│   └── processed/
│       ├── mrr_movements.csv
│       ├── mrr_bridge_monthly.csv
│       ├── cohort_retention.csv
│       └── key_metrics.csv
├── sql/
│   ├── 01_schema_and_load.sql
│   ├── 02_movement_classification.sql
│   ├── 03_mrr_bridge_waterfall.sql
│   ├── 04_cohort_retention.sql
│   └── 05_key_metrics.sql
├── dashboard/
│   └── mrr_bridge_dashboard.xlsx
├── deck/
│   └── board_deck.pptx
├── memo/
│   └── interpretive_memo.docx
└── scripts/
    └── generate_data.py
```

## Contact

Osaretin Idiagbonmwen, FP&A Analyst (CA, AAT)
idiagbonmwenosaretin@gmail.com

[linkedin.com/in/osaretin-idiagbonmwen-33ab85339](https://www.linkedin.com/in/osaretin-idiagbonmwen-33ab85339/)
