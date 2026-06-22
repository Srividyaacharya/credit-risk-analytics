# Credit Risk Analytics — BFSI Data Analyst Portfolio Project

> End-to-end credit risk analysis of 149,999 borrowers using SQL, Python and Power BI  
> Domain: Banking, Financial Services & Insurance (BFSI) | Role: Data Analyst

---

## Dashboard Preview

### Page 1 — Executive Overview
![Executive Overview](powerbi/screenshots/page1_executive.png)

### Page 2 — Risk Drivers & Delinquency Analysis
![Risk Drivers](powerbi/screenshots/page2_delinquency.png)

### Page 3 — Customer Risk Segmentation & Scoring
![Risk Segmentation](powerbi/screenshots/page3_segmentation.png)

---

## Project Summary

A financial institution wants to understand which borrowers are most likely
to default on their loans — enabling smarter credit decisions, risk-based
pricing, and early intervention before accounts go bad.

This project builds a complete analytics pipeline: from raw borrower data
to a 3-page interactive Power BI dashboard used to communicate findings
to risk managers, credit officers, and senior leadership.

**What makes this project different from a generic analytics portfolio:**
- Every finding is validated statistically — not just "it looks like X"
- Domain-specific metrics used: IV/WOE, DPD, KS statistic, Gini
- SQL, Python and Power BI all use the same dataset — true end-to-end pipeline
- Business takeaways written for non-technical stakeholders, not just data teams

---

## Key Findings

- **6.68% overall default rate** across 149,999 borrowers (10,026 customers defaulted)
- **Delinquency history is the strongest predictor** (IV = 1.39) — customers
  with 5+ late payment incidents default at **57.2%** versus 2.73% for clean
  customers — a **21x difference**
- **Credit utilization is the second strongest predictor** (IV = 1.00) —
  customers using 70%+ of their credit limit default at **19.88%** versus 2.12%
  for low utilization — a **9x difference**
- **Customers aged 25-34 default the most** at 11.12% — T-Test confirms this
  is a real pattern (p < 0.001), not a coincidence
- **Low-income customers default at 9.43%** versus 4.62% for high-income
  customers — confirmed statistically via Chi-Square (Chi² = 496.2, p < 0.001)
- **All patterns validated** using T-Test, Chi-Square, and IV/WOE analysis —
  every insight is statistically significant at p < 0.001

---

## Tools & Technologies

| Tool | Purpose |
|------|---------|
| MS SQL Server (SSMS) | Data storage, 14-section analysis, Power BI views |
| Python — Pandas, NumPy | Data cleaning, feature engineering, EDA |
| Python — Matplotlib, Seaborn | 7 EDA charts |
| Python — Scipy | T-Test, Chi-Square, correlation, skewness analysis |
| Python — Custom functions | WOE and Information Value (IV) calculation |
| Power BI Desktop | 3-page interactive dashboard with slicers |

---

## Dataset

