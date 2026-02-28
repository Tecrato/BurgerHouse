<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Notificacion;
use Pusher\Pusher;
use Exception;

function notificationes_view(...$args)
{
    view('notifications');
}

function notificationes_get_all(...$args)
{
    get_all(new Notificacion(), ...$args);
}

function notificationes_add(...$args)
{
    add(new Notificacion(), $_POST);
}

function notificationes_update(...$args)
{
    update(new Notificacion(), $_POST);
}

function notificationes_delete(...$args)
{
    delete(new Notificacion(), $_POST['id']);
}

function notificationes_sendNotifications(...$args)
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
