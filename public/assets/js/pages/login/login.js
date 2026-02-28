import { nuevaBitacora } from "../../Functions2.js";
import functionGeneral from "../../Functions.js";

const { validateField, setValidationStyles, sessionInfo } = functionGeneral()


document.querySelectorAll("#login_form #login-correo, #login_form #login-password").forEach((input) => {
  input.addEventListener("keyup", (e) => validateField(e, rules))
  input.addEventListener("blur", (e) => validateField(e, rules))
})
$(".preloader ").fadeOut();
let login_form = document.getElementById("login_form")
login_form.querySelector("button").disabled = true

const rules = {
  email: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    }
  },
  password: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    }
  },
}

login_form.addEventListener("submit", async (e) => {
  e.preventDefault()
  let dataform = {
    email: document.getElementById("login-correo").value,
    password: document.getElementById("login-password").value,
  }
  const error = validate(dataform, rules);
  setValidationStyles("login-correo", error?.email ? error.email[0] : null);
  setValidationStyles("login-password", error?.password ? error.password[0] : null);
  if (!error) {
    login_form.querySelector(".spinner-border").classList.remove("d-none")
    login_form.querySelector("button").setAttribute("disabled", true)
    let data = new FormData()
    data.append("email", document.getElementById("login-correo").value)
    data.append("password", document.getElementById("login-password").value)
    data.append("token", document.querySelector('.cf-turnstile input[name="cf-turnstile-response"]').value)
    let validate = await fetch("login/login", { method: "POST", body: data })
    let result = await validate.json()
    if (result.success == true) {
      let session = await sessionInfo()
      nuevaBitacora("Usuarios", "Login", "inicio de sesion")
      console.log(result);
      
      window.location = "home"
    } else {
      const Toast = Swal.mixin({
        toast: true,
        position: "bottom-end",
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        didOpen: (toast) => {
          toast.onmouseenter = Swal.stopTimer;
          toast.onmouseleave = Swal.resumeTimer;
        }
      });
      Toast.fire({
        icon: "error",
        title: `${result.message}`
      });
      login_form.querySelector(".spinner-border").classList.add("d-none")
      login_form.querySelector("button").removeAttribute("disabled")
    }
  }
})

window.captchaVerify = (token) => {
  login_form.querySelector("button").disabled = false
}