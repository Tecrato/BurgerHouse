<?php


use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Metodo_pago;


function metodos_de_pago_view(...$args)
{
    view('metodos_de_pago');
}

function metodos_de_pago_get_all(...$args)
{
    $modelo = new Metodo_pago();
    get_all($modelo, ...$args);
}
