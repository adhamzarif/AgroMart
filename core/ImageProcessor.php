<?php
/**
 * ImageProcessor
 * ─────────────────────────────────────────────────────────────
 * Generates thumb (200x200), medium (800w), and original variants
 * of uploaded images. Uses GD (bundled with PHP); falls back to
 * "use original for all sizes" if GD is unavailable.
 *
 * File layout:
 *   uploads/crops/abc123.jpg              ← original (existing files)
 *   uploads/crops/abc123_thumb.jpg        ← 200x200 square crop
 *   uploads/crops/abc123_medium.jpg       ← 800px wide (aspect preserved)
 *
 * URL via:
 *   upload_url('crops/abc123.jpg')               → original
 *   image_variant_url('crops/abc123.jpg', 'thumb')  → thumb URL (falls back to original)
 *
 * Backward-compatible: existing images without variants still work
 * because image_variant_url() checks file existence and falls back.
 * ─────────────────────────────────────────────────────────────
 */
class ImageProcessor {

    const VARIANT_THUMB = 'thumb';
    const VARIANT_MEDIUM = 'medium';
    const VARIANT_LARGE = 'large';

    const DIMENSIONS = [
        self::VARIANT_THUMB  => ['width' => 200, 'height' => 200, 'mode' => 'crop',  'quality' => 80],
        self::VARIANT_MEDIUM => ['width' => 800, 'height' => 800, 'mode' => 'fit',   'quality' => 85],
        self::VARIANT_LARGE  => ['width' => 1600,'height' => 1600,'mode' => 'fit',   'quality' => 88],
    ];

    /** Quick check whether image processing is available on this PHP install. */
    public static function isAvailable() {
        return extension_loaded('gd') && function_exists('imagecreatefromjpeg');
    }

    /**
     * Generate all variants for a given uploaded file.
     * Called from handle_image_uploads() right after the move succeeds.
     *
     * @param string $absolutePath  full path to the original (e.g. /var/www/AgroFin/uploads/crops/foo.jpg)
     * @return array  ['ok' => bool, 'generated' => ['thumb'=>filename, ...], 'errors' => [...]]
     */
    public static function generateVariants($absolutePath) {
        if (!self::isAvailable()) {
            return ['ok' => false, 'generated' => [], 'errors' => ['GD extension not loaded — using original at all sizes']];
        }
        if (!file_exists($absolutePath)) {
            return ['ok' => false, 'generated' => [], 'errors' => ['Source file not found']];
        }

        $info = @getimagesize($absolutePath);
        if (!$info) {
            return ['ok' => false, 'generated' => [], 'errors' => ['Not a valid image']];
        }

        // Source image
        $srcImg = self::loadImage($absolutePath, $info['mime']);
        if (!$srcImg) {
            return ['ok' => false, 'generated' => [], 'errors' => ['Failed to load source image']];
        }

        $srcW = imagesx($srcImg);
        $srcH = imagesy($srcImg);

        $generated = [];
        $errors = [];

        foreach (self::DIMENSIONS as $variantName => $spec) {
            try {
                $variantPath = self::variantPath($absolutePath, $variantName);

                // Skip variant if it would be LARGER than source (e.g. tiny upload)
                if ($spec['width'] >= $srcW && $spec['height'] >= $srcH && $variantName !== self::VARIANT_THUMB) {
                    continue;
                }

                $resized = self::resizeImage($srcImg, $srcW, $srcH, $spec);
                $saved = self::saveImage($resized, $variantPath, $info['mime'], $spec['quality']);
                imagedestroy($resized);

                if ($saved) {
                    $generated[$variantName] = basename($variantPath);
                } else {
                    $errors[] = "Failed to save $variantName variant";
                }
            } catch (Throwable $e) {
                $errors[] = "$variantName: " . $e->getMessage();
            }
        }

        imagedestroy($srcImg);
        return ['ok' => empty($errors), 'generated' => $generated, 'errors' => $errors];
    }

    /**
     * Translate a filename + variant into a relative path.
     *   variantFilename('abc.jpg', 'thumb')  → 'abc_thumb.jpg'
     */
    public static function variantFilename($originalFilename, $variant) {
        $info = pathinfo($originalFilename);
        $base = $info['filename'];
        $ext = $info['extension'] ?? 'jpg';
        if ($variant === 'original' || !isset(self::DIMENSIONS[$variant])) {
            return $originalFilename;
        }
        return $base . '_' . $variant . '.' . $ext;
    }

    private static function variantPath($absolutePath, $variant) {
        $info = pathinfo($absolutePath);
        return $info['dirname'] . '/' . $info['filename'] . '_' . $variant . '.' . $info['extension'];
    }

