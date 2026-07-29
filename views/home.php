<?php include __DIR__ . '/../includes/header.php'; ?>
<?php include __DIR__ . '/../includes/navbar.php'; ?>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap-grid.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<style>
    :root {
        --glass-bg: rgba(255, 255, 255, 0.86);
        --glass-border: rgba(255, 255, 255, 0.42);
        --glass-shadow: 0 10px 30px rgba(46, 125, 50, 0.06);
    }

    .home-page {
        background: #f0f7ee;
        min-height: calc(100vh - 72px);
        font-family: var(--font-bn);
        overflow-x: hidden;
        padding-bottom: 90px;
    }

    .home-hero {
        background: linear-gradient(135deg, #0d3b1a 0%, #1a5c28 52%, #2e7d32 100%);
        color: #fff;
        text-align: center;
        padding: 68px 24px 112px;
        position: relative;
        overflow: hidden;
    }

    .home-hero::before {
        content: "";
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: radial-gradient(circle, rgba(255,255,255,0.08) 0%, transparent 60%);
        transform: rotate(30deg);
    }

    .home-hero::after {
        content: "";
        position: absolute;
        bottom: -2px;
        left: 0;
        width: 100%;
        height: 60px;
        background: url('data:image/svg+xml;utf8,<svg viewBox="0 0 1440 100" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg"><path fill="%23f0f7ee" d="M0,100 C320,0 420,100 720,50 C1020,0 1120,100 1440,50 L1440,100 L0,100 Z"/></svg>') center/cover no-repeat;
    }

    .home-hero-content {
        position: relative;
        z-index: 1;
        max-width: 840px;
        margin: 0 auto;
    }

    .hero-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(255,255,255,0.15);
        border: 1px solid rgba(255,255,255,0.3);
        border-radius: 30px;
        padding: 7px 16px;
        font-size: 14px;
        font-weight: 600;
        margin-bottom: 18px;
        backdrop-filter: blur(10px);
        animation: fadeInDown 0.8s ease;
    }

    .home-hero h1 {
        color: #fff;
        font-family: var(--font-bn);
        font-size: clamp(34px, 4.6vw, 54px);
        font-weight: 800;
        line-height: 1.25;
        margin-bottom: 14px;
        animation: fadeInUp 0.8s ease 0.15s both;
    }

    .home-hero h1 span {
        color: #8ee89b;
    }

    .home-hero p {
        max-width: 720px;
        margin: 0 auto 24px;
        color: rgba(255,255,255,0.9);
        font-size: 17px;
        line-height: 1.68;
        animation: fadeInUp 0.8s ease 0.25s both;
    }

    .hero-actions {
        display: flex;
        justify-content: center;
        flex-wrap: wrap;
        gap: 14px;
        animation: fadeInUp 0.8s ease 0.35s both;
    }

    .hero-actions .btn {
        border-radius: 30px;
        padding: 13px 28px;
    }

    .btn-white {
        background: #fff;
        color: #1a5c28;
        box-shadow: 0 12px 28px rgba(0,0,0,0.18);
    }

    .btn-white:hover {
        color: #1a5c28;
        background: #f3fff1;
        transform: translateY(-2px);
    }

    .btn-hero-outline {
        color: #fff;
        background: rgba(255,255,255,0.1);
        border: 1px solid rgba(255,255,255,0.48);
    }

    .btn-hero-outline:hover {
        color: #fff;
        background: rgba(255,255,255,0.18);
        transform: translateY(-2px);
    }

    .overview-panel {
        max-width: 980px;
        margin: -62px auto 64px;
        padding: 0 20px;
        position: relative;
        z-index: 10;
    }

    .overview-card {
        background: var(--glass-bg);
        border: 1px solid var(--glass-border);
        border-radius: 20px;
        box-shadow: 0 15px 35px rgba(0,0,0,0.08);
        backdrop-filter: blur(20px);
        padding: 18px 22px;
    }

    .overview-item {
        display: flex;
        align-items: center;
        gap: 14px;
        padding: 8px 10px;
    }

    .overview-icon {
        width: 44px;
        height: 44px;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        flex-shrink: 0;
    }

    .overview-value {
        color: #0d3b1a;
        font-family: var(--font-mono);
        font-size: 22px;
        font-weight: 800;
        line-height: 1.1;
        margin-bottom: 4px;
    }

    .overview-label {
        color: #6b7280;
        font-size: 14px;
        font-weight: 600;
    }

    .section-block {
        padding: 0 0 82px;
    }

    .section-header {
        text-align: center;
        max-width: 720px;
        margin: 0 auto 48px;
    }

    .section-kicker {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        color: #2e7d32;
        font-size: 14px;
        font-weight: 700;
        margin-bottom: 12px;
    }

    .section-title {
        color: #0d3b1a;
        font-family: var(--font-bn);
        font-size: clamp(30px, 4vw, 42px);
        font-weight: 800;
        line-height: 1.3;
        margin-bottom: 12px;
    }

    .section-sub {
        color: #6b7280;
        font-size: 16px;
        line-height: 1.75;
        margin: 0;
    }

    .home-card {
        height: 100%;
        background: var(--glass-bg);
        border: 1px solid var(--glass-border);
        border-radius: 20px;
        box-shadow: var(--glass-shadow);
        backdrop-filter: blur(20px);
        padding: 30px;
        transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }

    .home-card:hover {
        transform: translateY(-6px);
        box-shadow: 0 18px 42px rgba(46, 125, 50, 0.12);
        border-color: #4caf50;
    }

    .home-card-icon {
        width: 62px;
        height: 62px;
        border-radius: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 28px;
        margin-bottom: 22px;
        transition: transform 0.3s ease;
    }

    .home-card:hover .home-card-icon {
        transform: rotate(8deg) scale(1.06);
    }

    .home-card h3 {
        color: #1f2937;
        font-family: var(--font-bn);
        font-size: 21px;
        font-weight: 800;
        line-height: 1.4;
        margin-bottom: 12px;
    }

    .home-card p {
        color: #6b7280;
        font-size: 15px;
        line-height: 1.7;
        margin-bottom: 22px;
    }

    .card-link {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        color: #2e7d32;
        font-weight: 800;
        font-size: 15px;
    }

    .reviews-section {
        background: linear-gradient(135deg, #f0f7ee 0%, #e8f5e9 50%, #f5f9f4 100%);
        color: #1f2937;
        padding: 82px 0;
        margin-bottom: 0;
    }

    .reviews-section .section-title,
    .reviews-section .section-sub {
        color: #0d3b1a;
    }

    .reviews-section .section-sub {
        color: #6b7280;
        opacity: 1;
    }

    .review-stage {
        max-width: 900px;
        margin: 0 auto;
        position: relative;
        height: 320px;
    }

    .review-carousel-container {
        position: relative;
        width: 100%;
        height: 100%;
        perspective: 1000px;
    }

    .review-card {
        position: absolute;
        width: 100%;
        height: 100%;
        display: grid;
        grid-template-columns: auto 1fr;
        gap: 24px;
        align-items: flex-start;
        background: var(--glass-bg);
        border: 1px solid var(--glass-border);
        border-radius: 20px;
        padding: 40px;
        box-shadow: var(--glass-shadow);
        backdrop-filter: blur(20px);
        transition: all 0.7s cubic-bezier(0.34, 1.56, 0.64, 1);
        opacity: 0;
        transform: translateX(100px) rotateY(10deg);
        z-index: 0;
        pointer-events: none;
    }

    .review-card.active {
        opacity: 1;
        transform: translateX(0) rotateY(0deg);
        z-index: 10;
        pointer-events: auto;
    }

    .review-card.prev {
        opacity: 0;
        transform: translateX(-100px) rotateY(-10deg);
        z-index: 5;
    }

    .review-avatar {
        width: 70px;
        height: 70px;
        border-radius: 18px;
        background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
        color: #1b5e20;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 32px;
        font-weight: 800;
        flex-shrink: 0;
        box-shadow: 0 8px 16px rgba(26, 92, 40, 0.15);
    }

    .review-stars {
        color: #f59e0b;
        font-size: 14px;
        margin-bottom: 12px;
        letter-spacing: 2px;
    }

    .review-text {
        color: #374151;
        font-size: 16px;
        font-weight: 600;
        line-height: 1.8;
        margin: 0 0 16px;
        font-style: italic;
    }

    .review-name {
        color: #0d3b1a;
        font-weight: 800;
        font-size: 16px;
        margin-bottom: 4px;
    }

    .review-meta {
        color: #6b7280;
        font-size: 13px;
    }

    /* Carousel Navigation */
    .review-nav {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 12px;
        margin-top: 40px;
    }

    .review-dot {
        width: 12px;
        height: 12px;
        border-radius: 50%;
        background: rgba(13, 59, 26, 0.2);
        border: 2px solid transparent;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .review-dot.active {
        background: #1a5c28;
        transform: scale(1.3);
        box-shadow: 0 0 0 4px rgba(26, 92, 40, 0.2);
    }

    .review-dot:hover {
        background: rgba(26, 92, 40, 0.5);
    }

    .review-arrow {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: #fff;
        border: 2px solid #1a5c28;
        color: #1a5c28;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.3s ease;
        font-size: 16px;
    }

    .review-arrow:hover {
        background: #1a5c28;
        color: #fff;
        transform: scale(1.1);
    }

    .review-prev { margin-right: auto; }
    .review-next { margin-left: auto; }

    @keyframes fadeInDown {
        from { opacity: 0; transform: translateY(-30px); }
        to { opacity: 1; transform: translateY(0); }
    }

    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(30px); }
        to { opacity: 1; transform: translateY(0); }
    }

    @media (max-width: 768px) {
        .home-hero {
            padding: 62px 20px 102px;
        }

        .overview-panel {
            margin-bottom: 58px;
        }

        .overview-card,
        .home-card {
            border-radius: 16px;
        }

        .review-stage {
            height: 380px;
        }

        .review-card {
            grid-template-columns: 1fr;
            text-align: center;
            justify-items: center;
            min-height: auto;
            padding: 24px 22px;
        }
    }
