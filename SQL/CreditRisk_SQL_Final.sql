-- ============================================================
--  CREDIT RISK ANALYTICS — SQL PORTFOLIO PROJECT
--  Dataset  : Give Me Some Credit (Kaggle)
--  Tool     : MS SQL Server Management Studio (SSMS)
-- ============================================================

--  SECTIONS
--  1.  Database & Table Setup
--  2.  Portfolio Overview  
--  3.  Customer Profile    
--  4.  Age Risk Analysis  
--  5.  Income Analysis
--  6.  Delinquency Analysis    
--  7.  Debt Analysis       
--  8.  Credit Utilization    
--  9.  Dependents Analysis    
--  10.  Portfolio Quality Buckets  
--  11. Combined Risk Analysis     
--  12. Top Risky Customers        
--  13. Window Functions         
--  14. Executive Summary      

-- ============================================================


-- ============================================================
--  SECTION 1 : DATABASE & TABLE SETUP
-- ============================================================

-- Create Database
-- SSMS > Right-click CreditRiskDB > Tasks > Import Flat File > table name
-- Select your cs-training-final.csv file (with CustomerID added)

CREATE DATABASE CreditRiskDB;
GO

USE CreditRiskDB;
GO


-- Verify import worked correctly
SELECT COUNT(*) AS TotalRows FROM credit_risk;   -- Expected: 150000
SELECT TOP 5  * FROM credit_risk;


-- ============================================================
--  SECTION 2 : PORTFOLIO OVERVIEW
--  Purpose  : Understand the size and health of the loan book
-- ============================================================

-- 2.1 How many customers do we have?
SELECT
    COUNT(*) AS Total_Customers
FROM credit_risk;


-- 2.2 How many customers defaulted?
SELECT
    COUNT(*) AS Total_Defaulters
FROM credit_risk
WHERE SeriousDlqin2yrs = 1;


-- 2.3 What is the overall default rate?
-- Default Rate = (Defaulters / Total) x 100
SELECT
    CAST(
        100.0 * SUM(SeriousDlqin2yrs) / COUNT(*)
    AS DECIMAL(5,2)) AS Default_Rate_Pct
FROM credit_risk;
-- Expected: 6.68%
-- Insight : Only 6.68% defaulted — data is heavily imbalanced


-- 2.4 Full portfolio snapshot in one query
SELECT
    COUNT(*)                                                         AS Total_Customers,
    SUM(SeriousDlqin2yrs)                                           AS Total_Defaulters,
    COUNT(*) - SUM(SeriousDlqin2yrs)                                AS Total_Performing,
    CAST(100.0 * SUM(SeriousDlqin2yrs) / COUNT(*)AS DECIMAL(5,2))             AS Default_Rate_Pct
FROM credit_risk;


-- ============================================================
--  SECTION 3 : CUSTOMER PROFILE
--  Purpose  : Who are our customers? Age, income, family size
-- ============================================================

-- 3.1 What is the average age of our customers?
SELECT
    AVG(Age) AS Avg_Age
FROM credit_risk
WHERE Age > 0;   -- filter out 1 invalid row where age = 0


-- 3.2 What is the average monthly income?

SELECT
    ROUND(AVG(MonthlyIncome), 2) AS Avg_Monthly_Income
FROM credit_risk;


-- 3.3 How are customers distributed by income?
SELECT
    CASE
        WHEN MonthlyIncome IS NULL  THEN 'Unknown'
        WHEN MonthlyIncome < 3000   THEN 'Low Income'
        WHEN MonthlyIncome < 8000   THEN 'Middle Income'
        ELSE                             'High Income'
    END                                  AS Income_Band,
    COUNT(*)                             AS Customers
FROM credit_risk
GROUP BY
    CASE
        WHEN MonthlyIncome IS NULL  THEN 'Unknown'
        WHEN MonthlyIncome < 3000   THEN 'Low Income'
        WHEN MonthlyIncome < 8000   THEN 'Middle Income'
        ELSE                             'High Income'
    END
ORDER BY Customers DESC;

-- Insight: missing income is itself a risk signal


-- ============================================================
--  SECTION 4 : AGE RISK ANALYSIS
--  Purpose  : Which age group defaults the most?
-- ============================================================

