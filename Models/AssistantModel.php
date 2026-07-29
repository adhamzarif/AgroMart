<?php
/**
 * AssistantModel — rule-based Bangla AI assistant.
 * Recognizes farmer intents (weather, prices, crops, loans, account help)
 * and provides helpful responses pulling from real DB data.
 */
class AssistantModel extends Model {

    /** Intent patterns: regex -> intent code */
    private const INTENT_PATTERNS = [
        // Weather
        '/(আবহাওয়া|আবহাওয়ার|বৃষ্টি|বর্ষণ|ঝড়|বন্যা|খরা|শৈত্য|তাপদাহ|ঘূর্ণিঝড়|weather|rain|storm|flood)/iu' => 'weather',
        // Prices / market
        '/(দাম|মূল্য|বাজার|বিক্রি|price|market|rate|কত টাকা|কত দামে)/iu' => 'price',
        // Crop recommendations
        '/(কোন ফসল|কী চাষ|কি চাষ|সুপারিশ|recommend|suggest|উপযুক্ত ফসল|লাভজনক)/iu' => 'recommendation',
        // Loan
        '/(লোন|ঋণ|টাকা ধার|loan|credit|কিস্তি|ক্রেডিট স্কোর)/iu' => 'loan',
        // Order help
        '/(অর্ডার|ক্রয়|কিনতে|order|purchase|শিপিং|ডেলিভারি|delivery)/iu' => 'order',
        // Profile / account
        '/(একাউন্ট|প্রোফাইল|পাসওয়ার্ড|ভুলে|account|password|profile|verify|যাচাই)/iu' => 'account',
        // Agent help
        '/(এজেন্ট|agent|সাহায্য|হেল্প|help|সমস্যা|problem)/iu' => 'support',
        // Greetings
        '/(সালাম|নমস্কার|হ্যালো|hi|hello|আদাব|শুভ)/iu' => 'greeting',
        // Thanks
        '/(ধন্যবাদ|শুকরিয়া|thanks|thank you)/iu' => 'thanks',
    ];

    /** Process a query and return ['intent','response','data','using_llm']. */
    public function process($userId, $query, $userContext = []) {
        $startMs = microtime(true) * 1000;
        $query = trim($query);
        if ($query === '') {
            return ['intent' => 'empty', 'response' => 'অনুগ্রহ করে কিছু জিজ্ঞাসা করুন।', 'data' => null, 'using_llm' => false];
        }

        $intent = $this->detectIntent($query);
        $result = $this->generateResponse($intent, $query, $userId, $userContext);
        $result['using_llm'] = false;
        $result['tokens_used'] = 0;

        // ── RAG: try LLM if available + intent is data-bearing ──
        // (skip for greeting/thanks/unknown — pure social, no DB context to enrich)
        $llmIntents = ['weather','price','recommendation','loan','order','account','support'];
        if (in_array($intent, $llmIntents, true)) {
            require_once __DIR__ . '/../core/LlmProvider.php';
            if (LlmProvider::isAvailable()) {
                $districtName = null;
                if (!empty($userId)) {
                    $districtName = $this->fetchScalar(
                        "SELECT d.district_name FROM users u
                         LEFT JOIN districts d ON u.district_id = d.district_id
                         WHERE u.user_id = ?", [$userId]
                    );
                }
                $llmCtx = array_merge($userContext, [
                    'user_id' => $userId,
                    'district_name' => $districtName,
                ]);
                $llmResult = LlmProvider::generate($query, $result['data'] ?? null, $llmCtx);
                if ($llmResult['ok'] && trim($llmResult['response']) !== '') {
                    $result['response'] = $llmResult['response'];
                    $result['using_llm'] = true;
                    $result['tokens_used'] = $llmResult['tokens_used'] ?? 0;
                }
                // On failure, keep rule-based response (transparent fallback)
            }
        }

        $responseMs = (int)(microtime(true) * 1000 - $startMs);

        // Log query
        try {
            $this->execute(
                "INSERT INTO assistant_queries (user_id, query_type, query_language, user_query, detected_intent, assistant_response, response_time_ms)
                 VALUES (?, 'text', ?, ?, ?, ?, ?)",
                [$userId, $this->detectLanguage($query), $query, $intent, $result['response'], $responseMs]
            );
            $result['query_id'] = $this->lastInsertId();
        } catch (Throwable $e) { /* non-fatal */ }

        $result['intent'] = $intent;
        $result['response_time_ms'] = $responseMs;
        return $result;
    }

