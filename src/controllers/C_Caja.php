<?php
use Shtch\Burgerhouse\models\Caja;
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};


function caja_view()
{
    view('cash');
}
function caja_get_all(...$args) {
    get_all(new Caja(), ...$args);
}
function caja_detailCash(...$args)
{
    $modelo = new Caja();
    $modelo->cajaDetails($_SESSION['id']);
}

function caja_add(...$args)
{
    add(new Caja(), $_POST);
}
function caja_add_many(...$args)
{
    add_many(new Caja(), $_POST['lista']);
}
function caja_update(...$args)
{
    update(new Caja(), $_POST);
}

function caja_closeCash(...$args)
{
    try {
        $id = $_POST['id'];
        $modelo = new Caja();
        $modelo->closeCash($id);
        echo json_encode(['success' => true]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}