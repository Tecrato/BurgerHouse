<?php

use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
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