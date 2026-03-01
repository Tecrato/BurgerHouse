<?php


use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Usuario;
use Shtch\Burgerhouse\models\Rol;


function login_view(...$args)
{
    view('login');
}

function login_get_all(...$args)
{
    $modelo = new Usuario();
    get_all($modelo, ...$args);
}

function login_sessionInfo(...$args) {
    echo json_encode([
        "success" => true,
        "message" => [
            "id" => $_SESSION['id'] ?? null,
            "nombre" => $_SESSION['nombre'] ?? null,
            "apellido" => $_SESSION['apellido'] ?? null,
            "correo" => $_SESSION['correo'] ?? null,
            "rol" => $_SESSION['rol'] ?? null,
            "permisos" => $_SESSION['permisos'] ?? []
        ]
    ]);
}
function login_login(...$args)
{
    $usuario = new Usuario(email: $_POST['email']);
    $result = $usuario->search();

    if (empty($result) || !isset($result[0]['hash'])) {
        echo json_encode(['success' => false, 'message' => 'Usuario o contraseña incorrectos']);
    } else {
        $password = $_POST['password'] ?? '';
        $storedHash = $result[0]['hash'];
        $isValidPassword = password_verify($password, $storedHash);

        // compatibilidad temporal para usuarios viejos en texto plano
        if (!$isValidPassword && hash_equals((string)$storedHash, (string)$password)) {
            $isValidPassword = true;
            $rehashUser = new Usuario(id: $result[0]['id'], hash: password_hash($password, PASSWORD_DEFAULT));
            $rehashUser->actualizar();
        }

        if (!$isValidPassword) {
            echo json_encode(['success' => false, 'message' => 'Usuario o contraseña incorrectos']);
            return;
        }

        $session_id = substr(str_shuffle('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'), 0, 10);
        $us = new Usuario(id: $result[0]['id'], session_id: $session_id);
        $us->actualizar();
        echo json_encode(['success' => true, 'message' => 'Usuario encontrado']);
        $rol = new Rol(id: $result[0]['rol_id']);
        $permisos = $rol->obtener_permisos();
        $_SESSION['permisos'] = $permisos;
        $_SESSION['id'] = $result[0]['id'];
        $_SESSION['id_rol'] = $result[0]['rol_id'];
        $_SESSION['rol'] = $result[0]['rol'];
        $_SESSION['nombre'] = $result[0]['nombre'];
        $_SESSION['apellido'] = $result[0]['apellido'];
        $_SESSION['correo'] = $result[0]['email'];
        $_SESSION['session_id'] = $session_id;
        $_SESSION['imagen'] = $result[0]['imagen'];
    }
}

function login_logout(...$args)
{
    session_destroy();
    echo json_encode(['success' => true, 'message' => 'Sesión cerrada']);
}

function login_cedula(...$args)
{
    define('APPID_CEDULA', '1033');
    define('TOKEN_CEDULA', '2e40fcab6d2f933e63fa9be82cdbd1be');
    function getCurlData($url)
    {
        $curl = curl_init();
        curl_setopt($curl, CURLOPT_URL, $url);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($curl, CURLOPT_TIMEOUT, 10);
        $curlData = curl_exec($curl);
        curl_close($curl);
        return $curlData;
    }
    function getCI($cedula, $return_raw = false)
    {
        $cedula = $_POST['cedula'];
        $res = getCurlData("https://api.cedula.com.ve/api/v1?app_id=" . APPID_CEDULA . "&token=" . TOKEN_CEDULA . "&cedula=" . (int)$cedula);
        if ($return_raw)
            return strlen($res) > 3 ? $res : false;
        $res = json_decode($res, true);
        return isset($res['data']) && $res['data'] ? $res['data'] : $res['error_str'];
    }
    $consulta = getCI(00000);
    if (is_array($consulta)) {
        echo json_encode(['success' => true, 'message' => $consulta]);
    } else {
        echo json_encode(['success' => false, 'message' => $consulta]);
    }
}
