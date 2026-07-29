<?php include __DIR__ . '/../../includes/header.php'; ?>
<?php include __DIR__ . '/../../includes/navbar.php'; ?>

<!-- Bootstrap 5 Grid System and Components -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Bootstrap Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<style>
    :root {
        --cp-primary: #1a5c28;
        --cp-secondary: #2e7d32;
        --cp-light: #f0f7ee;
        --cp-dark: #0d3b1a;
        --cp-accent: #4caf50;
        --cp-text: #333;
        --cp-muted: #6c757d;
        --cp-bg: #f0f7ee;
    }

    body {
        background-color: var(--cp-bg);
        font-family: var(--font-bn), sans-serif;
        color: var(--cp-text);
        overflow-x: hidden;
    }

    /* Hero Section */
    .cp-hero {
        background: linear-gradient(135deg, rgba(13,59,26,0.9), rgba(46,125,50,0.9)), url('https://images.unsplash.com/photo-1596524430615-b46475ddff6e?auto=format&fit=crop&w=1920&q=80') center/cover no-repeat;
        color: #fff;
        padding: 100px 24px;
        text-align: center;
        position: relative;
    }

    .cp-hero::after {
        content: '';
        position: absolute;
        bottom: -1px;
        left: 0;
        width: 100%;
        height: 50px;
        background: url('data:image/svg+xml;utf8,<svg viewBox="0 0 1440 100" xmlns="http://www.w3.org/2000/svg"><path fill="%23f9fbf9" d="M0,50 C320,100 420,0 720,50 C1020,100 1120,0 1440,50 L1440,100 L0,100 Z"/></svg>') no-repeat bottom center/cover;
    }

    .cp-hero h1 {
        font-size: clamp(36px, 5vw, 48px);
        font-weight: 800;
        margin-bottom: 16px;
        animation: fadeInDown 0.8s ease;
    }

    .cp-hero p {
        font-size: clamp(16px, 3vw, 20px);
        color: rgba(255,255,255,0.9);
        max-width: 600px;
        margin: 0 auto;
        animation: fadeInUp 0.8s ease 0.2s both;
    }

    /* Section Titles */
    .section-title {
        text-align: center;
        font-size: 32px;
        font-weight: 800;
        color: var(--cp-dark);
        margin-bottom: 12px;
    }
    .section-subtitle {
        text-align: center;
        color: var(--cp-muted);
        margin-bottom: 48px;
    }

    /* Info Cards */
    .info-card {
        background: #fff;
        border-radius: 16px;
        padding: 30px 20px;
        text-align: center;
        box-shadow: 0 10px 30px rgba(0,0,0,0.04);
        transition: all 0.3s ease;
        height: 100%;
        border-bottom: 4px solid transparent;
    }
    .info-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 15px 35px rgba(46,125,50,0.1);
        border-color: var(--cp-accent);
    }
    .info-icon {
        width: 64px;
        height: 64px;
        background: var(--cp-light);
        color: var(--cp-primary);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 28px;
        margin: 0 auto 20px;
        transition: transform 0.3s;
    }
    .info-card:hover .info-icon {
        transform: scale(1.1);
        background: var(--cp-primary);
        color: #fff;
    }
    .info-title {
        font-size: 18px;
        font-weight: 700;
        color: var(--cp-dark);
        margin-bottom: 8px;
    }
    .info-text {
        color: var(--cp-muted);
        margin: 0;
        font-size: 15px;
    }

    /* Contact Form */
    .contact-wrapper {
        background: #fff;
        border-radius: 24px;
        overflow: hidden;
        box-shadow: 0 20px 50px rgba(0,0,0,0.05);
    }
    .form-section {
        padding: 48px;
    }
    .form-control, .form-select {
        padding: 14px 20px;
        border-radius: 12px;
        border: 1.5px solid #e9ecef;
        background-color: #f8f9fa;
        font-size: 15px;
        transition: all 0.3s ease;
    }
    .form-control:focus, .form-select:focus {
        background-color: #fff;
        border-color: var(--cp-primary);
        box-shadow: 0 0 0 4px rgba(26, 92, 40, 0.1);
    }
    .btn-submit {
        background: var(--cp-primary);
        color: #fff;
        font-weight: 700;
        padding: 14px 32px;
        border-radius: 30px;
        border: none;
        width: 100%;
        transition: all 0.3s ease;
    }
    .btn-submit:hover {
        background: var(--cp-dark);
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(26,92,40,0.2);
    }

    /* Support Categories */
    .support-cat-card {
        background: #fff;
        border-radius: 16px;
        padding: 24px;
        display: flex;
        align-items: center;
        gap: 16px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.03);
        transition: all 0.3s;
        cursor: pointer;
        border: 1px solid #f1f1f1;
    }
    .support-cat-card:hover {
        background: var(--cp-light);
        border-color: var(--cp-accent);
        transform: translateX(5px);
    }
    .sc-icon {
        font-size: 32px;
        color: var(--cp-primary);
    }
    .sc-text {
        font-weight: 700;
        font-size: 18px;
        color: var(--cp-dark);
        margin: 0;
    }

    /* FAQ Section */
    .faq-section {
        padding: 80px 0;
    }
    .accordion-button {
        font-weight: 600;
        color: var(--cp-dark);
        padding: 20px 24px;
        border-radius: 12px !important;
        background: #fff;
        box-shadow: 0 2px 10px rgba(0,0,0,0.02);
    }
    .accordion-button:not(.collapsed) {
        background: var(--cp-light);
        color: var(--cp-primary);
        box-shadow: none;
    }
    .accordion-button:focus {
        box-shadow: none;
        border-color: rgba(0,0,0,.125);
    }
    .accordion-item {
        border: none;
        margin-bottom: 16px;
        background: transparent;
    }
    .accordion-body {
        background: #fff;
        border-radius: 0 0 12px 12px;
        color: var(--cp-muted);
        line-height: 1.6;
        padding: 20px 24px;
    }

    /* Social Section */
    .social-section {
        background: var(--cp-dark);
        color: #fff;
        padding: 60px 0;
        text-align: center;
    }
    .social-icons {
        display: flex;
        gap: 20px;
        justify-content: center;
        margin-top: 24px;
    }
    .social-btn {
        width: 50px;
        height: 50px;
        background: rgba(255,255,255,0.1);
        color: #fff;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        text-decoration: none;
        transition: all 0.3s;
    }
    .social-btn:hover {
        background: var(--cp-accent);
        transform: translateY(-5px);
        color: #fff;
    }

    @keyframes fadeInDown {
        from { opacity: 0; transform: translateY(-30px); }
        to { opacity: 1; transform: translateY(0); }
    }
    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(30px); }
        to { opacity: 1; transform: translateY(0); }
    }
