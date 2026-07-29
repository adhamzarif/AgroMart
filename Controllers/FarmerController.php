<?php
/**
 * FarmerController — full Chunk-2 farmer module.
 * Each "section" method dispatches sub-actions via $action parameter:
 *  /farmer/crops          → list
 *  /farmer/crops/add      → create form / POST handler
 *  /farmer/crops/edit/5   → edit form / POST handler
 *  /farmer/crops/delete/5 → soft-delete (POST)
 */
class FarmerController extends Controller {

    public function index() { $this->redirect('/farmer/dashboard'); }

    // ─────────────────────────────────────────────────────────────────
    // DASHBOARD
    // ─────────────────────────────────────────────────────────────────
    public function dashboard() {
        $this->requireRole('Farmer');
        $userId = $this->userId();
        $stats = (new StatsModel())->forFarmer($userId);

        $pdo = (new Model())->pdo();

        $st = $pdo->prepare(
            "SELECT o.*, c.crop_name, u.full_name AS buyer_name
             FROM orders o
             JOIN crops c ON o.crop_id = c.crop_id
             JOIN users u ON o.buyer_id = u.user_id
             WHERE o.farmer_id = ? ORDER BY o.order_date DESC LIMIT 5"
        );
        $st->execute([$userId]);
        $recentOrders = $st->fetchAll();

        $st = $pdo->prepare(
            "SELECT c.*, cc.category_name_bn FROM crops c
             JOIN crop_categories cc ON c.category_id = cc.category_id
             WHERE c.farmer_id = ? AND c.status = 'available'
             ORDER BY c.created_at DESC LIMIT 4"
        );
        $st->execute([$userId]);
        $activeCrops = $st->fetchAll();

        $districtId = (int)($_SESSION['district_id'] ?? 0);
        $weatherAlert = null;
        try {
            $stmt = $pdo->prepare(
                "SELECT * FROM weather_alerts
                 WHERE is_active = 1 AND JSON_CONTAINS(affected_districts, ?)
                 ORDER BY created_at DESC LIMIT 1"
            );
            $stmt->execute([(string)(int)$districtId]);
            $weatherAlert = $stmt->fetch() ?: null;
        } catch (Throwable $e) {
            // Fallback for older MariaDB without JSON_CONTAINS — use a tight LIKE match
            try {
                $needle = (int)$districtId;
                $stmt = $pdo->prepare(
                    "SELECT * FROM weather_alerts
                     WHERE is_active = 1
                       AND (affected_districts LIKE ? OR affected_districts LIKE ?
                         OR affected_districts LIKE ? OR affected_districts LIKE ?)
                     ORDER BY created_at DESC LIMIT 1"
                );
                $stmt->execute([
                    '[' . $needle . ']',
                    '[' . $needle . ',%',
                    '%,' . $needle . ',%',
                    '%,' . $needle . ']',
                ]);
                $weatherAlert = $stmt->fetch() ?: null;
            } catch (Throwable $e2) { $weatherAlert = null; }
        }

        $st = $pdo->prepare(
            "SELECT * FROM crop_recommendations
             WHERE (farmer_id = ? OR farmer_id IS NULL) AND district_id = ?
             ORDER BY recommendation_score DESC LIMIT 3"
        );
        $st->execute([$userId, $districtId]);
        $recommendations = $st->fetchAll();

        $title = 'কৃষক ড্যাশবোর্ড | AgroFin';
        $this->view('farmer/dashboard', compact('title','stats','recentOrders','activeCrops','weatherAlert','recommendations'));
    }

    // ─────────────────────────────────────────────────────────────────
    // CROPS CRUD
    // ─────────────────────────────────────────────────────────────────
    public function crops($action = null, $id = null) {
        $this->requireRole('Farmer');
        if ($action === 'add')    return $this->cropsForm(null);
        if ($action === 'edit')   return $this->cropsForm((int)$id);
        if ($action === 'delete') return $this->cropsDelete((int)$id);

        // List
        $userId = $this->userId();
        $statusFilter = $_GET['status'] ?? null;
        $cropModel = new CropModel();
        $crops = $cropModel->listByFarmer($userId, $statusFilter);
        $title = 'আমার ফসল | AgroFin';
        $this->view('farmer/crops/index', compact('title','crops','statusFilter'));
    }

