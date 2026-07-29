<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb">
                    <a href="<?= BASE_URL ?>/">হোম</a>
                    <i class="bi bi-chevron-right" style="font-size:10px"></i>
                    <a href="<?= BASE_URL ?>/farmer/dashboard">কৃষক ড্যাশবোর্ড</a>
                    <i class="bi bi-chevron-right" style="font-size:10px"></i>
                    আমার ওয়ালেট
                </div>
                <h1><i class="bi bi-wallet2"></i> আমার ওয়ালেট</h1>
            </div>
            <div>
                <a href="<?= BASE_URL ?>/farmer/wallet/withdraw" class="nav-pill-btn primary">
                    <i class="bi bi-arrow-up-circle"></i> উত্তোলন করুন
                </a>
            </div>
        </div>

        <?php /* Flash messages auto-render in header.php */ ?>

        <!-- ─── Hero balance card ─── -->
        <div class="wallet-hero">
            <div class="wh-left">
                <div class="wh-label">বর্তমান ব্যালেন্স</div>
                <div class="wh-balance"><?= bdt($user['wallet_balance'] ?? 0, 2) ?></div>
                <!-- Subtitle removed as requested -->
            </div>
            <div class="wh-right">
                <i class="bi bi-wallet2"></i>
            </div>
        </div>

        <!-- ─── Quick stats ─── -->
        <div class="stat-grid" style="margin-top:18px;">
            <div class="stat-tile tile-green">
                <div class="st-label">এই মাসের বিক্রয়</div>
                <div class="st-value"><?= bdt($summary['this_month_sales'], 0) ?></div>
                <div class="st-foot"><i class="bi bi-graph-up"></i> বর্তমান মাস</div>
                <div class="st-icon"><i class="bi bi-arrow-up-circle-fill"></i></div>
            </div>
            <div class="stat-tile tile-blue">
                <div class="st-label">সর্বমোট আয়</div>
                <div class="st-value"><?= bdt($summary['total_sales'], 0) ?></div>
                <div class="st-foot"><i class="bi bi-cash"></i> সকল বিক্রয় থেকে</div>
                <div class="st-icon"><i class="bi bi-piggy-bank-fill"></i></div>
            </div>
            <div class="stat-tile tile-orange">
                <div class="st-label">মোট উত্তোলন</div>
                <div class="st-value"><?= bdt($summary['total_withdrawn'], 0) ?></div>
                <div class="st-foot"><i class="bi bi-arrow-down"></i> অপেক্ষমাণ + সম্পন্ন</div>
                <div class="st-icon"><i class="bi bi-arrow-up-circle-fill"></i></div>
            </div>
            <div class="stat-tile tile-teal">
                <div class="st-label">মোট লেনদেন</div>
                <div class="st-value"><?= bn_num($summary['total_count']) ?></div>
                <div class="st-foot"><i class="bi bi-list-ul"></i> সকল কার্যকলাপ</div>
                <div class="st-icon"><i class="bi bi-clock-history"></i></div>
            </div>
        </div>

        <!-- ─── Transaction history table ─── -->
        <div class="content-card" style="margin-top:18px;">
            <div class="card-head">
                <h3><i class="bi bi-clock-history"></i> লেনদেনের ইতিহাস</h3>
                <div class="card-sub">সাম্প্রতিক ১০০টি লেনদেন</div>
            </div>

            <?php if (empty($transactions)): ?>
                <div class="empty-state" style="padding:40px;text-align:center;color:var(--gray-500);">
                    <i class="bi bi-inbox" style="font-size:48px;opacity:0.4;"></i>
                    <p style="margin-top:12px;">এখনো কোনো লেনদেন নেই।</p>
                    <p style="font-size:13px;color:var(--gray-400);">যখন কেউ আপনার ফসল কিনবে অথবা আপনি লোন পাবেন, এখানে দেখাবে।</p>
                </div>
            <?php else: ?>
                <div class="table-wrap">
                <table class="table-clean">
                    <thead>
                        <tr>
                            <th>তারিখ</th>
                            <th>ধরন</th>
                            <th>বিবরণ</th>
                            <th>রেফারেন্স</th>
                            <th>স্ট্যাটাস</th>
                            <th style="text-align:right;">পরিমাণ</th>
                            <th style="text-align:right;">ব্যালেন্স</th>
                        </tr>
                    </thead>
                    <tbody>
                    <?php foreach ($transactions as $t):
                        $dir   = TransactionModel::direction($t['transaction_type']);
                        $sign  = $dir === 'in' ? '+' : '-';
                        $color = $dir === 'in' ? '#2E7D32' : '#C62828';
                        $statusColor = [
                            'completed' => '#2E7D32',
                            'pending'   => '#F57C00',
                            'failed'    => '#C62828',
                            'cancelled' => '#757575',
                        ][$t['transaction_status']] ?? '#757575';
                    ?>
                        <tr>
                            <td>
                                <div style="font-size:13px;"><?= date('d M Y', strtotime($t['created_at'])) ?></div>
                                <div style="font-size:11px;color:var(--gray-500);"><?= date('h:i A', strtotime($t['created_at'])) ?></div>
                            </td>
                            <td>
                                <span class="badge-pill" style="background:<?= $color ?>20; color:<?= $color ?>; padding:3px 10px; border-radius:12px; font-size:12px; font-weight:600;">
                                    <i class="bi bi-arrow-<?= $dir === 'in' ? 'down-left' : 'up-right' ?>"></i>
                                    <?= e(TransactionModel::typeLabel($t['transaction_type'])) ?>
                                </span>
                            </td>
                            <td><?= e($t['description'] ?? '—') ?></td>
                            <td><code style="font-size:11px;color:var(--gray-600);"><?= e($t['reference_number'] ?? '—') ?></code></td>
                            <td>
                                <span style="background:<?= $statusColor ?>20; color:<?= $statusColor ?>; padding:3px 10px; border-radius:12px; font-size:11px; font-weight:600;">
                                    <?= e(TransactionModel::statusLabel($t['transaction_status'])) ?>
                                </span>
                            </td>
                            <td style="text-align:right; font-weight:700; color:<?= $color ?>; font-family:monospace;">
                                <?= $sign ?> <?= bdt($t['amount'], 2) ?>
                            </td>
                            <td style="text-align:right; font-family:monospace; color:var(--gray-700);">
                                <?= $t['balance_after'] !== null ? bdt($t['balance_after'], 2) : '—' ?>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
                </div>
            <?php endif; ?>
        </div>

    </main>
