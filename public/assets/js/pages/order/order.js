import functionGeneral from "../../Functions.js";
import Templates from "../../templates.js"
import { myfecth, nuevaBitacora, formatear_fecha, formatear_hora, sessionInfo } from "../../Functions2.js"
import domicile_and_takeaway from "./domicile_and_takeaway.js";
import { local, more_product_local_order, payOrder } from "./local.js";
import { payOrderReservation } from "./reservationOrder.js"
import { report, invoice } from "./report.js"
const { resetForm, permission, amountDolar } = functionGeneral()
import introTooltip from "../../intro-tooltip.js"
const { order } = introTooltip()
// let [session, permisos] = await sessionInfo();
order('navbarDropdown')

permission("Ordenes (llevar)")
permission("Ordenes (delivery)")
permission("Ordenes (local)")
permission("Ordenes (reservas)", () => {
  const tabContainer = document.getElementById('nav-tab');
  const tabContent = document.getElementById('nav-tabContent');

  if (!tabContainer || !tabContent) return;
  const tabButtons = Array.from(tabContainer.querySelectorAll('button[data-bs-target]'))
    .filter(btn => btn.offsetParent !== null);

  const validPaneIds = tabButtons.map(btn => btn.dataset.bsTarget.replace('#', ''));
  Array.from(tabContent.children).forEach(pane => {
    if (!validPaneIds.includes(pane.id)) {
      pane.remove();
    }
  });
  tabButtons.forEach(btn => btn.classList.remove('active'));
  Array.from(tabContent.children).forEach(pane => pane.classList.remove('show', 'active'));
  let paneToActivate = null;
  const activeBtn = tabButtons.find(btn => btn.classList.contains('active'));

  if (activeBtn) {
    const targetId = activeBtn.dataset.bsTarget.replace('#', '');
    paneToActivate = document.getElementById(targetId);
  }

  if (!paneToActivate && tabButtons.length > 0) {
    const firstBtn = tabButtons[0];
    firstBtn.classList.add('active');
    const firstPaneId = firstBtn.dataset.bsTarget.replace('#', '');
    paneToActivate = document.getElementById(firstPaneId);
  }

  if (paneToActivate) {
    paneToActivate.classList.add('show', 'active');
  }
})


const parseDataTableTotal = (raw) => {
  if (raw === null || raw === undefined) return null;

  if (raw && typeof raw.json === "function") {
    try {
      return parseDataTableTotal(raw.json());
    } catch (e) {
      // continuar con otras estrategias de parseo
    }
  }

  if (raw && typeof raw.data !== "undefined") {
    return parseDataTableTotal(raw.data);
  }

  if (raw && typeof raw.text !== "undefined") {
    return parseDataTableTotal(raw.text);
  }

  if (typeof raw === "number") {
    return Number.isFinite(raw) ? raw : null;
  }

  if (typeof raw === "object") {
    if (typeof raw.total !== "undefined") return parseDataTableTotal(raw.total);
    if (typeof raw.recordsTotal !== "undefined") return parseDataTableTotal(raw.recordsTotal);
    if (typeof raw.message !== "undefined") return parseDataTableTotal(raw.message);
  }

  if (typeof raw === "string") {
    const value = raw.trim();
    if (value.length === 0) return null;

    if (/^\d+$/.test(value)) return parseInt(value, 10);

    try {
      const parsed = JSON.parse(value);
      return parseDataTableTotal(parsed);
    } catch (e) {
      return null;
    }
  }

  return null;
};

const parseDataRows = (response) => {
  if (Array.isArray(response)) return response;
  if (response && Array.isArray(response.data)) return response.data;
  return [];
};

const countEndpointByModule = {};

const resolveServerTotal = (module, filters = {}) => {
  if (countEndpointByModule[module] === false) return null;

  const actions = countEndpointByModule[module]
    ? [countEndpointByModule[module]]
    : ["count"];

  for (const action of actions) {
    try {
      const raw = myfecth(`${module}/${action}`, {}, filters, null, "POST");
      const parsed = parseDataTableTotal(raw);
      if (parsed !== null) {
        countEndpointByModule[module] = action;
        return parsed;
      }
    } catch (e) {
      // ignorar y probar siguiente endpoint de conteo
    }
  }

  if (!countEndpointByModule[module]) {
    countEndpointByModule[module] = false;
  }

  return null;
};

