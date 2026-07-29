<?php
/**
 * LivepriceController — AUDIENCE-AWARE (Path A)
 * ─────────────────────────────────────────────────────────────
 * Shows real farmer prices from the `crops` table joined with the
 * external market reference from `market_prices`. The framing of the
 * comparison ADAPTS to who is looking:
 *
 *   - Anonymous visitor       → "buyer" view (default)
 *   - Logged-in buyer         → "buyer" view
 *   - Logged-in farmer        → "farmer" view (price-setting guidance)
 *   - Dual-role (active=X)    → view matches their active_role
 *   - Admin / Agent           → "buyer" view + small viewer badge
 *
 * Anonymous visitors can manually toggle via /liveprice/setView/farmer
 * (the choice is remembered in their session). Logged-in users cannot
 * override their role-based view — they use the existing role-switch
 * mechanism instead.
 *
 * The underlying data is the same; only labels, button text, empty-state
 * copy, and the "savings vs extra income" framing change.
 */
class LivepriceController extends Controller {

    /** Visual + display metadata per crop name. Unknown crops get a fallback. */
    private static $cropMeta = [
        'বোরো ধান'   => ['emoji'=>'🌾','bg'=>'#fff8e1','cat'=>'দানাশস্য'],
        'আমন ধান'    => ['emoji'=>'🌾','bg'=>'#fff8e1','cat'=>'দানাশস্য'],
        'ব্রি ধান-২৮' => ['emoji'=>'🌾','bg'=>'#fff8e1','cat'=>'দানাশস্য'],
        'গম'         => ['emoji'=>'🌾','bg'=>'#fffde7','cat'=>'দানাশস্য'],
        'ভুট্টা'     => ['emoji'=>'🌽','bg'=>'#fff9c4','cat'=>'দানাশস্য'],
        'আলু'        => ['emoji'=>'🥔','bg'=>'#f0f7ee','cat'=>'শাকসবজি'],
        'টমেটো'      => ['emoji'=>'🍅','bg'=>'#ffebee','cat'=>'শাকসবজি'],
        'গাজর'       => ['emoji'=>'🥕','bg'=>'#fff3e0','cat'=>'শাকসবজি'],
        'বেগুন'      => ['emoji'=>'🍆','bg'=>'#ede7f6','cat'=>'শাকসবজি'],
        'পালং শাক'   => ['emoji'=>'🥬','bg'=>'#e8f5e9','cat'=>'শাকসবজি'],
        'লাউ'        => ['emoji'=>'🥒','bg'=>'#e8f5e9','cat'=>'শাকসবজি'],
        'কুমড়া'      => ['emoji'=>'🎃','bg'=>'#fff3e0','cat'=>'শাকসবজি'],
        'মুলা'       => ['emoji'=>'🥬','bg'=>'#f1f8e9','cat'=>'শাকসবজি'],
        'ঢেঁড়স'      => ['emoji'=>'🥒','bg'=>'#e8f5e9','cat'=>'শাকসবজি'],
        'শসা'        => ['emoji'=>'🥒','bg'=>'#e8f5e9','cat'=>'শাকসবজি'],
        'পেঁয়াজ'      => ['emoji'=>'🧅','bg'=>'#f3e5f5','cat'=>'মশলা'],
        'রসুন'       => ['emoji'=>'🧄','bg'=>'#f9fbe7','cat'=>'মশলা'],
        'কাঁচামরিচ'  => ['emoji'=>'🌶️','bg'=>'#fce4ec','cat'=>'মশলা'],
        'আদা'        => ['emoji'=>'🫚','bg'=>'#fff3e0','cat'=>'মশলা'],
        'হলুদ'       => ['emoji'=>'🌶️','bg'=>'#fff9c4','cat'=>'মশলা'],
        'আম'         => ['emoji'=>'🥭','bg'=>'#fff8e1','cat'=>'ফলমূল'],
        'কলা'        => ['emoji'=>'🍌','bg'=>'#fffde7','cat'=>'ফলমূল'],
        'কাঁঠাল'     => ['emoji'=>'🌳','bg'=>'#fff8e1','cat'=>'ফলমূল'],
        'লিচু'       => ['emoji'=>'🍒','bg'=>'#ffebee','cat'=>'ফলমূল'],
        'লেবু'       => ['emoji'=>'🍋','bg'=>'#f9fbe7','cat'=>'ফলমূল'],
        'নারিকেল'    => ['emoji'=>'🥥','bg'=>'#efebe9','cat'=>'ফলমূল'],
        'পেঁপে'      => ['emoji'=>'🥭','bg'=>'#fff3e0','cat'=>'ফলমূল'],
    ];

