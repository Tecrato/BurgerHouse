<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Paquetes_mesa;

function paquete_mesa_view(...$args)
{
    view('paaquete_reservacion');
}

function paquete_mesa_get_all(...$args)
{
    get_all(new Paquetes_mesa(), ...$args);
}

function paquete_mesa_add(...$args)
{
    add(new Paquetes_mesa(), $_POST);
}

function paquete_mesa_update(...$args)
{
    update(new Paquetes_mesa(), $_POST);
}

function paquete_mesa_delete(...$args)
{
    delete(new Paquetes_mesa(), $_POST['id']);
}