const buildServerSideAjax = ({
  module,
  baseFilters = {},
  defaultOrderBy = "id",
  defaultOrderType = "asc",
  clientFilter = null,
  searchFiltersBuilder = null,
}) => {
  return function (data, callback) {
    const page = Math.floor(data.start / data.length);
    const size = data.length;
    const requestFilters = { ...baseFilters };

    const searchValue = (data.search?.value || "").trim();
    if (searchValue) {
      const searchFilters = typeof searchFiltersBuilder === "function"
        ? searchFiltersBuilder(searchValue)
        : {
          nombre_like: searchValue,
          apellido_like: searchValue,
          cedula_like: searchValue,
          nro_factura: searchValue,
        };
      Object.assign(requestFilters, searchFilters);
    }

    const total = resolveServerTotal(module, requestFilters);

    const dtOrder = Array.isArray(data.order) && data.order.length > 0 ? data.order[0] : null;
    const columnData = dtOrder && data.columns?.[dtOrder.column]
      ? data.columns[dtOrder.column].data
      : null;
    const orderBy = typeof columnData === "string" && columnData.trim() !== ""
      ? columnData
      : defaultOrderBy;
    const orderType = dtOrder?.dir || defaultOrderType;

    let request = myfecth(`${module}/get_all/${page}/${size}/${orderBy}/${orderType}`, {}, requestFilters, null, "POST");

    if (request.status !== 200) {
      callback({
        draw: data.draw,
        data: [],
        recordsTotal: 0,
        recordsFiltered: 0,
      });
      return;
    }

    let response = request.json();

    const rows = parseDataRows(response);
    const filteredRows = typeof clientFilter === "function" ? rows.filter(clientFilter) : rows;

    const inferredTotal = total
      ?? parseDataTableTotal(response)
      ?? (data.start + filteredRows.length + (filteredRows.length === size ? 1 : 0));

    callback({
      draw: data.draw,
      data: filteredRows,
      recordsTotal: inferredTotal,
      recordsFiltered: inferredTotal,
    });
  };
};
//tables de domicilio 
let tableOrderDomicileoPendings = $('.table-order-domicilio-pendientes').DataTable({
  language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
  "orden": [[1, "desc"]],
  processing: true,
  serverSide: true,
  pageLength: 10,
  ajax: buildServerSideAjax({
    module: "orden",
    baseFilters: { tipo: "delivery" },
    clientFilter: (row) => row.status != "entregada" && row.status != "anulada",
  }),

  columns: [
    {
      data: null, render: function (data) {
        let estado = data.status
        let width = 0
        let bg = "bh_1"
        if (estado == "en cocina") width = 33.33
        else if (estado == "en preparacion") width = 66.66
        else if (estado == "para despachar") { width = 100; bg = "bg-success" }
        else if (estado == "por verificar") { width = 100; bg = "bh_2" }
        else if (estado == "entregada") { width = 100; bg = "bg-success" }
        else if (estado == "en camino") { width = 100; bg = "bg-success" }
        else { width = 100; bg = "bg-secondary" }
        return `
            <div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
              <div class="progress-bar progress-bar-striped progress-bar-animated ${bg}" style="width: ${width}%">${estado}</div>
            </div>
      
      ` }
    },
    { data: null, render: function (data) { return data.id.toString().padStart(7, '0') } },
    { data: null, render: function (data) { return data.cliente_nombre + " " + data.cliente_apellido } },
    { data: null, render: function (data) { return formatear_fecha(data.fecha) } },
    { data: null, render: function (data) { return formatear_hora(data.fecha) } },
    {
      data: null,
      orderable: false,
      render: function (data, type, row, meta) {
        let btnVerify = `<li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-verify="Ordenes (llevar)" type_action="verify_orden" class="dropdown-item d-flex gap-2"><i data-feather="check"></i>Verificar Orden</a></li>`
        let btnNull = ` <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-null="Ordenes (llevar)" type_action="null_order" class="dropdown-item d-flex gap-2"><i data-feather="x"></i>Anular orden</a></li>`
        return `
            <div class="dropdown dropstart">
                <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                <ul class="dropdown-menu" data-bs-boundary="viewport">
                    ${row.status == "por verificar" ? btnVerify : ""}
                    <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-printOrder="Ordenes (llevar)" type_action="print_order" class="dropdown-item d-flex gap-2"><i data-feather="file-text"></i>Imprimir cuenta</a></li>
                    ${row.status == "por verificar" ? btnNull : ""}
                    <li><a type_action="details" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="info"></i>Detalles</a></li>
                    <li><a type_action="payment" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="credit-card"></i>Detalles de pago</a></li>
                </ul>
            </div>
          `;
      }
    }
  ],
  drawCallback: function (settings) {
    feather.replace();
    document.querySelectorAll(".reference_btn").forEach((btn) => {
      let tooltip = new bootstrap.Tooltip(btn)
      btn.addEventListener("click", () => detailOrder(btn))
    })
    document.querySelectorAll(".btn-circle").forEach((btn) => {
      let tooltip = new bootstrap.Tooltip(btn)
      btn.addEventListener("click", async () => actionOrder(btn, "en cocina"))
    })
    permission("Ordenes (delivery)")
  },
  "dom": 'tipr',
  "paging": true,
  "info": true,
});
let tableOrderDomicileProcess = $('.table-order-domicilio-procesadas').DataTable({
  "orden": [[1, "desc"]],
  language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
  processing: true,
  serverSide: true,
  pageLength: 10,
  ajax: buildServerSideAjax({
    module: "orden",
    baseFilters: { status: "entregada", tipo: "delivery" },
  }),

  columns: [
    {
      data: null, render: function (data) {
        let estado = data.status
        let width = 0
        let bg = "bh_1"
        if (estado == "en cocina") width = 33.33
        else if (estado == "en preparacion") width = 66.66
        else if (estado == "para despachar") { width = 100; bg = "bg-success" }
        else if (estado == "por verificar") { width = 100; bg = "bh_2" }
        else if (estado == "entregada") { width = 100; bg = "bg-success" }
        else { width = 100; bg = "bg-secondary" }
        return `
            <div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
              <div class="progress-bar progress-bar-striped progress-bar-animated ${bg}" style="width: ${width}%">${estado}</div>
            </div>
      
      ` }
    },
    { data: null, render: function (data) { return data.id.toString().padStart(7, '0') } },
    { data: null, render: function (data) { return data.cliente_nombre + " " + data.cliente_apellido } },
    { data: null, render: function (data) { return formatear_fecha(data.fecha) } },
    { data: null, render: function (data) { return formatear_hora(data.fecha) } },
    {
      data: null,
      orderable: false,
      render: function (data, type, row, meta) {
        return `
            <div class="dropdown dropstart">
                <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                <ul class="dropdown-menu" data-bs-boundary="viewport">
                    <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-printOrder="Ordenes (llevar)" type_action="print_order" class="dropdown-item d-flex gap-2"><i data-feather="file-text"></i>Imprimir cuenta</a></li>
                    <li><a type_action="details" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="info"></i>Detalles</a></li>
                    <li><a type_action="payment" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="credit-card"></i>Detalles de pago</a></li>
                </ul>
            </div>
          `;
      }
    }

  ],
  drawCallback: function (settings) {
    feather.replace();
    document.querySelectorAll(".reference_btn").forEach((btn) => {
      let tooltip = new bootstrap.Tooltip(btn)
      btn.addEventListener("click", () => detailOrder(btn))
    })
  },
  "dom": 'tipr',
  "paging": true,
  "info": true,
});
let tableOrderDomicileNull = $('.table-order-domicilio-null').DataTable({
  language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
  "orden": [[0, "desc"]],
  processing: true,
  serverSide: true,
  pageLength: 10,
  ajax: buildServerSideAjax({
    module: "orden",
    baseFilters: { status: "anulada", tipo: "delivery" },
  }),

  columns: [
    {
      data: null, render: function (data) {
        let estado = data.status
        let width = 0
        let bg = "bh_1"
        if (estado == "en cocina") width = 33.33
        else if (estado == "en preparacion") width = 66.66
        else if (estado == "para despachar") { width = 100; bg = "bg-success" }
        else if (estado == "por verificar") { width = 100; bg = "bh_2" }
        else if (estado == "entregada") { width = 100; bg = "bg-success" }
        else { width = 100; bg = "bg-secondary" }
        return `
            <div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
              <div class="progress-bar progress-bar-striped progress-bar-animated ${bg}" style="width: ${width}%">${estado}</div>
            </div>
      
      ` }
    },
    { data: null, render: function (data) { return data.id.toString().padStart(7, '0') } },
    { data: null, render: function (data) { return data.cliente_nombre + " " + data.cliente_apellido } },
    { data: null, render: function (data) { return formatear_fecha(data.fecha) } },
    { data: null, render: function (data) { return formatear_hora(data.fecha) } },
    {
      data: null,
      orderable: false,
      render: function (data, type, row, meta) {
        return `
            <div class="dropdown dropstart">
                <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                <ul class="dropdown-menu" data-bs-boundary="viewport">
                    <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-printOrder="Ordenes (llevar)" type_action="print_order" class="dropdown-item d-flex gap-2"><i data-feather="file-text"></i>Imprimir cuenta</a></li>
                    <li><a type_action="details" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="info"></i>Detalles</a></li>
                    <li><a type_action="payment" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="credit-card"></i>Detalles de pago</a></li>
                </ul>
            </div>
          `;
      }
    }

  ],
  drawCallback: function (settings) {
    feather.replace();
    document.querySelectorAll(".reference_btn").forEach((btn) => {
      let tooltip = new bootstrap.Tooltip(btn)
      btn.addEventListener("click", () => detailOrder(btn))
    })
    document.querySelectorAll(".btn-circle").forEach((btn) => {
      let tooltip = new bootstrap.Tooltip(btn)
    })

  },
  "dom": 'tipr',
  "paging": true,
  "info": true,
});
$('#searchBoxDomicilioPending').on('keyup', function () { tableOrderDomicileoPendings.search(this.value).draw(); });
$('#searchBoxDomicilioProcesadas').on('keyup', function () { tableOrderDomicileProcess.search(this.value).draw(); });
$('#searchBoxDomicilioNull').on('keyup', function () { tableOrderDomicileNull.search(this.value).draw(); });

