import functionGeneral from "../../Functions.js";
import Templates from "../../templates.js";
import { set_validaciones, reglas_validaciones, validate } from "../../Validaciones.js";
// Inicializar validators personalizados
set_validaciones();
const { setValidationStyles, validateField, addDataTables, reindex, deleteDatatable, editDataTables, updateDataTables, resetForm, sessionInfo, binnacle, permission } = functionGeneral();
const { elemenFormCategoryRawmaterial } = Templates()
let session = await sessionInfo();
document.querySelectorAll(".btn-add-tooltip").forEach((btn) => { new bootstrap.Tooltip(btn) })
let table = $(".table_category_rawmaterial").DataTable({
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    ajax: {
        url: 'categoria_materia_prima/get_all/0/10000000/id/asc',
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
                <button data-id="${data.id}" module-edit="categoria_materia_prima" data-module-edit="categorias" class="btn bh_1 rounded-circle btn-circle edit_btn_datatable" data-bs-toggle="modal" data-bs-target="#edit-categoryRawMaterial" data-bs-title="Editar Categoria" data-bs-placement="bottom">
                    <i data-feather="edit" class="text-white"></i>
                </button>
                <button data-id="${data.id}" module-delete="categoria_materia_prima" data-module-delete="categorias" class="btn bh_5 rounded-circle btn-circle trash_btn_datatable" data-bs-toggle="tooltip" data-bs-title="Eliminar Categoria" data-bs-placement="bottom">
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
$('#searchCategoryRawMaterials').on('keyup', function () { table.search(this.value).draw() });
deleteDatatable(".table_category_rawmaterial", table, () => binnacle(session.user_id, "Materia Prima", "Eliminacion", "Eliminacion de categoria de materia prima"))

let CategoryRawMaterialCount = 1;
function addCategoryRawMaterial() {
    CategoryRawMaterialCount++;
    document.getElementById("categoryRawMaterials-container").insertAdjacentHTML('beforeend', elemenFormCategoryRawmaterial(CategoryRawMaterialCount));
    feather.replace();
    attachValidationListeners(CategoryRawMaterialCount);
    const newCategoryRawMaterial = document.getElementById(`categoryRawMaterials-${CategoryRawMaterialCount}`);
    newCategoryRawMaterial.querySelector(".remove-categoryRawMaterials").addEventListener("click", function () {
        newCategoryRawMaterial.remove();
        reindex("#categoryRawMaterials-container .categoryRawMaterials", `categoryRawMaterials`, CategoryRawMaterialCount, "Categoria Materia Prima");
    });
}
document.getElementById("add-categoryRawMaterial-btn").addEventListener("click", () => {
    addCategoryRawMaterial()
    reindex("#categoryRawMaterials-container .categoryRawMaterials", `categoryRawMaterials`, CategoryRawMaterialCount, "Categoria Materia Prima");
});
function attachValidationListeners(index) {
    const unitElement = document.getElementById(`categoryRawMaterials-${index}`);
    unitElement.querySelectorAll("input[type='text']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("blur", (e) => validateField(e, reglas_validaciones));
    });
    const category2 = document.getElementById(`categoryRawMaterial-container`);
    category2.querySelectorAll("input[type='text']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("blur", (e) => validateField(e, reglas_validaciones));
    });
}

let form = document.getElementById("form-submit-categoryRawMaterials")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        const categoryRawMaterial = document.querySelectorAll(".categoryRawMaterials");
        let formHasError = false;
        let datacategoryRawMaterial = []

        categoryRawMaterial.forEach((category, i) => {
            const index = i + 1;
            const data = {
                nombre: category.querySelector(`input[name="nombre"]`).value,
            }
            datacategoryRawMaterial.push(data)
            const errors = validate(data, reglas_validaciones);
            setValidationStyles(`input-name-categoryRawMaterials-${index}`, errors?.nombre ? errors.nombre[0] : null);
            if (errors?.nombre) {
                formHasError = true;
            }
        })
        if (!formHasError) {
            let dataFinal = new FormData()
            datacategoryRawMaterial.forEach((category, index) => {
                dataFinal.append(`lista[${index}][nombre]`, category.nombre)
            })
            addDataTables(table, dataFinal, "categoria_materia_prima", binnacle(session.user_id, "Materia Prima", "Agregar", "Se agrego una nueva categoria materia prima"))
            resetForm(".categoryRawMaterials", form)
            bootstrap.Modal.getOrCreateInstance('#register-categoryRawMaterials').hide()
        }
    })
    form.dataset.listenerAttached = "true";
}

editDataTables(".table_category_rawmaterial", (response) => {
    let formHasError = false;
    console.log(document.querySelector("#input-name-categoryRawMaterial"));
    document.querySelector("#input-name-categoryRawMaterial").value = response[0].nombre;
    document.querySelector("#input-id-categoryRawMaterial").value = response[0].id;
    const data = {
        nombre: document.querySelector(`#input-name-categoryRawMaterial`).value,
    }
    const errors = validate(data, reglas_validaciones);
    setValidationStyles(`input-name-categoryRawMaterial`, errors?.nombre ? errors.nombre[0] : null);

    if (errors?.nombre) {
        formHasError = true;
    }
    let formEdit = document.getElementById("form-submit-edit-categoryRawMaterial")
    if (!formEdit.dataset.listenerAttached) {
        formEdit.addEventListener("submit", (e) => {
            e.preventDefault();
            const data = {
                nombre: document.querySelector(`#input-name-categoryRawMaterial`).value,
            }
            const errors = validate(data, reglas_validaciones);
            setValidationStyles(`input-name-categoryRawMaterial`, errors?.nombre ? errors.nombre[0] : null);
            if (errors?.nombre) formHasError = true;
            else formHasError = false;

            if (!formHasError) {
                let dataFinal = new FormData()
                dataFinal.append(`nombre`, document.querySelector(`#input-name-categoryRawMaterial`).value)
                dataFinal.append(`id`, document.querySelector("#input-id-categoryRawMaterial").value)
                updateDataTables(table, dataFinal, "categoria_materia_prima", binnacle(session.user_id, "Materia Prima", "Actualizar", "Se actualizo una categoria de materia prima"))
                bootstrap.Modal.getOrCreateInstance('#edit-categoryRawMaterial').hide()
            }
        })
        formEdit.dataset.listenerAttached = "true";
    }
})
attachValidationListeners(1);