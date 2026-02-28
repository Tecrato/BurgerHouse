<?php

require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Permiso;



function permisos_view(...$args)
{
    view('permisos');
}
function permisos_get_all(...$args) {
    get_all(new Permiso(), ...$args);
}
function permisos_add(...$args) {
    add(new Permiso(), $_POST);
}