-- 4.1 Default rate by age group
SELECT
    CASE
        WHEN Age < 25              THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        WHEN Age BETWEEN 55 AND 64 THEN '55-64'
        ELSE                            '65+'
    END                                                              AS Age_Group,
    COUNT(*)                                                         AS Customers,
    SUM(SeriousDlqin2yrs)                                           AS Defaults,
    CAST(100.0 * SUM(SeriousDlqin2yrs) / COUNT(*)AS DECIMAL(5,2))             AS Default_Rate_Pct
FROM credit_risk
WHERE Age > 0
GROUP BY
    CASE
        WHEN Age < 25              THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        WHEN Age BETWEEN 55 AND 64 THEN '55-64'
        ELSE                            '65+'
    END
ORDER BY Default_Rate_Pct DESC;
-- Insight: Younger borrowers tend to default more Older borrowers (65+) also show higher risk (fixed income)

-- ============================================================
--  SECTION 5 :  Income Analysis
--  Purpose  : Do lower income customers default more?
-- ============================================================

SELECT
    CASE
        WHEN MonthlyIncome IS NULL   THEN '0. Unknown'
        WHEN MonthlyIncome < 3000    THEN '1. Low (under $3K)'
        WHEN MonthlyIncome < 6000    THEN '2. Mid ($3K - $6K)'
        WHEN MonthlyIncome < 10000   THEN '3. Upper Mid ($6K - $10K)'
        ELSE                              '4. High ($10K+)'
    END                                                              AS Income_Band,
    COUNT(*)                                                         AS Total_Customers,
    SUM(SeriousDlqin2yrs)                                           AS Total_Defaults,
    CAST(SUM(SeriousDlqin2yrs) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Default_Rate_Pct,
    CAST(MIN(MonthlyIncome) AS DECIMAL(10,0))                       AS Min_Income,
    CAST(MAX(MonthlyIncome) AS DECIMAL(10,0))                       AS Max_Income,
    CAST(AVG(MonthlyIncome) AS DECIMAL(10,0))                       AS Avg_Income
FROM credit_risk
GROUP BY
    CASE
        WHEN MonthlyIncome IS NULL   THEN '0. Unknown'
        WHEN MonthlyIncome < 3000    THEN '1. Low (under $3K)'
        WHEN MonthlyIncome < 6000    THEN '2. Mid ($3K - $6K)'
        WHEN MonthlyIncome < 10000   THEN '3. Upper Mid ($6K - $10K)'
        ELSE                              '4. High ($10K+)'
    END
ORDER BY Income_Band;

--Insight
-- Low income    : ~9.43%  default rate  (highest risk)
-- Unknown       : ~7.50%  (missing income is itself a risk signal)
-- Mid income    : ~6.74%
-- Upper Mid     : ~5.50%
-- High income   : ~4.62%  (lowest risk)

-- ============================================================
--  SECTION 6 : DELINQUENCY ANALYSIS
--  Purpose  : Past late payments are the strongest default predictor
-- ============================================================

-- 6.1 How does 90-day delinquency impact default rate?
-- This is the single most powerful predictor in the dataset

SELECT
    NumberOfTimes90DaysLate              AS Times_90_Days_Late,
    COUNT(*)                             AS Customers,
    CAST(100.0 * SUM(SeriousDlqin2yrs) / COUNT(*) AS DECIMAL(5,2)) AS Default_Rate_Pct
FROM credit_risk
GROUP BY NumberOfTimes90DaysLate
ORDER BY NumberOfTimes90DaysLate;
-- Insight: Even 1 incident of 90-day late payment = massive jump in default rate


-- 6.2 Average delinquencies — defaulters vs non-defaulters
SELECT
    CASE
        WHEN SeriousDlqin2yrs = 1 THEN 'Defaulted'
        ELSE                           'Not Defaulted'
    END                                                              AS Customer_Type,
    ROUND(AVG(CAST(NumberOfTime30_59DaysPastDueNotWorse AS FLOAT)), 2)      AS Avg_30_59_Days_Late,
    ROUND(AVG(CAST(NumberOfTime60_89DaysPastDueNotWorse AS FLOAT)), 2)      AS Avg_60_89_Days_Late,
    ROUND(AVG(CAST(NumberOfTimes90DaysLate      AS FLOAT)), 2)      AS Avg_90_Days_Late
FROM credit_risk
GROUP BY SeriousDlqin2yrs;

-- Insight: Defaulters have significantly more late payment incidents across all three severity levels


-- 6.3 First-time vs repeat late payers
SELECT
    CASE
        WHEN (NumberOfTime30_59DaysPastDueNotWorse
            + NumberOfTime60_89DaysPastDueNotWorse
            + NumberOfTimes90DaysLate) = 0  THEN 'Never Late'
        WHEN (NumberOfTime30_59DaysPastDueNotWorse
            + NumberOfTime60_89DaysPastDueNotWorse
            + NumberOfTimes90DaysLate) = 1  THEN 'First Time Late'
        ELSE                                    'Repeat Offender'
    END                                                              AS Customer_Type,
    COUNT(*)                                                         AS Customers,
    CAST(100.0 * SUM(SeriousDlqin2yrs) / COUNT(*)AS DECIMAL(5,2))             AS Default_Rate_Pct
FROM credit_risk
GROUP BY
    CASE
        WHEN (NumberOfTime30_59DaysPastDueNotWorse
            + NumberOfTime60_89DaysPastDueNotWorse
            + NumberOfTimes90DaysLate) = 0  THEN 'Never Late'
        WHEN (NumberOfTime30_59DaysPastDueNotWorse
            + NumberOfTime60_89DaysPastDueNotWorse
            + NumberOfTimes90DaysLate) = 1  THEN 'First Time Late'
        ELSE                                    'Repeat Offender'
    END
ORDER BY Default_Rate_Pct DESC;


-- ============================================================
--  SECTION 7 : DEBT ANALYSIS
--  Purpose  : High debt burden = higher financial stress = more defaults
-- ============================================================

-- 7.1 Default rate by debt ratio band
-- DebtRatio = Monthly debt payments / Monthly income
SELECT
    CASE
        WHEN DebtRatio < 0.3  THEN 'Low (under 30%)'
        WHEN DebtRatio < 0.6  THEN 'Medium (30-60%)'
        ELSE                       'High (60%+)'
    END                                                              AS Debt_Band,
    COUNT(*)                                                         AS Customers,
    CAST(100.0 * SUM(SeriousDlqin2yrs) / COUNT(*) AS DECIMAL(5,2))             AS Default_Rate_Pct
FROM credit_risk
WHERE DebtRatio < 50       -- remove extreme outliers
GROUP BY
    CASE
        WHEN DebtRatio < 0.3  THEN 'Low (under 30%)'
        WHEN DebtRatio < 0.6  THEN 'Medium (30-60%)'
        ELSE                       'High (60%+)'
    END
ORDER BY Default_Rate_Pct DESC;

-- Insight: Higher debt burden = higher default rate, Customers spending 60%+ of income on debt are most at risk


-- ============================================================
--  SECTION 8 : CREDIT UTILIZATION ANALYSIS
--  Purpose  : How much of credit limit is being used?
-- ============================================================

-- 8.1 Default rate by credit utilization band
-- RevolvingUtilization = Credit used / Credit limit (0 to 1)
SELECT
    CASE
        WHEN RevolvingUtilizationOfUnsecuredLines < 0.3  THEN 'Low (0-30%)'
        WHEN RevolvingUtilizationOfUnsecuredLines < 0.7  THEN 'Medium (30-70%)'
        ELSE                                  'High (70%+)'
    END                                                              AS Utilization_Band,
    COUNT(*)                                                         AS Customers,
    CAST(100.0 * SUM(SeriousDlqin2yrs) / COUNT(*) AS DECIMAL(5,2))             AS Default_Rate_Pct
FROM credit_risk
WHERE RevolvingUtilizationOfUnsecuredLines <= 1    -- remove values over 100%
GROUP BY
    CASE
        WHEN RevolvingUtilizationOfUnsecuredLines < 0.3  THEN 'Low (0-30%)'
        WHEN RevolvingUtilizationOfUnsecuredLines < 0.7  THEN 'Medium (30-70%)'
        ELSE                                  'High (70%+)'
    END
ORDER BY Default_Rate_Pct DESC;
-- Insight: Customers using 70%+ of their credit limit are the riskiest , Low utilization = financially disciplined = low default risk


-- ============================================================
--  SECTION 9 : DEPENDENTS ANALYSIS
--  Purpose  : More dependents = more expenses = less money for repayment
-- ============================================================

--9.1 Default rate by number of dependents
SELECT
    CASE
        WHEN NumberOfDependents IS NULL THEN 'Unknown'
        WHEN NumberOfDependents = 0     THEN '0 Dependents'
        WHEN NumberOfDependents = 1     THEN '1 Dependent'
        WHEN NumberOfDependents = 2     THEN '2 Dependents'
        WHEN NumberOfDependents = 3     THEN '3 Dependents'
        ELSE                                 '4 or More'
    END                                                              AS Family_Size,
    COUNT(*)                                                         AS Customers,
    CAST(100.0 * SUM(SeriousDlqin2yrs) / COUNT(*) AS DECIMAL(5,2))             AS Default_Rate_Pct,
    ROUND(AVG(MonthlyIncome), 2)                                    AS Avg_Income
FROM credit_risk
GROUP BY
    CASE
        WHEN NumberOfDependents IS NULL THEN 'Unknown'
        WHEN NumberOfDependents = 0     THEN '0 Dependents'
        WHEN NumberOfDependents = 1     THEN '1 Dependent'
        WHEN NumberOfDependents = 2     THEN '2 Dependents'
        WHEN NumberOfDependents = 3     THEN '3 Dependents'
        ELSE                                 '4 or More'
    END
ORDER BY Default_Rate_Pct DESC;
-- Insight: Larger families with lower income = highest stress
--          Missing dependent data is also a risk flag


-- ============================================================
--  SECTION 10 : PORTFOLIO QUALITY BUCKETS
--  Purpose  : Classify ALL customers into 4 health categories
--             Like a traffic light system for the loan book
-- ============================================================

-- 10.1 Portfolio bucket breakdown
-- Good Standing / Watch / Stressed / Defaulted
SELECT
    CASE
        WHEN SeriousDlqin2yrs = 1
             THEN '4. Defaulted'
        WHEN (NumberOfTime30_59DaysPastDueNotWorse
            + NumberOfTime60_89DaysPastDueNotWorse
            + NumberOfTimes90DaysLate) >= 3
             THEN '3. Stressed'
        WHEN (NumberOfTime30_59DaysPastDueNotWorse
            + NumberOfTime60_89DaysPastDueNotWorse
            + NumberOfTimes90DaysLate) BETWEEN 1 AND 2
             THEN '2. Watch'
        ELSE      '1. Good Standing'
    END                                                              AS Portfolio_Bucket,
    COUNT(*)                                                         AS Customers,
    CAST (COUNT(*) * 100.0 /
          SUM(COUNT(*)) OVER() AS DECIMAL(5,2))                                  AS Pct_Of_Portfolio,
    ROUND(AVG(MonthlyIncome), 2)                                    AS Avg_Income,
    ROUND(AVG(RevolvingUtilizationOfUnsecuredLines), 4)                             AS Avg_Utilization
FROM credit_risk
WHERE Age > 0
  AND RevolvingUtilizationOfUnsecuredLines <= 1
  AND DebtRatio < 50
GROUP BY
    CASE
        WHEN SeriousDlqin2yrs = 1
             THEN '4. Defaulted'
        WHEN (NumberOfTime30_59DaysPastDueNotWorse
            + NumberOfTime60_89DaysPastDueNotWorse
            + NumberOfTimes90DaysLate) >= 3
             THEN '3. Stressed'
        WHEN (NumberOfTime30_59DaysPastDueNotWorse
            + NumberOfTime60_89DaysPastDueNotWorse
            + NumberOfTimes90DaysLate) BETWEEN 1 AND 2
             THEN '2. Watch'
        ELSE      '1. Good Standing'
    END
ORDER BY Portfolio_Bucket;

-- Insight: This tells the bank how healthy its entire loan portfolio is
--          Stressed customers need early intervention before they default


-- ============================================================
--  SECTION 11 : COMBINED RISK ANALYSIS
--  Purpose   : Find customers with MULTIPLE risk factors at once
-- ============================================================

-- 11.1 High utilization AND high debt ratio together
-- These "double stressed" customers are the most dangerous
SELECT
    CASE
        WHEN RevolvingUtilizationOfUnsecuredLines >= 0.7
             AND DebtRatio >= 0.6    THEN '1. Double High Risk'
        WHEN RevolvingUtilizationOfUnsecuredLines >= 0.7
             AND DebtRatio < 0.6     THEN '2. High Utilization Only'
        WHEN RevolvingUtilizationOfUnsecuredLines < 0.7
             AND DebtRatio >= 0.6    THEN '3. High Debt Ratio Only'
        ELSE                              '4. Low Combined Risk'
    END                                                              AS Combined_Risk,
    COUNT(*)                                                         AS Customers,
    CAST(100.0 * SUM(SeriousDlqin2yrs) / COUNT(*) AS DECIMAL(5,2))             AS Default_Rate_Pct,
    ROUND(AVG(MonthlyIncome), 2)                                    AS Avg_Income
FROM credit_risk
WHERE RevolvingUtilizationOfUnsecuredLines <= 1
  AND DebtRatio < 50
GROUP BY
    CASE
        WHEN RevolvingUtilizationOfUnsecuredLines >= 0.7
             AND DebtRatio >= 0.6    THEN '1. Double High Risk'
        WHEN RevolvingUtilizationOfUnsecuredLines >= 0.7
             AND DebtRatio < 0.6     THEN '2. High Utilization Only'
        WHEN RevolvingUtilizationOfUnsecuredLines < 0.7
             AND DebtRatio >= 0.6    THEN '3. High Debt Ratio Only'
        ELSE                              '4. Low Combined Risk'
    END
ORDER BY Default_Rate_Pct DESC;

-- Insight: Double High Risk customers default at a much higher rate
--          This combination is a key red flag for loan officers


-- ============================================================
--  SECTION 12 : TOP RISKY CUSTOMERS
--  Purpose   : Identify specific high-risk individuals
-- ============================================================

-- 12.1 Top 20 riskiest customers
SELECT TOP 20
    CustomerID,
    Age,
    ROUND(MonthlyIncome, 2)                                          AS Monthly_Income,
    ROUND(DebtRatio, 4)                                              AS Debt_Ratio,
    ROUND(RevolvingUtilizationOfUnsecuredLines, 4)                                   AS Credit_Utilization,
    NumberOfTimes90DaysLate                                          AS Times_90_Days_Late,
    (NumberOfTime30_59DaysPastDueNotWorse
   + NumberOfTime60_89DaysPastDueNotWorse
   + NumberOfTimes90DaysLate)                                        AS Total_Delinquencies,
    SeriousDlqin2yrs                                                 AS Is_Default
FROM credit_risk
WHERE Age > 0
  AND RevolvingUtilizationOfUnsecuredLines <= 1
  AND DebtRatio < 50
ORDER BY
    NumberOfTimes90DaysLate DESC,
    DebtRatio               DESC;
-- Insight: These are the customers a bank would flag for immediate review
--          In a real bank this list triggers collection calls


-- ============================================================
--  SECTION 13 : WINDOW FUNCTIONS
--  Purpose   : Rank and percentile analysis — shows SQL expertise
-- ============================================================

-- 13.1 Rank customers by monthly income (highest to lowest)
-- RANK() assigns position — ties get same rank
SELECT TOP 100
    CustomerID,
    ROUND(MonthlyIncome, 2)                                          AS Monthly_Income,
    RANK() OVER (
        ORDER BY MonthlyIncome DESC
    )                                                                AS Income_Rank
FROM credit_risk
WHERE MonthlyIncome IS NOT NULL
ORDER BY Income_Rank;
-- Insight: Shows which customers are highest earners in the portfolio


-- 13.2 Split customers into income deciles (10 equal groups)
-- NTILE(10) puts customers in groups 1-10 by income
-- Group 1 = highest income, Group 10 = lowest income

SELECT TOP 100
    CustomerID,
    ROUND(MonthlyIncome, 2)                                          AS Monthly_Income,
    NTILE(10) OVER (
        ORDER BY MonthlyIncome DESC
    )                                                                AS Income_Decile
FROM credit_risk
WHERE MonthlyIncome IS NOT NULL
ORDER BY Income_Decile;
-- Insight: Banks use deciles for targeted product offers
--          Decile 1 = premium customers, Decile 10 = most vulnerable


-- 13.3 Default rate by income decile
-- This shows if lower income deciles have higher default rates
SELECT
    Income_Decile,
    COUNT(*)                                                         AS Customers,
    SUM(Is_Default)                                                  AS Defaults,
    CAST(100.0 * SUM(Is_Default) / COUNT(*) AS DECIMAL(5,2))                    AS Default_Rate_Pct,
    ROUND(AVG(Monthly_Income), 2)                                    AS Avg_Income
FROM (
    SELECT
        CustomerID,
        SeriousDlqin2yrs                                             AS Is_Default,
        MonthlyIncome                                                AS Monthly_Income,
        NTILE(10) OVER (
            ORDER BY MonthlyIncome DESC
        )                                                            AS Income_Decile
    FROM credit_risk
    WHERE MonthlyIncome IS NOT NULL
) AS Decile_Data
GROUP BY Income_Decile
ORDER BY Income_Decile;

-- Insight: If default rate is highest in decile 10 (lowest income)
--          it confirms income is a strong predictor of default


-- 13.4 Running total of defaults by age group
-- Shows cumulative picture as age increases

SELECT
    CASE
        WHEN Age < 25              THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        WHEN Age BETWEEN 55 AND 64 THEN '55-64'
        ELSE                            '65+'
    END                                                              AS Age_Group,
    SUM(SeriousDlqin2yrs)                                           AS Defaults_In_Group,
    SUM(SUM(SeriousDlqin2yrs)) OVER (
        ORDER BY
            CASE
                WHEN Age < 25              THEN 1
                WHEN Age BETWEEN 25 AND 34 THEN 2
                WHEN Age BETWEEN 35 AND 44 THEN 3
                WHEN Age BETWEEN 45 AND 54 THEN 4
                WHEN Age BETWEEN 55 AND 64 THEN 5
                ELSE                            6
            END
    )                                                                AS Running_Total_Defaults
FROM credit_risk
WHERE Age > 0
GROUP BY
    CASE
        WHEN Age < 25              THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        WHEN Age BETWEEN 55 AND 64 THEN '55-64'
        ELSE                            '65+'
    END,
    CASE
        WHEN Age < 25              THEN 1
        WHEN Age BETWEEN 25 AND 34 THEN 2
        WHEN Age BETWEEN 35 AND 44 THEN 3
        WHEN Age BETWEEN 45 AND 54 THEN 4
        WHEN Age BETWEEN 55 AND 64 THEN 5
        ELSE                            6
    END
ORDER BY
    CASE
        WHEN Age < 25              THEN 1
        WHEN Age BETWEEN 25 AND 34 THEN 2
        WHEN Age BETWEEN 35 AND 44 THEN 3
        WHEN Age BETWEEN 45 AND 54 THEN 4
        WHEN Age BETWEEN 55 AND 64 THEN 5
        ELSE                            6
    END;


-- ============================================================
--  SECTION 14 : EXECUTIVE SUMMARY
--  Purpose   : One query that tells the complete portfolio story
--              This is what you show in a boardroom presentation
-- ============================================================

-- 14.1 Complete executive dashboard query
SELECT
    COUNT(*)                                                         AS Total_Customers,
    SUM(SeriousDlqin2yrs)                                           AS Total_Defaulters,
    COUNT(*) - SUM(SeriousDlqin2yrs)                                AS Total_Performing,
    CAST(100.0 * SUM(SeriousDlqin2yrs) / COUNT(*) AS DECIMAL(5,2))             AS Default_Rate_Pct,
    ROUND(AVG(MonthlyIncome), 2)                                    AS Avg_Monthly_Income,
    ROUND(AVG(CAST(Age AS FLOAT)), 1)                               AS Avg_Age,
    ROUND(AVG(DebtRatio), 4)                                        AS Avg_Debt_Ratio,
    ROUND(AVG(RevolvingUtilizationOfUnsecuredLines), 4)                             AS Avg_Credit_Utilization,
    SUM(CASE WHEN MonthlyIncome IS NULL THEN 1 ELSE 0 END)          AS Missing_Income_Count,
    CAST(100.0 * SUM(CASE WHEN MonthlyIncome IS NULL
                           THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2))       AS Pct_Missing_Income
FROM credit_risk
WHERE Age > 0
  AND RevolvingUtilizationOfUnsecuredLines <= 1
  AND DebtRatio < 50;




