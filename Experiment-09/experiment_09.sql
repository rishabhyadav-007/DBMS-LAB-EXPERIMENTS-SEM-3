CREATE DATABASE IF NOT EXISTS RailwayDB;
USE RailwayDB;
CREATE TABLE IF NOT EXISTS Railway_Bookings (
booking_id       INT AUTO_INCREMENT PRIMARY KEY,
pnr_no           VARCHAR(12) NOT NULL,
train_no         INT NOT NULL,
train_name       VARCHAR(100) NOT NULL,
passenger_name   VARCHAR(100) NOT NULL,
age              INT,
gender           CHAR(1),
travel_date      DATE NOT NULL,
source_station   VARCHAR(50) NOT NULL,
dest_station     VARCHAR(50) NOT NULL,
coach_class      VARCHAR(10) NOT NULL,     -- '1A', '2A', '3A', 'SL', 'CC'
fare             DECIMAL(8,2) NOT NULL,
booking_status   VARCHAR(15) NOT NULL,     -- 'CONFIRMED', 'RAC', 'WAITLIST'
booking_time     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DELIMITER $$
CREATE PROCEDURE PopulateBookings(IN total_rows INT)
BEGIN
DECLARE i INT DEFAULT 1;
DECLARE rand_pnr VARCHAR(12);
DECLARE rand_train INT;
DECLARE rand_class VARCHAR(10);
DECLARE rand_status VARCHAR(15);
DECLARE rand_date DATE;
-- Disable autocommit for fast bulk insertion
SET autocommit = 0;
SET rand_pnr    = LPAD(FLOOR(1000000000 + (RAND() * 9000000000)), 10, '0');
SET rand_train  = 12000 + FLOOR(RAND() * 50); -- Train numbers 12000 - 12049
SET rand_class  = ELT(FLOOR(1 + (RAND() * 5)), '1A', '2A', '3A', 'SL', 'CC');
SET rand_status = ELT(FLOOR(1 + (RAND() * 3)), 'CONFIRMED', 'RAC', 'WAITLIST');
SET rand_date   = DATE_ADD('2026-06-01', INTERVAL FLOOR(RAND() * 90) DAY);
INSERT INTO Railway_Bookings (
pnr_no, train_no, train_name, passenger_name, age, gender,
IF(RAND() > 0.5, 'M', 'F'),
rand_date,
ELT(FLOOR(1 + (RAND() * 4)), 'New Delhi', 'Mumbai CST', 'Howrah', 'Chennai Central'),
ELT(FLOOR(1 + (RAND() * 4)), 'Bangalore City', 'Ahmedabad', 'Pune', 'Secunderabad'),
rand_class,
);
SET i = i + 1;
END WHILE;
COMMIT;
SET autocommit = 1;
END$$
DELIMITER ;
-- Call procedure to insert 5,000 records
CALL PopulateBookings(5000);
-- Verify total row count
SELECT COUNT(*) AS total_bookings FROM Railway_Bookings;
SINGLE-COLUMN LOOKUP (pnr_no)
-- Select a sample PNR from the table for testing
SELECT pnr_no FROM Railway_Bookings LIMIT 1;
-- Assume target PNR is '4829104821'
(A) BEFORE INDEX (Full Table Scan)
EXPLAIN SELECT * FROM Railway_Bookings WHERE pnr_no = '4829104821';
CREATE INDEX idx_pnr ON Railway_Bookings (pnr_no);
(C) AFTER INDEX (Const/Ref Lookup)
EXPLAIN SELECT * FROM Railway_Bookings WHERE pnr_no = '4829104821';
SELECT passenger_name, coach_class, fare
FROM Railway_Bookings
WHERE train_no = 12015
AND travel_date = '2026-07-15'
AND booking_status = 'CONFIRMED';
EXPLAIN SELECT passenger_name, coach_class, fare
FROM Railway_Bookings
WHERE train_no = 12015
AND travel_date = '2026-07-15'
AND booking_status = 'CONFIRMED';
-- Multi-column index ordered by equality columns first
CREATE INDEX idx_train_date_status
ON Railway_Bookings (train_no, travel_date, booking_status);
EXPLAIN SELECT passenger_name, coach_class, fare
FROM Railway_Bookings
WHERE train_no = 12015
AND travel_date = '2026-07-15'
AND booking_status = 'CONFIRMED';
Index Used (key)
Key Length (key_len)
