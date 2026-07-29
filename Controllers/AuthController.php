<?php
/**
 * AuthController — login, register, logout, role switching.
 * Real DB-backed authentication with password hashing and CSRF protection.
 */
class AuthController extends Controller {

    /** GET shows login form, POST processes it. */
    public function login() {
        if (!empty($_SESSION['user_id'])) {
            $this->redirectToDashboard();
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $identifier = clean_str($_POST['identifier'] ?? '', 100);
            $password   = $_POST['password'] ?? '';

            if ($identifier === '' || $password === '') {
                Flash::set('danger', 'মোবাইল নম্বর/ইমেইল এবং পাসওয়ার্ড দুটোই দিতে হবে।');
                $this->redirect('/auth/login');
            }

            // Rate limit: by IP (10/15min) and by identifier (5/15min)
            // Two separate limits so a single attacker can't lock out a real user
            $ip = RateLimit::clientIp();
            $ipCheck = RateLimit::check('login:ip:' . $ip, 10, 900);
            if (!$ipCheck['ok']) {
                Flash::set('danger', 'অনেকবার চেষ্টা হয়েছে এই IP থেকে। ' . RateLimit::formatRetry($ipCheck['retry_after']) . ' পরে চেষ্টা করুন।');
                $this->redirect('/auth/login');
            }
            $idCheck = RateLimit::check('login:user:' . md5(strtolower($identifier)), 5, 900);
            if (!$idCheck['ok']) {
                Flash::set('danger', 'এই অ্যাকাউন্টে অনেকবার ভুল চেষ্টা — ' . RateLimit::formatRetry($idCheck['retry_after']) . ' পরে চেষ্টা করুন।');
                $this->redirect('/auth/login');
            }

            $userModel = new UserModel();
            $user = $userModel->authenticate($identifier, $password);

            if ($user === null) {
                // Failed login — count both limits
                RateLimit::hit('login:ip:' . $ip, 900);
                RateLimit::hit('login:user:' . md5(strtolower($identifier)), 900);
                Flash::set('danger', 'ভুল মোবাইল/ইমেইল অথবা পাসওয়ার্ড।');
                $this->redirect('/auth/login');
            }
            if (isset($user['__blocked'])) {
                Flash::set('danger', 'আপনার অ্যাকাউন্ট ' . ($user['__blocked'] === 'banned' ? 'নিষিদ্ধ' : 'সাময়িকভাবে স্থগিত') . ' করা হয়েছে। সহায়তার জন্য যোগাযোগ করুন।');
                $this->redirect('/auth/login');
            }

            // Successful login → clear the per-identifier counter so a slow typist
            // doesn't get locked out on the next session
            RateLimit::clear('login:user:' . md5(strtolower($identifier)));

            $this->establishSession($user, $userModel);
            Flash::set('success', 'স্বাগতম, ' . $user['full_name'] . '!');
            $this->redirectToDashboard();
        }

        $title = 'লগইন | AgroFin';
        $this->view('auth/login', compact('title'));
    }

