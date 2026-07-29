<?php
/**
 * AgentController — Chunk 3 full agent module.
 * Inherits _messagesShared from FarmerController.
 */
class AgentController extends FarmerController {

    public function index() { $this->redirect('/agent/dashboard'); }

    // Aliases matching the existing sidebar URLs:
    public function registerFarmer() { $this->redirect('/agent/farmers/register'); }
    public function listCrop()       { $this->redirect('/agent/crops'); }
    public function activities()     { $this->redirect('/agent/earnings'); }

    // ─────────────────────────────────────────────────────────────────
    // DASHBOARD
    // ─────────────────────────────────────────────────────────────────
    public function dashboard() {
        $this->requireRole('Agent');
        $userId = $this->userId();
        $agent  = (new AgentModel())->findByUserId($userId);
        if (!$agent) {
            Flash::set('danger', 'এজেন্ট প্রোফাইল পাওয়া যায়নি।');
            $this->redirect('/');
        }
        $stats = (new StatsModel())->forAgent($agent['agent_id']);

        $farmers = (new AgentModel())->assignedFarmers($agent['agent_id'], 'active');
        $farmers = array_slice($farmers, 0, 5);

        $tickets = (new TicketModel())->listForAgent($agent['agent_id'], null);
        $tickets = array_slice($tickets, 0, 5);

        $unassigned = (new TicketModel())->listUnassigned();
        $unassigned = array_slice($unassigned, 0, 5);

        $activities = (new AgentModel())->activities($agent['agent_id'], 8);

        $title = 'এজেন্ট ড্যাশবোর্ড | AgroFin';
        $this->view('agent/dashboard', compact('title','agent','stats','farmers','tickets','unassigned','activities'));
    }

    // ─────────────────────────────────────────────────────────────────
    // FARMERS (assigned + register on behalf)
    // ─────────────────────────────────────────────────────────────────
    public function farmers($action = null, $id = null) {
        $this->requireRole('Agent');
        $agent = (new AgentModel())->findByUserId($this->userId());
        if (!$agent) { Flash::set('danger', 'এজেন্ট প্রোফাইল পাওয়া যায়নি।'); $this->redirect('/'); }

        if ($action === 'register') return $this->farmerRegisterForm($agent);
        if ($action === 'detail' && $id) return $this->farmerDetail($agent, (int)$id);

        $farmers = (new AgentModel())->assignedFarmers($agent['agent_id']);
        $title = 'আমার কৃষক | AgroFin';
        $this->view('agent/farmers/index', compact('title','farmers','agent'));
    }

