<?php
/**
 * BuyerController — full Chunk-2 buyer module.
 * URL patterns mirror FarmerController dispatch style.
 */
class BuyerController extends FarmerController { // reuse _messagesShared

    public function index() { $this->redirect('/buyer/dashboard'); }

    // ─────────────────────────────────────────────────────────────────
    // DASHBOARD (real data)
    // ─────────────────────────────────────────────────────────────────
    public function dashboard() {
        $this->requireRole('Buyer');
        $userId = $this->userId();
        $stats = (new StatsModel())->forBuyer($userId);

        $pdo = (new Model())->pdo();

        $st = $pdo->prepare(
            "SELECT o.*, c.crop_name, c.images, u.full_name AS farmer_name, d.district_name
             FROM orders o
             JOIN crops c ON o.crop_id = c.crop_id
             JOIN users u ON o.farmer_id = u.user_id
             LEFT JOIN districts d ON u.district_id = d.district_id
             WHERE o.buyer_id = ? ORDER BY o.order_date DESC LIMIT 5"
        );
        $st->execute([$userId]);
        $recentOrders = $st->fetchAll();

        $st = $pdo->prepare(
            "SELECT c.*, u.full_name AS farmer_name, d.district_name, cc.category_name_bn
             FROM crops c
             JOIN users u ON c.farmer_id = u.user_id
             LEFT JOIN districts d ON u.district_id = d.district_id
             JOIN crop_categories cc ON c.category_id = cc.category_id
             WHERE c.status='available' AND c.quantity > 0
             ORDER BY c.created_at DESC LIMIT 6"
        );
        $st->execute();
        $featured = $st->fetchAll();

        $st = $pdo->prepare(
            "SELECT f.*, c.crop_name, c.price_per_unit, c.unit
             FROM favorites f LEFT JOIN crops c ON f.crop_id = c.crop_id
             WHERE f.user_id = ? AND f.favorite_type = 'crop'
             ORDER BY f.created_at DESC LIMIT 4"
        );
        $st->execute([$userId]);
        $favorites = $st->fetchAll();

        $title = 'ক্রেতা ড্যাশবোর্ড | AgroFin';
        $this->view('buyer/dashboard', compact('title','stats','recentOrders','featured','favorites'));
    }

    // ─────────────────────────────────────────────────────────────────
    // BROWSE MARKETPLACE
    // ─────────────────────────────────────────────────────────────────
    public function browse() {
        $this->requireRole('Buyer');
        $cropModel = new CropModel();
        $pdo = (new Model())->pdo();

        $filters = [
            'q'           => trim($_GET['q'] ?? ''),
            'category_id' => $_GET['category_id'] ?? null,
            'district_id' => $_GET['district_id'] ?? null,
            'min_price'   => $_GET['min_price'] ?? null,
            'max_price'   => $_GET['max_price'] ?? null,
            'quality'     => $_GET['quality'] ?? null,
            'organic'     => $_GET['organic'] ?? null,
            'sort'        => $_GET['sort'] ?? 'newest',
        ];
        $page = max(1, (int)($_GET['page'] ?? 1));
        $perPage = 12;
        $offset = ($page - 1) * $perPage;

        // Try MeiliSearch (gets fast typo-tolerant Bangla search if configured + running)
        // Falls back to SQL LIKE-search transparently when Meili is missing/down.
        $searchInfo = SearchProvider::searchCrops($filters, $perPage, $offset);

        if ($searchInfo['driver'] === 'meilisearch' && is_array($searchInfo['hits'])) {
            // Hydrate the crop_id list from Meili with full DB rows (so stock/status are fresh)
            $crops = $cropModel->findByIds($searchInfo['hits']);
            $total = (int)$searchInfo['total'];
        } else {
            // SQL fallback (also the default driver)
            $crops = $cropModel->search($filters, $perPage, $offset);
            $total = $cropModel->searchCount($filters);
        }
        $totalPages = (int)ceil($total / $perPage);

        $categories = $pdo->query("SELECT * FROM crop_categories ORDER BY category_id")->fetchAll();
        $districts  = (new DistrictModel())->all();

        // Log search if meaningful
        if (!empty($filters['q']) || !empty($filters['category_id'])) {
            try {
                $pdo->prepare(
                    "INSERT INTO search_logs (user_id, search_query, filters_applied, results_count)
                     VALUES (?,?,?,?)"
                )->execute([
                    $this->userId(),
                    $filters['q'] ?: '(filter only)',
                    json_encode($filters, JSON_UNESCAPED_UNICODE),
                    $total,
                ]);
            } catch (Throwable $e) {}
        }

        $searchDriver = $searchInfo['driver'];   // expose to view for the badge
        $searchTimeMs = $searchInfo['elapsed_ms'];

        $title = 'মার্কেটপ্লেস ব্রাউজ | AgroFin';
        $this->view('buyer/browse', compact('title','crops','total','totalPages','page','filters','categories','districts','searchDriver','searchTimeMs'));
    }

