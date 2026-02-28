<?php
namespace Shtch\Burgerhouse\models;

use Shtch\Burgerhouse\models\Db_base;

class Vista extends Db_base {

    public function __construct($nombre_vista, $variables = [], $variables_like = []) {
        parent::__construct($nombre_vista);

        $this->add_variables($variables);

        $this->add_variables_like($variables_like);
    
    }
}
