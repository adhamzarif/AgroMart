<?php 
require __DIR__ . '/../../includes/header.php';

$districts = $districts ?? [];
$districtNameBn = [
    'Bagerhat' => 'বাগেরহাট',
    'Bandarban' => 'বান্দরবান',
    'Barguna' => 'বরগুনা',
    'Barishal' => 'বরিশাল',
    'Bhola' => 'ভোলা',
    'Bogra' => 'বগুড়া',
    'Brahmanbaria' => 'ব্রাহ্মণবাড়িয়া',
    'Chandpur' => 'চাঁদপুর',
    'Chapai Nawabganj' => 'চাঁপাইনবাবগঞ্জ',
    'Chattogram' => 'চট্টগ্রাম',
    'Chuadanga' => 'চুয়াডাঙ্গা',
    'Comilla' => 'কুমিল্লা',
    'Cox\'s Bazar' => 'কক্সবাজার',
    'Dhaka' => 'ঢাকা',
    'Dinajpur' => 'দিনাজপুর',
    'Faridpur' => 'ফরিদপুর',
    'Feni' => 'ফেনী',
    'Gaibandha' => 'গাইবান্ধা',
    'Gazipur' => 'গাজীপুর',
    'Gopalganj' => 'গোপালগঞ্জ',
    'Habiganj' => 'হবিগঞ্জ',
    'Jamalpur' => 'জামালপুর',
    'Jashore' => 'যশোর',
    'Jhalokati' => 'ঝালকাঠি',
    'Jhenaidah' => 'ঝিনাইদহ',
    'Joypurhat' => 'জয়পুরহাট',
    'Khagrachhari' => 'খাগড়াছড়ি',
    'Khulna' => 'খুলনা',
    'Kishoreganj' => 'কিশোরগঞ্জ',
    'Kurigram' => 'কুড়িগ্রাম',
    'Kushtia' => 'কুষ্টিয়া',
    'Lakshmipur' => 'লক্ষ্মীপুর',
    'Lalmonirhat' => 'লালমনিরহাট',
    'Madaripur' => 'মাদারীপুর',
    'Magura' => 'মাগুরা',
    'Manikganj' => 'মানিকগঞ্জ',
    'Meherpur' => 'মেহেরপুর',
    'Moulvibazar' => 'মৌলভীবাজার',
    'Munshiganj' => 'মুন্সিগঞ্জ',
    'Mymensingh' => 'ময়মনসিংহ',
    'Naogaon' => 'নওগাঁ',
    'Narail' => 'নড়াইল',
    'Narayanganj' => 'নারায়ণগঞ্জ',
    'Narsingdi' => 'নরসিংদী',
    'Natore' => 'নাটোর',
    'Netrokona' => 'নেত্রকোণা',
    'Nilphamari' => 'নীলফামারী',
    'Noakhali' => 'নোয়াখালী',
    'Pabna' => 'পাবনা',
    'Panchagarh' => 'পঞ্চগড়',
    'Patuakhali' => 'পটুয়াখালী',
    'Pirojpur' => 'পিরোজপুর',
    'Rajbari' => 'রাজবাড়ী',
    'Rajshahi' => 'রাজশাহী',
    'Rangamati' => 'রাঙ্গামাটি',
    'Rangpur' => 'রংপুর',
    'Satkhira' => 'সাতক্ষীরা',
    'Shariatpur' => 'শরীয়তপুর',
    'Sherpur' => 'শেরপুর',
    'Sirajganj' => 'সিরাজগঞ্জ',
    'Sunamganj' => 'সুনামগঞ্জ',
    'Sylhet' => 'সিলেট',
    'Tangail' => 'টাঙ্গাইল',
    'Thakurgaon' => 'ঠাকুরগাঁও',
];
foreach ($districts as &$d) {
    $d['district_name_bn'] = $districtNameBn[$d['district_name']] ?? $d['district_name'];
}
unset($d);
$selectedDistrictName = '';
if (!empty($old['districtId'])) {
    foreach ($districts as $d) {
        if ((int)$d['district_id'] === (int)$old['districtId']) {
            $selectedDistrictName = $d['district_name_bn'];
            break;
        }
    }
}
?>

