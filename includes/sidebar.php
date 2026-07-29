<?php
if (empty($_SESSION['user_id'])) return;
$role = $_SESSION['active_role'] ?? '';
$curPath = $_SERVER['REQUEST_URI'] ?? '';
function _sb_active($pattern) {
    return strpos($_SERVER['REQUEST_URI'] ?? '', $pattern) !== false ? 'active' : '';
}
?>
<aside class="sidebar" id="sidebar">
    <div class="sidebar-section">প্রধান মেনু</div>
    <a href="<?= BASE_URL ?>/<?= strtolower($role) ?>/dashboard" class="sidebar-link <?= _sb_active('/dashboard') ?>"><i class="bi bi-grid-1x2-fill"></i> ড্যাশবোর্ড</a>

    <?php if ($role === 'Farmer'): ?>
        <a href="<?= BASE_URL ?>/farmer/crops" class="sidebar-link <?= _sb_active('/farmer/crops') ?>"><i class="bi bi-basket"></i> আমার ফসল</a>
        <a href="<?= BASE_URL ?>/farmer/orders" class="sidebar-link <?= _sb_active('/farmer/orders') ?>"><i class="bi bi-bag-check"></i> প্রাপ্ত অর্ডার</a>
        <a href="<?= BASE_URL ?>/farmer/inventory" class="sidebar-link <?= _sb_active('/farmer/inventory') ?>"><i class="bi bi-box-seam"></i> ইনভেন্টরি</a>

        <div class="sidebar-section">আর্থিক সেবা</div>
        <a href="<?= BASE_URL ?>/farmer/loans" class="sidebar-link <?= _sb_active('/farmer/loans') ?>"><i class="bi bi-cash-stack"></i> মাইক্রো-লোন</a>
        <a href="<?= BASE_URL ?>/farmer/wallet" class="sidebar-link <?= _sb_active('/farmer/wallet') ?>"><i class="bi bi-wallet2"></i> আমার ওয়ালেট</a>
        <a href="<?= BASE_URL ?>/farmer/expenses" class="sidebar-link <?= _sb_active('/farmer/expenses') ?>"><i class="bi bi-receipt"></i> খরচ ব্যবস্থাপনা</a>
        <a href="<?= BASE_URL ?>/farmer/profit-loss" class="sidebar-link <?= _sb_active('profit-loss') ?>"><i class="bi bi-graph-up"></i> লাভ-ক্ষতি</a>
        <a href="<?= BASE_URL ?>/farmer/credit-score" class="sidebar-link <?= _sb_active('credit-score') ?>"><i class="bi bi-shield-check"></i> ক্রেডিট স্কোর</a>

        <div class="sidebar-section">যোগাযোগ ও সহায়তা</div>
        <a href="<?= BASE_URL ?>/farmer/messages" class="sidebar-link <?= _sb_active('/messages') ?>"><i class="bi bi-chat-dots"></i> বার্তা</a>
        <a href="<?= BASE_URL ?>/farmer/assistant" class="sidebar-link <?= _sb_active('/assistant') ?>"><i class="bi bi-robot"></i> স্মার্ট অ্যাসিস্ট্যান্ট</a>
        <a href="<?= BASE_URL ?>/farmer/weather" class="sidebar-link <?= _sb_active('/weather') ?>"><i class="bi bi-cloud-sun"></i> আবহাওয়া</a>
        <a href="<?= BASE_URL ?>/farmer/groups" class="sidebar-link <?= _sb_active('/groups') ?>"><i class="bi bi-people"></i> কৃষক গ্রুপ</a>

    <?php elseif ($role === 'Buyer'): ?>
        <a href="<?= BASE_URL ?>/buyer/browse" class="sidebar-link <?= _sb_active('/browse') ?>"><i class="bi bi-shop"></i> ফসল ব্রাউজ করুন</a>
        <a href="<?= BASE_URL ?>/buyer/orders" class="sidebar-link <?= _sb_active('/buyer/orders') ?>"><i class="bi bi-truck"></i> আমার অর্ডার</a>
        <a href="<?= BASE_URL ?>/buyer/favorites" class="sidebar-link <?= _sb_active('/favorites') ?>"><i class="bi bi-heart"></i> প্রিয় তালিকা</a>
        <a href="<?= BASE_URL ?>/buyer/subscriptions" class="sidebar-link <?= _sb_active('/subscriptions') ?>"><i class="bi bi-arrow-repeat"></i> সাবস্ক্রিপশন</a>

        <div class="sidebar-section">যোগাযোগ</div>
        <a href="<?= BASE_URL ?>/buyer/messages" class="sidebar-link <?= _sb_active('/messages') ?>"><i class="bi bi-chat-dots"></i> বার্তা</a>
        <a href="<?= BASE_URL ?>/buyer/payment-methods" class="sidebar-link <?= _sb_active('payment-methods') ?>"><i class="bi bi-credit-card"></i> পেমেন্ট পদ্ধতি</a>

    <?php elseif ($role === 'Agent'): ?>
        <a href="<?= BASE_URL ?>/agent/farmers" class="sidebar-link <?= _sb_active('/farmers') ?>"><i class="bi bi-people-fill"></i> আমার কৃষকরা</a>
        <a href="<?= BASE_URL ?>/agent/register-farmer" class="sidebar-link <?= _sb_active('register-farmer') ?>"><i class="bi bi-person-plus"></i> নতুন কৃষক নিবন্ধন</a>
        <a href="<?= BASE_URL ?>/agent/list-crop" class="sidebar-link <?= _sb_active('list-crop') ?>"><i class="bi bi-basket"></i> ফসল লিস্ট করুন</a>
        <a href="<?= BASE_URL ?>/agent/activities" class="sidebar-link <?= _sb_active('/activities') ?>"><i class="bi bi-list-check"></i> কার্যক্রম</a>
        <a href="<?= BASE_URL ?>/agent/tickets" class="sidebar-link <?= _sb_active('/tickets') ?>"><i class="bi bi-life-preserver"></i> সাপোর্ট টিকেট</a>
        <a href="<?= BASE_URL ?>/agent/earnings" class="sidebar-link <?= _sb_active('/earnings') ?>"><i class="bi bi-wallet2"></i> কমিশন</a>

    <?php elseif ($role === 'Admin'): ?>
        <a href="<?= BASE_URL ?>/admin/users" class="sidebar-link <?= _sb_active('/admin/users') ?>"><i class="bi bi-people-fill"></i> ব্যবহারকারী</a>
        <a href="<?= BASE_URL ?>/admin/loans" class="sidebar-link <?= _sb_active('/admin/loans') ?>"><i class="bi bi-bank"></i> ঋণ অনুমোদন</a>
        <a href="<?= BASE_URL ?>/admin/crops" class="sidebar-link <?= _sb_active('/admin/crops') ?>"><i class="bi bi-basket"></i> ফসল মডারেশন</a>
        <a href="<?= BASE_URL ?>/admin/categories" class="sidebar-link <?= _sb_active('/categories') ?>"><i class="bi bi-tags"></i> ক্যাটাগরি</a>
        <a href="<?= BASE_URL ?>/admin/prices" class="sidebar-link <?= _sb_active('/prices') ?>"><i class="bi bi-tags"></i> মার্কেট প্রাইস</a>
        <a href="<?= BASE_URL ?>/admin/weather" class="sidebar-link <?= _sb_active('/weather') ?>"><i class="bi bi-cloud-rain"></i> আবহাওয়া সতর্কতা</a>
        <a href="<?= BASE_URL ?>/admin/transport" class="sidebar-link <?= _sb_active('/transport') ?>"><i class="bi bi-truck"></i> পরিবহন</a>
        <a href="<?= BASE_URL ?>/admin/announcements" class="sidebar-link <?= _sb_active('/announcements') ?>"><i class="bi bi-megaphone"></i> ঘোষণা</a>
        <a href="<?= BASE_URL ?>/admin/reports" class="sidebar-link <?= _sb_active('/reports') ?>"><i class="bi bi-file-earmark-bar-graph"></i> রিপোর্ট</a>
        <a href="<?= BASE_URL ?>/admin/audit" class="sidebar-link <?= _sb_active('/audit') ?>"><i class="bi bi-clipboard-check"></i> অডিট লগ</a>
    <?php endif; ?>

    <div class="sidebar-section">অ্যাকাউন্ট</div>
    <a href="<?= BASE_URL ?>/profile" class="sidebar-link <?= _sb_active('/profile') ?>"><i class="bi bi-person-circle"></i> প্রোফাইল</a>
    <a href="<?= BASE_URL ?>/auth/logout" class="sidebar-link" style="color: var(--danger);"><i class="bi bi-box-arrow-right"></i> লগআউট</a>
</aside>