    private function cropsForm($cropId) {
        $userId = $this->userId();
        $cropModel = new CropModel();
        $pdo = (new Model())->pdo();

        $crop = null;
        if ($cropId) {
            $crop = $cropModel->find($cropId);
            if (!$crop || (int)$crop['farmer_id'] !== $userId) {
                Flash::set('danger', 'ফসলটি পাওয়া যায়নি অথবা অনুমতি নেই।');
                $this->redirect('/farmer/crops');
            }
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $errors = [];
            $data = [
                'farmer_id'       => $userId,
                'category_id'     => (int)($_POST['category_id'] ?? 0),
                'crop_name'       => clean_str($_POST['crop_name'] ?? '', 100),
                'crop_variety'    => clean_str($_POST['crop_variety'] ?? '', 100),
                'quantity'        => (float)($_POST['quantity'] ?? 0),
                'unit'            => $_POST['unit'] ?? 'kg',
                'price_per_unit'  => (float)($_POST['price_per_unit'] ?? 0),
                'quality_grade'   => $_POST['quality_grade'] ?? 'B',
                'is_organic'      => !empty($_POST['is_organic']),
                'harvest_date'    => $_POST['harvest_date'] ?? null,
                'available_from'  => $_POST['available_from'] ?? date('Y-m-d'),
                'available_until' => $_POST['available_until'] ?? null,
                'description'     => clean_str($_POST['description'] ?? '', 1000),
            ];
            if (mb_strlen($data['crop_name']) < 2) $errors[] = 'ফসলের নাম দিতে হবে।';
            if ($data['category_id'] <= 0) $errors[] = 'ক্যাটাগরি নির্বাচন করুন।';
            if ($data['quantity'] <= 0) $errors[] = 'পরিমাণ ০ এর বেশি হতে হবে।';
            if ($data['price_per_unit'] <= 0) $errors[] = 'মূল্য ০ এর বেশি হতে হবে।';
            if (!in_array($data['unit'], ['kg','ton','mon','piece'], true)) $errors[] = 'অবৈধ একক।';
            if (!in_array($data['quality_grade'], ['A','B','C'], true)) $errors[] = 'অবৈধ মান গ্রেড।';

            // Image upload
            $uploaded = handle_image_uploads('images', 'crops', 5);
            foreach ($uploaded['errors'] as $err) $errors[] = $err;

            if (!empty($errors)) {
                foreach ($errors as $err) Flash::set('danger', $err);
            } else {
                // Merge images: keep existing + add new
                $existing = [];
                if ($crop && !empty($crop['images'])) {
                    $existing = is_array($crop['images']) ? $crop['images'] : (json_decode($crop['images'], true) ?: []);
                }
                $keep = $_POST['keep_image'] ?? [];
                $existing = array_values(array_intersect($existing, (array)$keep));
                $data['images'] = array_merge($existing, $uploaded['files']);

                if ($cropId) {
                    $cropModel->update($cropId, $userId, $data);
                    Flash::set('success', 'ফসল সফলভাবে আপডেট হয়েছে।');
                } else {
                    $newId = $cropModel->create($data);
                    Flash::set('success', 'নতুন ফসল সফলভাবে যোগ হয়েছে।');
                    $cropId = $newId;
                }
                $this->redirect('/farmer/crops');
            }
        }

        $categories = $pdo->query("SELECT * FROM crop_categories ORDER BY category_id")->fetchAll();
        $title = $cropId ? 'ফসল সম্পাদনা' : 'নতুন ফসল যোগ করুন';
        $images = [];
        if ($crop && !empty($crop['images'])) {
            $images = is_array($crop['images']) ? $crop['images'] : (json_decode($crop['images'], true) ?: []);
        }
        $this->view('farmer/crops/form', compact('title','crop','categories','images'));
    }

