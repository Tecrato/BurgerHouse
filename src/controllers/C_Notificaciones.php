<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Notificacion;


function notificaciones_view(...$args)
{
    view('notificaciones');
}

function notificaciones_get_all(...$args)
{
    $modelo = new Notificacion();
    get_all($modelo, ...$args);
}