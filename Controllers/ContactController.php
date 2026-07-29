<?php
class ContactController extends Controller {
    public function index() {
        $title = "যোগাযোগ | AgroFin";
        $this->view('contact/index', compact('title'));
    }
}