**Source:** [Give Me Some Credit — Kaggle Competition](https://www.kaggle.com/c/GiveMeSomeCredit/data)

| Item | Detail |
|------|--------|
| Original rows | 150,000 |
| Rows after cleaning | 149,999 |
| Input columns | 11 features |
| Target column | SeriousDlqin2yrs (1 = defaulted within 2 years) |
| Default rate | 6.68% |
| CustomerID | C001 to C150000 |

### Column Descriptions

| Column | Plain English |
|--------|--------------|
| SeriousDlqin2yrs | Target — did this customer default? (1=yes, 0=no) |
| RevolvingUtilizationOfUnsecuredLines | What % of credit card limit is being used |
| age | Borrower age in years |
| NumberOfTime30-59DaysPastDueNotWorse | Times payment was 30-59 days late |
| NumberOfTime60-89DaysPastDueNotWorse | Times payment was 60-89 days late |
| NumberOfTimes90DaysLate | Times payment was 90+ days late (most severe) |
| DebtRatio | Monthly debt payments divided by monthly income |
| MonthlyIncome | Gross monthly income in USD |
| NumberOfOpenCreditLinesAndLoans | Total active loans and credit lines |
| NumberRealEstateLoansOrLines | Home loans and mortgages |
| NumberOfDependents | Family members financially dependent on borrower |

### Missing Values

| Column | Missing Count | Missing % | Fix Applied |
|--------|--------------|-----------|-------------|
| MonthlyIncome | 29,731 | 19.82% | Filled with median ($5,400) |
| NumberOfDependents | 3,924 | 2.62% | Filled with 0 |

### Data Cleaning Approach

```python
# Step 1: Remove only age <= 0 (1 invalid row)
df = df[df['age'] > 0].copy()

# Step 2: Fill missing values — keep all rows
df['MonthlyIncome']      = df['MonthlyIncome'].fillna(df['MonthlyIncome'].median())
df['NumberOfDependents'] = df['NumberOfDependents'].fillna(0)

# Step 3: Cap outliers at 99th percentile — do NOT remove rows
for col in ['RevolvingUtilizationOfUnsecuredLines', 'DebtRatio', 'MonthlyIncome']:
    df[col] = df[col].clip(upper=df[col].quantile(0.99))

# Result: 149,999 rows retained from 150,000 original
```

> **Why cap instead of remove?**
> Removing rows with extreme DebtRatio values (> 50) would drop 25,934 rows — 17.3%
> of the dataset. These customers are real borrowers with extreme financial stress.
> Capping their values at the 99th percentile preserves all customers while
> preventing extreme values from distorting the analysis. Retaining more data
> also produces more reliable statistical test results across 149,999 rows.

---

## Project Structure

```
credit-risk-analytics/
│
├── data/
│   └── cs-training.csv                         ← raw dataset from Kaggle
│
├── notebooks/
│   ├── CreditRisk_EDA.ipynb                    ← 7 exploratory charts
│   └── CreditRisk_Statistical_Analysis.ipynb   ← 5 statistical tests
│
├── sql/
│   └── CreditRisk_SQL_Final.sql                ← 14 SQL analysis sections
│
├── powerbi/
│   ├── CreditRisk_Dashboard.pbix               ← Power BI dashboard file
│   └── screenshots/
│       ├── page1_executive.png
│       ├── page2_delinquency.png
│       └── page3_segmentation.png
│
├── outputs/
│   ├── model_output_for_powerbi.csv            ← customer risk scores
│   ├── cutoff_analysis_for_powerbi.csv         ← threshold decision table
│   └── risk_scorecard_for_powerbi.csv          ← risk band summary
│
└── README.md
```

---

## Section 1 — SQL Analytics (14 Sections)

All analysis runs in MS SQL Server Management Studio on a table of 149,999 rows
with CustomerID as the primary key (C001 to C150000).

### Sections Covered

| Section | Queries | Key Output |
|---------|---------|-----------|
| Portfolio Health | Overall default rate, quality buckets, missing data audit | 6.68% default rate confirmed |
| Customer Demographics | Default rate by age, income, dependents | 25-34 age group is highest risk |
| Delinquency Analysis | 30/60/90+ DPD severity, repeat vs first-time offenders | 57.2% default rate for 5+ incidents |
| Credit Utilization | Utilization bands, debt ratio segmentation | High util = 9x more defaults |
| Combined Risk | Double-stress: high utilization AND high debt ratio together | Strongest combined signal |
| Risk Scoring | Rule-based score per customer (0–100) | Every customer gets a risk score |
| Window Functions | RANK(), NTILE() — income deciles and customer ranking | Shows SQL advanced skills |
| Power BI Views | vw_RiskSummary and vw_CustomerRiskBands | Direct connection to Power BI |

### Sample Query — Delinquency Impact

```sql
SELECT
    CASE
        WHEN (NumberOfTime30_59DaysPastDue
            + NumberOfTime60_89DaysPastDue
            + NumberOfTimes90DaysLate) = 0    THEN '0 incidents'
        WHEN (NumberOfTime30_59DaysPastDue
            + NumberOfTime60_89DaysPastDue
            + NumberOfTimes90DaysLate) = 1    THEN '1 incident'
        WHEN (NumberOfTime30_59DaysPastDue
            + NumberOfTime60_89DaysPastDue
            + NumberOfTimes90DaysLate) BETWEEN 2 AND 4 THEN '2-4 incidents'
        ELSE '5+ incidents'
    END AS DelinquencyBand,
    COUNT(*) AS Customers,
    CAST(SUM(SeriousDlqin2yrs) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS DefaultRate_Pct
FROM credit_risk
GROUP BY ...
ORDER BY DefaultRate_Pct DESC;

-- Results:
-- 5+ incidents : 57.2%   ← 21x higher than clean customers
-- 2-4 incidents: 29.9%
-- 1 incident   : 12.2%
-- 0 incidents  :  2.7%
```

---

## Section 2 — Python EDA (7 Charts)

**Notebook:** `notebooks/CreditRisk_EDA.ipynb`

### Charts Produced

| # | Chart | File | Key Finding |
|---|-------|------|------------|
| 1 | Default Overview | `01_default_overview.png` | 6.68% default rate — class imbalance confirmed |
| 2 | Default by Age Group | `02_default_by_age.png` | Ages 18-34 default at 11%+ — nearly 5x the 65+ rate |
| 3 | Credit Utilization vs Default | `03_credit_utilization.png` | High util (70%+) = 19.88% default vs 2.12% low util |
| 4 | Income vs Default | `04_income_vs_default.png` | Low income defaults at 9.43% vs 4.62% high income |
| 5 | Delinquency History | `05_delinquency_vs_default.png` | Strongest predictor — escalates sharply with each incident |
| 6 | Missing Data | `06_missing_data.png` | 19.82% of MonthlyIncome missing — filled with median |
| 7 | Risk Segmentation | `07_risk_segmentation.png` | Full portfolio split: Low / Medium / High risk bands |

### Key Descriptive Statistics

```
                        Mean      Median     Std
Age (years)             52.3       52.0      14.8
Monthly Income ($)    6,805      5,400     5,210
Debt Ratio              0.35       0.23      0.27
Credit Utilization      0.32       0.16      0.27
Total Delinquencies     0.93       0.00     12.47

Note: Income mean ($6,805) is much higher than median ($5,400)
because a few high earners pull the average up.
Always use MEDIAN for income analysis.
```

---

## Section 3 — Statistical Analysis (5 Tests)

**Notebook:** `notebooks/CreditRisk_Statistical_Analysis.ipynb`

The goal of statistical testing is to prove that patterns found in EDA are
**real and not coincidences**. All tests run on the full 149,999 rows.

### Test 1 — Descriptive Statistics

Summary distributions for all key columns. Income is heavily right-skewed
(skewness = 112.9 before capping) — confirming median is the right measure.

### Test 2 — T-Test: Are defaulters genuinely different?

**Question:** Is the difference between defaulters and non-defaulters real,
or could it just be random variation?

| Variable | Non-Default Average | Default Average | T-Statistic | P-Value | Significant? |
|----------|--------------------|-----------------|----|---------|-------------|
| Monthly Income | $6,194 | $5,429 | 19.31 | < 0.001 | Yes ✓ |
| Age | 52.8 years | 45.9 years | 44.99 | < 0.001 | Yes ✓ |
| Credit Utilization | 0.30 | 0.70 | -113.32 | < 0.001 | Yes ✓ |

> **How to read:** P-value < 0.05 = the difference is REAL, not by chance.
> All 3 variables are confirmed — defaulters earn less, are younger,
> and use more than double the credit of non-defaulters.

### Test 3 — Chi-Square: Is the category pattern real?

**Question:** Is the relationship between a category (like age group) and
default rate statistically significant?

| Variable | Chi-Square | P-Value | Significant? |
|----------|-----------|---------|-------------|
| Delinquency Band | 23,092.7 | < 0.001 | Yes ✓ |
| Utilization Band | 10,669.1 | < 0.001 | Yes ✓ |
| Age Band | 2,018.8 | < 0.001 | Yes ✓ |
| Income Band | 496.2 | < 0.001 | Yes ✓ |

> **How to read:** P-value < 0.05 = the category IS related to default.
> All 4 variables confirmed — none of these patterns are random.

### Test 4 — Correlation Analysis

How strongly each variable moves together with the default column:

```
Positive = increases default risk    Negative = decreases default risk

RevolvingUtilizationOfUnsecuredLines : +0.24  (strongest positive)
NumberOfTime30-59DaysPastDue         : +0.13
NumberOfTime60-89DaysPastDue         : +0.11
NumberOfTimes90DaysLate              : +0.11
NumberOfDependents                   : +0.04
DebtRatio                            : +0.04
MonthlyIncome                        : -0.02
Age                                  : -0.10  (strongest negative)
```

### Test 5 — Information Value (IV) & Weight of Evidence (WOE)

**Question:** Which column is the single best predictor of default?

```
IV Guide:
  < 0.02   = Useless for prediction
  0.02-0.10 = Weak
  0.10-0.30 = Medium
  > 0.30   = Strong
  > 0.50   = Very Strong

Results (calculated on 149,999 rows):
  Delinquency History (combined) : IV = 1.3882  Very Strong ✓
  Credit Utilization             : IV = 1.0048  Very Strong ✓
  Age                            : IV = 0.2511  Medium ✓
  Monthly Income                 : IV = 0.0529  Weak

Key insight: Income alone (IV = 0.05) is a surprisingly weak predictor.
It must be combined with delinquency history and utilization to be useful.
```

---

## Section 4 — Power BI Dashboard (3 Pages)

**File:** `powerbi/CreditRisk_Dashboard.pbix`

### Page 1 — Executive Overview

**Visuals:**
- 6 KPI cards: Total Customers (150K), Total Defaulters (10K), Default Rate (6.68%),
  Median Monthly Income ($5,400), Median Debt Ratio (37%), Credit Utilization (32%)
- Portfolio Composition donut chart (defaulters vs non-defaulters)
- Default Rate by Age Group (horizontal bar chart)
- Default Rate by Income Segment (column chart)
- Default Rate by Credit Utilization (column chart)
- Key Findings text box

### Page 2 — Risk Drivers & Delinquency Analysis

Deep-dive into the three delinquency severity levels. Uses colour-coded bars
(green → amber → orange → dark red) to show risk escalation visually.

**Visuals:**
- 4 KPI cards: High Risk Customers %, Avg 90+ DPD, Customers with 90+ DPD %,
  Avg Credit Lines
- Impact of 90+ Day Delinquencies on Default Risk (colour-coded bar chart)
- Impact of 60+ Day Delinquencies on Default Risk (colour-coded bar chart)
- Impact of 30+ Day Delinquencies on Default Risk (colour-coded bar chart)
- Default Rate by Age × Income Segment (matrix with conditional formatting)
- Interactive slicers: Age Group, Income Band
- Key Risk Drivers text box

**Why 3 separate delinquency charts?**
Banks classify delinquency by severity: 30+ DPD (mild warning), 60+ DPD
(serious), 90+ DPD (near-default). Showing each level separately reveals
how the default rate escalates — 30+ DPD customers default at 40.5%,
60+ DPD at 57.2%, and 90+ DPD at 60.45%. This is how actual bank risk
teams monitor their portfolio.

### Page 3 — Customer Risk Segmentation & Scoring

Risk band classification for every customer. Lets a risk manager filter
to any segment and see who falls there.

**Visuals:**
- 4 KPI cards: High Risk Customers (33K, red), High Risk % (22%, red),
  High Risk Default Rate (20.7%, red), Low Risk Customers (89K, green)
- Customer Distribution by Risk Tier (donut chart)
- Default Rate by Risk Tier (colour-coded bar chart)
- Risk Tier by Income Segment (matrix with conditional formatting)
- Customer Profile by Risk Tier × Age Group (stacked bar chart)
- Interactive slicers: Age Group, Income Band
- Key Risk Drivers text box

### DAX Measures Used

```dax
Default Rate =
DIVIDE(
    COUNTROWS(FILTER(CustomerRisk, CustomerRisk[ActualDefault] = 1)),
    COUNTROWS(CustomerRisk)
)

High Risk Count =
COUNTROWS(
    FILTER(CustomerRisk,
        CustomerRisk[RiskBand] = "High Risk" ||
        CustomerRisk[RiskBand] = "Very High Risk")
)

Segment Default Rate =
DIVIDE(
    SUMX(CustomerRisk, CustomerRisk[ActualDefault]),
    COUNTROWS(CustomerRisk)
)
```

---

## Risk Segmentation Results

Customer risk bands assigned using a rule-based scoring system:

| Risk Band | Default Rate | Customers | Bank Decision |
|-----------|-------------|-----------|---------------|
| Low Risk | 2.84% | 89,000 | Auto Approve |
| Medium Risk | 2.57% | 28,000 | Manual Review |
| High Risk | 20.68% | 33,000 | Require Collateral |

> High Risk customers default at **7.2x** the rate of Low Risk customers —
> confirming the segmentation is meaningful and actionable.

---

## Business Takeaways

**For a risk manager or credit officer reviewing this project:**

Customers with 3 or more past late payment incidents should trigger an
automatic review — they default at a rate 21 times higher than customers
with a clean payment history. This single rule alone would catch a large
proportion of future defaults.

Customers using more than 70% of their credit card limit are 9 times more
likely to default than customers who use less than 30%. A simple utilization
alert system would flag high-risk customers before they miss their first EMI.

The 25-34 age group represents the highest risk demographic — not because
of age itself, but because they have shorter credit histories, less savings,
and higher financial commitments. Offering smaller initial credit limits with
a 6-month review period is a lower-risk approach than outright rejection.

Low-income customers default twice as often as high-income customers, but
income alone has low predictive power (IV = 0.05). The combination of low
income + high utilization + any delinquency history is the real danger
signal — a finding that comes from combining all three analyses together.

---

## How to Run This Project

### Prerequisites
```bash
pip install pandas numpy matplotlib seaborn scipy
```

### Step 1 — SQL
```
1. Open sql/CreditRisk_SQL_Final.sql in MS SQL Server Management Studio
2. Run each section from top to bottom (F5 to execute)
3. Section 1 creates the database and imports the CSV
4. Sections 2-13 run the analysis queries
5. Section 14 creates views for Power BI
```

### Step 2 — Python Notebooks
```
Run in this order:
1. notebooks/CreditRisk_EDA.ipynb
2. notebooks/CreditRisk_Statistical_Analysis.ipynb

Each notebook loads cs-training.csv and applies the same
cleaning approach at the top (age filter + median fill + 99th pct cap)
```

### Step 3 — Power BI
```
1. Open powerbi/CreditRisk_Dashboard.pbix in Power BI Desktop
2. Home → Transform Data → update data source path to your local
   outputs/model_output_for_powerbi.csv
3. Click Refresh
4. All 3 pages will update with your local data
```

---

## Statistical Significance Summary

Every finding in this project has been tested for statistical significance.
Nothing is based on visual impression alone.

| Finding | Test Used | Result | P-Value |
|---------|-----------|--------|---------|
| Defaulters earn less | T-Test | Significant | < 0.001 |
| Defaulters are younger | T-Test | Significant | < 0.001 |
| Defaulters use more credit | T-Test | Significant | < 0.001 |
| Age group is related to default | Chi-Square | Significant | < 0.001 |
| Utilization band is related to default | Chi-Square | Significant | < 0.001 |
| Delinquency band is related to default | Chi-Square | Significant | < 0.001 |
| Income band is related to default | Chi-Square | Significant | < 0.001 |
| Delinquency = strongest predictor | IV/WOE | IV = 1.39 | Very Strong |
| Utilization = second predictor | IV/WOE | IV = 1.00 | Very Strong |


## Contact

**[Your Name]**
Data Analyst | BFSI Domain

- LinkedIn: [Your LinkedIn URL]
- Email: [Your Email]
- GitHub: [Your GitHub Profile URL]

---

*Portfolio project demonstrating end-to-end credit risk analytics skills
for BFSI data analyst roles — SQL, Python, Statistical Analysis, Power BI.*
