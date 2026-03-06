<aside class="left-sidebar" data-sidebarbg="skin6">
    <!-- Sidebar scroll-->
    <div class="scroll-sidebar" data-sidebarbg="skin6">
        <!-- Sidebar navigation-->
        <nav class="sidebar-nav">
            <ul id="sidebarnav">

                <li class="sidebar-item">
                    <a class="sidebar-link sidebar-link" href="home"
                        aria-expanded="false"><i data-feather="home" class="feather-icon"></i><span
                            class="hide-menu">Dashboard</span>
                    </a>
                </li>

                <li class="list-divider"></li>

                <li class="nav-small-cap"><span class="hide-menu">Aplicaciones</span></li>

                <?php
                $tieneOrdenes = false;
                $tieneDelivery = false;

                foreach ($_SESSION['permisos'] as $permiso) {
                    $mod = strtolower($permiso['modulo']);
                    $act = $permiso['permisos'];
                    if ($mod === 'ordenes' && $act) $tieneOrdenes = true;
                    if ($mod === 'delivery' && $act) $tieneDelivery = true;
                }

                if ($tieneOrdenes || $tieneDelivery) { ?>
                    <li class="sidebar-item">
                        <a class="sidebar-link has-arrow" href="javascript:void(0)" aria-expanded="false">
                            <i data-feather="truck" class="feather-icon"></i>
                            <span class="hide-menu">Pedidos y entregas</span>
                        </a>
                        <ul aria-expanded="false" class="collapse first-level base-level-line">
                            <?php if ($tieneOrdenes) { ?>
                                <li class="sidebar-item module_link">
                                    <a href="orden" class="sidebar-link">
                                        <span class="hide-menu">Ordenes</span>
                                    </a>
                                </li>
                            <?php } ?>
                            <?php if ($tieneDelivery) { ?>
                                <li class="sidebar-item module_link">
                                    <a href="delivery" class="sidebar-link">
                                        <span class="hide-menu"> Delivery </span>
                                    </a>
                                </li>
                            <?php } ?>
                        </ul>
                    </li>
                <?php } ?>


                <?php for ($i = 0; $i < count($_SESSION['permisos']); $i++) { ?>

                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'cocina' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link" href="cocina"
                                aria-expanded="false">
                                <i data-feather="coffee" class="feather-icon"></i>
                                <span class="hide-menu">Cocina</span>
                            </a>
                        </li>
                    <?php } ?>

                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'mesas' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link" href="mesas"
                                aria-expanded="false">
                                <i data-feather="grid" class="feather-icon"></i>
                                <span class="hide-menu">Mesas</span>
                            </a>
                        </li>
                    <?php } ?>

                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'estadisticas' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link" href="estadisticas"
                                aria-expanded="false">
                                <i data-feather="bar-chart" class="feather-icon"></i>
                                <span class="hide-menu">Estadisticas</span>
                            </a>
                        </li>
                    <?php } ?>

                <?php  } ?>

                <?php
                $reservaciones = false;
                $paquetes = false;

                foreach ($_SESSION['permisos'] as $permiso) {
                    $mod = strtolower($permiso['modulo']);
                    $act = $permiso['permisos'];
                    if ($mod === 'paquetes' && $act) $paquetes = true;
                    if ($mod === 'reservaciones' && $act) $reservaciones = true;
                }

                if ($paquetes || $reservaciones) { ?>
                    <li class="sidebar-item">
                        <a class="sidebar-link has-arrow" href="javascript:void(0)" aria-expanded="false">
                            <i data-feather="calendar" class="feather-icon"></i>
                            <span class="hide-menu">Calendario</span>
                        </a>
                        <ul aria-expanded="false" class="collapse first-level base-level-line">
                            <?php if ($reservaciones) { ?>
                                <li class="sidebar-item module_link">
                                    <a href="calendario" class="sidebar-link">
                                        <span class="hide-menu">Reservaciones</span>
                                    </a>
                                </li>
                            <?php } ?>
                            <?php if ($paquetes) { ?>
                                <li class="sidebar-item module_link">
                                    <a href="paquete_reservacion" class="sidebar-link">
                                        <span class="hide-menu">Paquetes de reservaciones</span>
                                    </a>
                                </li>
                            <?php } ?>
                        </ul>
                    </li>
                <?php } ?>


                <?php for ($i = 0; $i < count($_SESSION['permisos']); $i++) { ?>
                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'bitacora' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="bitacora"
                                aria-expanded="false">
                                <i data-feather="book-open" class="feather-icon"></i>
                                <span class="hide-menu">Bitacora</span>
                            </a>
                        </li>
                    <?php } ?>

                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'capital' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="capital"
                                aria-expanded="false">
                                <i data-feather="credit-card" class="feather-icon"></i>
                                <span class="hide-menu">Capital</span>
                            </a>
                        </li>
                    <?php } ?>

                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'papelera' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="papelera"
                                aria-expanded="false">
                                <i data-feather="trash-2" class="feather-icon"></i>
                                <span class="hide-menu">Papelera</span>
                            </a>
                        </li>
                    <?php } ?>
                <?php  } ?>

                <li class="list-divider"></li>
                <li class="nav-small-cap"><span class="hide-menu">Modulos</span></li>

                <?php
                $tieneProductoPreparado = false;
                $tieneMateriaPrima = false;
                $tieneRecetas = false;
                $tieneAdicionales = false;

                foreach ($_SESSION['permisos'] as $permiso) {
                    $modulo = strtolower($permiso['modulo']);
                    $activo = $permiso['permisos'];

                    if ($modulo === 'producto preparado' && $activo) $tieneProductoPreparado = true;
                    if ($modulo === 'materia prima' && $activo) $tieneMateriaPrima = true;
                    if ($modulo === 'recetas' && $activo) $tieneRecetas = true;
                    if ($modulo === 'adicionales' && $activo) $tieneAdicionales = true;
                }

                if ($tieneProductoPreparado || $tieneMateriaPrima || $tieneRecetas || $tieneAdicionales) { ?>
                    <li class="sidebar-item">
                        <a class="sidebar-link has-arrow" href="#" aria-expanded="false">
                            <i data-feather="sunset" class="feather-icon"></i>
                            <span class="hide-menu">Produc Preparados</span>
                        </a>
                        <ul aria-expanded="false" class="collapse first-level base-level-line">
                            <?php if ($tieneProductoPreparado) { ?>
                                <li class="sidebar-item module_link">
                                    <a href="producto_preparado" class="sidebar-link">
                                        <span class="hide-menu">Producto</span>
                                    </a>
                                </li>
                            <?php } ?>
                            <?php if ($tieneMateriaPrima) { ?>
                                <li class="sidebar-item module_link">
                                    <a href="materia_prima" class="sidebar-link">
                                        <span class="hide-menu">Materia Prima</span>
                                    </a>
                                </li>
                            <?php } ?>
                            <?php if ($tieneRecetas) { ?>
                                <li class="sidebar-item module_link">
                                    <a href="recetas" class="sidebar-link">
                                        <span class="hide-menu">Recetas</span>
                                    </a>
                                </li>
                            <?php } ?>
                            <?php if ($tieneAdicionales) { ?>
                                <li class="sidebar-item module_link">
                                    <a href="adicionales" class="sidebar-link">
                                        <span class="hide-menu">Adicionales</span>
                                    </a>
                                </li>
                            <?php } ?>
                        </ul>
                    </li>
                <?php } ?>

                <?php for ($i = 0; $i < count($_SESSION['permisos']); $i++) { ?>
                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'producto procesado' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="producto_procesado"
                                aria-expanded="false">
                                <i data-feather="codepen" class="feather-icon"></i>
                                <span class="hide-menu">Produc Procesados</span>
                            </a>
                        </li>
                    <?php } ?>

                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'proveedores' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="proveedor"
                                aria-expanded="false">
                                <i data-feather="bookmark" class="feather-icon"></i>
                                <span
                                    class="hide-menu">Proveedores
                                </span>
                            </a>
                        </li>
                    <?php } ?>

                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'clientes' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="clients"
                                aria-expanded="false">
                                <i data-feather="users" class="feather-icon"></i>
                                <span
                                    class="hide-menu">Clientes
                                </span>
                            </a>
                        </li>
                    <?php } ?>

                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'caja' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="caja"
                                aria-expanded="false">
                                <i data-feather="inbox" class="feather-icon"></i>
                                <span
                                    class="hide-menu">Caja
                                </span>
                            </a>
                        </li>
                    <?php } ?>
                <?php  } ?>



                <?php
                $invoice = false;

                foreach ($_SESSION['permisos'] as $permiso) {
                    $mod = strtolower($permiso['modulo']);
                    $act = $permiso['permisos'];
                    if ($mod === 'facturas' && $act) $invoice = true;
                }

                if ($invoice) { ?>
                    <li class="sidebar-item" data-module="Facturacion">
                        <a class="sidebar-link has-arrow" href="javascript:void(0)"
                            aria-expanded="false">
                            <i data-feather="shopping-bag" class="feather-icon"></i>
                            <span class="hide-menu">Facturación</span>
                        </a>
                        <ul aria-expanded="false" class="collapse  first-level base-level-line">
                            <li class="sidebar-item">
                                <a href="invoice" class="sidebar-link">
                                    <span
                                        class="hide-menu">Facturas
                                    </span>
                                </a>
                            </li>
                        </ul>
                    </li>
                <?php } ?>


                <?php for ($i = 0; $i < count($_SESSION['permisos']); $i++) { ?>
                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'unidades' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="unidades"
                                aria-expanded="false">
                                <i data-feather="flag" class="feather-icon"></i>
                                <span
                                    class="hide-menu">Unidades
                                </span>
                            </a>
                        </li>
                    <?php } ?>

                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'categorias' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="category"
                                aria-expanded="false">
                                <i data-feather="flag" class="feather-icon"></i>
                                <span
                                    class="hide-menu">Categorias
                                </span>
                            </a>
                        </li>
                    <?php } ?>

                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'metodo pago' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="metodos_de_pago"
                                aria-expanded="false">
                                <i data-feather="award" class="feather-icon"></i>
                                <span
                                    class="hide-menu">Metodos de pago
                                </span>
                            </a>
                        </li>
                    <?php } ?>
                <?php  } ?>


                <li class="list-divider"></li>
                <li class="nav-small-cap"><span class="hide-menu">Autenticación</span></li>

                <?php for ($i = 0; $i < count($_SESSION['permisos']); $i++) { ?>
                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'roles y permisos' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="permisos"
                                aria-expanded="false">
                                <i data-feather="lock" class="feather-icon"></i>
                                <span
                                    class="hide-menu">Roles y permisos
                                </span>
                            </a>
                        </li>
                    <?php } ?>

                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'mantenimiento' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="mantenimiento"
                                aria-expanded="false">
                                <i data-feather="monitor" class="feather-icon"></i>
                                <span
                                    class="hide-menu">Mantenimiento
                                </span>
                            </a>
                        </li>
                    <?php } ?>

                    <?php if (strtolower($_SESSION['permisos'][$i]['modulo']) == 'usuarios' && $_SESSION['permisos'][$i]['permisos']) { ?>
                        <li class="sidebar-item module_link">
                            <a class="sidebar-link sidebar-link" href="users"
                                aria-expanded="false">
                                <i data-feather="user" class="feather-icon"></i>
                                <span
                                    class="hide-menu">Usuarios
                                </span>
                            </a>
                        </li>
                    <?php } ?>
                <?php  } ?>

                <li class="list-divider"></li>
                <li class="nav-small-cap"><span class="hide-menu">Extra</span></li>
                <li class="sidebar-item">
                    <a class="sidebar-link sidebar-link logout_btn" style="cursor: pointer;"
                        aria-expanded="false">
                        <i data-feather="log-out" class="feather-icon"></i>
                        <span class="hide-menu">Logout</span>
                    </a>
                </li>

            </ul>
        </nav>
    </div>
</aside>