    // ── Image manipulation (GD) ──

    private static function loadImage($path, $mime) {
        switch ($mime) {
            case 'image/jpeg':
                return @imagecreatefromjpeg($path);
            case 'image/png':
                $img = @imagecreatefrompng($path);
                if ($img) imagepalettetotruecolor($img);
                return $img;
            case 'image/webp':
                return function_exists('imagecreatefromwebp') ? @imagecreatefromwebp($path) : null;
            default:
                return null;
        }
    }

    private static function saveImage($img, $path, $mime, $quality) {
        switch ($mime) {
            case 'image/jpeg':
                return @imagejpeg($img, $path, $quality);
            case 'image/png':
                // PNG quality: 0 (no compression) – 9 (max compression). Quality 85 → ~3.
                $pngLevel = 9 - (int)round(($quality / 100) * 9);
                return @imagepng($img, $path, $pngLevel);
            case 'image/webp':
                return function_exists('imagewebp') ? @imagewebp($img, $path, $quality) : false;
            default:
                return false;
        }
    }

    private static function resizeImage($srcImg, $srcW, $srcH, array $spec) {
        if ($spec['mode'] === 'crop') {
            return self::cropToSquare($srcImg, $srcW, $srcH, $spec['width']);
        }
        return self::fitWithinBounds($srcImg, $srcW, $srcH, $spec['width'], $spec['height']);
    }

    /** Center-crop to a square then resize to $targetSize × $targetSize. */
    private static function cropToSquare($srcImg, $srcW, $srcH, $targetSize) {
        $side = min($srcW, $srcH);
        $offsetX = (int)(($srcW - $side) / 2);
        $offsetY = (int)(($srcH - $side) / 2);

        $dst = imagecreatetruecolor($targetSize, $targetSize);
        imagealphablending($dst, false);
        imagesavealpha($dst, true);
        $transparent = imagecolorallocatealpha($dst, 0, 0, 0, 127);
        imagefilledrectangle($dst, 0, 0, $targetSize, $targetSize, $transparent);
        imagealphablending($dst, true);

        imagecopyresampled($dst, $srcImg, 0, 0, $offsetX, $offsetY, $targetSize, $targetSize, $side, $side);
        return $dst;
    }

    /** Resize image to fit within $maxW × $maxH while preserving aspect ratio. */
    private static function fitWithinBounds($srcImg, $srcW, $srcH, $maxW, $maxH) {
        $ratio = min($maxW / $srcW, $maxH / $srcH);
        $newW = (int)round($srcW * $ratio);
        $newH = (int)round($srcH * $ratio);

        $dst = imagecreatetruecolor($newW, $newH);
        imagealphablending($dst, false);
        imagesavealpha($dst, true);
        $transparent = imagecolorallocatealpha($dst, 0, 0, 0, 127);
        imagefilledrectangle($dst, 0, 0, $newW, $newH, $transparent);
        imagealphablending($dst, true);

        imagecopyresampled($dst, $srcImg, 0, 0, 0, 0, $newW, $newH, $srcW, $srcH);
        return $dst;
    }

    /**
     * Backfill: scan an uploads/ subdirectory and generate missing variants
     * for every image. Used by the admin maintenance task.
     */
    public static function backfillDirectory($absoluteDir, $callback = null) {
        if (!is_dir($absoluteDir)) return ['ok' => false, 'count' => 0, 'errors' => ["Dir not found: $absoluteDir"]];

        $count = 0;
        $errors = [];
        $files = glob($absoluteDir . '/*.{jpg,jpeg,png,webp}', GLOB_BRACE);
        foreach ($files as $file) {
            $name = basename($file);
            // Skip files that ARE variants (have _thumb / _medium / _large suffix)
            if (preg_match('/_(thumb|medium|large)\./', $name)) continue;

            $info = pathinfo($name);
            $base = $info['filename'];
            $ext = $info['extension'];

            // Skip if all variants already exist
            $allExist = true;
            foreach (array_keys(self::DIMENSIONS) as $v) {
                if (!file_exists($absoluteDir . '/' . $base . '_' . $v . '.' . $ext)) {
                    $allExist = false;
                    break;
                }
            }
            if ($allExist) continue;

            $result = self::generateVariants($file);
            if ($result['ok']) {
                $count++;
                if ($callback) $callback($name, true);
            } else {
                $errors[] = "$name: " . implode(', ', $result['errors']);
                if ($callback) $callback($name, false);
            }
        }
        return ['ok' => empty($errors), 'count' => $count, 'errors' => $errors];
    }
}
