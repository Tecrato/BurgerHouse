<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>

<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">


    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>

    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>


    <div class="page-wrapper">

        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h4 class="page-title text-truncate text-dark font-weight-medium mb-1">Moneda</h4>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="index.html" class="text-muted">Aplicaciones</a></li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Moneda</li>
                            </ol>
                        </nav>
                    </div>
                </div>

                <?php include_once __DIR__ . '/../views/Components/BoxAndDolar.php' ?>

            </div>
        </div>

        <div class="container-fluid">


            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="row">
                                <div class="d-flex justify-content-between gap-4">
                                    <div class="input-group">
                                        <input type="text" class="form-control" placeholder="Dolar" aria-label="Recipient's username" aria-describedby="button-addon2">
                                        <button class="btn bh_1" type="button" id="button-addon2" style="color: #fff;">Guardar</button>
                                    </div>
                                    <button class="btn bh_5 btn-sm" style="color: #fff;">Actualizar</button>
                                </div>
                            </div>
                            <div class="row p-4 gap-3">
                                <div class="col-md-5 col-lg-5 text-center m-auto">
                                    <h2>Tasa Actual</h2>
                                    <h3 class="mb-3">56.36 Bs</h3>
                                    <img class="img-fluid" style="width: 58%;" src="./assets/img/dgdsRecurso 4.png" alt="">
                                </div>
                                <div class="col-md-5 col-lg-5 text-center m-auto">
                                    <h2>Tasa BCV</h2>
                                    <h3 class="mb-3">56.36 Bs</h3>
                                    <img class="img-fluid" style="width: 70%;" src="./assets/img/bcv.png" alt="">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <?php include_once __DIR__ . '/../views/Components/modals/Confirm.php' ?>

</div>

<script src="./assets/libs/libs/jquery/dist/jquery.min.js"></script>
<script src="./assets/libs/libs/popper.js/dist/umd/popper.min.js"></script>
<script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>

<script src="./assets/js/app-style-switcher.js"></script>
<script src="./assets/js/feather.min.js"></script>
<script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
<script src="./assets/js/sidebarmenu.js"></script>
<script src="./assets/js/custom.min.js"></script>


<?php include_once __DIR__ . '/../views/Components/footer.php' ?>