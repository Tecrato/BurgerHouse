import { nuevaBitacora } from "../../Functions2.js";
import functionGeneral from "../../Functions.js";

const { validateField, setValidationStyles, sessionInfo } = functionGeneral();

const loginForm = document.getElementById("login_form");
const submitButton = loginForm.querySelector('button[type="submit"]');
const spinner = loginForm.querySelector(".spinner-border");
const captchaContainer = document.getElementById("login-captcha");
const captchaMessage = document.getElementById("error-login-captcha");

let captchaToken = "";
let turnstileWidgetId = null;
let isSubmitting = false;
let isCaptchaRendered = false;

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
  }
};

const setSubmitState = () => {
  submitButton.disabled = isSubmitting || captchaToken.length === 0;
};

const setCaptchaMessage = (message = "") => {
  if (!captchaMessage) {
    return;
  }
  captchaMessage.textContent = message;
};

const resetCaptcha = ({ showMessage = false } = {}) => {
  captchaToken = "";

  if (window.turnstile && turnstileWidgetId !== null) {
    window.turnstile.reset(turnstileWidgetId);
  }

  if (showMessage) {
    setCaptchaMessage("Verifica el captcha para continuar.");
  }

  setSubmitState();
};

const onCaptchaSuccess = (token) => {
  captchaToken = token || "";
  setCaptchaMessage("");
  setSubmitState();
};

const onCaptchaExpired = () => {
  captchaToken = "";
  setCaptchaMessage("El captcha expiró. Vuelve a verificarlo.");
  setSubmitState();
};

const onCaptchaError = () => {
  captchaToken = "";
  setCaptchaMessage("No se pudo validar el captcha. Intenta nuevamente.");
  setSubmitState();
};

const renderCaptcha = () => {
  if (isCaptchaRendered || !captchaContainer || !window.turnstile) {
    return;
  }

  const siteKey = (captchaContainer.dataset.sitekey || "").trim();

  if (!siteKey) {
    setCaptchaMessage("Captcha no configurado. Contacta al administrador.");
    return;
  }

  turnstileWidgetId = window.turnstile.render(captchaContainer, {
    sitekey: siteKey,
    theme: "light",
    language: "es",
    callback: onCaptchaSuccess,
    "expired-callback": onCaptchaExpired,
    "error-callback": onCaptchaError
  });

  isCaptchaRendered = true;
  setSubmitState();
};

const waitForTurnstileAndRender = () => {
  let tries = 0;
  const maxTries = 200;

  const poller = setInterval(() => {
    if (window.turnstile) {
      clearInterval(poller);
      renderCaptcha();
      return;
    }

    tries += 1;
    if (tries >= maxTries) {
      clearInterval(poller);
      setCaptchaMessage("No se pudo cargar el captcha. Recarga la página.");
    }
  }, 100);
};

document.querySelectorAll("#login_form #login-correo, #login_form #login-password").forEach((input) => {
  input.addEventListener("keyup", (event) => validateField(event, rules));
  input.addEventListener("blur", (event) => validateField(event, rules));
});

$(".preloader ").fadeOut();
setSubmitState();
waitForTurnstileAndRender();

loginForm.addEventListener("submit", async (event) => {
  event.preventDefault();

  const dataForm = {
    email: document.getElementById("login-correo").value,
    password: document.getElementById("login-password").value
  };

  const error = validate(dataForm, rules);
  setValidationStyles("login-correo", error?.email ? error.email[0] : null);
  setValidationStyles("login-password", error?.password ? error.password[0] : null);

  if (error) {
    return;
  }

  if (!captchaToken) {
    setCaptchaMessage("Verifica el captcha para continuar.");
    setSubmitState();
    return;
  }

  isSubmitting = true;
  setSubmitState();
  spinner.classList.remove("d-none");

  try {
    const data = new FormData();
    data.append("email", document.getElementById("login-correo").value);
    data.append("password", document.getElementById("login-password").value);
    data.append("token", captchaToken);

    const request = await fetch("login/login", { method: "POST", body: data });
    const result = await request.json();

    if (result.success === true) {
      await sessionInfo();
      nuevaBitacora("Usuarios", "Login", "inicio de sesion");
      window.location = "home";
      return;
    }

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
      title: `${result.message || "No se pudo iniciar sesión"}`
    });

    if (result.resetCaptcha !== false) {
      resetCaptcha({ showMessage: true });
    }
  } catch (errorRequest) {
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
      title: "Error inesperado al validar el login"
    });

    resetCaptcha({ showMessage: true });
  } finally {
    isSubmitting = false;
    spinner.classList.add("d-none");
    setSubmitState();
  }
});
