<?php

function make_url_error($message, $code = 400, $ajax = false) {
    header('HTTP/1.0 ' . $code . ' ' . ERROR_DICT[$code]);
    echo $message;
    if (
        (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'xmlhttprequest') ||
        (isset($_SERVER['CONTENT_TYPE']) && strpos($_SERVER['CONTENT_TYPE'], 'application/json') !== false) ||
        (isset($_SERVER['HTTP_ACCEPT']) && strpos($_SERVER['HTTP_ACCEPT'], 'application/json') !== false) ||
        (isset($_POST['ajax']) && $_POST['ajax'] === '1') || (isset($_GET['ajax']) && $_GET['ajax'] === '1') ||
        $ajax === true
    ) {
        echo json_encode(["success" => false, "message" => $message]);
        exit;
    }
    if ($code === 401 || $code === 403 || $code === 404) {
        // echo "No estás autenticado. Redirigiendo a login...";
        // echo "<br>";
        // echo $message;
        include_once __DIR__.'/../views/error-404.php';
        // header('Location: ' . __URL__ . 'error404/');
        exit;
    }
    exit;
}

function login_verify_turnstile(string $token): array
{
    $secret = trim((string)($GLOBALS['turnstile']['secret_key'] ?? ''));

    if ($secret === '') {
        return [
            'success' => false,
            'message' => 'Captcha no configurado en el servidor.'
        ];
    }

    if ($token === '') {
        return [
            'success' => false,
            'message' => 'Debes completar el captcha.'
        ];
    }

    $postFields = [
        'secret' => $secret,
        'response' => $token
    ];

    if (!empty($_SERVER['REMOTE_ADDR'])) {
        $postFields['remoteip'] = $_SERVER['REMOTE_ADDR'];
    }

    $responseBody = null;

    if (function_exists('curl_init')) {
        $curl = curl_init('https://challenges.cloudflare.com/turnstile/v0/siteverify');
        curl_setopt($curl, CURLOPT_POST, true);
        curl_setopt($curl, CURLOPT_POSTFIELDS, http_build_query($postFields));
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_TIMEOUT, 10);
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, true);
        curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, 2);

        $responseBody = curl_exec($curl);

        // Fallback para entornos locales con CA no configurada (ej. XAMPP).
        if ($responseBody === false) {
            curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, 0);
            $responseBody = curl_exec($curl);
        }

    } else {
        $context = stream_context_create([
            'http' => [
                'method' => 'POST',
                'header' => "Content-type: application/x-www-form-urlencoded\r\n",
                'content' => http_build_query($postFields),
                'timeout' => 10
            ]
        ]);

        $responseBody = @file_get_contents('https://challenges.cloudflare.com/turnstile/v0/siteverify', false, $context);
    }

    if ($responseBody === false || $responseBody === null) {
        return [
            'success' => false,
            'message' => 'No se pudo validar el captcha. Intenta nuevamente.'
        ];
    }

    $decoded = json_decode($responseBody, true);

    if (!is_array($decoded)) {
        return [
            'success' => false,
            'message' => 'Respuesta inválida al validar captcha.'
        ];
    }

    if (($decoded['success'] ?? false) !== true) {
        $errorCodes = $decoded['error-codes'] ?? [];
        if (!is_array($errorCodes)) {
            $errorCodes = [$errorCodes];
        }

        $message = 'No se pudo validar el captcha.';

        if (in_array('timeout-or-duplicate', $errorCodes, true)) {
            $message = 'El captcha expiró. Vuelve a verificarlo.';
        } elseif (in_array('missing-input-secret', $errorCodes, true) || in_array('invalid-input-secret', $errorCodes, true)) {
            $message = 'Captcha no configurado en el servidor.';
        } elseif (in_array('missing-input-response', $errorCodes, true) || in_array('invalid-input-response', $errorCodes, true)) {
            $message = 'Captcha inválido. Verifícalo nuevamente.';
        }

        return [
            'success' => false,
            'message' => $message
        ];
    }

    return ['success' => true];
}

function obtener_persona_cedula($cedula)
{
    function getCurlData($url)
    {
        $curl = curl_init();
        curl_setopt($curl, CURLOPT_URL, $url);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($curl, CURLOPT_TIMEOUT, 10);
        $curlData = curl_exec($curl);
        return $curlData;
    }
    function getCI($cedula, $return_raw = false)
    {
        $res = getCurlData("https://api.cedula.com.ve/api/v1?app_id=" . APPID_CEDULA . "&token=" . TOKEN_CEDULA . "&cedula=" . (int)$cedula);
        if ($return_raw)
            return strlen($res) > 3 ? $res : false;
        $res = json_decode($res, true);
        return isset($res['data']) && $res['data'] ? $res['data'] : $res['error_str'];
    }
    return getCI($cedula);
}

function parseUrl()
{
    $uri = $_SERVER['REQUEST_URI'];
    $uri = parse_url($uri, PHP_URL_PATH);
    $uri = str_replace('/BurgerHouse', '', $uri);
    return explode('/', filter_var(trim($uri, '/'), FILTER_SANITIZE_URL));
}