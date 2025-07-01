USE airbnb_db;

-- 1️⃣ INNER JOIN: Get all bookings and the users who made them
SELECT
    b.booking_id,
    b.check_in_date,
    b.check_out_date,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM Booking b
INNER JOIN User u ON b.guest_id = u.user_id;

-- 2️⃣ LEFT JOIN: Get all properties and their reviews (include properties without reviews)
SELECT
    p.property_id,
    p.name AS property_name,
    r.review_id,
    r.rating,
    r.comment
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id;

-- 3️⃣ FULL OUTER JOIN (MySQL workaround using UNION): Get all users and bookings (even unmatched)
SELECT
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.check_in_date,
    b.check_out_date
FROM User u
LEFT JOIN Booking b ON u.user_id = b.guest_id

UNION

SELECT
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.check_in_date,
    b.check_out_date
FROM Booking b
LEFT JOIN User u ON b.guest_id = u.user_id;
