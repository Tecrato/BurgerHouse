<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Paquetes;

function paquete_reservacion_view(...$args)
{
    view('package_reservation');
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


