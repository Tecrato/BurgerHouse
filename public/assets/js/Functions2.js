import { Response } from "./Enums.js";


// Utilidades secundarias

function parse_post_parameters(parametros_post) {
  let postData = '';
  for (let key in parametros_post) {
    if (postData !== '') {
      postData += '&';
    }
    postData += `${encodeURIComponent(key)}=${encodeURIComponent(parametros_post[key])}`;
  }
  return postData;
}


function getCookies(name) {
  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);

  if (parts.length === 2) return parts.pop().split(';').shift();
}

// Utilidades generales
export function myfecth(url, parametros_get = {}, parametros_post = null, callback = null, method = 'GET', async_call = false, parseAsJson = false) {
  const request = new XMLHttpRequest();
  request.withCredentials = true;
  let token = getCookies("PHPSESSID") || "";

  let postData = null;

  // parse de los parametros post dependiendo del tipo de dato que se envie
  if (method === 'POST' && parametros_post !== null) {
    if (parametros_post instanceof FormData) {
      // Dejar que el navegador establezca el encabezado Content-Type para FormData
      postData = parametros_post;
    } else if (parametros_post instanceof Object && parseAsJson) {
      postData = JSON.stringify(parametros_post);
    } else if (parametros_post instanceof Object) {
      postData = parse_post_parameters(parametros_post);
    } else if (typeof parametros_post === 'string' && parametros_post.length > 0) {
      postData = parametros_post;
    }
  }

  // Agregar parámetros GET a la URL
  let url_with_params = url;
  if (parametros_get !== null && Object.keys(parametros_get).length > 0) {
    url_with_params += '?';
    let first = true;
    for (let key in parametros_get) {
      if (!first) {
        url_with_params += '&';
      }
      url_with_params += `${key}=${parametros_get[key]}`;
      first = false;
    }
  }
  request.open(method, url_with_params, async_call);

  // Establecer encabezados según el tipo de datos enviados
  if (method === 'POST' && !(postData instanceof FormData)) {
      request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  } else if (method === 'POST' && postData instanceof Object) {
      request.setRequestHeader('Content-Type', 'application/json');
  }

  // Agregar token de sesión si está disponible
  if (token) {
    request.setRequestHeader("PHPSESSID", `${token}`);
  }

  if (async_call) {
    request.onload = function () {
      const resp = new Response(request.status, request.response);
      if (request.status >= 200 && request.status < 400) {
        // console.log(request.response);

        if (typeof callback === "function") callback(resp);
      } else {
        console.log('Error al obtener los datos');
        console.log(request.response);
      }
    }
    request.send(postData);
    return;
  }
  request.send(postData);
  const resp = new Response(request.status, request.response);
  if (typeof callback === "function")  callback(resp);
  return resp;
}

export function nuevaBitacora(table, action, description) {
  myfecth("bitacora/add", {}, { tabla: table, accion: action, descripcion: description }, null, 'POST', true);
}

export function sessionInfo(modulo = null) {
  let result = myfecth("login/SessionInfo").json();
  let permisos = (result.message.permisos || []).filter(permiso => permiso.modulo === modulo);
  return [result, permisos];
}
export function formatear_fecha(fechaString) {
    const fecha = new Date(fechaString);
    const dia = String(fecha.getDate()).padStart(2, '0');
    const mes = String(fecha.getMonth() + 1).padStart(2, '0');
    const anio = fecha.getFullYear();
    return `${dia}/${mes}/${anio}`;
  }

export function formatear_hora(fechaString) {
    const fecha = new Date(fechaString);
    const horas = String(fecha.getHours()).padStart(2, '0');
    const minutos = String(fecha.getMinutes()).padStart(2, '0');
    const segundos = String(fecha.getSeconds()).padStart(2, '0');
    return `${horas}:${minutos}:${segundos}`;
}

// Manipulación del DOM y eventos

