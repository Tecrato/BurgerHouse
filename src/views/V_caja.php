<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>

<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">
    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>
    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>
    <div class="page-wrapper">
        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h3 class="page-title text-truncate text-dark font-weight-medium mb-1">Caja</h3>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="index.html" class="text-muted">Modulos</a></li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Caja</li>
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
                    <button class="nav-link active" id="home-tab" data-bs-toggle="tab" data-bs-target="#home-tab-pane" type="button" role="tab" aria-controls="home-tab-pane" aria-selected="true">Abiertas</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="profile-tab" data-bs-toggle="tab" data-bs-target="#profile-tab-pane" type="button" role="tab" aria-controls="profile-tab-pane" aria-selected="false">Cerradas</button>
                </li>
            </ul>

            <div class="tab-content" id="myTabContent">
                <div class="tab-pane fade show active" id="home-tab-pane" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
                    <div class="row g-3 align-items-center mb-5 mt-3">
                        <div class="col-auto">
                            <input type="search" id="searchCashOpen" placeholder="Buscar" class="form-control" aria-describedby="passwordHelpInline">
                        </div>
                        <button style="color: #fff;" type="button" data-module-open="caja" class="btn bh_1 btn-circle" data-bs-toggle="modal" data-bs-target="#register-cash">
                            <i data-feather="plus" class="svg-icon"></i>
                        </button>
                    </div>
                    <div class="row cont-cash_open">
                        <!-- js -->
                    </div>
                </div>

                <div class="tab-pane fade" id="profile-tab-pane" role="tabpanel" aria-labelledby="profile-tab" tabindex="0">
                    <div class="row g-3 align-items-center my-4">
                        <div class="col-auto">
                            <input type="search" id="searchCashClose" placeholder="Buscar" class="form-control" aria-describedby="passwordHelpInline">
                        </div>
                        <button type="button" class="btn bh_1 btn-circle text-white" data-bs-toggle="dropdown" aria-expanded="false">
                            <i data-feather="filter" class="svg-icon"></i>
                        </button>
                        <div class="dropdown">
                            <ul class="dropdown-menu p-4">
                                <form id="form_cash_filter_date">
                                    <div class="row g-3 align-items-center mb-3">
                                        <div class="col-auto">
                                            <label for="inputPassword6" class="col-form-label">Desde</label>
                                        </div>
                                        <div class="col-auto">
                                            <input type="date" id="date_start" class="form-control" aria-describedby="passwordHelpInline">
                                        </div>
                                    </div>
                                    <div class="row g-3 align-items-center">
                                        <div class="col-auto">
                                            <label for="inputPassword6" class="col-form-label">Hasta</label>
                                        </div>
                                        <div class="col-auto">
                                            <input type="date" id="date_end" class="form-control" aria-describedby="passwordHelpInline">
                                        </div>
                                    </div>
                                    <div class="row g-3 align-items-center justify-content-center mt-3">
                                        <div class="col-auto">
                                            <button type="submit" class="btn bh_5 text-white">Aplicar</button>
                                        </div>
                                    </div>
                                </form>
                            </ul>
                        </div>
                    </div>
                    <div class="row cont-cash_close">
                        <!-- js -->
                    </div>
                </div>
                <?php include_once __DIR__ . '/../views/Components/modals/cash/modal.php' ?>
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
    <script src="./assets/libs/libs/jspdf/jspdf.umd.min.js"></script>
    <script type="module" src="./assets/js/pages/cash/cash.js"></script>
    <script type="module" src="./assets/js/pages/cash/report.js"></script>