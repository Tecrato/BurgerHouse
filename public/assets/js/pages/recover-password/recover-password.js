import functionGeneral from "../../Functions.js";
import { nuevaBitacora } from "../../Functions2.js"
const { searchParam, validateField, setValidationStyles, sessionInfo, binnacle } = functionGeneral();
$(".preloader").fadeOut();
let session = await sessionInfo();
const stepsContainer = document.querySelector('.steps');
const nextButtons = document.querySelectorAll('.next');
const backButtons = document.querySelectorAll('.back');
const btnUpdateUser = document.querySelector(".btn_update_user")
let currentStep = 0;
let timer = 150;
let time
let dataSendEmail = new FormData();
let dataSendToken = new FormData();
let idUser
validate.validators.customPassword = function (value, options) {
    if (!value) return;
    if (!/(?=.*\d)/.test(value)) {
        return options.onceDigit;
    }
    if (!/(?=.*[a-z])/.test(value)) {
        return options.onceLower;
    }
    if (!/(?=.*[^a-zA-Z0-9])/.test(value)) {
        return options.onceSpecial;
    }
    if (/\s/.test(value)) {
        return options.noSpace;
    }
    if (value.length < 8 || value.length > 15) {
        return options.length;
    }
};
const rules = {
    password: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        customPassword: {
            onceDigit: "^Al menos un dígito.",
            onceLower: "^Al menos una letra minúscula.",
            onceSpecial: "^Al menos un carácter especial.",
            noSpace: "^Sin espacios en blanco.",
            length: "^Longitud entre 8 y 15 caracteres."
        }
    },
}
const rules2 = {
    confirm: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        customPassword: {
            onceDigit: "^Al menos un dígito.",
            onceLower: "^Al menos una letra minúscula.",
            onceSpecial: "^Al menos un carácter especial.",
            noSpace: "^Sin espacios en blanco.",
            length: "^Longitud entre 8 y 15 caracteres."
        }
    },
}
const rules3 = {
    password: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        customPassword: {
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

let toas = (type, msj) => {
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
        icon: `${type}`,
        title: `${msj}`
    });
}
function updateSteps() {
    stepsContainer.style.transform = `translateX(${(-100 * currentStep)}%)`;
}
let interval = () => {
    time = setInterval(() => {
        document.querySelector(".call-again").querySelector("p").textContent = `en ${timer} segundos`
        timer--;
        if (timer <= 0) {
            clearInterval(time)
            document.querySelector(".underline").disabled = false
        };
    }, 1000);

    let resend = document.querySelector(".underline")
    resend.addEventListener("click", () => {
        myfecth("changepass/sendEmail", {}, dataSendEmail);
        timer = 150
        interval()
    })
}

nextButtons.forEach(button => {
    button.addEventListener('click', async () => {
        let data_validate = button.getAttribute('data-validate');
        if (data_validate == "email") {
            button.querySelector(".spinner-border").classList.remove("d-none")
            button.setAttribute("disabled", true)
            let email = button.closest('.stepes').querySelector("#email").value;
            let pet = await searchParam({ email: email }, "Changepass");
            if (pet.length > 0) {
                dataSendEmail.append("email", pet[0].email);
                dataSendEmail.append("id", pet[0].id);
                dataSendEmail.append("name", pet[0].nombre);
                interval();
                let res = myfecth("changepass/sendEmail", {}, dataSendEmail).json();
                if (res.success == true) {
                    currentStep++;
                    updateSteps();
                    toas("success", "Se envio un correo para restablecer la contraseña");
                    button.querySelector(".spinner-border").classList.add("d-none")
                    button.removeAttribute("disabled")
                } else {
                    toas("error", "Hubo un error al enviar el correo");
                    button.querySelector(".spinner-border").classList.add("d-none")
                    button.removeAttribute("disabled")
                }
            } else {
                toas("error", "El correo no se encuentra registrado");
                button.querySelector(".spinner-border").classList.add("d-none")
                button.removeAttribute("disabled")
            }
        } else if (data_validate == "token") {
            let token = button.closest('.stepes').querySelector("#token").value;
            dataSendToken.append("token", token);
            let result = myfecth(`changepass/validateToken`, {}, dataSendToken).json()
            if (result.success == true) {
                currentStep++;
                updateSteps();
                idUser = result.mensaje[0].id;
            } else {
                toas("error", result.mensaje);
            }
        }
    });
});

btnUpdateUser.addEventListener('click', async () => {
    let password = document.querySelector("#password").value;
    let confirm = document.querySelector("#confirm").value;
    let data = {
        password: password,
        confirm: confirm
    }
    const error = validate(data, rules3);
    setValidationStyles("password", error?.password ? error.password[0] : null);
    setValidationStyles("confirm", error?.confirm ? error.confirm[0] : null);

    if (!error) {
        let newpass = new FormData()
        newpass.append("hash", document.querySelector("#password").value)
        newpass.append("id", idUser)
        let result = myfecth("changepass/update", {}, newpass).json()
        if (result.success == true) {
            toas("success", "Contraseña actualizada");
            nuevaBitacora(`Recuperar contraseña", "Actualizacion", "Se actualizo la contraseña del usuario ${idUser}`);
            setTimeout(() => { window.location = "login" }, 2000)
        } else {
            toas("error", "Hubo un error al actualizar la contraseña");
        }
    }
})

backButtons.forEach(button => {
    button.addEventListener('click', () => {
        currentStep--;
        updateSteps();
    });
});

let form = document.querySelector(".form_new_pass");
form.querySelectorAll('input').forEach(input => {
    if (input.name == "confirm") {
        input.addEventListener('keyup', (e) => validateField(e, rules2));
    } else if (input.name == "password") {
        input.addEventListener('keyup', (e) => validateField(e, rules));
    }
})