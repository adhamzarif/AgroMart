<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<style>
.f-group { margin-bottom: 16px; }
.f-label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; }
.f-input, .f-select { width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; }
.f-input:focus, .f-select:focus { border-color: var(--m4-primary); }
.f-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.f-row-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; }
.chip-grid { display:grid; grid-template-columns: repeat(auto-fill, minmax(160px,1fr)); gap: 6px; max-height: 220px; overflow-y: auto; padding: 12px; border: 1.5px solid var(--gray-200); border-radius: 8px; }
.chip-grid label { display:flex; gap:6px; align-items:center; font-size:13px; padding:6px 8px; border-radius:6px; cursor:pointer; }
.chip-grid label:hover { background: var(--gray-50); }
.vehicle-chips { display:flex; gap: 10px; flex-wrap:wrap; }
.vehicle-chips label { display:flex; gap:6px; align-items:center; padding: 8px 14px; border: 1.5px solid var(--gray-200); border-radius: 99px; cursor: pointer; font-size: 13px; }
.vehicle-chips label:has(input:checked) { background: var(--m4-primary); color: #fff; border-color: var(--m4-primary); }
</style>

<?php
$selectedDistricts = $partner ? (is_array($partner['service_districts']) ? $partner['service_districts'] : json_decode($partner['service_districts'], true) ?? []) : [];
$selectedVehicles = $partner ? (is_array($partner['vehicle_types']) ? $partner['vehicle_types'] : json_decode($partner['vehicle_types'], true) ?? []) : [];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/transport">পরিবহন</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> <?= $partner ? 'সম্পাদনা' : 'নতুন' ?></div>
                <h1><?= $partner ? '✏ পার্টনার সম্পাদনা' : '🚚 নতুন পরিবহন পার্টনার' ?></h1>
            </div>
        </div>

        <div class="dash-card">
            <form method="POST">
                <?= Csrf::field() ?>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">কোম্পানির নাম *</label>
                        <input type="text" name="partner_name" class="f-input" required maxlength="100" value="<?= e($partner['partner_name'] ?? '') ?>" placeholder="যেমন: ঢাকা ট্রান্সপোর্ট লি.">
                    </div>
                    <div class="f-group">
                        <label class="f-label">যোগাযোগ ব্যক্তি</label>
                        <input type="text" name="contact_person" class="f-input" maxlength="100" value="<?= e($partner['contact_person'] ?? '') ?>" placeholder="ম্যানেজারের নাম">
                    </div>
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">যোগাযোগ ফোন *</label>
                        <input type="text" name="contact_phone" class="f-input" required pattern="01[3-9][0-9]{8}" value="<?= e($partner['contact_phone'] ?? '') ?>" placeholder="০১৭XXXXXXXX">
                    </div>
                    <div class="f-group">
                        <label class="f-label">ইমেল</label>
                        <input type="email" name="contact_email" class="f-input" value="<?= e($partner['contact_email'] ?? '') ?>" placeholder="contact@company.com">
                    </div>
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">প্রতি কিমি রেট (৳) *</label>
                        <input type="number" name="base_rate_per_km" class="f-input" required step="0.01" min="0.01" value="<?= e($partner['base_rate_per_km'] ?? '') ?>" placeholder="যেমন: 25.50">
                    </div>
                    <div class="f-group">
                        <label class="f-label">ন্যূনতম চার্জ (৳) *</label>
                        <input type="number" name="min_charge" class="f-input" required step="0.01" min="0" value="<?= e($partner['min_charge'] ?? '') ?>" placeholder="যেমন: 200">
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">যানবাহন প্রকার * (একাধিক নির্বাচন করুন)</label>
                    <div class="vehicle-chips">
                        <?php foreach (['pickup'=>'🛻 Pickup','truck'=>'🚛 Truck','van'=>'🚐 Van','motorcycle'=>'🏍 Motorcycle'] as $k => $v): ?>
                            <label>
                                <input type="checkbox" name="vehicle_types[]" value="<?= $k ?>" <?= in_array($k, $selectedVehicles) ? 'checked' : '' ?>>
                                <?= $v ?>
                            </label>
                        <?php endforeach; ?>
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">সার্ভিস জেলা * (একাধিক নির্বাচন করুন)</label>
                    <div style="margin-bottom: 6px;">
                        <button type="button" onclick="document.querySelectorAll('input[name=\'service_districts[]\']').forEach(c=>c.checked=true);" class="nav-pill-btn ghost" style="font-size:11px; padding:4px 10px;">সব নির্বাচন</button>
                        <button type="button" onclick="document.querySelectorAll('input[name=\'service_districts[]\']').forEach(c=>c.checked=false);" class="nav-pill-btn ghost" style="font-size:11px; padding:4px 10px;">সব মুছুন</button>
                    </div>
                    <div class="chip-grid">
                        <?php foreach ($districts as $d): ?>
                            <label>
                                <input type="checkbox" name="service_districts[]" value="<?= (int)$d['district_id'] ?>" <?= in_array($d['district_id'], $selectedDistricts) ? 'checked' : '' ?>>
                                <?= e($d['district_name']) ?>
                            </label>
                        <?php endforeach; ?>
                    </div>
                </div>

                <div style="display:flex; gap:10px; margin-top: 18px; border-top: 1px solid var(--gray-100); padding-top: 16px;">
                    <button type="submit" class="nav-pill-btn primary" style="background:var(--m4-primary);"><i class="bi bi-save"></i> <?= $partner ? 'আপডেট' : 'সংরক্ষণ' ?> করুন</button>
                    <a href="<?= BASE_URL ?>/admin/transport" class="nav-pill-btn ghost">বাতিল</a>
                </div>
            </form>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
