<?php

namespace Shtch\Burgerhouse\function;
use Shtch\Burgerhouse\models\Usuario;
use Shtch\Burgerhouse\models\Rol;

class AuthSession
{
    public $usuario;
    public $permisos;
    public function __construct()
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        if (!isset($_SESSION['id'])) {
            $this->usuario = null;
            return;
        }
        $modelo = new Usuario(id: $_SESSION['id']);
        $result = $modelo->search()[0] ?? null;
        if (!$result) {
            session_destroy();
            $this->usuario = null;
            return;
        }
        if ($result['id_rol'] !== $_SESSION['id_rol']) {
            $this->permisos = [];
        } else {
            $modelo_rol = new Rol(id: $result['id_rol']);
            $this->permisos = $modelo_rol->obtener_permisos();
            $_SESSION['permisos'] = $this->permisos;
        }
        $this->usuario = $result;
        if ($this->usuario['session_id'] !== $_SESSION['session_id']) {
            session_destroy();
            $this->usuario = null;
        }
    }
    public function is_admin(): bool
    {
        return $this->usuario && $this->usuario['rol'] === 'Super Admin';
    }
    public function has_permission($modulo, $permiso) : bool
    {
        $modulo = strtolower($modulo);
        $permiso = strtolower($permiso);
        if (!$this->usuario) {
            return false;
        }
        if ($this->usuario['rol'] === 'Super Admin') {
            return true;
        }
        foreach ($this->permisos as $perm) {
            if ($perm['modulo'] === $modulo) {
                $permisosArray = array_map('trim', explode(',', $perm['permisos']));
                return in_array($permiso, $permisosArray, true);
            }
        }
        return false;
    }
}
