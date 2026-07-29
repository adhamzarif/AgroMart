<?php
/**
 * AdminController — Chunk 3 full admin module.
 */
class AdminController extends Controller {

    public function index() { $this->redirect('/admin/dashboard'); }

    // Coming-soon helper (still used as last resort)
    private function _comingSoon($featureName, $description) {
        $this->requireRole('Admin');
        $title = $featureName . ' | AgroFin';
        $this->view('admin/coming-soon', compact('title','featureName','description'));
    }

    // ─────────────────────────────────────────────────────────────────
    // CROP CATEGORIES MGMT (Chunk 4)
    // ─────────────────────────────────────────────────────────────────
    public function categories($action = null, $id = null) {
        $this->requireRole('Admin');
        $catModel = new CategoryModel();

        if ($action === 'add' || $action === 'edit') {
            $cat = $action === 'edit' ? $catModel->find((int)$id) : null;
            if ($action === 'edit' && !$cat) {
                Flash::set('danger', 'ক্যাটাগরি পাওয়া যায়নি।');
                $this->redirect('/admin/categories');
            }
            if ($_SERVER['REQUEST_METHOD'] === 'POST') {
                $this->requireCsrf();
                $data = [
                    'category_name'      => clean_str($_POST['category_name'] ?? '', 50),
                    'category_name_bn'   => clean_str($_POST['category_name_bn'] ?? '', 50),
                    'parent_category_id' => !empty($_POST['parent_category_id']) ? (int)$_POST['parent_category_id'] : null,
                    'description'        => clean_str($_POST['description'] ?? '', 500),
                    'icon'               => clean_str($_POST['icon'] ?? '', 50),
                ];
                $errors = [];
                if (mb_strlen($data['category_name']) < 2) $errors[] = 'ইংরেজি নাম দিন।';
                if (mb_strlen($data['category_name_bn']) < 2) $errors[] = 'বাংলা নাম দিন।';

                if (!$errors) {
                    $res = $cat ? $catModel->update($cat['category_id'], $data) : $catModel->create($data);
                    if (is_array($res) && !$res['ok']) {
                        Flash::set('danger', $res['error']);
                    } else {
                        (new AuditLogModel())->log($this->userId(), $cat ? 'category_update' : 'category_create',
                            'crop_categories', $cat['category_id'] ?? null, $cat, $data);
                        Flash::set('success', $cat ? 'ক্যাটাগরি আপডেট হয়েছে।' : 'নতুন ক্যাটাগরি যোগ হয়েছে।');
                        $this->redirect('/admin/categories');
                    }
                }
                foreach ($errors as $err) Flash::set('danger', $err);
            }
            $allForParents = $catModel->all();
            $title = $cat ? 'ক্যাটাগরি সম্পাদনা' : 'নতুন ক্যাটাগরি';
            $this->view('admin/categories/form', compact('title','cat','allForParents'));
            return;
        }
        if ($action === 'delete' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $res = $catModel->delete((int)$id);
            (new AuditLogModel())->log($this->userId(), 'category_delete', 'crop_categories', (int)$id);
            Flash::set($res['ok'] ? 'info' : 'danger', $res['ok'] ? 'ক্যাটাগরি মুছে ফেলা হয়েছে।' : $res['error']);
            $this->redirect('/admin/categories');
        }

        $categories = $catModel->all();
        $title = 'ক্যাটাগরি ব্যবস্থাপনা | AgroFin';
        $this->view('admin/categories/index', compact('title','categories'));
    }

    // ─────────────────────────────────────────────────────────────────
    // TRANSPORT PARTNERS (Chunk 4)
    // ─────────────────────────────────────────────────────────────────
    public function transport($action = null, $id = null) {
        $this->requireRole('Admin');
        $tm = new TransportModel();

        if ($action === 'add' || $action === 'edit') return $this->transportForm($action === 'edit' ? (int)$id : null);
        if ($action === 'toggle' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $p = $tm->findPartner((int)$id);
            $tm->setPartnerActive((int)$id, !$p['is_active']);
            Flash::set('info', 'পার্টনার ' . ($p['is_active'] ? 'নিষ্ক্রিয়' : 'সক্রিয়') . ' করা হয়েছে।');
            $this->redirect('/admin/transport');
        }
        if ($action === 'delete' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $tm->deletePartner((int)$id);
            (new AuditLogModel())->log($this->userId(), 'transport_delete', 'transport_partners', (int)$id);
            Flash::set('info', 'পার্টনার মুছে ফেলা হয়েছে।');
            $this->redirect('/admin/transport');
        }

        $partners = $tm->listPartners(false);
        $title = 'পরিবহন পার্টনার | AgroFin';
        $this->view('admin/transport/index', compact('title','partners'));
    }

