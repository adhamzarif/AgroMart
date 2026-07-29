<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<style>
.browse-grid { display: grid; grid-template-columns: 280px 1fr; gap: 20px; }
@media (max-width: 800px) { .browse-grid { grid-template-columns: 1fr; } }
.filter-card { background: #fff; border-radius: 14px; padding: 18px; box-shadow: 0 2px 12px rgba(0,0,0,0.04); height: fit-content; position: sticky; top: 80px; }
.filter-card h4 { margin: 0 0 10px; font-size: 14px; font-weight: 700; color: var(--gray-800); }
.filter-card label { font-size: 12px; color: var(--gray-600); margin-bottom: 4px; display: block; }
.filter-card input, .filter-card select { width: 100%; padding: 8px 10px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 13px; box-sizing: border-box; margin-bottom: 12px; }
.search-bar { display: flex; gap: 10px; margin-bottom: 18px; align-items: center; flex-wrap: wrap; }
.search-bar input { flex: 1; min-width: 200px; padding: 12px 18px; border: 1.5px solid var(--gray-200); border-radius: 999px; font-size: 14px; outline: none; box-shadow: 0 2px 8px rgba(0,0,0,0.04); }
.search-bar input:focus { border-color: var(--m1-primary); }
.crop-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 14px; }
.crop-card { background: #fff; border-radius: 14px; overflow: hidden; box-shadow: 0 2px 12px rgba(0,0,0,0.05); transition: transform 0.2s, box-shadow 0.2s; text-decoration: none; color: inherit; display: block; }
.crop-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,0.1); }
.crop-img { height: 160px; background: linear-gradient(135deg, #c8e6c9, #e8f5e9); display: flex; align-items: center; justify-content: center; font-size: 60px; position: relative; }
.crop-img img { width: 100%; height: 100%; object-fit: cover; }
.crop-meta { padding: 12px 14px; }
.pager { display: flex; gap: 6px; justify-content: center; margin-top: 24px; }
.pager a, .pager span { padding: 8px 14px; border-radius: 8px; text-decoration: none; color: var(--gray-700); border: 1.5px solid var(--gray-200); font-size: 13px; }
.pager a:hover { background: var(--gray-50); }
.pager .current { background: var(--m1-primary); color: #fff; border-color: var(--m1-primary); }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/buyer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> ব্রাউজ</div>
                <h1>মার্কেটপ্লেস 🛒</h1>
            </div>
            <div style="font-size:13px; color:var(--gray-500);">
                মোট <strong><?= bn_num($total) ?></strong> ফসল পাওয়া গেছে
                <?php if (!empty($searchDriver) && $searchDriver === 'meilisearch'): ?>
                    <span style="display:inline-block; margin-left:8px; padding:2px 8px; border-radius:99px; font-size:11px;
                                 background: linear-gradient(135deg, #7B1FA2, #2E7D32);
                                 color: #fff;"
                          title="Search engine: <?= e($searchDriver) ?>">
                        ⚡ MeiliSearch
                        <?php if (!empty($searchTimeMs)): ?> · <?= bn_num($searchTimeMs) ?>ms<?php endif; ?>
                    </span>
                <?php endif; ?>
            </div>
        </div>

        <div class="browse-grid">
            <!-- Filters -->
            <form method="GET" id="filterForm">
                <div class="filter-card">
                    <h4><i class="bi bi-funnel"></i> ফিল্টার</h4>

                    <label>ক্যাটাগরি</label>
                    <select name="category_id">
                        <option value="">— সব —</option>
                        <?php foreach ($categories as $c): ?>
                            <option value="<?= (int)$c['category_id'] ?>" <?= ($filters['category_id'] ?? '') == $c['category_id'] ? 'selected' : '' ?>><?= e($c['icon']) ?> <?= e($c['category_name_bn']) ?></option>
                        <?php endforeach; ?>
                    </select>

                    <label>জেলা</label>
                    <select name="district_id">
                        <option value="">— সব জেলা —</option>
                        <?php foreach ($districts as $d): ?>
                            <option value="<?= (int)$d['district_id'] ?>" <?= ($filters['district_id'] ?? '') == $d['district_id'] ? 'selected' : '' ?>><?= e($d['district_name']) ?></option>
                        <?php endforeach; ?>
                    </select>

                    <label>সর্বনিম্ন মূল্য (৳)</label>
                    <input type="number" name="min_price" value="<?= e($filters['min_price'] ?? '') ?>" placeholder="০" min="0">

                    <label>সর্বোচ্চ মূল্য (৳)</label>
                    <input type="number" name="max_price" value="<?= e($filters['max_price'] ?? '') ?>" placeholder="∞" min="0">

                    <label>মান গ্রেড</label>
                    <select name="quality">
                        <option value="">— সব গ্রেড —</option>
                        <option value="A" <?= ($filters['quality'] ?? '') === 'A' ? 'selected' : '' ?>>A - প্রিমিয়াম</option>
                        <option value="B" <?= ($filters['quality'] ?? '') === 'B' ? 'selected' : '' ?>>B - সাধারণ</option>
                        <option value="C" <?= ($filters['quality'] ?? '') === 'C' ? 'selected' : '' ?>>C - সীমিত</option>
                    </select>

                    <label style="display:flex; align-items:center; gap:6px; font-size:13px; color:var(--gray-800); margin-bottom:14px;">
                        <input type="checkbox" name="organic" value="1" style="width:auto; margin:0;" <?= !empty($filters['organic']) ? 'checked' : '' ?>>
                        🍃 শুধু জৈব ফসল
                    </label>

                    <label>সাজানো</label>
                    <select name="sort">
                        <option value="newest" <?= ($filters['sort'] ?? 'newest') === 'newest' ? 'selected' : '' ?>>সবচেয়ে নতুন</option>
                        <option value="price_low" <?= ($filters['sort'] ?? '') === 'price_low' ? 'selected' : '' ?>>মূল্য: কম থেকে বেশি</option>
                        <option value="price_high" <?= ($filters['sort'] ?? '') === 'price_high' ? 'selected' : '' ?>>মূল্য: বেশি থেকে কম</option>
                        <option value="popular" <?= ($filters['sort'] ?? '') === 'popular' ? 'selected' : '' ?>>সবচেয়ে জনপ্রিয়</option>
                    </select>

                    <button type="submit" class="nav-pill-btn primary" style="width:100%; justify-content:center; margin-top:6px;">প্রয়োগ করুন</button>
                    <a href="<?= BASE_URL ?>/buyer/browse" class="nav-pill-btn ghost" style="width:100%; justify-content:center; margin-top:8px;">রিসেট</a>
                </div>
            </form>

            <!-- Results -->
            <div>
                <form method="GET" class="search-bar">
                    <!-- Keep other filters when searching -->
                    <?php foreach (['category_id','district_id','min_price','max_price','quality','organic','sort'] as $k): ?>
                        <?php if (!empty($filters[$k])): ?>
                            <input type="hidden" name="<?= $k ?>" value="<?= e($filters[$k]) ?>">
                        <?php endif; ?>
                    <?php endforeach; ?>
                    <input type="text" name="q" placeholder="🔍 ফসল, জাত বা বিবরণ অনুসন্ধান..." value="<?= e($filters['q'] ?? '') ?>">
                    <button type="submit" class="nav-pill-btn primary">খুঁজুন</button>
                </form>

                <?php if (empty($crops)): ?>
                    <div class="dash-card">
                        <div class="empty-state">
                            <i class="bi bi-search"></i>
                            <h4>কোনো ফসল পাওয়া যায়নি</h4>
                            <p>আপনার ফিল্টার পরিবর্তন করে আবার চেষ্টা করুন।</p>
                        </div>
                    </div>
                <?php else: ?>
                <div class="crop-grid">
                    <?php foreach ($crops as $c):
                        $img = first_image_variant($c['images'], 'thumb');
                    ?>
                        <a href="<?= BASE_URL ?>/buyer/crop/<?= (int)$c['crop_id'] ?>" class="crop-card">
                            <div class="crop-img">
                                <?php if ($img): ?>
                                    <img src="<?= e($img) ?>" alt="">
                                <?php else: ?>
                                    🌾
                                <?php endif; ?>
                                <?php if ($c['is_organic']): ?>
                                    <span class="badge badge-success" style="position:absolute; top:8px; left:8px; font-size:10px;"><i class="bi bi-leaf"></i> জৈব</span>
                                <?php endif; ?>
                                <span class="badge badge-info" style="position:absolute; top:8px; right:8px; font-size:10px;">Grade <?= e($c['quality_grade']) ?></span>
                            </div>
                            <div class="crop-meta">
                                <div style="font-weight:700; font-size:14px;"><?= e($c['crop_name']) ?></div>
                                <div style="font-size:11px; color:var(--gray-500); margin-bottom:6px;"><?= e($c['category_name_bn']) ?> <?php if ($c['district_name']): ?>• <?= e($c['district_name']) ?><?php endif; ?></div>
                                <div style="display:flex; justify-content:space-between; align-items:center;">
                                    <span style="font-weight:800; color:var(--m1-primary); font-size:16px;"><?= bdt($c['price_per_unit'], 0) ?><span style="font-size:10px; color:var(--gray-500); font-weight:400;">/<?= e($c['unit']) ?></span></span>
                                    <span style="font-size:11px; color:var(--gray-500);"><?= bn_num($c['quantity']) ?> <?= e($c['unit']) ?></span>
                                </div>
                                <?php if ($c['farmer_rating'] > 0): ?>
                                    <div style="font-size:11px; color:#f57c00; margin-top:4px;">⭐ <?= bn_num(number_format($c['farmer_rating'], 1)) ?></div>
                                <?php endif; ?>
                                <div style="font-size:11px; color:var(--gray-500); margin-top:6px; border-top:1px solid var(--gray-100); padding-top:6px;"><i class="bi bi-person"></i> <?= e(mb_substr($c['farmer_name'], 0, 22, 'UTF-8')) ?></div>
                            </div>
                        </a>
                    <?php endforeach; ?>
                </div>

                <?php if ($totalPages > 1):
                    $q = $_GET; unset($q['page']);
                    $base = http_build_query($q);
                ?>
                <div class="pager">
                    <?php if ($page > 1): ?>
                        <a href="?<?= $base ? $base . '&' : '' ?>page=<?= $page - 1 ?>">← আগে</a>
                    <?php endif; ?>
                    <?php for ($p = max(1, $page-2); $p <= min($totalPages, $page+2); $p++): ?>
                        <?php if ($p == $page): ?>
                            <span class="current"><?= bn_num($p) ?></span>
                        <?php else: ?>
                            <a href="?<?= $base ? $base . '&' : '' ?>page=<?= $p ?>"><?= bn_num($p) ?></a>
                        <?php endif; ?>
                    <?php endfor; ?>
                    <?php if ($page < $totalPages): ?>
                        <a href="?<?= $base ? $base . '&' : '' ?>page=<?= $page + 1 ?>">পরে →</a>
                    <?php endif; ?>
                </div>
                <?php endif; ?>
                <?php endif; ?>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
