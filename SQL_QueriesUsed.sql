

-- Data Cleaning and Manipulation Using PostgreSQL

-- Removing Empty Column - Subscription Type
ALTER TABLE bookings DROP COLUMN Subscription_Type;



-- Checking For Duplicates in Booking Id
SELECT booking_id, COUNT(*)
FROM bookings
GROUP BY booking_id
HAVING COUNT(*) > 1;



--  HANDLING MISSING VALUES (I Chose Imputation After Observing the Dataset)

-- Imputing Class Type for Non-Class Bookings(because Class Type logically apply only to class booking type)
UPDATE bookings
SET class_type = COALESCE(class_type, 'N/A')
WHERE booking_type <> 'Class';



-- Imputing Instructor for only Class Booking Type(because instructor also logically apply only to class booking type)
UPDATE bookings
SET instructor = COALESCE(instructor, 'Unknown Instructor')
WHERE booking_type = 'Class';

UPDATE bookings
SET instructor = COALESCE(instructor, 'N/A')
WHERE booking_type <> 'Class';



-- Imputing Facility for Facility, Birthday Party Booking Type
UPDATE bookings
SET facility = COALESCE(facility, 'Unknown Facility')
WHERE booking_type IN ('Facility', 'Birthday Party');

UPDATE bookings
SET facility = COALESCE(facility, 'N/A')
WHERE booking_type = 'Class';




--  Imputing Theme for Only Birthday Parties(because themes logically apply only to birthday party events)
UPDATE bookings
SET theme = COALESCE(theme, 'No Theme Selected')
WHERE booking_type = 'Birthday Party';

UPDATE bookings
SET theme = COALESCE(theme, 'N/A')
WHERE booking_type IN ('Facility', 'Class');



-- Imputing Time Slot 
UPDATE bookings
SET time_slot = COALESCE(time_slot, 'Unknown');



-- Imputing duration
-- computing average duration for confirmed bookings
WITH avg_duration AS (
    SELECT AVG(duration_mins) AS avg_value
    FROM bookings
    WHERE status = 'Confirmed' AND duration_mins IS NOT NULL
)
--  Updating rows with Average Value for "Confirmed" status
UPDATE bookings
SET duration_mins = (SELECT avg_value FROM avg_duration)
WHERE status = 'Confirmed' AND duration_mins IS NULL;
-- Filling Value '0' for "Pending" status
UPDATE bookings
SET duration_mins = 0
WHERE status = 'Pending' AND duration_mins IS NULL;



-- Imputing Price
-- Computing the median price for non-zero values
WITH median_price AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_value
    FROM bookings
    WHERE Price <> 0
)
-- Updating rows where Status = 'Confirmed' and Price = 0 with the computed median
UPDATE bookings
SET price = (SELECT median_value FROM median_price)
WHERE status = 'Confirmed' AND Price = 0;



-- Imputing Missing Customer Email & Phone
UPDATE bookings
SET customer_email = COALESCE(customer_email, 'Not Provided'),
    customer_phone = COALESCE(customer_phone, 'Not Provided');






