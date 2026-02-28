<?php
// C_Adicionales.php will become a plain procedural controller.  it no longer
// uses a namespace so that its functions are global and visible from
// public/index.php.
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, delete, check};

use Shtch\Burgerhouse\models\ProductoPreparado as Adicional;


function adicionales_view()
{
    view('adicionales');
}

function adicionales_get_all(...$args)
{
    $modelo = new Adicional();
    get_all($modelo, ...$args);
}
function adicionales_add() {
    add(new Adicional(), $_POST);
}

function adicionales_add_many(...$args) {
    $adicionales = json_decode($_POST['adicionales'], true);
    foreach ($adicionales as $adicional) {
        add(new Adicional(), $adicional);
    }
}

function adicionales_update(...$args) {
    $modelo = new Adicional(...$_POST);
    $modelo->actualizar();
}

function adicionales_delete(...$args) {
    delete(new Adicional(), $_POST['id']);
}

function adicionales_check(...$args) {
    check();
}