    private function transportForm($partnerId) {
        $tm = new TransportModel();
        $partner = $partnerId ? $tm->findPartner($partnerId) : null;
        if ($partnerId && !$partner) {
            Flash::set('danger', 'পার্টনার পাওয়া যায়নি।');
            $this->redirect('/admin/transport');
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $data = [
                'partner_name'      => clean_str($_POST['partner_name'] ?? '', 100),
                'contact_person'    => clean_str($_POST['contact_person'] ?? '', 100),
                'contact_phone'     => clean_str($_POST['contact_phone'] ?? '', 15),
                'contact_email'     => trim($_POST['contact_email'] ?? '') ?: null,
                'service_districts' => array_map('intval', $_POST['service_districts'] ?? []),
                'vehicle_types'     => array_filter(array_map('trim', $_POST['vehicle_types'] ?? [])),
                'base_rate_per_km'  => (float)($_POST['base_rate_per_km'] ?? 0),
                'min_charge'        => (float)($_POST['min_charge'] ?? 0),
            ];
            $errors = [];
            if (mb_strlen($data['partner_name']) < 2) $errors[] = 'পার্টনারের নাম দিন।';
            if (!preg_match('/^01[3-9]\d{8}$/', $data['contact_phone'])) $errors[] = 'বৈধ ফোন নম্বর দিন।';
            if (empty($data['service_districts'])) $errors[] = 'অন্তত একটি সার্ভিস জেলা নির্বাচন করুন।';
            if (empty($data['vehicle_types'])) $errors[] = 'অন্তত একটি যানবাহন প্রকার নির্বাচন করুন।';
            if ($data['base_rate_per_km'] <= 0) $errors[] = 'কিলোমিটার প্রতি রেট দিন।';

            if (!$errors) {
                try {
                    if ($partner) {
                        $tm->updatePartner($partner['partner_id'], $data);
                        (new AuditLogModel())->log($this->userId(), 'transport_update', 'transport_partners', $partner['partner_id'], $partner, $data);
                        Flash::set('success', 'পার্টনার আপডেট হয়েছে।');
                    } else {
                        $newId = $tm->createPartner($data);
                        (new AuditLogModel())->log($this->userId(), 'transport_create', 'transport_partners', $newId, null, $data);
                        Flash::set('success', 'নতুন পার্টনার যোগ হয়েছে।');
                    }
                    $this->redirect('/admin/transport');
                } catch (Throwable $e) {
                    Flash::set('danger', 'সংরক্ষণ ব্যর্থ: ' . $e->getMessage());
                }
            }
            foreach ($errors as $err) Flash::set('danger', $err);
        }

        $districts = (new DistrictModel())->all();
        $title = $partner ? 'পার্টনার সম্পাদনা' : 'নতুন পরিবহন পার্টনার';
        $this->view('admin/transport/form', compact('title','partner','districts'));
    }

    // ─────────────────────────────────────────────────────────────────
    // ANNOUNCEMENTS / BROADCAST (Chunk 4)
    // ─────────────────────────────────────────────────────────────────
    public function announcements($action = null) {
        $this->requireRole('Admin');
        $am = new AnnouncementModel();

        if ($action === 'send' && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $title = clean_str($_POST['title'] ?? '', 200);
            $message = clean_str($_POST['message'] ?? '', 2000);
            $priority = $_POST['priority'] ?? 'medium';
            $roles = $_POST['roles'] ?? [];
            $districts = $_POST['districts'] ?? [];

            $errors = [];
            if (mb_strlen($title) < 3) $errors[] = 'শিরোনাম দিন।';
            if (mb_strlen($message) < 10) $errors[] = 'বার্তা লিখুন (কমপক্ষে ১০ অক্ষর)।';

            if (!$errors) {
                $res = $am->broadcast($this->userId(), $title, $message,
                    ['roles' => $roles, 'districts' => $districts], $priority);
                (new AuditLogModel())->log($this->userId(), 'announcement_broadcast', 'notifications', null, null,
                    ['title' => $title, 'recipients' => $res['recipient_count']]);
                Flash::set('success', '✓ ' . bn_num($res['recipient_count']) . ' জন ব্যবহারকারীর কাছে ঘোষণা পাঠানো হয়েছে।');
                $this->redirect('/admin/announcements');
            }
            foreach ($errors as $err) Flash::set('danger', $err);
        }

        $broadcasts = $am->listBroadcasts(30);
        $districts = (new DistrictModel())->all();
        $title = 'ঘোষণা ও ব্রডকাস্ট | AgroFin';
        $this->view('admin/announcements/index', compact('title','broadcasts','districts'));
    }

