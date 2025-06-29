# 🏡 Airbnb Clone - Database Schema (DDL)

This repository contains the full SQL schema design (DDL) for the **ALX Airbnb Clone** project. The goal is to model a robust, scalable, and normalized relational database that powers the backend of a property rental platform, similar to Airbnb.

---

## 📁 Project Structure

alx-airbnb-database/
└── database-script-0x01/
├── schema.sql # SQL DDL script for creating the entire database schema
└── README.md # Project documentation and usage instructions

markdown
Copy
Edit

---

## 🧱 Schema Overview

The database is organized into modular components:

### 🌍 Location Hierarchy
- `Country`: Stores country info (name, code, currency).
- `State`: Subdivisions of countries.
- `City`: Cities linked to states.
- `Address`: Full addresses with coordinates.

### 👤 User Management
- `User`: Core user data (guests and hosts).
- `User_Phone`: Multiple phone numbers per user.

### 🏠 Property Listings
- `Property`: Main listing details.
- `Amenity`: List of possible amenities.
- `Property_Amenity`: Many-to-many between properties and amenities.
- `Property_Image`: Photos and visual metadata for listings.

### 📆 Bookings
- `Booking`: Reservation details.
- `Booking_Status_History`: Booking state change log.

### 💳 Payments
- `Payment_Method`: Saved payment methods for users.
- `Payment`: Transactions linked to bookings.

### ⭐ Reviews
- `Review`: Feedback from both guests and hosts.

### 💬 Messaging
- `Message`: Communication between users.

### ⚙️ Optimization
- `Property_Search_Cache`: Denormalized table for faster search.
- `User_Statistics`: Aggregated performance data per user.

---

## 📊 Views and Triggers

### ✅ Views
- `vw_property_details`: Full property info with location and host.
- `vw_booking_details`: Guest, host, and booking summary.

### ⚡ Triggers
- `tr_property_cache_update`: Updates cache when a listing is changed.
- `tr_booking_stats_insert`: Updates user statistics on new booking.

---

## 🚀 How to Run

Ensure you have MySQL installed. Then run:

```bash
mysql -u your_username -p < schema.sql