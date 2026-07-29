<?php include __DIR__ . '/../../includes/header.php'; ?>
<?php include __DIR__ . '/../../includes/navbar.php'; ?>

<!-- Bootstrap 5 Grid System -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap-grid.min.css" rel="stylesheet">
<!-- Bootstrap Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<style>
    :root {
        --hiw-primary: #1a5c28;
        --hiw-secondary: #2e7d32;
        --hiw-light: #f0f7ee;
        --hiw-dark: #0d3b1a;
        --hiw-accent: #4caf50;
        --hiw-text: #333333;
        --hiw-muted: #6c757d;
        --hiw-bg: #f0f7ee;
        --hiw-card-bg: #ffffff;
    }

    html {
        scroll-behavior: smooth;
    }

    body {
        background-color: var(--hiw-bg);
        font-family: var(--font-bn), sans-serif;
        color: var(--hiw-text);
        overflow-x: hidden;
    }

    /* Hero Section */
    .hiw-hero {
        background: linear-gradient(135deg, var(--hiw-dark) 0%, var(--hiw-primary) 50%, var(--hiw-secondary) 100%);
        color: #fff;
        padding: 100px 24px;
        position: relative;
        overflow: hidden;
        text-align: center;
    }
    
    .hiw-hero::before {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 60%);
        transform: rotate(30deg);
        z-index: 0;
    }

    .hiw-hero .container {
        position: relative;
        z-index: 1;
    }

    .hiw-hero-title {
        font-size: clamp(36px, 6vw, 56px);
        font-weight: 800;
        margin-bottom: 20px;
        animation: fadeInDown 0.8s ease-out;
    }

    .hiw-hero-subtitle {
        font-size: clamp(16px, 3vw, 20px);
        color: rgba(255, 255, 255, 0.9);
        max-width: 700px;
        margin: 0 auto 40px;
        line-height: 1.6;
        animation: fadeInUp 0.8s ease-out 0.2s both;
    }

    .hiw-hero-img {
        width: 100%;
        max-width: 600px;
        border-radius: 20px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        margin: 0 auto;
        animation: zoomIn 1s ease-out 0.4s both;
    }

    /* Section Headers */
    .section-title {
        text-align: center;
        font-size: 32px;
        font-weight: 800;
        color: var(--hiw-dark);
        margin-bottom: 12px;
    }
    
    .section-subtitle {
        text-align: center;
        font-size: 16px;
        color: var(--hiw-muted);
        margin-bottom: 48px;
    }

    /* Step-by-Step Section */
    .step-section {
        padding: 80px 24px;
        background: var(--hiw-light);
    }

    .step-timeline {
        position: relative;
        max-width: 800px;
        margin: 0 auto;
    }

    .step-timeline::before {
        content: '';
        position: absolute;
        top: 0;
        bottom: 0;
        left: 50%;
        width: 4px;
        background: var(--hiw-accent);
        transform: translateX(-50%);
        border-radius: 2px;
    }

    .step-card-wrapper {
        position: relative;
        width: 50%;
        padding: 20px 40px;
        box-sizing: border-box;
    }

    .step-card-wrapper:nth-child(odd) {
        left: 0;
        text-align: right;
    }

    .step-card-wrapper:nth-child(even) {
        left: 50%;
    }

    .step-dot {
        position: absolute;
        width: 24px;
        height: 24px;
        background: #fff;
        border: 4px solid var(--hiw-accent);
        border-radius: 50%;
        top: 50%;
        transform: translateY(-50%);
        z-index: 2;
    }

    .step-card-wrapper:nth-child(odd) .step-dot {
        right: -12px;
    }

    .step-card-wrapper:nth-child(even) .step-dot {
        left: -12px;
    }

    .step-card {
        background: var(--hiw-card-bg);
        padding: 24px;
        border-radius: 16px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.05);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        position: relative;
    }

    .step-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 15px 40px rgba(46,125,50,0.15);
    }

    .step-num {
        display: inline-block;
        font-size: 14px;
        font-weight: 700;
        color: var(--hiw-accent);
        background: rgba(76,175,80,0.1);
        padding: 4px 12px;
        border-radius: 20px;
        margin-bottom: 12px;
    }

    .step-title {
        font-size: 20px;
        font-weight: 700;
        color: var(--hiw-dark);
        margin-bottom: 8px;
    }

    .step-desc {
        font-size: 15px;
        color: var(--hiw-muted);
        margin: 0;
    }

    @media (max-width: 768px) {
        .step-timeline::before { left: 30px; }
        .step-card-wrapper { width: 100%; padding-left: 70px; padding-right: 0; text-align: left !important; }
        .step-card-wrapper:nth-child(even) { left: 0; }
        .step-dot { left: 18px !important; }
    }

    /* Role Section */
    .role-section {
        padding: 80px 24px;
        background: #fff;
    }

    .role-card {
        background: var(--hiw-card-bg);
        border: 1px solid rgba(46,125,50,0.1);
        border-radius: 16px;
        padding: 32px 24px;
        text-align: center;
        height: 100%;
        transition: all 0.3s ease;
    }

    .role-card:hover {
        border-color: var(--hiw-accent);
        box-shadow: 0 15px 30px rgba(46,125,50,0.1);
        transform: translateY(-8px);
    }

    .role-icon {
        width: 80px;
        height: 80px;
        background: var(--hiw-light);
        color: var(--hiw-primary);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 36px;
        margin: 0 auto 20px;
        transition: transform 0.3s ease;
    }

    .role-card:hover .role-icon {
        transform: scale(1.1) rotate(5deg);
        background: var(--hiw-primary);
        color: #fff;
    }

    .role-title {
        font-size: 22px;
        font-weight: 700;
        color: var(--hiw-dark);
        margin-bottom: 16px;
    }

    .role-list {
        list-style: none;
        padding: 0;
        margin: 0;
        text-align: left;
    }

    .role-list li {
        font-size: 15px;
        color: var(--hiw-muted);
        margin-bottom: 10px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .role-list li i {
        color: var(--hiw-accent);
    }

    /* Smart Features Section */
    .features-section {
        padding: 80px 24px;
        background: var(--hiw-light);
    }

    .feature-chip {
        background: #fff;
        border-radius: 30px;
        padding: 16px 24px;
        display: flex;
        align-items: center;
        gap: 16px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        margin-bottom: 16px;
        transition: all 0.3s ease;
        cursor: default;
    }

    .feature-chip:hover {
        transform: translateX(10px);
        background: var(--hiw-primary);
        color: #fff;
    }

    .feature-chip:hover .fc-icon {
        background: #fff;
        color: var(--hiw-primary);
    }

    .feature-chip:hover .fc-text {
        color: #fff;
    }

    .fc-icon {
        width: 48px;
        height: 48px;
        background: rgba(76,175,80,0.1);
        color: var(--hiw-accent);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        transition: all 0.3s ease;
    }

    .fc-text {
        font-size: 18px;
        font-weight: 600;
        color: var(--hiw-dark);
        transition: color 0.3s ease;
    }

    /* CTA Section */
    .cta-section {
        padding: 100px 24px;
        background: linear-gradient(rgba(13,59,26,0.9), rgba(46,125,50,0.9)), url('https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&w=1920&q=80') center/cover no-repeat;
        text-align: center;
        color: #fff;
    }

    .cta-title {
        font-size: 36px;
        font-weight: 800;
        margin-bottom: 24px;
    }

    .cta-buttons {
        display: flex;
        gap: 16px;
        justify-content: center;
        flex-wrap: wrap;
    }

    .btn-hiw-primary {
        background: #fff;
        color: var(--hiw-primary);
        font-weight: 700;
        padding: 14px 32px;
        border-radius: 30px;
        text-decoration: none;
        transition: all 0.3s ease;
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }

    .btn-hiw-primary:hover {
        transform: translateY(-3px);
        box-shadow: 0 10px 20px rgba(255,255,255,0.2);
    }

    .btn-hiw-outline {
        background: transparent;
        color: #fff;
        font-weight: 700;
        padding: 14px 32px;
        border: 2px solid #fff;
        border-radius: 30px;
        text-decoration: none;
        transition: all 0.3s ease;
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }

    .btn-hiw-outline:hover {
        background: rgba(255,255,255,0.1);
        transform: translateY(-3px);
    }

    /* Animations */
    @keyframes fadeInDown {
        from { opacity: 0; transform: translateY(-30px); }
        to { opacity: 1; transform: translateY(0); }
    }
    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(30px); }
        to { opacity: 1; transform: translateY(0); }
    }
    @keyframes zoomIn {
        from { opacity: 0; transform: scale(0.9); }
        to { opacity: 1; transform: scale(1); }
    }
