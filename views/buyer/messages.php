<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<?php $role = strtolower($_SESSION['active_role'] ?? 'farmer'); ?>

<style>
.msg-layout { display: grid; grid-template-columns: 320px 1fr; gap: 0; min-height: 600px; border-radius: 16px; overflow: hidden; background: #fff; box-shadow: 0 4px 20px rgba(0,0,0,0.05); }
.msg-sidebar { border-right: 1px solid var(--gray-100); background: var(--gray-50); overflow-y: auto; max-height: 700px; }
.msg-conv-item { padding: 14px 16px; border-bottom: 1px solid var(--gray-100); cursor: pointer; text-decoration: none; color: inherit; display: flex; gap: 10px; align-items: center; transition: background 0.2s; }
.msg-conv-item:hover { background: #fff; }
.msg-conv-item.active { background: #fff; border-left: 3px solid var(--m1-primary); }
.msg-avatar { width: 40px; height: 40px; border-radius: 50%; background: var(--grad-m2); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; flex-shrink: 0; }
.msg-pane { display: flex; flex-direction: column; max-height: 700px; }
.msg-pane-header { padding: 14px 18px; border-bottom: 1px solid var(--gray-100); display: flex; align-items: center; gap: 10px; background: var(--gray-50); }
.msg-list { flex: 1; overflow-y: auto; padding: 18px; background: #fafafa; }
.msg-bubble { max-width: 70%; padding: 10px 14px; border-radius: 14px; margin-bottom: 10px; font-size: 14px; line-height: 1.5; }
.msg-bubble.me { background: var(--grad-m1); color: #fff; margin-left: auto; border-bottom-right-radius: 4px; }
.msg-bubble.them { background: #fff; color: var(--gray-800); border: 1px solid var(--gray-100); border-bottom-left-radius: 4px; }
.msg-time { font-size: 10px; opacity: 0.7; margin-top: 4px; display:block; }
.msg-form { padding: 14px 18px; border-top: 1px solid var(--gray-100); background: #fff; display: flex; gap: 8px; }
.msg-form input { flex: 1; padding: 10px 14px; border: 1.5px solid var(--gray-200); border-radius: 999px; font-size: 14px; outline: none; }
.msg-form input:focus { border-color: var(--m1-primary); }
.unread-dot { width: 9px; height: 9px; background: var(--danger); border-radius: 50%; display: inline-block; }
@media (max-width: 800px) { .msg-layout { grid-template-columns: 1fr; } .msg-sidebar { display: <?= $partner ? 'none' : 'block' ?>; } .msg-pane { display: <?= $partner ? 'flex' : 'none' ?>; } }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <h1>বার্তা 💬</h1>
            </div>
        </div>

        <?php if (empty($inbox) && !$partner): ?>
            <div class="dash-card">
                <div class="empty-state">
                    <i class="bi bi-chat-dots"></i>
                    <h4>কোনো কথোপকথন নেই</h4>
                    <p>অর্ডার পেজ থেকে অন্যপক্ষকে বার্তা পাঠান।</p>
                </div>
            </div>
        <?php else: ?>
        <div class="msg-layout">
            <div class="msg-sidebar">
                <?php foreach ($inbox as $c): ?>
                    <a href="<?= BASE_URL ?>/<?= $role ?>/messages/with/<?= (int)$c['partner_id'] ?>" class="msg-conv-item <?= $partner && $partner['user_id'] == $c['partner_id'] ? 'active' : '' ?>">
                        <div class="msg-avatar"><?= e(mb_substr($c['partner_name'], 0, 1, 'UTF-8')) ?></div>
                        <div style="flex:1; min-width:0;">
                            <div style="display:flex; justify-content:space-between; align-items:center;">
                                <strong style="font-size:14px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;"><?= e($c['partner_name']) ?></strong>
                                <?php if ($c['unread'] > 0): ?><span class="unread-dot"></span><?php endif; ?>
                            </div>
                            <div style="font-size:12px; color:var(--gray-500); white-space:nowrap; overflow:hidden; text-overflow:ellipsis;"><?= e(mb_substr($c['last_message'] ?? '', 0, 40, 'UTF-8')) ?></div>
                            <div style="font-size:10px; color:var(--gray-400);"><?= $c['last_at'] ? bn_date($c['last_at'], true) : '' ?></div>
                        </div>
                    </a>
                <?php endforeach; ?>
            </div>

            <div class="msg-pane">
                <?php if ($partner): ?>
                    <div class="msg-pane-header">
                        <a href="<?= BASE_URL ?>/<?= $role ?>/messages" style="font-size:18px; color:var(--gray-700); text-decoration:none;"><i class="bi bi-arrow-left"></i></a>
                        <div class="msg-avatar"><?= e(mb_substr($partner['full_name'], 0, 1, 'UTF-8')) ?></div>
                        <div>
                            <strong><?= e($partner['full_name']) ?></strong><br>
                            <span style="font-size:11px; color:var(--gray-500);"><?= e($partner['phone']) ?></span>
                        </div>
                    </div>
                    <div class="msg-list" id="msgList">
                        <?php
                        $me = $_SESSION['user_id'] ?? 0;
                        foreach ($conversation as $m):
                            $mine = (int)$m['sender_id'] === (int)$me;
                        ?>
                            <div class="msg-bubble <?= $mine ? 'me' : 'them' ?>">
                                <?= nl2br(e($m['message_text'])) ?>
                                <span class="msg-time"><?= bn_date($m['created_at'], true) ?></span>
                            </div>
                        <?php endforeach; ?>
                        <?php if (empty($conversation)): ?>
                            <div style="text-align:center; color:var(--gray-400); padding:40px;"><i class="bi bi-chat-dots" style="font-size:48px;"></i><br>কথোপকথন শুরু করুন</div>
                        <?php endif; ?>
                    </div>
                    <form method="POST" action="<?= BASE_URL ?>/<?= $role ?>/messages/send" class="msg-form">
                        <?= Csrf::field() ?>
                        <input type="hidden" name="receiver_id" value="<?= (int)$partner['user_id'] ?>">
                        <input type="text" name="message_text" placeholder="বার্তা লিখুন..." required maxlength="2000" autocomplete="off">
                        <button type="submit" class="nav-pill-btn primary"><i class="bi bi-send-fill"></i></button>
                    </form>
                <?php else: ?>
                    <div style="display:flex; align-items:center; justify-content:center; flex:1; color:var(--gray-400);">
                        <div style="text-align:center;">
                            <i class="bi bi-chat-square-dots" style="font-size:64px;"></i>
                            <p style="margin-top:14px;">কথোপকথন শুরু করতে বাম পাশ থেকে নির্বাচন করুন</p>
                        </div>
                    </div>
                <?php endif; ?>
            </div>
        </div>
        <?php endif; ?>
    </main>
</div>
</div>

<script>
var ml = document.getElementById('msgList');
if (ml) ml.scrollTop = ml.scrollHeight;
</script>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