    private function cropsDelete($cropId) {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') $this->redirect('/farmer/crops');
        $this->requireCsrf();
        $ok = (new CropModel())->delete($cropId, $this->userId());
        Flash::set($ok ? 'success' : 'danger', $ok ? 'ফসল মুছে ফেলা হয়েছে।' : 'মুছতে ব্যর্থ।');
        $this->redirect('/farmer/crops');
    }

    // ─────────────────────────────────────────────────────────────────
    // ORDERS (received by farmer)
    // ─────────────────────────────────────────────────────────────────
    public function orders($action = null, $id = null) {
        $this->requireRole('Farmer');
        $userId = $this->userId();
        $orderModel = new OrderModel();

        if ($action === 'detail' && $id) {
            $order = $orderModel->find((int)$id);
            if (!$order || (int)$order['farmer_id'] !== $userId) {
                Flash::set('danger', 'অর্ডার পাওয়া যায়নি।');
                $this->redirect('/farmer/orders');
            }
            $title = 'অর্ডার বিস্তারিত | AgroFin';
            $this->view('farmer/orders/detail', compact('title','order'));
            return;
        }

        if ($action === 'update-status' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $order = $orderModel->find((int)$id);
            if (!$order || (int)$order['farmer_id'] !== $userId) {
                Flash::set('danger', 'অননুমোদিত।');
                $this->redirect('/farmer/orders');
            }
            $newStatus = $_POST['new_status'] ?? '';
            $reason    = clean_str($_POST['reason'] ?? '', 255);
            $ok = $orderModel->updateStatus((int)$id, $newStatus, $userId, $reason);
            Flash::set($ok ? 'success' : 'danger', $ok ? 'অর্ডারের অবস্থা আপডেট হয়েছে।' : 'আপডেট ব্যর্থ।');
            $this->redirect('/farmer/orders/detail/' . (int)$id);
        }

        $statusFilter = $_GET['status'] ?? null;
        $orders = $orderModel->listByFarmer($userId, $statusFilter);
        $title = 'প্রাপ্ত অর্ডার | AgroFin';
        $this->view('farmer/orders/index', compact('title','orders','statusFilter'));
    }

    // ─────────────────────────────────────────────────────────────────
    // INVENTORY
    // ─────────────────────────────────────────────────────────────────
    public function inventory() {
        $this->requireRole('Farmer');
        $logs = (new CropModel())->inventoryLogs($this->userId(), 100);
        $title = 'ইনভেন্টরি লগ | AgroFin';
        $this->view('farmer/inventory', compact('title','logs'));
    }

    // ─────────────────────────────────────────────────────────────────
    // LOANS
    // ─────────────────────────────────────────────────────────────────
    public function loans($action = null, $id = null) {
        $this->requireRole('Farmer');
        $userId = $this->userId();
        $loanModel = new LoanModel();

        if ($action === 'apply') return $this->loanApplyForm();
        if ($action === 'detail' && $id) return $this->loanDetail((int)$id);
        if ($action === 'repay' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $amount = (float)($_POST['amount'] ?? 0);
            $ref    = clean_str($_POST['transaction_reference'] ?? '', 100);
            $res = $loanModel->recordRepayment((int)$id, $userId, $amount, 'manual', $ref ?: null);
            Flash::set($res['ok'] ? 'success' : 'danger', $res['ok'] ? 'কিস্তি জমা সফল।' : ($res['error'] ?? 'ব্যর্থ'));
            $this->redirect('/farmer/loans/detail/' . (int)$id);
        }

        $loans = $loanModel->listByFarmer($userId);
        $creditScore = $loanModel->creditScore($userId);
        $title = 'মাইক্রো-লোন | AgroFin';
        $this->view('farmer/loans/index', compact('title','loans','creditScore'));
    }

