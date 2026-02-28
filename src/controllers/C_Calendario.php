<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Reservacion;

function calendario_view(...$args)
{
    view('calendar');
}

function calendario_get_all(...$args)
{
    get_all(new Reservacion(), ...$args);
}

function calendario_add(...$args)
{
    add(new Reservacion(), $_POST);
}

function calendario_update(...$args)
{
    update(new Reservacion(), $_POST);
}

function calendario_delete(...$args)
{
    delete(new Reservacion(), $_POST['id']);
}