    // ─────────────────────────────────────────────────────────────────
    // CROP DETAIL
    // ─────────────────────────────────────────────────────────────────
    public function crop($cropId = null) {
        $this->requireRole('Buyer');
        $cropId = (int)$cropId;
        $cropModel = new CropModel();
        $crop = $cropModel->find($cropId);
        if (!$crop) {
            Flash::set('danger', 'ফসলটি পাওয়া যায়নি।');
            $this->redirect('/buyer/browse');
        }
        $cropModel->incrementViews($cropId);

        $isFavorite = (new FavoriteModel())->isCropFavorite($this->userId(), $cropId);

        // Recent ratings of this farmer
        $ratings = (new RatingModel())->listForFarmer($crop['farmer_id'], 5);

        // Payment methods for one-click order
        $paymentMethods = (new PaymentMethodModel())->listForUser($this->userId());
        $districts = (new DistrictModel())->all();

        $title = e($crop['crop_name']) . ' | AgroFin';
        $this->view('buyer/crop', compact('title','crop','isFavorite','ratings','paymentMethods','districts'));
    }

    // ─────────────────────────────────────────────────────────────────
    // PLACE ORDER (POST handler)
    // ─────────────────────────────────────────────────────────────────
    public function order() {
        $this->requireRole('Buyer');
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') $this->redirect('/buyer/browse');
        $this->requireCsrf();

        $userId = $this->userId();
        $data = [
            'buyer_id'             => $userId,
            'crop_id'              => (int)($_POST['crop_id'] ?? 0),
            'quantity_ordered'     => (float)($_POST['quantity'] ?? 0),
            'delivery_type'        => $_POST['delivery_type'] ?? 'home_delivery',
            'delivery_address'     => clean_str($_POST['delivery_address'] ?? '', 255),
            'delivery_district_id' => (int)($_POST['delivery_district_id'] ?? 0) ?: null,
            'preferred_delivery_date' => $_POST['preferred_delivery_date'] ?? null,
            'special_instructions' => clean_str($_POST['special_instructions'] ?? '', 500),
            'delivery_charge'      => 50, // flat for now
        ];

        if ($data['crop_id'] <= 0) {
            Flash::set('danger', 'অবৈধ ফসল।');
            $this->redirect('/buyer/browse');
        }

        $res = (new OrderModel())->create($data);
        if (!$res['ok']) {
            Flash::set('danger', 'অর্ডার ব্যর্থ: ' . $res['error']);
            $this->redirect('/buyer/crop/' . $data['crop_id']);
        }

        // Check if payment gateway is enabled
        $paymentProvider = Env::get('PAYMENT_PROVIDER', '');
        if ($paymentProvider !== '' && $paymentProvider !== 'disabled') {
            // Route through payment gateway
            Flash::set('info', 'অর্ডার তৈরি — পেমেন্ট সম্পন্ন করুন। অর্ডার নম্বর: ' . $res['order_number']);
            $this->redirect('/payment/initiate/' . $res['order_id']);
        }

        // Legacy flow — no gateway configured, order is confirmed as before
        Flash::set('success', 'অভিনন্দন! অর্ডার নম্বর: ' . $res['order_number']);
        $this->redirect('/buyer/orders/detail/' . $res['order_id']);
    }

