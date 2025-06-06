-- This file contains SQL queries for the Sakila database.

-- Category DynEnum
-- name: category_enum
select ''||category_id as key, name as label
FROM category
WHERE name LIKE :value
LIMIT :limit

-- Store DynEnum
-- name: store_enum
select ''||s.store_id as key, CONCAT(c.city, ', ', a.district) as label
FROM store s
join address a on s.address_id=a.address_id
join city c on a.city_id = c.city_id 


-- 1. Actor with most films (Bar Chart)
-- name: actor_with_most_films
SELECT CONCAT(a.first_name, ' ', a.last_name) AS actor_name, COUNT(*) as films
FROM actor a
JOIN film_actor fa USING (actor_id)
JOIN film f USING (film_id)
WHERE f.release_year >= :start_year
  AND f.release_year <= :end_year
  AND f.length BETWEEN :min_length AND :max_length
  AND (:category = 0 OR EXISTS (
    SELECT 1 FROM film_category fc
    WHERE fc.film_id = f.film_id AND fc.category_id = :category
  ))
GROUP BY a.actor_id, actor_name
ORDER BY films DESC
LIMIT 20;

-- 2. Monthly rental revenue (Line Chart)
-- name: monthly_rental_revenue
SELECT 
    DATE_TRUNC('month', p.payment_date) as p_date,
    c.name as category_name,
    SUM(p.amount) as total_revenue
FROM payment p
JOIN rental r USING (rental_id)
JOIN inventory i USING (inventory_id)
JOIN film f USING (film_id)
JOIN film_category fc USING (film_id)
JOIN category c USING (category_id)
WHERE p.payment_date >= :start_date
  AND p.payment_date <= :end_date
  AND (:store = 0 OR i.store_id = :store)
GROUP BY p_date, category_name
ORDER BY p_date;

-- 3. Film category distribution (Pie Chart)
-- name: film_category_distribution
SELECT c.name as category_name, COUNT(*) as film_count
FROM category c
JOIN film_category fc USING (category_id)
JOIN film f USING (film_id)
WHERE f.release_year >= :start_year
  AND f.release_year <= :end_year
  AND f.rental_rate BETWEEN :min_rental_rate AND :max_rental_rate
GROUP BY c.category_id, c.name
ORDER BY film_count DESC;

-- 4. Revenue by country (Area Map)
-- name: revenue_by_country
SELECT 
    co.country as country_name,
    SUM(p.amount) as total_revenue
FROM payment p
JOIN rental r USING (rental_id)
JOIN inventory i USING (inventory_id)
JOIN customer cu ON cu.customer_id = r.customer_id
JOIN address a USING (address_id)
JOIN city ci USING (city_id)
JOIN country co USING (country_id)
WHERE p.payment_date >= :start_date
  AND p.payment_date <= :end_date
  AND (:store = 0 OR i.store_id = :store)
GROUP BY co.country_id, co.country
HAVING SUM(p.amount) > 0
ORDER BY total_revenue DESC;

-- 5. Daily rental trends by category (Line Chart)
-- name: daily_rental_trends_by_category
SELECT 
    DATE(r.rental_date) as rental_date,
    c.name as category_name,
    COUNT(*) as rental_count
FROM rental r
JOIN inventory i USING (inventory_id)
JOIN film f USING (film_id)
JOIN film_category fc USING (film_id)
JOIN category c USING (category_id)
WHERE r.rental_date >= :start_date
  AND r.rental_date <= :end_date
  AND (:store = 0 OR i.store_id = :store)
  AND (:category = 0 OR c.category_id = :category)
GROUP BY DATE(r.rental_date), fc.category_id, c.name
ORDER BY rental_date, category_name;

-- 6. Top customers by rental count (Bar Chart)
-- name: top_customers_by_rentals
SELECT 
    CONCAT(cu.first_name, ' ', cu.last_name) as customer_name,
    COUNT(*) as rental_count
FROM customer cu
JOIN rental r USING (customer_id)
JOIN inventory i USING (inventory_id)
JOIN film f USING (film_id)
WHERE r.rental_date >= :start_date
  AND r.rental_date <= :end_date
  AND (:store = 0 OR i.store_id = :store)
  AND f.length BETWEEN :min_length AND :max_length
  AND (:active_only = 'NO' OR cu.active = 1)
GROUP BY cu.customer_id, customer_name
ORDER BY rental_count DESC
LIMIT 25;

-- 7. Film length distribution by category (Bar Chart)
-- name: film_length_distribution_by_category
SELECT 
    c.name as category_name,
    ROUND(AVG(f.length)) as avg_length_minutes
FROM category c
JOIN film_category fc USING (category_id)
JOIN film f USING (film_id)
WHERE f.release_year >= :start_year
  AND f.release_year <= :end_year
GROUP BY c.category_id, c.name
ORDER BY avg_length_minutes DESC;