//tables para llevar
let tableOrderParaLlevarPendingsVeryfy = $('.table-order-llevar-pendientes').DataTable({
  language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
  "orden": [[1, "desc"]],
  processing: true,
  serverSide: true,
  pageLength: 10,
  ajax: buildServerSideAjax({
    module: "orden",
    baseFilters: { tipo: "llevar" },
    clientFilter: (row) => row.status != "entregada" && row.status != "anulada",
  }),

  columns: [
    {
      data: null, render: function (data) {
        let estado = data.status
        let width = 0
        let bg = "bh_1"
        if (estado == "en cocina") width = 33.33
        else if (estado == "en preparacion") width = 66.66
        else if (estado == "para despachar") { width = 100; bg = "bg-success" }
        else if (estado == "por verificar") { width = 100; bg = "bh_2" }
        else { width = 100; bg = "bg-secondary" }
        return `
            <div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
              <div class="progress-bar progress-bar-striped progress-bar-animated ${bg}" style="width: ${width}%">${estado}</div>
            </div>
      
      ` }
    },
    { data: null, render: function (data) { return data.id.toString().padStart(7, '0') } },
    { data: null, render: function (data) { return data.cliente_nombre + " " + data.cliente_apellido } },
    { data: null, render: function (data) { return formatear_fecha(data.fecha) } },
    { data: null, render: function (data) { return formatear_hora(data.fecha) } },
    {
      data: null,
      orderable: false,
      render: function (data, type, row, meta) {
        let btnVerify = `<li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-verify="Ordenes (llevar)" type_action="verify_orden" class="dropdown-item d-flex gap-2"><i data-feather="check"></i>Verificar Orden</a></li>`
        let btnNull = ` <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-null="Ordenes (llevar)" type_action="null_order" class="dropdown-item d-flex gap-2"><i data-feather="x"></i>Anular orden</a></li>`
        return `
            <div class="dropdown dropstart">
                <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                <ul class="dropdown-menu" data-bs-boundary="viewport">
                    ${row.status == "por verificar" ? btnVerify : ""}
                    <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-printOrder="Ordenes (llevar)" type_action="print_order" class="dropdown-item d-flex gap-2"><i data-feather="file-text"></i>Imprimir cuenta</a></li>
                    ${row.status == "por verificar" ? btnNull : ""}
                    <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-dispatch="Ordenes (llevar)" type_action="sale_order" type="entregar" class="dropdown-item d-flex gap-2"><i data-feather="corner-down-right"></i>Entregar</a></li>
                    <li><a type_action="details" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="info"></i>Detalles</a></li>
                    <li><a type_action="payment" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="credit-card"></i>Detalles de pago</a></li>
                </ul>
            </div>
          `;
      }
    }
  ],
  drawCallback: function (settings) {
    feather.replace();
    document.querySelectorAll(".reference_btn").forEach((btn) => {
      btn.addEventListener("click", () => detailOrder(btn))
    })
    document.querySelectorAll(".dropdown-item").forEach((btn) => {
      if (!btn.dataset.listenerAttached) {
        btn.addEventListener("click", async () => actionOrder(btn, "entregada"))
        btn.dataset.listenerAttached = "true";
      }
    })
    permission("Ordenes (llevar)")
  },
  "dom": 'tipr',
  "paging": true,
  "info": true,
});
let tableOrderParaLlevarProcess = $('.table-order-llevar-procesadas').DataTable({
  "orden": [[1, "desc"]],
  language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
  processing: true,
  serverSide: true,
  pageLength: 10,
  ajax: buildServerSideAjax({
    module: "orden",
    baseFilters: { status: "entregada", tipo: "llevar" },
  }),

  columns: [
    {
      data: null, render: function (data, type, row, meta) {
        return `<div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
        <div class="progress-bar progress-bar-striped progress-bar-animated bg-success" style="width: 100%">${row.status}</div>
      </div>`
      }
    },
    { data: null, render: function (data) { return data.id.toString().padStart(7, '0') } },
    { data: null, render: function (data) { return data.cliente_nombre + " " + data.cliente_apellido } },
    { data: null, render: function (data) { return formatear_fecha(data.fecha) } },
    { data: null, render: function (data) { return formatear_hora(data.fecha) } },
    {
      data: null,
      orderable: false,
      render: function (data, type, row, meta) {
        return `
            <div class="dropdown dropstart">
                <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                <ul class="dropdown-menu" data-bs-boundary="viewport">
                    <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-printOrder="Ordenes (llevar)" type_action="print_order" class="dropdown-item d-flex gap-2"><i data-feather="file-text"></i>Imprimir cuenta</a></li>
                    <li><a type_action="details" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="info"></i>Detalles</a></li>
                    <li><a type_action="payment" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="credit-card"></i>Detalles de pago</a></li>
                </ul>
            </div>
          `;
      }
    }
  ],
  drawCallback: function (settings) {
    feather.replace();
    document.querySelectorAll(".reference_btn").forEach((btn) => {
      btn.addEventListener("click", () => detailOrder(btn))
    })
    document.querySelectorAll(".dropdown-item").forEach((btn) => {

      if (!btn.dataset.listenerAttached) {
        btn.addEventListener("click", async () => actionOrder(btn, "entregada"))
        btn.dataset.listenerAttached = "true";
      }

    })
  },
  "dom": 'tipr',
  "paging": true,
  "info": true,
});
let tableOrderParaLlevarNull = $('.table-order-llevar-anuladas').DataTable({
  language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
  "orden": [[1, "desc"]],
  processing: true,
  serverSide: true,
  pageLength: 10,
  ajax: buildServerSideAjax({
    module: "orden",
    baseFilters: { status: "anulada", tipo: "llevar" },
  }),

  columns: [
    {
      data: null, render: function (data, type, row, meta) {
        return `<div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
        <div class="progress-bar progress-bar-striped progress-bar-animated bg-secondary" style="width: 100%">${row.status}</div>
      </div>`
      }
    },
    { data: null, render: function (data) { return data.id.toString().padStart(7, '0') } },
    { data: null, render: function (data) { return data.cliente_nombre + " " + data.cliente_apellido } },
    { data: null, render: function (data) { return formatear_fecha(data.fecha) } },
    { data: null, render: function (data) { return formatear_hora(data.fecha) } },
    {
      data: null,
      orderable: false,
      render: function (data, type, row, meta) {
        return `
            <div class="dropdown dropstart">
                <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                <ul class="dropdown-menu" data-bs-boundary="viewport">
                    <li><a type_action="details" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="info"></i>Detalles</a></li>
                    <li><a type_action="payment" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="credit-card"></i>Detalles de pago</a></li>
                </ul>
            </div>
          `;
      }
    }
  ],
  drawCallback: function (settings) {
    feather.replace();
    document.querySelectorAll(".reference_btn").forEach((btn) => {
      if (!btn.dataset.listenerAttached) {
        btn.addEventListener("click", () => detailOrder(btn))
        btn.dataset.listenerAttached = "true";
      }
    })
  },
  "dom": 'tipr',
  "paging": true,
  "info": true,
});
$('#searchBoxLLevarPending').on('keyup', function () { tableOrderParaLlevarPendingsVeryfy.search(this.value).draw(); });
$('#searchBoxllevarProcesadas').on('keyup', function () { tableOrderParaLlevarProcess.search(this.value).draw(); });
$('#searchBoxllevarAnuladas').on('keyup', function () { tableOrderParaLlevarNull.search(this.value).draw(); });

