<?php
/**
 * Global helper functions used throughout the views and controllers.
 * Keep this file dependency-free.
 */

/** HTML-escape (alias). */
function e($s) {
    return htmlspecialchars((string)$s, ENT_QUOTES | ENT_HTML5, 'UTF-8');
}

/**
 * Convert an English numeral string to Bangla numerals.
 * Works on digits inside any text: "৳ 1,250" -> "৳ ১,২৫০"
 */
function bn_num($value) {
    $bn = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    $s  = (string)$value;
    $out = '';
    $len = strlen($s);
    for ($i = 0; $i < $len; $i++) {
        $c = $s[$i];
        $out .= ctype_digit($c) ? $bn[(int)$c] : $c;
    }
    return $out;
}

/** Format a money amount as Bangla currency: 1250.5 -> "৳ ১,২৫০.৫০" */
function bdt($amount, $decimals = 2) {
    $amount = (float)$amount;
    return '৳ ' . bn_num(number_format($amount, $decimals));
}

/** Format a date (datetime string) to Bangla-friendly text. */
function bn_date($dt, $withTime = false) {
    if (empty($dt) || $dt === '0000-00-00 00:00:00' || $dt === '0000-00-00') return '';
    $t = is_numeric($dt) ? (int)$dt : strtotime($dt);
    if ($t === false) return '';
    $months = [1=>'জানুয়ারি','ফেব্রুয়ারি','মার্চ','এপ্রিল','মে','জুন','জুলাই','আগস্ট','সেপ্টেম্বর','অক্টোবর','নভেম্বর','ডিসেম্বর'];
    $day   = bn_num(date('j', $t));
    $month = $months[(int)date('n', $t)];
    $year  = bn_num(date('Y', $t));
    $out = "$day $month, $year";
    if ($withTime) {
        $h = (int)date('g', $t);
        $m = bn_num(date('i', $t));
        $ampm = date('a', $t) === 'am' ? 'সকাল' : 'বিকাল';
        $out .= ' • ' . $ampm . ' ' . bn_num($h) . ':' . $m;
    }
    return $out;
}

/** Sanitize a string input for safe DB storage (trim + strip control chars). */
function clean_str($s, $max = null) {
    $s = is_string($s) ? trim($s) : '';
    $s = preg_replace('/[\x00-\x1F\x7F]/u', '', $s); // strip control chars
    if ($max !== null && function_exists('mb_substr')) {
        $s = mb_substr($s, 0, $max, 'UTF-8');
    }
    return $s;
}

/** Validate Bangladesh phone (01XXXXXXXXX, 11 digits). */
function is_valid_phone($p) {
    return (bool)preg_match('/^01[0-9]{9}$/', $p);
}

/** Validate email. */
function is_valid_email($e) {
    return (bool)filter_var($e, FILTER_VALIDATE_EMAIL);
}

/** Validate NID number (10, 13, or 17 digits). */
function is_valid_nid($n) {
    return (bool)preg_match('/^[0-9]{10}$|^[0-9]{13}$|^[0-9]{17}$/', $n);
}

/** Build a URL relative to BASE_URL. */
function url($path = '') {
    return BASE_URL . '/' . ltrim($path, '/');
}

/** Build a public uploads URL. */
function upload_url($subpath) {
    return UPLOAD_URL . '/' . ltrim($subpath, '/');
}

/** Friendly time-ago in Bangla. */
function bn_ago($dt) {
    if (empty($dt)) return '';
    $t = is_numeric($dt) ? (int)$dt : strtotime($dt);
    if ($t === false) return '';
    $diff = time() - $t;
    if ($diff < 60)      return bn_num($diff) . ' সেকেন্ড আগে';
    if ($diff < 3600)    return bn_num((int)($diff/60)) . ' মিনিট আগে';
    if ($diff < 86400)   return bn_num((int)($diff/3600)) . ' ঘণ্টা আগে';
    if ($diff < 2592000) return bn_num((int)($diff/86400)) . ' দিন আগে';
    if ($diff < 31536000)return bn_num((int)($diff/2592000)) . ' মাস আগে';
    return bn_num((int)($diff/31536000)) . ' বছর আগে';
}

/** Generate a unique reference/order number. */
function gen_ref($prefix = 'REF') {
    return $prefix . '-' . date('Ymd') . '-' . strtoupper(substr(bin2hex(random_bytes(3)), 0, 6));
}

/** Returns mapping of role keys to Bangla labels. */
function role_labels() {
    return [
        'Farmer' => 'কৃষক',
        'Buyer'  => 'ক্রেতা',
        'Agent'  => 'এজেন্ট',
        'Admin'  => 'অ্যাডমিন',
        'Dual'   => 'কৃষক ও ক্রেতা',
    ];
}

/** Map db role values (lowercase) to canonical session role names. */
function canonical_role($dbRole) {
    return ucfirst(strtolower($dbRole));
}

/**
 * Handle a multi-file image upload to UPLOAD_PATH/$subDir.
 * $filesField is the name in $_FILES (multi: name="images[]").
 * Returns ['files' => [...filenames], 'errors' => [...]].
 */
