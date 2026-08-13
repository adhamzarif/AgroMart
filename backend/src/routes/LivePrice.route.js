const express = require('express');
const router = express.Router();

const db = require('../config/db');


router.get('/', async (req, res) => {
    try {
        const query = `
            SELECT mp.id, mp.name, mp.category AS cat, mp.market_price AS market, 
                   mp.unit, mp.trend, mp.emoji, mp.bg_color AS bg, mp.image_url,
                   COALESCE(AVG(c.price), mp.market_price) AS agrofin,
                   COUNT(c.id) AS farmer_count
            FROM market_prices mp
            LEFT JOIN crops c ON LOWER(c.name) = LOWER(mp.name) AND c.status = 'active'
            GROUP BY mp.id;
        `;
        const { rows } = await db.query(query);

        const crops = rows.map(row => {
            const agrofin = parseFloat(row.agrofin || 0);
            const market = parseFloat(row.market || 0);
            const gap = market ? Math.abs(market - agrofin).toFixed(2) : null;
            return {
                ...row,
                agrofin,
                market,
                gap,
                gap_positive: market > agrofin
            };
        });

        res.json({ success: true, crops });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

module.exports = router;