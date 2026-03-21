import functionGeneral from "../../Functions.js"
import { nuevaBitacora, myfecth, sessionInfo } from "../../Functions2.js"
import { set_validaciones, reglas_validaciones, validate } from "../../Validaciones.js";
// Inicializar validators personalizados
set_validaciones();
const { setValidationStyles, validateField } = functionGeneral()
dayjs.extend(window.dayjs_plugin_relativeTime);
dayjs.locale('es');
var [session, permisos] = sessionInfo();

const activity = async () => {
    let color = ['bh_1', 'bh_2', 'bh_4', 'bh_5', 'bh_6'];
    let pet = myfecth("bitacora/get_all").json()
    let template = ""
    let icon = ""
    let title = ""
    
    pet.forEach((item, index) => {
        if (item.descripcion.includes("Se agrego ") || item.descripcion.includes("Se creo ")) icon = "plus"
        else if (item.descripcion.includes("Se elimino ") || item.descripcion.includes("Se Elimino ")) icon = "trash"
        else if (item.descripcion.includes("Se actualizo ")) icon = "edit"
        else if (item.descripcion.includes("Se ha restaurado ")) icon = "refresh-cw"
        else if (item.descripcion.includes("Se abrio ")) icon = "book-open"
        else if (item.descripcion.includes("Se cerro ")) icon = "x"
        else if (item.descripcion.includes("Se preparo ")) icon = "coffee"
        else if (item.descripcion.includes("Se verifico ")) icon = "check" 
        else if (item.descripcion.includes("Se anulo ")) icon = "x-circle"
        else if (item.descripcion.includes("Se acepto ")) icon = "check-circle"
        else if (item.descripcion.includes("inicio de sesion")) icon = "log-in"
        else if (item.descripcion.includes("Se ha agregado")) icon = "plus-circle"
        else if (item.descripcion.includes("Se despacho")) icon = "log-in"
        else if (item.descripcion.includes("Se envio")) icon = "log-out"
        else if (item.descripcion.includes("Guardar Gasto") || item.descripcion.includes("Guardar Ingreso")) icon = "dollar-sign"
        else if (item.descripcion.includes("Se pago")) icon = "dollar-sign"

        if (item.descripcion.includes("Se agrego ") || item.descripcion.includes("Se creo ")) title = "Nuevo elemento agregado"
        else if (item.descripcion.includes("Se elimino ")) title = "Elemento eliminado"
        else if (item.descripcion.includes("Se actualizo ")) title = "Elemento actualizado"
        else if (item.descripcion.includes("Se ha restaurado ")) title = "Elemento restaurado"
        else if (item.descripcion.includes("Se abrio ")) title = "Elemento abierto"
        else if (item.descripcion.includes("Se ha cerrado ")) title = "Elemento cerrado"
        else if (item.descripcion.includes("Se preparo ")) title = "Elemento preparado"
        else if (item.descripcion.includes("Se verifico ")) title = "Elemento verificado"
        else if (item.descripcion.includes("Se anulo ")) title = "Elemento anulado"
        else if (item.descripcion.includes("Se acepto ")) title = "Elemento aceptado"
        else if (item.descripcion.includes("inicio de sesion")) title = "Inicio de sesion"
        else if (item.descripcion.includes("Se ha agregado")) title = "Nuevo elemento agregado"
        else if (item.descripcion.includes("Se despacho")) title = "Nuevo despacho"
        else if (item.descripcion.includes("Se envio")) title = "Nuevo envio"
        else if (item.descripcion.includes("Se pago")) title = "Pago realizado"

        else if (item.descripcion.includes("Guardar Gasto") || item.descripcion.includes("Guardar Ingreso")) title = "Nuevo movimiento de dinero"

        
        template += `
        <div class="d-flex align-items-start border-left-line pb-3">
            <div>
                <a href="javascript:void(0)" class="btn ${color[index]} btn-circle mb-2 btn-item text-white">
                    <i data-feather="${icon}"></i>
                </a>
            </div>
            <div class="ms-3 mt-2">
                <h5 class="text-dark font-weight-medium mb-2">${title}!</h5>
                <p class="font-14 mb-2 text-muted">
                    ${item.nombre_usuario + " " + (item.descripcion).replace("Se", "")}
                </p>
                <span class="font-weight-light font-14 text-muted">${dayjs(item.fecha).fromNow()}</span>
            </div>
        </div>
        `
    })
    document.querySelector(".activity").innerHTML = template;
    feather.replace();
}
document.getElementById("input-name-user-profile").value = session.message['nombre']
document.getElementById("input-lastname-user-profile").value = session.message['apellido']
document.getElementById("input-email-user-profile").value = session.message['correo']
document.getElementById("img_profile").src = session.message['imagen'] ? `media/users/${session.message['imagen']}` : "./assets/img/users/1.jpg"
document.getElementById("session_name_rol").textContent = session.message['rol']

