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
                    <h3 class="page-title text-truncate text-dark font-weight-medium mb-1">Estadisticas</h3>
                    <div class="d-flex align-items-center">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb m-0 p-0">
                                <li class="breadcrumb-item"><a href="home" class="text-muted">Aplicaciones</a></li>
                                <li class="breadcrumb-item text-muted active" aria-current="page">Estadisticas</li>
                            </ol>
                        </nav>
                    </div>
                </div>

                <?php include_once __DIR__ . '/../views/Components/BoxAndDolar.php' ?>

            </div>
        </div>

        <div class="container-fluid">
            <div class="row">
                <div class="col-lg-7 col-md-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex align-items-start flex-wrap justify-content-between">
                                <div>
                                    <h4 class="card-title">Gasto Promedio (Clientes)</h4>
                                    <p class="fs-6 type_flter_date" type_temporality="week">Semana 14 de Febrero del 2025</p>
                                </div>
                                <div class=" d-flex align-items-center gap-2">
                                    <select class="form-select form_select_type_filter" graphic="Gasto Promedio">
                                        <option disabled value="s/v">Tipo de filtro</option>
                                        <option selected value="Semana/mes/año">Semana/mes/año</option>
                                        <option value="Mes/Año">Mes/Año</option>
                                        <option value="Año">Año</option>
                                    </select>
                                    <a class="link-secondary text-muted btn_print_graphic" graphic="Gasto Promedio" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-title="Descargar PDF">
                                        <i data-feather="download"></i>
                                    </a>
                                </div>
                            </div>
                            <div>
                                <form class="row g-3 container_inputs_filter" graphic="Gasto Promedio">
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
                                <canvas class="mt-1 position-relative mt-2 w-100 h-25" id="ticketChart"></canvas>
                                <div class="container-leyend_gasto_cliente">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
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
                                    <a class="link-secondary text-muted btn_print_graphic" graphic="Total de ventas" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-title="Descargar PDF">
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
            </div>

            <div class="row">
                <div class="col-lg-6 col-md-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex align-items-start justify-content-between">
                                <div class="mb-1">
                                    <h4 class="card-title">Porcentaje de reservaciones(horario)</h4>
                                    <p class="fs-6 type_flter_date" type_temporality="anual"></p>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <select class="form-select form_select_type_filter" graphic="Porcentaje de reservaciones">
                                        <option disabled value="s/v">Tipo de filtro</option>
                                        <option value="Semana/mes/año">Semana/mes/año</option>
                                        <option value="Mes/Año">Mes/Año</option>
                                        <option selected value="Año">Año</option>
                                    </select>
                                    <a class="link-secondary text-muted btn_print_graphic" graphic="Porcentaje de reservaciones" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-title="Descargar PDF">
                                        <i data-feather="download"></i>
                                    </a>
                                </div>
                            </div>
                            <div>
                                <form class="row g-3 container_inputs_filter" graphic="Porcentaje de reservaciones">
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
                                <canvas id="ocupacionChart" class="w-100"></canvas>
                            </div>
                            <div class="container_leyend_porcentaje_reservas">
                                <!-- leyenda -->
                            </div>
                        </div>
                    </div>


                </div>
                <div class="col-lg-6 col-md-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex align-items-start justify-content-between">
                                <div class="mb-1">
                                    <h4 class="card-title">Porcentaje de reservaciones(metodo)</h4>
                                    <p class="fs-6 type_flter_date" type_temporality="anual"></p>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <select class="form-select form_select_type_filter" graphic="reservaciones por metodo">
                                        <option disabled value="s/v">Tipo de filtro</option>
                                        <option value="Semana/mes/año">Semana/mes/año</option>
                                        <option value="Mes/Año">Mes/Año</option>
                                        <option selected value="Año">Año</option>
                                    </select>
                                    <a class="link-secondary text-muted btn_print_graphic" graphic="reservaciones por metodo" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-title="Descargar PDF">
                                        <i data-feather="download"></i>
                                    </a>
                                </div>
                            </div>
                            <div>
                                <form class="row g-3 container_inputs_filter" graphic="reservaciones por metodo">
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
                                <canvas id="ReservasChart"></canvas>
                            </div>
                            <div class="container_leyend_reservas_metodo mt-3">
                                <!-- leyenda -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-12 col-md-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex align-items-start flex-wrap justify-content-between">
                                <div>
                                    <h4 class="card-title">Productos mas vendidos</h4>
                                    <p class="fs-6 type_flter_date" type_temporality="anual">Semana 14 de Febrero del 2025</p>
                                </div>
                                <div class=" d-flex align-items-center gap-2">
                                    <select class="form-select form_select_type_filter" graphic="productos mas vendidos">
                                        <option disabled value="s/v">Tipo de filtro</option>
                                        <option value="Semana/mes/año">Semana/mes/año</option>
                                        <option value="Mes/Año">Mes/Año</option>
                                        <option selected value="Año">Año</option>
                                    </select>
                                    <a class="link-secondary text-muted btn_print_graphic" graphic="productos mas vendidos" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-title="Descargar PDF">
                                        <i data-feather="download"></i>
                                    </a>
                                </div>
                            </div>
                            <div class="mb-3">
                                <form class="row g-3 container_inputs_filter" graphic="productos mas vendidos">
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
                            <div>
                                <canvas class="mb-4" id="productMoreSales"></canvas>
                                <div class="container-leyend_product_more_sales">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-12 col-md-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex align-items-start flex-wrap justify-content-between">
                                <div>
                                    <h4 class="card-title">Productos menos vendidos</h4>
                                    <p class="fs-6 type_flter_date" type_temporality="anual">Semana 14 de Febrero del 2025</p>
                                </div>
                                <div class=" d-flex align-items-center gap-2">
                                    <select class="form-select form_select_type_filter" graphic="productos menos vendidos">
                                        <option disabled value="s/v">Tipo de filtro</option>
                                        <option value="Semana/mes/año">Semana/mes/año</option>
                                        <option value="Mes/Año">Mes/Año</option>
                                        <option selected value="Año">Año</option>
                                    </select>
                                    <a class="link-secondary text-muted btn_print_graphic" graphic="productos menos vendidos" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-title="Descargar PDF">
                                        <i data-feather="download"></i>
                                    </a>
                                </div>
                            </div>
                            <div class="mb-3">
                                <form class="row g-3 container_inputs_filter" graphic="productos menos vendidos">
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
                            <div>
                                <canvas class="mb-4" id="productMinSales"></canvas>
                                <div class="container-leyend_product_min_sales">

                                </div>
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
<script src="./assets/js/feather.min.js"></script>
<script src="./assets/libs/libs/perfect-scrollbar/dist/perfect-scrollbar.jquery.min.js"></script>
<script src="./assets/js/sidebarmenu.js"></script>
<script src="./assets/js/custom.min.js"></script>
<script src="./assets/libs/libs/jspdf/jspdf.umd.min.js"></script>
<script src="./assets/libs/libs/jspdf/jspdf.plugin.autotable.min.js"></script>
<script src="./assets/libs/libs/chart.js/dist/Chart.min.js"></script>
<script src="./assets/libs/libs/chart.js/dist/chartjs-plugin-datalabels.js"></script>
<script type="module" src="./assets/js/pages/statistics/statistics.js"></script>