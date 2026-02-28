<?php
    require_once __DIR__ . '/../vendor/autoload.php';
    require_once __DIR__ . '/../src/config/config.php';
    use Shtch\Burgerhouse\models\Usuario;


    function parseUrl()
    {
        $uri = $_SERVER['REQUEST_URI'];
        $uri = parse_url($uri, PHP_URL_PATH);
        $uri = str_replace('/BurgerHouse', '', $uri);
        return explode('/', filter_var(trim($uri, '/'), FILTER_SANITIZE_URL));
    }

    // ensure the current request is authenticated.  redirect to login if not.
    // bypasses a small whitelist of public modules.
    function ensureAuthenticated(string $module): void
    {
        // modules that anyone can visit without being logged in
        $public = ['login','recover_password','index','web'];
        if (in_array(strtolower($module), $public, true)) {
            return;
        }

        if (empty($_SESSION['id']) || empty($_SESSION['session_id'])) {
            header('Location: login');
            exit;
        }

        // verify session id against database
        $usuario = new Usuario(id: $_SESSION['id']);
        $result = $usuario->search();
        if (empty($result) || $result[0]['session_id'] !== $_SESSION['session_id']) {
            session_destroy();
            header('Location: login');
            exit;
        }
    }


    session_start();
    $url = parseUrl();
    // previous controller code expected a $usuario array but we now
    // reference $_SESSION directly, so we no longer need to build this.

    // authentication check: redirect to login unless request is for a public page
    $module = !empty($url[0]) ? strtolower($url[0]) : 'index';
    ensureAuthenticated($module);

    //validar si la url es un archivo de media
    if (strpos($url[0], 'media') === 0) {
        $filePath = '../src/' . implode('/', $url);
        if (file_exists($filePath)) {
            header('Content-Type: ' . mime_content_type($filePath));
            readfile($filePath);
            exit;
        } else {
            header('HTTP/1.0 404 Not Found');
            echo "Archivo no encontrado.";
            exit;
        }
    }

    // determine module and action from url
    $action = isset($url[1]) ? strtolower($url[1]) : 'view';

    // load corresponding controller file (procedural version)
    $controllerFile = __DIR__ . '/../src/controllers/C_' . ucfirst($module) . '.php';
    if (file_exists($controllerFile)) {
        include_once $controllerFile;
    } else {
        // missing controller -> fallback to error
        include_once __DIR__ . '/../src/controllers/C_Error404.php';
        $module = 'error404';
        $action = 'view';
    }

    // construct function name using convention: module_action
    $func = $module . '_' . $action;
    if (!function_exists($func)) {
        // last resort: error page
        if (!function_exists('error404_view')) {
            include_once __DIR__ . '/../src/controllers/C_Error404.php';
        }
        $func = 'error404_view';
    }

    // invoke the procedural handler
    $func(...array_slice($url, 2), ...$_GET);
