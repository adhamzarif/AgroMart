<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$catLabels = [
    'seeds'      => ['🌱', 'বীজ', 'success'],
    'fertilizer' => ['🌿', 'সার', 'info'],
    'pesticide'  => ['🧴', 'কীটনাশক', 'warning'],
    'labor'      => ['👷', 'শ্রমিক', 'farmer'],
    'irrigation' => ['💧', 'সেচ', 'info'],
    'equipment'  => ['🛠', 'সরঞ্জাম', 'neutral'],
    'transport'  => ['🚚', 'পরিবহন', 'agent'],
    'other'      => ['📌', 'অন্যান্য', 'neutral'],
];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> খরচ</div>
                <h1>খরচ ব্যবস্থাপনা 💸</h1>
            </div>
            <a href="<?= BASE_URL ?>/farmer/expenses/add" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> নতুন খরচ যোগ করুন</a>
        </div>

        <!-- Filters -->
        <div class="dash-card" style="padding: 14px 20px;">
            <form method="GET" style="display:flex; gap:10px; align-items:end; flex-wrap:wrap;">
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">ক্যাটাগরি</label>
                    <select name="category" style="padding:8px 12px; border:1.5px solid var(--gray-200); border-radius:8px; min-width:140px;">
                        <option value="">— সব —</option>
                        <?php foreach ($catLabels as $k => $v): ?>
                            <option value="<?= $k ?>" <?= ($filters['category'] ?? '') === $k ? 'selected' : '' ?>><?= $v[0] ?> <?= $v[1] ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">তারিখ (থেকে)</label>
                    <input type="date" name="date_from" value="<?= e($filters['date_from'] ?? '') ?>" style="padding:8px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">তারিখ (পর্যন্ত)</label>
                    <input type="date" name="date_to" value="<?= e($filters['date_to'] ?? '') ?>" style="padding:8px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                </div>
                <button type="submit" class="nav-pill-btn primary"><i class="bi bi-funnel"></i> ফিল্টার</button>
                <a href="<?= BASE_URL ?>/farmer/expenses" class="nav-pill-btn ghost">রিসেট</a>
            </form>
        </div>

        <!-- Summary -->
        <div class="stat-grid">
            <div class="stat-tile tile-red">
                <div class="st-label">মোট খরচ</div>
                <div class="st-value"><?= bdt($total, 0) ?></div>
                <div class="st-foot"><?= bn_num(count($expenses)) ?> টি এন্ট্রি</div>
                <div class="st-icon"><i class="bi bi-cash-stack"></i></div>
            </div>
            <?php
            $top = $byCategory[0] ?? null;
            ?>
            <div class="stat-tile tile-orange">
                <div class="st-label">সর্বোচ্চ ক্যাটাগরি</div>
                <div class="st-value" style="font-size:18px;"><?= $top ? ($catLabels[$top['expense_category']][1] ?? $top['expense_category']) : '—' ?></div>
                <div class="st-foot"><?= $top ? bdt($top['total'], 0) : '—' ?></div>
                <div class="st-icon"><i class="bi bi-pie-chart"></i></div>
            </div>
        </div>

        <?php if (empty($expenses)): ?>
            <div class="dash-card">
                <div class="empty-state">
                    <i class="bi bi-receipt"></i>
                    <h4>কোনো খরচের রেকর্ড নেই</h4>
                    <p>খরচ যোগ করে আপনার লাভ-ক্ষতি ট্র্যাক করুন।</p>
                    <a href="<?= BASE_URL ?>/farmer/expenses/add" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> খরচ যোগ করুন</a>
                </div>
            </div>
        <?php else: ?>
        <div class="dash-card">
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr><th>তারিখ</th><th>ক্যাটাগরি</th><th>বিবরণ</th><th>ফসল</th><th>পরিমাণ</th><th>রসিদ</th><th>কাজ</th></tr>
                </thead>
                <tbody>
                <?php foreach ($expenses as $e):
                    $cl = $catLabels[$e['expense_category']] ?? ['📌', $e['expense_category'], 'neutral'];
                ?>
                    <tr>
                        <td style="font-size:12px;"><?= bn_date($e['expense_date']) ?></td>
                        <td><span class="badge badge-<?= $cl[2] ?>"><?= $cl[0] ?> <?= $cl[1] ?></span></td>
                        <td><?= e($e['expense_description']) ?: '—' ?></td>
                        <td><?= e($e['crop_name'] ?? '—') ?></td>
                        <td class="mono" style="font-weight:700; color:var(--danger);"><?= bdt($e['expense_amount'], 0) ?></td>
                        <td><?= $e['receipt_url'] ? '<a href="' . upload_url('receipts/' . $e['receipt_url']) . '" target="_blank"><i class="bi bi-receipt"></i> দেখুন</a>' : '—' ?></td>
                        <td>
                            <a href="<?= BASE_URL ?>/farmer/expenses/edit/<?= (int)$e['expense_id'] ?>" style="margin-right:8px;"><i class="bi bi-pencil"></i></a>
                            <form method="POST" action="<?= BASE_URL ?>/farmer/expenses/delete/<?= (int)$e['expense_id'] ?>" style="display:inline;" onsubmit="return confirm('মুছে ফেলবেন?');">
                                <?= Csrf::field() ?>
                                <button type="submit" style="background:none; border:none; color:var(--danger); cursor:pointer;"><i class="bi bi-trash"></i></button>
                            </form>
                        </td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            </div>
        </div>
        <?php endif; ?>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
