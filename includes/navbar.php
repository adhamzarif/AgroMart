<?php
$isLoggedIn = !empty($_SESSION['user_id']);
$activeRole = $_SESSION['active_role'] ?? null;
$available  = $_SESSION['available_roles'] ?? [];
$userName   = $_SESSION['name'] ?? '';
$pp         = $_SESSION['profile_picture'] ?? '';
?>
<style>
    .agro-nav-shell {
        height: 100%; width: 100%; max-width: 1540px; margin: 0 auto; padding: 0 40px;
        display: grid; grid-template-columns: 220px 1fr 320px;
        align-items: center; gap: 24px;
    }
    .agro-brand {
        font-family: var(--font-display); font-size: 26px; font-weight: 800;
        color: var(--m1-primary); text-decoration: none;
    }
    .agro-nav { display: flex; align-items: center; gap: 28px; justify-self: center; }
    .agro-nav a.nav-lnk { color: var(--gray-700); font-weight: 500; font-size: 15px; text-decoration: none; position: relative; padding: 6px 0; transition: color 0.2s; }
    .agro-nav a.nav-lnk::after { content:''; position:absolute; bottom:0; left:0; width:0; height:2px; background:var(--m1-primary); border-radius:2px; transition: width 0.25s ease; }
    .agro-nav a.nav-lnk:hover, .agro-nav a.nav-lnk.active { color: var(--m1-primary); }
    .agro-nav a.nav-lnk:hover::after, .agro-nav a.nav-lnk.active::after { width:100%; }

    .agro-actions { display: flex; gap: 10px; align-items: center; justify-content: flex-end; }
    .nav-pill-btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 18px; border-radius: 999px; font-size: 14px; font-weight: 600; transition: all 0.2s; text-decoration: none; cursor: pointer; border: none; }
    .nav-pill-btn.ghost { color: var(--gray-700); background: transparent; }
    .nav-pill-btn.ghost:hover { background: var(--gray-100); color: var(--m1-primary); }
    .nav-pill-btn.primary { background: var(--m1-primary); color: #fff; box-shadow: 0 2px 8px rgba(46,125,50,0.25); }
    .nav-pill-btn.primary:hover { background: var(--m1-dark); transform: translateY(-1px); }

    .nav-icon-btn { width: 40px; height: 40px; border-radius: 50%; background: transparent; color: var(--gray-700); border: none; cursor: pointer; position: relative; display: inline-flex; align-items: center; justify-content: center; font-size: 18px; }
    .nav-icon-btn:hover { background: var(--gray-100); color: var(--m1-primary); }
    .nav-icon-btn .badge-dot { position: absolute; top: 5px; right: 5px; min-width: 16px; height: 16px; padding: 0 4px; border-radius: 999px; background: var(--danger); color: #fff; font-size: 10px; font-weight: 700; display: flex; align-items: center; justify-content: center; }

    .nav-avatar { width: 38px; height: 38px; border-radius: 50%; background: var(--grad-m1); color: #fff; font-weight: 700; display: inline-flex; align-items: center; justify-content: center; font-size: 14px; overflow: hidden; }
    .nav-avatar img { width: 100%; height: 100%; object-fit: cover; }

    .role-switcher { position: relative; }
    .role-switcher-btn { display: inline-flex; align-items: center; gap: 6px; padding: 7px 12px; border-radius: 999px; background: var(--m1-primary)1a; color: var(--m1-primary); font-size: 13px; font-weight: 600; border: 1.5px solid var(--m1-primary); background: rgba(46,125,50,0.08); cursor: pointer; }
    .role-switcher-btn:hover { background: rgba(46,125,50,0.15); }
    .role-dropdown { position: absolute; top: calc(100% + 8px); right: 0; min-width: 200px; background: #fff; border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.12); padding: 8px; display: none; z-index: 100; }
    .role-dropdown.show { display: block; }
    .role-dropdown a { display: flex; align-items: center; gap: 10px; padding: 10px 12px; color: var(--gray-800); text-decoration: none; border-radius: 8px; font-size: 14px; }
    .role-dropdown a:hover { background: var(--gray-50); color: var(--m1-primary); }
    .role-dropdown a.active { background: rgba(46,125,50,0.1); color: var(--m1-primary); font-weight: 600; }

    .user-menu { position: relative; }
    .user-menu-dd { position: absolute; top: calc(100% + 8px); right: 0; min-width: 240px; background: #fff; border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.12); padding: 8px; display: none; z-index: 100; }
    .user-menu-dd.show { display: block; }
    .user-menu-dd .um-head { padding: 12px; border-bottom: 1px solid var(--gray-100); margin-bottom: 6px; }
    .user-menu-dd .um-name { font-size: 14px; font-weight: 700; color: var(--gray-900); }
    .user-menu-dd .um-role { font-size: 12px; color: var(--gray-500); }
    .user-menu-dd a { display: flex; align-items: center; gap: 10px; padding: 9px 12px; color: var(--gray-800); text-decoration: none; border-radius: 8px; font-size: 14px; }
    .user-menu-dd a:hover { background: var(--gray-50); color: var(--m1-primary); }
    .user-menu-dd a.danger:hover { color: var(--danger); background: var(--danger-bg); }

    .mobile-toggle { display: none; }

    @media (max-width: 1024px) { .agro-nav-shell { grid-template-columns: auto 1fr auto; padding: 0 20px; gap: 16px; } .agro-nav { gap: 18px; } }
    @media (max-width: 820px) {
        .agro-nav { display: none; }
        .agro-actions .label-hide { display: none; }
        .mobile-toggle { display: inline-flex; }
        .agro-nav-shell { grid-template-columns: auto 1fr auto; }
    }
</style>
<nav style="background: #fff; box-shadow: 0 1px 12px rgba(0,0,0,0.06); position: sticky; top: 0; z-index: 1000; height: 68px;">
    <div class="agro-nav-shell">
        <div><a href="<?= BASE_URL ?>/" class="agro-brand">🌾 AgroFin</a></div>

        <?php if (!$isLoggedIn): ?>
            <nav class="agro-nav">
                <a href="<?= BASE_URL ?>/" class="nav-lnk">হোম</a>
                <a href="<?= BASE_URL ?>/features" class="nav-lnk">ফিচারসমূহ</a>
                <a href="<?= BASE_URL ?>/marketplace" class="nav-lnk">মার্কেটপ্লেস</a>
                <a href="<?= BASE_URL ?>/liveprice" class="nav-lnk">লাইভ দাম</a>
                <a href="<?= BASE_URL ?>/how-it-works" class="nav-lnk">কীভাবে কাজ করে</a>
                <a href="<?= BASE_URL ?>/contact" class="nav-lnk">যোগাযোগ</a>
            </nav>
            <div class="agro-actions">
                <a href="<?= BASE_URL ?>/auth/login" class="nav-pill-btn ghost"><i class="bi bi-box-arrow-in-right"></i> লগইন</a>
                <a href="<?= BASE_URL ?>/auth/register" class="nav-pill-btn primary"><i class="bi bi-person-plus"></i> রেজিস্টার</a>
            </div>
        <?php else: ?>
            <nav class="agro-nav">
                <a href="<?= BASE_URL ?>/<?= strtolower($activeRole) ?>/dashboard" class="nav-lnk">ড্যাশবোর্ড</a>
                <a href="<?= BASE_URL ?>/marketplace" class="nav-lnk">মার্কেটপ্লেস</a>
                <a href="<?= BASE_URL ?>/liveprice" class="nav-lnk">লাইভ দাম</a>
            </nav>
            <div class="agro-actions">
                <?php if (count($available) > 1): ?>
                <div class="role-switcher">
                    <button class="role-switcher-btn" type="button" id="roleSwBtn">
                        <i class="bi bi-arrow-left-right"></i>
                        <span class="label-hide"><?= e(role_labels()[$activeRole] ?? $activeRole) ?></span>
                        <i class="bi bi-chevron-down" style="font-size:10px"></i>
                    </button>
                    <div class="role-dropdown" id="roleSwDd">
                        <?php foreach ($available as $r): ?>
                            <a href="<?= BASE_URL ?>/auth/switchRole/<?= e($r) ?>" class="<?= $activeRole === $r ? 'active' : '' ?>">
                                <i class="bi bi-<?= $r === 'Farmer' ? 'flower2' : ($r === 'Buyer' ? 'cart' : ($r === 'Agent' ? 'headset' : 'shield')) ?>"></i>
                                <?= e(role_labels()[$r] ?? $r) ?>
                            </a>
                        <?php endforeach; ?>
                    </div>
                </div>
                <?php endif; ?>

                <button class="nav-icon-btn" type="button" title="বিজ্ঞপ্তি"><i class="bi bi-bell"></i></button>

                <div class="user-menu">
                    <button class="nav-icon-btn" type="button" id="userMenuBtn" style="padding:0;">
                        <span class="nav-avatar">
                            <?php if (!empty($pp) && file_exists(UPLOAD_PATH . '/profiles/' . $pp)): ?>
                                <img src="<?= e(upload_url('profiles/' . $pp)) ?>" alt="">
                            <?php else: ?>
                                <?= e(mb_substr($userName, 0, 1, 'UTF-8')) ?>
                            <?php endif; ?>
                        </span>
                    </button>
                    <div class="user-menu-dd" id="userMenuDd">
                        <div class="um-head">
                            <div class="um-name"><?= e($userName) ?></div>
                            <div class="um-role"><?= e(role_labels()[$activeRole] ?? $activeRole) ?></div>
                        </div>
                        <a href="<?= BASE_URL ?>/profile"><i class="bi bi-person"></i> প্রোফাইল</a>
                        <a href="<?= BASE_URL ?>/profile/settings"><i class="bi bi-gear"></i> সেটিংস</a>
                        <a href="<?= BASE_URL ?>/auth/logout" class="danger"><i class="bi bi-box-arrow-right"></i> লগআউট</a>
                    </div>
                </div>
            </div>
        <?php endif; ?>
    </div>
</nav>

<script>
(function(){
    // Role switcher
    var rb = document.getElementById('roleSwBtn');
    var rd = document.getElementById('roleSwDd');
    if (rb) rb.addEventListener('click', function(e){ e.stopPropagation(); rd.classList.toggle('show'); });
    // User menu
    var ub = document.getElementById('userMenuBtn');
    var ud = document.getElementById('userMenuDd');
    if (ub) ub.addEventListener('click', function(e){ e.stopPropagation(); ud.classList.toggle('show'); });
    document.addEventListener('click', function(){
        if (rd) rd.classList.remove('show');
        if (ud) ud.classList.remove('show');
    });
})();
</script>
