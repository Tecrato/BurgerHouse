export default function introTooltip() {
	function additional(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: '.page-title',
							intro: 'Esta es la sección de Adicionales, donde puedes gestionar los productos disponibles en el sistema.',
							position: 'bottom'
						},
						{
							element: '#searchAdditional',
							intro: 'Utiliza este cuadro de búsqueda para filtrar los adicionales disponibles.',
							position: 'top'
						},
						{
							element: '.btn-add-tooltip',
							intro: 'Haz clic aquí para agregar un nuevo adicional.',
							position: 'top'
						},
						{
							element: '.card-body',
							intro: 'Aquí puedes ver la lista de adicionales disponibles. Puedes editar o eliminar cada adicional.',
							position: 'top'
						},
						{
							element: '.cont-product',
							intro: 'Este contenedor muestra los productos preparados disponibles. Puedes editarlos o eliminarlos.',
							position: 'top'
						},
						{
							element: '#top-products',
							intro: 'Esta sección muestra los productos más vendidos y su rendimiento.',
							position: 'top'
						}
					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function binnacleIntro(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs === 'undefined') {
				return;
			}
			let intro = introJs();
			intro.setOptions({
				steps: [
					{
						element: '.page-title',
						intro: 'Esta es la sección de bitácora, donde puedes consultar las actividades realizadas por los usuarios y el sistema.',
						position: 'bottom'
					},
					{
						element: '#home-tab',
						intro: 'Aquí puedes ver tu actividad personal registrada en la bitácora.',
						position: 'bottom'
					},
					{
						element: '#profile-tab',
						intro: 'Aquí puedes consultar las actividades registradas por el sistema.',
						position: 'bottom'
					},
					{
						element: '#searchBinnacleUser',
						intro: 'Utiliza este cuadro de búsqueda para filtrar tu actividad en la bitácora.',
						position: 'top'
					},
					{
						element: '.table_binnacle_user',
						intro: 'Tabla que muestra tu actividad registrada, incluyendo descripción, fecha y hora.',
						position: 'top'
					},
				],
				showBullets: true,
				exitOnOverlayClick: false,
				showProgress: true
			});
			intro.start();
			
		});
	}
	function calendarIntro(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: '.page-title',
							intro: 'Esta es la sección de calendario, donde puedes gestionar eventos y reservaciones.',
							position: 'bottom'
						},
						{
							element: '#calendar-events',
							intro: 'Aquí puedes ver los eventos y reservaciones disponibles. Puedes arrastrarlos al calendario.',
							position: 'right'
						},
						{
							element: '#calendar',
							intro: 'Este es el calendario principal donde puedes visualizar y gestionar tus eventos y reservaciones.',
							position: 'top'
						},
						{
							element: '.fc-prev-button',
							intro: 'Haz clic aquí para navegar al mes anterior en el calendario.',
							position: 'bottom'
						},
						{
							element: '.fc-next-button',
							intro: 'Haz clic aquí para navegar al mes siguiente en el calendario.',
							position: 'bottom'
						},
						{
							element: '.fc-today-button',
							intro: 'Haz clic aquí para volver al día actual en el calendario.',
							position: 'bottom'
						},
						{
							element: '.fc-month-button',
							intro: 'Vista mensual del calendario. Útil para una visión general de los eventos.',
							position: 'bottom'
						},
						{
							element: '.fc-agendaWeek-button',
							intro: 'Vista semanal del calendario. Útil para planificar eventos en detalle.',
							position: 'bottom'
						},
						{
							element: '.fc-agendaDay-button',
							intro: 'Vista diaria del calendario. Útil para gestionar eventos específicos.',
							position: 'bottom'
						}

					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function capital(element) {
		document.getElementById(element).addEventListener('click', function () {
			//null
		});
	}
	function cashIntro(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: '.page-title',
							intro: 'Esta es la sección de caja, donde puedes gestionar las cajas abiertas y cerradas.',
							position: 'bottom'
						},
						{
							element: '.cash_status',
							intro: 'El estado de la caja actual se muestra aquí. Si está abierta, será verde; si está cerrada, será roja.',
							position: 'top'
						},
						{
							element: '#home-tab',
							intro: 'Aquí puedes ver las cajas abiertas actualmente.',
							position: 'bottom'
						},
						{
							element: '#profile-tab',
							intro: 'Aquí puedes consultar las cajas cerradas previamente.',
							position: 'bottom'
						},
						{
							element: '#inputPassword6',
							intro: 'Utiliza este cuadro de búsqueda para filtrar las cajas abiertas o cerradas.',
							position: 'top'
						},
						{
							element: '.bh_1[data-bs-target="#register-cash"]',
							intro: 'Haz clic aquí para registrar una nueva caja.',
							position: 'top'
						},
						{
							element: '.bh_1',
							intro: 'Haz clic aquí para cerrar esta caja.',
							position: 'top'
						},
						{
							element: '.bh_5',
							intro: 'Haz clic aquí para ver los detalles de esta caja.',
							position: 'top'
						},
					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function client(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: '.page-title',
							intro: 'Esta es la sección de clientes, donde puedes gestionar los clientes registrados en el sistema.',
							position: 'bottom'
						},
						{
							element: '.breadcrumb',
							intro: 'Aquí puedes ver la ruta de navegación actual dentro de la aplicación.',
							position: 'top'
						},
						{
							element: '#SearchClients',
							intro: 'Utiliza este cuadro de búsqueda para filtrar los clientes registrados.',
							position: 'top'
						},
						{
							element: '.btn-circle[data-bs-target="#register-client"]',
							intro: 'Haz clic aquí para agregar un nuevo cliente.',
							position: 'top'
						},
						{
							element: '#btn-report',
							intro: 'Haz clic aquí para generar un reporte de los clientes registrados.',
							position: 'top'
						},
						{
							element: '.container_clients',
							intro: 'Este contenedor muestra los clientes registrados. Puedes editarlos o eliminarlos.',
							position: 'top'
						},
						{
							element: '.edit_btn[data-bs-target="#edit-client"]',
							intro: 'Este es el botón para editar un cliente existente. Aquí puedes actualizar los detalles del cliente.',
							position: 'top'
						},
						{
							element: '.trash_btn',
							intro: 'Este es el modal para registrar un nuevo cliente. Aquí puedes ingresar los detalles del cliente.',
							position: 'top'
						},
					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function dashboard(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: '.page-title',
							intro: 'Este es el título principal del dashboard, donde se muestra un saludo personalizado.',
							position: 'bottom'
						},
						{
							element: '.breadcrumb',
							intro: 'Aquí puedes navegar entre las secciones del dashboard.',
							position: 'top'
						},
						{
							element: '.col-sm-6:nth-child(1)',
							intro: 'Esta tarjeta muestra el número de nuevos clientes registrados.',
							position: 'right'
						},
						{
							element: '.col-sm-6:nth-child(2)',
							intro: 'Aquí puedes ver las ganancias del mes.',
							position: 'right'
						},
						{
							element: '.col-sm-6:nth-child(3)',
							intro: 'Esta tarjeta muestra las órdenes completadas.',
							position: 'right'
						},
						{
							element: '.col-sm-6:nth-child(4)',
							intro: 'Aquí puedes ver el número de mesas disponibles.',
							position: 'right'
						},
						{
							element: '#campaign-v2',
							intro: 'Este gráfico muestra el total de ventas divididas entre Delivery y Local.',
							position: 'top'
						},
						{
							element: '.net-income',
							intro: 'Este gráfico muestra la ganancia neta y permite buscar datos por año.',
							position: 'top'
						},
						{
							element: '.stats',
							intro: 'Este gráfico muestra las ganancias semanales.',
							position: 'top'
						},
						{
							element: '.activity',
							intro: 'Aquí puedes ver la actividad reciente, como nuevas órdenes y alertas de stock.',
							position: 'top'
						},
						{
							element: '.table',
							intro: 'Esta tabla muestra información sobre los clientes frecuentes.',
							position: 'top'
						}

					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function order(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: document.querySelector('.page-wrapper'),
							intro: 'Bienvenido a la seccion de ordenes a domicilio, para llevar y del local, aqui podras gestionar todas las ordenes de tu negocio.',
							position: 'bottom'
						},
						{
							element: document.querySelector('#nav-domicilio-tab'),
							intro: 'Aqui podras ver todas las ordenes a domicilio, puedes filtrar por estado.',
							position: 'bottom'
						},
						{
							element: document.querySelector('#nav-llevar-tab'),
							intro: 'Aqui podras ver todas las ordenes para llevar, puedes filtrar por estado.',
							position: 'bottom'
						},
						{
							element: document.querySelector('#nav-local-tab'),
							intro: 'Aqui podras ver todas las ordenes locales, puedes filtrar por estado.',
							position: 'bottom'
						},
						{
							element: document.querySelector('.target_order_delivery_null'),
							intro: 'Ordenes anuladas a domicilio',
							position: 'bottom'
						},
						{
							element: document.querySelector('.target_order_delivery_total'),
							intro: 'Total de ordenes a domicilio',
							position: 'bottom'
						},
						{
							element: document.querySelector('.target_order_delivery_verify'),
							intro: 'Ordenes a domicilio por verificar',
							position: 'bottom'
						},
						{
							element: document.querySelector('.target_order_delivery_kitchen'),
							intro: 'Ordenes para llevar en cocina',
							position: 'bottom'
						},
						{
							element: document.querySelector('.target_order_delivery_delivery'),
							intro: 'Ordenes a domicilio en proceso de entrega',
							position: 'bottom'
						},
						{
							element: document.querySelector('.target_order_delivery_delivered'),
							intro: 'Ordenes a domicilio entregadas',
							position: 'bottom'
						},
						{
							element: document.querySelector('.btnOrder'),
							intro: 'Generar una nueva orden a domicilio.',
							position: 'bottom'
						},
						{
							element: document.querySelector('#home-tab'),
							intro: 'Ordenes a domicilio por verificar ',
							position: 'bottom'
						},
						{
							element: document.querySelector('#profile-tab'),
							intro: 'Ordenes a domicilio en proceso',
							position: 'bottom'
						},
						{
							element: document.querySelector('#null_order'),
							intro: 'Ordenes a domicilio anuladas',
							position: 'bottom'
						},
						{
							element: '#searchBoxDomicilioPending',
							intro: 'Utiliza este cuadro de búsqueda para filtrar las órdenes pendientes a domicilio.',
							position: 'bottom'
						},
						{
							element: document.querySelector('.table-order-domicilio-pendientes'),
							intro: 'Tabla de ordenes a domicilio pendientes, puedes ver el detalle de la orden, los datos del pago y verificar o anular la orden.',
							position: 'bottom'
						}
					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function productPrepared(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: '.page-title',
							intro: 'Esta es la sección de productos preparados, donde puedes gestionar los productos disponibles en el sistema.',
							position: 'bottom'
						},
						{
							element: '#searchProduct',
							intro: 'Utiliza este cuadro de búsqueda para filtrar los productos preparados.',
							position: 'top'
						},
						{
							element: '.btn-add-tooltip',
							intro: 'Haz clic aquí para agregar un nuevo producto preparado.',
							position: 'top'
						},
						{
							element: '#categories',
							intro: 'Aquí puedes ver las categorías disponibles para los productos preparados. Selecciona una categoría para filtrar los productos preparados por tipo.',
							position: 'top'
						},
						{
							element: '.cont-product',
							intro: 'Este contenedor muestra los productos preparados disponibles. Puedes editarlos o eliminarlos.',
							position: 'top'
						},
						{
							element: '#top-products',
							intro: 'Esta sección muestra los productos más vendidos y su rendimiento.',
							position: 'top'
						}
					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function productProcessIntro(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: '.page-title',
							intro: 'Esta es la sección de productos procesados, donde puedes gestionar los productos disponibles en el sistema.',
							position: 'bottom'
						},
						{
							element: '#searchProduct',
							intro: 'Utiliza este cuadro de búsqueda para filtrar los productos procesados.',
							position: 'top'
						},
						{
							element: '.btn-add-tooltip',
							intro: 'Haz clic aquí para agregar un nuevo producto preparado.',
							position: 'top'
						},
						{
							element: '#categories',
							intro: 'Aquí puedes ver las categorías disponibles para los productos procesados. Selecciona una categoría para filtrar los productos procesados por tipo.',
							position: 'top'
						},
						{
							element: '.cont-product',
							intro: 'Este contenedor muestra los productos procesados disponibles. Puedes editarlos o eliminarlos.',
							position: 'top'
						},
						{
							element: '#top-products',
							intro: 'Esta sección muestra los productos más vendidos y su rendimiento.',
							position: 'top'
						}
					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function rawMaterial(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: '.page-title',
							intro: 'Esta es la sección de Materia Prima, donde puedes gestionar las materias primas utilizadas en los productos preparados.',
							position: 'bottom'
						},
						{
							element: '#nav-home-tab',
							intro: 'Haz clic aquí para ver y gestionar las materias primas disponibles.',
							position: 'bottom'
						},
						{
							element: '#nav-profile-tab',
							intro: 'Haz clic aquí para ver y gestionar las entradas de materias primas.',
							position: 'bottom'
						},
						{
							element: '#searchRawmaterial',
							intro: 'Utiliza este cuadro de búsqueda para filtrar las materias primas disponibles.',
							position: 'top'
						},
						{
							element: '.btn-circle[data-bs-target="#register-rawMaterial"]',
							intro: 'Haz clic aquí para agregar una nueva materia prima.',
							position: 'top'
						},
						{
							element: '.table_rawmaterial',
							intro: 'Esta tabla muestra las materias primas disponibles. Puedes editarlas o eliminarlas.',
							position: 'top'
						},
					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function recipe(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: '.page-title',
							intro: 'Esta es la sección de recetas, donde puedes gestionar las recetas de los productos preparados.',
							position: 'bottom'
						},
						{
							element: '#inputPassword6',
							intro: 'Utiliza este cuadro de búsqueda para filtrar las recetas disponibles.',
							position: 'top'
						},
						{
							element: '.bh_1',
							intro: 'Haz clic aquí para agregar una nueva receta.',
							position: 'top'
						},
						{
							element: '.cont_recipe',
							intro: 'Este contenedor muestra las recetas disponibles. Puedes editarlas.',
							position: 'top'
						},
					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function statistics(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: '.page-title',
							intro: 'Esta es la sección de estadísticas, donde puedes analizar el rendimiento del restaurante.',
							position: 'bottom'
						},
						{
							element: '#ticketChart',
							intro: 'Gráfica de gasto promedio por cliente. Aquí puedes observar el rendimiento semanal.',
							position: 'top'
						},
						{
							element: '#filter-ticketChart',
							intro: 'Utiliza este filtro para cambiar el rango de fechas de la gráfica de Gasto Promedio.',
							position: 'top'
						},
						{
							element: '#pdf_net_income',
							intro: 'Haz clic aquí para descargar un informe en PDF de las estadísticas actuales.',
							position: 'left'
						},
						{
							element: '#myDonutChart',
							intro: 'Gráfica de ventas totales divididas entre Delivery y Local.',
							position: 'top'
						},
						{
							element: '#ocupacionChart',
							intro: 'Gráfica de ocupación por horario. Muestra el porcentaje de mesas ocupadas en diferentes franjas horarias.',
							position: 'top'
						},
						{
							element: '#ReservasChart',
							intro: 'Gráfica de reservas por canales. Identifica los métodos de reserva más utilizados por los clientes.',
							position: 'top'
						},
						{
							element: '#productMoreSales',
							intro: 'Gráfica de productos más vendidos. Analiza los productos con mayor demanda.',
							position: 'top'
						},
						{
							element: '#productMinSales',
							intro: 'Gráfica de productos menos vendidos. Identifica los productos con menor rendimiento.',
							position: 'top'
						},
					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function supplier(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: '.page-title',
							intro: 'Esta es la sección de proveedores, donde puedes gestionar los proveedores registrados en el sistema.',
							position: 'bottom'
						},
						{
							element: '.breadcrumb',
							intro: 'Aquí puedes ver la ruta de navegación actual dentro de la aplicación.',
							position: 'top'
						},
						{
							element: '#SearchSupplier',
							intro: 'Utiliza este cuadro de búsqueda para filtrar los proveedores registrados.',
							position: 'top'
						},
						{
							element: '.btn-circle[data-bs-target="#register-supplier"]',
							intro: 'Haz clic aquí para agregar un nuevo proveedor.',
							position: 'top'
						},
						{
							element: '.cont_suppliers',
							intro: 'Este contenedor muestra los proveedores registrados. Puedes editarlos o eliminarlos.',
							position: 'top'
						},
						{
							element: '.edit_btn[data-bs-target="#edit-supplier"]',
							intro: 'Este es el botón para editar un proveedor existente. Aquí puedes actualizar los detalles del proveedor.',
							position: 'top'
						},
						{
							element: '.trash_btn',
							intro: 'Este es el modal para registrar un nuevo proveedor. Aquí puedes ingresar los detalles del proveedor.',
							position: 'top'
						},
					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function table(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: document.querySelector('.page-wrapper'),
							intro: 'Bienvenido a la seccion de mesas, aqui podras ver y gestionr todas las mesas registradas de tu negocio.',
							position: 'bottom'
						},
						{
							element: document.querySelector('#home-tab'),
							intro: 'Aqui podrás ver las mesas que estan libres, puedes agregar, editar o eliminar mesas.',
							position: 'bottom'
						},
						{
							element: document.querySelector('#profile-tab'),
							intro: 'Aqui podras ver las mesas que estan ocupadas, puedes ver los detalles de las mesas.',
							position: 'bottom'
						},
						{
							element: document.querySelector('#SearchTablesFREE'),
							intro: 'Puedes buscar mesas por nombre, si no hay resultados se mostrará una marca de agua con el logo del negocio.',
							position: 'bottom'
						},
						{
							element: document.querySelector('#register-table-button'),
							intro: 'Puedes registrar una nueva mesa, debes ingresar el nombre de la mesa, la cantidad de sillas, una imagen representativa de la mesa y si es VIP.',
							position: 'bottom'
						},
						{
							element: document.querySelector('.card'),
							intro: 'Puedes ver los detalles de la mesa, puedes editar o eliminar la mesa.',
							position: 'bottom'
						}
					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	function trash(element) {
		document.getElementById(element).addEventListener('click', function () {
			if (typeof introJs !== 'undefined') {
				let intro = introJs();
				intro.setOptions({
					steps: [
						{
							element: '.page-title',
							intro: 'Esta es la sección de papelera, donde puedes gestionar los elementos eliminados de diferentes módulos.',
							position: 'bottom'
						},
						{
							element: '#SearchTrash',
							intro: 'Utiliza este cuadro de búsqueda para filtrar los elementos eliminados en la papelera.',
							position: 'top'
						},
						{
							element: '.select_options_module',
							intro: 'Selecciona un módulo para filtrar los elementos eliminados específicos de ese módulo.',
							position: 'top'
						},
						{
							element: '.table_trash',
							intro: 'Esta tabla muestra los elementos eliminados. Si deseas puedes restaurarlos.',
							position: 'top'
						}
					],
					showBullets: true,
					exitOnOverlayClick: false,
					showProgress: true
				});
				intro.start();
			}
		});
	}
	return {
		additional,
		binnacleIntro,
		calendarIntro,
		capital,
		cashIntro,
		client,
		dashboard,
		order,
		productPrepared,
		productProcessIntro,
		rawMaterial,
		recipe,
		statistics,
		supplier,
		table,
		trash
	}
}