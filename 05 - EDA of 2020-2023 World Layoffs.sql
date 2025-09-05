-- Exploratory Data Analysis | 
-- Looking at the data or whats inside to see patterns or trends | 
-- ---------------------------------------------------------------
-- DATA OVERVIEW
-- ROWS = 2361 -> 1995 (cleaned)
-- COLUMNS = 9

-- ---------------------------------------------------------------
--  ---------------------REFERENCE-------------------------------
-- company → Company name
-- location → City of headquarters
-- industry → Industry sector
-- total_laid_off → Number of employees laid off
-- percentage_laid_off → % of workforce laid off (e.g., 0.05 = 5%)
-- date → Date of layoffs
-- stage → Funding stage (Series B, Post-IPO, etc.)
-- country → Country
-- funds_raised_millions → Funding raised in millions (eg, 1 = 1 million)
-- ---------------------------------------------------------------




SELECT *
FROM layoffs_staging_02;

SELECT COUNT(*) -- just to count rows
FROM layoffs_staging_02;
-- focus more on [total_laid_off] and [percentage_laid_off] columns


-- --------------------------------------------------------------
-- first is to look at the max total_layoff

SELECT Max(total_laid_off) -- and the MAX result was 12,000. This is the number of employees
FROM layoffs_staging_02;

SELECT Max(percentage_laid_off) -- Max result is 1, which means 100% were laid off in a company | the percentage of workforce in the company
FROM layoffs_staging_02;

SELECT *
FROM layoffs_staging_02
WHERE percentage_laid_off = 1 -- 1 means 100% and the max number of laid of is 2434
ORDER BY total_laid_off DESC
; 

-- total_laid_off && percentage_laid_off are comparable

-- if total_laid_off = positive && percentage_laid_off = 1
	-- THEN the company shut down OR terminated every employee
    
-- IF total_laid_off = NULL  && percentage_laid_off = present
	-- THEN exact number is missing and percentage shows portions only

-- --------------------------------------------------------------
-- I will look at the funds_raised_million 
SELECT *
FROM layoffs_staging_02
WHERE funds_raised_millions IS NOT NULL -- MAX 121.9 Billion $ invested
ORDER BY 9 DESC;

-- MIN is 1 million but there are rows with 0

-- --------------------------------------------------------------

-- check the companies that closed or terminated all employees
SELECT *
FROM layoffs_staging_02
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- --------------------------------------------------------------
-- check the comapny and SUM of total laid off
-- SUM of total laid off, which means the total number across all companies
SELECT company, SUM(total_laid_off) AS total_laid_off_sum -- need to do this bc there are multiple rows with the same company
FROM layoffs_staging_02
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY 2 DESC; 

SELECT company, total_laid_off, `date`
FROM layoffs_staging_02
WHERE company = 'amazon' -- there are 3 rows, 150 + 8000 + 10000
ORDER BY 1 ASC;
-- --------------------------------------------------------------
-- look at date range

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging_02
; -- MIN = March 2020 | MAX = March 2023

-- --------------------------------------------------------------


SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_02
GROUP BY industry
; -- healthcare has the highest laid off


SELECT country, SUM(total_laid_off)
FROM layoffs_staging_02
GROUP BY country
ORDER BY 2 DESC
; -- USA, India, Netherlands are the top 3 in terms # of total laid off

-- ------------------------------------------------------------
-- checking the dates, 2020 - 2023
SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging_02
GROUP BY `date`
ORDER BY 1 DESC; -- much better if group by years (2020, 2021, 2022 & 2023)

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_02
GROUP BY YEAR(`date`)
ORDER BY 1; -- this is better

-- check the staging of the company

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging_02
GROUP BY stage
ORDER BY 2 DESC; 

-- -----------------------------------------------------------

-- checking at percentages of laid off

SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging_02
GROUP BY company
ORDER BY 2 DESC; -- hmmm theres 2 and 1.7 | looks irrelevant

SELECT company, AVG(percentage_laid_off) -- use average
FROM layoffs_staging_02
GROUP BY company
ORDER BY 2 DESC;


-- -----------------------------------------------------------
-- check the rolling total of layoffs but base on the month
-- hardest in the lesson

SELECT SUBSTRING(`date`, 6, 2) AS `MONTH`,  -- this is to get the month, 1111 is just optional just to see the day
SUM(total_laid_off)
FROM layoffs_staging_02
GROUP BY `MONTH`
ORDER BY 1; -- january is the highest but the year is not shown bc i only choose month or substring 6.... 

SELECT *
FROM layoffs_staging_02;


SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`,  -- include the year & month only in the substring. Day is not included
SUM(total_laid_off)
FROM layoffs_staging_02
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;  

-- the rolling total --------------------
-- CTE table --------
WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`,  -- include the year & month only in the substring. Day is not included
SUM(total_laid_off) AS Total_Off
FROM layoffs_staging_02
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC  
)
SELECT `MONTH`, total_off, SUM(Total_Off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total
; -- this is continous rolling total from 2020 onwards. 

SELECT company, `date`, SUM(total_laid_off)
FROM layoffs_staging_02
GROUP BY company, `date`
ORDER BY 3 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_02
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- CTE table with dense ranking per year---------------
WITH 

Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_02
GROUP BY company, YEAR(`date`)
), 

Company_Year_Rank AS (
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS `rank`
FROM Company_Year
WHERE years IS NOT NULL)
-- ORDER BY `rank` ASC 


SELECT * 
FROM Company_Year_Rank
WHERE `rank` <= 5

;

/* 
Summary:
1. Company_Year CTE → sum layoffs per company per year | cleans
2. Company_Year_Rank CTE → rank companies by layoffs inside each year | ranksthf
3. SELECT * → get only the top 5 companies per year | final result
*/

-- ---------------------------------------------

/*
This project:
-Cleaned & explored layoff dataset (2020–2023)
-patterned by company, industry, country, stage, time
-rolling totals and rankings in layoffs
-insight: Layoffs were concentrated in a few big companies, mostly USA based, in 2022–2023.
*/











