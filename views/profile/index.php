<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/">হোম</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> প্রোফাইল</div>
                <h1>আমার প্রোফাইল</h1>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1.6fr; gap: 22px;">
            <!-- LEFT: avatar card -->
            <div class="dash-card" style="text-align: center;">
                <div style="width:120px; height:120px; margin:0 auto 14px; border-radius:50%; background: var(--grad-m1); color:#fff; font-size:48px; font-weight:700; display:flex; align-items:center; justify-content:center; overflow:hidden;">
                    <?php if (!empty($user['profile_picture']) && file_exists(UPLOAD_PATH . '/profiles/' . $user['profile_picture'])): ?>
                        <img src="<?= e(image_variant_url('profiles/' . $user['profile_picture'], 'thumb')) ?>" alt="" style="width:100%; height:100%; object-fit:cover;">
                    <?php else: ?>
                        <?= e(mb_substr($user['full_name'], 0, 1, 'UTF-8')) ?>
                    <?php endif; ?>
                </div>
                <h3 style="margin:0 0 4px; font-size:18px;"><?= e($user['full_name']) ?></h3>
                <div style="font-size:13px; color:var(--gray-500); margin-bottom: 14px;"><?= e($user['phone']) ?></div>
                <div style="display:flex; gap:6px; flex-wrap:wrap; justify-content:center; margin-bottom:14px;">
                    <?php foreach ($roles as $r): ?>
                        <span class="badge badge-<?= $r === 'farmer' ? 'farmer' : ($r === 'buyer' ? 'buyer' : ($r === 'agent' ? 'agent' : 'neutral')) ?>"><?= e(role_labels()[ucfirst($r)] ?? $r) ?></span>
                    <?php endforeach; ?>
                </div>
                <div style="border-top: 1px solid var(--gray-100); padding-top: 14px; font-size:13px; color:var(--gray-600); text-align:left;">
                    <div style="margin-bottom:6px;"><i class="bi bi-envelope text-muted"></i> <?= e($user['email'] ?? '—') ?></div>
                    <div style="margin-bottom:6px;"><i class="bi bi-geo-alt text-muted"></i> <?= e($user['district_name'] ?? '—') ?></div>
                    <div style="margin-bottom:6px;"><i class="bi bi-wallet text-muted"></i> ওয়ালেট: <?= bdt($user['wallet_balance'], 0) ?></div>
                    <div><i class="bi bi-clock text-muted"></i> যোগ দিয়েছেন: <?= bn_date($user['created_at']) ?></div>
                </div>
                <div style="display:flex; gap:6px; flex-wrap:wrap; justify-content:center; margin-top:14px;">
                    <span class="badge badge-<?= $user['phone_verified'] ? 'success' : 'warning' ?>">📱 <?= $user['phone_verified'] ? 'ফোন যাচাইকৃত' : 'ফোন অযাচাইকৃত' ?></span>
                    <?php if ($user['email']): ?>
                        <span class="badge badge-<?= $user['email_verified'] ? 'success' : 'warning' ?>">📧 <?= $user['email_verified'] ? 'ইমেইল যাচাইকৃত' : 'ইমেইল অযাচাইকৃত' ?></span>
                    <?php endif; ?>
                    <?php if ($user['nid_number']): ?>
                        <span class="badge badge-<?= $user['nid_verified'] ? 'success' : 'warning' ?>">🆔 <?= $user['nid_verified'] ? 'NID যাচাইকৃত' : 'NID অযাচাইকৃত' ?></span>
                    <?php endif; ?>
                </div>
            </div>

            <!-- RIGHT: edit forms -->
            <div>
                <div class="dash-card">
                    <h3 style="margin: 0 0 18px; font-size:17px; display:flex; align-items:center; gap:8px;"><i class="bi bi-pencil-square" style="color:var(--m1-primary)"></i> প্রোফাইল তথ্য আপডেট</h3>
                    <form method="POST" action="<?= BASE_URL ?>/profile/update" enctype="multipart/form-data">
                        <?= Csrf::field() ?>
                        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:14px;">
                            <div>
                                <label class="label">পুরো নাম <span class="req">*</span></label>
                                <input type="text" name="full_name" class="input" value="<?= e($user['full_name']) ?>" required>
                            </div>
                            <div>
                                <label class="label">মোবাইল নম্বর</label>
                                <input type="text" class="input" value="<?= e($user['phone']) ?>" readonly style="background:var(--gray-50)" title="মোবাইল নম্বর পরিবর্তনযোগ্য নয়">
                            </div>
                            <div>
                                <label class="label">ইমেইল</label>
                                <input type="email" name="email" class="input" value="<?= e($user['email']) ?>">
                            </div>
                            <div>
                                <label class="label">জেলা <span class="req">*</span></label>
                                <select name="district_id" class="select" required>
                                    <?php foreach ($districts as $d): ?>
                                        <option value="<?= (int)$d['district_id'] ?>" <?= $d['district_id'] == $user['district_id'] ? 'selected' : '' ?>><?= e($d['district_name']) ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                            <div style="grid-column: 1 / -1;">
                                <label class="label">ঠিকানা</label>
                                <input type="text" name="address" class="input" value="<?= e($user['address']) ?>">
                            </div>
                            <div style="grid-column: 1 / -1;">
                                <label class="label">প্রোফাইল ছবি (সর্বোচ্চ ২ MB, JPG/PNG/WEBP)</label>
                                <input type="file" name="profile_picture" class="input" accept="image/jpeg,image/png,image/webp">
                            </div>
                        </div>
                        <button type="submit" class="nav-pill-btn primary" style="margin-top:18px;"><i class="bi bi-save"></i> সংরক্ষণ করুন</button>
                    </form>
                </div>

                <div class="dash-card">
                    <h3 style="margin: 0 0 18px; font-size:17px; display:flex; align-items:center; gap:8px;"><i class="bi bi-shield-lock" style="color:var(--m3-primary)"></i> পাসওয়ার্ড পরিবর্তন</h3>
                    <form method="POST" action="<?= BASE_URL ?>/profile/changePassword">
                        <?= Csrf::field() ?>
                        <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:14px;">
                            <div>
                                <label class="label">বর্তমান পাসওয়ার্ড</label>
                                <input type="password" name="current_password" class="input" required>
                            </div>
                            <div>
                                <label class="label">নতুন পাসওয়ার্ড</label>
                                <input type="password" name="new_password" class="input" minlength="6" required>
                            </div>
                            <div>
                                <label class="label">পুনরায়</label>
                                <input type="password" name="confirm_password" class="input" minlength="6" required>
                            </div>
                        </div>
                        <button type="submit" class="nav-pill-btn primary" style="margin-top:18px; background:var(--m3-primary)"><i class="bi bi-key"></i> পাসওয়ার্ড পরিবর্তন</button>
                    </form>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
