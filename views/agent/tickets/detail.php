<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$priorityMap = ['urgent'=>['danger','🚨 জরুরি'],'high'=>['warning','⚡ উচ্চ'],'medium'=>['info','মাঝারি'],'low'=>['neutral','নিম্ন']];
$statusMap = ['open'=>['warning','খোলা'],'in_progress'=>['info','প্রক্রিয়াধীন'],'resolved'=>['success','সমাধান হয়েছে'],'closed'=>['neutral','বন্ধ'],'cancelled'=>['danger','বাতিল']];
$issueMap = ['registration_help'=>'নিবন্ধন সহায়তা','crop_listing'=>'ফসল লিস্ট','order_issue'=>'অর্ডার সমস্যা','payment_problem'=>'পেমেন্ট সমস্যা','loan_query'=>'লোন জিজ্ঞাসা','technical_issue'=>'কারিগরি সমস্যা','account_access'=>'অ্যাকাউন্ট অ্যাক্সেস','other'=>'অন্যান্য'];
$sm = $statusMap[$t['status']] ?? ['neutral', $t['status']];
$pm = $priorityMap[$t['priority']] ?? ['neutral', $t['priority']];
$isMine = (int)$t['assigned_agent_id'] === (int)$agent['agent_id'];
$canEdit = $isMine && in_array($t['status'], ['open','in_progress'], true);
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/agent/tickets">টিকেট</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> বিস্তারিত</div>
                <h1>টিকেট #<?= e($t['ticket_number']) ?></h1>
            </div>
            <div style="display:flex; gap:6px; flex-wrap:wrap;">
                <span class="badge badge-<?= $pm[0] ?>" style="font-size:13px; padding:8px 14px;"><?= $pm[1] ?></span>
                <span class="badge badge-<?= $sm[0] ?>" style="font-size:13px; padding:8px 14px;"><?= $sm[1] ?></span>
            </div>
        </div>

        <div style="display:grid; grid-template-columns: 2fr 1fr; gap: 20px;">
            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><?= e($t['subject']) ?></h3>
                    <div style="font-size:13px; color:var(--gray-500); margin-bottom:14px;">
                        <strong>ধরন:</strong> <?= e($issueMap[$t['issue_type']] ?? $t['issue_type']) ?> •
                        <strong>খোলা হয়েছে:</strong> <?= bn_date($t['created_at'], true) ?>
                        <?php if ($t['assigned_at']): ?> • <strong>এসাইন্ড:</strong> <?= bn_date($t['assigned_at'], true) ?><?php endif; ?>
                        <?php if ($t['resolved_at']): ?> • <strong>সমাধান:</strong> <?= bn_date($t['resolved_at'], true) ?><?php endif; ?>
                    </div>
                    <div style="padding: 16px; background: var(--gray-50); border-radius: 10px; border-left: 4px solid var(--m4-primary); line-height:1.7;">
                        <?= nl2br(e($t['description'])) ?>
                    </div>
                </div>

                <?php if ($t['resolution_notes']): ?>
                <div class="dash-card" style="border-left:4px solid var(--success);">
                    <h3 style="margin:0 0 14px; color:var(--success-dark);"><i class="bi bi-check2-circle"></i> সমাধানের নোট</h3>
                    <div style="line-height:1.7;"><?= nl2br(e($t['resolution_notes'])) ?></div>
                </div>
                <?php endif; ?>

                <?php if (!$t['assigned_agent_id']): ?>
                <div class="dash-card" style="border-left:4px solid var(--m4-primary);">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-hand-thumbs-up"></i> টিকেটটি গ্রহণ করুন</h3>
                    <p style="font-size:13px; color:var(--gray-600);">এই টিকেট এখনো কোনো এজেন্ট গ্রহণ করেননি। গ্রহণ করলে এটি আপনার টিকেটে চলে যাবে।</p>
                    <form method="POST" action="<?= BASE_URL ?>/agent/tickets/claim/<?= (int)$t['ticket_id'] ?>">
                        <?= Csrf::field() ?>
                        <button type="submit" class="nav-pill-btn primary" style="background:var(--m4-primary)"><i class="bi bi-check2"></i> গ্রহণ করুন</button>
                    </form>
                </div>
                <?php elseif ($canEdit): ?>
                <div class="dash-card" style="border-left:4px solid var(--m1-primary);">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-pencil-square"></i> অবস্থা আপডেট করুন</h3>
                    <form method="POST" action="<?= BASE_URL ?>/agent/tickets/update/<?= (int)$t['ticket_id'] ?>">
                        <?= Csrf::field() ?>
                        <div style="margin-bottom: 12px;">
                            <label style="display:block; font-size:13px; font-weight:600; margin-bottom: 4px;">নতুন অবস্থা *</label>
                            <select name="new_status" required style="width:100%; padding:10px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                                <?php foreach (['in_progress'=>'প্রক্রিয়াধীন','resolved'=>'সমাধান হয়েছে','cancelled'=>'বাতিল'] as $k=>$v): ?>
                                    <option value="<?= $k ?>" <?= $t['status'] === $k ? 'selected' : '' ?>><?= $v ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div style="margin-bottom: 14px;">
                            <label style="display:block; font-size:13px; font-weight:600; margin-bottom: 4px;">সমাধান / কারণ</label>
                            <textarea name="resolution_notes" rows="4" style="width:100%; padding:10px 12px; border:1.5px solid var(--gray-200); border-radius:8px; resize:vertical; font-family:inherit;" placeholder="সমাধানের বিস্তারিত বা বাতিলের কারণ লিখুন"><?= e($t['resolution_notes'] ?? '') ?></textarea>
                            <div style="font-size:11px; color:var(--gray-500); margin-top:4px;">"সমাধান হয়েছে" নির্বাচন করলে আপনি ৳১০ কমিশন পাবেন।</div>
                        </div>
                        <button type="submit" class="nav-pill-btn primary"><i class="bi bi-save"></i> আপডেট করুন</button>
                    </form>
                </div>
                <?php endif; ?>
            </div>

            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-person"></i> কৃষক</h3>
                    <div style="display:flex; align-items:center; gap:10px; margin-bottom:12px;">
                        <div style="width:48px; height:48px; border-radius:50%; background:var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700;"><?= e(mb_substr($t['farmer_name'], 0, 1, 'UTF-8')) ?></div>
                        <div>
                            <strong><?= e($t['farmer_name']) ?></strong><br>
                            <span style="font-size:12px; color:var(--gray-500);"><?= e($t['farmer_phone']) ?></span>
                        </div>
                    </div>
                    <a href="<?= BASE_URL ?>/agent/messages/with/<?= (int)$t['farmer_id'] ?>" class="nav-pill-btn ghost" style="width:100%; justify-content:center;"><i class="bi bi-chat-dots"></i> বার্তা পাঠান</a>
                </div>

                <?php if ($t['agent_name']): ?>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px; font-size:14px;"><i class="bi bi-person-check"></i> এসাইন্ড এজেন্ট</h3>
                    <strong><?= e($t['agent_name']) ?></strong>
                    <?php if ($isMine): ?><div style="font-size:11px; color:var(--success); margin-top:2px;">✓ এটি আপনার টিকেট</div><?php endif; ?>
                </div>
                <?php endif; ?>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
