<?php
$turnstileSiteKey = (string)($GLOBALS['turnstile']['site_key'] ?? '');
?>
<!DOCTYPE html>
<html dir="ltr">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" type="image/png" sizes="16x16" href="./assets/img/favicon.png">
    <title>Iniciar Sesión</title>
    <link href="./assets/css/style.css" rel="stylesheet">
    <link href="./assets/css/stylesPerson.css" rel="stylesheet">
    <script src="https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit" async defer></script>
    <link rel="stylesheet" href="./assets/libs/libs/sweetalert/sweetalert2.min.css">
    <script src="./assets/libs/libs/sweetalert/sweetalert2.all.min.js"></script>
</head>

<body>
    <div class="main-wrapper">
        <?php include_once __DIR__ . '/../views/Components/preloader.php' ?>

        <div class="auth-wrapper d-flex no-block justify-content-center align-items-center position-relative overflow-hidden" style="background:url(./assets/img/big/auth-bg.jpg) no-repeat center center;">
            <div class="auth-box row login_page">
                <div class="col-lg-7 col-md-5 modal-bg-img" style="background-image: url(./assets/img/big/banner_login.png);">
                </div>
                <div class="col-lg-5 col-md-7 bg-white">
                    <div class="p-3">
                        <div class="text-center">
                            <img src="./assets/img/bh_logo.png" alt="wrapkit" width="70">
                        </div>
                        <h2 class="mt-3 text-center">Ingresar</h2>
                        <p class="text-center">Ingrese su dirección de correo electrónico y contraseña para acceder al panel de administración.</p>
                        <form id="login_form" autocomplete="off" class="mt-4">
                            <div class="row">
                                <div class="col-lg-12">
                                    <div class="form-group mb-3">
                                        <label class="form-label text-dark" for="uname">Correo</label>
                                        <input autocomplete="off" class="form-control" id="login-correo" type="email" placeholder="Ingrese su correo electronico" name="email">
                                        <div class="text-danger mt-1 fs-6" id="error-login-correo"></div>
                                    </div>
                                </div>
                                <div class="col-lg-12">
                                    <div class="form-group mb-3">
                                        <label class="form-label text-dark" for="pwd">Contraseña</label>
                                        <input autocomplete="new-password" class="form-control" id="login-password" type="password" placeholder="ingrese su contraseña" name="password">
                                        <div class="text-danger mt-1 fs-6" id="error-login-password"></div>
                                    </div>
                                </div>
                                <div class="col-lg-12 d-flex flex-column justify-content-center align-items-center mb-3 gap-2">
                                    <div id="login-captcha" class="cf-turnstile" data-sitekey="<?php echo htmlspecialchars($turnstileSiteKey, ENT_QUOTES, 'UTF-8'); ?>"></div>
                                    <div class="text-danger fs-6 text-center" id="error-login-captcha"></div>
                                </div>
                                <div class="col-lg-12 text-center">
                                    <button type="submit" class="btn w-100 btn-dark d-flex justify-content-center align-items-center gap-2" disabled>
                                        <div class="spinner-border text-primary d-none" role="status" style="width: 20px; height: 20px;">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                        Ingresar
                                    </button>
                                </div>
                                <div class="col-lg-12 text-center mt-4">
                                    <a href="Changepass" class="text-info">¿Olvidaste tu contraseña?</a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script src="./assets/libs/libs/jquery/dist/jquery.min.js "></script>
    <script src="./assets/libs/libs/popper.js/dist/umd/popper.min.js "></script>
    <script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.min.js "></script>
    <script src="./assets/libs/libs/validatejs/validate.min.js"></script>
    <script type="module" src="./assets/js/pages/login/login.js"></script>
</body>

</html>
