-- data familiraization
SELECT * FROM BNPL_Risk LIMIT 10;

SELECT Age, Income_USD as "Income" FROM BNPL_Risk;

SELECT Income_USD as "Income", Average_Transaction_Value_USD as "Avg. Transaction Value" FROM BNPL_Risk WHERE Credit_Score >= 600; 

SELECT Employment_Status, count(*) FROM BNPL_Risk GROUP BY Employment_Status ORDER BY COUNT(*) DESC;

SELECT Employment_Status, Sum(income_USD)/count(*) from BNPL_Risk GROUP BY Employment_Status;

SELECT Shopping_Category_Most_Frequent as "Most frequent category", Count(*), Sum(Average_Transaction_Value_USD)/count(*) as "Average Transaction Amount" FROM BNPL_Risk GROUP BY Shopping_Category_Most_Frequent ORDER BY count(*) DESC;

-- testing to see the relationship between credit scores, the average debt and if they have late payement history 
SELECT 
	CASE
		WHEN Credit_Score < 580 THEN 'Poor'
		WHEN Credit_Score BETWEEN 580 AND 669 THEN 'Fair'
		WHEN Credit_Score BETWEEN 670 AND 739 THEN 'Good'
		WHEN Credit_Score >= 740 THEN 'Excellent'
	END AS Credit_Score_Bracket,
	count(*) as Num_customers,
	round(Avg(Total_BNPL_Debt_USD), 2) AS "Average BNPL debt",
	round(AVG(Case when Late_Payment_History = 'Yes' Then 1 Else 0 End), 3) as Late_Payment_Rate
FROM BNPL_Risk
GROUP BY Credit_Score_Bracket ORDER BY Credit_Score DESC;
-- found that average debt was pretty similar between all credit score brackets, but the proportion of people with late payement history rose dramatically the worse their credit score bracket was 

--counting how many nulls we find
SELECT Count(*), Min(Credit_Score), Max(Credit_Score)
FROM BNPL_Risk
Where Credit_Score IS NULL;
-- ended up being 298, which is the same as in our credit score bracket

-- testing to see if shopping category relates to late payement rate
SELECT Shopping_Category_Most_Frequent as "Most frequent category", Count(*), round(avg(Average_Transaction_Value_USD), 2) as "Average Transaction Amount", round(AVG(Case when Late_Payment_History = 'Yes' Then 1 Else 0 End), 3) as Late_Payment_Rate
FROM BNPL_Risk GROUP BY Shopping_Category_Most_Frequent ORDER BY count(*) DESC;
-- There really seems to be no relationship between late payment history abd what category. All the rates are between .242 and .255, so not a big difference. 
-- More notable as we previously have seen, is that Category is highly correlated with the average transaction amount, with travel being the highest (804) and groceries/essentials being the lowest (49.84).

-- testing if the amount of active loans is correlated with late payment rate
SELECT Total_BNPL_Active_Loans as "Number of active loans", count(*), round(AVG(Case when Late_Payment_History = 'Yes' Then 1 Else 0 End), 3) as Late_Payment_Rate
FROM BNPL_Risk GROUP BY Total_BNPL_Active_Loans;
-- found no real correlation, most are between .24 and .26, with the only exceptions being 8, which had the lowest late payement rate at .202, as well as 10 which had a late payement rate of .322, which is by far the highest. These two numbers (along with 9) had much lower sample sizes than all the others, so that could explain why. 

--testing the same as before but bracketing the numbers rather then testing them individually 
SELECT 
	CASE
		WHEN Total_BNPL_Active_Loans <= 2 THEN 'Low'
		WHEN Total_BNPL_Active_Loans <= 6 THEN 'Medium'
		ELSE 'High'
	END AS Active_loan_bracket,
	count(*),
	round(AVG(Case when Late_Payment_History = 'Yes' Then 1 Else 0 End), 3) as Late_Payment_Rate
FROM BNPL_Risk
GROUP BY Active_loan_bracket;
-- As expected, when we bracket the number of active loans, the payement rate for all categories are flat

-- testing to see if age relates to late payement rate
SELECT 
	CASE 
		WHEN age <= 30 THEN '18-30' 
		WHEN age BETWEEN 31 AND 50 THEN '31-50'
		ELSE '51+'
	END AS Age_Bracket,
	count(*),
	round(AVG(Case when Late_Payment_History = 'Yes' Then 1 Else 0 End), 3) as Late_Payment_Rate
FROM BNPL_Risk 
GROUP BY Age_bracket;
-- no real relationship between late payement rate and Age

-- seeing if a two dimensional grouping of income and credit score can predict late payement rate. 
SELECT
	CASE 
		WHEN Credit_Score < 580 THEN 'Poor'
		WHEN Credit_Score BETWEEN 580 AND 669 THEN 'Fair'
		WHEN Credit_Score BETWEEN 670 AND 739 THEN 'Good'
		WHEN Credit_Score >= 740 THEN 'Excellent'
	END AS Credit_Score_Bracket,
	CASE
		WHEN Income_USD < 40000 THEN 'Low Income'
		WHEN Income_USD < 80000 THEN 'Mid Income'
		ELSE 'High Income' 
	END AS Income_bracket, 
	count(*) as n, 
	round(AVG(Case when Late_Payment_History = 'Yes' Then 1 Else 0 End), 3) as Late_Payment_Rate
FROM BNPL_Risk
WHERE Credit_Score IS NOT NULL
GROUP BY Credit_Score_Bracket, Income_Bracket
ORDER BY MIN(Credit_Score) DESC, Income_Bracket;
-- Summary: Income predicts late-payment risk in lower Credit score brackets, but not higher ones. 
-- Some of the most telling results. 
-- Those with Excellent Credit score have a Low late payement rate regardless of income (all between .104 and .118) (All with large enough sample sizes, though Exceleent and Low income has 135 which is low comparitvely, but still large enough)
-- Good Credit is the same story as Excellent, all income levels have virtually the same late payement rate (Between .093 and .096) (all good sample sizes)
-- However, Fair credit score, the lower the income, the higher the late payement rate. Goes from .266 for high income, to .297 for mid to .366 for low. (All with large sample sizes)
-- Poor credit score paints a similar picture to Fair. Low income and Poor credit have a .666 late payement rate, while Mid income and Poor Credit has a .474 late payment rate. For note though, High income and Poor credit is has a rate of .512, which is between, but the same size is only 80, so this relationship may not hold. 

