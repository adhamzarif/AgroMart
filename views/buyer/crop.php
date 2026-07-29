<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<?php
$images = !empty($crop['images']) ? (is_array($crop['images']) ? $crop['images'] : (json_decode($crop['images'], true) ?: [])) : [];
?>

<style>
.crop-detail-grid { display: grid; grid-template-columns: 1.2fr 1fr; gap: 24px; }
@media (max-width: 800px) { .crop-detail-grid { grid-template-columns: 1fr; } }
.gallery-main { background: linear-gradient(135deg, #c8e6c9, #e8f5e9); border-radius: 14px; height: 360px; display: flex; align-items: center; justify-content: center; font-size: 100px; overflow: hidden; margin-bottom: 12px; }
.gallery-main img { width: 100%; height: 100%; object-fit: cover; }
.gallery-thumbs { display: flex; gap: 8px; overflow-x: auto; }
.gallery-thumb { width: 72px; height: 72px; border-radius: 8px; object-fit: cover; cursor: pointer; border: 2px solid transparent; transition: border 0.2s; flex-shrink: 0; }
.gallery-thumb:hover, .gallery-thumb.active { border-color: var(--m1-primary); }
.spec-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid var(--gray-100); font-size: 14px; }
.spec-row:last-child { border-bottom: 0; }
.spec-label { color: var(--gray-500); font-size: 12px; }
.f-input { width: 100%; padding: 10px 12px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; }
.f-input:focus { border-color: var(--m1-primary); }
.review-card { padding: 14px; border: 1px solid var(--gray-100); border-radius: 10px; margin-bottom: 10px; background: #fafafa; }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/buyer/browse">ব্রাউজ</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> ফসল বিস্তারিত</div>
                <h1><?= e($crop['crop_name']) ?></h1>
            </div>
            <form method="POST" action="<?= BASE_URL ?>/buyer/favorites/toggle-crop/<?= (int)$crop['crop_id'] ?>" style="display:inline;">
                <?= Csrf::field() ?>
                <button type="submit" class="nav-pill-btn <?= $isFavorite ? 'primary' : 'ghost' ?>">
                    <i class="bi bi-heart<?= $isFavorite ? '-fill' : '' ?>"></i> <?= $isFavorite ? 'পছন্দ থেকে সরান' : 'পছন্দে যোগ করুন' ?>
                </button>
            </form>
        </div>

        <div class="crop-detail-grid">
            <!-- Left: Images + Info -->
            <div>
                <div class="dash-card" style="margin: 0;">
                    <div class="gallery-main" id="galleryMain">
                        <?php if (!empty($images)): ?>
                            <img src="<?= e(image_variant_url('crops/' . $images[0], 'medium')) ?>" alt="">
                        <?php else: ?>
                            🌾
                        <?php endif; ?>
                    </div>
                    <?php if (count($images) > 1): ?>
                    <div class="gallery-thumbs">
                        <?php foreach ($images as $i => $img):
                            $thumbUrl = image_variant_url('crops/' . $img, 'thumb');
                            $mediumUrl = image_variant_url('crops/' . $img, 'medium');
                        ?>
                            <img src="<?= e($thumbUrl) ?>" class="gallery-thumb <?= $i == 0 ? 'active' : '' ?>" onclick="document.getElementById('galleryMain').innerHTML = '<img src=\'<?= e($mediumUrl) ?>\'>'; document.querySelectorAll('.gallery-thumb').forEach(t=>t.classList.remove('active')); this.classList.add('active');">
                        <?php endforeach; ?>
                    </div>
                    <?php endif; ?>
                </div>

                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-info-circle"></i> বিস্তারিত তথ্য</h3>
                    <?php if ($crop['description']): ?>
                        <p style="color:var(--gray-700); margin-bottom: 18px;"><?= nl2br(e($crop['description'])) ?></p>
                    <?php endif; ?>
                    <div class="spec-row"><span class="spec-label">ক্যাটাগরি</span><strong><?= e($crop['category_name_bn']) ?></strong></div>
                    <?php if ($crop['crop_variety']): ?>
                        <div class="spec-row"><span class="spec-label">জাত</span><strong><?= e($crop['crop_variety']) ?></strong></div>
                    <?php endif; ?>
                    <div class="spec-row"><span class="spec-label">উপলব্ধ পরিমাণ</span><strong><?= bn_num($crop['quantity']) ?> <?= e($crop['unit']) ?></strong></div>
                    <div class="spec-row"><span class="spec-label">প্রতি এককের মূল্য</span><strong style="color:var(--m1-primary); font-size:16px;"><?= bdt($crop['price_per_unit'], 2) ?></strong></div>
                    <div class="spec-row"><span class="spec-label">মান গ্রেড</span><span class="badge badge-info">Grade <?= e($crop['quality_grade']) ?></span></div>
                    <div class="spec-row"><span class="spec-label">জৈব পদ্ধতি</span><strong><?= $crop['is_organic'] ? '✓ হ্যাঁ' : 'না' ?></strong></div>
                    <?php if ($crop['harvest_date']): ?>
                        <div class="spec-row"><span class="spec-label">ফসল কাটার তারিখ</span><strong><?= bn_date($crop['harvest_date']) ?></strong></div>
                    <?php endif; ?>
                    <div class="spec-row"><span class="spec-label">উপলব্ধ সময়</span><strong><?= bn_date($crop['available_from']) ?> <?= $crop['available_until'] ? '— ' . bn_date($crop['available_until']) : '' ?></strong></div>
                </div>

                <!-- Reviews -->
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-star-fill" style="color:#f57c00"></i> কৃষকের রিভিউ</h3>
                    <?php if (empty($ratings)): ?>
                        <p style="color:var(--gray-500); text-align:center; padding:18px;">এখনো কোনো রিভিউ নেই।</p>
                    <?php else: foreach ($ratings as $r): ?>
                        <div class="review-card">
                            <div style="display:flex; justify-content:space-between; margin-bottom:6px;">
                                <strong><?= e($r['buyer_name']) ?></strong>
                                <span style="color:#f57c00; font-weight:700;">⭐ <?= bn_num(number_format($r['overall_rating'], 1)) ?></span>
                            </div>
                            <?php if ($r['review_title']): ?><div style="font-weight:600; font-size:13px; margin-bottom:4px;"><?= e($r['review_title']) ?></div><?php endif; ?>
                            <?php if ($r['review_text']): ?><div style="font-size:13px; color:var(--gray-700);"><?= e($r['review_text']) ?></div><?php endif; ?>
                            <div style="font-size:11px; color:var(--gray-400); margin-top:6px;"><?= bn_date($r['created_at']) ?></div>
                        </div>
                    <?php endforeach; endif; ?>
                </div>
            </div>

            <!-- Right: Farmer + Order -->
            <div>
                <div class="dash-card" style="border-left: 4px solid var(--m1-primary);">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-person-circle"></i> কৃষকের তথ্য</h3>
                    <div style="display:flex; align-items:center; gap:12px; margin-bottom:12px;">
                        <div style="width:56px; height:56px; border-radius:50%; background: var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:24px;"><?= e(mb_substr($crop['farmer_name'], 0, 1, 'UTF-8')) ?></div>
                        <div>
                            <strong style="font-size:16px;"><?= e($crop['farmer_name']) ?></strong>
                            <?php if ($crop['district_name']): ?><div style="font-size:12px; color:var(--gray-500);"><i class="bi bi-geo-alt"></i> <?= e($crop['district_name']) ?><?= $crop['division'] ? ', ' . e($crop['division']) : '' ?></div><?php endif; ?>
                            <?php if ($crop['farmer_rating'] > 0): ?>
                                <div style="font-size:12px; color:#f57c00; margin-top:2px;">⭐ <?= bn_num(number_format($crop['farmer_rating'], 1)) ?> (<?= bn_num($crop['farmer_rating_count']) ?> রিভিউ)</div>
                            <?php endif; ?>
                        </div>
                    </div>
                    <a href="<?= BASE_URL ?>/buyer/messages/with/<?= (int)$crop['farmer_id'] ?>" class="nav-pill-btn ghost" style="width:100%; justify-content:center;"><i class="bi bi-chat-dots"></i> কৃষককে বার্তা পাঠান</a>
                </div>

                <!-- Order Form -->
                <?php if ($crop['status'] === 'available' && $crop['quantity'] > 0): ?>
                <div class="dash-card" style="border-left: 4px solid var(--m1-primary); background: linear-gradient(135deg, #e8f5e9, #fff);">
                    <h3 style="margin:0 0 14px; color:var(--m1-primary);"><i class="bi bi-bag-plus"></i> অর্ডার দিন</h3>
                    <form method="POST" action="<?= BASE_URL ?>/buyer/order">
                        <?= Csrf::field() ?>
                        <input type="hidden" name="crop_id" value="<?= (int)$crop['crop_id'] ?>">

                        <div style="margin-bottom:12px;">
                            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">পরিমাণ (<?= e($crop['unit']) ?>) *</label>
                            <input type="number" name="quantity" id="qtyInput" class="f-input" step="0.01" min="0.01" max="<?= $crop['quantity'] ?>" value="1" required oninput="updateTotal()">
                            <div style="font-size:11px; color:var(--gray-500); margin-top:4px;">উপলব্ধ: <?= bn_num($crop['quantity']) ?> <?= e($crop['unit']) ?></div>
                        </div>

                        <div style="margin-bottom:12px;">
                            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">ডেলিভারি প্রকার *</label>
                            <select name="delivery_type" class="f-input">
                                <option value="home_delivery">🏠 হোম ডেলিভারি (+৳৫০)</option>
                                <option value="self_pickup">🚶 সেলফ পিকআপ (ফ্রি)</option>
                            </select>
                        </div>

                        <div style="margin-bottom:12px;">
                            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">ডেলিভারি ঠিকানা</label>
                            <input type="text" name="delivery_address" class="f-input" placeholder="ঠিকানা" value="<?= e($_SESSION['address'] ?? '') ?>">
                        </div>

                        <div style="margin-bottom:12px;">
                            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">জেলা</label>
                            <select name="delivery_district_id" class="f-input">
                                <option value="">— নির্বাচন করুন —</option>
                                <?php foreach ($districts as $d): ?>
                                    <option value="<?= (int)$d['district_id'] ?>" <?= ($_SESSION['district_id'] ?? 0) == $d['district_id'] ? 'selected' : '' ?>><?= e($d['district_name']) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>

                        <div style="margin-bottom:12px;">
                            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">পছন্দের ডেলিভারি তারিখ</label>
                            <input type="date" name="preferred_delivery_date" class="f-input" min="<?= date('Y-m-d') ?>" value="<?= date('Y-m-d', strtotime('+3 days')) ?>">
                        </div>

                        <div style="margin-bottom:14px;">
                            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">বিশেষ নির্দেশনা</label>
                            <textarea name="special_instructions" class="f-input" rows="2" style="resize:vertical; font-family:inherit;"></textarea>
                        </div>

                        <div style="padding:14px; background:#fff; border-radius:10px; margin-bottom:14px; border:1.5px dashed var(--m1-primary);">
                            <div style="display:flex; justify-content:space-between; font-size:13px; margin-bottom:4px;">
                                <span>সাবটোটাল</span><strong id="subTotal"><?= bdt($crop['price_per_unit'], 0) ?></strong>
                            </div>
                            <div style="display:flex; justify-content:space-between; font-size:13px; margin-bottom:8px;">
                                <span>ডেলিভারি চার্জ</span><span>৳৫০</span>
                            </div>
                            <div style="display:flex; justify-content:space-between; font-size:16px; font-weight:700; color:var(--m1-primary); border-top: 1px solid var(--gray-100); padding-top: 6px;">
                                <span>মোট</span><span id="grandTotal"><?= bdt($crop['price_per_unit'] + 50, 0) ?></span>
                            </div>
                        </div>

                        <button type="submit" class="nav-pill-btn primary" style="width:100%; justify-content:center; padding: 12px;"><i class="bi bi-check2-circle"></i> অর্ডার নিশ্চিত করুন</button>
                    </form>
                </div>
                <?php else: ?>
                <div class="alert alert-warning"><i class="bi bi-x-circle"></i> এই ফসলটি বর্তমানে অর্ডারের জন্য উপলব্ধ নয়।</div>
                <?php endif; ?>
            </div>
        </div>
    </main>
</div>
</div>

<script>
var price = <?= (float)$crop['price_per_unit'] ?>;
var delivery = 50;
function updateTotal() {
    var qty = parseFloat(document.getElementById('qtyInput').value) || 0;
    var sub = qty * price;
    var fmt = function(n) { return '৳' + n.toFixed(0).replace(/\B(?=(\d{3})+(?!\d))/g, ','); };
    document.getElementById('subTotal').textContent = fmt(sub);
    document.getElementById('grandTotal').textContent = fmt(sub + delivery);
}
</script>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