    // ─────────────────────────────────────────────────────────────────
    // CROPS MODERATION (Chunk 4)
    // ─────────────────────────────────────────────────────────────────
    public function crops($action = null, $id = null) {
        $this->requireRole('Admin');
        $pdo = (new Model())->pdo();

        if ($action === 'remove' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $reason = clean_str($_POST['reason'] ?? '', 255);
            $stmt = $pdo->prepare("SELECT * FROM crops WHERE crop_id = ?");
            $stmt->execute([(int)$id]);
            $crop = $stmt->fetch();
            if ($crop) {
                $pdo->prepare("UPDATE crops SET status = 'removed' WHERE crop_id = ?")->execute([(int)$id]);
                (new AuditLogModel())->log($this->userId(), 'crop_moderation_remove', 'crops', (int)$id,
                    ['status' => $crop['status']], ['status' => 'removed', 'reason' => $reason]);
                // Notify farmer
                $pdo->prepare(
                    "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url, related_id)
                     VALUES (?, 'system', 'high', 'ফসল লিস্ট মুছে ফেলা হয়েছে', ?, '/farmer/crops', ?)"
                )->execute([$crop['farmer_id'], $crop['crop_name'] . ' — কারণ: ' . ($reason ?: 'নীতিমালা লঙ্ঘন'), $id]);
                Flash::set('warning', 'ফসল লিস্ট থেকে সরানো হয়েছে।');
            }
            $this->redirect('/admin/crops');
        }

        $filter = $_GET['status'] ?? 'available';
        $q = trim($_GET['q'] ?? '');
        $where = ["1=1"];
        $params = [];
        if ($filter && $filter !== 'all') { $where[] = "c.status = ?"; $params[] = $filter; }
        if ($q !== '') { $where[] = "(c.crop_name LIKE ? OR u.full_name LIKE ?)"; array_push($params, "%$q%", "%$q%"); }

        $sql = "SELECT c.*, cc.category_name_bn, u.full_name AS farmer_name, u.phone AS farmer_phone, d.district_name
                FROM crops c
                JOIN crop_categories cc ON c.category_id = cc.category_id
                JOIN users u ON c.farmer_id = u.user_id
                LEFT JOIN districts d ON u.district_id = d.district_id
                WHERE " . implode(' AND ', $where) . "
                ORDER BY c.created_at DESC LIMIT 100";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $crops = $stmt->fetchAll();

        $title = 'ফসল মডারেশন | AgroFin';
        $this->view('admin/crops/index', compact('title','crops','filter','q'));
    }

    // ─────────────────────────────────────────────────────────────────
    // DASHBOARD
    // ─────────────────────────────────────────────────────────────────
    public function dashboard() {
        $this->requireRole('Admin');
        $stats = (new StatsModel())->forAdmin();
        $pdo = (new Model())->pdo();

        // Pending loans queue
        $pendingLoans = $pdo->query(
            "SELECT l.*, u.full_name AS farmer_name FROM loans l
             JOIN users u ON l.farmer_id = u.user_id
             WHERE l.status = 'pending'
             ORDER BY l.application_date ASC LIMIT 5"
        )->fetchAll();

        // Recent users
        $recentUsers = $pdo->query(
            "SELECT u.*, GROUP_CONCAT(r.role) AS roles, d.district_name
             FROM users u
             LEFT JOIN user_roles r ON u.user_id = r.user_id
             LEFT JOIN districts d ON u.district_id = d.district_id
             GROUP BY u.user_id
             ORDER BY u.created_at DESC LIMIT 6"
        )->fetchAll();

        // Active weather alerts
        $weatherAlerts = (new WeatherAlertModel())->listAll(true);
        $weatherAlerts = array_slice($weatherAlerts, 0, 3);

        // Open unassigned tickets
        $unassignedTickets = (new TicketModel())->listUnassigned();
        $unassignedTickets = array_slice($unassignedTickets, 0, 5);

        $title = 'অ্যাডমিন ড্যাশবোর্ড | AgroFin';
        $this->view('admin/dashboard', compact('title','stats','pendingLoans','recentUsers','weatherAlerts','unassignedTickets'));
    }

