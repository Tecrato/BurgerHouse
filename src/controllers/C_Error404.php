<?php
// procedural controller for 404 errors

function error404_view()
{
    header("HTTP/1.0 404 Not Found");
    echo "<h1>404 - Página no encontrada</h1>";
    echo "<p>La URL solicitada no existe: " . htmlspecialchars($_SERVER['REQUEST_URI']) . "</p>";
}
