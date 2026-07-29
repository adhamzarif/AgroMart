<?php
require_once 'core/Controller.php';

class FeaturesController extends Controller {
    public function index() {
        $this->view('features/index');
    }
}
