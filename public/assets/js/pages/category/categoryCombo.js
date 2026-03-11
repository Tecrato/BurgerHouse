import functionGeneral from "../../Functions.js";
import { nuevaBitacora, modal_operacion, myfecth } from "../../Functions2.js";
import Templates from "../../templates.js";
import { set_validaciones, reglas_validaciones, validate } from "../../Validaciones.js";
// Inicializar validators personalizados
set_validaciones();
const { setValidationStyles, validateField, addDataTables, reindex, deleteDatatable, editDataTables, updateDataTables, resetForm, sessionInfo, binnacle, permission } = functionGeneral();
const { elemenFormCategoryProduct } = Templates()
let session = await sessionInfo();
permission("categorias")
document.querySelectorAll(".btn-add-tooltip").forEach((btn) => { new bootstrap.Tooltip(btn) })
let n = $(".table_combo").DataTable({
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    ajax: {
        url: 'categoria_producto/get_all/0/10000000/id/asc',
        dataSrc: '',
        type: 'POST',
        data: {
            active: 1,
        },
    },
    columns: [
        { data: 'id' },
        { data: 'nombre' },
        {
            data: null,
            orderable: false,
            render: function (data, type, row, meta) {
                return `
                <button data-id="${data.id}" module-edit="categoria_producto" data-module-edit="categorias" class="btn bh_1 rounded-circle btn-circle edit_btn_datatable" data-bs-toggle="modal" data-bs-target="#editar_categoria_producto" data-bs-title="Editar Categoria" data-bs-placement="bottom">
                    <i data-feather="edit" class="text-white"></i>
                </button>
                <button data-id="${data.id}" module-delete="categoria_producto" data-module-delete="categorias" class="btn bh_5 rounded-circle btn-circle trash_btn_datatable" data-bs-toggle="tooltip" data-bs-title="Eliminar Categoria" data-bs-placement="bottom">
                    <i data-feather="trash" class="text-white"></i>
                </button>
`;
            }
        }
    ],
    drawCallback: function (settings) {
        feather.replace();
        document.querySelectorAll(".trash_btn_datatable, .edit_btn_datatable").forEach((btn) => {
            let tooltip = new bootstrap.Tooltip(btn)
        })
        permission("categorias")
    },
    "dom": 'tipr',
    "paging": true,
    "info": true,
})
$('#searchCategoryProducts').on('keyup', function () { n.search(this.value).draw() });
// modal_operacion(
//     () => myfecth("categoria_producto/delete", {}, {}),
//     'eliminar',
//     () => {
//         n.ajax.reload()
//     }
// )
deleteDatatable(".table_combo", n, () => nuevaBitacora("Categoria de Producto", "Eliminacion", "Se elimino una categoria de productos"))

let contador_categoria_producto = 1;
function agregar_categoria_producto() {
    contador_categoria_producto++;
    document.getElementById("contenedor_categorias_producto").insertAdjacentHTML('beforeend', elemenFormCategoryProduct(contador_categoria_producto));
    feather.replace();
    adjuntar_escuchas_validacion(contador_categoria_producto);
    const nueva_categoria_producto = document.getElementById(`categoria_producto-${contador_categoria_producto}`);
    nueva_categoria_producto.querySelector(".remove-categoryProducts").addEventListener("click", function () {
        nueva_categoria_producto.remove();
        reindex("#contenedor_categorias_producto .categoria_producto", `categoria_producto`, contador_categoria_producto, "Categoria Producto");
    });
}
document.getElementById("btn_agregar_categoria_producto").addEventListener("click", () => {
    agregar_categoria_producto()
    reindex("#contenedor_categorias_producto .categoria_producto", "categoria_producto", contador_categoria_producto, "Categoria Producto");
});
function adjuntar_escuchas_validacion(indice) {
    const elemento_unidad = document.getElementById(`categoria_producto-${indice}`);
    elemento_unidad.querySelectorAll("input[type='text']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("blur", (e) => validateField(e, reglas_validaciones));
    });
    const categoria2 = document.getElementById(`contenedor_categorias_producto`);
    categoria2.querySelectorAll("input[type='text']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("blur", (e) => validateField(e, reglas_validaciones));
    });
}

let formulario = document.getElementById("formulario_enviar_categoria_producto")
if (!formulario.dataset.listenerAttached) {
    formulario.addEventListener("submit", (e) => {
        e.preventDefault();
        const categorias_producto = document.querySelectorAll(".categoria_producto");
        let formulario_con_error = false;
        let datos_categorias_producto = []

        categorias_producto.forEach((categoria, i) => {
            const indice = i + 1;
            const datos = {
                nombre: categoria.querySelector(`input[name="nombre"]`).value,
            }
            datos_categorias_producto.push(datos)
            const errores = validate(datos, reglas_validaciones);
            setValidationStyles(`input_nombre_categoria_producto-${indice}`, errores?.nombre ? errores.nombre[0] : null);
            if (errores?.nombre) {
                formulario_con_error = true;
            }
        })
        if (!formulario_con_error) {
            let datos_finales = new FormData()
            datos_categorias_producto.forEach((categoria, indice) => {
                datos_finales.append(`lista[${indice}][nombre]`, categoria.nombre)
            })
            
            modal_operacion(
                () => {
                    return myfecth("categoria_producto/add_many", {}, datos_finales)
                },
                'agregar',
                () => {
                    n.ajax.reload()
                    nuevaBitacora("Categoria de Producto", "Agregar", "Se agrego una categoria de productos")
                }
            )
            resetForm(".categoria_producto", formulario)
            bootstrap.Modal.getOrCreateInstance('#registrar_categoria_producto').hide()
        }
    })
    formulario.dataset.listenerAttached = "true";
}

editDataTables(".table_combo", (response) => {
    let formulario_con_error = false;
    document.querySelector("#input_nombre_categoria_producto_editar").value = response[0].nombre;
    document.querySelector("#input_id_categoria_producto").value = response[0].id;
    const datos = {
        nombre: document.querySelector(`#input_nombre_categoria_producto_editar`).value,
    }
    const errores = validate(datos, reglas_validaciones);
    setValidationStyles(`input_nombre_categoria_producto_editar`, errores?.nombre ? errores.nombre[0] : null);

    if (errores?.nombre) {
        formulario_con_error = true;
    }
    
    let formulario_editar = document.getElementById("formulario_editar_categoria_producto")
    if (!formulario_editar.dataset.listenerAttached) {
        formulario_editar.addEventListener("submit", (e) => {
            e.preventDefault();
            const datos = {
                nombre: document.querySelector(`#input_nombre_categoria_producto_editar`).value,
            }
            const errores = validate(datos, reglas_validaciones);
            setValidationStyles(`input_nombre_categoria_producto_editar`, errores?.nombre ? errores.nombre[0] : null);
            if (errores?.nombre) formulario_con_error = true;
            else formulario_con_error = false;

            if (!formulario_con_error) {
                let datos_finales = new FormData()
                datos_finales.append(`nombre`, document.querySelector(`#input_nombre_categoria_producto_editar`).value)
                datos_finales.append(`id`, document.querySelector("#input_id_categoria_producto").value)
                modal_operacion(
                    () => myfecth("categoria_producto/update", {}, datos_finales),
                    'editar',
                    () => {
                        bootstrap.Modal.getOrCreateInstance('#editar_categoria_producto').hide()
                        nuevaBitacora("Categoria de Producto", "Actualizacion", "Se actualizo una categoria de productos")
                        n.ajax.reload()
                    }
                )
            }
        })
        formulario_editar.dataset.listenerAttached = "true";
    }
})
adjuntar_escuchas_validacion(1);