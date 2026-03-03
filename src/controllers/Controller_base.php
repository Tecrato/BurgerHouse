<?php

// global helper accessible from public/index.php and from any procedural
// controller.  it must reside *before* the namespace declaration so that
// it lives in the root namespace rather than in
// Shtch\Burgerhouse\controllers.
namespace Shtch\Burgerhouse\controllers;
use Exception;

function view($module_name)
{
    $candidates = [
        __DIR__ . '/../views/V_' . $module_name . '.php',
        __DIR__ . '/../views/' . $module_name . '.php',
    ];

    foreach ($candidates as $file) {
        if (file_exists($file)) {
            include_once $file;
            return;
        }
    }

    throw new Exception('Vista no encontrada: ' . $module_name);
}
function get_all($modelo, ...$args)
{
    // $modelo->get_all(...$args);
    header('Content-Type: application/json');
    try {
        $modelo->clear();
        $modelo->__construct(...$_POST);
        echo json_encode($modelo->search(...$args));
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage(), 'post' => $_POST, 'args' => $args, 'get' => $_GET]);
    }
}

function add($modelo, $args = [])
{
    header('Content-Type: application/json');
    try {
        $modelo->clear();
        $modelo->__construct(...$args);
        if (isset($_FILES['imagen'])) {
            guardar_imagen_single(get_called_class($modelo));
        }
        $id = $modelo->agregar();
        echo json_encode(['success' => true, 'last_id' => $id]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function add_many($modelo, $args = [])
{
    try {
        for ($i = 0; $i < count($_POST['lista']); $i++) {
            $modelo->__construct(...$_POST['lista'][$i]);
            if (isset($_FILES['lista'])) {
                guardar_imagen_mult($i, get_called_class($modelo));
            }
            $modelo->agregar();
        }
        echo json_encode(['success' => true]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function update($modelo, $args = [])
{
    header('Content-Type: application/json');
    try {
        $modelo->clear();
        $modelo->__construct(...$args);
        $result = $modelo->actualizar();
        if (isset($_FILES['imagen'])) {
            guardar_imagen_single($modelo->module_name);
        }
        if ($result == false or $result == 0) {
            header("HTTP/1.0 500 Internal Server Error");
            echo json_encode(['success' => false, 'message' => 'No se pudo actualizar el registro']);
        } else {
            echo json_encode(['success' => true]);
        }
    } catch (Exception $e) {
        header("HTTP/1.0 500 Internal Server Error");
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function delete($modelo, $args = [])
{
    header('Content-Type: application/json');
    try {
        $modelo->clear();
        $modelo->add_variables(["a.id" => $_POST['id']]);
        $result = $modelo->borrar();
        if ($result === 0 or $result === false) {
            echo json_encode(['success' => false, 'message' => 'No se pudo eliminar el registro']);
        } else {
            echo json_encode(['success' => true]);
        }
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function delete_many($modelo, $args = [])
{
    try {
        for ($i = 0; $i < count($_POST['lista']); $i++) {
            $modelo->__construct(...$_POST['lista'][$i]);
            $result = $modelo->borrar();
        }
        if ($result === 0 or $result === false) {
            echo json_encode(['success' => false, 'message' => 'No se pudo eliminar el registro']);
        } else {
            echo json_encode(['success' => true]);
        }
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function update_many($modelo, $args = [])
{
    try {

        for ($i = 0; $i < count($_POST['lista']); $i++) {
            $modelo->__construct(...$_POST['lista'][$i]);
            if (isset($_FILES['lista'])) {
                guardar_imagen_mult($i, get_called_class($modelo));
            }
            $result = $modelo->actualizar();
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

function guardar_imagen_mult($index, $module_name = null)
{
    is_dir("../src/media/" . $module_name) or mkdir("../src/media/" . $module_name);
    $imagen = $_FILES['lista'];
    $result = move_uploaded_file($imagen['tmp_name'][$index]['imagen'], '../src/media/' . $module_name . '/' . $imagen['name'][$index]['imagen']);
}

function guardar_imagen_single($module_name)
{
    is_dir("../src/media/" . $module_name) or mkdir("../src/media/" . $module_name);
    $imagen = $_FILES['imagen'];
    $result = move_uploaded_file($imagen['tmp_name'], '../src/media/' . $module_name . '/' . $imagen['name']);
}

function total($modelo, $args = [])
{
    header('Content-Type: application/json');
    try {
        $modelo->clear();
        $modelo->__construct(...$_POST);
        echo json_encode($modelo->count());
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function check(...$args)
{
    header('Content-Type: application/json');
    echo "<pre>";
    echo "POST:";
    print_r($_POST);
    echo "GET:";
    print_r($_GET);
    echo "</pre>";
    print_r($args);
    echo "</pre>";
    echo "Session";
    print_r($_SESSION);
    echo "</pre>";
    print_r($_FILES);
    $data = $_POST;
    unset($data['variable']);
    print_r($_POST);
}
