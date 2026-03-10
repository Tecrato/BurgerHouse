<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<link rel="stylesheet" href="./assets/libs/libs/bs-stepper/bs-stepper.min.css">
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>
<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">
    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>
    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>
    <div class="page-wrapper">
        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h4 class="page-title text-truncate text-dark font-weight-medium mb-1">Calendario</h4>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item text-muted active" aria-current="page">Aplicaciones</li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Calendario</li>
                                <li class="breadcrumb-item text-muted" aria-current="page">Reservaciones</li>
                            </ol>
                        </nav>
                    </div>
                </div>
                <?php include_once __DIR__ . '/../views/Components/BoxAndDolar.php' ?>
            </div>
        </div>
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="card">
                        <div class="">
                            <div class="row">
                                <div class="col-lg-3 border-end pr-0">
                                    <div class="card-body border-bottom d-flex align-items-center justify-content-between">
                                        <h4 class="card-title mt-2">Reservaciones</h4>
                                        <button class="btn bh_1 btn-circle btn-sm text-white btn_add_reservation" data-module-schedule="reservaciones">
                                            <i data-feather="plus"></i>
                                        </button>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-12">
                                                <div id="calendar-events" class="">
                                                    <div class="calendar-events mb-3">
                                                        <i class="fa fa-circle me-2" style="color: #FF4B00;"></i>Confirmadas
                                                    </div>
                                                    <div class="calendar-events mb-3" data-class="bg-success">
                                                        <i class="fa fa-circle me-2" style="color: #FFB200;"></i>Por verificar
                                                    </div>
                                                    <div class="calendar-events mb-3" data-class="bg-success">
                                                        <i class="fa fa-circle me-2" style="color: #b41a1a;"></i>Anuladas
                                                    </div>
                                                </div>
                                                <hr>
                                                <div>
                                                    <div class="calendar-events mt-3 fs-6 text-muted">
                                                        <i class="fa fa-info-circle me-2" style="color: #FF4B00;"></i>Pulse sobre cualquiera de los dias que cuenten con una reservacion para ver los detalles
                                                    </div>
                                                    <div class="calendar-events mt-3 fs-6 text-muted">
                                                        <i class="fa fa-info-circle me-2" style="color: #FF4B00;"></i>Solo podra editar las reservas mientras no esten en cocina
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-9">
                                    <div class="card-body ">
                                        <div id="calendar"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>
        <?php include_once __DIR__ . '/../views/Components/modals/reservation/modal.php' ?>
    </div>
</div>

<script src="./assets/libs/libs/intl-tel-input/js/intlTelInput.js"></script>
<script src="./assets/libs/libs/jquery/dist/jquery.min.js"></script>
<script src="./assets/libs/extra-libs/taskboard/js/jquery-ui.min.js"></script>
<script src="./assets/libs/libs/popper.js/dist/umd/popper.min.js"></script>
<script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
<script src="./assets/js/app-style-switcher.js"></script>
<script src="./assets/js/feather.min.js"></script>
<script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
<script src="./assets/js/sidebarmenu.js"></script>
<script src="./assets/js/custom.min.js"></script>
<script src="./assets/libs/libs/moment/min/moment.min.js"></script>
<script src="./assets/libs/libs/fullcalendar/index.global.min.js"></script>
<script src="./assets/libs/libs/fullcalendar/index.global.js"></script>
<script src="./assets/libs/libs/fullcalendar/es.global.min.js"></script>
<script src="./assets/libs/libs/bs-stepper/bs-stepper.min.js"></script>