<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Paquetes;

function paquete_reservacion_view(...$args)
{
    view('paquete_reservacion');
}

function paquete_reservacion_get_all(...$args)
{
    get_all(new Paquetes(), ...$args);
}

function paquete_reservacion_add(...$args)
{
    add(new Paquetes(), $_POST);
}

function paquete_reservacion_update(...$args)
{
    update(new Paquetes(), $_POST);
}

function paquete_reservacion_delete(...$args)
{
    delete(new Paquetes(), $_POST['id']);
}


