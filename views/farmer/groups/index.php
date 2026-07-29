<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> গ্রুপ</div>
                <h1>কৃষক গ্রুপ 👥</h1>
            </div>
            <a href="<?= BASE_URL ?>/farmer/groups/create" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> নতুন গ্রুপ তৈরি</a>
        </div>

        <div class="dash-card" style="background: linear-gradient(135deg, #e8f5e9, #fff); border-left: 4px solid var(--m1-primary);">
            <h3 style="margin:0 0 8px;"><i class="bi bi-info-circle"></i> কৃষক গ্রুপ কেন তৈরি করবেন?</h3>
            <p style="font-size:13px; color:var(--gray-700); margin: 0; line-height:1.7;">
                একই এলাকার কৃষকেরা মিলে গ্রুপ গঠন করলে — বীজ-সার সম্মিলিতভাবে কেনা যায় (কম দামে), বাজারে পৌঁছাতে একসাথে কাজ করা যায়, বড় ক্রেতা থেকে সরাসরি অর্ডার পাওয়া যায়, প্রশিক্ষণ ও তথ্য বিনিময় সহজ হয়। গ্রুপ লিডার সবার পক্ষে যোগাযোগ রাখেন।
            </p>
        </div>

        <!-- My Groups -->
        <div class="dash-card">
            <div class="dash-card-header">
                <h3><i class="bi bi-person-check"></i> আমার গ্রুপ (<?= bn_num(count($myGroups)) ?>)</h3>
            </div>
            <?php if (empty($myGroups)): ?>
                <div class="empty-state">
                    <i class="bi bi-people"></i>
                    <h4>আপনি কোনো গ্রুপে নেই</h4>
                    <p>নিচের লোকাল গ্রুপগুলিতে যোগ দিন অথবা নতুন গ্রুপ তৈরি করুন।</p>
                </div>
            <?php else: ?>
            <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(280px,1fr)); gap: 14px;">
                <?php foreach ($myGroups as $g):
                    $roleLabels = ['leader'=>['👑 লিডার','farmer'], 'treasurer'=>['💰 কোষাধ্যক্ষ','warning'], 'member'=>['👤 সদস্য','info']];
                    $rl = $roleLabels[$g['member_role']] ?? ['👤 সদস্য','info'];
                ?>
                    <a href="<?= BASE_URL ?>/farmer/groups/detail/<?= (int)$g['group_id'] ?>" style="text-decoration:none; color:inherit;">
                        <div style="background:#fff; border:1.5px solid var(--gray-200); border-radius:14px; padding:16px; transition: all 0.2s; cursor:pointer;" onmouseover="this.style.borderColor='var(--m1-primary)';this.style.transform='translateY(-2px)';this.style.boxShadow='0 6px 16px rgba(0,0,0,0.08)';" onmouseout="this.style.borderColor='var(--gray-200)';this.style.transform='';this.style.boxShadow='';">
                            <div style="display:flex; justify-content:space-between; align-items:start; margin-bottom: 8px;">
                                <strong style="font-size:15px;"><?= e($g['group_name']) ?></strong>
                                <span class="badge badge-<?= $rl[1] ?>"><?= $rl[0] ?></span>
                            </div>
                            <div style="font-size:12px; color:var(--gray-500); margin-bottom: 10px;">
                                <i class="bi bi-geo-alt"></i> <?= e($g['district_name']) ?>
                                • <i class="bi bi-people"></i> <?= bn_num($g['total_members']) ?> সদস্য
                            </div>
                            <div style="font-size:11px; color:var(--gray-400); margin-bottom: 6px;">কোড: <code><?= e($g['group_code']) ?></code></div>
                            <div style="font-size:11px; color:var(--gray-500);">আপনার অবদান: <strong><?= bn_num($g['land_contribution_acres']) ?> একর</strong> • যোগদান: <?= bn_date($g['join_date']) ?></div>
                        </div>
                    </a>
                <?php endforeach; ?>
            </div>
            <?php endif; ?>
        </div>

        <!-- Local Groups -->
        <div class="dash-card">
            <div class="dash-card-header">
                <h3><i class="bi bi-geo-alt"></i> আমার জেলার গ্রুপসমূহ (<?= bn_num(count($localGroups)) ?>)</h3>
            </div>
            <?php if (empty($localGroups)): ?>
                <div class="empty-state">
                    <i class="bi bi-search"></i>
                    <h4>এই জেলায় কোনো গ্রুপ নেই</h4>
                    <p>আপনি প্রথম গ্রুপ তৈরি করুন এবং অন্যদের আমন্ত্রণ জানান।</p>
                </div>
            <?php else: ?>
            <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(320px,1fr)); gap: 14px;">
                <?php foreach ($localGroups as $g):
                    $myIds = array_column($myGroups, 'group_id');
                    $isMine = in_array($g['group_id'], $myIds);
                ?>
                    <div class="dash-card" style="margin:0; padding:16px;">
                        <strong style="font-size:15px;"><?= e($g['group_name']) ?></strong>
                        <div style="font-size:12px; color:var(--gray-500); margin: 6px 0;">
                            <i class="bi bi-person-fill"></i> <?= e($g['leader_name']) ?>
                            • <i class="bi bi-people"></i> <?= bn_num($g['total_members']) ?>
                            • <?= bn_num($g['total_land_acres']) ?> একর
                        </div>
                        <?php if ($g['group_description']): ?>
                            <p style="font-size:12px; color:var(--gray-600); margin: 8px 0; line-height:1.5;"><?= e(mb_substr($g['group_description'], 0, 100, 'UTF-8')) ?>...</p>
                        <?php endif; ?>
                        <a href="<?= BASE_URL ?>/farmer/groups/detail/<?= (int)$g['group_id'] ?>" class="nav-pill-btn <?= $isMine ? 'ghost' : 'primary' ?>" style="width:100%; justify-content:center; font-size:13px; margin-top:8px;">
                            <?= $isMine ? '✓ আপনি সদস্য' : 'বিস্তারিত দেখুন' ?>
                        </a>
                    </div>
                <?php endforeach; ?>
            </div>
            <?php endif; ?>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
