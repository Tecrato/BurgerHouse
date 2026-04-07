<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>

<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">
    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>
    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>
    <div class="page-wrapper">
        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h3 class="page-title text-truncate text-dark font-weight-medium mb-1">Perfil</h3>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="./index.php">Perfil</a>
                            </ol>
                        </nav>
                    </div>
                </div>
                <?php include_once __DIR__ . '/../views/Components/BoxAndDolar.php' ?>
            </div>
        </div>
        <div class="container-fluid">
            <div class="row mt-3">
                <div class="col-md-6 col-lg-8">
                    <div class="card">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col-md-12 col-lg-5 text-center">
                                    <label id="input-file-user-profile-label" for="input-file-user-profile">
                                        <input type="file" class="d-none" id="input-file-user-profile">
                                        <img alt="user" id="img_profile" class="rounded-circle mb-4" width="200" height="200" style="object-fit: cover">
                                    </label>
                                    <h3 class="text-uppercase" id="session_name_rol"></h3>
                                </div>
                                <div class="col-md-12 col-lg-7">
                                    <form class="form-submit-edit-user-profile" action="">
                                        <div class="row mb-4">
                                            <label for="input-name-user-profile" class="col-sm-5 col-form-label">Nombre</label>
                                            <div class="col-sm-7">
                                                <input type="text" class="form-control" id="input-name-user-profile" name="nombre" placeholder="Nombre">
                                                <div class="text-danger mt-1 fs-6" id="error-input-name-user-profile"></div>
                                            </div>
                                        </div>
                                        <div class="row mb-4">
                                            <label for="input-lastname-user-profile" class="col-sm-5 col-form-label">Apellido</label>
                                            <div class="col-sm-7">
                                                <input type="text" class="form-control" id="input-lastname-user-profile" name="apellido" placeholder="Apellido">
                                                <div class="text-danger mt-1 fs-6" id="error-input-lastname-user-profile"></div>
                                            </div>
                                        </div>
                                        <div class="row mb-4">
                                            <label for="input-email-user-profile" class="col-sm-5 col-form-label">Correo Electronico</label>
                                            <div class="col-sm-7">
                                                <input type="email" class="form-control" id="input-email-user-profile" name="email" placeholder="Correo Electronico">
                                                <div class="text-danger mt-1 fs-6" id="error-input-email-user-profile"></div>
                                            </div>
                                        </div>
                                        <div class="mt-5 d-flex justify-content-center">
                                            <button type="submit" class="btn bh_1 text-white">Guardar</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <div class="row">
                                <form action="" id="form-edit-password-user-profile">
                                    <h3 class="mb-5 border-bottom pb-3">Cambiar Contraseña</h3>
                                    <div class="row mb-5">
                                        <label for="input-newPassword-user-profile" class="col-sm-5 col-form-label">Contraseña Nueva</label>
                                        <div class="col-sm-7">
                                            <input type="password" class="form-control" id="input-newPassword-user-profile" name="password" placeholder="Contraseña Nueva">
                                            <div class="text-danger mt-1 fs-6" id="error-input-newPassword-user-profile"></div>
                                        </div>
                                    </div>
                                    <div class="row mb-5">
                                        <label for="input-confirPassword-user-profile" class="col-sm-5 col-form-label">Confirmar Contraseña</label>
                                        <div class="col-sm-7">
                                            <input type="password" class="form-control" id="input-confirPassword-user-profile" name="confirm" placeholder="Confirmar Contraseña">
                                            <div class="text-danger mt-1 fs-6" id="error-input-confirPassword-user-profile"></div>
                                        </div>
                                    </div>
                                    <div class="mt-5 d-flex justify-content-center">
                                        <button class="btn bh_1 text-white" type="submit">
                                            <span class="spinner-border spinner-border-sm d-none" aria-hidden="true"></span>
                                            <span role="status">Cambiar Contraseña</span>
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-4">
                    <div class="card">
                        <div class="card-body">
                            <h4 class="card-title">Mi Actividad Reciente</h4>
                            <div class="mt-4 activity">
                                <!-- aqui cargan con js -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>
    </div>

    <script src="./assets/libs/libs/jquery/dist/jquery.min.js"></script>
    <script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
    <script src="./assets/js/app-style-switcher.js"></script>
    <script src="./assets/js/feather.min.js"></script>
    <script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
    <script src="./assets/js/sidebarmenu.js"></script>
    <script src="./assets/js/custom.min.js"></script>
    <script type="module" src="./assets/js/pages/profile/profile.js"></script>
    <script src="./assets/libs/libs/daysjs/dayjs.min.js"></script>
    <script src="./assets/libs/libs/daysjs/es.js"></script>
    <script src="./assets/libs/libs/daysjs/relativeTime.js"></script>