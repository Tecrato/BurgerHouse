<?php

require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Bitacora;

function bitacora_view()
{
    view('binnacle');
}
function bitacora_get_all(...$args) {
    get_all(new Bitacora(), ...$args);
}
function bitacora_add(...$args) {
    add(new Bitacora(), [
        'id_usuario' => $_SESSION['id'],
        'tabla' => $_POST['tabla'],
        'accion' => $_POST['accion'],
        'descripcion' => $_POST['descripcion']
    ]);
}

function bitacora_update(...$args) {
    $modelo = new Bitacora();
    $modelo->actualizar($_SESSION['id']);
}