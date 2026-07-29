<?php
/**
 * ProfileController — view & edit own profile (all roles).
 */
class ProfileController extends Controller {

    public function index() {
        $this->requireLogin();
        $userModel = new UserModel();
        $user = $userModel->find($this->userId());
        if (!$user) {
            session_destroy();
            $this->redirect('/auth/login');
        }
        $districts = (new DistrictModel())->all();
        $roles = $userModel->getRoles($user['user_id']);
        $title = 'প্রোফাইল | AgroFin';
        $this->view('profile/index', compact('title','user','districts','roles'));
    }

    public function update() {
        $this->requireLogin();
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') $this->redirect('/profile');
        $this->requireCsrf();

        $userId = $this->userId();
        $fullName  = clean_str($_POST['full_name'] ?? '', 100);
        $email     = clean_str($_POST['email'] ?? '', 100);
        $address   = clean_str($_POST['address'] ?? '', 255);
        $districtId= (int)($_POST['district_id'] ?? 0);

        $errors = [];
        if (mb_strlen($fullName) < 2) $errors[] = 'পুরো নাম দিতে হবে।';
        if ($email !== '' && !is_valid_email($email)) $errors[] = 'ইমেইল ঠিকানা সঠিক নয়।';
        if ($districtId <= 0) $errors[] = 'জেলা নির্বাচন করুন।';

        $userModel = new UserModel();
        if ($email !== '') {
            $other = $userModel->findByEmail($email);
            if ($other && (int)$other['user_id'] !== $userId) {
                $errors[] = 'এই ইমেইল ইতোমধ্যে অন্য একটি অ্যাকাউন্টে ব্যবহৃত হচ্ছে।';
            }
        }

        // Handle profile picture upload
        $newPic = null;
        if (!empty($_FILES['profile_picture']['name'])) {
            $f = $_FILES['profile_picture'];
            if ($f['error'] === UPLOAD_ERR_OK) {
                if ($f['size'] > 2 * 1024 * 1024) {
                    $errors[] = 'প্রোফাইল ছবি ২ মেগাবাইটের বেশি হতে পারবে না।';
                } else {
                    $info = @getimagesize($f['tmp_name']);
                    if (!$info || !in_array($info['mime'], ['image/jpeg','image/png','image/webp'], true)) {
                        $errors[] = 'শুধু JPG, PNG অথবা WEBP ছবি আপলোড করুন।';
                    } else {
                        $ext = ['image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp'][$info['mime']];
                        $newPic = 'u' . $userId . '_' . time() . '.' . $ext;
                        $dest = UPLOAD_PATH . '/profiles/' . $newPic;
                        if (!@move_uploaded_file($f['tmp_name'], $dest)) {
                            $errors[] = 'ছবি সংরক্ষণে সমস্যা হয়েছে।';
                            $newPic = null;
                        }
                    }
                }
            } elseif ($f['error'] !== UPLOAD_ERR_NO_FILE) {
                $errors[] = 'ছবি আপলোডে সমস্যা হয়েছে।';
            }
        }

        if ($errors) {
            foreach ($errors as $err) Flash::set('danger', $err);
            $this->redirect('/profile');
        }

        $fields = [
            'full_name'  => $fullName,
            'email'      => $email !== '' ? $email : null,
            'address'    => $address,
            'district_id'=> $districtId,
        ];
        if ($newPic) $fields['profile_picture'] = $newPic;

        try {
            $userModel->updateProfile($userId, $fields);
            // Refresh session
            $_SESSION['name'] = $fullName;
            $_SESSION['email'] = $fields['email'];
            $_SESSION['district_id'] = $districtId;
            if ($newPic) $_SESSION['profile_picture'] = $newPic;
            Flash::set('success', 'প্রোফাইল সফলভাবে আপডেট হয়েছে।');
        } catch (Throwable $e) {
            Flash::set('danger', 'আপডেট করতে সমস্যা হয়েছে: ' . $e->getMessage());
        }
        $this->redirect('/profile');
    }

    public function changePassword() {
        $this->requireLogin();
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') $this->redirect('/profile');
        $this->requireCsrf();

        $userId = $this->userId();
        $current = $_POST['current_password'] ?? '';
        $new = $_POST['new_password'] ?? '';
        $confirm = $_POST['confirm_password'] ?? '';

        $errors = [];
        if (strlen($new) < 6) $errors[] = 'নতুন পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।';
        if ($new !== $confirm) $errors[] = 'নতুন পাসওয়ার্ড দুইবার একই হতে হবে।';

        $userModel = new UserModel();
        $user = $userModel->find($userId);
        if (!$user || !password_verify($current, $user['password_hash'])) {
            $errors[] = 'বর্তমান পাসওয়ার্ড সঠিক নয়।';
        }
        if ($errors) {
            foreach ($errors as $err) Flash::set('danger', $err);
            $this->redirect('/profile');
        }
        $userModel->changePassword($userId, $new);
        Flash::set('success', 'পাসওয়ার্ড সফলভাবে পরিবর্তন হয়েছে।');
        $this->redirect('/profile');
    }

    public function settings() {
        $this->redirect('/profile');
    }
}
