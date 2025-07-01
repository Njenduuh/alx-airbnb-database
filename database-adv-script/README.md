# Advanced SQL Join Queries - Airbnb Clone

This script demonstrates complex SQL JOIN operations using the Airbnb database schema.

---

## 📄 File

- `joins_queries.sql`: Contains INNER JOIN, LEFT JOIN, and FULL OUTER JOIN queries.

---

## 🔍 Queries Explained

### 1️⃣ INNER JOIN — Bookings + Users

Returns bookings **only when** a user is linked to it.

```sql
SELECT ...
FROM Booking b
INNER JOIN User u ON b.guest_id = u.user_id;
```

---

### 2️⃣ LEFT JOIN — Properties + Reviews

Returns **all properties**, even those without reviews. Review columns are `NULL` if no match.

```sql
SELECT ...
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id;
```

---

### 3️⃣ FULL OUTER JOIN — Users + Bookings

Returns **all users** and **all bookings**, even if not connected.  
MySQL doesn’t support `FULL OUTER JOIN` natively, so we use a `UNION`:

```sql
SELECT ...
FROM User u
LEFT JOIN Booking b ON u.user_id = b.guest_id

UNION

SELECT ...
FROM Booking b
LEFT JOIN User u ON b.guest_id = u.user_id;
```

---

## ✅ How to Run

```bash
mysql -u your_username -p airbnb_db < joins_queries.sql
```

You can also copy/paste each query into MySQL Workbench or any database client.

---

## 👨‍💻 Author

Wilson  
ALX Software Engineering Program  
Repository: `alx-airbnb-database/database-adv-script`
