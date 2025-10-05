# 1. Frequently Rented Categories
SELECT 
    c.name AS Film_Category,
    COUNT(r.inventory_id) AS Rental_Count
FROM
    rental r
        JOIN
    inventory i ON r.inventory_id = i.inventory_id
        JOIN
    film_category fc ON i.film_id = fc.film_id
        JOIN
    category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY Rental_Count DESC;

# 2. TOP 3 Rented Films
SELECT 
    f.title, COUNT(r.rental_id) AS Rental_Count
FROM
    film_text f
        JOIN
    inventory i ON f.film_id = i.film_id
        JOIN
    rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY Rental_Count DESC
LIMIT 3;

# 3. Films that have never been rented
SELECT 
    f.title
FROM
    film_text f
        LEFT JOIN
    inventory i ON f.film_id = i.film_id
        LEFT JOIN
    rental r ON i.inventory_id = r.inventory_id
WHERE
    r.rental_id IS NULL;

# 4. Top 10 Customers
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS Total_Spending
FROM
    payment p
        LEFT JOIN
    customer c ON p.customer_id = c.customer_id
GROUP BY customer_id , first_name , last_name
ORDER BY Total_Spending DESC
LIMIT 10;

# 5. Revenue Earned in Each Store
SELECT 
    st.store_id, SUM(p.amount) AS Total_Sales
FROM
    payment p
        JOIN
    staff s ON p.staff_id = s.staff_id
        JOIN
    store st ON s.store_id = st.store_id
GROUP BY st.store_id;

# 6. Rentals Sold by Staff
SELECT 
    s.first_name,
    s.last_name,
    s.store_id,
    COUNT(r.rental_id) AS Rentals_Sold
FROM
    rental r
        JOIN
    staff s ON r.staff_id = s.staff_id
GROUP BY s.first_name , s.last_name , s.store_id
ORDER BY Rentals_Sold DESC;

# 7. Actor Ranking across categories
Select * 
FROM 
(
SELECT 
	c.name AS Category, 
    a.first_name, a.last_name, 
    COUNT(r.rental_id) AS Total_Rentals,
DENSE_RANK() OVER (PARTITION BY c.name ORDER BY COUNT(r.rental_id)) AS Actor_Rank
FROM 
	actor a
		JOIN 
	film_actor fa ON a.actor_id = fa.actor_id
		JOIN 
	film_category fc ON fa.film_id = fc.film_id
		JOIN 
	category c ON fc.category_id = c.category_id
		JOIN 
	inventory i ON fa.film_id = i.film_id
		JOIN 
	rental r ON i.inventory_id = r.inventory_id
GROUP BY c.name, a.first_name, a.last_name) as Top5
WHERE Actor_Rank <=5
ORDER BY Category, Actor_Rank;

# 8. Country Wise Spending
WITH Country_Wise_Spending AS (
    SELECT 
        co.country AS Country,
        SUM(p.amount) AS Total_Spending
    FROM 
		payment p
		JOIN 
	customer cu ON p.customer_id = cu.customer_id
		JOIN 
	address a ON cu.address_id = a.address_id
		JOIN 
	city ci ON a.city_id = ci.city_id
		JOIN 
	country co ON ci.country_id = co.country_id
    GROUP BY co.country
)
SELECT 
    Country,
    Total_Spending,
    ROUND((Total_Spending / (SELECT SUM(Total_Spending) FROM Country_Wise_Spending)) * 100, 2) AS Percent_of_Global_Revenue
FROM 
	Country_Wise_Spending
ORDER BY Total_Spending DESC
LIMIT 10;