</style>

<!-- Hero Section -->
<section class="hiw-hero">
    <div class="container">
        <h1 class="hiw-hero-title">🌾 AgroFin কীভাবে কাজ করে?</h1>
        <p class="hiw-hero-subtitle">কৃষক, ক্রেতা এবং এজেন্টদের জন্য সহজ, স্মার্ট ও স্বচ্ছ কৃষি মার্কেটপ্লেস।</p>
        <a href="/AgroFin/marketplace" class="btn-hiw-primary" style="margin-bottom: 48px;">
            মার্কেটপ্লেস দেখুন <i class="bi bi-arrow-right"></i>
        </a>
        <div>
            <img src="https://images.unsplash.com/photo-1592982537447-6f2a6a0a2c07?auto=format&fit=crop&w=1200&q=80" alt="Modern Agriculture" class="hiw-hero-img">
        </div>
    </div>
</section>

<!-- Step-by-Step Section -->
<section class="step-section">
    <div class="container">
        <h2 class="section-title">সহজ ৫টি ধাপ</h2>
        <p class="section-subtitle">যেভাবে পুরো সিস্টেমটি পরিচালিত হয়</p>
        
        <div class="step-timeline">
            <!-- Step 1 -->
            <div class="step-card-wrapper">
                <div class="step-dot"></div>
                <div class="step-card">
                    <span class="step-num">ধাপ ০১</span>
                    <h3 class="step-title">👨‍🌾 কৃষক ফসল যুক্ত করে</h3>
                    <p class="step-desc">কৃষক তার ফসল, মূল্য ও পরিমাণ যোগ করে।</p>
                </div>
            </div>
            
            <!-- Step 2 -->
            <div class="step-card-wrapper">
                <div class="step-dot"></div>
                <div class="step-card">
                    <span class="step-num">ধাপ ০২</span>
                    <h3 class="step-title">🛒 ক্রেতা ফসল খুঁজে</h3>
                    <p class="step-desc">ক্রেতারা অঞ্চল ও দামের ভিত্তিতে ফসল খুঁজে পায়।</p>
                </div>
            </div>
            
            <!-- Step 3 -->
            <div class="step-card-wrapper">
                <div class="step-dot"></div>
                <div class="step-card">
                    <span class="step-num">ধাপ ০৩</span>
                    <h3 class="step-title">💰 অর্ডার ও পেমেন্ট</h3>
                    <p class="step-desc">ক্রেতারা সরাসরি অর্ডার ও পেমেন্ট সম্পন্ন করে।</p>
                </div>
            </div>
            
            <!-- Step 4 -->
            <div class="step-card-wrapper">
                <div class="step-dot"></div>
                <div class="step-card">
                    <span class="step-num">ধাপ ০৪</span>
                    <h3 class="step-title">🚚 ডেলিভারি ও ট্র্যাকিং</h3>
                    <p class="step-desc">লজিস্টিক সিস্টেম নিরাপদ ডেলিভারি নিশ্চিত করে।</p>
                </div>
            </div>
            
            <!-- Step 5 -->
            <div class="step-card-wrapper">
                <div class="step-dot"></div>
                <div class="step-card">
                    <span class="step-num">ধাপ ০৫</span>
                    <h3 class="step-title">📈 স্মার্ট বিশ্লেষণ</h3>
                    <p class="step-desc">সিস্টেম বাজার মূল্য ও লাভ-ক্ষতির বিশ্লেষণ দেয়।</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- User Role Section -->
