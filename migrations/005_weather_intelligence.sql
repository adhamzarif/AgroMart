-- ═══════════════════════════════════════════════════════════════════
-- AgroFin Migration 005: Weather Intelligence
-- ═══════════════════════════════════════════════════════════════════
-- Adds:
--   1. districts.latitude / districts.longitude  (for OpenWeatherMap calls)
--   2. Seeds coordinates for all 64 BD districts
--   3. weather_forecasts table (current + 5-day forecast cache)
-- ═══════════════════════════════════════════════════════════════════

USE agrofin;

-- ─── 1. Add lat/lon columns to districts (idempotent) ──────────────
DROP PROCEDURE IF EXISTS migration_005_district_coords;
DELIMITER $$
CREATE PROCEDURE migration_005_district_coords()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 'agrofin' AND TABLE_NAME = 'districts'
          AND COLUMN_NAME = 'latitude'
    ) THEN
        ALTER TABLE districts
            ADD COLUMN latitude DECIMAL(9,6) NULL AFTER division,
            ADD COLUMN longitude DECIMAL(9,6) NULL AFTER latitude;
    END IF;
END$$
DELIMITER ;
CALL migration_005_district_coords();
DROP PROCEDURE migration_005_district_coords;

-- ─── 2. Seed district coordinates (Wikipedia values for district centers) ─
-- Dhaka division
UPDATE districts SET latitude=23.8103, longitude=90.4125 WHERE district_name='Dhaka';
UPDATE districts SET latitude=23.6850, longitude=90.5050 WHERE district_name='Narayanganj';
UPDATE districts SET latitude=24.0950, longitude=90.4203 WHERE district_name='Gazipur';
UPDATE districts SET latitude=24.0840, longitude=90.2546 WHERE district_name='Tangail';
UPDATE districts SET latitude=23.6116, longitude=90.4994 WHERE district_name='Munshiganj';
UPDATE districts SET latitude=23.6225, longitude=90.5000 WHERE district_name='Narsingdi';
UPDATE districts SET latitude=23.6166, longitude=89.8377 WHERE district_name='Faridpur';
UPDATE districts SET latitude=23.6228, longitude=89.6437 WHERE district_name='Rajbari';
UPDATE districts SET latitude=23.4621, longitude=89.7522 WHERE district_name='Gopalganj';
UPDATE districts SET latitude=23.4860, longitude=90.1853 WHERE district_name='Madaripur';
UPDATE districts SET latitude=23.5337, longitude=90.3308 WHERE district_name='Shariatpur';
UPDATE districts SET latitude=24.4260, longitude=90.4150 WHERE district_name='Kishoreganj';
UPDATE districts SET latitude=24.0867, longitude=89.9333 WHERE district_name='Manikganj';

-- Chittagong division
UPDATE districts SET latitude=22.3569, longitude=91.7832 WHERE district_name='Chittagong';
UPDATE districts SET latitude=21.4272, longitude=92.0058 WHERE district_name='Cox''s Bazar';
UPDATE districts SET latitude=22.4625, longitude=91.9712 WHERE district_name='Rangamati';
UPDATE districts SET latitude=22.3475, longitude=92.2106 WHERE district_name='Bandarban';
UPDATE districts SET latitude=23.0500, longitude=91.9833 WHERE district_name='Khagrachhari';
UPDATE districts SET latitude=22.9325, longitude=90.7308 WHERE district_name='Bhola';
UPDATE districts SET latitude=23.4607, longitude=91.1809 WHERE district_name='Comilla';
UPDATE districts SET latitude=23.0354, longitude=91.3964 WHERE district_name='Feni';
UPDATE districts SET latitude=22.8696, longitude=91.0973 WHERE district_name='Noakhali';
UPDATE districts SET latitude=22.5856, longitude=90.6516 WHERE district_name='Lakshmipur';
UPDATE districts SET latitude=23.2986, longitude=91.4324 WHERE district_name='Chandpur';
UPDATE districts SET latitude=24.0589, longitude=91.1551 WHERE district_name='Brahmanbaria';

-- Rajshahi division
UPDATE districts SET latitude=24.3745, longitude=88.6042 WHERE district_name='Rajshahi';
UPDATE districts SET latitude=24.8465, longitude=88.7708 WHERE district_name='Naogaon';
UPDATE districts SET latitude=24.7106, longitude=88.2461 WHERE district_name='Chapainawabganj';
UPDATE districts SET latitude=24.7136, longitude=88.4250 WHERE district_name='Natore';
UPDATE districts SET latitude=24.0064, longitude=89.2372 WHERE district_name='Pabna';
UPDATE districts SET latitude=24.4533, longitude=89.7006 WHERE district_name='Sirajganj';
UPDATE districts SET latitude=24.8482, longitude=89.3727 WHERE district_name='Bogura';
UPDATE districts SET latitude=25.0939, longitude=89.0500 WHERE district_name='Joypurhat';

