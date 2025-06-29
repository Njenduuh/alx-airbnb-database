# Airbnb Clone - Sample Data Seeding

This script populates the Airbnb Clone database with sample data for testing and development purposes.

---

## 📄 File

- `seed.sql`: Contains INSERT statements for seeding the database with mock data.

## 🗃️ Tables Populated

- Country, State, City, Address
- User, User_Phone
- Amenity
- Property, Property_Amenity, Property_Image
- Booking, Booking_Status_History
- Payment_Method, Payment
- Review, Message

---

## 🚀 How to Run

Ensure the database `airbnb_db` exists and all tables are created via `schema.sql`.

Then run:

```bash
mysql -u your_username -p airbnb_db < seed.sql