function handle_image_uploads($filesField, $subDir, $maxFiles = 5, $maxBytes = 3145728) {
    $files = [];
    $errors = [];
    if (empty($_FILES[$filesField])) return ['files' => $files, 'errors' => $errors];
    $f = $_FILES[$filesField];

    // Normalize structure
    $count = is_array($f['name']) ? count($f['name']) : 0;
    if ($count === 0) return ['files' => $files, 'errors' => $errors];
    $count = min($count, $maxFiles);

    $destDir = UPLOAD_PATH . '/' . trim($subDir, '/');
    if (!is_dir($destDir)) @mkdir($destDir, 0775, true);

    // Lazy-load image processor (one-time include)
    require_once __DIR__ . '/ImageProcessor.php';

    for ($i = 0; $i < $count; $i++) {
        if (empty($f['name'][$i])) continue;
        if ($f['error'][$i] === UPLOAD_ERR_NO_FILE) continue;
        if ($f['error'][$i] !== UPLOAD_ERR_OK) { $errors[] = 'আপলোড সমস্যা: ' . $f['name'][$i]; continue; }
        if ($f['size'][$i] > $maxBytes) { $errors[] = $f['name'][$i] . ' ৩ মেগাবাইটের বেশি।'; continue; }
        $info = @getimagesize($f['tmp_name'][$i]);
        if (!$info || !in_array($info['mime'], ['image/jpeg','image/png','image/webp'], true)) {
            $errors[] = $f['name'][$i] . ': শুধু JPG/PNG/WEBP সমর্থিত।'; continue;
        }
        $ext = ['image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp'][$info['mime']];
        $newName = date('Ymd_His') . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
        $destPath = $destDir . '/' . $newName;
        if (@move_uploaded_file($f['tmp_name'][$i], $destPath)) {
            $files[] = $newName;
            // Generate thumb/medium/large variants — non-fatal if it fails
            ImageProcessor::generateVariants($destPath);
        } else {
            $errors[] = $f['name'][$i] . ' সংরক্ষণ ব্যর্থ।';
        }
    }
    return ['files' => $files, 'errors' => $errors];
}

/** Handle a single file upload. Returns filename or null. */
function handle_single_upload($filesField, $subDir, $maxBytes = 2097152, $allowedMimes = null) {
    if (empty($_FILES[$filesField]) || $_FILES[$filesField]['error'] === UPLOAD_ERR_NO_FILE) return null;
    $f = $_FILES[$filesField];
    if ($f['error'] !== UPLOAD_ERR_OK) return null;
    if ($f['size'] > $maxBytes) return null;
    $info = @getimagesize($f['tmp_name']);
    $allowed = $allowedMimes ?: ['image/jpeg','image/png','image/webp'];
    if (!$info || !in_array($info['mime'], $allowed, true)) return null;
    $ext = ['image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp'][$info['mime']];
    $destDir = UPLOAD_PATH . '/' . trim($subDir, '/');
    if (!is_dir($destDir)) @mkdir($destDir, 0775, true);
    $newName = date('Ymd_His') . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
    $destPath = $destDir . '/' . $newName;
    if (!@move_uploaded_file($f['tmp_name'], $destPath)) return null;

    // Generate variants — non-fatal
    require_once __DIR__ . '/ImageProcessor.php';
    ImageProcessor::generateVariants($destPath);
    return $newName;
}

/**
 * Build a URL for a specific image variant, with safe fallback to the original
 * if the variant file doesn't exist. This is what views should use.
 *
 *   image_variant_url('crops/abc.jpg', 'thumb')   → /uploads/crops/abc_thumb.jpg
 *                                                    (or /uploads/crops/abc.jpg if no thumb)
 *
 * @param string $subpath   path relative to uploads/ (e.g. 'crops/abc.jpg')
 * @param string $variant   'thumb', 'medium', 'large', or 'original'
 */
function image_variant_url($subpath, $variant = 'medium') {
    if (empty($subpath)) return '';
    if ($variant === 'original') return upload_url($subpath);

    require_once __DIR__ . '/ImageProcessor.php';
    $variantSub = ImageProcessor::variantFilename(basename($subpath), $variant);
    $variantSubpath = dirname($subpath) . '/' . $variantSub;
    $absolutePath = UPLOAD_PATH . '/' . ltrim($variantSubpath, '/');

    return file_exists($absolutePath)
        ? upload_url($variantSubpath)
        : upload_url($subpath);  // fall back to original
}

/** Pick first image filename from a JSON column. */
function first_image($jsonField, $subDir = 'crops') {
    if (empty($jsonField)) return null;
    $arr = is_array($jsonField) ? $jsonField : json_decode($jsonField, true);
    if (!is_array($arr) || empty($arr)) return null;
    return upload_url($subDir . '/' . $arr[0]);
}

/**
 * Get the first image as a specific variant URL.
 * Falls back to original if variant not generated yet.
 *
 *   first_image_variant($crop['images'], 'thumb')   // for listings
 *   first_image_variant($crop['images'], 'medium')  // for detail pages
 */
function first_image_variant($jsonField, $variant = 'thumb', $subDir = 'crops') {
    if (empty($jsonField)) return null;
    $arr = is_array($jsonField) ? $jsonField : json_decode($jsonField, true);
    if (!is_array($arr) || empty($arr)) return null;
    return image_variant_url($subDir . '/' . $arr[0], $variant);
}
