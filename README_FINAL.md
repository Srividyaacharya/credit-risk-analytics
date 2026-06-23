# Credit Risk Analytics — BFSI Data Analyst Portfolio Project

> End-to-end credit risk analysis of 149,999 borrowers  
> Tools: MS SQL Server | Python | Power BI  
> Domain: Banking, Financial Services & Insurance (BFSI)

---

## Dashboard Preview

### Page 1 — Executive Overview
![Executive Overview](powerbi/screenshots/page1_executive.png)

### Page 2 — Risk Drivers & Delinquency Analysis
![Risk Drivers](powerbi/screenshots/page2_delinquency.png)

### Page 3 — Customer Risk Segmentation & Scoring
![Risk Segmentation](powerbi/screenshots/page3_segmentation.png)

---

## Project Overview

A financial institution wants to understand which borrowers are most likely
to default on their loans — enabling smarter credit decisions, risk-based
pricing, and early intervention before accounts go bad.

This project builds a complete analytics pipeline:

```
data/cs-training.csv (raw)
    │
    ├── SQL → structured queries → segment analysis → Power BI views
    │
    └── Python → data cleaning → EDA → statistical testing
                    │
                    └── outputs/cs_cleaned.csv → Power BI dashboard
```

---

## Key Findings

| Finding | Value | Test Used |
|---------|-------|-----------|
| Overall default rate | 6.68% | Descriptive stats |
| Highest risk age group | 25-34 (11.12% default) | T-Test p < 0.001 |
| Delinquency — strongest predictor | IV = 1.39 | IV / WOE analysis |
| 5+ late payments vs clean customers | 57.2% vs 2.7% — 21x difference | Chi-Square p < 0.001 |
| Credit utilization — second predictor | IV = 1.00 | IV / WOE analysis |
| High util (70%+) vs low util (<30%) | 19.88% vs 2.12% — 9x difference | Chi-Square p < 0.001 |
| Low income vs High income default rate | 9.43% vs 4.62% | Chi-Square p < 0.001 |
| All patterns statistically validated | All p < 0.001 | T-Test + Chi-Square |

---

## Tools Used

| Tool | Version | Purpose |
|------|---------|---------|
| MS SQL Server (SSMS) | 2019+ | Data storage, 14-section analysis, Power BI views |
| Python — Pandas | 2.x | Data cleaning, feature engineering |
| Python — Matplotlib / Seaborn | Latest | 7 EDA charts |
| Python — Scipy | Latest | T-Test, Chi-Square, Skewness, Correlation |
| Python — Custom functions | — | WOE and Information Value (IV) |
| Power BI Desktop | Latest | 3-page interactive dashboard with slicers |

---

## Dataset