//tables local
let tableOrderLocalPendingsVeryfy = $('.table-order-local-pendientes').DataTable({
  language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
  "orden": [[2, "desc"], [3, "desc"]],
  processing: true,
  serverSide: true,
  pageLength: 10,
  ajax: buildServerSideAjax({
    module: "orden",
    baseFilters: { tipo: "local" },
    clientFilter: (row) => row.status != "pagado",
  }),

  columns: [
    {
      data: null, render: function (data) {
        let estado = data.status
        let width = 0
        if (estado == "en cocina") width = 33.33
        else if (estado == "en preparacion") width = 66.66
        else if (estado == "por despachar") width = 100
        else width = 100
        return `
      <div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
        <div class="progress-bar progress-bar-striped progress-bar-animated ${width == 100 ? "bg-success" : "bh_1"}" style="width: ${width}%">${estado}</div>
      </div>
      
      ` }
    },
    { data: null, render: function (data) { return data.id.toString().padStart(7, '0') } },
    { data: null, render: function (data) { return formatear_fecha(data.fecha) } },
    { data: null, render: function (data) { return formatear_hora(data.fecha) } },
    {
      data: null,
      orderable: false,
      render: function (data, type, row, meta) {
        return `
            <div class="dropstart">
                <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                <ul class="dropdown-menu">
                    <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-moreProducts="Ordenes (local)" type_action="more_products" type_module="local" class="dropdown-item d-flex gap-2"><i data-feather="plus"></i>Agregar productos</a></li>
                    <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-printOrder="Ordenes (local)" type_action="print_order" class="dropdown-item d-flex gap-2"><i data-feather="file-text"></i>Imprimir cuenta</a></li>
                    <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-PayOrder="Ordenes (local)" type_action="pay_order" class="dropdown-item d-flex gap-2"><i data-feather="credit-card"></i>Pagar</a></li>
                    <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-dispatch="Ordenes (local)" type_action="sale_order" type="mesa" class="dropdown-item d-flex gap-2"><i data-feather="corner-down-right"></i>Entregar</a></li>
                    <li><a type_action="details" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="info"></i>Detalles</a></li>
                </ul>
            </div>
          `;
      }
    }
  ],
  drawCallback: function (settings) {
    feather.replace();
    document.querySelectorAll(".reference_btn").forEach((btn) => {
      btn.addEventListener("click", () => detailOrder(btn))
    })
    document.querySelectorAll(".dropdown-item").forEach((btn) => {
      if (!btn.dataset.listenerAttached) {
        btn.addEventListener("click", async () => actionOrder(btn, "en mesa"))
        btn.dataset.listenerAttached = true
      }
    })
    permission("Ordenes (local)")

  },
  "dom": 'tipr',
  "paging": true,
  "info": true,
});
let tableOrderLocalProcess = $('.table-order-local-procesadas').DataTable({
  "orden": [[1, "desc"]],
  language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
  processing: true,
  serverSide: true,
  pageLength: 10,
  ajax: buildServerSideAjax({
    module: "orden",
    baseFilters: { status: "pagado", tipo: "local" },
  }),

  columns: [
    {
      data: null, render: function (data) {
        return `
      <div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
        <div class="progress-bar progress-bar-striped progress-bar-animated bg-success" style="width:100%">${data.status}</div>
      </div>
      
      ` }
    },
    { data: null, render: function (data) { return data.id.toString().padStart(7, '0') } },
    { data: null, render: function (data) { return data.cliente_nombre + " " + data.cliente_apellido } },
    { data: null, render: function (data) { return formatear_fecha(data.fecha) } },
    { data: null, render: function (data) { return formatear_hora(data.fecha) } },
    {
      data: null,
      orderable: false,
      render: function (data, type, row, meta) {
        return `
            <div class="dropstart">
                <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                <ul class="dropdown-menu">
                    <li><a nro_orden="${data.nro_orden}" id_order="${data.id}" data-module-printOrder="Ordenes (local)" type_action="print_order" class="dropdown-item d-flex gap-2"><i data-feather="file-text"></i>Imprimir cuenta</a></li>
                    <li><a type_action="details" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="info"></i>Detalles</a></li>
                    <li><a type_action="payment" data-id_order="${data.id}" data_id_sale="${data.id_venta}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="info"></i>Detalles de pago</a></li>
                </ul>
            </div>
          `;
      }
    }
  ],
  drawCallback: function (settings) {
    feather.replace();
    document.querySelectorAll(".reference_btn").forEach((btn) => {
      btn.addEventListener("click", () => detailOrder(btn))
    })
    document.querySelectorAll(".dropdown-item").forEach((btn) => {
      if (!btn.dataset.listenerAttached) {
        btn.addEventListener("click", async () => actionOrder(btn, "en mesa"))
        btn.dataset.listenerAttached = true
      }
    })
    permission("Ordenes (local)")
  },
  "dom": 'tipr',
  "paging": true,
  "info": true,
});