</style>

<!-- Hero Section -->
<section class="cp-hero">
    <div class="container">
        <h1>📞 যোগাযোগ করুন</h1>
        <p>আমাদের সাথে যোগাযোগ করুন যেকোনো সহায়তা বা তথ্যের জন্য। AgroFin সাপোর্ট টিম সবসময় আপনার পাশে আছে।</p>
    </div>
</section>

<!-- Contact Info Section -->
<section class="container" style="margin-top: -40px; position: relative; z-index: 10;">
    <div class="row g-4 justify-content-center">
        <div class="col-12 col-md-6 col-lg-3">
            <div class="info-card">
                <div class="info-icon"><i class="bi bi-envelope-paper"></i></div>
                <h3 class="info-title">Email Support</h3>
                <p class="info-text">support@agrofin.com<br>info@agrofin.com</p>
            </div>
        </div>
        <div class="col-12 col-md-6 col-lg-3">
            <div class="info-card">
                <div class="info-icon"><i class="bi bi-telephone"></i></div>
                <h3 class="info-title">Phone Support</h3>
                <p class="info-text">+880 1XXXXXXXXX<br>+880 9XXXXXXXXX</p>
            </div>
        </div>
        <div class="col-12 col-md-6 col-lg-3">
            <div class="info-card">
                <div class="info-icon"><i class="bi bi-geo-alt"></i></div>
                <h3 class="info-title">Office Location</h3>
                <p class="info-text">AgroFin Tower, Banani<br>Dhaka, Bangladesh</p>
            </div>
        </div>
        <div class="col-12 col-md-6 col-lg-3">
            <div class="info-card">
                <div class="info-icon"><i class="bi bi-clock"></i></div>
                <h3 class="info-title">Support Time</h3>
                <p class="info-text">Saturday - Thursday<br>9:00 AM – 8:00 PM</p>
            </div>
        </div>
    </div>