    // ─────────────────────────────────────────────────────────────────
    // MY ORDERS
    // ─────────────────────────────────────────────────────────────────
    public function orders($action = null, $id = null) {
        $this->requireRole('Buyer');
        $userId = $this->userId();
        $orderModel = new OrderModel();

        if ($action === 'detail' && $id) {
            $order = $orderModel->find((int)$id);
            if (!$order || (int)$order['buyer_id'] !== $userId) {
                Flash::set('danger', 'অর্ডার পাওয়া যায়নি।');
                $this->redirect('/buyer/orders');
            }
            $rating = (new RatingModel())->ratingForOrder((int)$id);
            $title = 'অর্ডার বিস্তারিত | AgroFin';
            $this->view('buyer/orders/detail', compact('title','order','rating'));
            return;
        }

        if ($action === 'cancel' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $order = $orderModel->find((int)$id);
            if (!$order || (int)$order['buyer_id'] !== $userId) {
                Flash::set('danger', 'অননুমোদিত।');
                $this->redirect('/buyer/orders');
            }
            if (!in_array($order['order_status'], ['pending','confirmed'], true)) {
                Flash::set('danger', 'এই অর্ডারটি এখন বাতিল করা যাবে না।');
                $this->redirect('/buyer/orders/detail/' . (int)$id);
            }
            $reason = clean_str($_POST['reason'] ?? 'ক্রেতা কর্তৃক বাতিল', 255);
            $orderModel->updateStatus((int)$id, 'cancelled', $userId, $reason);
            Flash::set('success', 'অর্ডার বাতিল হয়েছে।');
            $this->redirect('/buyer/orders/detail/' . (int)$id);
        }

        if ($action === 'review' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $data = [
                'overall_rating'       => (float)($_POST['overall_rating'] ?? 0),
                'quality_rating'       => (float)($_POST['quality_rating'] ?? 0),
                'delivery_rating'      => (float)($_POST['delivery_rating'] ?? 0),
                'communication_rating' => (float)($_POST['communication_rating'] ?? 0),
                'review_title'         => clean_str($_POST['review_title'] ?? '', 100),
                'review_text'          => clean_str($_POST['review_text'] ?? '', 1000),
                'would_recommend'      => !empty($_POST['would_recommend']),
            ];
            foreach (['overall_rating','quality_rating','delivery_rating','communication_rating'] as $k) {
                if ($data[$k] < 1 || $data[$k] > 5) {
                    Flash::set('danger', 'রেটিং ১ থেকে ৫ এর মধ্যে দিন।');
                    $this->redirect('/buyer/orders/detail/' . (int)$id);
                }
            }
            $res = (new RatingModel())->createForOrder((int)$id, $userId, $data);
            Flash::set($res['ok'] ? 'success' : 'danger', $res['ok'] ? 'ধন্যবাদ! রিভিউ যোগ হয়েছে।' : $res['error']);
            $this->redirect('/buyer/orders/detail/' . (int)$id);
        }

        $statusFilter = $_GET['status'] ?? null;
        $orders = $orderModel->listByBuyer($userId, $statusFilter);
        $title = 'আমার অর্ডার | AgroFin';
        $this->view('buyer/orders/index', compact('title','orders','statusFilter'));
    }

    // ─────────────────────────────────────────────────────────────────
    // FAVORITES
    // ─────────────────────────────────────────────────────────────────
    public function favorites($action = null, $id = null) {
        $this->requireRole('Buyer');
        $userId = $this->userId();
        $favModel = new FavoriteModel();

        if ($action === 'toggle-crop' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $result = $favModel->toggleCrop($userId, (int)$id);
            Flash::set('info', $result === 'added' ? 'প্রিয় তালিকায় যোগ হয়েছে।' : 'প্রিয় তালিকা থেকে সরানো হয়েছে।');
            $this->redirect($_SERVER['HTTP_REFERER'] ?? '/buyer/favorites');
        }

        if ($action === 'toggle-farmer' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $favModel->toggleFarmer($userId, (int)$id);
            $this->redirect($_SERVER['HTTP_REFERER'] ?? '/buyer/favorites');
        }

        $cropFavorites = $favModel->listCrops($userId);
        $farmerFavorites = $favModel->listFarmers($userId);
        $title = 'প্রিয় তালিকা | AgroFin';
        $this->view('buyer/favorites', compact('title','cropFavorites','farmerFavorites'));
    }

    // ─────────────────────────────────────────────────────────────────
    // SUBSCRIPTIONS
    // ─────────────────────────────────────────────────────────────────
    public function subscriptions($action = null, $id = null) {
        $this->requireRole('Buyer');
        $userId = $this->userId();
        $subModel = new SubscriptionModel();

        if ($action === 'add')    return $this->subscriptionForm();
        if ($action === 'pause' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $subModel->setStatus((int)$id, $userId, 'paused');
            Flash::set('info', 'সাবস্ক্রিপশন স্থগিত করা হয়েছে।');
            $this->redirect('/buyer/subscriptions');
        }
        if ($action === 'resume' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $subModel->setStatus((int)$id, $userId, 'active');
            Flash::set('success', 'সাবস্ক্রিপশন পুনরায় চালু।');
            $this->redirect('/buyer/subscriptions');
        }
        if ($action === 'cancel' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $subModel->setStatus((int)$id, $userId, 'cancelled');
            Flash::set('info', 'সাবস্ক্রিপশন বাতিল করা হয়েছে।');
            $this->redirect('/buyer/subscriptions');
        }

        $subs = $subModel->listByBuyer($userId);
        $title = 'সাবস্ক্রিপশন | AgroFin';
        $this->view('buyer/subscriptions/index', compact('title','subs'));
    }

