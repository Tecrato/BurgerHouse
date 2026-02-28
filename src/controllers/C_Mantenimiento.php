<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Usuario;

function maintenance_export(...) {
    // converted from MaintenanceController.php::export - please implement logic
    // TODO: migrate code from class method
}

function maintenance_import(...) {
    // converted from MaintenanceController.php::import - please implement logic
    // TODO: migrate code from class method
}

function maintenance_search(...) {
    // converted from MaintenanceController.php::search - please implement logic
    // TODO: migrate code from class method
}

function maintenance_delete(...) {
    // converted from MaintenanceController.php::delete - please implement logic
    get_all(new Usuario(), ...$args); // adapt as needed
}