document.querySelector('input[type="file"]').addEventListener('change', async function () {
    const reader = new FileReader();
    reader.onload = function (e) {
        document.getElementById('img_profile').src = e.target.result;
    };
    reader.readAsDataURL(this.files[0]);

    let data = new FormData();
    data.append('imagen', this.files[0]);
    data.append('imagen_name', this.files[0].name);
    data.append('id', session.message.id);
    // let sendImg = await fetch(`login/UpdateSession`, { method: "POST", body: data });
    let res = myfecth("users/update", {}, data, null, "POST").json();
    if (res.success == true) {
        [session, permisos] = sessionInfo();
        // let user2 = myfecth("users/get_all", {}, {id:session.message.id}).json();
        document.getElementById("img_profile_header").src = `media/users/${session.message["imagen"]}`
        nuevaBitacora("Perfil", "Actualizacion", "Se actualizo la imagen de perfil")
        activity()
        const Toast = Swal.mixin({
            toast: true,
            position: "bottom-end",
            showConfirmButton: false,
            timer: 5000,
            timerProgressBar: true,
            didOpen: (toast) => {
                toast.onmouseenter = Swal.stopTimer;
                toast.onmouseleave = Swal.resumeTimer;
            }
        });
        Toast.fire({
            icon: `success`,
            title: `Imagen actualizada correctamente`
        });
    } else {
        const Toast = Swal.mixin({
            toast: true,
            position: "bottom-end",
            showConfirmButton: false,
            timer: 1000,
            timerProgressBar: true,
            didOpen: (toast) => {
                toast.onmouseenter = Swal.stopTimer;
                toast.onmouseleave = Swal.resumeTimer;
            }
        });
        Toast.fire({
            icon: `error`,
            title: `Error al actualizar la imagen`
        });
    }
});

const rules = {
    nombre: reglas_validaciones.nombre,
    apellido: reglas_validaciones.apellido,
    email: reglas_validaciones.email,
};
const rulesPassNew = {
    password: reglas_validaciones.password,
}
const rulesPassConfirm = {
    confirm: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        password: {
            onceDigit: "^Al menos un dígito.",
            onceLower: "^Al menos una letra minúscula.",
            onceSpecial: "^Al menos un carácter especial.",
            noSpace: "^Sin espacios en blanco.",
            length: "^Longitud entre 8 y 15 caracteres."
        }
    },
}
const rulesPassVerify = {
    password: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        password: {
            onceDigit: "^Al menos un dígito.",
            onceLower: "^Al menos una letra minúscula.",
            onceSpecial: "^Al menos un carácter especial.",
            noSpace: "^Sin espacios en blanco.",
            length: "^Longitud entre 8 y 15 caracteres."
        }
    },
    confirm: {
        presence: true,
        equality: {
            attribute: "password",
            message: "^Las contraseñas no coinciden"
        }
    }
}
let data = {
    nombre: document.querySelector(`#input-name-user-profile`).value,
    apellido: document.querySelector(`#input-lastname-user-profile`).value,
    email: document.querySelector(`#input-email-user-profile`).value,
}
const error = validate(data, rules);
setValidationStyles("input-name-user-profile", error?.nombre ? error.nombre[0] : null);
setValidationStyles("input-lastname-user-profile", error?.apellido ? error.apellido[0] : null);
setValidationStyles("input-email-user-profile", error?.email ? error.email[0] : null);
let formEditProfile = document.querySelector(".form-submit-edit-user-profile");
if (!formEditProfile.dataset.listenerAttached) {
    formEditProfile.addEventListener("submit", async (e) => {
        e.preventDefault();
        let hasError = false;
        let data2 = {
            nombre: document.querySelector(`#input-name-user-profile`).value,
            apellido: document.querySelector(`#input-lastname-user-profile`).value,
            email: document.querySelector(`#input-email-user-profile`).value,
        }
        const error = validate(data2, rules);
        setValidationStyles("input-name-user-profile", error?.nombre ? error.nombre[0] : null);
        setValidationStyles("input-lastname-user-profile", error?.apellido ? error.apellido[0] : null);
        setValidationStyles("input-email-user-profile", error?.email ? error.email[0] : null);
        if (error) hasError = true;
        else hasError = false;
        if (!hasError) {
            Swal.fire({
                title: "¿Deseas actualizar tu perfil?",
                icon: "warning",
                showCancelButton: true,
                confirmButtonText: "Si, actualizar",
                cancelButtonText: "Cancelar",
                confirmButtonColor: "#FF4B00",
            }).then(async (result) => {
                if (result.isConfirmed) {
                    Swal.fire({
                        title: 'Procesando...',
                        text: 'Por favor espera',
                        allowOutsideClick: false,
                        didOpen: () => { Swal.showLoading() }
                    });
                    let data = new FormData();
                    data.append('nombre', document.querySelector(`#input-name-user-profile`).value);
                    data.append('apellido', document.querySelector(`#input-lastname-user-profile`).value);
                    data.append('email', document.querySelector(`#input-email-user-profile`).value);
                    data.append('id', session.message.id);
                    let res = myfecth("users/update", {}, data).json();
                    if (res.success == true) {
                        let session2 = await sessionInfo();
                        nuevaBitacora('Perfil', 'Perfil actualizado', 'Se actualizo el perfil');
                        activity()
                        document.getElementById("name_profile_header").textContent = (session2.message.nombre + " " + session2.message.apellido)
                        Swal.close();
                        Swal.fire({
                            title: `Exito!`,
                            text: "Tu perfil fue actualizado correctamente",
                            icon: "success",
                        });
                    } else {
                        Swal.close();
                        Swal.fire({
                            title: `Error!`,
                            text: "Tu perfil no fue actualizado",
                            icon: "error",
                        });
                    }
                }
            });
        }
    });
    formEditProfile.dataset.listenerAttached = true
}

