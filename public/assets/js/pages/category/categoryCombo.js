import functionGeneral from "../../Functions.js";
import { nuevaBitacora } from "../../Functions2.js";
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
                <button data-id="${data.id}" module-edit="categoryProducto" data-module-edit="categorias" class="btn bh_1 rounded-circle btn-circle edit_btn_datatable" data-bs-toggle="modal" data-bs-target="#edit-categoryCombo" data-bs-title="Editar Categoria" data-bs-placement="bottom">
                    <i data-feather="edit" class="text-white"></i>
                </button>
                <button data-id="${data.id}" module-delete="categoryProducto" data-module-delete="categorias" class="btn bh_5 rounded-circle btn-circle trash_btn_datatable" data-bs-toggle="tooltip" data-bs-title="Eliminar Categoria" data-bs-placement="bottom">
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
deleteDatatable(".table_combo", n, () => nuevaBitacora("Categoria de Producto", "Eliminacion", "Se elimino una categoria de productos"))

let CategoryProductCount = 1;
function addCategoryCombo() {
    CategoryProductCount++;
    document.getElementById("categoryCombos-container").insertAdjacentHTML('beforeend', elemenFormCategoryProduct(CategoryProductCount));
    feather.replace();
    attachValidationListeners(CategoryProductCount);
    const newCategoryCombo = document.getElementById(`categoryCombos-${CategoryProductCount}`);
    newCategoryCombo.querySelector(".remove-categoryProducts").addEventListener("click", function () {
        newCategoryCombo.remove();
        reindex("#categoryCombos-container .categoryCombos", `categoryCombos`, CategoryProductCount, "Categoria Combo");
    });
}
document.getElementById("add-categoryProduct-btn").addEventListener("click", () => {
    addCategoryCombo()
    reindex("#categoryCombos-container .categoryCombos", "categoryCombos", CategoryProductCount, "Categoria Combo");
});
function attachValidationListeners(index) {
    const unitElement = document.getElementById(`categoryCombos-${index}`);
    unitElement.querySelectorAll("input[type='text']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("blur", (e) => validateField(e, reglas_validaciones));
    });
    const category2 = document.getElementById(`categoryCombo-container`);
    category2.querySelectorAll("input[type='text']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("blur", (e) => validateField(e, reglas_validaciones));
    });
}

let form = document.getElementById("form-submit-categoryProduct")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        const CategoryCombos = document.querySelectorAll(".categoryCombos");
        let formHasError = false;
        let dataCategoryCombos = []

        CategoryCombos.forEach((category, i) => {
            const index = i + 1;
            const data = {
                nombre: category.querySelector(`input[name="nombre"]`).value,
            }
            dataCategoryCombos.push(data)
            const errors = validate(data, reglas_validaciones);
            setValidationStyles(`input-name-categoryProduct-${index}`, errors?.nombre ? errors.nombre[0] : null);
            if (errors?.nombre) {
                formHasError = true;
            }
        })
        if (!formHasError) {
            let dataFinal = new FormData()
            dataCategoryCombos.forEach((category, index) => {
                dataFinal.append(`lista[${index}][nombre]`, category.nombre)
            })
            addDataTables(n, dataFinal, "categoryProducto", nuevaBitacora("Categoria de Producto", "Agregar", "Se agrego una categoria de productos"))
            resetForm(".categoryCombos", form)
            bootstrap.Modal.getOrCreateInstance('#register-categoryCombo').hide()
        }
    })
    form.dataset.listenerAttached = "true";
}

editDataTables(".table_combo", (response) => {
    let formHasError = false;
    document.querySelector("#input-name-categoryProduct").value = response[0].nombre;
    document.querySelector("#input-id-categoryCombo").value = response[0].id;
    const data = {
        nombre: document.querySelector(`#input-name-categoryProduct`).value,
    }
    const errors = validate(data, reglas_validaciones);
    setValidationStyles(`input-name-categoryProduct`, errors?.nombre ? errors.nombre[0] : null);

    if (errors?.nombre) {
        formHasError = true;
    }
    let formEdit = document.getElementById("form-submit-edit-categoryProduct")
    if (!formEdit.dataset.listenerAttached) {
        formEdit.addEventListener("submit", (e) => {
            e.preventDefault();
            const data = {
                nombre: document.querySelector(`#input-name-categoryProduct`).value,
            }
            const errors = validate(data, reglas_validaciones);
            setValidationStyles(`input-name-categoryProduct`, errors?.nombre ? errors.nombre[0] : null);
            if (errors?.nombre) formHasError = true;
            else formHasError = false;

            if (!formHasError) {
                let dataFinal = new FormData()
                dataFinal.append(`nombre`, document.querySelector(`#input-name-categoryProduct`).value)
                dataFinal.append(`id`, document.querySelector("#input-id-categoryCombo").value)
                updateDataTables(n, dataFinal, "categoryProducto", nuevaBitacora("Categoria de Producto", "Actualizacion", "Se actualizo una categoria de productos"))
                bootstrap.Modal.getOrCreateInstance('#edit-categoryCombo').hide()
            }
        })
        formEdit.dataset.listenerAttached = "true";
    }
})
attachValidationListeners(1);