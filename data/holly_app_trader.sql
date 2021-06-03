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
							30000*years_in_app_store + 30000*years_in_play_store AS income,
							*
					FROM apps_in_both_stores)

SELECT  name, 
		primary_genre AS app_store_genre, 
		category AS play_store_genre,
		app_price,
		play_price,
		app_cr,
		play_cr,
		(income - initial_cost - operating_cost)::money AS lifetime_value
FROM income_expense
ORDER BY lifetime_value DESC


--using app store genre
SELECT primary_genre, 
	   ROUND(AVG(play_rating),2) AS avg_play_rating, 
	   ROUND(AVG(app_rating),2) AS avg_app_rating,
	   ROUND(AVG(play_price),2) AS avg_play_price,
	   ROUND(AVG(app_price),2) AS avg_app_price
FROM apps_in_both_stores 
GROUP BY primary_genre
ORDER BY combined_rating DESC;
--"Catalogs"			4.60	4.50	9.10	7.99	7.99
--"Book"				4.50	4.50	9.00	2.99	2.99
--"Health & Fitness"	4.40	4.50	8.90	2.16	2.16

--using play store genre
SELECT category, 
	   ROUND(AVG(play_rating),2) AS avg_play_rating, 
	   ROUND(AVG(app_rating),2) AS avg_app_rating, 
	   ROUND(AVG(play_price),2) AS avg_play_price,
	   ROUND(AVG(app_price),2) AS avg_app_price
FROM apps_in_both_stores 
GROUP BY category
ORDER BY combined_rating DESC;
--"BOOKS_AND_REFERENCE"	4.70	4.50	9.20	0.00	0.00
--"GAME"				4.42	4.34	8.76	0.27	0.45
--"HEALTH_AND_FITNESS"	4.36	4.36	8.72	1.85	1.85

SELECT *
FROM apps_in_both_stores 
WHERE category IN ('BOOKS_AND_REFERENCE','GAME','HEALTH_AND_FITNESS') 
OR primary_genre IN ('Catalogs', 'Book', 'Health & Fitness')
ORDER BY lifetime_value

--If price $1 or less... ($5000 * 12)* $10,000 * 2
-- PROFIT = (5000*12*Ya + 5000*12*Yp)/2 - 10,000*a - 10,000*p - 1000*12*MAX(Ya,Yp)
-- 		30,000Ya + 30,000*Yp - 20,000 - 12,000*MAX(Ya,Yp)
-- 		(30000*yrs_play_str - 12000*yrs_play_str)
		
SELECT 18000*years_in_play_store + 30000*years_in_app_store - 20000 AS lifetime_value,
		*
FROM apps_in_both_stores
WHERE years_in_play_store >= years_in_app_store
UNION
SELECT 18000*years_in_app_store + 30000*years_in_play_store - 20000 AS lifetime_value,
		*
FROM apps_in_both_stores
WHERE years_in_app_store > years_in_play_store
ORDER BY lifetime_value DESC


						

	   
		
		