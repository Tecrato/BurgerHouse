<?php
// procedural controller for 404 errors

$resultado_final = '';

// No auth for 404

if (count($url) < 2) {
    // Show 404 page
    header("HTTP/1.0 404 Not Found");
    echo "<h1>404 - Página no encontrada</h1>";
    echo "<p>La URL solicitada no existe: " . htmlspecialchars(
        isset($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : ''
    ) . "</p>";
    exit;
}

// No actions for 404
make_url_error("Página no encontrada.", 404);

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    $resultado_final = json_encode($resultado_final);
}
print_r($resultado_final);
