<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>

<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">


    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>

    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>


    <div class="page-wrapper">

        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h4 class="page-title text-truncate text-dark font-weight-medium mb-1">Materia Prima</h4>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="index.html" class="text-muted">Modulos</a></li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Productos Preparados</li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Materia Prima</li>
                            </ol>
                        </nav>
                    </div>
                </div>

                <?php include_once __DIR__ . '/../views/Components/BoxAndDolar.php' ?>

            </div>
        </div>

        <div class="container-fluid">

            <nav>
                <div class="nav nav-tabs" id="nav-tab" role="tablist">
                    <button class="nav-link active" id="nav-home-tab" data-bs-toggle="tab" data-bs-target="#nav-home" type="button" role="tab" aria-controls="nav-home" aria-selected="true">Materia Prima</button>
                    <button class="nav-link" id="nav-profile-tab" data-bs-toggle="tab" data-bs-target="#nav-profile" type="button" role="tab" aria-controls="nav-profile" aria-selected="false">Entradas</button>
                </div>
            </nav>
            <div class="tab-content" id="nav-tabContent">
                <div class="tab-pane fade show active" id="nav-home" role="tabpanel" aria-labelledby="nav-home-tab" tabindex="0">
                    <?php include_once __DIR__ . '/../views/Components/switcher/rawmaterial/rawmaterial.php' ?>
                </div>
                <div class="tab-pane fade" id="nav-profile" role="tabpanel" aria-labelledby="nav-profile-tab" tabindex="0">
                    <?php include_once __DIR__ . '/../views/Components/switcher/rawmaterial/entrys.php' ?>
                </div>
            </div>
        </div>
        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>
    </div>

    <?php include_once __DIR__ . '/../views/Components/modals/raw_material/entrysModal.php' ?>
    <?php include_once __DIR__ . '/../views/Components/modals/raw_material/raw-materialModal.php' ?>

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
<script src="./assets/libs/libs/jspdf/jspdf.umd.min.js"></script>
<script src="./assets/libs/libs/jspdf/jspdf.plugin.autotable.min.js"></script>
<script type="module" src="./assets/js/pages/raw-material/raw_material.js"></script>
<script type="module" src="./assets/js/pages/raw-material/entrys.js"></script>
<script type="module" src="./assets/js/pages/raw-material/report.js"></script>