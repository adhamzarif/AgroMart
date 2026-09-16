-- Realistic Bangladesh vegetable supply-chain margins.
-- Farmer gets 35-50% traditionally, 85% on AgroMart (15% platform fee).
-- Safe to re-run.

DELETE FROM supply_chain_margins;

INSERT INTO supply_chain_margins (crop_name, role, share_pct, system) VALUES
-- Traditional (4 hops): farmer, dealer, wholesaler, retailer
('লাউ',       'farmer',     40, 'traditional'),
('লাউ',       'dealer',     10, 'traditional'),
('লাউ',       'wholesaler', 18, 'traditional'),
('লাউ',       'retailer',   32, 'traditional'),

('কাঁচামরিচ', 'farmer',     42, 'traditional'),
('কাঁচামরিচ', 'dealer',      9, 'traditional'),
('কাঁচামরিচ', 'wholesaler', 16, 'traditional'),
('কাঁচামরিচ', 'retailer',   33, 'traditional'),

('বেগুন',     'farmer',     38, 'traditional'),
('বেগুন',     'dealer',     11, 'traditional'),
('বেগুন',     'wholesaler', 17, 'traditional'),
('বেগুন',     'retailer',   34, 'traditional'),

('আলু',       'farmer',     45, 'traditional'),
('আলু',       'dealer',      8, 'traditional'),
('আলু',       'wholesaler', 15, 'traditional'),
('আলু',       'retailer',   32, 'traditional'),

('টমেটো',    'farmer',     37, 'traditional'),
('টমেটো',    'dealer',     10, 'traditional'),
('টমেটো',    'wholesaler', 18, 'traditional'),
('টমেটো',    'retailer',   35, 'traditional'),

('পেঁয়াজ',    'farmer',     43, 'traditional'),
('পেঁয়াজ',    'dealer',      9, 'traditional'),
('পেঁয়াজ',    'wholesaler', 16, 'traditional'),
('পেঁয়াজ',    'retailer',   32, 'traditional'),

('সরিষা',    'farmer',     50, 'traditional'),
('সরিষা',    'dealer',      8, 'traditional'),
('সরিষা',    'wholesaler', 14, 'traditional'),
('সরিষা',    'retailer',   28, 'traditional'),

('মুগ ডাল',   'farmer',     48, 'traditional'),
('মুগ ডাল',   'dealer',      9, 'traditional'),
('মুগ ডাল',   'wholesaler', 15, 'traditional'),
('মুগ ডাল',   'retailer',   28, 'traditional'),

('মসুর ডাল',  'farmer',     46, 'traditional'),
('মসুর ডাল',  'dealer',      9, 'traditional'),
('মসুর ডাল',  'wholesaler', 16, 'traditional'),
('মসুর ডাল',  'retailer',   29, 'traditional'),

-- AgroMart direct: farmer 85%, platform 15%
('লাউ',       'farmer',     85, 'agromart'),
('লাউ',       'platform',   15, 'agromart'),
('কাঁচামরিচ', 'farmer',     85, 'agromart'),
('কাঁচামরিচ', 'platform',   15, 'agromart'),
('বেগুন',     'farmer',     85, 'agromart'),
('বেগুন',     'platform',   15, 'agromart'),
('আলু',       'farmer',     85, 'agromart'),
('আলু',       'platform',   15, 'agromart'),
('টমেটো',    'farmer',     85, 'agromart'),
('টমেটো',    'platform',   15, 'agromart'),
('পেঁয়াজ',    'farmer',     85, 'agromart'),
('পেঁয়াজ',    'platform',   15, 'agromart'),
('সরিষা',    'farmer',     85, 'agromart'),
('সরিষা',    'platform',   15, 'agromart'),
('মুগ ডাল',   'farmer',     85, 'agromart'),
('মুগ ডাল',   'platform',   15, 'agromart'),
('মসুর ডাল',  'farmer',     85, 'agromart'),
('মসুর ডাল',  'platform',   15, 'agromart');
