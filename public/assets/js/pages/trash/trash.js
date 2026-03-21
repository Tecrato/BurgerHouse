import functionGeneral from "../../Functions.js";
import { nuevaBitacora } from "../../Functions2.js"
import introTooltip from "../../intro-tooltip.js"
const {trash} = introTooltip()
const { sessionInfo, binnacle, fecha, permission } = functionGeneral();
let session = await sessionInfo()
trash('navbarDropdown')
const modulesConfig = {
    mesas: {
        ajax: {
            dataSrc: '',
            url: 'mesas/get_all/0/10000000/id/asc',
            type: 'POST',
            data: { active: 0 },
        },
        columns: [
            { title: 'ID', data: 'id' },
            { title: 'Imagen', data: null, render: (data) => `<img src='${"media/table/" + data.imagen}' width='50px' height='50px' alt='Imagen de la mesa'>` },
            { title: 'Nombre', data: 'nombre' },
            { title: 'Sillas', data: 'sillas' },
            {
                title: 'Acciones',
                data: null,
                orderable: false,
                render: (data) => `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore="mesas" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Mesa" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>`
            }
        ]
    },
    product_prepared: {
        ajax: {
            url: 'producto_preparado/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            data: {
                active: 0,
            }
        },
        columns: [
            { title: '', data: null, render: (data) => `<img src='${data.imagen ? "media/producto preparado/" + data.imagen : "./assets/img/big/banner_login.png"}' width='50px' height='50px' alt='Imagen del producto preparado'>` },
            { title: 'Nombre', data: 'nombre' },
            { title: 'Precio', data: null, render: (data) => { return (data.precio).toString().replace(".", ",") + " $" } },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore="producto_preparado" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Producto" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>
                `
            }
        ]
    },
    product_processed: {
        ajax: {
            url: 'producto_procesado/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            data: {
                active: 0,
            }
        },
        columns: [
            { title: '', data: null, render: (data) => `<img src='${data.imagen ? "media/producto_procesado/" + data.imagen : "./assets/img/big/banner_login.png"}' width='50px' height='50px' alt='Imagen del producto procesado'>` },
            { title: 'Nombre', data: 'nombre' },
            { title: 'Precio', data: null, render: (data) => { return (data.precio).toString().replace(".", ",") + " $" } },

            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore="producto_procesado" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Producto" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>
                `
            }
        ]
    },
    Proveedores: {
        ajax: {
            url: 'provedor/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            data: {
                active: 0
            }
        },
        columns: [
            { title: 'ID', data: 'id' },
            { title: 'Nombre', data: 'nombre' },
            { title: 'Razon Social', data: 'razon_social' },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                  <button data-id="${data.id}" data-module-restore="Papelera" module-restore="proveedor" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Proveedor" data-bs-placement="bottom">
                      <i data-feather="refresh-ccw" class="text-white"></i>
                  </button>
                  `
            }
        ]
    },
    Clientes: {
        ajax: {
            url: 'clientes/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            data: {
                active: 0
            }
        },
        columns: [
            { title: 'ID', data: 'id' },
            { title: 'Nombre', data: null, render: (data) => `${data.nombre + " " + data.apellido}` },
            { title: 'Telefono', data: 'telefono' },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore="clientes" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Cliente" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>
                `
            }
        ]
    },
    Unidades: {
        ajax: {
            url: 'unidades/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            dataSrc: '',
            data: {
                active: 0
            }
        },
        columns: [
            { title: 'ID', data: 'id' },
            { title: 'Nombre', data: 'nombre' },
            { title: 'Alias', data: 'alias' },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore="unidades" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Unidad" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>
                `
            }
        ]
    },
    materia_prima: {
        ajax: {
            url: 'materia_prima/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            dataSrc: '',
            data: {
                active: 0
            }
        },
        columns: [
            { title: 'ID', data: 'id' },
            { title: 'Nombre', data: 'nombre' },
            { title: 'Categoria', data: 'nombre_categoria' },
            { title: 'Unidad', data: 'alias_unidad' },
            { title: 'Stock Min', data: 'stock_min' },
            { title: 'StocK Max', data: 'stock_max' },
            { title: 'existencia', data: 'existencia' },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore="materia_prima" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Unidad" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>
                `
            }
        ]
    },
    Categoria_combo: {
        ajax: {
            url: 'categoria_producto/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            data: {
                active: 0
            }
        },
        columns: [
            { title: 'ID', data: 'id' },
            { title: 'Nombre', data: 'nombre' },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                  <button data-id="${data.id}" data-module-restore="Papelera" module-restore="categoria_poducto" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Categoria" data-bs-placement="bottom">
                      <i data-feather="refresh-ccw" class="text-white"></i>
                  </button>
                  `
            }
        ]
    },
    Categoria_rawmaterial: {
        ajax: {
            url: 'categoria_materia_prima/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            data: {
                active: 0
            }
        },
        columns: [
            { title: 'ID', data: 'id' },
            { title: 'Nombre', data: 'nombre' },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore="categoria_materia_prima" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Categoria" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>
                `
            }
        ]
    },
    Metodos_pago: {
        ajax: {
            url: 'metodo_pago/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            data: {
                active: 0
            }
        },
        columns: [
            { title: 'ID', data: 'id' },
            { title: 'Nombre', data: 'nombre' },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore="metodo_pago" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Metodo de pago" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>
                `
            }
        ]
    },
    Roles: {
        ajax: {
            url: 'roles/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            data: {
                active: 0
            }
        },
        columns: [
            { title: 'ID', data: 'id' },
            { title: 'Nombre', data: 'nombre' },
            { title: 'Descripcion', data: 'descripcion' },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore="roles" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Rol" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>
                `
            }
        ]
    },
    Usuarios: {
        ajax: {
            url: 'users/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            data: {
                active: 0
            }
        },
        columns: [
            { title: 'ID', data: 'id' },
            { title: 'Nombre', data: null, render: (data) => { return `${data.nombre} ${data.apellido}` } },
            { title: 'Correo', data: 'email' },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore="users" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Usuario" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>
                `
            }
        ]
    },
    Adicionales: {
        ajax: {
            url: 'adicionales/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            data: { active: 0, tipo: "adicional" }
        },
        columns: [
            { title: '', data: null, render: (data) => { return `<img style="object-fit: cover" src='media/adicionales/${data.imagen}' width='50px' height='50px' alt='Imagen del adicional'>` } },
            { title: 'Nombre', data: 'nombre' },
            { title: 'Precio', data: null, render: (data) => { return (data.precio).toString().replace(".", ",") + " $" } },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore="adicionales" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Adicional" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>
                `
            }
        ]
    },
    entry_raw_material: {
        ajax: {
            url: 'entrada_materia_prima_detalles/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            data: {
                active: 0,
            }
        },
        columns: [
            { title: "#", data: 'id' },
            { title: "Codigo", data: 'codigo' },
            { title: "M.P", data: 'nombre_materia_prima' },
            { title: "Provee.", data: 'nombre_proveedor' },
            { title: "Cantidad", data: 'cantidad' },
            { title: "Fecha vencimiento", data: false, render: (data, type, row) => { return fecha(row.fecha_vencimiento) } },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore=Entrada_materia_prima/ class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Entrada" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>
                `
            }
        ]
    },
    entry_product_processed: {
        ajax: {
            url: 'entrada_producto_procesado/get_all/0/10000000/id/asc',
            dataSrc: '',
            type: 'POST',
            data: { active: 0 }
        },
        columns: [
            { title: "#", data: 'id' },
            { title: "Codigo", data: 'codigo' },
            { title: "Product.", data: 'nombre_producto' },
            { title: "Provee.", data: 'nombre_proveedor' },
            { title: "Cantidad", data: 'cantidad' },
            { title: "Fecha", data: false, render: (data, type, row) => { return fecha(row.fecha_compra) } },
            {
                title: 'Acciones',
                data: null,
                render: (data) =>
                    `
                <button data-id="${data.id}" data-module-restore="Papelera" module-restore="entrada_producto_procesado" class="btn bh_1 rounded-circle btn-circle btn_datatable_restore" data-bs-toggle="tooltip" data-bs-title="Restaurar Entrada" data-bs-placement="bottom">
                    <i data-feather="refresh-ccw" class="text-white"></i>
                </button>
                `
            }
        ]
    }
};

let table;
function initTable(moduleKey) {
    const config = modulesConfig[moduleKey];
    if (!config) {
        $('.table_trash').hide();
        return;
    }
    $('.table_trash').show();

    // Destruye y limpia DOM si ya había otra tabla
    if ($.fn.DataTable.isDataTable('.table_trash')) {
        $('.table_trash').DataTable().destroy();
        $('.table_trash thead').empty();
        $('.table_trash tbody').empty();
    }
    $('.table_trash thead').empty();
    $('.table_trash tbody').empty();
    // Reconstruye <thead>
    $('.table_trash thead').append('<tr></tr>');
    config.columns.forEach(col => { $('.table_trash thead tr').append(`<th>${col.title}</th>`) });
    table = $('.table_trash').DataTable({
        destroy: true,
        ajax: config.ajax,
        columns: config.columns,
        language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
        drawCallback: function () {
            feather.replace();
            document.querySelectorAll(".btn_datatable_restore").forEach(btn => new bootstrap.Tooltip(btn));
            permission("Papelera")
        },
        dom: 'tipr',
        paging: true,
        info: true,
    });
    $('#SearchTrash').on('keyup', function () { table.search(this.value).draw() });
    $('.table_trash tbody').off('click', 'button.btn_datatable_restore').on('click', 'button.btn_datatable_restore', function () {
        Swal.fire({
            title: "¿Deseas Restaurar este elemento?",
            icon: "warning",
            showCancelButton: true,
            confirmButtonText: "Restaurar",
            cancelButtonText: "Cancelar",
            confirmButtonColor: "#FF4B00",
        }).then((result) => {
            if (result.isConfirmed) {
                const id = this.getAttribute('data-id');
                const module = this.getAttribute('module-restore');
                $.ajax({
                    type: "POST",
                    url: `${module}/update`,
                    data: { id, active: 1 },
                    success: function (response) {
                        if (response.success == true) {
                            Swal.fire({
                                title: `Exito!`,
                                text: "El elemento fue restaurado correctamente",
                                icon: "success",
                            });
                            table.ajax.reload();
                            nuevaBitacora("Papelera", "Restaurar", "Se ha restaurado un elemento de la papelera")
                        } else {
                            Swal.fire({
                                title: `Error!`,
                                text: "El elemento no fue restaurado",
                                icon: "error",
                            });
                        }
                    }
                });
            }
        });
    });
}
let select = document.querySelector(".select_options_module")
let options = select.querySelectorAll(".dropdown-item")
options.forEach((option) => {
    option.addEventListener("click", () => {
        let moduleKey = option.getAttribute("data-key");
        let moduleName = option.textContent;
        select.querySelector("input[type='button']").value = moduleName
        initTable(moduleKey);
    });
});
initTable("mesas");
