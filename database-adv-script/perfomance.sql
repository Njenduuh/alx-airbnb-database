-- User table
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_status ON User(account_status);
CREATE INDEX idx_user_created ON User(created_at);

-- Booking table
CREATE INDEX idx_booking_guest ON Booking(guest_id);
CREATE INDEX idx_booking_property ON Booking(property_id);
CREATE INDEX idx_booking_dates ON Booking(check_in_date, check_out_date);
CREATE INDEX idx_booking_status ON Booking(booking_status);
CREATE INDEX idx_booking_created ON Booking(created_at);

-- Property table
CREATE INDEX idx_property_host ON Property(host_id);
CREATE INDEX idx_property_address ON Property(address_id);
CREATE INDEX idx_property_type ON Property(property_type);
CREATE INDEX idx_property_price ON Property(price_per_night);
CREATE INDEX idx_property_status ON Property(availability_status, listing_status);
