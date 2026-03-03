<?php
use Shtch\Burgerhouse\models\Usuario;
use Shtch\Burgerhouse\models\Rol;
use Shtch\Burgerhouse\function\AuthSession;

$session = new AuthSession();
$resultado_final = '';

// if (!$session->usuario) {
//     make_url_error("No estás autenticado. Redirigiendo a login...", 401);
// }

// if (!$session->is_admin()) {
//     make_url_error("No tienes permiso para acceder a este recurso.", 403);
// }

if (count($url) < 2) {
    include_once __DIR__ . '/../views/V_login.php';
    exit;
} else {

if ($url[1] === 'get_all') {
    if (!$session->usuario) {
        make_url_error("No tienes permiso para acceder a este recurso.", 401);
    }
    $resultado_final = $moduleModel->search(...$parametros_paginacion);
} else if ($url[1] === 'login') {
    $email = trim((string)($_POST['email'] ?? ''));
    $password = (string)($_POST['password'] ?? '');
    $captchaToken = trim((string)($_POST['token'] ?? ''));
    $captchaBypass = (bool)($GLOBALS['turnstile']['bypass'] ?? false);

    if ($email === '' || $password === '') {
        make_url_error("Debes ingresar correo y contraseña.", 401);
    }

    if (!$captchaBypass && !login_verify_turnstile($captchaToken)['success']) {
        make_url_error($captchaValidation['message'], 401);
    }

    $usuario = new Usuario(email: $email);
    $result = $usuario->search();

    if (empty($result) || !isset($result[0]['hash'])) {
        $resultado_final = ['success' => false, 'message' => 'Usuario o contraseña incorrectos', 'resetCaptcha' => true];
        make_url_error("Usuario o contraseña incorrectos", 400);
    }

    $storedHash = $result[0]['hash'];
    $isValidPassword = password_verify($password, $storedHash);

    // compatibilidad temporal para usuarios viejos en texto plano
    if (!$isValidPassword && hash_equals((string)$storedHash, (string)$password)) {
        $isValidPassword = true;
        $rehashUser = new Usuario(id: $result[0]['id'], hash: password_hash($password, PASSWORD_DEFAULT));
        $rehashUser->actualizar();
    }

    if (!$isValidPassword) {
        $resultado_final = ['success' => false, 'message' => 'Usuario o contraseña incorrectos', 'resetCaptcha' => true];
        make_url_error("Usuario o contraseña incorrectos", 400);
    }

    $session_id = substr(str_shuffle('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'), 0, 10);
    $us = new Usuario(id: $result[0]['id'], session_id: $session_id);
    $us->actualizar();

    $rol = new Rol(id: $result[0]['id_rol']);
    $permisos = $rol->obtener_permisos();
    $_SESSION['permisos'] = $permisos;
    $_SESSION['id'] = $result[0]['id'];
    $_SESSION['id_rol'] = $result[0]['id_rol'];
    $_SESSION['rol'] = $result[0]['rol'];
    $_SESSION['nombre'] = $result[0]['nombre'];
    $_SESSION['apellido'] = $result[0]['apellido'];
    $_SESSION['correo'] = $result[0]['email'];
    $_SESSION['session_id'] = $session_id;
    $_SESSION['imagen'] = $result[0]['imagen'];

    $ajax = true;

    $resultado_final = ['success' => true, 'message' => 'Usuario encontrado'];
} else if ($url[1] === 'logout') {
    session_destroy();
    $resultado_final = ['success' => true, 'message' => 'Sesión cerrada'];
} else if ($url[1] === 'cedula') {
    if (!$session->usuario) {
        make_url_error("No tienes permiso para acceder a este recurso.", 401);
    }
    $consulta = obtener_persona_cedula($_POST['cedula']);
    if (is_array($consulta)) {
        $resultado_final = ['success' => true, 'message' => $consulta];
    } else {
        make_url_error($consulta, 500);
    }
} else if ($url[1] === 'SessionInfo') {
    if (!$session->usuario) {
        make_url_error("No tienes permiso para acceder a este recurso.", 401);
    }
    $resultado_final = [
        'success' => true,
        'message' => [
            'id' => isset($_SESSION['id']) ? $_SESSION['id'] : null,
            'nombre' => isset($_SESSION['nombre']) ? $_SESSION['nombre'] : null,
            'apellido' => isset($_SESSION['apellido']) ? $_SESSION['apellido'] : null,
            'correo' => isset($_SESSION['correo']) ? $_SESSION['correo'] : null,
            'rol' => isset($_SESSION['rol']) ? $_SESSION['rol'] : null,
            'permisos' => isset($_SESSION['permisos']) ? $_SESSION['permisos'] : []
        ]
    ];
    $ajax = true;
}

}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    $resultado_final = json_encode($resultado_final);
}

print_r($resultado_final);