    private function detectIntent($query) {
        foreach (self::INTENT_PATTERNS as $pattern => $intent) {
            if (@preg_match($pattern, $query)) return $intent;
        }
        return 'unknown';
    }

    private function detectLanguage($query) {
        return preg_match('/[\x{0980}-\x{09FF}]/u', $query) ? 'bangla' : 'english';
    }

    private function generateResponse($intent, $query, $userId, $ctx) {
        switch ($intent) {
            case 'weather':   return $this->respWeather($userId);
            case 'price':     return $this->respPrice($query, $userId);
            case 'recommendation': return $this->respRecommend($userId);
            case 'loan':      return $this->respLoan($userId);
            case 'order':     return $this->respOrder($userId, $ctx['role'] ?? null);
            case 'account':   return $this->respAccount();
            case 'support':   return $this->respSupport();
            case 'greeting':  return ['response' => '✋ সালামালাইকুম! আমি AgroFin সহকারী। আপনার কী জিজ্ঞাসা — আবহাওয়া, ফসলের দাম, লোন, অর্ডার, নাকি অন্য কিছু?', 'data' => null];
            case 'thanks':    return ['response' => '🙏 আপনাকে স্বাগতম! আরও কিছু জানতে চাইলে জিজ্ঞাসা করুন।', 'data' => null];
            default:          return $this->respUnknown();
        }
    }

    // ─── INTENT HANDLERS ──────────────────────────────────────────────

    private function respWeather($userId) {
        $row = $this->fetchOne("SELECT district_id FROM users WHERE user_id = ?", [$userId]);
        $districtId = (int)($row['district_id'] ?? 0);
        $alerts = $this->fetchAll(
            "SELECT * FROM weather_alerts
             WHERE is_active = 1 AND JSON_CONTAINS(affected_districts, ?)
             ORDER BY created_at DESC LIMIT 3",
            [(string)$districtId]
        );
        if (empty($alerts)) {
            return ['response' => '☀ আপনার এলাকায় বর্তমানে কোনো আবহাওয়া সতর্কতা নেই। আবহাওয়া স্বাভাবিক বলে মনে হচ্ছে। আরো বিস্তারিত আবহাওয়া দেখতে: /farmer/weather', 'data' => ['alerts' => []]];
        }
        $msg = "⚠ আপনার এলাকায় " . bn_num(count($alerts)) . " টি সক্রিয় সতর্কতা রয়েছে:\n\n";
        foreach ($alerts as $a) {
            $msg .= "• " . $a['alert_title'] . " (" . $a['severity'] . " মাত্রা)\n";
            $msg .= "  " . self::safeTrim($a['alert_message'], 150) . "\n";
            if ($a['recommendations']) {
                $msg .= "  সুপারিশ: " . self::safeTrim($a['recommendations'], 100) . "\n";
            }
            $msg .= "\n";
        }
        $msg .= "বিস্তারিত: /farmer/weather";
        return ['response' => $msg, 'data' => ['alerts' => $alerts]];
    }

