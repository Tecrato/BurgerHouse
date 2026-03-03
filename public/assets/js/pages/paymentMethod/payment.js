import functionGeneral from "../../Functions.js";
import { nuevaBitacora } from "../../Functions2.js"
import Templates from "../../templates.js";
const { setValidationStyles, validateField, addDataTables, reindex, deleteDatatable, editDataTables, updateDataTables, resetForm, sessionInfo, binnacle, permission } = functionGeneral();
const { elemenFormPaymentMethod } = Templates()
permission("metodo pago")
const tooltip = new bootstrap.Tooltip(document.querySelector(".btn-add-tooltip"))
let table = $(".table_payment").DataTable({
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    ajax: {
        url: 'metodo_pago/get_all/0/10000000/id/asc',
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
                <button data-id="${data.id}" module-edit="metodo_pago" data-module-edit="metodo pago" class="btn bh_1 rounded-circle btn-circle edit_btn_datatable" data-bs-toggle="modal" data-bs-target="#edit-payment" data-bs-title="Editar Metodo de pago" data-bs-placement="bottom">
                    <i data-feather="edit" class="text-white"></i>
                </button>
                <button data-id="${data.id}" module-delete="metodo_pago" data-module-delete="metodo pago" class="btn bh_5 rounded-circle btn-circle trash_btn_datatable"  data-bs-toggle="tooltip" data-bs-title="Eliminar Metodo de pago" data-bs-placement="bottom">
                    <i data-feather="trash" class="text-white"></i>
                </button>`;
            }
        }
    ],
    drawCallback: function (settings) {
        feather.replace();
        document.querySelectorAll(".trash_btn_datatable, .edit_btn_datatable").forEach((btn) => {
            let tooltip = new bootstrap.Tooltip(btn)
        })
        permission("metodo pago")
    },
    "dom": 'tipr',
    "paging": true,
    "info": true,
})
$('#searchPayments').on('keyup', function () {
    table.search(this.value).draw();
});
deleteDatatable(".table_payment", table, () => nuevaBitacora("Metodo de Pago", "Eliminacion", "Se ha eliminado un metodo de pago"))
let paymentCount = 1;
function addPayment() {
    paymentCount++;
    document.getElementById("payments-container").insertAdjacentHTML('beforeend', elemenFormPaymentMethod(paymentCount));
    feather.replace();
    attachValidationListeners(paymentCount);
    const newPayment = document.getElementById(`payments-${paymentCount}`);
    newPayment.querySelector(".remove-payment").addEventListener("click", function () {
        newPayment.remove();
        reindex("#payments-container .payments", `payments`, paymentCount, "Metodos de Pago");
    });
}
document.getElementById("add-payment-btn").addEventListener("click", () => {
    addPayment();
    reindex("#payments-container .payments", `payments`, paymentCount, "Metodos de Pago");
});
function attachValidationListeners(index) {
    const paymentElement = document.getElementById(`payments-${index}`);
    paymentElement.querySelectorAll("input[type='text']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules));
        input.addEventListener("blur", (e) => validateField(e, rules));
    });
    const paymentEdit = document.getElementById(`payment-container`);
    paymentEdit.querySelectorAll("input[type='text']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules));
        input.addEventListener("blur", (e) => validateField(e, rules));
    });
}
validate.validators.nombreValidator = function (value, options, key, attributes) {
    if (!value) return;
    if (!/^[A-Z]/.test(value)) {
        return options.uppercaseMessage;
    }
    if (!/^[A-Za-z0-9\s]*$/.test(value)) {
        return options.specialCharMessage;
    }
};
const rules = {
    nombre: {
        nombreValidator: {
            uppercaseMessage: "^debe tener la primera letra en mayúscula.",
            specialCharMessage: "^No se permiten signos como puntos (.) o comas (,)."
        },
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        length: {
            minimum: 2,
            message: "^debe tener al menos 2 caracteres"
        },
    },
};

let form = document.getElementById("form-submit-payments")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        const Payment = document.querySelectorAll(".payments");
        let formHasError = false;
        let dataPayment = []

        Payment.forEach((payment, i) => {
            const index = i + 1;
            const data = {
                nombre: payment.querySelector(`input[name="nombre"]`).value,
            }
            dataPayment.push(data)
            const errors = validate(data, rules);
            setValidationStyles(`input-name-payments-${index}`, errors?.nombre ? errors.nombre[0] : null);
            if (errors) {
                formHasError = true;
            }
        })
        if (!formHasError) {
            let dataFinal = new FormData()
            dataPayment.forEach((category, index) => {
                dataFinal.append(`lista[${index}][nombre]`, category.nombre)
            })
            addDataTables(table, dataFinal, "metodo_pago", () => nuevaBitacora("Metodo de Pago", "Agregar", "Se ha agregado un metodo de pago"))
            resetForm(".payments", form)
            bootstrap.Modal.getOrCreateInstance('#register-payments').hide()
        }
    })
    form.dataset.listenerAttached = "true";
}

editDataTables(".table_payment", (response) => {
    let formHasError = false;
    document.querySelector("#input-name-payment").value = response[0].nombre;
    document.querySelector("#input-id-payment").value = response[0].id;
    const data = {
        nombre: document.querySelector(`#input-name-payment`).value,
    }
    const errors = validate(data, rules);
    setValidationStyles(`input-name-payment`, errors?.nombre ? errors.nombre[0] : null);

    if (errors) {
        formHasError = true;
    }
    let formEdit = document.getElementById("form-submit-edit-payment")
    if (!formEdit.dataset.listenerAttached) {
        formEdit.addEventListener("submit", (e) => {
            e.preventDefault();
            const data = {
                nombre: document.querySelector(`#input-name-payment`).value,
            }
            const errors = validate(data, rules);
            setValidationStyles(`input-name-payment`, errors?.nombre ? errors.nombre[0] : null);
            if (errors) formHasError = true;
            else formHasError = false;

            if (!formHasError) {
                let dataFinal = new FormData()
                dataFinal.append(`nombre`, document.querySelector(`#input-name-payment`).value)
                dataFinal.append(`id`, document.querySelector("#input-id-payment").value)
                updateDataTables(table, dataFinal, "metodo_pago", () => nuevaBitacora("Metodo de Pago", "Actualizacion", "Se ha actualizado un metodo de pago"))
                bootstrap.Modal.getOrCreateInstance('#edit-payment').hide()
            }
        })
        formEdit.dataset.listenerAttached = "true";
    }
})
attachValidationListeners(1)