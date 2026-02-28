<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Paquetes_mesa;

function paquete_mesa_view(...$args)
{
    view('paquete_mesa');
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


