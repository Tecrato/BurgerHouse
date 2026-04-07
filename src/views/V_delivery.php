<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>

<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full"
    data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">

    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>
    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>

    <div class="page-wrapper">
        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h3 class="page-title text-truncate text-dark font-weight-medium mb-1">Delivery</h3>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="index.html" class="text-muted">Aplicaciones</a></li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Pedidos y entregas</li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Delivery</li>
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
                    <button class="nav-link active" id="home-tab" data-bs-toggle="tab" data-bs-target="#home-tab-pane" type="button" role="tab" aria-controls="home-tab-pane" aria-selected="true">Pendientes</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="profile-tab" data-bs-toggle="tab" data-bs-target="#profile-tab-pane" type="button" role="tab" aria-controls="profile-tab-pane" aria-selected="false">Entregados</button>
                </li>
            </ul>

            <div class="tab-content" id="myTabContent">
                <div class="tab-pane fade show active" id="home-tab-pane" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
                    <div class="row g-3 align-items-center my-4">
                        <div class="col-auto">
                            <input type="search" id="searchDeliveryPending" placeholder="Buscar" class="form-control" aria-describedby="passwordHelpInline">
                        </div>
                    </div>
                    <div class="row cont-delivery-pending">

                    </div>
                </div>
                <div class="tab-pane fade" id="profile-tab-pane" role="tabpanel" aria-labelledby="profile-tab" tabindex="0">
                    <div class="row g-3 align-items-center my-4">
                        <div class="col-auto">
                            <input type="search" id="searchDeliveryOff" placeholder="Buscar" class="form-control" aria-describedby="passwordHelpInline">
                        </div>
                    </div>
                    <div class="row cont-delivery-off">

                    </div>
                </div>
            </div>
        </div>
        <?php include_once __DIR__ . '/../views/Components/modals/delivery-kitchen/modal.php' ?>
        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>


        <!-- Toast -->
        <div class="toast-container position-fixed bottom-0 end-0 p-3">
            <div id="liveToast" class="toast border-0" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="toast-header bh_1 text-white">
                    <i class="me-2" data-feather="alert-circle"></i>
                    <strong class="me-auto">Bootstrap</strong>
                    <small>11 mins ago</small>
                    <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
                <div class="toast-body bh_1 text-white">
                    Hello, world! This is a toast message.
                </div>
            </div>
        </div>

    </div>

    <script src="./assets/libs/libs/jquery/dist/jquery.min.js"></script>
    <script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
    <script src="./assets/js/app-style-switcher.js"></script>
    <script src="./assets/js/feather.min.js"></script>
    <script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
    <script src="./assets/js/sidebarmenu.js"></script>
    <script src="./assets/js/custom.min.js"></script>
    <script src="./assets/libs/libs/jspdf/jspdf.umd.min.js"></script>
    <script src="./assets/libs/libs/daysjs/dayjs.min.js"></script>
    <script src="./assets/libs/libs/daysjs/es.js"></script>
    <script src="./assets/libs/libs/daysjs/relativeTime.js"></script>
    <script type="module" src="./assets/js/pages/delivery/delivery.js"></script>