    /** GET shows register form, POST processes it. */
    public function register() {
        if (!empty($_SESSION['user_id'])) {
            $this->redirectToDashboard();
        }

        $districtModel = new DistrictModel();
        $districts = $districtModel->all();

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();

            $fullName  = clean_str($_POST['full_name'] ?? '', 100);
            $phone     = clean_str($_POST['phone'] ?? '', 15);
            $email     = clean_str($_POST['email'] ?? '', 100);
            $password  = $_POST['password'] ?? '';
            $confirm   = $_POST['confirm_password'] ?? '';
            $districtId = (int)($_POST['district_id'] ?? 0);
            $address    = clean_str($_POST['address'] ?? '', 255);
            $nid        = clean_str($_POST['nid_number'] ?? '', 17);
            $roles      = $_POST['roles'] ?? [];
            if (!is_array($roles)) $roles = [$roles];

            // ── Validation ──
            $errors = [];
            if (mb_strlen($fullName) < 2)         $errors[] = 'পুরো নাম দিতে হবে।';
            if (!is_valid_phone($phone))          $errors[] = 'মোবাইল নম্বর সঠিক ফরম্যাটে দিন (01XXXXXXXXX)।';
            if ($email !== '' && !is_valid_email($email)) $errors[] = 'ইমেইল ঠিকানা সঠিক নয়।';
            if (strlen($password) < 6)            $errors[] = 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।';
            if ($password !== $confirm)           $errors[] = 'পাসওয়ার্ড ও পুনরায় পাসওয়ার্ড একই হতে হবে।';
            if ($districtId <= 0)                 $errors[] = 'জেলা নির্বাচন করুন।';
            if ($nid !== '' && !is_valid_nid($nid)) $errors[] = 'NID নম্বর সঠিক নয় (১০, ১৩ অথবা ১৭ ডিজিট)।';

            $allowedRoles = ['Farmer','Buyer','Agent'];
            $validRoles = array_values(array_intersect($allowedRoles, $roles));
            if (empty($validRoles)) $errors[] = 'কমপক্ষে একটি ভূমিকা নির্বাচন করুন।';
            // Agent role cannot combine with others (business rule)
            if (in_array('Agent', $validRoles, true) && count($validRoles) > 1) {
                $errors[] = 'এজেন্ট ভূমিকা অন্য কোনো ভূমিকার সাথে একত্রে নেওয়া যাবে না।';
            }
            if (in_array('Agent', $validRoles, true) && $nid === '') {
                $errors[] = 'এজেন্ট হিসেবে নিবন্ধন করতে NID নম্বর আবশ্যক।';
            }

            $userModel = new UserModel();
            if ($userModel->findByPhone($phone)) $errors[] = 'এই মোবাইল নম্বরে ইতোমধ্যে একটি অ্যাকাউন্ট আছে।';
            if ($email !== '' && $userModel->findByEmail($email)) $errors[] = 'এই ইমেইলে ইতোমধ্যে একটি অ্যাকাউন্ট আছে।';

            $district = $districtModel->find($districtId);
            if (!$district) $errors[] = 'অবৈধ জেলা।';

            if ($errors) {
                foreach ($errors as $err) Flash::set('danger', $err);
                $old = compact('fullName','phone','email','districtId','address','nid','roles');
                $title = 'রেজিস্টার | AgroFin';
                $this->view('auth/register', compact('title','districts','old'));
                return;
            }

            // ── OTP gate ──
            // If OTP verification is enabled (SMS_PROVIDER set), check that this phone
            // was verified within the last 10 minutes. Otherwise, send an OTP and show
            // the verify-otp page with all the form data stashed in session.
            $otpRequired = Env::get('SMS_PROVIDER', '') !== '' || Env::getBool('OTP_REQUIRED', true);
            if ($otpRequired) {
                // IP-level rate limit: max 5 OTP sends per IP per hour (to stop SMS spam)
                $ip = RateLimit::clientIp();
                $rl = RateLimit::check('otp:ip:' . $ip, 5, 3600);
                if (!$rl['ok']) {
                    Flash::set('danger', 'এই IP থেকে অনেকবার OTP রিকোয়েস্ট। ' . RateLimit::formatRetry($rl['retry_after']) . ' পরে চেষ্টা করুন।');
                    $this->redirect('/auth/register');
                }

                $otpModel = new OtpModel();
                if (!$otpModel->recentlyVerified($phone, 'register', 600)) {
                    // Stash the form data so we can complete registration after OTP verify
                    $_SESSION['pending_registration'] = [
                        'full_name'   => $fullName,
                        'phone'       => $phone,
                        'email'       => $email,
                        'password'    => $password,
                        'district_id' => $districtId,
                        'address'     => $address,
                        'nid'         => $nid,
                        'roles'       => $validRoles,
                        'expires_at'  => time() + 1800, // 30 minutes to complete
                    ];

                    // Trigger OTP send
                    $sendResult = $otpModel->send($phone, 'register');
                    if (!$sendResult['ok']) {
                        Flash::set('danger', $sendResult['error']);
                        $this->redirect('/auth/register');
                    }
                    // Count this send for IP rate limit
                    RateLimit::hit('otp:ip:' . $ip, 3600);
                    if (!empty($sendResult['dev_code'])) {
                        Flash::set('info', 'ডেভ মোড — OTP কোড: <strong>' . e($sendResult['dev_code']) . '</strong> (storage/logs/sms.log-এও আছে)');
                    } else {
                        Flash::set('success', 'OTP পাঠানো হয়েছে ' . e($phone) . ' নম্বরে। ৫ মিনিটের মধ্যে যাচাই করুন।');
                    }
                    $this->redirect('/auth/verify-otp');
                }
            }

            // ── OTP verified (or not required) — create user ──
            try {
                $userId = $userModel->create([
                    'full_name'   => $fullName,
                    'phone'       => $phone,
                    'email'       => $email !== '' ? $email : null,
                    'password'    => $password,
                    'nid_number'  => $nid !== '' ? $nid : null,
                    'district_id' => $districtId,
                    'address'     => $address,
                ], array_map('strtolower', $validRoles));
                // Mark as phone-verified since OTP passed
                if ($otpRequired) {
                    $this->markPhoneVerified($userId);
                }
            } catch (Throwable $e) {
                Flash::set('danger', 'অ্যাকাউন্ট তৈরি করতে সমস্যা হয়েছে: ' . $e->getMessage());
                $this->redirect('/auth/register');
            }

            // Clear stash
            unset($_SESSION['pending_registration']);

            // Auto-login
            $user = $userModel->find($userId);
            $this->establishSession($user, $userModel);
            Flash::set('success', 'অভিনন্দন, ' . $fullName . '! আপনার অ্যাকাউন্ট তৈরি হয়েছে।');
            $this->redirectToDashboard();
        }

