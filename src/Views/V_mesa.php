<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>

<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">
    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>
    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>
    <div class="page-wrapper">
        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h3 class="page-title text-truncate text-dark font-weight-medium mb-1">Mesas</h3>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="home" class="text-muted">Aplicaciones</a></li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Mesas</li>
                            </ol>
                        </nav>
                    </div>
                </div>
                <?php include_once __DIR__ . '/../views/Components/BoxAndDolar.php' ?>
            </div>
        </div>

        <div class="container-fluid">
            <ul class="nav nav-tabs" id="myTab" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="home-tab" data-bs-toggle="tab" data-bs-target="#home-tab-pane" type="button" role="tab" aria-controls="home-tab-pane" aria-selected="true">Libres</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="profile-tab" data-bs-toggle="tab" data-bs-target="#profile-tab-pane" type="button" role="tab" aria-controls="profile-tab-pane" aria-selected="false">Ocupadas</button>
                </li>
            </ul>
            <div class="tab-content" id="myTabContent">
                <div class="tab-pane fade show active" id="home-tab-pane" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
                    <div class="row g-3 align-items-center mb-5 mt-3">
                        <div class="col-auto">
                            <input type="search" id="SearchTablesFREE" placeholder="Buscar" class="form-control" aria-describedby="passwordHelpInline">
                        </div>
                        <button id="register-table-button" data-bs-toggle="modal" data-module-add="mesas" data-bs-target="#register-table" type="button" class="btn bh_1 btn-circle text-white">
                            <i data-feather="plus" class="svg-icon"></i>
                        </button>
                    </div>

                    <div class="row cont_tables_free mb-5">
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
                <div class="tab-pane fade" id="profile-tab-pane" role="tabpanel" aria-labelledby="profile-tab" tabindex="0">
                    <div class="row g-3 align-items-center mb-5 mt-3">
                        <div class="col-auto">
                            <input type="search" id="SearchTablesOCCUPIED" placeholder="Buscar" class="form-control" aria-describedby="passwordHelpInline">
                        </div>
                    </div>

                    <div class="row cont_tables_occupied mb-5">
                        <!-- aqui se cargan las mesas ocupadas -->
                    </div>
                    <nav aria-label="Page navigation example">
                        <ul class="pagination pagination_occupied justify-content-end">
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
            </div>





        </div>
        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>
        <?php include_once __DIR__ . '/../views/Components/modals/table/modal.php' ?>
    </div>


    <script src="./assets/libs/libs/jquery/dist/jquery.min.js"></script>
    <script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
    <script src="./assets/js/app-style-switcher.js"></script>
    <script src="./assets/js/feather.min.js"></script>
    <script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
    <script src="./assets/js/sidebarmenu.js"></script>
    <script src="./assets/js/custom.min.js"></script>
    <script type="module" src="./assets/js/pages/table/table.js"></script>