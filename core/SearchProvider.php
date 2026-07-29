<?php
/**
 * SearchProvider
 * ─────────────────────────────────────────────────────────────
 * Wraps full-text search behind a single interface. Two backends:
 *
 *   meilisearch — Bangla typo tolerance, sub-50ms responses, faceted filters.
 *                 Requires a running MeiliSearch instance (Docker:
 *                   docker run -p 7700:7700 getmeili/meilisearch:latest).
 *
 *   sql (default) — falls back to LIKE-based search via CropModel::search().
 *                   No external service needed; works out of the box.
 *
 * Configure via .env:
 *   SEARCH_DRIVER=sql                  # sql | meilisearch
 *   MEILISEARCH_HOST=http://127.0.0.1:7700
 *   MEILISEARCH_API_KEY=               # optional master key
 *   MEILISEARCH_CROPS_INDEX=crops
 *
 * The marketplace controller treats search() as a black box — it always
 * returns the same shape, regardless of driver.
 * ─────────────────────────────────────────────────────────────
 */
class SearchProvider {

    const CROPS_INDEX = 'crops';

    /** True if MeiliSearch is configured AND reachable. */
    public static function isMeiliAvailable() {
        if (self::driver() !== 'meilisearch') return false;
        // Cheap health probe — cached for 60s so we don't ping on every request
        $cached = Cache::get('search:meili:health');
        if ($cached !== null) return $cached;

        $ok = self::pingMeili();
        Cache::set('search:meili:health', $ok, 60);
        return $ok;
    }

    public static function driver() {
        return Env::get('SEARCH_DRIVER', 'sql');
    }

    /**
     * Search crops. Returns:
     *   ['ok' => bool, 'driver' => 'meilisearch|sql', 'hits' => [crop_id, ...],
     *    'total' => int, 'elapsed_ms' => int, 'error' => string|null]
     *
     * Caller (CropModel/BuyerController) then hydrates crop_id list with full DB rows.
     * This lets us use Meili for ranking but still get fresh data (stock, status) from DB.
     */
    public static function searchCrops($filters, $limit = 24, $offset = 0) {
        $startMs = microtime(true) * 1000;

        if (self::isMeiliAvailable()) {
            $result = self::searchCropsMeili($filters, $limit, $offset);
            $result['elapsed_ms'] = (int)(microtime(true) * 1000 - $startMs);
            if ($result['ok']) return $result;
            // On Meili failure, fall through to SQL
        }

        return [
            'ok' => true,
            'driver' => 'sql',
            'hits' => null,    // null signals: "use SQL search directly"
            'total' => null,
            'elapsed_ms' => (int)(microtime(true) * 1000 - $startMs),
            'error' => null,
        ];
    }

    /** Index one crop (insert or update). Idempotent. */
    public static function indexCrop(array $crop) {
        if (!self::isMeiliAvailable()) return ['ok' => true, 'skipped' => true];

        $doc = self::cropToDocument($crop);
        return self::meiliRequest('POST', '/indexes/' . self::cropsIndexName() . '/documents', [$doc]);
    }

    /** Remove a crop from the search index (e.g. after delete/sold-out). */
    public static function deindexCrop($cropId) {
        if (!self::isMeiliAvailable()) return ['ok' => true, 'skipped' => true];
        return self::meiliRequest('DELETE', '/indexes/' . self::cropsIndexName() . '/documents/' . (int)$cropId);
    }

    /** Bulk-index a list of crop rows. Returns ['ok','count','error']. */
    public static function indexCropsBulk(array $crops) {
        if (!self::isMeiliAvailable()) return ['ok' => true, 'count' => 0, 'skipped' => true];
        $docs = array_map([self::class, 'cropToDocument'], $crops);
        if (empty($docs)) return ['ok' => true, 'count' => 0];
        $res = self::meiliRequest('POST', '/indexes/' . self::cropsIndexName() . '/documents', $docs);
        $res['count'] = count($docs);
        return $res;
    }

    /** Drop and recreate the crops index — used during full rebuild. */
    public static function rebuildCropsIndex() {
        if (!self::isMeiliAvailable()) return ['ok' => false, 'error' => 'MeiliSearch not available'];

        $name = self::cropsIndexName();
        // Delete existing (ignore 404)
        self::meiliRequest('DELETE', '/indexes/' . $name);

        // Create fresh index with crop_id as primary key
        $create = self::meiliRequest('POST', '/indexes', ['uid' => $name, 'primaryKey' => 'crop_id']);
        if (!$create['ok']) return $create;

        // Configure searchable + filterable + sortable attributes
        self::meiliRequest('PATCH', '/indexes/' . $name . '/settings', [
            'searchableAttributes' => ['crop_name', 'crop_variety', 'description', 'farmer_name', 'district_name', 'category_name_bn'],
            'filterableAttributes' => ['category_id', 'district_id', 'quality_grade', 'is_organic', 'price_per_unit', 'status'],
            'sortableAttributes'   => ['price_per_unit', 'created_at_ts', 'views_count'],
            'rankingRules'         => ['words', 'typo', 'proximity', 'attribute', 'sort', 'exactness'],
            'typoTolerance'        => ['enabled' => true, 'minWordSizeForTypos' => ['oneTypo' => 4, 'twoTypos' => 8]],
            // Bangla support: no stop words trimming (keeps full Bangla phrases intact)
            'stopWords' => [],
        ]);

        return ['ok' => true, 'index' => $name];
    }