//tables reservation
let tableOrderResPendingsVeryfy = $('.table-order-res-pendientes').DataTable({
  language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
  "orden": [[2, "desc"], [3, "desc"]],
  processing: true,
  serverSide: true,
  pageLength: 10,
  ajax: buildServerSideAjax({
    module: "calendario",
    clientFilter: (row) => row.status_orden != "pagado",
  }),

  columns: [
    {
      data: null, render: function (data) {
        let estado = data.status_orden
        let width = 0
        if (estado == "en cocina") width = 33.33
        else if (estado == "en preparacion") width = 66.66
        else if (estado == "por despachar") width = 100
        else if (estado == "pendiente") width = 33.33
        else width = 100
        return `
      <div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
        <div class="progress-bar progress-bar-striped progress-bar-animated ${width == 100 ? "bg-success" : "bh_1"}" style="width: ${width}%">${estado}</div>
      </div>
      
      ` }
    },
    { data: null, render: function (data) { return data.id_orden.toString().padStart(7, '0') } },
    { data: null, render: function (data) { return formatear_fecha(data.fecha_inicio) } },
    { data: null, render: function (data) { return formatear_hora(data.fecha_inicio) } },
    {
      data: null,
      orderable: false,
      render: function (data, type, row, meta) {
        return `
            <div class="dropstart">
                <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                <ul class="dropdown-menu">
                    <li><a id_order="${data.id_orden}" data-module-moreProducts="Ordenes (reservas)" data_id_reservation="${data.id}" type_action="more_products" type_module="reservation" class="dropdown-item d-flex gap-2"><i data-feather="plus"></i>Agregar productos</a></li>
                    <li><a id_order="${data.id_orden}" data_id_reservation="${data.id}" type_action="print_order" class="dropdown-item d-flex gap-2"><i data-feather="file-text"></i>Imprimir cuenta</a></li>
                    <li><a id_order="${data.id_orden}" data-module-PayOrder="Ordenes (reservas)" id_reservation="${data.id}" type_action="pay_order" class="dropdown-item d-flex gap-2"><i data-feather="credit-card"></i>Pagar</a></li>
                    <li><a id_order="${data.id_orden}" data-module-dispatch="Ordenes (reservas)" type="mesa" type_action="sale_order" class="dropdown-item d-flex gap-2"><i data-feather="corner-down-right"></i>Entregar</a></li>
                    <li><a type_action="details" data-id_order="${data.id_orden}" data_id_reservation="${data.id}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="info"></i>Detalles</a></li>
                </ul>
            </div>
          `;
      }
    }
  ],
  drawCallback: function (settings) {
    feather.replace();
    document.querySelectorAll(".reference_btn").forEach((btn) => {
      btn.addEventListener("click", () => detailOrder(btn))
    })
    document.querySelectorAll(".dropdown-item").forEach((btn) => {
      if (!btn.dataset.listenerAttached) {
        btn.addEventListener("click", async () => actionOrder(btn, "en mesa"))
        btn.dataset.listenerAttached = true
      }
    })
    permission("Ordenes (reservas)")

  },
  "dom": 'tipr',
  "paging": true,
  "info": true,
});
let tableOrderResProcessVeryfy = $('.table-order-res-procesadas').DataTable({
  language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
  "orden": [[2, "desc"], [3, "desc"]],
  processing: true,
  serverSide: true,
  pageLength: 10,
  ajax: buildServerSideAjax({
    module: "calendario",
    clientFilter: (row) => row.status_orden == "pagado",
  }),

  columns: [
    {
      data: null, render: function (data) {
        let estado = data.status_orden
        let width = 0
        if (estado == "en cocina") width = 33.33
        else if (estado == "en preparacion") width = 66.66
        else if (estado == "por despachar") width = 100
        else if (estado == "pendiente") width = 33.33
        else width = 100
        return `
      <div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
        <div class="progress-bar progress-bar-striped progress-bar-animated ${width == 100 ? "bg-success" : "bh_1"}" style="width: ${width}%">${estado}</div>
      </div>
      
      ` }
    },
    { data: null, render: function (data) { return data.id_orden.toString().padStart(7, '0') } },
    { data: null, render: function (data) { return formatear_fecha(data.fecha_inicio) } },
    { data: null, render: function (data) { return formatear_hora(data.fecha_inicio) } },
    {
      data: null,
      orderable: false,
      render: function (data, type, row, meta) {
        return `
            <div class="dropstart">
                <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                <ul class="dropdown-menu">
                    <li><a id_order="${data.id_orden}" data_id_reservation="${data.id}" type_action="print_order" class="dropdown-item d-flex gap-2"><i data-feather="file-text"></i>Imprimir cuenta</a></li>
                    <li><a type_action="details" data-id_order="${data.id_orden}" data_id_reservation="${data.id}" style="cursor: pointer" class="dropdown-item d-flex gap-2 reference_btn"><i data-feather="info"></i>Detalles</a></li>
                </ul>
            </div>
          `;
      }
    }
  ],
  drawCallback: function (settings) {
    feather.replace();
    document.querySelectorAll(".reference_btn").forEach((btn) => {
      btn.addEventListener("click", () => detailOrder(btn))
    })
    document.querySelectorAll(".dropdown-item").forEach((btn) => {
      if (!btn.dataset.listenerAttached) {
        btn.addEventListener("click", async () => actionOrder(btn, "en mesa"))
        btn.dataset.listenerAttached = true
      }
    })
    permission("Ordenes (reservas)")


  },
  "dom": 'tipr',
  "paging": true,
  "info": true,
});
$('#searchBoxResPending').on('keyup', function () { tableOrderResPendingsVeryfy.search(this.value).draw(); });
$('#searchBoxResProcesadas').on('keyup', function () { tableOrderResProcessVeryfy.search(this.value).draw(); });



window.stepper = new Stepper(document.querySelector('#stepper'), { linear: true, animation: true });
window.stepper2 = new Stepper(document.querySelector('#stepper-2'), { linear: true, animation: true });
window.stepper3 = new Stepper(document.querySelector('#stepper-3'), { linear: true, animation: true });
window.stepper4 = new Stepper(document.querySelector('#stepper-4'), { linear: true, animation: true });
window.stepperReservationOrder = new Stepper(document.querySelector('#stepper-payReservation'), { linear: true, animation: true });

