<?php
// quick script to update procedural controllers by removing the redundant
// $usuario parameter and switching to $_SESSION directly.
// run from workspace root: php scripts/convert_controllers.php

$dir = __DIR__ . '/../src/controllers';
$files = glob($dir . '/C_*.php');
foreach ($files as $file) {
    $content = file_get_contents($file);
    $original = $content;

    // 1. remove $usuario or $_SESSION from function signature (plus any comma)
    $content = preg_replace(
        '/function\\s+([a-zA-Z0-9_]+)\\s*\\(\\s*(?:\\$usuario|\\$_SESSION)\\s*(,\\s*)?/',
        'function $1(',
        $content
    );
    // eliminate stray leading commas inside parentheses
    $content = preg_replace(
        '/function\s+([a-zA-Z0-9_]+)\s*\(\s*,\s*/',
        'function $1(',
        $content
    );

    // 2. convert remaining $usuario references to $_SESSION
    $content = str_replace('$usuario', '$_SESSION', $content);

    if ($content !== $original) {
        file_put_contents($file, $content);
        echo "Updated $file\n";
    }
}

echo "Conversion completed. Please review individual files for edge cases.\n";