    public function index() {
        $pdo = \Database::getInstance()->getConnection();

        // ── 1. Decide which view to render (the "audience") ────────────
        $viewMode      = self::decideViewMode();    // 'buyer' | 'farmer'
        $isAnonymous   = empty($_SESSION['user_id']);
        $isStaff       = !$isAnonymous && in_array(($_SESSION['active_role'] ?? ''), ['Admin', 'Agent'], true);
        // Dual-role users have multiple roles registered — they can toggle
        $availableRoles = $_SESSION['available_roles'] ?? [];
        $isDualRole     = count(array_intersect($availableRoles, ['Buyer', 'Farmer'])) >= 2;
        // Anonymous users get the manual toggle too
        $canToggle      = $isAnonymous || $isDualRole;

        // ── 2. Pull aggregated farmer prices from `crops` ─────────────
        $rows = $pdo->query("
            SELECT
                c.crop_name,
                ROUND(AVG(c.price_per_unit), 0)  AS agrofin_price,
                MIN(c.price_per_unit)             AS min_price,
                MAX(c.price_per_unit)             AS max_price,
                COUNT(*)                          AS farmer_count,
                SUM(c.quantity)                   AS total_stock,
                MAX(c.unit)                       AS unit,
                MAX(c.created_at)                 AS latest_listing,
                (SELECT mp.retail_price
                 FROM market_prices mp
                 WHERE mp.crop_name COLLATE utf8mb4_unicode_ci = c.crop_name COLLATE utf8mb4_unicode_ci
                 ORDER BY mp.price_date DESC, mp.created_at DESC
                 LIMIT 1) AS market_retail_price,
                (SELECT c2.images
                 FROM crops c2
                 WHERE c2.crop_name COLLATE utf8mb4_unicode_ci = c.crop_name COLLATE utf8mb4_unicode_ci
                   AND c2.images IS NOT NULL
                   AND c2.images <> '[]'
                   AND c2.images <> ''
                 ORDER BY c2.created_at DESC
                 LIMIT 1) AS sample_images
            FROM crops c
            JOIN users u ON c.farmer_id = u.user_id
            WHERE c.status = 'available'
              AND c.quantity > 0
              AND u.account_status = 'active'
              AND EXISTS (
                  SELECT 1 FROM user_roles ur
                  WHERE ur.user_id = u.user_id AND ur.role = 'farmer'
              )
            GROUP BY c.crop_name
            ORDER BY c.crop_name
        ")->fetchAll(\PDO::FETCH_ASSOC);

        // ── 3. Pull trend baseline (yesterday's farmer prices) ────────
        $prevPrices = [];
        try {
            $prevStmt = $pdo->query("
                SELECT crop_name, AVG(price_per_unit) AS avg_price
                FROM crops
                WHERE DATE(updated_at) BETWEEN CURDATE() - INTERVAL 7 DAY AND CURDATE() - INTERVAL 1 DAY
                  AND status IN ('available','sold','expired')
                GROUP BY crop_name
            ");
            foreach ($prevStmt as $r) {
                $prevPrices[$r['crop_name']] = (float)$r['avg_price'];
            }
        } catch (\Throwable $e) {
            $prevPrices = [];
        }

        // ── 4. Build the array structure the view expects ─────────────
        $crops = [];
        $totalGap  = 0.0;
        $totalRef  = 0.0;

        foreach ($rows as $row) {
            $name           = $row['crop_name'];
            $agrofinPrice   = (float)$row['agrofin_price'];
            $marketPrice    = $row['market_retail_price'] !== null
                                ? (float)$row['market_retail_price']
                                : null;
            $farmerCount    = (int)$row['farmer_count'];
            $unit           = $row['unit'] ?? 'kg';

            // Calculate the gap in either direction
            $gap = null;
            if ($marketPrice !== null) {
                $gap = $marketPrice - $agrofinPrice;
                if (abs($gap) > 0) {
                    $totalGap += abs($gap);
                    $totalRef += $marketPrice;
                }
            }

            // Trend
            $trend = 'flat';
            if (isset($prevPrices[$name]) && $prevPrices[$name] > 0) {
                $diffPct = (($agrofinPrice - $prevPrices[$name]) / $prevPrices[$name]) * 100;
                if ($diffPct > 2)       $trend = 'up';
                elseif ($diffPct < -2)  $trend = 'down';
            }

            $meta = self::$cropMeta[$name] ?? ['emoji'=>'🌱','bg'=>'#f1f8e9','cat'=>'অন্যান্য'];

            // Resolve a real farmer-uploaded image (if any farmer listed photos for this crop)
            $imageUrl = first_image_variant($row['sample_images'] ?? null, 'thumb');

            $crops[] = [
                'name'         => $name,
                'cat'          => $meta['cat'],
                'emoji'        => $meta['emoji'],
                'bg'           => $meta['bg'],
                'image_url'    => $imageUrl,
                'agrofin'      => bn_num(number_format($agrofinPrice, 0)),
                'market'       => $marketPrice !== null ? bn_num(number_format($marketPrice, 0)) : null,
                'gap'          => $gap !== null ? bn_num(number_format(abs($gap), 0)) : null,
                'gap_positive' => $gap !== null && $gap > 0,  // market > agrofin = buyer saves / farmer could charge more
                'unit'         => self::unitToBangla($unit),
                'trend'        => $trend,
                'farmer_count' => $farmerCount,
                'has_market'   => $marketPrice !== null,
            ];
        }

        // ── 5. Header stats ───────────────────────────────────────────
        $totalProducts = count($crops);
        $totalFarmers  = (int)$pdo->query("
            SELECT COUNT(DISTINCT c.farmer_id)
            FROM crops c
            JOIN users u ON c.farmer_id = u.user_id
            WHERE c.status = 'available' AND c.quantity > 0 AND u.account_status = 'active'
        ")->fetchColumn();
        $avgGapPct     = $totalRef > 0 ? (int)round(($totalGap / $totalRef) * 100) : 0;
        $lastUpdated   = $rows[0]['latest_listing'] ?? null;

        $title = 'লাইভ মার্কেট প্রাইস | AgroFin';
        $this->view('liveprice/index', compact(
            'title', 'crops', 'totalProducts', 'totalFarmers',
            'avgGapPct', 'lastUpdated',
            'viewMode', 'isAnonymous', 'isStaff', 'canToggle'
        ));
    }

    /**
     * Manual view toggle — sets a session flag so anonymous + dual-role users
     * can override the auto-detected view.
     *
     *   GET /liveprice/setView/farmer
     *   GET /liveprice/setView/buyer
     */
    public function setView($mode = null) {
        if (in_array($mode, ['farmer', 'buyer'], true)) {
            $_SESSION['liveprice_view_pref'] = $mode;
        }
        $this->redirect('/liveprice');
    }

    /** Resolve which framing to use based on session state + manual override. */
    private static function decideViewMode() {
        // 1. Explicit toggle override (highest priority for anonymous + dual-role)
        $pref = $_SESSION['liveprice_view_pref'] ?? null;

        // 2. Anonymous → use pref if set, else default to 'buyer'
        if (empty($_SESSION['user_id'])) {
            return $pref ?: 'buyer';
        }

        // 3. Logged-in: derive from active_role
        $role = $_SESSION['active_role'] ?? '';
        if ($role === 'Farmer') {
            // Dual-role farmer can still flip via pref
            return $pref === 'buyer' ? 'buyer' : 'farmer';
        }
        if ($role === 'Buyer') {
            return $pref === 'farmer' ? 'farmer' : 'buyer';
        }
        // Admin / Agent / unknown → buyer view (they monitor what buyers see)
        return 'buyer';
    }

    /** Convert unit code from `crops.unit` to Bangla. */
    private static function unitToBangla($unit) {
        return [
            'kg'    => 'কেজি',
            'ton'   => 'টন',
            'mon'   => 'মণ',
            'piece' => 'পিস',
            'dozen' => 'ডজন',
            'bunch' => 'আঁটি',
            'liter' => 'লিটার',
            'gram'  => 'গ্রাম',
        ][$unit] ?? $unit;
    }
}
