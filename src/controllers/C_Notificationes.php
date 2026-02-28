<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Notificacion;
use Pusher\Pusher;
use Exception;

function notification_view(...$args)
{
    view('notifications');
}

function notification_get_all(...$args)
{
    get_all(new Notificacion(), ...$args);
}

function notification_add(...$args)
{
    add(new Notificacion(), $_POST);
}

function notification_update(...$args)
{
    update(new Notificacion(), $_POST);
}

function notification_delete(...$args)
{
    delete(new Notificacion(), $_POST['id']);
}

function notification_sendNotifications(...$args)
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


function notification_sendNotifications(...) {
    // converted from NotificationController.php::sendNotifications - please implement logic
    // TODO: migrate code from class method
}