-- Khulna division
UPDATE districts SET latitude=22.8456, longitude=89.5403 WHERE district_name='Khulna';
UPDATE districts SET latitude=22.8000, longitude=89.4500 WHERE district_name='Bagerhat';
UPDATE districts SET latitude=22.7185, longitude=89.0709 WHERE district_name='Satkhira';
UPDATE districts SET latitude=23.0500, longitude=89.5500 WHERE district_name='Jessore';
UPDATE districts SET latitude=23.0167, longitude=89.1167 WHERE district_name='Jhenaidah';
UPDATE districts SET latitude=23.1641, longitude=89.2155 WHERE district_name='Magura';
UPDATE districts SET latitude=23.4500, longitude=89.6300 WHERE district_name='Narail';
UPDATE districts SET latitude=23.6028, longitude=88.6311 WHERE district_name='Kushtia';
UPDATE districts SET latitude=23.7912, longitude=88.9100 WHERE district_name='Meherpur';
UPDATE districts SET latitude=23.6383, longitude=88.8400 WHERE district_name='Chuadanga';

-- Barishal division
UPDATE districts SET latitude=22.7010, longitude=90.3535 WHERE district_name='Barishal';
UPDATE districts SET latitude=22.6033, longitude=90.0850 WHERE district_name='Pirojpur';
UPDATE districts SET latitude=22.0000, longitude=90.1167 WHERE district_name='Patuakhali';
UPDATE districts SET latitude=22.5167, longitude=90.3333 WHERE district_name='Jhalokati';
UPDATE districts SET latitude=22.8333, longitude=90.6833 WHERE district_name='Barguna';

-- Sylhet division
UPDATE districts SET latitude=24.8949, longitude=91.8687 WHERE district_name='Sylhet';
UPDATE districts SET latitude=24.4828, longitude=91.7747 WHERE district_name='Habiganj';
UPDATE districts SET latitude=24.4829, longitude=91.7649 WHERE district_name='Moulvibazar';
UPDATE districts SET latitude=25.0667, longitude=91.4000 WHERE district_name='Sunamganj';

-- Rangpur division
UPDATE districts SET latitude=25.7439, longitude=89.2752 WHERE district_name='Rangpur';
UPDATE districts SET latitude=25.6217, longitude=88.6336 WHERE district_name='Dinajpur';
UPDATE districts SET latitude=26.3411, longitude=88.5542 WHERE district_name='Panchagarh';
UPDATE districts SET latitude=26.0317, longitude=88.4685 WHERE district_name='Thakurgaon';
UPDATE districts SET latitude=25.8000, longitude=88.7833 WHERE district_name='Nilphamari';
UPDATE districts SET latitude=26.0167, longitude=89.6500 WHERE district_name='Lalmonirhat';
UPDATE districts SET latitude=25.7967, longitude=89.6442 WHERE district_name='Kurigram';
UPDATE districts SET latitude=25.4664, longitude=89.4378 WHERE district_name='Gaibandha';

-- Mymensingh division
UPDATE districts SET latitude=24.7471, longitude=90.4203 WHERE district_name='Mymensingh';
UPDATE districts SET latitude=24.5750, longitude=89.9542 WHERE district_name='Jamalpur';
UPDATE districts SET latitude=24.7470, longitude=90.0500 WHERE district_name='Sherpur';
UPDATE districts SET latitude=24.8722, longitude=90.7197 WHERE district_name='Netrokona';

-- ─── 3. weather_forecasts table ──────────────────────────────────
CREATE TABLE IF NOT EXISTS weather_forecasts (
    forecast_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    district_id INT UNSIGNED NOT NULL,
    forecast_date DATE NOT NULL,
    forecast_for ENUM('current','today','tomorrow','day_3','day_4','day_5') NOT NULL,
    temp_min DECIMAL(5,2),
    temp_max DECIMAL(5,2),
    humidity TINYINT UNSIGNED,
    rainfall_mm DECIMAL(6,2) DEFAULT 0,
    wind_speed_kmh DECIMAL(5,2),
    conditions VARCHAR(100),                  -- "Heavy rain", "Sunny", etc.
    icon VARCHAR(20),                         -- OWM icon code
    raw_payload JSON,                         -- full provider response
    fetched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_district_date_for (district_id, forecast_date, forecast_for),
    INDEX idx_district_date (district_id, forecast_date),
    FOREIGN KEY (district_id) REFERENCES districts(district_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT 'Migration 005 complete. District coordinates seeded + weather_forecasts table ready.' AS msg,
       (SELECT COUNT(*) FROM districts WHERE latitude IS NOT NULL) AS districts_with_coords;
