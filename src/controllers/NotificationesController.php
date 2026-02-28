<?php

namespace Shtch\Burgerhouse\controllers;

use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Notificacion;
use Pusher\Pusher;
use Exception;

class NotificationController extends Controller_base
{
    public function __construct()
    {
        parent::__construct("notifications");
        $this->db = new Notificacion();
    }

    public function sendNotifications()
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
}
