<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Usuario;

function recover_password_view(...$args)
{
    view('recover_password');
}

function recover_password_sendEmail(...$args)
{
    date_default_timezone_set('America/Caracas');
    $day = new DateTime();
    $day->format('Y-m-d H:i:s');
    $token = random_int(1000, 9999);
    $expiresAt = $day->add(new DateInterval('PT150S'))->format('Y-m-d H:i:s');
    $usuario = new Usuario();
    $usuario->__construct(id: $_POST['id'], token: $token, token_expiracion: $expiresAt);
    $usuario->actualizar();
    $mail = new PHPMailer(true);
    try {
        $mail->isSMTP();
        $mail->Host       = 'smtp.gmail.com';
        $mail->SMTPAuth   = true;
        $mail->Username   = 'garnicaluis391@gmail.com';
        $mail->Password   = 'cczxcuzcduloehqc';
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port       = 587;

        $mail->CharSet  = 'UTF-8';
        $mail->setFrom('garnicaluis391@gmail.com', 'Burger House Soporte');
        $mail->addAddress($_POST['email']);
        $mail->isHTML(true);
        $mail->Subject = 'Restablece tu contraseña';
        $mail->addEmbeddedImage(
            './assets/img/banner.png',
            'logo_cid',
            'logo.png'
        );
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
        echo json_encode(["success" => true, "mensaje" => "Correo enviado."]);
    } catch (Exception $e) {
        echo json_encode(["success" => false, "mensaje" => "Error al enviar el correo: " . $e->getMessage()]);
    }
}

function recover_password_validateToken(...$args)
{
    $token = $_POST['token'] ?? '';
    date_default_timezone_set('America/Caracas');
    $now  = new DateTime();
    $now->format('Y-m-d H:i:s');
    $usuario = new Usuario();
    $usuario->__construct(token: $token);
    $result = $usuario->search();

    if (!empty($result)) {
        $date_DB = new DateTime($result[0]['token_expiracion']);
        if ($now > $date_DB) {
            echo json_encode(["success" => false, "mensaje" => "Codigo expirado."]);
        } else {
            echo json_encode(["success" => true, "mensaje" => $result]);
        }
    } else {
        echo json_encode(["success" => false, "mensaje" => "Codigo no valido."]);
    }
}


function changepass_sendEmail(...) {
    // converted from ChangepassController.php::sendEmail - please implement logic
    // TODO: migrate code from class method
}

function changepass_validateToken(...) {
    // converted from ChangepassController.php::validateToken - please implement logic
    // TODO: migrate code from class method
}