        $title = 'রেজিস্টার | AgroFin';
        $old = [];
        $this->view('auth/register', compact('title','districts','old'));
    }

    /**
     * GET shows OTP verification form. POST verifies the code.
     * On success, completes the pending registration from session.
     */
    public function verifyOtp() {
        if (!empty($_SESSION['user_id'])) {
            $this->redirectToDashboard();
        }

        $pending = $_SESSION['pending_registration'] ?? null;
        if (!$pending || $pending['expires_at'] < time()) {
            unset($_SESSION['pending_registration']);
            Flash::set('warning', 'রেজিস্ট্রেশন সেশন মেয়াদ শেষ। আবার শুরু করুন।');
            $this->redirect('/auth/register');
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->requireCsrf();
            $action = $_POST['action'] ?? 'verify';
            $otpModel = new OtpModel();

            if ($action === 'resend') {
                $result = $otpModel->send($pending['phone'], 'register');
                if ($result['ok']) {
                    if (!empty($result['dev_code'])) {
                        Flash::set('info', 'নতুন OTP কোড (dev): <strong>' . e($result['dev_code']) . '</strong>');
                    } else {
                        Flash::set('success', 'নতুন OTP পাঠানো হয়েছে।');
                    }
                } else {
                    Flash::set('danger', $result['error']);
                }
                $this->redirect('/auth/verify-otp');
            }

            // Verify path
            $code = trim($_POST['otp_code'] ?? '');
            $result = $otpModel->verify($pending['phone'], $code);
            if (!$result['ok']) {
                Flash::set('danger', $result['error']);
                $this->redirect('/auth/verify-otp');
            }

            // OTP verified — finalize the registration
            $userModel = new UserModel();
            try {
                $userId = $userModel->create([
                    'full_name'   => $pending['full_name'],
                    'phone'       => $pending['phone'],
                    'email'       => $pending['email'] !== '' ? $pending['email'] : null,
                    'password'    => $pending['password'],
                    'nid_number'  => !empty($pending['nid']) ? $pending['nid'] : null,
                    'district_id' => $pending['district_id'],
                    'address'     => $pending['address'],
                ], array_map('strtolower', $pending['roles']));
                $this->markPhoneVerified($userId);
            } catch (Throwable $e) {
                Flash::set('danger', 'অ্যাকাউন্ট তৈরি করতে সমস্যা হয়েছে: ' . $e->getMessage());
                $this->redirect('/auth/register');
            }

            unset($_SESSION['pending_registration']);
            $user = $userModel->find($userId);
            $this->establishSession($user, $userModel);
            Flash::set('success', '✓ ফোন যাচাই সফল! আপনার অ্যাকাউন্ট তৈরি হয়েছে।');
            $this->redirectToDashboard();
        }

        $title = 'OTP যাচাই | AgroFin';
        $phone = $pending['phone'];
        $expiresAt = $pending['expires_at'];
        $this->view('auth/verify_otp', compact('title','phone','expiresAt'));
    }

    /** Mark a user's phone as OTP-verified. */
    private function markPhoneVerified($userId) {
        try {
            Database::getInstance()->getConnection()
                ->prepare("UPDATE users SET phone_verified = 1, otp_verified_at = NOW() WHERE user_id = ?")
                ->execute([$userId]);
        } catch (Throwable $e) {
            // Column may not exist if migration 004 not yet run — non-fatal
        }
    }

    /** Switch active role for dual-role users (Farmer + Buyer). */
    public function switchRole($newRole = null) {
        $this->requireLogin();
        $newRole = ucfirst(strtolower($newRole ?? ''));
        $available = $_SESSION['available_roles'] ?? [];
        if (in_array($newRole, $available, true)) {
            $_SESSION['active_role'] = $newRole;
            SessionGuard::regenerateAfterPrivilegeChange();
            Logger::info('Role switched', ['user_id' => $_SESSION['user_id'], 'new_role' => $newRole]);
            Flash::set('info', 'আপনি এখন ' . (role_labels()[$newRole] ?? $newRole) . ' মোডে আছেন।');
        }
        $this->redirectToDashboard();
    }

    public function logout() {
        $_SESSION = [];
        if (ini_get('session.use_cookies')) {
            $p = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000, $p['path'], $p['domain'], $p['secure'], $p['httponly']);
        }
        session_destroy();
        session_start(); // start a clean session so Flash can store the goodbye
        Flash::set('info', 'আপনি লগআউট হয়েছেন। আবার দেখা হবে!');
        $this->redirect('/');
    }

    // ─── Helpers ──────────────────────────────────────────────────────

    /** Populate $_SESSION from a user row. */
    private function establishSession($user, UserModel $userModel) {
        $roles = $userModel->getRoles($user['user_id']);
        $cRoles = array_map('canonical_role', $roles); // Farmer/Buyer/Agent/Admin
        // Determine primary "label" role and active role
        if (count($cRoles) === 1) {
            $role = $cRoles[0];
            $active = $cRoles[0];
        } else {
            // Multi-role: dual (Farmer+Buyer), or rare combos
            $set = array_flip($cRoles);
            if (isset($set['Farmer']) && isset($set['Buyer']) && count($cRoles) === 2) {
                $role = 'Dual';
                $active = 'Farmer';
            } else {
                // Just pick the first as primary
                $role = $cRoles[0];
                $active = $cRoles[0];
            }
        }
        SessionGuard::markLogin((int)$user['user_id']);
        $_SESSION['user_id']        = (int)$user['user_id'];
        $_SESSION['name']           = $user['full_name'];
        $_SESSION['phone']          = $user['phone'];
        $_SESSION['email']          = $user['email'];
        $_SESSION['profile_picture']= $user['profile_picture'];
        $_SESSION['role']           = $role;
        $_SESSION['active_role']    = $active;
        $_SESSION['available_roles']= $cRoles;
        $_SESSION['district_id']    = (int)$user['district_id'];
        $_SESSION['_created']       = time();
    }

    private function redirectToDashboard() {
        $active = $_SESSION['active_role'] ?? 'Farmer';
        $this->redirect('/' . strtolower($active) . '/dashboard');
    }
}
