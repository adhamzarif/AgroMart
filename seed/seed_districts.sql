INSERT INTO districts (district_id, district_name) VALUES
(1, 'Dhaka'),
(2, 'Chittagong'),
(3, 'Rajshahi'),
(4, 'Khulna'),
(5, 'Sylhet'),
(6, 'Barishal'),
(7, 'Rangpur'),
(8, 'Mymensingh'),
(9, 'Rangamati')
ON CONFLICT (district_id) DO NOTHING;
