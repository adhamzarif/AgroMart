<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<?php
$actionIcons = [
    'user_verify'=>['✓','যাচাইকরণ','success'],
    'user_ban'=>['🚫','স্থগিত','danger'],
    'user_unban'=>['🔓','পুনঃসক্রিয়','success'],
    'loan_approve'=>['💰','লোন অনুমোদন','success'],
    'loan_reject'=>['❌','লোন বাতিল','danger'],
    'price_add'=>['💹','মূল্য যোগ','info'],
    'price_update'=>['💹','মূল্য আপডেট','info'],
    'price_delete'=>['🗑','মূল্য মুছে ফেলা','danger'],
    'weather_alert_create'=>['⛈','আবহাওয়া সতর্কতা','warning'],
];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> অডিট লগ</div>
                <h1>অডিট লগ 📋</h1>
            </div>
            <div style="font-size:13px; color:var(--gray-500);">মোট <strong><?= bn_num($total) ?></strong> টি এন্ট্রি</div>
        </div>

        <div class="dash-card" style="padding: 14px 20px;">
            <form method="GET" style="display:flex; gap:10px; align-items:end; flex-wrap:wrap;">
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">অ্যাকশন</label>
                    <select name="action_type" style="padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px; min-width:180px;">
                        <option value="">— সব —</option>
                        <?php foreach ($actionIcons as $k => $v): ?>
                            <option value="<?= $k ?>" <?= ($filters['action_type'] ?? '') === $k ? 'selected' : '' ?>><?= $v[0] ?> <?= $v[1] ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">তারিখ থেকে</label>
                    <input type="date" name="date_from" value="<?= e($filters['date_from'] ?? '') ?>" style="padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">তারিখ পর্যন্ত</label>
                    <input type="date" name="date_to" value="<?= e($filters['date_to'] ?? '') ?>" style="padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                </div>
                <button type="submit" class="nav-pill-btn primary"><i class="bi bi-funnel"></i> ফিল্টার</button>
                <a href="<?= BASE_URL ?>/admin/audit" class="nav-pill-btn ghost">রিসেট</a>
            </form>
        </div>

        <div class="dash-card">
            <?php if (empty($logs)): ?>
                <div class="empty-state"><i class="bi bi-clipboard"></i><h4>কোনো লগ এন্ট্রি নেই</h4></div>
            <?php else: ?>
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr><th>সময়</th><th>ব্যবহারকারী</th><th>অ্যাকশন</th><th>টেবিল</th><th>রেকর্ড #</th><th>IP</th><th>বিস্তারিত</th></tr>
                </thead>
                <tbody>
                <?php foreach ($logs as $l):
                    $a = $actionIcons[$l['action_type']] ?? ['•', $l['action_type'], 'neutral'];
                ?>
                    <tr>
                        <td style="font-size:11px; white-space:nowrap;"><?= bn_date($l['created_at'], true) ?></td>
                        <td><?= e($l['actor_name'] ?? '—') ?></td>
                        <td><span class="badge badge-<?= $a[2] ?>"><?= $a[0] ?> <?= $a[1] ?></span></td>
                        <td style="font-size:12px; font-family:monospace;"><?= e($l['table_name']) ?></td>
                        <td class="mono" style="font-size:11px;"><?= bn_num($l['record_id']) ?></td>
                        <td style="font-size:11px; color:var(--gray-500); font-family:monospace;"><?= e($l['ip_address'] ?? '—') ?></td>
                        <td>
                            <?php if ($l['old_values'] || $l['new_values']): ?>
                                <details>
                                    <summary style="cursor:pointer; color:var(--m2-primary); font-size:12px;">দেখুন</summary>
                                    <div style="margin-top: 8px; padding: 10px; background: var(--gray-50); border-radius: 6px; font-family: monospace; font-size: 11px; max-width: 400px; word-break: break-all;">
                                        <?php if ($l['old_values']): ?>
                                            <div><strong>পূর্বে:</strong> <?= e($l['old_values']) ?></div>
                                        <?php endif; ?>
                                        <?php if ($l['new_values']): ?>
                                            <div style="margin-top:4px;"><strong>পরে:</strong> <?= e($l['new_values']) ?></div>
                                        <?php endif; ?>
                                    </div>
                                </details>
                            <?php else: ?>
                                <span style="color:var(--gray-400); font-size:11px;">—</span>
                            <?php endif; ?>
                        </td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            </div>

            <?php if ($totalPages > 1):
                $q = $_GET; unset($q['page']);
                $base = http_build_query($q);
            ?>
            <div style="display:flex; gap:6px; justify-content:center; margin-top: 18px;">
                <?php for ($p = max(1, $page-3); $p <= min($totalPages, $page+3); $p++): ?>
                    <a href="?<?= $base ? $base . '&' : '' ?>page=<?= $p ?>" class="nav-pill-btn <?= $p === $page ? 'primary' : 'ghost' ?>" style="font-size:13px; padding:6px 12px;"><?= bn_num($p) ?></a>
                <?php endfor; ?>
            </div>
            <?php endif; ?>
            <?php endif; ?>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
