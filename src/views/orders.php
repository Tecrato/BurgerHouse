<?php include_once __DIR__ . '/../views/Components/header.php' ?>
<link href="./assets/libs/libs/tagify/tagify.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="./assets/libs/libs/bs-stepper/bs-stepper.min.css">
<?php include_once __DIR__ . '/../views/Components/preloader.php' ?>
<div id="main-wrapper" data-theme="light" data-layout="vertical" data-navbarbg="skin6" data-sidebartype="full" data-sidebar-position="fixed" data-header-position="fixed" data-boxed-layout="full">
    <?php include_once __DIR__ . '/../views/Components/topBar.php' ?>
    <?php include_once __DIR__ . '/../views/Components/aside.php' ?>
    <div class="page-wrapper">
        <div class="page-breadcrumb">
            <div class="row">
                <div class="col-md-8 align-self-center">
                    <h4 class="page-title text-truncate text-dark font-weight-medium mb-1">Ordenes</h4>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="index.html" class="text-muted">Aplicaciones</a></li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Pedidos y entregas</li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Ordenes</li>
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
                    <nav>
                        <div class="nav nav-tabs" id="nav-tab" role="tablist">
                            <button class="nav-link module_link" data-module="Ordenes (delivery)" id="nav-domicilio-tab" data-bs-toggle="tab" data-bs-target="#nav-domicilio" type="button" role="tab" aria-controls="nav-home" aria-selected="true">A domicilio</button>
                            <button class="nav-link module_link" data-module="Ordenes (llevar)" id="nav-llevar-tab" data-bs-toggle="tab" data-bs-target="#nav-llevar" type="button" role="tab" aria-controls="nav-profile" aria-selected="false">Para llevar</button>
                            <button class="nav-link module_link" data-module="Ordenes (local)" id="nav-local-tab" data-bs-toggle="tab" data-bs-target="#nav-local" type="button" role="tab" aria-controls="nav-contact" aria-selected="false">En el local</button>
                            <button class="nav-link" data-module="Ordenes (reservas)" id="nav-res-tab" data-bs-toggle="tab" data-bs-target="#nav-res" type="button" role="tab" aria-controls="res-contact" aria-selected="false">Reservaciones</button>
                        </div>
                    </nav>
                    <div class="card">
                        <div class="card-body">
                            <div class="tab-content" id="nav-tabContent">
                                <div class="tab-pane fade" id="nav-domicilio" role="tabpanel" aria-labelledby="nav-home-tab" tabindex="0">

                                    <div class="row">
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_5BG text-center">
                                                    <h1 class="font-light text-white target_order_delivery_null">0</h1>
                                                    <h6 class="text-white">Pagos nulos</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_1BG text-center">
                                                    <h1 class="font-light text-white target_order_delivery_total">0</h1>
                                                    <h6 class="text-white">Ordenes Totales</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_2 text-center">
                                                    <h1 class="font-light text-white target_order_delivery_verify">0</h1>
                                                    <h6 class="text-white">Por Verificar</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_6 text-center">
                                                    <h1 class="font-light text-white target_order_delivery_kitchen">0</h1>
                                                    <h6 class="text-white">En cocina</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_4 text-center">
                                                    <h1 class="font-light text-white target_order_delivery_delivery">0</h1>
                                                    <h6 class="text-white">Por Despachar</h6>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_1 text-center">
                                                    <h1 class="font-light text-white target_order_delivery_running">0</h1>
                                                    <h6 class="text-white">En camino</h6>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_5BG text-center">
                                                    <h1 class="font-light text-white target_order_delivery_delivered">0</h1>
                                                    <h6 class="text-white">Despachadas</h6>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <button type="button" class="btn bh_1 text-white mb-3 btnOrder" data-module-create="Ordenes (delivery)" type_order="delivery">
                                        <i class="fas fa-plus"></i>
                                        Orden
                                    </button>

                                    <ul class="nav nav-tabs" id="myTab" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link active" id="home-tab" data-bs-toggle="tab" data-bs-target="#home-tab-pane" type="button" role="tab" aria-controls="home-tab-pane" aria-selected="true">Pendientes</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="profile-tab" data-bs-toggle="tab" data-bs-target="#profile-tab-pane" type="button" role="tab" aria-controls="profile-tab-pane" aria-selected="false">Procesadas</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="null_order" data-bs-toggle="tab" data-bs-target="#null_order_tab" type="button" role="tab" aria-controls="profile-tab-pane" aria-selected="false">Anuladas</button>
                                        </li>
                                    </ul>
                                    <div class="tab-content" id="myTabContent">
                                        <div class="tab-pane fade show active" id="home-tab-pane" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
                                            <div class="row justify-content-between mt-3">
                                                <div class="col-md-6 col-lg-3">
                                                    <input type="text" class="form-control" id="searchBoxDomicilioPending" placeholder="Buscar">
                                                </div>
                                                <div class="col-md-6 col-lg-9">
                                                </div>
                                            </div>
                                            <div class="table-responsive mt-2">
                                                <table class="table no-wrap table-order-domicilio-pendientes table-dark-mode w-100">
                                                    <thead>
                                                        <tr>
                                                            <th>Estado</th>
                                                            <th>N° Orden</th>
                                                            <th>Cliente</th>
                                                            <th>Fecha</th>
                                                            <th>Hora</th>
                                                            <th>Acciones</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <div class="tab-pane fade" id="profile-tab-pane" role="tabpanel" aria-labelledby="profile-tab" tabindex="0">
                                            <div class="row justify-content-between mt-3">
                                                <div class="col-md-6 col-lg-3">
                                                    <input type="text" class="form-control" id="searchBoxDomicilioProcesadas" placeholder="Buscar">
                                                </div>
                                                <div class="col-md-6 col-lg-9">
                                                </div>
                                            </div>
                                            <div class="table-responsive mt-2">
                                                <table class="table no-wrap table-order-domicilio-procesadas table-dark-mode w-100">
                                                    <thead>
                                                        <tr>
                                                            <th>Estado</th>
                                                            <th>N° Orden</th>
                                                            <th>Cliente</th>
                                                            <th>Fecha</th>
                                                            <th>Hora</th>
                                                            <th>Acciones</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <div class="tab-pane fade" id="null_order_tab" role="tabpanel" aria-labelledby="profile-tab" tabindex="0">
                                            <div class="row justify-content-between mt-3">
                                                <div class="col-md-6 col-lg-3">
                                                    <input type="text" class="form-control" id="searchBoxDomicilioNull" placeholder="Buscar">
                                                </div>
                                                <div class="col-md-6 col-lg-9">
                                                </div>
                                            </div>
                                            <div class="table-responsive mt-2">
                                                <table class="table no-wrap table-order-domicilio-null table-dark-mode w-100">
                                                    <thead>
                                                        <tr>
                                                            <th>Estado</th>
                                                            <th>N° Orden</th>
                                                            <th>Cliente</th>
                                                            <th>Fecha</th>
                                                            <th>Hora</th>
                                                            <th>Acciones</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="tab-pane fade" id="nav-llevar" role="tabpanel" aria-labelledby="nav-profile-tab" tabindex="0">
                                    <div class="row">
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_5BG text-center">
                                                    <h1 class="font-light text-white target_order_llevar_null">0</h1>
                                                    <h6 class="text-white">Pagos nulos</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_1BG text-center">
                                                    <h1 class="font-light text-white target_order_llevar_total">0</h1>
                                                    <h6 class="text-white">Ordenes Totales</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_2 text-center">
                                                    <h1 class="font-light text-white target_order_llevar_verify">0</h1>
                                                    <h6 class="text-white">Por Verificar</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_6 text-center">
                                                    <h1 class="font-light text-white target_order_llevar_kitchen">0</h1>
                                                    <h6 class="text-white">En cocina</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_4 text-center">
                                                    <h1 class="font-light text-white target_order_llevar_delivery">0</h1>
                                                    <h6 class="text-white">Por Despachar</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_5BG text-center">
                                                    <h1 class="font-light text-white target_order_llevar_delivered">0</h1>
                                                    <h6 class="text-white">Despachadas</h6>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <button type="button" class="btn bh_1 text-white mb-3 btnOrder" data-module-create="Ordenes (llevar)" type_order="llevar">
                                        <i class="fas fa-plus"></i>
                                        Orden
                                    </button>

                                    <ul class="nav nav-tabs" id="myTab" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link active" id="home-tab" data-bs-toggle="tab" data-bs-target="#pending" type="button" role="tab">Pendientes</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="profile-tab" data-bs-toggle="tab" data-bs-target="#process" type="button" role="tab">Procesadas</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="profile-tab" data-bs-toggle="tab" data-bs-target="#orderParallevarAnuladas" type="button" role="tab">Anuladas</button>
                                        </li>
                                    </ul>
                                    <div class="tab-content" id="myTabContent">
                                        <div class="tab-pane fade show active" id="pending" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
                                            <div class="row justify-content-between mt-3">
                                                <div class="col-md-6 col-lg-3">
                                                    <input type="text" class="form-control" id="searchBoxLLevarPending" placeholder="Buscar">
                                                </div>
                                                <div class="col-md-6 col-lg-9">
                                                </div>
                                            </div>
                                            <div class="mt-2 table-responsive" style="min-height: 290px;">
                                                <table class="table no-wrap table-order-llevar-pendientes table-dark-mode w-100">
                                                    <thead>
                                                        <tr>
                                                            <th>Estado</th>
                                                            <th>N° Orden</th>
                                                            <th>Cliente</th>
                                                            <th>Fecha</th>
                                                            <th>Hora</th>
                                                            <th>Acciones</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <div class="tab-pane fade show" id="process" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
                                            <div class="row justify-content-between mt-3">
                                                <div class="col-md-6 col-lg-3">
                                                    <input type="text" class="form-control" id="searchBoxllevarProcesadas" placeholder="Buscar">
                                                </div>
                                                <div class="col-md-6 col-lg-9">
                                                </div>
                                            </div>
                                            <div class="table-responsive mt-2" style="min-height: 250px;">
                                                <table class="table no-wrap table-order-llevar-procesadas table-dark-mode w-100">
                                                    <thead>
                                                        <tr>
                                                            <th>Estado</th>
                                                            <th>N° Orden</th>
                                                            <th>Cliente</th>
                                                            <th>Fecha</th>
                                                            <th>Hora</th>
                                                            <th>Acciones</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <div class="tab-pane fade show" id="orderParallevarAnuladas" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
                                            <div class="row justify-content-between mt-3">
                                                <div class="col-md-6 col-lg-3">
                                                    <input type="text" class="form-control" id="searchBoxllevarAnuladas" placeholder="Buscar">
                                                </div>
                                                <div class="col-md-6 col-lg-9">
                                                </div>
                                            </div>
                                            <div class="table-responsive mt-2" style="min-height: 250px;">
                                                <table class="table no-wrap table-order-llevar-anuladas table-dark-mode w-100">
                                                    <thead>
                                                        <tr>
                                                            <th>Estado</th>
                                                            <th>N° Orden</th>
                                                            <th>Cliente</th>
                                                            <th>Fecha</th>
                                                            <th>Hora</th>
                                                            <th>Acciones</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="tab-pane fade" id="nav-local" role="tabpanel" aria-labelledby="nav-contact-tab" tabindex="0">
                                    <div class="row">
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_1BG text-center">
                                                    <h1 class="font-light text-white target_order_local_total">0</h1>
                                                    <h6 class="text-white">Ordenes Totales</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_2 text-center">
                                                    <h1 class="font-light text-white target_order_local_perpayment">0</h1>
                                                    <h6 class="text-white">Por Pagar</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_6 text-center">
                                                    <h1 class="font-light text-white target_order_local_kitchen">0</h1>
                                                    <h6 class="text-white">En cocina</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_4 text-center">
                                                    <h1 class="font-light text-white target_order_local_intable">0</h1>
                                                    <h6 class="text-white">En mesa</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_5BG text-center">
                                                    <h1 class="font-light text-white target_order_local_payed">0</h1>
                                                    <h6 class="text-white">Pagadas</h6>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <button type="button" class="btn bh_1 text-white mb-3 btn_order_local" data-module-create="Ordenes (local)" type_order="local">
                                        <i class="fas fa-plus"></i>
                                        Orden
                                    </button>

                                    <ul class="nav nav-tabs" id="myTab2" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link active" id="home-tab2" data-bs-toggle="tab" data-bs-target="#home-tab-pane2" type="button" role="tab" aria-controls="home-tab-pane" aria-selected="true">Pendientes</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="profile-tab2" data-bs-toggle="tab" data-bs-target="#profile-tab-pane2" type="button" role="tab" aria-controls="profile-tab-pane" aria-selected="false">Procesadas</button>
                                        </li>
                                    </ul>
                                    <div class="tab-content" id="myTabContent">
                                        <div class="tab-pane fade show active" id="home-tab-pane2" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
                                            <div class="row justify-content-between mt-3">
                                                <div class="col-md-6 col-lg-3">
                                                    <input type="text" class="form-control" id="searchBoxLocalPending" placeholder="Buscar">
                                                </div>
                                                <div class="col-md-6 col-lg-9">
                                                </div>
                                            </div>
                                            <div class="table-responsive mt-2" style="min-height: 290px;">
                                                <table class="table no-wrap table-order-local-pendientes table-dark-mode w-100">
                                                    <thead>
                                                        <tr>
                                                            <th>Estado</th>
                                                            <th>N° Orden</th>
                                                            <th>Fecha</th>
                                                            <th>Hora</th>
                                                            <th>Acciones</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <div class="tab-pane fade" id="profile-tab-pane2" role="tabpanel" aria-labelledby="profile-tab" tabindex="0">
                                            <div class="row justify-content-between mt-3">
                                                <div class="col-md-6 col-lg-3">
                                                    <input type="text" class="form-control" id="searchBoxLocalProcesadas" placeholder="Buscar">
                                                </div>
                                                <div class="col-md-6 col-lg-9">
                                                </div>
                                            </div>
                                            <div class="table-responsive mt-2" style="min-height: 290px;">
                                                <table class="table no-wrap table-order-local-procesadas table-dark-mode w-100">
                                                    <thead>
                                                        <tr>
                                                            <th>Estado</th>
                                                            <th>N° Orden</th>
                                                            <th>Cliente</th>
                                                            <th>Fecha</th>
                                                            <th>Hora</th>
                                                            <th>Acciones</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="tab-pane fade" id="nav-res" role="tabpanel" aria-labelledby="nav-res-tab" tabindex="0">
                                    <div class="row">
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_1BG text-center">
                                                    <h1 class="font-light text-white target_order_reserva_total">0</h1>
                                                    <h6 class="text-white">Ordenes Totales</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_6 text-center">
                                                    <h1 class="font-light text-white target_order_reserva_kitchen">0</h1>
                                                    <h6 class="text-white">En cocina</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_2 text-center">
                                                    <h1 class="font-light text-white target_order_reserva_intable">0</h1>
                                                    <h6 class="text-white">En mesa</h6>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Column -->
                                        <div class="col-md-6 col-lg col-xlg-3">
                                            <div class="card card-hover">
                                                <div class="p-2 bh_5BG text-center">
                                                    <h1 class="font-light text-white target_order_reserva_payed">0</h1>
                                                    <h6 class="text-white">Despachadas</h6>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <ul class="nav nav-tabs" id="myTab3" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link active" id="home-tab3" data-bs-toggle="tab" data-bs-target="#home-tab-pane3" type="button" role="tab" aria-controls="home-tab-pane" aria-selected="true">Pendientes</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="profile-tab3" data-bs-toggle="tab" data-bs-target="#profile-tab-pane3" type="button" role="tab" aria-controls="profile-tab-pane" aria-selected="false">Procesadas</button>
                                        </li>
                                    </ul>
                                    <div class="tab-content" id="myTabContent">
                                        <div class="tab-pane fade show active" id="home-tab-pane3" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
                                            <div class="row justify-content-between mt-3">
                                                <div class="col-md-6 col-lg-3">
                                                    <input type="text" class="form-control" id="searchBoxResPending" placeholder="Buscar">
                                                </div>
                                                <div class="col-md-6 col-lg-9">
                                                </div>
                                            </div>
                                            <div class="table-responsive mt-2" style="min-height: 290px;">
                                                <table class="table no-wrap table-order-res-pendientes table-dark-mode w-100">
                                                    <thead>
                                                        <tr>
                                                            <th>Estado</th>
                                                            <th>N° Orden</th>
                                                            <th>Fecha Reser.</th>
                                                            <th>Hora Reser.</th>
                                                            <th>Acciones</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <div class="tab-pane fade" id="profile-tab-pane3" role="tabpanel" aria-labelledby="profile-tab" tabindex="0">
                                            <div class="row justify-content-between mt-3">
                                                <div class="col-md-6 col-lg-3">
                                                    <input type="text" class="form-control" id="searchBoxResProcesadas" placeholder="Buscar">
                                                </div>
                                                <div class="col-md-6 col-lg-9">
                                                </div>
                                            </div>
                                            <div class="table-responsive mt-2" style="min-height: 290px;">
                                                <table class="table no-wrap table-order-res-procesadas table-dark-mode w-100">
                                                    <thead>
                                                        <tr>
                                                            <th>Estado</th>
                                                            <th>N° Orden</th>
                                                            <th>Fecha Reser.</th>
                                                            <th>Hora Reser.</th>
                                                            <th>Acciones</th>
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
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>
    </div>
    <?php include_once __DIR__ . '/../views/Components/modals/order/domicile_and_takeaway.php' ?>
    <?php include_once __DIR__ . '/../views/Components/modals/order/modalDetailsOrder.php' ?>
    <?php include_once __DIR__ . '/../views/Components/modals/order/local.php' ?>
    <?php include_once __DIR__ . '/../views/Components/modals/order/more_products.php' ?>
    <?php include_once __DIR__ . '/../views/Components/modals/order/payment_order_local.php' ?>
    <?php include_once __DIR__ . '/../views/Components/modals/order/payment_order_reservation.php' ?>

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
<script src="./assets/libs/libs/popper.js/dist/umd/popper.min.js"></script>
<script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
<script src="./assets/libs/extra-libs/datatables.net/js/jquery.dataTables.js"></script>
<script src="./assets/libs/extra-libs/datatables.net-bs4/js/dataTables.responsive.min.js"></script>
<script src="./assets/js/app-style-switcher.js"></script>
<script src="./assets/js/feather.min.js"></script>
<script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
<script src="./assets/js/sidebarmenu.js"></script>
<script src="./assets/js/custom.min.js"></script>
<script src="./assets/libs/libs/daysjs/dayjs.min.js"></script>
<script src="./assets/libs/libs/daysjs/es.js"></script>
<script src="./assets/libs/libs/daysjs/relativeTime.js"></script>
<script src="./assets/libs/libs/jspdf/jspdf.umd.min.js"></script>
<script src="./assets/libs/libs/tagify/tagify.js"></script>
<script src="./assets/libs/libs/tagify/tagify.polyfills.min.js"></script>
<script type="module" src="./assets/js/pages/order/domicile_and_takeaway.js"></script>
<script type="module" src="./assets/js/pages/order/order.js"></script>
<script type="module" src="./assets/js/pages/order/local.js"></script>
<script src="./assets/libs/libs/bs-stepper/bs-stepper.min.js"></script>