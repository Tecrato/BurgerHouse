<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
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