const detailOrder = async (btn) => {
  let data = new FormData();
  let id_order = btn.getAttribute("data-id_order");
  let id_sale = btn.getAttribute("data_id_sale");
  let action = btn.getAttribute("type_action");
  if (action == "details") {
    data.append("id_orden", id_order)
    let dataProductPrepared = []
    let templateProductPrepared = ""
    let templateProductProcess = ""
    let res = myfecth("Detalle_orden_producto_preparado/get_all", {}, data).json()
    let res2 = myfecth("Detalle_orden_producto_procesado/get_all", {}, data).json()
    let group = {}
    res.forEach((productPrepared) => { if (productPrepared.tipo == "producto") dataProductPrepared.push(productPrepared) })
    dataProductPrepared.forEach((productPrepared) => {
      templateProductPrepared += `
            <tr>
              <td>${productPrepared.nombre}</td>
              <td>${productPrepared.cantidad}</td>
              <td>${productPrepared.descripcion == null ? "S/D" : productPrepared.descripcion}</td>
              <td>${productPrepared.adicionales == null ? "S/A" : productPrepared.adicionales}</td>
            </tr>
          `
    })
    res2.forEach((productProcess) => {
      if (!group[productProcess.id_producto]) group[productProcess.id_producto] = productProcess
      else group[productProcess.id_producto] = { ...group[productProcess.id_producto], cantidad: parseInt(group[productProcess.id_producto].cantidad) + parseInt(productProcess.cantidad) }
    })
    group = Object.entries(group).map(([key, value]) => ({ id_producto: key, ...value }));
    group.forEach((productProcess) => {
      templateProductProcess += `
            <tr>
              <td>${productProcess.nombre}</td>
              <td>${productProcess.cantidad}</td>
            </tr>
          `
    })

    document.querySelector(".tbody-detail-order").innerHTML = templateProductPrepared
    document.querySelector(".tbody-detail-order").innerHTML += templateProductProcess
    bootstrap.Modal.getOrCreateInstance('#detail_order').show()
  } else {
    data.append("id_venta", id_sale)
    let dataPayment = []
    let templatePayment = ""
    let res = myfecth("paymentSale/get_all/0/10000000/id/asc", {}, data).json()
    res.forEach((payment) => {
      templatePayment += `
      <div class="col-md-6">
          <h3>Referencia: ${payment.referencia}</h3>
          <img class="w-75" src="./media/pay/${payment.comprobante}" alt="">
      </div>`
    })
    document.querySelector(".cont-detail-payment").innerHTML = templatePayment
    bootstrap.Modal.getOrCreateInstance('#detail_payment').show()
  }
}
const actionOrder = async (btn, status) => {
  let data = new FormData();
  let action = btn.getAttribute("type_action");
  if (action == "verify_orden") {
    Swal.fire({
      title: "¿Deseas verificar esta orden?",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Si, verificar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#FF4B00",
    }).then(async (result) => {
      if (result.isConfirmed) {
        let id_order = btn.getAttribute("id_order");
        data.append("id", id_order);
        data.append("status", "en cocina");
        let response = myfecth(`orden/update`, {}, data).json();
        if (response.success) {
          if (response.success == true) {
            Swal.fire({
              title: `Exito!`,
              text: "La orden fue verificada correctamente",
              icon: "success",
            });
            nuevaBitacora("orden", "Actualizacion", `Se verifico la orden ${btn.getAttribute("nro_orden")}`);
            tableOrderParaLlevarNull.ajax.reload();
            tableOrderParaLlevarPendingsVeryfy.ajax.reload();
            tableOrderParaLlevarPorDespachar.ajax.reload();
            tableOrderParaLlevarProcess.ajax.reload();
            tableOrderDomicileNull.ajax.reload();
            tableOrderDomicileProcess.ajax.reload();
            tableOrderDomicileoPendings.ajax.reload();
            targetUpdate("delivery")
            targetUpdate("llevar")
          } else {
            Swal.fire({
              title: `Error!`,
              text: "La orden no fue verificada",
              icon: "error",
            });
          }
        }
      }
    });
  } else if (action == "sale_order") {
    let id_order = btn.getAttribute("id_order");
    let dataVerify = new FormData();
    dataVerify.append("id", id_order);
    let resVerify = myfecth(`orden/get_all`, {}, dataVerify).json();
    if (resVerify[0].status == "en preparacion" || resVerify[0].status == "en cocina" || resVerify[0].status == "por verificar" || resVerify[0].status == "anulado" || resVerify[0].status == "pendiente" || resVerify[0].status == "pagado") {
      Swal.fire({
        title: `Error!`,
        text: "La orden no se puede entregar",
        icon: "error",
      });
    } else {
      Swal.fire({
        title: "¿Deseas entregar esta orden?",
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Si, entregar",
        cancelButtonText: "Cancelar",
        confirmButtonColor: "#FF4B00",
      }).then(async (result) => {
        if (result.isConfirmed) {
          let id_order = btn.getAttribute("id_order");
          data.append("id", id_order);
          data.append("status", status);
          let response = myfecth(`orden/update`, {}, data).json();
          if (response.success == true) {
            Swal.fire({
              title: `Exito!`,
              text: "La orden se entrego correctamente",
              icon: "success",
            });
            if (btn.getAttribute("type") == "mesa") {
              nuevaBitacora("orden", "Actualizacion", `Se envio la orden ${id_order.toString().padStart(5, "0")} a su mesa`);
            } else {
              nuevaBitacora("orden", "Actualizacion", `Se despacho la orden ${id_order.toString().padStart(5, "0")}`);
            }
            tableOrderParaLlevarNull.ajax.reload();
            tableOrderParaLlevarPendingsVeryfy.ajax.reload();
            tableOrderParaLlevarProcess.ajax.reload();
            tableOrderLocalPendingsVeryfy.ajax.reload();
            tableOrderLocalProcess.ajax.reload();
            tableOrderResPendingsVeryfy.ajax.reload()
            tableOrderResProcessVeryfy.ajax.reload()
            targetUpdate("delivery")
            targetUpdate("llevar")
            targetUpdate("reserva")

          } else {
            Swal.fire({
              title: `Error!`,
              text: "La orden no fue entregada",
              icon: "error",
            });
          }
        }
      });
    }
  } else if (action == "print_order") {
    let id = btn.getAttribute('id_order')
    let id_reservation = 0
    if (btn.getAttribute('data_id_reservation')) id_reservation = btn.getAttribute('data_id_reservation')
    let info = myfecth(`orden/get_all`, {}, { id: id }).json();
    let detailsPrepered = myfecth(`Detalle_orden_producto_preparado/get_all`, {}, { id_orden: id }).json();
    let detailsProcess = myfecth(`Detalle_orden_producto_procesado/get_all`, {}, { id_orden: id }).json();
    let totalAmountPrepared = detailsPrepered.map(item => item.precio * item.cantidad).reduce((a, b) => a + b, 0)
    let totalAmountProcess = detailsProcess.map(item => item.precio * item.cantidad).reduce((a, b) => a + b, 0)
    let iva = (totalAmountPrepared + totalAmountProcess) * 0.16
    let dataPaymentAbove = myfecth("pago_reserva/get_all", {}, { id_reserva: id_reservation }).json()
    let dataPayment = myfecth("pago_venta/get_all/0/10000", {}, { id_venta: info[0].id_venta }).json()
    console.log(dataPayment);
    let amountBs = []
    let amountUSD = []
    dataPaymentAbove.forEach(item => {
      if (item.metodo_pago != "divisa") {
        amountBs.push(parseFloat(item.monto))
      } else {
        amountUSD.push(parseFloat(item.monto))
      }
    })
    const above = {
      montoBs: amountBs.reduce((a, b) => a + b, 0),
      montoDolar: amountUSD.reduce((a, b) => a + b, 0)
    }
    let clientData = {
      id_cliente: info[0].id_cliente ?? "POR ASIGNAR",
      nameClient: info[0].cliente_nombre ? info[0].cliente_nombre + " " + info[0].cliente_apellido : "POR ASIGNAR",
      telefonoClient: info[0].cliente_telefono ?? "POR ASIGNAR"
    };
    let amountTotal = {
      total_dolares: "TOTAL: " + (((totalAmountPrepared + totalAmountProcess) + iva).toFixed(2)),
      total_bs: (((totalAmountPrepared + totalAmountProcess) + iva) * parseFloat(dataPayment[0].tasa)).toFixed(2),
      subtotal: "SUBTOTAL: " + ((totalAmountPrepared + totalAmountProcess).toFixed(2)),
      iva: "IVA: " + (iva.toFixed(2))
    }
    invoice(detailsPrepered, detailsProcess, clientData, info[0].id, info[0].direccion ?? "BURGER HOUSE", amountTotal, "print", info, above, dataPayment)
  } else if (action == "more_products") {
    window.id_orden = btn.getAttribute("id_order");
    window.type_order_resLocal = btn.getAttribute("type_module");
    window.id_reservation = btn.getAttribute("data_id_reservation");

    more_product_local_order(functionGeneral, Templates, () => {
      tableOrderLocalPendingsVeryfy.ajax.reload();
      tableOrderLocalProcess.ajax.reload();
      tableOrderResPendingsVeryfy.ajax.reload()
      tableOrderResProcessVeryfy.ajax.reload()
      targetUpdate("reserva")
      targetUpdate("local")

    }, myfecth)
    bootstrap.Modal.getOrCreateInstance('#more_products').show()
  } else if (action == "null_order") {
    Swal.fire({
      title: "¿Deseas anular esta orden?",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Si, anular",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#FF4B00",
    }).then(async (result) => {
      if (result.isConfirmed) {
        let id_order = btn.getAttribute("id_order");
        data.append("id", id_order);
        data.append("status", "anulada");
        let response = myfecth(`orden/update`, {}, data).json();
        if (response.success) {
          if (response.success == true) {
            Swal.fire({
              title: `Exito!`,
              text: "La orden fue anulada correctamente",
              icon: "success",
            });
            nuevaBitacora("orden", "Actualizacion", `Se anulo la orden ${btn.getAttribute("nro_orden")}`);
            tableOrderParaLlevarNull.ajax.reload();
            tableOrderParaLlevarPendingsVeryfy.ajax.reload();
            tableOrderParaLlevarPorDespachar.ajax.reload();
            tableOrderParaLlevarProcess.ajax.reload();
            tableOrderDomicileNull.ajax.reload();
            tableOrderDomicileProcess.ajax.reload();
            tableOrderDomicileoPendings.ajax.reload();
            targetUpdate("delivery")
            targetUpdate("llevar")
          } else {
            Swal.fire({
              title: `Error!`,
              text: "La orden no fue anulada",
              icon: "error",
            });
          }
        }
      }
    });
  } else if (action == "pay_order") {
    const DataFormat = (formatear_fecha) => {
      const fechaFormat = new Date(formatear_fecha);
      const año = fechaFormat.getFullYear();
      const mes = String(fechaFormat.getMonth() + 1).padStart(2, '0');
      const dia = String(fechaFormat.getDate()).padStart(2, '0');
      const formatear_hora = String(fechaFormat.getHours()).padStart(2, '0');
      const minutos = String(fechaFormat.getMinutes()).padStart(2, '0');
      const segundos = String(fechaFormat.getSeconds()).padStart(2, '0');

      const fechaMysql = `${año}-${mes}-${dia} ${formatear_hora}:${minutos}:${segundos}`;
      return fechaMysql
    }
    let id = btn.getAttribute('id_order')
    let id_reservation = 0
    if (btn.getAttribute('id_reservation')) id_reservation = btn.getAttribute('id_reservation')
    let info = myfecth(`orden/get_all`, {}, { id: id }).json()
    let detailsPrepered = myfecth("Detalle_orden_producto_preparado", {}, { id_orden: id }).json()
    let detailsProcess = myfecth("Detalle_orden_producto_procesado", {}, { id_orden: id }).json()
    let totalAmountPrepared = detailsPrepered.map(item => item.precio * item.cantidad).reduce((a, b) => a + b, 0)
    let totalAmountProcess = detailsProcess.map(item => item.precio * item.cantidad).reduce((a, b) => a + b, 0)
    let iva = (totalAmountPrepared + totalAmountProcess) * 0.16
    let dataPaymentAbove = myfecth("pago_reserva", {}, { id_reserva: id_reservation }).json()
    let montoBs = []
    let montoUSD = []
    dataPaymentAbove.forEach(item => {
      if (item.metodo_pago != "divisa") montoBs.push(parseFloat(item.monto))
      else montoUSD.push(parseFloat(item.monto))
    })
    const amountAbove = { montoBs: montoBs.reduce((a, b) => a + b, 0), montoUSD: montoUSD.reduce((a, b) => a + b, 0) }
    let clientData = {
      id_cliente: info[0].id_cliente ?? "POR ASIGNAR",
      nameClient: info[0].cliente_nombre ? info[0].cliente_nombre + " " + info[0].cliente_apellido : "POR ASIGNAR",
      telefonoClient: info[0].cliente_telefono ?? "POR ASIGNAR"
    };
    let amountTotal = {
      total_dolares: "TOTAL: " + (((totalAmountPrepared + totalAmountProcess) + iva).toFixed(2)),
      total_bs: (((totalAmountPrepared + totalAmountProcess) + iva) * await amountDolar()).toFixed(2),
      subtotal: "SUBTOTAL: " + ((totalAmountPrepared + totalAmountProcess).toFixed(2)),
      iva: "IVA: " + (iva.toFixed(2))
    }

    let total_order = parseFloat(amountTotal.total_bs)
    let total_amount_above = amountAbove.montoBs + amountAbove.montoUSD * await amountDolar()
    let total_pay = total_order - total_amount_above
    window.amountTotalOrderLocalPayment = amountTotal
    window.IdOrderPaymentLocal = id
    window.IdReservationPaymentLocal = id_reservation
    window.amountAboveReservation = amountAbove
    window.dataInvoicePaymentLocal = {
      detailsPrepered,
      detailsProcess,
      clientData,
      id,
      direccion: info[0].direccion ?? "BURGER HOUSE",
      amountTotal
    }
    if (info[0].status != "en mesa") {
      Swal.fire({
        title: `Error!`,
        text: "Esta orden no se encuentra en mesa",
        icon: "error",
      });
    } else if (total_amount_above != 0 && (total_pay < 0 && info[0].status == "en mesa")) {
      Swal.fire({
        title: "¿Deseas pagar esta orden?",
        text: `El monto de pago de la reserva, cubre el total de la orden`,
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Si, pagar",
        cancelButtonText: "Cancelar",
        confirmButtonColor: "#FF4B00",
      }).then(async (result) => {
        if (result.isConfirmed) {
          let data = new FormData();
          data.append("id", id);
          data.append("status", "pagado");
          let response = myfecth(`orden/update`, {}, data).json();
          let dataReservation = new FormData();
          dataReservation.append("id", id_reservation);
          dataReservation.append("status", "finalizada");
          dataReservation.append("fecha_final", DataFormat(new Date()));
          let petResponse = myfecth(`calendario/update`, {}, dataReservation).json();
          if (response.success == true && petResponse.success == true) {
            if (response.success == true) {
              Swal.fire({
                title: `Exito!`,
                text: "La orden fue pagada correctamente",
                icon: "success",
              });
              nuevaBitacora("orden", "Actualizacion", `Se pago la orden ${id.toString().padStart(8, "0")}`);
              tableOrderResPendingsVeryfy.ajax.reload();
              tableOrderResProcessVeryfy.ajax.reload();
              targetUpdate("reserva")
            } else {
              Swal.fire({
                title: `Error!`,
                text: "La orden no pudo ser pagada",
                icon: "error",
              });
            }
          }
        }
      });

    } else if (total_amount_above != 0 && (total_pay > 0 && info[0].status == "en mesa")) {
      payOrderReservation(functionGeneral, Templates, invoice, () => {
        tableOrderResPendingsVeryfy.ajax.reload()
        tableOrderResProcessVeryfy.ajax.reload()
        targetUpdate("reserva")
      }, myfecth)
      bootstrap.Modal.getOrCreateInstance('#payment_order_local_reservation').show()
    } else {
      payOrder(functionGeneral, Templates, invoice, () => {
        tableOrderLocalPendingsVeryfy.ajax.reload()
        tableOrderLocalProcess.ajax.reload()
        targetUpdate("local")
      }, myfecth)
      bootstrap.Modal.getOrCreateInstance('#payment_order_local').show()
    }
  }
}
const targetUpdate = async (type) => {
  
 // tamos tontos o q?, 
 
  // let dataNull = []
  // let dataVerify = []
  // let dataDelivery = []
  // let dataForDelivery = []
  // let dataDelivered = []
  // let dataKitchen = []
  // let dataDispatched = []
  // let dataPayed = []

  // let perPayment = []

  // let pet = await searchParam({ tipo: type }, "orden", 1000000000) // ya para cuando traia 7k de resultados ya no es gracioso
  // pet.forEach((order) => {
  //   if (order.status == "anulada") dataNull.push(order)
  //   else if (order.status == "por verificar" && order.tipo == type) dataVerify.push(order)
  //   else if (order.status == "en cocina" || order.status == "en preparacion" && order.tipo == type) dataKitchen.push(order)
  //   else if (order.status == "para despachar" && order.tipo == type) dataDelivery.push(order)
  //   else if (order.status == "en camino" && order.tipo == type) dataForDelivery.push(order)
  //   else if (order.status == "entregada" && order.tipo == type) dataDelivered.push(order)
  //   else if (order.status == "pagado" && order.tipo == type) dataPayed.push(order)
  //   else if (order.status == "en mesa" && order.tipo == type) perPayment.push(order)
  //   else dataDispatched.push(order)
  // })


  const resultado = myfecth("estadisticas/stats_ordenes", {}, {tipo: type }, null, "POST",false).json()[0]

  console.log(resultado);

  if (document.querySelector(`.target_order_${type}_null`) || document.querySelector(`.target_order_${type}_verify`)) {
    document.querySelector(`.target_order_${type}_null`).textContent = resultado.anulada
    document.querySelector(`.target_order_${type}_verify`).textContent = resultado["por verificar"]
  }
  document.querySelector(`.target_order_${type}_total`).textContent = resultado.total

  if (type == "llevar") document.querySelector(`.target_order_${type}_delivery`).textContent = resultado.terminada
  else if (document.querySelector(`.target_order_${type}_delivery`)) {
    document.querySelector(`.target_order_${type}_delivery`).textContent = resultado.entregada
  }

  if (document.querySelector(`.target_order_${type}_delivered`)) {
    document.querySelector(`.target_order_${type}_delivered`).textContent = resultado.entregada
  }


  if (document.querySelector(`.target_order_${type}_running`)) {
    document.querySelector(`.target_order_${type}_running`).textContent = resultado["en camino"]
  }

  document.querySelector(`.target_order_${type}_kitchen`).textContent = resultado["en cocina"]

  if (type == "local") {
    document.querySelector(`.target_order_${type}_perpayment`).textContent = resultado["en mesa"]
    document.querySelector(`.target_order_${type}_intable`).textContent = resultado["en mesa"]
    document.querySelector(`.target_order_${type}_payed`).textContent = resultado.pagado
  }

  if (type == "reserva") {
    document.querySelector(`.target_order_${type}_intable`).textContent = resultado["en mesa"]
    document.querySelector(`.target_order_${type}_payed`).textContent = resultado.pagado
  }
}

