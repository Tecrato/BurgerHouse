<?php

namespace Shtch\Burgerhouse\models;

use Shtch\Burgerhouse\models\Db_base;

class Usuario extends Db_base
{
    private $id;
    private $id_rol;
    private $nombre;
    private $apellido;
    private $hash;
    private $active;
    private $session_id;
    private $email;
    private $token;
    private $imagen;
    private $token_expiracion;
    private $nombre_like;

    function __construct($id = null, $nombre = null, $hash = null, $id_rol = null, $active = null, $session_id = null, $email = null, $apellido = null, $nombre_like = null, $token = null, $token_expiracion = null, $imagen_name = null)
    {
        parent::__construct("usuario", 2);
        $this->id = $id;
        $this->nombre = $nombre;
        $this->hash = $hash;
        $this->id_rol = $id_rol;
        $this->active = $active;
        $this->session_id = $session_id;
        $this->email = $email;
        $this->apellido = $apellido;
        $this->token = $token;
        $this->token_expiracion = $token_expiracion;
        $this->nombre_like = $nombre_like;
        $this->imagen = $imagen_name;

        $this->add_variables([
            "a.id" => $this->id,
            "a.nombre" => $this->nombre,
            "a.hash" => $this->hash,
            "a.id_rol" => $this->id_rol,
            "a.active" => $this->active,
            "a.session_id" => $this->session_id,
            "a.email" => $this->email,
            "a.apellido" => $this->apellido,
            "a.token" => $this->token,
            "a.token_expiracion" => $this->token_expiracion,
            "a.imagen" => $this->imagen
        ]);
        $this->select_query = "
                a.id,
                a.nombre,
                a.hash,
                roles.nombre rol,
                roles.id id_rol,
                a.active,
                a.session_id,
                a.email,
                a.apellido,
                a.token,
                a.token_expiracion,
                a.imagen
            ";
        $this->joins = "
                INNER JOIN roles ON roles.id = a.id_rol
            ";

        $this->add_variables_like([
            "a.nombre" => $this->nombre_like
        ]);
    }
}
