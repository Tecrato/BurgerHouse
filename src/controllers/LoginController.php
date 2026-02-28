<?php

namespace Shtch\Burgerhouse\controllers;

use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Permiso;
use Shtch\Burgerhouse\models\Usuario;
use Shtch\Burgerhouse\models\Rol;

class LoginController extends Controller_base
{
    public function __construct()
    {
        parent::__construct('login');
        // $this->db = new Usuario(nombre:$_POST['email'], hash:$_POST['password']);
    }
    public function login()
    {
        $this->db = new Usuario(email: $_POST['email'], hash: $_POST['password']);
        $result = $this->db->search();
        if (empty($result)) {
            echo json_encode(['success' => false, 'message' => 'Usuario o contraseña incorrectos']);
        } else {
            // $token = $_POST['token'];
            // $secretKey = '0x4AAAAAABDYzHAap8ofRwK1xEfj_e_rKz8';
            // $response = file_get_contents("https://challenges.cloudflare.com/turnstile/v0/siteverify", false, stream_context_create([
            //     'http' => [
            //         'method' => 'POST',
            //         'header' => "Content-Type: application/x-www-form-urlencoded\r\n",
            //         'content' => http_build_query(['secret' => $secretKey, 'response' => $token])
            //     ]
            // ]));
            // $resultado = json_decode($response, true);
            // if (!$resultado['success']) {
            //     echo json_encode(['success' => false, 'message' => 'Error de verificación de captcha']);
            // } else {
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
        // }
    }
    public function logout()
    {
        session_destroy();
        exit;
    }
    public function cedula()
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
    public function SessionInfo()
    {
        if (!isset($_SESSION)) {
            echo json_encode(['success' => false, 'message' => 'Sesion no iniciada']);
        } else {
            echo json_encode(['success' => true, 'message' => $_SESSION]);
        }
    }
    public function UpdateSession()
    {
        // if (isset($_POST['imagen_name'])) {
        //     $imagen = $_POST['imagen_name'];
        //     $_SESSION['imagen'] = $imagen;
        // } else if (isset($_POST['nombre']) && isset($_POST['apellido']) && isset($_POST['email'])) {
        //     $nombre = $_POST['nombre'];
        //     $apellido = $_POST['apellido'];
        //     $correo = $_POST['email'];
        //     $_SESSION['nombre'] = $nombre;
        //     $_SESSION['apellido'] = $apellido;
        //     $_SESSION['correo'] = $correo;
        // } else {
        //     $permisos = $_POST['permisos'];
        //     $_SESSION['permisos'] = $permisos;
        // }
    }
}