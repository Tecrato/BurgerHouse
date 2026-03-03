import functionGeneral from "../../Functions.js";
import { nuevaBitacora } from "../../Functions2.js"
import Templates from "../../templates.js";
const { selectOptionAll, setValidationStyles, validateField, searchParam, searchFilter, print, add, update, reindex, resetForm, binnacle, sessionInfo, Delete, edit, permission } = functionGeneral();
const { elemenFormUser, optionsRol, targetUser } = Templates()
const tooltip = new bootstrap.Tooltip(document.querySelector(".btn-add-tooltip"))
let session = await sessionInfo();
permission("usuarios")
selectOptionAll(".select_options_td", null)
selectOptionAll(".select_options_rol", "rol", optionsRol)
selectOptionAll(".select_options_td_edit", null)
selectOptionAll(".select_options_rol_edit", "rol", optionsRol)
const config = {
    search: () => searchParam({ active: 1 }, "users"),
    template: targetUser,
    container: ".container_users",
    funtions: () => {
        Delete(config, () => nuevaBitacora("Usuario", "Eliminacion", "Se elimino un usuario"));
        edit((response) => editData(response));
        document.querySelectorAll(".edit_btn, .trash_btn").forEach((element) => { let tooltip = new bootstrap.Tooltip(element) });
        permission("usuarios")
    },
}
//funcion del search para filtrar los usuarios
searchFilter("#search-filter-users", (e) => {
    if (e.target.value == "") print(config)
    else print({ ...config, search: () => searchParam({ active: 1, nombre_like: e.target.value }, "users") })
})
let UsersCount = 1;
function addUsers() {
    UsersCount++;
    document.getElementById("users-container").insertAdjacentHTML('beforeend', elemenFormUser(UsersCount));
    feather.replace();
    selectOptionAll(".select_options_td", null)
    selectOptionAll(".select_options_rol", "rol", optionsRol)
    attachValidationListeners(UsersCount);
    const newUser = document.getElementById(`user-${UsersCount}`);
    newUser.querySelector(".remove-user").addEventListener("click", function () {
        newUser.remove();
        reindex("#users-container .users", "user", UsersCount, "Usuario");
    });
}
function attachValidationListeners(index) {
    const productElement = document.getElementById(`user-${index}`);
    productElement.querySelectorAll("input[type='text'], input[type='button'], input[type='password']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules));
        input.addEventListener("blur", (e) => validateField(e, rules));
    });
    const productElement2 = document.getElementById(`user`);
    productElement2.querySelectorAll("input[type='text'], input[type='button'], input[type='password']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules2));
        input.addEventListener("blur", (e) => validateField(e, rules2));
    });
}
document.getElementById("add-user-btn").addEventListener("click", () => {
    addUsers()
    reindex("#users-container .users", "user", UsersCount, "Usuario");
});
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
validate.validators.email = function (value, options, key, attributes) {
    if (!value) return;
    if (!/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(value)) {
        return options.validateEmail
    }
}
validate.validators.password = function (value, options, key, attributes) {
    if (!value) return;
    if (!/(?=.*\d)/.test(value)) {
        return options.onceDigit
    }
    if (!/(?=.*[a-z])/.test(value)) {
        return options.onceLower
    }
    if (!/(?=.*[A-Z])/.test(value)) {
        return options.onceUpper
    }
    if (!/(?=.*[^a-zA-Z0-9])/.test(value)) {
        return options.onceSpecial
    }
    if (/\s/.test(value)) {
        return options.noSpace
    }
    if (value.length < 8 || value.length > 15) {
        return options.length
    }
}
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
            minimum: 2,
            message: "^debe tener al menos 2 caracteres"
        },
    },
    // rif: {
    //     presence: {
    //         allowEmpty: false,
    //         message: "^es requerida"
    //     },
    //     format: {
    //         pattern: "^[0-9]+$",
    //         message: "^solo puede tener numeros"
    //     }
    // },
    // tipo_documento: {
    //     presence: {
    //         allowEmpty: false,
    //         message: "^es requerida"
    //     },
    //     validateTD: { message: "^es requerido" }
    // },
    id_rol: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        validateTD: { message: "^es requerido" }
    },
    hash: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        password: {
            onceDigit: "^Al menos un dígito.",
            onceLower: "^Al menos una letra minúscula.",
            onceUpper: "^Al menos una letra mayúscula",
            onceSpecial: "^Al menos un carácter especial.",
            noSpace: "^Sin espacios en blanco.",
            length: "^Longitud entre 8 y 15 caracteres.",
        }
    },
    email: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        email: { validateEmail: "^El correo electrónico no es válido" }
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
            minimum: 2,
            message: "^debe tener al menos 2 caracteres"
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
            minimum: 2,
            message: "^debe tener al menos 2 caracteres"
        },
    },
    // rif: {
    //     presence: {
    //         allowEmpty: false,
    //         message: "^es requerida"
    //     },
    //     format: {
    //         pattern: "^[0-9]+$",
    //         message: "^solo puede tener numeros"
    //     }
    // },
    // tipo_documento: {
    //     presence: {
    //         allowEmpty: false,
    //         message: "^es requerida"
    //     },
    //     validateTD: { message: "^es requerido" }
    // },
    id_rol: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        validateTD: { message: "^es requerido" }
    },
    // hash: {
    //     presence: {
    //         allowEmpty: false,
    //         message: "^es requerido"
    //     },
    //     password: {
    //         onceDigit: "^Al menos un dígito.",
    //         onceLower: "^Al menos una letra minúscula.",
    //         onceSpecial: "^Al menos un carácter especial.",
    //         noSpace: "^Sin espacios en blanco.",
    //         length: "^Longitud entre 8 y 15 caracteres."
    //     }
    // },
    email: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        email: { validateEmail: "^El correo electrónico no es válido" }
    }
};
let form = document.getElementById("form-submit-users")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        const users = document.querySelectorAll(".users");
        let formHasError = false;
        let dataUsers = []

        users.forEach((user, i) => {
            const index = i + 1;
            const data = {
                nombre: user.querySelector(`input[name="nombre"]`).value,
                apellido: user.querySelector(`input[name="apellido"]`).value,
                // tipo_documento: user.querySelector(`input[name="tipo_documento"]`) ? user.querySelector(`input[name="tipo_documento"]`).value : "",
                // rif: user.querySelector(`input[name="rif"]`).value,
                email: user.querySelector(`input[name="email"]`).value,
                id_rol: user.querySelector(`input[name="id_rol"]`).getAttribute("data-id"),
                hash: user.querySelector(`input[name="hash"]`).value
            }
            dataUsers.push(data)
            const errors = validate(data, rules);
            setValidationStyles(`input-name-user-${index}`, errors?.nombre ? errors.nombre[0] : null);
            setValidationStyles(`input-lastname-user-${index}`, errors?.apellido ? errors.apellido[0] : null);
            // setValidationStyles(`input-td-user-${index}`, errors?.tipo_documento ? errors.tipo_documento[0] : null);
            // setValidationStyles(`input-rif-user-${index}`, errors?.rif ? errors.rif[0] : null);
            setValidationStyles(`input-email-user-${index}`, errors?.email ? errors.email[0] : null);
            setValidationStyles(`input-password-user-${index}`, errors?.hash ? errors.hash[0] : null);
            setValidationStyles(`input-rol-user-${index}`, errors?.id_rol ? errors.id_rol[0] : null);
            if (errors) {
                formHasError = true;
            }
        })
        if (!formHasError) {
            let dataFinal = new FormData()
            dataUsers.forEach((user, index) => {
                dataFinal.append(`lista[${index}][nombre]`, user.nombre)
                dataFinal.append(`lista[${index}][apellido]`, user.apellido)
                // dataFinal.append(`lista[${index}][documento]`, user.tipo_documento + "-" + user.rif)
                dataFinal.append(`lista[${index}][email]`, user.email)
                dataFinal.append(`lista[${index}][id_rol]`, user.id_rol)
                dataFinal.append(`lista[${index}][hash]`, user.hash)
            })
            resetForm("#users-container .users", form)
            add(config, "users", dataFinal, () => nuevaBitacora("Usuarios", "Agregar", "Se agrego un usuario"))
            bootstrap.Modal.getOrCreateInstance('#register-user').hide()
        }
    })
    form.dataset.listenerAttached = "true";
}
attachValidationListeners(1)
print(config)
//edicion de usuarios
function editData(response) {
    document.querySelector(`#id-user`).value = response[0].id;
    document.querySelector(`#input-name-user`).value = response[0].nombre;
    document.querySelector(`#input-lastname-user`).value = response[0].apellido;
    // document.querySelector(`#input-td-user`).value = response[0].documento.split("-")[0];
    // document.querySelector(`#input-rif-user`).value = response[0].documento.split("-")[1];
    document.querySelector(`#input-email-user`).value = response[0].email;
    // document.querySelector(`#input-password-user`).value = response[0].hash;
    document.querySelector(`#input-rol-user`).setAttribute("data-id", response[0].id_rol);
    document.querySelector(`#input-rol-user`).value = response[0].rol;

    const data = {
        nombre: document.querySelector(`#input-name-user`).value,
        apellido: document.querySelector(`#input-lastname-user`).value,
        // tipo_documento: document.querySelector(`#input-td-user`) ? document.querySelector(`#input-td-user`).value : "",
        // rif: document.querySelector(`#input-rif-user`).value,
        email: document.querySelector(`#input-email-user`).value,
        id_rol: document.querySelector(`#input-rol-user`).getAttribute("data-id"),
        // hash: document.querySelector(`#input-password-user`).value
    }
    const errors = validate(data, rules);
    setValidationStyles(`input-name-user`, errors?.nombre ? errors.nombre[0] : null);
    setValidationStyles(`input-lastname-user`, errors?.apellido ? errors.apellido[0] : null);
    // setValidationStyles(`input-td-user`, errors?.tipo_documento ? errors.tipo_documento[0] : null);
    // setValidationStyles(`input-rif-user`, errors?.rif ? errors.rif[0] : null);
    setValidationStyles(`input-email-user`, errors?.email ? errors.email[0] : null);
    // setValidationStyles(`input-password-user`, errors?.hash ? errors.hash[0] : null);
    setValidationStyles(`input-rol-user`, errors?.id_rol ? errors.id_rol[0] : null);

    let formEdit = document.getElementById("form-submit-edit-user")
    if (!formEdit.dataset.listenerAttached) {
        formEdit.addEventListener("submit", (e) => {
            let hasError = false
            e.preventDefault();
            const data = {
                nombre: formEdit.querySelector(`input[name="nombre"]`).value,
                apellido: formEdit.querySelector(`input[name="apellido"]`).value,
                // tipo_documento: formEdit.querySelector(`input[name="tipo_documento"]`) ? formEdit.querySelector(`input[name="tipo_documento"]`).value : "",
                // rif: formEdit.querySelector(`input[name="rif"]`).value,
                email: formEdit.querySelector(`input[name="email"]`).value,
                id_rol: formEdit.querySelector(`input[name="id_rol"]`).getAttribute("data-id"),
                // hash: formEdit.querySelector(`input[name="hash"]`).value
            }
            const errors = validate(data, rules2);
            setValidationStyles(`input-name-user`, errors?.nombre ? errors.nombre[0] : null);
            setValidationStyles(`input-lastname-user`, errors?.apellido ? errors.apellido[0] : null);
            // setValidationStyles(`input-td-user`, errors?.tipo_documento ? errors.tipo_documento[0] : null);
            // setValidationStyles(`input-rif-user`, errors?.rif ? errors.rif[0] : null);
            setValidationStyles(`input-email-user`, errors?.email ? errors.email[0] : null);
            // setValidationStyles(`input-password-user`, errors?.hash ? errors.hash[0] : null);
            setValidationStyles(`input-rol-user`, errors?.id_rol ? errors.id_rol[0] : null);

            if (errors) hasError = true;
            else hasError = false

            if (!hasError) {
                let dataFinal = new FormData()
                dataFinal.append('nombre', data.nombre)
                dataFinal.append('apellido', data.apellido)
                // dataFinal.append('documento', data.tipo_documento + "-" + data.rif)
                dataFinal.append('email', data.email)
                dataFinal.append('id_rol', data.id_rol)
                // dataFinal.append('hash', data.hash)
                dataFinal.append('id', formEdit.querySelector(`input[name="id_user"]`).value)
                update(config, "users", dataFinal, () => nuevaBitacora("Usuarios", "Actualizacion", "Se actualizo un usuario"))
                bootstrap.Modal.getOrCreateInstance('#edit-user').hide()
            }
        })
        formEdit.dataset.listenerAttached = "true";
    }
}