export function imprimir(url, plantilla, contenedor, get_params = {}, post_params = null, callback = null,templateParams = {}) {
  let templatesWrapper = "";
  let templateCharge = `
        <div class="col-12 d-flex justify-content-center align-items-center fs-1" style="height: 50vh;">
          <div class="spinner-border" role="status" style="width: 150px; height: 150px; color: #c1c1c1;">
            <span class="visually-hidden">Loading...</span>
          </div>
        </div>
        `;
  const containerElement = document.querySelector(contenedor);
  if (!containerElement) return;
  containerElement.innerHTML = templateCharge;
  myfecth(url, get_params, post_params, function (response) {
    if (!response || response.status !== 200) {
      templatesWrapper = `
        <div class="col-12">
            <div class="d-flex justify-content-center align-items-center">
                <img src="./assets/img/cerrar.png" alt="Logo" class="img-fluid opacity-50">
            </div>
        </div>
      `;
      containerElement.innerHTML = templatesWrapper;
      feather.replace();
      if (typeof callback === "function") callback(null);
      return;
    }
    const data = response.json();
    
    if (!data || (Array.isArray(data) && data.length === 0)) {
      templatesWrapper = `
        <div class="col-12">
            <div class="d-flex justify-content-center align-items-center">
                <img src="./assets/img/bh_logo.png" alt="Logo" class="img-fluid opacity-25">
            </div>
        </div>
      `;
      containerElement.innerHTML = templatesWrapper;
      feather.replace();
      if (typeof callback === "function") callback(null);
      return;
    }
    let html = '';
    data.forEach(function (objet) {
      html += plantilla(objet, ...Object.values(templateParams));
    });
    document.querySelector(contenedor).innerHTML = html;
    if (typeof callback === "function") {
      callback(data);
    }
    feather.replace();
  }, 'POST', true);

}

export function funcs_btn_eliminar(recursive_call = null) {
  const btns_eliminar = document.querySelectorAll(".btn_eliminar");
  btns_eliminar.forEach(btn => {
    btn.addEventListener("click", (elemento) => {
      Swal.fire({
        title: "¿Deseas eliminar este elemento?",
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Eliminar",
        cancelButtonText: "Cancelar",
        confirmButtonColor: "#FF4B00",
      }).then(function (result) {
        console.log(result);
        if (!result.isConfirmed) {
          return;
        }
        
        
        elemento.preventDefault();
        let id = btn.dataset.id;
        let modulo = btn.dataset.module;
        let infosession = sessionInfo();
        myfecth(`${modulo}/update`, {}, { id: id, active: 0 }, function (response) {
          console.log(response, response.status);
          if (response.status === 200) {
            nuevaBitacora(modulo, "Eliminar", "El elemento con id " + id + " fue eliminado. ");
            
            Swal.fire({
              title: `Exito!`,
              text: "El elemento fue eliminado correctamente",
              icon: "success",
            });
            recursive_call();
          } else {
            
            Swal.fire({
              title: `Error!`,
              text: "Hubo un error al eliminar el elemento",
              icon: "error",
            });
          }
        }, 'POST');
      });
    });
  });
}
export function funcs_btn_editar(recursive_call) {
  const btns_editar = document.querySelectorAll(".edit_btn");
  btns_editar.forEach(btn => {
    btn.addEventListener("click", (elemento) => {
      elemento.preventDefault();
      let id = btn.dataset.id;
      recursive_call(id);
    });
  });
}
export function setValidationStyles(input, errorMessage) {
  const inputElement = document.getElementById(input);
  const errorElement = document.getElementById("error-" + input);

  if (errorMessage) {
    inputElement.classList.add("is-invalid");
    inputElement.classList.remove("is-valid");
    errorElement.textContent = errorMessage;
  } else {
    inputElement.classList.add("is-valid");
    inputElement.classList.remove("is-invalid");
    errorElement.textContent = "";
  }
}

export function searchFilter(inputSelector, callback) {
    const inputElement = document.querySelector(inputSelector);
    if (inputElement) inputElement.addEventListener('keyup', callback);
}


export function InputPriceFormat(input) {
  let inputDom = document.querySelectorAll(input);
  inputDom.forEach((element) => {
    element.addEventListener("input", (e) => {
      let valueUser = e.target.value.replace(/,/g, "").replace(/\./g, "").replace(/[^0-9]/g, "");
      if (valueUser.length <= 2) {
        element.value = "0," + valueUser;
      } else if (valueUser.length >= 3) {
        element.value = `${parseFloat(valueUser.slice(0, valueUser.length - 2)).toLocaleString('es-VE')},${valueUser.slice(valueUser.length - 2)}`;
        //element.value = it.replace(/^0(?=\d)\,?/, "").replace(/\B(?=(\d{3})+(?!\d))/g, ".");
      }
    });
  });
}