targetUpdate("delivery")
targetUpdate("llevar")
targetUpdate("local")
targetUpdate("reserva")

const resetFormModal = () => {
  document.querySelector(".cont-select-product-order").innerHTML = ""
  const container = document.querySelector(".cont_category_product_orders");
  container.innerHTML = container.children[0].outerHTML
  document.querySelector(".target_client_order").innerHTML = ""
  document.querySelector(".loader_client_order").querySelector("h3").classList.remove("d-none")
  document.querySelector(".target_client_order").classList.add("d-none")
  document.querySelector(".loader_client_order").querySelector(".loader").classList.add("d-none")
  document.getElementById('form-search-client-order').reset()
  document.querySelector(".direction_sale").value = ""
  resetForm(".payments", document.getElementById("form-submit-payment"))
}
const resetFormModalLocal = () => {
  document.querySelector(".cont-select-product-order_local").innerHTML = ""
  const container = document.querySelector(".cont_category_product_orders_local");
  container.innerHTML = container.children[0].outerHTML
}
document.querySelectorAll(".btnOrder").forEach((btn) => {
  // if (!btn.dataset.listenerAttached) {
  btn.addEventListener("click", (e) => {
    window.type_order = btn.getAttribute("type_order")
    stepper.to(0)
    domicile_and_takeaway(functionGeneral, Templates, invoice, () => targetUpdate(window.type_order), () => {
      tableOrderDomicileoPendings.ajax.reload()
      tableOrderDomicileProcess.ajax.reload()
      tableOrderDomicileNull.ajax.reload()
      tableOrderParaLlevarPendingsVeryfy.ajax.reload()
      tableOrderParaLlevarProcess.ajax.reload()
      tableOrderParaLlevarNull.ajax.reload()
    }, myfecth)
    resetFormModal()
    setTimeout(() => { bootstrap.Modal.getOrCreateInstance('#domicile_and_takeaway').show() }, 300)
  })
})
const btnLocalOrder = document.querySelector(".btn_order_local")
document.querySelector(".btn_order_local").addEventListener("click", () => {
  stepper2.to(0)
  resetFormModalLocal()
  local(functionGeneral, Templates, () => {
    tableOrderLocalPendingsVeryfy.ajax.reload()
    tableOrderLocalProcess.ajax.reload()
    targetUpdate("local")
  }, myfecth)
  setTimeout(() => { bootstrap.Modal.getOrCreateInstance('#product_and_table').show() }, 300)
})

