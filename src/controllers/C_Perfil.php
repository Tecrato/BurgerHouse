<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};

// Perfil (profile) module – only shows a view in the original class.
function perfil_view(...$args)
{
    view('perfil');
}
