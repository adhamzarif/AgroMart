# AgroFin - সেটআপ নির্দেশিকা 🌾

স্বাগতম! এই গাইডটি অনুসরণ করে মাত্র ৫ মিনিটে AgroFin প্রজেক্ট চালু করতে পারবেন।

## ১. প্রয়োজনীয় সফটওয়্যার

- **XAMPP** (PHP 8.0 বা তার উপরে, MySQL/MariaDB সহ)
  ডাউনলোড: https://www.apachefriends.org/

XAMPP-এ যা থাকে: Apache, MySQL/MariaDB, PHP, phpMyAdmin — সব একসাথে।

## ২. প্রজেক্ট ফাইল কপি করুন

ZIP ফাইল আনজিপ করার পর `AgroFin` ফোল্ডারটি কপি করুন এই জায়গায়:

```
C:\xampp\htdocs\AgroFin\
```

ফাইনাল পাথ এমন হবে: `C:\xampp\htdocs\AgroFin\index.php`

## ৩. XAMPP চালু করুন

1. **XAMPP Control Panel** খুলুন
2. **Apache** এর "Start" বাটনে ক্লিক করুন (সবুজ দেখাবে)
3. **MySQL** এর "Start" বাটনে ক্লিক করুন (সবুজ দেখাবে)

## ৪. ডাটাবেস ইমপোর্ট করুন

1. ব্রাউজারে যান: **http://localhost/phpmyadmin**
2. উপরের মেনু থেকে **"Import"** এ ক্লিক করুন
3. **"Choose File"** তে ক্লিক করে `AgroFin/database.sql` ফাইলটি সিলেক্ট করুন
4. নিচে **"Import"** বাটনে ক্লিক করুন

✅ সফল হলে দেখবেন: `AgroFin database ready ✓ — districts: 64, users: 8, crops: 7`

**বিকল্প পদ্ধতি (কমান্ড লাইন):**

```bash
cd C:\xampp\mysql\bin
mysql.exe -u root < C:\xampp\htdocs\AgroFin\database.sql
```

## ৫. ব্রাউজারে দেখুন

ব্রাউজারে গিয়ে টাইপ করুন:

```
http://localhost/AgroFin/
```

🎉 হোমপেজ দেখা যাবে। এবার লগইন করুন!

## ৬. ডেমো অ্যাকাউন্ট

সব অ্যাকাউন্টের পাসওয়ার্ড: **`password123`**

| ভূমিকা    | মোবাইল         | ইমেইল                  | নাম              |
|-----------|----------------|------------------------|------------------|
| 👨‍🌾 কৃষক     | `01712345001`  | karim@example.com      | করিম মিয়া      |
| 👩‍🌾 কৃষক     | `01812345002`  | fatema@example.com     | ফাতেমা বেগম     |
| 👨‍🌾 কৃষক     | `01912345003`  | halim@example.com      | আব্দুল হালিম    |
| 🛒 ক্রেতা    | `01612345004`  | hasan@traders.com      | হাসান ট্রেডার্স |
| 🛒 ক্রেতা    | `01512345005`  | order@freshmart.bd     | FreshMart BD     |
| 🤝 এজেন্ট    | `01312345006`  | rafiq@agent.com        | রফিকুল ইসলাম   |
| 🤝 এজেন্ট    | `01412345007`  | salma@agent.com        | সালমা খাতুন    |
| 👑 অ্যাডমিন   | `01212345008`  | admin@agrofin.com      | সুলতানা আহমেদ  |

লগইন করতে যেকোনো মোবাইল নম্বর বা ইমেইল ব্যবহার করতে পারবেন।

## ৭. ফাইল পারমিশন (Linux/Mac এ)

যদি আপনি Linux/Mac এ চালান, `uploads/` ফোল্ডারে রাইট পারমিশন দিন:

```bash
chmod -R 775 uploads/
```

## সমস্যার সমাধান

### ❌ "ডাটাবেস সংযোগ ব্যর্থ" এরর

`config/database.php` খুলে এই লাইনগুলো চেক করুন:

```php
private $host = 'localhost';
private $db   = 'agrofin';
private $user = 'root';
private $pass = '';   // ডিফল্টে খালি
```

যদি আপনার MySQL এ পাসওয়ার্ড সেট থাকে, `$pass` এ লিখুন।

### ❌ "Class 'PDO' not found"

`php.ini` ফাইলে `extension=pdo_mysql` লাইনটি আনকমেন্ট করুন।

### ❌ "404 Not Found" (সাবরাউট খুলে না)

XAMPP-এ `mod_rewrite` চালু করুন:
1. `C:\xampp\apache\conf\httpd.conf` খুলুন
2. `LoadModule rewrite_module modules/mod_rewrite.so` লাইনের শুরু থেকে `#` সরিয়ে দিন
3. Apache রিস্টার্ট করুন

প্রজেক্টে ইতোমধ্যে `.htaccess` ফাইল আছে যা URL রিরাইট করে।

### ❌ বাংলা লেখা ভাঙা দেখায়

phpMyAdmin এ যান → `agrofin` ডাটাবেস → **Operations** → Collation: `utf8mb4_unicode_ci` সিলেক্ট করুন।

## পরবর্তী চাঙ্ক

এটি Chunk 1 (Foundation + Auth + Database)। পরবর্তী চাঙ্কগুলোতে আসবে:
- **Chunk 2:** কৃষক ও ক্রেতার সম্পূর্ণ CRUD (ফসল ব্যবস্থাপনা, অর্ডার, পেমেন্ট)
- **Chunk 3:** এজেন্ট ও অ্যাডমিনের সম্পূর্ণ CRUD
- **Chunk 4:** স্মার্ট ফিচার (অ্যাসিস্ট্যান্ট, আবহাওয়া, সুপারিশ, এনালিটিক্স)

---

কোনো সমস্যা হলে: `support@agrofin.com.bd`
