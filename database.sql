-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 14, 2026 at 04:31 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `agrofin`
--

-- --------------------------------------------------------

--
-- Table structure for table `agents`
--

CREATE TABLE `agents` (
  `agent_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `agent_code` varchar(20) NOT NULL,
  `service_districts` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`service_districts`)),
  `vehicle_type` enum('motorcycle','bicycle','none') DEFAULT 'none',
  `commission_rate` decimal(5,2) DEFAULT 2.00,
  `training_completed` tinyint(1) DEFAULT 0,
  `training_completion_date` date DEFAULT NULL,
  `agent_rating` decimal(3,2) DEFAULT 0.00,
  `total_farmers_assigned` int(10) UNSIGNED DEFAULT 0,
  `total_commission_earned` decimal(12,2) DEFAULT 0.00,
  `bank_account_number` varchar(50) DEFAULT NULL,
  `bank_name` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive','suspended') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `agents`
--

INSERT INTO `agents` (`agent_id`, `user_id`, `agent_code`, `service_districts`, `vehicle_type`, `commission_rate`, `training_completed`, `training_completion_date`, `agent_rating`, `total_farmers_assigned`, `total_commission_earned`, `bank_account_number`, `bank_name`, `status`, `created_at`, `updated_at`) VALUES
(1, 6, 'AGT-MYM-042', '[40, 22, 46]', 'motorcycle', 2.50, 1, '2025-08-15', 4.90, 2, 480.00, NULL, NULL, 'active', '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(2, 7, 'AGT-COM-018', '[12, 8, 7]', 'motorcycle', 2.00, 1, '2025-09-20', 4.70, 1, 200.00, NULL, NULL, 'active', '2026-06-03 15:58:45', '2026-06-03 15:58:45');

-- --------------------------------------------------------

--
-- Table structure for table `agent_activities`
--

CREATE TABLE `agent_activities` (
  `activity_id` int(10) UNSIGNED NOT NULL,
  `agent_id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED DEFAULT NULL,
  `activity_type` enum('farmer_registration','crop_listing','order_help','loan_assistance','message_help','training_session','field_visit','other') NOT NULL,
  `description` text DEFAULT NULL,
  `commission_earned` decimal(10,2) DEFAULT 0.00,
  `activity_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `agent_activities`
--

INSERT INTO `agent_activities` (`activity_id`, `agent_id`, `farmer_id`, `activity_type`, `description`, `commission_earned`, `activity_date`) VALUES
(1, 1, 1, 'farmer_registration', 'করিম মিয়া কে নিবন্ধন সম্পন্ন', 200.00, '2026-02-03 15:58:45'),
(2, 1, 1, 'crop_listing', '৫০০ কেজি ধান লিস্ট করা হয়েছে', 50.00, '2026-05-22 15:58:45'),
(3, 1, 1, 'order_help', 'প্রথম অর্ডার নিশ্চিতকরণে সহায়তা', 30.00, '2026-05-24 15:58:45'),
(4, 1, 3, 'farmer_registration', 'আব্দুল হালিম কে নিবন্ধন সম্পন্ন', 200.00, '2026-05-04 15:58:45'),
(5, 2, 2, 'loan_assistance', 'ফাতেমা বেগম এর লোন আবেদনে সহায়তা', 150.00, '2026-04-29 15:58:45'),
(6, 2, 2, 'crop_listing', '১০০০ কেজি আলু লিস্ট করা হয়েছে', 50.00, '2026-05-14 15:58:45');

-- --------------------------------------------------------

--
-- Table structure for table `agent_farmer_mapping`
--

CREATE TABLE `agent_farmer_mapping` (
  `mapping_id` int(10) UNSIGNED NOT NULL,
  `agent_id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED NOT NULL,
  `assigned_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `help_count` int(10) UNSIGNED DEFAULT 0,
  `last_interaction` timestamp NULL DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `agent_farmer_mapping`
--

INSERT INTO `agent_farmer_mapping` (`mapping_id`, `agent_id`, `farmer_id`, `assigned_date`, `help_count`, `last_interaction`, `status`) VALUES
(1, 1, 1, '2026-06-03 15:58:45', 47, '2026-06-01 15:58:45', 'active'),
(2, 1, 3, '2026-06-03 15:58:45', 8, '2026-05-29 15:58:45', 'active'),
(3, 2, 2, '2026-06-03 15:58:45', 23, '2026-06-02 15:58:45', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `assistant_queries`
--

CREATE TABLE `assistant_queries` (
  `query_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `query_type` enum('voice','text') NOT NULL,
  `query_language` enum('bangla','english') NOT NULL,
  `user_query` text NOT NULL,
  `detected_intent` varchar(100) DEFAULT NULL,
  `assistant_response` text DEFAULT NULL,
  `response_time_ms` int(10) UNSIGNED DEFAULT NULL,
  `was_helpful` tinyint(1) DEFAULT NULL,
  `feedback_text` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `assistant_queries`
--

INSERT INTO `assistant_queries` (`query_id`, `user_id`, `query_type`, `query_language`, `user_query`, `detected_intent`, `assistant_response`, `response_time_ms`, `was_helpful`, `feedback_text`, `created_at`) VALUES
(1, 1, 'text', 'bangla', 'আজকের আবহাওয়া কেমন?', 'weather', '⚠ আপনার এলাকায় ১ টি সক্রিয় সতর্কতা রয়েছে:\n\n• ময়মনসিংহ অঞ্চলে ভারী বৃষ্টিপাত (medium মাত্রা)\n  আগামী ৭২ ঘণ্টায় ময়মনসিংহ ও আশেপাশের জেলায় ভারী বৃষ্টিপাতের সম্ভাবনা রয়েছে।\n  সুপারিশ: কাটা ফসল ঢেকে রাখুন। জলাবদ্ধতা এড়াতে নিকাশ ব্যবস্থা ঠিক রাখুন।\n\nবিস্তারিত: /farmer/weather', 9, NULL, NULL, '2026-06-03 16:02:10'),
(2, 1, 'text', 'bangla', 'আজকের আবহাওয়া কেমন?', 'weather', '⚠ আপনার এলাকায় ১ টি সক্রিয় সতর্কতা রয়েছে:\n\n• ময়মনসিংহ অঞ্চলে ভারী বৃষ্টিপাত (medium মাত্রা)\n  আগামী ৭২ ঘণ্টায় ময়মনসিংহ ও আশেপাশের জেলায় ভারী বৃষ্টিপাতের সম্ভাবনা রয়েছে।\n  সুপারিশ: কাটা ফসল ঢেকে রাখুন। জলাবদ্ধতা এড়াতে নিকাশ ব্যবস্থা ঠিক রাখুন।\n\nবিস্তারিত: /farmer/weather', 5, NULL, NULL, '2026-06-03 16:08:50'),
(3, 1, 'text', 'bangla', 'আজকের আবহাওয়া কেমন?', 'weather', '⚠ আপনার এলাকায় ১ টি সক্রিয় সতর্কতা রয়েছে:\n\n• ময়মনসিংহ অঞ্চলে ভারী বৃষ্টিপাত (medium মাত্রা)\n  আগামী ৭২ ঘণ্টায় ময়মনসিংহ ও আশেপাশের জেলায় ভারী বৃষ্টিপাতের সম্ভাবনা রয়েছে।\n  সুপারিশ: কাটা ফসল ঢেকে রাখুন। জলাবদ্ধতা এড়াতে নিকাশ ব্যবস্থা ঠিক রাখুন।\n\nবিস্তারিত: /farmer/weather', 3, NULL, NULL, '2026-06-03 16:08:53'),
(4, 1, 'text', 'bangla', 'আজকের আবহাওয়া কেমন?', 'weather', '⚠ আপনার এলাকায় ১ টি সক্রিয় সতর্কতা রয়েছে:\n\n• ময়মনসিংহ অঞ্চলে ভারী বৃষ্টিপাত (medium মাত্রা)\n  আগামী ৭২ ঘণ্টায় ময়মনসিংহ ও আশেপাশের জেলায় ভারী বৃষ্টিপাতের সম্ভাবনা রয়েছে।\n  সুপারিশ: কাটা ফসল ঢেকে রাখুন। জলাবদ্ধতা এড়াতে নিকাশ ব্যবস্থা ঠিক রাখুন।\n\nবিস্তারিত: /farmer/weather', 6, NULL, NULL, '2026-06-03 16:09:09'),
(5, 1, 'text', 'bangla', 'আজকের আবহাওয়া কেমন?', 'weather', '⚠ আপনার এলাকায় ১ টি সক্রিয় সতর্কতা রয়েছে:\n\n• ময়মনসিংহ অঞ্চলে ভারী বৃষ্টিপাত (medium মাত্রা)\n  আগামী ৭২ ঘণ্টায় ময়মনসিংহ ও আশেপাশের জেলায় ভারী বৃষ্টিপাতের সম্ভাবনা রয়েছে।\n  সুপারিশ: কাটা ফসল ঢেকে রাখুন। জলাবদ্ধতা এড়াতে নিকাশ ব্যবস্থা ঠিক রাখুন।\n\nবিস্তারিত: /farmer/weather', 1, NULL, NULL, '2026-06-03 16:10:00'),
(6, 3, 'text', 'english', 'mango price', 'price', '💹 সাম্প্রতিক বাজার দর:\n\n• বোরো ধান (Dhaka) — পাইকারি ৳42 / kg\n• আলু (Munshiganj) — পাইকারি ৳18 / kg\n• পেঁয়াজ (Faridpur) — পাইকারি ৳55 / kg\n• রসুন (Dhaka) — পাইকারি ৳130 / kg\n• বেগুন (Mymensingh) — পাইকারি ৳28 / kg\n\nবিস্তারিত: /liveprice — অথবা একটি নির্দিষ্ট ফসলের নাম বলুন (যেমন: \'ধানের দাম কত?\')', 12, 0, NULL, '2026-06-03 17:06:06'),
(7, 3, 'text', 'bangla', 'আমার অর্ডার?', 'order', '📦 আপনার সক্রিয় অর্ডার সংখ্যা: ১ টি\n\nঅর্ডার ব্যবস্থাপনা: /farmer/orders\nঅর্ডার এর কোনো বিশেষ সমস্যা থাকলে এজেন্টকে টিকেট দিন।', 3, NULL, NULL, '2026-06-03 17:06:37'),
(8, 1, 'text', 'bangla', 'কোন ফসল লাভজনক?', 'recommendation', '🌱 আপনার এলাকার জন্য শীর্ষ ফসল সুপারিশ:\n\n🌾 মুগ ডাল — স্কোর 85.0/১০০\n   মৌসুম: summer | মেয়াদ: 90 দিন\n   লাভ মার্জিন: 35.0% | বিনিয়োগ: ৳8,000\n   কারণ: বর্তমান বাজারে মুগ ডালের চাহিদা বেশি। উচ্চ মুনাফার সম্ভাবনা।\n\n🌾 করলা — স্কোর 78.0/১০০\n   মৌসুম: summer | মেয়াদ: 75 দিন\n   লাভ মার্জিন: 28.0% | বিনিয়োগ: ৳12,000\n   কারণ: গ্রীষ্মকালীন সবজি, ভালো বাজারমূল্য।\n\n', 44, NULL, NULL, '2026-06-04 13:41:15'),
(9, 9, 'text', 'bangla', 'আজকের আবহাওয়া কেমন?', 'weather', '⚠ আপনার এলাকায় ১ টি সক্রিয় সতর্কতা রয়েছে:\n\n• ভারী বর্ষণের পূর্বাভাস (high মাত্রা)\n  Patuakhali জেলায় 2026-06-13 তারিখে আনুমানিক 98.4মিমি বৃষ্টিপাত হতে পারে।\n  সুপারিশ: ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন\n\nবিস্তারিত: /farmer/weather', 89, NULL, NULL, '2026-06-10 17:11:30');

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `log_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `action_type` varchar(50) NOT NULL,
  `table_name` varchar(50) NOT NULL,
  `record_id` int(10) UNSIGNED DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crops`
--

CREATE TABLE `crops` (
  `crop_id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED NOT NULL,
  `category_id` int(10) UNSIGNED NOT NULL,
  `crop_name` varchar(100) NOT NULL,
  `crop_variety` varchar(100) DEFAULT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit` enum('kg','ton','mon','piece') NOT NULL,
  `price_per_unit` decimal(10,2) NOT NULL,
  `quality_grade` enum('A','B','C') DEFAULT 'B',
  `is_organic` tinyint(1) DEFAULT 0,
  `harvest_date` date DEFAULT NULL,
  `available_from` date NOT NULL,
  `available_until` date DEFAULT NULL,
  `description` text DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `status` enum('available','sold','expired','removed') DEFAULT 'available',
  `views_count` int(10) UNSIGNED DEFAULT 0,
  `listed_by_agent` tinyint(1) DEFAULT 0,
  `agent_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `crops`
--

INSERT INTO `crops` (`crop_id`, `farmer_id`, `category_id`, `crop_name`, `crop_variety`, `quantity`, `unit`, `price_per_unit`, `quality_grade`, `is_organic`, `harvest_date`, `available_from`, `available_until`, `description`, `images`, `status`, `views_count`, `listed_by_agent`, `agent_id`, `created_at`, `updated_at`) VALUES
(1, 1, 2, 'টমেটো', 'হাইব্রিড', 95.00, 'kg', 45.00, 'A', 0, '2026-06-08', '2026-06-08', '2026-06-10', 'টেস্ট টমেটো', '[\"20260608_210919_124978e2.jpg\"]', 'expired', 7, 0, NULL, '2026-06-08 15:09:19', '2026-06-10 18:00:03'),
(2, 1, 1, 'ধান', 'BRRI-28', 99.00, 'kg', 38.00, 'A', 0, '2026-06-10', '2026-06-10', '2026-06-30', '', '[\"20260610_070236_934461ab.jpg\"]', 'available', 1, 0, NULL, '2026-06-10 01:02:36', '2026-06-10 07:37:15'),
(3, 1, 1, 'গম', 'BARI গম-33', 75.01, 'kg', 42.00, 'A', 0, '2026-06-10', '2026-06-10', '2026-06-30', 'টেস্ট গম', '[\"20260610_070612_07b34ac7.jpg\"]', 'available', 1, 0, NULL, '2026-06-10 01:06:12', '2026-06-10 07:31:03'),
(4, 9, 2, 'আলু', 'ডায়মন্ড', 250.00, 'kg', 20.00, 'A', 0, '2026-06-10', '2026-06-10', '2026-06-30', 'টেস্ট আলু', '[\"20260610_071155_b4c22a45.jpg\"]', 'available', 0, 0, NULL, '2026-06-10 01:11:55', '2026-06-10 01:11:55'),
(5, 9, 3, 'আম', 'হিমসাগর', 150.00, 'kg', 90.00, 'A', 1, '2026-06-10', '2026-06-10', '2026-06-15', 'টেস্ট আম', '[\"20260610_071636_6a3af6e5.jpg\"]', 'available', 0, 0, NULL, '2026-06-10 01:16:36', '2026-06-10 01:16:36'),
(6, 9, 3, 'লিচু', 'বোম্বাই', 1000.00, 'piece', 4.00, 'A', 0, '2026-06-10', '2026-06-10', '2026-06-16', 'best lichi', '[\"20260610_072324_0a3af515.jpg\"]', 'available', 7, 0, NULL, '2026-06-10 01:22:22', '2026-06-10 09:53:15'),
(7, 2, 1, 'ডাল (মসুর)', 'BARI মসুর-8', 200.00, 'kg', 60.00, 'A', 0, '2026-06-14', '2026-06-14', '2026-07-11', '', '[\"20260614_164700_5e301f12.jpg\"]', 'available', 0, 0, NULL, '2026-06-14 10:47:00', '2026-06-14 10:47:00'),
(8, 2, 1, 'ডাল (মুগ)', 'মুগ-6', 150.00, 'kg', 65.00, 'A', 0, '2026-06-15', '2026-06-14', '2026-07-11', '', '[\"20260614_164932_2f5061c4.jpg\"]', 'available', 0, 0, NULL, '2026-06-14 10:48:12', '2026-06-14 10:49:32'),
(9, 2, 1, 'সরিষা', 'সরিষা-17', 89.00, 'kg', 70.00, 'A', 0, '2026-06-14', '2026-06-14', '2026-07-11', '', '[\"20260614_165513_1b58c649.jpg\"]', 'available', 1, 0, NULL, '2026-06-14 10:55:13', '2026-06-14 11:33:34'),
(10, 3, 2, 'বেগুন', 'হাইব্রিড', 30.00, 'kg', 40.00, 'A', 0, '2026-06-15', '2026-06-14', '2026-06-20', '', '[\"20260614_165852_c9678b9d.png\"]', 'available', 0, 0, NULL, '2026-06-14 10:58:52', '2026-06-14 10:58:52'),
(11, 3, 2, 'কাঁচামরিচ', 'হাইব্রিড', 60.00, 'kg', 60.00, 'A', 1, '2026-06-14', '2026-06-14', '2026-06-21', '', '[\"20260614_170044_e2861888.jpg\"]', 'available', 1, 0, NULL, '2026-06-14 11:00:44', '2026-06-14 11:06:48'),
(12, 3, 1, 'লাউ', 'দেশি', 30.01, 'piece', 20.00, 'A', 1, '2026-06-15', '2026-06-14', '2026-06-21', '', '[\"20260614_170303_85f82510.jpg\"]', 'available', 3, 0, NULL, '2026-06-14 11:03:03', '2026-06-14 11:07:03');

--
-- Triggers `crops`
--
DELIMITER $$
CREATE TRIGGER `tr_crops_after_update` AFTER UPDATE ON `crops` FOR EACH ROW BEGIN
    
    IF NEW.quantity <> OLD.quantity THEN
        
        
        
        IF NOT EXISTS (
            SELECT 1 FROM inventory_logs
            WHERE crop_id = NEW.crop_id
              AND quantity_after = NEW.quantity
              AND logged_at >= NOW() - INTERVAL 2 SECOND
        ) THEN
            INSERT INTO inventory_logs
                (crop_id, change_type, quantity_before, quantity_after,
                 change_reason, changed_by)
            VALUES (
                NEW.crop_id,
                CASE
                    WHEN NEW.quantity > OLD.quantity THEN 'restocked'
                    WHEN NEW.quantity < OLD.quantity THEN 'sold'
                    ELSE 'adjusted'
                END,
                OLD.quantity,
                NEW.quantity,
                CONCAT('Auto-logged by trigger (delta: ',
                       CASE WHEN NEW.quantity > OLD.quantity THEN '+' ELSE '' END,
                       (NEW.quantity - OLD.quantity), ')'),
                NEW.farmer_id
            );
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `crop_categories`
--

CREATE TABLE `crop_categories` (
  `category_id` int(10) UNSIGNED NOT NULL,
  `category_name` varchar(50) NOT NULL,
  `category_name_bn` varchar(50) NOT NULL,
  `parent_category_id` int(10) UNSIGNED DEFAULT NULL,
  `description` text DEFAULT NULL,
  `icon` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `crop_categories`
--

INSERT INTO `crop_categories` (`category_id`, `category_name`, `category_name_bn`, `parent_category_id`, `description`, `icon`, `created_at`) VALUES
(1, 'Cereals', 'দানাশস্য', NULL, 'ধান, গম, ভুট্টা ইত্যাদি', '🌾', '2026-06-03 15:58:45'),
(2, 'Vegetables', 'সবজি', NULL, 'তাজা মৌসুমি সবজি', '🥕', '2026-06-03 15:58:45'),
(3, 'Fruits', 'ফলমূল', NULL, 'মৌসুমি ফল', '🍎', '2026-06-03 15:58:45'),
(4, 'Pulses', 'ডাল', NULL, 'মসুর, মুগ, খেসারি ইত্যাদি', '🫘', '2026-06-03 15:58:45'),
(5, 'Spices', 'মশলা', NULL, 'হলুদ, মরিচ, পেঁয়াজ ইত্যাদি', '🌶', '2026-06-03 15:58:45'),
(6, 'Cash Crops', 'অর্থকরী ফসল', NULL, 'পাট, তুলা, আখ ইত্যাদি', '🌿', '2026-06-03 15:58:45'),
(7, 'Oilseeds', 'তৈলবীজ', NULL, 'সরিষা, তিল ইত্যাদি', '🌻', '2026-06-03 15:58:45');

-- --------------------------------------------------------

--
-- Table structure for table `crop_recommendations`
--

CREATE TABLE `crop_recommendations` (
  `recommendation_id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED DEFAULT NULL,
  `district_id` int(10) UNSIGNED NOT NULL,
  `season` enum('winter','summer','monsoon','autumn') NOT NULL,
  `recommended_crop` varchar(100) NOT NULL,
  `recommendation_score` decimal(5,2) NOT NULL,
  `demand_score` decimal(5,2) NOT NULL,
  `price_score` decimal(5,2) NOT NULL,
  `success_rate` decimal(5,2) NOT NULL,
  `expected_profit_margin` decimal(5,2) DEFAULT NULL,
  `investment_required` decimal(10,2) DEFAULT NULL,
  `growing_duration_days` int(10) UNSIGNED DEFAULT NULL,
  `water_requirement` enum('low','medium','high') DEFAULT 'medium',
  `difficulty_level` enum('easy','medium','hard') DEFAULT 'medium',
  `recommendation_reason` text DEFAULT NULL,
  `recommendation_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `crop_recommendations`
--

INSERT INTO `crop_recommendations` (`recommendation_id`, `farmer_id`, `district_id`, `season`, `recommended_crop`, `recommendation_score`, `demand_score`, `price_score`, `success_rate`, `expected_profit_margin`, `investment_required`, `growing_duration_days`, `water_requirement`, `difficulty_level`, `recommendation_reason`, `recommendation_date`, `created_at`) VALUES
(1, NULL, 40, 'summer', 'মুগ ডাল', 85.00, 80.00, 90.00, 78.00, 35.00, 8000.00, 90, 'low', 'easy', 'বর্তমান বাজারে মুগ ডালের চাহিদা বেশি। উচ্চ মুনাফার সম্ভাবনা।', '2026-06-03', '2026-06-03 15:58:45'),
(2, NULL, 40, 'summer', 'করলা', 78.00, 85.00, 75.00, 72.00, 28.00, 12000.00, 75, 'medium', 'medium', 'গ্রীষ্মকালীন সবজি, ভালো বাজারমূল্য।', '2026-06-03', '2026-06-03 15:58:45'),
(3, NULL, 12, 'summer', 'পেঁপে', 82.00, 88.00, 80.00, 75.00, 32.00, 15000.00, 120, 'medium', 'medium', 'কুমিল্লা অঞ্চলে পেঁপের চাহিদা সারাবছর।', '2026-06-03', '2026-06-03 15:58:45'),
(4, NULL, 55, 'monsoon', 'আমন ধান', 90.00, 90.00, 85.00, 88.00, 25.00, 10000.00, 120, 'high', 'easy', 'রংপুর অঞ্চলে আমন চাষের জন্য আদর্শ মৌসুম।', '2026-06-03', '2026-06-03 15:58:45');

-- --------------------------------------------------------

--
-- Table structure for table `dashboard_widgets`
--

CREATE TABLE `dashboard_widgets` (
  `widget_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `widget_type` varchar(50) NOT NULL,
  `widget_position` int(10) UNSIGNED NOT NULL,
  `widget_config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`widget_config`)),
  `is_visible` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `deliveries`
--

CREATE TABLE `deliveries` (
  `delivery_id` int(10) UNSIGNED NOT NULL,
  `order_id` int(10) UNSIGNED NOT NULL,
  `transport_partner_id` int(10) UNSIGNED DEFAULT NULL,
  `vehicle_type` enum('pickup','truck','van','motorcycle') NOT NULL,
  `vehicle_number` varchar(20) DEFAULT NULL,
  `driver_name` varchar(100) DEFAULT NULL,
  `driver_phone` varchar(15) DEFAULT NULL,
  `pickup_address` text NOT NULL,
  `delivery_address` text NOT NULL,
  `distance_km` decimal(6,2) DEFAULT NULL,
  `delivery_charge` decimal(8,2) NOT NULL,
  `pickup_time` timestamp NULL DEFAULT NULL,
  `estimated_delivery_time` timestamp NULL DEFAULT NULL,
  `actual_delivery_time` timestamp NULL DEFAULT NULL,
  `current_location` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`current_location`)),
  `delivery_status` enum('pending','picked_up','in_transit','out_for_delivery','delivered','failed') DEFAULT 'pending',
  `delivery_proof_url` varchar(255) DEFAULT NULL,
  `receiver_signature_url` varchar(255) DEFAULT NULL,
  `delivery_notes` text DEFAULT NULL,
  `delivery_rating` decimal(2,1) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `demand_analytics`
--

CREATE TABLE `demand_analytics` (
  `demand_id` int(10) UNSIGNED NOT NULL,
  `crop_name` varchar(100) NOT NULL,
  `district_id` int(10) UNSIGNED NOT NULL,
  `analysis_date` date NOT NULL,
  `total_supply_kg` decimal(12,2) DEFAULT 0.00,
  `total_demand_orders` int(10) UNSIGNED DEFAULT 0,
  `demand_supply_ratio` decimal(8,4) DEFAULT 0.0000,
  `market_status` enum('surplus','balanced','shortage') DEFAULT 'balanced',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `demand_analytics`
--

INSERT INTO `demand_analytics` (`demand_id`, `crop_name`, `district_id`, `analysis_date`, `total_supply_kg`, `total_demand_orders`, `demand_supply_ratio`, `market_status`, `created_at`) VALUES
(1, 'আম', 55, '2026-06-03', 150.00, 1, 0.0667, 'balanced', '2026-06-03 16:00:03'),
(2, 'গম', 55, '2026-06-03', 800.00, 0, 0.0000, 'surplus', '2026-06-03 16:00:03'),
(3, 'ডায়মন্ড আলু', 12, '2026-06-03', 1000.00, 1, 0.0100, 'surplus', '2026-06-03 16:00:03'),
(4, 'পেঁয়াজ', 12, '2026-06-03', 300.00, 0, 0.0000, 'surplus', '2026-06-03 16:00:03'),
(5, 'বোরো ধান', 40, '2026-06-03', 500.00, 0, 0.0000, 'surplus', '2026-06-03 16:00:03'),
(6, 'মসুর ডাল', 40, '2026-06-03', 100.00, 0, 0.0000, 'surplus', '2026-06-03 16:00:03'),
(7, 'টমেটো', 40, '2026-06-03', 0.00, 1, 9999.9999, 'shortage', '2026-06-03 16:00:03'),
(8, 'টমেটো', 40, '2026-06-09', 100.00, 0, 0.0000, 'surplus', '2026-06-09 00:54:06'),
(9, 'আম', 51, '2026-06-10', 150.00, 0, 0.0000, 'surplus', '2026-06-10 18:00:03'),
(10, 'আলু', 51, '2026-06-10', 250.00, 0, 0.0000, 'surplus', '2026-06-10 18:00:03'),
(11, 'গম', 40, '2026-06-10', 75.01, 1, 0.1333, 'balanced', '2026-06-10 18:00:03'),
(12, 'ধান', 40, '2026-06-10', 99.00, 1, 0.1010, 'balanced', '2026-06-10 18:00:03'),
(13, 'লিচু', 51, '2026-06-10', 1000.00, 0, 0.0000, 'surplus', '2026-06-10 18:00:03'),
(14, 'টমেটো', 40, '2026-06-10', 0.00, 5, 9999.9999, 'shortage', '2026-06-10 18:00:03');

-- --------------------------------------------------------

--
-- Table structure for table `districts`
--

CREATE TABLE `districts` (
  `district_id` int(10) UNSIGNED NOT NULL,
  `district_name` varchar(50) NOT NULL,
  `division` enum('Dhaka','Chittagong','Rajshahi','Khulna','Barishal','Sylhet','Rangpur','Mymensingh') NOT NULL,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `districts`
--

INSERT INTO `districts` (`district_id`, `district_name`, `division`, `latitude`, `longitude`, `created_at`) VALUES
(1, 'Bagerhat', 'Khulna', 22.800000, 89.450000, '2026-06-03 15:58:44'),
(2, 'Bandarban', 'Chittagong', 22.347500, 92.210600, '2026-06-03 15:58:44'),
(3, 'Barguna', 'Barishal', 22.833300, 90.683300, '2026-06-03 15:58:44'),
(4, 'Barishal', 'Barishal', 22.701000, 90.353500, '2026-06-03 15:58:44'),
(5, 'Bhola', 'Barishal', 22.932500, 90.730800, '2026-06-03 15:58:44'),
(6, 'Bogra', 'Rajshahi', NULL, NULL, '2026-06-03 15:58:44'),
(7, 'Brahmanbaria', 'Chittagong', 24.058900, 91.155100, '2026-06-03 15:58:44'),
(8, 'Chandpur', 'Chittagong', 23.298600, 91.432400, '2026-06-03 15:58:44'),
(9, 'Chapai Nawabganj', 'Rajshahi', NULL, NULL, '2026-06-03 15:58:44'),
(10, 'Chattogram', 'Chittagong', NULL, NULL, '2026-06-03 15:58:44'),
(11, 'Chuadanga', 'Khulna', 23.638300, 88.840000, '2026-06-03 15:58:44'),
(12, 'Comilla', 'Chittagong', 23.460700, 91.180900, '2026-06-03 15:58:44'),
(13, 'Cox\'s Bazar', 'Chittagong', 21.427200, 92.005800, '2026-06-03 15:58:44'),
(14, 'Dhaka', 'Dhaka', 23.810300, 90.412500, '2026-06-03 15:58:44'),
(15, 'Dinajpur', 'Rangpur', 25.621700, 88.633600, '2026-06-03 15:58:44'),
(16, 'Faridpur', 'Dhaka', 23.616600, 89.837700, '2026-06-03 15:58:44'),
(17, 'Feni', 'Chittagong', 23.035400, 91.396400, '2026-06-03 15:58:44'),
(18, 'Gaibandha', 'Rangpur', 25.466400, 89.437800, '2026-06-03 15:58:44'),
(19, 'Gazipur', 'Dhaka', 24.095000, 90.420300, '2026-06-03 15:58:44'),
(20, 'Gopalganj', 'Dhaka', 23.462100, 89.752200, '2026-06-03 15:58:44'),
(21, 'Habiganj', 'Sylhet', 24.482800, 91.774700, '2026-06-03 15:58:44'),
(22, 'Jamalpur', 'Mymensingh', 24.575000, 89.954200, '2026-06-03 15:58:44'),
(23, 'Jashore', 'Khulna', NULL, NULL, '2026-06-03 15:58:44'),
(24, 'Jhalokati', 'Barishal', 22.516700, 90.333300, '2026-06-03 15:58:44'),
(25, 'Jhenaidah', 'Khulna', 23.016700, 89.116700, '2026-06-03 15:58:44'),
(26, 'Joypurhat', 'Rajshahi', 25.093900, 89.050000, '2026-06-03 15:58:44'),
(27, 'Khagrachhari', 'Chittagong', 23.050000, 91.983300, '2026-06-03 15:58:44'),
(28, 'Khulna', 'Khulna', 22.845600, 89.540300, '2026-06-03 15:58:44'),
(29, 'Kishoreganj', 'Dhaka', 24.426000, 90.415000, '2026-06-03 15:58:44'),
(30, 'Kurigram', 'Rangpur', 25.796700, 89.644200, '2026-06-03 15:58:44'),
(31, 'Kushtia', 'Khulna', 23.602800, 88.631100, '2026-06-03 15:58:44'),
(32, 'Lakshmipur', 'Chittagong', 22.585600, 90.651600, '2026-06-03 15:58:44'),
(33, 'Lalmonirhat', 'Rangpur', 26.016700, 89.650000, '2026-06-03 15:58:44'),
(34, 'Madaripur', 'Dhaka', 23.486000, 90.185300, '2026-06-03 15:58:44'),
(35, 'Magura', 'Khulna', 23.164100, 89.215500, '2026-06-03 15:58:44'),
(36, 'Manikganj', 'Dhaka', 24.086700, 89.933300, '2026-06-03 15:58:44'),
(37, 'Meherpur', 'Khulna', 23.791200, 88.910000, '2026-06-03 15:58:44'),
(38, 'Moulvibazar', 'Sylhet', 24.482900, 91.764900, '2026-06-03 15:58:44'),
(39, 'Munshiganj', 'Dhaka', 23.611600, 90.499400, '2026-06-03 15:58:44'),
(40, 'Mymensingh', 'Mymensingh', 24.747100, 90.420300, '2026-06-03 15:58:44'),
(41, 'Naogaon', 'Rajshahi', 24.846500, 88.770800, '2026-06-03 15:58:44'),
(42, 'Narail', 'Khulna', 23.450000, 89.630000, '2026-06-03 15:58:44'),
(43, 'Narayanganj', 'Dhaka', 23.685000, 90.505000, '2026-06-03 15:58:44'),
(44, 'Narsingdi', 'Dhaka', 23.622500, 90.500000, '2026-06-03 15:58:44'),
(45, 'Natore', 'Rajshahi', 24.713600, 88.425000, '2026-06-03 15:58:44'),
(46, 'Netrokona', 'Mymensingh', 24.872200, 90.719700, '2026-06-03 15:58:44'),
(47, 'Nilphamari', 'Rangpur', 25.800000, 88.783300, '2026-06-03 15:58:44'),
(48, 'Noakhali', 'Chittagong', 22.869600, 91.097300, '2026-06-03 15:58:44'),
(49, 'Pabna', 'Rajshahi', 24.006400, 89.237200, '2026-06-03 15:58:44'),
(50, 'Panchagarh', 'Rangpur', 26.341100, 88.554200, '2026-06-03 15:58:44'),
(51, 'Patuakhali', 'Barishal', 22.000000, 90.116700, '2026-06-03 15:58:44'),
(52, 'Pirojpur', 'Barishal', 22.603300, 90.085000, '2026-06-03 15:58:44'),
(53, 'Rajbari', 'Dhaka', 23.622800, 89.643700, '2026-06-03 15:58:44'),
(54, 'Rajshahi', 'Rajshahi', 24.374500, 88.604200, '2026-06-03 15:58:44'),
(55, 'Rangamati', 'Chittagong', 22.462500, 91.971200, '2026-06-03 15:58:44'),
(56, 'Rangpur', 'Rangpur', 25.743900, 89.275200, '2026-06-03 15:58:44'),
(57, 'Satkhira', 'Khulna', 22.718500, 89.070900, '2026-06-03 15:58:44'),
(58, 'Shariatpur', 'Dhaka', 23.533700, 90.330800, '2026-06-03 15:58:44'),
(59, 'Sherpur', 'Mymensingh', 24.747000, 90.050000, '2026-06-03 15:58:44'),
(60, 'Sirajganj', 'Rajshahi', 24.453300, 89.700600, '2026-06-03 15:58:44'),
(61, 'Sunamganj', 'Sylhet', 25.066700, 91.400000, '2026-06-03 15:58:44'),
(62, 'Sylhet', 'Sylhet', 24.894900, 91.868700, '2026-06-03 15:58:44'),
(63, 'Tangail', 'Dhaka', 24.084000, 90.254600, '2026-06-03 15:58:44'),
(64, 'Thakurgaon', 'Rangpur', 26.031700, 88.468500, '2026-06-03 15:58:44');

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `expense_id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED NOT NULL,
  `crop_id` int(10) UNSIGNED DEFAULT NULL,
  `expense_category` enum('seeds','fertilizer','pesticide','labor','irrigation','equipment','transport','other') NOT NULL,
  `expense_amount` decimal(10,2) NOT NULL,
  `expense_description` varchar(255) DEFAULT NULL,
  `expense_date` date NOT NULL,
  `receipt_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `farmer_groups`
--

CREATE TABLE `farmer_groups` (
  `group_id` int(10) UNSIGNED NOT NULL,
  `group_name` varchar(100) NOT NULL,
  `group_code` varchar(20) NOT NULL,
  `group_leader_id` int(10) UNSIGNED NOT NULL,
  `district_id` int(10) UNSIGNED NOT NULL,
  `total_members` int(10) UNSIGNED DEFAULT 1,
  `total_land_acres` decimal(10,2) DEFAULT 0.00,
  `group_description` text DEFAULT NULL,
  `formation_date` date NOT NULL,
  `approved_by` int(10) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `farmer_ratings`
--

CREATE TABLE `farmer_ratings` (
  `rating_id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED NOT NULL,
  `buyer_id` int(10) UNSIGNED NOT NULL,
  `order_id` int(10) UNSIGNED NOT NULL,
  `overall_rating` decimal(2,1) NOT NULL,
  `quality_rating` decimal(2,1) NOT NULL,
  `delivery_rating` decimal(2,1) NOT NULL,
  `communication_rating` decimal(2,1) NOT NULL,
  `review_title` varchar(100) DEFAULT NULL,
  `review_text` text DEFAULT NULL,
  `review_images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`review_images`)),
  `would_recommend` tinyint(1) DEFAULT 1,
  `is_verified_purchase` tinyint(1) DEFAULT 1,
  `helpful_count` int(10) UNSIGNED DEFAULT 0,
  `farmer_response` text DEFAULT NULL,
  `responded_at` timestamp NULL DEFAULT NULL,
  `is_flagged` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `farmer_support_tickets`
--

CREATE TABLE `farmer_support_tickets` (
  `ticket_id` int(10) UNSIGNED NOT NULL,
  `ticket_number` varchar(20) NOT NULL,
  `farmer_id` int(10) UNSIGNED NOT NULL,
  `assigned_agent_id` int(10) UNSIGNED DEFAULT NULL,
  `issue_type` enum('registration_help','crop_listing','order_issue','payment_problem','loan_query','technical_issue','account_access','other') NOT NULL,
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `subject` varchar(200) NOT NULL,
  `description` text NOT NULL,
  `status` enum('open','in_progress','resolved','closed','cancelled') DEFAULT 'open',
  `resolution_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `assigned_at` timestamp NULL DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `favorite_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `favorite_type` enum('crop','farmer') NOT NULL,
  `crop_id` int(10) UNSIGNED DEFAULT NULL,
  `farmer_id` int(10) UNSIGNED DEFAULT NULL,
  `price_alert_enabled` tinyint(1) DEFAULT 0,
  `alert_price_threshold` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `favorites`
--

INSERT INTO `favorites` (`favorite_id`, `user_id`, `favorite_type`, `crop_id`, `farmer_id`, `price_alert_enabled`, `alert_price_threshold`, `created_at`) VALUES
(5, 4, 'farmer', NULL, 1, 0, NULL, '2026-06-03 15:58:45'),
(6, 5, 'farmer', NULL, 2, 0, NULL, '2026-06-03 15:58:45');

-- --------------------------------------------------------

--
-- Table structure for table `group_members`
--

CREATE TABLE `group_members` (
  `membership_id` int(10) UNSIGNED NOT NULL,
  `group_id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED NOT NULL,
  `land_contribution_acres` decimal(8,2) DEFAULT 0.00,
  `join_date` date NOT NULL,
  `member_role` enum('leader','member','treasurer') DEFAULT 'member',
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_logs`
--

CREATE TABLE `inventory_logs` (
  `log_id` int(10) UNSIGNED NOT NULL,
  `crop_id` int(10) UNSIGNED NOT NULL,
  `change_type` enum('listed','sold','adjusted','expired','restocked') NOT NULL,
  `quantity_before` decimal(10,2) NOT NULL,
  `quantity_after` decimal(10,2) NOT NULL,
  `change_reason` varchar(255) DEFAULT NULL,
  `changed_by` int(10) UNSIGNED DEFAULT NULL,
  `logged_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inventory_logs`
--

INSERT INTO `inventory_logs` (`log_id`, `crop_id`, `change_type`, `quantity_before`, `quantity_after`, `change_reason`, `changed_by`, `logged_at`) VALUES
(1, 1, 'listed', 0.00, 100.00, 'নতুন ফসল লিস্ট', 1, '2026-06-08 15:09:19'),
(2, 2, 'listed', 0.00, 100.00, 'নতুন ফসল লিস্ট', 1, '2026-06-10 01:02:36'),
(3, 3, 'listed', 0.00, 80.00, 'নতুন ফসল লিস্ট', 1, '2026-06-10 01:06:12'),
(4, 4, 'listed', 0.00, 250.00, 'নতুন ফসল লিস্ট', 9, '2026-06-10 01:11:55'),
(5, 5, 'listed', 0.00, 150.00, 'নতুন ফসল লিস্ট', 9, '2026-06-10 01:16:36'),
(6, 6, 'listed', 0.00, 1000.00, 'নতুন ফসল লিস্ট', 9, '2026-06-10 01:22:22'),
(7, 3, 'sold', 80.00, 75.01, 'Auto-logged by trigger (delta: -4.99)', 1, '2026-06-10 07:31:03'),
(8, 3, 'sold', 80.00, 75.01, 'অর্ডার ORD-20260610-9DC02D', 9, '2026-06-10 07:31:03'),
(9, 2, 'sold', 100.00, 99.00, 'Auto-logged by trigger (delta: -1.00)', 1, '2026-06-10 07:37:15'),
(10, 2, 'sold', 100.00, 99.00, 'অর্ডার ORD-20260610-61B64C', 9, '2026-06-10 07:37:15'),
(11, 1, 'sold', 100.00, 99.00, 'Auto-logged by trigger (delta: -1.00)', 1, '2026-06-10 07:43:52'),
(12, 1, 'sold', 100.00, 99.00, 'অর্ডার ORD-20260610-6B5B05', 9, '2026-06-10 07:43:52'),
(13, 1, 'sold', 99.00, 98.00, 'Auto-logged by trigger (delta: -1.00)', 1, '2026-06-10 07:47:39'),
(14, 1, 'sold', 99.00, 98.00, 'অর্ডার ORD-20260610-66DE9C', 9, '2026-06-10 07:47:39'),
(15, 1, 'sold', 98.00, 97.00, 'Auto-logged by trigger (delta: -1.00)', 1, '2026-06-10 09:53:23'),
(16, 1, 'sold', 98.00, 97.00, 'অর্ডার ORD-20260610-D38033', 9, '2026-06-10 09:53:23'),
(17, 1, 'sold', 97.00, 96.00, 'Auto-logged by trigger (delta: -1.00)', 1, '2026-06-10 09:55:51'),
(18, 1, 'sold', 97.00, 96.00, 'অর্ডার ORD-20260610-87CC90', 9, '2026-06-10 09:55:51'),
(19, 1, 'sold', 96.00, 95.00, 'Auto-logged by trigger (delta: -1.00)', 1, '2026-06-10 17:12:15'),
(20, 1, 'sold', 96.00, 95.00, 'অর্ডার ORD-20260610-A3D098', 9, '2026-06-10 17:12:15'),
(21, 7, 'listed', 0.00, 200.00, 'নতুন ফসল লিস্ট', 2, '2026-06-14 10:47:00'),
(22, 8, 'listed', 0.00, 150.00, 'নতুন ফসল লিস্ট', 2, '2026-06-14 10:48:12'),
(23, 9, 'listed', 0.00, 90.00, 'নতুন ফসল লিস্ট', 2, '2026-06-14 10:55:13'),
(24, 10, 'listed', 0.00, 30.00, 'নতুন ফসল লিস্ট', 3, '2026-06-14 10:58:52'),
(25, 11, 'listed', 0.00, 60.00, 'নতুন ফসল লিস্ট', 3, '2026-06-14 11:00:44'),
(26, 12, 'listed', 0.00, 40.00, 'নতুন ফসল লিস্ট', 3, '2026-06-14 11:03:03'),
(27, 12, 'sold', 40.00, 20.00, 'Auto-logged by trigger (delta: -20.00)', 3, '2026-06-14 11:06:01'),
(28, 12, 'sold', 40.00, 20.00, 'অর্ডার ORD-20260614-F8156A', 9, '2026-06-14 11:06:01'),
(29, 12, 'restocked', 20.00, 40.00, 'Auto-logged by trigger (delta: +20.00)', 3, '2026-06-14 11:06:29'),
(30, 12, 'restocked', 20.00, 40.00, 'অর্ডার বাতিল: ', 9, '2026-06-14 11:06:29'),
(31, 12, 'sold', 40.00, 30.01, 'Auto-logged by trigger (delta: -9.99)', 3, '2026-06-14 11:07:03'),
(32, 12, 'sold', 40.00, 30.01, 'অর্ডার ORD-20260614-0E59B6', 9, '2026-06-14 11:07:03'),
(33, 9, 'sold', 90.00, 89.00, 'Auto-logged by trigger (delta: -1.00)', 2, '2026-06-14 11:33:34'),
(34, 9, 'sold', 90.00, 89.00, 'অর্ডার ORD-20260614-55425E', 9, '2026-06-14 11:33:34');

-- --------------------------------------------------------

--
-- Table structure for table `loans`
--

CREATE TABLE `loans` (
  `loan_id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED NOT NULL,
  `loan_amount` decimal(12,2) NOT NULL,
  `interest_rate` decimal(5,2) DEFAULT 5.00,
  `loan_purpose` varchar(255) NOT NULL,
  `tenure_months` int(10) UNSIGNED NOT NULL,
  `monthly_installment` decimal(10,2) NOT NULL,
  `total_payable` decimal(12,2) NOT NULL,
  `amount_paid` decimal(12,2) DEFAULT 0.00,
  `remaining_balance` decimal(12,2) NOT NULL,
  `credit_score_at_application` int(10) UNSIGNED DEFAULT NULL,
  `application_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `approval_date` timestamp NULL DEFAULT NULL,
  `disbursement_date` timestamp NULL DEFAULT NULL,
  `next_payment_date` date DEFAULT NULL,
  `status` enum('pending','approved','rejected','disbursed','active','completed','defaulted') DEFAULT 'pending',
  `approved_by` int(10) UNSIGNED DEFAULT NULL,
  `rejection_reason` varchar(255) DEFAULT NULL,
  `assisted_by_agent` tinyint(1) DEFAULT 0,
  `agent_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `loans`
--

INSERT INTO `loans` (`loan_id`, `farmer_id`, `loan_amount`, `interest_rate`, `loan_purpose`, `tenure_months`, `monthly_installment`, `total_payable`, `amount_paid`, `remaining_balance`, `credit_score_at_application`, `application_date`, `approval_date`, `disbursement_date`, `next_payment_date`, `status`, `approved_by`, `rejection_reason`, `assisted_by_agent`, `agent_id`, `created_at`, `updated_at`) VALUES
(1, 1, 20000.00, 8.00, 'বীজ ও সার ক্রয়', 6, 3500.00, 21000.00, 14000.00, 7000.00, 78, '2026-04-04 15:58:45', '2026-04-06 15:58:45', '2026-04-07 15:58:45', '2026-06-08', 'active', 8, NULL, 0, NULL, '2026-06-03 15:58:45', '2026-06-10 10:47:35'),
(2, 2, 15000.00, 8.00, 'কৃষি সরঞ্জাম ক্রয়', 4, 3900.00, 15700.00, 3900.00, 11800.00, 72, '2026-04-29 15:58:45', '2026-04-30 15:58:45', '2026-05-01 15:58:45', '2026-06-05', 'active', 8, NULL, 0, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(3, 3, 10000.00, 8.00, 'সেচ যন্ত্র ক্রয়', 3, 3450.00, 10350.00, 0.00, 10350.00, 65, '2026-06-01 15:58:45', NULL, NULL, NULL, 'pending', NULL, NULL, 0, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(4, 1, 5000.00, 8.00, 'অতিরিক্ত মূলধন', 2, 2570.00, 5140.00, 5140.00, 0.00, 80, '2026-03-05 15:58:45', '2026-03-06 15:58:45', '2026-03-07 15:58:45', NULL, 'completed', 8, NULL, 0, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45');

-- --------------------------------------------------------

--
-- Table structure for table `loan_repayments`
--

CREATE TABLE `loan_repayments` (
  `repayment_id` int(10) UNSIGNED NOT NULL,
  `loan_id` int(10) UNSIGNED NOT NULL,
  `payment_amount` decimal(10,2) NOT NULL,
  `payment_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `payment_method` enum('auto_deduction','manual','cash','mobile_banking') DEFAULT 'auto_deduction',
  `transaction_reference` varchar(100) DEFAULT NULL,
  `late_fee` decimal(8,2) DEFAULT 0.00,
  `is_early_payment` tinyint(1) DEFAULT 0,
  `remaining_after_payment` decimal(12,2) NOT NULL,
  `recorded_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `loan_repayments`
--

INSERT INTO `loan_repayments` (`repayment_id`, `loan_id`, `payment_amount`, `payment_date`, `payment_method`, `transaction_reference`, `late_fee`, `is_early_payment`, `remaining_after_payment`, `recorded_by`, `created_at`) VALUES
(1, 1, 3500.00, '2026-05-04 15:58:45', 'auto_deduction', 'TXN001', 0.00, 0, 17500.00, NULL, '2026-06-03 15:58:45'),
(2, 1, 3500.00, '2026-06-02 15:58:45', 'auto_deduction', 'TXN002', 0.00, 0, 14000.00, NULL, '2026-06-03 15:58:45'),
(3, 2, 3900.00, '2026-05-31 15:58:45', 'manual', 'TXN003', 0.00, 0, 11800.00, NULL, '2026-06-03 15:58:45'),
(4, 1, 3500.00, '2026-06-10 10:46:55', 'manual', NULL, 0.00, 0, 10500.00, NULL, '2026-06-10 10:46:55'),
(5, 1, 3500.00, '2026-06-10 10:47:35', 'manual', 'bikash', 0.00, 0, 7000.00, NULL, '2026-06-10 10:47:35');

-- --------------------------------------------------------

--
-- Table structure for table `market_prices`
--

CREATE TABLE `market_prices` (
  `price_id` int(10) UNSIGNED NOT NULL,
  `crop_name` varchar(100) NOT NULL,
  `district_id` int(10) UNSIGNED NOT NULL,
  `wholesale_price` decimal(10,2) NOT NULL,
  `retail_price` decimal(10,2) NOT NULL,
  `unit` enum('kg','ton','mon','piece') DEFAULT 'kg',
  `price_date` date NOT NULL,
  `source` varchar(100) DEFAULT 'DAM',
  `updated_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `market_prices`
--

INSERT INTO `market_prices` (`price_id`, `crop_name`, `district_id`, `wholesale_price`, `retail_price`, `unit`, `price_date`, `source`, `updated_by`, `created_at`) VALUES
(1, 'বোরো ধান', 14, 42.00, 45.00, 'kg', '2026-06-03', 'DAM', NULL, '2026-06-03 15:58:45'),
(2, 'বোরো ধান', 40, 40.00, 43.00, 'kg', '2026-06-03', 'DAM', NULL, '2026-06-03 15:58:45'),
(3, 'বোরো ধান', 12, 41.00, 44.00, 'kg', '2026-06-03', 'DAM', NULL, '2026-06-03 15:58:45'),
(4, 'টমেটো', 14, 48.00, 55.00, 'kg', '2026-06-03', 'DAM', NULL, '2026-06-03 15:58:45'),
(5, 'টমেটো', 40, 44.00, 50.00, 'kg', '2026-06-03', 'DAM', NULL, '2026-06-03 15:58:45'),
(6, 'আলু', 14, 38.00, 42.00, 'kg', '2026-06-03', 'DAM', NULL, '2026-06-03 15:58:45'),
(7, 'পেঁয়াজ', 14, 60.00, 70.00, 'kg', '2026-06-03', 'DAM', NULL, '2026-06-03 15:58:45'),
(8, 'গম', 14, 40.00, 45.00, 'kg', '2026-06-03', 'DAM', NULL, '2026-06-03 15:58:45'),
(9, 'আম', 14, 100.00, 120.00, 'kg', '2026-06-03', 'DAM', NULL, '2026-06-03 15:58:45'),
(10, 'বোরো ধান', 14, 41.00, 44.00, 'kg', '2026-06-02', 'DAM', NULL, '2026-06-03 15:58:45'),
(11, 'টমেটো', 14, 50.00, 56.00, 'kg', '2026-06-02', 'DAM', NULL, '2026-06-03 15:58:45'),
(12, 'আলু', 14, 39.00, 43.00, 'kg', '2026-06-02', 'DAM', NULL, '2026-06-03 15:58:45'),
(13, 'ধান (Boro)', 14, 32.09, 41.88, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(14, 'ধান (Boro)', 40, 30.06, 40.14, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(15, 'ধান (Boro)', 56, 29.00, 38.03, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(16, 'গম', 15, 38.13, 50.03, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(17, 'ভুট্টা', 56, 27.92, 38.05, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(18, 'আলু', 39, 17.95, 28.06, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(19, 'পেঁয়াজ', 16, 54.96, 74.74, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(20, 'রসুন', 14, 130.18, 174.39, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(21, 'বেগুন', 40, 28.10, 44.94, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(22, 'বেগুন', 14, 34.98, 55.15, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(23, 'লাউ', 12, 24.93, 40.11, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(24, 'কাঁচামরিচ', 14, 100.28, 160.34, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(25, 'আদা', 62, 180.00, 240.34, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(26, 'ইলিশ', 4, 551.15, 849.41, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(27, 'ইলিশ', 8, 500.00, 798.32, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(28, 'পাট', 56, 65.23, 85.00, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(29, 'ডাল (মসুর)', 49, 95.20, 130.09, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(30, 'ডাল (মুগ)', 49, 109.62, 150.31, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(31, 'সরিষা', 15, 85.12, 114.84, 'kg', '2026-06-03', 'AgroFin Seed', NULL, '2026-06-03 16:00:03'),
(32, 'ধান (Boro)', 14, 32.03, 42.05, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(33, 'ধান (Boro)', 40, 29.98, 40.06, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(34, 'ধান (Boro)', 56, 28.99, 38.05, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(35, 'গম', 15, 37.97, 49.98, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(36, 'গম', 14, 42.02, 55.00, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(37, 'ভুট্টা', 56, 27.95, 37.98, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(38, 'আলু', 39, 18.03, 27.97, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(39, 'আলু', 14, 21.96, 32.03, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(40, 'পেঁয়াজ', 16, 55.11, 74.88, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(41, 'পেঁয়াজ', 14, 65.08, 85.00, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(42, 'রসুন', 14, 130.21, 175.35, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(43, 'টমেটো', 14, 44.96, 69.89, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(44, 'বেগুন', 40, 28.00, 45.09, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(45, 'বেগুন', 14, 35.04, 55.02, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(46, 'লাউ', 12, 25.04, 39.95, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(47, 'কাঁচামরিচ', 14, 99.96, 160.26, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(48, 'আদা', 62, 179.93, 240.39, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(49, 'ইলিশ', 4, 548.89, 850.00, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(50, 'ইলিশ', 8, 500.61, 799.35, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(51, 'পাট', 56, 64.95, 84.93, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(52, 'ডাল (মসুর)', 49, 94.96, 130.00, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(53, 'ডাল (মুগ)', 49, 109.82, 149.82, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(54, 'সরিষা', 15, 85.17, 114.77, 'kg', '2026-06-09', 'AgroFin Seed', NULL, '2026-06-09 00:54:06'),
(55, 'ধান (Boro)', 14, 31.95, 41.97, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(56, 'ধান (Boro)', 40, 30.04, 40.00, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(57, 'ধান (Boro)', 56, 28.95, 38.04, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(58, 'গম', 15, 38.04, 49.93, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(59, 'গম', 14, 42.01, 54.92, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(60, 'ভুট্টা', 56, 28.00, 38.01, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(61, 'আলু', 39, 17.97, 28.02, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(62, 'আলু', 14, 21.98, 31.98, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(63, 'পেঁয়াজ', 16, 55.06, 74.95, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(64, 'পেঁয়াজ', 14, 64.98, 84.97, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(65, 'রসুন', 14, 129.81, 175.31, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(66, 'টমেটো', 14, 44.95, 69.90, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(67, 'বেগুন', 40, 28.00, 45.06, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(68, 'বেগুন', 14, 35.01, 55.06, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(69, 'লাউ', 12, 24.96, 40.06, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(70, 'কাঁচামরিচ', 14, 99.86, 160.23, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(71, 'আদা', 62, 179.87, 240.09, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(72, 'ইলিশ', 4, 550.20, 849.70, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(73, 'ইলিশ', 8, 500.00, 799.72, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(74, 'পাট', 56, 65.05, 84.97, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(75, 'ডাল (মসুর)', 49, 95.17, 130.14, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(76, 'ডাল (মুগ)', 49, 109.88, 150.27, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03'),
(77, 'সরিষা', 15, 85.12, 114.80, 'kg', '2026-06-10', 'AgroFin Seed', NULL, '2026-06-10 18:00:03');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `message_id` int(10) UNSIGNED NOT NULL,
  `sender_id` int(10) UNSIGNED NOT NULL,
  `receiver_id` int(10) UNSIGNED NOT NULL,
  `message_text` text NOT NULL,
  `message_type` enum('text','image','file','voice') DEFAULT 'text',
  `attachment_url` varchar(255) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `related_crop_id` int(10) UNSIGNED DEFAULT NULL,
  `sent_by_agent` tinyint(1) DEFAULT 0,
  `agent_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `notification_type` enum('order','message','price_alert','loan','weather','payment','rating','agent','system','promotion') NOT NULL,
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `title` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `action_url` varchar(255) DEFAULT NULL,
  `related_id` int(10) UNSIGNED DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`notification_id`, `user_id`, `notification_type`, `priority`, `title`, `message`, `action_url`, `related_id`, `is_read`, `read_at`, `created_at`) VALUES
(1, 1, 'order', 'high', 'নতুন অর্ডার পেয়েছেন', 'হাসান ট্রেডার্স থেকে ৫০ কেজি ধানের অর্ডার এসেছে।', '/farmer/orders', NULL, 0, NULL, '2026-06-03 15:58:45'),
(2, 1, 'price_alert', 'medium', 'আলুর দাম বাড়ছে', 'আপনার এলাকায় আলুর দাম গত ৭ দিনে ১২% বেড়েছে।', '/liveprice', NULL, 0, NULL, '2026-06-03 15:58:45'),
(3, 2, 'loan', 'medium', 'লোন কিস্তি আসন্ন', 'আগামী ২ দিনের মধ্যে আপনার লোন কিস্তি জমা দিতে হবে।', '/farmer/loans', NULL, 0, NULL, '2026-06-03 15:58:45'),
(4, 4, 'order', 'medium', 'অর্ডার শিপিং এ', 'আপনার অর্ডার ORD-20260508 শিপিং এ আছে।', '/buyer/orders', NULL, 0, NULL, '2026-06-03 15:58:45'),
(5, 1, 'system', 'medium', 'ফসল লিস্ট মেয়াদ শেষ', 'টমেটো এর উপলব্ধতা শেষ হয়ে গেছে। আবার বিক্রির জন্য নতুন লিস্ট তৈরি করুন।', '/farmer/crops', 2, 0, NULL, '2026-06-03 16:00:03'),
(6, 1, 'loan', 'urgent', '⚠ লোন পরিশোধে দেরি — 1 দিন', 'লোন L-00001 এর কিস্তি ৳3,500 এখনো পরিশোধ হয়নি। যত দ্রুত সম্ভব পরিশোধ করুন।', '/farmer/loans/detail/1', 1, 0, NULL, '2026-06-09 00:54:06'),
(7, 1, 'order', 'high', 'নতুন অর্ডার পেয়েছেন', 'আপনি একটি নতুন অর্ডার পেয়েছেন: ORD-20260610-9DC02D', '/farmer/orders', 1, 0, NULL, '2026-06-10 07:31:03'),
(8, 1, 'order', 'high', 'নতুন অর্ডার পেয়েছেন', 'আপনি একটি নতুন অর্ডার পেয়েছেন: ORD-20260610-61B64C', '/farmer/orders', 2, 0, NULL, '2026-06-10 07:37:15'),
(9, 1, 'order', 'high', 'নতুন অর্ডার পেয়েছেন', 'আপনি একটি নতুন অর্ডার পেয়েছেন: ORD-20260610-6B5B05', '/farmer/orders', 3, 0, NULL, '2026-06-10 07:43:52'),
(10, 1, 'order', 'high', 'নতুন অর্ডার পেয়েছেন', 'আপনি একটি নতুন অর্ডার পেয়েছেন: ORD-20260610-66DE9C', '/farmer/orders', 4, 0, NULL, '2026-06-10 07:47:39'),
(11, 1, 'order', 'high', 'নতুন অর্ডার পেয়েছেন', 'আপনি একটি নতুন অর্ডার পেয়েছেন: ORD-20260610-D38033', '/farmer/orders', 5, 0, NULL, '2026-06-10 09:53:23'),
(12, 1, 'order', 'high', 'নতুন অর্ডার পেয়েছেন', 'আপনি একটি নতুন অর্ডার পেয়েছেন: ORD-20260610-87CC90', '/farmer/orders', 6, 0, NULL, '2026-06-10 09:55:51'),
(13, 1, 'order', 'high', '💰 নতুন অর্ডার পেমেন্ট', 'অর্ডার ORD-20260610-87CC90 এর পেমেন্ট সম্পন্ন (৳95)।', '/farmer/orders/detail/', 6, 0, NULL, '2026-06-10 09:55:52'),
(14, 1, 'order', 'high', 'নতুন অর্ডার পেয়েছেন', 'আপনি একটি নতুন অর্ডার পেয়েছেন: ORD-20260610-A3D098', '/farmer/orders', 7, 0, NULL, '2026-06-10 17:12:15'),
(15, 1, 'order', 'high', '💰 নতুন অর্ডার পেমেন্ট', 'অর্ডার ORD-20260610-A3D098 এর পেমেন্ট সম্পন্ন (৳95)।', '/farmer/orders/detail/', 7, 0, NULL, '2026-06-10 17:12:17'),
(16, 1, 'system', 'medium', 'ফসল লিস্ট মেয়াদ শেষ', 'টমেটো এর উপলব্ধতা শেষ হয়ে গেছে। আবার বিক্রির জন্য নতুন লিস্ট তৈরি করুন।', '/farmer/crops', 1, 0, NULL, '2026-06-10 18:00:03'),
(17, 3, 'order', 'high', 'নতুন অর্ডার পেয়েছেন', 'আপনি একটি নতুন অর্ডার পেয়েছেন: ORD-20260614-F8156A', '/farmer/orders', 8, 0, NULL, '2026-06-14 11:06:01'),
(18, 3, 'order', 'high', '💰 নতুন অর্ডার পেমেন্ট', 'অর্ডার ORD-20260614-F8156A এর পেমেন্ট সম্পন্ন (৳450)।', '/farmer/orders/detail/', 8, 0, NULL, '2026-06-14 11:06:06'),
(19, 3, 'order', 'medium', 'অর্ডার বাতিল', 'অর্ডার ORD-20260614-F8156A এর অবস্থা: বাতিল', '/farmer/orders', 8, 0, NULL, '2026-06-14 11:06:29'),
(20, 3, 'order', 'high', 'নতুন অর্ডার পেয়েছেন', 'আপনি একটি নতুন অর্ডার পেয়েছেন: ORD-20260614-0E59B6', '/farmer/orders', 9, 0, NULL, '2026-06-14 11:07:03'),
(21, 3, 'order', 'high', '💰 নতুন অর্ডার পেমেন্ট', 'অর্ডার ORD-20260614-0E59B6 এর পেমেন্ট সম্পন্ন (৳250)।', '/farmer/orders/detail/', 9, 0, NULL, '2026-06-14 11:07:05'),
(22, 2, 'order', 'high', 'নতুন অর্ডার পেয়েছেন', 'আপনি একটি নতুন অর্ডার পেয়েছেন: ORD-20260614-55425E', '/farmer/orders', 10, 0, NULL, '2026-06-14 11:33:34'),
(23, 2, 'order', 'high', '💰 নতুন অর্ডার পেমেন্ট', 'অর্ডার ORD-20260614-55425E এর পেমেন্ট সম্পন্ন (৳120)।', '/farmer/orders/detail/', 10, 0, NULL, '2026-06-14 11:33:35');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(10) UNSIGNED NOT NULL,
  `order_number` varchar(30) NOT NULL,
  `buyer_id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED NOT NULL,
  `crop_id` int(10) UNSIGNED NOT NULL,
  `quantity_ordered` decimal(10,2) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `delivery_charge` decimal(8,2) DEFAULT 0.00,
  `total_amount` decimal(12,2) NOT NULL,
  `order_status` enum('pending_payment','pending','confirmed','processing','packed','shipped','delivered','cancelled','refunded') DEFAULT 'pending',
  `payment_status` enum('pending','paid','failed','refunded') DEFAULT 'pending',
  `payment_gateway` varchar(30) DEFAULT NULL,
  `payment_id` int(10) UNSIGNED DEFAULT NULL,
  `delivery_type` enum('home_delivery','self_pickup') DEFAULT 'home_delivery',
  `delivery_address` text DEFAULT NULL,
  `delivery_district_id` int(10) UNSIGNED DEFAULT NULL,
  `preferred_delivery_date` date DEFAULT NULL,
  `special_instructions` text DEFAULT NULL,
  `cancellation_reason` varchar(255) DEFAULT NULL,
  `cancelled_by` int(10) UNSIGNED DEFAULT NULL,
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `confirmed_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `order_number`, `buyer_id`, `farmer_id`, `crop_id`, `quantity_ordered`, `unit_price`, `subtotal`, `delivery_charge`, `total_amount`, `order_status`, `payment_status`, `payment_gateway`, `payment_id`, `delivery_type`, `delivery_address`, `delivery_district_id`, `preferred_delivery_date`, `special_instructions`, `cancellation_reason`, `cancelled_by`, `order_date`, `confirmed_at`, `delivered_at`, `updated_at`) VALUES
(1, 'ORD-20260610-9DC02D', 9, 1, 3, 4.99, 42.00, 209.58, 50.00, 259.58, 'pending_payment', 'pending', 'mock', 1, 'self_pickup', 'badda', 14, '2026-06-13', '', NULL, NULL, '2026-06-10 07:31:03', NULL, NULL, '2026-06-10 07:31:03'),
(2, 'ORD-20260610-61B64C', 9, 1, 2, 1.00, 38.00, 38.00, 50.00, 88.00, 'pending_payment', 'pending', 'mock', 2, 'home_delivery', 'badda', 51, '2026-06-13', '', NULL, NULL, '2026-06-10 07:37:15', NULL, NULL, '2026-06-10 07:37:15'),
(3, 'ORD-20260610-6B5B05', 9, 1, 1, 1.00, 45.00, 45.00, 50.00, 95.00, 'pending_payment', 'pending', 'mock', 3, 'home_delivery', '', 51, '2026-06-13', '', NULL, NULL, '2026-06-10 07:43:52', NULL, NULL, '2026-06-10 07:43:52'),
(4, 'ORD-20260610-66DE9C', 9, 1, 1, 1.00, 45.00, 45.00, 50.00, 95.00, 'pending_payment', 'pending', 'mock', 4, 'home_delivery', '', 51, '2026-06-13', '', NULL, NULL, '2026-06-10 07:47:39', NULL, NULL, '2026-06-10 07:47:39'),
(5, 'ORD-20260610-D38033', 9, 1, 1, 1.00, 45.00, 45.00, 50.00, 95.00, 'pending_payment', 'pending', 'mock', 5, 'home_delivery', '', 51, '2026-06-13', '', NULL, NULL, '2026-06-10 09:53:23', NULL, NULL, '2026-06-10 09:53:23'),
(6, 'ORD-20260610-87CC90', 9, 1, 1, 1.00, 45.00, 45.00, 50.00, 95.00, 'confirmed', 'paid', 'mock', 6, 'home_delivery', '', 51, '2026-06-13', '', NULL, NULL, '2026-06-10 09:55:51', '2026-06-10 09:55:52', NULL, '2026-06-10 09:55:52'),
(7, 'ORD-20260610-A3D098', 9, 1, 1, 1.00, 45.00, 45.00, 50.00, 95.00, 'confirmed', 'paid', 'mock', 7, 'home_delivery', '', 51, '2026-06-13', '', NULL, NULL, '2026-06-10 17:12:15', '2026-06-10 17:12:17', NULL, '2026-06-10 17:12:17'),
(8, 'ORD-20260614-F8156A', 9, 3, 12, 20.00, 20.00, 400.00, 50.00, 450.00, 'cancelled', 'paid', 'mock', 8, 'self_pickup', 'BDDAA', 51, '2026-06-17', '', '', 9, '2026-06-14 11:06:01', '2026-06-14 11:06:06', NULL, '2026-06-14 11:06:29'),
(9, 'ORD-20260614-0E59B6', 9, 3, 12, 9.99, 20.00, 199.80, 50.00, 249.80, 'confirmed', 'paid', 'mock', 9, 'home_delivery', 'BDDAA', 51, '2026-06-17', '', NULL, NULL, '2026-06-14 11:07:03', '2026-06-14 11:07:05', NULL, '2026-06-14 11:07:05'),
(10, 'ORD-20260614-55425E', 9, 2, 9, 1.00, 70.00, 70.00, 50.00, 120.00, 'confirmed', 'paid', 'mock', 10, 'home_delivery', 'BDDAA', 51, '2026-06-17', '', NULL, NULL, '2026-06-14 11:33:33', '2026-06-14 11:33:35', NULL, '2026-06-14 11:33:35');

--
-- Triggers `orders`
--
DELIMITER $$
CREATE TRIGGER `tr_orders_before_insert` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
    IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
        SET @next_id = COALESCE((SELECT MAX(order_id) FROM orders), 0) + 1;
        SET NEW.order_number = CONCAT(
            'ORD-',
            DATE_FORMAT(NOW(), '%Y%m%d'),
            '-',
            LPAD(@next_id, 5, '0')
        );
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `otp_codes`
--

CREATE TABLE `otp_codes` (
  `otp_id` int(10) UNSIGNED NOT NULL,
  `phone` varchar(15) NOT NULL,
  `code_hash` varchar(255) NOT NULL,
  `purpose` enum('register','login','reset_password','verify_phone','two_factor') NOT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `attempts` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `max_attempts` tinyint(3) UNSIGNED NOT NULL DEFAULT 5,
  `verified_at` timestamp NULL DEFAULT NULL,
  `request_ip` varchar(45) DEFAULT NULL,
  `sent_via` enum('sms','log','email') NOT NULL DEFAULT 'log',
  `provider_response` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `otp_codes`
--

INSERT INTO `otp_codes` (`otp_id`, `phone`, `code_hash`, `purpose`, `expires_at`, `attempts`, `max_attempts`, `verified_at`, `request_ip`, `sent_via`, `provider_response`, `created_at`) VALUES
(1, '01323275259', '$2y$10$XfrCiFme8DMgYKJFgJdm3.GkgA5x9Ksx2zUqkwaWEXS0.wpgwdmWS', 'register', '2026-06-10 01:09:35', 1, 5, '2026-06-10 01:09:35', '::1', 'log', '{\"logged\":true}', '2026-06-10 01:09:28');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `payment_id` int(10) UNSIGNED NOT NULL,
  `payment_reference` varchar(50) NOT NULL,
  `order_id` int(10) UNSIGNED DEFAULT NULL,
  `subscription_id` int(10) UNSIGNED DEFAULT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `gateway` enum('sslcommerz','bkash','nagad','rocket','mock','cod') NOT NULL,
  `gateway_transaction_id` varchar(100) DEFAULT NULL,
  `gateway_session_key` varchar(255) DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` char(3) DEFAULT 'BDT',
  `status` enum('initiated','pending','success','failed','cancelled','refunded') NOT NULL DEFAULT 'initiated',
  `failure_reason` varchar(255) DEFAULT NULL,
  `raw_request` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`raw_request`)),
  `raw_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`raw_response`)),
  `ipn_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`ipn_payload`)),
  `initiated_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL,
  `refunded_at` timestamp NULL DEFAULT NULL,
  `refund_amount` decimal(12,2) DEFAULT 0.00,
  `refund_reason` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`payment_id`, `payment_reference`, `order_id`, `subscription_id`, `user_id`, `gateway`, `gateway_transaction_id`, `gateway_session_key`, `amount`, `currency`, `status`, `failure_reason`, `raw_request`, `raw_response`, `ipn_payload`, `initiated_at`, `completed_at`, `refunded_at`, `refund_amount`, `refund_reason`) VALUES
(1, 'PAY-20260610-9FA57A75', 1, NULL, 9, 'mock', 'MOCK-2C087F7B', 'mock_6a2912b7ebb3c', 259.58, 'BDT', 'success', NULL, '{\"order_id\":1,\"user_id\":9,\"amount\":\"259.58\",\"customer_name\":\"Redwan\",\"customer_email\":\"redwanhossain212@gmail.com\",\"customer_phone\":\"01323275259\",\"customer_address\":\"bauphal\",\"product_name\":\"AgroFin Order #ORD-20260610-9DC02D\",\"payment_reference\":\"PAY-20260610-9FA57A75\",\"payment_id\":1}', '{\"provider\":\"mock\",\"message\":\"Mock checkout page will offer pass\\/fail\\/cancel choice\"}', '{\"url\":\"payment\\/callback\",\"ref\":\"PAY-20260610-9FA57A75\",\"result\":\"success\",\"status\":\"success\"}', '2026-06-10 07:31:03', '2026-06-10 07:31:12', NULL, 0.00, NULL),
(2, 'PAY-20260610-BCBC6C72', 2, NULL, 9, 'mock', 'MOCK-42D3ED14', 'mock_6a29142b21596', 88.00, 'BDT', 'success', NULL, '{\"order_id\":2,\"user_id\":9,\"amount\":\"88.00\",\"customer_name\":\"Redwan\",\"customer_email\":\"redwanhossain212@gmail.com\",\"customer_phone\":\"01323275259\",\"customer_address\":\"bauphal\",\"product_name\":\"AgroFin Order #ORD-20260610-61B64C\",\"payment_reference\":\"PAY-20260610-BCBC6C72\",\"payment_id\":2}', '{\"provider\":\"mock\",\"message\":\"Mock checkout page will offer pass\\/fail\\/cancel choice\"}', '{\"url\":\"payment\\/callback\",\"ref\":\"PAY-20260610-BCBC6C72\",\"result\":\"success\",\"status\":\"success\"}', '2026-06-10 07:37:15', '2026-06-10 07:37:17', NULL, 0.00, NULL),
(3, 'PAY-20260610-7D32C6F4', 3, NULL, 9, 'mock', 'MOCK-5BB22537', 'mock_6a2915b8cecb6', 95.00, 'BDT', 'success', NULL, '{\"order_id\":3,\"user_id\":9,\"amount\":\"95.00\",\"customer_name\":\"Redwan\",\"customer_email\":\"redwanhossain212@gmail.com\",\"customer_phone\":\"01323275259\",\"customer_address\":\"bauphal\",\"product_name\":\"AgroFin Order #ORD-20260610-6B5B05\",\"payment_reference\":\"PAY-20260610-7D32C6F4\",\"payment_id\":3}', '{\"provider\":\"mock\",\"message\":\"Mock checkout page will offer pass\\/fail\\/cancel choice\"}', '{\"url\":\"payment\\/callback\",\"ref\":\"PAY-20260610-7D32C6F4\",\"result\":\"success\",\"status\":\"success\"}', '2026-06-10 07:43:52', '2026-06-10 07:43:55', NULL, 0.00, NULL),
(4, 'PAY-20260610-DCCE6F35', 4, NULL, 9, 'mock', 'MOCK-69D46C30', 'mock_6a29169bddf92', 95.00, 'BDT', 'success', NULL, '{\"order_id\":4,\"user_id\":9,\"amount\":\"95.00\",\"customer_name\":\"Redwan\",\"customer_email\":\"redwanhossain212@gmail.com\",\"customer_phone\":\"01323275259\",\"customer_address\":\"bauphal\",\"product_name\":\"AgroFin Order #ORD-20260610-66DE9C\",\"payment_reference\":\"PAY-20260610-DCCE6F35\",\"payment_id\":4}', '{\"provider\":\"mock\",\"message\":\"Mock checkout page will offer pass\\/fail\\/cancel choice\"}', '{\"url\":\"payment\\/callback\",\"ref\":\"PAY-20260610-DCCE6F35\",\"result\":\"success\",\"status\":\"success\"}', '2026-06-10 07:47:39', '2026-06-10 07:47:41', NULL, 0.00, NULL),
(5, 'PAY-20260610-5BAFC3A6', 5, NULL, 9, 'mock', 'MOCK-41510312', 'mock_6a29341326c2c', 95.00, 'BDT', 'success', NULL, '{\"order_id\":5,\"user_id\":9,\"amount\":\"95.00\",\"customer_name\":\"Redwan\",\"customer_email\":\"redwanhossain212@gmail.com\",\"customer_phone\":\"01323275259\",\"customer_address\":\"bauphal\",\"product_name\":\"AgroFin Order #ORD-20260610-D38033\",\"payment_reference\":\"PAY-20260610-5BAFC3A6\",\"payment_id\":5}', '{\"provider\":\"mock\",\"message\":\"Mock checkout page will offer pass\\/fail\\/cancel choice\"}', '{\"url\":\"payment\\/callback\",\"ref\":\"PAY-20260610-5BAFC3A6\",\"result\":\"success\",\"status\":\"success\"}', '2026-06-10 09:53:23', '2026-06-10 09:53:25', NULL, 0.00, NULL),
(6, 'PAY-20260610-7031D1F1', 6, NULL, 9, 'mock', 'MOCK-4A8AB994', 'mock_6a2934a768332', 95.00, 'BDT', 'success', NULL, '{\"order_id\":6,\"user_id\":9,\"amount\":\"95.00\",\"customer_name\":\"Redwan\",\"customer_email\":\"redwanhossain212@gmail.com\",\"customer_phone\":\"01323275259\",\"customer_address\":\"bauphal\",\"product_name\":\"AgroFin Order #ORD-20260610-87CC90\",\"payment_reference\":\"PAY-20260610-7031D1F1\",\"payment_id\":6}', '{\"provider\":\"mock\",\"message\":\"Mock checkout page will offer pass\\/fail\\/cancel choice\"}', '{\"url\":\"payment\\/callback\",\"ref\":\"PAY-20260610-7031D1F1\",\"result\":\"success\",\"status\":\"success\"}', '2026-06-10 09:55:51', '2026-06-10 09:55:52', NULL, 0.00, NULL),
(7, 'PAY-20260610-AECB3095', 7, NULL, 9, 'mock', 'MOCK-AF1BEE99', 'mock_6a299aef72448', 95.00, 'BDT', 'success', NULL, '{\"order_id\":7,\"user_id\":9,\"amount\":\"95.00\",\"customer_name\":\"Redwan\",\"customer_email\":\"redwanhossain212@gmail.com\",\"customer_phone\":\"01323275259\",\"customer_address\":\"bauphal\",\"product_name\":\"AgroFin Order #ORD-20260610-A3D098\",\"payment_reference\":\"PAY-20260610-AECB3095\",\"payment_id\":7}', '{\"provider\":\"mock\",\"message\":\"Mock checkout page will offer pass\\/fail\\/cancel choice\"}', '{\"url\":\"payment\\/callback\",\"ref\":\"PAY-20260610-AECB3095\",\"result\":\"success\",\"status\":\"success\"}', '2026-06-10 17:12:15', '2026-06-10 17:12:17', NULL, 0.00, NULL),
(8, 'PAY-20260614-1AA2F83A', 8, NULL, 9, 'mock', 'MOCK-B1E24B0D', 'mock_6a2e8b1a12c02', 450.00, 'BDT', 'success', NULL, '{\"order_id\":8,\"user_id\":9,\"amount\":\"450.00\",\"customer_name\":\"Redwan\",\"customer_email\":\"redwanhossain212@gmail.com\",\"customer_phone\":\"01323275259\",\"customer_address\":\"bauphal\",\"product_name\":\"AgroFin Order #ORD-20260614-F8156A\",\"payment_reference\":\"PAY-20260614-1AA2F83A\",\"payment_id\":8}', '{\"provider\":\"mock\",\"message\":\"Mock checkout page will offer pass\\/fail\\/cancel choice\"}', '{\"url\":\"payment\\/callback\",\"ref\":\"PAY-20260614-1AA2F83A\",\"result\":\"success\",\"status\":\"success\"}', '2026-06-14 11:06:02', '2026-06-14 11:06:06', NULL, 0.00, NULL),
(9, 'PAY-20260614-ED1AFA1E', 9, NULL, 9, 'mock', 'MOCK-B59BF6B4', 'mock_6a2e8b57b9d7e', 249.80, 'BDT', 'success', NULL, '{\"order_id\":9,\"user_id\":9,\"amount\":\"249.80\",\"customer_name\":\"Redwan\",\"customer_email\":\"redwanhossain212@gmail.com\",\"customer_phone\":\"01323275259\",\"customer_address\":\"bauphal\",\"product_name\":\"AgroFin Order #ORD-20260614-0E59B6\",\"payment_reference\":\"PAY-20260614-ED1AFA1E\",\"payment_id\":9}', '{\"provider\":\"mock\",\"message\":\"Mock checkout page will offer pass\\/fail\\/cancel choice\"}', '{\"url\":\"payment\\/callback\",\"ref\":\"PAY-20260614-ED1AFA1E\",\"result\":\"success\",\"status\":\"success\"}', '2026-06-14 11:07:03', '2026-06-14 11:07:05', NULL, 0.00, NULL),
(10, 'PAY-20260614-08DF9D5B', 10, NULL, 9, 'mock', 'MOCK-18F76DF0', 'mock_6a2e918e14a7f', 120.00, 'BDT', 'success', NULL, '{\"order_id\":10,\"user_id\":9,\"amount\":\"120.00\",\"customer_name\":\"Redwan\",\"customer_email\":\"redwanhossain212@gmail.com\",\"customer_phone\":\"01323275259\",\"customer_address\":\"bauphal\",\"product_name\":\"AgroFin Order #ORD-20260614-55425E\",\"payment_reference\":\"PAY-20260614-08DF9D5B\",\"payment_id\":10}', '{\"provider\":\"mock\",\"message\":\"Mock checkout page will offer pass\\/fail\\/cancel choice\"}', '{\"url\":\"payment\\/callback\",\"ref\":\"PAY-20260614-08DF9D5B\",\"result\":\"success\",\"status\":\"success\"}', '2026-06-14 11:33:34', '2026-06-14 11:33:35', NULL, 0.00, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `payment_methods`
--

CREATE TABLE `payment_methods` (
  `method_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `method_type` enum('bkash','nagad','rocket','bank_transfer','wallet') NOT NULL,
  `account_number` varchar(50) NOT NULL,
  `account_name` varchar(100) DEFAULT NULL,
  `bank_name` varchar(100) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT 0,
  `is_verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `payment_methods`
--

INSERT INTO `payment_methods` (`method_id`, `user_id`, `method_type`, `account_number`, `account_name`, `bank_name`, `is_default`, `is_verified`, `created_at`, `updated_at`) VALUES
(1, 4, 'bkash', '01612345004', 'Hasan Traders', NULL, 1, 1, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(2, 5, 'bkash', '01512345005', 'FreshMart BD', NULL, 1, 1, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(3, 4, 'bank_transfer', '1234567890', 'Hasan Traders', NULL, 0, 1, '2026-06-03 15:58:45', '2026-06-03 15:58:45');

-- --------------------------------------------------------

--
-- Table structure for table `price_history`
--

CREATE TABLE `price_history` (
  `history_id` int(10) UNSIGNED NOT NULL,
  `crop_name` varchar(100) NOT NULL,
  `district_id` int(10) UNSIGNED NOT NULL,
  `wholesale_price` decimal(10,2) NOT NULL,
  `retail_price` decimal(10,2) NOT NULL,
  `unit` enum('kg','ton','mon','piece') DEFAULT 'kg',
  `price_date` date NOT NULL,
  `archived_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `price_predictions`
--

CREATE TABLE `price_predictions` (
  `prediction_id` int(10) UNSIGNED NOT NULL,
  `crop_name` varchar(100) NOT NULL,
  `district_id` int(10) UNSIGNED NOT NULL,
  `current_price` decimal(10,2) NOT NULL,
  `predicted_price_7d` decimal(10,2) NOT NULL,
  `predicted_price_15d` decimal(10,2) NOT NULL,
  `predicted_price_30d` decimal(10,2) NOT NULL,
  `prediction_confidence` decimal(5,2) NOT NULL,
  `trend_direction` enum('rising','falling','stable') NOT NULL,
  `recommendation` enum('sell_now','wait','moderate') NOT NULL,
  `recommendation_reason` text DEFAULT NULL,
  `prediction_date` date NOT NULL,
  `model_version` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `price_predictions`
--

INSERT INTO `price_predictions` (`prediction_id`, `crop_name`, `district_id`, `current_price`, `predicted_price_7d`, `predicted_price_15d`, `predicted_price_30d`, `prediction_confidence`, `trend_direction`, `recommendation`, `recommendation_reason`, `prediction_date`, `model_version`, `created_at`) VALUES
(1, 'বোরো ধান', 14, 45.00, 47.00, 48.00, 46.00, 78.00, 'rising', 'wait', 'আগামী ১৫ দিনে দাম ৭% বাড়ার সম্ভাবনা। অপেক্ষা করুন।', '2026-06-03', NULL, '2026-06-03 15:58:45'),
(2, 'টমেটো', 14, 55.00, 52.00, 50.00, 48.00, 82.00, 'falling', 'sell_now', 'মৌসুমী সরবরাহ বাড়ছে। এখনই বিক্রি করা ভালো।', '2026-06-03', NULL, '2026-06-03 15:58:45'),
(3, 'আলু', 14, 42.00, 43.00, 45.00, 48.00, 75.00, 'rising', 'moderate', 'ধীরে ধীরে দাম বাড়ছে। ৩০% এখন, ৭০% পরে বিক্রি করুন।', '2026-06-03', NULL, '2026-06-03 15:58:45');

-- --------------------------------------------------------

--
-- Table structure for table `search_logs`
--

CREATE TABLE `search_logs` (
  `search_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `search_query` varchar(255) NOT NULL,
  `search_type` enum('text','voice','filter') DEFAULT 'text',
  `filters_applied` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`filters_applied`)),
  `results_count` int(10) UNSIGNED DEFAULT 0,
  `clicked_crop_id` int(10) UNSIGNED DEFAULT NULL,
  `search_timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `search_logs`
--

INSERT INTO `search_logs` (`search_id`, `user_id`, `search_query`, `search_type`, `filters_applied`, `results_count`, `clicked_crop_id`, `search_timestamp`) VALUES
(1, 4, '(filter only)', 'text', '{\"q\":\"\",\"category_id\":\"2\",\"district_id\":\"1\",\"min_price\":\"\",\"max_price\":\"\",\"quality\":\"A\",\"organic\":null,\"sort\":\"newest\"}', 0, NULL, '2026-06-10 01:29:54');

-- --------------------------------------------------------

--
-- Table structure for table `subscriptions`
--

CREATE TABLE `subscriptions` (
  `subscription_id` int(10) UNSIGNED NOT NULL,
  `buyer_id` int(10) UNSIGNED NOT NULL,
  `farmer_id` int(10) UNSIGNED NOT NULL,
  `crop_name` varchar(100) NOT NULL,
  `quantity_per_delivery` decimal(10,2) NOT NULL,
  `unit` enum('kg','ton','mon','piece') NOT NULL,
  `price_locked` decimal(10,2) NOT NULL,
  `frequency` enum('daily','weekly','biweekly','monthly') NOT NULL,
  `next_delivery_date` date NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `auto_payment` tinyint(1) DEFAULT 1,
  `payment_method_id` int(10) UNSIGNED DEFAULT NULL,
  `status` enum('active','paused','cancelled','expired') DEFAULT 'active',
  `total_orders_generated` int(10) UNSIGNED DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_settings`
--

CREATE TABLE `system_settings` (
  `setting_id` int(10) UNSIGNED NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `setting_type` enum('string','number','boolean','json') DEFAULT 'string',
  `setting_category` varchar(50) NOT NULL,
  `setting_description` varchar(255) DEFAULT NULL,
  `is_editable` tinyint(1) DEFAULT 1,
  `updated_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `system_settings`
--

INSERT INTO `system_settings` (`setting_id`, `setting_key`, `setting_value`, `setting_type`, `setting_category`, `setting_description`, `is_editable`, `updated_by`, `created_at`, `updated_at`) VALUES
(1, 'platform_name', 'AgroFin', 'string', 'general', 'Platform name', 1, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(2, 'platform_name_bn', 'এগ্রোফিন', 'string', 'general', 'Platform name (Bangla)', 1, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(3, 'default_commission_rate', '2.00', 'number', 'financial', 'Default agent commission rate %', 1, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(4, 'default_interest_rate', '8.00', 'number', 'financial', 'Default loan interest rate %', 1, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(5, 'max_loan_amount', '50000', 'number', 'financial', 'Maximum loan amount (BDT)', 1, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(6, 'min_credit_score', '60', 'number', 'financial', 'Minimum credit score for loan eligibility', 1, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(7, 'support_email', 'support@agrofin.com.bd', 'string', 'general', 'Support email address', 1, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(8, 'support_phone', '+8809678111222', 'string', 'general', 'Support phone', 1, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45');

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `transaction_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `transaction_type` enum('sale','purchase','loan_disbursement','loan_repayment','commission','refund','withdrawal','deposit') NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` char(3) DEFAULT 'BDT',
  `transaction_status` enum('pending','completed','failed','cancelled') DEFAULT 'pending',
  `payment_method_id` int(10) UNSIGNED DEFAULT NULL,
  `related_order_id` int(10) UNSIGNED DEFAULT NULL,
  `related_loan_id` int(10) UNSIGNED DEFAULT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `balance_before` decimal(12,2) DEFAULT NULL,
  `balance_after` decimal(12,2) DEFAULT NULL,
  `is_flagged` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`transaction_id`, `user_id`, `transaction_type`, `amount`, `currency`, `transaction_status`, `payment_method_id`, `related_order_id`, `related_loan_id`, `reference_number`, `description`, `balance_before`, `balance_after`, `is_flagged`, `created_at`, `completed_at`) VALUES
(6, 9, 'purchase', 95.00, 'BDT', 'completed', NULL, 6, NULL, 'TXN-20260610-4CCB0A-B', 'অর্ডার পেমেন্ট via mock', NULL, NULL, 0, '2026-06-10 09:55:52', '2026-06-10 09:55:52'),
(7, 1, 'sale', 95.00, 'BDT', 'completed', NULL, 6, NULL, 'TXN-20260610-4CCB0A-S', 'বিক্রয় আয় (অর্ডার ORD-20260610-87CC90)', NULL, NULL, 0, '2026-06-10 09:55:52', '2026-06-10 09:55:52'),
(8, 9, 'purchase', 95.00, 'BDT', 'completed', NULL, 7, NULL, 'TXN-20260610-18F772-B', 'অর্ডার পেমেন্ট via mock', NULL, NULL, 0, '2026-06-10 17:12:17', '2026-06-10 17:12:17'),
(9, 1, 'sale', 95.00, 'BDT', 'completed', NULL, 7, NULL, 'TXN-20260610-18F772-S', 'বিক্রয় আয় (অর্ডার ORD-20260610-A3D098)', NULL, NULL, 0, '2026-06-10 17:12:17', '2026-06-10 17:12:17'),
(10, 9, 'purchase', 450.00, 'BDT', 'completed', NULL, 8, NULL, 'TXN-20260614-CBFEB1-B', 'অর্ডার পেমেন্ট via mock', NULL, NULL, 0, '2026-06-14 11:06:06', '2026-06-14 11:06:06'),
(11, 3, 'sale', 450.00, 'BDT', 'completed', NULL, 8, NULL, 'TXN-20260614-CBFEB1-S', 'বিক্রয় আয় (অর্ডার ORD-20260614-F8156A)', NULL, NULL, 0, '2026-06-14 11:06:06', '2026-06-14 11:06:06'),
(12, 9, 'purchase', 249.80, 'BDT', 'completed', NULL, 9, NULL, 'TXN-20260614-BC1BCB-B', 'অর্ডার পেমেন্ট via mock', NULL, NULL, 0, '2026-06-14 11:07:05', '2026-06-14 11:07:05'),
(13, 3, 'sale', 249.80, 'BDT', 'completed', NULL, 9, NULL, 'TXN-20260614-BC1BCB-S', 'বিক্রয় আয় (অর্ডার ORD-20260614-0E59B6)', NULL, NULL, 0, '2026-06-14 11:07:05', '2026-06-14 11:07:05'),
(14, 9, 'purchase', 120.00, 'BDT', 'completed', NULL, 10, NULL, 'TXN-20260614-31AC01-B', 'অর্ডার পেমেন্ট via mock', NULL, NULL, 0, '2026-06-14 11:33:35', '2026-06-14 11:33:35'),
(15, 2, 'sale', 120.00, 'BDT', 'completed', NULL, 10, NULL, 'TXN-20260614-31AC01-S', 'বিক্রয় আয় (অর্ডার ORD-20260614-55425E)', NULL, NULL, 0, '2026-06-14 11:33:35', '2026-06-14 11:33:35');

--
-- Triggers `transactions`
--
DELIMITER $$
CREATE TRIGGER `tr_transactions_after_insert` AFTER INSERT ON `transactions` FOR EACH ROW BEGIN
    DECLARE current_balance DECIMAL(12,2) DEFAULT 0;
    DECLARE new_balance DECIMAL(12,2) DEFAULT 0;
    DECLARE is_wallet_payment INT DEFAULT 0;

    IF NEW.transaction_status = 'completed' THEN

        SELECT COALESCE(wallet_balance,0)
        INTO current_balance
        FROM users
        WHERE user_id = NEW.user_id;

        IF NEW.payment_method_id IS NOT NULL THEN
            SELECT COUNT(*)
            INTO is_wallet_payment
            FROM payment_methods
            WHERE method_id = NEW.payment_method_id
              AND method_type = 'wallet';
        END IF;

        IF NEW.transaction_type IN ('sale','deposit','loan_disbursement','refund') THEN
            SET new_balance = current_balance + NEW.amount;

        ELSEIF NEW.transaction_type IN ('purchase','withdrawal','loan_repayment','commission') THEN
            IF is_wallet_payment > 0 THEN
                SET new_balance = current_balance - NEW.amount;
            ELSE
                SET new_balance = current_balance;
            END IF;

        ELSE
            SET new_balance = current_balance;
        END IF;

        IF new_balance < 0 THEN
            SET new_balance = 0;
        END IF;

        UPDATE users
        SET wallet_balance = new_balance
        WHERE user_id = NEW.user_id;

    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `transport_partners`
--

CREATE TABLE `transport_partners` (
  `partner_id` int(10) UNSIGNED NOT NULL,
  `partner_name` varchar(100) NOT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `contact_phone` varchar(15) NOT NULL,
  `contact_email` varchar(100) DEFAULT NULL,
  `service_districts` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`service_districts`)),
  `vehicle_types` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`vehicle_types`)),
  `base_rate_per_km` decimal(6,2) NOT NULL,
  `min_charge` decimal(8,2) NOT NULL,
  `rating` decimal(3,2) DEFAULT 0.00,
  `total_deliveries` int(10) UNSIGNED DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `transport_partners`
--

INSERT INTO `transport_partners` (`partner_id`, `partner_name`, `contact_person`, `contact_phone`, `contact_email`, `service_districts`, `vehicle_types`, `base_rate_per_km`, `min_charge`, `rating`, `total_deliveries`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Bangla Logistics', 'আবু সাঈদ', '01711000001', 'info@banglalog.com', '[14, 40, 12, 22, 46]', '[\"pickup\", \"truck\", \"van\"]', 18.50, 300.00, 4.60, 1240, 1, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(2, 'SpeedyAgri Transport', 'মামুন', '01711000002', 'op@speedyagri.bd', '[14, 55, 30, 33]', '[\"truck\", \"van\"]', 22.00, 500.00, 4.40, 860, 1, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(3, 'GreenWheels Bangladesh', 'রিয়াদ', '01711000003', 'hello@greenwheels.bd', '[14, 40, 12, 8, 21]', '[\"motorcycle\", \"pickup\"]', 15.00, 200.00, 4.80, 520, 1, '2026-06-03 15:58:45', '2026-06-03 15:58:45');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(10) UNSIGNED NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `nid_number` varchar(17) DEFAULT NULL,
  `district_id` int(10) UNSIGNED NOT NULL,
  `address` text DEFAULT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `account_status` enum('active','inactive','suspended','banned') DEFAULT 'active',
  `phone_verified` tinyint(1) DEFAULT 0,
  `otp_verified_at` timestamp NULL DEFAULT NULL,
  `email_verified` tinyint(1) DEFAULT 0,
  `nid_verified` tinyint(1) DEFAULT 0,
  `wallet_balance` decimal(12,2) DEFAULT 0.00,
  `preferred_language` enum('bn','en') DEFAULT 'bn',
  `last_login` timestamp NULL DEFAULT NULL,
  `last_seen_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `full_name`, `phone`, `email`, `password_hash`, `nid_number`, `district_id`, `address`, `profile_picture`, `account_status`, `phone_verified`, `otp_verified_at`, `email_verified`, `nid_verified`, `wallet_balance`, `preferred_language`, `last_login`, `last_seen_at`, `created_at`, `updated_at`) VALUES
(1, 'করিম মিয়া', '01712345001', 'karim@example.com', '$2b$10$rxWGrS69U.ur2RUKypas0.yUbuKds3RNhZWFX6RQWN19oHyrXD1wO', '1234567890123', 40, 'ময়মনসিংহ সদর, ময়মনসিংহ', NULL, 'active', 1, NULL, 0, 1, 12690.00, 'bn', '2026-06-14 11:08:50', '2026-06-14 11:18:22', '2026-06-03 15:58:45', '2026-06-14 11:18:22'),
(2, 'ফাতেমা বেগম', '01812345002', 'fatema@example.com', '$2b$10$tBixwyeRU7jU4OPTWtay7uD2eyLisWxoJOvoR7T2VdYyMzN5g2yKe', '1234567890124', 12, 'লাকসাম, কুমিল্লা', NULL, 'active', 1, NULL, 0, 1, 3320.00, 'bn', '2026-06-14 10:43:07', '2026-06-14 10:53:26', '2026-06-03 15:58:45', '2026-06-14 11:33:35'),
(3, 'আব্দুল হালিম', '01912345003', 'halim@example.com', '$2b$10$dLvOTNg8.rEoh64QNcMN5eOy8LxIrsepk1HiyQPHErcFcO87FtcBa', '1234567890125', 55, 'রংপুর সদর', NULL, 'active', 1, NULL, 0, 0, 699.80, 'bn', '2026-06-14 10:57:00', '2026-06-14 11:03:03', '2026-06-03 15:58:45', '2026-06-14 11:07:05'),
(4, 'হাসান ট্রেডার্স', '01612345004', 'hasan@traders.com', '$2b$10$7j7Kr8Du/EtgP3AoNo6Jg.mGu6LiWnJ9IiZs0vsZfHYHtcGfY1K02', NULL, 14, 'মতিঝিল, ঢাকা', NULL, 'active', 1, NULL, 0, 0, 0.00, 'bn', '2026-06-10 01:27:13', '2026-06-10 01:27:13', '2026-06-03 15:58:45', '2026-06-10 01:27:13'),
(5, 'FreshMart BD', '01512345005', 'order@freshmart.bd', '$2b$10$hpRZb3l/CtqrYaiwL/Pp9uQmFV7AKoYtJ.lvGbS.E4w52XupmER5i', NULL, 14, 'গুলশান, ঢাকা', NULL, 'active', 1, NULL, 0, 0, 0.00, 'bn', NULL, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(6, 'রফিকুল ইসলাম', '01312345006', 'rafiq@agent.com', '$2b$10$uPhYbEgi.PDVQb/pcCStU.CAVijku/WzIpGK8CXYvufHAW2oD77Se', '2234567890123', 40, 'ময়মনসিংহ সদর', NULL, 'active', 1, NULL, 0, 1, 0.00, 'bn', '2026-06-10 17:40:25', '2026-06-10 17:40:25', '2026-06-03 15:58:45', '2026-06-10 17:40:25'),
(7, 'সালমা খাতুন', '01412345007', 'salma@agent.com', '$2b$10$.qmv5xvw5EMWFNqtCxtBj.j9j2PKtWUH4K5kayrAdC7vGLYdkSRUG', '2234567890124', 12, 'কুমিল্লা সদর', NULL, 'active', 1, NULL, 0, 1, 0.00, 'bn', NULL, NULL, '2026-06-03 15:58:45', '2026-06-03 15:58:45'),
(8, 'সুলতানা আহমেদ', '01212345008', 'admin@agrofin.com', '$2b$10$xliWtJMNrWjPz3qO3NkLJeMsieo1ElpFKJCBYP4LnvWrQiMsyFQwC', NULL, 14, 'AgroFin সদর দপ্তর, ঢাকা', NULL, 'active', 1, NULL, 0, 0, 0.00, 'bn', '2026-06-14 10:39:38', '2026-06-14 10:39:39', '2026-06-03 15:58:45', '2026-06-14 10:39:39'),
(9, 'Redwan', '01323275259', 'redwanhossain212@gmail.com', '$2y$10$VJ8lbUjMUy8rQ2kLFbiILe7oEU.L5egIzXzSbyqCFtYUrf0StGzzy', NULL, 51, 'bauphal', NULL, 'active', 1, '2026-06-10 01:09:35', 0, 0, 0.00, 'bn', '2026-06-14 11:31:05', '2026-06-14 12:20:15', '2026-06-10 01:09:35', '2026-06-14 12:20:15');

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

CREATE TABLE `user_roles` (
  `user_id` int(10) UNSIGNED NOT NULL,
  `role` enum('farmer','buyer','agent','admin') NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`user_id`, `role`, `assigned_at`) VALUES
(1, 'farmer', '2026-06-03 15:58:45'),
(2, 'farmer', '2026-06-03 15:58:45'),
(3, 'farmer', '2026-06-03 15:58:45'),
(4, 'buyer', '2026-06-03 15:58:45'),
(5, 'buyer', '2026-06-03 15:58:45'),
(6, 'agent', '2026-06-03 15:58:45'),
(7, 'agent', '2026-06-03 15:58:45'),
(8, 'admin', '2026-06-03 15:58:45'),
(9, 'farmer', '2026-06-10 01:09:35'),
(9, 'buyer', '2026-06-10 01:09:35');

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_active_crops_with_details`
-- (See below for the actual view)
--
CREATE TABLE `vw_active_crops_with_details` (
`crop_id` int(10) unsigned
,`farmer_id` int(10) unsigned
,`category_id` int(10) unsigned
,`crop_name` varchar(100)
,`crop_variety` varchar(100)
,`quantity` decimal(10,2)
,`unit` enum('kg','ton','mon','piece')
,`price_per_unit` decimal(10,2)
,`quality_grade` enum('A','B','C')
,`is_organic` tinyint(1)
,`harvest_date` date
,`available_from` date
,`available_until` date
,`description` text
,`images` longtext
,`status` enum('available','sold','expired','removed')
,`views_count` int(10) unsigned
,`listed_by_agent` tinyint(1)
,`agent_id` int(10) unsigned
,`created_at` timestamp
,`updated_at` timestamp
,`farmer_name` varchar(100)
,`farmer_phone` varchar(15)
,`farmer_picture` varchar(255)
,`district_name` varchar(50)
,`division` enum('Dhaka','Chittagong','Rajshahi','Khulna','Barishal','Sylhet','Rangpur','Mymensingh')
,`category_name_bn` varchar(50)
,`category_name` varchar(50)
,`farmer_avg_rating` decimal(6,5)
,`farmer_rating_count` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_farmer_performance`
-- (See below for the actual view)
--
CREATE TABLE `vw_farmer_performance` (
`farmer_id` int(10) unsigned
,`farmer_name` varchar(100)
,`district_name` varchar(50)
,`total_crops_listed` bigint(21)
,`total_orders` bigint(21)
,`total_revenue` decimal(34,2)
,`avg_rating` decimal(6,5)
);

-- --------------------------------------------------------

--
-- Table structure for table `weather_alerts`
--

CREATE TABLE `weather_alerts` (
  `alert_id` int(10) UNSIGNED NOT NULL,
  `alert_type` enum('flood','cyclone','drought','heavy_rain','heatwave','cold_wave','storm') NOT NULL,
  `severity` enum('low','medium','high','severe') NOT NULL,
  `affected_districts` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`affected_districts`)),
  `alert_title` varchar(200) NOT NULL,
  `alert_message` text NOT NULL,
  `recommendations` text DEFAULT NULL,
  `affected_crops` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`affected_crops`)),
  `start_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `end_time` timestamp NULL DEFAULT NULL,
  `issued_by` varchar(100) DEFAULT 'BMD',
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `weather_alerts`
--

INSERT INTO `weather_alerts` (`alert_id`, `alert_type`, `severity`, `affected_districts`, `alert_title`, `alert_message`, `recommendations`, `affected_crops`, `start_time`, `end_time`, `issued_by`, `created_by`, `is_active`, `created_at`) VALUES
(1, 'heavy_rain', 'medium', '[40, 46, 22]', 'ময়মনসিংহ অঞ্চলে ভারী বৃষ্টিপাত', 'আগামী ৭২ ঘণ্টায় ময়মনসিংহ ও আশেপাশের জেলায় ভারী বৃষ্টিপাতের সম্ভাবনা রয়েছে।', 'কাটা ফসল ঢেকে রাখুন। জলাবদ্ধতা এড়াতে নিকাশ ব্যবস্থা ঠিক রাখুন।', '[\"ধান\", \"টমেটো\"]', '2026-06-09 00:54:07', '2026-06-06 15:58:45', 'BMD', NULL, 0, '2026-06-03 15:58:45'),
(2, 'flood', 'high', '[8, 30, 33]', 'উত্তরাঞ্চলে বন্যার পূর্বাভাস', 'কুড়িগ্রাম, লালমনিরহাট ও চাঁদপুরে আগামী সপ্তাহে নদীর পানি বৃদ্ধির সম্ভাবনা।', 'নিচু এলাকার ফসল দ্রুত কাটার পরামর্শ। গবাদিপশু উঁচু স্থানে সরান।', '[\"ধান\", \"সবজি\"]', '2026-06-10 18:00:03', '2026-06-10 15:58:45', 'BMD', NULL, 0, '2026-06-03 15:58:45'),
(3, 'heatwave', 'high', '[1]', 'তাপদাহের পূর্বাভাস', 'Bagerhat জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 40.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:04'),
(4, 'heavy_rain', 'medium', '[2]', 'ভারী বর্ষণের পূর্বাভাস', 'Bandarban জেলায় 2026-06-07 তারিখে আনুমানিক 71.1মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:05'),
(5, 'heatwave', 'medium', '[4]', 'তাপদাহের পূর্বাভাস', 'Barishal জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 38.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:06'),
(6, 'heavy_rain', 'severe', '[8]', 'ভারী বর্ষণের পূর্বাভাস', 'Chandpur জেলায় 2026-06-07 তারিখে আনুমানিক 121.9মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:08'),
(7, 'heatwave', 'high', '[11]', 'তাপদাহের পূর্বাভাস', 'Chuadanga জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 41.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:08'),
(8, 'heavy_rain', 'severe', '[12]', 'ভারী বর্ষণের পূর্বাভাস', 'Comilla জেলায় 2026-06-07 তারিখে আনুমানিক 121.5মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:09'),
(9, 'heavy_rain', 'severe', '[14]', 'ভারী বর্ষণের পূর্বাভাস', 'Dhaka জেলায় 2026-06-07 তারিখে আনুমানিক 126.8মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:10'),
(10, 'heatwave', 'high', '[15]', 'তাপদাহের পূর্বাভাস', 'Dinajpur জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 41.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:11'),
(11, 'heatwave', 'medium', '[16]', 'তাপদাহের পূর্বাভাস', 'Faridpur জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:11'),
(12, 'heavy_rain', 'high', '[17]', 'ভারী বর্ষণের পূর্বাভাস', 'Feni জেলায় 2026-06-07 তারিখে আনুমানিক 94.3মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:12'),
(13, 'heavy_rain', 'medium', '[19]', 'ভারী বর্ষণের পূর্বাভাস', 'Gazipur জেলায় 2026-06-04 তারিখে আনুমানিক 72.4মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:13'),
(14, 'heatwave', 'medium', '[20]', 'তাপদাহের পূর্বাভাস', 'Gopalganj জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 39.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:13'),
(15, 'heavy_rain', 'severe', '[21]', 'ভারী বর্ষণের পূর্বাভাস', 'Habiganj জেলায় 2026-06-06 তারিখে আনুমানিক 104.1মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:14'),
(16, 'heatwave', 'high', '[25]', 'তাপদাহের পূর্বাভাস', 'Jhenaidah জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 40.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:15'),
(17, 'heatwave', 'medium', '[26]', 'তাপদাহের পূর্বাভাস', 'Joypurhat জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 39.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:15'),
(18, 'heavy_rain', 'severe', '[27]', 'ভারী বর্ষণের পূর্বাভাস', 'Khagrachhari জেলায় 2026-06-07 তারিখে আনুমানিক 100.7মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:15'),
(19, 'heatwave', 'high', '[28]', 'তাপদাহের পূর্বাভাস', 'Khulna জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 40.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:16'),
(20, 'heavy_rain', 'medium', '[29]', 'ভারী বর্ষণের পূর্বাভাস', 'Kishoreganj জেলায় 2026-06-04 তারিখে আনুমানিক 52.7মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:16'),
(21, 'heavy_rain', 'medium', '[30]', 'ভারী বর্ষণের পূর্বাভাস', 'Kurigram জেলায় 2026-06-04 তারিখে আনুমানিক 51.0মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:17'),
(22, 'heatwave', 'high', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 41.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:17'),
(23, 'heatwave', 'medium', '[34]', 'তাপদাহের পূর্বাভাস', 'Madaripur জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:18'),
(24, 'heatwave', 'high', '[35]', 'তাপদাহের পূর্বাভাস', 'Magura জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 40.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:19'),
(25, 'heavy_rain', 'medium', '[36]', 'ভারী বর্ষণের পূর্বাভাস', 'Manikganj জেলায় 2026-06-04 তারিখে আনুমানিক 60.8মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:19'),
(26, 'heatwave', 'high', '[37]', 'তাপদাহের পূর্বাভাস', 'Meherpur জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 40.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:19'),
(27, 'heavy_rain', 'severe', '[38]', 'ভারী বর্ষণের পূর্বাভাস', 'Moulvibazar জেলায় 2026-06-06 তারিখে আনুমানিক 107.8মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:20'),
(28, 'heavy_rain', 'severe', '[39]', 'ভারী বর্ষণের পূর্বাভাস', 'Munshiganj জেলায় 2026-06-07 তারিখে আনুমানিক 140.2মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:20'),
(29, 'heatwave', 'medium', '[41]', 'তাপদাহের পূর্বাভাস', 'Naogaon জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 39.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:21'),
(30, 'heatwave', 'medium', '[42]', 'তাপদাহের পূর্বাভাস', 'Narail জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 39.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:21'),
(31, 'heavy_rain', 'severe', '[43]', 'ভারী বর্ষণের পূর্বাভাস', 'Narayanganj জেলায় 2026-06-07 তারিখে আনুমানিক 158.6মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:22'),
(32, 'heavy_rain', 'severe', '[44]', 'ভারী বর্ষণের পূর্বাভাস', 'Narsingdi জেলায় 2026-06-07 তারিখে আনুমানিক 140.2মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:22'),
(33, 'heatwave', 'high', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 40.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:22'),
(34, 'heavy_rain', 'medium', '[46]', 'ভারী বর্ষণের পূর্বাভাস', 'Netrokona জেলায় 2026-06-06 তারিখে আনুমানিক 54.7মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:23'),
(35, 'heatwave', 'medium', '[47]', 'তাপদাহের পূর্বাভাস', 'Nilphamari জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 39.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:23'),
(36, 'heavy_rain', 'high', '[48]', 'ভারী বর্ষণের পূর্বাভাস', 'Noakhali জেলায় 2026-06-07 তারিখে আনুমানিক 84.3মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:23'),
(37, 'heatwave', 'medium', '[49]', 'তাপদাহের পূর্বাভাস', 'Pabna জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 39.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:24'),
(38, 'heatwave', 'medium', '[52]', 'তাপদাহের পূর্বাভাস', 'Pirojpur জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:25'),
(39, 'heatwave', 'medium', '[53]', 'তাপদাহের পূর্বাভাস', 'Rajbari জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 39.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:25'),
(40, 'heatwave', 'high', '[54]', 'তাপদাহের পূর্বাভাস', 'Rajshahi জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 40.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:26'),
(41, 'heavy_rain', 'high', '[55]', 'ভারী বর্ষণের পূর্বাভাস', 'Rangamati জেলায় 2026-06-07 তারিখে আনুমানিক 93.2মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:26'),
(42, 'heatwave', 'high', '[57]', 'তাপদাহের পূর্বাভাস', 'Satkhira জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 40.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:29'),
(43, 'heavy_rain', 'high', '[58]', 'ভারী বর্ষণের পূর্বাভাস', 'Shariatpur জেলায় 2026-06-07 তারিখে আনুমানিক 96.3মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:29'),
(44, 'heavy_rain', 'high', '[61]', 'ভারী বর্ষণের পূর্বাভাস', 'Sunamganj জেলায় 2026-06-06 তারিখে আনুমানিক 78.2মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:30'),
(45, 'heavy_rain', 'severe', '[62]', 'ভারী বর্ষণের পূর্বাভাস', 'Sylhet জেলায় 2026-06-06 তারিখে আনুমানিক 126.3মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:31'),
(46, 'heavy_rain', 'medium', '[63]', 'ভারী বর্ষণের পূর্বাভাস', 'Tangail জেলায় 2026-06-04 তারিখে আনুমানিক 66.2মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:00:31'),
(47, 'heatwave', 'medium', '[1]', 'তাপদাহের পূর্বাভাস', 'Bagerhat জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 39.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:00'),
(48, 'heatwave', 'severe', '[11]', 'তাপদাহের পূর্বাভাস', 'Chuadanga জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 42.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:02'),
(49, 'heatwave', 'medium', '[16]', 'তাপদাহের পূর্বাভাস', 'Faridpur জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 38.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:04'),
(50, 'heatwave', 'high', '[20]', 'তাপদাহের পূর্বাভাস', 'Gopalganj জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 40.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:05'),
(51, 'heatwave', 'high', '[25]', 'তাপদাহের পূর্বাভাস', 'Jhenaidah জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 41.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:07'),
(52, 'heatwave', 'medium', '[28]', 'তাপদাহের পূর্বাভাস', 'Khulna জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 39.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:08'),
(53, 'heatwave', 'high', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 41.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:09'),
(54, 'heatwave', 'medium', '[34]', 'তাপদাহের পূর্বাভাস', 'Madaripur জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 38.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:10'),
(55, 'heatwave', 'high', '[35]', 'তাপদাহের পূর্বাভাস', 'Magura জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 41.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:10'),
(56, 'heatwave', 'medium', '[36]', 'তাপদাহের পূর্বাভাস', 'Manikganj জেলায় 2026-06-04 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-04 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:11'),
(57, 'heatwave', 'severe', '[37]', 'তাপদাহের পূর্বাভাস', 'Meherpur জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 42.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:11'),
(58, 'heatwave', 'high', '[41]', 'তাপদাহের পূর্বাভাস', 'Naogaon জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 41.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:12'),
(59, 'heatwave', 'high', '[42]', 'তাপদাহের পূর্বাভাস', 'Narail জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 41.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:13'),
(60, 'heatwave', 'high', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 41.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:14'),
(61, 'heatwave', 'high', '[49]', 'তাপদাহের পূর্বাভাস', 'Pabna জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 41.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:16'),
(62, 'heatwave', 'medium', '[52]', 'তাপদাহের পূর্বাভাস', 'Pirojpur জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 38.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:17'),
(63, 'heatwave', 'high', '[53]', 'তাপদাহের পূর্বাভাস', 'Rajbari জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 40.9°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:17'),
(64, 'heatwave', 'high', '[54]', 'তাপদাহের পূর্বাভাস', 'Rajshahi জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 41.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:18'),
(65, 'heatwave', 'medium', '[57]', 'তাপদাহের পূর্বাভাস', 'Satkhira জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 40.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:03:19'),
(66, 'heatwave', 'high', '[1]', 'তাপদাহের পূর্বাভাস', 'Bagerhat জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 40.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:42'),
(67, 'heatwave', 'high', '[1]', 'তাপদাহের পূর্বাভাস', 'Bagerhat জেলায় 2026-06-07 তারিখে সর্বোচ্চ তাপমাত্রা 40.9°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:42'),
(68, 'heatwave', 'high', '[11]', 'তাপদাহের পূর্বাভাস', 'Chuadanga জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 42.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:45'),
(69, 'heavy_rain', 'high', '[16]', 'ভারী বর্ষণের পূর্বাভাস', 'Faridpur জেলায় 2026-06-07 তারিখে আনুমানিক 76.7মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:46'),
(70, 'heatwave', 'medium', '[20]', 'তাপদাহের পূর্বাভাস', 'Gopalganj জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 39.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:48'),
(71, 'heavy_rain', 'high', '[20]', 'ভারী বর্ষণের পূর্বাভাস', 'Gopalganj জেলায় 2026-06-07 তারিখে আনুমানিক 96.9মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:48'),
(72, 'heatwave', 'high', '[25]', 'তাপদাহের পূর্বাভাস', 'Jhenaidah জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 41.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:50'),
(73, 'heatwave', 'high', '[25]', 'তাপদাহের পূর্বাভাস', 'Jhenaidah জেলায় 2026-06-07 তারিখে সর্বোচ্চ তাপমাত্রা 41.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:50'),
(74, 'heatwave', 'medium', '[28]', 'তাপদাহের পূর্বাভাস', 'Khulna জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 40.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:51'),
(75, 'heatwave', 'high', '[28]', 'তাপদাহের পূর্বাভাস', 'Khulna জেলায় 2026-06-07 তারিখে সর্বোচ্চ তাপমাত্রা 40.9°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:51'),
(76, 'heatwave', 'severe', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 42.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:52'),
(77, 'heavy_rain', 'high', '[34]', 'ভারী বর্ষণের পূর্বাভাস', 'Madaripur জেলায় 2026-06-07 তারিখে আনুমানিক 85.5মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:53'),
(78, 'heatwave', 'severe', '[35]', 'তাপদাহের পূর্বাভাস', 'Magura জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 42.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:53'),
(79, 'heatwave', 'medium', '[35]', 'তাপদাহের পূর্বাভাস', 'Magura জেলায় 2026-06-07 তারিখে সর্বোচ্চ তাপমাত্রা 39.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:53'),
(80, 'heatwave', 'medium', '[36]', 'তাপদাহের পূর্বাভাস', 'Manikganj জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 38.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:53'),
(81, 'heatwave', 'medium', '[36]', 'তাপদাহের পূর্বাভাস', 'Manikganj জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 38.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:53'),
(82, 'heatwave', 'high', '[37]', 'তাপদাহের পূর্বাভাস', 'Meherpur জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 41.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:54'),
(83, 'heatwave', 'high', '[41]', 'তাপদাহের পূর্বাভাস', 'Naogaon জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 40.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:55'),
(84, 'heatwave', 'medium', '[41]', 'তাপদাহের পূর্বাভাস', 'Naogaon জেলায় 2026-06-07 তারিখে সর্বোচ্চ তাপমাত্রা 38.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:55'),
(85, 'heatwave', 'high', '[42]', 'তাপদাহের পূর্বাভাস', 'Narail জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 41.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:56'),
(86, 'heavy_rain', 'high', '[42]', 'ভারী বর্ষণের পূর্বাভাস', 'Narail জেলায় 2026-06-07 তারিখে আনুমানিক 75.6মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:56'),
(87, 'heatwave', 'high', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 41.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:57'),
(88, 'heatwave', 'high', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-07 তারিখে সর্বোচ্চ তাপমাত্রা 40.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:57'),
(89, 'heatwave', 'high', '[49]', 'তাপদাহের পূর্বাভাস', 'Pabna জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 40.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:58'),
(90, 'heatwave', 'medium', '[52]', 'তাপদাহের পূর্বাভাস', 'Pirojpur জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 38.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:07:59'),
(91, 'heatwave', 'high', '[53]', 'তাপদাহের পূর্বাভাস', 'Rajbari জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 41.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:08:00'),
(92, 'heavy_rain', 'medium', '[53]', 'ভারী বর্ষণের পূর্বাভাস', 'Rajbari জেলায় 2026-06-07 তারিখে আনুমানিক 52.3মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:08:00'),
(93, 'heatwave', 'high', '[54]', 'তাপদাহের পূর্বাভাস', 'Rajshahi জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 41.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:08:00'),
(94, 'heatwave', 'high', '[54]', 'তাপদাহের পূর্বাভাস', 'Rajshahi জেলায় 2026-06-07 তারিখে সর্বোচ্চ তাপমাত্রা 40.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:08:00'),
(95, 'heatwave', 'high', '[57]', 'তাপদাহের পূর্বাভাস', 'Satkhira জেলায় 2026-06-06 তারিখে সর্বোচ্চ তাপমাত্রা 40.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-06 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:08:02'),
(96, 'heatwave', 'severe', '[57]', 'তাপদাহের পূর্বাভাস', 'Satkhira জেলায় 2026-06-07 তারিখে সর্বোচ্চ তাপমাত্রা 42.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-03 16:08:02'),
(97, 'heatwave', 'medium', '[1]', 'তাপদাহের পূর্বাভাস', 'Bagerhat জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 39.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:43:59'),
(98, 'heatwave', 'medium', '[11]', 'তাপদাহের পূর্বাভাস', 'Chuadanga জেলায় 2026-06-07 তারিখে সর্বোচ্চ তাপমাত্রা 39.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:11'),
(99, 'heatwave', 'medium', '[11]', 'তাপদাহের পূর্বাভাস', 'Chuadanga জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 38.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:11'),
(100, 'heatwave', 'medium', '[14]', 'তাপদাহের পূর্বাভাস', 'Dhaka জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 38.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:13'),
(101, 'heatwave', 'medium', '[16]', 'তাপদাহের পূর্বাভাস', 'Faridpur জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 38.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:15'),
(102, 'heatwave', 'medium', '[20]', 'তাপদাহের পূর্বাভাস', 'Gopalganj জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:19'),
(103, 'heavy_rain', 'medium', '[21]', 'ভারী বর্ষণের পূর্বাভাস', 'Habiganj জেলায় 2026-06-07 তারিখে আনুমানিক 61.3মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:20'),
(104, 'heatwave', 'medium', '[24]', 'তাপদাহের পূর্বাভাস', 'Jhalokati জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 38.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:21'),
(105, 'heatwave', 'high', '[25]', 'তাপদাহের পূর্বাভাস', 'Jhenaidah জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 40.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:22'),
(106, 'heatwave', 'medium', '[26]', 'তাপদাহের পূর্বাভাস', 'Joypurhat জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:23'),
(107, 'heatwave', 'medium', '[28]', 'তাপদাহের পূর্বাভাস', 'Khulna জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 39.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:25'),
(108, 'heatwave', 'medium', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-07 তারিখে সর্বোচ্চ তাপমাত্রা 39.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:27'),
(109, 'heatwave', 'medium', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 39.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:27'),
(110, 'heatwave', 'high', '[35]', 'তাপদাহের পূর্বাভাস', 'Magura জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 40.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:31'),
(111, 'heatwave', 'medium', '[37]', 'তাপদাহের পূর্বাভাস', 'Meherpur জেলায় 2026-06-07 তারিখে সর্বোচ্চ তাপমাত্রা 39.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:32'),
(112, 'heatwave', 'medium', '[37]', 'তাপদাহের পূর্বাভাস', 'Meherpur জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 38.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:32'),
(113, 'heavy_rain', 'medium', '[38]', 'ভারী বর্ষণের পূর্বাভাস', 'Moulvibazar জেলায় 2026-06-07 তারিখে আনুমানিক 61.3মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:33'),
(114, 'heatwave', 'medium', '[39]', 'তাপদাহের পূর্বাভাস', 'Munshiganj জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:34'),
(115, 'heatwave', 'medium', '[41]', 'তাপদাহের পূর্বাভাস', 'Naogaon জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 38.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:36'),
(116, 'heatwave', 'medium', '[42]', 'তাপদাহের পূর্বাভাস', 'Narail জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:37'),
(117, 'heatwave', 'medium', '[43]', 'তাপদাহের পূর্বাভাস', 'Narayanganj জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 38.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:37'),
(118, 'heatwave', 'medium', '[44]', 'তাপদাহের পূর্বাভাস', 'Narsingdi জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:38'),
(119, 'heatwave', 'medium', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 39.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:39'),
(120, 'heatwave', 'medium', '[49]', 'তাপদাহের পূর্বাভাস', 'Pabna জেলায় 2026-06-07 তারিখে সর্বোচ্চ তাপমাত্রা 38.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:43'),
(121, 'heatwave', 'medium', '[49]', 'তাপদাহের পূর্বাভাস', 'Pabna জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 38.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:43'),
(122, 'heatwave', 'medium', '[52]', 'তাপদাহের পূর্বাভাস', 'Pirojpur জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 38.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:45'),
(123, 'heatwave', 'medium', '[53]', 'তাপদাহের পূর্বাভাস', 'Rajbari জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 38.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:46'),
(124, 'heatwave', 'medium', '[54]', 'তাপদাহের পূর্বাভাস', 'Rajshahi জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 38.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:47'),
(125, 'heatwave', 'high', '[57]', 'তাপদাহের পূর্বাভাস', 'Satkhira জেলায় 2026-06-08 তারিখে সর্বোচ্চ তাপমাত্রা 41.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-08 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:50'),
(126, 'heavy_rain', 'medium', '[61]', 'ভারী বর্ষণের পূর্বাভাস', 'Sunamganj জেলায় 2026-06-07 তারিখে আনুমানিক 64.0মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:53'),
(127, 'heavy_rain', 'medium', '[62]', 'ভারী বর্ষণের পূর্বাভাস', 'Sylhet জেলায় 2026-06-07 তারিখে আনুমানিক 62.8মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-09 00:54:07', '2026-06-07 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:54'),
(128, 'heatwave', 'medium', '[63]', 'তাপদাহের পূর্বাভাস', 'Tangail জেলায় 2026-06-05 তারিখে সর্বোচ্চ তাপমাত্রা 38.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-09 00:54:07', '2026-06-05 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-04 13:44:54'),
(129, 'heatwave', 'medium', '[1]', 'তাপদাহের পূর্বাভাস', 'Bagerhat জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 38.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:07'),
(130, 'heatwave', 'severe', '[11]', 'তাপদাহের পূর্বাভাস', 'Chuadanga জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 42.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:14'),
(131, 'heatwave', 'high', '[11]', 'তাপদাহের পূর্বাভাস', 'Chuadanga জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 42.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:14'),
(132, 'heatwave', 'medium', '[15]', 'তাপদাহের পূর্বাভাস', 'Dinajpur জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 39.9°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:17');
INSERT INTO `weather_alerts` (`alert_id`, `alert_type`, `severity`, `affected_districts`, `alert_title`, `alert_message`, `recommendations`, `affected_crops`, `start_time`, `end_time`, `issued_by`, `created_by`, `is_active`, `created_at`) VALUES
(133, 'heatwave', 'medium', '[15]', 'তাপদাহের পূর্বাভাস', 'Dinajpur জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 38.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:17'),
(134, 'heatwave', 'medium', '[16]', 'তাপদাহের পূর্বাভাস', 'Faridpur জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 38.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:18'),
(135, 'heatwave', 'medium', '[16]', 'তাপদাহের পূর্বাভাস', 'Faridpur জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:18'),
(136, 'heatwave', 'high', '[20]', 'তাপদাহের পূর্বাভাস', 'Gopalganj জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 40.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:21'),
(137, 'heatwave', 'medium', '[20]', 'তাপদাহের পূর্বাভাস', 'Gopalganj জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 39.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:21'),
(138, 'heatwave', 'high', '[25]', 'তাপদাহের পূর্বাভাস', 'Jhenaidah জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 41.9°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:24'),
(139, 'heatwave', 'high', '[25]', 'তাপদাহের পূর্বাভাস', 'Jhenaidah জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 40.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:24'),
(140, 'heatwave', 'high', '[26]', 'তাপদাহের পূর্বাভাস', 'Joypurhat জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 40.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:25'),
(141, 'heatwave', 'medium', '[26]', 'তাপদাহের পূর্বাভাস', 'Joypurhat জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 39.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:25'),
(142, 'heatwave', 'medium', '[28]', 'তাপদাহের পূর্বাভাস', 'Khulna জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 38.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:27'),
(143, 'heatwave', 'high', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 41.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:30'),
(144, 'heatwave', 'severe', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 42.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:30'),
(145, 'heatwave', 'medium', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-11 তারিখে সর্বোচ্চ তাপমাত্রা 38.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-11 00:00:00', '2026-06-11 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-09 00:54:30'),
(146, 'heatwave', 'medium', '[34]', 'তাপদাহের পূর্বাভাস', 'Madaripur জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 38.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:32'),
(147, 'heatwave', 'high', '[35]', 'তাপদাহের পূর্বাভাস', 'Magura জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 42.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:33'),
(148, 'heatwave', 'high', '[35]', 'তাপদাহের পূর্বাভাস', 'Magura জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 40.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:33'),
(149, 'heatwave', 'medium', '[35]', 'তাপদাহের পূর্বাভাস', 'Magura জেলায় 2026-06-11 তারিখে সর্বোচ্চ তাপমাত্রা 38.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-11 00:00:00', '2026-06-11 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-09 00:54:33'),
(150, 'heatwave', 'severe', '[37]', 'তাপদাহের পূর্বাভাস', 'Meherpur জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 42.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:35'),
(151, 'heatwave', 'high', '[37]', 'তাপদাহের পূর্বাভাস', 'Meherpur জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 41.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:35'),
(152, 'heatwave', 'medium', '[37]', 'তাপদাহের পূর্বাভাস', 'Meherpur জেলায় 2026-06-11 তারিখে সর্বোচ্চ তাপমাত্রা 38.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-11 00:00:00', '2026-06-11 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-09 00:54:35'),
(153, 'heatwave', 'high', '[41]', 'তাপদাহের পূর্বাভাস', 'Naogaon জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 41.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:38'),
(154, 'heatwave', 'high', '[41]', 'তাপদাহের পূর্বাভাস', 'Naogaon জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 41.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:38'),
(155, 'heatwave', 'high', '[42]', 'তাপদাহের পূর্বাভাস', 'Narail জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 40.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:39'),
(156, 'heatwave', 'medium', '[42]', 'তাপদাহের পূর্বাভাস', 'Narail জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 39.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:39'),
(157, 'heatwave', 'high', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 41.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:42'),
(158, 'heatwave', 'high', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 41.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:42'),
(159, 'heatwave', 'medium', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-12 তারিখে সর্বোচ্চ তাপমাত্রা 38.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-12 00:00:00', '2026-06-12 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-09 00:54:42'),
(160, 'heatwave', 'medium', '[47]', 'তাপদাহের পূর্বাভাস', 'Nilphamari জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 38.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:44'),
(161, 'heatwave', 'high', '[49]', 'তাপদাহের পূর্বাভাস', 'Pabna জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 40.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:45'),
(162, 'heatwave', 'high', '[49]', 'তাপদাহের পূর্বাভাস', 'Pabna জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 40.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:45'),
(163, 'heavy_rain', 'medium', '[50]', 'ভারী বর্ষণের পূর্বাভাস', 'Panchagarh জেলায় 2026-06-10 তারিখে আনুমানিক 59.9মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:46'),
(164, 'heavy_rain', 'high', '[51]', 'ভারী বর্ষণের পূর্বাভাস', 'Patuakhali জেলায় 2026-06-13 তারিখে আনুমানিক 98.4মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-13 00:00:00', '2026-06-13 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-09 00:54:47'),
(165, 'heavy_rain', 'medium', '[52]', 'ভারী বর্ষণের পূর্বাভাস', 'Pirojpur জেলায় 2026-06-12 তারিখে আনুমানিক 59.4মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-12 00:00:00', '2026-06-12 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-09 00:54:48'),
(166, 'heatwave', 'medium', '[53]', 'তাপদাহের পূর্বাভাস', 'Rajbari জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 39.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:49'),
(167, 'heatwave', 'medium', '[53]', 'তাপদাহের পূর্বাভাস', 'Rajbari জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 38.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:49'),
(168, 'heatwave', 'severe', '[54]', 'তাপদাহের পূর্বাভাস', 'Rajshahi জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 42.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:50'),
(169, 'heatwave', 'high', '[54]', 'তাপদাহের পূর্বাভাস', 'Rajshahi জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 41.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:50'),
(170, 'heatwave', 'medium', '[57]', 'তাপদাহের পূর্বাভাস', 'Satkhira জেলায় 2026-06-10 তারিখে সর্বোচ্চ তাপমাত্রা 39.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-10 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:53'),
(171, 'heatwave', 'medium', '[59]', 'তাপদাহের পূর্বাভাস', 'Sherpur জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 38.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:55'),
(172, 'heatwave', 'medium', '[63]', 'তাপদাহের পূর্বাভাস', 'Tangail জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:58'),
(173, 'heatwave', 'medium', '[64]', 'তাপদাহের পূর্বাভাস', 'Thakurgaon জেলায় 2026-06-09 তারিখে সর্বোচ্চ তাপমাত্রা 38.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-10 18:00:03', '2026-06-09 17:59:59', 'AgroFin Weather Bot', NULL, 0, '2026-06-09 00:54:59'),
(174, 'heavy_rain', 'medium', '[4]', 'ভারী বর্ষণের পূর্বাভাস', 'Barishal জেলায় 2026-06-13 তারিখে আনুমানিক 56.9মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-13 00:00:00', '2026-06-13 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-09 01:17:17'),
(175, 'heatwave', 'medium', '[11]', 'তাপদাহের পূর্বাভাস', 'Chuadanga জেলায় 2026-06-11 তারিখে সর্বোচ্চ তাপমাত্রা 38.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-11 00:00:00', '2026-06-11 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-10 18:00:11'),
(176, 'heatwave', 'medium', '[25]', 'তাপদাহের পূর্বাভাস', 'Jhenaidah জেলায় 2026-06-11 তারিখে সর্বোচ্চ তাপমাত্রা 38.9°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-11 00:00:00', '2026-06-11 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-10 18:00:23'),
(177, 'heatwave', 'medium', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-14 তারিখে সর্বোচ্চ তাপমাত্রা 38.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-14 00:00:00', '2026-06-14 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-10 18:00:28'),
(178, 'heatwave', 'medium', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-11 তারিখে সর্বোচ্চ তাপমাত্রা 39.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-11 00:00:00', '2026-06-11 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-10 18:00:40'),
(179, 'heatwave', 'medium', '[54]', 'তাপদাহের পূর্বাভাস', 'Rajshahi জেলায় 2026-06-11 তারিখে সর্বোচ্চ তাপমাত্রা 38.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-11 00:00:00', '2026-06-11 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-10 18:00:48'),
(180, 'heatwave', 'medium', '[11]', 'তাপদাহের পূর্বাভাস', 'Chuadanga জেলায় 2026-06-15 তারিখে সর্বোচ্চ তাপমাত্রা 38.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-15 00:00:00', '2026-06-15 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:24'),
(181, 'heatwave', 'medium', '[11]', 'তাপদাহের পূর্বাভাস', 'Chuadanga জেলায় 2026-06-16 তারিখে সর্বোচ্চ তাপমাত্রা 39.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-16 00:00:00', '2026-06-16 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:24'),
(182, 'heatwave', 'medium', '[11]', 'তাপদাহের পূর্বাভাস', 'Chuadanga জেলায় 2026-06-17 তারিখে সর্বোচ্চ তাপমাত্রা 39.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-17 00:00:00', '2026-06-17 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:24'),
(183, 'heatwave', 'medium', '[11]', 'তাপদাহের পূর্বাভাস', 'Chuadanga জেলায় 2026-06-18 তারিখে সর্বোচ্চ তাপমাত্রা 39.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-18 00:00:00', '2026-06-18 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:24'),
(184, 'heatwave', 'medium', '[15]', 'তাপদাহের পূর্বাভাস', 'Dinajpur জেলায় 2026-06-15 তারিখে সর্বোচ্চ তাপমাত্রা 39.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-15 00:00:00', '2026-06-15 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:25'),
(185, 'heatwave', 'medium', '[25]', 'তাপদাহের পূর্বাভাস', 'Jhenaidah জেলায় 2026-06-15 তারিখে সর্বোচ্চ তাপমাত্রা 38.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-15 00:00:00', '2026-06-15 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:28'),
(186, 'heatwave', 'medium', '[25]', 'তাপদাহের পূর্বাভাস', 'Jhenaidah জেলায় 2026-06-17 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-17 00:00:00', '2026-06-17 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:28'),
(187, 'heatwave', 'medium', '[25]', 'তাপদাহের পূর্বাভাস', 'Jhenaidah জেলায় 2026-06-18 তারিখে সর্বোচ্চ তাপমাত্রা 38.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-18 00:00:00', '2026-06-18 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:28'),
(188, 'heatwave', 'medium', '[26]', 'তাপদাহের পূর্বাভাস', 'Joypurhat জেলায় 2026-06-15 তারিখে সর্বোচ্চ তাপমাত্রা 39.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-15 00:00:00', '2026-06-15 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:29'),
(189, 'heatwave', 'medium', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-15 তারিখে সর্বোচ্চ তাপমাত্রা 39.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-15 00:00:00', '2026-06-15 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:30'),
(190, 'heatwave', 'high', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-16 তারিখে সর্বোচ্চ তাপমাত্রা 40.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-16 00:00:00', '2026-06-16 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:30'),
(191, 'heatwave', 'high', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-17 তারিখে সর্বোচ্চ তাপমাত্রা 40.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-17 00:00:00', '2026-06-17 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:30'),
(192, 'heatwave', 'high', '[31]', 'তাপদাহের পূর্বাভাস', 'Kushtia জেলায় 2026-06-18 তারিখে সর্বোচ্চ তাপমাত্রা 40.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-18 00:00:00', '2026-06-18 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:30'),
(193, 'heavy_rain', 'medium', '[33]', 'ভারী বর্ষণের পূর্বাভাস', 'Lalmonirhat জেলায় 2026-06-17 তারিখে আনুমানিক 52.9মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-17 00:00:00', '2026-06-17 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:31'),
(194, 'heavy_rain', 'medium', '[33]', 'ভারী বর্ষণের পূর্বাভাস', 'Lalmonirhat জেলায় 2026-06-18 তারিখে আনুমানিক 62.6মিমি বৃষ্টিপাত হতে পারে।', 'ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।', '[]', '2026-06-18 00:00:00', '2026-06-18 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:31'),
(195, 'heatwave', 'medium', '[35]', 'তাপদাহের পূর্বাভাস', 'Magura জেলায় 2026-06-17 তারিখে সর্বোচ্চ তাপমাত্রা 38.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-17 00:00:00', '2026-06-17 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:32'),
(196, 'heatwave', 'medium', '[35]', 'তাপদাহের পূর্বাভাস', 'Magura জেলায় 2026-06-18 তারিখে সর্বোচ্চ তাপমাত্রা 38.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-18 00:00:00', '2026-06-18 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:32'),
(197, 'heatwave', 'medium', '[37]', 'তাপদাহের পূর্বাভাস', 'Meherpur জেলায় 2026-06-15 তারিখে সর্বোচ্চ তাপমাত্রা 38.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-15 00:00:00', '2026-06-15 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:32'),
(198, 'heatwave', 'medium', '[37]', 'তাপদাহের পূর্বাভাস', 'Meherpur জেলায় 2026-06-16 তারিখে সর্বোচ্চ তাপমাত্রা 39.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-16 00:00:00', '2026-06-16 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:32'),
(199, 'heatwave', 'medium', '[37]', 'তাপদাহের পূর্বাভাস', 'Meherpur জেলায় 2026-06-17 তারিখে সর্বোচ্চ তাপমাত্রা 39.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-17 00:00:00', '2026-06-17 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:32'),
(200, 'heatwave', 'medium', '[37]', 'তাপদাহের পূর্বাভাস', 'Meherpur জেলায় 2026-06-18 তারিখে সর্বোচ্চ তাপমাত্রা 39.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-18 00:00:00', '2026-06-18 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:32'),
(201, 'heatwave', 'high', '[41]', 'তাপদাহের পূর্বাভাস', 'Naogaon জেলায় 2026-06-15 তারিখে সর্বোচ্চ তাপমাত্রা 40.6°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-15 00:00:00', '2026-06-15 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:34'),
(202, 'heatwave', 'medium', '[41]', 'তাপদাহের পূর্বাভাস', 'Naogaon জেলায় 2026-06-16 তারিখে সর্বোচ্চ তাপমাত্রা 38.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-16 00:00:00', '2026-06-16 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:34'),
(203, 'heatwave', 'medium', '[41]', 'তাপদাহের পূর্বাভাস', 'Naogaon জেলায় 2026-06-17 তারিখে সর্বোচ্চ তাপমাত্রা 39.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-17 00:00:00', '2026-06-17 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:34'),
(204, 'heatwave', 'medium', '[41]', 'তাপদাহের পূর্বাভাস', 'Naogaon জেলায় 2026-06-18 তারিখে সর্বোচ্চ তাপমাত্রা 39.0°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-18 00:00:00', '2026-06-18 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:34'),
(205, 'heatwave', 'medium', '[42]', 'তাপদাহের পূর্বাভাস', 'Narail জেলায় 2026-06-18 তারিখে সর্বোচ্চ তাপমাত্রা 38.1°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-18 00:00:00', '2026-06-18 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:34'),
(206, 'heatwave', 'high', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-15 তারিখে সর্বোচ্চ তাপমাত্রা 41.3°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-15 00:00:00', '2026-06-15 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:35'),
(207, 'heatwave', 'high', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-16 তারিখে সর্বোচ্চ তাপমাত্রা 40.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-16 00:00:00', '2026-06-16 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:35'),
(208, 'heatwave', 'high', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-17 তারিখে সর্বোচ্চ তাপমাত্রা 40.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-17 00:00:00', '2026-06-17 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:35'),
(209, 'heatwave', 'medium', '[45]', 'তাপদাহের পূর্বাভাস', 'Natore জেলায় 2026-06-18 তারিখে সর্বোচ্চ তাপমাত্রা 39.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-18 00:00:00', '2026-06-18 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:35'),
(210, 'heatwave', 'medium', '[47]', 'তাপদাহের পূর্বাভাস', 'Nilphamari জেলায় 2026-06-15 তারিখে সর্বোচ্চ তাপমাত্রা 38.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-15 00:00:00', '2026-06-15 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:36'),
(211, 'heatwave', 'medium', '[49]', 'তাপদাহের পূর্বাভাস', 'Pabna জেলায় 2026-06-17 তারিখে সর্বোচ্চ তাপমাত্রা 39.2°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-17 00:00:00', '2026-06-17 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:36'),
(212, 'heatwave', 'medium', '[49]', 'তাপদাহের পূর্বাভাস', 'Pabna জেলায় 2026-06-18 তারিখে সর্বোচ্চ তাপমাত্রা 38.9°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-18 00:00:00', '2026-06-18 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:36'),
(213, 'heatwave', 'high', '[54]', 'তাপদাহের পূর্বাভাস', 'Rajshahi জেলায় 2026-06-15 তারিখে সর্বোচ্চ তাপমাত্রা 40.7°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-15 00:00:00', '2026-06-15 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:38'),
(214, 'heatwave', 'high', '[54]', 'তাপদাহের পূর্বাভাস', 'Rajshahi জেলায় 2026-06-16 তারিখে সর্বোচ্চ তাপমাত্রা 40.5°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-16 00:00:00', '2026-06-16 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:38'),
(215, 'heatwave', 'high', '[54]', 'তাপদাহের পূর্বাভাস', 'Rajshahi জেলায় 2026-06-17 তারিখে সর্বোচ্চ তাপমাত্রা 40.4°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-17 00:00:00', '2026-06-17 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:38'),
(216, 'heatwave', 'medium', '[54]', 'তাপদাহের পূর্বাভাস', 'Rajshahi জেলায় 2026-06-18 তারিখে সর্বোচ্চ তাপমাত্রা 39.8°সে পর্যন্ত উঠতে পারে।', 'ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।', '[]', '2026-06-18 00:00:00', '2026-06-18 17:59:59', 'AgroFin Weather Bot', NULL, 1, '2026-06-14 11:17:38');

-- --------------------------------------------------------

--
-- Table structure for table `weather_forecasts`
--

CREATE TABLE `weather_forecasts` (
  `forecast_id` int(10) UNSIGNED NOT NULL,
  `district_id` int(10) UNSIGNED NOT NULL,
  `forecast_date` date NOT NULL,
  `forecast_for` enum('current','today','tomorrow','day_3','day_4','day_5') NOT NULL,
  `temp_min` decimal(5,2) DEFAULT NULL,
  `temp_max` decimal(5,2) DEFAULT NULL,
  `humidity` tinyint(3) UNSIGNED DEFAULT NULL,
  `rainfall_mm` decimal(6,2) DEFAULT 0.00,
  `wind_speed_kmh` decimal(5,2) DEFAULT NULL,
  `conditions` varchar(100) DEFAULT NULL,
  `icon` varchar(20) DEFAULT NULL,
  `raw_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`raw_payload`)),
  `fetched_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `weather_forecasts`
--

INSERT INTO `weather_forecasts` (`forecast_id`, `district_id`, `forecast_date`, `forecast_for`, `temp_min`, `temp_max`, `humidity`, `rainfall_mm`, `wind_speed_kmh`, `conditions`, `icon`, `raw_payload`, `fetched_at`) VALUES
(1, 1, '2026-06-03', 'current', 30.13, 31.15, 65, 0.00, 19.94, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.13,\"temp_max\":31.15,\"humidity\":65,\"rainfall_mm\":0,\"wind_speed_kmh\":19.94,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:42'),
(2, 1, '2026-06-03', 'today', 30.29, 31.15, 69, 0.00, 19.94, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.29,\"temp_max\":31.15,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":19.94,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:42'),
(3, 1, '2026-06-04', 'tomorrow', 27.12, 40.64, 67, 16.72, 31.36, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.12,\"temp_max\":40.64,\"humidity\":67,\"rainfall_mm\":16.72,\"wind_speed_kmh\":31.36,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:42'),
(4, 1, '2026-06-05', 'day_3', 29.36, 39.25, 67, 5.06, 23.80, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":29.36,\"temp_max\":39.25,\"humidity\":67,\"rainfall_mm\":5.06,\"wind_speed_kmh\":23.8,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:42'),
(5, 1, '2026-06-06', 'day_4', 29.69, 40.01, 65, 3.40, 28.94, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":29.69,\"temp_max\":40.01,\"humidity\":65,\"rainfall_mm\":3.4,\"wind_speed_kmh\":28.94,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:42'),
(6, 1, '2026-06-07', 'day_5', 29.51, 40.89, 66, 2.27, 30.89, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":29.51,\"temp_max\":40.89,\"humidity\":66,\"rainfall_mm\":2.27,\"wind_speed_kmh\":30.89,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:42'),
(7, 2, '2026-06-03', 'current', 25.19, 25.71, 83, 0.00, 4.57, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":25.19,\"temp_max\":25.71,\"humidity\":83,\"rainfall_mm\":0,\"wind_speed_kmh\":4.57,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:07:43'),
(8, 2, '2026-06-03', 'today', 25.06, 25.71, 85, 0.00, 4.57, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":25.06,\"temp_max\":25.71,\"humidity\":85,\"rainfall_mm\":0,\"wind_speed_kmh\":4.57,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:07:43'),
(9, 2, '2026-06-04', 'tomorrow', 24.76, 36.88, 72, 4.55, 13.07, 'Clear', '02d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.76,\"temp_max\":36.88,\"humidity\":72,\"rainfall_mm\":4.55,\"wind_speed_kmh\":13.07,\"conditions\":\"Clear\",\"icon\":\"02d\"}', '2026-06-03 16:07:43'),
(10, 2, '2026-06-05', 'day_3', 25.22, 35.64, 75, 2.87, 12.38, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.22,\"temp_max\":35.64,\"humidity\":75,\"rainfall_mm\":2.87,\"wind_speed_kmh\":12.38,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:43'),
(11, 2, '2026-06-06', 'day_4', 25.60, 35.15, 72, 2.23, 10.30, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":25.6,\"temp_max\":35.15,\"humidity\":72,\"rainfall_mm\":2.23,\"wind_speed_kmh\":10.3,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:43'),
(12, 2, '2026-06-07', 'day_5', 22.54, 30.01, 91, 71.10, 13.10, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":22.54,\"temp_max\":30.01,\"humidity\":91,\"rainfall_mm\":71.1,\"wind_speed_kmh\":13.1,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:43'),
(13, 3, '2026-06-03', 'current', 29.48, 29.86, 78, 0.00, 16.20, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.48,\"temp_max\":29.86,\"humidity\":78,\"rainfall_mm\":0,\"wind_speed_kmh\":16.2,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:07:43'),
(14, 3, '2026-06-03', 'today', 29.32, 29.86, 80, 0.16, 16.20, 'Clear', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.32,\"temp_max\":29.86,\"humidity\":80,\"rainfall_mm\":0.16,\"wind_speed_kmh\":16.2,\"conditions\":\"Clear\",\"icon\":\"10n\"}', '2026-06-03 16:07:43'),
(15, 3, '2026-06-04', 'tomorrow', 28.97, 34.17, 73, 2.16, 28.08, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.97,\"temp_max\":34.17,\"humidity\":73,\"rainfall_mm\":2.16,\"wind_speed_kmh\":28.08,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:43'),
(16, 3, '2026-06-05', 'day_3', 29.50, 34.22, 76, 7.94, 27.79, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":29.5,\"temp_max\":34.22,\"humidity\":76,\"rainfall_mm\":7.94,\"wind_speed_kmh\":27.79,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:43'),
(17, 3, '2026-06-06', 'day_4', 29.66, 33.34, 77, 2.41, 32.54, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":29.66,\"temp_max\":33.34,\"humidity\":77,\"rainfall_mm\":2.41,\"wind_speed_kmh\":32.54,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:43'),
(18, 3, '2026-06-07', 'day_5', 23.88, 31.92, 83, 27.99, 28.80, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":23.88,\"temp_max\":31.92,\"humidity\":83,\"rainfall_mm\":27.99,\"wind_speed_kmh\":28.8,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:43'),
(19, 4, '2026-06-03', 'current', 29.47, 30.20, 72, 0.00, 13.39, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.47,\"temp_max\":30.2,\"humidity\":72,\"rainfall_mm\":0,\"wind_speed_kmh\":13.39,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:43'),
(20, 4, '2026-06-03', 'today', 29.51, 30.20, 76, 0.00, 13.39, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.51,\"temp_max\":30.2,\"humidity\":76,\"rainfall_mm\":0,\"wind_speed_kmh\":13.39,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:43'),
(21, 4, '2026-06-04', 'tomorrow', 29.03, 37.62, 66, 3.92, 23.33, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.03,\"temp_max\":37.62,\"humidity\":66,\"rainfall_mm\":3.92,\"wind_speed_kmh\":23.33,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:43'),
(22, 4, '2026-06-05', 'day_3', 29.57, 38.01, 66, 0.98, 22.54, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":29.57,\"temp_max\":38.01,\"humidity\":66,\"rainfall_mm\":0.98,\"wind_speed_kmh\":22.54,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:43'),
(23, 4, '2026-06-06', 'day_4', 29.92, 37.86, 67, 0.35, 27.07, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":29.92,\"temp_max\":37.86,\"humidity\":67,\"rainfall_mm\":0.35,\"wind_speed_kmh\":27.07,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:43'),
(24, 4, '2026-06-07', 'day_5', 25.90, 35.58, 73, 13.14, 23.44, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.9,\"temp_max\":35.58,\"humidity\":73,\"rainfall_mm\":13.14,\"wind_speed_kmh\":23.44,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:43'),
(25, 5, '2026-06-03', 'current', 29.42, 29.73, 78, 0.00, 15.84, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.42,\"temp_max\":29.73,\"humidity\":78,\"rainfall_mm\":0,\"wind_speed_kmh\":15.84,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:07:44'),
(26, 5, '2026-06-03', 'today', 29.15, 29.73, 80, 0.11, 15.84, 'Clear', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.15,\"temp_max\":29.73,\"humidity\":80,\"rainfall_mm\":0.11,\"wind_speed_kmh\":15.84,\"conditions\":\"Clear\",\"icon\":\"10n\"}', '2026-06-03 16:07:44'),
(27, 5, '2026-06-04', 'tomorrow', 28.91, 34.51, 72, 1.98, 27.86, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.91,\"temp_max\":34.51,\"humidity\":72,\"rainfall_mm\":1.98,\"wind_speed_kmh\":27.86,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:44'),
(28, 5, '2026-06-05', 'day_3', 29.26, 34.68, 76, 13.36, 25.81, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":29.26,\"temp_max\":34.68,\"humidity\":76,\"rainfall_mm\":13.36,\"wind_speed_kmh\":25.81,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:44'),
(29, 5, '2026-06-06', 'day_4', 29.42, 33.60, 77, 4.47, 31.93, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":29.42,\"temp_max\":33.6,\"humidity\":77,\"rainfall_mm\":4.47,\"wind_speed_kmh\":31.93,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:44'),
(30, 5, '2026-06-07', 'day_5', 23.96, 31.90, 83, 28.07, 28.26, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":23.96,\"temp_max\":31.9,\"humidity\":83,\"rainfall_mm\":28.07,\"wind_speed_kmh\":28.26,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:44'),
(31, 7, '2026-06-03', 'current', 27.19, 28.17, 78, 0.00, 10.76, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":27.19,\"temp_max\":28.17,\"humidity\":78,\"rainfall_mm\":0,\"wind_speed_kmh\":10.76,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:07:44'),
(32, 7, '2026-06-03', 'today', 27.45, 28.17, 81, 0.44, 10.76, 'Clear', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":27.45,\"temp_max\":28.17,\"humidity\":81,\"rainfall_mm\":0.44,\"wind_speed_kmh\":10.76,\"conditions\":\"Clear\",\"icon\":\"10n\"}', '2026-06-03 16:07:44'),
(33, 7, '2026-06-04', 'tomorrow', 24.41, 34.96, 79, 22.47, 34.88, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.41,\"temp_max\":34.96,\"humidity\":79,\"rainfall_mm\":22.47,\"wind_speed_kmh\":34.88,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:44'),
(34, 7, '2026-06-05', 'day_3', 25.72, 33.62, 81, 20.06, 23.80, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.72,\"temp_max\":33.62,\"humidity\":81,\"rainfall_mm\":20.06,\"wind_speed_kmh\":23.8,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:44'),
(35, 7, '2026-06-06', 'day_4', 26.86, 33.80, 82, 43.61, 25.34, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.86,\"temp_max\":33.8,\"humidity\":82,\"rainfall_mm\":43.61,\"wind_speed_kmh\":25.34,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:44'),
(36, 7, '2026-06-07', 'day_5', 23.27, 28.13, 92, 37.17, 22.54, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":23.27,\"temp_max\":28.13,\"humidity\":92,\"rainfall_mm\":37.17,\"wind_speed_kmh\":22.54,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:44'),
(37, 8, '2026-06-03', 'current', 26.85, 27.74, 83, 0.00, 8.86, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":26.85,\"temp_max\":27.74,\"humidity\":83,\"rainfall_mm\":0,\"wind_speed_kmh\":8.86,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:44'),
(38, 8, '2026-06-03', 'today', 26.97, 27.74, 86, 0.00, 8.86, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":26.97,\"temp_max\":27.74,\"humidity\":86,\"rainfall_mm\":0,\"wind_speed_kmh\":8.86,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:44'),
(39, 8, '2026-06-04', 'tomorrow', 26.01, 34.10, 78, 8.65, 16.88, 'Rain', '02d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.01,\"temp_max\":34.1,\"humidity\":78,\"rainfall_mm\":8.65,\"wind_speed_kmh\":16.88,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-03 16:07:44'),
(40, 8, '2026-06-05', 'day_3', 26.96, 33.85, 84, 12.20, 19.87, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.96,\"temp_max\":33.85,\"humidity\":84,\"rainfall_mm\":12.2,\"wind_speed_kmh\":19.87,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:44'),
(41, 8, '2026-06-06', 'day_4', 26.35, 33.01, 82, 4.19, 22.68, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.35,\"temp_max\":33.01,\"humidity\":82,\"rainfall_mm\":4.19,\"wind_speed_kmh\":22.68,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:44'),
(42, 8, '2026-06-07', 'day_5', 22.64, 28.57, 93, 121.89, 17.96, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":22.64,\"temp_max\":28.57,\"humidity\":93,\"rainfall_mm\":121.89,\"wind_speed_kmh\":17.96,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:44'),
(43, 11, '2026-06-03', 'current', 31.38, 32.78, 52, 0.63, 19.48, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":31.38,\"temp_max\":32.78,\"humidity\":52,\"rainfall_mm\":0.63,\"wind_speed_kmh\":19.48,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:45'),
(44, 11, '2026-06-03', 'today', 31.23, 32.78, 59, 0.75, 19.51, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":31.23,\"temp_max\":32.78,\"humidity\":59,\"rainfall_mm\":0.75,\"wind_speed_kmh\":19.51,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:45'),
(45, 11, '2026-06-04', 'tomorrow', 27.38, 41.03, 61, 11.04, 36.36, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.38,\"temp_max\":41.03,\"humidity\":61,\"rainfall_mm\":11.04,\"wind_speed_kmh\":36.36,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:45'),
(46, 11, '2026-06-05', 'day_3', 26.72, 42.07, 64, 10.33, 25.31, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.72,\"temp_max\":42.07,\"humidity\":64,\"rainfall_mm\":10.33,\"wind_speed_kmh\":25.31,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:45'),
(47, 11, '2026-06-06', 'day_4', 28.21, 41.99, 63, 16.26, 22.54, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":28.21,\"temp_max\":41.99,\"humidity\":63,\"rainfall_mm\":16.26,\"wind_speed_kmh\":22.54,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:45'),
(48, 11, '2026-06-07', 'day_5', 27.91, 37.45, 71, 1.81, 31.72, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":27.91,\"temp_max\":37.45,\"humidity\":71,\"rainfall_mm\":1.81,\"wind_speed_kmh\":31.72,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:45'),
(49, 12, '2026-06-03', 'current', 27.60, 27.97, 80, 0.00, 10.62, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":27.6,\"temp_max\":27.97,\"humidity\":80,\"rainfall_mm\":0,\"wind_speed_kmh\":10.62,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:45'),
(50, 12, '2026-06-03', 'today', 27.45, 27.97, 83, 0.00, 10.62, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":27.45,\"temp_max\":27.97,\"humidity\":83,\"rainfall_mm\":0,\"wind_speed_kmh\":10.62,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:45'),
(51, 12, '2026-06-04', 'tomorrow', 25.28, 35.08, 77, 9.48, 22.68, 'Rain', '04d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.28,\"temp_max\":35.08,\"humidity\":77,\"rainfall_mm\":9.48,\"wind_speed_kmh\":22.68,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:45'),
(52, 12, '2026-06-05', 'day_3', 26.44, 33.49, 81, 12.62, 30.28, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.44,\"temp_max\":33.49,\"humidity\":81,\"rainfall_mm\":12.62,\"wind_speed_kmh\":30.28,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:45'),
(53, 12, '2026-06-06', 'day_4', 27.13, 33.55, 81, 8.28, 27.86, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":27.13,\"temp_max\":33.55,\"humidity\":81,\"rainfall_mm\":8.28,\"wind_speed_kmh\":27.86,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:45'),
(54, 12, '2026-06-07', 'day_5', 22.63, 28.46, 92, 121.46, 23.33, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":22.63,\"temp_max\":28.46,\"humidity\":92,\"rainfall_mm\":121.46,\"wind_speed_kmh\":23.33,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:45'),
(55, 13, '2026-06-03', 'current', 28.13, 28.66, 83, 0.10, 6.55, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":28.13,\"temp_max\":28.66,\"humidity\":83,\"rainfall_mm\":0.1,\"wind_speed_kmh\":6.55,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:45'),
(56, 13, '2026-06-03', 'today', 28.09, 28.66, 84, 0.10, 7.42, 'Rain', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":28.09,\"temp_max\":28.66,\"humidity\":84,\"rainfall_mm\":0.1,\"wind_speed_kmh\":7.42,\"conditions\":\"Rain\",\"icon\":\"01n\"}', '2026-06-03 16:07:45'),
(57, 13, '2026-06-04', 'tomorrow', 27.69, 32.21, 77, 3.87, 19.08, 'Clear', '01d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.69,\"temp_max\":32.21,\"humidity\":77,\"rainfall_mm\":3.87,\"wind_speed_kmh\":19.08,\"conditions\":\"Clear\",\"icon\":\"01d\"}', '2026-06-03 16:07:45'),
(58, 13, '2026-06-05', 'day_3', 27.31, 32.06, 80, 2.89, 20.74, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":27.31,\"temp_max\":32.06,\"humidity\":80,\"rainfall_mm\":2.89,\"wind_speed_kmh\":20.74,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:45'),
(59, 13, '2026-06-06', 'day_4', 27.43, 32.35, 79, 0.42, 27.43, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":27.43,\"temp_max\":32.35,\"humidity\":79,\"rainfall_mm\":0.42,\"wind_speed_kmh\":27.43,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-03 16:07:45'),
(60, 13, '2026-06-07', 'day_5', 26.43, 32.46, 82, 5.93, 26.42, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":26.43,\"temp_max\":32.46,\"humidity\":82,\"rainfall_mm\":5.93,\"wind_speed_kmh\":26.42,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:45'),
(61, 14, '2026-06-03', 'current', 30.73, 30.90, 66, 0.00, 19.48, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.73,\"temp_max\":30.9,\"humidity\":66,\"rainfall_mm\":0,\"wind_speed_kmh\":19.48,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:46'),
(62, 14, '2026-06-03', 'today', 30.28, 30.90, 68, 0.00, 19.48, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.28,\"temp_max\":30.9,\"humidity\":68,\"rainfall_mm\":0,\"wind_speed_kmh\":19.48,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:46'),
(63, 14, '2026-06-04', 'tomorrow', 25.03, 37.94, 64, 14.17, 25.85, 'Rain', '04d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.03,\"temp_max\":37.94,\"humidity\":64,\"rainfall_mm\":14.17,\"wind_speed_kmh\":25.85,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:46'),
(64, 14, '2026-06-05', 'day_3', 27.10, 37.37, 69, 10.53, 25.99, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":27.1,\"temp_max\":37.37,\"humidity\":69,\"rainfall_mm\":10.53,\"wind_speed_kmh\":25.99,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:46'),
(65, 14, '2026-06-06', 'day_4', 26.87, 36.86, 71, 13.45, 31.07, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.87,\"temp_max\":36.86,\"humidity\":71,\"rainfall_mm\":13.45,\"wind_speed_kmh\":31.07,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:46'),
(66, 14, '2026-06-07', 'day_5', 24.65, 32.82, 84, 126.82, 25.09, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.65,\"temp_max\":32.82,\"humidity\":84,\"rainfall_mm\":126.82,\"wind_speed_kmh\":25.09,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:46'),
(67, 15, '2026-06-03', 'current', 30.34, 30.83, 62, 0.00, 16.88, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.34,\"temp_max\":30.83,\"humidity\":62,\"rainfall_mm\":0,\"wind_speed_kmh\":16.88,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:46'),
(68, 15, '2026-06-03', 'today', 30.48, 30.83, 63, 0.00, 16.88, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.48,\"temp_max\":30.83,\"humidity\":63,\"rainfall_mm\":0,\"wind_speed_kmh\":16.88,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:46'),
(69, 15, '2026-06-04', 'tomorrow', 26.67, 41.56, 65, 5.46, 20.74, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.67,\"temp_max\":41.56,\"humidity\":65,\"rainfall_mm\":5.46,\"wind_speed_kmh\":20.74,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:46'),
(70, 15, '2026-06-05', 'day_3', 25.47, 37.38, 71, 7.98, 26.71, 'Rain', '01d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.47,\"temp_max\":37.38,\"humidity\":71,\"rainfall_mm\":7.98,\"wind_speed_kmh\":26.71,\"conditions\":\"Rain\",\"icon\":\"01d\"}', '2026-06-03 16:07:46'),
(71, 15, '2026-06-06', 'day_4', 25.96, 34.80, 76, 19.27, 19.87, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":25.96,\"temp_max\":34.8,\"humidity\":76,\"rainfall_mm\":19.27,\"wind_speed_kmh\":19.87,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:46'),
(72, 15, '2026-06-07', 'day_5', 25.23, 33.46, 84, 9.61, 22.43, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.23,\"temp_max\":33.46,\"humidity\":84,\"rainfall_mm\":9.61,\"wind_speed_kmh\":22.43,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:46'),
(73, 16, '2026-06-03', 'current', 30.39, 31.79, 61, 0.00, 21.53, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.39,\"temp_max\":31.79,\"humidity\":61,\"rainfall_mm\":0,\"wind_speed_kmh\":21.53,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:46'),
(74, 16, '2026-06-03', 'today', 30.74, 31.79, 66, 0.00, 21.53, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.74,\"temp_max\":31.79,\"humidity\":66,\"rainfall_mm\":0,\"wind_speed_kmh\":21.53,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:46'),
(75, 16, '2026-06-04', 'tomorrow', 27.42, 38.47, 68, 13.27, 28.15, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.42,\"temp_max\":38.47,\"humidity\":68,\"rainfall_mm\":13.27,\"wind_speed_kmh\":28.15,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:46'),
(76, 16, '2026-06-05', 'day_3', 25.77, 38.37, 72, 16.50, 28.87, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.77,\"temp_max\":38.37,\"humidity\":72,\"rainfall_mm\":16.5,\"wind_speed_kmh\":28.87,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:46'),
(77, 16, '2026-06-06', 'day_4', 26.84, 37.90, 69, 17.96, 28.12, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.84,\"temp_max\":37.9,\"humidity\":69,\"rainfall_mm\":17.96,\"wind_speed_kmh\":28.12,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:46'),
(78, 16, '2026-06-07', 'day_5', 25.09, 35.19, 78, 76.65, 24.34, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.09,\"temp_max\":35.19,\"humidity\":78,\"rainfall_mm\":76.65,\"wind_speed_kmh\":24.34,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:46'),
(79, 17, '2026-06-03', 'current', 27.55, 28.31, 84, 0.00, 9.79, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":27.55,\"temp_max\":28.31,\"humidity\":84,\"rainfall_mm\":0,\"wind_speed_kmh\":9.79,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:47'),
(80, 17, '2026-06-03', 'today', 27.67, 28.31, 87, 0.00, 9.79, 'Clouds', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":27.67,\"temp_max\":28.31,\"humidity\":87,\"rainfall_mm\":0,\"wind_speed_kmh\":9.79,\"conditions\":\"Clouds\",\"icon\":\"01n\"}', '2026-06-03 16:07:47'),
(81, 17, '2026-06-04', 'tomorrow', 27.65, 34.14, 75, 9.00, 19.80, 'Rain', '01d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.65,\"temp_max\":34.14,\"humidity\":75,\"rainfall_mm\":9,\"wind_speed_kmh\":19.8,\"conditions\":\"Rain\",\"icon\":\"01d\"}', '2026-06-03 16:07:47'),
(82, 17, '2026-06-05', 'day_3', 27.82, 34.24, 80, 8.21, 21.24, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":27.82,\"temp_max\":34.24,\"humidity\":80,\"rainfall_mm\":8.21,\"wind_speed_kmh\":21.24,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:47'),
(83, 17, '2026-06-06', 'day_4', 27.15, 33.62, 80, 1.43, 29.52, 'Rain', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":27.15,\"temp_max\":33.62,\"humidity\":80,\"rainfall_mm\":1.43,\"wind_speed_kmh\":29.52,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-03 16:07:47'),
(84, 17, '2026-06-07', 'day_5', 23.25, 28.77, 90, 94.32, 26.57, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":23.25,\"temp_max\":28.77,\"humidity\":90,\"rainfall_mm\":94.32,\"wind_speed_kmh\":26.57,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:47'),
(85, 18, '2026-06-03', 'current', 29.52, 29.83, 70, 0.00, 20.09, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.52,\"temp_max\":29.83,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":20.09,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:47'),
(86, 18, '2026-06-03', 'today', 28.71, 29.83, 73, 0.00, 20.09, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":28.71,\"temp_max\":29.83,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":20.09,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:47'),
(87, 18, '2026-06-04', 'tomorrow', 24.48, 36.19, 76, 9.92, 20.09, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.48,\"temp_max\":36.19,\"humidity\":76,\"rainfall_mm\":9.92,\"wind_speed_kmh\":20.09,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:47'),
(88, 18, '2026-06-05', 'day_3', 24.81, 35.25, 77, 9.54, 27.29, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":24.81,\"temp_max\":35.25,\"humidity\":77,\"rainfall_mm\":9.54,\"wind_speed_kmh\":27.29,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:47'),
(89, 18, '2026-06-06', 'day_4', 25.72, 34.85, 80, 18.32, 17.32, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":25.72,\"temp_max\":34.85,\"humidity\":80,\"rainfall_mm\":18.32,\"wind_speed_kmh\":17.32,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:47'),
(90, 18, '2026-06-07', 'day_5', 25.05, 28.09, 92, 15.00, 26.93, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.05,\"temp_max\":28.09,\"humidity\":92,\"rainfall_mm\":15,\"wind_speed_kmh\":26.93,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:47'),
(91, 19, '2026-06-03', 'current', 30.14, 30.28, 67, 0.00, 19.58, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.14,\"temp_max\":30.28,\"humidity\":67,\"rainfall_mm\":0,\"wind_speed_kmh\":19.58,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:07:47'),
(92, 19, '2026-06-03', 'today', 29.55, 30.28, 69, 0.00, 19.58, 'Clear', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.55,\"temp_max\":30.28,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":19.58,\"conditions\":\"Clear\",\"icon\":\"04n\"}', '2026-06-03 16:07:47'),
(93, 19, '2026-06-04', 'tomorrow', 23.85, 37.22, 72, 72.37, 22.90, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":23.85,\"temp_max\":37.22,\"humidity\":72,\"rainfall_mm\":72.37,\"wind_speed_kmh\":22.9,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:47'),
(94, 19, '2026-06-05', 'day_3', 25.78, 35.52, 78, 12.02, 31.32, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.78,\"temp_max\":35.52,\"humidity\":78,\"rainfall_mm\":12.02,\"wind_speed_kmh\":31.32,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:47'),
(95, 19, '2026-06-06', 'day_4', 25.17, 36.01, 76, 23.16, 26.50, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":25.17,\"temp_max\":36.01,\"humidity\":76,\"rainfall_mm\":23.16,\"wind_speed_kmh\":26.5,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:47'),
(96, 19, '2026-06-07', 'day_5', 24.94, 30.61, 89, 43.98, 28.19, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.94,\"temp_max\":30.61,\"humidity\":89,\"rainfall_mm\":43.98,\"wind_speed_kmh\":28.19,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:47'),
(97, 20, '2026-06-03', 'current', 30.31, 31.82, 59, 0.00, 21.38, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.31,\"temp_max\":31.82,\"humidity\":59,\"rainfall_mm\":0,\"wind_speed_kmh\":21.38,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:48'),
(98, 20, '2026-06-03', 'today', 30.65, 31.82, 64, 0.00, 21.38, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.65,\"temp_max\":31.82,\"humidity\":64,\"rainfall_mm\":0,\"wind_speed_kmh\":21.38,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:48'),
(99, 20, '2026-06-04', 'tomorrow', 28.07, 39.53, 65, 11.65, 26.68, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.07,\"temp_max\":39.53,\"humidity\":65,\"rainfall_mm\":11.65,\"wind_speed_kmh\":26.68,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:48'),
(100, 20, '2026-06-05', 'day_3', 26.73, 40.81, 71, 14.40, 17.93, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.73,\"temp_max\":40.81,\"humidity\":71,\"rainfall_mm\":14.4,\"wind_speed_kmh\":17.93,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:48'),
(101, 20, '2026-06-06', 'day_4', 26.68, 39.70, 66, 15.14, 28.84, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.68,\"temp_max\":39.7,\"humidity\":66,\"rainfall_mm\":15.14,\"wind_speed_kmh\":28.84,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:48'),
(102, 20, '2026-06-07', 'day_5', 25.24, 36.91, 74, 96.92, 21.02, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.24,\"temp_max\":36.91,\"humidity\":74,\"rainfall_mm\":96.92,\"wind_speed_kmh\":21.02,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:48'),
(103, 21, '2026-06-03', 'current', 26.95, 28.18, 74, 0.00, 8.46, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":26.95,\"temp_max\":28.18,\"humidity\":74,\"rainfall_mm\":0,\"wind_speed_kmh\":8.46,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:48'),
(104, 21, '2026-06-03', 'today', 26.73, 28.18, 78, 2.72, 8.46, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":26.73,\"temp_max\":28.18,\"humidity\":78,\"rainfall_mm\":2.72,\"wind_speed_kmh\":8.46,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-03 16:07:48'),
(105, 21, '2026-06-04', 'tomorrow', 24.42, 34.63, 78, 17.22, 17.39, 'Rain', '03d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.42,\"temp_max\":34.63,\"humidity\":78,\"rainfall_mm\":17.22,\"wind_speed_kmh\":17.39,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-03 16:07:48'),
(106, 21, '2026-06-05', 'day_3', 25.10, 33.79, 81, 14.06, 13.57, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.1,\"temp_max\":33.79,\"humidity\":81,\"rainfall_mm\":14.06,\"wind_speed_kmh\":13.57,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:48'),
(107, 21, '2026-06-06', 'day_4', 24.90, 32.42, 90, 104.14, 13.28, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":24.9,\"temp_max\":32.42,\"humidity\":90,\"rainfall_mm\":104.14,\"wind_speed_kmh\":13.28,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:48'),
(108, 21, '2026-06-07', 'day_5', 24.15, 30.20, 88, 14.79, 12.64, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.15,\"temp_max\":30.2,\"humidity\":88,\"rainfall_mm\":14.79,\"wind_speed_kmh\":12.64,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:48'),
(109, 22, '2026-06-03', 'current', 30.38, 31.01, 65, 0.00, 14.58, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.38,\"temp_max\":31.01,\"humidity\":65,\"rainfall_mm\":0,\"wind_speed_kmh\":14.58,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:49'),
(110, 22, '2026-06-03', 'today', 30.23, 31.01, 67, 0.00, 16.16, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.23,\"temp_max\":31.01,\"humidity\":67,\"rainfall_mm\":0,\"wind_speed_kmh\":16.16,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:49'),
(111, 22, '2026-06-04', 'tomorrow', 25.47, 35.96, 73, 11.02, 23.40, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.47,\"temp_max\":35.96,\"humidity\":73,\"rainfall_mm\":11.02,\"wind_speed_kmh\":23.4,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:49'),
(112, 22, '2026-06-05', 'day_3', 25.44, 35.80, 78, 33.24, 30.71, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.44,\"temp_max\":35.8,\"humidity\":78,\"rainfall_mm\":33.24,\"wind_speed_kmh\":30.71,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:49'),
(113, 22, '2026-06-06', 'day_4', 25.47, 36.42, 77, 20.71, 22.14, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":25.47,\"temp_max\":36.42,\"humidity\":77,\"rainfall_mm\":20.71,\"wind_speed_kmh\":22.14,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:49'),
(114, 22, '2026-06-07', 'day_5', 25.46, 30.78, 88, 22.58, 26.06, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.46,\"temp_max\":30.78,\"humidity\":88,\"rainfall_mm\":22.58,\"wind_speed_kmh\":26.06,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:49'),
(115, 24, '2026-06-03', 'current', 29.71, 30.18, 73, 0.00, 14.65, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.71,\"temp_max\":30.18,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":14.65,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:49'),
(116, 24, '2026-06-03', 'today', 29.55, 30.18, 76, 0.00, 14.65, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.55,\"temp_max\":30.18,\"humidity\":76,\"rainfall_mm\":0,\"wind_speed_kmh\":14.65,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:49'),
(117, 24, '2026-06-04', 'tomorrow', 29.32, 37.43, 65, 2.33, 21.67, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.32,\"temp_max\":37.43,\"humidity\":65,\"rainfall_mm\":2.33,\"wind_speed_kmh\":21.67,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:49'),
(118, 24, '2026-06-05', 'day_3', 29.96, 37.88, 64, 0.00, 26.93, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":29.96,\"temp_max\":37.88,\"humidity\":64,\"rainfall_mm\":0,\"wind_speed_kmh\":26.93,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:49'),
(119, 24, '2026-06-06', 'day_4', 30.03, 37.81, 67, 0.25, 29.66, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":30.03,\"temp_max\":37.81,\"humidity\":67,\"rainfall_mm\":0.25,\"wind_speed_kmh\":29.66,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:49'),
(120, 24, '2026-06-07', 'day_5', 27.93, 34.75, 72, 3.24, 25.52, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":27.93,\"temp_max\":34.75,\"humidity\":72,\"rainfall_mm\":3.24,\"wind_speed_kmh\":25.52,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:49'),
(121, 25, '2026-06-03', 'current', 30.95, 32.36, 60, 0.00, 20.81, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.95,\"temp_max\":32.36,\"humidity\":60,\"rainfall_mm\":0,\"wind_speed_kmh\":20.81,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:50'),
(122, 25, '2026-06-03', 'today', 31.00, 32.36, 65, 0.00, 20.81, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":31,\"temp_max\":32.36,\"humidity\":65,\"rainfall_mm\":0,\"wind_speed_kmh\":20.81,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:50'),
(123, 25, '2026-06-04', 'tomorrow', 27.64, 40.72, 63, 6.14, 32.54, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.64,\"temp_max\":40.72,\"humidity\":63,\"rainfall_mm\":6.14,\"wind_speed_kmh\":32.54,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:50'),
(124, 25, '2026-06-05', 'day_3', 25.35, 41.09, 66, 10.11, 24.44, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.35,\"temp_max\":41.09,\"humidity\":66,\"rainfall_mm\":10.11,\"wind_speed_kmh\":24.44,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:50'),
(125, 25, '2026-06-06', 'day_4', 28.05, 41.84, 68, 10.52, 30.78, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":28.05,\"temp_max\":41.84,\"humidity\":68,\"rainfall_mm\":10.52,\"wind_speed_kmh\":30.78,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:50'),
(126, 25, '2026-06-07', 'day_5', 30.02, 41.41, 64, 3.76, 26.96, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":30.02,\"temp_max\":41.41,\"humidity\":64,\"rainfall_mm\":3.76,\"wind_speed_kmh\":26.96,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:50'),
(127, 26, '2026-06-03', 'current', 31.53, 32.58, 55, 0.00, 18.47, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":31.53,\"temp_max\":32.58,\"humidity\":55,\"rainfall_mm\":0,\"wind_speed_kmh\":18.47,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:50'),
(128, 26, '2026-06-03', 'today', 31.27, 32.58, 58, 0.00, 18.47, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":31.27,\"temp_max\":32.58,\"humidity\":58,\"rainfall_mm\":0,\"wind_speed_kmh\":18.47,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:50'),
(129, 26, '2026-06-04', 'tomorrow', 26.47, 39.09, 67, 5.31, 24.73, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.47,\"temp_max\":39.09,\"humidity\":67,\"rainfall_mm\":5.31,\"wind_speed_kmh\":24.73,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:50'),
(130, 26, '2026-06-05', 'day_3', 26.08, 37.50, 74, 23.82, 32.51, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.08,\"temp_max\":37.5,\"humidity\":74,\"rainfall_mm\":23.82,\"wind_speed_kmh\":32.51,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:50'),
(131, 26, '2026-06-06', 'day_4', 23.45, 37.09, 75, 35.88, 18.65, 'Rain', '02d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":23.45,\"temp_max\":37.09,\"humidity\":75,\"rainfall_mm\":35.88,\"wind_speed_kmh\":18.65,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-03 16:07:50'),
(132, 26, '2026-06-07', 'day_5', 25.66, 35.65, 81, 21.26, 28.08, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.66,\"temp_max\":35.65,\"humidity\":81,\"rainfall_mm\":21.26,\"wind_speed_kmh\":28.08,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:50'),
(133, 27, '2026-06-03', 'current', 24.99, 25.64, 82, 0.00, 4.93, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":24.99,\"temp_max\":25.64,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":4.93,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:07:50'),
(134, 27, '2026-06-03', 'today', 24.97, 25.64, 86, 0.00, 4.93, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":24.97,\"temp_max\":25.64,\"humidity\":86,\"rainfall_mm\":0,\"wind_speed_kmh\":4.93,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:07:50'),
(135, 27, '2026-06-04', 'tomorrow', 25.05, 37.00, 75, 3.58, 8.17, 'Rain', '03d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.05,\"temp_max\":37,\"humidity\":75,\"rainfall_mm\":3.58,\"wind_speed_kmh\":8.17,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-03 16:07:50'),
(136, 27, '2026-06-05', 'day_3', 25.15, 31.70, 85, 11.50, 9.25, 'Rain', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.15,\"temp_max\":31.7,\"humidity\":85,\"rainfall_mm\":11.5,\"wind_speed_kmh\":9.25,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:50'),
(137, 27, '2026-06-06', 'day_4', 24.64, 33.15, 81, 9.73, 11.74, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":24.64,\"temp_max\":33.15,\"humidity\":81,\"rainfall_mm\":9.73,\"wind_speed_kmh\":11.74,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:50'),
(138, 27, '2026-06-07', 'day_5', 22.27, 27.41, 93, 100.66, 8.82, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":22.27,\"temp_max\":27.41,\"humidity\":93,\"rainfall_mm\":100.66,\"wind_speed_kmh\":8.82,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:50'),
(139, 28, '2026-06-03', 'current', 30.04, 31.17, 65, 0.00, 19.51, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.04,\"temp_max\":31.17,\"humidity\":65,\"rainfall_mm\":0,\"wind_speed_kmh\":19.51,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:51'),
(140, 28, '2026-06-03', 'today', 30.29, 31.17, 69, 0.00, 19.51, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.29,\"temp_max\":31.17,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":19.51,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:51'),
(141, 28, '2026-06-04', 'tomorrow', 27.81, 40.55, 66, 13.44, 30.42, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.81,\"temp_max\":40.55,\"humidity\":66,\"rainfall_mm\":13.44,\"wind_speed_kmh\":30.42,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:51'),
(142, 28, '2026-06-05', 'day_3', 29.30, 39.33, 66, 6.97, 23.26, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":29.3,\"temp_max\":39.33,\"humidity\":66,\"rainfall_mm\":6.97,\"wind_speed_kmh\":23.26,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:51'),
(143, 28, '2026-06-06', 'day_4', 29.68, 39.99, 65, 1.88, 29.70, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":29.68,\"temp_max\":39.99,\"humidity\":65,\"rainfall_mm\":1.88,\"wind_speed_kmh\":29.7,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:51'),
(144, 28, '2026-06-07', 'day_5', 28.61, 40.87, 66, 2.60, 28.73, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":28.61,\"temp_max\":40.87,\"humidity\":66,\"rainfall_mm\":2.6,\"wind_speed_kmh\":28.73,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:51'),
(145, 29, '2026-06-03', 'current', 29.10, 29.73, 70, 0.00, 13.54, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.1,\"temp_max\":29.73,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":13.54,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:51'),
(146, 29, '2026-06-03', 'today', 28.76, 29.73, 73, 0.26, 13.54, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":28.76,\"temp_max\":29.73,\"humidity\":73,\"rainfall_mm\":0.26,\"wind_speed_kmh\":13.54,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-03 16:07:51'),
(147, 29, '2026-06-04', 'tomorrow', 24.41, 36.40, 76, 52.69, 30.10, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.41,\"temp_max\":36.4,\"humidity\":76,\"rainfall_mm\":52.69,\"wind_speed_kmh\":30.1,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:51'),
(148, 29, '2026-06-05', 'day_3', 25.28, 35.74, 79, 10.75, 20.45, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.28,\"temp_max\":35.74,\"humidity\":79,\"rainfall_mm\":10.75,\"wind_speed_kmh\":20.45,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:51'),
(149, 29, '2026-06-06', 'day_4', 24.74, 34.74, 80, 27.48, 23.80, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":24.74,\"temp_max\":34.74,\"humidity\":80,\"rainfall_mm\":27.48,\"wind_speed_kmh\":23.8,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:51'),
(150, 29, '2026-06-07', 'day_5', 24.94, 30.24, 92, 29.26, 25.96, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.94,\"temp_max\":30.24,\"humidity\":92,\"rainfall_mm\":29.26,\"wind_speed_kmh\":25.96,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:51'),
(151, 30, '2026-06-03', 'current', 29.23, 29.46, 72, 0.00, 25.70, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.23,\"temp_max\":29.46,\"humidity\":72,\"rainfall_mm\":0,\"wind_speed_kmh\":25.7,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:51'),
(152, 30, '2026-06-03', 'today', 28.08, 29.23, 76, 0.49, 25.70, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":28.08,\"temp_max\":29.23,\"humidity\":76,\"rainfall_mm\":0.49,\"wind_speed_kmh\":25.7,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-03 16:07:51'),
(153, 30, '2026-06-04', 'tomorrow', 25.06, 34.64, 81, 51.04, 29.56, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.06,\"temp_max\":34.64,\"humidity\":81,\"rainfall_mm\":51.04,\"wind_speed_kmh\":29.56,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:51'),
(154, 30, '2026-06-05', 'day_3', 24.94, 32.56, 80, 9.08, 29.99, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":24.94,\"temp_max\":32.56,\"humidity\":80,\"rainfall_mm\":9.08,\"wind_speed_kmh\":29.99,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:51'),
(155, 30, '2026-06-06', 'day_4', 25.84, 33.07, 83, 20.19, 21.31, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":25.84,\"temp_max\":33.07,\"humidity\":83,\"rainfall_mm\":20.19,\"wind_speed_kmh\":21.31,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:51'),
(156, 30, '2026-06-07', 'day_5', 25.72, 28.23, 89, 9.63, 27.94, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.72,\"temp_max\":28.23,\"humidity\":89,\"rainfall_mm\":9.63,\"wind_speed_kmh\":27.94,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:51'),
(157, 31, '2026-06-03', 'current', 31.51, 32.65, 54, 0.23, 20.23, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":31.51,\"temp_max\":32.65,\"humidity\":54,\"rainfall_mm\":0.23,\"wind_speed_kmh\":20.23,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:52'),
(158, 31, '2026-06-03', 'today', 31.24, 32.65, 60, 0.37, 20.23, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":31.24,\"temp_max\":32.65,\"humidity\":60,\"rainfall_mm\":0.37,\"wind_speed_kmh\":20.23,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:52'),
(159, 31, '2026-06-04', 'tomorrow', 28.28, 41.11, 60, 10.64, 30.74, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.28,\"temp_max\":41.11,\"humidity\":60,\"rainfall_mm\":10.64,\"wind_speed_kmh\":30.74,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:52'),
(160, 31, '2026-06-05', 'day_3', 27.78, 41.80, 63, 6.38, 27.79, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":27.78,\"temp_max\":41.8,\"humidity\":63,\"rainfall_mm\":6.38,\"wind_speed_kmh\":27.79,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:52');
INSERT INTO `weather_forecasts` (`forecast_id`, `district_id`, `forecast_date`, `forecast_for`, `temp_min`, `temp_max`, `humidity`, `rainfall_mm`, `wind_speed_kmh`, `conditions`, `icon`, `raw_payload`, `fetched_at`) VALUES
(161, 31, '2026-06-06', 'day_4', 28.06, 42.11, 61, 13.65, 22.39, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":28.06,\"temp_max\":42.11,\"humidity\":61,\"rainfall_mm\":13.65,\"wind_speed_kmh\":22.39,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:52'),
(162, 31, '2026-06-07', 'day_5', 29.01, 37.97, 69, 0.84, 33.73, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":29.01,\"temp_max\":37.97,\"humidity\":69,\"rainfall_mm\":0.84,\"wind_speed_kmh\":33.73,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:52'),
(163, 32, '2026-06-03', 'current', 29.70, 30.02, 76, 0.11, 15.44, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.7,\"temp_max\":30.02,\"humidity\":76,\"rainfall_mm\":0.11,\"wind_speed_kmh\":15.44,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:52'),
(164, 32, '2026-06-03', 'today', 29.45, 30.02, 78, 0.32, 15.44, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.45,\"temp_max\":30.02,\"humidity\":78,\"rainfall_mm\":0.32,\"wind_speed_kmh\":15.44,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:52'),
(165, 32, '2026-06-04', 'tomorrow', 29.17, 35.01, 70, 1.31, 26.06, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.17,\"temp_max\":35.01,\"humidity\":70,\"rainfall_mm\":1.31,\"wind_speed_kmh\":26.06,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-03 16:07:52'),
(166, 32, '2026-06-05', 'day_3', 29.75, 34.89, 73, 1.09, 29.41, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":29.75,\"temp_max\":34.89,\"humidity\":73,\"rainfall_mm\":1.09,\"wind_speed_kmh\":29.41,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:52'),
(167, 32, '2026-06-06', 'day_4', 29.82, 33.97, 74, 0.36, 31.57, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":29.82,\"temp_max\":33.97,\"humidity\":74,\"rainfall_mm\":0.36,\"wind_speed_kmh\":31.57,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:52'),
(168, 32, '2026-06-07', 'day_5', 25.19, 32.26, 81, 19.80, 27.58, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.19,\"temp_max\":32.26,\"humidity\":81,\"rainfall_mm\":19.8,\"wind_speed_kmh\":27.58,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:52'),
(169, 33, '2026-06-03', 'current', 28.94, 29.57, 70, 0.15, 20.56, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":28.94,\"temp_max\":29.57,\"humidity\":70,\"rainfall_mm\":0.15,\"wind_speed_kmh\":20.56,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:52'),
(170, 33, '2026-06-03', 'today', 27.07, 28.94, 76, 1.99, 20.56, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":27.07,\"temp_max\":28.94,\"humidity\":76,\"rainfall_mm\":1.99,\"wind_speed_kmh\":20.56,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:52'),
(171, 33, '2026-06-04', 'tomorrow', 24.86, 35.35, 79, 33.74, 24.98, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.86,\"temp_max\":35.35,\"humidity\":79,\"rainfall_mm\":33.74,\"wind_speed_kmh\":24.98,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:52'),
(172, 33, '2026-06-05', 'day_3', 24.84, 33.02, 79, 9.65, 18.94, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":24.84,\"temp_max\":33.02,\"humidity\":79,\"rainfall_mm\":9.65,\"wind_speed_kmh\":18.94,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:52'),
(173, 33, '2026-06-06', 'day_4', 25.39, 32.54, 84, 18.36, 18.22, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":25.39,\"temp_max\":32.54,\"humidity\":84,\"rainfall_mm\":18.36,\"wind_speed_kmh\":18.22,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:52'),
(174, 33, '2026-06-07', 'day_5', 25.72, 30.10, 87, 2.49, 20.23, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.72,\"temp_max\":30.1,\"humidity\":87,\"rainfall_mm\":2.49,\"wind_speed_kmh\":20.23,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:52'),
(175, 34, '2026-06-03', 'current', 29.66, 30.73, 68, 0.00, 18.90, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.66,\"temp_max\":30.73,\"humidity\":68,\"rainfall_mm\":0,\"wind_speed_kmh\":18.9,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:53'),
(176, 34, '2026-06-03', 'today', 29.79, 30.73, 71, 0.00, 18.90, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.79,\"temp_max\":30.73,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":18.9,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:53'),
(177, 34, '2026-06-04', 'tomorrow', 26.23, 38.50, 70, 5.91, 30.82, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.23,\"temp_max\":38.5,\"humidity\":70,\"rainfall_mm\":5.91,\"wind_speed_kmh\":30.82,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:53'),
(178, 34, '2026-06-05', 'day_3', 25.02, 38.25, 74, 37.72, 31.75, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.02,\"temp_max\":38.25,\"humidity\":74,\"rainfall_mm\":37.72,\"wind_speed_kmh\":31.75,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:53'),
(179, 34, '2026-06-06', 'day_4', 26.07, 37.15, 73, 5.54, 29.05, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.07,\"temp_max\":37.15,\"humidity\":73,\"rainfall_mm\":5.54,\"wind_speed_kmh\":29.05,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:53'),
(180, 34, '2026-06-07', 'day_5', 24.77, 35.22, 80, 85.50, 30.10, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.77,\"temp_max\":35.22,\"humidity\":80,\"rainfall_mm\":85.5,\"wind_speed_kmh\":30.1,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:53'),
(181, 35, '2026-06-03', 'current', 30.90, 32.67, 58, 0.00, 20.09, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.9,\"temp_max\":32.67,\"humidity\":58,\"rainfall_mm\":0,\"wind_speed_kmh\":20.09,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:53'),
(182, 35, '2026-06-03', 'today', 31.18, 32.67, 64, 0.00, 20.09, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":31.18,\"temp_max\":32.67,\"humidity\":64,\"rainfall_mm\":0,\"wind_speed_kmh\":20.09,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:53'),
(183, 35, '2026-06-04', 'tomorrow', 27.84, 40.32, 64, 8.72, 36.40, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.84,\"temp_max\":40.32,\"humidity\":64,\"rainfall_mm\":8.72,\"wind_speed_kmh\":36.4,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:53'),
(184, 35, '2026-06-05', 'day_3', 27.10, 41.27, 64, 9.89, 32.80, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":27.1,\"temp_max\":41.27,\"humidity\":64,\"rainfall_mm\":9.89,\"wind_speed_kmh\":32.8,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:53'),
(185, 35, '2026-06-06', 'day_4', 26.84, 42.01, 67, 9.89, 37.37, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.84,\"temp_max\":42.01,\"humidity\":67,\"rainfall_mm\":9.89,\"wind_speed_kmh\":37.37,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:53'),
(186, 35, '2026-06-07', 'day_5', 27.06, 39.63, 68, 15.40, 25.34, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":27.06,\"temp_max\":39.63,\"humidity\":68,\"rainfall_mm\":15.4,\"wind_speed_kmh\":25.34,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:53'),
(187, 36, '2026-06-03', 'current', 30.55, 30.90, 67, 0.10, 23.40, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.55,\"temp_max\":30.9,\"humidity\":67,\"rainfall_mm\":0.1,\"wind_speed_kmh\":23.4,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:53'),
(188, 36, '2026-06-03', 'today', 29.93, 30.90, 70, 0.10, 23.40, 'Rain', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.93,\"temp_max\":30.9,\"humidity\":70,\"rainfall_mm\":0.1,\"wind_speed_kmh\":23.4,\"conditions\":\"Rain\",\"icon\":\"02n\"}', '2026-06-03 16:07:53'),
(189, 36, '2026-06-04', 'tomorrow', 24.92, 38.46, 71, 60.77, 21.78, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.92,\"temp_max\":38.46,\"humidity\":71,\"rainfall_mm\":60.77,\"wind_speed_kmh\":21.78,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:53'),
(190, 36, '2026-06-05', 'day_3', 26.83, 38.22, 73, 7.62, 36.86, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.83,\"temp_max\":38.22,\"humidity\":73,\"rainfall_mm\":7.62,\"wind_speed_kmh\":36.86,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:53'),
(191, 36, '2026-06-06', 'day_4', 26.14, 38.06, 72, 14.21, 33.05, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.14,\"temp_max\":38.06,\"humidity\":72,\"rainfall_mm\":14.21,\"wind_speed_kmh\":33.05,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:53'),
(192, 36, '2026-06-07', 'day_5', 24.97, 33.76, 80, 18.22, 27.32, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.97,\"temp_max\":33.76,\"humidity\":80,\"rainfall_mm\":18.22,\"wind_speed_kmh\":27.32,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:53'),
(193, 37, '2026-06-03', 'current', 31.28, 33.02, 51, 1.61, 16.56, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":31.28,\"temp_max\":33.02,\"humidity\":51,\"rainfall_mm\":1.61,\"wind_speed_kmh\":16.56,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:54'),
(194, 37, '2026-06-03', 'today', 31.30, 33.02, 58, 1.84, 17.71, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":31.3,\"temp_max\":33.02,\"humidity\":58,\"rainfall_mm\":1.84,\"wind_speed_kmh\":17.71,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:54'),
(195, 37, '2026-06-04', 'tomorrow', 27.90, 40.68, 59, 1.18, 35.03, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.9,\"temp_max\":40.68,\"humidity\":59,\"rainfall_mm\":1.18,\"wind_speed_kmh\":35.03,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:54'),
(196, 37, '2026-06-05', 'day_3', 27.00, 42.12, 64, 12.82, 31.97, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":27,\"temp_max\":42.12,\"humidity\":64,\"rainfall_mm\":12.82,\"wind_speed_kmh\":31.97,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:54'),
(197, 37, '2026-06-06', 'day_4', 28.28, 41.71, 63, 11.71, 21.38, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":28.28,\"temp_max\":41.71,\"humidity\":63,\"rainfall_mm\":11.71,\"wind_speed_kmh\":21.38,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:54'),
(198, 37, '2026-06-07', 'day_5', 26.23, 36.93, 72, 8.17, 25.45, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":26.23,\"temp_max\":36.93,\"humidity\":72,\"rainfall_mm\":8.17,\"wind_speed_kmh\":25.45,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:54'),
(199, 38, '2026-06-03', 'current', 27.12, 28.32, 73, 0.00, 8.64, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":27.12,\"temp_max\":28.32,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":8.64,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:54'),
(200, 38, '2026-06-03', 'today', 26.87, 28.32, 78, 2.91, 8.64, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":26.87,\"temp_max\":28.32,\"humidity\":78,\"rainfall_mm\":2.91,\"wind_speed_kmh\":8.64,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-03 16:07:54'),
(201, 38, '2026-06-04', 'tomorrow', 24.54, 34.64, 77, 18.49, 17.89, 'Rain', '03d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.54,\"temp_max\":34.64,\"humidity\":77,\"rainfall_mm\":18.49,\"wind_speed_kmh\":17.89,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-03 16:07:54'),
(202, 38, '2026-06-05', 'day_3', 25.21, 33.85, 81, 14.25, 13.82, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.21,\"temp_max\":33.85,\"humidity\":81,\"rainfall_mm\":14.25,\"wind_speed_kmh\":13.82,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:54'),
(203, 38, '2026-06-06', 'day_4', 24.92, 32.54, 90, 107.80, 13.82, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":24.92,\"temp_max\":32.54,\"humidity\":90,\"rainfall_mm\":107.8,\"wind_speed_kmh\":13.82,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:54'),
(204, 38, '2026-06-07', 'day_5', 24.32, 30.22, 88, 15.67, 12.92, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.32,\"temp_max\":30.22,\"humidity\":88,\"rainfall_mm\":15.67,\"wind_speed_kmh\":12.92,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:54'),
(205, 39, '2026-06-03', 'current', 30.25, 30.42, 69, 0.00, 17.10, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.25,\"temp_max\":30.42,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":17.1,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:54'),
(206, 39, '2026-06-03', 'today', 29.74, 30.42, 71, 0.00, 17.10, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.74,\"temp_max\":30.42,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":17.1,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:54'),
(207, 39, '2026-06-04', 'tomorrow', 26.04, 37.57, 66, 1.04, 29.88, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.04,\"temp_max\":37.57,\"humidity\":66,\"rainfall_mm\":1.04,\"wind_speed_kmh\":29.88,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:54'),
(208, 39, '2026-06-05', 'day_3', 26.32, 37.54, 71, 11.76, 29.34, 'Rain', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.32,\"temp_max\":37.54,\"humidity\":71,\"rainfall_mm\":11.76,\"wind_speed_kmh\":29.34,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:54'),
(209, 39, '2026-06-06', 'day_4', 26.66, 36.89, 72, 11.32, 29.05, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.66,\"temp_max\":36.89,\"humidity\":72,\"rainfall_mm\":11.32,\"wind_speed_kmh\":29.05,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:54'),
(210, 39, '2026-06-07', 'day_5', 24.03, 33.22, 83, 140.17, 28.51, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.03,\"temp_max\":33.22,\"humidity\":83,\"rainfall_mm\":140.17,\"wind_speed_kmh\":28.51,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:54'),
(211, 40, '2026-06-03', 'current', 27.80, 29.00, 75, 1.48, 6.23, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":27.8,\"temp_max\":29,\"humidity\":75,\"rainfall_mm\":1.48,\"wind_speed_kmh\":6.23,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:55'),
(212, 40, '2026-06-03', 'today', 27.36, 29.00, 80, 3.27, 9.90, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":27.36,\"temp_max\":29,\"humidity\":80,\"rainfall_mm\":3.27,\"wind_speed_kmh\":9.9,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:55'),
(213, 40, '2026-06-04', 'tomorrow', 24.88, 35.44, 78, 12.53, 24.59, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.88,\"temp_max\":35.44,\"humidity\":78,\"rainfall_mm\":12.53,\"wind_speed_kmh\":24.59,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:55'),
(214, 40, '2026-06-05', 'day_3', 25.21, 35.33, 79, 11.33, 32.15, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.21,\"temp_max\":35.33,\"humidity\":79,\"rainfall_mm\":11.33,\"wind_speed_kmh\":32.15,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:55'),
(215, 40, '2026-06-06', 'day_4', 24.10, 35.09, 82, 33.48, 20.23, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":24.1,\"temp_max\":35.09,\"humidity\":82,\"rainfall_mm\":33.48,\"wind_speed_kmh\":20.23,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:55'),
(216, 40, '2026-06-07', 'day_5', 24.66, 28.58, 92, 24.18, 25.74, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.66,\"temp_max\":28.58,\"humidity\":92,\"rainfall_mm\":24.18,\"wind_speed_kmh\":25.74,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:55'),
(217, 41, '2026-06-03', 'current', 31.70, 33.11, 49, 0.28, 14.65, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":31.7,\"temp_max\":33.11,\"humidity\":49,\"rainfall_mm\":0.28,\"wind_speed_kmh\":14.65,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:55'),
(218, 41, '2026-06-03', 'today', 31.92, 33.11, 54, 0.28, 19.22, 'Rain', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":31.92,\"temp_max\":33.11,\"humidity\":54,\"rainfall_mm\":0.28,\"wind_speed_kmh\":19.22,\"conditions\":\"Rain\",\"icon\":\"03n\"}', '2026-06-03 16:07:55'),
(219, 41, '2026-06-04', 'tomorrow', 27.88, 39.74, 62, 2.81, 27.40, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.88,\"temp_max\":39.74,\"humidity\":62,\"rainfall_mm\":2.81,\"wind_speed_kmh\":27.4,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:55'),
(220, 41, '2026-06-05', 'day_3', 27.11, 41.20, 65, 3.56, 21.53, 'Rain', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":27.11,\"temp_max\":41.2,\"humidity\":65,\"rainfall_mm\":3.56,\"wind_speed_kmh\":21.53,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-03 16:07:55'),
(221, 41, '2026-06-06', 'day_4', 27.18, 40.05, 64, 19.66, 18.79, 'Rain', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":27.18,\"temp_max\":40.05,\"humidity\":64,\"rainfall_mm\":19.66,\"wind_speed_kmh\":18.79,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-03 16:07:55'),
(222, 41, '2026-06-07', 'day_5', 25.76, 38.39, 75, 11.07, 38.77, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.76,\"temp_max\":38.39,\"humidity\":75,\"rainfall_mm\":11.07,\"wind_speed_kmh\":38.77,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:55'),
(223, 42, '2026-06-03', 'current', 30.48, 31.97, 59, 0.00, 21.82, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.48,\"temp_max\":31.97,\"humidity\":59,\"rainfall_mm\":0,\"wind_speed_kmh\":21.82,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:56'),
(224, 42, '2026-06-03', 'today', 30.65, 31.97, 65, 0.00, 21.82, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.65,\"temp_max\":31.97,\"humidity\":65,\"rainfall_mm\":0,\"wind_speed_kmh\":21.82,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:56'),
(225, 42, '2026-06-04', 'tomorrow', 27.75, 39.75, 64, 8.11, 27.79, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.75,\"temp_max\":39.75,\"humidity\":64,\"rainfall_mm\":8.11,\"wind_speed_kmh\":27.79,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:56'),
(226, 42, '2026-06-05', 'day_3', 27.40, 41.58, 68, 6.95, 19.12, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":27.4,\"temp_max\":41.58,\"humidity\":68,\"rainfall_mm\":6.95,\"wind_speed_kmh\":19.12,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:56'),
(227, 42, '2026-06-06', 'day_4', 26.76, 40.98, 65, 19.83, 29.38, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.76,\"temp_max\":40.98,\"humidity\":65,\"rainfall_mm\":19.83,\"wind_speed_kmh\":29.38,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:56'),
(228, 42, '2026-06-07', 'day_5', 25.46, 37.22, 73, 75.57, 21.85, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.46,\"temp_max\":37.22,\"humidity\":73,\"rainfall_mm\":75.57,\"wind_speed_kmh\":21.85,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:56'),
(229, 43, '2026-06-03', 'current', 30.49, 30.62, 68, 0.00, 17.28, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.49,\"temp_max\":30.62,\"humidity\":68,\"rainfall_mm\":0,\"wind_speed_kmh\":17.28,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:56'),
(230, 43, '2026-06-03', 'today', 30.04, 30.62, 70, 0.00, 17.28, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.04,\"temp_max\":30.62,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":17.28,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:07:56'),
(231, 43, '2026-06-04', 'tomorrow', 25.64, 37.64, 64, 1.43, 30.56, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.64,\"temp_max\":37.64,\"humidity\":64,\"rainfall_mm\":1.43,\"wind_speed_kmh\":30.56,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:56'),
(232, 43, '2026-06-05', 'day_3', 26.82, 37.59, 69, 9.42, 29.56, 'Rain', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.82,\"temp_max\":37.59,\"humidity\":69,\"rainfall_mm\":9.42,\"wind_speed_kmh\":29.56,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:56'),
(233, 43, '2026-06-06', 'day_4', 27.09, 36.99, 71, 11.03, 29.38, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":27.09,\"temp_max\":36.99,\"humidity\":71,\"rainfall_mm\":11.03,\"wind_speed_kmh\":29.38,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:56'),
(234, 43, '2026-06-07', 'day_5', 23.98, 32.86, 84, 158.61, 27.25, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":23.98,\"temp_max\":32.86,\"humidity\":84,\"rainfall_mm\":158.61,\"wind_speed_kmh\":27.25,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:56'),
(235, 44, '2026-06-03', 'current', 30.25, 30.42, 69, 0.00, 17.10, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.25,\"temp_max\":30.42,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":17.1,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:56'),
(236, 44, '2026-06-03', 'today', 29.74, 30.42, 71, 0.00, 17.10, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.74,\"temp_max\":30.42,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":17.1,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:56'),
(237, 44, '2026-06-04', 'tomorrow', 26.04, 37.57, 66, 1.04, 29.88, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.04,\"temp_max\":37.57,\"humidity\":66,\"rainfall_mm\":1.04,\"wind_speed_kmh\":29.88,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:56'),
(238, 44, '2026-06-05', 'day_3', 26.32, 37.54, 71, 11.76, 29.34, 'Rain', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.32,\"temp_max\":37.54,\"humidity\":71,\"rainfall_mm\":11.76,\"wind_speed_kmh\":29.34,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:56'),
(239, 44, '2026-06-06', 'day_4', 26.66, 36.89, 72, 11.32, 29.05, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.66,\"temp_max\":36.89,\"humidity\":72,\"rainfall_mm\":11.32,\"wind_speed_kmh\":29.05,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:56'),
(240, 44, '2026-06-07', 'day_5', 24.03, 33.22, 83, 140.17, 28.51, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.03,\"temp_max\":33.22,\"humidity\":83,\"rainfall_mm\":140.17,\"wind_speed_kmh\":28.51,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:56'),
(241, 45, '2026-06-03', 'current', 32.19, 33.14, 47, 0.14, 14.69, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":32.19,\"temp_max\":33.14,\"humidity\":47,\"rainfall_mm\":0.14,\"wind_speed_kmh\":14.69,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:57'),
(242, 45, '2026-06-03', 'today', 31.76, 33.14, 54, 0.14, 19.51, 'Rain', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":31.76,\"temp_max\":33.14,\"humidity\":54,\"rainfall_mm\":0.14,\"wind_speed_kmh\":19.51,\"conditions\":\"Rain\",\"icon\":\"01n\"}', '2026-06-03 16:07:57'),
(243, 45, '2026-06-04', 'tomorrow', 28.94, 40.23, 58, 0.94, 39.46, 'Clear', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.94,\"temp_max\":40.23,\"humidity\":58,\"rainfall_mm\":0.94,\"wind_speed_kmh\":39.46,\"conditions\":\"Clear\",\"icon\":\"10d\"}', '2026-06-03 16:07:57'),
(244, 45, '2026-06-05', 'day_3', 28.04, 41.05, 60, 2.08, 21.35, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":28.04,\"temp_max\":41.05,\"humidity\":60,\"rainfall_mm\":2.08,\"wind_speed_kmh\":21.35,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:57'),
(245, 45, '2026-06-06', 'day_4', 28.02, 41.03, 63, 29.39, 26.03, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":28.02,\"temp_max\":41.03,\"humidity\":63,\"rainfall_mm\":29.39,\"wind_speed_kmh\":26.03,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:57'),
(246, 45, '2026-06-07', 'day_5', 27.61, 40.14, 69, 2.70, 33.08, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":27.61,\"temp_max\":40.14,\"humidity\":69,\"rainfall_mm\":2.7,\"wind_speed_kmh\":33.08,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:57'),
(247, 46, '2026-06-03', 'current', 27.64, 28.65, 76, 1.50, 4.57, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":27.64,\"temp_max\":28.65,\"humidity\":76,\"rainfall_mm\":1.5,\"wind_speed_kmh\":4.57,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:57'),
(248, 46, '2026-06-03', 'today', 26.89, 28.65, 81, 4.21, 11.52, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":26.89,\"temp_max\":28.65,\"humidity\":81,\"rainfall_mm\":4.21,\"wind_speed_kmh\":11.52,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:57'),
(249, 46, '2026-06-04', 'tomorrow', 25.16, 34.52, 79, 20.65, 18.68, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.16,\"temp_max\":34.52,\"humidity\":79,\"rainfall_mm\":20.65,\"wind_speed_kmh\":18.68,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:57'),
(250, 46, '2026-06-05', 'day_3', 24.40, 34.69, 79, 13.55, 28.33, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":24.4,\"temp_max\":34.69,\"humidity\":79,\"rainfall_mm\":13.55,\"wind_speed_kmh\":28.33,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:57'),
(251, 46, '2026-06-06', 'day_4', 24.55, 34.06, 85, 54.74, 24.59, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":24.55,\"temp_max\":34.06,\"humidity\":85,\"rainfall_mm\":54.74,\"wind_speed_kmh\":24.59,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:57'),
(252, 46, '2026-06-07', 'day_5', 24.79, 28.20, 91, 18.40, 20.99, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.79,\"temp_max\":28.2,\"humidity\":91,\"rainfall_mm\":18.4,\"wind_speed_kmh\":20.99,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:57'),
(253, 47, '2026-06-03', 'current', 29.71, 30.00, 66, 0.00, 17.60, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.71,\"temp_max\":30,\"humidity\":66,\"rainfall_mm\":0,\"wind_speed_kmh\":17.6,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:57'),
(254, 47, '2026-06-03', 'today', 29.58, 30.00, 68, 0.00, 17.60, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.58,\"temp_max\":30,\"humidity\":68,\"rainfall_mm\":0,\"wind_speed_kmh\":17.6,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:57'),
(255, 47, '2026-06-04', 'tomorrow', 25.71, 39.11, 71, 6.45, 20.52, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.71,\"temp_max\":39.11,\"humidity\":71,\"rainfall_mm\":6.45,\"wind_speed_kmh\":20.52,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:57'),
(256, 47, '2026-06-05', 'day_3', 25.00, 36.67, 74, 8.84, 26.71, 'Rain', '02d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25,\"temp_max\":36.67,\"humidity\":74,\"rainfall_mm\":8.84,\"wind_speed_kmh\":26.71,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-03 16:07:57'),
(257, 47, '2026-06-06', 'day_4', 25.34, 33.57, 80, 20.76, 19.30, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":25.34,\"temp_max\":33.57,\"humidity\":80,\"rainfall_mm\":20.76,\"wind_speed_kmh\":19.3,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:57'),
(258, 47, '2026-06-07', 'day_5', 25.44, 31.67, 87, 8.43, 20.66, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.44,\"temp_max\":31.67,\"humidity\":87,\"rainfall_mm\":8.43,\"wind_speed_kmh\":20.66,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:57'),
(259, 48, '2026-06-03', 'current', 28.96, 29.24, 81, 0.00, 11.95, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":28.96,\"temp_max\":29.24,\"humidity\":81,\"rainfall_mm\":0,\"wind_speed_kmh\":11.95,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:07:58'),
(260, 48, '2026-06-03', 'today', 28.82, 29.24, 83, 0.00, 11.95, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":28.82,\"temp_max\":29.24,\"humidity\":83,\"rainfall_mm\":0,\"wind_speed_kmh\":11.95,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:07:58'),
(261, 48, '2026-06-04', 'tomorrow', 28.73, 32.41, 78, 5.83, 23.08, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.73,\"temp_max\":32.41,\"humidity\":78,\"rainfall_mm\":5.83,\"wind_speed_kmh\":23.08,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:58'),
(262, 48, '2026-06-05', 'day_3', 29.03, 32.69, 79, 8.04, 23.22, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":29.03,\"temp_max\":32.69,\"humidity\":79,\"rainfall_mm\":8.04,\"wind_speed_kmh\":23.22,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:58'),
(263, 48, '2026-06-06', 'day_4', 29.18, 31.87, 82, 2.45, 32.11, 'Rain', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":29.18,\"temp_max\":31.87,\"humidity\":82,\"rainfall_mm\":2.45,\"wind_speed_kmh\":32.11,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-03 16:07:58'),
(264, 48, '2026-06-07', 'day_5', 22.53, 29.86, 88, 84.26, 30.78, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":22.53,\"temp_max\":29.86,\"humidity\":88,\"rainfall_mm\":84.26,\"wind_speed_kmh\":30.78,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:07:58'),
(265, 49, '2026-06-03', 'current', 31.48, 32.27, 54, 0.76, 18.54, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":31.48,\"temp_max\":32.27,\"humidity\":54,\"rainfall_mm\":0.76,\"wind_speed_kmh\":18.54,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:58'),
(266, 49, '2026-06-03', 'today', 30.92, 32.27, 60, 1.01, 18.54, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.92,\"temp_max\":32.27,\"humidity\":60,\"rainfall_mm\":1.01,\"wind_speed_kmh\":18.54,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:58'),
(267, 49, '2026-06-04', 'tomorrow', 27.69, 39.79, 63, 3.43, 22.50, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.69,\"temp_max\":39.79,\"humidity\":63,\"rainfall_mm\":3.43,\"wind_speed_kmh\":22.5,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:58'),
(268, 49, '2026-06-05', 'day_3', 27.35, 40.95, 69, 28.60, 35.89, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":27.35,\"temp_max\":40.95,\"humidity\":69,\"rainfall_mm\":28.6,\"wind_speed_kmh\":35.89,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:58'),
(269, 49, '2026-06-06', 'day_4', 28.02, 40.63, 65, 10.46, 18.90, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":28.02,\"temp_max\":40.63,\"humidity\":65,\"rainfall_mm\":10.46,\"wind_speed_kmh\":18.9,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:58'),
(270, 49, '2026-06-07', 'day_5', 26.65, 35.63, 75, 5.84, 29.12, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":26.65,\"temp_max\":35.63,\"humidity\":75,\"rainfall_mm\":5.84,\"wind_speed_kmh\":29.12,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:58'),
(271, 50, '2026-06-03', 'current', 27.79, 29.20, 69, 0.33, 13.36, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":27.79,\"temp_max\":29.2,\"humidity\":69,\"rainfall_mm\":0.33,\"wind_speed_kmh\":13.36,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:59'),
(272, 50, '2026-06-03', 'today', 26.77, 29.20, 74, 0.65, 16.99, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":26.77,\"temp_max\":29.2,\"humidity\":74,\"rainfall_mm\":0.65,\"wind_speed_kmh\":16.99,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:07:59'),
(273, 50, '2026-06-04', 'tomorrow', 24.56, 37.43, 72, 7.74, 25.60, 'Rain', '02d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.56,\"temp_max\":37.43,\"humidity\":72,\"rainfall_mm\":7.74,\"wind_speed_kmh\":25.6,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-03 16:07:59'),
(274, 50, '2026-06-05', 'day_3', 24.26, 35.08, 75, 13.29, 14.69, 'Rain', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":24.26,\"temp_max\":35.08,\"humidity\":75,\"rainfall_mm\":13.29,\"wind_speed_kmh\":14.69,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-03 16:07:59'),
(275, 50, '2026-06-06', 'day_4', 24.82, 32.50, 81, 16.41, 17.96, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":24.82,\"temp_max\":32.5,\"humidity\":81,\"rainfall_mm\":16.41,\"wind_speed_kmh\":17.96,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:59'),
(276, 50, '2026-06-07', 'day_5', 25.13, 32.29, 81, 6.86, 19.15, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.13,\"temp_max\":32.29,\"humidity\":81,\"rainfall_mm\":6.86,\"wind_speed_kmh\":19.15,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:59'),
(277, 51, '2026-06-03', 'current', 29.92, 30.18, 79, 0.00, 20.12, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.92,\"temp_max\":30.18,\"humidity\":79,\"rainfall_mm\":0,\"wind_speed_kmh\":20.12,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:07:59'),
(278, 51, '2026-06-03', 'today', 29.85, 30.18, 80, 0.18, 20.12, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.85,\"temp_max\":30.18,\"humidity\":80,\"rainfall_mm\":0.18,\"wind_speed_kmh\":20.12,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-03 16:07:59'),
(279, 51, '2026-06-04', 'tomorrow', 29.78, 33.64, 75, 0.34, 26.24, 'Clear', '01d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.78,\"temp_max\":33.64,\"humidity\":75,\"rainfall_mm\":0.34,\"wind_speed_kmh\":26.24,\"conditions\":\"Clear\",\"icon\":\"01d\"}', '2026-06-03 16:07:59'),
(280, 51, '2026-06-05', 'day_3', 30.06, 33.98, 75, 0.10, 24.95, 'Clouds', '01d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":30.06,\"temp_max\":33.98,\"humidity\":75,\"rainfall_mm\":0.1,\"wind_speed_kmh\":24.95,\"conditions\":\"Clouds\",\"icon\":\"01d\"}', '2026-06-03 16:07:59'),
(281, 51, '2026-06-06', 'day_4', 30.09, 33.79, 78, 0.75, 29.48, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":30.09,\"temp_max\":33.79,\"humidity\":78,\"rainfall_mm\":0.75,\"wind_speed_kmh\":29.48,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:59'),
(282, 51, '2026-06-07', 'day_5', 30.18, 32.52, 80, 0.72, 29.99, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":30.18,\"temp_max\":32.52,\"humidity\":80,\"rainfall_mm\":0.72,\"wind_speed_kmh\":29.99,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:59'),
(283, 52, '2026-06-03', 'current', 29.86, 30.29, 72, 0.00, 15.91, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.86,\"temp_max\":30.29,\"humidity\":72,\"rainfall_mm\":0,\"wind_speed_kmh\":15.91,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:07:59'),
(284, 52, '2026-06-03', 'today', 29.57, 30.29, 75, 0.17, 15.91, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.57,\"temp_max\":30.29,\"humidity\":75,\"rainfall_mm\":0.17,\"wind_speed_kmh\":15.91,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-03 16:07:59'),
(285, 52, '2026-06-04', 'tomorrow', 29.26, 38.51, 66, 3.69, 21.67, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.26,\"temp_max\":38.51,\"humidity\":66,\"rainfall_mm\":3.69,\"wind_speed_kmh\":21.67,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:07:59'),
(286, 52, '2026-06-05', 'day_3', 29.86, 38.35, 65, 0.44, 26.21, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":29.86,\"temp_max\":38.35,\"humidity\":65,\"rainfall_mm\":0.44,\"wind_speed_kmh\":26.21,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:07:59'),
(287, 52, '2026-06-06', 'day_4', 29.94, 38.18, 67, 0.33, 30.78, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":29.94,\"temp_max\":38.18,\"humidity\":67,\"rainfall_mm\":0.33,\"wind_speed_kmh\":30.78,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:07:59'),
(288, 52, '2026-06-07', 'day_5', 28.37, 36.29, 70, 3.54, 26.78, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":28.37,\"temp_max\":36.29,\"humidity\":70,\"rainfall_mm\":3.54,\"wind_speed_kmh\":26.78,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:07:59'),
(289, 53, '2026-06-03', 'current', 30.91, 32.37, 57, 0.00, 21.64, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.91,\"temp_max\":32.37,\"humidity\":57,\"rainfall_mm\":0,\"wind_speed_kmh\":21.64,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:08:00'),
(290, 53, '2026-06-03', 'today', 30.92, 32.37, 63, 0.00, 21.64, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.92,\"temp_max\":32.37,\"humidity\":63,\"rainfall_mm\":0,\"wind_speed_kmh\":21.64,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:08:00'),
(291, 53, '2026-06-04', 'tomorrow', 27.85, 39.12, 66, 7.82, 28.51, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.85,\"temp_max\":39.12,\"humidity\":66,\"rainfall_mm\":7.82,\"wind_speed_kmh\":28.51,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:08:00'),
(292, 53, '2026-06-05', 'day_3', 26.60, 40.94, 70, 6.56, 27.18, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.6,\"temp_max\":40.94,\"humidity\":70,\"rainfall_mm\":6.56,\"wind_speed_kmh\":27.18,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:00'),
(293, 53, '2026-06-06', 'day_4', 26.81, 41.41, 68, 44.31, 28.76, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.81,\"temp_max\":41.41,\"humidity\":68,\"rainfall_mm\":44.31,\"wind_speed_kmh\":28.76,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:08:00'),
(294, 53, '2026-06-07', 'day_5', 25.52, 36.08, 76, 52.34, 24.41, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.52,\"temp_max\":36.08,\"humidity\":76,\"rainfall_mm\":52.34,\"wind_speed_kmh\":24.41,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:08:00'),
(295, 54, '2026-06-03', 'current', 32.35, 33.54, 47, 0.47, 15.41, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":32.35,\"temp_max\":33.54,\"humidity\":47,\"rainfall_mm\":0.47,\"wind_speed_kmh\":15.41,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:08:00'),
(296, 54, '2026-06-03', 'today', 31.86, 33.54, 54, 0.47, 19.15, 'Rain', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":31.86,\"temp_max\":33.54,\"humidity\":54,\"rainfall_mm\":0.47,\"wind_speed_kmh\":19.15,\"conditions\":\"Rain\",\"icon\":\"03n\"}', '2026-06-03 16:08:00'),
(297, 54, '2026-06-04', 'tomorrow', 28.49, 40.48, 58, 2.53, 31.14, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.49,\"temp_max\":40.48,\"humidity\":58,\"rainfall_mm\":2.53,\"wind_speed_kmh\":31.14,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:08:00'),
(298, 54, '2026-06-05', 'day_3', 28.32, 41.52, 61, 3.11, 22.57, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":28.32,\"temp_max\":41.52,\"humidity\":61,\"rainfall_mm\":3.11,\"wind_speed_kmh\":22.57,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:08:00'),
(299, 54, '2026-06-06', 'day_4', 28.86, 41.65, 59, 17.40, 17.89, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":28.86,\"temp_max\":41.65,\"humidity\":59,\"rainfall_mm\":17.4,\"wind_speed_kmh\":17.89,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-03 16:08:00'),
(300, 54, '2026-06-07', 'day_5', 27.78, 40.37, 68, 19.76, 31.07, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":27.78,\"temp_max\":40.37,\"humidity\":68,\"rainfall_mm\":19.76,\"wind_speed_kmh\":31.07,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:08:00'),
(301, 55, '2026-06-03', 'current', 26.19, 26.59, 86, 0.00, 5.80, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":26.19,\"temp_max\":26.59,\"humidity\":86,\"rainfall_mm\":0,\"wind_speed_kmh\":5.8,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:08:00'),
(302, 55, '2026-06-03', 'today', 26.03, 26.59, 88, 0.00, 6.26, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":26.03,\"temp_max\":26.59,\"humidity\":88,\"rainfall_mm\":0,\"wind_speed_kmh\":6.26,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:08:00'),
(303, 55, '2026-06-04', 'tomorrow', 25.88, 35.41, 76, 5.54, 15.52, 'Rain', '01d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.88,\"temp_max\":35.41,\"humidity\":76,\"rainfall_mm\":5.54,\"wind_speed_kmh\":15.52,\"conditions\":\"Rain\",\"icon\":\"01d\"}', '2026-06-03 16:08:00'),
(304, 55, '2026-06-05', 'day_3', 26.05, 34.30, 80, 4.65, 15.01, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.05,\"temp_max\":34.3,\"humidity\":80,\"rainfall_mm\":4.65,\"wind_speed_kmh\":15.01,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-03 16:08:00'),
(305, 55, '2026-06-06', 'day_4', 26.27, 35.17, 73, 0.45, 21.64, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.27,\"temp_max\":35.17,\"humidity\":73,\"rainfall_mm\":0.45,\"wind_speed_kmh\":21.64,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:08:00'),
(306, 55, '2026-06-07', 'day_5', 23.32, 31.10, 89, 93.23, 15.26, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":23.32,\"temp_max\":31.1,\"humidity\":89,\"rainfall_mm\":93.23,\"wind_speed_kmh\":15.26,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:08:00'),
(307, 56, '2026-06-03', 'current', 29.04, 29.13, 72, 0.00, 19.40, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.04,\"temp_max\":29.13,\"humidity\":72,\"rainfall_mm\":0,\"wind_speed_kmh\":19.4,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:08:01'),
(308, 56, '2026-06-03', 'today', 28.46, 29.13, 75, 0.00, 19.40, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":28.46,\"temp_max\":29.13,\"humidity\":75,\"rainfall_mm\":0,\"wind_speed_kmh\":19.4,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:08:01'),
(309, 56, '2026-06-04', 'tomorrow', 24.35, 35.69, 81, 34.54, 21.89, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.35,\"temp_max\":35.69,\"humidity\":81,\"rainfall_mm\":34.54,\"wind_speed_kmh\":21.89,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:01'),
(310, 56, '2026-06-05', 'day_3', 24.77, 35.30, 79, 9.70, 27.79, 'Rain', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":24.77,\"temp_max\":35.3,\"humidity\":79,\"rainfall_mm\":9.7,\"wind_speed_kmh\":27.79,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-03 16:08:01'),
(311, 56, '2026-06-06', 'day_4', 25.77, 33.37, 82, 15.37, 17.24, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":25.77,\"temp_max\":33.37,\"humidity\":82,\"rainfall_mm\":15.37,\"wind_speed_kmh\":17.24,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:08:01'),
(312, 56, '2026-06-07', 'day_5', 25.61, 28.42, 91, 10.05, 22.36, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.61,\"temp_max\":28.42,\"humidity\":91,\"rainfall_mm\":10.05,\"wind_speed_kmh\":22.36,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:01'),
(313, 57, '2026-06-03', 'current', 30.69, 31.72, 63, 0.00, 20.52, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.69,\"temp_max\":31.72,\"humidity\":63,\"rainfall_mm\":0,\"wind_speed_kmh\":20.52,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:08:02'),
(314, 57, '2026-06-03', 'today', 30.66, 31.72, 68, 0.00, 20.52, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.66,\"temp_max\":31.72,\"humidity\":68,\"rainfall_mm\":0,\"wind_speed_kmh\":20.52,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:08:02'),
(315, 57, '2026-06-04', 'tomorrow', 28.08, 40.79, 64, 24.41, 19.91, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.08,\"temp_max\":40.79,\"humidity\":64,\"rainfall_mm\":24.41,\"wind_speed_kmh\":19.91,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:02'),
(316, 57, '2026-06-05', 'day_3', 27.24, 39.98, 66, 4.77, 30.53, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":27.24,\"temp_max\":39.98,\"humidity\":66,\"rainfall_mm\":4.77,\"wind_speed_kmh\":30.53,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:08:02'),
(317, 57, '2026-06-06', 'day_4', 29.93, 40.55, 62, 2.85, 28.33, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":29.93,\"temp_max\":40.55,\"humidity\":62,\"rainfall_mm\":2.85,\"wind_speed_kmh\":28.33,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:08:02'),
(318, 57, '2026-06-07', 'day_5', 29.30, 42.58, 61, 6.00, 30.38, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":29.3,\"temp_max\":42.58,\"humidity\":61,\"rainfall_mm\":6,\"wind_speed_kmh\":30.38,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:08:02'),
(319, 58, '2026-06-03', 'current', 29.59, 30.28, 70, 0.00, 18.29, 'Clear', '01n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.59,\"temp_max\":30.28,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":18.29,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-03 16:08:04'),
(320, 58, '2026-06-03', 'today', 29.44, 30.28, 73, 0.00, 18.29, 'Clear', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.44,\"temp_max\":30.28,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":18.29,\"conditions\":\"Clear\",\"icon\":\"03n\"}', '2026-06-03 16:08:04');
INSERT INTO `weather_forecasts` (`forecast_id`, `district_id`, `forecast_date`, `forecast_for`, `temp_min`, `temp_max`, `humidity`, `rainfall_mm`, `wind_speed_kmh`, `conditions`, `icon`, `raw_payload`, `fetched_at`) VALUES
(321, 58, '2026-06-04', 'tomorrow', 25.32, 37.79, 71, 3.94, 27.72, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.32,\"temp_max\":37.79,\"humidity\":71,\"rainfall_mm\":3.94,\"wind_speed_kmh\":27.72,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:04'),
(322, 58, '2026-06-05', 'day_3', 25.18, 37.52, 75, 27.23, 28.01, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.18,\"temp_max\":37.52,\"humidity\":75,\"rainfall_mm\":27.23,\"wind_speed_kmh\":28.01,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:08:04'),
(323, 58, '2026-06-06', 'day_4', 25.72, 36.56, 74, 9.42, 31.07, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":25.72,\"temp_max\":36.56,\"humidity\":74,\"rainfall_mm\":9.42,\"wind_speed_kmh\":31.07,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:08:04'),
(324, 58, '2026-06-07', 'day_5', 24.52, 33.70, 82, 96.28, 31.07, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.52,\"temp_max\":33.7,\"humidity\":82,\"rainfall_mm\":96.28,\"wind_speed_kmh\":31.07,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:08:04'),
(325, 59, '2026-06-03', 'current', 29.64, 30.29, 67, 0.22, 11.02, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.64,\"temp_max\":30.29,\"humidity\":67,\"rainfall_mm\":0.22,\"wind_speed_kmh\":11.02,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:08:04'),
(326, 59, '2026-06-03', 'today', 29.48, 30.29, 69, 0.22, 11.02, 'Rain', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.48,\"temp_max\":30.29,\"humidity\":69,\"rainfall_mm\":0.22,\"wind_speed_kmh\":11.02,\"conditions\":\"Rain\",\"icon\":\"03n\"}', '2026-06-03 16:08:04'),
(327, 59, '2026-06-04', 'tomorrow', 24.81, 37.91, 71, 8.06, 20.63, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.81,\"temp_max\":37.91,\"humidity\":71,\"rainfall_mm\":8.06,\"wind_speed_kmh\":20.63,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:04'),
(328, 59, '2026-06-05', 'day_3', 25.01, 36.73, 77, 22.69, 35.71, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.01,\"temp_max\":36.73,\"humidity\":77,\"rainfall_mm\":22.69,\"wind_speed_kmh\":35.71,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:04'),
(329, 59, '2026-06-06', 'day_4', 25.16, 36.98, 79, 23.19, 22.07, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":25.16,\"temp_max\":36.98,\"humidity\":79,\"rainfall_mm\":23.19,\"wind_speed_kmh\":22.07,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:04'),
(330, 59, '2026-06-07', 'day_5', 24.51, 29.00, 92, 21.20, 22.72, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.51,\"temp_max\":29,\"humidity\":92,\"rainfall_mm\":21.2,\"wind_speed_kmh\":22.72,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:04'),
(331, 60, '2026-06-03', 'current', 31.43, 31.84, 66, 0.00, 25.49, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":31.43,\"temp_max\":31.84,\"humidity\":66,\"rainfall_mm\":0,\"wind_speed_kmh\":25.49,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:08:04'),
(332, 60, '2026-06-03', 'today', 30.93, 31.84, 68, 0.00, 25.49, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":30.93,\"temp_max\":31.84,\"humidity\":68,\"rainfall_mm\":0,\"wind_speed_kmh\":25.49,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:08:04'),
(333, 60, '2026-06-04', 'tomorrow', 27.59, 33.11, 77, 8.11, 34.99, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.59,\"temp_max\":33.11,\"humidity\":77,\"rainfall_mm\":8.11,\"wind_speed_kmh\":34.99,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-03 16:08:04'),
(334, 60, '2026-06-05', 'day_3', 26.52, 33.99, 78, 23.43, 33.66, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.52,\"temp_max\":33.99,\"humidity\":78,\"rainfall_mm\":23.43,\"wind_speed_kmh\":33.66,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:04'),
(335, 60, '2026-06-06', 'day_4', 26.48, 35.09, 77, 21.40, 28.66, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.48,\"temp_max\":35.09,\"humidity\":77,\"rainfall_mm\":21.4,\"wind_speed_kmh\":28.66,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:04'),
(336, 60, '2026-06-07', 'day_5', 26.27, 33.33, 81, 12.16, 26.21, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":26.27,\"temp_max\":33.33,\"humidity\":81,\"rainfall_mm\":12.16,\"wind_speed_kmh\":26.21,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:04'),
(337, 61, '2026-06-03', 'current', 26.03, 27.30, 79, 2.71, 3.71, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":26.03,\"temp_max\":27.3,\"humidity\":79,\"rainfall_mm\":2.71,\"wind_speed_kmh\":3.71,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:08:06'),
(338, 61, '2026-06-03', 'today', 25.74, 27.30, 83, 10.43, 8.64, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":25.74,\"temp_max\":27.3,\"humidity\":83,\"rainfall_mm\":10.43,\"wind_speed_kmh\":8.64,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:08:06'),
(339, 61, '2026-06-04', 'tomorrow', 25.20, 33.73, 81, 30.17, 11.56, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.2,\"temp_max\":33.73,\"humidity\":81,\"rainfall_mm\":30.17,\"wind_speed_kmh\":11.56,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:06'),
(340, 61, '2026-06-05', 'day_3', 25.49, 33.65, 79, 23.93, 10.30, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.49,\"temp_max\":33.65,\"humidity\":79,\"rainfall_mm\":23.93,\"wind_speed_kmh\":10.3,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:06'),
(341, 61, '2026-06-06', 'day_4', 25.13, 32.51, 89, 78.23, 13.57, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":25.13,\"temp_max\":32.51,\"humidity\":89,\"rainfall_mm\":78.23,\"wind_speed_kmh\":13.57,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:06'),
(342, 61, '2026-06-07', 'day_5', 25.11, 27.39, 91, 14.28, 16.96, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25.11,\"temp_max\":27.39,\"humidity\":91,\"rainfall_mm\":14.28,\"wind_speed_kmh\":16.96,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:06'),
(343, 62, '2026-06-03', 'current', 26.31, 27.94, 78, 1.00, 6.70, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":26.31,\"temp_max\":27.94,\"humidity\":78,\"rainfall_mm\":1,\"wind_speed_kmh\":6.7,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:08:06'),
(344, 62, '2026-06-03', 'today', 26.32, 27.94, 82, 5.89, 7.49, 'Rain', '10n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":26.32,\"temp_max\":27.94,\"humidity\":82,\"rainfall_mm\":5.89,\"wind_speed_kmh\":7.49,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-03 16:08:06'),
(345, 62, '2026-06-04', 'tomorrow', 25.61, 34.29, 79, 33.94, 14.08, 'Rain', '04d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.61,\"temp_max\":34.29,\"humidity\":79,\"rainfall_mm\":33.94,\"wind_speed_kmh\":14.08,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:08:06'),
(346, 62, '2026-06-05', 'day_3', 25.79, 33.69, 78, 20.80, 10.30, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":25.79,\"temp_max\":33.69,\"humidity\":78,\"rainfall_mm\":20.8,\"wind_speed_kmh\":10.3,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:06'),
(347, 62, '2026-06-06', 'day_4', 23.91, 31.04, 88, 126.30, 13.72, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":23.91,\"temp_max\":31.04,\"humidity\":88,\"rainfall_mm\":126.3,\"wind_speed_kmh\":13.72,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:06'),
(348, 62, '2026-06-07', 'day_5', 24.54, 29.18, 89, 13.99, 13.10, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.54,\"temp_max\":29.18,\"humidity\":89,\"rainfall_mm\":13.99,\"wind_speed_kmh\":13.1,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:06'),
(349, 63, '2026-06-03', 'current', 30.37, 30.68, 66, 0.00, 20.95, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":30.37,\"temp_max\":30.68,\"humidity\":66,\"rainfall_mm\":0,\"wind_speed_kmh\":20.95,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-03 16:08:07'),
(350, 63, '2026-06-03', 'today', 29.70, 30.68, 69, 0.00, 20.95, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":29.7,\"temp_max\":30.68,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":20.95,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:08:07'),
(351, 63, '2026-06-04', 'tomorrow', 23.68, 37.81, 70, 66.17, 25.56, 'Rain', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":23.68,\"temp_max\":37.81,\"humidity\":70,\"rainfall_mm\":66.17,\"wind_speed_kmh\":25.56,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:07'),
(352, 63, '2026-06-05', 'day_3', 26.43, 35.94, 74, 13.58, 30.02, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":26.43,\"temp_max\":35.94,\"humidity\":74,\"rainfall_mm\":13.58,\"wind_speed_kmh\":30.02,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:07'),
(353, 63, '2026-06-06', 'day_4', 26.08, 36.48, 74, 17.99, 26.82, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.08,\"temp_max\":36.48,\"humidity\":74,\"rainfall_mm\":17.99,\"wind_speed_kmh\":26.82,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-03 16:08:07'),
(354, 63, '2026-06-07', 'day_5', 25.00, 32.90, 86, 35.84, 26.93, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":25,\"temp_max\":32.9,\"humidity\":86,\"rainfall_mm\":35.84,\"wind_speed_kmh\":26.93,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-03 16:08:07'),
(355, 64, '2026-06-03', 'current', 29.51, 30.50, 63, 0.00, 10.30, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"current\",\"temp_min\":29.51,\"temp_max\":30.5,\"humidity\":63,\"rainfall_mm\":0,\"wind_speed_kmh\":10.3,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-03 16:08:07'),
(356, 64, '2026-06-03', 'today', 28.81, 30.50, 68, 0.00, 13.00, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-03\",\"forecast_for\":\"today\",\"temp_min\":28.81,\"temp_max\":30.5,\"humidity\":68,\"rainfall_mm\":0,\"wind_speed_kmh\":13,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-03 16:08:07'),
(357, 64, '2026-06-04', 'tomorrow', 24.59, 37.99, 70, 4.60, 24.30, 'Clear', '10d', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.59,\"temp_max\":37.99,\"humidity\":70,\"rainfall_mm\":4.6,\"wind_speed_kmh\":24.3,\"conditions\":\"Clear\",\"icon\":\"10d\"}', '2026-06-03 16:08:07'),
(358, 64, '2026-06-05', 'day_3', 24.85, 36.08, 73, 9.05, 22.00, 'Rain', '01d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"day_3\",\"temp_min\":24.85,\"temp_max\":36.08,\"humidity\":73,\"rainfall_mm\":9.05,\"wind_speed_kmh\":22,\"conditions\":\"Rain\",\"icon\":\"01d\"}', '2026-06-03 16:08:07'),
(359, 64, '2026-06-06', 'day_4', 26.06, 34.01, 78, 9.75, 19.69, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_4\",\"temp_min\":26.06,\"temp_max\":34.01,\"humidity\":78,\"rainfall_mm\":9.75,\"wind_speed_kmh\":19.69,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-03 16:08:07'),
(360, 64, '2026-06-07', 'day_5', 24.94, 32.71, 81, 6.19, 18.47, 'Rain', '03d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_5\",\"temp_min\":24.94,\"temp_max\":32.71,\"humidity\":81,\"rainfall_mm\":6.19,\"wind_speed_kmh\":18.47,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-03 16:08:07'),
(1081, 1, '2026-06-04', 'current', 27.76, 27.76, 72, 5.10, 4.61, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":27.76,\"temp_max\":27.76,\"humidity\":72,\"rainfall_mm\":5.1,\"wind_speed_kmh\":4.61,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:43:59'),
(1082, 1, '2026-06-04', 'today', 27.76, 28.69, 76, 7.02, 17.39, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.76,\"temp_max\":28.69,\"humidity\":76,\"rainfall_mm\":7.02,\"wind_speed_kmh\":17.39,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:43:59'),
(1083, 1, '2026-06-05', 'tomorrow', 25.95, 38.31, 70, 15.47, 39.64, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.95,\"temp_max\":38.31,\"humidity\":70,\"rainfall_mm\":15.47,\"wind_speed_kmh\":39.64,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:43:59'),
(1084, 1, '2026-06-06', 'day_3', 28.73, 37.66, 68, 0.13, 30.71, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":28.73,\"temp_max\":37.66,\"humidity\":68,\"rainfall_mm\":0.13,\"wind_speed_kmh\":30.71,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:43:59'),
(1085, 1, '2026-06-07', 'day_4', 29.30, 37.15, 68, 0.91, 24.84, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":29.3,\"temp_max\":37.15,\"humidity\":68,\"rainfall_mm\":0.91,\"wind_speed_kmh\":24.84,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:43:59'),
(1086, 1, '2026-06-08', 'day_5', 29.62, 39.28, 65, 0.66, 26.14, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":29.62,\"temp_max\":39.28,\"humidity\":65,\"rainfall_mm\":0.66,\"wind_speed_kmh\":26.14,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:43:59'),
(1087, 2, '2026-06-04', 'current', 26.28, 26.28, 90, 0.36, 4.39, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":26.28,\"temp_max\":26.28,\"humidity\":90,\"rainfall_mm\":0.36,\"wind_speed_kmh\":4.39,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:02'),
(1088, 2, '2026-06-04', 'today', 25.23, 26.28, 92, 2.33, 4.39, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":25.23,\"temp_max\":26.28,\"humidity\":92,\"rainfall_mm\":2.33,\"wind_speed_kmh\":4.39,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:02'),
(1089, 2, '2026-06-05', 'tomorrow', 24.62, 36.60, 74, 4.93, 14.83, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.62,\"temp_max\":36.6,\"humidity\":74,\"rainfall_mm\":4.93,\"wind_speed_kmh\":14.83,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-04 13:44:02'),
(1090, 2, '2026-06-06', 'day_3', 24.62, 37.31, 74, 0.77, 10.76, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":24.62,\"temp_max\":37.31,\"humidity\":74,\"rainfall_mm\":0.77,\"wind_speed_kmh\":10.76,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:02'),
(1091, 2, '2026-06-07', 'day_4', 25.12, 36.43, 74, 1.84, 11.70, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.12,\"temp_max\":36.43,\"humidity\":74,\"rainfall_mm\":1.84,\"wind_speed_kmh\":11.7,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:02'),
(1092, 2, '2026-06-08', 'day_5', 24.80, 35.93, 76, 6.17, 10.87, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":24.8,\"temp_max\":35.93,\"humidity\":76,\"rainfall_mm\":6.17,\"wind_speed_kmh\":10.87,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:02'),
(1093, 3, '2026-06-04', 'current', 29.03, 29.03, 80, 0.89, 6.30, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.03,\"temp_max\":29.03,\"humidity\":80,\"rainfall_mm\":0.89,\"wind_speed_kmh\":6.3,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:04'),
(1094, 3, '2026-06-04', 'today', 29.03, 29.28, 81, 0.89, 11.84, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.03,\"temp_max\":29.28,\"humidity\":81,\"rainfall_mm\":0.89,\"wind_speed_kmh\":11.84,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-04 13:44:04'),
(1095, 3, '2026-06-05', 'tomorrow', 28.17, 33.24, 75, 6.57, 22.28, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.17,\"temp_max\":33.24,\"humidity\":75,\"rainfall_mm\":6.57,\"wind_speed_kmh\":22.28,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:04'),
(1096, 3, '2026-06-06', 'day_3', 29.34, 33.32, 77, 2.27, 29.45, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":29.34,\"temp_max\":33.32,\"humidity\":77,\"rainfall_mm\":2.27,\"wind_speed_kmh\":29.45,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:04'),
(1097, 3, '2026-06-07', 'day_4', 29.32, 33.01, 76, 4.87, 29.45, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":29.32,\"temp_max\":33.01,\"humidity\":76,\"rainfall_mm\":4.87,\"wind_speed_kmh\":29.45,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:04'),
(1098, 3, '2026-06-08', 'day_5', 29.40, 33.33, 78, 1.73, 26.78, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":29.4,\"temp_max\":33.33,\"humidity\":78,\"rainfall_mm\":1.73,\"wind_speed_kmh\":26.78,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:04'),
(1099, 4, '2026-06-04', 'current', 29.00, 29.00, 76, 2.08, 10.76, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29,\"temp_max\":29,\"humidity\":76,\"rainfall_mm\":2.08,\"wind_speed_kmh\":10.76,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:06'),
(1100, 4, '2026-06-04', 'today', 29.00, 29.06, 79, 2.45, 13.93, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29,\"temp_max\":29.06,\"humidity\":79,\"rainfall_mm\":2.45,\"wind_speed_kmh\":13.93,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:06'),
(1101, 4, '2026-06-05', 'tomorrow', 28.25, 37.74, 69, 4.39, 23.90, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.25,\"temp_max\":37.74,\"humidity\":69,\"rainfall_mm\":4.39,\"wind_speed_kmh\":23.9,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:06'),
(1102, 4, '2026-06-06', 'day_3', 29.05, 37.58, 67, 0.65, 23.47, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":29.05,\"temp_max\":37.58,\"humidity\":67,\"rainfall_mm\":0.65,\"wind_speed_kmh\":23.47,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:06'),
(1103, 4, '2026-06-07', 'day_4', 29.49, 36.93, 67, 1.71, 22.07, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":29.49,\"temp_max\":36.93,\"humidity\":67,\"rainfall_mm\":1.71,\"wind_speed_kmh\":22.07,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:06'),
(1104, 4, '2026-06-08', 'day_5', 29.50, 37.12, 69, 0.00, 23.11, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":29.5,\"temp_max\":37.12,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":23.11,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:06'),
(1105, 5, '2026-06-04', 'current', 28.81, 28.81, 79, 0.68, 6.19, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.81,\"temp_max\":28.81,\"humidity\":79,\"rainfall_mm\":0.68,\"wind_speed_kmh\":6.19,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:08'),
(1106, 5, '2026-06-04', 'today', 28.81, 29.00, 80, 0.68, 11.16, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.81,\"temp_max\":29,\"humidity\":80,\"rainfall_mm\":0.68,\"wind_speed_kmh\":11.16,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-04 13:44:08'),
(1107, 5, '2026-06-05', 'tomorrow', 28.12, 33.64, 74, 6.38, 22.93, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.12,\"temp_max\":33.64,\"humidity\":74,\"rainfall_mm\":6.38,\"wind_speed_kmh\":22.93,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:08'),
(1108, 5, '2026-06-06', 'day_3', 29.15, 33.56, 77, 2.72, 28.44, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":29.15,\"temp_max\":33.56,\"humidity\":77,\"rainfall_mm\":2.72,\"wind_speed_kmh\":28.44,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:08'),
(1109, 5, '2026-06-07', 'day_4', 29.15, 33.55, 76, 4.17, 28.01, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":29.15,\"temp_max\":33.55,\"humidity\":76,\"rainfall_mm\":4.17,\"wind_speed_kmh\":28.01,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:08'),
(1110, 5, '2026-06-08', 'day_5', 29.27, 33.75, 78, 2.94, 26.57, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":29.27,\"temp_max\":33.75,\"humidity\":78,\"rainfall_mm\":2.94,\"wind_speed_kmh\":26.57,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:08'),
(1111, 7, '2026-06-04', 'current', 28.20, 28.20, 82, 0.13, 13.86, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.2,\"temp_max\":28.2,\"humidity\":82,\"rainfall_mm\":0.13,\"wind_speed_kmh\":13.86,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:09'),
(1112, 7, '2026-06-04', 'today', 27.67, 28.20, 83, 0.13, 13.86, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.67,\"temp_max\":28.2,\"humidity\":83,\"rainfall_mm\":0.13,\"wind_speed_kmh\":13.86,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-04 13:44:09'),
(1113, 7, '2026-06-05', 'tomorrow', 26.79, 35.42, 73, 3.71, 18.40, 'Rain', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.79,\"temp_max\":35.42,\"humidity\":73,\"rainfall_mm\":3.71,\"wind_speed_kmh\":18.4,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:09'),
(1114, 7, '2026-06-06', 'day_3', 27.24, 33.46, 80, 18.48, 19.91, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":27.24,\"temp_max\":33.46,\"humidity\":80,\"rainfall_mm\":18.48,\"wind_speed_kmh\":19.91,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:09'),
(1115, 7, '2026-06-07', 'day_4', 25.76, 31.57, 86, 48.16, 22.21, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.76,\"temp_max\":31.57,\"humidity\":86,\"rainfall_mm\":48.16,\"wind_speed_kmh\":22.21,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:09'),
(1116, 7, '2026-06-08', 'day_5', 26.13, 32.82, 84, 18.71, 20.99, 'Rain', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":26.13,\"temp_max\":32.82,\"humidity\":84,\"rainfall_mm\":18.71,\"wind_speed_kmh\":20.99,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:09'),
(1117, 8, '2026-06-04', 'current', 28.02, 28.02, 81, 0.00, 4.93, 'Clear', '01n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.02,\"temp_max\":28.02,\"humidity\":81,\"rainfall_mm\":0,\"wind_speed_kmh\":4.93,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-04 13:44:10'),
(1118, 8, '2026-06-04', 'today', 26.78, 28.02, 85, 1.00, 8.68, 'Clear', '01n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":26.78,\"temp_max\":28.02,\"humidity\":85,\"rainfall_mm\":1,\"wind_speed_kmh\":8.68,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-04 13:44:10'),
(1119, 8, '2026-06-05', 'tomorrow', 26.39, 34.80, 78, 2.71, 13.25, 'Rain', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.39,\"temp_max\":34.8,\"humidity\":78,\"rainfall_mm\":2.71,\"wind_speed_kmh\":13.25,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:10'),
(1120, 8, '2026-06-06', 'day_3', 26.10, 33.19, 79, 3.43, 17.96, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":26.1,\"temp_max\":33.19,\"humidity\":79,\"rainfall_mm\":3.43,\"wind_speed_kmh\":17.96,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:10'),
(1121, 8, '2026-06-07', 'day_4', 25.56, 32.73, 82, 18.26, 20.09, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.56,\"temp_max\":32.73,\"humidity\":82,\"rainfall_mm\":18.26,\"wind_speed_kmh\":20.09,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:10'),
(1122, 8, '2026-06-08', 'day_5', 26.00, 32.74, 84, 4.43, 18.86, 'Rain', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":26,\"temp_max\":32.74,\"humidity\":84,\"rainfall_mm\":4.43,\"wind_speed_kmh\":18.86,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:10'),
(1123, 11, '2026-06-04', 'current', 30.12, 30.12, 70, 0.41, 23.08, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":30.12,\"temp_max\":30.12,\"humidity\":70,\"rainfall_mm\":0.41,\"wind_speed_kmh\":23.08,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:11'),
(1124, 11, '2026-06-04', 'today', 29.13, 30.12, 71, 1.23, 23.08, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.13,\"temp_max\":30.12,\"humidity\":71,\"rainfall_mm\":1.23,\"wind_speed_kmh\":23.08,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:11'),
(1125, 11, '2026-06-05', 'tomorrow', 28.00, 40.18, 66, 13.91, 17.35, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":28,\"temp_max\":40.18,\"humidity\":66,\"rainfall_mm\":13.91,\"wind_speed_kmh\":17.35,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:11'),
(1126, 11, '2026-06-06', 'day_3', 27.49, 40.82, 62, 16.97, 22.61, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":27.49,\"temp_max\":40.82,\"humidity\":62,\"rainfall_mm\":16.97,\"wind_speed_kmh\":22.61,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:11'),
(1127, 11, '2026-06-07', 'day_4', 27.52, 39.05, 67, 15.58, 22.82, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":27.52,\"temp_max\":39.05,\"humidity\":67,\"rainfall_mm\":15.58,\"wind_speed_kmh\":22.82,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:11'),
(1128, 11, '2026-06-08', 'day_5', 28.70, 38.82, 59, 0.00, 20.92, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.7,\"temp_max\":38.82,\"humidity\":59,\"rainfall_mm\":0,\"wind_speed_kmh\":20.92,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:11'),
(1129, 12, '2026-06-04', 'current', 28.45, 28.45, 77, 0.00, 5.33, 'Clear', '01n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.45,\"temp_max\":28.45,\"humidity\":77,\"rainfall_mm\":0,\"wind_speed_kmh\":5.33,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-04 13:44:12'),
(1130, 12, '2026-06-04', 'today', 27.66, 28.45, 80, 0.14, 10.22, 'Clear', '02n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.66,\"temp_max\":28.45,\"humidity\":80,\"rainfall_mm\":0.14,\"wind_speed_kmh\":10.22,\"conditions\":\"Clear\",\"icon\":\"02n\"}', '2026-06-04 13:44:12'),
(1131, 12, '2026-06-05', 'tomorrow', 26.82, 35.78, 74, 4.17, 18.54, 'Rain', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.82,\"temp_max\":35.78,\"humidity\":74,\"rainfall_mm\":4.17,\"wind_speed_kmh\":18.54,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:12'),
(1132, 12, '2026-06-06', 'day_3', 26.82, 34.16, 79, 5.58, 23.58, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":26.82,\"temp_max\":34.16,\"humidity\":79,\"rainfall_mm\":5.58,\"wind_speed_kmh\":23.58,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:12'),
(1133, 12, '2026-06-07', 'day_4', 26.65, 33.07, 82, 29.80, 24.59, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":26.65,\"temp_max\":33.07,\"humidity\":82,\"rainfall_mm\":29.8,\"wind_speed_kmh\":24.59,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:12'),
(1134, 12, '2026-06-08', 'day_5', 26.39, 33.36, 84, 11.05, 22.57, 'Rain', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":26.39,\"temp_max\":33.36,\"humidity\":84,\"rainfall_mm\":11.05,\"wind_speed_kmh\":22.57,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:12'),
(1135, 13, '2026-06-04', 'current', 28.65, 28.65, 84, 1.84, 8.24, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.65,\"temp_max\":28.65,\"humidity\":84,\"rainfall_mm\":1.84,\"wind_speed_kmh\":8.24,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:13'),
(1136, 13, '2026-06-04', 'today', 28.06, 28.65, 85, 6.43, 8.24, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.06,\"temp_max\":28.65,\"humidity\":85,\"rainfall_mm\":6.43,\"wind_speed_kmh\":8.24,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:13'),
(1137, 13, '2026-06-05', 'tomorrow', 27.38, 32.43, 78, 4.24, 18.32, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.38,\"temp_max\":32.43,\"humidity\":78,\"rainfall_mm\":4.24,\"wind_speed_kmh\":18.32,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:13'),
(1138, 13, '2026-06-06', 'day_3', 27.65, 32.19, 76, 1.05, 24.12, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":27.65,\"temp_max\":32.19,\"humidity\":76,\"rainfall_mm\":1.05,\"wind_speed_kmh\":24.12,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:13'),
(1139, 13, '2026-06-07', 'day_4', 27.65, 32.28, 76, 1.47, 28.58, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":27.65,\"temp_max\":32.28,\"humidity\":76,\"rainfall_mm\":1.47,\"wind_speed_kmh\":28.58,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:13'),
(1140, 13, '2026-06-08', 'day_5', 28.05, 32.51, 78, 3.10, 26.75, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.05,\"temp_max\":32.51,\"humidity\":78,\"rainfall_mm\":3.1,\"wind_speed_kmh\":26.75,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:13'),
(1141, 14, '2026-06-04', 'current', 28.97, 28.97, 77, 3.65, 7.70, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.97,\"temp_max\":28.97,\"humidity\":77,\"rainfall_mm\":3.65,\"wind_speed_kmh\":7.7,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:13'),
(1142, 14, '2026-06-04', 'today', 28.70, 29.00, 74, 3.65, 9.43, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.7,\"temp_max\":29,\"humidity\":74,\"rainfall_mm\":3.65,\"wind_speed_kmh\":9.43,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-04 13:44:13'),
(1143, 14, '2026-06-05', 'tomorrow', 28.39, 38.07, 63, 6.65, 23.44, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.39,\"temp_max\":38.07,\"humidity\":63,\"rainfall_mm\":6.65,\"wind_speed_kmh\":23.44,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:13'),
(1144, 14, '2026-06-06', 'day_3', 27.80, 37.14, 68, 11.33, 24.80, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":27.8,\"temp_max\":37.14,\"humidity\":68,\"rainfall_mm\":11.33,\"wind_speed_kmh\":24.8,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:13'),
(1145, 14, '2026-06-07', 'day_4', 26.61, 33.80, 74, 14.91, 23.08, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":26.61,\"temp_max\":33.8,\"humidity\":74,\"rainfall_mm\":14.91,\"wind_speed_kmh\":23.08,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:13'),
(1146, 14, '2026-06-08', 'day_5', 28.35, 35.71, 71, 1.42, 23.36, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.35,\"temp_max\":35.71,\"humidity\":71,\"rainfall_mm\":1.42,\"wind_speed_kmh\":23.36,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:13'),
(1147, 15, '2026-06-04', 'current', 30.03, 30.03, 70, 0.00, 20.16, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":30.03,\"temp_max\":30.03,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":20.16,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-04 13:44:14'),
(1148, 15, '2026-06-04', 'today', 28.86, 30.03, 73, 0.00, 23.22, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.86,\"temp_max\":30.03,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":23.22,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-04 13:44:14'),
(1149, 15, '2026-06-05', 'tomorrow', 26.01, 37.98, 65, 12.56, 17.82, 'Rain', '02d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.01,\"temp_max\":37.98,\"humidity\":65,\"rainfall_mm\":12.56,\"wind_speed_kmh\":17.82,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-04 13:44:14'),
(1150, 15, '2026-06-06', 'day_3', 25.61, 36.36, 67, 27.80, 16.06, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":25.61,\"temp_max\":36.36,\"humidity\":67,\"rainfall_mm\":27.8,\"wind_speed_kmh\":16.06,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:14'),
(1151, 15, '2026-06-07', 'day_4', 26.18, 34.13, 76, 11.97, 23.29, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":26.18,\"temp_max\":34.13,\"humidity\":76,\"rainfall_mm\":11.97,\"wind_speed_kmh\":23.29,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:14'),
(1152, 15, '2026-06-08', 'day_5', 26.14, 36.69, 71, 2.89, 14.65, 'Rain', '02d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":26.14,\"temp_max\":36.69,\"humidity\":71,\"rainfall_mm\":2.89,\"wind_speed_kmh\":14.65,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-04 13:44:14'),
(1153, 16, '2026-06-04', 'current', 28.74, 28.74, 77, 1.05, 15.34, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.74,\"temp_max\":28.74,\"humidity\":77,\"rainfall_mm\":1.05,\"wind_speed_kmh\":15.34,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:15'),
(1154, 16, '2026-06-04', 'today', 28.38, 28.74, 76, 1.72, 15.34, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.38,\"temp_max\":28.74,\"humidity\":76,\"rainfall_mm\":1.72,\"wind_speed_kmh\":15.34,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:15'),
(1155, 16, '2026-06-05', 'tomorrow', 26.22, 36.62, 71, 7.67, 25.13, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.22,\"temp_max\":36.62,\"humidity\":71,\"rainfall_mm\":7.67,\"wind_speed_kmh\":25.13,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:15'),
(1156, 16, '2026-06-06', 'day_3', 27.30, 36.84, 74, 11.82, 23.29, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":27.3,\"temp_max\":36.84,\"humidity\":74,\"rainfall_mm\":11.82,\"wind_speed_kmh\":23.29,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:15'),
(1157, 16, '2026-06-07', 'day_4', 27.00, 35.76, 74, 13.37, 22.79, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":27,\"temp_max\":35.76,\"humidity\":74,\"rainfall_mm\":13.37,\"wind_speed_kmh\":22.79,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:15'),
(1158, 16, '2026-06-08', 'day_5', 28.60, 38.09, 69, 0.00, 23.69, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.6,\"temp_max\":38.09,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":23.69,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:15'),
(1159, 17, '2026-06-04', 'current', 28.69, 28.69, 79, 0.00, 6.62, 'Clear', '01n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.69,\"temp_max\":28.69,\"humidity\":79,\"rainfall_mm\":0,\"wind_speed_kmh\":6.62,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-04 13:44:16'),
(1160, 17, '2026-06-04', 'today', 27.72, 28.69, 82, 1.85, 9.32, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.72,\"temp_max\":28.69,\"humidity\":82,\"rainfall_mm\":1.85,\"wind_speed_kmh\":9.32,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:16'),
(1161, 17, '2026-06-05', 'tomorrow', 27.16, 34.11, 78, 4.46, 16.52, 'Rain', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.16,\"temp_max\":34.11,\"humidity\":78,\"rainfall_mm\":4.46,\"wind_speed_kmh\":16.52,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:16'),
(1162, 17, '2026-06-06', 'day_3', 26.95, 33.66, 77, 2.08, 22.21, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":26.95,\"temp_max\":33.66,\"humidity\":77,\"rainfall_mm\":2.08,\"wind_speed_kmh\":22.21,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:16'),
(1163, 17, '2026-06-07', 'day_4', 27.18, 32.69, 79, 10.57, 25.67, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":27.18,\"temp_max\":32.69,\"humidity\":79,\"rainfall_mm\":10.57,\"wind_speed_kmh\":25.67,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:16'),
(1164, 17, '2026-06-08', 'day_5', 27.27, 33.01, 81, 1.53, 24.70, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":27.27,\"temp_max\":33.01,\"humidity\":81,\"rainfall_mm\":1.53,\"wind_speed_kmh\":24.7,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:16'),
(1165, 18, '2026-06-04', 'current', 27.45, 27.45, 79, 0.00, 14.90, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":27.45,\"temp_max\":27.45,\"humidity\":79,\"rainfall_mm\":0,\"wind_speed_kmh\":14.9,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-04 13:44:17'),
(1166, 18, '2026-06-04', 'today', 26.12, 27.45, 83, 2.19, 16.02, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":26.12,\"temp_max\":27.45,\"humidity\":83,\"rainfall_mm\":2.19,\"wind_speed_kmh\":16.02,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-04 13:44:17'),
(1167, 18, '2026-06-05', 'tomorrow', 25.02, 35.57, 74, 4.53, 33.66, 'Rain', '01d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.02,\"temp_max\":35.57,\"humidity\":74,\"rainfall_mm\":4.53,\"wind_speed_kmh\":33.66,\"conditions\":\"Rain\",\"icon\":\"01d\"}', '2026-06-04 13:44:17'),
(1168, 18, '2026-06-06', 'day_3', 24.88, 35.65, 73, 17.18, 17.75, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":24.88,\"temp_max\":35.65,\"humidity\":73,\"rainfall_mm\":17.18,\"wind_speed_kmh\":17.75,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:17'),
(1169, 18, '2026-06-07', 'day_4', 24.75, 31.36, 86, 13.59, 19.22, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":24.75,\"temp_max\":31.36,\"humidity\":86,\"rainfall_mm\":13.59,\"wind_speed_kmh\":19.22,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:17'),
(1170, 18, '2026-06-08', 'day_5', 25.50, 33.44, 82, 16.31, 21.96, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":25.5,\"temp_max\":33.44,\"humidity\":82,\"rainfall_mm\":16.31,\"wind_speed_kmh\":21.96,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:17'),
(1171, 19, '2026-06-04', 'current', 27.32, 27.32, 86, 7.23, 10.58, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":27.32,\"temp_max\":27.32,\"humidity\":86,\"rainfall_mm\":7.23,\"wind_speed_kmh\":10.58,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:18'),
(1172, 19, '2026-06-04', 'today', 27.32, 27.52, 84, 7.82, 11.88, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.32,\"temp_max\":27.52,\"humidity\":84,\"rainfall_mm\":7.82,\"wind_speed_kmh\":11.88,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:18'),
(1173, 19, '2026-06-05', 'tomorrow', 27.02, 36.32, 70, 8.79, 24.77, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.02,\"temp_max\":36.32,\"humidity\":70,\"rainfall_mm\":8.79,\"wind_speed_kmh\":24.77,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:18'),
(1174, 19, '2026-06-06', 'day_3', 25.54, 36.44, 73, 15.22, 20.34, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":25.54,\"temp_max\":36.44,\"humidity\":73,\"rainfall_mm\":15.22,\"wind_speed_kmh\":20.34,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:18'),
(1175, 19, '2026-06-07', 'day_4', 25.57, 33.61, 80, 23.00, 24.16, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.57,\"temp_max\":33.61,\"humidity\":80,\"rainfall_mm\":23,\"wind_speed_kmh\":24.16,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:18'),
(1176, 19, '2026-06-08', 'day_5', 25.65, 34.98, 78, 12.69, 22.46, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":25.65,\"temp_max\":34.98,\"humidity\":78,\"rainfall_mm\":12.69,\"wind_speed_kmh\":22.46,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:18'),
(1177, 20, '2026-06-04', 'current', 28.85, 28.85, 75, 2.31, 8.60, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.85,\"temp_max\":28.85,\"humidity\":75,\"rainfall_mm\":2.31,\"wind_speed_kmh\":8.6,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:19'),
(1178, 20, '2026-06-04', 'today', 28.50, 28.85, 76, 3.65, 15.66, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.5,\"temp_max\":28.85,\"humidity\":76,\"rainfall_mm\":3.65,\"wind_speed_kmh\":15.66,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:19'),
(1179, 20, '2026-06-05', 'tomorrow', 26.81, 37.97, 71, 17.17, 17.75, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.81,\"temp_max\":37.97,\"humidity\":71,\"rainfall_mm\":17.17,\"wind_speed_kmh\":17.75,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:19'),
(1180, 20, '2026-06-06', 'day_3', 27.14, 37.15, 77, 23.49, 24.16, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":27.14,\"temp_max\":37.15,\"humidity\":77,\"rainfall_mm\":23.49,\"wind_speed_kmh\":24.16,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:19'),
(1181, 20, '2026-06-07', 'day_4', 27.62, 35.74, 74, 13.81, 18.40, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":27.62,\"temp_max\":35.74,\"humidity\":74,\"rainfall_mm\":13.81,\"wind_speed_kmh\":18.4,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:19'),
(1182, 20, '2026-06-08', 'day_5', 28.56, 38.52, 68, 0.00, 20.30, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.56,\"temp_max\":38.52,\"humidity\":68,\"rainfall_mm\":0,\"wind_speed_kmh\":20.3,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:19'),
(1183, 21, '2026-06-04', 'current', 29.02, 29.02, 75, 0.44, 3.74, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.02,\"temp_max\":29.02,\"humidity\":75,\"rainfall_mm\":0.44,\"wind_speed_kmh\":3.74,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:20'),
(1184, 21, '2026-06-04', 'today', 27.31, 29.02, 81, 4.44, 8.53, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.31,\"temp_max\":29.02,\"humidity\":81,\"rainfall_mm\":4.44,\"wind_speed_kmh\":8.53,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:20'),
(1185, 21, '2026-06-05', 'tomorrow', 26.15, 35.31, 73, 9.54, 10.01, 'Rain', '02d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.15,\"temp_max\":35.31,\"humidity\":73,\"rainfall_mm\":9.54,\"wind_speed_kmh\":10.01,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-04 13:44:20'),
(1186, 21, '2026-06-06', 'day_3', 24.79, 32.66, 82, 25.08, 15.59, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":24.79,\"temp_max\":32.66,\"humidity\":82,\"rainfall_mm\":25.08,\"wind_speed_kmh\":15.59,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:20'),
(1187, 21, '2026-06-07', 'day_4', 23.35, 31.76, 87, 61.33, 12.53, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":23.35,\"temp_max\":31.76,\"humidity\":87,\"rainfall_mm\":61.33,\"wind_speed_kmh\":12.53,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:20'),
(1188, 21, '2026-06-08', 'day_5', 24.98, 31.59, 89, 31.82, 11.56, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":24.98,\"temp_max\":31.59,\"humidity\":89,\"rainfall_mm\":31.82,\"wind_speed_kmh\":11.56,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:20'),
(1189, 22, '2026-06-04', 'current', 26.79, 26.79, 93, 9.10, 28.48, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":26.79,\"temp_max\":26.79,\"humidity\":93,\"rainfall_mm\":9.1,\"wind_speed_kmh\":28.48,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:20'),
(1190, 22, '2026-06-04', 'today', 26.79, 27.28, 90, 11.16, 28.48, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":26.79,\"temp_max\":27.28,\"humidity\":90,\"rainfall_mm\":11.16,\"wind_speed_kmh\":28.48,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:20'),
(1191, 22, '2026-06-05', 'tomorrow', 27.01, 35.70, 70, 5.73, 15.77, 'Clear', '01d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.01,\"temp_max\":35.7,\"humidity\":70,\"rainfall_mm\":5.73,\"wind_speed_kmh\":15.77,\"conditions\":\"Clear\",\"icon\":\"01d\"}', '2026-06-04 13:44:20'),
(1192, 22, '2026-06-06', 'day_3', 26.06, 35.02, 75, 22.69, 21.60, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":26.06,\"temp_max\":35.02,\"humidity\":75,\"rainfall_mm\":22.69,\"wind_speed_kmh\":21.6,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:20'),
(1193, 22, '2026-06-07', 'day_4', 25.87, 34.16, 82, 21.29, 23.00, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.87,\"temp_max\":34.16,\"humidity\":82,\"rainfall_mm\":21.29,\"wind_speed_kmh\":23,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:20'),
(1194, 22, '2026-06-08', 'day_5', 25.29, 33.58, 81, 10.16, 21.31, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":25.29,\"temp_max\":33.58,\"humidity\":81,\"rainfall_mm\":10.16,\"wind_speed_kmh\":21.31,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:20'),
(1195, 24, '2026-06-04', 'current', 30.52, 30.52, 71, 0.49, 13.00, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":30.52,\"temp_max\":30.52,\"humidity\":71,\"rainfall_mm\":0.49,\"wind_speed_kmh\":13,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:21'),
(1196, 24, '2026-06-04', 'today', 29.72, 30.52, 75, 0.96, 15.23, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.72,\"temp_max\":30.52,\"humidity\":75,\"rainfall_mm\":0.96,\"wind_speed_kmh\":15.23,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:21'),
(1197, 24, '2026-06-05', 'tomorrow', 29.29, 38.26, 68, 1.88, 23.33, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.29,\"temp_max\":38.26,\"humidity\":68,\"rainfall_mm\":1.88,\"wind_speed_kmh\":23.33,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:21'),
(1198, 24, '2026-06-06', 'day_3', 29.59, 37.57, 66, 0.30, 25.34, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":29.59,\"temp_max\":37.57,\"humidity\":66,\"rainfall_mm\":0.3,\"wind_speed_kmh\":25.34,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:21'),
(1199, 24, '2026-06-07', 'day_4', 29.74, 37.23, 65, 0.51, 25.09, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":29.74,\"temp_max\":37.23,\"humidity\":65,\"rainfall_mm\":0.51,\"wind_speed_kmh\":25.09,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:21'),
(1200, 24, '2026-06-08', 'day_5', 29.83, 37.94, 67, 0.00, 24.70, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":29.83,\"temp_max\":37.94,\"humidity\":67,\"rainfall_mm\":0,\"wind_speed_kmh\":24.7,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:21');
INSERT INTO `weather_forecasts` (`forecast_id`, `district_id`, `forecast_date`, `forecast_for`, `temp_min`, `temp_max`, `humidity`, `rainfall_mm`, `wind_speed_kmh`, `conditions`, `icon`, `raw_payload`, `fetched_at`) VALUES
(1201, 25, '2026-06-04', 'current', 28.09, 28.09, 74, 2.93, 13.90, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.09,\"temp_max\":28.09,\"humidity\":74,\"rainfall_mm\":2.93,\"wind_speed_kmh\":13.9,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:22'),
(1202, 25, '2026-06-04', 'today', 28.09, 28.82, 75, 6.09, 22.10, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.09,\"temp_max\":28.82,\"humidity\":75,\"rainfall_mm\":6.09,\"wind_speed_kmh\":22.1,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:22'),
(1203, 25, '2026-06-05', 'tomorrow', 28.23, 39.68, 65, 2.75, 33.70, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.23,\"temp_max\":39.68,\"humidity\":65,\"rainfall_mm\":2.75,\"wind_speed_kmh\":33.7,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:22'),
(1204, 25, '2026-06-06', 'day_3', 29.13, 40.51, 61, 0.00, 28.91, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":29.13,\"temp_max\":40.51,\"humidity\":61,\"rainfall_mm\":0,\"wind_speed_kmh\":28.91,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:22'),
(1205, 25, '2026-06-07', 'day_4', 28.59, 37.49, 65, 15.51, 20.88, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":28.59,\"temp_max\":37.49,\"humidity\":65,\"rainfall_mm\":15.51,\"wind_speed_kmh\":20.88,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:22'),
(1206, 25, '2026-06-08', 'day_5', 29.42, 40.63, 61, 0.00, 25.74, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":29.42,\"temp_max\":40.63,\"humidity\":61,\"rainfall_mm\":0,\"wind_speed_kmh\":25.74,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:22'),
(1207, 26, '2026-06-04', 'current', 29.26, 29.26, 74, 0.00, 22.75, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.26,\"temp_max\":29.26,\"humidity\":74,\"rainfall_mm\":0,\"wind_speed_kmh\":22.75,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-04 13:44:23'),
(1208, 26, '2026-06-04', 'today', 28.41, 29.26, 76, 0.00, 22.75, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.41,\"temp_max\":29.26,\"humidity\":76,\"rainfall_mm\":0,\"wind_speed_kmh\":22.75,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-04 13:44:23'),
(1209, 26, '2026-06-05', 'tomorrow', 27.17, 38.54, 66, 14.04, 25.16, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.17,\"temp_max\":38.54,\"humidity\":66,\"rainfall_mm\":14.04,\"wind_speed_kmh\":25.16,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:23'),
(1210, 26, '2026-06-06', 'day_3', 26.21, 36.23, 68, 7.85, 16.99, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":26.21,\"temp_max\":36.23,\"humidity\":68,\"rainfall_mm\":7.85,\"wind_speed_kmh\":16.99,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:23'),
(1211, 26, '2026-06-07', 'day_4', 26.25, 34.98, 77, 26.32, 34.63, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":26.25,\"temp_max\":34.98,\"humidity\":77,\"rainfall_mm\":26.32,\"wind_speed_kmh\":34.63,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:23'),
(1212, 26, '2026-06-08', 'day_5', 26.48, 37.02, 71, 1.47, 24.41, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":26.48,\"temp_max\":37.02,\"humidity\":71,\"rainfall_mm\":1.47,\"wind_speed_kmh\":24.41,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:23'),
(1213, 27, '2026-06-04', 'current', 25.36, 25.36, 91, 1.09, 2.63, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":25.36,\"temp_max\":25.36,\"humidity\":91,\"rainfall_mm\":1.09,\"wind_speed_kmh\":2.63,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:24'),
(1214, 27, '2026-06-04', 'today', 24.75, 25.36, 93, 1.47, 4.28, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":24.75,\"temp_max\":25.36,\"humidity\":93,\"rainfall_mm\":1.47,\"wind_speed_kmh\":4.28,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:24'),
(1215, 27, '2026-06-05', 'tomorrow', 24.47, 36.27, 74, 2.03, 8.71, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.47,\"temp_max\":36.27,\"humidity\":74,\"rainfall_mm\":2.03,\"wind_speed_kmh\":8.71,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:24'),
(1216, 27, '2026-06-06', 'day_3', 24.96, 35.39, 72, 0.26, 11.52, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":24.96,\"temp_max\":35.39,\"humidity\":72,\"rainfall_mm\":0.26,\"wind_speed_kmh\":11.52,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:24'),
(1217, 27, '2026-06-07', 'day_4', 24.72, 34.82, 80, 13.63, 13.10, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":24.72,\"temp_max\":34.82,\"humidity\":80,\"rainfall_mm\":13.63,\"wind_speed_kmh\":13.1,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:24'),
(1218, 27, '2026-06-08', 'day_5', 24.43, 32.57, 86, 13.27, 9.83, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":24.43,\"temp_max\":32.57,\"humidity\":86,\"rainfall_mm\":13.27,\"wind_speed_kmh\":9.83,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:24'),
(1219, 28, '2026-06-04', 'current', 27.82, 27.82, 73, 4.84, 6.26, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":27.82,\"temp_max\":27.82,\"humidity\":73,\"rainfall_mm\":4.84,\"wind_speed_kmh\":6.26,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:25'),
(1220, 28, '2026-06-04', 'today', 27.82, 28.63, 76, 6.72, 15.52, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.82,\"temp_max\":28.63,\"humidity\":76,\"rainfall_mm\":6.72,\"wind_speed_kmh\":15.52,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:25'),
(1221, 28, '2026-06-05', 'tomorrow', 26.14, 38.29, 69, 12.48, 37.04, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.14,\"temp_max\":38.29,\"humidity\":69,\"rainfall_mm\":12.48,\"wind_speed_kmh\":37.04,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:25'),
(1222, 28, '2026-06-06', 'day_3', 28.61, 37.67, 69, 0.17, 30.35, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":28.61,\"temp_max\":37.67,\"humidity\":69,\"rainfall_mm\":0.17,\"wind_speed_kmh\":30.35,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:25'),
(1223, 28, '2026-06-07', 'day_4', 29.28, 37.24, 68, 1.16, 24.95, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":29.28,\"temp_max\":37.24,\"humidity\":68,\"rainfall_mm\":1.16,\"wind_speed_kmh\":24.95,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:25'),
(1224, 28, '2026-06-08', 'day_5', 29.55, 39.43, 65, 1.01, 24.91, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":29.55,\"temp_max\":39.43,\"humidity\":65,\"rainfall_mm\":1.01,\"wind_speed_kmh\":24.91,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:25'),
(1225, 29, '2026-06-04', 'current', 27.56, 27.56, 85, 3.25, 18.43, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":27.56,\"temp_max\":27.56,\"humidity\":85,\"rainfall_mm\":3.25,\"wind_speed_kmh\":18.43,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:26'),
(1226, 29, '2026-06-04', 'today', 27.35, 27.56, 84, 9.12, 18.43, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.35,\"temp_max\":27.56,\"humidity\":84,\"rainfall_mm\":9.12,\"wind_speed_kmh\":18.43,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:26'),
(1227, 29, '2026-06-05', 'tomorrow', 26.76, 37.12, 71, 2.48, 25.42, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.76,\"temp_max\":37.12,\"humidity\":71,\"rainfall_mm\":2.48,\"wind_speed_kmh\":25.42,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:26'),
(1228, 29, '2026-06-06', 'day_3', 25.81, 35.71, 76, 40.98, 22.25, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":25.81,\"temp_max\":35.71,\"humidity\":76,\"rainfall_mm\":40.98,\"wind_speed_kmh\":22.25,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:26'),
(1229, 29, '2026-06-07', 'day_4', 25.11, 33.33, 85, 28.82, 23.58, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.11,\"temp_max\":33.33,\"humidity\":85,\"rainfall_mm\":28.82,\"wind_speed_kmh\":23.58,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:26'),
(1230, 29, '2026-06-08', 'day_5', 25.53, 34.82, 82, 13.39, 19.12, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":25.53,\"temp_max\":34.82,\"humidity\":82,\"rainfall_mm\":13.39,\"wind_speed_kmh\":19.12,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:26'),
(1231, 30, '2026-06-04', 'current', 26.76, 26.76, 83, 1.02, 7.78, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":26.76,\"temp_max\":26.76,\"humidity\":83,\"rainfall_mm\":1.02,\"wind_speed_kmh\":7.78,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:26'),
(1232, 30, '2026-06-04', 'today', 25.35, 26.76, 85, 9.67, 17.50, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":25.35,\"temp_max\":26.76,\"humidity\":85,\"rainfall_mm\":9.67,\"wind_speed_kmh\":17.5,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:26'),
(1233, 30, '2026-06-05', 'tomorrow', 25.36, 34.54, 75, 10.39, 13.93, 'Rain', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.36,\"temp_max\":34.54,\"humidity\":75,\"rainfall_mm\":10.39,\"wind_speed_kmh\":13.93,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-04 13:44:26'),
(1234, 30, '2026-06-06', 'day_3', 24.83, 32.97, 78, 20.10, 28.33, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":24.83,\"temp_max\":32.97,\"humidity\":78,\"rainfall_mm\":20.1,\"wind_speed_kmh\":28.33,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:26'),
(1235, 30, '2026-06-07', 'day_4', 25.40, 30.86, 83, 5.52, 20.63, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.4,\"temp_max\":30.86,\"humidity\":83,\"rainfall_mm\":5.52,\"wind_speed_kmh\":20.63,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:26'),
(1236, 30, '2026-06-08', 'day_5', 25.87, 32.31, 83, 20.33, 19.76, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":25.87,\"temp_max\":32.31,\"humidity\":83,\"rainfall_mm\":20.33,\"wind_speed_kmh\":19.76,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:26'),
(1237, 31, '2026-06-04', 'current', 30.19, 30.19, 70, 0.53, 28.04, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":30.19,\"temp_max\":30.19,\"humidity\":70,\"rainfall_mm\":0.53,\"wind_speed_kmh\":28.04,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:27'),
(1238, 31, '2026-06-04', 'today', 28.99, 30.19, 72, 1.36, 28.04, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.99,\"temp_max\":30.19,\"humidity\":72,\"rainfall_mm\":1.36,\"wind_speed_kmh\":28.04,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:27'),
(1239, 31, '2026-06-05', 'tomorrow', 27.50, 39.75, 66, 13.23, 19.76, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.5,\"temp_max\":39.75,\"humidity\":66,\"rainfall_mm\":13.23,\"wind_speed_kmh\":19.76,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:27'),
(1240, 31, '2026-06-06', 'day_3', 27.43, 41.17, 61, 19.26, 19.51, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":27.43,\"temp_max\":41.17,\"humidity\":61,\"rainfall_mm\":19.26,\"wind_speed_kmh\":19.51,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:27'),
(1241, 31, '2026-06-07', 'day_4', 27.61, 39.06, 69, 23.25, 29.45, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":27.61,\"temp_max\":39.06,\"humidity\":69,\"rainfall_mm\":23.25,\"wind_speed_kmh\":29.45,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:27'),
(1242, 31, '2026-06-08', 'day_5', 28.03, 38.99, 58, 0.00, 22.93, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.03,\"temp_max\":38.99,\"humidity\":58,\"rainfall_mm\":0,\"wind_speed_kmh\":22.93,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:27'),
(1243, 32, '2026-06-04', 'current', 30.43, 30.43, 73, 0.62, 13.82, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":30.43,\"temp_max\":30.43,\"humidity\":73,\"rainfall_mm\":0.62,\"wind_speed_kmh\":13.82,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:28'),
(1244, 32, '2026-06-04', 'today', 29.94, 30.43, 76, 0.93, 13.82, 'Rain', '04n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.94,\"temp_max\":30.43,\"humidity\":76,\"rainfall_mm\":0.93,\"wind_speed_kmh\":13.82,\"conditions\":\"Rain\",\"icon\":\"04n\"}', '2026-06-04 13:44:28'),
(1245, 32, '2026-06-05', 'tomorrow', 29.23, 34.58, 72, 6.98, 21.38, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.23,\"temp_max\":34.58,\"humidity\":72,\"rainfall_mm\":6.98,\"wind_speed_kmh\":21.38,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:28'),
(1246, 32, '2026-06-06', 'day_3', 29.66, 34.52, 75, 1.73, 27.94, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":29.66,\"temp_max\":34.52,\"humidity\":75,\"rainfall_mm\":1.73,\"wind_speed_kmh\":27.94,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:28'),
(1247, 32, '2026-06-07', 'day_4', 29.61, 33.82, 74, 3.43, 28.87, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":29.61,\"temp_max\":33.82,\"humidity\":74,\"rainfall_mm\":3.43,\"wind_speed_kmh\":28.87,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:28'),
(1248, 32, '2026-06-08', 'day_5', 29.69, 34.33, 74, 0.45, 26.03, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":29.69,\"temp_max\":34.33,\"humidity\":74,\"rainfall_mm\":0.45,\"wind_speed_kmh\":26.03,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:28'),
(1249, 33, '2026-06-04', 'current', 25.73, 25.73, 90, 2.01, 10.69, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":25.73,\"temp_max\":25.73,\"humidity\":90,\"rainfall_mm\":2.01,\"wind_speed_kmh\":10.69,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:29'),
(1250, 33, '2026-06-04', 'today', 24.84, 25.73, 91, 15.13, 11.38, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":24.84,\"temp_max\":25.73,\"humidity\":91,\"rainfall_mm\":15.13,\"wind_speed_kmh\":11.38,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:29'),
(1251, 33, '2026-06-05', 'tomorrow', 24.88, 34.89, 77, 15.08, 15.80, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.88,\"temp_max\":34.89,\"humidity\":77,\"rainfall_mm\":15.08,\"wind_speed_kmh\":15.8,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:29'),
(1252, 33, '2026-06-06', 'day_3', 24.89, 33.34, 78, 13.78, 22.97, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":24.89,\"temp_max\":33.34,\"humidity\":78,\"rainfall_mm\":13.78,\"wind_speed_kmh\":22.97,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:29'),
(1253, 33, '2026-06-07', 'day_4', 24.93, 31.59, 83, 8.00, 16.92, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":24.93,\"temp_max\":31.59,\"humidity\":83,\"rainfall_mm\":8,\"wind_speed_kmh\":16.92,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:29'),
(1254, 33, '2026-06-08', 'day_5', 25.33, 33.00, 82, 20.54, 14.22, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":25.33,\"temp_max\":33,\"humidity\":82,\"rainfall_mm\":20.54,\"wind_speed_kmh\":14.22,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:29'),
(1255, 34, '2026-06-04', 'current', 28.71, 28.71, 76, 1.34, 11.05, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.71,\"temp_max\":28.71,\"humidity\":76,\"rainfall_mm\":1.34,\"wind_speed_kmh\":11.05,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:30'),
(1256, 34, '2026-06-04', 'today', 28.21, 28.71, 75, 1.34, 15.08, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.21,\"temp_max\":28.71,\"humidity\":75,\"rainfall_mm\":1.34,\"wind_speed_kmh\":15.08,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-04 13:44:30'),
(1257, 34, '2026-06-05', 'tomorrow', 26.87, 37.47, 69, 3.74, 29.52, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.87,\"temp_max\":37.47,\"humidity\":69,\"rainfall_mm\":3.74,\"wind_speed_kmh\":29.52,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:30'),
(1258, 34, '2026-06-06', 'day_3', 27.89, 37.74, 72, 5.82, 26.89, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":27.89,\"temp_max\":37.74,\"humidity\":72,\"rainfall_mm\":5.82,\"wind_speed_kmh\":26.89,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:30'),
(1259, 34, '2026-06-07', 'day_4', 27.90, 36.45, 72, 8.73, 22.93, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":27.9,\"temp_max\":36.45,\"humidity\":72,\"rainfall_mm\":8.73,\"wind_speed_kmh\":22.93,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:30'),
(1260, 34, '2026-06-08', 'day_5', 28.54, 37.43, 69, 0.31, 22.00, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.54,\"temp_max\":37.43,\"humidity\":69,\"rainfall_mm\":0.31,\"wind_speed_kmh\":22,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:30'),
(1261, 35, '2026-06-04', 'current', 27.93, 27.93, 72, 1.28, 23.51, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":27.93,\"temp_max\":27.93,\"humidity\":72,\"rainfall_mm\":1.28,\"wind_speed_kmh\":23.51,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:31'),
(1262, 35, '2026-06-04', 'today', 27.93, 28.56, 73, 2.50, 23.51, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.93,\"temp_max\":28.56,\"humidity\":73,\"rainfall_mm\":2.5,\"wind_speed_kmh\":23.51,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:31'),
(1263, 35, '2026-06-05', 'tomorrow', 28.13, 39.15, 65, 8.60, 25.24, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.13,\"temp_max\":39.15,\"humidity\":65,\"rainfall_mm\":8.6,\"wind_speed_kmh\":25.24,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:31'),
(1264, 35, '2026-06-06', 'day_3', 28.89, 39.68, 63, 0.49, 29.48, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":28.89,\"temp_max\":39.68,\"humidity\":63,\"rainfall_mm\":0.49,\"wind_speed_kmh\":29.48,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:31'),
(1265, 35, '2026-06-07', 'day_4', 28.33, 37.85, 65, 10.38, 21.92, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":28.33,\"temp_max\":37.85,\"humidity\":65,\"rainfall_mm\":10.38,\"wind_speed_kmh\":21.92,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:31'),
(1266, 35, '2026-06-08', 'day_5', 29.58, 40.32, 60, 0.00, 23.87, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":29.58,\"temp_max\":40.32,\"humidity\":60,\"rainfall_mm\":0,\"wind_speed_kmh\":23.87,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:31'),
(1267, 36, '2026-06-04', 'current', 29.09, 29.09, 79, 5.90, 11.95, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.09,\"temp_max\":29.09,\"humidity\":79,\"rainfall_mm\":5.9,\"wind_speed_kmh\":11.95,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:32'),
(1268, 36, '2026-06-04', 'today', 28.30, 29.09, 78, 5.90, 13.00, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.3,\"temp_max\":29.09,\"humidity\":78,\"rainfall_mm\":5.9,\"wind_speed_kmh\":13,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-04 13:44:32'),
(1269, 36, '2026-06-05', 'tomorrow', 27.78, 37.56, 66, 2.19, 19.48, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.78,\"temp_max\":37.56,\"humidity\":66,\"rainfall_mm\":2.19,\"wind_speed_kmh\":19.48,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:32'),
(1270, 36, '2026-06-06', 'day_3', 27.03, 37.91, 70, 23.73, 24.41, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":27.03,\"temp_max\":37.91,\"humidity\":70,\"rainfall_mm\":23.73,\"wind_speed_kmh\":24.41,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:32'),
(1271, 36, '2026-06-07', 'day_4', 27.03, 35.32, 76, 19.11, 28.51, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":27.03,\"temp_max\":35.32,\"humidity\":76,\"rainfall_mm\":19.11,\"wind_speed_kmh\":28.51,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:32'),
(1272, 36, '2026-06-08', 'day_5', 26.91, 36.87, 72, 2.76, 26.64, 'Rain', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":26.91,\"temp_max\":36.87,\"humidity\":72,\"rainfall_mm\":2.76,\"wind_speed_kmh\":26.64,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:32'),
(1273, 37, '2026-06-04', 'current', 30.30, 30.30, 69, 0.00, 21.92, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":30.3,\"temp_max\":30.3,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":21.92,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-04 13:44:32'),
(1274, 37, '2026-06-04', 'today', 29.14, 30.30, 70, 0.26, 21.92, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.14,\"temp_max\":30.3,\"humidity\":70,\"rainfall_mm\":0.26,\"wind_speed_kmh\":21.92,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-04 13:44:32'),
(1275, 37, '2026-06-05', 'tomorrow', 27.22, 39.32, 67, 25.60, 21.13, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.22,\"temp_max\":39.32,\"humidity\":67,\"rainfall_mm\":25.6,\"wind_speed_kmh\":21.13,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:32'),
(1276, 37, '2026-06-06', 'day_3', 25.95, 40.46, 66, 27.57, 26.60, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":25.95,\"temp_max\":40.46,\"humidity\":66,\"rainfall_mm\":27.57,\"wind_speed_kmh\":26.6,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:32'),
(1277, 37, '2026-06-07', 'day_4', 26.35, 39.73, 70, 10.47, 24.84, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":26.35,\"temp_max\":39.73,\"humidity\":70,\"rainfall_mm\":10.47,\"wind_speed_kmh\":24.84,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:32'),
(1278, 37, '2026-06-08', 'day_5', 28.73, 38.43, 61, 0.00, 22.28, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.73,\"temp_max\":38.43,\"humidity\":61,\"rainfall_mm\":0,\"wind_speed_kmh\":22.28,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:32'),
(1279, 38, '2026-06-04', 'current', 29.02, 29.02, 75, 0.44, 3.74, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.02,\"temp_max\":29.02,\"humidity\":75,\"rainfall_mm\":0.44,\"wind_speed_kmh\":3.74,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:33'),
(1280, 38, '2026-06-04', 'today', 27.31, 29.02, 81, 4.44, 8.53, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.31,\"temp_max\":29.02,\"humidity\":81,\"rainfall_mm\":4.44,\"wind_speed_kmh\":8.53,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:33'),
(1281, 38, '2026-06-05', 'tomorrow', 26.15, 35.31, 73, 9.54, 10.01, 'Rain', '02d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.15,\"temp_max\":35.31,\"humidity\":73,\"rainfall_mm\":9.54,\"wind_speed_kmh\":10.01,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-04 13:44:33'),
(1282, 38, '2026-06-06', 'day_3', 24.79, 32.66, 82, 25.08, 15.59, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":24.79,\"temp_max\":32.66,\"humidity\":82,\"rainfall_mm\":25.08,\"wind_speed_kmh\":15.59,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:33'),
(1283, 38, '2026-06-07', 'day_4', 23.35, 31.76, 87, 61.33, 12.53, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":23.35,\"temp_max\":31.76,\"humidity\":87,\"rainfall_mm\":61.33,\"wind_speed_kmh\":12.53,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:33'),
(1284, 38, '2026-06-08', 'day_5', 24.98, 31.59, 89, 31.82, 11.56, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":24.98,\"temp_max\":31.59,\"humidity\":89,\"rainfall_mm\":31.82,\"wind_speed_kmh\":11.56,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:33'),
(1285, 39, '2026-06-04', 'current', 29.07, 29.07, 76, 1.00, 8.82, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.07,\"temp_max\":29.07,\"humidity\":76,\"rainfall_mm\":1,\"wind_speed_kmh\":8.82,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:34'),
(1286, 39, '2026-06-04', 'today', 28.82, 29.07, 74, 1.00, 9.43, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.82,\"temp_max\":29.07,\"humidity\":74,\"rainfall_mm\":1,\"wind_speed_kmh\":9.43,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-04 13:44:34'),
(1287, 39, '2026-06-05', 'tomorrow', 27.72, 38.48, 65, 4.66, 28.12, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.72,\"temp_max\":38.48,\"humidity\":65,\"rainfall_mm\":4.66,\"wind_speed_kmh\":28.12,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-04 13:44:34'),
(1288, 39, '2026-06-06', 'day_3', 28.20, 37.00, 69, 7.41, 26.06, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":28.2,\"temp_max\":37,\"humidity\":69,\"rainfall_mm\":7.41,\"wind_speed_kmh\":26.06,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:34'),
(1289, 39, '2026-06-07', 'day_4', 28.21, 33.97, 74, 11.59, 23.98, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":28.21,\"temp_max\":33.97,\"humidity\":74,\"rainfall_mm\":11.59,\"wind_speed_kmh\":23.98,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:34'),
(1290, 39, '2026-06-08', 'day_5', 28.74, 36.00, 72, 1.70, 24.08, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.74,\"temp_max\":36,\"humidity\":72,\"rainfall_mm\":1.7,\"wind_speed_kmh\":24.08,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:34'),
(1291, 40, '2026-06-04', 'current', 27.69, 27.69, 85, 1.40, 3.67, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":27.69,\"temp_max\":27.69,\"humidity\":85,\"rainfall_mm\":1.4,\"wind_speed_kmh\":3.67,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:35'),
(1292, 40, '2026-06-04', 'today', 26.83, 27.69, 85, 2.71, 7.96, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":26.83,\"temp_max\":27.69,\"humidity\":85,\"rainfall_mm\":2.71,\"wind_speed_kmh\":7.96,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:35'),
(1293, 40, '2026-06-05', 'tomorrow', 26.57, 36.42, 73, 4.82, 24.55, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.57,\"temp_max\":36.42,\"humidity\":73,\"rainfall_mm\":4.82,\"wind_speed_kmh\":24.55,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:35'),
(1294, 40, '2026-06-06', 'day_3', 25.15, 35.06, 77, 41.33, 18.76, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":25.15,\"temp_max\":35.06,\"humidity\":77,\"rainfall_mm\":41.33,\"wind_speed_kmh\":18.76,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:35'),
(1295, 40, '2026-06-07', 'day_4', 25.28, 32.13, 85, 14.46, 21.17, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.28,\"temp_max\":32.13,\"humidity\":85,\"rainfall_mm\":14.46,\"wind_speed_kmh\":21.17,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:35'),
(1296, 40, '2026-06-08', 'day_5', 26.00, 32.88, 86, 13.84, 17.42, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":26,\"temp_max\":32.88,\"humidity\":86,\"rainfall_mm\":13.84,\"wind_speed_kmh\":17.42,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:35'),
(1297, 41, '2026-06-04', 'current', 30.31, 30.31, 68, 0.00, 25.63, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":30.31,\"temp_max\":30.31,\"humidity\":68,\"rainfall_mm\":0,\"wind_speed_kmh\":25.63,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-04 13:44:36'),
(1298, 41, '2026-06-04', 'today', 29.12, 30.31, 70, 0.00, 25.63, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.12,\"temp_max\":30.31,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":25.63,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-04 13:44:36'),
(1299, 41, '2026-06-05', 'tomorrow', 27.46, 39.68, 62, 5.15, 20.84, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.46,\"temp_max\":39.68,\"humidity\":62,\"rainfall_mm\":5.15,\"wind_speed_kmh\":20.84,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:36'),
(1300, 41, '2026-06-06', 'day_3', 26.16, 37.38, 68, 21.80, 22.64, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":26.16,\"temp_max\":37.38,\"humidity\":68,\"rainfall_mm\":21.8,\"wind_speed_kmh\":22.64,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:36'),
(1301, 41, '2026-06-07', 'day_4', 25.88, 36.24, 72, 46.73, 18.04, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.88,\"temp_max\":36.24,\"humidity\":72,\"rainfall_mm\":46.73,\"wind_speed_kmh\":18.04,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:36'),
(1302, 41, '2026-06-08', 'day_5', 27.51, 38.08, 62, 0.00, 25.02, 'Clouds', '01d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":27.51,\"temp_max\":38.08,\"humidity\":62,\"rainfall_mm\":0,\"wind_speed_kmh\":25.02,\"conditions\":\"Clouds\",\"icon\":\"01d\"}', '2026-06-04 13:44:36'),
(1303, 42, '2026-06-04', 'current', 29.03, 29.03, 75, 4.24, 10.55, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.03,\"temp_max\":29.03,\"humidity\":75,\"rainfall_mm\":4.24,\"wind_speed_kmh\":10.55,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:37'),
(1304, 42, '2026-06-04', 'today', 28.65, 29.03, 76, 5.60, 17.17, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.65,\"temp_max\":29.03,\"humidity\":76,\"rainfall_mm\":5.6,\"wind_speed_kmh\":17.17,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:37'),
(1305, 42, '2026-06-05', 'tomorrow', 26.95, 38.28, 70, 24.51, 16.63, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.95,\"temp_max\":38.28,\"humidity\":70,\"rainfall_mm\":24.51,\"wind_speed_kmh\":16.63,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:37'),
(1306, 42, '2026-06-06', 'day_3', 26.67, 37.23, 76, 20.49, 25.92, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":26.67,\"temp_max\":37.23,\"humidity\":76,\"rainfall_mm\":20.49,\"wind_speed_kmh\":25.92,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:37'),
(1307, 42, '2026-06-07', 'day_4', 27.85, 36.32, 72, 14.70, 18.86, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":27.85,\"temp_max\":36.32,\"humidity\":72,\"rainfall_mm\":14.7,\"wind_speed_kmh\":18.86,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:37'),
(1308, 42, '2026-06-08', 'day_5', 28.74, 38.50, 67, 0.00, 19.44, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.74,\"temp_max\":38.5,\"humidity\":67,\"rainfall_mm\":0,\"wind_speed_kmh\":19.44,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-04 13:44:37'),
(1309, 43, '2026-06-04', 'current', 29.32, 29.32, 74, 1.23, 9.32, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.32,\"temp_max\":29.32,\"humidity\":74,\"rainfall_mm\":1.23,\"wind_speed_kmh\":9.32,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:37'),
(1310, 43, '2026-06-04', 'today', 29.13, 29.38, 72, 1.23, 9.32, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.13,\"temp_max\":29.38,\"humidity\":72,\"rainfall_mm\":1.23,\"wind_speed_kmh\":9.32,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-04 13:44:37'),
(1311, 43, '2026-06-05', 'tomorrow', 28.13, 38.27, 63, 4.88, 26.17, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.13,\"temp_max\":38.27,\"humidity\":63,\"rainfall_mm\":4.88,\"wind_speed_kmh\":26.17,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:37'),
(1312, 43, '2026-06-06', 'day_3', 28.35, 37.13, 68, 7.78, 25.16, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":28.35,\"temp_max\":37.13,\"humidity\":68,\"rainfall_mm\":7.78,\"wind_speed_kmh\":25.16,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:37'),
(1313, 43, '2026-06-07', 'day_4', 28.00, 34.00, 73, 13.45, 23.26, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":28,\"temp_max\":34,\"humidity\":73,\"rainfall_mm\":13.45,\"wind_speed_kmh\":23.26,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:37'),
(1314, 43, '2026-06-08', 'day_5', 28.69, 35.92, 72, 2.81, 23.72, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.69,\"temp_max\":35.92,\"humidity\":72,\"rainfall_mm\":2.81,\"wind_speed_kmh\":23.72,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:37'),
(1315, 44, '2026-06-04', 'current', 29.07, 29.07, 76, 1.00, 8.82, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.07,\"temp_max\":29.07,\"humidity\":76,\"rainfall_mm\":1,\"wind_speed_kmh\":8.82,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:38'),
(1316, 44, '2026-06-04', 'today', 28.82, 29.07, 74, 1.00, 9.43, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.82,\"temp_max\":29.07,\"humidity\":74,\"rainfall_mm\":1,\"wind_speed_kmh\":9.43,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-04 13:44:38'),
(1317, 44, '2026-06-05', 'tomorrow', 27.72, 38.48, 65, 4.66, 28.12, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.72,\"temp_max\":38.48,\"humidity\":65,\"rainfall_mm\":4.66,\"wind_speed_kmh\":28.12,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-04 13:44:38'),
(1318, 44, '2026-06-06', 'day_3', 28.20, 37.00, 69, 7.41, 26.06, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":28.2,\"temp_max\":37,\"humidity\":69,\"rainfall_mm\":7.41,\"wind_speed_kmh\":26.06,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:38'),
(1319, 44, '2026-06-07', 'day_4', 28.21, 33.97, 74, 11.59, 23.98, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":28.21,\"temp_max\":33.97,\"humidity\":74,\"rainfall_mm\":11.59,\"wind_speed_kmh\":23.98,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:38'),
(1320, 44, '2026-06-08', 'day_5', 28.74, 36.00, 72, 1.70, 24.08, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.74,\"temp_max\":36,\"humidity\":72,\"rainfall_mm\":1.7,\"wind_speed_kmh\":24.08,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:38'),
(1321, 45, '2026-06-04', 'current', 31.25, 31.25, 62, 0.00, 17.89, 'Clear', '01n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":31.25,\"temp_max\":31.25,\"humidity\":62,\"rainfall_mm\":0,\"wind_speed_kmh\":17.89,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-04 13:44:39'),
(1322, 45, '2026-06-04', 'today', 29.55, 31.25, 64, 0.00, 22.32, 'Clear', '01n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.55,\"temp_max\":31.25,\"humidity\":64,\"rainfall_mm\":0,\"wind_speed_kmh\":22.32,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-04 13:44:39'),
(1323, 45, '2026-06-05', 'tomorrow', 27.76, 40.41, 60, 2.38, 23.58, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.76,\"temp_max\":40.41,\"humidity\":60,\"rainfall_mm\":2.38,\"wind_speed_kmh\":23.58,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:39'),
(1324, 45, '2026-06-06', 'day_3', 27.22, 41.16, 60, 11.05, 22.36, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":27.22,\"temp_max\":41.16,\"humidity\":60,\"rainfall_mm\":11.05,\"wind_speed_kmh\":22.36,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:39'),
(1325, 45, '2026-06-07', 'day_4', 26.45, 38.26, 68, 25.33, 20.70, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":26.45,\"temp_max\":38.26,\"humidity\":68,\"rainfall_mm\":25.33,\"wind_speed_kmh\":20.7,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:39'),
(1326, 45, '2026-06-08', 'day_5', 27.48, 39.32, 58, 0.84, 20.77, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":27.48,\"temp_max\":39.32,\"humidity\":58,\"rainfall_mm\":0.84,\"wind_speed_kmh\":20.77,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:39'),
(1327, 46, '2026-06-04', 'current', 27.92, 27.92, 84, 1.86, 7.42, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":27.92,\"temp_max\":27.92,\"humidity\":84,\"rainfall_mm\":1.86,\"wind_speed_kmh\":7.42,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:40'),
(1328, 46, '2026-06-04', 'today', 26.98, 27.92, 86, 3.15, 7.49, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":26.98,\"temp_max\":27.92,\"humidity\":86,\"rainfall_mm\":3.15,\"wind_speed_kmh\":7.49,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:40'),
(1329, 46, '2026-06-05', 'tomorrow', 26.37, 35.68, 71, 4.97, 12.06, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.37,\"temp_max\":35.68,\"humidity\":71,\"rainfall_mm\":4.97,\"wind_speed_kmh\":12.06,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:40'),
(1330, 46, '2026-06-06', 'day_3', 24.67, 34.86, 79, 52.05, 19.66, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":24.67,\"temp_max\":34.86,\"humidity\":79,\"rainfall_mm\":52.05,\"wind_speed_kmh\":19.66,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:40'),
(1331, 46, '2026-06-07', 'day_4', 24.50, 31.16, 87, 37.61, 19.26, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":24.5,\"temp_max\":31.16,\"humidity\":87,\"rainfall_mm\":37.61,\"wind_speed_kmh\":19.26,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:40'),
(1332, 46, '2026-06-08', 'day_5', 25.12, 31.88, 88, 23.84, 19.91, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":25.12,\"temp_max\":31.88,\"humidity\":88,\"rainfall_mm\":23.84,\"wind_speed_kmh\":19.91,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:40'),
(1333, 47, '2026-06-04', 'current', 29.29, 29.29, 73, 0.00, 16.49, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.29,\"temp_max\":29.29,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":16.49,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-04 13:44:41'),
(1334, 47, '2026-06-04', 'today', 27.80, 29.29, 76, 1.43, 21.24, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.8,\"temp_max\":29.29,\"humidity\":76,\"rainfall_mm\":1.43,\"wind_speed_kmh\":21.24,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-04 13:44:41'),
(1335, 47, '2026-06-05', 'tomorrow', 25.26, 37.21, 68, 14.10, 17.21, 'Rain', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.26,\"temp_max\":37.21,\"humidity\":68,\"rainfall_mm\":14.1,\"wind_speed_kmh\":17.21,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-04 13:44:41'),
(1336, 47, '2026-06-06', 'day_3', 24.96, 35.25, 71, 11.40, 18.29, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":24.96,\"temp_max\":35.25,\"humidity\":71,\"rainfall_mm\":11.4,\"wind_speed_kmh\":18.29,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:41'),
(1337, 47, '2026-06-07', 'day_4', 26.22, 33.56, 78, 6.68, 16.99, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":26.22,\"temp_max\":33.56,\"humidity\":78,\"rainfall_mm\":6.68,\"wind_speed_kmh\":16.99,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:41'),
(1338, 47, '2026-06-08', 'day_5', 26.09, 35.51, 76, 6.58, 13.90, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":26.09,\"temp_max\":35.51,\"humidity\":76,\"rainfall_mm\":6.58,\"wind_speed_kmh\":13.9,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:41'),
(1339, 48, '2026-06-04', 'current', 30.18, 30.18, 74, 0.00, 13.79, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":30.18,\"temp_max\":30.18,\"humidity\":74,\"rainfall_mm\":0,\"wind_speed_kmh\":13.79,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-04 13:44:42'),
(1340, 48, '2026-06-04', 'today', 29.56, 30.18, 77, 1.57, 13.79, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.56,\"temp_max\":30.18,\"humidity\":77,\"rainfall_mm\":1.57,\"wind_speed_kmh\":13.79,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:42'),
(1341, 48, '2026-06-05', 'tomorrow', 28.87, 32.74, 78, 7.65, 19.58, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.87,\"temp_max\":32.74,\"humidity\":78,\"rainfall_mm\":7.65,\"wind_speed_kmh\":19.58,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:42'),
(1342, 48, '2026-06-06', 'day_3', 29.05, 31.90, 81, 4.39, 30.20, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":29.05,\"temp_max\":31.9,\"humidity\":81,\"rainfall_mm\":4.39,\"wind_speed_kmh\":30.2,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:42'),
(1343, 48, '2026-06-07', 'day_4', 28.77, 31.25, 81, 9.80, 27.76, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":28.77,\"temp_max\":31.25,\"humidity\":81,\"rainfall_mm\":9.8,\"wind_speed_kmh\":27.76,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:42'),
(1344, 48, '2026-06-08', 'day_5', 29.15, 31.56, 84, 2.69, 27.97, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":29.15,\"temp_max\":31.56,\"humidity\":84,\"rainfall_mm\":2.69,\"wind_speed_kmh\":27.97,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:42'),
(1345, 49, '2026-06-04', 'current', 30.04, 30.04, 70, 0.00, 20.41, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":30.04,\"temp_max\":30.04,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":20.41,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-04 13:44:43'),
(1346, 49, '2026-06-04', 'today', 29.03, 30.04, 71, 0.00, 20.41, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.03,\"temp_max\":30.04,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":20.41,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-04 13:44:43'),
(1347, 49, '2026-06-05', 'tomorrow', 26.03, 39.85, 66, 40.98, 20.48, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.03,\"temp_max\":39.85,\"humidity\":66,\"rainfall_mm\":40.98,\"wind_speed_kmh\":20.48,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:43'),
(1348, 49, '2026-06-06', 'day_3', 26.27, 38.64, 70, 21.56, 24.55, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":26.27,\"temp_max\":38.64,\"humidity\":70,\"rainfall_mm\":21.56,\"wind_speed_kmh\":24.55,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:43'),
(1349, 49, '2026-06-07', 'day_4', 26.63, 38.65, 69, 11.89, 17.06, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":26.63,\"temp_max\":38.65,\"humidity\":69,\"rainfall_mm\":11.89,\"wind_speed_kmh\":17.06,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:43'),
(1350, 49, '2026-06-08', 'day_5', 28.22, 38.58, 64, 0.18, 25.09, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.22,\"temp_max\":38.58,\"humidity\":64,\"rainfall_mm\":0.18,\"wind_speed_kmh\":25.09,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-04 13:44:43'),
(1351, 50, '2026-06-04', 'current', 29.79, 29.79, 70, 0.00, 17.39, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.79,\"temp_max\":29.79,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":17.39,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-04 13:44:44'),
(1352, 50, '2026-06-04', 'today', 26.31, 29.79, 76, 5.39, 17.39, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":26.31,\"temp_max\":29.79,\"humidity\":76,\"rainfall_mm\":5.39,\"wind_speed_kmh\":17.39,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:44'),
(1353, 50, '2026-06-05', 'tomorrow', 24.73, 35.11, 75, 10.22, 17.50, 'Rain', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.73,\"temp_max\":35.11,\"humidity\":75,\"rainfall_mm\":10.22,\"wind_speed_kmh\":17.5,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-04 13:44:44'),
(1354, 50, '2026-06-06', 'day_3', 24.34, 34.43, 77, 14.00, 14.08, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":24.34,\"temp_max\":34.43,\"humidity\":77,\"rainfall_mm\":14,\"wind_speed_kmh\":14.08,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:44'),
(1355, 50, '2026-06-07', 'day_4', 25.18, 33.40, 80, 7.89, 16.85, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.18,\"temp_max\":33.4,\"humidity\":80,\"rainfall_mm\":7.89,\"wind_speed_kmh\":16.85,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:44'),
(1356, 50, '2026-06-08', 'day_5', 25.01, 32.92, 80, 16.42, 16.31, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":25.01,\"temp_max\":32.92,\"humidity\":80,\"rainfall_mm\":16.42,\"wind_speed_kmh\":16.31,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:44'),
(1357, 51, '2026-06-04', 'current', 30.45, 30.45, 80, 0.00, 14.40, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":30.45,\"temp_max\":30.45,\"humidity\":80,\"rainfall_mm\":0,\"wind_speed_kmh\":14.4,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-04 13:44:44'),
(1358, 51, '2026-06-04', 'today', 29.94, 30.45, 81, 0.10, 14.83, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.94,\"temp_max\":30.45,\"humidity\":81,\"rainfall_mm\":0.1,\"wind_speed_kmh\":14.83,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-04 13:44:44'),
(1359, 51, '2026-06-05', 'tomorrow', 29.99, 34.21, 74, 1.14, 26.57, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.99,\"temp_max\":34.21,\"humidity\":74,\"rainfall_mm\":1.14,\"wind_speed_kmh\":26.57,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:44'),
(1360, 51, '2026-06-06', 'day_3', 29.92, 33.16, 77, 0.10, 28.04, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":29.92,\"temp_max\":33.16,\"humidity\":77,\"rainfall_mm\":0.1,\"wind_speed_kmh\":28.04,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:44');
INSERT INTO `weather_forecasts` (`forecast_id`, `district_id`, `forecast_date`, `forecast_for`, `temp_min`, `temp_max`, `humidity`, `rainfall_mm`, `wind_speed_kmh`, `conditions`, `icon`, `raw_payload`, `fetched_at`) VALUES
(1361, 51, '2026-06-07', 'day_4', 29.89, 33.43, 75, 0.38, 26.57, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":29.89,\"temp_max\":33.43,\"humidity\":75,\"rainfall_mm\":0.38,\"wind_speed_kmh\":26.57,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:44'),
(1362, 51, '2026-06-08', 'day_5', 30.16, 34.51, 75, 0.67, 26.50, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":30.16,\"temp_max\":34.51,\"humidity\":75,\"rainfall_mm\":0.67,\"wind_speed_kmh\":26.5,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:44'),
(1363, 52, '2026-06-04', 'current', 29.82, 29.82, 76, 0.84, 11.23, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.82,\"temp_max\":29.82,\"humidity\":76,\"rainfall_mm\":0.84,\"wind_speed_kmh\":11.23,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:45'),
(1364, 52, '2026-06-04', 'today', 29.06, 29.82, 79, 2.94, 15.34, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.06,\"temp_max\":29.82,\"humidity\":79,\"rainfall_mm\":2.94,\"wind_speed_kmh\":15.34,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:45'),
(1365, 52, '2026-06-05', 'tomorrow', 27.59, 38.00, 69, 6.91, 25.67, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.59,\"temp_max\":38,\"humidity\":69,\"rainfall_mm\":6.91,\"wind_speed_kmh\":25.67,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:45'),
(1366, 52, '2026-06-06', 'day_3', 29.15, 36.67, 69, 0.27, 26.10, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":29.15,\"temp_max\":36.67,\"humidity\":69,\"rainfall_mm\":0.27,\"wind_speed_kmh\":26.1,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:45'),
(1367, 52, '2026-06-07', 'day_4', 29.44, 36.72, 68, 0.13, 24.73, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":29.44,\"temp_max\":36.72,\"humidity\":68,\"rainfall_mm\":0.13,\"wind_speed_kmh\":24.73,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:45'),
(1368, 52, '2026-06-08', 'day_5', 29.57, 38.60, 68, 0.00, 24.70, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":29.57,\"temp_max\":38.6,\"humidity\":68,\"rainfall_mm\":0,\"wind_speed_kmh\":24.7,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:45'),
(1369, 53, '2026-06-04', 'current', 29.11, 29.11, 77, 2.73, 15.88, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.11,\"temp_max\":29.11,\"humidity\":77,\"rainfall_mm\":2.73,\"wind_speed_kmh\":15.88,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:46'),
(1370, 53, '2026-06-04', 'today', 28.62, 29.11, 77, 3.74, 17.82, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.62,\"temp_max\":29.11,\"humidity\":77,\"rainfall_mm\":3.74,\"wind_speed_kmh\":17.82,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:46'),
(1371, 53, '2026-06-05', 'tomorrow', 26.48, 37.77, 71, 19.94, 23.08, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.48,\"temp_max\":37.77,\"humidity\":71,\"rainfall_mm\":19.94,\"wind_speed_kmh\":23.08,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:46'),
(1372, 53, '2026-06-06', 'day_3', 26.92, 37.23, 75, 9.06, 29.02, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":26.92,\"temp_max\":37.23,\"humidity\":75,\"rainfall_mm\":9.06,\"wind_speed_kmh\":29.02,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:46'),
(1373, 53, '2026-06-07', 'day_4', 26.68, 35.83, 73, 12.59, 23.54, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":26.68,\"temp_max\":35.83,\"humidity\":73,\"rainfall_mm\":12.59,\"wind_speed_kmh\":23.54,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:46'),
(1374, 53, '2026-06-08', 'day_5', 28.70, 38.25, 67, 0.00, 21.71, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.7,\"temp_max\":38.25,\"humidity\":67,\"rainfall_mm\":0,\"wind_speed_kmh\":21.71,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:46'),
(1375, 54, '2026-06-04', 'current', 31.04, 31.04, 63, 0.00, 26.17, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":31.04,\"temp_max\":31.04,\"humidity\":63,\"rainfall_mm\":0,\"wind_speed_kmh\":26.17,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-04 13:44:47'),
(1376, 54, '2026-06-04', 'today', 29.22, 31.04, 65, 0.00, 26.17, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":29.22,\"temp_max\":31.04,\"humidity\":65,\"rainfall_mm\":0,\"wind_speed_kmh\":26.17,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-04 13:44:47'),
(1377, 54, '2026-06-05', 'tomorrow', 26.70, 39.54, 62, 1.09, 27.72, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.7,\"temp_max\":39.54,\"humidity\":62,\"rainfall_mm\":1.09,\"wind_speed_kmh\":27.72,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:47'),
(1378, 54, '2026-06-06', 'day_3', 26.19, 40.75, 64, 35.72, 21.46, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":26.19,\"temp_max\":40.75,\"humidity\":64,\"rainfall_mm\":35.72,\"wind_speed_kmh\":21.46,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:47'),
(1379, 54, '2026-06-07', 'day_4', 27.55, 38.36, 67, 3.41, 27.65, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":27.55,\"temp_max\":38.36,\"humidity\":67,\"rainfall_mm\":3.41,\"wind_speed_kmh\":27.65,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:47'),
(1380, 54, '2026-06-08', 'day_5', 27.49, 38.63, 57, 1.21, 22.07, 'Clouds', '01d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":27.49,\"temp_max\":38.63,\"humidity\":57,\"rainfall_mm\":1.21,\"wind_speed_kmh\":22.07,\"conditions\":\"Clouds\",\"icon\":\"01d\"}', '2026-06-04 13:44:47'),
(1381, 55, '2026-06-04', 'current', 27.96, 27.96, 88, 0.00, 6.01, 'Clear', '01n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":27.96,\"temp_max\":27.96,\"humidity\":88,\"rainfall_mm\":0,\"wind_speed_kmh\":6.01,\"conditions\":\"Clear\",\"icon\":\"01n\"}', '2026-06-04 13:44:48'),
(1382, 55, '2026-06-04', 'today', 26.33, 27.96, 91, 4.57, 6.01, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":26.33,\"temp_max\":27.96,\"humidity\":91,\"rainfall_mm\":4.57,\"wind_speed_kmh\":6.01,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:48'),
(1383, 55, '2026-06-05', 'tomorrow', 25.62, 35.60, 77, 5.09, 14.08, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.62,\"temp_max\":35.6,\"humidity\":77,\"rainfall_mm\":5.09,\"wind_speed_kmh\":14.08,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:48'),
(1384, 55, '2026-06-06', 'day_3', 25.98, 35.20, 74, 0.41, 17.86, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":25.98,\"temp_max\":35.2,\"humidity\":74,\"rainfall_mm\":0.41,\"wind_speed_kmh\":17.86,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:48'),
(1385, 55, '2026-06-07', 'day_4', 26.19, 35.80, 73, 4.32, 18.83, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":26.19,\"temp_max\":35.8,\"humidity\":73,\"rainfall_mm\":4.32,\"wind_speed_kmh\":18.83,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:48'),
(1386, 55, '2026-06-08', 'day_5', 25.76, 34.53, 79, 7.29, 18.47, 'Rain', '03d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":25.76,\"temp_max\":34.53,\"humidity\":79,\"rainfall_mm\":7.29,\"wind_speed_kmh\":18.47,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-04 13:44:48'),
(1387, 56, '2026-06-04', 'current', 28.31, 28.31, 79, 0.00, 12.78, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.31,\"temp_max\":28.31,\"humidity\":79,\"rainfall_mm\":0,\"wind_speed_kmh\":12.78,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-04 13:44:49'),
(1388, 56, '2026-06-04', 'today', 25.99, 28.31, 83, 5.50, 15.55, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":25.99,\"temp_max\":28.31,\"humidity\":83,\"rainfall_mm\":5.5,\"wind_speed_kmh\":15.55,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-04 13:44:49'),
(1389, 56, '2026-06-05', 'tomorrow', 24.85, 35.93, 71, 6.22, 15.52, 'Rain', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.85,\"temp_max\":35.93,\"humidity\":71,\"rainfall_mm\":6.22,\"wind_speed_kmh\":15.52,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-04 13:44:49'),
(1390, 56, '2026-06-06', 'day_3', 24.69, 34.54, 74, 14.51, 19.48, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":24.69,\"temp_max\":34.54,\"humidity\":74,\"rainfall_mm\":14.51,\"wind_speed_kmh\":19.48,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:49'),
(1391, 56, '2026-06-07', 'day_4', 25.08, 32.21, 83, 11.30, 16.60, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.08,\"temp_max\":32.21,\"humidity\":83,\"rainfall_mm\":11.3,\"wind_speed_kmh\":16.6,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:49'),
(1392, 56, '2026-06-08', 'day_5', 25.14, 34.13, 81, 16.30, 14.22, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":25.14,\"temp_max\":34.13,\"humidity\":81,\"rainfall_mm\":16.3,\"wind_speed_kmh\":14.22,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:49'),
(1393, 57, '2026-06-04', 'current', 28.54, 28.54, 75, 9.44, 5.80, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.54,\"temp_max\":28.54,\"humidity\":75,\"rainfall_mm\":9.44,\"wind_speed_kmh\":5.8,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:50'),
(1394, 57, '2026-06-04', 'today', 28.39, 29.01, 78, 14.04, 15.19, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.39,\"temp_max\":29.01,\"humidity\":78,\"rainfall_mm\":14.04,\"wind_speed_kmh\":15.19,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:50'),
(1395, 57, '2026-06-05', 'tomorrow', 27.64, 38.63, 71, 14.56, 32.44, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.64,\"temp_max\":38.63,\"humidity\":71,\"rainfall_mm\":14.56,\"wind_speed_kmh\":32.44,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:50'),
(1396, 57, '2026-06-06', 'day_3', 29.11, 39.25, 64, 0.00, 28.19, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":29.11,\"temp_max\":39.25,\"humidity\":64,\"rainfall_mm\":0,\"wind_speed_kmh\":28.19,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:50'),
(1397, 57, '2026-06-07', 'day_4', 29.70, 36.62, 66, 0.79, 22.82, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":29.7,\"temp_max\":36.62,\"humidity\":66,\"rainfall_mm\":0.79,\"wind_speed_kmh\":22.82,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:50'),
(1398, 57, '2026-06-08', 'day_5', 29.55, 41.15, 59, 0.00, 28.04, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":29.55,\"temp_max\":41.15,\"humidity\":59,\"rainfall_mm\":0,\"wind_speed_kmh\":28.04,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-04 13:44:50'),
(1399, 58, '2026-06-04', 'current', 28.61, 28.61, 78, 1.49, 9.18, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.61,\"temp_max\":28.61,\"humidity\":78,\"rainfall_mm\":1.49,\"wind_speed_kmh\":9.18,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:50'),
(1400, 58, '2026-06-04', 'today', 28.04, 28.61, 77, 1.49, 14.72, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.04,\"temp_max\":28.61,\"humidity\":77,\"rainfall_mm\":1.49,\"wind_speed_kmh\":14.72,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-04 13:44:50'),
(1401, 58, '2026-06-05', 'tomorrow', 26.68, 36.92, 68, 3.64, 31.64, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.68,\"temp_max\":36.92,\"humidity\":68,\"rainfall_mm\":3.64,\"wind_speed_kmh\":31.64,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-04 13:44:50'),
(1402, 58, '2026-06-06', 'day_3', 27.69, 37.14, 74, 7.57, 28.15, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":27.69,\"temp_max\":37.14,\"humidity\":74,\"rainfall_mm\":7.57,\"wind_speed_kmh\":28.15,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:50'),
(1403, 58, '2026-06-07', 'day_4', 28.03, 35.26, 75, 8.81, 20.88, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":28.03,\"temp_max\":35.26,\"humidity\":75,\"rainfall_mm\":8.81,\"wind_speed_kmh\":20.88,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:50'),
(1404, 58, '2026-06-08', 'day_5', 28.47, 36.81, 71, 0.16, 23.36, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":28.47,\"temp_max\":36.81,\"humidity\":71,\"rainfall_mm\":0.16,\"wind_speed_kmh\":23.36,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:50'),
(1405, 59, '2026-06-04', 'current', 27.53, 27.53, 85, 0.95, 16.99, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":27.53,\"temp_max\":27.53,\"humidity\":85,\"rainfall_mm\":0.95,\"wind_speed_kmh\":16.99,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:51'),
(1406, 59, '2026-06-04', 'today', 26.53, 27.53, 86, 2.91, 16.99, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":26.53,\"temp_max\":27.53,\"humidity\":86,\"rainfall_mm\":2.91,\"wind_speed_kmh\":16.99,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:51'),
(1407, 59, '2026-06-05', 'tomorrow', 26.37, 36.79, 70, 3.63, 18.94, 'Clear', '01d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.37,\"temp_max\":36.79,\"humidity\":70,\"rainfall_mm\":3.63,\"wind_speed_kmh\":18.94,\"conditions\":\"Clear\",\"icon\":\"01d\"}', '2026-06-04 13:44:51'),
(1408, 59, '2026-06-06', 'day_3', 25.69, 36.34, 73, 11.15, 18.54, 'Rain', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":25.69,\"temp_max\":36.34,\"humidity\":73,\"rainfall_mm\":11.15,\"wind_speed_kmh\":18.54,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:51'),
(1409, 59, '2026-06-07', 'day_4', 25.27, 33.35, 83, 19.09, 23.40, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.27,\"temp_max\":33.35,\"humidity\":83,\"rainfall_mm\":19.09,\"wind_speed_kmh\":23.4,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:51'),
(1410, 59, '2026-06-08', 'day_5', 25.41, 33.17, 82, 8.54, 19.44, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":25.41,\"temp_max\":33.17,\"humidity\":82,\"rainfall_mm\":8.54,\"wind_speed_kmh\":19.44,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:51'),
(1411, 60, '2026-06-04', 'current', 28.75, 28.75, 83, 4.39, 24.62, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.75,\"temp_max\":28.75,\"humidity\":83,\"rainfall_mm\":4.39,\"wind_speed_kmh\":24.62,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:52'),
(1412, 60, '2026-06-04', 'today', 28.75, 29.05, 80, 4.39, 24.62, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":28.75,\"temp_max\":29.05,\"humidity\":80,\"rainfall_mm\":4.39,\"wind_speed_kmh\":24.62,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-04 13:44:52'),
(1413, 60, '2026-06-05', 'tomorrow', 28.41, 33.57, 67, 4.69, 15.55, 'Clouds', '01d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.41,\"temp_max\":33.57,\"humidity\":67,\"rainfall_mm\":4.69,\"wind_speed_kmh\":15.55,\"conditions\":\"Clouds\",\"icon\":\"01d\"}', '2026-06-04 13:44:52'),
(1414, 60, '2026-06-06', 'day_3', 27.41, 32.76, 76, 18.07, 32.40, 'Rain', '03d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":27.41,\"temp_max\":32.76,\"humidity\":76,\"rainfall_mm\":18.07,\"wind_speed_kmh\":32.4,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-04 13:44:52'),
(1415, 60, '2026-06-07', 'day_4', 26.31, 33.61, 79, 15.44, 42.73, 'Rain', '04d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":26.31,\"temp_max\":33.61,\"humidity\":79,\"rainfall_mm\":15.44,\"wind_speed_kmh\":42.73,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:52'),
(1416, 60, '2026-06-08', 'day_5', 26.94, 34.14, 78, 2.46, 31.00, 'Rain', '03d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":26.94,\"temp_max\":34.14,\"humidity\":78,\"rainfall_mm\":2.46,\"wind_speed_kmh\":31,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-04 13:44:52'),
(1417, 61, '2026-06-04', 'current', 27.36, 27.36, 81, 1.47, 9.40, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":27.36,\"temp_max\":27.36,\"humidity\":81,\"rainfall_mm\":1.47,\"wind_speed_kmh\":9.4,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:53'),
(1418, 61, '2026-06-04', 'today', 25.62, 27.36, 84, 10.12, 9.40, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":25.62,\"temp_max\":27.36,\"humidity\":84,\"rainfall_mm\":10.12,\"wind_speed_kmh\":9.4,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:53'),
(1419, 61, '2026-06-05', 'tomorrow', 25.26, 34.21, 77, 17.06, 12.82, 'Rain', '10d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.26,\"temp_max\":34.21,\"humidity\":77,\"rainfall_mm\":17.06,\"wind_speed_kmh\":12.82,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:53'),
(1420, 61, '2026-06-06', 'day_3', 25.11, 32.46, 84, 52.10, 13.18, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":25.11,\"temp_max\":32.46,\"humidity\":84,\"rainfall_mm\":52.1,\"wind_speed_kmh\":13.18,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:53'),
(1421, 61, '2026-06-07', 'day_4', 23.65, 31.11, 86, 63.95, 16.56, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":23.65,\"temp_max\":31.11,\"humidity\":86,\"rainfall_mm\":63.95,\"wind_speed_kmh\":16.56,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:53'),
(1422, 61, '2026-06-08', 'day_5', 24.09, 31.06, 87, 34.45, 18.47, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":24.09,\"temp_max\":31.06,\"humidity\":87,\"rainfall_mm\":34.45,\"wind_speed_kmh\":18.47,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:53'),
(1423, 62, '2026-06-04', 'current', 28.23, 28.23, 75, 0.31, 9.76, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":28.23,\"temp_max\":28.23,\"humidity\":75,\"rainfall_mm\":0.31,\"wind_speed_kmh\":9.76,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:54'),
(1424, 62, '2026-06-04', 'today', 26.22, 28.23, 80, 9.81, 9.76, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":26.22,\"temp_max\":28.23,\"humidity\":80,\"rainfall_mm\":9.81,\"wind_speed_kmh\":9.76,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:54'),
(1425, 62, '2026-06-05', 'tomorrow', 25.52, 35.70, 74, 20.56, 11.66, 'Rain', '03d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.52,\"temp_max\":35.7,\"humidity\":74,\"rainfall_mm\":20.56,\"wind_speed_kmh\":11.66,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-04 13:44:54'),
(1426, 62, '2026-06-06', 'day_3', 25.15, 31.87, 84, 33.91, 13.21, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":25.15,\"temp_max\":31.87,\"humidity\":84,\"rainfall_mm\":33.91,\"wind_speed_kmh\":13.21,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:54'),
(1427, 62, '2026-06-07', 'day_4', 22.20, 31.37, 85, 62.83, 12.42, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":22.2,\"temp_max\":31.37,\"humidity\":85,\"rainfall_mm\":62.83,\"wind_speed_kmh\":12.42,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:54'),
(1428, 62, '2026-06-08', 'day_5', 24.15, 31.52, 87, 33.17, 15.88, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":24.15,\"temp_max\":31.52,\"humidity\":87,\"rainfall_mm\":33.17,\"wind_speed_kmh\":15.88,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:54'),
(1429, 63, '2026-06-04', 'current', 27.44, 27.44, 86, 8.32, 7.52, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":27.44,\"temp_max\":27.44,\"humidity\":86,\"rainfall_mm\":8.32,\"wind_speed_kmh\":7.52,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:54'),
(1430, 63, '2026-06-04', 'today', 27.44, 27.75, 83, 8.49, 13.03, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.44,\"temp_max\":27.75,\"humidity\":83,\"rainfall_mm\":8.49,\"wind_speed_kmh\":13.03,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:54'),
(1431, 63, '2026-06-05', 'tomorrow', 26.79, 38.27, 66, 13.11, 17.06, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.79,\"temp_max\":38.27,\"humidity\":66,\"rainfall_mm\":13.11,\"wind_speed_kmh\":17.06,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:54'),
(1432, 63, '2026-06-06', 'day_3', 26.14, 36.72, 71, 15.89, 17.35, 'Rain', '10d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":26.14,\"temp_max\":36.72,\"humidity\":71,\"rainfall_mm\":15.89,\"wind_speed_kmh\":17.35,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:54'),
(1433, 63, '2026-06-07', 'day_4', 25.99, 34.42, 78, 24.15, 20.88, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.99,\"temp_max\":34.42,\"humidity\":78,\"rainfall_mm\":24.15,\"wind_speed_kmh\":20.88,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:54'),
(1434, 63, '2026-06-08', 'day_5', 26.30, 37.53, 74, 8.95, 23.36, 'Rain', '04d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":26.3,\"temp_max\":37.53,\"humidity\":74,\"rainfall_mm\":8.95,\"wind_speed_kmh\":23.36,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-04 13:44:54'),
(1435, 64, '2026-06-04', 'current', 29.58, 29.58, 69, 0.36, 18.61, 'Rain', '10n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"current\",\"temp_min\":29.58,\"temp_max\":29.58,\"humidity\":69,\"rainfall_mm\":0.36,\"wind_speed_kmh\":18.61,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-04 13:44:55'),
(1436, 64, '2026-06-04', 'today', 27.80, 29.58, 73, 1.69, 18.61, 'Rain', '01n', '{\"forecast_date\":\"2026-06-04\",\"forecast_for\":\"today\",\"temp_min\":27.8,\"temp_max\":29.58,\"humidity\":73,\"rainfall_mm\":1.69,\"wind_speed_kmh\":18.61,\"conditions\":\"Rain\",\"icon\":\"01n\"}', '2026-06-04 13:44:55'),
(1437, 64, '2026-06-05', 'tomorrow', 25.25, 36.44, 69, 4.12, 20.70, 'Rain', '02d', '{\"forecast_date\":\"2026-06-05\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.25,\"temp_max\":36.44,\"humidity\":69,\"rainfall_mm\":4.12,\"wind_speed_kmh\":20.7,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-04 13:44:55'),
(1438, 64, '2026-06-06', 'day_3', 25.46, 36.32, 72, 8.30, 15.48, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-06\",\"forecast_for\":\"day_3\",\"temp_min\":25.46,\"temp_max\":36.32,\"humidity\":72,\"rainfall_mm\":8.3,\"wind_speed_kmh\":15.48,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-04 13:44:55'),
(1439, 64, '2026-06-07', 'day_4', 25.80, 33.37, 76, 1.90, 18.11, 'Rain', '10d', '{\"forecast_date\":\"2026-06-07\",\"forecast_for\":\"day_4\",\"temp_min\":25.8,\"temp_max\":33.37,\"humidity\":76,\"rainfall_mm\":1.9,\"wind_speed_kmh\":18.11,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:55'),
(1440, 64, '2026-06-08', 'day_5', 26.19, 35.88, 73, 8.75, 16.42, 'Rain', '10d', '{\"forecast_date\":\"2026-06-08\",\"forecast_for\":\"day_5\",\"temp_min\":26.19,\"temp_max\":35.88,\"humidity\":73,\"rainfall_mm\":8.75,\"wind_speed_kmh\":16.42,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-04 13:44:55'),
(1441, 1, '2026-06-09', 'current', 30.52, 32.58, 80, 0.00, 18.25, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":30.52,\"temp_max\":32.58,\"humidity\":80,\"rainfall_mm\":0,\"wind_speed_kmh\":18.25,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:16'),
(1442, 1, '2026-06-09', 'today', 26.61, 37.49, 71, 16.68, 25.06, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":26.61,\"temp_max\":37.49,\"humidity\":71,\"rainfall_mm\":16.68,\"wind_speed_kmh\":25.06,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:16'),
(1443, 1, '2026-06-10', 'tomorrow', 28.99, 38.41, 65, 0.00, 24.44, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.99,\"temp_max\":38.41,\"humidity\":65,\"rainfall_mm\":0,\"wind_speed_kmh\":24.44,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:16'),
(1444, 1, '2026-06-11', 'day_3', 29.52, 37.63, 64, 0.00, 24.73, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":29.52,\"temp_max\":37.63,\"humidity\":64,\"rainfall_mm\":0,\"wind_speed_kmh\":24.73,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:16'),
(1445, 1, '2026-06-12', 'day_4', 27.65, 34.82, 76, 14.94, 22.64, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.65,\"temp_max\":34.82,\"humidity\":76,\"rainfall_mm\":14.94,\"wind_speed_kmh\":22.64,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:16'),
(1446, 1, '2026-06-13', 'day_5', 26.77, 30.27, 84, 11.30, 21.06, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":26.77,\"temp_max\":30.27,\"humidity\":84,\"rainfall_mm\":11.3,\"wind_speed_kmh\":21.06,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:16'),
(1447, 2, '2026-06-09', 'current', 25.69, 29.50, 88, 0.29, 5.72, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":25.69,\"temp_max\":29.5,\"humidity\":88,\"rainfall_mm\":0.29,\"wind_speed_kmh\":5.72,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:17'),
(1448, 2, '2026-06-09', 'today', 23.91, 36.50, 81, 4.52, 10.69, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":23.91,\"temp_max\":36.5,\"humidity\":81,\"rainfall_mm\":4.52,\"wind_speed_kmh\":10.69,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:17'),
(1449, 2, '2026-06-10', 'tomorrow', 23.37, 35.79, 79, 7.33, 14.54, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":23.37,\"temp_max\":35.79,\"humidity\":79,\"rainfall_mm\":7.33,\"wind_speed_kmh\":14.54,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:17'),
(1450, 2, '2026-06-11', 'day_3', 24.45, 36.78, 75, 4.06, 15.12, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":24.45,\"temp_max\":36.78,\"humidity\":75,\"rainfall_mm\":4.06,\"wind_speed_kmh\":15.12,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:17'),
(1451, 2, '2026-06-12', 'day_4', 24.47, 35.68, 79, 4.54, 9.36, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":24.47,\"temp_max\":35.68,\"humidity\":79,\"rainfall_mm\":4.54,\"wind_speed_kmh\":9.36,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:17'),
(1452, 2, '2026-06-13', 'day_5', 23.84, 28.97, 88, 9.10, 8.35, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":23.84,\"temp_max\":28.97,\"humidity\":88,\"rainfall_mm\":9.1,\"wind_speed_kmh\":8.35,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:17'),
(1453, 3, '2026-06-09', 'current', 29.38, 31.11, 85, 0.00, 18.29, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.38,\"temp_max\":31.11,\"humidity\":85,\"rainfall_mm\":0,\"wind_speed_kmh\":18.29,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:17'),
(1454, 3, '2026-06-09', 'today', 28.99, 32.29, 81, 5.67, 26.82, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":28.99,\"temp_max\":32.29,\"humidity\":81,\"rainfall_mm\":5.67,\"wind_speed_kmh\":26.82,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:17'),
(1455, 3, '2026-06-10', 'tomorrow', 28.90, 32.74, 80, 0.71, 29.52, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.9,\"temp_max\":32.74,\"humidity\":80,\"rainfall_mm\":0.71,\"wind_speed_kmh\":29.52,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:17'),
(1456, 3, '2026-06-11', 'day_3', 28.75, 31.71, 81, 1.69, 29.16, 'Rain', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":28.75,\"temp_max\":31.71,\"humidity\":81,\"rainfall_mm\":1.69,\"wind_speed_kmh\":29.16,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:17'),
(1457, 3, '2026-06-12', 'day_4', 27.86, 31.65, 79, 23.15, 22.14, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.86,\"temp_max\":31.65,\"humidity\":79,\"rainfall_mm\":23.15,\"wind_speed_kmh\":22.14,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:17'),
(1458, 3, '2026-06-13', 'day_5', 26.44, 28.06, 87, 11.72, 25.49, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":26.44,\"temp_max\":28.06,\"humidity\":87,\"rainfall_mm\":11.72,\"wind_speed_kmh\":25.49,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:17'),
(1459, 4, '2026-06-09', 'current', 29.65, 32.62, 84, 0.00, 15.19, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.65,\"temp_max\":32.62,\"humidity\":84,\"rainfall_mm\":0,\"wind_speed_kmh\":15.19,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:17'),
(1460, 4, '2026-06-09', 'today', 29.05, 35.13, 74, 3.27, 22.50, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":29.05,\"temp_max\":35.13,\"humidity\":74,\"rainfall_mm\":3.27,\"wind_speed_kmh\":22.5,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:17'),
(1461, 4, '2026-06-10', 'tomorrow', 28.77, 36.30, 70, 0.63, 23.29, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.77,\"temp_max\":36.3,\"humidity\":70,\"rainfall_mm\":0.63,\"wind_speed_kmh\":23.29,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:17'),
(1462, 4, '2026-06-11', 'day_3', 28.51, 35.28, 74, 3.64, 24.41, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":28.51,\"temp_max\":35.28,\"humidity\":74,\"rainfall_mm\":3.64,\"wind_speed_kmh\":24.41,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:17'),
(1463, 4, '2026-06-12', 'day_4', 27.22, 32.46, 80, 43.34, 20.88, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.22,\"temp_max\":32.46,\"humidity\":80,\"rainfall_mm\":43.34,\"wind_speed_kmh\":20.88,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:17'),
(1464, 4, '2026-06-13', 'day_5', 25.70, 27.67, 91, 56.94, 19.19, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.7,\"temp_max\":27.67,\"humidity\":91,\"rainfall_mm\":56.94,\"wind_speed_kmh\":19.19,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:17'),
(1465, 5, '2026-06-09', 'current', 29.27, 31.26, 85, 0.00, 19.30, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.27,\"temp_max\":31.26,\"humidity\":85,\"rainfall_mm\":0,\"wind_speed_kmh\":19.3,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:18'),
(1466, 5, '2026-06-09', 'today', 28.79, 32.63, 81, 7.08, 26.75, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":28.79,\"temp_max\":32.63,\"humidity\":81,\"rainfall_mm\":7.08,\"wind_speed_kmh\":26.75,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:18'),
(1467, 5, '2026-06-10', 'tomorrow', 28.64, 33.04, 80, 1.04, 28.26, 'Clouds', '01d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.64,\"temp_max\":33.04,\"humidity\":80,\"rainfall_mm\":1.04,\"wind_speed_kmh\":28.26,\"conditions\":\"Clouds\",\"icon\":\"01d\"}', '2026-06-09 01:17:18'),
(1468, 5, '2026-06-11', 'day_3', 28.58, 31.99, 81, 1.91, 29.20, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":28.58,\"temp_max\":31.99,\"humidity\":81,\"rainfall_mm\":1.91,\"wind_speed_kmh\":29.2,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:18'),
(1469, 5, '2026-06-12', 'day_4', 27.43, 31.84, 80, 24.27, 22.97, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.43,\"temp_max\":31.84,\"humidity\":80,\"rainfall_mm\":24.27,\"wind_speed_kmh\":22.97,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:18'),
(1470, 5, '2026-06-13', 'day_5', 26.48, 27.80, 88, 11.04, 24.52, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":26.48,\"temp_max\":27.8,\"humidity\":88,\"rainfall_mm\":11.04,\"wind_speed_kmh\":24.52,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:18'),
(1471, 7, '2026-06-09', 'current', 27.00, 30.52, 87, 0.62, 13.68, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":27,\"temp_max\":30.52,\"humidity\":87,\"rainfall_mm\":0.62,\"wind_speed_kmh\":13.68,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:18'),
(1472, 7, '2026-06-09', 'today', 25.79, 31.67, 82, 15.90, 21.60, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":25.79,\"temp_max\":31.67,\"humidity\":82,\"rainfall_mm\":15.9,\"wind_speed_kmh\":21.6,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:18'),
(1473, 7, '2026-06-10', 'tomorrow', 25.24, 31.50, 87, 9.79, 21.74, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.24,\"temp_max\":31.5,\"humidity\":87,\"rainfall_mm\":9.79,\"wind_speed_kmh\":21.74,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:18'),
(1474, 7, '2026-06-11', 'day_3', 25.09, 32.68, 83, 21.43, 14.90, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":25.09,\"temp_max\":32.68,\"humidity\":83,\"rainfall_mm\":21.43,\"wind_speed_kmh\":14.9,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:18'),
(1475, 7, '2026-06-12', 'day_4', 25.50, 31.77, 85, 47.53, 17.21, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.5,\"temp_max\":31.77,\"humidity\":85,\"rainfall_mm\":47.53,\"wind_speed_kmh\":17.21,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:18'),
(1476, 7, '2026-06-13', 'day_5', 24.70, 30.55, 88, 13.37, 20.74, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":24.7,\"temp_max\":30.55,\"humidity\":88,\"rainfall_mm\":13.37,\"wind_speed_kmh\":20.74,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:18'),
(1477, 8, '2026-06-09', 'current', 26.25, 29.62, 90, 0.27, 13.61, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":26.25,\"temp_max\":29.62,\"humidity\":90,\"rainfall_mm\":0.27,\"wind_speed_kmh\":13.61,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:19'),
(1478, 8, '2026-06-09', 'today', 26.25, 33.02, 85, 8.15, 18.79, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":26.25,\"temp_max\":33.02,\"humidity\":85,\"rainfall_mm\":8.15,\"wind_speed_kmh\":18.79,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:19'),
(1479, 8, '2026-06-10', 'tomorrow', 25.44, 30.89, 88, 6.30, 17.75, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.44,\"temp_max\":30.89,\"humidity\":88,\"rainfall_mm\":6.3,\"wind_speed_kmh\":17.75,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:19'),
(1480, 8, '2026-06-11', 'day_3', 25.69, 33.28, 82, 7.07, 17.06, 'Rain', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":25.69,\"temp_max\":33.28,\"humidity\":82,\"rainfall_mm\":7.07,\"wind_speed_kmh\":17.06,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:19'),
(1481, 8, '2026-06-12', 'day_4', 25.30, 32.55, 84, 21.82, 15.77, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.3,\"temp_max\":32.55,\"humidity\":84,\"rainfall_mm\":21.82,\"wind_speed_kmh\":15.77,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:19'),
(1482, 8, '2026-06-13', 'day_5', 24.89, 27.26, 92, 5.08, 11.38, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":24.89,\"temp_max\":27.26,\"humidity\":92,\"rainfall_mm\":5.08,\"wind_speed_kmh\":11.38,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:19'),
(1483, 11, '2026-06-09', 'current', 30.79, 34.16, 69, 0.00, 20.23, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":30.79,\"temp_max\":34.16,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":20.23,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:19'),
(1484, 11, '2026-06-09', 'today', 28.80, 42.15, 56, 0.40, 33.01, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":28.8,\"temp_max\":42.15,\"humidity\":56,\"rainfall_mm\":0.4,\"wind_speed_kmh\":33.01,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:19'),
(1485, 11, '2026-06-10', 'tomorrow', 28.72, 42.00, 64, 14.43, 37.37, 'Clear', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.72,\"temp_max\":42,\"humidity\":64,\"rainfall_mm\":14.43,\"wind_speed_kmh\":37.37,\"conditions\":\"Clear\",\"icon\":\"10d\"}', '2026-06-09 01:17:19'),
(1486, 11, '2026-06-11', 'day_3', 26.80, 37.88, 70, 13.57, 27.22, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":26.8,\"temp_max\":37.88,\"humidity\":70,\"rainfall_mm\":13.57,\"wind_speed_kmh\":27.22,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:19'),
(1487, 11, '2026-06-12', 'day_4', 26.36, 36.21, 74, 18.37, 14.15, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.36,\"temp_max\":36.21,\"humidity\":74,\"rainfall_mm\":18.37,\"wind_speed_kmh\":14.15,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:19'),
(1488, 11, '2026-06-13', 'day_5', 27.53, 36.04, 70, 2.82, 22.79, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":27.53,\"temp_max\":36.04,\"humidity\":70,\"rainfall_mm\":2.82,\"wind_speed_kmh\":22.79,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:19'),
(1489, 12, '2026-06-09', 'current', 27.07, 30.53, 88, 0.00, 17.78, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":27.07,\"temp_max\":30.53,\"humidity\":88,\"rainfall_mm\":0,\"wind_speed_kmh\":17.78,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:19'),
(1490, 12, '2026-06-09', 'today', 27.07, 33.85, 82, 8.98, 25.27, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":27.07,\"temp_max\":33.85,\"humidity\":82,\"rainfall_mm\":8.98,\"wind_speed_kmh\":25.27,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:19'),
(1491, 12, '2026-06-10', 'tomorrow', 25.88, 32.17, 86, 10.80, 21.49, 'Rain', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.88,\"temp_max\":32.17,\"humidity\":86,\"rainfall_mm\":10.8,\"wind_speed_kmh\":21.49,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:19'),
(1492, 12, '2026-06-11', 'day_3', 26.13, 33.04, 81, 13.86, 19.26, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":26.13,\"temp_max\":33.04,\"humidity\":81,\"rainfall_mm\":13.86,\"wind_speed_kmh\":19.26,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:19'),
(1493, 12, '2026-06-12', 'day_4', 25.96, 32.06, 83, 30.46, 17.71, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.96,\"temp_max\":32.06,\"humidity\":83,\"rainfall_mm\":30.46,\"wind_speed_kmh\":17.71,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:19'),
(1494, 12, '2026-06-13', 'day_5', 25.24, 27.58, 90, 2.19, 16.67, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.24,\"temp_max\":27.58,\"humidity\":90,\"rainfall_mm\":2.19,\"wind_speed_kmh\":16.67,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:19'),
(1495, 13, '2026-06-09', 'current', 26.86, 29.67, 86, 5.46, 10.98, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":26.86,\"temp_max\":29.67,\"humidity\":86,\"rainfall_mm\":5.46,\"wind_speed_kmh\":10.98,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:20'),
(1496, 13, '2026-06-09', 'today', 26.18, 31.33, 83, 6.60, 24.73, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":26.18,\"temp_max\":31.33,\"humidity\":83,\"rainfall_mm\":6.6,\"wind_speed_kmh\":24.73,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:20'),
(1497, 13, '2026-06-10', 'tomorrow', 26.48, 32.07, 82, 1.63, 29.66, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.48,\"temp_max\":32.07,\"humidity\":82,\"rainfall_mm\":1.63,\"wind_speed_kmh\":29.66,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:20'),
(1498, 13, '2026-06-11', 'day_3', 27.07, 32.00, 80, 0.55, 28.58, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.07,\"temp_max\":32,\"humidity\":80,\"rainfall_mm\":0.55,\"wind_speed_kmh\":28.58,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:20'),
(1499, 13, '2026-06-12', 'day_4', 27.02, 31.03, 79, 2.01, 26.24, 'Rain', '03d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.02,\"temp_max\":31.03,\"humidity\":79,\"rainfall_mm\":2.01,\"wind_speed_kmh\":26.24,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:20'),
(1500, 13, '2026-06-13', 'day_5', 25.81, 29.84, 78, 17.83, 16.31, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.81,\"temp_max\":29.84,\"humidity\":78,\"rainfall_mm\":17.83,\"wind_speed_kmh\":16.31,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:20'),
(1501, 14, '2026-06-09', 'current', 29.28, 32.61, 80, 0.00, 18.25, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.28,\"temp_max\":32.61,\"humidity\":80,\"rainfall_mm\":0,\"wind_speed_kmh\":18.25,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:20'),
(1502, 14, '2026-06-09', 'today', 27.52, 37.91, 68, 1.96, 41.00, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":27.52,\"temp_max\":37.91,\"humidity\":68,\"rainfall_mm\":1.96,\"wind_speed_kmh\":41,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:20'),
(1503, 14, '2026-06-10', 'tomorrow', 28.48, 35.97, 72, 4.38, 26.35, 'Rain', '04d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.48,\"temp_max\":35.97,\"humidity\":72,\"rainfall_mm\":4.38,\"wind_speed_kmh\":26.35,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:20'),
(1504, 14, '2026-06-11', 'day_3', 27.55, 35.09, 73, 18.87, 23.26, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.55,\"temp_max\":35.09,\"humidity\":73,\"rainfall_mm\":18.87,\"wind_speed_kmh\":23.26,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:20'),
(1505, 14, '2026-06-12', 'day_4', 27.40, 33.12, 74, 24.03, 20.92, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.4,\"temp_max\":33.12,\"humidity\":74,\"rainfall_mm\":24.03,\"wind_speed_kmh\":20.92,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:20'),
(1506, 14, '2026-06-13', 'day_5', 26.06, 30.76, 81, 7.68, 22.86, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":26.06,\"temp_max\":30.76,\"humidity\":81,\"rainfall_mm\":7.68,\"wind_speed_kmh\":22.86,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:20'),
(1507, 15, '2026-06-09', 'current', 29.12, 32.09, 79, 0.62, 15.41, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.12,\"temp_max\":32.09,\"humidity\":79,\"rainfall_mm\":0.62,\"wind_speed_kmh\":15.41,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:20'),
(1508, 15, '2026-06-09', 'today', 26.34, 39.90, 67, 5.12, 22.18, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":26.34,\"temp_max\":39.9,\"humidity\":67,\"rainfall_mm\":5.12,\"wind_speed_kmh\":22.18,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:20'),
(1509, 15, '2026-06-10', 'tomorrow', 23.92, 38.18, 70, 11.38, 31.97, 'Rain', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":23.92,\"temp_max\":38.18,\"humidity\":70,\"rainfall_mm\":11.38,\"wind_speed_kmh\":31.97,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:20'),
(1510, 15, '2026-06-11', 'day_3', 24.63, 32.54, 75, 12.38, 22.82, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":24.63,\"temp_max\":32.54,\"humidity\":75,\"rainfall_mm\":12.38,\"wind_speed_kmh\":22.82,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:20'),
(1511, 15, '2026-06-12', 'day_4', 25.83, 34.02, 73, 10.50, 17.57, 'Rain', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.83,\"temp_max\":34.02,\"humidity\":73,\"rainfall_mm\":10.5,\"wind_speed_kmh\":17.57,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:20'),
(1512, 15, '2026-06-13', 'day_5', 26.28, 34.17, 73, 7.90, 18.18, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":26.28,\"temp_max\":34.17,\"humidity\":73,\"rainfall_mm\":7.9,\"wind_speed_kmh\":18.18,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:20'),
(1513, 16, '2026-06-09', 'current', 29.17, 32.46, 83, 0.00, 16.42, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.17,\"temp_max\":32.46,\"humidity\":83,\"rainfall_mm\":0,\"wind_speed_kmh\":16.42,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:21'),
(1514, 16, '2026-06-09', 'today', 25.01, 38.55, 74, 8.76, 51.88, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":25.01,\"temp_max\":38.55,\"humidity\":74,\"rainfall_mm\":8.76,\"wind_speed_kmh\":51.88,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:21'),
(1515, 16, '2026-06-10', 'tomorrow', 27.42, 38.45, 71, 3.68, 25.60, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.42,\"temp_max\":38.45,\"humidity\":71,\"rainfall_mm\":3.68,\"wind_speed_kmh\":25.6,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:21'),
(1516, 16, '2026-06-11', 'day_3', 27.64, 35.84, 74, 9.10, 26.28, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.64,\"temp_max\":35.84,\"humidity\":74,\"rainfall_mm\":9.1,\"wind_speed_kmh\":26.28,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:21'),
(1517, 16, '2026-06-12', 'day_4', 26.21, 34.11, 79, 9.26, 28.30, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.21,\"temp_max\":34.11,\"humidity\":79,\"rainfall_mm\":9.26,\"wind_speed_kmh\":28.3,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:21'),
(1518, 16, '2026-06-13', 'day_5', 25.97, 31.14, 84, 7.59, 25.24, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.97,\"temp_max\":31.14,\"humidity\":84,\"rainfall_mm\":7.59,\"wind_speed_kmh\":25.24,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:21'),
(1519, 17, '2026-06-09', 'current', 27.04, 30.21, 88, 0.30, 15.95, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":27.04,\"temp_max\":30.21,\"humidity\":88,\"rainfall_mm\":0.3,\"wind_speed_kmh\":15.95,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:21'),
(1520, 17, '2026-06-09', 'today', 27.00, 32.99, 83, 4.81, 20.95, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":27,\"temp_max\":32.99,\"humidity\":83,\"rainfall_mm\":4.81,\"wind_speed_kmh\":20.95,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:21');
INSERT INTO `weather_forecasts` (`forecast_id`, `district_id`, `forecast_date`, `forecast_for`, `temp_min`, `temp_max`, `humidity`, `rainfall_mm`, `wind_speed_kmh`, `conditions`, `icon`, `raw_payload`, `fetched_at`) VALUES
(1521, 17, '2026-06-10', 'tomorrow', 26.12, 32.04, 84, 4.37, 24.66, 'Rain', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.12,\"temp_max\":32.04,\"humidity\":84,\"rainfall_mm\":4.37,\"wind_speed_kmh\":24.66,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:21'),
(1522, 17, '2026-06-11', 'day_3', 26.06, 33.26, 79, 2.87, 22.54, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":26.06,\"temp_max\":33.26,\"humidity\":79,\"rainfall_mm\":2.87,\"wind_speed_kmh\":22.54,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:21'),
(1523, 17, '2026-06-12', 'day_4', 26.60, 32.71, 79, 7.45, 21.67, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.6,\"temp_max\":32.71,\"humidity\":79,\"rainfall_mm\":7.45,\"wind_speed_kmh\":21.67,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:21'),
(1524, 17, '2026-06-13', 'day_5', 25.63, 28.96, 86, 5.11, 17.42, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.63,\"temp_max\":28.96,\"humidity\":86,\"rainfall_mm\":5.11,\"wind_speed_kmh\":17.42,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:21'),
(1525, 18, '2026-06-09', 'current', 27.01, 29.89, 85, 1.17, 20.38, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":27.01,\"temp_max\":29.89,\"humidity\":85,\"rainfall_mm\":1.17,\"wind_speed_kmh\":20.38,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:21'),
(1526, 18, '2026-06-09', 'today', 24.94, 35.40, 77, 10.16, 21.17, 'Rain', '03d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":24.94,\"temp_max\":35.4,\"humidity\":77,\"rainfall_mm\":10.16,\"wind_speed_kmh\":21.17,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:21'),
(1527, 18, '2026-06-10', 'tomorrow', 24.82, 34.47, 78, 9.20, 21.24, 'Rain', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.82,\"temp_max\":34.47,\"humidity\":78,\"rainfall_mm\":9.2,\"wind_speed_kmh\":21.24,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:21'),
(1528, 18, '2026-06-11', 'day_3', 23.17, 32.72, 81, 19.74, 17.50, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":23.17,\"temp_max\":32.72,\"humidity\":81,\"rainfall_mm\":19.74,\"wind_speed_kmh\":17.5,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:21'),
(1529, 18, '2026-06-12', 'day_4', 25.59, 33.28, 80, 16.44, 15.88, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.59,\"temp_max\":33.28,\"humidity\":80,\"rainfall_mm\":16.44,\"wind_speed_kmh\":15.88,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:21'),
(1530, 18, '2026-06-13', 'day_5', 25.35, 33.18, 81, 8.42, 22.54, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.35,\"temp_max\":33.18,\"humidity\":81,\"rainfall_mm\":8.42,\"wind_speed_kmh\":22.54,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:21'),
(1531, 19, '2026-06-09', 'current', 28.66, 32.35, 81, 0.00, 19.51, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":28.66,\"temp_max\":32.35,\"humidity\":81,\"rainfall_mm\":0,\"wind_speed_kmh\":19.51,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:22'),
(1532, 19, '2026-06-09', 'today', 26.15, 37.52, 70, 2.94, 30.38, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":26.15,\"temp_max\":37.52,\"humidity\":70,\"rainfall_mm\":2.94,\"wind_speed_kmh\":30.38,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:22'),
(1533, 19, '2026-06-10', 'tomorrow', 27.66, 34.98, 77, 8.82, 23.72, 'Rain', '04d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.66,\"temp_max\":34.98,\"humidity\":77,\"rainfall_mm\":8.82,\"wind_speed_kmh\":23.72,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:22'),
(1534, 19, '2026-06-11', 'day_3', 27.19, 33.98, 77, 25.17, 19.37, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.19,\"temp_max\":33.98,\"humidity\":77,\"rainfall_mm\":25.17,\"wind_speed_kmh\":19.37,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:22'),
(1535, 19, '2026-06-12', 'day_4', 26.05, 32.56, 78, 24.42, 18.61, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.05,\"temp_max\":32.56,\"humidity\":78,\"rainfall_mm\":24.42,\"wind_speed_kmh\":18.61,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:22'),
(1536, 19, '2026-06-13', 'day_5', 24.91, 31.14, 83, 9.83, 21.28, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":24.91,\"temp_max\":31.14,\"humidity\":83,\"rainfall_mm\":9.83,\"wind_speed_kmh\":21.28,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:22'),
(1537, 20, '2026-06-09', 'current', 29.59, 33.24, 82, 0.00, 17.46, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.59,\"temp_max\":33.24,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":17.46,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:22'),
(1538, 20, '2026-06-09', 'today', 25.27, 40.12, 72, 21.41, 40.57, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":25.27,\"temp_max\":40.12,\"humidity\":72,\"rainfall_mm\":21.41,\"wind_speed_kmh\":40.57,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:22'),
(1539, 20, '2026-06-10', 'tomorrow', 28.11, 39.16, 70, 5.00, 20.16, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.11,\"temp_max\":39.16,\"humidity\":70,\"rainfall_mm\":5,\"wind_speed_kmh\":20.16,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:22'),
(1540, 20, '2026-06-11', 'day_3', 27.58, 35.58, 73, 5.09, 25.67, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.58,\"temp_max\":35.58,\"humidity\":73,\"rainfall_mm\":5.09,\"wind_speed_kmh\":25.67,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:22'),
(1541, 20, '2026-06-12', 'day_4', 26.29, 34.06, 80, 9.65, 19.55, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.29,\"temp_max\":34.06,\"humidity\":80,\"rainfall_mm\":9.65,\"wind_speed_kmh\":19.55,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:22'),
(1542, 20, '2026-06-13', 'day_5', 25.79, 30.66, 85, 11.72, 23.90, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.79,\"temp_max\":30.66,\"humidity\":85,\"rainfall_mm\":11.72,\"wind_speed_kmh\":23.9,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:22'),
(1543, 21, '2026-06-09', 'current', 26.21, 29.40, 87, 0.47, 7.88, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":26.21,\"temp_max\":29.4,\"humidity\":87,\"rainfall_mm\":0.47,\"wind_speed_kmh\":7.88,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:22'),
(1544, 21, '2026-06-09', 'today', 24.69, 34.55, 80, 13.18, 13.54, 'Rain', '02d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":24.69,\"temp_max\":34.55,\"humidity\":80,\"rainfall_mm\":13.18,\"wind_speed_kmh\":13.54,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-09 01:17:22'),
(1545, 21, '2026-06-10', 'tomorrow', 24.23, 30.72, 86, 18.67, 12.06, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.23,\"temp_max\":30.72,\"humidity\":86,\"rainfall_mm\":18.67,\"wind_speed_kmh\":12.06,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:22'),
(1546, 21, '2026-06-11', 'day_3', 24.88, 30.94, 87, 28.29, 10.91, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":24.88,\"temp_max\":30.94,\"humidity\":87,\"rainfall_mm\":28.29,\"wind_speed_kmh\":10.91,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:22'),
(1547, 21, '2026-06-12', 'day_4', 24.19, 32.79, 85, 21.10, 9.83, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":24.19,\"temp_max\":32.79,\"humidity\":85,\"rainfall_mm\":21.1,\"wind_speed_kmh\":9.83,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:22'),
(1548, 21, '2026-06-13', 'day_5', 24.53, 30.51, 87, 13.82, 15.73, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":24.53,\"temp_max\":30.51,\"humidity\":87,\"rainfall_mm\":13.82,\"wind_speed_kmh\":15.73,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:22'),
(1549, 22, '2026-06-09', 'current', 28.17, 31.32, 80, 1.68, 16.27, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":28.17,\"temp_max\":31.32,\"humidity\":80,\"rainfall_mm\":1.68,\"wind_speed_kmh\":16.27,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:23'),
(1550, 22, '2026-06-09', 'today', 25.66, 36.71, 73, 7.19, 22.43, 'Rain', '01d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":25.66,\"temp_max\":36.71,\"humidity\":73,\"rainfall_mm\":7.19,\"wind_speed_kmh\":22.43,\"conditions\":\"Rain\",\"icon\":\"01d\"}', '2026-06-09 01:17:23'),
(1551, 22, '2026-06-10', 'tomorrow', 25.63, 35.26, 76, 4.55, 24.70, 'Rain', '04d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.63,\"temp_max\":35.26,\"humidity\":76,\"rainfall_mm\":4.55,\"wind_speed_kmh\":24.7,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:23'),
(1552, 22, '2026-06-11', 'day_3', 27.45, 32.86, 79, 31.68, 23.11, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.45,\"temp_max\":32.86,\"humidity\":79,\"rainfall_mm\":31.68,\"wind_speed_kmh\":23.11,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:23'),
(1553, 22, '2026-06-12', 'day_4', 26.17, 33.06, 79, 13.13, 14.47, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.17,\"temp_max\":33.06,\"humidity\":79,\"rainfall_mm\":13.13,\"wind_speed_kmh\":14.47,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:23'),
(1554, 22, '2026-06-13', 'day_5', 25.51, 33.04, 80, 8.80, 19.30, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.51,\"temp_max\":33.04,\"humidity\":80,\"rainfall_mm\":8.8,\"wind_speed_kmh\":19.3,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:23'),
(1555, 24, '2026-06-09', 'current', 29.97, 32.80, 83, 0.00, 15.05, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.97,\"temp_max\":32.8,\"humidity\":83,\"rainfall_mm\":0,\"wind_speed_kmh\":15.05,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:23'),
(1556, 24, '2026-06-09', 'today', 29.44, 35.84, 73, 0.61, 24.05, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":29.44,\"temp_max\":35.84,\"humidity\":73,\"rainfall_mm\":0.61,\"wind_speed_kmh\":24.05,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:23'),
(1557, 24, '2026-06-10', 'tomorrow', 29.15, 36.24, 69, 0.00, 24.73, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.15,\"temp_max\":36.24,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":24.73,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:23'),
(1558, 24, '2026-06-11', 'day_3', 28.79, 35.40, 74, 3.63, 27.22, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":28.79,\"temp_max\":35.4,\"humidity\":74,\"rainfall_mm\":3.63,\"wind_speed_kmh\":27.22,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:23'),
(1559, 24, '2026-06-12', 'day_4', 28.29, 33.79, 75, 30.72, 17.68, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":28.29,\"temp_max\":33.79,\"humidity\":75,\"rainfall_mm\":30.72,\"wind_speed_kmh\":17.68,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:23'),
(1560, 24, '2026-06-13', 'day_5', 25.63, 28.15, 90, 42.75, 19.01, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.63,\"temp_max\":28.15,\"humidity\":90,\"rainfall_mm\":42.75,\"wind_speed_kmh\":19.01,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:23'),
(1561, 25, '2026-06-09', 'current', 31.14, 34.77, 73, 0.00, 18.04, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":31.14,\"temp_max\":34.77,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":18.04,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:23'),
(1562, 25, '2026-06-09', 'today', 27.99, 41.87, 62, 4.08, 32.83, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":27.99,\"temp_max\":41.87,\"humidity\":62,\"rainfall_mm\":4.08,\"wind_speed_kmh\":32.83,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:23'),
(1563, 25, '2026-06-10', 'tomorrow', 29.04, 40.41, 62, 0.89, 27.36, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.04,\"temp_max\":40.41,\"humidity\":62,\"rainfall_mm\":0.89,\"wind_speed_kmh\":27.36,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:23'),
(1564, 25, '2026-06-11', 'day_3', 29.51, 37.97, 64, 0.00, 24.98, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":29.51,\"temp_max\":37.97,\"humidity\":64,\"rainfall_mm\":0,\"wind_speed_kmh\":24.98,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:23'),
(1565, 25, '2026-06-12', 'day_4', 27.32, 34.06, 74, 15.04, 19.37, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.32,\"temp_max\":34.06,\"humidity\":74,\"rainfall_mm\":15.04,\"wind_speed_kmh\":19.37,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:23'),
(1566, 25, '2026-06-13', 'day_5', 27.42, 34.51, 73, 0.79, 23.36, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":27.42,\"temp_max\":34.51,\"humidity\":73,\"rainfall_mm\":0.79,\"wind_speed_kmh\":23.36,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:23'),
(1567, 26, '2026-06-09', 'current', 29.15, 32.60, 77, 0.11, 17.03, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.15,\"temp_max\":32.6,\"humidity\":77,\"rainfall_mm\":0.11,\"wind_speed_kmh\":17.03,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:24'),
(1568, 26, '2026-06-09', 'today', 26.97, 40.21, 62, 1.59, 20.23, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":26.97,\"temp_max\":40.21,\"humidity\":62,\"rainfall_mm\":1.59,\"wind_speed_kmh\":20.23,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:24'),
(1569, 26, '2026-06-10', 'tomorrow', 26.27, 39.26, 67, 6.54, 28.55, 'Rain', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.27,\"temp_max\":39.26,\"humidity\":67,\"rainfall_mm\":6.54,\"wind_speed_kmh\":28.55,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:24'),
(1570, 26, '2026-06-11', 'day_3', 24.03, 33.83, 76, 26.48, 20.99, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":24.03,\"temp_max\":33.83,\"humidity\":76,\"rainfall_mm\":26.48,\"wind_speed_kmh\":20.99,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:24'),
(1571, 26, '2026-06-12', 'day_4', 25.75, 36.23, 70, 3.84, 17.06, 'Rain', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.75,\"temp_max\":36.23,\"humidity\":70,\"rainfall_mm\":3.84,\"wind_speed_kmh\":17.06,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:24'),
(1572, 26, '2026-06-13', 'day_5', 26.19, 34.07, 73, 3.27, 20.48, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":26.19,\"temp_max\":34.07,\"humidity\":73,\"rainfall_mm\":3.27,\"wind_speed_kmh\":20.48,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:24'),
(1573, 27, '2026-06-09', 'current', 25.84, 30.14, 86, 0.00, 7.24, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":25.84,\"temp_max\":30.14,\"humidity\":86,\"rainfall_mm\":0,\"wind_speed_kmh\":7.24,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:24'),
(1574, 27, '2026-06-09', 'today', 23.89, 35.18, 80, 4.12, 11.59, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":23.89,\"temp_max\":35.18,\"humidity\":80,\"rainfall_mm\":4.12,\"wind_speed_kmh\":11.59,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:24'),
(1575, 27, '2026-06-10', 'tomorrow', 23.33, 33.55, 83, 4.60, 10.22, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":23.33,\"temp_max\":33.55,\"humidity\":83,\"rainfall_mm\":4.6,\"wind_speed_kmh\":10.22,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:24'),
(1576, 27, '2026-06-11', 'day_3', 23.78, 34.93, 77, 1.64, 9.97, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":23.78,\"temp_max\":34.93,\"humidity\":77,\"rainfall_mm\":1.64,\"wind_speed_kmh\":9.97,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:24'),
(1577, 27, '2026-06-12', 'day_4', 24.24, 34.10, 82, 5.32, 8.50, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":24.24,\"temp_max\":34.1,\"humidity\":82,\"rainfall_mm\":5.32,\"wind_speed_kmh\":8.5,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:24'),
(1578, 27, '2026-06-13', 'day_5', 23.73, 26.75, 96, 12.10, 5.87, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":23.73,\"temp_max\":26.75,\"humidity\":96,\"rainfall_mm\":12.1,\"wind_speed_kmh\":5.87,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:24'),
(1579, 28, '2026-06-09', 'current', 30.37, 32.47, 80, 0.00, 17.82, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":30.37,\"temp_max\":32.47,\"humidity\":80,\"rainfall_mm\":0,\"wind_speed_kmh\":17.82,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:24'),
(1580, 28, '2026-06-09', 'today', 26.19, 37.38, 72, 17.67, 25.88, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":26.19,\"temp_max\":37.38,\"humidity\":72,\"rainfall_mm\":17.67,\"wind_speed_kmh\":25.88,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:24'),
(1581, 28, '2026-06-10', 'tomorrow', 28.90, 38.43, 66, 0.11, 24.55, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.9,\"temp_max\":38.43,\"humidity\":66,\"rainfall_mm\":0.11,\"wind_speed_kmh\":24.55,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:24'),
(1582, 28, '2026-06-11', 'day_3', 29.41, 37.87, 63, 0.00, 24.70, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":29.41,\"temp_max\":37.87,\"humidity\":63,\"rainfall_mm\":0,\"wind_speed_kmh\":24.7,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:24'),
(1583, 28, '2026-06-12', 'day_4', 27.35, 34.56, 77, 18.21, 19.08, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.35,\"temp_max\":34.56,\"humidity\":77,\"rainfall_mm\":18.21,\"wind_speed_kmh\":19.08,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:24'),
(1584, 28, '2026-06-13', 'day_5', 26.59, 29.91, 84, 13.47, 21.06, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":26.59,\"temp_max\":29.91,\"humidity\":84,\"rainfall_mm\":13.47,\"wind_speed_kmh\":21.06,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:24'),
(1585, 29, '2026-06-09', 'current', 27.63, 31.40, 84, 0.61, 17.10, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":27.63,\"temp_max\":31.4,\"humidity\":84,\"rainfall_mm\":0.61,\"wind_speed_kmh\":17.1,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1586, 29, '2026-06-09', 'today', 25.65, 36.77, 74, 5.03, 25.56, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":25.65,\"temp_max\":36.77,\"humidity\":74,\"rainfall_mm\":5.03,\"wind_speed_kmh\":25.56,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1587, 29, '2026-06-10', 'tomorrow', 26.23, 34.40, 82, 13.69, 23.87, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.23,\"temp_max\":34.4,\"humidity\":82,\"rainfall_mm\":13.69,\"wind_speed_kmh\":23.87,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1588, 29, '2026-06-11', 'day_3', 26.29, 33.00, 84, 31.46, 15.98, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":26.29,\"temp_max\":33,\"humidity\":84,\"rainfall_mm\":31.46,\"wind_speed_kmh\":15.98,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1589, 29, '2026-06-12', 'day_4', 25.59, 32.63, 80, 22.23, 12.64, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.59,\"temp_max\":32.63,\"humidity\":80,\"rainfall_mm\":22.23,\"wind_speed_kmh\":12.64,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1590, 29, '2026-06-13', 'day_5', 24.71, 31.89, 82, 7.38, 19.48, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":24.71,\"temp_max\":31.89,\"humidity\":82,\"rainfall_mm\":7.38,\"wind_speed_kmh\":19.48,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1591, 30, '2026-06-09', 'current', 26.96, 29.69, 84, 0.46, 22.07, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":26.96,\"temp_max\":29.69,\"humidity\":84,\"rainfall_mm\":0.46,\"wind_speed_kmh\":22.07,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1592, 30, '2026-06-09', 'today', 25.68, 34.57, 76, 5.53, 29.48, 'Rain', '03d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":25.68,\"temp_max\":34.57,\"humidity\":76,\"rainfall_mm\":5.53,\"wind_speed_kmh\":29.48,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:25'),
(1593, 30, '2026-06-10', 'tomorrow', 25.87, 32.66, 78, 7.07, 22.75, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.87,\"temp_max\":32.66,\"humidity\":78,\"rainfall_mm\":7.07,\"wind_speed_kmh\":22.75,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1594, 30, '2026-06-11', 'day_3', 24.10, 30.68, 82, 22.89, 14.11, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":24.1,\"temp_max\":30.68,\"humidity\":82,\"rainfall_mm\":22.89,\"wind_speed_kmh\":14.11,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1595, 30, '2026-06-12', 'day_4', 25.18, 31.51, 81, 23.22, 15.77, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.18,\"temp_max\":31.51,\"humidity\":81,\"rainfall_mm\":23.22,\"wind_speed_kmh\":15.77,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1596, 30, '2026-06-13', 'day_5', 25.91, 31.84, 81, 10.89, 26.71, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.91,\"temp_max\":31.84,\"humidity\":81,\"rainfall_mm\":10.89,\"wind_speed_kmh\":26.71,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1597, 31, '2026-06-09', 'current', 30.85, 34.41, 66, 0.00, 18.97, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":30.85,\"temp_max\":34.41,\"humidity\":66,\"rainfall_mm\":0,\"wind_speed_kmh\":18.97,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:25'),
(1598, 31, '2026-06-09', 'today', 28.48, 41.81, 54, 0.40, 28.30, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":28.48,\"temp_max\":41.81,\"humidity\":54,\"rainfall_mm\":0.4,\"wind_speed_kmh\":28.3,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1599, 31, '2026-06-10', 'tomorrow', 28.99, 42.46, 61, 10.06, 35.10, 'Clear', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.99,\"temp_max\":42.46,\"humidity\":61,\"rainfall_mm\":10.06,\"wind_speed_kmh\":35.1,\"conditions\":\"Clear\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1600, 31, '2026-06-11', 'day_3', 26.71, 38.02, 73, 22.09, 25.52, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":26.71,\"temp_max\":38.02,\"humidity\":73,\"rainfall_mm\":22.09,\"wind_speed_kmh\":25.52,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1601, 31, '2026-06-12', 'day_4', 26.13, 36.22, 74, 17.68, 18.14, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.13,\"temp_max\":36.22,\"humidity\":74,\"rainfall_mm\":17.68,\"wind_speed_kmh\":18.14,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:25'),
(1602, 31, '2026-06-13', 'day_5', 27.42, 36.72, 68, 2.68, 23.40, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":27.42,\"temp_max\":36.72,\"humidity\":68,\"rainfall_mm\":2.68,\"wind_speed_kmh\":23.4,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:25'),
(1603, 32, '2026-06-09', 'current', 29.84, 31.91, 82, 0.00, 15.77, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.84,\"temp_max\":31.91,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":15.77,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:26'),
(1604, 32, '2026-06-09', 'today', 29.13, 32.98, 79, 2.61, 25.74, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":29.13,\"temp_max\":32.98,\"humidity\":79,\"rainfall_mm\":2.61,\"wind_speed_kmh\":25.74,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:26'),
(1605, 32, '2026-06-10', 'tomorrow', 29.15, 33.35, 77, 0.43, 28.01, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.15,\"temp_max\":33.35,\"humidity\":77,\"rainfall_mm\":0.43,\"wind_speed_kmh\":28.01,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:26'),
(1606, 32, '2026-06-11', 'day_3', 28.79, 32.32, 78, 1.39, 26.78, 'Rain', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":28.79,\"temp_max\":32.32,\"humidity\":78,\"rainfall_mm\":1.39,\"wind_speed_kmh\":26.78,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:26'),
(1607, 32, '2026-06-12', 'day_4', 28.46, 32.71, 75, 19.98, 24.01, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":28.46,\"temp_max\":32.71,\"humidity\":75,\"rainfall_mm\":19.98,\"wind_speed_kmh\":24.01,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:26'),
(1608, 32, '2026-06-13', 'day_5', 26.23, 28.11, 86, 12.70, 22.36, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":26.23,\"temp_max\":28.11,\"humidity\":86,\"rainfall_mm\":12.7,\"wind_speed_kmh\":22.36,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:26'),
(1609, 33, '2026-06-09', 'current', 26.97, 29.95, 84, 0.43, 17.93, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":26.97,\"temp_max\":29.95,\"humidity\":84,\"rainfall_mm\":0.43,\"wind_speed_kmh\":17.93,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:26'),
(1610, 33, '2026-06-09', 'today', 24.98, 34.63, 77, 9.88, 19.91, 'Rain', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":24.98,\"temp_max\":34.63,\"humidity\":77,\"rainfall_mm\":9.88,\"wind_speed_kmh\":19.91,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:26'),
(1611, 33, '2026-06-10', 'tomorrow', 25.68, 33.05, 79, 7.90, 18.22, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.68,\"temp_max\":33.05,\"humidity\":79,\"rainfall_mm\":7.9,\"wind_speed_kmh\":18.22,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:26'),
(1612, 33, '2026-06-11', 'day_3', 23.57, 31.41, 81, 20.97, 16.42, 'Rain', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":23.57,\"temp_max\":31.41,\"humidity\":81,\"rainfall_mm\":20.97,\"wind_speed_kmh\":16.42,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:26'),
(1613, 33, '2026-06-12', 'day_4', 24.36, 31.55, 81, 22.99, 20.23, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":24.36,\"temp_max\":31.55,\"humidity\":81,\"rainfall_mm\":22.99,\"wind_speed_kmh\":20.23,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:26'),
(1614, 33, '2026-06-13', 'day_5', 25.59, 32.23, 81, 16.83, 19.37, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.59,\"temp_max\":32.23,\"humidity\":81,\"rainfall_mm\":16.83,\"wind_speed_kmh\":19.37,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:26'),
(1615, 34, '2026-06-09', 'current', 28.89, 31.76, 85, 0.00, 16.92, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":28.89,\"temp_max\":31.76,\"humidity\":85,\"rainfall_mm\":0,\"wind_speed_kmh\":16.92,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:26'),
(1616, 34, '2026-06-09', 'today', 24.84, 38.06, 76, 16.32, 42.77, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":24.84,\"temp_max\":38.06,\"humidity\":76,\"rainfall_mm\":16.32,\"wind_speed_kmh\":42.77,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:26'),
(1617, 34, '2026-06-10', 'tomorrow', 27.79, 36.01, 75, 2.23, 28.15, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.79,\"temp_max\":36.01,\"humidity\":75,\"rainfall_mm\":2.23,\"wind_speed_kmh\":28.15,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:26'),
(1618, 34, '2026-06-11', 'day_3', 26.73, 34.92, 77, 12.88, 25.24, 'Rain', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":26.73,\"temp_max\":34.92,\"humidity\":77,\"rainfall_mm\":12.88,\"wind_speed_kmh\":25.24,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:26'),
(1619, 34, '2026-06-12', 'day_4', 25.83, 34.14, 78, 14.56, 18.36, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.83,\"temp_max\":34.14,\"humidity\":78,\"rainfall_mm\":14.56,\"wind_speed_kmh\":18.36,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:26'),
(1620, 34, '2026-06-13', 'day_5', 25.55, 28.88, 87, 10.80, 22.93, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.55,\"temp_max\":28.88,\"humidity\":87,\"rainfall_mm\":10.8,\"wind_speed_kmh\":22.93,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:26'),
(1621, 35, '2026-06-09', 'current', 31.20, 34.72, 73, 0.00, 19.44, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":31.2,\"temp_max\":34.72,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":19.44,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:27'),
(1622, 35, '2026-06-09', 'today', 27.23, 41.98, 63, 14.08, 32.69, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":27.23,\"temp_max\":41.98,\"humidity\":63,\"rainfall_mm\":14.08,\"wind_speed_kmh\":32.69,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:27'),
(1623, 35, '2026-06-10', 'tomorrow', 28.86, 40.65, 65, 9.97, 24.70, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.86,\"temp_max\":40.65,\"humidity\":65,\"rainfall_mm\":9.97,\"wind_speed_kmh\":24.7,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:27'),
(1624, 35, '2026-06-11', 'day_3', 29.35, 38.61, 61, 0.00, 26.82, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":29.35,\"temp_max\":38.61,\"humidity\":61,\"rainfall_mm\":0,\"wind_speed_kmh\":26.82,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:27'),
(1625, 35, '2026-06-12', 'day_4', 27.44, 35.97, 73, 12.94, 21.56, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.44,\"temp_max\":35.97,\"humidity\":73,\"rainfall_mm\":12.94,\"wind_speed_kmh\":21.56,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:27'),
(1626, 35, '2026-06-13', 'day_5', 26.96, 33.78, 75, 2.70, 22.03, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":26.96,\"temp_max\":33.78,\"humidity\":75,\"rainfall_mm\":2.7,\"wind_speed_kmh\":22.03,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:27'),
(1627, 36, '2026-06-09', 'current', 28.89, 32.15, 81, 0.47, 21.31, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":28.89,\"temp_max\":32.15,\"humidity\":81,\"rainfall_mm\":0.47,\"wind_speed_kmh\":21.31,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:27'),
(1628, 36, '2026-06-09', 'today', 26.26, 37.60, 73, 7.36, 43.16, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":26.26,\"temp_max\":37.6,\"humidity\":73,\"rainfall_mm\":7.36,\"wind_speed_kmh\":43.16,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:27'),
(1629, 36, '2026-06-10', 'tomorrow', 27.71, 37.33, 73, 1.49, 30.42, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.71,\"temp_max\":37.33,\"humidity\":73,\"rainfall_mm\":1.49,\"wind_speed_kmh\":30.42,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:27'),
(1630, 36, '2026-06-11', 'day_3', 27.58, 34.95, 74, 21.53, 29.74, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.58,\"temp_max\":34.95,\"humidity\":74,\"rainfall_mm\":21.53,\"wind_speed_kmh\":29.74,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:27'),
(1631, 36, '2026-06-12', 'day_4', 26.49, 34.02, 75, 12.81, 24.16, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.49,\"temp_max\":34.02,\"humidity\":75,\"rainfall_mm\":12.81,\"wind_speed_kmh\":24.16,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:27'),
(1632, 36, '2026-06-13', 'day_5', 25.92, 32.05, 80, 6.62, 23.33, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.92,\"temp_max\":32.05,\"humidity\":80,\"rainfall_mm\":6.62,\"wind_speed_kmh\":23.33,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:27'),
(1633, 37, '2026-06-09', 'current', 30.89, 34.24, 70, 0.00, 20.84, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":30.89,\"temp_max\":34.24,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":20.84,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:28'),
(1634, 37, '2026-06-09', 'today', 28.94, 42.12, 54, 0.00, 34.49, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":28.94,\"temp_max\":42.12,\"humidity\":54,\"rainfall_mm\":0,\"wind_speed_kmh\":34.49,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:28'),
(1635, 37, '2026-06-10', 'tomorrow', 28.50, 41.62, 63, 5.62, 37.37, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.5,\"temp_max\":41.62,\"humidity\":63,\"rainfall_mm\":5.62,\"wind_speed_kmh\":37.37,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:28'),
(1636, 37, '2026-06-11', 'day_3', 26.81, 38.11, 68, 12.15, 23.69, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":26.81,\"temp_max\":38.11,\"humidity\":68,\"rainfall_mm\":12.15,\"wind_speed_kmh\":23.69,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:28'),
(1637, 37, '2026-06-12', 'day_4', 26.42, 35.85, 74, 16.77, 14.15, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.42,\"temp_max\":35.85,\"humidity\":74,\"rainfall_mm\":16.77,\"wind_speed_kmh\":14.15,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:28'),
(1638, 37, '2026-06-13', 'day_5', 27.33, 34.66, 72, 2.18, 23.00, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":27.33,\"temp_max\":34.66,\"humidity\":72,\"rainfall_mm\":2.18,\"wind_speed_kmh\":23,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:28'),
(1639, 38, '2026-06-09', 'current', 26.21, 29.40, 87, 0.47, 7.88, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":26.21,\"temp_max\":29.4,\"humidity\":87,\"rainfall_mm\":0.47,\"wind_speed_kmh\":7.88,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:28'),
(1640, 38, '2026-06-09', 'today', 24.69, 34.55, 80, 13.18, 13.54, 'Rain', '02d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":24.69,\"temp_max\":34.55,\"humidity\":80,\"rainfall_mm\":13.18,\"wind_speed_kmh\":13.54,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-09 01:17:28'),
(1641, 38, '2026-06-10', 'tomorrow', 24.23, 30.72, 86, 18.67, 12.06, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.23,\"temp_max\":30.72,\"humidity\":86,\"rainfall_mm\":18.67,\"wind_speed_kmh\":12.06,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:28'),
(1642, 38, '2026-06-11', 'day_3', 24.88, 30.94, 87, 28.29, 10.91, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":24.88,\"temp_max\":30.94,\"humidity\":87,\"rainfall_mm\":28.29,\"wind_speed_kmh\":10.91,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:28'),
(1643, 38, '2026-06-12', 'day_4', 24.19, 32.79, 85, 21.10, 9.83, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":24.19,\"temp_max\":32.79,\"humidity\":85,\"rainfall_mm\":21.1,\"wind_speed_kmh\":9.83,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:28'),
(1644, 38, '2026-06-13', 'day_5', 24.53, 30.51, 87, 13.82, 15.73, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":24.53,\"temp_max\":30.51,\"humidity\":87,\"rainfall_mm\":13.82,\"wind_speed_kmh\":15.73,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:28'),
(1645, 39, '2026-06-09', 'current', 29.18, 32.41, 82, 0.00, 17.71, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.18,\"temp_max\":32.41,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":17.71,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:28'),
(1646, 39, '2026-06-09', 'today', 26.98, 36.91, 72, 3.34, 39.42, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":26.98,\"temp_max\":36.91,\"humidity\":72,\"rainfall_mm\":3.34,\"wind_speed_kmh\":39.42,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:28'),
(1647, 39, '2026-06-10', 'tomorrow', 28.29, 36.48, 73, 2.69, 27.14, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.29,\"temp_max\":36.48,\"humidity\":73,\"rainfall_mm\":2.69,\"wind_speed_kmh\":27.14,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:28'),
(1648, 39, '2026-06-11', 'day_3', 27.78, 34.70, 74, 15.65, 22.18, 'Rain', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.78,\"temp_max\":34.7,\"humidity\":74,\"rainfall_mm\":15.65,\"wind_speed_kmh\":22.18,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:28'),
(1649, 39, '2026-06-12', 'day_4', 27.13, 33.37, 76, 23.04, 21.02, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.13,\"temp_max\":33.37,\"humidity\":76,\"rainfall_mm\":23.04,\"wind_speed_kmh\":21.02,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:28'),
(1650, 39, '2026-06-13', 'day_5', 25.83, 30.06, 83, 8.47, 23.47, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.83,\"temp_max\":30.06,\"humidity\":83,\"rainfall_mm\":8.47,\"wind_speed_kmh\":23.47,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:28'),
(1651, 40, '2026-06-09', 'current', 27.00, 30.51, 87, 0.25, 16.24, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":27,\"temp_max\":30.51,\"humidity\":87,\"rainfall_mm\":0.25,\"wind_speed_kmh\":16.24,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:29'),
(1652, 40, '2026-06-09', 'today', 24.59, 33.37, 78, 3.09, 23.15, 'Rain', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":24.59,\"temp_max\":33.37,\"humidity\":78,\"rainfall_mm\":3.09,\"wind_speed_kmh\":23.15,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:29'),
(1653, 40, '2026-06-10', 'tomorrow', 25.99, 33.46, 82, 13.95, 22.79, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.99,\"temp_max\":33.46,\"humidity\":82,\"rainfall_mm\":13.95,\"wind_speed_kmh\":22.79,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:29'),
(1654, 40, '2026-06-11', 'day_3', 25.19, 31.85, 88, 34.56, 17.10, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":25.19,\"temp_max\":31.85,\"humidity\":88,\"rainfall_mm\":34.56,\"wind_speed_kmh\":17.1,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:29'),
(1655, 40, '2026-06-12', 'day_4', 24.66, 32.38, 82, 17.82, 16.16, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":24.66,\"temp_max\":32.38,\"humidity\":82,\"rainfall_mm\":17.82,\"wind_speed_kmh\":16.16,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:29'),
(1656, 40, '2026-06-13', 'day_5', 24.81, 31.97, 83, 11.80, 18.79, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":24.81,\"temp_max\":31.97,\"humidity\":83,\"rainfall_mm\":11.8,\"wind_speed_kmh\":18.79,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:29'),
(1657, 41, '2026-06-09', 'current', 30.53, 34.21, 74, 0.00, 14.22, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":30.53,\"temp_max\":34.21,\"humidity\":74,\"rainfall_mm\":0,\"wind_speed_kmh\":14.22,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:29'),
(1658, 41, '2026-06-09', 'today', 29.74, 41.29, 53, 0.00, 23.90, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":29.74,\"temp_max\":41.29,\"humidity\":53,\"rainfall_mm\":0,\"wind_speed_kmh\":23.9,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:29'),
(1659, 41, '2026-06-10', 'tomorrow', 27.15, 41.03, 60, 7.29, 33.84, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.15,\"temp_max\":41.03,\"humidity\":60,\"rainfall_mm\":7.29,\"wind_speed_kmh\":33.84,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:29'),
(1660, 41, '2026-06-11', 'day_3', 25.11, 35.18, 71, 15.23, 23.11, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":25.11,\"temp_max\":35.18,\"humidity\":71,\"rainfall_mm\":15.23,\"wind_speed_kmh\":23.11,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:29'),
(1661, 41, '2026-06-12', 'day_4', 26.12, 37.24, 68, 1.27, 24.41, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.12,\"temp_max\":37.24,\"humidity\":68,\"rainfall_mm\":1.27,\"wind_speed_kmh\":24.41,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:29'),
(1662, 41, '2026-06-13', 'day_5', 27.43, 34.95, 69, 2.42, 23.58, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":27.43,\"temp_max\":34.95,\"humidity\":69,\"rainfall_mm\":2.42,\"wind_speed_kmh\":23.58,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:29'),
(1663, 42, '2026-06-09', 'current', 29.97, 33.50, 81, 0.00, 18.40, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.97,\"temp_max\":33.5,\"humidity\":81,\"rainfall_mm\":0,\"wind_speed_kmh\":18.4,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:29'),
(1664, 42, '2026-06-09', 'today', 25.14, 40.61, 71, 29.53, 31.32, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":25.14,\"temp_max\":40.61,\"humidity\":71,\"rainfall_mm\":29.53,\"wind_speed_kmh\":31.32,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:29'),
(1665, 42, '2026-06-10', 'tomorrow', 28.34, 39.28, 70, 10.80, 24.62, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.34,\"temp_max\":39.28,\"humidity\":70,\"rainfall_mm\":10.8,\"wind_speed_kmh\":24.62,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:29'),
(1666, 42, '2026-06-11', 'day_3', 27.91, 35.79, 72, 4.14, 24.01, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.91,\"temp_max\":35.79,\"humidity\":72,\"rainfall_mm\":4.14,\"wind_speed_kmh\":24.01,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:29'),
(1667, 42, '2026-06-12', 'day_4', 26.57, 33.82, 82, 11.37, 21.96, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.57,\"temp_max\":33.82,\"humidity\":82,\"rainfall_mm\":11.37,\"wind_speed_kmh\":21.96,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:29'),
(1668, 42, '2026-06-13', 'day_5', 25.90, 30.45, 84, 12.08, 23.40, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.9,\"temp_max\":30.45,\"humidity\":84,\"rainfall_mm\":12.08,\"wind_speed_kmh\":23.4,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:29'),
(1669, 43, '2026-06-09', 'current', 29.16, 32.49, 81, 0.00, 17.32, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.16,\"temp_max\":32.49,\"humidity\":81,\"rainfall_mm\":0,\"wind_speed_kmh\":17.32,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:30'),
(1670, 43, '2026-06-09', 'today', 27.37, 37.18, 70, 2.97, 36.83, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":27.37,\"temp_max\":37.18,\"humidity\":70,\"rainfall_mm\":2.97,\"wind_speed_kmh\":36.83,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:30'),
(1671, 43, '2026-06-10', 'tomorrow', 28.32, 36.84, 72, 4.09, 26.93, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.32,\"temp_max\":36.84,\"humidity\":72,\"rainfall_mm\":4.09,\"wind_speed_kmh\":26.93,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:30'),
(1672, 43, '2026-06-11', 'day_3', 27.99, 34.62, 74, 16.76, 21.74, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.99,\"temp_max\":34.62,\"humidity\":74,\"rainfall_mm\":16.76,\"wind_speed_kmh\":21.74,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:30'),
(1673, 43, '2026-06-12', 'day_4', 27.34, 33.29, 75, 24.50, 20.41, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.34,\"temp_max\":33.29,\"humidity\":75,\"rainfall_mm\":24.5,\"wind_speed_kmh\":20.41,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:30'),
(1674, 43, '2026-06-13', 'day_5', 25.91, 30.60, 81, 7.54, 23.40, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.91,\"temp_max\":30.6,\"humidity\":81,\"rainfall_mm\":7.54,\"wind_speed_kmh\":23.4,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:30'),
(1675, 44, '2026-06-09', 'current', 29.18, 32.41, 82, 0.00, 17.71, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.18,\"temp_max\":32.41,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":17.71,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:30'),
(1676, 44, '2026-06-09', 'today', 26.98, 36.91, 72, 3.34, 39.42, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":26.98,\"temp_max\":36.91,\"humidity\":72,\"rainfall_mm\":3.34,\"wind_speed_kmh\":39.42,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:30'),
(1677, 44, '2026-06-10', 'tomorrow', 28.29, 36.48, 73, 2.69, 27.14, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.29,\"temp_max\":36.48,\"humidity\":73,\"rainfall_mm\":2.69,\"wind_speed_kmh\":27.14,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:30'),
(1678, 44, '2026-06-11', 'day_3', 27.78, 34.70, 74, 15.65, 22.18, 'Rain', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.78,\"temp_max\":34.7,\"humidity\":74,\"rainfall_mm\":15.65,\"wind_speed_kmh\":22.18,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:30'),
(1679, 44, '2026-06-12', 'day_4', 27.13, 33.37, 76, 23.04, 21.02, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.13,\"temp_max\":33.37,\"humidity\":76,\"rainfall_mm\":23.04,\"wind_speed_kmh\":21.02,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:30'),
(1680, 44, '2026-06-13', 'day_5', 25.83, 30.06, 83, 8.47, 23.47, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.83,\"temp_max\":30.06,\"humidity\":83,\"rainfall_mm\":8.47,\"wind_speed_kmh\":23.47,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:30');
INSERT INTO `weather_forecasts` (`forecast_id`, `district_id`, `forecast_date`, `forecast_for`, `temp_min`, `temp_max`, `humidity`, `rainfall_mm`, `wind_speed_kmh`, `conditions`, `icon`, `raw_payload`, `fetched_at`) VALUES
(1681, 45, '2026-06-09', 'current', 30.92, 34.53, 71, 0.00, 15.98, 'Clear', '01d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":30.92,\"temp_max\":34.53,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":15.98,\"conditions\":\"Clear\",\"icon\":\"01d\"}', '2026-06-09 01:17:30'),
(1682, 45, '2026-06-09', 'today', 28.91, 41.73, 51, 0.00, 26.42, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":28.91,\"temp_max\":41.73,\"humidity\":51,\"rainfall_mm\":0,\"wind_speed_kmh\":26.42,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:30'),
(1683, 45, '2026-06-10', 'tomorrow', 28.78, 41.44, 56, 1.00, 31.64, 'Clouds', '01d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.78,\"temp_max\":41.44,\"humidity\":56,\"rainfall_mm\":1,\"wind_speed_kmh\":31.64,\"conditions\":\"Clouds\",\"icon\":\"01d\"}', '2026-06-09 01:17:30'),
(1684, 45, '2026-06-11', 'day_3', 26.17, 36.33, 67, 8.34, 25.85, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":26.17,\"temp_max\":36.33,\"humidity\":67,\"rainfall_mm\":8.34,\"wind_speed_kmh\":25.85,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:30'),
(1685, 45, '2026-06-12', 'day_4', 26.38, 38.36, 61, 0.41, 24.41, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.38,\"temp_max\":38.36,\"humidity\":61,\"rainfall_mm\":0.41,\"wind_speed_kmh\":24.41,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:30'),
(1686, 45, '2026-06-13', 'day_5', 27.70, 36.98, 63, 1.07, 23.69, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":27.7,\"temp_max\":36.98,\"humidity\":63,\"rainfall_mm\":1.07,\"wind_speed_kmh\":23.69,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:30'),
(1687, 46, '2026-06-09', 'current', 26.98, 30.03, 87, 0.17, 16.31, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":26.98,\"temp_max\":30.03,\"humidity\":87,\"rainfall_mm\":0.17,\"wind_speed_kmh\":16.31,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1688, 46, '2026-06-09', 'today', 25.53, 33.06, 78, 1.72, 17.60, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":25.53,\"temp_max\":33.06,\"humidity\":78,\"rainfall_mm\":1.72,\"wind_speed_kmh\":17.6,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:31'),
(1689, 46, '2026-06-10', 'tomorrow', 25.49, 33.06, 82, 16.66, 19.62, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.49,\"temp_max\":33.06,\"humidity\":82,\"rainfall_mm\":16.66,\"wind_speed_kmh\":19.62,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1690, 46, '2026-06-11', 'day_3', 24.81, 30.85, 90, 43.54, 16.67, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":24.81,\"temp_max\":30.85,\"humidity\":90,\"rainfall_mm\":43.54,\"wind_speed_kmh\":16.67,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1691, 46, '2026-06-12', 'day_4', 24.37, 32.28, 84, 24.38, 18.36, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":24.37,\"temp_max\":32.28,\"humidity\":84,\"rainfall_mm\":24.38,\"wind_speed_kmh\":18.36,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1692, 46, '2026-06-13', 'day_5', 25.05, 31.74, 83, 13.32, 19.91, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.05,\"temp_max\":31.74,\"humidity\":83,\"rainfall_mm\":13.32,\"wind_speed_kmh\":19.91,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1693, 47, '2026-06-09', 'current', 27.83, 30.92, 84, 1.40, 15.59, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":27.83,\"temp_max\":30.92,\"humidity\":84,\"rainfall_mm\":1.4,\"wind_speed_kmh\":15.59,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1694, 47, '2026-06-09', 'today', 25.84, 38.65, 74, 18.78, 15.73, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":25.84,\"temp_max\":38.65,\"humidity\":74,\"rainfall_mm\":18.78,\"wind_speed_kmh\":15.73,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1695, 47, '2026-06-10', 'tomorrow', 23.52, 35.31, 75, 14.10, 35.24, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":23.52,\"temp_max\":35.31,\"humidity\":75,\"rainfall_mm\":14.1,\"wind_speed_kmh\":35.24,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1696, 47, '2026-06-11', 'day_3', 24.23, 32.31, 79, 19.40, 22.07, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":24.23,\"temp_max\":32.31,\"humidity\":79,\"rainfall_mm\":19.4,\"wind_speed_kmh\":22.07,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1697, 47, '2026-06-12', 'day_4', 25.41, 32.36, 79, 14.95, 15.37, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.41,\"temp_max\":32.36,\"humidity\":79,\"rainfall_mm\":14.95,\"wind_speed_kmh\":15.37,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1698, 47, '2026-06-13', 'day_5', 25.85, 33.41, 77, 15.17, 19.08, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.85,\"temp_max\":33.41,\"humidity\":77,\"rainfall_mm\":15.17,\"wind_speed_kmh\":19.08,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1699, 48, '2026-06-09', 'current', 28.87, 30.10, 85, 0.11, 23.58, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":28.87,\"temp_max\":30.1,\"humidity\":85,\"rainfall_mm\":0.11,\"wind_speed_kmh\":23.58,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1700, 48, '2026-06-09', 'today', 28.39, 31.18, 85, 6.73, 28.55, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":28.39,\"temp_max\":31.18,\"humidity\":85,\"rainfall_mm\":6.73,\"wind_speed_kmh\":28.55,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1701, 48, '2026-06-10', 'tomorrow', 28.35, 31.00, 85, 3.93, 30.49, 'Rain', '02d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.35,\"temp_max\":31,\"humidity\":85,\"rainfall_mm\":3.93,\"wind_speed_kmh\":30.49,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-09 01:17:31'),
(1702, 48, '2026-06-11', 'day_3', 28.02, 31.20, 83, 2.41, 27.11, 'Rain', '02d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":28.02,\"temp_max\":31.2,\"humidity\":83,\"rainfall_mm\":2.41,\"wind_speed_kmh\":27.11,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-09 01:17:31'),
(1703, 48, '2026-06-12', 'day_4', 28.12, 30.88, 80, 18.03, 25.27, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":28.12,\"temp_max\":30.88,\"humidity\":80,\"rainfall_mm\":18.03,\"wind_speed_kmh\":25.27,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:31'),
(1704, 48, '2026-06-13', 'day_5', 26.77, 27.79, 85, 7.45, 22.10, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":26.77,\"temp_max\":27.79,\"humidity\":85,\"rainfall_mm\":7.45,\"wind_speed_kmh\":22.1,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:31'),
(1705, 49, '2026-06-09', 'current', 30.62, 34.01, 76, 0.00, 18.90, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":30.62,\"temp_max\":34.01,\"humidity\":76,\"rainfall_mm\":0,\"wind_speed_kmh\":18.9,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:32'),
(1706, 49, '2026-06-09', 'today', 27.43, 40.83, 62, 0.96, 44.14, 'Clouds', '01d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":27.43,\"temp_max\":40.83,\"humidity\":62,\"rainfall_mm\":0.96,\"wind_speed_kmh\":44.14,\"conditions\":\"Clouds\",\"icon\":\"01d\"}', '2026-06-09 01:17:32'),
(1707, 49, '2026-06-10', 'tomorrow', 28.51, 40.29, 64, 5.71, 36.07, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.51,\"temp_max\":40.29,\"humidity\":64,\"rainfall_mm\":5.71,\"wind_speed_kmh\":36.07,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:32'),
(1708, 49, '2026-06-11', 'day_3', 26.11, 37.27, 69, 10.60, 25.09, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":26.11,\"temp_max\":37.27,\"humidity\":69,\"rainfall_mm\":10.6,\"wind_speed_kmh\":25.09,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:32'),
(1709, 49, '2026-06-12', 'day_4', 26.32, 35.46, 76, 21.34, 14.29, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.32,\"temp_max\":35.46,\"humidity\":76,\"rainfall_mm\":21.34,\"wind_speed_kmh\":14.29,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:32'),
(1710, 49, '2026-06-13', 'day_5', 26.62, 34.24, 76, 5.21, 20.45, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":26.62,\"temp_max\":34.24,\"humidity\":76,\"rainfall_mm\":5.21,\"wind_speed_kmh\":20.45,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:32'),
(1711, 50, '2026-06-09', 'current', 25.84, 29.03, 87, 1.76, 14.40, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":25.84,\"temp_max\":29.03,\"humidity\":87,\"rainfall_mm\":1.76,\"wind_speed_kmh\":14.4,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:32'),
(1712, 50, '2026-06-09', 'today', 24.40, 34.51, 78, 5.52, 22.10, 'Rain', '03d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":24.4,\"temp_max\":34.51,\"humidity\":78,\"rainfall_mm\":5.52,\"wind_speed_kmh\":22.1,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:32'),
(1713, 50, '2026-06-10', 'tomorrow', 21.05, 34.88, 76, 59.92, 23.40, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":21.05,\"temp_max\":34.88,\"humidity\":76,\"rainfall_mm\":59.92,\"wind_speed_kmh\":23.4,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:32'),
(1714, 50, '2026-06-11', 'day_3', 22.56, 32.05, 80, 16.39, 21.24, 'Rain', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":22.56,\"temp_max\":32.05,\"humidity\":80,\"rainfall_mm\":16.39,\"wind_speed_kmh\":21.24,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:32'),
(1715, 50, '2026-06-12', 'day_4', 23.80, 30.82, 86, 19.27, 17.86, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":23.8,\"temp_max\":30.82,\"humidity\":86,\"rainfall_mm\":19.27,\"wind_speed_kmh\":17.86,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:32'),
(1716, 50, '2026-06-13', 'day_5', 24.80, 32.24, 78, 25.40, 17.14, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":24.8,\"temp_max\":32.24,\"humidity\":78,\"rainfall_mm\":25.4,\"wind_speed_kmh\":17.14,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:32'),
(1717, 51, '2026-06-09', 'current', 30.73, 32.41, 81, 0.00, 17.17, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":30.73,\"temp_max\":32.41,\"humidity\":81,\"rainfall_mm\":0,\"wind_speed_kmh\":17.17,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:32'),
(1718, 51, '2026-06-09', 'today', 29.75, 32.97, 79, 0.27, 23.36, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":29.75,\"temp_max\":32.97,\"humidity\":79,\"rainfall_mm\":0.27,\"wind_speed_kmh\":23.36,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:32'),
(1719, 51, '2026-06-10', 'tomorrow', 29.77, 33.20, 76, 0.12, 26.93, 'Clouds', '01d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.77,\"temp_max\":33.2,\"humidity\":76,\"rainfall_mm\":0.12,\"wind_speed_kmh\":26.93,\"conditions\":\"Clouds\",\"icon\":\"01d\"}', '2026-06-09 01:17:32'),
(1720, 51, '2026-06-11', 'day_3', 29.48, 33.67, 76, 2.26, 27.83, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":29.48,\"temp_max\":33.67,\"humidity\":76,\"rainfall_mm\":2.26,\"wind_speed_kmh\":27.83,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:32'),
(1721, 51, '2026-06-12', 'day_4', 29.27, 33.02, 74, 7.04, 21.49, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":29.27,\"temp_max\":33.02,\"humidity\":74,\"rainfall_mm\":7.04,\"wind_speed_kmh\":21.49,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:32'),
(1722, 51, '2026-06-13', 'day_5', 25.69, 28.99, 87, 98.95, 20.52, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.69,\"temp_max\":28.99,\"humidity\":87,\"rainfall_mm\":98.95,\"wind_speed_kmh\":20.52,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:32'),
(1723, 52, '2026-06-09', 'current', 29.88, 33.34, 82, 0.00, 15.52, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.88,\"temp_max\":33.34,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":15.52,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:33'),
(1724, 52, '2026-06-09', 'today', 29.30, 35.97, 73, 2.38, 24.55, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":29.3,\"temp_max\":35.97,\"humidity\":73,\"rainfall_mm\":2.38,\"wind_speed_kmh\":24.55,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:33'),
(1725, 52, '2026-06-10', 'tomorrow', 29.16, 36.53, 68, 0.00, 24.05, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.16,\"temp_max\":36.53,\"humidity\":68,\"rainfall_mm\":0,\"wind_speed_kmh\":24.05,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:33'),
(1726, 52, '2026-06-11', 'day_3', 29.11, 37.16, 69, 1.32, 22.79, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":29.11,\"temp_max\":37.16,\"humidity\":69,\"rainfall_mm\":1.32,\"wind_speed_kmh\":22.79,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:33'),
(1727, 52, '2026-06-12', 'day_4', 26.71, 34.50, 79, 59.43, 15.59, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.71,\"temp_max\":34.5,\"humidity\":79,\"rainfall_mm\":59.43,\"wind_speed_kmh\":15.59,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:33'),
(1728, 52, '2026-06-13', 'day_5', 25.45, 27.98, 90, 44.27, 20.59, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.45,\"temp_max\":27.98,\"humidity\":90,\"rainfall_mm\":44.27,\"wind_speed_kmh\":20.59,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:33'),
(1729, 53, '2026-06-09', 'current', 29.71, 32.90, 82, 0.00, 17.06, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.71,\"temp_max\":32.9,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":17.06,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:33'),
(1730, 53, '2026-06-09', 'today', 25.03, 39.58, 71, 13.07, 46.84, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":25.03,\"temp_max\":39.58,\"humidity\":71,\"rainfall_mm\":13.07,\"wind_speed_kmh\":46.84,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:33'),
(1731, 53, '2026-06-10', 'tomorrow', 28.27, 38.77, 72, 10.30, 28.91, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.27,\"temp_max\":38.77,\"humidity\":72,\"rainfall_mm\":10.3,\"wind_speed_kmh\":28.91,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:33'),
(1732, 53, '2026-06-11', 'day_3', 27.74, 35.28, 75, 6.81, 26.14, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.74,\"temp_max\":35.28,\"humidity\":75,\"rainfall_mm\":6.81,\"wind_speed_kmh\":26.14,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:33'),
(1733, 53, '2026-06-12', 'day_4', 26.43, 34.63, 79, 7.30, 33.05, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.43,\"temp_max\":34.63,\"humidity\":79,\"rainfall_mm\":7.3,\"wind_speed_kmh\":33.05,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:33'),
(1734, 53, '2026-06-13', 'day_5', 26.16, 31.16, 81, 6.46, 25.70, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":26.16,\"temp_max\":31.16,\"humidity\":81,\"rainfall_mm\":6.46,\"wind_speed_kmh\":25.7,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:33'),
(1735, 54, '2026-06-09', 'current', 30.91, 34.48, 71, 0.00, 18.58, 'Clear', '01d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":30.91,\"temp_max\":34.48,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":18.58,\"conditions\":\"Clear\",\"icon\":\"01d\"}', '2026-06-09 01:17:33'),
(1736, 54, '2026-06-09', 'today', 29.17, 42.08, 52, 0.12, 31.36, 'Clear', '03d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":29.17,\"temp_max\":42.08,\"humidity\":52,\"rainfall_mm\":0.12,\"wind_speed_kmh\":31.36,\"conditions\":\"Clear\",\"icon\":\"03d\"}', '2026-06-09 01:17:33'),
(1737, 54, '2026-06-10', 'tomorrow', 27.08, 41.49, 59, 6.29, 44.71, 'Clouds', '01d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.08,\"temp_max\":41.49,\"humidity\":59,\"rainfall_mm\":6.29,\"wind_speed_kmh\":44.71,\"conditions\":\"Clouds\",\"icon\":\"01d\"}', '2026-06-09 01:17:33'),
(1738, 54, '2026-06-11', 'day_3', 26.28, 36.90, 68, 7.32, 20.23, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":26.28,\"temp_max\":36.9,\"humidity\":68,\"rainfall_mm\":7.32,\"wind_speed_kmh\":20.23,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:33'),
(1739, 54, '2026-06-12', 'day_4', 26.30, 37.66, 68, 2.72, 24.34, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.3,\"temp_max\":37.66,\"humidity\":68,\"rainfall_mm\":2.72,\"wind_speed_kmh\":24.34,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:33'),
(1740, 54, '2026-06-13', 'day_5', 27.45, 35.47, 68, 0.93, 22.57, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":27.45,\"temp_max\":35.47,\"humidity\":68,\"rainfall_mm\":0.93,\"wind_speed_kmh\":22.57,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:33'),
(1741, 55, '2026-06-09', 'current', 26.36, 30.42, 87, 0.33, 8.10, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":26.36,\"temp_max\":30.42,\"humidity\":87,\"rainfall_mm\":0.33,\"wind_speed_kmh\":8.1,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1742, 55, '2026-06-09', 'today', 25.14, 34.28, 79, 1.61, 16.45, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":25.14,\"temp_max\":34.28,\"humidity\":79,\"rainfall_mm\":1.61,\"wind_speed_kmh\":16.45,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1743, 55, '2026-06-10', 'tomorrow', 24.72, 32.98, 80, 6.95, 19.51, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.72,\"temp_max\":32.98,\"humidity\":80,\"rainfall_mm\":6.95,\"wind_speed_kmh\":19.51,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1744, 55, '2026-06-11', 'day_3', 25.38, 35.53, 75, 0.22, 16.49, 'Clear', '01d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":25.38,\"temp_max\":35.53,\"humidity\":75,\"rainfall_mm\":0.22,\"wind_speed_kmh\":16.49,\"conditions\":\"Clear\",\"icon\":\"01d\"}', '2026-06-09 01:17:34'),
(1745, 55, '2026-06-12', 'day_4', 25.51, 33.41, 76, 2.44, 15.62, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.51,\"temp_max\":33.41,\"humidity\":76,\"rainfall_mm\":2.44,\"wind_speed_kmh\":15.62,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-09 01:17:34'),
(1746, 55, '2026-06-13', 'day_5', 24.42, 28.28, 90, 12.59, 9.68, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":24.42,\"temp_max\":28.28,\"humidity\":90,\"rainfall_mm\":12.59,\"wind_speed_kmh\":9.68,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1747, 56, '2026-06-09', 'current', 27.10, 29.72, 85, 0.87, 18.18, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":27.1,\"temp_max\":29.72,\"humidity\":85,\"rainfall_mm\":0.87,\"wind_speed_kmh\":18.18,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1748, 56, '2026-06-09', 'today', 24.98, 35.77, 77, 15.13, 18.47, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":24.98,\"temp_max\":35.77,\"humidity\":77,\"rainfall_mm\":15.13,\"wind_speed_kmh\":18.47,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1749, 56, '2026-06-10', 'tomorrow', 24.91, 33.52, 78, 9.57, 19.55, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.91,\"temp_max\":33.52,\"humidity\":78,\"rainfall_mm\":9.57,\"wind_speed_kmh\":19.55,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1750, 56, '2026-06-11', 'day_3', 23.64, 32.49, 82, 19.17, 16.02, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":23.64,\"temp_max\":32.49,\"humidity\":82,\"rainfall_mm\":19.17,\"wind_speed_kmh\":16.02,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1751, 56, '2026-06-12', 'day_4', 25.16, 33.10, 79, 13.66, 19.30, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.16,\"temp_max\":33.1,\"humidity\":79,\"rainfall_mm\":13.66,\"wind_speed_kmh\":19.3,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1752, 56, '2026-06-13', 'day_5', 25.69, 32.79, 80, 9.05, 22.10, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.69,\"temp_max\":32.79,\"humidity\":80,\"rainfall_mm\":9.05,\"wind_speed_kmh\":22.1,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1753, 57, '2026-06-09', 'current', 31.26, 35.09, 73, 0.00, 19.19, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":31.26,\"temp_max\":35.09,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":19.19,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:34'),
(1754, 57, '2026-06-09', 'today', 28.35, 37.68, 66, 16.90, 26.82, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":28.35,\"temp_max\":37.68,\"humidity\":66,\"rainfall_mm\":16.9,\"wind_speed_kmh\":26.82,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1755, 57, '2026-06-10', 'tomorrow', 29.24, 39.25, 64, 0.46, 24.70, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.24,\"temp_max\":39.25,\"humidity\":64,\"rainfall_mm\":0.46,\"wind_speed_kmh\":24.7,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1756, 57, '2026-06-11', 'day_3', 29.58, 37.35, 65, 0.00, 24.16, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":29.58,\"temp_max\":37.35,\"humidity\":65,\"rainfall_mm\":0,\"wind_speed_kmh\":24.16,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-09 01:17:34'),
(1757, 57, '2026-06-12', 'day_4', 27.87, 35.30, 72, 17.14, 17.50, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.87,\"temp_max\":35.3,\"humidity\":72,\"rainfall_mm\":17.14,\"wind_speed_kmh\":17.5,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:34'),
(1758, 57, '2026-06-13', 'day_5', 27.71, 33.48, 74, 1.53, 22.00, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":27.71,\"temp_max\":33.48,\"humidity\":74,\"rainfall_mm\":1.53,\"wind_speed_kmh\":22,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:34'),
(1759, 58, '2026-06-09', 'current', 28.96, 31.79, 85, 0.00, 17.57, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":28.96,\"temp_max\":31.79,\"humidity\":85,\"rainfall_mm\":0,\"wind_speed_kmh\":17.57,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:35'),
(1760, 58, '2026-06-09', 'today', 26.36, 37.18, 76, 6.29, 44.21, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":26.36,\"temp_max\":37.18,\"humidity\":76,\"rainfall_mm\":6.29,\"wind_speed_kmh\":44.21,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:35'),
(1761, 58, '2026-06-10', 'tomorrow', 28.03, 35.29, 76, 1.86, 28.33, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.03,\"temp_max\":35.29,\"humidity\":76,\"rainfall_mm\":1.86,\"wind_speed_kmh\":28.33,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-09 01:17:35'),
(1762, 58, '2026-06-11', 'day_3', 26.74, 34.61, 77, 14.56, 24.55, 'Rain', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":26.74,\"temp_max\":34.61,\"humidity\":77,\"rainfall_mm\":14.56,\"wind_speed_kmh\":24.55,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:35'),
(1763, 58, '2026-06-12', 'day_4', 25.82, 33.55, 79, 17.39, 20.52, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.82,\"temp_max\":33.55,\"humidity\":79,\"rainfall_mm\":17.39,\"wind_speed_kmh\":20.52,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:35'),
(1764, 58, '2026-06-13', 'day_5', 25.68, 28.99, 86, 9.63, 23.47, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.68,\"temp_max\":28.99,\"humidity\":86,\"rainfall_mm\":9.63,\"wind_speed_kmh\":23.47,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:35'),
(1765, 59, '2026-06-09', 'current', 26.84, 31.34, 84, 0.65, 14.87, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":26.84,\"temp_max\":31.34,\"humidity\":84,\"rainfall_mm\":0.65,\"wind_speed_kmh\":14.87,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:35'),
(1766, 59, '2026-06-09', 'today', 24.68, 38.33, 74, 4.72, 24.41, 'Rain', '02d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":24.68,\"temp_max\":38.33,\"humidity\":74,\"rainfall_mm\":4.72,\"wind_speed_kmh\":24.41,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-09 01:17:35'),
(1767, 59, '2026-06-10', 'tomorrow', 25.38, 35.66, 77, 8.94, 21.46, 'Rain', '04d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.38,\"temp_max\":35.66,\"humidity\":77,\"rainfall_mm\":8.94,\"wind_speed_kmh\":21.46,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:35'),
(1768, 59, '2026-06-11', 'day_3', 26.60, 32.97, 85, 29.73, 19.66, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":26.6,\"temp_max\":32.97,\"humidity\":85,\"rainfall_mm\":29.73,\"wind_speed_kmh\":19.66,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:35'),
(1769, 59, '2026-06-12', 'day_4', 25.02, 33.02, 81, 14.99, 18.86, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":25.02,\"temp_max\":33.02,\"humidity\":81,\"rainfall_mm\":14.99,\"wind_speed_kmh\":18.86,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:35'),
(1770, 59, '2026-06-13', 'day_5', 24.90, 33.40, 81, 11.41, 17.39, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":24.9,\"temp_max\":33.4,\"humidity\":81,\"rainfall_mm\":11.41,\"wind_speed_kmh\":17.39,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:35'),
(1771, 60, '2026-06-09', 'current', 28.94, 30.39, 82, 0.81, 20.74, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":28.94,\"temp_max\":30.39,\"humidity\":82,\"rainfall_mm\":0.81,\"wind_speed_kmh\":20.74,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:35'),
(1772, 60, '2026-06-09', 'today', 27.91, 34.61, 72, 3.08, 34.27, 'Rain', '02d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":27.91,\"temp_max\":34.61,\"humidity\":72,\"rainfall_mm\":3.08,\"wind_speed_kmh\":34.27,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-09 01:17:35'),
(1773, 60, '2026-06-10', 'tomorrow', 27.40, 34.28, 74, 1.69, 33.77, 'Clouds', '01d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.4,\"temp_max\":34.28,\"humidity\":74,\"rainfall_mm\":1.69,\"wind_speed_kmh\":33.77,\"conditions\":\"Clouds\",\"icon\":\"01d\"}', '2026-06-09 01:17:35'),
(1774, 60, '2026-06-11', 'day_3', 27.05, 32.77, 75, 39.42, 22.03, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.05,\"temp_max\":32.77,\"humidity\":75,\"rainfall_mm\":39.42,\"wind_speed_kmh\":22.03,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:35'),
(1775, 60, '2026-06-12', 'day_4', 27.03, 32.49, 76, 15.31, 17.89, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":27.03,\"temp_max\":32.49,\"humidity\":76,\"rainfall_mm\":15.31,\"wind_speed_kmh\":17.89,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:35'),
(1776, 60, '2026-06-13', 'day_5', 27.44, 32.25, 79, 5.08, 26.86, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":27.44,\"temp_max\":32.25,\"humidity\":79,\"rainfall_mm\":5.08,\"wind_speed_kmh\":26.86,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:35'),
(1777, 61, '2026-06-09', 'current', 26.95, 29.39, 87, 2.58, 9.40, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":26.95,\"temp_max\":29.39,\"humidity\":87,\"rainfall_mm\":2.58,\"wind_speed_kmh\":9.4,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:36'),
(1778, 61, '2026-06-09', 'today', 24.52, 32.55, 81, 19.86, 13.03, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":24.52,\"temp_max\":32.55,\"humidity\":81,\"rainfall_mm\":19.86,\"wind_speed_kmh\":13.03,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:36'),
(1779, 61, '2026-06-10', 'tomorrow', 24.99, 32.57, 83, 24.33, 14.15, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.99,\"temp_max\":32.57,\"humidity\":83,\"rainfall_mm\":24.33,\"wind_speed_kmh\":14.15,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:36'),
(1780, 61, '2026-06-11', 'day_3', 24.62, 30.75, 85, 33.33, 9.58, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":24.62,\"temp_max\":30.75,\"humidity\":85,\"rainfall_mm\":33.33,\"wind_speed_kmh\":9.58,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:36'),
(1781, 61, '2026-06-12', 'day_4', 24.08, 30.78, 86, 41.11, 12.56, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":24.08,\"temp_max\":30.78,\"humidity\":86,\"rainfall_mm\":41.11,\"wind_speed_kmh\":12.56,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:36'),
(1782, 61, '2026-06-13', 'day_5', 24.72, 30.74, 86, 19.49, 14.90, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":24.72,\"temp_max\":30.74,\"humidity\":86,\"rainfall_mm\":19.49,\"wind_speed_kmh\":14.9,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:36'),
(1783, 62, '2026-06-09', 'current', 26.78, 29.42, 84, 2.60, 6.55, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":26.78,\"temp_max\":29.42,\"humidity\":84,\"rainfall_mm\":2.6,\"wind_speed_kmh\":6.55,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:36'),
(1784, 62, '2026-06-09', 'today', 24.90, 34.24, 78, 22.56, 16.31, 'Rain', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":24.9,\"temp_max\":34.24,\"humidity\":78,\"rainfall_mm\":22.56,\"wind_speed_kmh\":16.31,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:36'),
(1785, 62, '2026-06-10', 'tomorrow', 25.00, 31.83, 84, 23.41, 10.26, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":25,\"temp_max\":31.83,\"humidity\":84,\"rainfall_mm\":23.41,\"wind_speed_kmh\":10.26,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:36'),
(1786, 62, '2026-06-11', 'day_3', 24.01, 29.39, 86, 29.92, 10.69, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":24.01,\"temp_max\":29.39,\"humidity\":86,\"rainfall_mm\":29.92,\"wind_speed_kmh\":10.69,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:36'),
(1787, 62, '2026-06-12', 'day_4', 23.52, 30.83, 88, 36.70, 11.45, 'Rain', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":23.52,\"temp_max\":30.83,\"humidity\":88,\"rainfall_mm\":36.7,\"wind_speed_kmh\":11.45,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:36'),
(1788, 62, '2026-06-13', 'day_5', 24.76, 30.40, 86, 19.43, 11.45, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":24.76,\"temp_max\":30.4,\"humidity\":86,\"rainfall_mm\":19.43,\"wind_speed_kmh\":11.45,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:36'),
(1789, 63, '2026-06-09', 'current', 29.14, 32.79, 79, 0.11, 20.34, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":29.14,\"temp_max\":32.79,\"humidity\":79,\"rainfall_mm\":0.11,\"wind_speed_kmh\":20.34,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:36'),
(1790, 63, '2026-06-09', 'today', 26.74, 38.54, 68, 2.80, 33.34, 'Rain', '04d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":26.74,\"temp_max\":38.54,\"humidity\":68,\"rainfall_mm\":2.8,\"wind_speed_kmh\":33.34,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:36'),
(1791, 63, '2026-06-10', 'tomorrow', 28.08, 35.59, 74, 3.75, 23.08, 'Rain', '04d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.08,\"temp_max\":35.59,\"humidity\":74,\"rainfall_mm\":3.75,\"wind_speed_kmh\":23.08,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:36'),
(1792, 63, '2026-06-11', 'day_3', 27.26, 34.48, 75, 24.20, 22.14, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":27.26,\"temp_max\":34.48,\"humidity\":75,\"rainfall_mm\":24.2,\"wind_speed_kmh\":22.14,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:36'),
(1793, 63, '2026-06-12', 'day_4', 26.11, 33.21, 77, 21.57, 19.98, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":26.11,\"temp_max\":33.21,\"humidity\":77,\"rainfall_mm\":21.57,\"wind_speed_kmh\":19.98,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:36'),
(1794, 63, '2026-06-13', 'day_5', 25.32, 32.08, 81, 8.48, 22.43, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.32,\"temp_max\":32.08,\"humidity\":81,\"rainfall_mm\":8.48,\"wind_speed_kmh\":22.43,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:36'),
(1795, 64, '2026-06-09', 'current', 26.88, 30.76, 86, 1.85, 10.84, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"current\",\"temp_min\":26.88,\"temp_max\":30.76,\"humidity\":86,\"rainfall_mm\":1.85,\"wind_speed_kmh\":10.84,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:37'),
(1796, 64, '2026-06-09', 'today', 25.77, 38.02, 74, 3.20, 18.11, 'Rain', '10d', '{\"forecast_date\":\"2026-06-09\",\"forecast_for\":\"today\",\"temp_min\":25.77,\"temp_max\":38.02,\"humidity\":74,\"rainfall_mm\":3.2,\"wind_speed_kmh\":18.11,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:37'),
(1797, 64, '2026-06-10', 'tomorrow', 21.40, 36.17, 73, 30.94, 31.32, 'Rain', '10d', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"tomorrow\",\"temp_min\":21.4,\"temp_max\":36.17,\"humidity\":73,\"rainfall_mm\":30.94,\"wind_speed_kmh\":31.32,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:37'),
(1798, 64, '2026-06-11', 'day_3', 23.16, 32.45, 80, 26.67, 19.51, 'Rain', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"day_3\",\"temp_min\":23.16,\"temp_max\":32.45,\"humidity\":80,\"rainfall_mm\":26.67,\"wind_speed_kmh\":19.51,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-09 01:17:37'),
(1799, 64, '2026-06-12', 'day_4', 24.73, 32.53, 81, 17.42, 20.84, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_4\",\"temp_min\":24.73,\"temp_max\":32.53,\"humidity\":81,\"rainfall_mm\":17.42,\"wind_speed_kmh\":20.84,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-09 01:17:37'),
(1800, 64, '2026-06-13', 'day_5', 25.64, 32.88, 77, 24.30, 16.81, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_5\",\"temp_min\":25.64,\"temp_max\":32.88,\"humidity\":77,\"rainfall_mm\":24.3,\"wind_speed_kmh\":16.81,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-09 01:17:37'),
(2161, 1, '2026-06-10', 'current', 27.33, 27.85, 82, 0.00, 8.50, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":27.33,\"temp_max\":27.85,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":8.5,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:04'),
(2162, 1, '2026-06-10', 'today', 27.85, 27.85, 82, 0.00, 8.50, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":27.85,\"temp_max\":27.85,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":8.5,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:04'),
(2163, 1, '2026-06-11', 'tomorrow', 25.95, 36.84, 68, 9.67, 23.44, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.95,\"temp_max\":36.84,\"humidity\":68,\"rainfall_mm\":9.67,\"wind_speed_kmh\":23.44,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:04'),
(2164, 1, '2026-06-12', 'day_3', 27.20, 35.28, 77, 6.59, 29.59, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.2,\"temp_max\":35.28,\"humidity\":77,\"rainfall_mm\":6.59,\"wind_speed_kmh\":29.59,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:04'),
(2165, 1, '2026-06-13', 'day_4', 26.25, 35.95, 80, 38.17, 22.68, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.25,\"temp_max\":35.95,\"humidity\":80,\"rainfall_mm\":38.17,\"wind_speed_kmh\":22.68,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:04'),
(2166, 1, '2026-06-14', 'day_5', 27.98, 35.46, 77, 0.41, 21.02, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.98,\"temp_max\":35.46,\"humidity\":77,\"rainfall_mm\":0.41,\"wind_speed_kmh\":21.02,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-10 18:00:04'),
(2167, 2, '2026-06-10', 'current', 23.67, 23.85, 97, 0.00, 4.72, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":23.67,\"temp_max\":23.85,\"humidity\":97,\"rainfall_mm\":0,\"wind_speed_kmh\":4.72,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:05'),
(2168, 2, '2026-06-10', 'today', 23.85, 23.85, 97, 0.00, 4.72, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":23.85,\"temp_max\":23.85,\"humidity\":97,\"rainfall_mm\":0,\"wind_speed_kmh\":4.72,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:05'),
(2169, 2, '2026-06-11', 'tomorrow', 23.98, 36.15, 81, 15.99, 7.78, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":23.98,\"temp_max\":36.15,\"humidity\":81,\"rainfall_mm\":15.99,\"wind_speed_kmh\":7.78,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:05'),
(2170, 2, '2026-06-12', 'day_3', 23.76, 27.93, 88, 1.72, 5.72, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":23.76,\"temp_max\":27.93,\"humidity\":88,\"rainfall_mm\":1.72,\"wind_speed_kmh\":5.72,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-10 18:00:05'),
(2171, 2, '2026-06-13', 'day_4', 22.94, 27.33, 89, 4.88, 6.30, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":22.94,\"temp_max\":27.33,\"humidity\":89,\"rainfall_mm\":4.88,\"wind_speed_kmh\":6.3,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:05'),
(2172, 2, '2026-06-14', 'day_5', 23.10, 30.44, 93, 16.46, 6.73, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":23.1,\"temp_max\":30.44,\"humidity\":93,\"rainfall_mm\":16.46,\"wind_speed_kmh\":6.73,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:05'),
(2173, 3, '2026-06-10', 'current', 28.67, 28.82, 87, 0.00, 18.14, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":28.67,\"temp_max\":28.82,\"humidity\":87,\"rainfall_mm\":0,\"wind_speed_kmh\":18.14,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:06'),
(2174, 3, '2026-06-10', 'today', 28.82, 28.82, 87, 0.00, 18.14, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":28.82,\"temp_max\":28.82,\"humidity\":87,\"rainfall_mm\":0,\"wind_speed_kmh\":18.14,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:06'),
(2175, 3, '2026-06-11', 'tomorrow', 28.57, 31.92, 78, 9.07, 23.00, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.57,\"temp_max\":31.92,\"humidity\":78,\"rainfall_mm\":9.07,\"wind_speed_kmh\":23,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:06'),
(2176, 3, '2026-06-12', 'day_3', 28.06, 30.55, 82, 25.00, 22.97, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":28.06,\"temp_max\":30.55,\"humidity\":82,\"rainfall_mm\":25,\"wind_speed_kmh\":22.97,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:06'),
(2177, 3, '2026-06-13', 'day_4', 27.67, 29.91, 83, 28.44, 24.91, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":27.67,\"temp_max\":29.91,\"humidity\":83,\"rainfall_mm\":28.44,\"wind_speed_kmh\":24.91,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:06'),
(2178, 3, '2026-06-14', 'day_5', 27.78, 30.21, 83, 9.18, 24.48, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.78,\"temp_max\":30.21,\"humidity\":83,\"rainfall_mm\":9.18,\"wind_speed_kmh\":24.48,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:06'),
(2179, 4, '2026-06-10', 'current', 28.07, 28.17, 87, 0.00, 9.72, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":28.07,\"temp_max\":28.17,\"humidity\":87,\"rainfall_mm\":0,\"wind_speed_kmh\":9.72,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:07'),
(2180, 4, '2026-06-10', 'today', 28.17, 28.17, 87, 0.00, 9.72, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":28.17,\"temp_max\":28.17,\"humidity\":87,\"rainfall_mm\":0,\"wind_speed_kmh\":9.72,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:07'),
(2181, 4, '2026-06-11', 'tomorrow', 27.94, 35.01, 72, 8.61, 20.16, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.94,\"temp_max\":35.01,\"humidity\":72,\"rainfall_mm\":8.61,\"wind_speed_kmh\":20.16,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:07'),
(2182, 4, '2026-06-12', 'day_3', 27.26, 33.72, 76, 13.37, 20.12, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.26,\"temp_max\":33.72,\"humidity\":76,\"rainfall_mm\":13.37,\"wind_speed_kmh\":20.12,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:07'),
(2183, 4, '2026-06-13', 'day_4', 27.06, 30.43, 83, 20.81, 20.95, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":27.06,\"temp_max\":30.43,\"humidity\":83,\"rainfall_mm\":20.81,\"wind_speed_kmh\":20.95,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:07'),
(2184, 4, '2026-06-14', 'day_5', 27.47, 31.91, 81, 11.32, 19.55, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.47,\"temp_max\":31.91,\"humidity\":81,\"rainfall_mm\":11.32,\"wind_speed_kmh\":19.55,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:07'),
(2185, 5, '2026-06-10', 'current', 28.41, 28.46, 88, 0.00, 17.32, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":28.41,\"temp_max\":28.46,\"humidity\":88,\"rainfall_mm\":0,\"wind_speed_kmh\":17.32,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:08'),
(2186, 5, '2026-06-10', 'today', 28.46, 28.46, 88, 0.00, 17.32, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":28.46,\"temp_max\":28.46,\"humidity\":88,\"rainfall_mm\":0,\"wind_speed_kmh\":17.32,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:08'),
(2187, 5, '2026-06-11', 'tomorrow', 28.31, 32.38, 78, 8.93, 22.36, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.31,\"temp_max\":32.38,\"humidity\":78,\"rainfall_mm\":8.93,\"wind_speed_kmh\":22.36,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:08'),
(2188, 5, '2026-06-12', 'day_3', 27.77, 30.88, 82, 23.67, 22.14, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.77,\"temp_max\":30.88,\"humidity\":82,\"rainfall_mm\":23.67,\"wind_speed_kmh\":22.14,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:08'),
(2189, 5, '2026-06-13', 'day_4', 27.43, 30.36, 82, 27.84, 23.98, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":27.43,\"temp_max\":30.36,\"humidity\":82,\"rainfall_mm\":27.84,\"wind_speed_kmh\":23.98,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:08'),
(2190, 5, '2026-06-14', 'day_5', 27.33, 30.49, 83, 8.14, 23.36, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.33,\"temp_max\":30.49,\"humidity\":83,\"rainfall_mm\":8.14,\"wind_speed_kmh\":23.36,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:08'),
(2191, 7, '2026-06-10', 'current', 25.47, 26.21, 92, 0.00, 8.53, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.47,\"temp_max\":26.21,\"humidity\":92,\"rainfall_mm\":0,\"wind_speed_kmh\":8.53,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:09'),
(2192, 7, '2026-06-10', 'today', 25.47, 25.47, 92, 0.00, 8.53, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.47,\"temp_max\":25.47,\"humidity\":92,\"rainfall_mm\":0,\"wind_speed_kmh\":8.53,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:09'),
(2193, 7, '2026-06-11', 'tomorrow', 25.14, 33.54, 79, 3.22, 18.18, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.14,\"temp_max\":33.54,\"humidity\":79,\"rainfall_mm\":3.22,\"wind_speed_kmh\":18.18,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-10 18:00:09'),
(2194, 7, '2026-06-12', 'day_3', 24.80, 29.60, 88, 21.88, 15.55, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":24.8,\"temp_max\":29.6,\"humidity\":88,\"rainfall_mm\":21.88,\"wind_speed_kmh\":15.55,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:09'),
(2195, 7, '2026-06-13', 'day_4', 24.62, 31.39, 86, 22.27, 19.66, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.62,\"temp_max\":31.39,\"humidity\":86,\"rainfall_mm\":22.27,\"wind_speed_kmh\":19.66,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:09'),
(2196, 7, '2026-06-14', 'day_5', 24.52, 29.62, 89, 17.13, 21.24, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.52,\"temp_max\":29.62,\"humidity\":89,\"rainfall_mm\":17.13,\"wind_speed_kmh\":21.24,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:09'),
(2197, 8, '2026-06-10', 'current', 25.24, 25.88, 93, 0.00, 10.84, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.24,\"temp_max\":25.88,\"humidity\":93,\"rainfall_mm\":0,\"wind_speed_kmh\":10.84,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:10'),
(2198, 8, '2026-06-10', 'today', 25.88, 25.88, 93, 0.00, 10.84, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.88,\"temp_max\":25.88,\"humidity\":93,\"rainfall_mm\":0,\"wind_speed_kmh\":10.84,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:10'),
(2199, 8, '2026-06-11', 'tomorrow', 24.98, 32.82, 78, 3.92, 13.39, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.98,\"temp_max\":32.82,\"humidity\":78,\"rainfall_mm\":3.92,\"wind_speed_kmh\":13.39,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:10'),
(2200, 8, '2026-06-12', 'day_3', 24.44, 30.78, 86, 18.93, 16.92, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":24.44,\"temp_max\":30.78,\"humidity\":86,\"rainfall_mm\":18.93,\"wind_speed_kmh\":16.92,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:10');
INSERT INTO `weather_forecasts` (`forecast_id`, `district_id`, `forecast_date`, `forecast_for`, `temp_min`, `temp_max`, `humidity`, `rainfall_mm`, `wind_speed_kmh`, `conditions`, `icon`, `raw_payload`, `fetched_at`) VALUES
(2201, 8, '2026-06-13', 'day_4', 24.06, 30.33, 88, 16.50, 17.78, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.06,\"temp_max\":30.33,\"humidity\":88,\"rainfall_mm\":16.5,\"wind_speed_kmh\":17.78,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:10'),
(2202, 8, '2026-06-14', 'day_5', 24.23, 30.27, 90, 9.73, 17.71, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.23,\"temp_max\":30.27,\"humidity\":90,\"rainfall_mm\":9.73,\"wind_speed_kmh\":17.71,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:10'),
(2203, 11, '2026-06-10', 'current', 27.56, 27.67, 70, 0.00, 11.92, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":27.56,\"temp_max\":27.67,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":11.92,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:10'),
(2204, 11, '2026-06-10', 'today', 27.67, 27.67, 70, 0.00, 11.92, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":27.67,\"temp_max\":27.67,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":11.92,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:10'),
(2205, 11, '2026-06-11', 'tomorrow', 26.62, 38.17, 69, 15.43, 34.13, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.62,\"temp_max\":38.17,\"humidity\":69,\"rainfall_mm\":15.43,\"wind_speed_kmh\":34.13,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-10 18:00:10'),
(2206, 11, '2026-06-12', 'day_3', 26.93, 37.05, 67, 7.10, 21.74, 'Rain', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.93,\"temp_max\":37.05,\"humidity\":67,\"rainfall_mm\":7.1,\"wind_speed_kmh\":21.74,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:10'),
(2207, 11, '2026-06-13', 'day_4', 27.15, 35.90, 76, 23.98, 32.26, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":27.15,\"temp_max\":35.9,\"humidity\":76,\"rainfall_mm\":23.98,\"wind_speed_kmh\":32.26,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:10'),
(2208, 11, '2026-06-14', 'day_5', 28.04, 37.29, 70, 0.00, 26.68, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":28.04,\"temp_max\":37.29,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":26.68,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:10'),
(2209, 12, '2026-06-10', 'current', 26.03, 26.30, 94, 0.00, 12.20, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.03,\"temp_max\":26.3,\"humidity\":94,\"rainfall_mm\":0,\"wind_speed_kmh\":12.2,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:11'),
(2210, 12, '2026-06-10', 'today', 26.30, 26.30, 94, 0.00, 12.20, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.3,\"temp_max\":26.3,\"humidity\":94,\"rainfall_mm\":0,\"wind_speed_kmh\":12.2,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:11'),
(2211, 12, '2026-06-11', 'tomorrow', 25.79, 33.61, 76, 1.26, 15.80, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.79,\"temp_max\":33.61,\"humidity\":76,\"rainfall_mm\":1.26,\"wind_speed_kmh\":15.8,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:11'),
(2212, 12, '2026-06-12', 'day_3', 24.98, 30.31, 87, 35.05, 19.33, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":24.98,\"temp_max\":30.31,\"humidity\":87,\"rainfall_mm\":35.05,\"wind_speed_kmh\":19.33,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:11'),
(2213, 12, '2026-06-13', 'day_4', 24.93, 31.45, 85, 17.22, 23.72, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.93,\"temp_max\":31.45,\"humidity\":85,\"rainfall_mm\":17.22,\"wind_speed_kmh\":23.72,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:11'),
(2214, 12, '2026-06-14', 'day_5', 25.00, 30.61, 89, 8.77, 21.96, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":25,\"temp_max\":30.61,\"humidity\":89,\"rainfall_mm\":8.77,\"wind_speed_kmh\":21.96,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:11'),
(2215, 13, '2026-06-10', 'current', 26.92, 27.42, 86, 0.11, 15.59, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.92,\"temp_max\":27.42,\"humidity\":86,\"rainfall_mm\":0.11,\"wind_speed_kmh\":15.59,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:12'),
(2216, 13, '2026-06-10', 'today', 27.42, 27.42, 86, 0.11, 15.59, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":27.42,\"temp_max\":27.42,\"humidity\":86,\"rainfall_mm\":0.11,\"wind_speed_kmh\":15.59,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:12'),
(2217, 13, '2026-06-11', 'tomorrow', 25.43, 31.68, 80, 22.82, 24.77, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.43,\"temp_max\":31.68,\"humidity\":80,\"rainfall_mm\":22.82,\"wind_speed_kmh\":24.77,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:12'),
(2218, 13, '2026-06-12', 'day_3', 25.66, 29.52, 86, 12.02, 22.21, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":25.66,\"temp_max\":29.52,\"humidity\":86,\"rainfall_mm\":12.02,\"wind_speed_kmh\":22.21,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:12'),
(2219, 13, '2026-06-13', 'day_4', 24.81, 27.90, 88, 9.24, 20.30, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.81,\"temp_max\":27.9,\"humidity\":88,\"rainfall_mm\":9.24,\"wind_speed_kmh\":20.3,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:12'),
(2220, 13, '2026-06-14', 'day_5', 24.69, 29.88, 85, 9.58, 24.05, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.69,\"temp_max\":29.88,\"humidity\":85,\"rainfall_mm\":9.58,\"wind_speed_kmh\":24.05,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:12'),
(2221, 14, '2026-06-10', 'current', 27.02, 27.02, 72, 0.00, 15.88, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":27.02,\"temp_max\":27.02,\"humidity\":72,\"rainfall_mm\":0,\"wind_speed_kmh\":15.88,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:13'),
(2222, 14, '2026-06-10', 'today', 27.02, 27.12, 74, 0.00, 15.88, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":27.02,\"temp_max\":27.12,\"humidity\":74,\"rainfall_mm\":0,\"wind_speed_kmh\":15.88,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:13'),
(2223, 14, '2026-06-11', 'tomorrow', 26.03, 36.04, 68, 7.68, 19.66, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.03,\"temp_max\":36.04,\"humidity\":68,\"rainfall_mm\":7.68,\"wind_speed_kmh\":19.66,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:13'),
(2224, 14, '2026-06-12', 'day_3', 27.05, 33.95, 73, 16.18, 18.94, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.05,\"temp_max\":33.95,\"humidity\":73,\"rainfall_mm\":16.18,\"wind_speed_kmh\":18.94,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:13'),
(2225, 14, '2026-06-13', 'day_4', 27.34, 33.02, 77, 10.68, 24.05, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":27.34,\"temp_max\":33.02,\"humidity\":77,\"rainfall_mm\":10.68,\"wind_speed_kmh\":24.05,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:13'),
(2226, 14, '2026-06-14', 'day_5', 26.63, 31.76, 80, 18.95, 21.31, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":26.63,\"temp_max\":31.76,\"humidity\":80,\"rainfall_mm\":18.95,\"wind_speed_kmh\":21.31,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:13'),
(2227, 15, '2026-06-10', 'current', 25.73, 26.06, 81, 3.06, 8.64, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.73,\"temp_max\":26.06,\"humidity\":81,\"rainfall_mm\":3.06,\"wind_speed_kmh\":8.64,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:14'),
(2228, 15, '2026-06-10', 'today', 26.06, 26.06, 81, 3.06, 8.64, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.06,\"temp_max\":26.06,\"humidity\":81,\"rainfall_mm\":3.06,\"wind_speed_kmh\":8.64,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:14'),
(2229, 15, '2026-06-11', 'tomorrow', 25.94, 36.59, 66, 1.51, 18.40, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.94,\"temp_max\":36.59,\"humidity\":66,\"rainfall_mm\":1.51,\"wind_speed_kmh\":18.4,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-10 18:00:14'),
(2230, 15, '2026-06-12', 'day_3', 26.68, 36.65, 68, 9.74, 22.14, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.68,\"temp_max\":36.65,\"humidity\":68,\"rainfall_mm\":9.74,\"wind_speed_kmh\":22.14,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:14'),
(2231, 15, '2026-06-13', 'day_4', 25.03, 31.87, 79, 23.25, 19.76, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.03,\"temp_max\":31.87,\"humidity\":79,\"rainfall_mm\":23.25,\"wind_speed_kmh\":19.76,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:14'),
(2232, 15, '2026-06-14', 'day_5', 25.15, 32.00, 83, 16.32, 20.02, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":25.15,\"temp_max\":32,\"humidity\":83,\"rainfall_mm\":16.32,\"wind_speed_kmh\":20.02,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:14'),
(2233, 16, '2026-06-10', 'current', 26.40, 26.64, 80, 0.00, 13.25, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.4,\"temp_max\":26.64,\"humidity\":80,\"rainfall_mm\":0,\"wind_speed_kmh\":13.25,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:15'),
(2234, 16, '2026-06-10', 'today', 26.40, 26.40, 80, 0.00, 13.25, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.4,\"temp_max\":26.4,\"humidity\":80,\"rainfall_mm\":0,\"wind_speed_kmh\":13.25,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:15'),
(2235, 16, '2026-06-11', 'tomorrow', 24.92, 35.90, 73, 17.37, 21.17, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.92,\"temp_max\":35.9,\"humidity\":73,\"rainfall_mm\":17.37,\"wind_speed_kmh\":21.17,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:15'),
(2236, 16, '2026-06-12', 'day_3', 26.51, 34.71, 76, 8.10, 18.97, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.51,\"temp_max\":34.71,\"humidity\":76,\"rainfall_mm\":8.1,\"wind_speed_kmh\":18.97,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:15'),
(2237, 16, '2026-06-13', 'day_4', 25.63, 32.00, 82, 22.60, 30.13, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.63,\"temp_max\":32,\"humidity\":82,\"rainfall_mm\":22.6,\"wind_speed_kmh\":30.13,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:15'),
(2238, 16, '2026-06-14', 'day_5', 26.42, 33.34, 82, 11.59, 21.38, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":26.42,\"temp_max\":33.34,\"humidity\":82,\"rainfall_mm\":11.59,\"wind_speed_kmh\":21.38,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:15'),
(2239, 17, '2026-06-10', 'current', 25.60, 26.29, 92, 0.00, 10.12, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.6,\"temp_max\":26.29,\"humidity\":92,\"rainfall_mm\":0,\"wind_speed_kmh\":10.12,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:16'),
(2240, 17, '2026-06-10', 'today', 26.29, 26.29, 92, 0.00, 10.12, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.29,\"temp_max\":26.29,\"humidity\":92,\"rainfall_mm\":0,\"wind_speed_kmh\":10.12,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:16'),
(2241, 17, '2026-06-11', 'tomorrow', 25.64, 33.22, 76, 4.79, 17.75, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.64,\"temp_max\":33.22,\"humidity\":76,\"rainfall_mm\":4.79,\"wind_speed_kmh\":17.75,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:16'),
(2242, 17, '2026-06-12', 'day_3', 25.88, 32.12, 81, 6.96, 21.13, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":25.88,\"temp_max\":32.12,\"humidity\":81,\"rainfall_mm\":6.96,\"wind_speed_kmh\":21.13,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:16'),
(2243, 17, '2026-06-13', 'day_4', 24.70, 30.48, 85, 21.21, 22.21, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.7,\"temp_max\":30.48,\"humidity\":85,\"rainfall_mm\":21.21,\"wind_speed_kmh\":22.21,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:16'),
(2244, 17, '2026-06-14', 'day_5', 24.80, 30.59, 88, 11.96, 22.28, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.8,\"temp_max\":30.59,\"humidity\":88,\"rainfall_mm\":11.96,\"wind_speed_kmh\":22.28,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:16'),
(2245, 18, '2026-06-10', 'current', 25.61, 26.19, 89, 0.00, 9.29, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.61,\"temp_max\":26.19,\"humidity\":89,\"rainfall_mm\":0,\"wind_speed_kmh\":9.29,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:17'),
(2246, 18, '2026-06-10', 'today', 26.19, 26.19, 89, 0.00, 9.29, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.19,\"temp_max\":26.19,\"humidity\":89,\"rainfall_mm\":0,\"wind_speed_kmh\":9.29,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:17'),
(2247, 18, '2026-06-11', 'tomorrow', 24.86, 35.05, 75, 14.73, 16.27, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.86,\"temp_max\":35.05,\"humidity\":75,\"rainfall_mm\":14.73,\"wind_speed_kmh\":16.27,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-10 18:00:17'),
(2248, 18, '2026-06-12', 'day_3', 24.88, 33.50, 77, 11.37, 19.58, 'Rain', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":24.88,\"temp_max\":33.5,\"humidity\":77,\"rainfall_mm\":11.37,\"wind_speed_kmh\":19.58,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:17'),
(2249, 18, '2026-06-13', 'day_4', 25.20, 33.95, 82, 10.98, 18.94, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.2,\"temp_max\":33.95,\"humidity\":82,\"rainfall_mm\":10.98,\"wind_speed_kmh\":18.94,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:17'),
(2250, 18, '2026-06-14', 'day_5', 24.91, 31.58, 87, 22.04, 20.16, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.91,\"temp_max\":31.58,\"humidity\":87,\"rainfall_mm\":22.04,\"wind_speed_kmh\":20.16,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:17'),
(2251, 19, '2026-06-10', 'current', 25.27, 25.28, 84, 0.00, 9.43, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.27,\"temp_max\":25.28,\"humidity\":84,\"rainfall_mm\":0,\"wind_speed_kmh\":9.43,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:18'),
(2252, 19, '2026-06-10', 'today', 25.27, 25.27, 84, 0.00, 9.43, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.27,\"temp_max\":25.27,\"humidity\":84,\"rainfall_mm\":0,\"wind_speed_kmh\":9.43,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:18'),
(2253, 19, '2026-06-11', 'tomorrow', 24.57, 34.97, 76, 16.71, 16.16, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.57,\"temp_max\":34.97,\"humidity\":76,\"rainfall_mm\":16.71,\"wind_speed_kmh\":16.16,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:18'),
(2254, 19, '2026-06-12', 'day_3', 25.54, 33.49, 77, 13.56, 17.89, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":25.54,\"temp_max\":33.49,\"humidity\":77,\"rainfall_mm\":13.56,\"wind_speed_kmh\":17.89,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:18'),
(2255, 19, '2026-06-13', 'day_4', 26.37, 32.43, 81, 15.28, 23.04, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.37,\"temp_max\":32.43,\"humidity\":81,\"rainfall_mm\":15.28,\"wind_speed_kmh\":23.04,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:18'),
(2256, 19, '2026-06-14', 'day_5', 25.65, 30.87, 85, 17.44, 19.26, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":25.65,\"temp_max\":30.87,\"humidity\":85,\"rainfall_mm\":17.44,\"wind_speed_kmh\":19.26,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:18'),
(2257, 20, '2026-06-10', 'current', 26.11, 26.53, 79, 0.00, 11.59, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.11,\"temp_max\":26.53,\"humidity\":79,\"rainfall_mm\":0,\"wind_speed_kmh\":11.59,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:19'),
(2258, 20, '2026-06-10', 'today', 26.11, 26.11, 79, 0.00, 11.59, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.11,\"temp_max\":26.11,\"humidity\":79,\"rainfall_mm\":0,\"wind_speed_kmh\":11.59,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:19'),
(2259, 20, '2026-06-11', 'tomorrow', 25.05, 36.47, 72, 22.82, 17.82, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.05,\"temp_max\":36.47,\"humidity\":72,\"rainfall_mm\":22.82,\"wind_speed_kmh\":17.82,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:19'),
(2260, 20, '2026-06-12', 'day_3', 26.44, 34.24, 76, 8.62, 17.28, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.44,\"temp_max\":34.24,\"humidity\":76,\"rainfall_mm\":8.62,\"wind_speed_kmh\":17.28,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:19'),
(2261, 20, '2026-06-13', 'day_4', 25.63, 32.91, 83, 22.90, 33.01, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.63,\"temp_max\":32.91,\"humidity\":83,\"rainfall_mm\":22.9,\"wind_speed_kmh\":33.01,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:19'),
(2262, 20, '2026-06-14', 'day_5', 26.72, 33.92, 81, 12.60, 19.73, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":26.72,\"temp_max\":33.92,\"humidity\":81,\"rainfall_mm\":12.6,\"wind_speed_kmh\":19.73,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:19'),
(2263, 21, '2026-06-10', 'current', 25.49, 25.68, 95, 0.00, 8.17, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.49,\"temp_max\":25.68,\"humidity\":95,\"rainfall_mm\":0,\"wind_speed_kmh\":8.17,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:20'),
(2264, 21, '2026-06-10', 'today', 25.68, 25.68, 95, 0.00, 8.17, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.68,\"temp_max\":25.68,\"humidity\":95,\"rainfall_mm\":0,\"wind_speed_kmh\":8.17,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:20'),
(2265, 21, '2026-06-11', 'tomorrow', 25.29, 33.89, 75, 3.26, 12.31, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.29,\"temp_max\":33.89,\"humidity\":75,\"rainfall_mm\":3.26,\"wind_speed_kmh\":12.31,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:20'),
(2266, 21, '2026-06-12', 'day_3', 25.03, 28.69, 89, 13.91, 10.33, 'Rain', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":25.03,\"temp_max\":28.69,\"humidity\":89,\"rainfall_mm\":13.91,\"wind_speed_kmh\":10.33,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:20'),
(2267, 21, '2026-06-13', 'day_4', 24.46, 31.15, 87, 19.15, 11.77, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.46,\"temp_max\":31.15,\"humidity\":87,\"rainfall_mm\":19.15,\"wind_speed_kmh\":11.77,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:20'),
(2268, 21, '2026-06-14', 'day_5', 24.01, 29.89, 86, 22.69, 12.92, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.01,\"temp_max\":29.89,\"humidity\":86,\"rainfall_mm\":22.69,\"wind_speed_kmh\":12.92,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:20'),
(2269, 22, '2026-06-10', 'current', 25.86, 26.39, 82, 0.21, 13.61, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.86,\"temp_max\":26.39,\"humidity\":82,\"rainfall_mm\":0.21,\"wind_speed_kmh\":13.61,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:21'),
(2270, 22, '2026-06-10', 'today', 26.39, 26.39, 82, 0.21, 13.61, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.39,\"temp_max\":26.39,\"humidity\":82,\"rainfall_mm\":0.21,\"wind_speed_kmh\":13.61,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:21'),
(2271, 22, '2026-06-11', 'tomorrow', 25.77, 34.06, 75, 6.82, 26.71, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.77,\"temp_max\":34.06,\"humidity\":75,\"rainfall_mm\":6.82,\"wind_speed_kmh\":26.71,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-10 18:00:21'),
(2272, 22, '2026-06-12', 'day_3', 26.24, 33.03, 76, 8.78, 21.71, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.24,\"temp_max\":33.03,\"humidity\":76,\"rainfall_mm\":8.78,\"wind_speed_kmh\":21.71,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:21'),
(2273, 22, '2026-06-13', 'day_4', 26.20, 33.27, 78, 15.15, 21.42, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.2,\"temp_max\":33.27,\"humidity\":78,\"rainfall_mm\":15.15,\"wind_speed_kmh\":21.42,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:21'),
(2274, 22, '2026-06-14', 'day_5', 25.53, 31.38, 86, 22.25, 19.69, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":25.53,\"temp_max\":31.38,\"humidity\":86,\"rainfall_mm\":22.25,\"wind_speed_kmh\":19.69,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:21'),
(2275, 24, '2026-06-10', 'current', 28.52, 28.94, 84, 0.00, 10.51, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":28.52,\"temp_max\":28.94,\"humidity\":84,\"rainfall_mm\":0,\"wind_speed_kmh\":10.51,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:22'),
(2276, 24, '2026-06-10', 'today', 28.94, 28.94, 84, 0.00, 10.51, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":28.94,\"temp_max\":28.94,\"humidity\":84,\"rainfall_mm\":0,\"wind_speed_kmh\":10.51,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:22'),
(2277, 24, '2026-06-11', 'tomorrow', 28.59, 34.71, 71, 7.12, 21.49, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.59,\"temp_max\":34.71,\"humidity\":71,\"rainfall_mm\":7.12,\"wind_speed_kmh\":21.49,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:22'),
(2278, 24, '2026-06-12', 'day_3', 27.69, 33.68, 73, 13.98, 21.92, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.69,\"temp_max\":33.68,\"humidity\":73,\"rainfall_mm\":13.98,\"wind_speed_kmh\":21.92,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:22'),
(2279, 24, '2026-06-13', 'day_4', 26.99, 29.93, 83, 25.22, 18.79, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.99,\"temp_max\":29.93,\"humidity\":83,\"rainfall_mm\":25.22,\"wind_speed_kmh\":18.79,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:22'),
(2280, 24, '2026-06-14', 'day_5', 27.56, 32.11, 79, 16.40, 20.95, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.56,\"temp_max\":32.11,\"humidity\":79,\"rainfall_mm\":16.4,\"wind_speed_kmh\":20.95,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:22'),
(2281, 25, '2026-06-10', 'current', 27.01, 27.32, 84, 0.00, 10.40, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":27.01,\"temp_max\":27.32,\"humidity\":84,\"rainfall_mm\":0,\"wind_speed_kmh\":10.4,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:23'),
(2282, 25, '2026-06-10', 'today', 27.32, 27.32, 84, 0.00, 10.40, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":27.32,\"temp_max\":27.32,\"humidity\":84,\"rainfall_mm\":0,\"wind_speed_kmh\":10.4,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:23'),
(2283, 25, '2026-06-11', 'tomorrow', 26.44, 38.88, 68, 7.57, 21.13, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.44,\"temp_max\":38.88,\"humidity\":68,\"rainfall_mm\":7.57,\"wind_speed_kmh\":21.13,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:23'),
(2284, 25, '2026-06-12', 'day_3', 26.36, 36.79, 73, 4.99, 35.86, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.36,\"temp_max\":36.79,\"humidity\":73,\"rainfall_mm\":4.99,\"wind_speed_kmh\":35.86,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:23'),
(2285, 25, '2026-06-13', 'day_4', 26.95, 35.80, 78, 45.72, 22.21, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.95,\"temp_max\":35.8,\"humidity\":78,\"rainfall_mm\":45.72,\"wind_speed_kmh\":22.21,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:23'),
(2286, 25, '2026-06-14', 'day_5', 28.05, 37.53, 74, 0.00, 23.36, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":28.05,\"temp_max\":37.53,\"humidity\":74,\"rainfall_mm\":0,\"wind_speed_kmh\":23.36,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:23'),
(2287, 26, '2026-06-10', 'current', 26.25, 26.55, 77, 0.50, 10.94, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.25,\"temp_max\":26.55,\"humidity\":77,\"rainfall_mm\":0.5,\"wind_speed_kmh\":10.94,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:23'),
(2288, 26, '2026-06-10', 'today', 26.55, 26.55, 77, 0.50, 10.94, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.55,\"temp_max\":26.55,\"humidity\":77,\"rainfall_mm\":0.5,\"wind_speed_kmh\":10.94,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:23'),
(2289, 26, '2026-06-11', 'tomorrow', 26.20, 37.48, 64, 1.90, 27.14, 'Rain', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.2,\"temp_max\":37.48,\"humidity\":64,\"rainfall_mm\":1.9,\"wind_speed_kmh\":27.14,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-10 18:00:23'),
(2290, 26, '2026-06-12', 'day_3', 26.96, 35.64, 66, 2.63, 19.94, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.96,\"temp_max\":35.64,\"humidity\":66,\"rainfall_mm\":2.63,\"wind_speed_kmh\":19.94,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:23'),
(2291, 26, '2026-06-13', 'day_4', 25.76, 35.47, 74, 10.59, 21.20, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.76,\"temp_max\":35.47,\"humidity\":74,\"rainfall_mm\":10.59,\"wind_speed_kmh\":21.2,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:23'),
(2292, 26, '2026-06-14', 'day_5', 25.27, 33.38, 80, 14.13, 21.20, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":25.27,\"temp_max\":33.38,\"humidity\":80,\"rainfall_mm\":14.13,\"wind_speed_kmh\":21.2,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:23'),
(2293, 27, '2026-06-10', 'current', 23.24, 23.52, 98, 0.13, 4.32, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":23.24,\"temp_max\":23.52,\"humidity\":98,\"rainfall_mm\":0.13,\"wind_speed_kmh\":4.32,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:24'),
(2294, 27, '2026-06-10', 'today', 23.52, 23.52, 98, 0.13, 4.32, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":23.52,\"temp_max\":23.52,\"humidity\":98,\"rainfall_mm\":0.13,\"wind_speed_kmh\":4.32,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:24'),
(2295, 27, '2026-06-11', 'tomorrow', 23.36, 35.26, 81, 8.03, 7.78, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":23.36,\"temp_max\":35.26,\"humidity\":81,\"rainfall_mm\":8.03,\"wind_speed_kmh\":7.78,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:24'),
(2296, 27, '2026-06-12', 'day_3', 23.58, 29.82, 88, 3.67, 7.34, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":23.58,\"temp_max\":29.82,\"humidity\":88,\"rainfall_mm\":3.67,\"wind_speed_kmh\":7.34,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-10 18:00:24'),
(2297, 27, '2026-06-13', 'day_4', 23.10, 29.35, 85, 2.05, 10.04, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":23.1,\"temp_max\":29.35,\"humidity\":85,\"rainfall_mm\":2.05,\"wind_speed_kmh\":10.04,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:24'),
(2298, 27, '2026-06-14', 'day_5', 22.95, 28.93, 93, 15.46, 7.99, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":22.95,\"temp_max\":28.93,\"humidity\":93,\"rainfall_mm\":15.46,\"wind_speed_kmh\":7.99,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:24'),
(2299, 28, '2026-06-10', 'current', 27.23, 27.62, 82, 0.00, 8.75, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":27.23,\"temp_max\":27.62,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":8.75,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:25'),
(2300, 28, '2026-06-10', 'today', 27.62, 27.62, 82, 0.00, 8.75, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":27.62,\"temp_max\":27.62,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":8.75,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:25'),
(2301, 28, '2026-06-11', 'tomorrow', 25.74, 36.95, 69, 10.17, 23.44, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.74,\"temp_max\":36.95,\"humidity\":69,\"rainfall_mm\":10.17,\"wind_speed_kmh\":23.44,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:25'),
(2302, 28, '2026-06-12', 'day_3', 27.26, 35.51, 77, 6.41, 28.40, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.26,\"temp_max\":35.51,\"humidity\":77,\"rainfall_mm\":6.41,\"wind_speed_kmh\":28.4,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:25'),
(2303, 28, '2026-06-13', 'day_4', 26.33, 35.62, 80, 32.54, 23.11, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.33,\"temp_max\":35.62,\"humidity\":80,\"rainfall_mm\":32.54,\"wind_speed_kmh\":23.11,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:25'),
(2304, 28, '2026-06-14', 'day_5', 27.90, 35.30, 78, 2.22, 20.59, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.9,\"temp_max\":35.3,\"humidity\":78,\"rainfall_mm\":2.22,\"wind_speed_kmh\":20.59,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-10 18:00:25'),
(2305, 29, '2026-06-10', 'current', 24.76, 25.22, 87, 0.00, 10.66, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":24.76,\"temp_max\":25.22,\"humidity\":87,\"rainfall_mm\":0,\"wind_speed_kmh\":10.66,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:26'),
(2306, 29, '2026-06-10', 'today', 25.22, 25.22, 87, 0.00, 10.66, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.22,\"temp_max\":25.22,\"humidity\":87,\"rainfall_mm\":0,\"wind_speed_kmh\":10.66,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:26'),
(2307, 29, '2026-06-11', 'tomorrow', 24.99, 33.91, 76, 15.62, 15.98, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.99,\"temp_max\":33.91,\"humidity\":76,\"rainfall_mm\":15.62,\"wind_speed_kmh\":15.98,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:26'),
(2308, 29, '2026-06-12', 'day_3', 25.52, 32.66, 81, 13.57, 16.09, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":25.52,\"temp_max\":32.66,\"humidity\":81,\"rainfall_mm\":13.57,\"wind_speed_kmh\":16.09,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:26'),
(2309, 29, '2026-06-13', 'day_4', 25.53, 31.68, 84, 19.46, 19.04, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.53,\"temp_max\":31.68,\"humidity\":84,\"rainfall_mm\":19.46,\"wind_speed_kmh\":19.04,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:26'),
(2310, 29, '2026-06-14', 'day_5', 25.04, 30.60, 88, 22.78, 19.19, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":25.04,\"temp_max\":30.6,\"humidity\":88,\"rainfall_mm\":22.78,\"wind_speed_kmh\":19.19,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:26'),
(2311, 30, '2026-06-10', 'current', 26.45, 26.50, 88, 0.00, 4.75, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.45,\"temp_max\":26.5,\"humidity\":88,\"rainfall_mm\":0,\"wind_speed_kmh\":4.75,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:27'),
(2312, 30, '2026-06-10', 'today', 26.45, 26.45, 88, 0.00, 4.75, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.45,\"temp_max\":26.45,\"humidity\":88,\"rainfall_mm\":0,\"wind_speed_kmh\":4.75,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:27'),
(2313, 30, '2026-06-11', 'tomorrow', 26.12, 33.92, 75, 10.14, 16.09, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.12,\"temp_max\":33.92,\"humidity\":75,\"rainfall_mm\":10.14,\"wind_speed_kmh\":16.09,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:27'),
(2314, 30, '2026-06-12', 'day_3', 25.89, 32.41, 76, 12.78, 18.14, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":25.89,\"temp_max\":32.41,\"humidity\":76,\"rainfall_mm\":12.78,\"wind_speed_kmh\":18.14,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:27'),
(2315, 30, '2026-06-13', 'day_4', 25.59, 32.29, 80, 20.94, 22.46, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.59,\"temp_max\":32.29,\"humidity\":80,\"rainfall_mm\":20.94,\"wind_speed_kmh\":22.46,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:27'),
(2316, 30, '2026-06-14', 'day_5', 25.01, 30.29, 85, 16.12, 19.01, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":25.01,\"temp_max\":30.29,\"humidity\":85,\"rainfall_mm\":16.12,\"wind_speed_kmh\":19.01,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:27'),
(2317, 31, '2026-06-10', 'current', 27.75, 27.78, 71, 0.00, 13.36, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":27.75,\"temp_max\":27.78,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":13.36,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:28'),
(2318, 31, '2026-06-10', 'today', 27.78, 27.78, 71, 0.00, 13.36, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":27.78,\"temp_max\":27.78,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":13.36,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:28'),
(2319, 31, '2026-06-11', 'tomorrow', 26.69, 37.06, 68, 10.98, 35.24, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.69,\"temp_max\":37.06,\"humidity\":68,\"rainfall_mm\":10.98,\"wind_speed_kmh\":35.24,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-10 18:00:28'),
(2320, 31, '2026-06-12', 'day_3', 27.23, 37.94, 64, 2.73, 23.29, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.23,\"temp_max\":37.94,\"humidity\":64,\"rainfall_mm\":2.73,\"wind_speed_kmh\":23.29,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:28'),
(2321, 31, '2026-06-13', 'day_4', 27.28, 36.35, 74, 14.20, 29.48, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":27.28,\"temp_max\":36.35,\"humidity\":74,\"rainfall_mm\":14.2,\"wind_speed_kmh\":29.48,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:28'),
(2322, 31, '2026-06-14', 'day_5', 28.15, 38.27, 66, 0.00, 25.78, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":28.15,\"temp_max\":38.27,\"humidity\":66,\"rainfall_mm\":0,\"wind_speed_kmh\":25.78,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:28'),
(2323, 32, '2026-06-10', 'current', 28.88, 29.21, 85, 0.00, 14.29, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":28.88,\"temp_max\":29.21,\"humidity\":85,\"rainfall_mm\":0,\"wind_speed_kmh\":14.29,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:29'),
(2324, 32, '2026-06-10', 'today', 29.21, 29.21, 85, 0.00, 14.29, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":29.21,\"temp_max\":29.21,\"humidity\":85,\"rainfall_mm\":0,\"wind_speed_kmh\":14.29,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:29'),
(2325, 32, '2026-06-11', 'tomorrow', 28.80, 32.70, 75, 6.82, 21.92, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.8,\"temp_max\":32.7,\"humidity\":75,\"rainfall_mm\":6.82,\"wind_speed_kmh\":21.92,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:29'),
(2326, 32, '2026-06-12', 'day_3', 28.00, 31.67, 78, 16.58, 22.86, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":28,\"temp_max\":31.67,\"humidity\":78,\"rainfall_mm\":16.58,\"wind_speed_kmh\":22.86,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:29'),
(2327, 32, '2026-06-13', 'day_4', 27.83, 29.05, 82, 19.61, 24.26, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":27.83,\"temp_max\":29.05,\"humidity\":82,\"rainfall_mm\":19.61,\"wind_speed_kmh\":24.26,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:29'),
(2328, 32, '2026-06-14', 'day_5', 28.19, 30.66, 80, 7.03, 23.87, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":28.19,\"temp_max\":30.66,\"humidity\":80,\"rainfall_mm\":7.03,\"wind_speed_kmh\":23.87,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:29'),
(2329, 33, '2026-06-10', 'current', 26.08, 26.41, 88, 0.10, 3.31, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.08,\"temp_max\":26.41,\"humidity\":88,\"rainfall_mm\":0.1,\"wind_speed_kmh\":3.31,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:30'),
(2330, 33, '2026-06-10', 'today', 26.41, 26.41, 88, 0.10, 3.31, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.41,\"temp_max\":26.41,\"humidity\":88,\"rainfall_mm\":0.1,\"wind_speed_kmh\":3.31,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:30'),
(2331, 33, '2026-06-11', 'tomorrow', 25.78, 34.04, 73, 7.28, 14.51, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.78,\"temp_max\":34.04,\"humidity\":73,\"rainfall_mm\":7.28,\"wind_speed_kmh\":14.51,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:30'),
(2332, 33, '2026-06-12', 'day_3', 25.68, 33.29, 76, 10.90, 14.36, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":25.68,\"temp_max\":33.29,\"humidity\":76,\"rainfall_mm\":10.9,\"wind_speed_kmh\":14.36,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:30'),
(2333, 33, '2026-06-13', 'day_4', 24.80, 31.85, 82, 28.91, 19.80, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.8,\"temp_max\":31.85,\"humidity\":82,\"rainfall_mm\":28.91,\"wind_speed_kmh\":19.8,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:30'),
(2334, 33, '2026-06-14', 'day_5', 24.18, 30.07, 87, 23.71, 17.14, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.18,\"temp_max\":30.07,\"humidity\":87,\"rainfall_mm\":23.71,\"wind_speed_kmh\":17.14,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:30'),
(2335, 34, '2026-06-10', 'current', 26.10, 26.81, 82, 0.00, 8.82, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.1,\"temp_max\":26.81,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":8.82,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:31'),
(2336, 34, '2026-06-10', 'today', 26.10, 26.10, 82, 0.00, 8.82, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.1,\"temp_max\":26.1,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":8.82,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:31'),
(2337, 34, '2026-06-11', 'tomorrow', 25.97, 35.47, 72, 14.82, 23.98, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.97,\"temp_max\":35.47,\"humidity\":72,\"rainfall_mm\":14.82,\"wind_speed_kmh\":23.98,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:31'),
(2338, 34, '2026-06-12', 'day_3', 26.43, 33.79, 77, 12.18, 19.08, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.43,\"temp_max\":33.79,\"humidity\":77,\"rainfall_mm\":12.18,\"wind_speed_kmh\":19.08,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:31'),
(2339, 34, '2026-06-13', 'day_4', 26.29, 31.61, 83, 16.14, 26.57, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.29,\"temp_max\":31.61,\"humidity\":83,\"rainfall_mm\":16.14,\"wind_speed_kmh\":26.57,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:31'),
(2340, 34, '2026-06-14', 'day_5', 26.60, 32.64, 84, 14.44, 22.07, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":26.6,\"temp_max\":32.64,\"humidity\":84,\"rainfall_mm\":14.44,\"wind_speed_kmh\":22.07,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:31'),
(2341, 35, '2026-06-10', 'current', 26.95, 27.08, 79, 0.00, 11.59, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.95,\"temp_max\":27.08,\"humidity\":79,\"rainfall_mm\":0,\"wind_speed_kmh\":11.59,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:31'),
(2342, 35, '2026-06-10', 'today', 27.08, 27.08, 79, 0.00, 11.59, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":27.08,\"temp_max\":27.08,\"humidity\":79,\"rainfall_mm\":0,\"wind_speed_kmh\":11.59,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:31'),
(2343, 35, '2026-06-11', 'tomorrow', 26.97, 38.82, 68, 10.13, 14.00, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.97,\"temp_max\":38.82,\"humidity\":68,\"rainfall_mm\":10.13,\"wind_speed_kmh\":14,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:31'),
(2344, 35, '2026-06-12', 'day_3', 26.36, 35.91, 73, 8.07, 37.12, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.36,\"temp_max\":35.91,\"humidity\":73,\"rainfall_mm\":8.07,\"wind_speed_kmh\":37.12,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:31'),
(2345, 35, '2026-06-13', 'day_4', 26.32, 35.15, 80, 44.46, 20.09, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.32,\"temp_max\":35.15,\"humidity\":80,\"rainfall_mm\":44.46,\"wind_speed_kmh\":20.09,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:31'),
(2346, 35, '2026-06-14', 'day_5', 27.87, 37.08, 75, 0.24, 21.35, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.87,\"temp_max\":37.08,\"humidity\":75,\"rainfall_mm\":0.24,\"wind_speed_kmh\":21.35,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:31'),
(2347, 36, '2026-06-10', 'current', 26.00, 26.47, 78, 1.04, 10.37, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26,\"temp_max\":26.47,\"humidity\":78,\"rainfall_mm\":1.04,\"wind_speed_kmh\":10.37,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:32'),
(2348, 36, '2026-06-10', 'today', 26.47, 26.47, 78, 1.04, 10.37, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.47,\"temp_max\":26.47,\"humidity\":78,\"rainfall_mm\":1.04,\"wind_speed_kmh\":10.37,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:32'),
(2349, 36, '2026-06-11', 'tomorrow', 25.96, 36.21, 71, 8.56, 21.89, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.96,\"temp_max\":36.21,\"humidity\":71,\"rainfall_mm\":8.56,\"wind_speed_kmh\":21.89,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:32'),
(2350, 36, '2026-06-12', 'day_3', 26.71, 34.04, 74, 6.45, 23.76, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.71,\"temp_max\":34.04,\"humidity\":74,\"rainfall_mm\":6.45,\"wind_speed_kmh\":23.76,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:32'),
(2351, 36, '2026-06-13', 'day_4', 25.97, 32.81, 79, 13.57, 26.46, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.97,\"temp_max\":32.81,\"humidity\":79,\"rainfall_mm\":13.57,\"wind_speed_kmh\":26.46,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:32'),
(2352, 36, '2026-06-14', 'day_5', 26.40, 32.89, 82, 19.32, 21.96, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":26.4,\"temp_max\":32.89,\"humidity\":82,\"rainfall_mm\":19.32,\"wind_speed_kmh\":21.96,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:32'),
(2353, 37, '2026-06-10', 'current', 27.22, 27.23, 70, 0.00, 12.49, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":27.22,\"temp_max\":27.23,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":12.49,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:33'),
(2354, 37, '2026-06-10', 'today', 27.22, 27.22, 70, 0.00, 12.49, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":27.22,\"temp_max\":27.22,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":12.49,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:33'),
(2355, 37, '2026-06-11', 'tomorrow', 26.69, 37.32, 69, 15.44, 31.57, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.69,\"temp_max\":37.32,\"humidity\":69,\"rainfall_mm\":15.44,\"wind_speed_kmh\":31.57,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-10 18:00:33'),
(2356, 37, '2026-06-12', 'day_3', 26.71, 36.76, 67, 7.08, 21.74, 'Rain', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.71,\"temp_max\":36.76,\"humidity\":67,\"rainfall_mm\":7.08,\"wind_speed_kmh\":21.74,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:33'),
(2357, 37, '2026-06-13', 'day_4', 26.89, 35.88, 75, 17.59, 28.76, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.89,\"temp_max\":35.88,\"humidity\":75,\"rainfall_mm\":17.59,\"wind_speed_kmh\":28.76,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:33'),
(2358, 37, '2026-06-14', 'day_5', 27.96, 37.13, 71, 0.86, 25.38, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.96,\"temp_max\":37.13,\"humidity\":71,\"rainfall_mm\":0.86,\"wind_speed_kmh\":25.38,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:33'),
(2359, 38, '2026-06-10', 'current', 25.49, 25.68, 95, 0.00, 8.17, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.49,\"temp_max\":25.68,\"humidity\":95,\"rainfall_mm\":0,\"wind_speed_kmh\":8.17,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:34'),
(2360, 38, '2026-06-10', 'today', 25.68, 25.68, 95, 0.00, 8.17, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.68,\"temp_max\":25.68,\"humidity\":95,\"rainfall_mm\":0,\"wind_speed_kmh\":8.17,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:34');
INSERT INTO `weather_forecasts` (`forecast_id`, `district_id`, `forecast_date`, `forecast_for`, `temp_min`, `temp_max`, `humidity`, `rainfall_mm`, `wind_speed_kmh`, `conditions`, `icon`, `raw_payload`, `fetched_at`) VALUES
(2361, 38, '2026-06-11', 'tomorrow', 25.29, 33.89, 75, 3.26, 12.31, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.29,\"temp_max\":33.89,\"humidity\":75,\"rainfall_mm\":3.26,\"wind_speed_kmh\":12.31,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:34'),
(2362, 38, '2026-06-12', 'day_3', 25.03, 28.69, 89, 13.91, 10.33, 'Rain', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":25.03,\"temp_max\":28.69,\"humidity\":89,\"rainfall_mm\":13.91,\"wind_speed_kmh\":10.33,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:34'),
(2363, 38, '2026-06-13', 'day_4', 24.46, 31.15, 87, 19.15, 11.77, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.46,\"temp_max\":31.15,\"humidity\":87,\"rainfall_mm\":19.15,\"wind_speed_kmh\":11.77,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:34'),
(2364, 38, '2026-06-14', 'day_5', 24.01, 29.89, 86, 22.69, 12.92, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.01,\"temp_max\":29.89,\"humidity\":86,\"rainfall_mm\":22.69,\"wind_speed_kmh\":12.92,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:34'),
(2365, 39, '2026-06-10', 'current', 27.01, 27.90, 78, 0.00, 8.89, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":27.01,\"temp_max\":27.9,\"humidity\":78,\"rainfall_mm\":0,\"wind_speed_kmh\":8.89,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:35'),
(2366, 39, '2026-06-10', 'today', 27.01, 27.01, 78, 0.00, 8.89, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":27.01,\"temp_max\":27.01,\"humidity\":78,\"rainfall_mm\":0,\"wind_speed_kmh\":8.89,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:35'),
(2367, 39, '2026-06-11', 'tomorrow', 26.38, 35.84, 69, 6.42, 20.16, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.38,\"temp_max\":35.84,\"humidity\":69,\"rainfall_mm\":6.42,\"wind_speed_kmh\":20.16,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:35'),
(2368, 39, '2026-06-12', 'day_3', 27.17, 33.91, 75, 17.01, 19.69, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.17,\"temp_max\":33.91,\"humidity\":75,\"rainfall_mm\":17.01,\"wind_speed_kmh\":19.69,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:35'),
(2369, 39, '2026-06-13', 'day_4', 27.15, 32.78, 78, 8.20, 24.19, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":27.15,\"temp_max\":32.78,\"humidity\":78,\"rainfall_mm\":8.2,\"wind_speed_kmh\":24.19,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:35'),
(2370, 39, '2026-06-14', 'day_5', 27.05, 32.32, 80, 15.44, 23.47, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.05,\"temp_max\":32.32,\"humidity\":80,\"rainfall_mm\":15.44,\"wind_speed_kmh\":23.47,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:35'),
(2371, 40, '2026-06-10', 'current', 24.96, 25.23, 90, 0.00, 10.51, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":24.96,\"temp_max\":25.23,\"humidity\":90,\"rainfall_mm\":0,\"wind_speed_kmh\":10.51,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:36'),
(2372, 40, '2026-06-10', 'today', 25.23, 25.23, 90, 0.00, 10.51, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.23,\"temp_max\":25.23,\"humidity\":90,\"rainfall_mm\":0,\"wind_speed_kmh\":10.51,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:36'),
(2373, 40, '2026-06-11', 'tomorrow', 25.34, 33.79, 77, 6.98, 16.20, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.34,\"temp_max\":33.79,\"humidity\":77,\"rainfall_mm\":6.98,\"wind_speed_kmh\":16.2,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-10 18:00:36'),
(2374, 40, '2026-06-12', 'day_3', 25.22, 32.62, 80, 11.44, 16.92, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":25.22,\"temp_max\":32.62,\"humidity\":80,\"rainfall_mm\":11.44,\"wind_speed_kmh\":16.92,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:36'),
(2375, 40, '2026-06-13', 'day_4', 24.79, 31.89, 84, 23.54, 16.99, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.79,\"temp_max\":31.89,\"humidity\":84,\"rainfall_mm\":23.54,\"wind_speed_kmh\":16.99,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:36'),
(2376, 40, '2026-06-14', 'day_5', 24.90, 29.13, 91, 26.95, 20.74, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.9,\"temp_max\":29.13,\"humidity\":91,\"rainfall_mm\":26.95,\"wind_speed_kmh\":20.74,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:36'),
(2377, 41, '2026-06-10', 'current', 25.42, 26.58, 73, 2.44, 10.30, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.42,\"temp_max\":26.58,\"humidity\":73,\"rainfall_mm\":2.44,\"wind_speed_kmh\":10.3,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:37'),
(2378, 41, '2026-06-10', 'today', 26.58, 26.58, 73, 2.44, 10.30, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.58,\"temp_max\":26.58,\"humidity\":73,\"rainfall_mm\":2.44,\"wind_speed_kmh\":10.3,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:37'),
(2379, 41, '2026-06-11', 'tomorrow', 25.65, 37.13, 66, 14.82, 31.72, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.65,\"temp_max\":37.13,\"humidity\":66,\"rainfall_mm\":14.82,\"wind_speed_kmh\":31.72,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:37'),
(2380, 41, '2026-06-12', 'day_3', 26.77, 37.47, 64, 2.90, 22.61, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.77,\"temp_max\":37.47,\"humidity\":64,\"rainfall_mm\":2.9,\"wind_speed_kmh\":22.61,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:37'),
(2381, 41, '2026-06-13', 'day_4', 26.88, 37.01, 66, 6.80, 24.01, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.88,\"temp_max\":37.01,\"humidity\":66,\"rainfall_mm\":6.8,\"wind_speed_kmh\":24.01,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:37'),
(2382, 41, '2026-06-14', 'day_5', 26.71, 35.85, 69, 4.58, 19.55, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":26.71,\"temp_max\":35.85,\"humidity\":69,\"rainfall_mm\":4.58,\"wind_speed_kmh\":19.55,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:37'),
(2383, 42, '2026-06-10', 'current', 26.13, 26.27, 79, 0.00, 12.67, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.13,\"temp_max\":26.27,\"humidity\":79,\"rainfall_mm\":0,\"wind_speed_kmh\":12.67,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:38'),
(2384, 42, '2026-06-10', 'today', 26.13, 26.13, 79, 0.00, 12.67, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.13,\"temp_max\":26.13,\"humidity\":79,\"rainfall_mm\":0,\"wind_speed_kmh\":12.67,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:38'),
(2385, 42, '2026-06-11', 'tomorrow', 26.14, 36.70, 70, 16.62, 13.57, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.14,\"temp_max\":36.7,\"humidity\":70,\"rainfall_mm\":16.62,\"wind_speed_kmh\":13.57,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:38'),
(2386, 42, '2026-06-12', 'day_3', 26.42, 34.92, 74, 7.79, 20.30, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.42,\"temp_max\":34.92,\"humidity\":74,\"rainfall_mm\":7.79,\"wind_speed_kmh\":20.3,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:38'),
(2387, 42, '2026-06-13', 'day_4', 25.96, 32.89, 83, 21.59, 38.52, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.96,\"temp_max\":32.89,\"humidity\":83,\"rainfall_mm\":21.59,\"wind_speed_kmh\":38.52,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:38'),
(2388, 42, '2026-06-14', 'day_5', 26.74, 34.16, 81, 11.50, 19.76, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":26.74,\"temp_max\":34.16,\"humidity\":81,\"rainfall_mm\":11.5,\"wind_speed_kmh\":19.76,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:38'),
(2389, 43, '2026-06-10', 'current', 27.11, 27.92, 78, 0.00, 8.75, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":27.11,\"temp_max\":27.92,\"humidity\":78,\"rainfall_mm\":0,\"wind_speed_kmh\":8.75,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:38'),
(2390, 43, '2026-06-10', 'today', 27.11, 27.11, 78, 0.00, 8.75, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":27.11,\"temp_max\":27.11,\"humidity\":78,\"rainfall_mm\":0,\"wind_speed_kmh\":8.75,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:38'),
(2391, 43, '2026-06-11', 'tomorrow', 26.30, 36.03, 68, 5.88, 19.51, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.3,\"temp_max\":36.03,\"humidity\":68,\"rainfall_mm\":5.88,\"wind_speed_kmh\":19.51,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:38'),
(2392, 43, '2026-06-12', 'day_3', 27.06, 34.01, 74, 17.95, 19.33, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.06,\"temp_max\":34.01,\"humidity\":74,\"rainfall_mm\":17.95,\"wind_speed_kmh\":19.33,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:38'),
(2393, 43, '2026-06-13', 'day_4', 27.21, 32.97, 77, 8.77, 23.98, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":27.21,\"temp_max\":32.97,\"humidity\":77,\"rainfall_mm\":8.77,\"wind_speed_kmh\":23.98,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:38'),
(2394, 43, '2026-06-14', 'day_5', 27.01, 31.91, 80, 15.65, 22.50, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.01,\"temp_max\":31.91,\"humidity\":80,\"rainfall_mm\":15.65,\"wind_speed_kmh\":22.5,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:38'),
(2395, 44, '2026-06-10', 'current', 26.56, 26.56, 73, 0.00, 12.64, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.56,\"temp_max\":26.56,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":12.64,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:39'),
(2396, 44, '2026-06-10', 'today', 26.56, 27.01, 76, 0.00, 12.64, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.56,\"temp_max\":27.01,\"humidity\":76,\"rainfall_mm\":0,\"wind_speed_kmh\":12.64,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:39'),
(2397, 44, '2026-06-11', 'tomorrow', 26.38, 35.84, 69, 6.42, 20.16, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.38,\"temp_max\":35.84,\"humidity\":69,\"rainfall_mm\":6.42,\"wind_speed_kmh\":20.16,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:39'),
(2398, 44, '2026-06-12', 'day_3', 27.17, 33.91, 75, 17.01, 19.69, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.17,\"temp_max\":33.91,\"humidity\":75,\"rainfall_mm\":17.01,\"wind_speed_kmh\":19.69,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:39'),
(2399, 44, '2026-06-13', 'day_4', 27.15, 32.78, 78, 8.20, 24.19, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":27.15,\"temp_max\":32.78,\"humidity\":78,\"rainfall_mm\":8.2,\"wind_speed_kmh\":24.19,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:39'),
(2400, 44, '2026-06-14', 'day_5', 27.05, 32.32, 80, 15.44, 23.47, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.05,\"temp_max\":32.32,\"humidity\":80,\"rainfall_mm\":15.44,\"wind_speed_kmh\":23.47,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:39'),
(2401, 45, '2026-06-10', 'current', 25.12, 26.48, 70, 1.94, 12.20, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.12,\"temp_max\":26.48,\"humidity\":70,\"rainfall_mm\":1.94,\"wind_speed_kmh\":12.2,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:40'),
(2402, 45, '2026-06-10', 'today', 26.48, 26.48, 70, 1.94, 12.20, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.48,\"temp_max\":26.48,\"humidity\":70,\"rainfall_mm\":1.94,\"wind_speed_kmh\":12.2,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:40'),
(2403, 45, '2026-06-11', 'tomorrow', 26.30, 39.33, 62, 5.83, 24.41, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.3,\"temp_max\":39.33,\"humidity\":62,\"rainfall_mm\":5.83,\"wind_speed_kmh\":24.41,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:40'),
(2404, 45, '2026-06-12', 'day_3', 26.92, 37.72, 60, 1.18, 21.06, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.92,\"temp_max\":37.72,\"humidity\":60,\"rainfall_mm\":1.18,\"wind_speed_kmh\":21.06,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:40'),
(2405, 45, '2026-06-13', 'day_4', 26.97, 37.53, 64, 6.73, 25.74, 'Rain', '04d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.97,\"temp_max\":37.53,\"humidity\":64,\"rainfall_mm\":6.73,\"wind_speed_kmh\":25.74,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:40'),
(2406, 45, '2026-06-14', 'day_5', 27.26, 36.29, 67, 7.84, 25.42, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.26,\"temp_max\":36.29,\"humidity\":67,\"rainfall_mm\":7.84,\"wind_speed_kmh\":25.42,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:40'),
(2407, 46, '2026-06-10', 'current', 25.73, 25.97, 91, 0.00, 10.80, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.73,\"temp_max\":25.97,\"humidity\":91,\"rainfall_mm\":0,\"wind_speed_kmh\":10.8,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:41'),
(2408, 46, '2026-06-10', 'today', 25.73, 25.73, 91, 0.00, 10.80, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.73,\"temp_max\":25.73,\"humidity\":91,\"rainfall_mm\":0,\"wind_speed_kmh\":10.8,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:41'),
(2409, 46, '2026-06-11', 'tomorrow', 25.03, 33.22, 76, 11.68, 15.37, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.03,\"temp_max\":33.22,\"humidity\":76,\"rainfall_mm\":11.68,\"wind_speed_kmh\":15.37,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:41'),
(2410, 46, '2026-06-12', 'day_3', 24.99, 30.08, 83, 11.27, 17.60, 'Rain', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":24.99,\"temp_max\":30.08,\"humidity\":83,\"rainfall_mm\":11.27,\"wind_speed_kmh\":17.6,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:41'),
(2411, 46, '2026-06-13', 'day_4', 24.98, 32.12, 81, 26.27, 17.89, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.98,\"temp_max\":32.12,\"humidity\":81,\"rainfall_mm\":26.27,\"wind_speed_kmh\":17.89,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:41'),
(2412, 46, '2026-06-14', 'day_5', 24.67, 29.14, 89, 16.09, 20.41, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.67,\"temp_max\":29.14,\"humidity\":89,\"rainfall_mm\":16.09,\"wind_speed_kmh\":20.41,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:41'),
(2413, 47, '2026-06-10', 'current', 25.39, 25.69, 86, 1.64, 11.52, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.39,\"temp_max\":25.69,\"humidity\":86,\"rainfall_mm\":1.64,\"wind_speed_kmh\":11.52,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:42'),
(2414, 47, '2026-06-10', 'today', 25.69, 25.69, 86, 1.64, 11.52, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.69,\"temp_max\":25.69,\"humidity\":86,\"rainfall_mm\":1.64,\"wind_speed_kmh\":11.52,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:42'),
(2415, 47, '2026-06-11', 'tomorrow', 25.53, 35.58, 70, 2.70, 17.68, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.53,\"temp_max\":35.58,\"humidity\":70,\"rainfall_mm\":2.7,\"wind_speed_kmh\":17.68,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-10 18:00:42'),
(2416, 47, '2026-06-12', 'day_3', 26.06, 35.29, 72, 8.56, 19.44, 'Rain', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.06,\"temp_max\":35.29,\"humidity\":72,\"rainfall_mm\":8.56,\"wind_speed_kmh\":19.44,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:42'),
(2417, 47, '2026-06-13', 'day_4', 24.87, 32.89, 78, 16.15, 18.72, 'Rain', '03d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.87,\"temp_max\":32.89,\"humidity\":78,\"rainfall_mm\":16.15,\"wind_speed_kmh\":18.72,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-10 18:00:42'),
(2418, 47, '2026-06-14', 'day_5', 24.88, 31.44, 84, 19.32, 19.80, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.88,\"temp_max\":31.44,\"humidity\":84,\"rainfall_mm\":19.32,\"wind_speed_kmh\":19.8,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:42'),
(2419, 48, '2026-06-10', 'current', 28.04, 28.41, 88, 0.00, 20.84, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":28.04,\"temp_max\":28.41,\"humidity\":88,\"rainfall_mm\":0,\"wind_speed_kmh\":20.84,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:43'),
(2420, 48, '2026-06-10', 'today', 28.41, 28.41, 88, 0.00, 20.84, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":28.41,\"temp_max\":28.41,\"humidity\":88,\"rainfall_mm\":0,\"wind_speed_kmh\":20.84,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:43'),
(2421, 48, '2026-06-11', 'tomorrow', 27.98, 31.32, 79, 4.73, 24.41, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.98,\"temp_max\":31.32,\"humidity\":79,\"rainfall_mm\":4.73,\"wind_speed_kmh\":24.41,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:43'),
(2422, 48, '2026-06-12', 'day_3', 27.58, 30.00, 83, 11.12, 24.95, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.58,\"temp_max\":30,\"humidity\":83,\"rainfall_mm\":11.12,\"wind_speed_kmh\":24.95,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:43'),
(2423, 48, '2026-06-13', 'day_4', 26.92, 29.35, 82, 23.98, 27.40, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.92,\"temp_max\":29.35,\"humidity\":82,\"rainfall_mm\":23.98,\"wind_speed_kmh\":27.4,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:43'),
(2424, 48, '2026-06-14', 'day_5', 27.19, 29.77, 85, 8.28, 27.94, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.19,\"temp_max\":29.77,\"humidity\":85,\"rainfall_mm\":8.28,\"wind_speed_kmh\":27.94,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:43'),
(2425, 49, '2026-06-10', 'current', 25.78, 26.13, 76, 0.00, 13.03, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.78,\"temp_max\":26.13,\"humidity\":76,\"rainfall_mm\":0,\"wind_speed_kmh\":13.03,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:44'),
(2426, 49, '2026-06-10', 'today', 26.13, 26.13, 76, 0.00, 13.03, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.13,\"temp_max\":26.13,\"humidity\":76,\"rainfall_mm\":0,\"wind_speed_kmh\":13.03,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:44'),
(2427, 49, '2026-06-11', 'tomorrow', 26.26, 37.42, 68, 5.23, 24.70, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.26,\"temp_max\":37.42,\"humidity\":68,\"rainfall_mm\":5.23,\"wind_speed_kmh\":24.7,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-10 18:00:44'),
(2428, 49, '2026-06-12', 'day_3', 26.63, 35.55, 69, 3.44, 21.64, 'Rain', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.63,\"temp_max\":35.55,\"humidity\":69,\"rainfall_mm\":3.44,\"wind_speed_kmh\":21.64,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:44'),
(2429, 49, '2026-06-13', 'day_4', 26.49, 35.01, 77, 34.42, 29.92, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.49,\"temp_max\":35.01,\"humidity\":77,\"rainfall_mm\":34.42,\"wind_speed_kmh\":29.92,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:44'),
(2430, 49, '2026-06-14', 'day_5', 27.40, 35.20, 75, 10.17, 22.97, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.4,\"temp_max\":35.2,\"humidity\":75,\"rainfall_mm\":10.17,\"wind_speed_kmh\":22.97,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:44'),
(2431, 50, '2026-06-10', 'current', 23.93, 24.48, 91, 0.98, 10.87, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":23.93,\"temp_max\":24.48,\"humidity\":91,\"rainfall_mm\":0.98,\"wind_speed_kmh\":10.87,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:45'),
(2432, 50, '2026-06-10', 'today', 24.48, 24.48, 91, 0.98, 10.87, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":24.48,\"temp_max\":24.48,\"humidity\":91,\"rainfall_mm\":0.98,\"wind_speed_kmh\":10.87,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:45'),
(2433, 50, '2026-06-11', 'tomorrow', 24.35, 34.08, 74, 6.96, 15.62, 'Rain', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.35,\"temp_max\":34.08,\"humidity\":74,\"rainfall_mm\":6.96,\"wind_speed_kmh\":15.62,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:45'),
(2434, 50, '2026-06-12', 'day_3', 24.52, 33.99, 75, 3.82, 13.82, 'Rain', '03d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":24.52,\"temp_max\":33.99,\"humidity\":75,\"rainfall_mm\":3.82,\"wind_speed_kmh\":13.82,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-10 18:00:45'),
(2435, 50, '2026-06-13', 'day_4', 24.49, 33.12, 80, 32.12, 15.26, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.49,\"temp_max\":33.12,\"humidity\":80,\"rainfall_mm\":32.12,\"wind_speed_kmh\":15.26,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:45'),
(2436, 50, '2026-06-14', 'day_5', 24.55, 31.06, 86, 17.47, 19.26, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.55,\"temp_max\":31.06,\"humidity\":86,\"rainfall_mm\":17.47,\"wind_speed_kmh\":19.26,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:45'),
(2437, 51, '2026-06-10', 'current', 29.45, 29.78, 83, 0.00, 19.19, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":29.45,\"temp_max\":29.78,\"humidity\":83,\"rainfall_mm\":0,\"wind_speed_kmh\":19.19,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:46'),
(2438, 51, '2026-06-10', 'today', 29.78, 29.78, 83, 0.00, 19.19, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":29.78,\"temp_max\":29.78,\"humidity\":83,\"rainfall_mm\":0,\"wind_speed_kmh\":19.19,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:46'),
(2439, 51, '2026-06-11', 'tomorrow', 29.05, 32.85, 77, 8.28, 21.67, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.05,\"temp_max\":32.85,\"humidity\":77,\"rainfall_mm\":8.28,\"wind_speed_kmh\":21.67,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:46'),
(2440, 51, '2026-06-12', 'day_3', 28.73, 31.34, 77, 11.59, 21.96, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":28.73,\"temp_max\":31.34,\"humidity\":77,\"rainfall_mm\":11.59,\"wind_speed_kmh\":21.96,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:46'),
(2441, 51, '2026-06-13', 'day_4', 28.55, 29.86, 81, 11.96, 22.97, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":28.55,\"temp_max\":29.86,\"humidity\":81,\"rainfall_mm\":11.96,\"wind_speed_kmh\":22.97,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:46'),
(2442, 51, '2026-06-14', 'day_5', 28.97, 31.60, 80, 2.99, 24.30, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":28.97,\"temp_max\":31.6,\"humidity\":80,\"rainfall_mm\":2.99,\"wind_speed_kmh\":24.3,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:46'),
(2443, 52, '2026-06-10', 'current', 28.07, 28.41, 85, 0.00, 9.14, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":28.07,\"temp_max\":28.41,\"humidity\":85,\"rainfall_mm\":0,\"wind_speed_kmh\":9.14,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:47'),
(2444, 52, '2026-06-10', 'today', 28.41, 28.41, 85, 0.00, 9.14, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":28.41,\"temp_max\":28.41,\"humidity\":85,\"rainfall_mm\":0,\"wind_speed_kmh\":9.14,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:47'),
(2445, 52, '2026-06-11', 'tomorrow', 26.79, 36.44, 71, 7.66, 19.84, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.79,\"temp_max\":36.44,\"humidity\":71,\"rainfall_mm\":7.66,\"wind_speed_kmh\":19.84,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:47'),
(2446, 52, '2026-06-12', 'day_3', 27.61, 33.60, 74, 11.96, 24.91, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.61,\"temp_max\":33.6,\"humidity\":74,\"rainfall_mm\":11.96,\"wind_speed_kmh\":24.91,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:47'),
(2447, 52, '2026-06-13', 'day_4', 27.16, 30.79, 83, 36.78, 21.89, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":27.16,\"temp_max\":30.79,\"humidity\":83,\"rainfall_mm\":36.78,\"wind_speed_kmh\":21.89,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:47'),
(2448, 52, '2026-06-14', 'day_5', 27.66, 33.51, 79, 16.32, 21.24, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.66,\"temp_max\":33.51,\"humidity\":79,\"rainfall_mm\":16.32,\"wind_speed_kmh\":21.24,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:47'),
(2449, 53, '2026-06-10', 'current', 26.50, 26.52, 76, 0.12, 14.04, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.5,\"temp_max\":26.52,\"humidity\":76,\"rainfall_mm\":0.12,\"wind_speed_kmh\":14.04,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:47'),
(2450, 53, '2026-06-10', 'today', 26.50, 26.50, 76, 0.12, 14.04, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.5,\"temp_max\":26.5,\"humidity\":76,\"rainfall_mm\":0.12,\"wind_speed_kmh\":14.04,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:47'),
(2451, 53, '2026-06-11', 'tomorrow', 25.96, 36.10, 71, 15.14, 21.24, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.96,\"temp_max\":36.1,\"humidity\":71,\"rainfall_mm\":15.14,\"wind_speed_kmh\":21.24,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:47'),
(2452, 53, '2026-06-12', 'day_3', 26.52, 34.87, 75, 6.38, 20.05, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.52,\"temp_max\":34.87,\"humidity\":75,\"rainfall_mm\":6.38,\"wind_speed_kmh\":20.05,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:47'),
(2453, 53, '2026-06-13', 'day_4', 25.92, 32.78, 82, 20.65, 40.90, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.92,\"temp_max\":32.78,\"humidity\":82,\"rainfall_mm\":20.65,\"wind_speed_kmh\":40.9,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:47'),
(2454, 53, '2026-06-14', 'day_5', 26.81, 33.90, 81, 12.94, 22.61, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":26.81,\"temp_max\":33.9,\"humidity\":81,\"rainfall_mm\":12.94,\"wind_speed_kmh\":22.61,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:47'),
(2455, 54, '2026-06-10', 'current', 24.88, 26.26, 72, 0.57, 11.66, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":24.88,\"temp_max\":26.26,\"humidity\":72,\"rainfall_mm\":0.57,\"wind_speed_kmh\":11.66,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:48'),
(2456, 54, '2026-06-10', 'today', 26.26, 26.26, 72, 0.57, 11.66, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.26,\"temp_max\":26.26,\"humidity\":72,\"rainfall_mm\":0.57,\"wind_speed_kmh\":11.66,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:48'),
(2457, 54, '2026-06-11', 'tomorrow', 25.84, 38.80, 65, 32.91, 18.11, 'Rain', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.84,\"temp_max\":38.8,\"humidity\":65,\"rainfall_mm\":32.91,\"wind_speed_kmh\":18.11,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-10 18:00:48'),
(2458, 54, '2026-06-12', 'day_3', 26.92, 37.51, 64, 1.00, 22.32, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.92,\"temp_max\":37.51,\"humidity\":64,\"rainfall_mm\":1,\"wind_speed_kmh\":22.32,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:48'),
(2459, 54, '2026-06-13', 'day_4', 26.94, 36.99, 69, 5.94, 24.59, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.94,\"temp_max\":36.99,\"humidity\":69,\"rainfall_mm\":5.94,\"wind_speed_kmh\":24.59,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:48'),
(2460, 54, '2026-06-14', 'day_5', 26.46, 36.53, 70, 8.13, 26.35, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":26.46,\"temp_max\":36.53,\"humidity\":70,\"rainfall_mm\":8.13,\"wind_speed_kmh\":26.35,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:48'),
(2461, 55, '2026-06-10', 'current', 24.65, 25.14, 94, 0.00, 7.60, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":24.65,\"temp_max\":25.14,\"humidity\":94,\"rainfall_mm\":0,\"wind_speed_kmh\":7.6,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:49'),
(2462, 55, '2026-06-10', 'today', 25.14, 25.14, 94, 0.00, 7.60, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.14,\"temp_max\":25.14,\"humidity\":94,\"rainfall_mm\":0,\"wind_speed_kmh\":7.6,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:49'),
(2463, 55, '2026-06-11', 'tomorrow', 25.32, 35.11, 76, 6.28, 16.45, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.32,\"temp_max\":35.11,\"humidity\":76,\"rainfall_mm\":6.28,\"wind_speed_kmh\":16.45,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:49'),
(2464, 55, '2026-06-12', 'day_3', 24.57, 29.96, 85, 0.10, 12.92, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":24.57,\"temp_max\":29.96,\"humidity\":85,\"rainfall_mm\":0.1,\"wind_speed_kmh\":12.92,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:49'),
(2465, 55, '2026-06-13', 'day_4', 23.85, 28.12, 88, 5.39, 11.95, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":23.85,\"temp_max\":28.12,\"humidity\":88,\"rainfall_mm\":5.39,\"wind_speed_kmh\":11.95,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:49'),
(2466, 55, '2026-06-14', 'day_5', 23.57, 29.97, 91, 23.21, 11.16, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":23.57,\"temp_max\":29.97,\"humidity\":91,\"rainfall_mm\":23.21,\"wind_speed_kmh\":11.16,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:49'),
(2467, 56, '2026-06-10', 'current', 25.89, 25.98, 89, 0.00, 7.60, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.89,\"temp_max\":25.98,\"humidity\":89,\"rainfall_mm\":0,\"wind_speed_kmh\":7.6,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:50'),
(2468, 56, '2026-06-10', 'today', 25.98, 25.98, 89, 0.00, 7.60, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.98,\"temp_max\":25.98,\"humidity\":89,\"rainfall_mm\":0,\"wind_speed_kmh\":7.6,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:50'),
(2469, 56, '2026-06-11', 'tomorrow', 25.44, 35.17, 75, 7.56, 17.35, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.44,\"temp_max\":35.17,\"humidity\":75,\"rainfall_mm\":7.56,\"wind_speed_kmh\":17.35,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-10 18:00:50'),
(2470, 56, '2026-06-12', 'day_3', 25.30, 34.34, 76, 11.82, 16.60, 'Rain', '03d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":25.3,\"temp_max\":34.34,\"humidity\":76,\"rainfall_mm\":11.82,\"wind_speed_kmh\":16.6,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-10 18:00:50'),
(2471, 56, '2026-06-13', 'day_4', 25.73, 33.28, 80, 12.94, 20.23, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.73,\"temp_max\":33.28,\"humidity\":80,\"rainfall_mm\":12.94,\"wind_speed_kmh\":20.23,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:50'),
(2472, 56, '2026-06-14', 'day_5', 24.93, 31.48, 86, 15.38, 18.58, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.93,\"temp_max\":31.48,\"humidity\":86,\"rainfall_mm\":15.38,\"wind_speed_kmh\":18.58,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:50'),
(2473, 57, '2026-06-10', 'current', 27.50, 28.09, 86, 0.00, 9.58, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":27.5,\"temp_max\":28.09,\"humidity\":86,\"rainfall_mm\":0,\"wind_speed_kmh\":9.58,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:51'),
(2474, 57, '2026-06-10', 'today', 28.09, 28.09, 86, 0.00, 9.58, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":28.09,\"temp_max\":28.09,\"humidity\":86,\"rainfall_mm\":0,\"wind_speed_kmh\":9.58,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:51'),
(2475, 57, '2026-06-11', 'tomorrow', 26.07, 36.99, 71, 18.08, 37.01, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.07,\"temp_max\":36.99,\"humidity\":71,\"rainfall_mm\":18.08,\"wind_speed_kmh\":37.01,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:51'),
(2476, 57, '2026-06-12', 'day_3', 27.14, 35.62, 75, 11.20, 35.32, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.14,\"temp_max\":35.62,\"humidity\":75,\"rainfall_mm\":11.2,\"wind_speed_kmh\":35.32,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:51'),
(2477, 57, '2026-06-13', 'day_4', 28.11, 36.09, 79, 37.59, 23.98, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":28.11,\"temp_max\":36.09,\"humidity\":79,\"rainfall_mm\":37.59,\"wind_speed_kmh\":23.98,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-10 18:00:51'),
(2478, 57, '2026-06-14', 'day_5', 28.49, 37.04, 71, 0.00, 24.41, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":28.49,\"temp_max\":37.04,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":24.41,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:51'),
(2479, 58, '2026-06-10', 'current', 26.40, 27.15, 80, 0.00, 8.75, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":26.4,\"temp_max\":27.15,\"humidity\":80,\"rainfall_mm\":0,\"wind_speed_kmh\":8.75,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:52'),
(2480, 58, '2026-06-10', 'today', 26.40, 26.40, 80, 0.00, 8.75, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.4,\"temp_max\":26.4,\"humidity\":80,\"rainfall_mm\":0,\"wind_speed_kmh\":8.75,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:52'),
(2481, 58, '2026-06-11', 'tomorrow', 26.16, 35.39, 71, 9.49, 23.65, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.16,\"temp_max\":35.39,\"humidity\":71,\"rainfall_mm\":9.49,\"wind_speed_kmh\":23.65,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:52'),
(2482, 58, '2026-06-12', 'day_3', 26.61, 33.29, 77, 13.81, 19.44, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.61,\"temp_max\":33.29,\"humidity\":77,\"rainfall_mm\":13.81,\"wind_speed_kmh\":19.44,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:52'),
(2483, 58, '2026-06-13', 'day_4', 26.48, 31.92, 81, 11.60, 25.45, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.48,\"temp_max\":31.92,\"humidity\":81,\"rainfall_mm\":11.6,\"wind_speed_kmh\":25.45,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:52'),
(2484, 58, '2026-06-14', 'day_5', 26.95, 32.64, 83, 15.01, 23.51, 'Rain', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":26.95,\"temp_max\":32.64,\"humidity\":83,\"rainfall_mm\":15.01,\"wind_speed_kmh\":23.51,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:52'),
(2485, 59, '2026-06-10', 'current', 24.97, 25.40, 87, 0.00, 12.82, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":24.97,\"temp_max\":25.4,\"humidity\":87,\"rainfall_mm\":0,\"wind_speed_kmh\":12.82,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:53'),
(2486, 59, '2026-06-10', 'today', 25.40, 25.40, 87, 0.00, 12.82, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.4,\"temp_max\":25.4,\"humidity\":87,\"rainfall_mm\":0,\"wind_speed_kmh\":12.82,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:53'),
(2487, 59, '2026-06-11', 'tomorrow', 25.43, 34.65, 74, 4.71, 20.59, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.43,\"temp_max\":34.65,\"humidity\":74,\"rainfall_mm\":4.71,\"wind_speed_kmh\":20.59,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:53'),
(2488, 59, '2026-06-12', 'day_3', 25.65, 33.82, 79, 10.22, 20.09, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":25.65,\"temp_max\":33.82,\"humidity\":79,\"rainfall_mm\":10.22,\"wind_speed_kmh\":20.09,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:53'),
(2489, 59, '2026-06-13', 'day_4', 25.07, 33.61, 80, 19.36, 18.47, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.07,\"temp_max\":33.61,\"humidity\":80,\"rainfall_mm\":19.36,\"wind_speed_kmh\":18.47,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:53'),
(2490, 59, '2026-06-14', 'day_5', 24.95, 31.16, 88, 23.87, 18.65, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.95,\"temp_max\":31.16,\"humidity\":88,\"rainfall_mm\":23.87,\"wind_speed_kmh\":18.65,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:53'),
(2491, 60, '2026-06-10', 'current', 27.44, 27.90, 71, 0.31, 19.08, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":27.44,\"temp_max\":27.9,\"humidity\":71,\"rainfall_mm\":0.31,\"wind_speed_kmh\":19.08,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:54'),
(2492, 60, '2026-06-10', 'today', 27.90, 27.90, 71, 0.31, 19.08, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":27.9,\"temp_max\":27.9,\"humidity\":71,\"rainfall_mm\":0.31,\"wind_speed_kmh\":19.08,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:54'),
(2493, 60, '2026-06-11', 'tomorrow', 26.15, 32.79, 75, 8.88, 29.48, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.15,\"temp_max\":32.79,\"humidity\":75,\"rainfall_mm\":8.88,\"wind_speed_kmh\":29.48,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:54'),
(2494, 60, '2026-06-12', 'day_3', 27.66, 32.26, 73, 5.30, 22.14, 'Rain', '04d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":27.66,\"temp_max\":32.26,\"humidity\":73,\"rainfall_mm\":5.3,\"wind_speed_kmh\":22.14,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-10 18:00:54'),
(2495, 60, '2026-06-13', 'day_4', 27.16, 32.29, 76, 14.73, 27.83, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":27.16,\"temp_max\":32.29,\"humidity\":76,\"rainfall_mm\":14.73,\"wind_speed_kmh\":27.83,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:54'),
(2496, 60, '2026-06-14', 'day_5', 27.31, 31.70, 81, 17.24, 27.29, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":27.31,\"temp_max\":31.7,\"humidity\":81,\"rainfall_mm\":17.24,\"wind_speed_kmh\":27.29,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:54'),
(2497, 61, '2026-06-10', 'current', 25.76, 26.06, 92, 0.00, 8.78, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.76,\"temp_max\":26.06,\"humidity\":92,\"rainfall_mm\":0,\"wind_speed_kmh\":8.78,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:55'),
(2498, 61, '2026-06-10', 'today', 26.06, 26.06, 92, 0.00, 8.78, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":26.06,\"temp_max\":26.06,\"humidity\":92,\"rainfall_mm\":0,\"wind_speed_kmh\":8.78,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:55'),
(2499, 61, '2026-06-11', 'tomorrow', 25.66, 35.02, 74, 18.45, 9.47, 'Rain', '10d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.66,\"temp_max\":35.02,\"humidity\":74,\"rainfall_mm\":18.45,\"wind_speed_kmh\":9.47,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:55'),
(2500, 61, '2026-06-12', 'day_3', 24.90, 29.27, 88, 31.14, 16.78, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":24.9,\"temp_max\":29.27,\"humidity\":88,\"rainfall_mm\":31.14,\"wind_speed_kmh\":16.78,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:55'),
(2501, 61, '2026-06-13', 'day_4', 24.62, 30.07, 85, 33.10, 15.41, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.62,\"temp_max\":30.07,\"humidity\":85,\"rainfall_mm\":33.1,\"wind_speed_kmh\":15.41,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:55'),
(2502, 61, '2026-06-14', 'day_5', 24.65, 29.77, 90, 16.95, 14.18, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.65,\"temp_max\":29.77,\"humidity\":90,\"rainfall_mm\":16.95,\"wind_speed_kmh\":14.18,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:55'),
(2503, 62, '2026-06-10', 'current', 25.65, 25.78, 93, 0.00, 10.01, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.65,\"temp_max\":25.78,\"humidity\":93,\"rainfall_mm\":0,\"wind_speed_kmh\":10.01,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:55'),
(2504, 62, '2026-06-10', 'today', 25.78, 25.78, 93, 0.00, 10.01, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.78,\"temp_max\":25.78,\"humidity\":93,\"rainfall_mm\":0,\"wind_speed_kmh\":10.01,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-10 18:00:55'),
(2505, 62, '2026-06-11', 'tomorrow', 25.50, 34.62, 72, 13.37, 6.80, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.5,\"temp_max\":34.62,\"humidity\":72,\"rainfall_mm\":13.37,\"wind_speed_kmh\":6.8,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:55'),
(2506, 62, '2026-06-12', 'day_3', 24.57, 28.65, 87, 22.83, 12.89, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":24.57,\"temp_max\":28.65,\"humidity\":87,\"rainfall_mm\":22.83,\"wind_speed_kmh\":12.89,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:55'),
(2507, 62, '2026-06-13', 'day_4', 24.71, 30.89, 84, 27.48, 11.66, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":24.71,\"temp_max\":30.89,\"humidity\":84,\"rainfall_mm\":27.48,\"wind_speed_kmh\":11.66,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:55'),
(2508, 62, '2026-06-14', 'day_5', 24.10, 29.49, 88, 22.48, 10.01, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.1,\"temp_max\":29.49,\"humidity\":88,\"rainfall_mm\":22.48,\"wind_speed_kmh\":10.01,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:55'),
(2509, 63, '2026-06-10', 'current', 25.53, 25.68, 81, 0.24, 10.44, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":25.53,\"temp_max\":25.68,\"humidity\":81,\"rainfall_mm\":0.24,\"wind_speed_kmh\":10.44,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:56'),
(2510, 63, '2026-06-10', 'today', 25.68, 25.68, 81, 0.24, 10.44, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.68,\"temp_max\":25.68,\"humidity\":81,\"rainfall_mm\":0.24,\"wind_speed_kmh\":10.44,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:56'),
(2511, 63, '2026-06-11', 'tomorrow', 25.61, 35.57, 74, 15.35, 19.94, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.61,\"temp_max\":35.57,\"humidity\":74,\"rainfall_mm\":15.35,\"wind_speed_kmh\":19.94,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-10 18:00:56'),
(2512, 63, '2026-06-12', 'day_3', 26.01, 33.93, 75, 9.87, 18.14, 'Rain', '10d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":26.01,\"temp_max\":33.93,\"humidity\":75,\"rainfall_mm\":9.87,\"wind_speed_kmh\":18.14,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:56'),
(2513, 63, '2026-06-13', 'day_4', 26.46, 33.08, 79, 12.53, 23.04, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":26.46,\"temp_max\":33.08,\"humidity\":79,\"rainfall_mm\":12.53,\"wind_speed_kmh\":23.04,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:56'),
(2514, 63, '2026-06-14', 'day_5', 26.22, 31.68, 82, 19.99, 18.65, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":26.22,\"temp_max\":31.68,\"humidity\":82,\"rainfall_mm\":19.99,\"wind_speed_kmh\":18.65,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:56'),
(2515, 64, '2026-06-10', 'current', 24.74, 25.11, 88, 2.27, 10.69, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"current\",\"temp_min\":24.74,\"temp_max\":25.11,\"humidity\":88,\"rainfall_mm\":2.27,\"wind_speed_kmh\":10.69,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:57'),
(2516, 64, '2026-06-10', 'today', 25.11, 25.11, 88, 2.27, 10.69, 'Rain', '10n', '{\"forecast_date\":\"2026-06-10\",\"forecast_for\":\"today\",\"temp_min\":25.11,\"temp_max\":25.11,\"humidity\":88,\"rainfall_mm\":2.27,\"wind_speed_kmh\":10.69,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-10 18:00:57'),
(2517, 64, '2026-06-11', 'tomorrow', 24.92, 35.11, 72, 5.71, 19.66, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-11\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.92,\"temp_max\":35.11,\"humidity\":72,\"rainfall_mm\":5.71,\"wind_speed_kmh\":19.66,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-10 18:00:57'),
(2518, 64, '2026-06-12', 'day_3', 25.29, 35.22, 73, 2.62, 13.97, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-12\",\"forecast_for\":\"day_3\",\"temp_min\":25.29,\"temp_max\":35.22,\"humidity\":73,\"rainfall_mm\":2.62,\"wind_speed_kmh\":13.97,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-10 18:00:57'),
(2519, 64, '2026-06-13', 'day_4', 25.21, 33.75, 75, 20.18, 16.70, 'Rain', '10d', '{\"forecast_date\":\"2026-06-13\",\"forecast_for\":\"day_4\",\"temp_min\":25.21,\"temp_max\":33.75,\"humidity\":75,\"rainfall_mm\":20.18,\"wind_speed_kmh\":16.7,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:57'),
(2520, 64, '2026-06-14', 'day_5', 24.78, 31.72, 83, 18.99, 19.51, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"day_5\",\"temp_min\":24.78,\"temp_max\":31.72,\"humidity\":83,\"rainfall_mm\":18.99,\"wind_speed_kmh\":19.51,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-10 18:00:57');
INSERT INTO `weather_forecasts` (`forecast_id`, `district_id`, `forecast_date`, `forecast_for`, `temp_min`, `temp_max`, `humidity`, `rainfall_mm`, `wind_speed_kmh`, `conditions`, `icon`, `raw_payload`, `fetched_at`) VALUES
(2521, 1, '2026-06-14', 'current', 31.93, 31.93, 66, 0.24, 20.27, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":31.93,\"temp_max\":31.93,\"humidity\":66,\"rainfall_mm\":0.24,\"wind_speed_kmh\":20.27,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:22'),
(2522, 1, '2026-06-14', 'today', 28.17, 31.93, 74, 0.95, 20.27, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.17,\"temp_max\":31.93,\"humidity\":74,\"rainfall_mm\":0.95,\"wind_speed_kmh\":20.27,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:22'),
(2523, 1, '2026-06-15', 'tomorrow', 28.14, 36.70, 69, 0.00, 25.63, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.14,\"temp_max\":36.7,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":25.63,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:22'),
(2524, 1, '2026-06-16', 'day_3', 28.54, 36.84, 67, 0.00, 27.40, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.54,\"temp_max\":36.84,\"humidity\":67,\"rainfall_mm\":0,\"wind_speed_kmh\":27.4,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:22'),
(2525, 1, '2026-06-17', 'day_4', 28.70, 36.98, 66, 0.00, 29.16, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.7,\"temp_max\":36.98,\"humidity\":66,\"rainfall_mm\":0,\"wind_speed_kmh\":29.16,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:22'),
(2526, 1, '2026-06-18', 'day_5', 28.64, 36.86, 67, 0.17, 29.74, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.64,\"temp_max\":36.86,\"humidity\":67,\"rainfall_mm\":0.17,\"wind_speed_kmh\":29.74,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:22'),
(2527, 2, '2026-06-14', 'current', 26.29, 26.29, 94, 2.18, 5.22, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":26.29,\"temp_max\":26.29,\"humidity\":94,\"rainfall_mm\":2.18,\"wind_speed_kmh\":5.22,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:22'),
(2528, 2, '2026-06-14', 'today', 24.03, 26.29, 95, 2.34, 6.80, 'Rain', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":24.03,\"temp_max\":26.29,\"humidity\":95,\"rainfall_mm\":2.34,\"wind_speed_kmh\":6.8,\"conditions\":\"Rain\",\"icon\":\"04n\"}', '2026-06-14 11:17:22'),
(2529, 2, '2026-06-15', 'tomorrow', 23.70, 31.93, 82, 4.40, 8.64, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":23.7,\"temp_max\":31.93,\"humidity\":82,\"rainfall_mm\":4.4,\"wind_speed_kmh\":8.64,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:22'),
(2530, 2, '2026-06-16', 'day_3', 24.07, 34.10, 77, 1.53, 9.86, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":24.07,\"temp_max\":34.1,\"humidity\":77,\"rainfall_mm\":1.53,\"wind_speed_kmh\":9.86,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:22'),
(2531, 2, '2026-06-17', 'day_4', 24.52, 35.44, 75, 0.80, 9.65, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":24.52,\"temp_max\":35.44,\"humidity\":75,\"rainfall_mm\":0.8,\"wind_speed_kmh\":9.65,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:22'),
(2532, 2, '2026-06-18', 'day_5', 24.74, 34.89, 70, 0.00, 11.27, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":24.74,\"temp_max\":34.89,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":11.27,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:22'),
(2533, 3, '2026-06-14', 'current', 29.10, 29.10, 82, 2.76, 20.27, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":29.1,\"temp_max\":29.1,\"humidity\":82,\"rainfall_mm\":2.76,\"wind_speed_kmh\":20.27,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:22'),
(2534, 3, '2026-06-14', 'today', 28.38, 29.10, 84, 10.45, 21.35, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.38,\"temp_max\":29.1,\"humidity\":84,\"rainfall_mm\":10.45,\"wind_speed_kmh\":21.35,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:22'),
(2535, 3, '2026-06-15', 'tomorrow', 28.22, 31.94, 80, 1.71, 25.96, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.22,\"temp_max\":31.94,\"humidity\":80,\"rainfall_mm\":1.71,\"wind_speed_kmh\":25.96,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-14 11:17:22'),
(2536, 3, '2026-06-16', 'day_3', 28.21, 31.80, 79, 0.55, 25.70, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.21,\"temp_max\":31.8,\"humidity\":79,\"rainfall_mm\":0.55,\"wind_speed_kmh\":25.7,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:22'),
(2537, 3, '2026-06-17', 'day_4', 28.22, 31.41, 78, 0.10, 28.12, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.22,\"temp_max\":31.41,\"humidity\":78,\"rainfall_mm\":0.1,\"wind_speed_kmh\":28.12,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:22'),
(2538, 3, '2026-06-18', 'day_5', 28.43, 31.43, 79, 0.81, 30.17, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.43,\"temp_max\":31.43,\"humidity\":79,\"rainfall_mm\":0.81,\"wind_speed_kmh\":30.17,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:22'),
(2539, 4, '2026-06-14', 'current', 30.72, 30.72, 74, 2.09, 9.86, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.72,\"temp_max\":30.72,\"humidity\":74,\"rainfall_mm\":2.09,\"wind_speed_kmh\":9.86,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:23'),
(2540, 4, '2026-06-14', 'today', 27.77, 30.72, 81, 3.05, 13.82, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.77,\"temp_max\":30.72,\"humidity\":81,\"rainfall_mm\":3.05,\"wind_speed_kmh\":13.82,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:23'),
(2541, 4, '2026-06-15', 'tomorrow', 27.88, 34.58, 73, 0.74, 20.38, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.88,\"temp_max\":34.58,\"humidity\":73,\"rainfall_mm\":0.74,\"wind_speed_kmh\":20.38,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:23'),
(2542, 4, '2026-06-16', 'day_3', 27.59, 33.98, 74, 0.22, 21.78, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.59,\"temp_max\":33.98,\"humidity\":74,\"rainfall_mm\":0.22,\"wind_speed_kmh\":21.78,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:23'),
(2543, 4, '2026-06-17', 'day_4', 27.76, 33.38, 73, 0.00, 23.11, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.76,\"temp_max\":33.38,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":23.11,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:23'),
(2544, 4, '2026-06-18', 'day_5', 28.04, 33.66, 73, 0.45, 23.72, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.04,\"temp_max\":33.66,\"humidity\":73,\"rainfall_mm\":0.45,\"wind_speed_kmh\":23.72,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:23'),
(2545, 5, '2026-06-14', 'current', 28.88, 28.88, 82, 2.25, 18.04, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":28.88,\"temp_max\":28.88,\"humidity\":82,\"rainfall_mm\":2.25,\"wind_speed_kmh\":18.04,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:23'),
(2546, 5, '2026-06-14', 'today', 28.28, 28.88, 84, 9.28, 20.12, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.28,\"temp_max\":28.88,\"humidity\":84,\"rainfall_mm\":9.28,\"wind_speed_kmh\":20.12,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:23'),
(2547, 5, '2026-06-15', 'tomorrow', 28.00, 32.13, 80, 2.20, 24.52, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28,\"temp_max\":32.13,\"humidity\":80,\"rainfall_mm\":2.2,\"wind_speed_kmh\":24.52,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-14 11:17:23'),
(2548, 5, '2026-06-16', 'day_3', 28.11, 32.22, 78, 0.67, 24.70, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.11,\"temp_max\":32.22,\"humidity\":78,\"rainfall_mm\":0.67,\"wind_speed_kmh\":24.7,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:23'),
(2549, 5, '2026-06-17', 'day_4', 28.13, 31.84, 78, 0.00, 27.54, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.13,\"temp_max\":31.84,\"humidity\":78,\"rainfall_mm\":0,\"wind_speed_kmh\":27.54,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:23'),
(2550, 5, '2026-06-18', 'day_5', 28.30, 31.64, 78, 0.76, 29.30, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.3,\"temp_max\":31.64,\"humidity\":78,\"rainfall_mm\":0.76,\"wind_speed_kmh\":29.3,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:23'),
(2551, 7, '2026-06-14', 'current', 29.56, 29.56, 80, 0.94, 16.78, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":29.56,\"temp_max\":29.56,\"humidity\":80,\"rainfall_mm\":0.94,\"wind_speed_kmh\":16.78,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:23'),
(2552, 7, '2026-06-14', 'today', 25.90, 29.56, 88, 7.64, 16.78, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":25.9,\"temp_max\":29.56,\"humidity\":88,\"rainfall_mm\":7.64,\"wind_speed_kmh\":16.78,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:23'),
(2553, 7, '2026-06-15', 'tomorrow', 25.16, 32.42, 85, 18.58, 22.75, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.16,\"temp_max\":32.42,\"humidity\":85,\"rainfall_mm\":18.58,\"wind_speed_kmh\":22.75,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:23'),
(2554, 7, '2026-06-16', 'day_3', 25.77, 32.76, 82, 7.62, 21.42, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":25.77,\"temp_max\":32.76,\"humidity\":82,\"rainfall_mm\":7.62,\"wind_speed_kmh\":21.42,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:23'),
(2555, 7, '2026-06-17', 'day_4', 26.05, 32.79, 80, 4.69, 21.85, 'Rain', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":26.05,\"temp_max\":32.79,\"humidity\":80,\"rainfall_mm\":4.69,\"wind_speed_kmh\":21.85,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:23'),
(2556, 7, '2026-06-18', 'day_5', 26.43, 32.88, 79, 3.44, 24.59, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":26.43,\"temp_max\":32.88,\"humidity\":79,\"rainfall_mm\":3.44,\"wind_speed_kmh\":24.59,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:23'),
(2557, 8, '2026-06-14', 'current', 28.67, 28.67, 81, 0.22, 14.98, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":28.67,\"temp_max\":28.67,\"humidity\":81,\"rainfall_mm\":0.22,\"wind_speed_kmh\":14.98,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:24'),
(2558, 8, '2026-06-14', 'today', 25.61, 28.67, 88, 2.38, 16.60, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":25.61,\"temp_max\":28.67,\"humidity\":88,\"rainfall_mm\":2.38,\"wind_speed_kmh\":16.6,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:24'),
(2559, 8, '2026-06-15', 'tomorrow', 25.20, 31.13, 84, 2.07, 18.14, 'Rain', '04d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.2,\"temp_max\":31.13,\"humidity\":84,\"rainfall_mm\":2.07,\"wind_speed_kmh\":18.14,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:24'),
(2560, 8, '2026-06-16', 'day_3', 24.90, 31.88, 82, 1.36, 18.00, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":24.9,\"temp_max\":31.88,\"humidity\":82,\"rainfall_mm\":1.36,\"wind_speed_kmh\":18,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:24'),
(2561, 8, '2026-06-17', 'day_4', 25.85, 32.75, 78, 0.15, 18.00, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":25.85,\"temp_max\":32.75,\"humidity\":78,\"rainfall_mm\":0.15,\"wind_speed_kmh\":18,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-14 11:17:24'),
(2562, 8, '2026-06-18', 'day_5', 26.25, 31.68, 79, 0.50, 21.35, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":26.25,\"temp_max\":31.68,\"humidity\":79,\"rainfall_mm\":0.5,\"wind_speed_kmh\":21.35,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:24'),
(2563, 11, '2026-06-14', 'current', 33.79, 33.79, 52, 0.00, 10.37, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":33.79,\"temp_max\":33.79,\"humidity\":52,\"rainfall_mm\":0,\"wind_speed_kmh\":10.37,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:24'),
(2564, 11, '2026-06-14', 'today', 28.29, 33.79, 64, 0.00, 18.72, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.29,\"temp_max\":33.79,\"humidity\":64,\"rainfall_mm\":0,\"wind_speed_kmh\":18.72,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-14 11:17:24'),
(2565, 11, '2026-06-15', 'tomorrow', 28.51, 38.72, 61, 0.12, 28.40, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.51,\"temp_max\":38.72,\"humidity\":61,\"rainfall_mm\":0.12,\"wind_speed_kmh\":28.4,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:24'),
(2566, 11, '2026-06-16', 'day_3', 28.56, 39.18, 61, 0.00, 28.01, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.56,\"temp_max\":39.18,\"humidity\":61,\"rainfall_mm\":0,\"wind_speed_kmh\":28.01,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:24'),
(2567, 11, '2026-06-17', 'day_4', 28.76, 39.76, 60, 0.00, 30.31, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.76,\"temp_max\":39.76,\"humidity\":60,\"rainfall_mm\":0,\"wind_speed_kmh\":30.31,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:24'),
(2568, 11, '2026-06-18', 'day_5', 29.16, 39.80, 61, 0.21, 33.98, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":29.16,\"temp_max\":39.8,\"humidity\":61,\"rainfall_mm\":0.21,\"wind_speed_kmh\":33.98,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:24'),
(2569, 12, '2026-06-14', 'current', 29.15, 29.15, 81, 1.49, 16.24, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":29.15,\"temp_max\":29.15,\"humidity\":81,\"rainfall_mm\":1.49,\"wind_speed_kmh\":16.24,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:24'),
(2570, 12, '2026-06-14', 'today', 26.86, 29.15, 87, 3.06, 20.56, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":26.86,\"temp_max\":29.15,\"humidity\":87,\"rainfall_mm\":3.06,\"wind_speed_kmh\":20.56,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:24'),
(2571, 12, '2026-06-15', 'tomorrow', 26.05, 32.60, 82, 5.44, 22.61, 'Rain', '04d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.05,\"temp_max\":32.6,\"humidity\":82,\"rainfall_mm\":5.44,\"wind_speed_kmh\":22.61,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:24'),
(2572, 12, '2026-06-16', 'day_3', 25.57, 32.11, 81, 2.64, 20.99, 'Rain', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":25.57,\"temp_max\":32.11,\"humidity\":81,\"rainfall_mm\":2.64,\"wind_speed_kmh\":20.99,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:24'),
(2573, 12, '2026-06-17', 'day_4', 26.62, 33.15, 77, 0.34, 21.64, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":26.62,\"temp_max\":33.15,\"humidity\":77,\"rainfall_mm\":0.34,\"wind_speed_kmh\":21.64,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:24'),
(2574, 12, '2026-06-18', 'day_5', 26.82, 32.06, 78, 0.98, 25.42, 'Rain', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":26.82,\"temp_max\":32.06,\"humidity\":78,\"rainfall_mm\":0.98,\"wind_speed_kmh\":25.42,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:24'),
(2575, 13, '2026-06-14', 'current', 28.62, 28.62, 80, 0.20, 17.71, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":28.62,\"temp_max\":28.62,\"humidity\":80,\"rainfall_mm\":0.2,\"wind_speed_kmh\":17.71,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:25'),
(2576, 13, '2026-06-14', 'today', 26.38, 28.62, 83, 0.48, 18.47, 'Rain', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":26.38,\"temp_max\":28.62,\"humidity\":83,\"rainfall_mm\":0.48,\"wind_speed_kmh\":18.47,\"conditions\":\"Rain\",\"icon\":\"04n\"}', '2026-06-14 11:17:25'),
(2577, 13, '2026-06-15', 'tomorrow', 26.01, 30.39, 80, 1.82, 23.87, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.01,\"temp_max\":30.39,\"humidity\":80,\"rainfall_mm\":1.82,\"wind_speed_kmh\":23.87,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:25'),
(2578, 13, '2026-06-16', 'day_3', 26.29, 30.56, 78, 0.13, 22.54, 'Clouds', '01d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":26.29,\"temp_max\":30.56,\"humidity\":78,\"rainfall_mm\":0.13,\"wind_speed_kmh\":22.54,\"conditions\":\"Clouds\",\"icon\":\"01d\"}', '2026-06-14 11:17:25'),
(2579, 13, '2026-06-17', 'day_4', 26.79, 30.94, 78, 1.09, 24.37, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":26.79,\"temp_max\":30.94,\"humidity\":78,\"rainfall_mm\":1.09,\"wind_speed_kmh\":24.37,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:25'),
(2580, 13, '2026-06-18', 'day_5', 26.85, 31.09, 78, 0.15, 24.88, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":26.85,\"temp_max\":31.09,\"humidity\":78,\"rainfall_mm\":0.15,\"wind_speed_kmh\":24.88,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:25'),
(2581, 14, '2026-06-14', 'current', 30.49, 30.49, 71, 2.16, 20.56, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.49,\"temp_max\":30.49,\"humidity\":71,\"rainfall_mm\":2.16,\"wind_speed_kmh\":20.56,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:25'),
(2582, 14, '2026-06-14', 'today', 28.01, 30.49, 77, 4.13, 20.56, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.01,\"temp_max\":30.49,\"humidity\":77,\"rainfall_mm\":4.13,\"wind_speed_kmh\":20.56,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:25'),
(2583, 14, '2026-06-15', 'tomorrow', 27.83, 34.86, 73, 7.38, 25.60, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.83,\"temp_max\":34.86,\"humidity\":73,\"rainfall_mm\":7.38,\"wind_speed_kmh\":25.6,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:25'),
(2584, 14, '2026-06-16', 'day_3', 27.70, 34.56, 72, 0.82, 25.60, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.7,\"temp_max\":34.56,\"humidity\":72,\"rainfall_mm\":0.82,\"wind_speed_kmh\":25.6,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:25'),
(2585, 14, '2026-06-17', 'day_4', 27.76, 34.66, 71, 0.24, 27.90, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.76,\"temp_max\":34.66,\"humidity\":71,\"rainfall_mm\":0.24,\"wind_speed_kmh\":27.9,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:25'),
(2586, 14, '2026-06-18', 'day_5', 28.02, 34.52, 71, 0.30, 29.77, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.02,\"temp_max\":34.52,\"humidity\":71,\"rainfall_mm\":0.3,\"wind_speed_kmh\":29.77,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:25'),
(2587, 15, '2026-06-14', 'current', 33.40, 33.40, 57, 0.00, 14.26, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":33.4,\"temp_max\":33.4,\"humidity\":57,\"rainfall_mm\":0,\"wind_speed_kmh\":14.26,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:25'),
(2588, 15, '2026-06-14', 'today', 27.95, 33.40, 68, 0.60, 18.68, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.95,\"temp_max\":33.4,\"humidity\":68,\"rainfall_mm\":0.6,\"wind_speed_kmh\":18.68,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-14 11:17:25'),
(2589, 15, '2026-06-15', 'tomorrow', 27.55, 39.22, 65, 2.15, 23.11, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.55,\"temp_max\":39.22,\"humidity\":65,\"rainfall_mm\":2.15,\"wind_speed_kmh\":23.11,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:25'),
(2590, 15, '2026-06-16', 'day_3', 26.54, 35.51, 69, 2.80, 19.40, 'Rain', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":26.54,\"temp_max\":35.51,\"humidity\":69,\"rainfall_mm\":2.8,\"wind_speed_kmh\":19.4,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-14 11:17:25'),
(2591, 15, '2026-06-17', 'day_4', 27.90, 35.03, 68, 0.36, 20.84, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.9,\"temp_max\":35.03,\"humidity\":68,\"rainfall_mm\":0.36,\"wind_speed_kmh\":20.84,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:25'),
(2592, 15, '2026-06-18', 'day_5', 28.05, 35.26, 69, 1.09, 20.12, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.05,\"temp_max\":35.26,\"humidity\":69,\"rainfall_mm\":1.09,\"wind_speed_kmh\":20.12,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:25'),
(2593, 16, '2026-06-14', 'current', 30.23, 30.23, 75, 1.69, 19.04, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.23,\"temp_max\":30.23,\"humidity\":75,\"rainfall_mm\":1.69,\"wind_speed_kmh\":19.04,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:26'),
(2594, 16, '2026-06-14', 'today', 27.60, 30.23, 81, 3.71, 19.04, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.6,\"temp_max\":30.23,\"humidity\":81,\"rainfall_mm\":3.71,\"wind_speed_kmh\":19.04,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:26'),
(2595, 16, '2026-06-15', 'tomorrow', 27.24, 36.02, 76, 16.53, 23.94, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.24,\"temp_max\":36.02,\"humidity\":76,\"rainfall_mm\":16.53,\"wind_speed_kmh\":23.94,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:26'),
(2596, 16, '2026-06-16', 'day_3', 27.31, 35.50, 75, 0.25, 27.43, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.31,\"temp_max\":35.5,\"humidity\":75,\"rainfall_mm\":0.25,\"wind_speed_kmh\":27.43,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:26'),
(2597, 16, '2026-06-17', 'day_4', 27.43, 35.00, 72, 0.12, 29.41, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.43,\"temp_max\":35,\"humidity\":72,\"rainfall_mm\":0.12,\"wind_speed_kmh\":29.41,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:26'),
(2598, 16, '2026-06-18', 'day_5', 27.68, 37.20, 73, 0.61, 29.59, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.68,\"temp_max\":37.2,\"humidity\":73,\"rainfall_mm\":0.61,\"wind_speed_kmh\":29.59,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:26'),
(2599, 17, '2026-06-14', 'current', 28.73, 28.73, 82, 0.00, 16.16, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":28.73,\"temp_max\":28.73,\"humidity\":82,\"rainfall_mm\":0,\"wind_speed_kmh\":16.16,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:26'),
(2600, 17, '2026-06-14', 'today', 26.40, 28.73, 87, 4.83, 17.93, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":26.4,\"temp_max\":28.73,\"humidity\":87,\"rainfall_mm\":4.83,\"wind_speed_kmh\":17.93,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:26'),
(2601, 17, '2026-06-15', 'tomorrow', 26.21, 31.65, 81, 0.70, 22.68, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.21,\"temp_max\":31.65,\"humidity\":81,\"rainfall_mm\":0.7,\"wind_speed_kmh\":22.68,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:26'),
(2602, 17, '2026-06-16', 'day_3', 25.96, 32.14, 79, 0.73, 22.07, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":25.96,\"temp_max\":32.14,\"humidity\":79,\"rainfall_mm\":0.73,\"wind_speed_kmh\":22.07,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:26'),
(2603, 17, '2026-06-17', 'day_4', 26.63, 32.58, 77, 0.30, 21.02, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":26.63,\"temp_max\":32.58,\"humidity\":77,\"rainfall_mm\":0.3,\"wind_speed_kmh\":21.02,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-14 11:17:26'),
(2604, 17, '2026-06-18', 'day_5', 27.01, 32.26, 77, 0.42, 24.95, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.01,\"temp_max\":32.26,\"humidity\":77,\"rainfall_mm\":0.42,\"wind_speed_kmh\":24.95,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:26'),
(2605, 18, '2026-06-14', 'current', 31.16, 31.16, 72, 0.00, 9.29, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":31.16,\"temp_max\":31.16,\"humidity\":72,\"rainfall_mm\":0,\"wind_speed_kmh\":9.29,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:26'),
(2606, 18, '2026-06-14', 'today', 25.80, 31.16, 82, 6.38, 18.94, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":25.8,\"temp_max\":31.16,\"humidity\":82,\"rainfall_mm\":6.38,\"wind_speed_kmh\":18.94,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:26'),
(2607, 18, '2026-06-15', 'tomorrow', 26.15, 34.73, 76, 0.14, 24.73, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.15,\"temp_max\":34.73,\"humidity\":76,\"rainfall_mm\":0.14,\"wind_speed_kmh\":24.73,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:26'),
(2608, 18, '2026-06-16', 'day_3', 25.79, 34.78, 78, 4.84, 21.78, 'Rain', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":25.79,\"temp_max\":34.78,\"humidity\":78,\"rainfall_mm\":4.84,\"wind_speed_kmh\":21.78,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-14 11:17:26'),
(2609, 18, '2026-06-17', 'day_4', 27.00, 34.24, 78, 4.64, 21.89, 'Rain', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27,\"temp_max\":34.24,\"humidity\":78,\"rainfall_mm\":4.64,\"wind_speed_kmh\":21.89,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:26'),
(2610, 18, '2026-06-18', 'day_5', 27.09, 33.12, 78, 5.51, 24.52, 'Rain', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.09,\"temp_max\":33.12,\"humidity\":78,\"rainfall_mm\":5.51,\"wind_speed_kmh\":24.52,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:26'),
(2611, 19, '2026-06-14', 'current', 30.45, 30.45, 73, 0.93, 13.75, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.45,\"temp_max\":30.45,\"humidity\":73,\"rainfall_mm\":0.93,\"wind_speed_kmh\":13.75,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:27'),
(2612, 19, '2026-06-14', 'today', 26.95, 30.45, 81, 4.96, 15.44, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":26.95,\"temp_max\":30.45,\"humidity\":81,\"rainfall_mm\":4.96,\"wind_speed_kmh\":15.44,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:27'),
(2613, 19, '2026-06-15', 'tomorrow', 26.93, 34.40, 78, 10.48, 24.84, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.93,\"temp_max\":34.4,\"humidity\":78,\"rainfall_mm\":10.48,\"wind_speed_kmh\":24.84,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:27'),
(2614, 19, '2026-06-16', 'day_3', 26.89, 33.85, 76, 0.88, 26.64, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":26.89,\"temp_max\":33.85,\"humidity\":76,\"rainfall_mm\":0.88,\"wind_speed_kmh\":26.64,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:27'),
(2615, 19, '2026-06-17', 'day_4', 27.22, 33.37, 74, 0.49, 27.29, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.22,\"temp_max\":33.37,\"humidity\":74,\"rainfall_mm\":0.49,\"wind_speed_kmh\":27.29,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:27'),
(2616, 19, '2026-06-18', 'day_5', 27.49, 33.65, 75, 0.66, 28.87, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.49,\"temp_max\":33.65,\"humidity\":75,\"rainfall_mm\":0.66,\"wind_speed_kmh\":28.87,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:27'),
(2617, 20, '2026-06-14', 'current', 30.70, 30.70, 73, 0.00, 16.27, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.7,\"temp_max\":30.7,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":16.27,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:27'),
(2618, 20, '2026-06-14', 'today', 27.63, 30.70, 80, 1.92, 16.45, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.63,\"temp_max\":30.7,\"humidity\":80,\"rainfall_mm\":1.92,\"wind_speed_kmh\":16.45,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-14 11:17:27'),
(2619, 20, '2026-06-15', 'tomorrow', 27.23, 36.94, 75, 13.00, 21.60, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.23,\"temp_max\":36.94,\"humidity\":75,\"rainfall_mm\":13,\"wind_speed_kmh\":21.6,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:27'),
(2620, 20, '2026-06-16', 'day_3', 27.39, 35.97, 74, 0.00, 27.40, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.39,\"temp_max\":35.97,\"humidity\":74,\"rainfall_mm\":0,\"wind_speed_kmh\":27.4,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:27'),
(2621, 20, '2026-06-17', 'day_4', 27.65, 36.15, 70, 0.00, 29.70, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.65,\"temp_max\":36.15,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":29.7,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:27'),
(2622, 20, '2026-06-18', 'day_5', 27.77, 37.75, 71, 0.57, 29.12, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.77,\"temp_max\":37.75,\"humidity\":71,\"rainfall_mm\":0.57,\"wind_speed_kmh\":29.12,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:27'),
(2623, 21, '2026-06-14', 'current', 28.03, 28.03, 85, 6.72, 10.37, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":28.03,\"temp_max\":28.03,\"humidity\":85,\"rainfall_mm\":6.72,\"wind_speed_kmh\":10.37,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:27'),
(2624, 21, '2026-06-14', 'today', 24.85, 28.03, 90, 11.63, 10.37, 'Rain', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":24.85,\"temp_max\":28.03,\"humidity\":90,\"rainfall_mm\":11.63,\"wind_speed_kmh\":10.37,\"conditions\":\"Rain\",\"icon\":\"04n\"}', '2026-06-14 11:17:27'),
(2625, 21, '2026-06-15', 'tomorrow', 24.43, 29.87, 89, 13.13, 11.20, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.43,\"temp_max\":29.87,\"humidity\":89,\"rainfall_mm\":13.13,\"wind_speed_kmh\":11.2,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:27'),
(2626, 21, '2026-06-16', 'day_3', 24.91, 32.66, 83, 11.75, 13.28, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":24.91,\"temp_max\":32.66,\"humidity\":83,\"rainfall_mm\":11.75,\"wind_speed_kmh\":13.28,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:27'),
(2627, 21, '2026-06-17', 'day_4', 25.10, 32.93, 82, 7.55, 13.21, 'Rain', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":25.1,\"temp_max\":32.93,\"humidity\":82,\"rainfall_mm\":7.55,\"wind_speed_kmh\":13.21,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:27'),
(2628, 21, '2026-06-18', 'day_5', 25.30, 32.41, 83, 16.17, 15.44, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":25.3,\"temp_max\":32.41,\"humidity\":83,\"rainfall_mm\":16.17,\"wind_speed_kmh\":15.44,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:27'),
(2629, 22, '2026-06-14', 'current', 29.91, 29.91, 75, 1.24, 14.36, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":29.91,\"temp_max\":29.91,\"humidity\":75,\"rainfall_mm\":1.24,\"wind_speed_kmh\":14.36,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:28'),
(2630, 22, '2026-06-14', 'today', 27.40, 29.91, 80, 1.42, 18.32, 'Rain', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.4,\"temp_max\":29.91,\"humidity\":80,\"rainfall_mm\":1.42,\"wind_speed_kmh\":18.32,\"conditions\":\"Rain\",\"icon\":\"04n\"}', '2026-06-14 11:17:28'),
(2631, 22, '2026-06-15', 'tomorrow', 27.11, 34.62, 76, 4.11, 29.34, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.11,\"temp_max\":34.62,\"humidity\":76,\"rainfall_mm\":4.11,\"wind_speed_kmh\":29.34,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:28'),
(2632, 22, '2026-06-16', 'day_3', 27.28, 33.90, 77, 0.95, 21.64, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.28,\"temp_max\":33.9,\"humidity\":77,\"rainfall_mm\":0.95,\"wind_speed_kmh\":21.64,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:28'),
(2633, 22, '2026-06-17', 'day_4', 27.58, 34.15, 74, 1.73, 26.06, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.58,\"temp_max\":34.15,\"humidity\":74,\"rainfall_mm\":1.73,\"wind_speed_kmh\":26.06,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:28'),
(2634, 22, '2026-06-18', 'day_5', 27.80, 33.65, 75, 1.41, 28.94, 'Rain', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.8,\"temp_max\":33.65,\"humidity\":75,\"rainfall_mm\":1.41,\"wind_speed_kmh\":28.94,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:28'),
(2635, 24, '2026-06-14', 'current', 31.42, 31.42, 68, 1.35, 16.78, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":31.42,\"temp_max\":31.42,\"humidity\":68,\"rainfall_mm\":1.35,\"wind_speed_kmh\":16.78,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:28'),
(2636, 24, '2026-06-14', 'today', 28.21, 31.42, 77, 3.02, 16.78, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.21,\"temp_max\":31.42,\"humidity\":77,\"rainfall_mm\":3.02,\"wind_speed_kmh\":16.78,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:28'),
(2637, 24, '2026-06-15', 'tomorrow', 28.25, 34.70, 72, 1.26, 21.46, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.25,\"temp_max\":34.7,\"humidity\":72,\"rainfall_mm\":1.26,\"wind_speed_kmh\":21.46,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:28'),
(2638, 24, '2026-06-16', 'day_3', 27.72, 34.01, 73, 0.28, 22.25, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.72,\"temp_max\":34.01,\"humidity\":73,\"rainfall_mm\":0.28,\"wind_speed_kmh\":22.25,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:28'),
(2639, 24, '2026-06-17', 'day_4', 28.00, 33.13, 73, 0.31, 24.05, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28,\"temp_max\":33.13,\"humidity\":73,\"rainfall_mm\":0.31,\"wind_speed_kmh\":24.05,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:28'),
(2640, 24, '2026-06-18', 'day_5', 28.23, 34.12, 72, 0.78, 25.85, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.23,\"temp_max\":34.12,\"humidity\":72,\"rainfall_mm\":0.78,\"wind_speed_kmh\":25.85,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:28'),
(2641, 25, '2026-06-14', 'current', 34.44, 34.44, 55, 0.00, 15.59, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":34.44,\"temp_max\":34.44,\"humidity\":55,\"rainfall_mm\":0,\"wind_speed_kmh\":15.59,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:28'),
(2642, 25, '2026-06-14', 'today', 28.76, 34.44, 67, 0.90, 17.03, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.76,\"temp_max\":34.44,\"humidity\":67,\"rainfall_mm\":0.9,\"wind_speed_kmh\":17.03,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-14 11:17:28'),
(2643, 25, '2026-06-15', 'tomorrow', 28.41, 38.13, 66, 0.00, 26.57, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.41,\"temp_max\":38.13,\"humidity\":66,\"rainfall_mm\":0,\"wind_speed_kmh\":26.57,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:28'),
(2644, 25, '2026-06-16', 'day_3', 28.43, 37.41, 65, 0.00, 29.95, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.43,\"temp_max\":37.41,\"humidity\":65,\"rainfall_mm\":0,\"wind_speed_kmh\":29.95,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:28'),
(2645, 25, '2026-06-17', 'day_4', 28.81, 38.49, 62, 0.00, 27.22, 'Clear', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.81,\"temp_max\":38.49,\"humidity\":62,\"rainfall_mm\":0,\"wind_speed_kmh\":27.22,\"conditions\":\"Clear\",\"icon\":\"03d\"}', '2026-06-14 11:17:28'),
(2646, 25, '2026-06-18', 'day_5', 29.10, 38.63, 64, 0.00, 30.24, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":29.1,\"temp_max\":38.63,\"humidity\":64,\"rainfall_mm\":0,\"wind_speed_kmh\":30.24,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:28'),
(2647, 26, '2026-06-14', 'current', 32.88, 32.88, 61, 0.00, 20.38, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":32.88,\"temp_max\":32.88,\"humidity\":61,\"rainfall_mm\":0,\"wind_speed_kmh\":20.38,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:29'),
(2648, 26, '2026-06-14', 'today', 28.23, 32.88, 69, 0.00, 23.44, 'Clouds', '02n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.23,\"temp_max\":32.88,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":23.44,\"conditions\":\"Clouds\",\"icon\":\"02n\"}', '2026-06-14 11:17:29'),
(2649, 26, '2026-06-15', 'tomorrow', 27.65, 39.02, 63, 1.10, 26.68, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.65,\"temp_max\":39.02,\"humidity\":63,\"rainfall_mm\":1.1,\"wind_speed_kmh\":26.68,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:29'),
(2650, 26, '2026-06-16', 'day_3', 27.26, 34.10, 66, 0.35, 24.48, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.26,\"temp_max\":34.1,\"humidity\":66,\"rainfall_mm\":0.35,\"wind_speed_kmh\":24.48,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:29'),
(2651, 26, '2026-06-17', 'day_4', 28.40, 36.45, 64, 0.87, 25.67, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.4,\"temp_max\":36.45,\"humidity\":64,\"rainfall_mm\":0.87,\"wind_speed_kmh\":25.67,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:29'),
(2652, 26, '2026-06-18', 'day_5', 28.33, 36.02, 67, 0.87, 29.95, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.33,\"temp_max\":36.02,\"humidity\":67,\"rainfall_mm\":0.87,\"wind_speed_kmh\":29.95,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:29'),
(2653, 27, '2026-06-14', 'current', 26.58, 26.58, 92, 1.71, 6.84, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":26.58,\"temp_max\":26.58,\"humidity\":92,\"rainfall_mm\":1.71,\"wind_speed_kmh\":6.84,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:29'),
(2654, 27, '2026-06-14', 'today', 24.16, 26.58, 95, 5.78, 8.24, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":24.16,\"temp_max\":26.58,\"humidity\":95,\"rainfall_mm\":5.78,\"wind_speed_kmh\":8.24,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:29'),
(2655, 27, '2026-06-15', 'tomorrow', 23.92, 31.69, 83, 2.69, 8.10, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":23.92,\"temp_max\":31.69,\"humidity\":83,\"rainfall_mm\":2.69,\"wind_speed_kmh\":8.1,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:29'),
(2656, 27, '2026-06-16', 'day_3', 24.00, 32.66, 77, 0.00, 9.79, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":24,\"temp_max\":32.66,\"humidity\":77,\"rainfall_mm\":0,\"wind_speed_kmh\":9.79,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:29'),
(2657, 27, '2026-06-17', 'day_4', 24.66, 34.84, 75, 0.00, 11.02, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":24.66,\"temp_max\":34.84,\"humidity\":75,\"rainfall_mm\":0,\"wind_speed_kmh\":11.02,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:29'),
(2658, 27, '2026-06-18', 'day_5', 25.03, 33.46, 73, 0.00, 12.56, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":25.03,\"temp_max\":33.46,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":12.56,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:29'),
(2659, 28, '2026-06-14', 'current', 31.49, 31.49, 68, 0.46, 19.19, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":31.49,\"temp_max\":31.49,\"humidity\":68,\"rainfall_mm\":0.46,\"wind_speed_kmh\":19.19,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:29'),
(2660, 28, '2026-06-14', 'today', 27.92, 31.49, 76, 1.08, 19.19, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.92,\"temp_max\":31.49,\"humidity\":76,\"rainfall_mm\":1.08,\"wind_speed_kmh\":19.19,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:29'),
(2661, 28, '2026-06-15', 'tomorrow', 27.92, 36.66, 69, 0.00, 24.05, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.92,\"temp_max\":36.66,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":24.05,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:29'),
(2662, 28, '2026-06-16', 'day_3', 28.48, 36.97, 67, 0.00, 26.78, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.48,\"temp_max\":36.97,\"humidity\":67,\"rainfall_mm\":0,\"wind_speed_kmh\":26.78,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:29'),
(2663, 28, '2026-06-17', 'day_4', 28.60, 36.99, 65, 0.00, 27.83, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.6,\"temp_max\":36.99,\"humidity\":65,\"rainfall_mm\":0,\"wind_speed_kmh\":27.83,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:29'),
(2664, 28, '2026-06-18', 'day_5', 28.63, 36.94, 67, 0.16, 29.16, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.63,\"temp_max\":36.94,\"humidity\":67,\"rainfall_mm\":0.16,\"wind_speed_kmh\":29.16,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:29'),
(2665, 29, '2026-06-14', 'current', 29.66, 29.66, 77, 2.33, 7.45, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":29.66,\"temp_max\":29.66,\"humidity\":77,\"rainfall_mm\":2.33,\"wind_speed_kmh\":7.45,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:30'),
(2666, 29, '2026-06-14', 'today', 26.54, 29.66, 84, 4.08, 16.92, 'Rain', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":26.54,\"temp_max\":29.66,\"humidity\":84,\"rainfall_mm\":4.08,\"wind_speed_kmh\":16.92,\"conditions\":\"Rain\",\"icon\":\"04n\"}', '2026-06-14 11:17:30'),
(2667, 29, '2026-06-15', 'tomorrow', 26.53, 33.56, 79, 11.01, 27.40, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.53,\"temp_max\":33.56,\"humidity\":79,\"rainfall_mm\":11.01,\"wind_speed_kmh\":27.4,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:30'),
(2668, 29, '2026-06-16', 'day_3', 26.65, 33.74, 78, 4.48, 22.32, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":26.65,\"temp_max\":33.74,\"humidity\":78,\"rainfall_mm\":4.48,\"wind_speed_kmh\":22.32,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:30'),
(2669, 29, '2026-06-17', 'day_4', 26.64, 33.16, 77, 4.77, 23.00, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":26.64,\"temp_max\":33.16,\"humidity\":77,\"rainfall_mm\":4.77,\"wind_speed_kmh\":23,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:30'),
(2670, 29, '2026-06-18', 'day_5', 27.09, 33.42, 78, 5.16, 26.28, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.09,\"temp_max\":33.42,\"humidity\":78,\"rainfall_mm\":5.16,\"wind_speed_kmh\":26.28,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:30'),
(2671, 30, '2026-06-14', 'current', 30.97, 30.97, 75, 0.39, 12.17, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.97,\"temp_max\":30.97,\"humidity\":75,\"rainfall_mm\":0.39,\"wind_speed_kmh\":12.17,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:30'),
(2672, 30, '2026-06-14', 'today', 25.96, 30.97, 82, 5.32, 24.01, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":25.96,\"temp_max\":30.97,\"humidity\":82,\"rainfall_mm\":5.32,\"wind_speed_kmh\":24.01,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:30'),
(2673, 30, '2026-06-15', 'tomorrow', 26.16, 33.05, 80, 8.33, 24.73, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.16,\"temp_max\":33.05,\"humidity\":80,\"rainfall_mm\":8.33,\"wind_speed_kmh\":24.73,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:30'),
(2674, 30, '2026-06-16', 'day_3', 25.91, 32.81, 83, 21.91, 22.75, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":25.91,\"temp_max\":32.81,\"humidity\":83,\"rainfall_mm\":21.91,\"wind_speed_kmh\":22.75,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:30'),
(2675, 30, '2026-06-17', 'day_4', 25.56, 32.06, 86, 35.56, 31.07, 'Rain', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":25.56,\"temp_max\":32.06,\"humidity\":86,\"rainfall_mm\":35.56,\"wind_speed_kmh\":31.07,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:30'),
(2676, 30, '2026-06-18', 'day_5', 25.95, 31.83, 86, 48.99, 24.66, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":25.95,\"temp_max\":31.83,\"humidity\":86,\"rainfall_mm\":48.99,\"wind_speed_kmh\":24.66,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:30'),
(2677, 31, '2026-06-14', 'current', 34.44, 34.44, 48, 0.12, 8.14, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":34.44,\"temp_max\":34.44,\"humidity\":48,\"rainfall_mm\":0.12,\"wind_speed_kmh\":8.14,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:30'),
(2678, 31, '2026-06-14', 'today', 28.61, 34.44, 61, 0.12, 18.18, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.61,\"temp_max\":34.44,\"humidity\":61,\"rainfall_mm\":0.12,\"wind_speed_kmh\":18.18,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-14 11:17:30'),
(2679, 31, '2026-06-15', 'tomorrow', 28.75, 39.70, 60, 0.00, 28.84, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.75,\"temp_max\":39.7,\"humidity\":60,\"rainfall_mm\":0,\"wind_speed_kmh\":28.84,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:30'),
(2680, 31, '2026-06-16', 'day_3', 28.70, 40.15, 61, 0.00, 29.81, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.7,\"temp_max\":40.15,\"humidity\":61,\"rainfall_mm\":0,\"wind_speed_kmh\":29.81,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:30');
INSERT INTO `weather_forecasts` (`forecast_id`, `district_id`, `forecast_date`, `forecast_for`, `temp_min`, `temp_max`, `humidity`, `rainfall_mm`, `wind_speed_kmh`, `conditions`, `icon`, `raw_payload`, `fetched_at`) VALUES
(2681, 31, '2026-06-17', 'day_4', 28.77, 40.05, 59, 0.00, 29.52, 'Clear', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.77,\"temp_max\":40.05,\"humidity\":59,\"rainfall_mm\":0,\"wind_speed_kmh\":29.52,\"conditions\":\"Clear\",\"icon\":\"03d\"}', '2026-06-14 11:17:30'),
(2682, 31, '2026-06-18', 'day_5', 29.15, 40.18, 61, 0.00, 34.31, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":29.15,\"temp_max\":40.18,\"humidity\":61,\"rainfall_mm\":0,\"wind_speed_kmh\":34.31,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:30'),
(2683, 32, '2026-06-14', 'current', 29.52, 29.52, 80, 1.05, 21.78, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":29.52,\"temp_max\":29.52,\"humidity\":80,\"rainfall_mm\":1.05,\"wind_speed_kmh\":21.78,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:31'),
(2684, 32, '2026-06-14', 'today', 28.29, 29.52, 83, 7.94, 21.78, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.29,\"temp_max\":29.52,\"humidity\":83,\"rainfall_mm\":7.94,\"wind_speed_kmh\":21.78,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:31'),
(2685, 32, '2026-06-15', 'tomorrow', 28.21, 32.27, 78, 1.66, 24.98, 'Rain', '02d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.21,\"temp_max\":32.27,\"humidity\":78,\"rainfall_mm\":1.66,\"wind_speed_kmh\":24.98,\"conditions\":\"Rain\",\"icon\":\"02d\"}', '2026-06-14 11:17:31'),
(2686, 32, '2026-06-16', 'day_3', 28.12, 31.99, 77, 0.35, 24.62, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.12,\"temp_max\":31.99,\"humidity\":77,\"rainfall_mm\":0.35,\"wind_speed_kmh\":24.62,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:31'),
(2687, 32, '2026-06-17', 'day_4', 28.22, 31.55, 77, 0.12, 26.68, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.22,\"temp_max\":31.55,\"humidity\":77,\"rainfall_mm\":0.12,\"wind_speed_kmh\":26.68,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:31'),
(2688, 32, '2026-06-18', 'day_5', 28.43, 31.83, 77, 1.51, 28.94, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.43,\"temp_max\":31.83,\"humidity\":77,\"rainfall_mm\":1.51,\"wind_speed_kmh\":28.94,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:31'),
(2689, 33, '2026-06-14', 'current', 30.23, 30.23, 76, 0.49, 9.83, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.23,\"temp_max\":30.23,\"humidity\":76,\"rainfall_mm\":0.49,\"wind_speed_kmh\":9.83,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:31'),
(2690, 33, '2026-06-14', 'today', 25.30, 30.23, 83, 6.38, 19.62, 'Rain', '03n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":25.3,\"temp_max\":30.23,\"humidity\":83,\"rainfall_mm\":6.38,\"wind_speed_kmh\":19.62,\"conditions\":\"Rain\",\"icon\":\"03n\"}', '2026-06-14 11:17:31'),
(2691, 33, '2026-06-15', 'tomorrow', 25.55, 33.55, 81, 14.55, 19.98, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.55,\"temp_max\":33.55,\"humidity\":81,\"rainfall_mm\":14.55,\"wind_speed_kmh\":19.98,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:31'),
(2692, 33, '2026-06-16', 'day_3', 25.68, 32.61, 84, 43.29, 17.35, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":25.68,\"temp_max\":32.61,\"humidity\":84,\"rainfall_mm\":43.29,\"wind_speed_kmh\":17.35,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:31'),
(2693, 33, '2026-06-17', 'day_4', 25.24, 31.40, 87, 52.88, 25.88, 'Rain', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":25.24,\"temp_max\":31.4,\"humidity\":87,\"rainfall_mm\":52.88,\"wind_speed_kmh\":25.88,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:31'),
(2694, 33, '2026-06-18', 'day_5', 25.45, 30.80, 90, 62.57, 16.92, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":25.45,\"temp_max\":30.8,\"humidity\":90,\"rainfall_mm\":62.57,\"wind_speed_kmh\":16.92,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:31'),
(2695, 34, '2026-06-14', 'current', 29.83, 29.83, 77, 1.57, 14.87, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":29.83,\"temp_max\":29.83,\"humidity\":77,\"rainfall_mm\":1.57,\"wind_speed_kmh\":14.87,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:31'),
(2696, 34, '2026-06-14', 'today', 27.28, 29.83, 82, 4.47, 15.52, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.28,\"temp_max\":29.83,\"humidity\":82,\"rainfall_mm\":4.47,\"wind_speed_kmh\":15.52,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:31'),
(2697, 34, '2026-06-15', 'tomorrow', 27.26, 35.13, 76, 8.65, 23.18, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.26,\"temp_max\":35.13,\"humidity\":76,\"rainfall_mm\":8.65,\"wind_speed_kmh\":23.18,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:31'),
(2698, 34, '2026-06-16', 'day_3', 27.33, 34.69, 74, 1.63, 23.72, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.33,\"temp_max\":34.69,\"humidity\":74,\"rainfall_mm\":1.63,\"wind_speed_kmh\":23.72,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:31'),
(2699, 34, '2026-06-17', 'day_4', 27.03, 35.36, 73, 0.19, 26.39, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.03,\"temp_max\":35.36,\"humidity\":73,\"rainfall_mm\":0.19,\"wind_speed_kmh\":26.39,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:31'),
(2700, 34, '2026-06-18', 'day_5', 27.59, 35.37, 72, 0.17, 28.26, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.59,\"temp_max\":35.37,\"humidity\":72,\"rainfall_mm\":0.17,\"wind_speed_kmh\":28.26,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:31'),
(2701, 35, '2026-06-14', 'current', 34.15, 34.15, 56, 0.00, 16.02, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":34.15,\"temp_max\":34.15,\"humidity\":56,\"rainfall_mm\":0,\"wind_speed_kmh\":16.02,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:32'),
(2702, 35, '2026-06-14', 'today', 28.52, 34.15, 68, 0.60, 18.94, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.52,\"temp_max\":34.15,\"humidity\":68,\"rainfall_mm\":0.6,\"wind_speed_kmh\":18.94,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-14 11:17:32'),
(2703, 35, '2026-06-15', 'tomorrow', 28.35, 37.56, 66, 0.00, 26.03, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.35,\"temp_max\":37.56,\"humidity\":66,\"rainfall_mm\":0,\"wind_speed_kmh\":26.03,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:32'),
(2704, 35, '2026-06-16', 'day_3', 28.34, 37.36, 65, 0.00, 29.05, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.34,\"temp_max\":37.36,\"humidity\":65,\"rainfall_mm\":0,\"wind_speed_kmh\":29.05,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:32'),
(2705, 35, '2026-06-17', 'day_4', 28.58, 38.78, 63, 0.00, 30.60, 'Clear', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.58,\"temp_max\":38.78,\"humidity\":63,\"rainfall_mm\":0,\"wind_speed_kmh\":30.6,\"conditions\":\"Clear\",\"icon\":\"03d\"}', '2026-06-14 11:17:32'),
(2706, 35, '2026-06-18', 'day_5', 28.92, 38.81, 64, 0.00, 31.18, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.92,\"temp_max\":38.81,\"humidity\":64,\"rainfall_mm\":0,\"wind_speed_kmh\":31.18,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:32'),
(2707, 36, '2026-06-14', 'current', 31.04, 31.04, 71, 0.00, 7.13, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":31.04,\"temp_max\":31.04,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":7.13,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:32'),
(2708, 36, '2026-06-14', 'today', 27.44, 31.04, 77, 1.97, 22.79, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.44,\"temp_max\":31.04,\"humidity\":77,\"rainfall_mm\":1.97,\"wind_speed_kmh\":22.79,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-14 11:17:32'),
(2709, 36, '2026-06-15', 'tomorrow', 27.09, 36.27, 73, 1.40, 21.60, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.09,\"temp_max\":36.27,\"humidity\":73,\"rainfall_mm\":1.4,\"wind_speed_kmh\":21.6,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:32'),
(2710, 36, '2026-06-16', 'day_3', 27.66, 35.26, 74, 0.00, 27.22, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.66,\"temp_max\":35.26,\"humidity\":74,\"rainfall_mm\":0,\"wind_speed_kmh\":27.22,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:32'),
(2711, 36, '2026-06-17', 'day_4', 27.47, 34.19, 73, 0.32, 29.38, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.47,\"temp_max\":34.19,\"humidity\":73,\"rainfall_mm\":0.32,\"wind_speed_kmh\":29.38,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:32'),
(2712, 36, '2026-06-18', 'day_5', 27.80, 35.12, 73, 0.28, 31.50, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.8,\"temp_max\":35.12,\"humidity\":73,\"rainfall_mm\":0.28,\"wind_speed_kmh\":31.5,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:32'),
(2713, 37, '2026-06-14', 'current', 33.66, 33.66, 54, 0.00, 11.23, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":33.66,\"temp_max\":33.66,\"humidity\":54,\"rainfall_mm\":0,\"wind_speed_kmh\":11.23,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:32'),
(2714, 37, '2026-06-14', 'today', 27.90, 33.66, 65, 0.44, 18.11, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.9,\"temp_max\":33.66,\"humidity\":65,\"rainfall_mm\":0.44,\"wind_speed_kmh\":18.11,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-14 11:17:32'),
(2715, 37, '2026-06-15', 'tomorrow', 28.29, 38.22, 62, 0.36, 30.38, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.29,\"temp_max\":38.22,\"humidity\":62,\"rainfall_mm\":0.36,\"wind_speed_kmh\":30.38,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:32'),
(2716, 37, '2026-06-16', 'day_3', 28.40, 39.20, 62, 0.00, 27.22, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.4,\"temp_max\":39.2,\"humidity\":62,\"rainfall_mm\":0,\"wind_speed_kmh\":27.22,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:32'),
(2717, 37, '2026-06-17', 'day_4', 28.72, 39.77, 59, 0.26, 30.53, 'Clear', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.72,\"temp_max\":39.77,\"humidity\":59,\"rainfall_mm\":0.26,\"wind_speed_kmh\":30.53,\"conditions\":\"Clear\",\"icon\":\"03d\"}', '2026-06-14 11:17:32'),
(2718, 37, '2026-06-18', 'day_5', 29.12, 39.69, 61, 0.00, 34.88, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":29.12,\"temp_max\":39.69,\"humidity\":61,\"rainfall_mm\":0,\"wind_speed_kmh\":34.88,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:32'),
(2719, 38, '2026-06-14', 'current', 28.03, 28.03, 85, 6.72, 10.37, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":28.03,\"temp_max\":28.03,\"humidity\":85,\"rainfall_mm\":6.72,\"wind_speed_kmh\":10.37,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:33'),
(2720, 38, '2026-06-14', 'today', 24.85, 28.03, 90, 11.63, 10.37, 'Rain', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":24.85,\"temp_max\":28.03,\"humidity\":90,\"rainfall_mm\":11.63,\"wind_speed_kmh\":10.37,\"conditions\":\"Rain\",\"icon\":\"04n\"}', '2026-06-14 11:17:33'),
(2721, 38, '2026-06-15', 'tomorrow', 24.43, 29.87, 89, 13.13, 11.20, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.43,\"temp_max\":29.87,\"humidity\":89,\"rainfall_mm\":13.13,\"wind_speed_kmh\":11.2,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:33'),
(2722, 38, '2026-06-16', 'day_3', 24.91, 32.66, 83, 11.75, 13.28, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":24.91,\"temp_max\":32.66,\"humidity\":83,\"rainfall_mm\":11.75,\"wind_speed_kmh\":13.28,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:33'),
(2723, 38, '2026-06-17', 'day_4', 25.10, 32.93, 82, 7.55, 13.21, 'Rain', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":25.1,\"temp_max\":32.93,\"humidity\":82,\"rainfall_mm\":7.55,\"wind_speed_kmh\":13.21,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:33'),
(2724, 38, '2026-06-18', 'day_5', 25.30, 32.41, 83, 16.17, 15.44, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":25.3,\"temp_max\":32.41,\"humidity\":83,\"rainfall_mm\":16.17,\"wind_speed_kmh\":15.44,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:33'),
(2725, 39, '2026-06-14', 'current', 30.25, 30.25, 74, 0.86, 19.40, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.25,\"temp_max\":30.25,\"humidity\":74,\"rainfall_mm\":0.86,\"wind_speed_kmh\":19.4,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:33'),
(2726, 39, '2026-06-14', 'today', 27.92, 30.25, 78, 1.73, 19.40, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.92,\"temp_max\":30.25,\"humidity\":78,\"rainfall_mm\":1.73,\"wind_speed_kmh\":19.4,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:33'),
(2727, 39, '2026-06-15', 'tomorrow', 27.76, 35.14, 74, 3.94, 24.48, 'Rain', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.76,\"temp_max\":35.14,\"humidity\":74,\"rainfall_mm\":3.94,\"wind_speed_kmh\":24.48,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-14 11:17:33'),
(2728, 39, '2026-06-16', 'day_3', 27.63, 34.41, 73, 1.16, 26.10, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.63,\"temp_max\":34.41,\"humidity\":73,\"rainfall_mm\":1.16,\"wind_speed_kmh\":26.1,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:33'),
(2729, 39, '2026-06-17', 'day_4', 27.79, 34.43, 72, 0.00, 26.10, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.79,\"temp_max\":34.43,\"humidity\":72,\"rainfall_mm\":0,\"wind_speed_kmh\":26.1,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:33'),
(2730, 39, '2026-06-18', 'day_5', 28.10, 34.15, 72, 0.29, 28.30, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.1,\"temp_max\":34.15,\"humidity\":72,\"rainfall_mm\":0.29,\"wind_speed_kmh\":28.3,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:33'),
(2731, 40, '2026-06-14', 'current', 28.68, 28.68, 83, 5.23, 0.86, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":28.68,\"temp_max\":28.68,\"humidity\":83,\"rainfall_mm\":5.23,\"wind_speed_kmh\":0.86,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:33'),
(2732, 40, '2026-06-14', 'today', 25.38, 28.68, 88, 8.64, 14.26, 'Rain', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":25.38,\"temp_max\":28.68,\"humidity\":88,\"rainfall_mm\":8.64,\"wind_speed_kmh\":14.26,\"conditions\":\"Rain\",\"icon\":\"04n\"}', '2026-06-14 11:17:33'),
(2733, 40, '2026-06-15', 'tomorrow', 25.73, 32.51, 81, 9.67, 19.76, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.73,\"temp_max\":32.51,\"humidity\":81,\"rainfall_mm\":9.67,\"wind_speed_kmh\":19.76,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:33'),
(2734, 40, '2026-06-16', 'day_3', 25.26, 33.11, 81, 9.27, 18.58, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":25.26,\"temp_max\":33.11,\"humidity\":81,\"rainfall_mm\":9.27,\"wind_speed_kmh\":18.58,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:33'),
(2735, 40, '2026-06-17', 'day_4', 25.51, 32.74, 81, 11.64, 19.22, 'Rain', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":25.51,\"temp_max\":32.74,\"humidity\":81,\"rainfall_mm\":11.64,\"wind_speed_kmh\":19.22,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:33'),
(2736, 40, '2026-06-18', 'day_5', 26.28, 32.92, 81, 15.78, 22.28, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":26.28,\"temp_max\":32.92,\"humidity\":81,\"rainfall_mm\":15.78,\"wind_speed_kmh\":22.28,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:33'),
(2737, 41, '2026-06-14', 'current', 33.90, 33.90, 52, 0.00, 22.03, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":33.9,\"temp_max\":33.9,\"humidity\":52,\"rainfall_mm\":0,\"wind_speed_kmh\":22.03,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:34'),
(2738, 41, '2026-06-14', 'today', 29.07, 33.90, 62, 0.00, 22.03, 'Clouds', '03n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":29.07,\"temp_max\":33.9,\"humidity\":62,\"rainfall_mm\":0,\"wind_speed_kmh\":22.03,\"conditions\":\"Clouds\",\"icon\":\"03n\"}', '2026-06-14 11:17:34'),
(2739, 41, '2026-06-15', 'tomorrow', 28.20, 40.56, 58, 1.12, 31.18, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.2,\"temp_max\":40.56,\"humidity\":58,\"rainfall_mm\":1.12,\"wind_speed_kmh\":31.18,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:34'),
(2740, 41, '2026-06-16', 'day_3', 28.43, 38.53, 60, 0.00, 29.30, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.43,\"temp_max\":38.53,\"humidity\":60,\"rainfall_mm\":0,\"wind_speed_kmh\":29.3,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:34'),
(2741, 41, '2026-06-17', 'day_4', 29.09, 39.29, 59, 0.41, 28.66, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":29.09,\"temp_max\":39.29,\"humidity\":59,\"rainfall_mm\":0.41,\"wind_speed_kmh\":28.66,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:34'),
(2742, 41, '2026-06-18', 'day_5', 28.91, 38.99, 63, 2.72, 27.94, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.91,\"temp_max\":38.99,\"humidity\":63,\"rainfall_mm\":2.72,\"wind_speed_kmh\":27.94,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:34'),
(2743, 42, '2026-06-14', 'current', 31.03, 31.03, 69, 0.00, 18.72, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":31.03,\"temp_max\":31.03,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":18.72,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:34'),
(2744, 42, '2026-06-14', 'today', 27.88, 31.03, 76, 0.75, 20.27, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.88,\"temp_max\":31.03,\"humidity\":76,\"rainfall_mm\":0.75,\"wind_speed_kmh\":20.27,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-14 11:17:34'),
(2745, 42, '2026-06-15', 'tomorrow', 27.49, 36.95, 74, 8.39, 22.75, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.49,\"temp_max\":36.95,\"humidity\":74,\"rainfall_mm\":8.39,\"wind_speed_kmh\":22.75,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:34'),
(2746, 42, '2026-06-16', 'day_3', 27.48, 36.26, 71, 0.00, 26.57, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.48,\"temp_max\":36.26,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":26.57,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:34'),
(2747, 42, '2026-06-17', 'day_4', 27.87, 36.64, 68, 0.00, 30.71, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.87,\"temp_max\":36.64,\"humidity\":68,\"rainfall_mm\":0,\"wind_speed_kmh\":30.71,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:34'),
(2748, 42, '2026-06-18', 'day_5', 28.08, 38.10, 68, 0.27, 28.51, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.08,\"temp_max\":38.1,\"humidity\":68,\"rainfall_mm\":0.27,\"wind_speed_kmh\":28.51,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:34'),
(2749, 43, '2026-06-14', 'current', 30.73, 30.73, 71, 0.85, 20.52, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.73,\"temp_max\":30.73,\"humidity\":71,\"rainfall_mm\":0.85,\"wind_speed_kmh\":20.52,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:34'),
(2750, 43, '2026-06-14', 'today', 28.09, 30.73, 76, 1.57, 20.52, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.09,\"temp_max\":30.73,\"humidity\":76,\"rainfall_mm\":1.57,\"wind_speed_kmh\":20.52,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:34'),
(2751, 43, '2026-06-15', 'tomorrow', 27.87, 35.21, 73, 5.10, 25.09, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.87,\"temp_max\":35.21,\"humidity\":73,\"rainfall_mm\":5.1,\"wind_speed_kmh\":25.09,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:34'),
(2752, 43, '2026-06-16', 'day_3', 27.64, 34.43, 72, 0.67, 25.99, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.64,\"temp_max\":34.43,\"humidity\":72,\"rainfall_mm\":0.67,\"wind_speed_kmh\":25.99,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:34'),
(2753, 43, '2026-06-17', 'day_4', 27.93, 34.43, 71, 0.00, 25.78, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.93,\"temp_max\":34.43,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":25.78,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:34'),
(2754, 43, '2026-06-18', 'day_5', 28.16, 34.24, 71, 0.31, 27.79, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.16,\"temp_max\":34.24,\"humidity\":71,\"rainfall_mm\":0.31,\"wind_speed_kmh\":27.79,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:34'),
(2755, 44, '2026-06-14', 'current', 30.25, 30.25, 74, 0.86, 19.40, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.25,\"temp_max\":30.25,\"humidity\":74,\"rainfall_mm\":0.86,\"wind_speed_kmh\":19.4,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:35'),
(2756, 44, '2026-06-14', 'today', 27.92, 30.25, 78, 1.73, 19.40, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.92,\"temp_max\":30.25,\"humidity\":78,\"rainfall_mm\":1.73,\"wind_speed_kmh\":19.4,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:35'),
(2757, 44, '2026-06-15', 'tomorrow', 27.76, 35.14, 74, 3.94, 24.48, 'Rain', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.76,\"temp_max\":35.14,\"humidity\":74,\"rainfall_mm\":3.94,\"wind_speed_kmh\":24.48,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-14 11:17:35'),
(2758, 44, '2026-06-16', 'day_3', 27.63, 34.41, 73, 1.16, 26.10, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.63,\"temp_max\":34.41,\"humidity\":73,\"rainfall_mm\":1.16,\"wind_speed_kmh\":26.1,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:35'),
(2759, 44, '2026-06-17', 'day_4', 27.79, 34.43, 72, 0.00, 26.10, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.79,\"temp_max\":34.43,\"humidity\":72,\"rainfall_mm\":0,\"wind_speed_kmh\":26.1,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:35'),
(2760, 44, '2026-06-18', 'day_5', 28.10, 34.15, 72, 0.29, 28.30, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.1,\"temp_max\":34.15,\"humidity\":72,\"rainfall_mm\":0.29,\"wind_speed_kmh\":28.3,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:35'),
(2761, 45, '2026-06-14', 'current', 33.51, 33.51, 47, 0.00, 15.37, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":33.51,\"temp_max\":33.51,\"humidity\":47,\"rainfall_mm\":0,\"wind_speed_kmh\":15.37,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:35'),
(2762, 45, '2026-06-14', 'today', 29.13, 33.51, 57, 0.00, 21.20, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":29.13,\"temp_max\":33.51,\"humidity\":57,\"rainfall_mm\":0,\"wind_speed_kmh\":21.2,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-14 11:17:35'),
(2763, 45, '2026-06-15', 'tomorrow', 28.64, 41.26, 53, 0.32, 33.88, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.64,\"temp_max\":41.26,\"humidity\":53,\"rainfall_mm\":0.32,\"wind_speed_kmh\":33.88,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-14 11:17:35'),
(2764, 45, '2026-06-16', 'day_3', 28.91, 40.74, 54, 0.32, 22.97, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.91,\"temp_max\":40.74,\"humidity\":54,\"rainfall_mm\":0.32,\"wind_speed_kmh\":22.97,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:35'),
(2765, 45, '2026-06-17', 'day_4', 28.14, 40.81, 59, 5.25, 26.75, 'Clear', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.14,\"temp_max\":40.81,\"humidity\":59,\"rainfall_mm\":5.25,\"wind_speed_kmh\":26.75,\"conditions\":\"Clear\",\"icon\":\"03d\"}', '2026-06-14 11:17:35'),
(2766, 45, '2026-06-18', 'day_5', 27.99, 39.81, 63, 6.12, 25.20, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.99,\"temp_max\":39.81,\"humidity\":63,\"rainfall_mm\":6.12,\"wind_speed_kmh\":25.2,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:35'),
(2767, 46, '2026-06-14', 'current', 30.39, 30.39, 75, 2.13, 6.05, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.39,\"temp_max\":30.39,\"humidity\":75,\"rainfall_mm\":2.13,\"wind_speed_kmh\":6.05,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:35'),
(2768, 46, '2026-06-14', 'today', 24.80, 30.39, 85, 12.15, 13.36, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":24.8,\"temp_max\":30.39,\"humidity\":85,\"rainfall_mm\":12.15,\"wind_speed_kmh\":13.36,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:35'),
(2769, 46, '2026-06-15', 'tomorrow', 25.29, 33.17, 81, 13.32, 19.66, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.29,\"temp_max\":33.17,\"humidity\":81,\"rainfall_mm\":13.32,\"wind_speed_kmh\":19.66,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:35'),
(2770, 46, '2026-06-16', 'day_3', 25.20, 32.99, 82, 15.82, 17.82, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":25.2,\"temp_max\":32.99,\"humidity\":82,\"rainfall_mm\":15.82,\"wind_speed_kmh\":17.82,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:35'),
(2771, 46, '2026-06-17', 'day_4', 25.50, 32.27, 82, 21.04, 19.26, 'Rain', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":25.5,\"temp_max\":32.27,\"humidity\":82,\"rainfall_mm\":21.04,\"wind_speed_kmh\":19.26,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:35'),
(2772, 46, '2026-06-18', 'day_5', 25.62, 32.81, 84, 24.25, 19.48, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":25.62,\"temp_max\":32.81,\"humidity\":84,\"rainfall_mm\":24.25,\"wind_speed_kmh\":19.48,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:35'),
(2773, 47, '2026-06-14', 'current', 32.53, 32.53, 63, 0.00, 14.22, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":32.53,\"temp_max\":32.53,\"humidity\":63,\"rainfall_mm\":0,\"wind_speed_kmh\":14.22,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:36'),
(2774, 47, '2026-06-14', 'today', 26.39, 32.53, 74, 3.76, 17.42, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":26.39,\"temp_max\":32.53,\"humidity\":74,\"rainfall_mm\":3.76,\"wind_speed_kmh\":17.42,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-14 11:17:36'),
(2775, 47, '2026-06-15', 'tomorrow', 26.55, 38.19, 71, 2.90, 20.81, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.55,\"temp_max\":38.19,\"humidity\":71,\"rainfall_mm\":2.9,\"wind_speed_kmh\":20.81,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:36'),
(2776, 47, '2026-06-16', 'day_3', 26.33, 34.15, 76, 6.94, 17.96, 'Rain', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":26.33,\"temp_max\":34.15,\"humidity\":76,\"rainfall_mm\":6.94,\"wind_speed_kmh\":17.96,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-14 11:17:36'),
(2777, 47, '2026-06-17', 'day_4', 27.62, 35.02, 75, 1.09, 18.40, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.62,\"temp_max\":35.02,\"humidity\":75,\"rainfall_mm\":1.09,\"wind_speed_kmh\":18.4,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:36'),
(2778, 47, '2026-06-18', 'day_5', 27.27, 34.08, 77, 7.06, 19.33, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.27,\"temp_max\":34.08,\"humidity\":77,\"rainfall_mm\":7.06,\"wind_speed_kmh\":19.33,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:36'),
(2779, 48, '2026-06-14', 'current', 28.78, 28.78, 85, 0.48, 19.30, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":28.78,\"temp_max\":28.78,\"humidity\":85,\"rainfall_mm\":0.48,\"wind_speed_kmh\":19.3,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:36'),
(2780, 48, '2026-06-14', 'today', 28.15, 28.78, 87, 5.59, 24.91, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.15,\"temp_max\":28.78,\"humidity\":87,\"rainfall_mm\":5.59,\"wind_speed_kmh\":24.91,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:36'),
(2781, 48, '2026-06-15', 'tomorrow', 28.03, 30.55, 82, 1.01, 27.22, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.03,\"temp_max\":30.55,\"humidity\":82,\"rainfall_mm\":1.01,\"wind_speed_kmh\":27.22,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:36'),
(2782, 48, '2026-06-16', 'day_3', 28.03, 30.52, 82, 1.07, 26.24, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.03,\"temp_max\":30.52,\"humidity\":82,\"rainfall_mm\":1.07,\"wind_speed_kmh\":26.24,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:36'),
(2783, 48, '2026-06-17', 'day_4', 28.17, 30.80, 80, 0.23, 25.34, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.17,\"temp_max\":30.8,\"humidity\":80,\"rainfall_mm\":0.23,\"wind_speed_kmh\":25.34,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-14 11:17:36'),
(2784, 48, '2026-06-18', 'day_5', 28.12, 30.58, 81, 0.96, 30.35, 'Rain', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.12,\"temp_max\":30.58,\"humidity\":81,\"rainfall_mm\":0.96,\"wind_speed_kmh\":30.35,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:36'),
(2785, 49, '2026-06-14', 'current', 33.55, 33.55, 57, 0.00, 12.71, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":33.55,\"temp_max\":33.55,\"humidity\":57,\"rainfall_mm\":0,\"wind_speed_kmh\":12.71,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:36'),
(2786, 49, '2026-06-14', 'today', 27.57, 33.55, 67, 0.35, 22.28, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.57,\"temp_max\":33.55,\"humidity\":67,\"rainfall_mm\":0.35,\"wind_speed_kmh\":22.28,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-14 11:17:36'),
(2787, 49, '2026-06-15', 'tomorrow', 28.04, 37.20, 67, 1.15, 30.67, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.04,\"temp_max\":37.2,\"humidity\":67,\"rainfall_mm\":1.15,\"wind_speed_kmh\":30.67,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:36'),
(2788, 49, '2026-06-16', 'day_3', 27.70, 37.48, 66, 0.12, 26.86, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.7,\"temp_max\":37.48,\"humidity\":66,\"rainfall_mm\":0.12,\"wind_speed_kmh\":26.86,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:36'),
(2789, 49, '2026-06-17', 'day_4', 28.33, 39.15, 62, 1.13, 31.25, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.33,\"temp_max\":39.15,\"humidity\":62,\"rainfall_mm\":1.13,\"wind_speed_kmh\":31.25,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:36'),
(2790, 49, '2026-06-18', 'day_5', 28.57, 38.86, 63, 0.00, 31.82, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.57,\"temp_max\":38.86,\"humidity\":63,\"rainfall_mm\":0,\"wind_speed_kmh\":31.82,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:36'),
(2791, 50, '2026-06-14', 'current', 30.62, 30.62, 71, 0.00, 15.30, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.62,\"temp_max\":30.62,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":15.3,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:37'),
(2792, 50, '2026-06-14', 'today', 24.47, 30.62, 81, 5.63, 15.30, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":24.47,\"temp_max\":30.62,\"humidity\":81,\"rainfall_mm\":5.63,\"wind_speed_kmh\":15.3,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-14 11:17:37'),
(2793, 50, '2026-06-15', 'tomorrow', 24.46, 35.33, 76, 12.89, 17.68, 'Rain', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.46,\"temp_max\":35.33,\"humidity\":76,\"rainfall_mm\":12.89,\"wind_speed_kmh\":17.68,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-14 11:17:37'),
(2794, 50, '2026-06-16', 'day_3', 24.76, 32.86, 83, 26.73, 16.02, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":24.76,\"temp_max\":32.86,\"humidity\":83,\"rainfall_mm\":26.73,\"wind_speed_kmh\":16.02,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:37'),
(2795, 50, '2026-06-17', 'day_4', 24.86, 32.57, 84, 21.85, 15.95, 'Rain', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":24.86,\"temp_max\":32.57,\"humidity\":84,\"rainfall_mm\":21.85,\"wind_speed_kmh\":15.95,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:37'),
(2796, 50, '2026-06-18', 'day_5', 25.23, 30.93, 88, 36.78, 19.26, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":25.23,\"temp_max\":30.93,\"humidity\":88,\"rainfall_mm\":36.78,\"wind_speed_kmh\":19.26,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:37'),
(2797, 51, '2026-06-14', 'current', 30.56, 30.56, 73, 0.32, 20.23, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":30.56,\"temp_max\":30.56,\"humidity\":73,\"rainfall_mm\":0.32,\"wind_speed_kmh\":20.23,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:37'),
(2798, 51, '2026-06-14', 'today', 29.07, 30.56, 79, 3.35, 20.30, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":29.07,\"temp_max\":30.56,\"humidity\":79,\"rainfall_mm\":3.35,\"wind_speed_kmh\":20.3,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:37'),
(2799, 51, '2026-06-15', 'tomorrow', 29.09, 32.26, 78, 1.23, 23.08, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":29.09,\"temp_max\":32.26,\"humidity\":78,\"rainfall_mm\":1.23,\"wind_speed_kmh\":23.08,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:37'),
(2800, 51, '2026-06-16', 'day_3', 28.74, 32.10, 78, 1.01, 27.04, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.74,\"temp_max\":32.1,\"humidity\":78,\"rainfall_mm\":1.01,\"wind_speed_kmh\":27.04,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:37'),
(2801, 51, '2026-06-17', 'day_4', 28.80, 32.10, 78, 0.85, 28.55, 'Rain', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.8,\"temp_max\":32.1,\"humidity\":78,\"rainfall_mm\":0.85,\"wind_speed_kmh\":28.55,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:37'),
(2802, 51, '2026-06-18', 'day_5', 28.83, 31.57, 78, 1.55, 29.99, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.83,\"temp_max\":31.57,\"humidity\":78,\"rainfall_mm\":1.55,\"wind_speed_kmh\":29.99,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:37'),
(2803, 52, '2026-06-14', 'current', 31.38, 31.38, 69, 2.08, 15.30, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":31.38,\"temp_max\":31.38,\"humidity\":69,\"rainfall_mm\":2.08,\"wind_speed_kmh\":15.3,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:37'),
(2804, 52, '2026-06-14', 'today', 27.85, 31.38, 78, 3.20, 16.02, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.85,\"temp_max\":31.38,\"humidity\":78,\"rainfall_mm\":3.2,\"wind_speed_kmh\":16.02,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:37'),
(2805, 52, '2026-06-15', 'tomorrow', 28.10, 35.33, 72, 0.15, 22.61, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.1,\"temp_max\":35.33,\"humidity\":72,\"rainfall_mm\":0.15,\"wind_speed_kmh\":22.61,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:37'),
(2806, 52, '2026-06-16', 'day_3', 27.94, 34.56, 73, 0.16, 23.80, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.94,\"temp_max\":34.56,\"humidity\":73,\"rainfall_mm\":0.16,\"wind_speed_kmh\":23.8,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:37'),
(2807, 52, '2026-06-17', 'day_4', 28.05, 33.95, 72, 0.16, 24.41, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.05,\"temp_max\":33.95,\"humidity\":72,\"rainfall_mm\":0.16,\"wind_speed_kmh\":24.41,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:37'),
(2808, 52, '2026-06-18', 'day_5', 28.30, 34.53, 72, 0.41, 24.84, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.3,\"temp_max\":34.53,\"humidity\":72,\"rainfall_mm\":0.41,\"wind_speed_kmh\":24.84,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:37'),
(2809, 53, '2026-06-14', 'current', 31.34, 31.34, 69, 0.43, 19.84, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":31.34,\"temp_max\":31.34,\"humidity\":69,\"rainfall_mm\":0.43,\"wind_speed_kmh\":19.84,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:38'),
(2810, 53, '2026-06-14', 'today', 28.03, 31.34, 76, 0.99, 20.45, 'Rain', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.03,\"temp_max\":31.34,\"humidity\":76,\"rainfall_mm\":0.99,\"wind_speed_kmh\":20.45,\"conditions\":\"Rain\",\"icon\":\"04n\"}', '2026-06-14 11:17:38'),
(2811, 53, '2026-06-15', 'tomorrow', 27.45, 36.42, 75, 5.76, 26.53, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.45,\"temp_max\":36.42,\"humidity\":75,\"rainfall_mm\":5.76,\"wind_speed_kmh\":26.53,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:38'),
(2812, 53, '2026-06-16', 'day_3', 27.44, 35.89, 73, 0.00, 26.75, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.44,\"temp_max\":35.89,\"humidity\":73,\"rainfall_mm\":0,\"wind_speed_kmh\":26.75,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:38'),
(2813, 53, '2026-06-17', 'day_4', 27.79, 36.24, 69, 0.00, 29.77, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.79,\"temp_max\":36.24,\"humidity\":69,\"rainfall_mm\":0,\"wind_speed_kmh\":29.77,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:38'),
(2814, 53, '2026-06-18', 'day_5', 28.05, 37.91, 70, 0.39, 31.21, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.05,\"temp_max\":37.91,\"humidity\":70,\"rainfall_mm\":0.39,\"wind_speed_kmh\":31.21,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:38'),
(2815, 54, '2026-06-14', 'current', 34.17, 34.17, 49, 0.00, 9.94, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":34.17,\"temp_max\":34.17,\"humidity\":49,\"rainfall_mm\":0,\"wind_speed_kmh\":9.94,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:38'),
(2816, 54, '2026-06-14', 'today', 28.84, 34.17, 59, 0.00, 18.04, 'Clouds', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.84,\"temp_max\":34.17,\"humidity\":59,\"rainfall_mm\":0,\"wind_speed_kmh\":18.04,\"conditions\":\"Clouds\",\"icon\":\"04n\"}', '2026-06-14 11:17:38'),
(2817, 54, '2026-06-15', 'tomorrow', 28.57, 40.66, 58, 0.17, 28.91, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.57,\"temp_max\":40.66,\"humidity\":58,\"rainfall_mm\":0.17,\"wind_speed_kmh\":28.91,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:38'),
(2818, 54, '2026-06-16', 'day_3', 28.71, 40.46, 58, 0.00, 28.80, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.71,\"temp_max\":40.46,\"humidity\":58,\"rainfall_mm\":0,\"wind_speed_kmh\":28.8,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:38'),
(2819, 54, '2026-06-17', 'day_4', 26.68, 40.41, 62, 6.39, 25.92, 'Clear', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":26.68,\"temp_max\":40.41,\"humidity\":62,\"rainfall_mm\":6.39,\"wind_speed_kmh\":25.92,\"conditions\":\"Clear\",\"icon\":\"04d\"}', '2026-06-14 11:17:38'),
(2820, 54, '2026-06-18', 'day_5', 28.71, 39.79, 64, 14.91, 25.85, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.71,\"temp_max\":39.79,\"humidity\":64,\"rainfall_mm\":14.91,\"wind_speed_kmh\":25.85,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:38'),
(2821, 55, '2026-06-14', 'current', 27.01, 27.01, 89, 0.94, 9.32, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":27.01,\"temp_max\":27.01,\"humidity\":89,\"rainfall_mm\":0.94,\"wind_speed_kmh\":9.32,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:38'),
(2822, 55, '2026-06-14', 'today', 24.88, 27.01, 91, 1.06, 10.55, 'Rain', '04n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":24.88,\"temp_max\":27.01,\"humidity\":91,\"rainfall_mm\":1.06,\"wind_speed_kmh\":10.55,\"conditions\":\"Rain\",\"icon\":\"04n\"}', '2026-06-14 11:17:38'),
(2823, 55, '2026-06-15', 'tomorrow', 24.78, 32.63, 77, 0.84, 15.84, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.78,\"temp_max\":32.63,\"humidity\":77,\"rainfall_mm\":0.84,\"wind_speed_kmh\":15.84,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:38'),
(2824, 55, '2026-06-16', 'day_3', 24.98, 33.41, 76, 0.00, 15.95, 'Clouds', '01d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":24.98,\"temp_max\":33.41,\"humidity\":76,\"rainfall_mm\":0,\"wind_speed_kmh\":15.95,\"conditions\":\"Clouds\",\"icon\":\"01d\"}', '2026-06-14 11:17:38'),
(2825, 55, '2026-06-17', 'day_4', 25.67, 34.52, 74, 0.00, 17.17, 'Clouds', '02d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":25.67,\"temp_max\":34.52,\"humidity\":74,\"rainfall_mm\":0,\"wind_speed_kmh\":17.17,\"conditions\":\"Clouds\",\"icon\":\"02d\"}', '2026-06-14 11:17:38'),
(2826, 55, '2026-06-18', 'day_5', 26.08, 34.24, 71, 0.00, 18.36, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":26.08,\"temp_max\":34.24,\"humidity\":71,\"rainfall_mm\":0,\"wind_speed_kmh\":18.36,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:38'),
(2827, 56, '2026-06-14', 'current', 31.84, 31.84, 70, 0.00, 9.18, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":31.84,\"temp_max\":31.84,\"humidity\":70,\"rainfall_mm\":0,\"wind_speed_kmh\":9.18,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:39'),
(2828, 56, '2026-06-14', 'today', 25.51, 31.84, 80, 6.46, 20.09, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":25.51,\"temp_max\":31.84,\"humidity\":80,\"rainfall_mm\":6.46,\"wind_speed_kmh\":20.09,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-14 11:17:39'),
(2829, 56, '2026-06-15', 'tomorrow', 26.05, 34.54, 77, 5.28, 20.48, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.05,\"temp_max\":34.54,\"humidity\":77,\"rainfall_mm\":5.28,\"wind_speed_kmh\":20.48,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:39'),
(2830, 56, '2026-06-16', 'day_3', 25.96, 33.81, 79, 4.81, 19.73, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":25.96,\"temp_max\":33.81,\"humidity\":79,\"rainfall_mm\":4.81,\"wind_speed_kmh\":19.73,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:39'),
(2831, 56, '2026-06-17', 'day_4', 26.76, 33.84, 80, 11.21, 19.91, 'Rain', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":26.76,\"temp_max\":33.84,\"humidity\":80,\"rainfall_mm\":11.21,\"wind_speed_kmh\":19.91,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:39'),
(2832, 56, '2026-06-18', 'day_5', 26.61, 32.87, 82, 27.22, 19.33, 'Rain', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":26.61,\"temp_max\":32.87,\"humidity\":82,\"rainfall_mm\":27.22,\"wind_speed_kmh\":19.33,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:39'),
(2833, 57, '2026-06-14', 'current', 34.54, 34.54, 53, 0.29, 17.10, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":34.54,\"temp_max\":34.54,\"humidity\":53,\"rainfall_mm\":0.29,\"wind_speed_kmh\":17.1,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:39'),
(2834, 57, '2026-06-14', 'today', 28.72, 34.54, 67, 1.99, 17.10, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.72,\"temp_max\":34.54,\"humidity\":67,\"rainfall_mm\":1.99,\"wind_speed_kmh\":17.1,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:39'),
(2835, 57, '2026-06-15', 'tomorrow', 28.52, 37.83, 66, 0.00, 25.49, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.52,\"temp_max\":37.83,\"humidity\":66,\"rainfall_mm\":0,\"wind_speed_kmh\":25.49,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:39'),
(2836, 57, '2026-06-16', 'day_3', 28.79, 37.75, 65, 0.00, 28.12, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.79,\"temp_max\":37.75,\"humidity\":65,\"rainfall_mm\":0,\"wind_speed_kmh\":28.12,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:39'),
(2837, 57, '2026-06-17', 'day_4', 29.09, 37.79, 63, 0.00, 29.27, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":29.09,\"temp_max\":37.79,\"humidity\":63,\"rainfall_mm\":0,\"wind_speed_kmh\":29.27,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:39'),
(2838, 57, '2026-06-18', 'day_5', 29.37, 37.75, 65, 0.25, 30.46, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":29.37,\"temp_max\":37.75,\"humidity\":65,\"rainfall_mm\":0.25,\"wind_speed_kmh\":30.46,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:39'),
(2839, 58, '2026-06-14', 'current', 29.66, 29.66, 78, 1.62, 15.84, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":29.66,\"temp_max\":29.66,\"humidity\":78,\"rainfall_mm\":1.62,\"wind_speed_kmh\":15.84,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:39'),
(2840, 58, '2026-06-14', 'today', 27.39, 29.66, 82, 3.93, 15.84, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.39,\"temp_max\":29.66,\"humidity\":82,\"rainfall_mm\":3.93,\"wind_speed_kmh\":15.84,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:39');
INSERT INTO `weather_forecasts` (`forecast_id`, `district_id`, `forecast_date`, `forecast_for`, `temp_min`, `temp_max`, `humidity`, `rainfall_mm`, `wind_speed_kmh`, `conditions`, `icon`, `raw_payload`, `fetched_at`) VALUES
(2841, 58, '2026-06-15', 'tomorrow', 27.40, 34.74, 76, 5.43, 27.18, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":27.4,\"temp_max\":34.74,\"humidity\":76,\"rainfall_mm\":5.43,\"wind_speed_kmh\":27.18,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:39'),
(2842, 58, '2026-06-16', 'day_3', 27.28, 34.73, 75, 1.82, 24.12, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.28,\"temp_max\":34.73,\"humidity\":75,\"rainfall_mm\":1.82,\"wind_speed_kmh\":24.12,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:39'),
(2843, 58, '2026-06-17', 'day_4', 27.11, 34.41, 74, 0.16, 26.93, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.11,\"temp_max\":34.41,\"humidity\":74,\"rainfall_mm\":0.16,\"wind_speed_kmh\":26.93,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:39'),
(2844, 58, '2026-06-18', 'day_5', 27.60, 34.21, 74, 0.12, 29.52, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.6,\"temp_max\":34.21,\"humidity\":74,\"rainfall_mm\":0.12,\"wind_speed_kmh\":29.52,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:39'),
(2845, 59, '2026-06-14', 'current', 28.32, 28.32, 82, 2.64, 14.00, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":28.32,\"temp_max\":28.32,\"humidity\":82,\"rainfall_mm\":2.64,\"wind_speed_kmh\":14,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:40'),
(2846, 59, '2026-06-14', 'today', 25.96, 28.32, 86, 2.91, 17.06, 'Rain', '03n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":25.96,\"temp_max\":28.32,\"humidity\":86,\"rainfall_mm\":2.91,\"wind_speed_kmh\":17.06,\"conditions\":\"Rain\",\"icon\":\"03n\"}', '2026-06-14 11:17:40'),
(2847, 59, '2026-06-15', 'tomorrow', 26.29, 35.57, 76, 1.37, 20.30, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.29,\"temp_max\":35.57,\"humidity\":76,\"rainfall_mm\":1.37,\"wind_speed_kmh\":20.3,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:40'),
(2848, 59, '2026-06-16', 'day_3', 26.34, 33.46, 77, 2.04, 20.48, 'Rain', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":26.34,\"temp_max\":33.46,\"humidity\":77,\"rainfall_mm\":2.04,\"wind_speed_kmh\":20.48,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:40'),
(2849, 59, '2026-06-17', 'day_4', 26.75, 33.59, 75, 2.59, 21.24, 'Rain', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":26.75,\"temp_max\":33.59,\"humidity\":75,\"rainfall_mm\":2.59,\"wind_speed_kmh\":21.24,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:40'),
(2850, 59, '2026-06-18', 'day_5', 27.24, 33.65, 74, 3.27, 26.50, 'Rain', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.24,\"temp_max\":33.65,\"humidity\":74,\"rainfall_mm\":3.27,\"wind_speed_kmh\":26.5,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:40'),
(2851, 60, '2026-06-14', 'current', 28.56, 28.56, 81, 1.97, 23.87, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":28.56,\"temp_max\":28.56,\"humidity\":81,\"rainfall_mm\":1.97,\"wind_speed_kmh\":23.87,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:40'),
(2852, 60, '2026-06-14', 'today', 28.56, 29.38, 80, 2.55, 28.94, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":28.56,\"temp_max\":29.38,\"humidity\":80,\"rainfall_mm\":2.55,\"wind_speed_kmh\":28.94,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:40'),
(2853, 60, '2026-06-15', 'tomorrow', 28.20, 32.50, 76, 0.71, 36.94, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":28.2,\"temp_max\":32.5,\"humidity\":76,\"rainfall_mm\":0.71,\"wind_speed_kmh\":36.94,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:40'),
(2854, 60, '2026-06-16', 'day_3', 28.40, 33.55, 75, 0.00, 34.45, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":28.4,\"temp_max\":33.55,\"humidity\":75,\"rainfall_mm\":0,\"wind_speed_kmh\":34.45,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:40'),
(2855, 60, '2026-06-17', 'day_4', 28.84, 33.26, 75, 1.38, 36.04, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":28.84,\"temp_max\":33.26,\"humidity\":75,\"rainfall_mm\":1.38,\"wind_speed_kmh\":36.04,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:40'),
(2856, 60, '2026-06-18', 'day_5', 28.91, 32.95, 76, 1.63, 35.89, 'Rain', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":28.91,\"temp_max\":32.95,\"humidity\":76,\"rainfall_mm\":1.63,\"wind_speed_kmh\":35.89,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:40'),
(2857, 61, '2026-06-14', 'current', 29.53, 29.53, 79, 3.19, 6.34, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":29.53,\"temp_max\":29.53,\"humidity\":79,\"rainfall_mm\":3.19,\"wind_speed_kmh\":6.34,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:40'),
(2858, 61, '2026-06-14', 'today', 25.48, 29.53, 86, 16.48, 10.15, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":25.48,\"temp_max\":29.53,\"humidity\":86,\"rainfall_mm\":16.48,\"wind_speed_kmh\":10.15,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:40'),
(2859, 61, '2026-06-15', 'tomorrow', 24.80, 31.31, 87, 28.87, 13.90, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.8,\"temp_max\":31.31,\"humidity\":87,\"rainfall_mm\":28.87,\"wind_speed_kmh\":13.9,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:40'),
(2860, 61, '2026-06-16', 'day_3', 24.97, 32.01, 83, 24.28, 9.86, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":24.97,\"temp_max\":32.01,\"humidity\":83,\"rainfall_mm\":24.28,\"wind_speed_kmh\":9.86,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:40'),
(2861, 61, '2026-06-17', 'day_4', 25.25, 31.06, 84, 26.64, 13.00, 'Rain', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":25.25,\"temp_max\":31.06,\"humidity\":84,\"rainfall_mm\":26.64,\"wind_speed_kmh\":13,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:40'),
(2862, 61, '2026-06-18', 'day_5', 24.98, 30.88, 87, 33.63, 13.93, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":24.98,\"temp_max\":30.88,\"humidity\":87,\"rainfall_mm\":33.63,\"wind_speed_kmh\":13.93,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:40'),
(2863, 62, '2026-06-14', 'current', 29.11, 29.11, 79, 5.88, 5.00, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":29.11,\"temp_max\":29.11,\"humidity\":79,\"rainfall_mm\":5.88,\"wind_speed_kmh\":5,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:41'),
(2864, 62, '2026-06-14', 'today', 25.31, 29.11, 86, 20.23, 8.89, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":25.31,\"temp_max\":29.11,\"humidity\":86,\"rainfall_mm\":20.23,\"wind_speed_kmh\":8.89,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:41'),
(2865, 62, '2026-06-15', 'tomorrow', 24.69, 28.98, 87, 19.42, 8.32, 'Rain', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":24.69,\"temp_max\":28.98,\"humidity\":87,\"rainfall_mm\":19.42,\"wind_speed_kmh\":8.32,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:41'),
(2866, 62, '2026-06-16', 'day_3', 25.11, 32.70, 80, 20.69, 7.13, 'Rain', '10d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":25.11,\"temp_max\":32.7,\"humidity\":80,\"rainfall_mm\":20.69,\"wind_speed_kmh\":7.13,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:41'),
(2867, 62, '2026-06-17', 'day_4', 25.68, 32.28, 81, 17.28, 8.32, 'Rain', '10d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":25.68,\"temp_max\":32.28,\"humidity\":81,\"rainfall_mm\":17.28,\"wind_speed_kmh\":8.32,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:41'),
(2868, 62, '2026-06-18', 'day_5', 25.48, 31.63, 82, 30.26, 9.00, 'Rain', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":25.48,\"temp_max\":31.63,\"humidity\":82,\"rainfall_mm\":30.26,\"wind_speed_kmh\":9,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:41'),
(2869, 63, '2026-06-14', 'current', 31.31, 31.31, 69, 0.25, 13.00, 'Rain', '10d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":31.31,\"temp_max\":31.31,\"humidity\":69,\"rainfall_mm\":0.25,\"wind_speed_kmh\":13,\"conditions\":\"Rain\",\"icon\":\"10d\"}', '2026-06-14 11:17:41'),
(2870, 63, '2026-06-14', 'today', 27.17, 31.31, 78, 3.85, 16.31, 'Rain', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":27.17,\"temp_max\":31.31,\"humidity\":78,\"rainfall_mm\":3.85,\"wind_speed_kmh\":16.31,\"conditions\":\"Rain\",\"icon\":\"10n\"}', '2026-06-14 11:17:41'),
(2871, 63, '2026-06-15', 'tomorrow', 26.78, 35.58, 76, 6.61, 25.45, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":26.78,\"temp_max\":35.58,\"humidity\":76,\"rainfall_mm\":6.61,\"wind_speed_kmh\":25.45,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:41'),
(2872, 63, '2026-06-16', 'day_3', 27.44, 35.05, 73, 0.39, 26.60, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":27.44,\"temp_max\":35.05,\"humidity\":73,\"rainfall_mm\":0.39,\"wind_speed_kmh\":26.6,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:41'),
(2873, 63, '2026-06-17', 'day_4', 27.31, 34.09, 73, 0.22, 27.86, 'Clouds', '04d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":27.31,\"temp_max\":34.09,\"humidity\":73,\"rainfall_mm\":0.22,\"wind_speed_kmh\":27.86,\"conditions\":\"Clouds\",\"icon\":\"04d\"}', '2026-06-14 11:17:41'),
(2874, 63, '2026-06-18', 'day_5', 27.67, 34.05, 74, 0.53, 28.73, 'Clouds', '10d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":27.67,\"temp_max\":34.05,\"humidity\":74,\"rainfall_mm\":0.53,\"wind_speed_kmh\":28.73,\"conditions\":\"Clouds\",\"icon\":\"10d\"}', '2026-06-14 11:17:41'),
(2875, 64, '2026-06-14', 'current', 31.94, 31.94, 63, 0.00, 15.62, 'Clouds', '03d', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"current\",\"temp_min\":31.94,\"temp_max\":31.94,\"humidity\":63,\"rainfall_mm\":0,\"wind_speed_kmh\":15.62,\"conditions\":\"Clouds\",\"icon\":\"03d\"}', '2026-06-14 11:17:41'),
(2876, 64, '2026-06-14', 'today', 25.37, 31.94, 75, 2.43, 15.62, 'Clouds', '10n', '{\"forecast_date\":\"2026-06-14\",\"forecast_for\":\"today\",\"temp_min\":25.37,\"temp_max\":31.94,\"humidity\":75,\"rainfall_mm\":2.43,\"wind_speed_kmh\":15.62,\"conditions\":\"Clouds\",\"icon\":\"10n\"}', '2026-06-14 11:17:41'),
(2877, 64, '2026-06-15', 'tomorrow', 25.74, 37.18, 70, 3.09, 21.78, 'Clear', '01d', '{\"forecast_date\":\"2026-06-15\",\"forecast_for\":\"tomorrow\",\"temp_min\":25.74,\"temp_max\":37.18,\"humidity\":70,\"rainfall_mm\":3.09,\"wind_speed_kmh\":21.78,\"conditions\":\"Clear\",\"icon\":\"01d\"}', '2026-06-14 11:17:41'),
(2878, 64, '2026-06-16', 'day_3', 26.24, 33.77, 78, 10.49, 20.23, 'Rain', '03d', '{\"forecast_date\":\"2026-06-16\",\"forecast_for\":\"day_3\",\"temp_min\":26.24,\"temp_max\":33.77,\"humidity\":78,\"rainfall_mm\":10.49,\"wind_speed_kmh\":20.23,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-14 11:17:41'),
(2879, 64, '2026-06-17', 'day_4', 26.49, 34.59, 77, 3.47, 17.75, 'Rain', '03d', '{\"forecast_date\":\"2026-06-17\",\"forecast_for\":\"day_4\",\"temp_min\":26.49,\"temp_max\":34.59,\"humidity\":77,\"rainfall_mm\":3.47,\"wind_speed_kmh\":17.75,\"conditions\":\"Rain\",\"icon\":\"03d\"}', '2026-06-14 11:17:41'),
(2880, 64, '2026-06-18', 'day_5', 26.28, 33.04, 81, 14.04, 20.81, 'Rain', '04d', '{\"forecast_date\":\"2026-06-18\",\"forecast_for\":\"day_5\",\"temp_min\":26.28,\"temp_max\":33.04,\"humidity\":81,\"rainfall_mm\":14.04,\"wind_speed_kmh\":20.81,\"conditions\":\"Rain\",\"icon\":\"04d\"}', '2026-06-14 11:17:41');

-- --------------------------------------------------------

--
-- Structure for view `vw_active_crops_with_details`
--
DROP TABLE IF EXISTS `vw_active_crops_with_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_active_crops_with_details`  AS SELECT `c`.`crop_id` AS `crop_id`, `c`.`farmer_id` AS `farmer_id`, `c`.`category_id` AS `category_id`, `c`.`crop_name` AS `crop_name`, `c`.`crop_variety` AS `crop_variety`, `c`.`quantity` AS `quantity`, `c`.`unit` AS `unit`, `c`.`price_per_unit` AS `price_per_unit`, `c`.`quality_grade` AS `quality_grade`, `c`.`is_organic` AS `is_organic`, `c`.`harvest_date` AS `harvest_date`, `c`.`available_from` AS `available_from`, `c`.`available_until` AS `available_until`, `c`.`description` AS `description`, `c`.`images` AS `images`, `c`.`status` AS `status`, `c`.`views_count` AS `views_count`, `c`.`listed_by_agent` AS `listed_by_agent`, `c`.`agent_id` AS `agent_id`, `c`.`created_at` AS `created_at`, `c`.`updated_at` AS `updated_at`, `u`.`full_name` AS `farmer_name`, `u`.`phone` AS `farmer_phone`, `u`.`profile_picture` AS `farmer_picture`, `d`.`district_name` AS `district_name`, `d`.`division` AS `division`, `cat`.`category_name_bn` AS `category_name_bn`, `cat`.`category_name` AS `category_name`, ifnull((select avg(`farmer_ratings`.`overall_rating`) from `farmer_ratings` where `farmer_ratings`.`farmer_id` = `u`.`user_id`),0) AS `farmer_avg_rating`, (select count(0) from `farmer_ratings` where `farmer_ratings`.`farmer_id` = `u`.`user_id`) AS `farmer_rating_count` FROM (((`crops` `c` join `users` `u` on(`c`.`farmer_id` = `u`.`user_id`)) join `districts` `d` on(`u`.`district_id` = `d`.`district_id`)) join `crop_categories` `cat` on(`c`.`category_id` = `cat`.`category_id`)) WHERE `c`.`status` = 'available' AND `c`.`quantity` > 0 ;

-- --------------------------------------------------------

--
-- Structure for view `vw_farmer_performance`
--
DROP TABLE IF EXISTS `vw_farmer_performance`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_farmer_performance`  AS SELECT `u`.`user_id` AS `farmer_id`, `u`.`full_name` AS `farmer_name`, `d`.`district_name` AS `district_name`, count(distinct `c`.`crop_id`) AS `total_crops_listed`, count(distinct `o`.`order_id`) AS `total_orders`, ifnull(sum(case when `o`.`order_status` = 'delivered' then `o`.`total_amount` end),0) AS `total_revenue`, ifnull(avg(`fr`.`overall_rating`),0) AS `avg_rating` FROM (((((`users` `u` join `districts` `d` on(`u`.`district_id` = `d`.`district_id`)) join `user_roles` `ur` on(`u`.`user_id` = `ur`.`user_id` and `ur`.`role` = 'farmer')) left join `crops` `c` on(`u`.`user_id` = `c`.`farmer_id`)) left join `orders` `o` on(`u`.`user_id` = `o`.`farmer_id`)) left join `farmer_ratings` `fr` on(`u`.`user_id` = `fr`.`farmer_id`)) GROUP BY `u`.`user_id` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `agents`
--
ALTER TABLE `agents`
  ADD PRIMARY KEY (`agent_id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD UNIQUE KEY `agent_code` (`agent_code`);

--
-- Indexes for table `agent_activities`
--
ALTER TABLE `agent_activities`
  ADD PRIMARY KEY (`activity_id`),
  ADD KEY `farmer_id` (`farmer_id`),
  ADD KEY `idx_agent_date` (`agent_id`,`activity_date`);

--
-- Indexes for table `agent_farmer_mapping`
--
ALTER TABLE `agent_farmer_mapping`
  ADD PRIMARY KEY (`mapping_id`),
  ADD KEY `agent_id` (`agent_id`),
  ADD KEY `idx_active` (`farmer_id`,`status`);

--
-- Indexes for table `assistant_queries`
--
ALTER TABLE `assistant_queries`
  ADD PRIMARY KEY (`query_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `idx_user_date` (`user_id`,`created_at`),
  ADD KEY `idx_table` (`table_name`,`record_id`);

--
-- Indexes for table `crops`
--
ALTER TABLE `crops`
  ADD PRIMARY KEY (`crop_id`),
  ADD KEY `agent_id` (`agent_id`),
  ADD KEY `idx_market` (`category_id`,`status`,`price_per_unit`),
  ADD KEY `idx_farmer_status` (`farmer_id`,`status`);

--
-- Indexes for table `crop_categories`
--
ALTER TABLE `crop_categories`
  ADD PRIMARY KEY (`category_id`),
  ADD UNIQUE KEY `category_name` (`category_name`),
  ADD UNIQUE KEY `category_name_bn` (`category_name_bn`),
  ADD KEY `parent_category_id` (`parent_category_id`);

--
-- Indexes for table `crop_recommendations`
--
ALTER TABLE `crop_recommendations`
  ADD PRIMARY KEY (`recommendation_id`),
  ADD KEY `farmer_id` (`farmer_id`),
  ADD KEY `idx_district_season` (`district_id`,`season`);

--
-- Indexes for table `dashboard_widgets`
--
ALTER TABLE `dashboard_widgets`
  ADD PRIMARY KEY (`widget_id`),
  ADD UNIQUE KEY `uq_widget` (`user_id`,`widget_type`);

--
-- Indexes for table `deliveries`
--
ALTER TABLE `deliveries`
  ADD PRIMARY KEY (`delivery_id`),
  ADD UNIQUE KEY `order_id` (`order_id`),
  ADD KEY `transport_partner_id` (`transport_partner_id`);

--
-- Indexes for table `demand_analytics`
--
ALTER TABLE `demand_analytics`
  ADD PRIMARY KEY (`demand_id`),
  ADD UNIQUE KEY `uq_demand` (`crop_name`,`district_id`,`analysis_date`),
  ADD KEY `district_id` (`district_id`);

--
-- Indexes for table `districts`
--
ALTER TABLE `districts`
  ADD PRIMARY KEY (`district_id`),
  ADD UNIQUE KEY `district_name` (`district_name`),
  ADD KEY `idx_division` (`division`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`expense_id`),
  ADD KEY `crop_id` (`crop_id`),
  ADD KEY `idx_farmer_date` (`farmer_id`,`expense_date`);

--
-- Indexes for table `farmer_groups`
--
ALTER TABLE `farmer_groups`
  ADD PRIMARY KEY (`group_id`),
  ADD UNIQUE KEY `group_name` (`group_name`),
  ADD UNIQUE KEY `group_code` (`group_code`),
  ADD KEY `group_leader_id` (`group_leader_id`),
  ADD KEY `district_id` (`district_id`),
  ADD KEY `approved_by` (`approved_by`);

--
-- Indexes for table `farmer_ratings`
--
ALTER TABLE `farmer_ratings`
  ADD PRIMARY KEY (`rating_id`),
  ADD UNIQUE KEY `uq_rating` (`buyer_id`,`order_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `idx_farmer` (`farmer_id`);

--
-- Indexes for table `farmer_support_tickets`
--
ALTER TABLE `farmer_support_tickets`
  ADD PRIMARY KEY (`ticket_id`),
  ADD UNIQUE KEY `ticket_number` (`ticket_number`),
  ADD KEY `farmer_id` (`farmer_id`),
  ADD KEY `assigned_agent_id` (`assigned_agent_id`);

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`favorite_id`),
  ADD KEY `crop_id` (`crop_id`),
  ADD KEY `farmer_id` (`farmer_id`),
  ADD KEY `idx_user_type` (`user_id`,`favorite_type`);

--
-- Indexes for table `group_members`
--
ALTER TABLE `group_members`
  ADD PRIMARY KEY (`membership_id`),
  ADD UNIQUE KEY `uq_member` (`group_id`,`farmer_id`),
  ADD KEY `farmer_id` (`farmer_id`);

--
-- Indexes for table `inventory_logs`
--
ALTER TABLE `inventory_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `crop_id` (`crop_id`),
  ADD KEY `changed_by` (`changed_by`);

--
-- Indexes for table `loans`
--
ALTER TABLE `loans`
  ADD PRIMARY KEY (`loan_id`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `agent_id` (`agent_id`),
  ADD KEY `idx_farmer_status` (`farmer_id`,`status`),
  ADD KEY `idx_status_date` (`status`,`application_date`);

--
-- Indexes for table `loan_repayments`
--
ALTER TABLE `loan_repayments`
  ADD PRIMARY KEY (`repayment_id`),
  ADD KEY `loan_id` (`loan_id`),
  ADD KEY `recorded_by` (`recorded_by`);

--
-- Indexes for table `market_prices`
--
ALTER TABLE `market_prices`
  ADD PRIMARY KEY (`price_id`),
  ADD UNIQUE KEY `uq_price` (`crop_name`,`district_id`,`price_date`),
  ADD KEY `district_id` (`district_id`),
  ADD KEY `updated_by` (`updated_by`),
  ADD KEY `idx_market_lookup` (`crop_name`,`district_id`,`price_date`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `related_crop_id` (`related_crop_id`),
  ADD KEY `agent_id` (`agent_id`),
  ADD KEY `idx_conv` (`sender_id`,`receiver_id`,`created_at`),
  ADD KEY `idx_inbox` (`receiver_id`,`is_read`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `idx_notify` (`user_id`,`is_read`,`created_at`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD UNIQUE KEY `order_number` (`order_number`),
  ADD KEY `crop_id` (`crop_id`),
  ADD KEY `delivery_district_id` (`delivery_district_id`),
  ADD KEY `cancelled_by` (`cancelled_by`),
  ADD KEY `idx_buyer_date` (`buyer_id`,`order_date`),
  ADD KEY `idx_farmer_date` (`farmer_id`,`order_date`),
  ADD KEY `idx_status` (`order_status`);

--
-- Indexes for table `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD PRIMARY KEY (`otp_id`),
  ADD KEY `idx_phone_purpose` (`phone`,`purpose`,`created_at`),
  ADD KEY `idx_expires` (`expires_at`),
  ADD KEY `idx_unverified` (`phone`,`verified_at`,`expires_at`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD UNIQUE KEY `payment_reference` (`payment_reference`),
  ADD KEY `idx_order` (`order_id`),
  ADD KEY `idx_subscription` (`subscription_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_gateway_txn` (`gateway`,`gateway_transaction_id`),
  ADD KEY `idx_status_date` (`status`,`initiated_at`);

--
-- Indexes for table `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD PRIMARY KEY (`method_id`),
  ADD UNIQUE KEY `uq_payment` (`user_id`,`method_type`,`account_number`);

--
-- Indexes for table `price_history`
--
ALTER TABLE `price_history`
  ADD PRIMARY KEY (`history_id`),
  ADD KEY `district_id` (`district_id`),
  ADD KEY `idx_history` (`crop_name`,`district_id`,`price_date`);

--
-- Indexes for table `price_predictions`
--
ALTER TABLE `price_predictions`
  ADD PRIMARY KEY (`prediction_id`),
  ADD UNIQUE KEY `uq_pred` (`crop_name`,`district_id`,`prediction_date`),
  ADD KEY `district_id` (`district_id`);

--
-- Indexes for table `search_logs`
--
ALTER TABLE `search_logs`
  ADD PRIMARY KEY (`search_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `clicked_crop_id` (`clicked_crop_id`);

--
-- Indexes for table `subscriptions`
--
ALTER TABLE `subscriptions`
  ADD PRIMARY KEY (`subscription_id`),
  ADD KEY `buyer_id` (`buyer_id`),
  ADD KEY `farmer_id` (`farmer_id`),
  ADD KEY `payment_method_id` (`payment_method_id`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`setting_id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`),
  ADD KEY `updated_by` (`updated_by`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`transaction_id`),
  ADD UNIQUE KEY `reference_number` (`reference_number`),
  ADD KEY `payment_method_id` (`payment_method_id`),
  ADD KEY `related_order_id` (`related_order_id`),
  ADD KEY `related_loan_id` (`related_loan_id`),
  ADD KEY `idx_user_date` (`user_id`,`created_at`);

--
-- Indexes for table `transport_partners`
--
ALTER TABLE `transport_partners`
  ADD PRIMARY KEY (`partner_id`),
  ADD UNIQUE KEY `partner_name` (`partner_name`),
  ADD UNIQUE KEY `contact_phone` (`contact_phone`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `nid_number` (`nid_number`),
  ADD KEY `district_id` (`district_id`),
  ADD KEY `idx_user_status` (`account_status`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`user_id`,`role`),
  ADD KEY `idx_role` (`role`);

--
-- Indexes for table `weather_alerts`
--
ALTER TABLE `weather_alerts`
  ADD PRIMARY KEY (`alert_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_active` (`is_active`,`created_at`);

--
-- Indexes for table `weather_forecasts`
--
ALTER TABLE `weather_forecasts`
  ADD PRIMARY KEY (`forecast_id`),
  ADD UNIQUE KEY `uniq_district_date_for` (`district_id`,`forecast_date`,`forecast_for`),
  ADD KEY `idx_district_date` (`district_id`,`forecast_date`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `agents`
--
ALTER TABLE `agents`
  MODIFY `agent_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `agent_activities`
--
ALTER TABLE `agent_activities`
  MODIFY `activity_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `agent_farmer_mapping`
--
ALTER TABLE `agent_farmer_mapping`
  MODIFY `mapping_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `assistant_queries`
--
ALTER TABLE `assistant_queries`
  MODIFY `query_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `log_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crops`
--
ALTER TABLE `crops`
  MODIFY `crop_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `crop_categories`
--
ALTER TABLE `crop_categories`
  MODIFY `category_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `crop_recommendations`
--
ALTER TABLE `crop_recommendations`
  MODIFY `recommendation_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `dashboard_widgets`
--
ALTER TABLE `dashboard_widgets`
  MODIFY `widget_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `deliveries`
--
ALTER TABLE `deliveries`
  MODIFY `delivery_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `demand_analytics`
--
ALTER TABLE `demand_analytics`
  MODIFY `demand_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `districts`
--
ALTER TABLE `districts`
  MODIFY `district_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `expense_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `farmer_groups`
--
ALTER TABLE `farmer_groups`
  MODIFY `group_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `farmer_ratings`
--
ALTER TABLE `farmer_ratings`
  MODIFY `rating_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `farmer_support_tickets`
--
ALTER TABLE `farmer_support_tickets`
  MODIFY `ticket_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `favorite_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `group_members`
--
ALTER TABLE `group_members`
  MODIFY `membership_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_logs`
--
ALTER TABLE `inventory_logs`
  MODIFY `log_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `loans`
--
ALTER TABLE `loans`
  MODIFY `loan_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `loan_repayments`
--
ALTER TABLE `loan_repayments`
  MODIFY `repayment_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `market_prices`
--
ALTER TABLE `market_prices`
  MODIFY `price_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `otp_codes`
--
ALTER TABLE `otp_codes`
  MODIFY `otp_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `payment_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `payment_methods`
--
ALTER TABLE `payment_methods`
  MODIFY `method_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `price_history`
--
ALTER TABLE `price_history`
  MODIFY `history_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `price_predictions`
--
ALTER TABLE `price_predictions`
  MODIFY `prediction_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `search_logs`
--
ALTER TABLE `search_logs`
  MODIFY `search_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `subscriptions`
--
ALTER TABLE `subscriptions`
  MODIFY `subscription_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_settings`
--
ALTER TABLE `system_settings`
  MODIFY `setting_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `transaction_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `transport_partners`
--
ALTER TABLE `transport_partners`
  MODIFY `partner_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `weather_alerts`
--
ALTER TABLE `weather_alerts`
  MODIFY `alert_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=217;

--
-- AUTO_INCREMENT for table `weather_forecasts`
--
ALTER TABLE `weather_forecasts`
  MODIFY `forecast_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2881;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `agents`
--
ALTER TABLE `agents`
  ADD CONSTRAINT `agents_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `agent_activities`
--
ALTER TABLE `agent_activities`
  ADD CONSTRAINT `agent_activities_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`agent_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `agent_activities_ibfk_2` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `agent_farmer_mapping`
--
ALTER TABLE `agent_farmer_mapping`
  ADD CONSTRAINT `agent_farmer_mapping_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`agent_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `agent_farmer_mapping_ibfk_2` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `assistant_queries`
--
ALTER TABLE `assistant_queries`
  ADD CONSTRAINT `assistant_queries_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `crops`
--
ALTER TABLE `crops`
  ADD CONSTRAINT `crops_ibfk_1` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `crops_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `crop_categories` (`category_id`),
  ADD CONSTRAINT `crops_ibfk_3` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`agent_id`) ON DELETE SET NULL;

--
-- Constraints for table `crop_categories`
--
ALTER TABLE `crop_categories`
  ADD CONSTRAINT `crop_categories_ibfk_1` FOREIGN KEY (`parent_category_id`) REFERENCES `crop_categories` (`category_id`) ON DELETE SET NULL;

--
-- Constraints for table `crop_recommendations`
--
ALTER TABLE `crop_recommendations`
  ADD CONSTRAINT `crop_recommendations_ibfk_1` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `crop_recommendations_ibfk_2` FOREIGN KEY (`district_id`) REFERENCES `districts` (`district_id`) ON DELETE CASCADE;

--
-- Constraints for table `dashboard_widgets`
--
ALTER TABLE `dashboard_widgets`
  ADD CONSTRAINT `dashboard_widgets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `deliveries`
--
ALTER TABLE `deliveries`
  ADD CONSTRAINT `deliveries_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `deliveries_ibfk_2` FOREIGN KEY (`transport_partner_id`) REFERENCES `transport_partners` (`partner_id`) ON DELETE SET NULL;

--
-- Constraints for table `demand_analytics`
--
ALTER TABLE `demand_analytics`
  ADD CONSTRAINT `demand_analytics_ibfk_1` FOREIGN KEY (`district_id`) REFERENCES `districts` (`district_id`) ON DELETE CASCADE;

--
-- Constraints for table `expenses`
--
ALTER TABLE `expenses`
  ADD CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expenses_ibfk_2` FOREIGN KEY (`crop_id`) REFERENCES `crops` (`crop_id`) ON DELETE SET NULL;

--
-- Constraints for table `farmer_groups`
--
ALTER TABLE `farmer_groups`
  ADD CONSTRAINT `farmer_groups_ibfk_1` FOREIGN KEY (`group_leader_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `farmer_groups_ibfk_2` FOREIGN KEY (`district_id`) REFERENCES `districts` (`district_id`),
  ADD CONSTRAINT `farmer_groups_ibfk_3` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `farmer_ratings`
--
ALTER TABLE `farmer_ratings`
  ADD CONSTRAINT `farmer_ratings_ibfk_1` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `farmer_ratings_ibfk_2` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `farmer_ratings_ibfk_3` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE;

--
-- Constraints for table `farmer_support_tickets`
--
ALTER TABLE `farmer_support_tickets`
  ADD CONSTRAINT `farmer_support_tickets_ibfk_1` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `farmer_support_tickets_ibfk_2` FOREIGN KEY (`assigned_agent_id`) REFERENCES `agents` (`agent_id`) ON DELETE SET NULL;

--
-- Constraints for table `favorites`
--
ALTER TABLE `favorites`
  ADD CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`crop_id`) REFERENCES `crops` (`crop_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `favorites_ibfk_3` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `group_members`
--
ALTER TABLE `group_members`
  ADD CONSTRAINT `group_members_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `farmer_groups` (`group_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `group_members_ibfk_2` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `inventory_logs`
--
ALTER TABLE `inventory_logs`
  ADD CONSTRAINT `inventory_logs_ibfk_1` FOREIGN KEY (`crop_id`) REFERENCES `crops` (`crop_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `inventory_logs_ibfk_2` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `loans`
--
ALTER TABLE `loans`
  ADD CONSTRAINT `loans_ibfk_1` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `loans_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `loans_ibfk_3` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`agent_id`) ON DELETE SET NULL;

--
-- Constraints for table `loan_repayments`
--
ALTER TABLE `loan_repayments`
  ADD CONSTRAINT `loan_repayments_ibfk_1` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`loan_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `loan_repayments_ibfk_2` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `market_prices`
--
ALTER TABLE `market_prices`
  ADD CONSTRAINT `market_prices_ibfk_1` FOREIGN KEY (`district_id`) REFERENCES `districts` (`district_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `market_prices_ibfk_2` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_3` FOREIGN KEY (`related_crop_id`) REFERENCES `crops` (`crop_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `messages_ibfk_4` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`agent_id`) ON DELETE SET NULL;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`crop_id`) REFERENCES `crops` (`crop_id`),
  ADD CONSTRAINT `orders_ibfk_4` FOREIGN KEY (`delivery_district_id`) REFERENCES `districts` (`district_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `orders_ibfk_5` FOREIGN KEY (`cancelled_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions` (`subscription_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD CONSTRAINT `payment_methods_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `price_history`
--
ALTER TABLE `price_history`
  ADD CONSTRAINT `price_history_ibfk_1` FOREIGN KEY (`district_id`) REFERENCES `districts` (`district_id`) ON DELETE CASCADE;

--
-- Constraints for table `price_predictions`
--
ALTER TABLE `price_predictions`
  ADD CONSTRAINT `price_predictions_ibfk_1` FOREIGN KEY (`district_id`) REFERENCES `districts` (`district_id`) ON DELETE CASCADE;

--
-- Constraints for table `search_logs`
--
ALTER TABLE `search_logs`
  ADD CONSTRAINT `search_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `search_logs_ibfk_2` FOREIGN KEY (`clicked_crop_id`) REFERENCES `crops` (`crop_id`) ON DELETE SET NULL;

--
-- Constraints for table `subscriptions`
--
ALTER TABLE `subscriptions`
  ADD CONSTRAINT `subscriptions_ibfk_1` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `subscriptions_ibfk_2` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `subscriptions_ibfk_3` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`method_id`) ON DELETE SET NULL;

--
-- Constraints for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD CONSTRAINT `system_settings_ibfk_1` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`method_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `transactions_ibfk_3` FOREIGN KEY (`related_order_id`) REFERENCES `orders` (`order_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `transactions_ibfk_4` FOREIGN KEY (`related_loan_id`) REFERENCES `loans` (`loan_id`) ON DELETE SET NULL;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`district_id`) REFERENCES `districts` (`district_id`);

--
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `weather_alerts`
--
ALTER TABLE `weather_alerts`
  ADD CONSTRAINT `weather_alerts_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `weather_forecasts`
--
ALTER TABLE `weather_forecasts`
  ADD CONSTRAINT `weather_forecasts_ibfk_1` FOREIGN KEY (`district_id`) REFERENCES `districts` (`district_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

