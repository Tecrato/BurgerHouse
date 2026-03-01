<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>

<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">
    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>
    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>
    <div class="page-wrapper">
        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h3 class="page-title text-truncate text-dark font-weight-medium mb-1">Paquetes de reservaciones</h3>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="home" class="text-muted">Aplicaciones</a></li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Calendario</li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Paquetes de reservaciones</li>
                            </ol>
                        </nav>
                    </div>
                </div>
                <?php include_once __DIR__ . '/../views/Components/BoxAndDolar.php' ?>
            </div>
        </div>

        <div class="container-fluid">
            <div class="row g-3 align-items-center mb-5 mt-3">
                <div class="col-auto">
                    <input type="search" id="SearchPackages" placeholder="Buscar" class="form-control" aria-describedby="passwordHelpInline">
                </div>
                <button data-bs-toggle="modal" data-module-add="paquetes" data-bs-target="#register-package" type="button" class="btn bh_1 btn-circle text-white">
                    <i data-feather="plus" class="svg-icon"></i>
                </button>
            </div>

            <div class="row cont_packages mb-5">
                <!-- aqui se cargan las mesas libres -->
            </div>
            <nav aria-label="Page navigation example">
                <ul class="pagination pagination_free justify-content-end">
                    <li class="page-item" id="prev-page">
                        <a class="page-link" href="#" aria-label="Previous">
                            <span aria-hidden="true">&laquo;</span>
                        </a>
                    </li>
                    <!-- Aquí se insertan los números dinámicamente -->
                    <li class="page-item" id="next-page">
                        <a class="page-link" href="#" aria-label="Next">
                            <span aria-hidden="true">&raquo;</span>
                        </a>
                    </li>
                </ul>
            </nav>

        </div>
        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>
        <?php include_once __DIR__ . '/../views/Components/modals/package_reservation/modal.php' ?>
    </div>
</div>


<script src="./assets/libs/libs/jquery/dist/jquery.min.js"></script>
<script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
<script src="./assets/js/app-style-switcher.js"></script>
<script src="./assets/js/feather.min.js"></script>
<script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
<script src="./assets/js/sidebarmenu.js"></script>
<script src="./assets/js/custom.min.js"></script>
<script type="module" src="./assets/js/pages/package_reservation/package_reservation.js"></script>