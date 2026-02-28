<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
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

function calendario_add_many(...$args)
{
    add_many(new Reservacion(), $_POST);
}

function calendario_update(...$args)
{
    update(new Reservacion(), $_POST);
}

function calendario_update_many(...$args)
{
    update_many(new Reservacion(), $_POST);
}

function calendario_delete(...$args)
{
    delete(new Reservacion(), $_POST['id']);
}

function calendario_delete_many(...$args)
{
    delete_many(new Reservacion(), $_POST['ids']);
}

function calendario_check(...$args)
{
    check(new Reservacion(), $_POST['id']);
}

function calendario_total(...$args)
{
    total(new Reservacion());
}
