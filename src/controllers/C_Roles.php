<?php

require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Rol;



function roles_view()
{
    view('roles');
}
function roles_get_all(...$args) {
    get_all(new Rol(), ...$args);

}
function roles_add(...$args) {
    add(new Rol(), $_POST);
}
function roles_update(...$args) {
    $modelo = new Rol(...$_POST);
    $modelo->actualizar();
}
function obtener_permisos() {
    $id_rol = intval($_POST['id_rol']) ?? null;
    if ($id_rol) {
        $rol = new Rol(id: $id_rol);
        $permisos = $rol->obtener_permisos();
        header('Content-Type: application/json');
        echo json_encode($permisos);
    } else {
        header('Content-Type: application/json');
        echo json_encode(['error' => 'ID de rol no proporcionado']);
    }
}

function roles_check(...$args) {
    check();
}