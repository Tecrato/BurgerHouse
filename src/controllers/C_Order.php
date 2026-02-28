<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Orden;

function order_add(...) {
    // converted from OrderController.php::add - please implement logic
    get_all(new Orden(), ...$args); // adapt as needed
}

function order_add_process_and_prepared(...) {
    // converted from OrderController.php::add_process_and_prepared - please implement logic
    // TODO: migrate code from class method
}

function order_sendInvoice(...) {
    // converted from OrderController.php::sendInvoice - please implement logic
    // TODO: migrate code from class method
}

function order_update(...) {
    // converted from OrderController.php::update - please implement logic
    get_all(new Orden(), ...$args); // adapt as needed
}