    private function farmerRegisterForm($agent) {
        $newPassword = null;
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $data = [
                'phone'       => preg_replace('/\D/', '', $_POST['phone'] ?? ''),
                'email'       => trim($_POST['email'] ?? '') ?: null,
                'full_name'   => clean_str($_POST['full_name'] ?? '', 100),
                'district_id' => !empty($_POST['district_id']) ? (int)$_POST['district_id'] : null,
                'address'     => clean_str($_POST['address'] ?? '', 255),
                'password'    => trim($_POST['password'] ?? '') ?: null,
            ];
            $errors = [];
            if (!preg_match('/^01[3-9]\d{8}$/', $data['phone'])) $errors[] = 'বৈধ ফোন নম্বর দিন (০১XXXXXXXXX)।';
            if (mb_strlen($data['full_name']) < 2) $errors[] = 'কৃষকের পূর্ণ নাম দিন।';
            if ($data['email'] && !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) $errors[] = 'অবৈধ ইমেল।';

            if (!$errors) {
                $res = (new AgentModel())->registerFarmer($agent['agent_id'], $data);
                if ($res['ok']) {
                    Flash::set('success', '✓ কৃষক সফলভাবে রেজিস্টার্ড হয়েছেন। কমিশন: ৳৫০। অস্থায়ী পাসওয়ার্ড: <strong>' . e($res['password']) . '</strong>');
                    $this->redirect('/agent/farmers');
                } else {
                    Flash::set('danger', $res['error']);
                }
            } else {
                foreach ($errors as $err) Flash::set('danger', $err);
            }
        }
        $districts = (new DistrictModel())->all();
        $title = 'নতুন কৃষক রেজিস্ট্রেশন';
        $this->view('agent/farmers/register', compact('title','districts','agent'));
    }

    private function farmerDetail($agent, $farmerId) {
        $agentModel = new AgentModel();
        if (!$agentModel->isFarmerAssigned($agent['agent_id'], $farmerId)) {
            Flash::set('danger', 'এই কৃষক আপনাকে এসাইন করা নেই।');
            $this->redirect('/agent/farmers');
        }
        $farmer = (new UserModel())->find($farmerId);
        $pdo = (new Model())->pdo();
        $st = $pdo->prepare(
            "SELECT c.*, cc.category_name_bn FROM crops c
             JOIN crop_categories cc ON c.category_id = cc.category_id
             WHERE c.farmer_id = ? ORDER BY c.created_at DESC"
        );
        $st->execute([$farmerId]);
        $crops = $st->fetchAll();

        $st = $pdo->prepare(
            "SELECT o.*, c.crop_name FROM orders o
             JOIN crops c ON o.crop_id = c.crop_id
             WHERE o.farmer_id = ? ORDER BY o.order_date DESC LIMIT 10"
        );
        $st->execute([$farmerId]);
        $orders = $st->fetchAll();

        $title = e($farmer['full_name']) . ' | এজেন্ট ভিউ';
        $this->view('agent/farmers/detail', compact('title','farmer','crops','orders','agent'));
    }

    // ─────────────────────────────────────────────────────────────────
    // CROPS ON BEHALF
    // ─────────────────────────────────────────────────────────────────
    public function crops($action = null, $id = null) {
        $this->requireRole('Agent');
        $agent = (new AgentModel())->findByUserId($this->userId());
        if (!$agent) $this->redirect('/');

        if ($action === 'list' && $id) {
            // List a new crop on behalf of farmer ID = $id
            return $this->listCropForFarmer($agent, (int)$id);
        }

        // Default: page that asks them to select a farmer
        $farmers = (new AgentModel())->assignedFarmers($agent['agent_id']);
        $title = 'কৃষকের পক্ষে ফসল লিস্ট';
        $this->view('agent/crops/select-farmer', compact('title','farmers'));
    }

    private function listCropForFarmer($agent, $farmerId) {
        $agentModel = new AgentModel();
        if (!$agentModel->isFarmerAssigned($agent['agent_id'], $farmerId)) {
            Flash::set('danger', 'এই কৃষক আপনাকে এসাইন করা নেই।');
            $this->redirect('/agent/farmers');
        }
        $farmer = (new UserModel())->find($farmerId);

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $errors = [];
            $data = [
                'farmer_id'       => $farmerId,
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
            if (mb_strlen($data['crop_name']) < 2) $errors[] = 'ফসলের নাম দিন।';
            if ($data['category_id'] <= 0) $errors[] = 'ক্যাটাগরি নির্বাচন করুন।';
            if ($data['quantity'] <= 0) $errors[] = 'পরিমাণ ০ এর বেশি হতে হবে।';
            if ($data['price_per_unit'] <= 0) $errors[] = 'মূল্য ০ এর বেশি হতে হবে।';

            $uploaded = handle_image_uploads('images', 'crops', 5);
            foreach ($uploaded['errors'] as $err) $errors[] = $err;

            if (!$errors) {
                $data['images'] = $uploaded['files'];
                $cropId = (new CropModel())->create($data);
                $agentModel->logActivity($agent['agent_id'], $farmerId, 'crop_listing',
                    'ফসল লিস্ট: ' . $data['crop_name'] . ' (' . $data['quantity'] . ' ' . $data['unit'] . ')', 20.00);
                Flash::set('success', '✓ ফসল সফলভাবে লিস্ট করা হয়েছে। কমিশন: ৳২০।');
                $this->redirect('/agent/farmers/detail/' . $farmerId);
            }
            foreach ($errors as $err) Flash::set('danger', $err);
        }

        $pdo = (new Model())->pdo();
        $categories = $pdo->query("SELECT * FROM crop_categories ORDER BY category_id")->fetchAll();
        $title = $farmer['full_name'] . ' এর পক্ষে ফসল লিস্ট';
        $this->view('agent/crops/list-form', compact('title','farmer','categories'));
    }

    // ─────────────────────────────────────────────────────────────────
    // TICKETS
    // ─────────────────────────────────────────────────────────────────
    public function tickets($action = null, $id = null) {
        $this->requireRole('Agent');
        $agent = (new AgentModel())->findByUserId($this->userId());
        if (!$agent) $this->redirect('/');
        $ticketModel = new TicketModel();

        if ($action === 'detail' && $id) {
            $t = $ticketModel->find((int)$id);
            if (!$t) { Flash::set('danger', 'টিকেট পাওয়া যায়নি।'); $this->redirect('/agent/tickets'); }
            $title = 'টিকেট #' . $t['ticket_number'];
            $this->view('agent/tickets/detail', compact('title','t','agent'));
            return;
        }

        if ($action === 'claim' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $ticketModel->assign((int)$id, $agent['agent_id']);
            Flash::set('success', 'টিকেট গ্রহণ করা হয়েছে।');
            $this->redirect('/agent/tickets/detail/' . (int)$id);
        }

        if ($action === 'update' && $id && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $newStatus = $_POST['new_status'] ?? '';
            $notes = clean_str($_POST['resolution_notes'] ?? '', 1000);
            if (in_array($newStatus, ['open','in_progress','resolved','closed','cancelled'], true)) {
                $ticketModel->updateStatus((int)$id, $newStatus, $notes, $this->userId());
                if ($newStatus === 'resolved') {
                    (new AgentModel())->logActivity($agent['agent_id'], null, 'message_help', 'টিকেট সমাধান', 10.00);
                }
                Flash::set('success', 'টিকেট আপডেট হয়েছে।');
            }
            $this->redirect('/agent/tickets/detail/' . (int)$id);
        }

        $statusFilter = $_GET['status'] ?? null;
        $tab = $_GET['tab'] ?? 'mine';
        if ($tab === 'queue') {
            $tickets = $ticketModel->listUnassigned();
        } else {
            $tickets = $ticketModel->listForAgent($agent['agent_id'], $statusFilter);
        }
        $stats = $ticketModel->statsForAgent($agent['agent_id']);

        $title = 'সাপোর্ট টিকেট | AgroFin';
        $this->view('agent/tickets/index', compact('title','tickets','statusFilter','tab','stats'));
    }

    // ─────────────────────────────────────────────────────────────────
    // EARNINGS (commission)
    // ─────────────────────────────────────────────────────────────────
    public function earnings() {
        $this->requireRole('Agent');
        $agent = (new AgentModel())->findByUserId($this->userId());
        if (!$agent) $this->redirect('/');
        $agentModel = new AgentModel();
        $summary = $agentModel->commissionSummary($agent['agent_id']);
        $filter = $_GET['type'] ?? null;
        $activities = $agentModel->activities($agent['agent_id'], 200, $filter);

        $title = 'কমিশন ও আয় | AgroFin';
        $this->view('agent/earnings', compact('title','agent','summary','activities','filter'));
    }

    // ─────────────────────────────────────────────────────────────────
    // MESSAGES (inherited)
    // ─────────────────────────────────────────────────────────────────
    public function messages($action = null, $partnerId = null) {
        $this->requireRole('Agent');
        return $this->_messagesShared($action, $partnerId);
    }
}
