<?php

    require_once __DIR__ . '/../vendor/autoload.php';
    require_once __DIR__ . '/../src/config/config.php';
    require_once __DIR__ . '/../src/function/mini_funciones.php';


    $url = parseUrl();

    //validar si la url es un archivo de media
    if (strpos($url[0], 'media') === 0) {
        $filePath = __DIR__ . '/../src/media/' . implode('/', array_slice($url, 1));
        if (file_exists($filePath)) {
            // Limpia salida previa accidental (BOM/newlines) para no corromper binarios.
            while (ob_get_level() > 0) {
                ob_end_clean();
            }

            $mimeType = mime_content_type($filePath) ?: 'application/octet-stream';
            header('Content-Type: ' . $mimeType);
            header('Content-Length: ' . filesize($filePath));
            readfile($filePath);
            exit;
        } else {
            header('HTTP/1.0 404 Not Found');
            echo "Archivo no encontrado.";
            echo "<br>";
            echo "Ruta: " . $filePath;
            exit;
        }
    }


    // para que se vuelva json al final
    if (
        (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'xmlhttprequest') ||
        (isset($_SERVER['CONTENT_TYPE']) && strpos($_SERVER['CONTENT_TYPE'], 'application/json') !== false) ||
        (isset($_SERVER['HTTP_ACCEPT']) && strpos($_SERVER['HTTP_ACCEPT'], 'application/json') !== false) ||
        (isset($_POST['ajax']) && $_POST['ajax'] === '1') || (isset($_GET['ajax']) && $_GET['ajax'] === '1')
    ) {
        $ajax = true;
    } else {
        $ajax = false;
    }
    

    $nro_page = $url[2] ?? null;
    $limite_registros = $url[3] ?? null;
    $columna_orden = $url[4] ?? null;
    $orden_direccion = $url[5] ?? null;



    if ($nro_page !== null && !preg_match('/^[0-9]+$/', $nro_page)) {
        make_url_error("Número de página inválido.");
        exit;
    }
    if ($limite_registros !== null && !preg_match('/^[0-9]+$/', $limite_registros)) {
        make_url_error("Número de registros inválido.".json_encode($limite_registros));
        exit;
    }
    if ($columna_orden !== null && !preg_match('/^[a-zA-Z0-9_\.]+$/', $columna_orden)) {
        make_url_error("Columna de orden inválida.");
        exit;
    }
    if ($orden_direccion !== null && !in_array(strtolower($orden_direccion), ['asc', 'desc'], true)) {
        make_url_error("Dirección de orden inválida.");
        exit;
    }

    $parametros_paginacion = array_filter([
        'n' => $nro_page,
        'limite' => $limite_registros,
        'order_by' => $columna_orden,
        'order_type' => $orden_direccion
    ]);
    
    if (!isset($url[0]) || $url[0] == '') {
        $url = [
            0 => "home"
        ];
    }

    if (file_exists(__DIR__ . '/../src/controllers/C_' . ucfirst(strtolower($url[0])) . '.php')) {
        require_once __DIR__ . '/../src/controllers/C_' . ucfirst(strtolower($url[0])) . '.php';
    } else {
        // $files = scandir(__DIR__ . '/../src/controllers/');
        // foreach ($files as $file) {
        //     echo $file . '<br>';
        // }
        echo __DIR__ . '/../src/controllers/C_' . ucfirst(strtolower($url[0])) . '.php';
        echo '<br>';
        echo '------------------';
        echo '<br>';
        print_r($url);
        echo '<br>';
        echo '------------------';
        echo '<br>';
        print_r($_SERVER['REQUEST_URI']);
        echo '<br>';
        echo '------------------';
        echo '<br>';
        make_url_error("La URL solicitada no existe.", 404, ajax: $ajax);
        // require_once __DIR__ . '/../src/controllers/C_Error404.php';
        // $url[0] = 'error404';
    }
    exit;
?>