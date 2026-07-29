<?php
/**
 * Reindex CLI Utility
 * ─────────────────────────────────────────────────────────────
 * Drops + recreates the MeiliSearch index, then bulk-loads every
 * active crop from the database. Run this:
 *   - Once after first installing MeiliSearch
 *   - Whenever you change the index settings
 *   - If the index gets corrupted or out of sync
 *
 * Usage:
 *   php cron/reindex_search.php
 *
 * Idempotent — safe to run multiple times. Won't run if SEARCH_DRIVER != meilisearch.
 */

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    die('CLI only');
}

define('APP_ROOT', dirname(__DIR__));
require APP_ROOT . '/core/Env.php';
Env::load(APP_ROOT . '/.env');
require APP_ROOT . '/config/database.php';
require APP_ROOT . '/core/Model.php';
require APP_ROOT . '/core/Helpers.php';
require APP_ROOT . '/core/Cache.php';
require APP_ROOT . '/core/SearchProvider.php';

spl_autoload_register(function ($class) {
    foreach (['Models', 'Controllers'] as $dir) {
        $f = APP_ROOT . '/' . $dir . '/' . $class . '.php';
        if (file_exists($f)) { require_once $f; return; }
    }
});

echo "──────────────────────────────────────────────────\n";
echo "  AgroFin · MeiliSearch Reindex\n";
echo "──────────────────────────────────────────────────\n";

$driver = SearchProvider::driver();
echo "SEARCH_DRIVER: $driver\n";
if ($driver !== 'meilisearch') {
    echo "✗ SEARCH_DRIVER must be 'meilisearch' to reindex. Edit .env and try again.\n";
    exit(1);
}

if (!SearchProvider::isMeiliAvailable()) {
    echo "✗ MeiliSearch is not reachable at " . Env::get('MEILISEARCH_HOST', '—') . "\n";
    echo "  Is the service running? Try: curl " . Env::get('MEILISEARCH_HOST', 'http://127.0.0.1:7700') . "/health\n";
    exit(1);
}

echo "✓ MeiliSearch reachable.\n";

echo "Rebuilding index...\n";
$rebuild = SearchProvider::rebuildCropsIndex();
if (!$rebuild['ok']) {
    echo "✗ Rebuild failed: " . ($rebuild['error'] ?? 'unknown') . "\n";
    exit(1);
}
echo "✓ Index recreated.\n";

// Load all active crops with their joined data
echo "Loading active crops from DB...\n";
$pdo = (new Model())->pdo();
$stmt = $pdo->query(
    "SELECT c.*, u.full_name AS farmer_name, u.district_id, d.district_name, cat.category_name_bn
     FROM crops c
     JOIN users u ON c.farmer_id = u.user_id
     LEFT JOIN districts d ON u.district_id = d.district_id
     LEFT JOIN crop_categories cat ON c.category_id = cat.category_id
     WHERE c.status = 'available'
     ORDER BY c.crop_id"
);
$crops = $stmt->fetchAll();
echo "  Found " . count($crops) . " active crops.\n";

if (empty($crops)) {
    echo "ℹ No crops to index. Done.\n";
    exit(0);
}

// Bulk index in batches of 500
$batchSize = 500;
$batches = array_chunk($crops, $batchSize);
$totalIndexed = 0;
foreach ($batches as $i => $batch) {
    $res = SearchProvider::indexCropsBulk($batch);
    if (!$res['ok']) {
        echo "✗ Batch " . ($i + 1) . " failed: " . ($res['error'] ?? 'unknown') . "\n";
        continue;
    }
    $totalIndexed += $res['count'];
    echo "  Batch " . ($i + 1) . "/" . count($batches) . " — indexed " . $res['count'] . " crops\n";
}

echo "──────────────────────────────────────────────────\n";
echo "✓ Done. Indexed $totalIndexed crops to MeiliSearch.\n";
echo "Note: MeiliSearch builds the search structures asynchronously.\n";
echo "Wait ~5-10 seconds before testing search on the marketplace.\n";
