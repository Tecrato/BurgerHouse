<?php


require_once __DIR__ . '/Controller_base.php';
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
