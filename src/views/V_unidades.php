<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>


<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">
    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>
    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>
    <div class="page-wrapper">
        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h3 class="page-title text-truncate text-dark font-weight-medium mb-1">Unidades</h3>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="./index.php">Modulos</a>
                                <li class="breadcrumb-item text-muted" aria-current="page">Unidad</li>
                            </ol>
                        </nav>
                    </div>
                </div>
                <?php include_once __DIR__ . '/../views/Components/BoxAndDolar.php' ?>
            </div>
        </div>
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-6 col-lg-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="table-responsive mt-3">
                                <div class="d-flex gap-4">
                                    <div class="col-md-6 col-lg-3">
                                        <input type="search" class="form-control" id="searchUnits" placeholder="Buscar">
                                    </div>
                                    <button type="button" class="btn bh_1 btn-circle text-white btn-add-tooltip" data-module-add="unidades" data-bs-toggle="modal" data-bs-target="#register-unit" data-bs-title="Agregar unidad" data-bs-placement="top">
                                        <i data-feather="plus" class="svg-icon"></i>
                                    </button>
                                </div>
                                <table class="table table-dark-mode no-wrap table_unit w-100">
                                    <thead>
                                        <tr>
                                            <th>Nro de unidad</th>
                                            <th>Nombre</th>
                                            <th>Alias</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- cargan con datatable -->
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php include_once __DIR__ . '/../views/Components/modals/units/modal.php' ?>
        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>
    </div>
</div>

<script src="./assets/libs/libs/jquery/dist/jquery.min.js"></script>
<script src="./assets/libs/libs/popper.js/dist/umd/popper.min.js"></script>
<script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
<script src="./assets/libs/extra-libs/datatables.net/js/jquery.dataTables.js"></script>
<script src="./assets/libs/extra-libs/datatables.net-bs4/js/dataTables.responsive.min.js"></script>
<script src="./assets/js/app-style-switcher.js"></script>
<script src="./assets/js/feather.min.js"></script>
<script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
<script src="./assets/js/sidebarmenu.js"></script>
<script src="./assets/js/custom.min.js"></script>
<script type="module" src="./assets/js/pages/units/units.js"></script>