<?php
/**
 * Lightweight front-controller router.
 * URL pattern: /Controller/method/param1/param2...
 * Dashes in URL segments are converted to camelCase (e.g. live-price -> LivePrice).
 */
class Router {
    protected $controller = 'HomeController';
    protected $method     = 'index';
    protected $params     = [];

    public function __construct() {
        $url = $this->parseUrl();

        if (isset($url[0]) && $url[0] !== '') {
            $controllerName = str_replace('-', '', ucwords($url[0], '-')) . 'Controller';
            $cf = BASE_PATH . '/Controllers/' . $controllerName . '.php';
            if (file_exists($cf)) {
                $this->controller = $controllerName;
                unset($url[0]);
            } else {
                http_response_code(404);
                // Fallback: render not-found via HomeController
                $this->controller = 'HomeController';
                $this->method     = 'notFound';
                $this->params     = [];
                return;
            }
        }

        require_once BASE_PATH . '/Controllers/' . $this->controller . '.php';
        $this->controller = new $this->controller;

        if (isset($url[1]) && $url[1] !== '') {
            $methodName = lcfirst(str_replace('-', '', ucwords($url[1], '-')));
            if (method_exists($this->controller, $methodName)) {
                $this->method = $methodName;
                unset($url[1]);
            } else {
                http_response_code(404);
                if (method_exists($this->controller, 'notFound')) {
                    $this->method = 'notFound';
                } else {
                    $this->method = 'index';
                }
            }
        }

        $this->params = $url ? array_values($url) : [];
    }

    public function dispatch() {
        call_user_func_array([$this->controller, $this->method], $this->params);
    }

    private function parseUrl() {
        if (isset($_GET['url'])) {
            return explode('/', filter_var(rtrim($_GET['url'], '/'), FILTER_SANITIZE_URL));
        }
        return [];
    }
}
