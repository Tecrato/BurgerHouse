import { myfecth } from "./Functions2.js";

// Importar validate desde window (cargado como script clásico)
const validate = window.validate;

export default function functionGeneral() {

  async function permission(module = null, funtion = null) {
    if (module != null) {
      return
    }
    let session = await sessionInfo();
    let response = session.message.permisos
    const permiss = response.find((e) => e.modulo.toLocaleLowerCase() == module.toLocaleLowerCase()) ? response.find((e) => e.modulo.toLocaleLowerCase() == module.toLocaleLowerCase()) : null;

    if (permiss != null) {
      let permissions = permiss.permisos.split(",");
      let tipos_permisos = {
        "agregar": "-add",
        "editar": "-edit",
        "eliminar": "-delete",
        "consultar": "",
        "verificar": "-verify",
        "anular": "-null",
        "crear": "-create",
        "despachar": "-dispatch",
        "preparar": "-prepared",
        "ver detalles": "-details",
        "guardar gasto": "-gasto",
        "guardar ingreso": "-ingreso",
        "restaurar": "-restore",
        "abrir": "-open",
        "cerrar": "-close",
        "asignar roles": "-assign_rol",
        "importar": "-import",
        "exportar": "-export",
        "agregar productos": "-moreProducts",
        "pagar": "-PayOrder",
        "aceptar entrega": "-acceptDelivery",
        "agendar reservacion": "-schedule",
        "anular reservacion": "-nullSchedule",
        "verificar reservacion": "-verifySchedule"
      }
      
      
      for (const permiso in tipos_permisos) {
        if (!permissions.includes(permiso)) {
          document.querySelectorAll(`[data-module${tipos_permisos[permiso]}='${module}']`).forEach((d) => d.remove());
        }
      }
    } else {
      if (document.querySelector(`[data-module='${module}']`)) {
        document.querySelectorAll(`[data-module='${module}']`).forEach((d) => d.remove());
      }
    }
    if (typeof funtion == "function") funtion()
  }
  function InputPrice(input) {
    let inputDom = document.querySelectorAll(input);
    inputDom.forEach((element) => {
      element.addEventListener("input", (e) => {
        let valueUser = e.target.value.replace(/,/g, "").replace(/\./g, "").replace(/[^0-9]/g, "");
        let valueLength = valueUser.length;
        if (valueLength <= 2) {
          element.value = "0," + valueUser;
        } else if (valueLength >= 3) {
          let it = valueUser.slice(0, valueLength - 2) + "," + valueUser.slice(valueLength - 2);
          element.value = it.replace(/^0(?=\d)\,?/, "").replace(/\B(?=(\d{3})+(?!\d))/g, ".");
        }
      });
    });
  }
  const CheckCash = async () => {
    let id_cash = null
    let caja = myfecth("caja/get_all").json()
    console.log(caja);
    if (caja.length > 0) {
      caja.forEach((e) => {
        /// (fecha(e.fecha_apertura) == fecha(new Date())) && 
        if (e.estado == 1) {
          id_cash = e.id
        }
      })
    }
    return id_cash
  }
  function hora(f) {
    const fecha = new Date(f);
    const horas = fecha.getHours();
    const minutos = fecha.getMinutes();
    const periodo = horas >= 12 ? "PM" : "AM";
    const horas12 = horas % 12 || 12;
    const horaFormateada = `${horas12}:${minutos < 10 ? `0${minutos}` : minutos} ${periodo}`;
    return horaFormateada;
  }
  const amountDolar = async () => {
    let search = await fetch("https://ve.dolarapi.com/v1/dolares")
    let response = await search.json()
    return parseFloat(response[0].promedio).toFixed(2);
  }
  function fecha(f) {
    const fecha = new Date(f);
    const dia = fecha.getDate();
    const mes = fecha.getMonth() + 1;
    const anio = fecha.getFullYear();
    const fechaFormateada = `${dia}/${mes}/${anio}`;
    return fechaFormateada;
  }
  function diasRestantesFechaVencimiento(element) {
    let fechaVencimiento = new Date(element.fecha_vencimiento);
    let fechaActual = new Date();
    fechaVencimiento.setMinutes(fechaVencimiento.getMinutes() + fechaVencimiento.getTimezoneOffset());

    let diferencia = fechaVencimiento.getTime() - fechaActual.getTime();
    let diasRestantes = Math.ceil(diferencia / (1000 * 60 * 60 * 24));
    return diasRestantes;
  }
  function setValidationStyles(input, errorMessage) {
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
  function validateField(event, rules) {
    const field = event.target;
    const fieldName = field.name;
    const fieldValue = field.value;
    const data = { [fieldName]: fieldValue };
    const fieldRules = { [fieldName]: rules[fieldName] };

    const errors = validate(data, fieldRules);
    const errorMessage = errors ? errors[fieldName][0] : null;
    setValidationStyles(field.id, errorMessage);
  }
  function reindex(elementAll, id, counter, name) {
    const element = document.querySelectorAll(elementAll);
    counter = element.length;

    element.forEach((item, index) => {
      const newIndex = index + 1;
      item.id = `${id}-${newIndex}`;

      item.querySelectorAll("input").forEach((input) => {
        const parts = input.id.split("-");
        const baseId = parts.slice(0, parts.length - 1).join("-");
        const newId = `${baseId}-${newIndex}`;
        input.id = newId;
      });
      item.querySelectorAll("[id^='error-input']").forEach((errorDiv) => {
        const parts = errorDiv.id.split("-");
        const newId = `${parts[0]}-${parts[1]}-${parts[2]}-${parts[3]}-${newIndex}`;
        errorDiv.id = newId;
      });

      const header = item.querySelector("h4");
      if (header) {
        header.textContent = `${name} ${newIndex}`;
      }
    });
  }
  function resetForm(elements, form) {
    let supplier = document.querySelectorAll(elements);
    supplier.forEach((d) => {
      let id = d.id.split("-")[1];
      if (id > 1) d.remove();
      d.querySelectorAll("input, textarea").forEach((input) => {
        input.value = input.type === "button" ? "Seleccione una opcion" : "";
        if (input.tagName.toLowerCase() === "input") {
          if (input.type === "button") {
            input.setAttribute("data-id", "Seleccione una opcion");
          }
        }
        input.classList.remove("is-valid", "is-invalid");
      });
      if (d.querySelectorAll("img")) {
        d.querySelectorAll("img").forEach((img) => {
          img.src = "";
          img.style.display = "none";
        });
      }
    });
    form.reset();
  }
  async function SelectOption(selectItem = null, module = null, template = null) {
    let select = document.querySelector(selectItem);
    if (module != null) {
      let template = ""
      let data = myfecth(`rol/get_all/0/6/id/desc`, {}, {active: 1}).json()
      if (data.length == 0) {
        select.querySelector(".options_search").innerHTML = `<a class="dropdown-item">No hay resultados</a>`;
      } else {
        data.forEach((element) => {
          template += ` <a class="dropdown-item" data-id="${element.id}">${element.nombre}</a>`;
        });
        select.querySelector(".options_search").innerHTML = template;
      }
    }
    if (module != null) {
      select.querySelector(".search_select").addEventListener("keyup", async (e) => {
        if (e.target.value != "") {
          let res = await searchLike(e, module, 1);
          let cont = "";
          if (res.length == 0) {
            cont = `<a class="dropdown-item"">No hay resultados</a>`;
            select.querySelector(".options_search").innerHTML = cont;
          } else {
            res.forEach((element) => {
              cont += template(element);
            });
          }
          select.querySelector(".options_search").innerHTML = cont;
          select.querySelectorAll(".dropdown-item").forEach((item) => {
            item.addEventListener("click", () => {
              let input = item.parentElement.parentElement.parentElement.firstElementChild.value;
              let option = item.textContent;
              item.parentElement.parentElement.parentElement.firstElementChild.value = option;
              if (module != null) {
                let id = item.getAttribute("data-id");
                item.parentElement.parentElement.parentElement.firstElementChild.setAttribute("data-id", id);
              }
              if (input != "" || input != "Seleccione una opcion") {
                item.parentElement.parentElement.firstElementChild.parentElement.parentElement.parentElement.parentElement.nextElementSibling.textContent = "";
              }
            });
          });

        }
      });
    }
    select.querySelectorAll(".dropdown-item").forEach((item) => {
      item.addEventListener("click", () => {
        let input = item.parentElement.parentElement.parentElement.firstElementChild.value;
        let option = item.textContent;
        item.parentElement.parentElement.parentElement.firstElementChild.value = option;
        if (module != null) {
          let id = item.getAttribute("data-id");
          item.parentElement.parentElement.parentElement.firstElementChild.setAttribute("data-id", id);
        }
        if (input != "" || input != "Seleccione una opcion") {
          item.parentElement.parentElement.firstElementChild.parentElement.parentElement.parentElement.parentElement.nextElementSibling.textContent = "";
        }
      });
    });
  }
  async function selectOptionAll(item = null, module = null, template = null) {
    let select = document.querySelectorAll(item);
    select.forEach(async (element) => {
      if (module != null) {
        let data = myfecth(`${module}/get_all/0/6/id/desc`, {}, {active: 1}).json()
        let cont = ""
        if (data.length == 0) {
          element.querySelector(".options_search").innerHTML = `<a class="dropdown-item">No hay resultados</a>`;
        } else {
          data.forEach((element) => {
            cont += template(element);
          });
          element.querySelector(".options_search").innerHTML = cont;
        }
        element.querySelectorAll(".dropdown-item").forEach((item) => {
          item.addEventListener("click", () => {
            let input = item.parentElement.parentElement.parentElement.firstElementChild.value;
            let option = item.textContent;
            item.parentElement.parentElement.parentElement.firstElementChild.value = option;
            if (module != null) {
              let id = item.getAttribute("data-id");
              item.parentElement.parentElement.parentElement.firstElementChild.setAttribute("data-id", id);
            }
            if (input != "" || input != "Seleccione una opcion") {
              item.parentElement.parentElement.firstElementChild.parentElement.parentElement.parentElement.parentElement.nextElementSibling.textContent = "";
            }
          });
        });
      }
      if (module != null) {
        element.querySelector(".search_select").addEventListener("keyup", async (e) => {
          if (e.target.value != "") {
            let res = myfecth(`${module}/get_all`, {},{nombre_like: e.target.value, active: 1}).json();
            let cont = "";
            if (res.length == 0) {
              cont = `<a class="dropdown-item">No hay resultados</a>`;
              element.querySelector(".options_search").innerHTML = cont;
            } else {
              res.forEach((element) => {
                cont += template(element);
              });
            }
            element.querySelector(".options_search").innerHTML = cont;
            inputSet()
          } else {
            let res = myfecth(`${module}/get_all`, {},{active: 1}).json()
            let cont = "";
            if (res.length == 0) {
              cont = `<a class="dropdown-item">No hay resultados</a>`;
              element.querySelector(".options_search").innerHTML = cont;
            } else {
              res.forEach((element) => {
                cont += template(element);
              });
            }
            element.querySelector(".options_search").innerHTML = cont;
            inputSet()
          }
        });
      }
      const inputSet = () => {
        element.querySelectorAll(".dropdown-item").forEach((item) => {
          item.addEventListener("click", () => {
            let input = item.parentElement.parentElement.parentElement.firstElementChild.value;
            let option = item.textContent;
            item.parentElement.parentElement.parentElement.firstElementChild.value = option;
            if (module != null) {
              let id = item.getAttribute("data-id");
              item.parentElement.parentElement.parentElement.firstElementChild.setAttribute("data-id", id);
            }
            if (module == "materia_prima") {
              item.closest(".row").querySelector(".type_unit").textContent = item.getAttribute("data-unit");
            }
            if (module == "metodo_pago") {
              if (item.textContent.toLocaleLowerCase() == "efectivo" || item.textContent.toLocaleLowerCase() == "transferencia" || item.textContent.toLocaleLowerCase() == "pago movil") {
                item.closest(".row").querySelector(".type_payment").textContent = "Bs";
              } else { item.closest(".row").querySelector(".type_payment").textContent = "$"; }
            }
            if (input != "" || input != "Seleccione una opcion") {
              item.parentElement.parentElement.firstElementChild.parentElement.parentElement.parentElement.parentElement.nextElementSibling.textContent = "";
            }
          });
        });
      }
      inputSet()
    })
  }
  async function reference(modal, carpeta) {
    let btn = document.querySelectorAll(".reference_btn");
    let modalCont = document.querySelector(modal);
    btn.forEach((element) => {
      element.addEventListener("click", async () => {
        let id = element.getAttribute("data-id");
        let module = element.getAttribute("data-module");
        let data = new FormData();
        data.append("id", id);
        let pet = myfecth(`${module}/get_all`, {}, {id: id}, null, "POST");
        let response = pet.json();
        let img = response[0].comprobante;
        modalCont.querySelector(".view_comprobante").src = `media/${carpeta}/${img}`;
      });
    });
  }
  function viewImage(inputs) {
    document.querySelectorAll(inputs).forEach((image) => {
      image.addEventListener("change", function (event) {
        const file = event.target.files[0]; // Obtiene el archivo seleccionado
        if (file) {
          const reader = new FileReader();
          reader.onload = function (e) {
            const img = image.parentElement.nextElementSibling;
            img.src = e.target.result; // Asigna el resultado de la lectura al src de la imagen
            img.style.display = "block"; // Muestra la imagen
          };
          reader.readAsDataURL(file); // Convierte el archivo en una URL de datos
        }
      });
    });
  }
  const sessionInfo = async () => {
    let pet = myfecth("login/SessionInfo")
    let response = pet.json()
    return response
  }
  //--------------funciones para el manejo de peticiones ajax para las tarjetas------------------
  const binnacle = async (id_user, table, action, description) => {
    let data = new FormData();
    data.append("tabla", table);
    data.append("accion", action);
    data.append("descripcion", description);
    let search = myfecth("bitacora/add", {}, data, null, "POST");
  }
  const print = async (config) => {
    const { search, template, container, funtions } = config;
    let templatesWrapper = "";
    let templateCharge = "";
    templateCharge = `
          <div class="col-12 d-flex justify-content-center align-items-center fs-1" style="height: 50vh;">
            <div class="spinner-border" role="status" style="width: 150px; height: 150px; color: #c1c1c1;">
              <span class="visually-hidden">Loading...</span>
            </div>
          </div>
          `
    document.querySelector(container).innerHTML = templateCharge;
    let response = await search();
    if (response.length == 0) {
      templatesWrapper = `
        <div class="col-12">
            <div class="d-flex justify-content-center align-items-center">
                <img src="./assets/img/bh_logo.png" alt="Logo" class="img-fluid opacity-25">
            </div>
        </div>
      `;
    } else {
      for (const element of response) {
        templatesWrapper += await template(element);
      }
    }
    document.querySelector(container).innerHTML = templatesWrapper;
    feather.replace();
    funtions()
  };
  const Delete = (config, binnacleDelete) => {
    document.querySelectorAll(".trash_btn").forEach((element) => {
      element.addEventListener("click", () => {
        Swal.fire({
          title: "¿Deseas eliminar este elemento?",
          icon: "warning",
          showCancelButton: true,
          confirmButtonText: "Eliminar",
          cancelButtonText: "Cancelar",
          confirmButtonColor: "#FF4B00",
        }).then((result) => {
          if (result.isConfirmed) {
            let id = element.getAttribute("data-id");
            let module = element.getAttribute("module-delete");
            $.ajax({
              type: "POST",
              url: `${module}/update`,
              data: { id, active: 0 },
              success: function (response) {
                if (response.success == true) {
                  Swal.fire({
                    title: `Exito!`,
                    text: "El elemento fue eliminado correctamente",
                    icon: "success",
                  });
                  print(config);
                  binnacleDelete()
                } else {
                  Swal.fire({
                    title: `Error!`,
                    text: "El elemento no fue eliminado",
                    icon: "error",
                  });
                }

              }
            });

          }
        });
      });
    });
  };
  const add = async (config, module, data, binnacleAdd) => {
    Swal.fire({
      title: 'Procesando...',
      text: 'Por favor espera',
      allowOutsideClick: false,
      didOpen: () => { Swal.showLoading() }
    });
    let action = await fetch(`${module}/add_many`, { method: "POST", body: data, });
    let response = await action.json()
    console.log(response);
    if (response.success == true) {
      Swal.close();
      Swal.fire({
        title: `Exito!`,
        text: "El elemento fue agregado correctamente",
        icon: "success",
      });
      print(config);
      binnacleAdd()
    } else {
      Swal.close();
      Swal.fire({
        title: `Error!`,
        text: `${response.message}`,
        icon: "error",
      });
    }
  };
  const searchParam = async (param, module, pagination = null, nro_page = null) => {
    let data = new FormData();
    Object.entries(param).forEach(([key, value]) => {
      if (value && typeof value === "object" && !Array.isArray(value)) {
        Object.entries(value).forEach(([subKey, subValue]) => {
          data.append(`${key}[${subKey}]`, subValue);
        });
      } else {
        data.append(key, value);
      }
    });

    let pet = await fetch(`${module}/get_all/${nro_page == null ? 0 : nro_page}/${pagination == null ? 6 : pagination}/id/desc`, {
      method: "POST",
      body: data
    });
    let response = await pet.json()
    return response
  };

  const update = async (config, module, data, binnacleAdd) => {
    Swal.fire({
      title: 'Procesando...',
      text: 'Por favor espera',
      allowOutsideClick: false,
      didOpen: () => { Swal.showLoading() }
    });
    let action = await fetch(`${module}/update`, {
      method: "POST",
      body: data,
    });
    let response = await action.json();
    if (response.success == true) {
      Swal.close();
      Swal.fire({
        title: `Exito!`,
        text: "El elemento fue actualizado correctamente",
        icon: "success",
      });
      print(config);
      binnacleAdd()
    } else {
      Swal.close();
      Swal.fire({
        title: `Error!`,
        text: "El elemento no fue actualizado",
        icon: "error",
      });
    }
  };
  const edit = async (inputs) => {
    document.querySelectorAll(".edit_btn").forEach(btn => {
      btn.addEventListener("click", async () => {
        let id = btn.getAttribute("data-id")
        let module = btn.getAttribute("module-edit")
        let data = new FormData();
        module == "Detalle_receta" ? data.append("id_receta", id) : data.append("id", id);
        let pet = await fetch(`${module}/get_all`, {
          method: "POST",
          body: data
        })
        let response = await pet.json()
        if (typeof inputs === "function") {
          inputs(response);
        }
      })
    })
  }
  const searchFilter = (searchInput, searchLike) => {
    let search = document.querySelector(searchInput);
    search.addEventListener("keyup", async (e) => {
      searchLike(e)
    });
  }
  const searchBetween = (searchInput, searchLike) => {
    let search = document.querySelector(searchInput);
    search.addEventListener("submit", async (e) => {
      e.preventDefault()
      e.stopPropagation()
      searchLike(e)
    });
  }
  const pagination = (print, pagItem) => {
    document.querySelectorAll(pagItem).forEach((pagination) => {
      let page = 0;
      const renderPagination = () => {
        pagination.querySelectorAll(".page-number").forEach(el => el.remove());
        const prevBtn = pagination.querySelector("#prev-page");
        const nextBtn = pagination.querySelector("#next-page");
        if (page > 0) {
          const prevNum = document.createElement("li");
          prevNum.className = "page-item page-number";
          prevNum.innerHTML = `<a class="page-link" href="#">${page}</a>`;
          prevNum.addEventListener("click", (e) => {
            e.preventDefault();
            page = page - 1;
            updatePag();
          });
          pagination.insertBefore(prevNum, nextBtn);
        }

        const current = document.createElement("li");
        current.className = "page-item page-number active";
        current.innerHTML = `<span class="page-link">${page + 1}</span>`;
        pagination.insertBefore(current, nextBtn);

        const nextNum = document.createElement("li");
        nextNum.className = "page-item page-number";
        nextNum.innerHTML = `<a class="page-link" href="#">${page + 2}</a>`;
        nextNum.addEventListener("click", (e) => {
          e.preventDefault();
          page = page + 1;
          updatePag();
        });
        pagination.insertBefore(nextNum, nextBtn);

        if (prevBtn) {
          prevBtn.classList.toggle("disabled", page === 0);
        }
      };

      const updatePag = () => {
        print(page);
        renderPagination();
      };

      const prevBtn = pagination.querySelector("#prev-page");
      const nextBtn = pagination.querySelector("#next-page");

      if (prevBtn) {
        prevBtn.addEventListener("click", (e) => {
          e.preventDefault();
          if (page > 0) {
            page--;
            updatePag();
          }
        });
      }
      if (nextBtn) {
        nextBtn.addEventListener("click", (e) => {
          e.preventDefault();
          page++;
          updatePag();
        });
      }
      updatePag();
    });
  };
  const notificationAlert = async (data) => {
    const { channel, message, event } = data
    let dataNotification = new FormData()
    dataNotification.append("channel", channel)
    dataNotification.append("message", message)
    dataNotification.append("event", event)
    const pet = await fetch(`notification/sendNotifications`, { method: "POST", body: dataNotification })
    const response = await pet.json()
    console.log(response);
  }
  const notification = async (data) => {
    const { id_usuario, titulo, mensaje } = data
    let dataNotification = new FormData()
    dataNotification.append("id_usuario", id_usuario)
    dataNotification.append("mensaje", mensaje)
    dataNotification.append("titulo", titulo)
    const pet = await fetch(`notification/add`, { method: "POST", body: dataNotification })
    const response = await pet.json()
    console.log(response);
  }
  //--------------funciones para el manejo de peticiones ajax para las datatables------------------
  const deleteDatatable = (tableItem, table, binnacle) => {
    $(`${tableItem} tbody`).on("click", ".trash_btn_datatable", function () {
      Swal.fire({
        title: "¿Deseas eliminar este elemento?",
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Eliminar",
        cancelButtonText: "Cancelar",
        confirmButtonColor: "#FF4B00",
      }).then((result) => {
        if (result.isConfirmed) {
          let id = this.getAttribute("data-id");
          let module = this.getAttribute("module-delete");
          $.ajax({
            type: "POST",
            url: `${module}/update`,
            data: { id, active: 0 },
            success: function (response) {
              if (response.success == true) {
                Swal.fire({
                  title: `Exito!`,
                  text: "El elemento fue eliminado correctamente",
                  icon: "success",
                });
                table.ajax.reload();
                binnacle()
              } else {
                Swal.fire({
                  title: `Error!`,
                  text: "El elemento no fue eliminado",
                  icon: "error",
                });
              }
            },
          });
        }
      });
    });
  };
  const addDataTables = async (table, data, module, binnacle) => {
    Swal.fire({
      title: 'Procesando...',
      text: 'Por favor espera',
      allowOutsideClick: false,
      didOpen: () => { Swal.showLoading() }
    });
    let pet = await fetch(`${module}/add_many`, {
      method: "POST",
      body: data,
    })
    let response = await pet.json()
    if (response.success == true) {
      Swal.close();
      Swal.fire({
        title: `Exito!`,
        text: "El elemento fue agregado correctamente",
        icon: "success",
      });
      table.ajax.reload();
      binnacle()
    } else {
      Swal.close();
      Swal.fire({
        title: `Error!`,
        text: "El elemento no fue agregado",
        icon: "error",
      });
    }
  }
  const editDataTables = async (tableItem, inputs) => {
    $(`${tableItem} tbody`).on("click", ".edit_btn_datatable", function () {
      let id = this.getAttribute("data-id")
      let module = this.getAttribute("module-edit")
      $.ajax({
        type: "POST",
        url: `${module}/get_all`,
        data: { "id": id },
        success: function (response) {
          inputs(response);
        }
      })
    })
  }
  const updateDataTables = async (table, data, module, binnacle) => {
    Swal.fire({
      title: 'Procesando...',
      text: 'Por favor espera',
      allowOutsideClick: false,
      didOpen: () => { Swal.showLoading() }
    });
    let pet = await fetch(`${module}/update`, {
      method: "POST",
      body: data,
    })
    let response = await pet.json()
    if (response.success == true) {
      Swal.close();
      Swal.fire({
        title: `Exito!`,
        text: "El elemento fue actualizado correctamente",
        icon: "success",
      });
      table.ajax.reload();
      binnacle()
    } else {
      Swal.close();
      Swal.fire({
        title: `Error!`,
        text: "El elemento no fue actualizado",
        icon: "error",
      });
    }
  }
  return {
    validate,
    InputPrice,
    hora,
    fecha,
    amountDolar,
    diasRestantesFechaVencimiento,
    setValidationStyles,
    validateField,
    binnacle,
    notification,
    notificationAlert,
    reference,
    sessionInfo,
    SelectOption,
    CheckCash,
    selectOptionAll,
    viewImage,
    searchParam,
    searchFilter,
    searchBetween,
    pagination,
    print,
    add,
    Delete,
    edit,
    update,
    reindex,
    resetForm,
    permission,
    addDataTables,
    deleteDatatable,
    editDataTables,
    updateDataTables,
  };
}