</style>

<div class="home-page">
    <section class="home-hero">
        <div class="home-hero-content">
            <div class="hero-badge">
                <span style="width:8px; height:8px; background:#8ee89b; border-radius:50%; box-shadow:0 0 10px #8ee89b;"></span>
                বাংলাদেশের স্মার্ট কৃষি প্ল্যাটফর্ম
            </div>
            <h1>কৃষকের ফসল, বাজারদর ও <span>অর্থায়ন</span> এক জায়গায়</h1>
            <p>AgroFin কৃষক, ক্রেতা এবং এজেন্টদের জন্য সহজ, স্বচ্ছ ও ডেটা-চালিত কৃষি মার্কেটপ্লেস। সরাসরি বিক্রি, লাইভ মূল্য, নিরাপদ অর্ডার এবং স্মার্ট লোন সহায়তা একই প্ল্যাটফর্মে।</p>
            <div class="hero-actions">
                <a href="/AgroFin/auth/register" class="btn btn-white">শুরু করুন <i class="bi bi-arrow-right"></i></a>
                <a href="/AgroFin/how-it-works" class="btn btn-hero-outline"><i class="bi bi-play-circle"></i> কিভাবে কাজ করে</a>
            </div>
        </div>
    </section>

    <div class="overview-panel">
        <div class="overview-card">
            <div class="row g-3">
                <div class="col-md-4">
                    <div class="overview-item">
                        <div class="overview-icon" style="background:#e8f5e9; color:#2e7d32;"><i class="bi bi-people"></i></div>
                        <div>
                            <div class="overview-value">10k+</div>
                            <div class="overview-label">নিবন্ধিত কৃষক</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="overview-item">
                        <div class="overview-icon" style="background:#fff3e0; color:#f57c00;"><i class="bi bi-graph-up-arrow"></i></div>
                        <div>
                            <div class="overview-value">32+</div>
                            <div class="overview-label">ফসলের লাইভ মূল্য</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="overview-item">
                        <div class="overview-icon" style="background:#e3f2fd; color:#1976d2;"><i class="bi bi-shield-check"></i></div>
                        <div>
                            <div class="overview-value">৳50M+</div>
                            <div class="overview-label">নিরাপদ লেনদেন</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <section class="section-block">
        <div class="container">
            <div class="section-header">
                <div class="section-kicker"><i class="bi bi-grid-1x2"></i> প্ল্যাটফর্ম সুবিধা</div>
                <h2 class="section-title">কৃষির প্রতিটি ধাপে দরকারি টুল</h2>
                <p class="section-sub">মার্কেটপ্লেস, বাজার বিশ্লেষণ, লোন এবং মাঠ পর্যায়ের সহায়তাকে একসাথে এনে AgroFin কৃষকের সিদ্ধান্তকে সহজ করে।</p>
            </div>

            <div class="row g-4">
                <div class="col-md-6 col-lg-4">
                    <div class="home-card">
                        <div class="home-card-icon" style="background:#e8f5e9; color:#2e7d32;"><i class="bi bi-shop"></i></div>
                        <h3>সরাসরি মার্কেটপ্লেস</h3>
                        <p>কৃষক নিজের ফসল তালিকাভুক্ত করতে পারে, আর ক্রেতা সরাসরি উৎস থেকে অর্ডার করতে পারে।</p>
                        <a href="/AgroFin/marketplace" class="card-link">মার্কেট দেখুন <i class="bi bi-arrow-right"></i></a>
                    </div>
                </div>

                <div class="col-md-6 col-lg-4">
                    <div class="home-card">
                        <div class="home-card-icon" style="background:#fff3e0; color:#f57c00;"><i class="bi bi-graph-up-arrow"></i></div>
                        <h3>লাইভ মূল্য ও পূর্বাভাস</h3>
                        <p>বর্তমান বাজারদর, ট্রেন্ড এবং সম্ভাব্য দামের তথ্য দেখে বিক্রির সময় ঠিক করা সহজ হয়।</p>
                        <a href="/AgroFin/liveprice" class="card-link" style="color:#f57c00;">দাম দেখুন <i class="bi bi-arrow-right"></i></a>
                    </div>
                </div>

                <div class="col-md-6 col-lg-4">
                    <div class="home-card">
                        <div class="home-card-icon" style="background:#e3f2fd; color:#1976d2;"><i class="bi bi-cash-stack"></i></div>
                        <h3>মাইক্রো-লোন সহায়তা</h3>
                        <p>চাষাবাদের খরচ, বীজ, সার ও পরিবহনের জন্য প্রয়োজনভিত্তিক অর্থায়ন সহায়তা।</p>
                        <a href="/AgroFin/features" class="card-link" style="color:#1976d2;">ফিচার দেখুন <i class="bi bi-arrow-right"></i></a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="reviews-section">
        <div class="container">
            <div class="section-header">
                <div class="section-kicker" style="color:#8ee89b;"><i class="bi bi-chat-heart"></i> কৃষকের অভিজ্ঞতা</div>
                <h2 class="section-title">AgroFin ব্যবহার করে কৃষকেরা যা বলছেন</h2>
                <p class="section-sub">মাঠের বাস্তব কাজ, সরাসরি বিক্রি এবং বাজারদর দেখে সিদ্ধান্ত নেওয়ার অভিজ্ঞতা।</p>
            </div>

            <div class="review-stage">
                <div class="review-carousel-container">
                    <article class="review-card active">
                    <div class="review-avatar">ক</div>
                    <div>
                        <div class="review-stars"><i class="bi bi-star-fill"></i> <i class="bi bi-star-fill"></i> <i class="bi bi-star-fill"></i> <i class="bi bi-star-fill"></i> <i class="bi bi-star-fill"></i></div>
                        <p class="review-text">“আগে পাইকারের দামের ওপর নির্ভর করতে হতো। এখন বাজারদর দেখে নিজের ধানের দাম ঠিক করতে পারি।”</p>
                        <div class="review-name">করিম মিয়া</div>
                        <div class="review-meta">ধান চাষি, ময়মনসিংহ</div>
                    </div>
                </article>

                <article class="review-card">
                    <div class="review-avatar">ফ</div>
                    <div>
                        <div class="review-stars"><i class="bi bi-star-fill"></i> <i class="bi bi-star-fill"></i> <i class="bi bi-star-fill"></i> <i class="bi bi-star-fill"></i> <i class="bi bi-star-half"></i></div>
                        <p class="review-text">“টমেটো বিক্রির সময় ক্রেতার সাথে সরাসরি কথা বলা যায়। অর্ডার আর পেমেন্টের হিসাবও পরিষ্কার থাকে।”</p>
                        <div class="review-name">ফাতেমা বেগম</div>
                        <div class="review-meta">সবজি চাষি, কুমিল্লা</div>
                    </div>
                </article>

                <article class="review-card">
                    <div class="review-avatar">জ</div>
                    <div>
                        <div class="review-stars"><i class="bi bi-star-fill"></i> <i class="bi bi-star-fill"></i> <i class="bi bi-star-fill"></i> <i class="bi bi-star-fill"></i> <i class="bi bi-star-fill"></i></div>
                        <p class="review-text">“ফসল তোলার আগে দাম ওঠানামা বুঝতে পারি। এতে কখন বিক্রি করব সেই সিদ্ধান্ত নেওয়া সহজ হয়েছে।”</p>
                        <div class="review-name">জালাল উদ্দিন</div>
                        <div class="review-meta">আলু চাষি, ঢাকা</div>
                    </div>
                </article>
                </div>
            </div>

            <!-- Navigation -->
            <div class="review-nav">
                <button class="review-arrow review-prev" onclick="reviewCarousel.prev()"><i class="bi bi-chevron-left"></i></button>
                <div class="review-dot active" onclick="reviewCarousel.goTo(0)"></div>
                <div class="review-dot" onclick="reviewCarousel.goTo(1)"></div>
                <div class="review-dot" onclick="reviewCarousel.goTo(2)"></div>
                <button class="review-arrow review-next" onclick="reviewCarousel.next()"><i class="bi bi-chevron-right"></i></button>
            </div>
        </div>
    </section>
