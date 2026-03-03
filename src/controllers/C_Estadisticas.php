<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Estadisticas;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/V_estadisticas.php')) {
        include_once __DIR__ . '/../views/V_estadisticas.php';
    } else if (file_exists(__DIR__ . '/../views/estadisticas.php')) {
        include_once __DIR__ . '/../views/estadisticas.php';
    } else {
        make_url_error("No se encontro una vista para estadisticas.", 404, ajax: $ajax);
    }
    exit;
}

$accion = strtolower($url[1]);
$estadisticas = new Estadisticas();

if ($accion === 'gastoclientesemana') {
    try {
        $resultado_final = $estadisticas->GastoClienteSemana((int)($_POST['anio'] ?? 0), (int)($_POST['semana'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'gastoclientemes') {
    try {
        $resultado_final = $estadisticas->GastoClienteMes((int)($_POST['anio'] ?? 0), (int)($_POST['mes'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'gastoclienteanual' || $accion === 'gastoclienteanio') {
    try {
        $resultado_final = $estadisticas->GastoClienteAnio((int)($_POST['anio'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'productosmasvendidosemana') {
    try {
        $resultado_final = $estadisticas->productosMasVendidoSemana((int)($_POST['anio'] ?? 0), (int)($_POST['semana'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'productosvendidosmes') {
    try {
        $resultado_final = $estadisticas->productosMasVendidosMes((int)($_POST['anio'] ?? 0), (int)($_POST['mes'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'productosvendidosanual' || $accion === 'productosvendidosanio') {
    try {
        $resultado_final = $estadisticas->productosMasVendidosAnio((int)($_POST['anio'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'productosmenosvendidossemana') {
    try {
        $resultado_final = $estadisticas->productosMenosVendidoSemana((int)($_POST['anio'] ?? 0), (int)($_POST['semana'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'productosmenosvendidosmes') {
    try {
        $resultado_final = $estadisticas->productosMenosVendidosMes((int)($_POST['anio'] ?? 0), (int)($_POST['mes'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'productosmenosvendidosanual' || $accion === 'productosmenosvendidosanio') {
    try {
        $resultado_final = $estadisticas->productosMenosVendidosAnio((int)($_POST['anio'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'totalventasemana') {
    try {
        $resultado_final = $estadisticas->totalVentaSemana((int)($_POST['anio'] ?? 0), (int)($_POST['semana'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'totalventames') {
    try {
        $resultado_final = $estadisticas->totalVentaMes((int)($_POST['anio'] ?? 0), (int)($_POST['mes'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'totalventaanio' || $accion === 'totalventaanual') {
    try {
        $resultado_final = $estadisticas->totalVentaAnio((int)($_POST['anio'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'utilidadnetasemana') {
    try {
        $resultado_final = $estadisticas->utilidadNetaSemana((int)($_POST['anio'] ?? 0), (int)($_POST['semana'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'utilidadnetames') {
    try {
        $resultado_final = $estadisticas->utilidadNetaMes((int)($_POST['anio'] ?? 0), (int)($_POST['mes'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'utilidadnetaanio' || $accion === 'utilidadnetaanual') {
    try {
        $resultado_final = $estadisticas->utilidadNetaAnio((int)($_POST['anio'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'reservahorariosemana') {
    try {
        $resultado_final = $estadisticas->porcentajeReservasSemana((int)($_POST['anio'] ?? 0), (int)($_POST['semana'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'reservahorariomes') {
    try {
        $resultado_final = $estadisticas->porcentajeReservasMes((int)($_POST['anio'] ?? 0), (int)($_POST['mes'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'reservahorarioanio' || $accion === 'reservahorarioanual') {
    try {
        $resultado_final = $estadisticas->porcentajeReservasAnio((int)($_POST['anio'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'reservaspormetodosemana') {
    try {
        $resultado_final = $estadisticas->porcentajeReservasMetodoSemana((int)($_POST['anio'] ?? 0), (int)($_POST['semana'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'reservaspormetodomes') {
    try {
        $resultado_final = $estadisticas->porcentajeReservasMetodoMes((int)($_POST['anio'] ?? 0), (int)($_POST['mes'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'reservaspormetodoanio' || $accion === 'reservaspormetodoanual') {
    try {
        $resultado_final = $estadisticas->porcentajeReservasMetodoAnio((int)($_POST['anio'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'stats_ordenes') {
    try {
        $resultado_final = $estadisticas->stats_ordenes((string)($_POST['tipo'] ?? ''));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else {
    make_url_error("Accion no valida para estadisticas.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