    private function respPrice($query, $userId) {
        $row = $this->fetchOne("SELECT district_id FROM users WHERE user_id = ?", [$userId]);
        $districtId = (int)($row['district_id'] ?? 0);

        // Try to extract a crop name from the query (compare against latest market_prices crop names)
        $crops = $this->fetchAll("SELECT DISTINCT crop_name FROM market_prices ORDER BY price_date DESC LIMIT 100");
        $matched = null;
        foreach ($crops as $c) {
            $cn = $c['crop_name'];
            if (mb_stripos($query, $cn, 0, 'UTF-8') !== false || stripos($query, $cn) !== false) {
                $matched = $cn; break;
            }
        }

        if ($matched) {
            $sql = "SELECT mp.*, d.district_name FROM market_prices mp
                    JOIN districts d ON mp.district_id = d.district_id
                    WHERE mp.crop_name = ?";
            $params = [$matched];
            if ($districtId > 0) {
                $sql .= " AND mp.district_id = ?";
                $params[] = $districtId;
            }
            $sql .= " ORDER BY mp.price_date DESC LIMIT 3";
            $rows = $this->fetchAll($sql, $params);
            if (!empty($rows)) {
                $msg = "💰 " . $matched . " এর সাম্প্রতিক মূল্য:\n\n";
                foreach ($rows as $p) {
                    $msg .= "📍 " . $p['district_name'] . " — " . bn_date($p['price_date']) . "\n";
                    $msg .= "  পাইকারি: ৳" . number_format($p['wholesale_price']) . " / " . $p['unit'] . "\n";
                    $msg .= "  খুচরা:   ৳" . number_format($p['retail_price']) . " / " . $p['unit'] . "\n\n";
                }
                $msg .= "সব দাম দেখুন: /liveprice";
                return ['response' => $msg, 'data' => ['prices' => $rows]];
            }
        }
        // Fallback - show top 5 latest prices
        $latest = $this->fetchAll(
            "SELECT mp.*, d.district_name FROM market_prices mp
             JOIN districts d ON mp.district_id = d.district_id
             ORDER BY mp.price_date DESC LIMIT 5"
        );
        $msg = "💹 সাম্প্রতিক বাজার দর:\n\n";
        foreach ($latest as $p) {
            $msg .= "• " . $p['crop_name'] . " (" . $p['district_name'] . ") — পাইকারি ৳" . number_format($p['wholesale_price']) . " / " . $p['unit'] . "\n";
        }
        $msg .= "\nবিস্তারিত: /liveprice — অথবা একটি নির্দিষ্ট ফসলের নাম বলুন (যেমন: 'ধানের দাম কত?')";
        return ['response' => $msg, 'data' => ['prices' => $latest]];
    }

    private function respRecommend($userId) {
        $row = $this->fetchOne("SELECT district_id FROM users WHERE user_id = ?", [$userId]);
        $districtId = (int)($row['district_id'] ?? 0);
        $recs = $this->fetchAll(
            "SELECT * FROM crop_recommendations
             WHERE (farmer_id = ? OR farmer_id IS NULL) AND district_id = ?
             ORDER BY recommendation_score DESC LIMIT 3",
            [$userId, $districtId]
        );
        if (empty($recs)) {
            return ['response' => '🌾 আপনার এলাকার জন্য এখনো কোনো বিশেষ সুপারিশ নেই। সাধারণ পরামর্শ: মৌসুম অনুযায়ী ধান (বোরো/আমন), গম, ভুট্টা, পাট, আলু, সবজি (টমেটো, বেগুন, লাউ) চাষ করতে পারেন। বিশদ ফসল গাইডের জন্য কৃষি সম্প্রসারণ অধিদপ্তরে যোগাযোগ করুন।', 'data' => ['recommendations' => []]];
        }
        $msg = "🌱 আপনার এলাকার জন্য শীর্ষ ফসল সুপারিশ:\n\n";
        foreach ($recs as $r) {
            $msg .= "🌾 " . $r['recommended_crop'] . " — স্কোর " . number_format($r['recommendation_score'], 1) . "/১০০\n";
            $msg .= "   মৌসুম: " . $r['season'] . " | মেয়াদ: " . $r['growing_duration_days'] . " দিন\n";
            $msg .= "   লাভ মার্জিন: " . number_format($r['expected_profit_margin'], 1) . "% | বিনিয়োগ: ৳" . number_format($r['investment_required']) . "\n";
            if ($r['recommendation_reason']) $msg .= "   কারণ: " . self::safeTrim($r['recommendation_reason'], 120) . "\n";
            $msg .= "\n";
        }
        return ['response' => $msg, 'data' => ['recommendations' => $recs]];
    }