</div>

<script>
    // ─── Review Carousel ───
    const reviewCarousel = {
        currentIndex: 0,
        cards: [],
        dots: [],
        autoplayInterval: null,

        init() {
            this.cards = document.querySelectorAll('.review-carousel-container .review-card');
            this.dots = document.querySelectorAll('.review-dot');
            this.startAutoplay();
        },

        goTo(index) {
            if (index < 0 || index >= this.cards.length) return;

            // Remove active class from all cards and dots
            this.cards.forEach(card => card.classList.remove('active', 'prev'));
            this.dots.forEach(dot => dot.classList.remove('active'));

            // Add prev class to current card before switching
            if (this.currentIndex !== index) {
                this.cards[this.currentIndex].classList.add('prev');
            }

            // Update index and set active
            this.currentIndex = index;
            this.cards[this.currentIndex].classList.add('active');
            this.dots[this.currentIndex].classList.add('active');

            // Reset autoplay
            this.resetAutoplay();
        },

        next() {
            this.goTo((this.currentIndex + 1) % this.cards.length);
        },

        prev() {
            this.goTo((this.currentIndex - 1 + this.cards.length) % this.cards.length);
        },

        startAutoplay() {
            this.autoplayInterval = setInterval(() => this.next(), 5000);
        },

        resetAutoplay() {
            clearInterval(this.autoplayInterval);
            this.startAutoplay();
        }
    };

    document.addEventListener('DOMContentLoaded', () => reviewCarousel.init());
</script>

<?php include __DIR__ . '/../includes/footer.php'; ?>
