<?php
// scans src/controllers for Controller classes (excluding files starting with C_)
// and generates a procedural skeleton in C_<name>.php using the same logic we
// established earlier.  Existing C_ files are left untouched.
// Run: php scripts/generate_procedural.php

$src = __DIR__ . '/../src/controllers';
$files = glob($src . '/*Controller.php');
foreach ($files as $file) {
    $basename = basename($file);
    if (strpos($basename, 'C_') === 0) {
        continue;
    }
    // determine module name: strip Controller.php and lowercase
    $mod = strtolower(str_replace('Controller.php', '', $basename));
    $newfile = $src . '/C_' . ucfirst($mod) . '.php';
    if (file_exists($newfile)) {
        echo "Skipping $newfile (already exists)\n";
        continue;
    }
    $content = file_get_contents($file);
    // find model name from constructor line
    $model = null;
    if (preg_match('/\\$this->db\s*=\s*new\s+([A-Za-z0-9_]+)\s*\(/', $content, $m)) {
        $model = $m[1];
    }
    // extract method names except __construct
    preg_match_all('/public function\s+([a-zA-Z0-9_]+)\s*\(/', $content, $mm);
    $methods = array_filter($mm[1], function($name){ return $name !== '__construct'; });

    $out = "<?php\n";
    $out .= "require_once __DIR__ . '/Controller_base.php';\n";
    if ($model) {
        $out .= "use Shtch\\Burgerhouse\\models\\$model;\n";
    }
    $out .= "\n";

    // if no methods detected, still provide a basic view() stub
    if (empty($methods)) {
        $methods[] = 'view';
    }

    foreach ($methods as $method) {
        $func = $mod . '_' . $method;
        $out .= "function $func(...\$args) {\n";
        $out .= "    // converted from $basename::$method - please implement logic\n";
        if ($method === 'view') {
            $out .= "    view('$mod');\n";
        } elseif ($model && in_array($method, ['get_all','count','add','add_many','delete','delete_many','update','updateMany'])) {
            $out .= "    get_all(new $model(), ...\$args); // adapt as needed\n";
        } else {
            $out .= "    // TODO: migrate code from class method\n";
        }
        $out .= "}\n\n";
    }

    file_put_contents($newfile, $out);
    echo "Generated skeleton $newfile\n";
}
echo "Done\n";
