<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/agent/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> ফসল লিস্ট করুন</div>
                <h1>🌾 কৃষকের পক্ষে ফসল লিস্ট</h1>
            </div>
        </div>

        <div class="alert alert-info">
            <i class="bi bi-info-circle"></i>
            প্রথমে নির্বাচন করুন কোন কৃষকের পক্ষে ফসল লিস্ট করতে চান। প্রতি সফল লিস্টিং-এ আপনি ৳২০ কমিশন পাবেন।
        </div>

        <div class="dash-card">
            <h3 style="margin:0 0 14px;"><i class="bi bi-people"></i> এসাইন্ড কৃষক নির্বাচন করুন</h3>
            <?php if (empty($farmers)): ?>
                <div class="empty-state">
                    <i class="bi bi-people"></i>
                    <h4>কোনো এসাইন্ড কৃষক নেই</h4>
                    <p>প্রথমে একটি কৃষক নিবন্ধন করুন।</p>
                    <a href="<?= BASE_URL ?>/agent/farmers/register" class="nav-pill-btn primary"><i class="bi bi-person-plus"></i> কৃষক নিবন্ধন করুন</a>
                </div>
            <?php else: ?>
            <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 12px;">
                <?php foreach ($farmers as $f): ?>
                    <a href="<?= BASE_URL ?>/agent/crops/list/<?= (int)$f['user_id'] ?>" style="text-decoration:none; color:inherit;">
                        <div style="background:#fff; border:1.5px solid var(--gray-200); border-radius: 12px; padding: 14px; transition: all 0.2s; cursor:pointer;" onmouseover="this.style.borderColor='var(--m1-primary)';this.style.transform='translateY(-2px)';this.style.boxShadow='0 6px 16px rgba(0,0,0,0.08)';" onmouseout="this.style.borderColor='var(--gray-200)';this.style.transform='';this.style.boxShadow='';">
                            <div style="display:flex; gap:12px; align-items:center;">
                                <div style="width:48px; height:48px; border-radius:50%; background: var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:20px;"><?= e(mb_substr($f['full_name'], 0, 1, 'UTF-8')) ?></div>
                                <div style="flex:1; min-width:0;">
                                    <strong><?= e($f['full_name']) ?></strong>
                                    <div style="font-size:11px; color:var(--gray-500);"><?= e($f['phone']) ?><?php if ($f['district_name']): ?> • <?= e($f['district_name']) ?><?php endif; ?></div>
                                </div>
                                <i class="bi bi-chevron-right" style="color:var(--gray-400);"></i>
                            </div>
                        </div>
                    </a>
                <?php endforeach; ?>
            </div>
            <?php endif; ?>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
