<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Materia_prima;

function materiaprima_view(...$args)
{
    view('rawmaterial');
}

function materiaprima_get_all(...$args)
{
    get_all(new Materia_prima(), ...$args);
}

function materiaprima_add(...$args)
{
    add(new Materia_prima(), $_POST);
}

function materiaprima_update(...$args)
{
    update(new Materia_prima(), $_POST);
}

function materiaprima_delete(...$args)
{
    delete(new Materia_prima(), $_POST['id']);
}


