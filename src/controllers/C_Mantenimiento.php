<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};

use Shtch\Burgerhouse\models\Backup;
use Shtch\Burgerhouse\models\Usuario;


function mantenimiento_export(...$args)
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
    try {
        $usuario = new Usuario();
        $usuario->clear();
        $usuario->__construct(id: $_POST['id']);
        $result = $usuario->search();

        $storedHash = $result[0]['hash'] ?? '';
        $inputPassword = $_POST['password'] ?? '';
        $validPassword = password_verify($inputPassword, $storedHash) || hash_equals((string)$storedHash, (string)$inputPassword);

        if ($validPassword) {
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
    try {
        $backup = new Backup();
        echo json_encode($backup->search($_POST['route']));
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}


function mantenimiento_delete(...$args)
{
    try {
        $usuario = new Usuario();
        $usuario->clear();
        $usuario->__construct(id: $_POST['id']);
        $result = $usuario->search();

        $storedHash = $result[0]['hash'] ?? '';
        $inputPassword = $_POST['password'] ?? '';
        $validPassword = password_verify($inputPassword, $storedHash) || hash_equals((string)$storedHash, (string)$inputPassword);

        if ($validPassword) {
            $backup = new Backup();
            $backup->delete($_POST['route'], $_POST['archive']);
            return;
        }

        echo json_encode(['success' => false, 'message' => 'Contraseña incorrecta']);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}
