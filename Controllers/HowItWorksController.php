<?php
class HowItWorksController extends Controller {
    public function index() {
        $title = "কীভাবে কাজ করে | AgroFin";
        $this->view('how_it_works/index', compact('title'));
    }
}
