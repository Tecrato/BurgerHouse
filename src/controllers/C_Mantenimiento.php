<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Backup;
use Shtch\Burgerhouse\models\Usuario;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/mantenimiento.php')) {
        include_once __DIR__ . '/../views/mantenimiento.php';
    } else {
        make_url_error("No se encontró la vista mantenimiento.php", 404);
    }
    exit;
}

if ($url[1] === 'export') {
    if (!$session->has_permission('mantenimiento', 'agregar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $backup = new Backup();
        $backup->respaldo($_POST['db'], $_POST['route']);
        $resultado_final = ['success' => true, 'message' => 'Backup creado exitosamente'];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'import') {
    if (!$session->has_permission('mantenimiento', 'agregar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $usuario = new Usuario();
        $usuario->clear();
        $usuario->__construct(id: $_POST['id']);
        $result = $usuario->search();

        $storedHash = $result[0]['hash'] ?? '';
        $inputPassword = $_POST['password'] ?? '';
        $validPassword = password_verify($inputPassword, $storedHash) || hash_equals((string)$storedHash, (string)$inputPassword);

        if ($validPassword) {
            $backup = new Backup();
            $backup->restaurar($_POST['db'], $_POST['route'], $_POST['archive']);
            $resultado_final = ['success' => true, 'message' => 'Restauración completada'];
        } else {
            make_url_error("Contraseña incorrecta", 401, ajax: true);
        }
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'search') {
    if (!$session->has_permission('mantenimiento', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $backup = new Backup();
        $resultado_final = $backup->search($_POST['route']);
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'delete') {
    if (!$session->has_permission('mantenimiento', 'eliminar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $usuario = new Usuario();
        $usuario->clear();
        $usuario->__construct(id: $_POST['id']);
        $result = $usuario->search();

        $storedHash = $result[0]['hash'] ?? '';
        $inputPassword = $_POST['password'] ?? '';
        $validPassword = password_verify($inputPassword, $storedHash) || hash_equals((string)$storedHash, (string)$inputPassword);

        if ($validPassword) {
            $backup = new Backup();
            $backup->delete($_POST['route'], $_POST['archive']);
            $resultado_final = ['success' => true, 'message' => 'Archivo eliminado'];
        } else {
            make_url_error("Contraseña incorrecta", 401, ajax: true);
        }
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else {
    make_url_error("Accion no valida para mantenimiento.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
