<?php
require_once __DIR__ . '/Controller_base.php';

// Perfil (profile) module – only shows a view in the original class.
function perfil_view(...$args)
{
    view('perfil');
}