    private function subscriptionForm() {
        $userId = $this->userId();
        $subModel = new SubscriptionModel();
        $pdo = (new Model())->pdo();

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $data = [
                'buyer_id'              => $userId,
                'farmer_id'             => (int)($_POST['farmer_id'] ?? 0),
                'crop_name'             => clean_str($_POST['crop_name'] ?? '', 100),
                'quantity_per_delivery' => (float)($_POST['quantity_per_delivery'] ?? 0),
                'unit'                  => $_POST['unit'] ?? 'kg',
                'price_locked'          => (float)($_POST['price_locked'] ?? 0),
                'frequency'             => $_POST['frequency'] ?? 'weekly',
                'start_date'            => $_POST['start_date'] ?? date('Y-m-d'),
                'next_delivery_date'    => $_POST['next_delivery_date'] ?? date('Y-m-d', strtotime('+7 days')),
                'end_date'              => $_POST['end_date'] ?? null,
                'auto_payment'          => !empty($_POST['auto_payment']),
                'payment_method_id'     => (int)($_POST['payment_method_id'] ?? 0) ?: null,
            ];
            $errors = [];
            if ($data['farmer_id'] <= 0) $errors[] = 'কৃষক নির্বাচন করুন।';
            if ($data['quantity_per_delivery'] <= 0) $errors[] = 'পরিমাণ ০ এর বেশি হতে হবে।';
            if ($data['price_locked'] <= 0) $errors[] = 'মূল্য ০ এর বেশি হতে হবে।';
            if (!in_array($data['frequency'], ['daily','weekly','biweekly','monthly'], true)) $errors[] = 'অবৈধ ফ্রিকোয়েন্সি।';

            if (!$errors) {
                $subModel->create($data);
                Flash::set('success', 'সাবস্ক্রিপশন সফলভাবে যোগ হয়েছে।');
                $this->redirect('/buyer/subscriptions');
            }
            foreach ($errors as $err) Flash::set('danger', $err);
        }

        // Suggested farmers: those the buyer has ordered from before
        $farmers = $pdo->prepare(
            "SELECT DISTINCT u.user_id, u.full_name, u.phone, d.district_name
             FROM users u
             JOIN orders o ON o.farmer_id = u.user_id
             LEFT JOIN districts d ON u.district_id = d.district_id
             WHERE o.buyer_id = ?
             ORDER BY u.full_name"
        );
        $farmers->execute([$userId]);
        $farmers = $farmers->fetchAll();

        $paymentMethods = (new PaymentMethodModel())->listForUser($userId);
        $title = 'নতুন সাবস্ক্রিপশন | AgroFin';
        $this->view('buyer/subscriptions/form', compact('title','farmers','paymentMethods'));
    }

    // ─────────────────────────────────────────────────────────────────
    // PAYMENT METHODS
    // ─────────────────────────────────────────────────────────────────
    public function paymentMethods($action = null, $id = null) {
        $this->requireRole('Buyer');
        $userId = $this->userId();
        $pmModel = new PaymentMethodModel();

        if ($action === 'add' && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $data = [
                'user_id'        => $userId,
                'method_type'    => $_POST['method_type'] ?? 'bkash',
                'account_number' => clean_str($_POST['account_number'] ?? '', 50),
                'account_name'   => clean_str($_POST['account_name'] ?? '', 100),
                'bank_name'      => clean_str($_POST['bank_name'] ?? '', 100),
                'is_default'     => !empty($_POST['is_default']),
            ];
            if (!in_array($data['method_type'], ['bkash','nagad','rocket','bank_transfer','wallet'], true)) {
                Flash::set('danger', 'অবৈধ পেমেন্ট পদ্ধতি।');
                $this->redirect('/buyer/payment-methods');
            }
            if (mb_strlen($data['account_number']) < 3) {
                Flash::set('danger', 'অ্যাকাউন্ট নম্বর দিন।');
                $this->redirect('/buyer/payment-methods');
            }
            $pmModel->add($data);
            Flash::set('success', 'পেমেন্ট পদ্ধতি যোগ হয়েছে।');
            $this->redirect('/buyer/payment-methods');
        }

        if ($action === 'default' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $pmModel->setDefault((int)$id, $userId);
            Flash::set('success', 'ডিফল্ট পেমেন্ট পদ্ধতি সেট হয়েছে।');
            $this->redirect('/buyer/payment-methods');
        }

        if ($action === 'delete' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $pmModel->delete((int)$id, $userId);
            Flash::set('info', 'পেমেন্ট পদ্ধতি মুছে ফেলা হয়েছে।');
            $this->redirect('/buyer/payment-methods');
        }

        $methods = $pmModel->listForUser($userId);
        $title = 'পেমেন্ট পদ্ধতি | AgroFin';
        $this->view('buyer/payment-methods', compact('title','methods'));
    }

    // ─────────────────────────────────────────────────────────────────
    // MESSAGES
    // ─────────────────────────────────────────────────────────────────
    public function messages($action = null, $partnerId = null) {
        $this->requireRole('Buyer');
        return $this->_messagesShared($action, $partnerId);
    }
}