let formEditPassword = document.getElementById("form-edit-password-user-profile")
formEditPassword.querySelectorAll('input').forEach(input => {
    if (input.name == "confirm") {
        input.addEventListener('keyup', (e) => validateField(e, rulesPassConfirm));
    } else if (input.name == "password") {
        input.addEventListener('keyup', (e) => validateField(e, rulesPassNew));
    }
})

if (!formEditPassword.dataset.listenerAttached) {
    formEditPassword.addEventListener("submit", async (e) => {
        let hasError = false
        e.preventDefault();
        let data = {
            password: document.querySelector(`#input-newPassword-user-profile`).value,
            confirm: document.querySelector(`#input-confirPassword-user-profile`).value,
        }
        const errors = validate(data, rulesPassVerify);
        setValidationStyles("input-newPassword-user-profile", errors?.password ? errors.password[0] : null);
        setValidationStyles("input-confirPassword-user-profile", errors?.confirm ? errors.confirm[0] : null);
        if (errors) hasError = true
        else hasError = false

        if (!hasError) {
            formEditPassword.querySelector("button").disabled = true
            formEditPassword.querySelector("button").firstElementChild.classList.remove("d-none")
            let dataEmail = new FormData();
            dataEmail.append("email", session.message.correo);
            dataEmail.append("id", session.message.id);
            dataEmail.append("name", session.message.nombre);
            let res = myfecth(`changepass/sendEmail`, {}, dataEmail).json();
            if (res.success == true) {
                formEditPassword.querySelector("button").disabled = false
                formEditPassword.querySelector("button").firstElementChild.classList.add("d-none")
                Swal.fire({
                    title: "Ingrese el codigo de verificación enviado a su correo",
                    input: "number",
                    focusConfirm: false,
                    showCancelButton: true,
                    cancelButtonText: "Cancelar",
                    confirmButtonColor: "#FF4B00",
                    confirmButtonText: "Comprobar",
                    showLoaderOnConfirm: true,
                    preConfirm: async (e) => {
                        let codigo = e
                        let data = new FormData();
                        data.append('token', codigo);
                        let res = myfecth("changepass/validateToken", {}, data).json();
                        return res
                    },
                    allowOutsideClick: () => !Swal.isLoading(),
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                }).then(async (result) => {
                    if (result.isConfirmed) {
                        if (result.value.success == true) {
                            Swal.fire({
                                title: 'Procesando...',
                                text: 'Por favor espera',
                                allowOutsideClick: false,
                                didOpen: () => { Swal.showLoading() }
                            });
                            let data = new FormData();
                            data.append('hash', document.querySelector(`#input-newPassword-user-profile`).value);
                            data.append('id', session.message.id);
                            let res = myfecth("changepass/update", {}, data).json();
                            if (res.success == true) {
                                nuevaBitacora('Usuario', 'Perfil actualizado', 'Se actualizo la contraseña de su perfil');
                                activity()
                                Swal.close();
                                Swal.fire({
                                    title: `Exito!`,
                                    text: "Tu contraseña fue actualizada correctamente",
                                    icon: "success",
                                });
                                formEditPassword.reset()
                                formEditPassword.querySelectorAll('input').forEach(input => {
                                    input.classList.remove("is-valid", "is-invalid")
                                })
                            } else {
                                Swal.close();
                                Swal.fire({
                                    title: `Error!`,
                                    text: "Tu contraseña no fue actualizada",
                                    icon: "error",
                                });
                            }
                        } else {
                            Swal.fire({
                                title: `Error!`,
                                text: "El codigo de verificacion es incorrecto",
                                icon: "error",
                            });
                        }
                    }
                });
            }
        }
    })
    formEditPassword.dataset.listenerAttached = true
}

activity()