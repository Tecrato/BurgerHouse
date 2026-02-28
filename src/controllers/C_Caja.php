<?php
use Shtch\Burgerhouse\models\Caja;
require_once __DIR__ . '/Controller_base.php';


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