</section>

<!-- Main Contact Form & Categories -->
<section class="container" style="padding: 80px 0;">
    <div class="contact-wrapper">
        <div class="row g-0">
            <!-- Form Area -->
            <div class="col-12 col-lg-7 form-section">
                <h2 style="font-weight:800; color:var(--cp-dark); margin-bottom: 8px;">বার্তা পাঠান</h2>
                <p style="color:var(--cp-muted); margin-bottom: 32px;">যেকোনো জিজ্ঞাসা বা মতামতের জন্য নিচের ফর্মটি পূরণ করুন</p>
                
                <form onsubmit="event.preventDefault(); alert('আপনার বার্তা সফলভাবে পাঠানো হয়েছে!');">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight:600; font-size:14px;">Full Name</label>
                            <input type="text" class="form-control" placeholder="আপনার সম্পূর্ণ নাম" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight:600; font-size:14px;">Email Address</label>
                            <input type="email" class="form-control" placeholder="আপনার ইমেইল ঠিকানা" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label" style="font-weight:600; font-size:14px;">Subject</label>
                            <select class="form-select" required>
                                <option value="" disabled selected>বিষয় নির্বাচন করুন...</option>
                                <option>মার্কেটপ্লেস সংক্রান্ত</option>
                                <option>লোন সহায়তা</option>
                                <option>ডেলিভারি সমস্যা</option>
                                <option>টেকনিক্যাল সাপোর্ট</option>
                                <option>অন্যান্য</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label" style="font-weight:600; font-size:14px;">Message</label>
                            <textarea class="form-control" rows="5" placeholder="আপনার বিস্তারিত বার্তা লিখুন..." required></textarea>
                        </div>
                        <div class="col-12 mt-4">
                            <button type="submit" class="btn-submit">
                                <i class="bi bi-send me-2"></i> Send Message
                            </button>
                        </div>
                    </div>
                </form>
            </div>
            
            <!-- Support Categories Area -->
            <div class="col-12 col-lg-5" style="background: #fafcfb; padding: 48px; border-left: 1px solid #eee;">
                <h3 style="font-weight:800; font-size:24px; color:var(--cp-dark); margin-bottom: 24px;">সাপোর্ট ক্যাটাগরি</h3>
                
                <div class="d-flex flex-column gap-3">
                    <div class="support-cat-card">
                        <div class="sc-icon">👨‍🌾</div>
                        <p class="sc-text">Farmer Support</p>
                    </div>
                    <div class="support-cat-card">
                        <div class="sc-icon">🛒</div>
                        <p class="sc-text">Buyer Support</p>
                    </div>
                    <div class="support-cat-card">
                        <div class="sc-icon">💰</div>
                        <p class="sc-text">Loan Assistance</p>
                    </div>
                    <div class="support-cat-card">
                        <div class="sc-icon">⚙️</div>
                        <p class="sc-text">Technical Support</p>
                    </div>
                    <div class="support-cat-card">
                        <div class="sc-icon">🚚</div>
                        <p class="sc-text">Delivery Support</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- FAQ Section -->
