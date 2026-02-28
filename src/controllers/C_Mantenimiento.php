<?php
require_once __DIR__ . '/Controller_base.php';

use Shtch\Burgerhouse\models\Backup;
use Shtch\Burgerhouse\models\Usuario;

function mantenimiento_export(...$args)
{
    return maintenance_export(...$args);
}

function maintenance_export(...$args)
{
    try {
        $backup = new Backup();
        $backup->respaldo($_POST['db'], $_POST['route']);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function mantenimiento_import(...$args)
{
    return maintenance_import(...$args);
}

function maintenance_import(...$args)
{
    try {
        $usuario = new Usuario();
        $usuario->clear();
        $usuario->__construct(id: $_POST['id']);
        $result = $usuario->search();

        if ($result[0]['hash'] == $_POST['password']) {
            $backup = new Backup();
            $backup->restaurar($_POST['db'], $_POST['route'], $_POST['archive']);
            return;
        }

        echo json_encode(['success' => false, 'message' => 'Contraseña incorrecta']);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function mantenimiento_search(...$args)
{
    return maintenance_search(...$args);
}

function maintenance_search(...$args)
{
    try {
        $backup = new Backup();
        echo json_encode($backup->search($_POST['route']));
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function mantenimiento_delete(...$args)
{
    return maintenance_delete(...$args);
}

function maintenance_delete(...$args)
{
    try {
        $usuario = new Usuario();
        $usuario->clear();
        $usuario->__construct(id: $_POST['id']);
        $result = $usuario->search();

        if ($result[0]['hash'] == $_POST['password']) {
            $backup = new Backup();
            $backup->delete($_POST['route'], $_POST['archive']);
            return;
        }

        echo json_encode(['success' => false, 'message' => 'Contraseña incorrecta']);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}