**Source:** [Give Me Some Credit — Kaggle](https://www.kaggle.com/c/GiveMeSomeCredit/data)

| Item | Detail |
|------|--------|
| Original rows | 150,000 |
| Rows after cleaning | 149,999 |
| Input columns | 11 features |
| Target column | SeriousDlqin2yrs (1 = defaulted) |
| Default rate | 6.68% |
| CustomerID | C001 to C150000 |

### Missing Values

| Column | Missing | % | Fix |
|--------|---------|---|-----|
| MonthlyIncome | 29,731 | 19.82% | Filled with median ($5,400) |
| NumberOfDependents | 3,924 | 2.62% | Filled with 0 |

### Cleaning Approach

```python
# Step 1: Remove only age <= 0 (1 invalid row)
df = df[df['age'] > 0].copy()

# Step 2: Fill missing values — keep ALL rows
df['MonthlyIncome']      = df['MonthlyIncome'].fillna(df['MonthlyIncome'].median())
df['NumberOfDependents'] = df['NumberOfDependents'].fillna(0)

# Step 3: Cap outliers at 99th percentile — do NOT remove rows
for col in ['RevolvingUtilizationOfUnsecuredLines', 'DebtRatio', 'MonthlyIncome']:
    df[col] = df[col].clip(upper=df[col].quantile(0.99))

# Result: 149,999 rows retained
```

> **Why cap instead of remove?**
> Removing rows with extreme values would drop 25,934 rows (17.3%).
> Capping at the 99th percentile preserves all customers while
> controlling the influence of extreme values on the analysis.

---

## Project Structure

```
credit-risk-analytics/
│
├── data/
│   └── cs-training.csv                         ← raw dataset from Kaggle
│
├── notebooks/
│   ├── CreditRisk_EDA.ipynb                    ← 7 EDA charts
│   └── CreditRisk_Statistical_Analysis.ipynb   ← 5 statistical tests
│
├── sql/
│   ├── CreditRisk_SQL_Final.sql                ← 14 SQL sections
│   ├── CreditRisk_Segment_Queries.sql          ← segment default rate queries
│   └── screenshots/
│       ├── 01_portfolio_overview.png
│       ├── 02_default_by_age.png
│       ├── 03_default_by_income.png
│       ├── 04_delinquency_analysis.png
│       ├── 05_credit_utilization.png
│       ├── 06_severity_comparison.png
│       └── 07_executive_summary.png
│
├── powerbi/
│   ├── CreditRisk_Dashboard.pbix               ← Power BI dashboard
│   └── screenshots/
│       ├── page1_executive.png
│       ├── page2_delinquency.png
│       └── page3_segmentation.png
│
├── outputs/
│   └── cs_cleaned.csv                          ← Python cleaned CSV used by Power BI
│
└── README.md
```

---

## Section 1 — SQL Analytics

**Files:** `sql/CreditRisk_SQL_Final.sql` | `sql/CreditRisk_Segment_Queries.sql`

**Database:** MS SQL Server | Database: CreditRiskDB | Table: credit_risk

### What the SQL covers

| # | Section | Key Output |
|---|---------|-----------|
| 1 | Database & Table Setup | CreditRiskDB created, 150K rows imported |
| 2 | Portfolio Overview | 6.68% default rate, 10,026 defaulters confirmed |
| 3 | Customer Demographics | Default rate by age, income, dependents |
| 4 | Delinquency Analysis | 30/60/90+ DPD severity, repeat vs first-time |
| 5 | Credit Utilization | Utilization bands, debt ratio segmentation |
| 6 | Combined Risk Analysis | High util + high debt ratio together |
| 7 | Portfolio Quality Buckets | Good / Watch / Stressed / Defaulted |
| 8 | Top 20 Riskiest Customers | CustomerID + risk score + key variables |
| 9 | Window Functions | RANK(), NTILE() — income deciles |
| 10 | Executive Summary | All KPIs in one query |
| 11 | Segment Default Rates | Income, utilization, delinquency, debt ratio |
| 12 | Severity Comparison | 30+ vs 60+ vs 90+ DPD default rates |
| 13 | Age × Income Matrix | Combined segment cross-analysis |
| 14 | Power BI Views | vw_RiskSummary, vw_CustomerRiskBands |

### Sample Result — Delinquency Impact

| Delinquency Band | Customers | Default Rate |
|-----------------|-----------|-------------|
| 0 incidents (clean) | 130,219 | 2.73% |
| 1 incident | 7,852 | 12.21% |
| 2-4 incidents | 8,104 | 29.90% |
| 5+ incidents | 3,824 | 57.22% |

> Customers with 5+ late payments default at **21x** the rate of clean customers

### SQL Screenshots
Results saved in `sql/screenshots/` — each major query result captured from SSMS.

---

## Section 2 — Python EDA

**File:** `notebooks/CreditRisk_EDA.ipynb`

**Input:** `data/cs-training.csv`
**Output:** `outputs/cs_cleaned.csv` (used by Power BI)

### Charts Produced

| Chart | Key Finding |
|-------|------------|
| `01_default_overview.png` | 6.68% default rate — severe class imbalance |
| `02_default_by_age.png` | Ages 25-34 default at 11.12% — highest risk group |
| `03_credit_utilization.png` | High util (70%+) = 19.88% default — 9x more than Low |
| `04_income_vs_default.png` | Low income defaults at 9.43% vs High income 4.62% |
| `05_delinquency_vs_default.png` | Strongest predictor — escalates sharply per incident |
| `06_missing_data.png` | 19.82% MonthlyIncome missing — filled with median |
| `07_risk_segmentation.png` | Full portfolio split across Low / Medium / High bands |

### Descriptive Statistics

| Metric | Age | Monthly Income | Debt Ratio | Utilization |
|--------|-----|----------------|------------|-------------|
| Mean | 52.3 | $6,805 | 0.35 | 0.32 |
| Median | 52.0 | $5,400 | 0.23 | 0.16 |
| Std Dev | 14.8 | $5,210 | 0.27 | 0.27 |

> Income mean ($6,805) is much higher than median ($5,400) due to
> high earners skewing the average. Median is the correct measure for income.

---

## Section 3 — Statistical Analysis

**File:** `notebooks/CreditRisk_Statistical_Analysis.ipynb`

All patterns found in EDA are **statistically validated** — nothing is
based on visual impression alone.

### T-Test — Are Defaulters Truly Different?

| Variable | Non-Default Avg | Default Avg | P-Value | Significant |
|----------|----------------|-------------|---------|-------------|
| Monthly Income | $6,194 | $5,429 | < 0.001 | Yes ✓ |
| Age | 52.8 years | 45.9 years | < 0.001 | Yes ✓ |
| Credit Utilization | 0.30 | 0.70 | < 0.001 | Yes ✓ |

> P-value < 0.05 = the difference is REAL, not by chance.
> Defaulters earn less, are younger, and use 2x more credit.

### Chi-Square — Is the Category Pattern Real?

| Variable | Chi-Square | P-Value | Significant |
|----------|-----------|---------|-------------|
| Delinquency Band | 23,092.7 | < 0.001 | Yes ✓ |
| Utilization Band | 10,669.1 | < 0.001 | Yes ✓ |
| Age Band | 2,018.8 | < 0.001 | Yes ✓ |
| Income Band | 496.2 | < 0.001 | Yes ✓ |

> All 4 category patterns are statistically significant — none are coincidences.

### Information Value (IV) — Which Column Predicts Best?

| Variable | IV | Predictive Strength |
|----------|----|-------------------|
| Delinquency History | 1.39 | Very Strong |
| Credit Utilization | 1.00 | Very Strong |
| Age | 0.25 | Medium |
| Monthly Income | 0.05 | Weak |

> Delinquency history (IV = 1.39) is the single best predictor.
> Income alone (IV = 0.05) is surprisingly weak — it must be combined
> with other variables to be useful.

### Skewness Analysis

| Variable | Skewness | Interpretation |
|----------|----------|----------------|
| Age | 0.23 | Symmetric — mean is reliable |
| Credit Utilization | 0.91 | Mild skew — use median |
| Monthly Income | 112.9 | Heavy skew — always use median |
| Total Delinquencies | 21.3 | Heavy skew — use median |

---

## Section 4 — Power BI Dashboard

**File:** `powerbi/CreditRisk_Dashboard.pbix`
**Data source:** `outputs/cs_cleaned.csv`

### Page 1 — Executive Overview
Board-level snapshot. A senior manager understands the full
portfolio health in under 30 seconds.

**Visuals:**
- 6 KPI cards: Total Customers, Total Defaulters, Default Rate,
  Median Income, Median Debt Ratio, Credit Utilization
- Portfolio Composition donut (defaulters vs non-defaulters)
- Default Rate by Age Group (horizontal bar)
- Default Rate by Income Segment (column chart)
- Default Rate by Credit Utilization (column chart)
- Key Findings text box

### Page 2 — Risk Drivers & Delinquency Analysis
Deep-dive into delinquency severity levels. Colour-coded bars
(green → amber → orange → dark red) show risk escalation visually.

**Visuals:**
- 4 KPI cards: High Risk %, Avg 90+ DPD, Customers with 90+ DPD %, Avg Credit Lines
- Impact of 90+ Day Delinquencies on Default Risk (colour-coded bar)
- Impact of 60+ Day Delinquencies on Default Risk (colour-coded bar)
- Impact of 30+ Day Delinquencies on Default Risk (colour-coded bar)
- Default Rate by Age × Income Segment (matrix with conditional formatting)
- Interactive slicers: Age Group, Income Band
- Key Risk Drivers text box

**Why 3 separate delinquency charts?**
Banks classify delinquency by severity — 30+ DPD (mild), 60+ DPD (serious),
90+ DPD (near-default). Showing each separately reveals escalation:
30+ = 40.50%, 60+ = 57.22%, 90+ = 60.45%. This is how real bank
risk teams monitor their portfolio.

### Page 3 — Customer Risk Segmentation & Scoring
Risk band classification for every customer. Interactive slicers
let the risk manager filter to any segment instantly.

**Visuals:**
- 4 KPI cards: High Risk Customers (red), High Risk %, High Risk Default Rate,
  Low Risk Customers (green)
- Customer Distribution by Risk Tier (donut — green/amber/red)
- Default Rate by Risk Tier (colour-matched bar chart)
- Risk Tier by Income Segment (matrix with conditional formatting)
- Customer Profile — Risk Tier × Age Group (stacked bar)
- Interactive slicers: Age Group, Income Band
- Key Risk Drivers text box

### Risk Segmentation Results

| Risk Band | Customers | Default Rate | Bank Decision |
|-----------|-----------|-------------|---------------|
| Low Risk | 89,000 | 2.57% | Auto Approve |
| Medium Risk | 28,000 | 2.84% | Manual Review |
| High Risk | 33,000 | 20.68% | Require Collateral |

> High Risk customers default at **8x** the rate of Low Risk customers

---

## How to Run

### Prerequisites
```bash
pip install pandas numpy matplotlib seaborn scipy
```

### Step 1 — SQL
```
1. Open SQL Server Management Studio (SSMS)
2. Open sql/CreditRisk_SQL_Final.sql
3. Run Section 1 first — creates CreditRiskDB and imports cs-training.csv
4. Run Sections 2-13 for analysis queries
5. Run Section 14 to create Power BI views
6. Open sql/CreditRisk_Segment_Queries.sql for segment default rate analysis
```

### Step 2 — Python Notebooks
```
Run in order:
1. notebooks/CreditRisk_EDA.ipynb
   → Cleans data and saves outputs/cs_cleaned.csv

2. notebooks/CreditRisk_Statistical_Analysis.ipynb
   → Runs T-Test, Chi-Square, IV/WOE on the cleaned data
```

### Step 3 — Power BI
```
1. Open powerbi/CreditRisk_Dashboard.pbix
2. Home → Transform Data → update source path to your local
   outputs/cs_cleaned.csv
3. Click Refresh — all 3 pages update automatically
```

---

## Business Takeaways

**For a risk manager reading this project:**

Customers with 3 or more past late payment incidents should trigger
an automatic review flag. They default at a rate 21 times higher than
customers with a clean payment history. A simple early warning system
at the first missed payment would be far cheaper than collections later.

Customers using more than 70% of their credit card limit are 9 times
more likely to default than disciplined spenders. A monthly utilization
alert to the relationship manager would identify at-risk customers before
they miss their first EMI.

Borrowers aged 25-34 represent the highest-risk demographic — not
because of age itself, but because of shorter credit histories and higher
financial commitments. Offering smaller initial credit limits with a
6-month review is a better approach than rejection.

Income alone is a weak predictor (IV = 0.05). The real danger signal is
the combination of low income + high utilization + any delinquency history.
No single variable tells the full story — all three together do.

---

## SQL Screenshot Reference

| File | Query Section | What It Shows |
|------|--------------|---------------|
| `01_portfolio_overview.png` | Executive Summary | 150K customers, 6.68% default rate |
| `02_default_by_age.png` | Demographics — Age | 25-34 age group = 11.12% |
| `03_default_by_income.png` | Segment Queries Q1 | Low income = 9.43% vs High = 4.62% |
| `04_delinquency_analysis.png` | Delinquency — bands | 5+ incidents = 57.22% |
| `05_credit_utilization.png` | Segment Queries Q2 | High util = 19.88% |
| `06_severity_comparison.png` | Segment Queries Q7 | 30+ / 60+ / 90+ DPD comparison |
| `07_executive_summary.png` | Segment Queries Q8 | All KPIs in one result |

---

## Contact

**[Your Name]**
Data Analyst | BFSI Domain

- LinkedIn : [Your LinkedIn URL]
- Email    : [Your Email]
- GitHub   : [Your GitHub Profile URL]

---

*Built as an end-to-end BFSI data analyst portfolio project.*
*SQL → Python EDA → Statistical Analysis → Power BI.*
