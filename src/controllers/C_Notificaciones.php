<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Notificacion;
use Pusher\Pusher;


function notificaciones_view(...$args)
{
    view('notificaciones');
}

function notificaciones_get_all(...$args)
{
    $modelo = new Notificacion();
    get_all($modelo, ...$args);
}

function notificaciones_add(...$args)
{
    add(new Notificacion(), $_POST);
}

function notificaciones_update(...$args)
{
    update(new Notificacion(), $_POST);
}

function notificaciones_delete(...$args)
{
    delete(new Notificacion(), $_POST['id']);
}

function notificaciones_sendNotifications(...$args)
{
    try {
        date_default_timezone_set('America/Caracas');
        $channel = $_POST['channel'];
        $event = $_POST['event'];
        $message = $_POST['message'];
        $pusher = new Pusher(
            '2a7ca356d030e2945ae9',
            '3c3f676721576bb7c676',
            '2016820',
            [
                'cluster' => 'us2',
                'useTLS' => true
            ]
        );
        $data = ['message' => $message,  'time' => date('Y-m-d H:i:s'), 'event' => $event];
        $pusher->trigger($channel, $event, $data);
        echo json_encode(['success' => true]);
    } catch (Exception $th) {
        echo json_encode(['success' => false, 'message' => $th->getMessage()]);
    }
}