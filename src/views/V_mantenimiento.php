<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>
<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">
    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>
    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>
    <div class="page-wrapper">
        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h3 class="page-title text-truncate text-dark font-weight-medium mb-1">Mantenimiento</h3>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="home" class="text-muted">Autenticacion</a></li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Mantenimiento</li>
                            </ol>
                        </nav>
                    </div>
                </div>

                <?php include_once __DIR__ . '/../views/Components/BoxAndDolar.php' ?>

            </div>
        </div>
        <div class="container-fluid">
            <div class="row">
                <ul class="nav nav-tabs" id="myTab" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="home-tab" data-bs-toggle="tab" data-bs-target="#home-tab-pane" type="button" role="tab" aria-controls="home-tab-pane" aria-selected="true">Sistema</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="profile-tab" data-bs-toggle="tab" data-bs-target="#profile-tab-pane" type="button" role="tab" aria-controls="profile-tab-pane" aria-selected="false">Usuario</button>
                    </li>
                </ul>
                <div class="tab-content" id="myTabContent">
                    <div class="tab-pane fade show active" id="home-tab-pane" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
                        <div class="d-flex gap-4 mt-4">
                            <div class="col-md-6 col-lg-3">
                                <input type="search" class="form-control" id="searchBackupSystem" placeholder="Buscar">
                            </div>
                            <div class="col-md-6 col-lg-9 d-flex align-items-center gap-4">
                                <i class="btn_export btn bh_1 btn-circle text-white btn-add-tooltip" data-id="system" data-module-export="Mantenimiento" data-db="burgerhouse" data-bs-toggle="tooltip" data-bs-placement="top" title="Exportar" data style="cursor: pointer;" data-feather="upload"></i>
                                <i data-bs-toggle="tooltip" data-bs-placement="top" title="Configuracion" data style="cursor: pointer;" data-feather="sliders"></i>
                            </div>
                        </div>
                        <div class="table-responsive mt-4">
                            <table class="table table-dark-mode no-wrap w-100 table_db_backup_system">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>BASE DE DATOS</th>
                                        <th>ACCIÓN</th>
                                    </tr>
                                </thead>
                                <tbody>

                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="tab-pane fade" id="profile-tab-pane" role="tabpanel" aria-labelledby="profile-tab" tabindex="0">
                        <div class="d-flex gap-4 mt-4">
                            <div class="col-md-6 col-lg-3">
                                <input type="search" class="form-control" id="searchBackupUser" placeholder="Buscar">
                            </div>
                            <div class="col-md-6 col-lg-9 d-flex align-items-center gap-4">
                                <i class="btn_export btn bh_1 btn-circle text-white btn-add-tooltip" data-id="users" data-module-export="Mantenimiento" data-db="usuarios_burgerhouse" data-bs-toggle="tooltip" data-bs-placement="top" title="Exportar" data style="cursor: pointer;" data-feather="upload"></i>
                                <i data-bs-toggle="tooltip" data-bs-placement="top" title="Configuracion" data style="cursor: pointer;" data-feather="sliders"></i>
                            </div>
                        </div>
                        <div class="table-responsive mt-4">
                            <table class="table table-dark-mode no-wrap w-100 table_db_backup_users">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>BASE DE DATOS</th>
                                        <th>ACCIÓN</th>
                                    </tr>
                                </thead>
                                <tbody>

                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>
    </div>
</div>

<script src="./assets/libs/libs/jquery/dist/jquery.min.js"></script>
<script src="./assets/libs/extra-libs/taskboard/js/jquery-ui.min.js"></script>
<script src="./assets/libs/libs/popper.js/dist/umd/popper.min.js"></script>
<script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
<script src="./assets/libs/extra-libs/datatables.net/js/jquery.dataTables.js"></script>
<script src="./assets/libs/extra-libs/datatables.net-bs4/js/dataTables.responsive.min.js"></script>
<script src="./assets/js/app-style-switcher.js"></script>
<script src="./assets/js/feather.min.js"></script>
<script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
<script src="./assets/js/sidebarmenu.js"></script>
<script src="./assets/js/custom.min.js"></script>
<script defer type="module" src="./assets/js/pages/maintenance/maintenance.js"></script>