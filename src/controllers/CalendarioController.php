<?php

namespace Shtch\Burgerhouse\controllers;

use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Reservacion;


class CalendarController extends Controller_base
{
    public function __construct()
    {
        parent::__construct("calendar");
        $this->db = new Reservacion();
    }
}
