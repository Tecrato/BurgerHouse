import functionGeneral from "../../Functions.js";
import Templates from "../../templates.js";
import introTooltip from "../../intro-tooltip.js"
import { 
    nuevaBitacora,
    InputPriceFormat,
    myfecth
 } from "../../Functions2.js";
import { set_validaciones, reglas_validaciones, validate } from "../../Validaciones.js";
// Inicializar validators personalizados
set_validaciones();
const { resetForm, setValidationStyles, validateField, addDataTables, reindex, deleteDatatable, editDataTables, updateDataTables, InputPrice, sessionInfo, viewImage, permission } = functionGeneral();
const { elemenFormAdditional } = Templates()
const { additional } = introTooltip()
additional('navbarDropdown')
InputPrice("[input_price]");
viewImage(".input-image")
permission("Adicionales")
let session = await sessionInfo();
let tooltip = new bootstrap.Tooltip(document.querySelector(".btn-add-tooltip"))
let n = $(".table_additional").DataTable({
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    processing: true,
    serverSide: true,
    pageLength: 10,
    ajax: function (data, callback, settings) {
        let page = Math.floor(data.start / data.length);
        let size = data.length;
        let totalRaw = myfecth("adicionales/count", {}, { active: 1, tipo: "adicional" }, null, 'POST');
        let total = 0;
        try {
            total = JSON.parse(totalRaw);
        } catch (e) {
            total = parseInt(totalRaw) || 0;
        }
        myfecth(
            `adicionales/get_all/${page}/${size}/${settings.aoColumns[data.order[0].column].data}/${data.order[0].dir}`,
            {},
            { active: 1, tipo: "adicional" },
            function (resp) {
                resp = resp.json()
                callback({
                    draw: data.draw,
                    data: resp.data || resp || [],
                    recordsTotal: total,
                    recordsFiltered: total
                });
            },
            'POST',
            true,
            function (err) {
                console.error(err);
                callback({ draw: data.draw, data: [], recordsTotal: 0, recordsFiltered: 0 });
            }
        )
    },
    columns: [
        { data: 'nombre' },
        { data: null, render: (data, type, row, meta) => { return `<img style="object-fit: cover" src='${data.imagen ? "media/additional/" + data.imagen : "./assets/img/big/banner_login.png"}' width='50px' height='50px' alt='Imagen del adicional'>` } },
        { data: null, render: (data, type, row, meta) => { return data.precio + " $" } },
        {
            data: null,
            orderable: false,
            render: function (data, type, row, meta) {
                return `
                <button data-id="${data.id}" module-edit="adicionales" data-module-edit="Adicionales" class="btn bh_1 rounded-circle btn-circle edit_btn_datatable" data-bs-toggle="modal" data-bs-target="#edit-additional" data-bs-title="Editar Adicional" data-bs-placement="bottom">
                    <i data-feather="edit" class="text-white"></i>
                </button>
                <button data-id="${data.id}" module-delete="adicionales" data-module-delete="Adicionales" class="btn bh_5 rounded-circle btn-circle trash_btn_datatable" data-bs-toggle="tooltip" data-bs-title="Eliminar Adicional" data-bs-placement="bottom">
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
        permission("Adicionales")
    },
    "dom": 'tipr',
    "paging": true,
    "info": true,
})
$('#searchAdditional').on('keyup', function () {
    n.search(this.value).draw();
});

let additionalCount = 1;
function addAdditional() {
    additionalCount++;
    document.getElementById("additionals-container").insertAdjacentHTML('beforeend', elemenFormAdditional(additionalCount));
    feather.replace();
    InputPriceFormat("[input_price]");
    viewImage(".input-image")

    attachValidationListeners(additionalCount);
    const newAdditional = document.getElementById(`additionals-${additionalCount}`);
    newAdditional.querySelector(".remove-additional").addEventListener("click", function () {
        newAdditional.remove();
        reindex("#additionals-container .additionals", "additionals", additionalCount, "Adicional");
    });
}
document.getElementById("add-additional-btn").addEventListener("click", () => {
    addAdditional();
    reindex("#additionals-container .additionals", "additionals", additionalCount, "Adicional");
});
function attachValidationListeners(index) {
    const additionalElement = document.getElementById(`additionals-${index}`);
    additionalElement.querySelectorAll("input[type='text'], input[type='file']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("blur", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("change", (e) => validateField(e, reglas_validaciones));
    });
    const element2 = document.getElementById(`additional`);
    element2.querySelectorAll("input[type='text']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("blur", (e) => validateField(e, reglas_validaciones));
    });
}
// Las reglas se definen directamente en cada validate() usando reglas_validaciones

let form = document.getElementById("form-submit-additionals")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        const additionals = document.querySelectorAll(".additionals");
        let formHasError = false;
        let dataAdditionals = []

        additionals.forEach((additional, i) => {
            const index = i + 1;
            const data = {
                nombre: additional.querySelector(`input[name="nombre"]`).value,
                precio: additional.querySelector(`input[name="precio"]`).value.replace(/\./g, '').replace(',', '.'),
                imagen: additional.querySelector(`input[name="imagen"]`) ? additional.querySelector(`input[name="imagen"]`).files[0] : ""
            };
            dataAdditionals.push(data)
            const errors = validate(data, reglas_validaciones);
            setValidationStyles(`input-name-additional-${index}`, errors?.nombre ? errors.nombre[0] : null);
            setValidationStyles(`input-price-additional-${index}`, errors?.precio ? errors.precio[0] : null);
            setValidationStyles(`input-image-additional-${index}`, errors?.imagen ? errors.imagen[0] : null);
            if (errors?.nombre || errors?.precio || errors?.imagen) formHasError = true;
        })
        if (!formHasError) {
            console.log(dataAdditionals);
            let dataFinal = new FormData()
            dataAdditionals.forEach((additional, index) => {
                dataFinal.append(`lista[${index}][nombre]`, additional.nombre)
                dataFinal.append(`lista[${index}][precio]`, additional.precio)
                dataFinal.append(`lista[${index}][imagen]`, additional.imagen)
                dataFinal.append(`lista[${index}][imagen_name]`, additional.imagen.name)
                dataFinal.append(`lista[${index}][tipo]`, "adicional")
            })
            addDataTables(n, dataFinal, "adicionales", () => nuevaBitacora("Adicionales", "Agregar", "Se agrego un nuevo adicional"))
            resetForm(".additionals", form)
            bootstrap.Modal.getOrCreateInstance('#register-additional').hide()
        }
    })
    form.dataset.listenerAttached = "true";
}
editDataTables(".table_additional", (response) => {
    let formHasError = false;
    document.getElementById("form-submit-edit-additional").reset();
    document.querySelector(`#input-name-additional`).value = response[0].nombre,
    document.querySelector(`#input-id-additional`).value = response[0].id,
    document.querySelector(`#input-price-additional`).value = (response[0].precio).toString().replace(/\./g, ',')
    document.querySelector(`#img-additional-response`).src = `media/additional/${response[0].imagen}`

    const data = {
        nombre: document.querySelector(`#input-name-additional`).value,
        precio: document.querySelector(`#input-price-additional`).value.replace(/\./g, '').replace(',', '.'),
    }

    const errors = validate(data, reglas_validaciones);
    setValidationStyles(`input-name-additional`, errors?.nombre ? errors.nombre[0] : null);
    setValidationStyles(`input-price-additional`, errors?.precio ? errors.precio[0] : null);

    if (errors?.nombre || errors?.precio) formHasError = true;

})

let formEdit = document.getElementById("form-submit-edit-additional")
if (!formEdit.dataset.listenerAttached) {
    formEdit.addEventListener("submit", (e) => {
        let formHasError = false;
        e.preventDefault();
        const data = {
            nombre: document.querySelector(`#input-name-additional`).value,
            precio: document.querySelector(`#input-price-additional`).value.replace(/\./g, '').replace(',', '.'),
            imagen: document.querySelector(`#input-image-additional`).files[0]
        }
        const errors = validate(data, reglas_validaciones);
        setValidationStyles(`input-name-additional`, errors?.nombre ? errors.nombre[0] : null);
        setValidationStyles(`input-price-additional`, errors?.precio ? errors.precio[0] : null);
        setValidationStyles(`input-image-additional`, errors?.imagen ? errors.imagen[0] : null);

        if (errors?.nombre || errors?.precio || errors?.imagen) formHasError = true;
        else formHasError = false;

        if (!formHasError) {
            let dataFinal = new FormData()
            dataFinal.append(`id`, document.querySelector(`#input-id-additional`).value)
            dataFinal.append(`nombre`, document.querySelector(`#input-name-additional`).value)
            dataFinal.append(`precio`, document.querySelector(`#input-price-additional`).value.replace(/\./g, '').replace(',', '.'))
            if (document.querySelector(`#input-image-additional`).value != "") {
                dataFinal.append(`imagen`, document.querySelector(`#input-image-additional`).files[0])
                dataFinal.append(`imagen_name`, document.querySelector(`#input-image-additional`).files[0].name)
            }
            updateDataTables(n, dataFinal, "adicionales", () => nuevaBitacora("Adicionales", "Actualizacion", "Se actualizo un adicional"))
            bootstrap.Modal.getOrCreateInstance('#edit-additional').hide()
        }
    })
    formEdit.dataset.listenerAttached = "true";
}
deleteDatatable(".table_additional", n, () => nuevaBitacora("Adicionales", "Eliminacion", "Se ha eliminado un adicional"))
attachValidationListeners(1);
