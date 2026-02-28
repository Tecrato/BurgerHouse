<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>

<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">
    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>
    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>

    <div class="page-wrapper">
        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h4 class="page-title text-truncate text-dark font-weight-medium mb-1">Papelera</h4>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="index.html" class="text-muted">Aplicaciones</a></li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Papelera</li>
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
                            <div class="d-flex gap-4">
                                <div class="col-md-6 col-lg-2">
                                    <input type="search" class="form-control" id="SearchTrash" placeholder="Buscar">
                                </div>
                                <div class="col-md-6 col-lg-3">
                                    <div class="dropdown select_options_module">
                                        <div class="dropdown">
                                            <div class="btn-group w-100" bis_skin_checked="1">
                                                <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" data-key-module="Seleccione una opcion">
                                                <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                                    <span> <i data-feather="chevron-down"></i></span>
                                                </button>
                                                <div class="dropdown-menu p-2" bis_skin_checked="1">
                                                    <div class="options_search" style="max-height: 180px; overflow-y: scroll;">
                                                        <a class="dropdown-item" data-key="mesas">Mesas</a>
                                                        <a class="dropdown-item" data-key="product_prepared">Productos Preparados</a>
                                                        <a class="dropdown-item" data-key="product_processed">Productos Procesados</a>
                                                        <a class="dropdown-item" data-key="entry_raw_material">Entradas materia prima</a>
                                                        <a class="dropdown-item" data-key="entry_product_processed">Entradas productos procesados</a>
                                                        <a class="dropdown-item" data-key="materia_prima">Materia Prima</a>
                                                        <a class="dropdown-item" data-key="Adicionales">Adicionales</a>
                                                        <a class="dropdown-item" data-key="Proveedores">Proveedores</a>
                                                        <a class="dropdown-item" data-key="Clientes">Clientes</a>
                                                        <a class="dropdown-item" data-key="Unidades">Unidades</a>
                                                        <a class="dropdown-item" data-key="Categoria_combo">Categoria de productos</a>
                                                        <a class="dropdown-item" data-key="Categoria_rawmaterial">Categoria de Materia prima</a>
                                                        <a class="dropdown-item" data-key="Metodos_pago">Metodos de pago</a>
                                                        <a class="dropdown-item" data-key="Roles">Roles</a>
                                                        <a class="dropdown-item" data-key="Usuarios">Usuarios</a>
                                                    </div>

                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="table-responsive mt-3">
                                <table class="table table-dark-mode no-wrap table_trash  w-100">
                                    <thead>
                                        <tr>
                                        
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
<script type="module" src="./assets/js/pages/trash/trash.js"></script>