    /** Admin-page stats. */
    public static function stats() {
        $stats = [
            'driver' => self::driver(),
            'meili_configured' => self::driver() === 'meilisearch',
            'meili_available' => self::isMeiliAvailable(),
            'host' => Env::get('MEILISEARCH_HOST', '—'),
        ];
        if ($stats['meili_available']) {
            $res = self::meiliRequest('GET', '/indexes/' . self::cropsIndexName() . '/stats');
            if ($res['ok']) {
                $stats['documents'] = $res['data']['numberOfDocuments'] ?? 0;
                $stats['is_indexing'] = !empty($res['data']['isIndexing']);
            }
        }
        return $stats;
    }

    // ── MeiliSearch internals ──

    private static function cropsIndexName() {
        return Env::get('MEILISEARCH_CROPS_INDEX', self::CROPS_INDEX);
    }

    private static function pingMeili() {
        $host = trim(Env::get('MEILISEARCH_HOST', ''), '/');
        if (!$host) return false;
        $ch = curl_init($host . '/health');
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 2,
            CURLOPT_CONNECTTIMEOUT => 1,
        ]);
        $resp = curl_exec($ch);
        $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        if ($code !== 200) return false;
        $parsed = json_decode($resp, true) ?: [];
        return ($parsed['status'] ?? '') === 'available';
    }

    private static function searchCropsMeili($filters, $limit, $offset) {
        $query = trim($filters['q'] ?? '');
        $filterClauses = ["status = 'available'"];

        if (!empty($filters['category_id'])) $filterClauses[] = 'category_id = ' . (int)$filters['category_id'];
        if (!empty($filters['district_id'])) $filterClauses[] = 'district_id = ' . (int)$filters['district_id'];
        if (!empty($filters['quality']))     $filterClauses[] = "quality_grade = '" . addslashes($filters['quality']) . "'";
        if (!empty($filters['organic']))     $filterClauses[] = 'is_organic = true';
        if (!empty($filters['min_price']))   $filterClauses[] = 'price_per_unit >= ' . (float)$filters['min_price'];
        if (!empty($filters['max_price']))   $filterClauses[] = 'price_per_unit <= ' . (float)$filters['max_price'];

        $sort = $filters['sort'] ?? 'newest';
        $sortClause = match($sort) {
            'price_low'  => ['price_per_unit:asc'],
            'price_high' => ['price_per_unit:desc'],
            'popular'    => ['views_count:desc'],
            default      => ['created_at_ts:desc'],
        };

        $payload = [
            'q'                  => $query,
            'limit'              => $limit,
            'offset'             => $offset,
            'filter'             => implode(' AND ', $filterClauses),
            'sort'               => $sortClause,
            'attributesToRetrieve' => ['crop_id'],
        ];

        $res = self::meiliRequest('POST', '/indexes/' . self::cropsIndexName() . '/search', $payload);
        if (!$res['ok']) {
            return ['ok' => false, 'driver' => 'meilisearch', 'hits' => [], 'total' => 0, 'error' => $res['error']];
        }
        $hitIds = array_map(fn($h) => (int)($h['crop_id'] ?? 0), $res['data']['hits'] ?? []);
        $hitIds = array_filter($hitIds);
        return [
            'ok' => true,
            'driver' => 'meilisearch',
            'hits' => $hitIds,
            'total' => (int)($res['data']['estimatedTotalHits'] ?? count($hitIds)),
            'error' => null,
        ];
    }

    /** Convert a DB crop row into a MeiliSearch document. */
    private static function cropToDocument(array $crop) {
        return [
            'crop_id'          => (int)$crop['crop_id'],
            'crop_name'        => $crop['crop_name'] ?? '',
            'crop_variety'     => $crop['crop_variety'] ?? '',
            'description'      => $crop['description'] ?? '',
            'category_id'      => (int)($crop['category_id'] ?? 0),
            'category_name_bn' => $crop['category_name_bn'] ?? '',
            'farmer_name'      => $crop['farmer_name'] ?? '',
            'district_id'      => (int)($crop['district_id'] ?? 0),
            'district_name'    => $crop['district_name'] ?? '',
            'quality_grade'    => $crop['quality_grade'] ?? '',
            'is_organic'       => !empty($crop['is_organic']),
            'price_per_unit'   => (float)($crop['price_per_unit'] ?? 0),
            'views_count'      => (int)($crop['views_count'] ?? 0),
            'status'           => $crop['status'] ?? 'available',
            'created_at_ts'    => isset($crop['created_at']) ? strtotime($crop['created_at']) : 0,
        ];
    }

    /** Universal HTTP wrapper for MeiliSearch. */
    private static function meiliRequest($method, $path, $body = null) {
        $host = trim(Env::get('MEILISEARCH_HOST', ''), '/');
        if (!$host) return ['ok' => false, 'error' => 'MEILISEARCH_HOST not configured'];

        $apiKey = Env::get('MEILISEARCH_API_KEY', '');
        $headers = ['Content-Type: application/json'];
        if ($apiKey) $headers[] = 'Authorization: Bearer ' . $apiKey;

        $ch = curl_init($host . $path);
        $opts = [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 5,
            CURLOPT_CONNECTTIMEOUT => 2,
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_HTTPHEADER => $headers,
        ];
        if ($body !== null) $opts[CURLOPT_POSTFIELDS] = json_encode($body, JSON_UNESCAPED_UNICODE);
        curl_setopt_array($ch, $opts);
        $resp = curl_exec($ch);
        $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $err = curl_error($ch);
        curl_close($ch);

        if ($err) return ['ok' => false, 'error' => 'cURL: ' . $err];
        $parsed = json_decode($resp, true);
        if ($code >= 400) {
            $msg = $parsed['message'] ?? "HTTP $code";
            return ['ok' => false, 'error' => $msg, 'data' => $parsed];
        }
        return ['ok' => true, 'data' => $parsed, 'error' => null];
    }
}
