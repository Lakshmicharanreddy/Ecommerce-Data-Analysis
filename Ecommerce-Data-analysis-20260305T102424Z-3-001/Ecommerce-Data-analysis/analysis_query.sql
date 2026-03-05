
-- analysing the data 



--OVREALL COMPANY REVENUE


SELECT SUM(REVENUE) AS TOTAL_REVENUE


FROM ECCOMERCE


--TOTAL PROFIT

SELECT SUM(PROFIT) AS TOTAL_PROFIT


FROM ECCOMERCE


--Monthly Revenue Trend


SELECT YEAR,
	   MONTH,
	   SUM(REVENUE) AS TOTAL_REVENUE


FROM ECCOMERCE

GROUP BY YEAR,MONTH

ORDER BY YEAR,MONTH



--Revenue by Category


WITH REVENUE_METRICS AS (

SELECT CATEGORY,
	   SUM(REVENUE) AS REVENUE,
	   SUM(SUM(REVENUE)) OVER() AS OVERALL_REVENUE


FROM ECCOMERCE

GROUP BY CATEGORY

)

SELECT CATEGORY,
       REVENUE,
	   (REVENUE / NULLIF(OVERALL_REVENUE,0)::NUMERIC) * 100 AS REVENUE_CONTRIBUTION

FROM REVENUE_METRICS




--Revenue by Region


SELECT REGION,
	   SUM(REVENUE) AS TOTAL_REVENUE


FROM ECCOMERCE

GROUP BY REGION

ORDER BY TOTAL_REVENUE DESC


--Units Sold by Category


SELECT CATEGORY,
	   SUM(UNITS_SOLD) AS TOTAL_UNITS_SOLD


FROM ECCOMERCE

GROUP BY CATEGORY

ORDER BY TOTAL_UNITS_SOLD DESC



--Average Customer Rating by Category



SELECT CATEGORY,
	   AVG(CUSTOMER_RATING) AS AVERAGE_CUSTOMER_RATING


FROM ECCOMERCE

GROUP BY CATEGORY

ORDER BY  AVERAGE_CUSTOMER_RATING DESC



--ROAS by Category


SELECT CATEGORY,
	   SUM(RETURN_ON_ADDS) AS RETURN_ON_ADVERTISEMENT


FROM ECCOMERCE

GROUP BY CATEGORY

ORDER BY RETURN_ON_ADVERTISEMENT DESC
LIMIT 1




--Profit vs Ad Spend Comparison


WITH CATEGORY_METRICS AS (

SELECT CATEGORY,
	   SUM(PROFIT) AS TOTAL_PROFIT,
	   SUM(ADVERTISEMENT_SPEND) AS TOTAL_ADVERISMENT_SPEND


FROM ECCOMERCE

GROUP BY CATEGORY


)

SELECT *,
CASE
	WHEN TOTAL_ADVERISMENT_SPEND > TOTAL_PROFIT THEN 'NEGATIVE'
	WHEN TOTAL_ADVERISMENT_SPEND = TOTAL_PROFIT THEN 'REMAINS SAME'
	ELSE 'POSITIVE'
END AS INVESTMENT_RETURN_STATUS
	


FROM CATEGORY_METRICS

ORDER BY TOTAL_ADVERISMENT_SPEND DESC


--Revenue Growth (Month-over-Month)


WITH monthly_revenue AS (

    SELECT 
        TO_DATE(year || '-' || month || '-01', 'YYYY-Month-DD') AS month_date,
        SUM(revenue) AS revenue
    FROM eccomerce
    GROUP BY 1

),

mom_calculation AS (

    SELECT 
        month_date,
        revenue,
        LAG(revenue) OVER (ORDER BY month_date) AS previous_revenue
    FROM monthly_revenue

)

SELECT 
    month_date,
    revenue,
    previous_revenue,
    ROUND(
        (revenue - previous_revenue)::NUMERIC
        / NULLIF(previous_revenue, 0)::numeric * 100,
        2
    ) AS mom_percentage_change,
    
    CASE
        WHEN revenue > previous_revenue THEN 'POSITIVE'
        WHEN revenue = previous_revenue THEN 'NO CHANGE'
        ELSE 'NEGATIVE'
    END AS mom_growth_status

FROM mom_calculation
WHERE previous_revenue IS NOT NULL
ORDER BY month_date;




--YOY GROWTH PERCENT


WITH monthly_revenue AS (

    SELECT 
        TO_DATE(year || '-' || month || '-01', 'YYYY-Month-DD') AS month_date,
        SUM(revenue) AS revenue
    FROM eccomerce
    GROUP BY 1

),

yoy_calculation AS (

    SELECT 
        month_date,
        revenue,
        LAG(revenue, 12) OVER (ORDER BY month_date) AS revenue_last_year
    FROM monthly_revenue

)

SELECT 
    month_date,
    revenue,
    revenue_last_year,

    ROUND(
        (revenue - revenue_last_year)::NUMERIC
        / NULLIF(revenue_last_year, 0)::numeric * 100,
        2
    ) AS yoy_percentage_change,

    CASE
        WHEN revenue > revenue_last_year THEN 'POSITIVE'
        WHEN revenue = revenue_last_year THEN 'NO CHANGE'
        ELSE 'NEGATIVE'
    END AS yoy_growth_status

FROM yoy_calculation
WHERE revenue_last_year IS NOT NULL
ORDER BY month_date;



-- CATEGORY PROFIT MARGIN


SELECT CATEGORY,
       SUM(REVENUE) AS total_revenue,
       SUM(cost) AS total_cost,
       (SUM(REVENUE)  - SUM(cost)) AS profit,
       ROUND(((SUM(REVENUE)  - SUM(cost))::NUMERIC / NULLIF(SUM(REVENUE) ,0)::NUMERIC) * 100, 2) AS profit_margin_percent
FROM ECCOMERCE
GROUP BY CATEGORY
ORDER BY profit_margin_percent DESC;












SELECT *

FROM ECCOMERCE



