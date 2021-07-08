SELECT * FROM play_store_apps LIMIT 5;
SELECT * FROM app_store_apps LIMIT 5;
SELECT COUNT(*) FROM play_store_apps;

WITH apps_in_both_stores AS (SELECT DISTINCT name,
									category,
									play.rating AS play_rating,
									play.price::money::numeric AS play_price,
									genres,
									app.price AS app_price, 
									app.rating AS app_rating,
									primary_genre,
							 		play.content_rating AS play_cr,
							 		app.content_rating AS app_cr,
							 		2*play.rating + 1 AS years_in_play_store,
							 		2*app.rating + 1 AS years_in_app_store
							 FROM play_store_apps AS play 
							 INNER JOIN app_store_apps AS app 
							 USING(name)),

income_expense AS (	SELECT 	CASE
								WHEN play_price > 1 AND app_price <= 1 THEN 10000*play_price + 10000
								WHEN app_price > 1 AND play_price <= 1 THEN 10000*app_price + 10000
								WHEN play_price > 1 AND app_price > 1 THEN 10000*app_price + 10000*play_price
								WHEN play_price <= 1 AND app_price <= 1 THEN 20000
							END AS initial_cost,
							CASE 
								WHEN years_in_play_store >= years_in_app_store THEN 12000*years_in_play_store 
								WHEN years_in_play_store < years_in_app_store THEN 12000*years_in_app_store
							END AS operating_cost,
							(30000*years_in_app_store + 30000*years_in_play_store)/2 AS income,
							*
				   
					FROM apps_in_both_stores)

--ELV of individual apps
SELECT  name, 
		primary_genre AS app_store_genre, 
		category AS play_store_genre,
		app_price,
		play_price,
		app_cr,
		play_cr,
		(income - initial_cost - operating_cost)::money AS lifetime_value
FROM income_expense
ORDER BY lifetime_value DESC;

--average ELV by app store genre
SELECT 	DISTINCT(primary_genre) AS app_store_genre,
		COUNT(name),
		AVG(income-initial_cost-operating_cost)::money AS avg_lifetime_value,
	   	AVG(app_price)::money AS avg_app_store_price,
		ROUND(AVG(app_rating),2) AS avg_app_store_rating
FROM income_expense
GROUP BY primary_genre
ORDER BY avg_lifetime_value DESC

--average ELV by play store genre
SELECT 	DISTINCT(category) AS play_store_genre,
		COUNT(name),
		AVG(income-initial_cost-operating_cost)::money AS avg_lifetime_value,
		AVG(play_price)::money AS avg_play_store_price,
		ROUND(AVG(play_rating),2) AS avg_play_store_rating
FROM income_expense
GROUP BY category
ORDER BY avg_lifetime_value DESC

--brainstorming Expected Lifetime Value formula
/*If price $1 or less... ($5000 * 12)* $10,000 * 2
PROFIT = (5000*12*Ya + 5000*12*Yp)/2 - 10,000*a - 10,000*p - 1000*12*MAX(Ya,Yp)
		30,000Ya + 30,000*Yp - 20,000 - 12,000*MAX(Ya,Yp)
		(30000*yrs_play_str - 12000*yrs_play_str)
*/		

--helping Zenon with average ELV by cost category
cost_cat AS (SELECT CASE WHEN app_price <= 1 THEN 'low cost (<= $1)'
						 WHEN app_price > 1 AND app_price <= 5 THEN 'med cost (<= $5)'
						 WHEN app_price > 5 THEN 'high cost (> $5)'
					END AS app_cost_cat,
					CASE WHEN play_price <= 1 THEN 'low cost (<= $1)'
						 WHEN play_price > 1 AND play_price <= 5 THEN 'med cost (<= $5)'
						 WHEN play_price > 5 THEN 'high cost (> $5)'
					END AS play_cost_cat,
					*
			 FROM income_expense)
			 
SELECT app_cost_cat,
		AVG(income-initial_cost-operating_cost)::money
FROM cost_cat
GROUP BY app_cost_cat

SELECT play_cost_cat,
		AVG(income-initial_cost-operating_cost)::money
FROM cost_cat
GROUP BY app_cost_cat

	   
		
		