btnLocalOrder.dataset.listenerAttached = "true"

const pusher = new Pusher('2a7ca356d030e2945ae9', { cluster: 'us2' });
const channelOrder = pusher.subscribe('Order');
channelOrder.bind('order', function (data) {
  targetUpdate("delivery")
  targetUpdate("llevar")
  targetUpdate("local")
  targetUpdate("reserva")

  tableOrderDomicileoPendings.ajax.reload()
  tableOrderDomicileProcess.ajax.reload()
  tableOrderDomicileNull.ajax.reload()
  tableOrderParaLlevarPendingsVeryfy.ajax.reload()
  tableOrderParaLlevarProcess.ajax.reload()
  tableOrderParaLlevarNull.ajax.reload()
  tableOrderLocalPendingsVeryfy.ajax.reload()
  tableOrderLocalProcess.ajax.reload()
  tableOrderResPendingsVeryfy.ajax.reload()
  tableOrderResProcessVeryfy.ajax.reload()

  const toas = document.querySelector(".toast-container")
  toas.querySelector("strong").textContent = data.event
  dayjs.extend(window.dayjs_plugin_relativeTime);
  dayjs.locale('es');
  toas.querySelector("small").textContent = dayjs(data.time).fromNow()
  toas.querySelector(".toast-body").textContent = data.message
  const toastBootstrap = bootstrap.Toast.getOrCreateInstance(toas.querySelector("#liveToast"), { delay: 5000 })
  toastBootstrap.show()
})

