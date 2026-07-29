<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$priorityMap = ['urgent'=>['danger','🚨 জরুরি'],'high'=>['warning','⚡ উচ্চ'],'medium'=>['info','মাঝারি'],'low'=>['neutral','নিম্ন']];
$statusMap = ['open'=>['warning','খোলা'],'in_progress'=>['info','প্রক্রিয়াধীন'],'resolved'=>['success','সমাধান'],'closed'=>['neutral','বন্ধ'],'cancelled'=>['danger','বাতিল']];
$issueMap = ['registration_help'=>'নিবন্ধন সহায়তা','crop_listing'=>'ফসল লিস্ট','order_issue'=>'অর্ডার সমস্যা','payment_problem'=>'পেমেন্ট সমস্যা','loan_query'=>'লোন জিজ্ঞাসা','technical_issue'=>'কারিগরি সমস্যা','account_access'=>'অ্যাকাউন্ট অ্যাক্সেস','other'=>'অন্যান্য'];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/agent/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> টিকেট</div>
                <h1>সাপোর্ট টিকেট 🎫</h1>
            </div>
        </div>

        <div class="stat-grid">
            <div class="stat-tile tile-orange">
                <div class="st-label">মোট টিকেট</div>
                <div class="st-value"><?= bn_num($stats['total'] ?? 0) ?></div>
                <div class="st-icon"><i class="bi bi-ticket"></i></div>
            </div>
            <div class="stat-tile tile-orange">
                <div class="st-label">খোলা</div>
                <div class="st-value"><?= bn_num($stats['open_count'] ?? 0) ?></div>
                <div class="st-icon"><i class="bi bi-clock"></i></div>
            </div>
            <div class="stat-tile tile-blue">
                <div class="st-label">প্রক্রিয়াধীন</div>
                <div class="st-value"><?= bn_num($stats['in_progress_count'] ?? 0) ?></div>
                <div class="st-icon"><i class="bi bi-gear"></i></div>
            </div>
            <div class="stat-tile tile-green">
                <div class="st-label">সমাধান</div>
                <div class="st-value"><?= bn_num($stats['resolved_count'] ?? 0) ?></div>
                <div class="st-icon"><i class="bi bi-check-circle"></i></div>
            </div>
        </div>

        <div class="dash-card" style="padding: 14px 20px;">
            <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;">
                <a href="<?= BASE_URL ?>/agent/tickets?tab=mine" class="nav-pill-btn <?= $tab === 'mine' ? 'primary' : 'ghost' ?>" style="font-size:13px;"><i class="bi bi-person-check"></i> আমার টিকেট</a>
                <a href="<?= BASE_URL ?>/agent/tickets?tab=queue" class="nav-pill-btn <?= $tab === 'queue' ? 'primary' : 'ghost' ?>" style="font-size:13px;"><i class="bi bi-collection"></i> খোলা সারি (গ্রহণ করুন)</a>
                <?php if ($tab === 'mine'): ?>
                    <span style="border-left: 1px solid var(--gray-200); height:20px; margin: 0 6px;"></span>
                    <?php foreach (['' => 'সব', 'open' => 'খোলা', 'in_progress' => 'প্রক্রিয়াধীন', 'resolved' => 'সমাধান'] as $k => $v):
                        $url = '?tab=mine' . ($k ? '&status=' . $k : '');
                    ?>
                        <a href="<?= BASE_URL ?>/agent/tickets<?= $url ?>" class="nav-pill-btn <?= ($statusFilter ?? '') === $k ? 'primary' : 'ghost' ?>" style="font-size:12px;"><?= $v ?></a>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
        </div>

        <div class="dash-card">
            <?php if (empty($tickets)): ?>
                <div class="empty-state">
                    <i class="bi bi-ticket-perforated"></i>
                    <h4>কোনো টিকেট নেই</h4>
                    <p><?= $tab === 'queue' ? 'সকল টিকেট ইতোমধ্যে এসাইন্ড।' : 'আপনি এখনো কোনো টিকেট গ্রহণ করেননি।' ?></p>
                </div>
            <?php else: ?>
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr><th>টিকেট #</th><th>কৃষক</th><th>ধরন</th><th>বিষয়</th><th>অগ্রাধিকার</th><th>অবস্থা</th><th>তারিখ</th><th></th></tr>
                </thead>
                <tbody>
                <?php foreach ($tickets as $t):
                    $sm = $statusMap[$t['status']] ?? ['neutral', $t['status']];
                    $pm = $priorityMap[$t['priority']] ?? ['neutral', $t['priority']];
                ?>
                    <tr>
                        <td class="mono" style="font-size:11px;"><?= e($t['ticket_number']) ?></td>
                        <td><?= e($t['farmer_name']) ?><br><span style="font-size:11px; color:var(--gray-500);"><?= e($t['farmer_phone'] ?? '') ?> <?= !empty($t['district_name']) ? '• ' . e($t['district_name']) : '' ?></span></td>
                        <td style="font-size:12px;"><?= e($issueMap[$t['issue_type']] ?? $t['issue_type']) ?></td>
                        <td><?= e(mb_substr($t['subject'], 0, 40, 'UTF-8')) ?></td>
                        <td><span class="badge badge-<?= $pm[0] ?>"><?= $pm[1] ?></span></td>
                        <td><span class="badge badge-<?= $sm[0] ?>"><?= $sm[1] ?></span></td>
                        <td style="font-size:11px;"><?= bn_date($t['created_at']) ?></td>
                        <td><a href="<?= BASE_URL ?>/agent/tickets/detail/<?= (int)$t['ticket_id'] ?>" class="nav-pill-btn ghost" style="font-size:12px; padding:5px 10px;">খুলুন →</a></td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            </div>
            <?php endif; ?>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
