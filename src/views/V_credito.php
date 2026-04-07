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
                    <h3 class="page-title text-truncate text-dark font-weight-medium mb-1">Creditos</h3>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="index.html" class="text-muted">Modulos</a></li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Facturacion</li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Credito</li>
                            </ol>
                        </nav>
                    </div>
                </div>

                <?php include_once __DIR__ . '/../views/Components/BoxAndDolar.php' ?>

            </div>
        </div>

        <div class="container-fluid">

            <div class="row gap-2 align-items-center mb-5">
                <div class="col-auto">
                    <input type="search" id="inputPassword6" placeholder="Buscar" class="form-control" aria-describedby="passwordHelpInline">
                </div>
                
                <button type="button" class="btn bh_1 btn-circle text-white" data-bs-toggle="dropdown" aria-expanded="false">
                    <i data-feather="filter" class="svg-icon"></i>
                </button>

                <div class="dropdown">
                    <ul class="dropdown-menu p-4">
                        <div class="row g-3 align-items-center mb-3">
                            <div class="col-auto">
                                <label for="inputPassword6" class="col-form-label">Desde</label>
                            </div>
                            <div class="col-auto">
                                <input type="date" id="inputPassword6" class="form-control" aria-describedby="passwordHelpInline">
                            </div>
                        </div>
                        <div class="row g-3 align-items-center">
                            <div class="col-auto">
                                <label for="inputPassword6" class="col-form-label">Hasta</label>
                            </div>
                            <div class="col-auto">
                                <input type="date" id="inputPassword6" class="form-control" aria-describedby="passwordHelpInline">
                            </div>
                        </div>
                        <div class="row g-3 align-items-center justify-content-center mt-3">
                            <div class="col-auto">
                                <button class="btn bh_5 text-white">Aplicar</button>
                            </div>
                        </div>
                    </ul>
                </div>

            </div>

            <div class="row">
                <div class="col-md-4 col-lg-3 ">
                    <div class="position-relative">
                        <span class="badge bh_1 d-flex justify-content-center align-items-center position-absolute rounded-circle" style="z-index: 1; width: 40px; height: 40px; top: -15px; right: -10px;">
                            <span><i style="font-size: 20px;" data-feather="clipboard" class="svg-icon"></i></span>
                        </span>
                        <div class="card">
                            <div class="card-body">
                                <div class="mb-3 border-bottom">
                                    <div class="d-flex justify-content-between ">
                                        <h5 class="card-title">Nro Factura</h5>
                                        <div>
                                            <p class="fs-6">454558</p>
                                        </div>
                                    </div>
                                    <div class="d-flex justify-content-between">
                                        <p class="fw-lighter fs-6">Fecha: 15/3/2025</p>
                                        <p class="fw-lighter fs-6">Hora: 13:40</p>
                                    </div>
                                </div>


                                <div class="row gap-3">
                                    <div class="d-flex flex-column gap-3">
                                        <div class="d-flex align-item-center justify-content-between text-start">
                                            <div>Cliente</div>
                                            <div class="fs-6">Jose Escalona</div>
                                        </div>
                                        <div class="d-flex justify-content-between">
                                            <div class="text-start">Vendedor</div>
                                            <div class=" text-end fs-6 w-50 text-truncate">Kevin</div>
                                        </div>
                                        <div class="d-flex justify-content-between">
                                            <div class="text-start">Total</div>
                                            <div class=" text-end fs-6 w-50 text-truncate">756 Bs</div>
                                        </div>
                                        <span class="badge text-bg-secondary badge-pill">A credito</span>
                                        <div class="d-flex justify-content-center gap-4 pt-3 border-top">
                                            <button class="btn btn-sm bh_1" style="color: #fff;">Pagar</button>
                                            <button class="btn btn-sm bh_5" style="color: #fff;">Detalles</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <?php include_once __DIR__ . '/../views/Components/modals/Confirm.php' ?>

        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>

    </div>



    <script src="./assets/libs/libs/jquery/dist/jquery.min.js"></script>
    <script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
    <script src="./assets/js/app-style-switcher.js"></script>
    <script src="./assets/js/feather.min.js"></script>
    <script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
    <script src="./assets/js/sidebarmenu.js"></script>
    <script src="./assets/js/custom.min.js"></script>