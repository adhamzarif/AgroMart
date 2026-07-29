<?php include __DIR__ . '/../../includes/header.php'; ?>
<?php include __DIR__ . '/../../includes/navbar.php'; ?>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap-grid.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<?php
$crops = $crops ?? [];
$currentUserId = $currentUserId ?? null;
$page = $page ?? 1;
$totalPages = $totalPages ?? 1;
?>

<style>
    .all-crops-page { background: #f0f7ee; min-height: 100vh; padding-bottom: 70px; font-family: var(--font-bn); }
    .all-crops-hero {
        background: linear-gradient(135deg, #0d3b1a 0%, #1f6f30 58%, #2e7d32 100%);
        color: #fff; padding: 58px 24px 92px; text-align: center; position: relative; overflow: hidden;
    }
    .all-crops-hero::after {
        content: ''; position: absolute; bottom: -1px; left: 0; width: 100%; height: 54px;
        background: url('data:image/svg+xml;utf8,<svg viewBox="0 0 1440 100" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg"><path fill="%23f0f7ee" d="M0,76 C260,28 480,108 720,58 C980,10 1140,80 1440,38 L1440,100 L0,100 Z"/></svg>') center/cover no-repeat;
    }
    .all-crops-hero .container { position: relative; z-index: 1; }
    .all-crops-hero h1 { color: #fff; font-size: clamp(34px, 5vw, 54px); font-weight: 900; margin: 0 0 12px; }
    .all-crops-hero p { max-width: 760px; margin: 0 auto; color: rgba(255,255,255,0.88); font-size: 17px; line-height: 1.7; }
    .all-toolbar {
        background: rgba(255,255,255,0.9); backdrop-filter: blur(18px); border: 1px solid rgba(255,255,255,0.5);
        border-radius: 18px; padding: 20px; box-shadow: 0 16px 38px rgba(0,0,0,0.08);
        margin: -50px auto 44px; position: relative; z-index: 5;
    }
    .all-input, .all-select {
        width: 100%; height: 54px; border: 1.5px solid #e5e7eb; border-radius: 12px; background: #fff;
        padding: 0 16px; font-size: 15px; color: #1f2937; outline: none;
    }
    .all-input:focus, .all-select:focus { border-color: #1a5c28; box-shadow: 0 0 0 4px rgba(26,92,40,0.1); }
    .all-count { color: #6b7280; font-size: 14px; margin-top: 12px; }
    .all-card {
        height: 100%; background: #fff; border: 1px solid #eef2ee; border-radius: 18px; overflow: hidden;
        box-shadow: 0 10px 28px rgba(0,0,0,0.045); transition: transform .25s ease, box-shadow .25s ease, border-color .25s ease;
        display: flex; flex-direction: column;
    }
    .all-card:hover { transform: translateY(-6px); border-color: #54b764; box-shadow: 0 18px 38px rgba(46,125,50,0.13); }
    .all-img-wrap { height: 190px; position: relative; overflow: hidden; background: #eef6ef; }
    .all-img { width: 100%; height: 100%; object-fit: cover; transition: transform .35s ease; }
    .all-card:hover .all-img { transform: scale(1.04); }
    .all-badge {
        position: absolute; top: 14px; right: 14px; background: rgba(255,255,255,0.92); color: #1a5c28;
        border-radius: 999px; padding: 6px 12px; font-size: 12px; font-weight: 800; box-shadow: 0 8px 18px rgba(0,0,0,0.1);
    }
    .all-body { padding: 20px; display: flex; flex-direction: column; flex: 1; }
    .all-cat { display: inline-flex; width: fit-content; background: #e8f5e9; color: #1a5c28; border-radius: 999px; padding: 4px 10px; font-size: 12px; font-weight: 800; margin-bottom: 10px; }
    .all-title { font-size: 22px; color: #1f2937; font-weight: 900; margin: 0 0 8px; }
    .all-meta { color: #6b7280; font-size: 14px; display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 12px; }
    .all-desc { color: #6b7280; line-height: 1.55; font-size: 14px; margin: 0 0 16px; }
    .all-bottom { margin-top: auto; border-top: 1px solid #edf2ed; padding-top: 16px; display: flex; justify-content: space-between; align-items: center; gap: 14px; }
    .all-price { color: #1a5c28; font-size: 26px; line-height: 1; font-weight: 900; }
    .all-unit { color: #6b7280; font-size: 12px; margin-top: 3px; }
    .all-order {
        background: #1a5c28; color: #fff; border-radius: 12px; padding: 10px 18px; text-decoration: none;
        font-weight: 800; font-size: 14px; white-space: nowrap;
    }
    .all-order:hover { background: #0d3b1a; color: #fff; }
    .all-empty { display: none; text-align: center; padding: 48px 20px; color: #6b7280; font-weight: 700; }
    .pag-wrap { margin: 40px 0 0; display: flex; justify-content: center; gap: 8px; flex-wrap: wrap; }
    .pag-btn { background: #fff; border: 1px solid #e5e7eb; color: #1f2937; padding: 12px 16px; border-radius: 10px; text-decoration: none; font-weight: 800; transition: all .25s; }
    .pag-btn:hover, .pag-btn.active { background: #1a5c28; color: #fff; border-color: #1a5c28; }
    .pag-btn.disabled { opacity: .5; cursor: not-allowed; }
    @media (max-width: 768px) {
        .all-crops-hero { padding: 46px 18px 82px; }
        .all-toolbar { margin-top: -42px; }
        .all-img-wrap { height: 210px; }
    }
</style>

<div class="all-crops-page">
    <section class="all-crops-hero">
        <div class="container">
            <h1>সব ফসল একসাথে</h1>
            <p>AgroFin marketplace-এ আপনার সাথে সংযুক্ত কৃষকদের সব পণ্য এখানে দেখুন। নাম বা ক্যাটাগরি দিয়ে দ্রুত খুঁজে নিন।</p>
        </div>
    </section>

    <main class="container">
        <div class="all-toolbar">
            <div class="row g-3 align-items-end">
                <div class="col-12 col-md-8">
                    <label style="font-size:13px;font-weight:800;color:#374151;margin-bottom:8px;display:block;">ফসল খুঁজুন</label>
                    <input class="all-input" id="cropSearch" type="text" placeholder="যেমন: আলু, ধান, টমেটো..." oninput="filterAllCrops()">
                </div>
                <div class="col-12 col-md-4">
                    <label style="font-size:13px;font-weight:800;color:#374151;margin-bottom:8px;display:block;">ক্যাটাগরি</label>
                    <select class="all-select" id="cropCategory" onchange="filterAllCrops()">
                        <option value="">সব ক্যাটাগরি</option>
                    </select>
                </div>
            </div>
            <div class="all-count">মোট <strong><?= count($crops) ?></strong> ফসল পাওয়া গেছে</div>
        </div>

        <?php if (!empty($crops)): ?>
        <div class="row g-4">
            <?php foreach ($crops as $crop): ?>
            <div class="col-12 col-md-6 col-lg-4" class="crop-item" data-name="<?= e($crop['crop_name']) ?>" data-cat="<?= e($crop['category_name_bn'] ?? '') ?>">
                <div class="all-card">
                    <div class="all-img-wrap">
                        <?php
                            $img = first_image_variant($crop['images'] ?? null, 'medium');
                            if (empty($img)) $img = 'https://images.unsplash.com/photo-1599599810694-b5ac4dd33c1f?w=500&q=80';
                        ?>
                        <img src="<?= e($img) ?>" alt="<?= e($crop['crop_name']) ?>" class="all-img" onerror="this.src='https://images.unsplash.com/photo-1599599810694-b5ac4dd33c1f?w=500&q=80'">
                        <span class="all-badge"><i class="bi bi-star-fill"></i> নতুন</span>
                    </div>
                    <div class="all-body">
                        <span class="all-cat"><?= e($crop['category_name_bn'] ?? 'ফসল') ?></span>
                        <h3 class="all-title"><?= e($crop['crop_name']) ?></h3>
                        <div class="all-meta">
                            <span><i class="bi bi-person-circle"></i> <?= e($crop['farmer_name'] ?? 'অজানা') ?></span>
                            <span><i class="bi bi-geo-alt-fill"></i> <?= e($crop['district_name'] ?? 'জেলা') ?></span>
                        </div>
                        <p class="all-desc"><?= e(substr($crop['description'], 0, 90)) ?>...</p>
                        <div class="all-bottom">
                            <div>
                                <div class="all-price">৳ <?= e($crop['price_per_unit']) ?></div>
                                <div class="all-unit">প্রতি <?= e($crop['unit'] ?? 'ইউনিট') ?></div>
                            </div>
                            <a href="/AgroFin/buyer/crop/<?= $crop['crop_id'] ?>" class="all-order">বিস্তারিত</a>
                        </div>
                    </div>
                </div>
            </div>
            <?php endforeach; ?>
        </div>

        <!-- Pagination -->
        <?php if ($totalPages > 1): ?>
        <div class="pag-wrap">
            <?php if ($page > 1): ?>
            <a href="?page=1" class="pag-btn"><i class="bi bi-chevron-bar-left"></i></a>
            <a href="?page=<?= $page - 1 ?>" class="pag-btn"><i class="bi bi-chevron-left"></i></a>
            <?php else: ?>
            <span class="pag-btn disabled"><i class="bi bi-chevron-bar-left"></i></span>
            <span class="pag-btn disabled"><i class="bi bi-chevron-left"></i></span>
            <?php endif; ?>
            
            <?php for ($i = 1; $i <= $totalPages; $i++): ?>
            <a href="?page=<?= $i ?>" class="pag-btn <?= $i === $page ? 'active' : '' ?>"><?= $i ?></a>
            <?php endfor; ?>

            <?php if ($page < $totalPages): ?>
            <a href="?page=<?= $page + 1 ?>" class="pag-btn"><i class="bi bi-chevron-right"></i></a>
            <a href="?page=<?= $totalPages ?>" class="pag-btn"><i class="bi bi-chevron-bar-right"></i></a>
            <?php else: ?>
            <span class="pag-btn disabled"><i class="bi bi-chevron-right"></i></span>
            <span class="pag-btn disabled"><i class="bi bi-chevron-bar-right"></i></span>
            <?php endif; ?>
        </div>
        <?php endif; ?>

        <?php else: ?>
        <div style="text-align:center; padding:80px 20px; background:#f9fdf8; border-radius:16px;">
            <div style="font-size:64px; margin-bottom:20px;"><i class="bi bi-inbox"></i></div>
            <h3 style="color:#1f2937; font-weight:900; margin-bottom:10px;">কোনো ফসল পাওয়া যায়নি</h3>
            <p style="color:#6b7280; margin-bottom:30px;">আপনার সাথে সংযুক্ত কৃষক এখনো কোনো ফসল যোগ করেননি। আরও কৃষককে অনুসরণ করুন।</p>
            <a href="/AgroFin" class="btn btn-primary" style="background:#1a5c28; color:#fff; padding:12px 30px; border-radius:10px; text-decoration:none; font-weight:800;">হোমে ফিরুন</a>
        </div>
        <?php endif; ?>
    </main>
</div>

<script>
function filterAllCrops() {
    const searchTerm = document.getElementById('cropSearch').value.toLowerCase();
    const categoryTerm = document.getElementById('cropCategory').value.toLowerCase();
    const items = document.querySelectorAll('.crop-item');
    
    items.forEach(item => {
        const name = item.getAttribute('data-name').toLowerCase();
        const cat = item.getAttribute('data-cat').toLowerCase();
        const matchesSearch = name.includes(searchTerm);
        const matchesCategory = !categoryTerm || cat.includes(categoryTerm);
        item.style.display = matchesSearch && matchesCategory ? '' : 'none';
    });
}

document.addEventListener('DOMContentLoaded', function() {
    const categorySelect = document.getElementById('cropCategory');
    const categories = new Set();
    document.querySelectorAll('.crop-item').forEach(item => {
        const cat = item.getAttribute('data-cat');
        if (cat) categories.add(cat);
    });
    categories.forEach(cat => {
        const option = document.createElement('option');
        option.value = cat;
        option.textContent = cat;
        categorySelect.appendChild(option);
    });
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
