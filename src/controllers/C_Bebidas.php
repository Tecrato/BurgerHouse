<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Adicionales;

function drink_view(...$args)
{
    view('drink');
}

function drink_add(...$args)
{
    header('Content-Type: application/json');
    try {
        $db = new Adicionales();
        $db->clear();
        $db->__construct(...$_POST);
        drink_guardar_imagen($_POST['nombre'], 0);
        echo json_encode(['success' => true, 'last_id' => $db->agregar()]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function drink_add_many(...$args)
{
    try {
        for ($i = 0; $i < count($_POST['lista']); $i++) {
            drink_guardar_imagen($_POST['lista'][$i]['nombre'], $i);
            $db = new Adicionales();
            $db->__construct(...$_POST['lista'][$i]);
            $db->agregar();
        }
        echo json_encode(['success' => true]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function drink_update(...$args)
{
    header('Content-Type: application/json');
    try {
        $db = new Adicionales();
        $db->clear();
        $db->__construct(...$_POST);
        $result = $db->actualizar();
        if (isset($_FILES['imagen'])) {
            drink_guardar_imagen_single();
        }
        if ($result == false or $result == 0) {
            echo json_encode(['success' => false, 'message' => 'No se pudo actualizar el registro']);
        } else {
            echo json_encode(['success' => true]);
        }
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function drink_guardar_imagen($pre, $index)
{
    $imagen = $_FILES['lista'];
    move_uploaded_file($imagen['tmp_name'][$index]['imagen'], '../src/media/bebidas/' . $imagen['name'][$index]['imagen']);
}

function drink_guardar_imagen_single()
{
    $imagen = $_FILES['imagen'];
    move_uploaded_file($imagen['tmp_name'], '../src/media/bebidas/' . $imagen['name']);
}

function drink_get_all(...$args)
{
    get_all(new Adicionales(), ...$args);
}

function drink_check(...$args)
{
    check();
}

function drink_total(...$args)
{
    total(new Adicionales(), ...$args);
}


function bebidas_view(...$args) { return drink_view(...$args); }
function bebidas_add(...$args) { return drink_add(...$args); }
function bebidas_add_many(...$args) { return drink_add_many(...$args); }
function bebidas_update(...$args) { return drink_update(...$args); }
function bebidas_get_all(...$args) { return drink_get_all(...$args); }
function bebidas_check(...$args) { return drink_check(...$args); }
function bebidas_total(...$args) { return drink_total(...$args); }
