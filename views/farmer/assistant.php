<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<style>
.chat-shell { display: grid; grid-template-columns: 1fr 280px; gap: 18px; }
@media (max-width: 900px) { .chat-shell { grid-template-columns: 1fr; } }
.chat-container { background: #fff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,0.06); display: flex; flex-direction: column; min-height: 600px; max-height: 75vh; }
.chat-header { padding: 18px 22px; background: linear-gradient(135deg, var(--m1-primary), var(--m4-primary)); color: #fff; display: flex; align-items: center; gap: 14px; }
.chat-header h2 { margin: 0; font-size: 18px; }
.chat-header p { margin: 2px 0 0; font-size: 12px; opacity: 0.9; }
.chat-body { flex: 1; overflow-y: auto; padding: 22px; background: linear-gradient(180deg, #f9fafb, #fff); }
.chat-msg { display: flex; gap: 10px; margin-bottom: 18px; max-width: 85%; }
.chat-msg.you { margin-left: auto; flex-direction: row-reverse; }
.chat-avatar { width: 36px; height: 36px; border-radius: 50%; display:flex; align-items:center; justify-content:center; flex-shrink:0; font-size: 16px; }
.chat-avatar.bot { background: linear-gradient(135deg, var(--m1-primary), var(--m4-primary)); color: #fff; }
.chat-avatar.user { background: var(--gray-200); color: var(--gray-700); }
.chat-bubble { padding: 12px 16px; border-radius: 16px; font-size: 14px; line-height: 1.6; white-space: pre-wrap; word-wrap: break-word; }
.chat-msg.you .chat-bubble { background: var(--m1-primary); color: #fff; border-bottom-right-radius: 4px; }
.chat-msg.bot .chat-bubble { background: #fff; color: var(--gray-800); border: 1px solid var(--gray-100); border-bottom-left-radius: 4px; }
.chat-meta { font-size: 11px; color: var(--gray-400); margin-top: 4px; }
.chat-feedback { display:flex; gap:6px; margin-top: 8px; }
.chat-feedback button { background:none; border: 1px solid var(--gray-200); padding: 4px 10px; border-radius: 99px; font-size: 11px; cursor:pointer; }
.chat-feedback button:hover { background: var(--gray-50); }
.chat-input-row { padding: 16px 18px; border-top: 1px solid var(--gray-100); background: #fff; display: flex; gap: 8px; }
.chat-input { flex: 1; padding: 12px 16px; border: 1.5px solid var(--gray-200); border-radius: 999px; font-size: 14px; outline: none; }
.chat-input:focus { border-color: var(--m1-primary); }
.suggestions { display:flex; gap:6px; padding: 10px 18px 0; flex-wrap: wrap; }
.suggestion-chip { background: var(--gray-50); border: 1px solid var(--gray-200); padding: 6px 12px; border-radius: 999px; font-size: 12px; color: var(--gray-700); cursor: pointer; transition: all 0.2s; }
.suggestion-chip:hover { background: var(--m1-primary); color: #fff; border-color: var(--m1-primary); }
.intent-badge { display: inline-block; padding: 2px 10px; border-radius: 99px; font-size: 10px; background: var(--gray-100); color: var(--gray-600); margin-right: 6px; }
.ai-badge { display: inline-block; padding: 2px 10px; border-radius: 99px; font-size: 10px; background: linear-gradient(135deg, #7B1FA2, #2E7D32); color: #fff; margin-right: 6px; font-weight: 600; }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> স্মার্ট সহকারী</div>
                <h1>🤖 AgroFin স্মার্ট সহকারী</h1>
            </div>
        </div>

        <div class="chat-shell">
            <div class="chat-container">
                <div class="chat-header">
                    <div style="width:42px; height:42px; border-radius:50%; background:rgba(255,255,255,0.25); display:flex; align-items:center; justify-content:center; font-size:22px;">🤖</div>
                    <div>
                        <h2>AgroFin সহকারী</h2>
                        <p>আবহাওয়া, দাম, ফসল সুপারিশ, লোন—যা জানতে চান জিজ্ঞাসা করুন</p>
                    </div>
                </div>

                <div class="chat-body" id="chatBody">
                    <!-- Welcome message -->
                    <div class="chat-msg bot">
                        <div class="chat-avatar bot">🤖</div>
                        <div>
                            <div class="chat-bubble">সালামালাইকুম! 🌾 আমি AgroFin সহকারী। আমাকে বাংলায় বা ইংরেজিতে যেকোনো প্রশ্ন করতে পারেন:

🌧 আবহাওয়া সতর্কতা
💰 ফসলের বাজার দর
🌾 কোন ফসল চাষ করব?
💳 লোনের তথ্য
📦 অর্ডার সংক্রান্ত
🔐 অ্যাকাউন্ট সাহায্য

নিচে আপনার প্রশ্ন লিখুন বা পরামর্শ থেকে বেছে নিন।</div>
                        </div>
                    </div>

                    <?php
                    // Show history (newest first in DB, so reverse for chronological)
                    $shown = array_reverse(array_slice($history, 0, 20));
                    $skipQueryId = $latest['query_id'] ?? null;
                    foreach ($shown as $h):
                        if ($skipQueryId && $h['query_id'] === $skipQueryId) continue;
                    ?>
                        <div class="chat-msg you">
                            <div class="chat-avatar user"><i class="bi bi-person-fill"></i></div>
                            <div>
                                <div class="chat-bubble"><?= e($h['user_query']) ?></div>
                                <div class="chat-meta" style="text-align:right;"><?= bn_date($h['created_at'], true) ?></div>
                            </div>
                        </div>
                        <div class="chat-msg bot">
                            <div class="chat-avatar bot">🤖</div>
                            <div>
                                <div class="chat-bubble"><?= nl2br(e($h['assistant_response'])) ?></div>
                                <div class="chat-meta">
                                    <?php if ($h['was_helpful'] === '1'): ?>👍 সহায়ক<?php elseif ($h['was_helpful'] === '0'): ?>👎 সহায়ক নয়<?php endif; ?>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>

                    <?php if ($latest && !empty($latest['response'])): ?>
                        <div class="chat-msg bot" id="latestBot">
                            <div class="chat-avatar bot">🤖</div>
                            <div>
                                <div class="chat-bubble"><?= nl2br(e($latest['response'])) ?></div>
                                <div class="chat-meta">
                                    <?php if (!empty($latest['using_llm'])): ?><span class="ai-badge">🤖 AI-powered</span><?php endif; ?>
                                </div>
                                <?php if (!empty($latest['query_id'])): ?>
                                <form method="POST" style="margin: 0;">
                                    <?= Csrf::field() ?>
                                    <input type="hidden" name="feedback_id" value="<?= (int)$latest['query_id'] ?>">
                                    <div class="chat-feedback">
                                        <button type="submit" name="feedback_value" value="yes">👍 সহায়ক</button>
                                        <button type="submit" name="feedback_value" value="no">👎 সহায়ক নয়</button>
                                    </div>
                                </form>
                                <?php endif; ?>
                            </div>
                        </div>
                    <?php endif; ?>
                </div>

                <div class="suggestions">
                    <span class="suggestion-chip" onclick="document.getElementById('queryInput').value='আজকের আবহাওয়া কেমন?';">🌧 আবহাওয়া</span>
                    <span class="suggestion-chip" onclick="document.getElementById('queryInput').value='টমেটোর দাম কত?';">💰 দাম</span>
                    <span class="suggestion-chip" onclick="document.getElementById('queryInput').value='কোন ফসল লাভজনক?';">🌾 ফসল সুপারিশ</span>
                    <span class="suggestion-chip" onclick="document.getElementById('queryInput').value='আমার লোনের অবস্থা?';">💳 লোন</span>
                    <span class="suggestion-chip" onclick="document.getElementById('queryInput').value='আমার অর্ডার?';">📦 অর্ডার</span>
                </div>

                <form method="POST" class="chat-input-row">
                    <?= Csrf::field() ?>
                    <input type="text" name="query" id="queryInput" class="chat-input" placeholder="বাংলায় বা ইংরেজিতে আপনার প্রশ্ন লিখুন..." autocomplete="off" required maxlength="1000" autofocus>
                    <button type="submit" class="nav-pill-btn primary" style="padding:11px 22px;"><i class="bi bi-send-fill"></i> পাঠান</button>
                </form>
            </div>

            <div>
                <div class="dash-card" style="margin: 0; border-left: 4px solid var(--m4-primary);">
                    <h3 style="margin:0 0 12px; font-size:15px;"><i class="bi bi-lightbulb"></i> কীভাবে ব্যবহার করবেন</h3>
                    <ul style="margin:0; padding-left:20px; font-size:13px; line-height:1.8;">
                        <li>বাংলা বা ইংরেজিতে স্বাভাবিকভাবে লিখুন</li>
                        <li>উপরের সাজেশন থেকে বেছে নিন</li>
                        <li>একাধিক প্রশ্ন একসাথে করতে পারেন</li>
                        <li>উত্তর সহায়ক হলে 👍 দিন — সহকারী আরও ভালো হবে</li>
                    </ul>
                </div>

                <div class="dash-card" style="margin-top: 16px;">
                    <h3 style="margin:0 0 12px; font-size:15px;"><i class="bi bi-chat-quote"></i> উদাহরণ প্রশ্ন</h3>
                    <div style="font-size:13px; line-height:1.8; color:var(--gray-700);">
                        • "ময়মনসিংহে আজ ধানের দাম কত?"<br>
                        • "এই মাসে কোন সবজি চাষ করব?"<br>
                        • "আমার লোনের পরবর্তী কিস্তি কবে?"<br>
                        • "আবহাওয়া সতর্কতা আছে?"<br>
                        • "পাসওয়ার্ড পরিবর্তন করব কীভাবে?"
                    </div>
                </div>

                <div class="dash-card" style="margin-top: 16px; background: linear-gradient(135deg, #e3f2fd, #fff); border-left: 4px solid var(--info);">
                    <h3 style="margin:0 0 12px; font-size:15px;"><i class="bi bi-info-circle"></i> সম্পর্কে</h3>
                    <p style="font-size:12px; color:var(--gray-600); margin:0; line-height:1.6;">এই সহকারী আপনার এলাকার ডেটা ব্যবহার করে — আবহাওয়া সতর্কতা, বাজার দর, ফসল সুপারিশ — সবই আপনার জেলা অনুযায়ী।</p>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<script>
// Scroll chat to bottom on load
var cb = document.getElementById('chatBody');
if (cb) cb.scrollTop = cb.scrollHeight;
</script>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