<section class="role-section">
    <div class="container">
        <h2 class="section-title">ব্যবহারকারী ভূমিকা</h2>
        <p class="section-subtitle">যার যার প্রয়োজনীয় সুবিধা</p>
        
        <div class="row g-4">
            <!-- Farmer -->
            <div class="col-12 col-md-6 col-lg-3">
                <div class="role-card">
                    <div class="role-icon">👨‍🌾</div>
                    <h3 class="role-title">Farmer</h3>
                    <ul class="role-list">
                        <li><i class="bi bi-check-circle-fill"></i> Crop selling</li>
                        <li><i class="bi bi-check-circle-fill"></i> Loan access</li>
                        <li><i class="bi bi-check-circle-fill"></i> Analytics</li>
                    </ul>
                </div>
            </div>
            
            <!-- Buyer -->
            <div class="col-12 col-md-6 col-lg-3">
                <div class="role-card">
                    <div class="role-icon">🛒</div>
                    <h3 class="role-title">Buyer</h3>
                    <ul class="role-list">
                        <li><i class="bi bi-check-circle-fill"></i> Buy crops</li>
                        <li><i class="bi bi-check-circle-fill"></i> Order tracking</li>
                        <li><i class="bi bi-check-circle-fill"></i> Direct communication</li>
                    </ul>
                </div>
            </div>
            
            <!-- Agent -->
            <div class="col-12 col-md-6 col-lg-3">
                <div class="role-card">
                    <div class="role-icon">🧑‍💼</div>
                    <h3 class="role-title">Agent</h3>
                    <ul class="role-list">
                        <li><i class="bi bi-check-circle-fill"></i> Delivery support</li>
                        <li><i class="bi bi-check-circle-fill"></i> Market verification</li>
                    </ul>
                </div>
            </div>
            
            <!-- Admin -->
            <div class="col-12 col-md-6 col-lg-3">
                <div class="role-card">
                    <div class="role-icon">👑</div>
                    <h3 class="role-title">Admin</h3>
                    <ul class="role-list">
                        <li><i class="bi bi-check-circle-fill"></i> System management</li>
                        <li><i class="bi bi-check-circle-fill"></i> Monitoring</li>
                        <li><i class="bi bi-check-circle-fill"></i> Price updates</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Smart Features Section -->
