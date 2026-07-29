<?php
class HomeController extends Controller {
    public function index() {
        if (!empty($_SESSION['user_id'])) {
            $active = $_SESSION['active_role'] ?? $_SESSION['role'] ?? 'Farmer';
            $this->redirect('/' . strtolower($active) . '/dashboard');
        }
        $title = 'AgroFin | Smart Agricultural Platform';
        $this->view('home', compact('title'));
    }

    public function notFound() {
        http_response_code(404);
        $title = 'পেজ পাওয়া যায়নি | AgroFin';
        $this->view('errors/404', compact('title'));
    }
}
