<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<div style="min-height: 60vh; display: flex; align-items: center; justify-content: center; padding: 40px 20px;">
    <div style="text-align: center; max-width: 480px;">
        <div style="font-size: 96px; font-weight: 800; background: linear-gradient(135deg, var(--m1-primary), var(--m1-light)); -webkit-background-clip: text; background-clip: text; color: transparent; margin-bottom: 10px;">৪০৪</div>
        <h2 style="font-size: 26px; color: var(--gray-900); margin-bottom: 12px;">পেজটি খুঁজে পাওয়া যায়নি</h2>
        <p style="font-size: 15px; color: var(--gray-600); margin-bottom: 28px;">আপনি যে পেজটি খুঁজছেন তা সরানো হয়েছে বা ইউআরএলটি ভুল হতে পারে।</p>
        <a href="<?= BASE_URL ?>/" class="nav-pill-btn primary"><i class="bi bi-house"></i> হোমপেজে ফিরে যান</a>
    </div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
