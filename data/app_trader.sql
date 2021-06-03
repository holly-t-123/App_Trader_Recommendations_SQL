WITH apps_in_both_stores AS (SELECT DISTINCT name,
								
									play.rating AS play_rating,
									play.price::money::numeric AS play_price,
							        play.content_rating AS play_content_rating,
									app.price AS app_price,
									app.rating AS app_rating,primary_genre, 
							        app.content_rating AS app_content_rating,
							        2*play.rating + 1 AS years_in_play_store,
							 		2*app.rating + 1 AS years_in_app_store
							        
							 FROM play_store_apps AS play
							 INNER JOIN app_store_apps AS app
							 USING(name)),
	income_expense AS (SELECT CASE
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
SELECT DISTINCT *
FROM apps_in_both_stores
ORDER BY NAME
WHERE app_price <= 1
AND play_price <=1
AND app_rating >=4.0
AND play_rating >=4.0
AND play_rating + app_rating >=9.2;

SELECT play_content_rating,
       COUNT(play_content_rating)AS content_rating_count,
	   AVG(income - initial_cost - operating_cost)::money AS lifetime_value,
	   ROUND(AVG(play_rating),2) AS avg_play_rating,
	   AVG(play_price)::money AS avg_play_price
FROM income_expense
GROUP BY play_content_rating




SELECT app_content_rating,
       COUNT(app_content_rating)AS content_rating_count,
       AVG(income - initial_cost - operating_cost)::money AS lifetime_value,
	   ROUND(AVG(app_rating),2) AS avg_app_rating,
	   AVG(app_price)::money AS avg_app_price
FROM income_expense
GROUP BY app_content_rating


SELECT DISTINCT *
FROM play_store_apps INNER JOIN app_store_apps
USING(name)
ORDER BY name



 












					 