<section class="features-section">
    <div class="container">
        <h2 class="section-title">স্মার্ট ফিচারসমূহ</h2>
        <p class="section-subtitle">কৃষিকে আরও আধুনিক ও লাভজনক করার প্রযুক্তি</p>
        
        <div class="row justify-content-center">
            <div class="col-12 col-md-8 col-lg-6">
                
                <div class="feature-chip">
                    <div class="fc-icon"><i class="bi bi-cpu"></i></div>
                    <div class="fc-text">AI Crop Suggestions</div>
                </div>
                
                <div class="feature-chip">
                    <div class="fc-icon"><i class="bi bi-graph-up-arrow"></i></div>
                    <div class="fc-text">Live Market Prices</div>
                </div>
                
                <div class="feature-chip">
                    <div class="fc-icon"><i class="bi bi-cash-coin"></i></div>
                    <div class="fc-text">Smart Loan System</div>
                </div>
                
                <div class="feature-chip">
                    <div class="fc-icon"><i class="bi bi-cloud-sun"></i></div>
                    <div class="fc-text">Weather Alerts</div>
                </div>
                
                <div class="feature-chip">
                    <div class="fc-icon"><i class="bi bi-bar-chart-steps"></i></div>
                    <div class="fc-text">Demand Analysis</div>
                </div>
                
            </div>
        </div>
    </div>
</section>

<!-- CTA Section -->
<section class="cta-section">
    <div class="container">
        <h2 class="cta-title">আজই AgroFin এর সাথে যুক্ত হোন</h2>
        <p style="font-size: 18px; margin-bottom: 40px; color: rgba(255,255,255,0.9);">স্মার্ট কৃষির নতুন দিগন্তে আপনাকে স্বাগতম</p>
        <div class="cta-buttons">
            <a href="/AgroFin/auth/register" class="btn-hiw-primary"><i class="bi bi-person-plus"></i> Register</a>
            <a href="/AgroFin/marketplace" class="btn-hiw-outline"><i class="bi bi-shop"></i> Explore Marketplace</a>
        </div>
    </div>
</section>

<script>
    // Reveal elements on scroll
    document.addEventListener("DOMContentLoaded", function() {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = 1;
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, { threshold: 0.1 });

        document.querySelectorAll('.step-card-wrapper, .role-card, .feature-chip').forEach(el => {
            el.style.opacity = 0;
            el.style.transform = 'translateY(20px)';
            el.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out';
            observer.observe(el);
        });
    });
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
