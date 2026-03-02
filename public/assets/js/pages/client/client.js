import functionGeneral from "../../Functions.js";
import Templates from "../../templates.js";
const { selectOptionAll, setValidationStyles, validateField, searchParam, searchFilter, print, add, update, reindex, resetForm, sessionInfo, binnacle, edit, Delete, permission } = functionGeneral();
const { elemenFormClient, targetClient } = Templates()
let session = await sessionInfo();
permission('clientes')
const tooltip = new bootstrap.Tooltip(document.querySelector(".btn-add-tooltip"))
const config = {
    search: () => searchParam({ active: 1 }, "clientes"),
    template: targetClient,
    container: ".container_clients",
    funtions: () => {
        Delete(config, () => binnacle(session.message.id, "Clientes", "Eliminacion", "Se elimino un cliente"));
        edit((response) => editData(response));
        document.querySelectorAll(".edit_btn, .trash_btn").forEach((element) => { let tooltip = new bootstrap.Tooltip(element) });
        permission('clientes')
    }
}
searchFilter("#SearchClients", (e) => {
    if (e.target.value == "") print(config)
    else print({ ...config, search: () => searchParam({ active: 1, nombre_like: e.target.value }, "clientes") })
})
selectOptionAll(".select_options_td", null, null)
let iti = window.intlTelInput(document.querySelector("#input-tel-client-1"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" });
let itiedit = window.intlTelInput(document.querySelector("#input-tel-client"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" });
// ------------------Validacion de Formulario---------------------------
let ClientCount = 1;
function addClient() {
    ClientCount++;
    document.getElementById("clients-container").insertAdjacentHTML('beforeend', elemenFormClient(ClientCount));
    feather.replace();
    let iti = window.intlTelInput(document.querySelector(`#input-tel-client-${ClientCount}`), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" });
    selectOptionAll(".select_options_td", null, null)
    attachValidationListeners(ClientCount);
    const newClient = document.getElementById(`clients-${ClientCount}`);
    newClient.querySelector(".remove-client").addEventListener("click", function () {
        newClient.remove();
        reindex("#clients-container .clients", "clients", ClientCount, "Cliente");
    });
}
function attachValidationListeners(index) {
    const productElement = document.getElementById(`clients-${index}`);
    productElement.querySelectorAll("input[type='text'], textarea, input[type='button'], input[type='tel']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules));
        input.addEventListener("blur", (e) => validateField(e, rules));
        input.addEventListener("change", (e) => validateField(e, rules));
    });
    const contEditClient = document.querySelector("#client-container");
    contEditClient.querySelectorAll("input[type='text'], textarea, input[type='button'], input[type='tel']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules2));
        input.addEventListener("blur", (e) => validateField(e, rules2));
        input.addEventListener("change", (e) => validateField(e, rules2));
    });
}
document.getElementById("add-client-btn").addEventListener("click", () => {
    addClient()
    reindex("#clients-container .clients", "clients", ClientCount, "Cliente");
});
validate.validators.telefonoValido = function (value) {
    if (!value) return
    if (!iti.isValidNumber()) {
        const pais = iti.getSelectedCountryData().name;
        return `^Número inválido para ${pais}`;
    }
};
validate.validators.telefonoValidoEdit = function (value) {
    if (!value) return
    if (!itiedit.isValidNumber()) {
        const pais = itiedit.getSelectedCountryData().name;
        return `^Número inválido para ${pais}`;
    }
};
validate.validators.validateTD = function (value, options, key, attributes) {
    if (!value) {
        return options.message || "es requerido";
    }
    if (value.toLowerCase() === "seleccione una opcion") {
        return options.message || "es requerido";
    }
};
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
            minimum: 4,
            message: "^debe tener al menos 3 caracteres"
        },
    },
    apellido: {
        nombreValidator: {
            uppercaseMessage: "^debe tener la primera letra en mayúscula.",
            specialCharMessage: "^No se permiten signos como puntos (.) o comas (,)."
        },
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        length: {
            minimum: 4,
            message: "^debe tener al menos 3 caracteres"
        },
    },
    documento: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        format: {
            pattern: "^[0-9]+$",
            message: "^solo puede tener numeros"
        }
    },
    telefono: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        telefonoValido: true

    },
    // direccion: {
    //     presence: {
    //         allowEmpty: false,
    //         message: "^es requerido"
    //     },
    // },
    tipo_documento: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        validateTD: { message: "^es requerido" }
    }
};
const rules2 = {
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
            minimum: 4,
            message: "^debe tener al menos 3 caracteres"
        },
    },
    apellido: {
        nombreValidator: {
            uppercaseMessage: "^debe tener la primera letra en mayúscula.",
            specialCharMessage: "^No se permiten signos como puntos (.) o comas (,)."
        },
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        length: {
            minimum: 4,
            message: "^debe tener al menos 3 caracteres"
        },
    },
    documento: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        format: {
            pattern: "^[0-9]+$",
            message: "^solo puede tener numeros"
        }
    },
    telefono: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        telefonoValidoEdit: true

    },
    // direccion: {
    //     presence: {
    //         allowEmpty: false,
    //         message: "^es requerido"
    //     },
    // },
    tipo_documento: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        validateTD: { message: "^es requerido" }
    }
};
let form = document.getElementById("form-submit-clients")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", function (e) {
        e.preventDefault();
        const client = document.querySelectorAll(".clients");
        let formHasError = false;
        let dataClient = []

        client.forEach((client, i) => {
            const index = i + 1;
            const data = {
                nombre: client.querySelector(`input[name="nombre"]`).value,
                apellido: client.querySelector(`input[name="apellido"]`).value,
                tipo_documento: client.querySelector(`input[name="tipo_documento"]`) ? client.querySelector(`input[name="tipo_documento"]`).value : "",
                telefono: window.intlTelInput(client.querySelector(`input[name="telefono"]`), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" }).getNumber(),
                documento: client.querySelector(`input[name="documento"]`) ? client.querySelector(`input[name="documento"]`).value : "",
                // direccion: client.querySelector(`textarea[name="direccion"]`) ? client.querySelector(`textarea[name="direccion"]`).value : "",
            };
            dataClient.push(data)
            const errors = validate(data, rules);
            setValidationStyles(`input-name-client-${index}`, errors?.nombre ? errors.nombre[0] : null);
            setValidationStyles(`input-lastname-client-${index}`, errors?.apellido ? errors.apellido[0] : null);
            setValidationStyles(`input-td-client-${index}`, errors?.tipo_documento ? errors.tipo_documento[0] : null);
            setValidationStyles(`input-doc-client-${index}`, errors?.documento ? errors.documento[0] : null);
            setValidationStyles(`input-tel-client-${index}`, errors?.telefono ? errors.telefono[0] : null);
            // setValidationStyles(`input-direction-client-${index}`, errors?.direccion ? errors.direccion[0] : null);
            if (errors) formHasError = true;
        });

        if (!formHasError) {
            let dataFinal = new FormData();
            dataClient.forEach((client, index) => {
                dataFinal.append(`lista[${index}][nombre]`, client.nombre);
                dataFinal.append(`lista[${index}][apellido]`, client.apellido);
                dataFinal.append(`lista[${index}][documento]`, client.tipo_documento + "-" + client.documento);
                dataFinal.append(`lista[${index}][telefono]`, client.telefono);
                // dataFinal.append(`lista[${index}][direccion]`, client.direccion);
            })
            add(config, "clientes", dataFinal, () => binnacle(session.message.id, "Clientes", "Agregar", "Se agrego un nuevo cliente"));
            resetForm("#clients-container .clients", form)
            bootstrap.Modal.getOrCreateInstance('#register-client').hide()
        }
    });
    form.dataset.listenerAttached = "true";
}
print(config);
const editData = (response) => {
    let hasError = false;
    document.querySelector("#input-name-client").value = response[0].nombre;
    document.querySelector("#input-lastname-client").value = response[0].apellido;
    document.querySelector("#input-doc-client").value = response[0].documento.split("-")[1];
    document.querySelector("#input-td-client").value = response[0].documento.split("-")[0];
    document.querySelector("#input-tel-client").value = response[0].telefono;
    // document.querySelector("#input-direction-client").value = response[0].direccion;
    document.querySelector("#input-id-client").value = response[0].id;
    const data = {
        nombre: document.querySelector(`#input-name-client`).value,
        apellido: document.querySelector(`#input-lastname-client`).value,
        tipo_documento: document.querySelector(`#input-td-client`).value,
        telefono: window.intlTelInput(document.querySelector(`#input-tel-client`), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" }).getNumber(),
        documento: document.querySelector(`#input-doc-client`).value,
        // direccion: document.querySelector(`#input-direction-client`).value,
    };
    const errors = validate(data, rules2);
    if (errors) hasError = true;
    setValidationStyles(`input-name-client`, errors?.nombre ? errors.nombre[0] : null);
    setValidationStyles(`input-lastname-client`, errors?.apellido ? errors.apellido[0] : null);
    setValidationStyles(`input-td-client`, errors?.tipo_documento ? errors.tipo_documento[0] : null);
    setValidationStyles(`input-doc-client`, errors?.documento ? errors.documento[0] : null);
    setValidationStyles(`input-tel-client`, errors?.telefono ? errors.telefono[0] : null);
    // setValidationStyles(`input-direction-client`, errors?.direccion ? errors.direccion[0] : null);

    let formEdit = document.getElementById("form-submit-edit-client")
    if (!formEdit.dataset.listenerAttached) {
        formEdit.addEventListener("submit", function (e) {
            e.preventDefault();
            const data = {
                nombre: document.querySelector(`#input-name-client`).value,
                apellido: document.querySelector(`#input-lastname-client`).value,
                tipo_documento: document.querySelector(`#input-td-client`).value,
                telefono: window.intlTelInput(document.querySelector(`#input-tel-client`), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" }).getNumber(),
                documento: document.querySelector(`#input-doc-client`).value,
                // direccion: document.querySelector(`#input-direction-client`).value,
            };
            const errors = validate(data, rules2);
            if (errors) hasError = true;
            else hasError = false
            if (!hasError) {
                let dataFinal = new FormData();
                dataFinal.append(`nombre`, data.nombre);
                dataFinal.append(`apellido`, data.apellido);
                dataFinal.append(`documento`, data.tipo_documento + "-" + data.documento);
                dataFinal.append(`telefono`, data.telefono);
                // dataFinal.append(`direccion`, data.direccion);
                dataFinal.append(`id`, document.querySelector("#input-id-client").value);
                update(config, "clientes", dataFinal, () => binnacle(session.message.id, "Clientes", "Actualizacion", "Se actualizo un cliente"))
                bootstrap.Modal.getOrCreateInstance('#edit-client').hide()
            }
        });
        formEdit.dataset.listenerAttached = "true";
    }
}
document.getElementById('navbarDropdown').addEventListener('click', function () {
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
attachValidationListeners(1)