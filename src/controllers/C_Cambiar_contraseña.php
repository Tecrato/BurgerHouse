<?php
use Shtch\Burgerhouse\models\Usuario;
use PHPMailer\PHPMailer\PHPMailer;

// Este controlador NO requiere autenticación porque es para recuperación de contraseña
$resultado_final = '';

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/recover_password.php')) {
        include_once __DIR__ . '/../views/recover_password.php';
    } else {
        make_url_error("No se encontró la vista recover_password.php", 404);
    }
    exit;
}

if ($url[1] === 'sendEmail') {
    // Enviar email de recuperación - no requiere autenticación
    try {
        date_default_timezone_set('America/Caracas');
        $day = new DateTime();
        $day->format('Y-m-d H:i:s');
        $token = random_int(1000, 9999);
        $expiresAt = $day->add(new DateInterval('PT150S'))->format('Y-m-d H:i:s');
        
        $usuario = new Usuario();
        $usuario->__construct(id: $_POST['id'], token: $token, token_expiracion: $expiresAt);
        $usuario->actualizar();
        
        $mail = new PHPMailer(true);
        $mail->isSMTP();
        $mail->Host       = 'smtp.gmail.com';
        $mail->SMTPAuth   = true;
        $mail->Username   = 'garnicaluis391@gmail.com';
        $mail->Password   = 'cczxcuzcduloehqc';
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port       = 587;

        $mail->CharSet = 'UTF-8';
        $mail->setFrom('garnicaluis391@gmail.com', 'Burger House Soporte');
        $mail->addAddress($_POST['email']);
        $mail->isHTML(true);
        $mail->Subject = 'Restablece tu contraseña';
        $mail->addEmbeddedImage('./assets/img/banner.png', 'logo_cid', 'logo.png');
        $mail->Body = '
            <html>
                <body>
                    <img src="cid:logo_cid" alt="Logo" width="300">
                    <h1 style="color:##FF4B00; font-family: Arial, sans-serif; text-align: center;">¡Hola, ' . $_POST['name'] . '!</h1>
                    <p style="font-size: 14px; line-height: 1.5;">Has solicitado restablecer tu contraseña en Burger House.</p>
                    <h3 style="font-family: Arial, sans-serif;">Tu código de verificación es: ' . $token . '</h3>
                    <p>Introduce este código en el formulario de restablecimiento dentro de los próximos 150 segundos para completar el proceso.</p>
                    <p>Si no solicitaste este cambio, ignora este correo y tu contraseña seguirá siendo la misma.</p>
                    <h3>¡Gracias!</h3>
                </body>
            </html>
        ';
        $mail->send();
        $resultado_final = ["success" => true, "mensaje" => "Correo enviado."];
    } catch (Exception $e) {
        make_url_error("Error al enviar el correo: " . $e->getMessage(), 500, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'validateToken') {
    // Validar token - no requiere autenticación
    try {
        $token = $_POST['token'] ?? '';
        date_default_timezone_set('America/Caracas');
        $now = new DateTime();
        $now->format('Y-m-d H:i:s');
        
        $usuario = new Usuario();
        $usuario->__construct(token: $token);
        $result = $usuario->search();

        if (!empty($result)) {
            $date_DB = new DateTime($result[0]['token_expiracion']);
            if ($now > $date_DB) {
                $resultado_final = ["success" => false, "mensaje" => "Codigo expirado."];
            } else {
                $resultado_final = ["success" => true, "mensaje" => $result];
            }
        } else {
            $resultado_final = ["success" => false, "mensaje" => "Codigo no valido."];
        }
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'update') {
    // Actualizar contraseña - no requiere autenticación
    if (empty($_POST['id']) || !array_key_exists('hash', $_POST) || trim((string)$_POST['hash']) === '') {
        make_url_error("Datos inválidos para actualizar contraseña.", 400, ajax: true);
    }

    try {
        $_POST['hash'] = password_hash($_POST['hash'], PASSWORD_DEFAULT);
        $usuario = new Usuario();
        $usuario->__construct(id: $_POST['id'], hash: $_POST['hash'], token: null, token_expiracion: null);
        $result = $usuario->actualizar();
        $resultado_final = ["success" => (bool)($result['success'] ?? false), "mensaje" => $result['message'] ?? null];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else {
    make_url_error("Accion no valida para cambiar_contraseña.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
