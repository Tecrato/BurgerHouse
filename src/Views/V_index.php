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
                    <h3 class="page-title text-truncate text-dark font-weight-medium mb-1">Bienvenido, <?php echo ucfirst($_SESSION['nombre']); ?>!</h3>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="home">Dashboard</a>
                                </li>
                            </ol>
                        </nav>
                    </div>
                </div>

                <?php include_once __DIR__ . '/../views/Components/BoxAndDolar.php' ?>

            </div>
        </div>

        <div class="container-fluid">

            <div class="row">
                <div class="col-sm-6 col-lg-3">
                    <div class="card border-end">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div>
                                    <div class="d-inline-flex align-items-center">
                                        <h2 class="text-dark mb-1 font-weight-medium nro_clientes">0</h2>
                                    </div>
                                    <h6 class="text-muted font-weight-normal mb-0 w-100 text-truncate">Clientes
                                    </h6>
                                </div>
                                <div class="ms-auto mt-md-3 mt-lg-0">
                                    <span class="opacity-7 text-muted"><i data-feather="user-plus"></i></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-lg-3">
                    <div class="card border-end ">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div>
                                    <h2 class="text-dark mb-1 w-100 text-truncate font-weight-medium ganancias">0</h2>
                                    <h6 class="text-muted font-weight-normal mb-0 w-100 text-truncate">Ganancias del Mes
                                    </h6>
                                </div>
                                <div class="ms-auto mt-md-3 mt-lg-0">
                                    <span class="opacity-7 text-muted"><i data-feather="dollar-sign"></i></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-lg-3">
                    <div class="card border-end ">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div>
                                    <div class="d-inline-flex align-items-center">
                                        <h2 class="text-dark mb-1 font-weight-medium order_completed">0</h2>
                                    </div>
                                    <h6 class="text-muted font-weight-normal mb-0 w-100 text-truncate">Ordenes Completadas
                                    </h6>
                                </div>
                                <div class="ms-auto mt-md-3 mt-lg-0">
                                    <span class="opacity-7 text-muted"><i data-feather="file-plus"></i></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-lg-3">
                    <div class="card ">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div>
                                    <h2 class="text-dark mb-1 font-weight-medium table_available">0</h2>
                                    <h6 class="text-muted font-weight-normal mb-0 w-100 text-truncate">Mesas Disponibles</h6>
                                </div>
                                <div class="ms-auto mt-md-3 mt-lg-0">
                                    <span class="opacity-7 text-muted"><i data-feather="globe"></i></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-5 col-md-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex align-items-start justify-content-between">
                                <div class="mb-1">
                                    <h4 class="card-title">Total de ventas</h4>
                                    <p class="fs-6 type_flter_date" type_temporality="anual">Semana 14 de Febrero del 2025</p>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <select class="form-select form_select_type_filter" graphic="Total de ventas">
                                        <option disabled value="s/v">Tipo de filtro</option>
                                        <option value="Semana/mes/año">Semana/mes/año</option>
                                        <option value="Mes/Año">Mes/Año</option>
                                        <option selected value="Año">Año</option>
                                    </select>
                                    <a class="link-secondary text-muted  btn_print_graphic" graphic="Total de ventas" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-title="Descargar PDF">
                                        <i data-feather="download"></i>
                                    </a>
                                </div>
                            </div>
                            <div>
                                <form class="row g-3 container_inputs_filter" graphic="Total de ventas">
                                    <div class="col-md-6 d-none" type="week">
                                        <input type="week" class="form-control" id="inputEmail4">
                                    </div>
                                    <div class="col-md-4 d-none" type="month">
                                        <select class="form-select" name="" id="">
                                            <option selected disabled value="s/v">Mes</option>
                                            <option value="1">Enero</option>
                                            <option value="2">Febrero</option>
                                            <option value="3">Marzo</option>
                                            <option value="4">Abril</option>
                                            <option value="5">Mayo</option>
                                            <option value="6">Junio</option>
                                            <option value="7">Julio</option>
                                            <option value="8">Agosto</option>
                                            <option value="9">Septiembre</option>
                                            <option value="10">Octubre</option>
                                            <option value="11">Noviembre</option>
                                            <option value="12">Diciembre</option>
                                        </select>
                                    </div>
                                    <div class="col-md-4" type="year">
                                        <input type="year" placeholder="2025" class="form-control" id="inputEmail4">
                                    </div>
                                    <article class="col-md-3" type="submit">
                                        <button type="submit" class="btn bh_1 text-white">aplicar</button>
                                    </article>
                                </form>
                            </div>
                            <div class="d-flex justify-content-center mt-3 mb-2">
                                <canvas class="w-75 h-25" id="myDonutChart"></canvas>
                            </div>
                            <div class="container_leyend_total_ventas">
                                <!-- leyenda -->
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-7 col-md-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex align-items-start flex-wrap justify-content-between">
                                <div>
                                    <h4 class="card-title">Utilidad neta</h4>
                                    <p class="fs-6 type_flter_date" type_temporality="anio">Semana 14 de Febrero del 2025</p>
                                </div>
                                <div class=" d-flex align-items-center gap-2">
                                    <select class="form-select form_select_type_filter" graphic="Utilidad neta">
                                        <option disabled value="s/v">Tipo de filtro</option>
                                        <option value="Semana/mes/año">Semana/mes/año</option>
                                        <option value="Mes/Año">Mes/Año</option>
                                        <option selected value="Año">Año</option>
                                    </select>
                                    <a class="link-secondary text-muted  btn_print_graphic" graphic="Utilidad neta" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-title="Descargar PDF">
                                        <i data-feather="download"></i>
                                    </a>
                                </div>
                            </div>
                            <div>
                                <form class="row g-3 container_inputs_filter" graphic="Utilidad neta">
                                    <div class="col-md-4 d-none" type="week">
                                        <input type="week" class="form-control" id="inputEmail4">
                                    </div>
                                    <div class="col-md-3 d-none" type="month">
                                        <select class="form-select" name="" id="">
                                            <option selected disabled value="s/v">Mes</option>
                                            <option value="1">Enero</option>
                                            <option value="2">Febrero</option>
                                            <option value="3">Marzo</option>
                                            <option value="4">Abril</option>
                                            <option value="5">Mayo</option>
                                            <option value="6">Junio</option>
                                            <option value="7">Julio</option>
                                            <option value="8">Agosto</option>
                                            <option value="9">Septiembre</option>
                                            <option value="10">Octubre</option>
                                            <option value="11">Noviembre</option>
                                            <option value="12">Diciembre</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3" type="year">
                                        <input type="year" placeholder="2025" class="form-control" id="inputEmail4">
                                    </div>
                                    <article class="col-md-3" type="submit">
                                        <button type="submit" class="btn bh_1 text-white">aplicar</button>
                                    </article>
                                </form>
                            </div>

                            <div id="net_income_container">
                                <canvas class="mt-1 position-relative mt-2 w-100 h-25" id="utilityChart"></canvas>
                                <div class="container-leyend_utilidad">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-8 col-md-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex align-items-start flex-wrap justify-content-between">
                                <div>
                                    <h4 class="card-title">Ingresos</h4>
                                    <p class="fs-6 type_flter_date" type_temporality="anio">Semana 14 de Febrero del 2025</p>
                                </div>
                                <div class=" d-flex align-items-center gap-2">
                                    <select class="form-select form_select_type_filter" graphic="Ingresos">
                                        <option disabled value="s/v">Tipo de filtro</option>
                                        <option selected value="Semana/mes/año">Semana/mes/año</option>
                                        <option value="Mes/Año">Mes/Año</option>
                                        <option value="Año">Año</option>
                                    </select>
                                    <a class="link-secondary text-muted btn_print_graphic" graphic="Ingresos" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-title="Descargar PDF">
                                        <i data-feather="download"></i>
                                    </a>
                                </div>
                            </div>
                            <div>
                                <form class="row g-3 container_inputs_filter" graphic="Ingresos">
                                    <div class="col-md-4" type="week">
                                        <input type="week" class="form-control" id="inputEmail4">
                                    </div>
                                    <div class="col-md-3 d-none" type="month">
                                        <select class="form-select" name="" id="">
                                            <option selected disabled value="s/v">Mes</option>
                                            <option value="1">Enero</option>
                                            <option value="2">Febrero</option>
                                            <option value="3">Marzo</option>
                                            <option value="4">Abril</option>
                                            <option value="5">Mayo</option>
                                            <option value="6">Junio</option>
                                            <option value="7">Julio</option>
                                            <option value="8">Agosto</option>
                                            <option value="9">Septiembre</option>
                                            <option value="10">Octubre</option>
                                            <option value="11">Noviembre</option>
                                            <option value="12">Diciembre</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3 d-none" type="year">
                                        <input type="year" placeholder="2025" class="form-control" id="inputEmail4">
                                    </div>
                                    <article class="col-md-3" type="submit">
                                        <button type="submit" class="btn bh_1 text-white">aplicar</button>
                                    </article>
                                </form>
                            </div>

                            <div id="net_income_container">
                                <canvas class="mt-1 position-relative mt-2 w-100 h-25" id="ingresosChart"></canvas>
                                <div class="container-leyend_ingresos mb-3">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-12 col-lg-4">
                    <div class="card">
                        <div class="card-body">
                            <h4 class="card-title">Mi Actividad Reciente</h4>
                            <div class="mt-4 activity">
                                <!-- con js -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex align-items-center mb-4">
                                <h4 class="card-title">Clientes Frecuentes</h4>
                            </div>
                            <div class="col-md-6 col-lg-3">
                                <input type="search" class="form-control" id="searchClientFrequent" placeholder="Buscar">
                            </div>
                            <div class="table-responsive">
                                <table class="table table-dark-mode no-wrap table_clients w-100">
                                    <thead>
                                        <tr class="border-0">
                                            <th class="border-0 font-14 font-weight-medium text-muted">Nombre
                                            </th>
                                            <th class="border-0 font-14 font-weight-medium text-muted px-2">Producto mas consumido
                                            </th>
                                            <!-- <th class="border-0 font-14 font-weight-medium text-muted">Reservacion</th> -->
                                            <th class="border-0 font-14 font-weight-medium text-muted text-center">Ultima Orden</th>
                                            <th class="border-0 font-14 font-weight-medium text-muted">Dinero gastado</th>
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

        <?php include_once __DIR__ . '/../views/Components/footer.php' ?>
    </div>
</div>



<script src="./assets/libs/libs/jquery/dist/jquery.min.js"></script>
<script src="./assets/libs/libs/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
<script src="./assets/js/app-style-switcher.js"></script>
<script src="./assets/libs/extra-libs/datatables.net/js/jquery.dataTables.js"></script>
<script src="./assets/libs/extra-libs/datatables.net-bs4/js/dataTables.responsive.min.js"></script>
<script src="./assets/js/feather.min.js"></script>
<script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
<script src="./assets/js/sidebarmenu.js"></script>
<script src="./assets/js/custom.min.js"></script>
<script src="./assets/libs/libs/jspdf/jspdf.umd.min.js"></script>
<script src="./assets/libs/libs/jspdf/jspdf.plugin.autotable.min.js"></script>
<script src="./assets/libs/libs/chart.js/dist/Chart.min.js"></script>
<script src="./assets/libs/libs/chart.js/dist/chartjs-plugin-datalabels.js"></script>
<script src="./assets/libs/libs/daysjs/dayjs.min.js"></script>
<script src="./assets/libs/libs/daysjs/es.js"></script>
<script src="./assets/libs/libs/daysjs/relativeTime.js"></script>
<script type="module" defer src="./assets/js/pages/dashboards/dashboard1.js"></script>