    // ─────────────────────────────────────────────────────────────────
    // USERS MANAGEMENT
    // ─────────────────────────────────────────────────────────────────
    public function users($action = null, $id = null) {
        $this->requireRole('Admin');
        $pdo = (new Model())->pdo();

        if ($action === 'detail' && $id) return $this->userDetail((int)$id);
        if ($action === 'verify' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') return $this->userToggle((int)$id, 'verify');
        if ($action === 'ban' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') return $this->userToggle((int)$id, 'ban');
        if ($action === 'unban' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') return $this->userToggle((int)$id, 'unban');

        $filters = [
            'q'      => trim($_GET['q'] ?? ''),
            'role'   => $_GET['role'] ?? null,
            'status' => $_GET['status'] ?? null,
        ];
        $page = max(1, (int)($_GET['page'] ?? 1));
        $perPage = 25;
        $offset = ($page - 1) * $perPage;

        $where = ['1=1'];
        $params = [];
        if (!empty($filters['q'])) {
            $where[] = "(u.full_name LIKE ? OR u.phone LIKE ? OR u.email LIKE ?)";
            $like = '%' . $filters['q'] . '%';
            array_push($params, $like, $like, $like);
        }
        if (!empty($filters['status']) && in_array($filters['status'], ['active','suspended','deleted'], true)) {
            $where[] = "u.account_status = ?";
            $params[] = $filters['status'];
        }
        if (!empty($filters['role']) && in_array($filters['role'], ['farmer','buyer','agent','admin'], true)) {
            $where[] = "EXISTS (SELECT 1 FROM user_roles WHERE user_id = u.user_id AND role = ?)";
            $params[] = $filters['role'];
        }

        $sql = "SELECT u.user_id, u.full_name, u.phone, u.email, u.account_status AS status, u.phone_verified, u.email_verified,
                       u.nid_verified, u.created_at, d.district_name,
                       (SELECT GROUP_CONCAT(role) FROM user_roles WHERE user_id = u.user_id) AS roles
                FROM users u
                LEFT JOIN districts d ON u.district_id = d.district_id
                WHERE " . implode(' AND ', $where) . "
                ORDER BY u.created_at DESC
                LIMIT $perPage OFFSET $offset";
        $st = $pdo->prepare($sql);
        $st->execute($params);
        $users = $st->fetchAll();

        $countSt = $pdo->prepare("SELECT COUNT(*) FROM users u WHERE " . implode(' AND ', $where));
        $countSt->execute($params);
        $total = (int)$countSt->fetchColumn();
        $totalPages = (int)ceil($total / $perPage);

        $title = 'ব্যবহারকারী ব্যবস্থাপনা | AgroFin';
        $this->view('admin/users/index', compact('title','users','filters','page','totalPages','total'));
    }

    private function userDetail($userId) {
        $user = (new UserModel())->find($userId);
        if (!$user) { Flash::set('danger', 'ব্যবহারকারী পাওয়া যায়নি।'); $this->redirect('/admin/users'); }
        // Detail view templates expect a "status" key (legacy alias for account_status)
        $user['status'] = $user['account_status'] ?? null;
        $pdo = (new Model())->pdo();
        $roles = $pdo->prepare("SELECT role FROM user_roles WHERE user_id = ?");
        $roles->execute([$userId]);
        $roles = array_column($roles->fetchAll(), 'role');

        // Activity counts
        $st = $pdo->prepare("SELECT
            (SELECT COUNT(*) FROM crops WHERE farmer_id = ?) AS crops_count,
            (SELECT COUNT(*) FROM orders WHERE farmer_id = ? OR buyer_id = ?) AS orders_count,
            (SELECT COUNT(*) FROM loans WHERE farmer_id = ?) AS loans_count,
            (SELECT COUNT(*) FROM expenses WHERE farmer_id = ?) AS expenses_count");
        $st->execute([$userId, $userId, $userId, $userId, $userId]);
        $activity = $st->fetch();

        $title = e($user['full_name']) . ' | ব্যবহারকারী বিস্তারিত';
        $this->view('admin/users/detail', compact('title','user','roles','activity'));
    }

    private function userToggle($userId, $kind) {
        $this->requireCsrf();
        $userModel = new UserModel();
        $user = $userModel->find($userId);
        if (!$user) { Flash::set('danger', 'ব্যবহারকারী পাওয়া যায়নি।'); $this->redirect('/admin/users'); }

        $pdo = (new Model())->pdo();
        $audit = new AuditLogModel();
        if ($kind === 'verify') {
            $pdo->prepare("UPDATE users SET phone_verified=1, email_verified=1, nid_verified=1 WHERE user_id = ?")->execute([$userId]);
            $audit->log($this->userId(), 'user_verify', 'users', $userId, null, ['verified' => true]);
            Flash::set('success', 'ব্যবহারকারী যাচাইকৃত হিসেবে চিহ্নিত হয়েছেন।');
        } elseif ($kind === 'ban') {
            $pdo->prepare("UPDATE users SET account_status='suspended' WHERE user_id = ?")->execute([$userId]);
            $audit->log($this->userId(), 'user_ban', 'users', $userId, ['status' => $user['account_status']], ['status' => 'suspended']);
            Flash::set('warning', 'ব্যবহারকারী সাময়িকভাবে স্থগিত করা হয়েছে।');
        } elseif ($kind === 'unban') {
            $pdo->prepare("UPDATE users SET account_status='active' WHERE user_id = ?")->execute([$userId]);
            $audit->log($this->userId(), 'user_unban', 'users', $userId, ['status' => $user['account_status']], ['status' => 'active']);
            Flash::set('success', 'ব্যবহারকারী পুনঃসক্রিয় করা হয়েছে।');
        }
        $this->redirect('/admin/users/detail/' . $userId);
    }

    // ─────────────────────────────────────────────────────────────────
    // LOAN APPROVAL
    // ─────────────────────────────────────────────────────────────────
    public function loans($action = null, $id = null) {
        $this->requireRole('Admin');
        $pdo = (new Model())->pdo();

        if ($action === 'detail' && $id) return $this->loanDetailAdmin((int)$id);
        if ($action === 'approve' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') return $this->loanDecide((int)$id, 'approve');
        if ($action === 'reject' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') return $this->loanDecide((int)$id, 'reject');

        $statusFilter = $_GET['status'] ?? 'pending';
        $sql = "SELECT l.*, u.full_name AS farmer_name, u.phone AS farmer_phone, d.district_name
                FROM loans l
                JOIN users u ON l.farmer_id = u.user_id
                LEFT JOIN districts d ON u.district_id = d.district_id";
        $params = [];
        if ($statusFilter && $statusFilter !== 'all') {
            $sql .= " WHERE l.status = ?";
            $params[] = $statusFilter;
        }
        $sql .= " ORDER BY l.application_date DESC LIMIT 100";
        $st = $pdo->prepare($sql);
        $st->execute($params);
        $loans = $st->fetchAll();

        $title = 'লোন ব্যবস্থাপনা | AgroFin';
        $this->view('admin/loans/index', compact('title','loans','statusFilter'));
    }

    private function loanDetailAdmin($loanId) {
        $loan = (new LoanModel())->find($loanId);
        if (!$loan) { Flash::set('danger', 'লোন পাওয়া যায়নি।'); $this->redirect('/admin/loans'); }
        $pdo = (new Model())->pdo();
        $st = $pdo->prepare("SELECT * FROM users WHERE user_id = ?");
        $st->execute([$loan['farmer_id']]);
        $farmer = $st->fetch();
        $repayments = (new LoanModel())->repaymentsForLoan($loanId);
        $cs = (new LoanModel())->creditScore($loan['farmer_id']);

        $title = 'লোন আবেদন বিস্তারিত | AgroFin';
        $this->view('admin/loans/detail', compact('title','loan','farmer','repayments','cs'));
    }

    private function loanDecide($loanId, $decision) {
        $this->requireCsrf();
        $loanModel = new LoanModel();
        $loan = $loanModel->find($loanId);
        if (!$loan || $loan['status'] !== 'pending') {
            Flash::set('danger', 'এই লোন এখন প্রক্রিয়াকরণ করা যাবে না।');
            $this->redirect('/admin/loans');
        }
        $pdo = (new Model())->pdo();
        $audit = new AuditLogModel();
        $adminId = $this->userId();

        if ($decision === 'approve') {
            $pdo->prepare(
                "UPDATE loans SET status='approved', approval_date = NOW(), approved_by = ?,
                                  disbursement_date = NOW(), status='disbursed',
                                  next_payment_date = DATE_ADD(NOW(), INTERVAL 1 MONTH)
                 WHERE loan_id = ?"
            )->execute([$adminId, $loanId]);
            $pdo->prepare("UPDATE loans SET status='active' WHERE loan_id = ?")->execute([$loanId]);

            $audit->log($adminId, 'loan_approve', 'loans', $loanId, ['status' => 'pending'], ['status' => 'active']);
            $pdo->prepare(
                "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url, related_id)
                 VALUES (?, 'loan', 'high', '✓ লোন অনুমোদিত', ?, '/farmer/loans', ?)"
            )->execute([$loan['farmer_id'], '৳' . bn_num(number_format($loan['loan_amount'])) . ' লোন অনুমোদিত হয়েছে।', $loanId]);
            Flash::set('success', '✓ লোন অনুমোদিত হয়েছে।');
        } else {
            $reason = clean_str($_POST['reason'] ?? '', 500);
            $pdo->prepare(
                "UPDATE loans SET status='rejected', rejection_reason = ?, approved_by = ? WHERE loan_id = ?"
            )->execute([$reason ?: 'Not specified', $adminId, $loanId]);
            $audit->log($adminId, 'loan_reject', 'loans', $loanId, ['status' => 'pending'], ['status' => 'rejected', 'reason' => $reason]);
            $pdo->prepare(
                "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url, related_id)
                 VALUES (?, 'loan', 'high', 'লোন বাতিল', ?, '/farmer/loans', ?)"
            )->execute([$loan['farmer_id'], 'আপনার লোন বাতিল হয়েছে। কারণ: ' . ($reason ?: '—'), $loanId]);
            Flash::set('warning', 'লোন বাতিল করা হয়েছে।');
        }
        $this->redirect('/admin/loans/detail/' . $loanId);
    }

    // ─────────────────────────────────────────────────────────────────
    // MARKET PRICES
    // ─────────────────────────────────────────────────────────────────
    public function prices($action = null, $id = null) {
        $this->requireRole('Admin');
        $priceModel = new PriceModel();

        if ($action === 'add' || $action === 'edit') return $this->priceForm($action === 'edit' ? (int)$id : null);
        if ($action === 'delete' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $priceModel->delete((int)$id);
            (new AuditLogModel())->log($this->userId(), 'price_delete', 'market_prices', (int)$id);
            Flash::set('info', 'মূল্য মুছে ফেলা হয়েছে।');
            $this->redirect('/admin/prices');
        }

        $filters = [
            'district_id' => $_GET['district_id'] ?? null,
            'crop_name'   => trim($_GET['crop_name'] ?? ''),
        ];
        $prices = $priceModel->latest($filters, 100);
        $districts = (new DistrictModel())->all();

        $title = 'মার্কেট প্রাইস ম্যানেজমেন্ট | AgroFin';
        $this->view('admin/prices/index', compact('title','prices','districts','filters'));
    }

    private function priceForm($priceId) {
        $priceModel = new PriceModel();
        $price = $priceId ? $priceModel->find($priceId) : null;

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $data = [
                'crop_name'       => clean_str($_POST['crop_name'] ?? '', 100),
                'district_id'     => (int)($_POST['district_id'] ?? 0),
                'wholesale_price' => (float)($_POST['wholesale_price'] ?? 0),
                'retail_price'    => (float)($_POST['retail_price'] ?? 0),
                'unit'            => $_POST['unit'] ?? 'kg',
                'price_date'      => $_POST['price_date'] ?? date('Y-m-d'),
                'source'          => clean_str($_POST['source'] ?? 'DAM', 100),
                'updated_by'      => $this->userId(),
            ];
            $errors = [];
            if (mb_strlen($data['crop_name']) < 2) $errors[] = 'ফসলের নাম দিন।';
            if ($data['district_id'] <= 0) $errors[] = 'জেলা নির্বাচন করুন।';
            if ($data['wholesale_price'] <= 0) $errors[] = 'পাইকারি মূল্য দিন।';
            if ($data['retail_price'] <= 0) $errors[] = 'খুচরা মূল্য দিন।';

            if (!$errors) {
                $newId = $priceModel->upsert($data);
                (new AuditLogModel())->log($this->userId(), $price ? 'price_update' : 'price_add',
                    'market_prices', $newId, $price, $data);
                Flash::set('success', $price ? 'মূল্য আপডেট হয়েছে।' : 'নতুন মূল্য যোগ হয়েছে।');
                $this->redirect('/admin/prices');
            }
            foreach ($errors as $err) Flash::set('danger', $err);
        }

        $districts = (new DistrictModel())->all();
        $title = $price ? 'মূল্য সম্পাদনা' : 'নতুন মূল্য যোগ করুন';
        $this->view('admin/prices/form', compact('title','price','districts'));
    }

    // ─────────────────────────────────────────────────────────────────
    // WEATHER ALERTS
    // ─────────────────────────────────────────────────────────────────
    public function weather($action = null, $id = null) {
        $this->requireRole('Admin');
        $alertModel = new WeatherAlertModel();

        if ($action === 'add') return $this->weatherForm();
        if ($action === 'toggle' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $current = $alertModel->find((int)$id);
            $alertModel->setActive((int)$id, !$current['is_active']);
            Flash::set('info', 'সতর্কতা ' . ($current['is_active'] ? 'নিষ্ক্রিয়' : 'সক্রিয়') . ' করা হয়েছে।');
            $this->redirect('/admin/weather');
        }
        if ($action === 'delete' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $alertModel->delete((int)$id);
            Flash::set('info', 'সতর্কতা মুছে ফেলা হয়েছে।');
            $this->redirect('/admin/weather');
        }

        $alerts = $alertModel->listAll();
        $title = 'আবহাওয়া সতর্কতা ব্যবস্থাপনা | AgroFin';
        $this->view('admin/weather/index', compact('title','alerts'));
    }

    private function weatherForm() {
        $alertModel = new WeatherAlertModel();

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $data = [
                'alert_type'         => $_POST['alert_type'] ?? 'storm',
                'severity'           => $_POST['severity'] ?? 'medium',
                'affected_districts' => array_map('intval', $_POST['affected_districts'] ?? []),
                'alert_title'        => clean_str($_POST['alert_title'] ?? '', 200),
                'alert_message'      => clean_str($_POST['alert_message'] ?? '', 2000),
                'recommendations'    => clean_str($_POST['recommendations'] ?? '', 2000),
                'affected_crops'     => array_filter(array_map('trim', explode(',', $_POST['affected_crops'] ?? ''))),
                'start_time'         => $_POST['start_time'] ?? date('Y-m-d H:i:s'),
                'end_time'           => $_POST['end_time'] ?? null,
                'issued_by'          => clean_str($_POST['issued_by'] ?? 'BMD', 100),
                'created_by'         => $this->userId(),
            ];
            $errors = [];
            if (mb_strlen($data['alert_title']) < 3) $errors[] = 'সতর্কতার শিরোনাম দিন।';
            if (mb_strlen($data['alert_message']) < 10) $errors[] = 'বার্তা লিখুন।';
            if (empty($data['affected_districts'])) $errors[] = 'অন্তত একটি জেলা নির্বাচন করুন।';
            $validTypes = ['flood','cyclone','drought','heavy_rain','heatwave','cold_wave','storm'];
            if (!in_array($data['alert_type'], $validTypes, true)) $errors[] = 'অবৈধ সতর্কতার ধরন।';

            if (!$errors) {
                $id = $alertModel->create($data);
                (new AuditLogModel())->log($this->userId(), 'weather_alert_create', 'weather_alerts', $id, null, $data);
                Flash::set('success', '✓ সতর্কতা প্রকাশিত এবং সংশ্লিষ্ট জেলার কৃষকদের জানানো হয়েছে।');
                $this->redirect('/admin/weather');
            }
            foreach ($errors as $err) Flash::set('danger', $err);
        }

        $districts = (new DistrictModel())->all();
        $title = 'নতুন আবহাওয়া সতর্কতা';
        $this->view('admin/weather/form', compact('title','districts'));
    }

    // ─────────────────────────────────────────────────────────────────
    // AUDIT LOG
    // ─────────────────────────────────────────────────────────────────
    public function audit() {
        $this->requireRole('Admin');
        $audit = new AuditLogModel();

        $filters = [
            'action_type' => $_GET['action_type'] ?? null,
            'date_from'   => $_GET['date_from'] ?? null,
            'date_to'     => $_GET['date_to'] ?? null,
        ];
        $page = max(1, (int)($_GET['page'] ?? 1));
        $perPage = 50;
        $offset = ($page - 1) * $perPage;
        $logs = $audit->recent($filters, $perPage, $offset);
        $total = $audit->countRecent($filters);
        $totalPages = (int)ceil($total / $perPage);

        $title = 'অডিট লগ | AgroFin';
        $this->view('admin/audit-log', compact('title','logs','filters','page','totalPages','total'));
    }

    // ─────────────────────────────────────────────────────────────────
    // REPORTS / ANALYTICS
    // ─────────────────────────────────────────────────────────────────
    public function reports() {
        $this->requireRole('Admin');
        $pdo = (new Model())->pdo();

        // Date range
        $from = $_GET['from'] ?? date('Y-m-d', strtotime('-30 days'));
        $to   = $_GET['to']   ?? date('Y-m-d');

        // User growth: counts of users registered in range, by role
        $st = $pdo->prepare(
            "SELECT r.role, COUNT(DISTINCT u.user_id) AS cnt
             FROM users u JOIN user_roles r ON u.user_id = r.user_id
             WHERE u.created_at BETWEEN ? AND ?
             GROUP BY r.role"
        );
        $st->execute([$from, $to . ' 23:59:59']);
        $userGrowth = $st->fetchAll();

        // GMV: total order value
        $st = $pdo->prepare(
            "SELECT
                COUNT(*) AS order_count,
                IFNULL(SUM(total_amount),0) AS gmv,
                SUM(CASE WHEN order_status='delivered' THEN 1 ELSE 0 END) AS delivered_count,
                IFNULL(SUM(CASE WHEN order_status='delivered' THEN total_amount ELSE 0 END),0) AS delivered_gmv,
                SUM(CASE WHEN order_status='cancelled' THEN 1 ELSE 0 END) AS cancelled_count
             FROM orders WHERE order_date BETWEEN ? AND ?"
        );
        $st->execute([$from, $to . ' 23:59:59']);
        $orderStats = $st->fetch();

        // Top categories
        $st = $pdo->prepare(
            "SELECT cc.category_name_bn, COUNT(o.order_id) AS order_count, SUM(o.total_amount) AS gmv
             FROM orders o
             JOIN crops c ON o.crop_id = c.crop_id
             JOIN crop_categories cc ON c.category_id = cc.category_id
             WHERE o.order_date BETWEEN ? AND ? AND o.order_status='delivered'
             GROUP BY cc.category_id
             ORDER BY gmv DESC LIMIT 10"
        );
        $st->execute([$from, $to . ' 23:59:59']);
        $topCategories = $st->fetchAll();

        // Loan stats
        $st = $pdo->prepare(
            "SELECT
                COUNT(*) AS total_loans,
                IFNULL(SUM(loan_amount),0) AS total_disbursed,
                IFNULL(SUM(amount_paid),0) AS total_repaid,
                SUM(CASE WHEN status IN ('active','disbursed') THEN 1 ELSE 0 END) AS active_count,
                SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) AS completed_count,
                SUM(CASE WHEN status='defaulted' THEN 1 ELSE 0 END) AS defaulted_count
             FROM loans WHERE application_date BETWEEN ? AND ?"
        );
        $st->execute([$from, $to . ' 23:59:59']);
        $loanStats = $st->fetch();

        // Top performing farmers
        $st = $pdo->prepare(
            "SELECT u.user_id, u.full_name, d.district_name,
                    COUNT(o.order_id) AS orders, SUM(o.total_amount) AS revenue,
                    IFNULL(AVG(fr.overall_rating),0) AS rating
             FROM users u
             JOIN orders o ON o.farmer_id = u.user_id
             LEFT JOIN districts d ON u.district_id = d.district_id
             LEFT JOIN farmer_ratings fr ON fr.farmer_id = u.user_id
             WHERE o.order_status='delivered' AND o.delivered_at BETWEEN ? AND ?
             GROUP BY u.user_id
             ORDER BY revenue DESC LIMIT 5"
        );
        $st->execute([$from, $to . ' 23:59:59']);
        $topFarmers = $st->fetchAll();

        $title = 'রিপোর্ট ও অ্যানালিটিক্স | AgroFin';
        $this->view('admin/reports', compact('title','from','to','userGrowth','orderStats','topCategories','loanStats','topFarmers'));
    }
}