    public function loanApply() { $this->redirect('/farmer/loans/apply'); }

    private function loanApplyForm() {
        $userId = $this->userId();
        $loanModel = new LoanModel();
        $cs = $loanModel->creditScore($userId);

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $data = [
                'farmer_id'      => $userId,
                'loan_amount'    => (float)($_POST['loan_amount'] ?? 0),
                'loan_purpose'   => clean_str($_POST['loan_purpose'] ?? '', 255),
                'tenure_months'  => (int)($_POST['tenure_months'] ?? 0),
                'interest_rate'  => 8.0,
            ];
            $errors = [];
            if ($data['loan_amount'] <= 0) $errors[] = 'লোনের পরিমাণ দিন।';
            if (mb_strlen($data['loan_purpose']) < 3) $errors[] = 'লোনের উদ্দেশ্য লিখুন।';
            if ($data['tenure_months'] < 1 || $data['tenure_months'] > 24) $errors[] = 'মেয়াদ ১-২৪ মাসের মধ্যে হতে হবে।';

            if ($errors) {
                foreach ($errors as $err) Flash::set('danger', $err);
            } else {
                $res = $loanModel->apply($data);
                if ($res['ok']) {
                    Flash::set('success', 'আপনার লোন আবেদন সফলভাবে জমা হয়েছে। অ্যাডমিনের পর্যালোচনার অপেক্ষায়।');
                    $this->redirect('/farmer/loans');
                } else {
                    Flash::set('danger', $res['error']);
                }
            }
        }
        $title = 'লোনের আবেদন | AgroFin';
        $this->view('farmer/loans/apply', compact('title','cs'));
    }

    private function loanDetail($loanId) {
        $userId = $this->userId();
        $loanModel = new LoanModel();
        $loan = $loanModel->find($loanId);
        if (!$loan || (int)$loan['farmer_id'] !== $userId) {
            Flash::set('danger', 'লোন পাওয়া যায়নি।');
            $this->redirect('/farmer/loans');
        }
        $repayments = $loanModel->repaymentsForLoan($loanId);
        $title = 'লোন বিস্তারিত | AgroFin';
        $this->view('farmer/loans/detail', compact('title','loan','repayments'));
    }

    // ─────────────────────────────────────────────────────────────────
    // EXPENSES
    // ─────────────────────────────────────────────────────────────────
    public function expenses($action = null, $id = null) {
        $this->requireRole('Farmer');
        $userId = $this->userId();
        $expenseModel = new ExpenseModel();

        if ($action === 'add')    return $this->expenseForm(null);
        if ($action === 'edit')   return $this->expenseForm((int)$id);
        if ($action === 'delete') {
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') $this->redirect('/farmer/expenses');
            $this->requireCsrf();
            $ok = $expenseModel->delete((int)$id, $userId);
            Flash::set($ok ? 'success' : 'danger', $ok ? 'খরচ মুছে ফেলা হয়েছে।' : 'মুছতে ব্যর্থ।');
            $this->redirect('/farmer/expenses');
        }

        $filters = [
            'category' => $_GET['category'] ?? null,
            'date_from'=> $_GET['date_from'] ?? null,
            'date_to'  => $_GET['date_to'] ?? null,
        ];
        $expenses = $expenseModel->listByFarmer($userId, $filters);
        $total = array_sum(array_map(fn($e) => (float)$e['expense_amount'], $expenses));
        $byCategory = $expenseModel->byCategory($userId, $filters['date_from'], $filters['date_to']);
        $title = 'খরচ ব্যবস্থাপনা | AgroFin';
        $this->view('farmer/expenses/index', compact('title','expenses','total','byCategory','filters'));
    }

    private function expenseForm($expenseId) {
        $userId = $this->userId();
        $expenseModel = new ExpenseModel();
        $expense = $expenseId ? $expenseModel->find($expenseId, $userId) : null;
        if ($expenseId && !$expense) {
            Flash::set('danger', 'খরচ পাওয়া যায়নি।');
            $this->redirect('/farmer/expenses');
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $data = [
                'farmer_id'           => $userId,
                'crop_id'             => !empty($_POST['crop_id']) ? (int)$_POST['crop_id'] : null,
                'expense_category'    => $_POST['expense_category'] ?? 'other',
                'expense_amount'      => (float)($_POST['expense_amount'] ?? 0),
                'expense_description' => clean_str($_POST['expense_description'] ?? '', 255),
                'expense_date'        => $_POST['expense_date'] ?? date('Y-m-d'),
            ];
            $errors = [];
            $validCats = ['seeds','fertilizer','pesticide','labor','irrigation','equipment','transport','other'];
            if (!in_array($data['expense_category'], $validCats, true)) $errors[] = 'অবৈধ ক্যাটাগরি।';
            if ($data['expense_amount'] <= 0) $errors[] = 'পরিমাণ ০ এর বেশি হতে হবে।';

            // Optional receipt
            $receipt = handle_single_upload('receipt', 'receipts', 2 * 1024 * 1024);
            if ($receipt) $data['receipt_url'] = $receipt;

            if ($errors) {
                foreach ($errors as $err) Flash::set('danger', $err);
            } else {
                if ($expenseId) $expenseModel->update($expenseId, $userId, $data);
                else $expenseModel->create($data);
                Flash::set('success', $expenseId ? 'খরচ আপডেট হয়েছে।' : 'খরচ যোগ হয়েছে।');
                $this->redirect('/farmer/expenses');
            }
        }

        $crops = (new CropModel())->listByFarmer($userId);
        $title = $expenseId ? 'খরচ সম্পাদনা' : 'নতুন খরচ যোগ করুন';
        $this->view('farmer/expenses/form', compact('title','expense','crops'));
    }

    // ─────────────────────────────────────────────────────────────────
    // PROFIT-LOSS REPORT
    // ─────────────────────────────────────────────────────────────────
    public function profitLoss() {
        $this->requireRole('Farmer');
        $userId = $this->userId();
        $from = $_GET['from'] ?? date('Y-m-01', strtotime('-2 months'));
        $to   = $_GET['to']   ?? date('Y-m-d');
        $expenseModel = new ExpenseModel();
        $pl = $expenseModel->profitLoss($userId, $from, $to);
        $byCategory = $expenseModel->byCategory($userId, $from, $to);
        $title = 'লাভ-ক্ষতি রিপোর্ট | AgroFin';
        $this->view('farmer/profit-loss', compact('title','pl','byCategory','from','to'));
    }

    // ─────────────────────────────────────────────────────────────────
    // CREDIT SCORE
    // ─────────────────────────────────────────────────────────────────
    public function creditScore() {
        $this->requireRole('Farmer');
        $cs = (new LoanModel())->creditScore($this->userId());
        $title = 'ক্রেডিট স্কোর | AgroFin';
        $this->view('farmer/credit-score', compact('title','cs'));
    }

    // ─────────────────────────────────────────────────────────────────
    // SMART ASSISTANT
    // ─────────────────────────────────────────────────────────────────
    public function assistant() {
        $this->requireRole('Farmer');
        $userId = $this->userId();
        $assistant = new AssistantModel();
        $latest = null;

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $query = clean_str($_POST['query'] ?? '', 1000);
            if ($query !== '') {
                $latest = $assistant->process($userId, $query, ['role' => 'Farmer']);
            }
        }
        // Handle feedback POST
        if (!empty($_POST['feedback_id']) && !empty($_POST['feedback_value']) && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $assistant->recordFeedback((int)$_POST['feedback_id'], $userId, $_POST['feedback_value'] === 'yes');
        }

        $history = $assistant->history($userId, 30);
        $title = '🤖 স্মার্ট সহকারী | AgroFin';
        $this->view('farmer/assistant', compact('title','history','latest'));
    }

    // ─────────────────────────────────────────────────────────────────
    // WEATHER ALERTS PAGE
    // ─────────────────────────────────────────────────────────────────
    public function weather() {
        $this->requireRole('Farmer');
        $userId = $this->userId();
        $districtId = (int)($_SESSION['district_id'] ?? 0);

        $pdo = (new Model())->pdo();
        $alerts = [];
        try {
            $stmt = $pdo->prepare(
                "SELECT * FROM weather_alerts
                 WHERE is_active = 1 AND JSON_CONTAINS(affected_districts, ?)
                 ORDER BY severity = 'severe' DESC, severity = 'high' DESC, created_at DESC"
            );
            $stmt->execute([(string)$districtId]);
            $alerts = $stmt->fetchAll();
        } catch (Throwable $e) { $alerts = []; }

        // Recent inactive alerts (history)
        $stmt = $pdo->prepare(
            "SELECT * FROM weather_alerts
             WHERE is_active = 0 AND JSON_CONTAINS(affected_districts, ?)
             ORDER BY created_at DESC LIMIT 10"
        );
        $stmt->execute([(string)$districtId]);
        $history = $stmt->fetchAll();

        $title = '⛈ আবহাওয়া সতর্কতা | AgroFin';
        $this->view('farmer/weather', compact('title','alerts','history'));
    }

    // ─────────────────────────────────────────────────────────────────
    // FARMER GROUPS
    // ─────────────────────────────────────────────────────────────────
    public function groups($action = null, $id = null) {
        $this->requireRole('Farmer');
        $userId = $this->userId();
        $groupModel = new GroupModel();

        if ($action === 'create') return $this->groupCreateForm();
        if ($action === 'detail' && $id) return $this->groupDetail((int)$id);
        if ($action === 'join' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $land = (float)($_POST['land_contribution_acres'] ?? 0);
            $res = $groupModel->join((int)$id, $userId, $land);
            Flash::set($res['ok'] ? 'success' : 'danger', $res['ok'] ? '✓ গ্রুপে যোগ দিয়েছেন।' : $res['error']);
            $this->redirect('/farmer/groups/detail/' . (int)$id);
        }
        if ($action === 'leave' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $res = $groupModel->leave((int)$id, $userId);
            Flash::set($res['ok'] ? 'info' : 'danger', $res['ok'] ? 'গ্রুপ ত্যাগ করেছেন।' : $res['error']);
            $this->redirect('/farmer/groups');
        }

        $myGroups = $groupModel->listForFarmer($userId);
        $districtId = (int)($_SESSION['district_id'] ?? 0);
        $localGroups = $groupModel->listAll($districtId);

        $title = 'কৃষক গ্রুপ | AgroFin';
        $this->view('farmer/groups/index', compact('title','myGroups','localGroups'));
    }

    private function groupCreateForm() {
        $userId = $this->userId();
        $groupModel = new GroupModel();

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $data = [
                'group_name'         => clean_str($_POST['group_name'] ?? '', 100),
                'leader_id'          => $userId,
                'district_id'        => (int)($_POST['district_id'] ?? ($_SESSION['district_id'] ?? 0)),
                'land_contribution'  => (float)($_POST['land_contribution'] ?? 0),
                'description'        => clean_str($_POST['description'] ?? '', 500),
                'formation_date'     => $_POST['formation_date'] ?? date('Y-m-d'),
            ];
            $errors = [];
            if (mb_strlen($data['group_name']) < 3) $errors[] = 'গ্রুপের নাম লিখুন।';
            if ($data['district_id'] <= 0) $errors[] = 'জেলা নির্বাচন করুন।';

            if (!$errors) {
                $res = $groupModel->create($data);
                if ($res['ok']) {
                    Flash::set('success', '✓ গ্রুপ তৈরি হয়েছে। কোড: ' . $res['group_code']);
                    $this->redirect('/farmer/groups/detail/' . $res['group_id']);
                } else {
                    Flash::set('danger', $res['error']);
                }
            }
            foreach ($errors as $err) Flash::set('danger', $err);
        }

        $districts = (new DistrictModel())->all();
        $title = 'নতুন গ্রুপ তৈরি';
        $this->view('farmer/groups/create', compact('title','districts'));
    }

    private function groupDetail($groupId) {
        $groupModel = new GroupModel();
        $group = $groupModel->find($groupId);
        if (!$group) {
            Flash::set('danger', 'গ্রুপ পাওয়া যায়নি।');
            $this->redirect('/farmer/groups');
        }
        $members = $groupModel->members($groupId);
        $isMember = $groupModel->isMember($groupId, $this->userId());

        $title = e($group['group_name']) . ' | গ্রুপ';
        $this->view('farmer/groups/detail', compact('title','group','members','isMember'));
    }

    // ─────────────────────────────────────────────────────────────────
    // WALLET — balance, transaction history, withdrawal requests
    // ─────────────────────────────────────────────────────────────────
    public function wallet($action = null) {
        $this->requireRole('Farmer');
        $userId = $this->userId();
        $txn = new TransactionModel();

        // POST withdrawal request
        if ($action === 'withdraw' && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $amount      = (float)($_POST['amount'] ?? 0);
            $method      = clean_str($_POST['method'] ?? '', 20);
            $account     = clean_str($_POST['account_number'] ?? '', 50);
            $accountName = clean_str($_POST['account_name'] ?? '', 100);

            $res = $txn->requestWithdrawal($userId, $amount, $method, $account, $accountName);
            if ($res['ok']) {
                Flash::set('success', 'উত্তোলনের অনুরোধ সফলভাবে জমা হয়েছে। অ্যাডমিন অনুমোদনের পর ব্যালেন্স কাটা হবে। রেফারেন্স: ' . $res['reference']);
            } else {
                Flash::set('danger', $res['error'] ?? 'উত্তোলন ব্যর্থ');
            }
            $this->redirect('/farmer/wallet');
        }

        // GET withdraw form
        if ($action === 'withdraw') {
            $user = (new UserModel())->find($userId);
            $title = 'উত্তোলন | AgroFin';
            return $this->view('farmer/wallet/withdraw', compact('title', 'user'));
        }

        // GET wallet index
        $user         = (new UserModel())->find($userId);
        $transactions = $txn->listForUser($userId, 100);
        $summary      = $txn->summary($userId);

        $title = 'আমার ওয়ালেট | AgroFin';
        $this->view('farmer/wallet/index', compact('title', 'user', 'transactions', 'summary'));
    }

    // ─────────────────────────────────────────────────────────────────
    // MESSAGES
    // ─────────────────────────────────────────────────────────────────
    public function messages($action = null, $partnerId = null) {
        $this->requireRole('Farmer');
        return $this->_messagesShared($action, $partnerId);
    }

    /** Shared between farmer and buyer messages views (we use the same view). */
    protected function _messagesShared($action, $partnerId) {
        $userId = $this->userId();
        $msg = new MessageModel();

        if ($action === 'send' && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $receiverId = (int)($_POST['receiver_id'] ?? 0);
            $text = clean_str($_POST['message_text'] ?? '', 2000);
            if ($receiverId > 0 && $receiverId !== $userId && $text !== '') {
                $msg->send($userId, $receiverId, $text);
            }
            $role = strtolower($this->activeRole());
            $this->redirect("/$role/messages/with/$receiverId");
        }

        $inbox = $msg->inbox($userId);
        $conversation = [];
        $partner = null;
        if ($action === 'with' && $partnerId) {
            $partnerId = (int)$partnerId;
            $partner = (new UserModel())->find($partnerId);
            if ($partner) {
                $conversation = $msg->conversation($userId, $partnerId);
                $msg->markRead($userId, $partnerId);
            }
        }
        $title = 'বার্তা | AgroFin';
        $role = strtolower($this->activeRole());
        $this->view($role . '/messages', compact('title','inbox','conversation','partner'));
    }
}