</div>
</div>

<style>
    .wallet-hero {
        background: linear-gradient(135deg, #1B5E20 0%, #2E7D32 60%, #43A047 100%);
        color: white;
        border-radius: 16px;
        padding: 28px 32px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-shadow: 0 8px 24px rgba(46,125,50,0.3);
        position: relative;
        overflow: hidden;
    }
    .wallet-hero::before {
        content: "";
        position: absolute;
        top: -50%; right: -10%;
        width: 320px; height: 320px;
        background: radial-gradient(circle, rgba(255,255,255,0.12) 0%, transparent 60%);
        pointer-events: none;
    }
    .wh-label { font-size: 13px; opacity: 0.85; text-transform: uppercase; letter-spacing: 2px; margin-bottom: 8px; }
    .wh-balance { font-size: 48px; font-weight: 800; letter-spacing: -1px; }
    .wh-sub { margin-top: 12px; font-size: 13px; opacity: 0.85; }
    .wh-sub i { margin-right: 6px; }
    .wh-right { font-size: 96px; opacity: 0.15; }

    .content-card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); }
    .card-head { display: flex; justify-content: space-between; align-items: center; padding-bottom: 14px; border-bottom: 1px solid #ECEFF1; margin-bottom: 14px; }
    .card-head h3 { margin: 0; font-size: 17px; color: #263238; }
    .card-head .card-sub { font-size: 12px; color: #90A4AE; }

    .table-wrap { overflow-x: auto; }
    .table-clean { width: 100%; border-collapse: collapse; }
    .table-clean th { text-align: left; padding: 10px 12px; background: #F5F7F9; font-size: 12px; font-weight: 600; color: #455A64; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 2px solid #ECEFF1; }
    .table-clean td { padding: 12px; border-bottom: 1px solid #ECEFF1; font-size: 13px; color: #263238; vertical-align: middle; }
    .table-clean tbody tr:hover { background: #F8FAF6; }
</style>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