    private function respLoan($userId) {
        $loan = $this->fetchOne(
            "SELECT * FROM loans WHERE farmer_id = ? AND status IN ('active','disbursed','approved','pending')
             ORDER BY application_date DESC LIMIT 1",
            [$userId]
        );
        if ($loan) {
            $msg = "💰 আপনার বর্তমান লোন:\n";
            $msg .= "• পরিমাণ: ৳" . number_format($loan['loan_amount']) . "\n";
            $msg .= "• বকেয়া: ৳" . number_format($loan['remaining_balance']) . "\n";
            $msg .= "• মাসিক কিস্তি: ৳" . number_format($loan['monthly_installment']) . "\n";
            $msg .= "• অবস্থা: " . $loan['status'] . "\n";
            if ($loan['next_payment_date']) $msg .= "• পরবর্তী পেমেন্ট: " . bn_date($loan['next_payment_date']) . "\n";
            $msg .= "\nবিস্তারিত: /farmer/loans";
            return ['response' => $msg, 'data' => ['loan' => $loan]];
        }
        return ['response' => "💰 আপনার কোনো সক্রিয় লোন নেই।\n\nAgroFin মাইক্রো-লোন সুবিধা:\n• ৮% সরল সুদ (বার্ষিক)\n• মেয়াদ: ৩-২৪ মাস\n• সর্বোচ্চ: ৳৫০,০০০\n• কোনো জামানত নেই\n• অনুমোদন: ২-৪ কার্যদিবস\n\nআবেদন করুন: /farmer/loans/apply", 'data' => null];
    }

    private function respOrder($userId, $role) {
        if ($role === 'Farmer') {
            $orders = $this->fetchAll(
                "SELECT COUNT(*) AS cnt FROM orders WHERE farmer_id = ? AND order_status IN ('pending','confirmed','shipped')",
                [$userId]
            );
            $cnt = (int)($orders[0]['cnt'] ?? 0);
            $msg = "📦 আপনার সক্রিয় অর্ডার সংখ্যা: " . bn_num($cnt) . " টি\n\n";
            $msg .= "অর্ডার ব্যবস্থাপনা: /farmer/orders\n";
            $msg .= "অর্ডার এর কোনো বিশেষ সমস্যা থাকলে এজেন্টকে টিকেট দিন।";
            return ['response' => $msg, 'data' => ['count' => $cnt]];
        }
        if ($role === 'Buyer') {
            $orders = $this->fetchAll(
                "SELECT COUNT(*) AS cnt FROM orders WHERE buyer_id = ? AND order_status IN ('pending','confirmed','shipped')",
                [$userId]
            );
            $cnt = (int)($orders[0]['cnt'] ?? 0);
            $msg = "📦 আপনার সক্রিয় অর্ডার: " . bn_num($cnt) . " টি\n\n";
            $msg .= "নতুন কেনাকাটা: /buyer/browse\n";
            $msg .= "আমার অর্ডার: /buyer/orders";
            return ['response' => $msg, 'data' => ['count' => $cnt]];
        }
        return ['response' => "অর্ডার ব্যবস্থাপনা ক্রেতা ও কৃষকদের জন্য। আপনার ভূমিকা অনুযায়ী মেনু থেকে অর্ডার দেখুন।", 'data' => null];
    }

    private function respAccount() {
        return ['response' => "🔐 অ্যাকাউন্ট সহায়তা:\n\n• প্রোফাইল আপডেট: /profile\n• পাসওয়ার্ড পরিবর্তন: /profile (পাসওয়ার্ড সেকশন)\n• ফোন/ইমেল যাচাইকরণ: একজন এজেন্টের সাথে যোগাযোগ করুন\n• লগআউট: উপরের ডানদিকের মেনু থেকে\n\nঅন্য কোনো সমস্যা হলে সাপোর্ট টিকেট খুলুন।", 'data' => null];
    }

