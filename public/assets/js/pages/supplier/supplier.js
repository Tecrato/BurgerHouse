import functionGeneral from "../../Functions.js";
import { nuevaBitacora } from "../../Functions2.js"
import Templates from "../../templates.js";
import introTooltip from "../../intro-tooltip.js"
const {supplier} = introTooltip()
const { selectOptionAll, setValidationStyles, validateField, searchParam, print, add, reindex, resetForm, update, searchFilter, sessionInfo, binnacle, edit, Delete, permission } = functionGeneral();
const { elemenFormSupplier, targetSupplier } = Templates()
let session = await sessionInfo()
supplier('navbarDropdown')
permission("proveedores")
const config = {
    search: () => searchParam({ active: 1 }, "proveedor"),
    template: targetSupplier,
    container: ".cont_suppliers",
    funtions: () => {
        Delete(config, () => nuevaBitacora('Proveedores', 'Eliminacion', 'Se Elimino un proveedor'));
        edit((response) => editData(response));
        document.querySelectorAll(".edit_btn, .trash_btn").forEach((element) => { let tooltip = new bootstrap.Tooltip(element) });
        permission("proveedores")
    }
}
searchFilter("#SearchSupplier", (e) => {
    if (e.target.value == "") print(config)
    else print({ ...config, search: () => searchParam({ active: 1, nombre_like: e.target.value }, "proveedor") })
})
selectOptionAll(".select_options_td", null)
selectOptionAll(".select_options_td_edit", null)
let iti = window.intlTelInput(document.querySelector("#input-num1-supplier-1"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" });
window.intlTelInput(document.querySelector("#input-num2-supplier-1"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js", });
let itiEdit = window.intlTelInput(document.querySelector("#input-num1-supplier"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js", });
window.intlTelInput(document.querySelector("#input-num2-supplier"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js", });
// ------------------Validacion de Formulario---------------------------
let SupplierCount = 1;
function addSupplier() {
    SupplierCount++;
    document.getElementById("suppliers-container").insertAdjacentHTML('beforeend', elemenFormSupplier(SupplierCount));
    feather.replace();
    selectOptionAll(".select_options_td", null)
    const input = document.querySelector(`#input-num1-supplier-${SupplierCount}`);
    const iti = window.intlTelInput(input, {
        initialCountry: "ve",
        separateDialCode: true,
        utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js"
    });
    const input2 = document.querySelector(`#input-num2-supplier-${SupplierCount}`);
    const iti2 = window.intlTelInput(input2, {
        initialCountry: "ve",
        separateDialCode: true,
        utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js",
    });
    attachValidationListeners(SupplierCount);

    const newSupplier = document.getElementById(`suppliers-${SupplierCount}`);
    newSupplier.querySelector(".remove-supplier").addEventListener("click", function () {
        newSupplier.remove();
        reindex("#suppliers-container .suppliers", "proveedor", SupplierCount, "Proveedor");
    });
}
function attachValidationListeners(index) {
    const productElement = document.getElementById(`suppliers-${index}`);
    productElement.querySelectorAll("input[type='text'], textarea, input[type='button'], input[type='tel']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules));
        input.addEventListener("blur", (e) => validateField(e, rules));
        input.addEventListener("change", (e) => validateField(e, rules));
    });

    const SupplierEdit = document.getElementById(`supplier-container`);
    SupplierEdit.querySelectorAll("input[type='text'], textarea, input[type='button'], input[type='tel']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules2));
        input.addEventListener("blur", (e) => validateField(e, rules2));
        input.addEventListener("change", (e) => validateField(e, rules2));
    });
}
document.getElementById("add-supplier-btn").addEventListener("click", () => {
    addSupplier()
    reindex("#suppliers-container .suppliers", "proveedor", SupplierCount, "Proveedor");
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
    if (!itiEdit.isValidNumber()) {
        const pais = itiEdit.getSelectedCountryData().name;
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
            message: "^debe tener al menos 4 caracteres"
        },
    },
    razonSocial: {
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
            message: "^debe tener al menos 4 caracteres"
        },
    },
    rif: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        format: {
            pattern: "^[0-9]+$",
            message: "^solo puede tener numeros"
        }
    },
    n_telefono1: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        telefonoValido: true

    },
    n_telefono2: {
        presence: {
            allowEmpty: true,
        },
    },
    direccion: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
    },
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
            message: "^debe tener al menos 4 caracteres"
        },
    },
    razonSocial: {
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
            message: "^debe tener al menos 4 caracteres"
        },
    },
    rif: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        format: {
            pattern: "^[0-9]+$",
            message: "^solo puede tener numeros"
        }
    },
    n_telefono1: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        telefonoValidoEdit: true

    },
    n_telefono2: {
        presence: {
            allowEmpty: true,
        },
    },
    direccion: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
    },
    tipo_documento: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        validateTD: { message: "^es requerido" }
    }
};
let form = document.getElementById("form-submit-suppliers")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", function (e) {
        e.preventDefault();
        const supplier = document.querySelectorAll(".suppliers");
        let formHasError = false;
        let dataSupplier = []

        supplier.forEach((supplier, i) => {
            const index = i + 1;
            const data = {
                nombre: supplier.querySelector(`input[name="nombre"]`).value,
                razonSocial: supplier.querySelector(`input[name="razonSocial"]`).value,
                tipo_documento: supplier.querySelector(`input[name="tipo_documento"]`) ? supplier.querySelector(`input[name="tipo_documento"]`).value : "",
                n_telefono1: window.intlTelInput(supplier.querySelector(`input[name="n_telefono1"]`), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" }).getNumber(),
                n_telefono2: window.intlTelInput(supplier.querySelector(`input[name="n_telefono2"]`), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" }).getNumber(),
                rif: supplier.querySelector(`input[name="rif"]`) ? supplier.querySelector(`input[name="rif"]`).value : "",
                direccion: supplier.querySelector(`textarea[name="direccion"]`) ? supplier.querySelector(`textarea[name="direccion"]`).value : "",
            };
            dataSupplier.push(data)
            const errors = validate(data, rules);
            setValidationStyles(`input-name-supplier-${index}`, errors?.nombre ? errors.nombre[0] : null);
            setValidationStyles(`input-razonSocial-supplier-${index}`, errors?.razonSocial ? errors.razonSocial[0] : null);
            setValidationStyles(`input-td-supplier-${index}`, errors?.tipo_documento ? errors.tipo_documento[0] : null);
            setValidationStyles(`input-rif-supplier-${index}`, errors?.rif ? errors.rif[0] : null);
            setValidationStyles(`input-num1-supplier-${index}`, errors?.n_telefono1 ? errors.n_telefono1[0] : null);
            setValidationStyles(`input-num2-supplier-${index}`, errors?.n_telefono2 ? errors.n_telefono2[0] : null);
            setValidationStyles(`input-direction-supplier-${index}`, errors?.direccion ? errors.direccion[0] : null);
            if (errors) formHasError = true;
        });

        if (!formHasError) {
            let data = new FormData()
            dataSupplier.forEach((sup, index) => {
                data.append(`lista[${index}][nombre]`, sup.nombre);
                data.append(`lista[${index}][razon_social]`, sup.razonSocial);
                data.append(`lista[${index}][documento]`, sup.tipo_documento + "-" + sup.rif);
                data.append(`lista[${index}][n_telefono1]`, sup.n_telefono1);
                data.append(`lista[${index}][n_telefono2]`, sup.n_telefono2);
                data.append(`lista[${index}][direccion]`, sup.direccion);
            })
            add(config, 'supplier', data, () => nuevaBitacora("Proveedores", "Agregar", "Se Agrego un proveedor"))
            bootstrap.Modal.getOrCreateInstance('#register-supplier').hide()
            resetForm("#suppliers-container .suppliers", form)
        }
    });
    form.dataset.listenerAttached = "true";
}
print(config)
attachValidationListeners(1)
function editData(response) {
    let hasError = false
    document.querySelector("#input-id-supplier").value = response[0].id
    document.querySelector("#input-name-supplier").value = response[0].nombre
    document.querySelector("#input-razonSocial-supplier").value = response[0].razon_social
    document.querySelector("#input-rif-supplier").value = response[0].documento.split("-")[1]
    document.querySelector("#input-td-supplier").value = response[0].documento.split("-")[0]
    document.querySelector("#input-num1-supplier").value = response[0].n_telefono1
    document.querySelector("#input-num2-supplier").value = response[0].n_telefono2 ? response[0].n_telefono2 : ""
    document.querySelector("#input-direction-supplier").value = response[0].direccion
    const data = {
        nombre: document.querySelector("#input-name-supplier").value,
        razonSocial: document.querySelector("#input-razonSocial-supplier").value,
        tipo_documento: document.querySelector("#input-td-supplier") ? document.querySelector("#input-td-supplier").value : "",
        n_telefono1: window.intlTelInput(document.querySelector("#input-num1-supplier"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" }).getNumber(),
        n_telefono2: window.intlTelInput(document.querySelector("#input-num2-supplier"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" }).getNumber(),
        rif: document.querySelector("#input-rif-supplier") ? document.querySelector("#input-rif-supplier").value : "",
        direccion: document.querySelector("#input-direction-supplier") ? document.querySelector("#input-direction-supplier").value : "",
    };
    const errors = validate(data, rules2);
    setValidationStyles(`input-name-supplier`, errors?.nombre ? errors.nombre[0] : null);
    setValidationStyles(`input-razonSocial-supplier`, errors?.razonSocial ? errors.razonSocial[0] : null);
    setValidationStyles(`input-td-supplier`, errors?.tipo_documento ? errors.tipo_documento[0] : null);
    setValidationStyles(`input-rif-supplier`, errors?.rif ? errors.rif[0] : null);
    setValidationStyles(`input-num1-supplier`, errors?.n_telefono1 ? errors.n_telefono1[0] : null);
    setValidationStyles(`input-num2-supplier`, errors?.n_telefono2 ? errors.n_telefono2[0] : null);
    setValidationStyles(`input-direction-supplier`, errors?.direccion ? errors.direccion[0] : null);
    if (errors) hasError = true;
    let formEdit = document.getElementById("form-submit-edit-supplier")
    if (!formEdit.dataset.listenerAttached) {
        formEdit.addEventListener("submit", function (e) {
            e.preventDefault();
            const data = {
                nombre: document.querySelector("#input-name-supplier").value,
                razonSocial: document.querySelector("#input-razonSocial-supplier").value,
                tipo_documento: document.querySelector("#input-td-supplier") ? document.querySelector("#input-td-supplier").value : "",
                n_telefono1: window.intlTelInput(document.querySelector("#input-num1-supplier"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" }).getNumber(),
                n_telefono2: window.intlTelInput(document.querySelector("#input-num2-supplier"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" }).getNumber(),
                rif: document.querySelector("#input-rif-supplier") ? document.querySelector("#input-rif-supplier").value : "",
                direccion: document.querySelector("#input-direction-supplier") ? document.querySelector("#input-direction-supplier").value : "",
            };
            const errors = validate(data, rules2);
            setValidationStyles(`input-name-supplier`, errors?.nombre ? errors.nombre[0] : null);
            setValidationStyles(`input-razonSocial-supplier`, errors?.razonSocial ? errors.razonSocial[0] : null);
            setValidationStyles(`input-td-supplier`, errors?.tipo_documento ? errors.tipo_documento[0] : null);
            setValidationStyles(`input-rif-supplier`, errors?.rif ? errors.rif[0] : null);
            setValidationStyles(`input-num1-supplier`, errors?.n_telefono1 ? errors.n_telefono1[0] : null);
            setValidationStyles(`input-num2-supplier`, errors?.n_telefono2 ? errors.n_telefono2[0] : null);
            setValidationStyles(`input-direction-supplier`, errors?.direccion ? errors.direccion[0] : null);
            if (errors) hasError = true;
            else hasError = false
            if (!hasError) {
                let data = new FormData()
                data.append(`id`, document.querySelector("#input-id-supplier").value)
                data.append(`nombre`, document.querySelector("#input-name-supplier").value)
                data.append(`razon_social`, document.querySelector("#input-razonSocial-supplier").value)
                data.append(`documento`, document.querySelector("#input-td-supplier").value + "-" + document.querySelector("#input-rif-supplier").value)
                data.append(`n_telefono1`, window.intlTelInput(document.querySelector("#input-num1-supplier"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" }).getNumber())
                data.append(`n_telefono2`, window.intlTelInput(document.querySelector("#input-num2-supplier"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" }).getNumber())
                data.append(`direccion`, document.querySelector("#input-direction-supplier").value)
                update(config, 'supplier', data, () => nuevaBitacora("Proveedores", "Actualizacion", "Se Actualizo un proveedor"))
                bootstrap.Modal.getOrCreateInstance('#edit-supplier').hide()
            }
        });
        formEdit.dataset.listenerAttached = "true";
    }
}