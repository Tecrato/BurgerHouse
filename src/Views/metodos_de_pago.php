<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>

<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">
    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>
    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>
    <div class="page-wrapper">
        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h3 class="page-title text-truncate text-dark font-weight-medium mb-1">Metodos de pago</h3>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="./index.php">Modulos</a>
                                <li class="breadcrumb-item text-muted" aria-current="page">Metodos de pago</li>
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
                            <div class="d-flex gap-3">
                                <div class="col-md-6 col-lg-3">
                                    <input type="search" class="form-control" id="searchPayments" placeholder="Buscar">
                                </div>
                                <button type="button" class="btn bh_1 btn-circle text-white btn-add-tooltip" data-module-add="metodo pago" data-bs-toggle="modal" data-bs-target="#register-payments" data-bs-title="Agregar Metodo de pago" data-bs-placement="bottom">
                                    <i data-feather="plus" class="svg-icon"></i>
                                </button>
                            </div>
                            <div class="table-responsive mt-2">
                                <table class="table table-dark-mode no-wrap table_payment w-100">
                                    <thead>
                                        <tr>
                                            <th>Nro</th>
                                            <th>Nombre</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>1</td>
                                            <td><span class="fs-6">Kg</span></td>
                                            <td>
                                                <button data-bs-toggle="modal" data-bs-target="#confirmAction" class="btn bh_1 rounded-circle btn-circle">
                                                    <i data-feather="edit" class="text-white"></i>
                                                </button>
                                                <button data-bs-toggle="modal" data-bs-target="#confirmAction" class="btn bh_5 rounded-circle btn-circle">
                                                    <i data-feather="trash" class="text-white"></i>
                                                </button>
                                            </td>

                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php include_once __DIR__ . '/../views/Components/modals/payment/modal.php' ?>
        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>
    </div>
</div>
</div>

<script src="./assets/libs/libs/jquery/dist/jquery.min.js"></script>
<script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
<script src="./assets/libs/extra-libs/datatables.net/js/jquery.dataTables.js"></script>
<script src="./assets/libs/extra-libs/datatables.net-bs4/js/dataTables.responsive.min.js"></script>
<script src="./assets/js/app-style-switcher.js"></script>
<script src="./assets/js/feather.min.js"></script>
<script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
<script src="./assets/js/sidebarmenu.js"></script>
<script src="./assets/js/custom.min.js"></script>
<script type="module" src="./assets/js/pages/paymentMethod/payment.js"></script>