    private function respSupport() {
        return ['response' => "🤝 সাহায্য পেতে:\n\n১. এজেন্টের সাথে যোগাযোগ করুন (যদি এসাইন্ড থাকে)\n২. সাপোর্ট টিকেট খুলুন (আপনার সমস্যা বিস্তারিত লিখুন)\n৩. বার্তা পাঠান: /farmer/messages\n\nজরুরি সমস্যার জন্য 'urgent' প্রায়োরিটি দিন।", 'data' => null];
    }

    private function respUnknown() {
        return ['response' => "🤔 দুঃখিত, আমি ঠিকমতো বুঝতে পারিনি। আমি যেসব বিষয়ে সহায়তা করতে পারি:\n\n• 🌧 আবহাওয়া সতর্কতা — 'আবহাওয়া কেমন?'\n• 💰 বাজার দর — 'টমেটোর দাম কত?'\n• 🌾 ফসল সুপারিশ — 'কোন ফসল লাভজনক?'\n• 💳 লোন তথ্য — 'আমার লোনের অবস্থা?'\n• 📦 অর্ডার তথ্য — 'আমার অর্ডার?'\n• 🔐 অ্যাকাউন্ট সাহায্য — 'পাসওয়ার্ড পরিবর্তন'\n\nবাংলায় বা ইংরেজিতে জিজ্ঞাসা করুন।", 'data' => null];
    }

    // ─── HISTORY / FEEDBACK ─────────────────────────────────────────────

    public function history($userId, $limit = 50) {
        return $this->fetchAll(
            "SELECT * FROM assistant_queries WHERE user_id = ? ORDER BY created_at DESC LIMIT $limit",
            [$userId]
        );
    }

    public function recordFeedback($queryId, $userId, $wasHelpful, $feedbackText = null) {
        return $this->execute(
            "UPDATE assistant_queries SET was_helpful = ?, feedback_text = ?
             WHERE query_id = ? AND user_id = ?",
            [$wasHelpful ? 1 : 0, $feedbackText, $queryId, $userId]
        );
    }

    /** Admin: aggregated stats on assistant usage. */
    public function adminStats() {
        return $this->fetchOne(
            "SELECT COUNT(*) AS total_queries,
                    COUNT(DISTINCT user_id) AS unique_users,
                    SUM(CASE WHEN was_helpful = 1 THEN 1 ELSE 0 END) AS helpful_count,
                    SUM(CASE WHEN was_helpful = 0 THEN 1 ELSE 0 END) AS unhelpful_count,
                    AVG(response_time_ms) AS avg_response_ms
             FROM assistant_queries"
        );
    }

    /**
     * UTF-8-safe truncate that works whether or not the mbstring extension
     * is loaded. Falls back to byte-level truncation that respects multi-byte
     * codepoint boundaries (so Bangla text is never cut mid-character).
     */
    private static function safeTrim($s, $maxBytes) {
        if (!is_string($s) || $s === '') return '';
        if (function_exists('mb_substr')) {
            return mb_substr($s, 0, $maxBytes, 'UTF-8');
        }
        if (strlen($s) <= $maxBytes) return $s;
        $truncated = substr($s, 0, $maxBytes);
        // Drop trailing partial UTF-8 sequence (bytes with high bit set)
        while (strlen($truncated) > 0
               && (ord($truncated[strlen($truncated) - 1]) & 0xC0) === 0x80) {
            $truncated = substr($truncated, 0, -1);
        }
        if (strlen($truncated) > 0
            && (ord($truncated[strlen($truncated) - 1]) & 0x80) !== 0) {
            $truncated = substr($truncated, 0, -1);
        }
        return $truncated;
    }
}
