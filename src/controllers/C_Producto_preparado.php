<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\ProductoPreparado;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/V_producto_preparado.php')) {
        include_once __DIR__ . '/../views/V_producto_preparado.php';
    } else {
        make_url_error("No se encontró la vista V_producto_preparado.php", 404);
    }
    exit;
}

if ($url[1] === 'get_all') {
    if (!$session->has_permission('productos_preparados', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new ProductoPreparado(...$_POST);
        $resultado_final = $modelo->search(...$parametros_paginacion);
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'add') {
    if (!$session->has_permission('productos_preparados', 'agregar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (isset($_FILES['lista']) && is_array($_FILES['lista'])) {
        foreach ($_FILES['lista']['name']['imagen'] as $index => $fileName) {
            if ($fileName && $_FILES['lista']['error']['imagen'][$index] === UPLOAD_ERR_OK) {
                $upload_dir = __DIR__ . '/../media/productos_preparados/';
                
                if (!file_exists($upload_dir)) {
                    mkdir($upload_dir, 0777, true);
                }
                
                $file_extension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
                $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif'];
                
                if (!in_array($file_extension, $allowed_extensions)) {
                    make_url_error("Tipo de archivo no permitido. Solo se permiten JPG, JPEG, PNG, GIF.", 400, ajax: true);
                }
                
                $file_name = uniqid('prod_prep_', true) . '.' . $file_extension;
                $upload_path = $upload_dir . $file_name;
                
                if (move_uploaded_file($_FILES['lista']['tmp_name']['imagen'][$index], $upload_path)) {
                    $_POST['lista'][$index]['imagen'] = $file_name;
                    $_POST['lista'][$index]['imagen_name'] = $file_name;
                } else {
                    make_url_error("Error al subir la imagen.", 500, ajax: true);
                }
            }
        }
    } elseif (isset($_FILES['imagen']) && $_FILES['imagen']['error'] === UPLOAD_ERR_OK) {
        $upload_dir = __DIR__ . '/../media/productos_preparados/';
        
        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }
        
        $file_extension = strtolower(pathinfo($_FILES['imagen']['name'], PATHINFO_EXTENSION));
        $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif'];
        
        if (!in_array($file_extension, $allowed_extensions)) {
            make_url_error("Tipo de archivo no permitido. Solo se permiten JPG, JPEG, PNG, GIF.", 400, ajax: true);
        }
        
        $file_name = uniqid('prod_prep_', true) . '.' . $file_extension;
        $upload_path = $upload_dir . $file_name;
        
        if (move_uploaded_file($_FILES['imagen']['tmp_name'], $upload_path)) {
            $_POST['imagen'] = $file_name;
            $_POST['imagen_name'] = $file_name;
        } else {
            make_url_error("Error al subir la imagen.", 500, ajax: true);
        }
    } elseif (isset($_POST['imagen']) && is_string($_POST['imagen'])) {
    } else {
        $_POST['imagen'] = null;
    }

    try {
        $modelo = new ProductoPreparado(...$_POST);
        $id = $modelo->agregar();
        $resultado_final = ['success' => true, 'last_id' => $id];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'update') {
    $active = $_POST['active'] ?? null;

    if ($active !== null && (string)$active === '0') {
        if (!$session->has_permission('productos_preparados', 'eliminar')) {
            make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
        }
    } else if ($active !== null && (string)$active === '1') {
        if (
            !$session->has_permission('Papelera', 'restaurar') &&
            !$session->has_permission('productos_preparados', 'eliminar')
        ) {
            make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
        }
    } else if (!$session->has_permission('productos_preparados', 'editar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (isset($_FILES['imagen']) && $_FILES['imagen']['error'] === UPLOAD_ERR_OK) {
        if (isset($_POST['id'])) {
            $modelo_actual = new ProductoPreparado(id: $_POST['id']);
            $producto_actual = $modelo_actual->search(n: 0, limite: 1);
            if (!empty($producto_actual) && !empty($producto_actual[0]['imagen'])) {
                $imagen_anterior = __DIR__ . '/../media/productos_preparados/' . $producto_actual[0]['imagen'];
                if (file_exists($imagen_anterior)) {
                    unlink($imagen_anterior);
                }
            }
        }
        
        $upload_dir = __DIR__ . '/../media/productos_preparados/';
        
        if (!file_exists($upload_dir)) {
            if (!mkdir($upload_dir, 0777, true)) {
                make_url_error("No se pudo crear el directorio de destino.", 500, ajax: true);
            }
        }
        
        if (!is_writable($upload_dir)) {
            chmod($upload_dir, 0777);
            if (!is_writable($upload_dir)) {
                make_url_error("El directorio no tiene permisos de escritura.", 500, ajax: true);
            }
        }
        
        $file_extension = strtolower(pathinfo($_FILES['imagen']['name'], PATHINFO_EXTENSION));
        $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif'];
        
        if (!in_array($file_extension, $allowed_extensions)) {
            make_url_error("Tipo de archivo no permitido. Solo se permiten JPG, JPEG, PNG, GIF.", 400, ajax: true);
        }
        
        $file_name = uniqid('prod_prep_', true) . '.' . $file_extension;
        $upload_path = $upload_dir . $file_name;
        
        if (!is_uploaded_file($_FILES['imagen']['tmp_name'])) {
            make_url_error("El archivo no fue subido correctamente.", 500, ajax: true);
        }
        
        if (move_uploaded_file($_FILES['imagen']['tmp_name'], $upload_path)) {
            $_POST['imagen'] = $file_name;
            $_POST['imagen_name'] = $file_name;
            if (!file_exists($upload_path)) {
                make_url_error("El archivo no se guardó correctamente.", 500, ajax: true);
            }
        } else {
            make_url_error("Error al mover la imagen. Verifica permisos del directorio.", 500, ajax: true);
        }
    } else {
        unset($_POST['imagen']);
    }

    try {
        $modelo = new ProductoPreparado(...$_POST);
        $resultado_final = $modelo->actualizar();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'delete') {
    if (!$session->has_permission('productos_preparados', 'eliminar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (!isset($_POST['id'])) {
        make_url_error("No se recibio el id para eliminar.", 400, ajax: true);
    }

    try {
        $modelo = new ProductoPreparado(id: $_POST['id']);
        $resultado_final = ['success' => $modelo->borrar()];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'count' || $url[1] === 'total') {
    if (!$session->has_permission('productos_preparados', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new ProductoPreparado(...$_POST);
        $resultado_final = $modelo->count();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else {
    make_url_error("Accion no valida para producto_preparado.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
