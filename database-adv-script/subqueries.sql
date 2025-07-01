USE airbnb_db;

-- 1️⃣ Non-correlated subquery: Find all properties where average rating is greater than 4.0
SELECT 
    p.property_id,
    p.name,
    AVG(r.rating) AS avg_rating
FROM Property p
JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name
HAVING AVG(r.rating) > 4.0
ORDER BY avg_rating DESC;

-- 2️⃣ Correlated subquery: Find users who have made more than 3 bookings
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    (
        SELECT COUNT(*) 
        FROM Booking b 
        WHERE b.guest_id = u.user_id
    ) AS total_bookings
FROM User u
WHERE (
    SELECT COUNT(*) 
    FROM Booking b 
    WHERE b.guest_id = u.user_id
) > 3
ORDER BY total_bookings DESC;