<style>
    .reg-page {
        min-height: 100vh; display: flex; align-items: center; justify-content: center;
        background: linear-gradient(135deg, #f0f7ee 0%, #e8f5e9 50%, #f5f9f4 100%);
        padding: 40px 20px;
    }
    .reg-box {
        width: 100%; max-width: 600px; background: #fff;
        border-radius: 20px; box-shadow: 0 8px 40px rgba(0,0,0,0.08);
        padding: 40px 36px;
    }
    .reg-box .logo { text-align: center; margin-bottom: 8px; }
    .reg-box .logo a { font-family: var(--font-display); font-size: 26px; font-weight: 800; color: var(--m1-primary); text-decoration: none; }
    .reg-box .form-title { text-align: center; font-size: 22px; font-weight: 700; color: var(--gray-900); margin: 0 0 4px; }
    .reg-box .form-sub { text-align: center; font-size: 13px; color: var(--gray-500); margin: 0 0 24px; }

    .role-selector { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 22px; }
    .role-card {
        position: relative; padding: 14px 10px; text-align: center; border-radius: 12px;
        border: 2px solid var(--gray-200); background: #fff; cursor: pointer; transition: all 0.2s;
    }
    .role-card:hover { border-color: var(--gray-300); }
    .role-card.active { border-color: var(--m1-primary); background: #f0f9f0; }
    .role-card .r-icon { font-size: 24px; color: var(--gray-400); margin-bottom: 4px; transition: color 0.2s; }
    .role-card.active .r-icon { color: var(--m1-primary); }
    .role-card .r-label { font-size: 13px; font-weight: 600; color: var(--gray-700); }
    .role-card .r-check {
        position: absolute; top: 6px; right: 6px; width: 18px; height: 18px; border-radius: 50%;
        background: var(--m1-primary); color: #fff; font-size: 10px; display: none;
        align-items: center; justify-content: center;
    }
    .role-card.active .r-check { display: flex; }
    .role-card input { display: none; }

    .reg-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 18px; }
    .reg-grid.full { grid-template-columns: 1fr; }
    .f-label { display: block; font-size: 13px; font-weight: 600; color: var(--gray-700); margin-bottom: 6px; }
    .f-label .req { color: #e53935; }
    .f-input, .f-select { width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 10px; font-size: 14px; color: var(--gray-800); background: #fff; outline: none; transition: border-color 0.2s, box-shadow 0.2s; box-sizing: border-box; }
    .f-input:focus, .f-select:focus { border-color: var(--m1-primary); box-shadow: 0 0 0 3px rgba(46,125,50,0.1); }
    
    /* Custom District Dropdown Styles */
    .reg-custom-dd { position: relative; }
    .reg-dd-trigger {
        width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 10px; font-size: 14px; color: var(--gray-800); background: #fff;
        cursor: pointer; outline: none; display: flex; align-items: center; justify-content: space-between; gap: 12px;
        transition: all 0.2s; user-select: none; box-sizing: border-box;
    }
    .reg-dd-trigger.placeholder { color: #9ca3af; }
    .reg-dd-trigger:hover { border-color: var(--m1-primary); background: #f9fafb; }
    .reg-dd-trigger.open { border-color: var(--m1-primary); background: #fff; box-shadow: 0 0 0 3px rgba(46,125,50,0.1); }
    .reg-dd-arrow { color: var(--m1-primary); font-size: 13px; line-height: 1; transition: transform 0.25s; }
    .reg-dd-trigger.open .reg-dd-arrow { transform: rotate(180deg); }
    .reg-dd-panel {
        display: none; position: absolute; bottom: calc(100% + 8px); left: 0; right: 0; z-index: 120;
        background: #fff; border: 1.5px solid var(--gray-200); border-radius: 10px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.1); overflow: hidden;
    }
    .reg-dd-panel.show { display: block; }
    .reg-dd-search-wrap { padding: 10px 12px; border-bottom: 1px solid #eef2ee; background: #fafafa; }
    .reg-dd-search { width: 100% !important; padding: 10px 12px !important; border-radius: 8px !important; font-size: 13px !important; border: 1px solid #e5e7eb !important; }
    .reg-dd-search::placeholder { color: #9ca3af; }
    .reg-dd-options { max-height: 180px; overflow-y: auto; padding: 4px 0; }
    .reg-dd-opt {
        padding: 10px 14px; font-size: 14px; color: #1f2937; cursor: pointer;
        transition: background 0.15s, color 0.15s;
    }
    .reg-dd-opt:hover { background: #f0f9f0; color: var(--m1-primary); }
    .reg-dd-opt.selected { background: #e8f5e9; color: var(--m1-primary); font-weight: 600; }
    .reg-dd-empty { padding: 12px 14px; font-size: 13px; color: #6b7280; text-align: center; }
    .reg-btn {
        width: 100%; padding: 13px; border: none; border-radius: 12px; font-size: 15px; font-weight: 700;
        color: #fff; background: linear-gradient(135deg, #2e7d32, #1b5e20); cursor: pointer;
        transition: transform 0.2s, box-shadow 0.2s;
    }
    .reg-btn:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(46,125,50,0.3); }
    .reg-footer { text-align: center; margin-top: 20px; font-size: 13px; color: var(--gray-500); }
    .reg-footer a { color: var(--m1-primary); font-weight: 600; text-decoration: none; }
    .form-hint { font-size: 11px; color: var(--gray-500); margin-top: 4px; }

    @media (max-width: 600px) {
        .reg-box { padding: 32px 22px; }
        .reg-grid { grid-template-columns: 1fr; }
        .role-selector { grid-template-columns: 1fr; }
    }
</style>

<?php $old = $old ?? []; ?>

<div class="reg-page">
    <div class="reg-box">
        <div class="logo"><a href="<?= BASE_URL ?>/">🌾 AgroFin</a></div>
        <h2 class="form-title">নতুন অ্যাকাউন্ট তৈরি করুন</h2>
        <p class="form-sub">আজই AgroFin ইকোসিস্টেমে যুক্ত হোন</p>

        <form action="<?= BASE_URL ?>/auth/register" method="POST" id="regForm">
            <?= Csrf::field() ?>

            <!-- Role Selector -->
            <div class="role-selector">
                <?php
                $rolesIn = (array)($old['roles'] ?? ['Farmer']);
                $isF = in_array('Farmer', $rolesIn, true);
                $isB = in_array('Buyer',  $rolesIn, true);
                $isA = in_array('Agent',  $rolesIn, true);
                ?>
                <label class="role-card <?= $isF ? 'active' : '' ?>">
                    <input type="checkbox" name="roles[]" value="Farmer" <?= $isF ? 'checked' : '' ?>>
                    <div class="r-check"><i class="bi bi-check"></i></div>
                    <div class="r-icon"><i class="bi bi-flower2"></i></div>
                    <div class="r-label">কৃষক</div>
                </label>
                <label class="role-card <?= $isB ? 'active' : '' ?>">
                    <input type="checkbox" name="roles[]" value="Buyer" <?= $isB ? 'checked' : '' ?>>
                    <div class="r-check"><i class="bi bi-check"></i></div>
                    <div class="r-icon"><i class="bi bi-cart3"></i></div>
                    <div class="r-label">ক্রেতা</div>
                </label>
                <label class="role-card <?= $isA ? 'active' : '' ?>">
                    <input type="checkbox" name="roles[]" value="Agent" <?= $isA ? 'checked' : '' ?>>
                    <div class="r-check"><i class="bi bi-check"></i></div>
                    <div class="r-icon"><i class="bi bi-headset"></i></div>
                    <div class="r-label">এজেন্ট</div>
                </label>
            </div>
            <div class="form-hint" style="margin-top:-10px; margin-bottom:18px; text-align:center;">কৃষক + ক্রেতা একসাথে নেওয়া যাবে। এজেন্ট আলাদাভাবে।</div>

            <div class="reg-grid">
                <div>
                    <label class="f-label">পুরো নাম <span class="req">*</span></label>
                    <input type="text" name="full_name" class="f-input" placeholder="আপনার পূর্ণ নাম" required value="<?= e($old['fullName'] ?? '') ?>">
                </div>
                <div>
                    <label class="f-label">মোবাইল নম্বর <span class="req">*</span></label>
                    <input type="tel" name="phone" class="f-input" placeholder="01XXXXXXXXX" pattern="01[0-9]{9}" required value="<?= e($old['phone'] ?? '') ?>">
                </div>
                <div>
                    <label class="f-label">ইমেইল</label>
                    <input type="email" name="email" class="f-input" placeholder="email@example.com" value="<?= e($old['email'] ?? '') ?>">
                </div>
                <div>
                    <label class="f-label">জেলা <span class="req">*</span></label>
                    <input type="hidden" name="district_id" id="regDistrictVal" value="<?= e($old['districtId'] ?? '') ?>">
                    <div class="reg-custom-dd" data-dd="district">
                        <div class="reg-dd-trigger <?= empty($selectedDistrictName) ? 'placeholder' : '' ?>" data-dd-trigger>
                            <span data-dd-label><?= e($selectedDistrictName ?: 'জেলা নির্বাচন করুন') ?></span>
                            <span class="reg-dd-arrow">⌄</span>
                        </div>
                        <div class="reg-dd-panel" data-dd-panel>
                            <div class="reg-dd-search-wrap">
                                <input type="text" class="reg-dd-search" data-dd-search placeholder="জেলা খুঁজুন...">
                            </div>
                            <div class="reg-dd-options" data-dd-options></div>
                        </div>
                    </div>
                </div>
                <div id="nidField" style="display: <?= $isA ? 'block' : 'none' ?>;">
                    <label class="f-label">NID নম্বর <span id="nidReq" class="req" style="display: <?= $isA ? 'inline' : 'none' ?>;">*</span></label>
                    <input type="text" name="nid_number" id="nidInput" class="f-input" placeholder="১০, ১৩ অথবা ১৭ ডিজিট" value="<?= e($old['nid'] ?? '') ?>">
                </div>
                <div>
                    <label class="f-label">ঠিকানা</label>
                    <input type="text" name="address" class="f-input" placeholder="গ্রাম/পাড়া, উপজেলা" value="<?= e($old['address'] ?? '') ?>">
                </div>
                <div>
                    <label class="f-label">পাসওয়ার্ড <span class="req">*</span></label>
                    <input type="password" name="password" class="f-input" placeholder="কমপক্ষে ৬ অক্ষর" minlength="6" required>
                </div>
                <div>
                    <label class="f-label">পাসওয়ার্ড পুনরায় <span class="req">*</span></label>
                    <input type="password" name="confirm_password" class="f-input" placeholder="পুনরায় টাইপ করুন" minlength="6" required>
                </div>
            </div>

            <button type="submit" class="reg-btn"><i class="bi bi-person-plus"></i>&nbsp; অ্যাকাউন্ট তৈরি করুন</button>
        </form>

        <div class="reg-footer">
            ইতোমধ্যে অ্যাকাউন্ট আছে? <a href="<?= BASE_URL ?>/auth/login">লগইন করুন →</a>
        </div>
    </div>
</div>

<script>
(function(){
    var cards = document.querySelectorAll('.role-card');
    var nidField = document.getElementById('nidField');
    var nidReq = document.getElementById('nidReq');
    var nidInput = document.getElementById('nidInput');

    cards.forEach(function(card) {
        card.addEventListener('click', function(e) {
            e.preventDefault();
            var cb = this.querySelector('input[type=checkbox]');
            var val = cb.value;

            if (val === 'Agent') {
                // Agent is exclusive
                if (!this.classList.contains('active')) {
                    cards.forEach(function(c){ c.classList.remove('active'); c.querySelector('input').checked = false; });
                    this.classList.add('active'); cb.checked = true;
                } else {
                    this.classList.remove('active'); cb.checked = false;
                }
            } else {
                // Farmer/Buyer toggle; deselect Agent first
                var agentCard = document.querySelector('.role-card input[value="Agent"]').closest('.role-card');
                agentCard.classList.remove('active'); agentCard.querySelector('input').checked = false;
                this.classList.toggle('active');
                cb.checked = this.classList.contains('active');
            }

            // Ensure at least one is selected
            if (!document.querySelectorAll('.role-card.active').length) {
                this.classList.add('active'); cb.checked = true;
            }

            // Show NID field if agent
            var agentSelected = document.querySelector('.role-card input[value="Agent"]').checked;
            nidField.style.display = agentSelected ? 'block' : 'none';
            nidReq.style.display = agentSelected ? 'inline' : 'none';
            if (agentSelected) nidInput.setAttribute('required', 'required'); else nidInput.removeAttribute('required');
        });
    });

    // ─── District Custom Dropdown ───
    const districtData = {
        items: <?= json_encode(array_values($districts), JSON_UNESCAPED_UNICODE) ?>,
        defaultLabel: 'জেলা নির্বাচন করুন'
    };

    function closeRegDropdowns(except = null) {
        document.querySelectorAll('.reg-custom-dd').forEach(dropdown => {
            if (dropdown === except) return;
            dropdown.querySelector('[data-dd-panel]')?.classList.remove('show');
            dropdown.querySelector('[data-dd-trigger]')?.classList.remove('open');
        });
    }

    function initRegDropdown(dropdown) {
        const trigger = dropdown.querySelector('[data-dd-trigger]');
        const label = dropdown.querySelector('[data-dd-label]');
        const panel = dropdown.querySelector('[data-dd-panel]');
        const search = dropdown.querySelector('[data-dd-search]');
        const options = dropdown.querySelector('[data-dd-options]');
        const hiddenInput = document.getElementById('regDistrictVal');

        function renderOptions(keyword = '') {
            const query = keyword.trim().toLowerCase();
            const filtered = districtData.items.filter(item =>
                item.district_name_bn.toLowerCase().includes(query) ||
                item.district_name.toLowerCase().includes(query)
            );
            options.innerHTML = filtered.length
                ? filtered.map(item => `<div class="reg-dd-opt" data-value="${item.district_id}">${item.district_name_bn}</div>`).join('')
                : '<div class="reg-dd-empty">কোনো ফলাফল পাওয়া যায়নি</div>';
        }

        renderOptions();

        trigger.addEventListener('click', () => {
            const isOpen = panel.classList.contains('show');
            closeRegDropdowns(dropdown);
            panel.classList.toggle('show', !isOpen);
            trigger.classList.toggle('open', !isOpen);
            if (!isOpen && search) {
                search.value = '';
                renderOptions();
                setTimeout(() => search.focus(), 30);
            }
        });

        if (search) {
            search.addEventListener('input', () => renderOptions(search.value));
        }

        options.addEventListener('click', event => {
            const option = event.target.closest('.reg-dd-opt');
            if (!option) return;

            const value = option.dataset.value;
            label.textContent = option.textContent;
            hiddenInput.value = value;
            trigger.classList.remove('placeholder');
            options.querySelectorAll('.reg-dd-opt').forEach(opt => opt.classList.toggle('selected', opt === option));
            panel.classList.remove('show');
            trigger.classList.remove('open');
        });
    }

    document.querySelectorAll('.reg-custom-dd').forEach(initRegDropdown);
    document.addEventListener('click', event => {
        if (!event.target.closest('.reg-custom-dd')) closeRegDropdowns();
    });
})();
</script>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
