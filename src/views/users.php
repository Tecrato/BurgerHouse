<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>

<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">
    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>
    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>

    <div class="page-wrapper">
        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h3 class="page-title text-truncate text-dark font-weight-medium mb-1">Usuarios</h3>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="home" class="text-muted">Autenticacion</a></li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Usuarios</li>
                            </ol>
                        </nav>
                    </div>
                </div>

                <?php include_once __DIR__ . '/../views/Components/BoxAndDolar.php' ?>

            </div>
        </div>

        <div class="container-fluid">

            <div class="row g-3 align-items-center mb-5">
                <div class="col-auto">
                    <input type="search" id="search-filter-users" placeholder="Buscar" class="form-control">
                </div>
                <button data-bs-toggle="modal" data-bs-target="#register-user" data-module-add="usuarios" type="button" class="btn bh_1 btn-circle text-white btn-add-tooltip" data-bs-title="Agregar Usuario" 
                data-bs-placement="top">
                    <i data-feather="user-plus" class="svg-icon"></i>
                </button>
            </div>

            <div class="row container_users">
                <!-- // Aquí se cargarán los usuarios -->
            </div>
        </div>
        <?php include_once __DIR__ . '/../views/Components/modals/user/modal.php' ?>
        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>
    </div>

    <script src="./assets/libs/libs/jquery/dist/jquery.min.js"></script>
    <script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
    <script src="./assets/libs/libs/validatejs/validate.min.js"></script>
    <script src="./assets/js/app-style-switcher.js"></script>
    <script src="./assets/js/feather.min.js"></script>
    <script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
    <script src="./assets/js/sidebarmenu.js"></script>
    <script src="./assets/js/custom.min.js"></script>
    <script type="module" src="./assets/js/pages/user/user.js"></script>