<section class="faq-section bg-white">
    <div class="container">
        <h2 class="section-title">সাধারণ জিজ্ঞাসা (FAQ)</h2>
        <p class="section-subtitle">আপনাদের কিছু সাধারণ প্রশ্নের উত্তর</p>
        
        <div class="row justify-content-center">
            <div class="col-12 col-lg-8">
                <div class="accordion" id="faqAccordion">
                    
                    <!-- FAQ 1 -->
                    <div class="accordion-item">
                        <h2 class="accordion-header">
                            <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-toggle="collapse" data-bs-target="#faq1">
                                How to register as a farmer or buyer?
                            </button>
                        </h2>
                        <div id="faq1" class="accordion-collapse collapse show" data-bs-parent="#faqAccordion">
                            <div class="accordion-body">
                                আপনি খুব সহজেই 'Register' পেজে গিয়ে আপনার মোবাইল নম্বর এবং জাতীয় পরিচয়পত্রের তথ্য দিয়ে কৃষক বা ক্রেতা হিসেবে রেজিস্ট্রেশন করতে পারবেন। রেজিস্ট্রেশন সম্পূর্ণ ফ্রিতে করা যায়।
                            </div>
                        </div>
                    </div>

                    <!-- FAQ 2 -->
                    <div class="accordion-item">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                                How to place orders in marketplace?
                            </button>
                        </h2>
                        <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                            <div class="accordion-body">
                                মার্কেটপ্লেস পেজে গিয়ে আপনার কাঙ্ক্ষিত ফসল খুঁজুন। ফসলের ডিটেইলস পেজ থেকে কৃষকের সাথে সরাসরি যোগাযোগ করে অথবা 'Order' বাটনে ক্লিক করে অর্ডার কনফার্ম করতে পারবেন।
                            </div>
                        </div>
                    </div>

                    <!-- FAQ 3 -->
                    <div class="accordion-item">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">
                                How does the smart loan system work?
                            </button>
                        </h2>
                        <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                            <div class="accordion-body">
                                আমাদের লোন সিস্টেমে আবেদন করার জন্য কৃষকের ড্যাশবোর্ড থেকে 'Micro-loan' সেকশনে যেতে হবে। আপনার পূর্ববর্তী কৃষি রেকর্ড এবং প্রোফাইলের ওপর ভিত্তি করে এআই সিস্টেম অটোমেটিক লোন অ্যাপ্রুভ করে।
                            </div>
                        </div>
                    </div>

                    <!-- FAQ 4 -->
                    <div class="accordion-item">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq4">
                                How to contact farmers directly?
                            </button>
                        </h2>
                        <div id="faq4" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                            <div class="accordion-body">
                                যেকোনো ফসলের লিস্টিং এ কৃষকের যোগাযোগের অপশন দেওয়া থাকে। আপনি সরাসরি মেসেজ অথবা কল করে কৃষকের সাথে দাম ও ডেলিভারি নিয়ে কথা বলতে পারবেন।
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</section>

<!-- Social Media Section -->
<section class="social-section">
    <div class="container">
        <h2 style="font-weight:800; margin-bottom: 8px;">আমাদের সোশ্যাল মিডিয়ায় যুক্ত থাকুন</h2>
        <p style="color: rgba(255,255,255,0.7);">নিয়মিত আপডেট এবং কৃষি টিপস পেতে আমাদের ফলো করুন</p>
        
        <div class="social-icons">
            <a href="#" class="social-btn" title="Facebook"><i class="bi bi-facebook"></i></a>
            <a href="#" class="social-btn" title="LinkedIn"><i class="bi bi-linkedin"></i></a>
            <a href="#" class="social-btn" title="YouTube"><i class="bi bi-youtube"></i></a>
            <a href="#" class="social-btn" title="Twitter"><i class="bi bi-twitter-x"></i></a>
        </div>
    </div>
</section>

<!-- Bootstrap JS for Accordion -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Reveal animation
    document.addEventListener("DOMContentLoaded", function() {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = 1;
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, { threshold: 0.1 });

        document.querySelectorAll('.info-card, .support-cat-card, .accordion-item').forEach(el => {
            el.style.opacity = 0;
            el.style.transform = 'translateY(20px)';
            el.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            observer.observe(el);
        });
    });
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
