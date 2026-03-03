import functionGeneral from "../../Functions.js";
import { nuevaBitacora } from "../../Functions2.js"
import Templates from "../../templates.js";
import introTooltip from "../../intro-tooltip.js"
const { productProcessIntro } = introTooltip()
const { InputPrice, update, selectOptionAll, viewImage, setValidationStyles, validateField, searchParam, print, add, reindex, resetForm, permission, searchFilter, sessionInfo, binnacle, edit, Delete } = functionGeneral();
const { targetProductProcess, elemenFormProductProcess, optionsRol } = Templates()
const tooltip = new bootstrap.Tooltip(document.querySelector(".btn-add-tooltip"))
let session = await sessionInfo()
productProcessIntro('navbarDropdown')
InputPrice("[input_price]");
selectOptionAll(".select_options_category_combo", "categoryProducto", optionsRol)
viewImage(".input-image")
permission("Producto procesado")//verifica el btn de agg
const config = {
  search: () => searchParam({ active: 1 }, "productProcess"),
  template: targetProductProcess,
  container: ".cont-product",
  funtions: () => {
    Delete(config, () => nuevaBitacora('Productos Procesado', 'Eliminacion', 'Se elimino un producto procesado'));
    edit((response) => editData(response));
    document.querySelectorAll(".edit_btn, .trash_btn").forEach((element) => { let tooltip = new bootstrap.Tooltip(element) });
    permission("Producto procesado")
  }
}
searchFilter("#searchProduct", (e) => {
  if (e.target.value == "") print(config)
  else print({ ...config, search: () => searchParam({ active: 1, nombre_like: e.target.value }, "productProcess") })
})
// ------------------Validacion de Formulario---------------------------
// Contador global de productos. Inicia en 1 porque ya existe un producto por defecto.
let productCount = 1;
function addProduct() {
  productCount++;
  document.getElementById("products-container").insertAdjacentHTML('beforeend', elemenFormProductProcess(productCount));
  feather.replace();
  selectOptionAll(".select_options_category_combo", "categoryProducto", optionsRol)

  viewImage(".input-image")
  InputPrice("[input_price]");

  attachValidationListeners(productCount);

  const newProduct = document.getElementById(`product-${productCount}`);
  newProduct.querySelector(".remove-product").addEventListener("click", function () {
    newProduct.remove();
    reindex("#products-container .product", "product", productCount, "Producto");
  });
}
function attachValidationListeners(index) {
  const productElement = document.getElementById(`product-${index}`);
  productElement.querySelectorAll("input[type='text'], textarea, input[type='button'], input[type='file']").forEach(input => {
    input.addEventListener("keyup", (e) => validateField(e, rules));
    input.addEventListener("blur", (e) => validateField(e, rules));
    input.addEventListener("change", (e) => validateField(e, rules));
  });

  ["min", "max"].forEach(name => {
    const input = productElement.querySelector(`input[name="${name}"]`);
    input.addEventListener("keyup", () => {
      const minVal = Number(productElement.querySelector(`input[name="min"]`).value);
      const maxVal = Number(productElement.querySelector(`input[name="max"]`).value);
      let minError = null;
      let maxError = null;

      if (isNaN(minVal) || minVal <= 0) minError = "Debe ser un número mayor que 0";

      if (isNaN(maxVal) || maxVal <= 0) maxError = "Debe ser un número mayor que 0";

      if (minError === null && maxError === null) {
        if (maxVal < minVal) maxError = "No puede ser menor que Stock Min";
      }

      setValidationStyles(`input-min-combo-${index}`, minError);
      setValidationStyles(`input-max-combo-${index}`, maxError);
    });
  });

  const productElement2 = document.getElementById(`product-container`);
  productElement2.querySelectorAll("input[type='text'], textarea, input[type='button']").forEach(input => {
    input.addEventListener("keyup", (e) => validateField(e, rules));
    input.addEventListener("blur", (e) => validateField(e, rules));
    input.addEventListener("change", (e) => validateField(e, rules));
  });

  ["min", "max"].forEach(name => {
    const input = productElement2.querySelector(`input[name="${name}"]`);
    input.addEventListener("keyup", () => {
      const minVal = Number(productElement2.querySelector(`input[name="min"]`).value);
      const maxVal = Number(productElement2.querySelector(`input[name="max"]`).value);
      let minError = null;
      let maxError = null;

      if (isNaN(minVal) || minVal <= 0) minError = "Debe ser un número mayor que 0";

      if (isNaN(maxVal) || maxVal <= 0) maxError = "Debe ser un número mayor que 0";

      if (minError === null && maxError === null) {
        if (maxVal < minVal) maxError = "No puede ser menor que Stock Min";
      }
      setValidationStyles(`input-min-combo`, minError);
      setValidationStyles(`input-max-combo`, maxError);
    });
  });
}
document.getElementById("add-product-btn").addEventListener("click", () => {
  addProduct();
  reindex("#products-container .product", "product", productCount, "Producto");
});
validate.validators.precio = function (value, options, key, attributes) {
  if (!value) return;
  const cleanValue = value.replace(/\./g, '').replace(',', '.');
  const numberValue = parseFloat(cleanValue);

  if (isNaN(numberValue)) {
    return options.message || "no es un número válido";
  }
  if (numberValue <= 0) {
    return options.message || "debe ser un número mayor a 0";
  }
};
validate.validators.validateCategoryAndRecipe = function (value, options, key, attributes) {
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
validate.validators.stockValidator = function (value, options, key, attributes) {
  // Si uno de los dos no está presente, no hacemos nada
  if (value == null || attributes[options.field] == null) return;
  const val = Number(value);
  const other = Number(attributes[options.field]);
  if (isNaN(val) || isNaN(other)) return;
  if (val < other) {
    return options.message || `no puede ser menor que ${options.field}`;
  }
};
validate.validators.fileType = function (value, options, key, attributes) {
  if (!value) return
  if (value.type) {
    const typeFile = value.type.split("/")[1]
    if (!options.types.includes(typeFile)) {
      return `debe ser una imagen JPG, PNG o WEBP`;
    }
  } else {
    const typeFile = value.split(".")[1]
    if (!options.types.includes(typeFile)) {
      return `debe ser una imagen JPG, PNG o WEBP`;
    }
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
  precio: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    precio: { message: "^debe ser un número mayor a 0" }
  },
  id_categoria: {
    presence: {
      allowEmpty: false,
      message: "^es requerida"
    },
    validateCategoryAndRecipe: { message: "^es requerido" }
  },
  detalles: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    length: {
      minimum: 15,
      message: "^debe tener al menos 15 caracteres"
    }
  },
  imagen: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    fileType: {
      types: ['jpeg', 'png', 'webp', 'jpg']
    }
  },
  min: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    numericality: {
      onlyInteger: true,
      greaterThan: 0,
      message: "^debe ser un número mayor que 0"
    }
  },
  max: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    numericality: {
      onlyInteger: true,
      greaterThan: 0,
      message: "^debe ser un número mayor que 0"
    },
    stockValidator: {
      field: "min",
      message: "^no puede ser menor que Stock Min"
    }
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
  precio: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    precio: { message: "^debe ser un número mayor a 0" }
  },
  id_categoria: {
    presence: {
      allowEmpty: false,
      message: "^es requerida"
    },
    validateCategoryAndRecipe: { message: "^es requerido" }
  },
  detalles: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    length: {
      minimum: 15,
      message: "^debe tener al menos 15 caracteres"
    }
  },
  min: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    numericality: {
      onlyInteger: true,
      greaterThan: 0,
      message: "^debe ser un número mayor que 0"
    }
  },
  max: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    numericality: {
      onlyInteger: true,
      greaterThan: 0,
      message: "^debe ser un número mayor que 0"
    },
    stockValidator: {
      field: "min",
      message: "^no puede ser menor que Stock Min"
    }
  }
};
const rules3 = {
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
  precio: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    precio: { message: "^debe ser un número mayor a 0" }
  },
  id_categoria: {
    presence: {
      allowEmpty: false,
      message: "^es requerida"
    },
    validateCategoryAndRecipe: { message: "^es requerido" }
  },
  detalles: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    length: {
      minimum: 15,
      message: "^debe tener al menos 15 caracteres"
    }
  },
  imagen: {
    fileType: {
      types: ['jpeg', 'png', 'webp', 'jpg']
    }
  },
  min: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    numericality: {
      onlyInteger: true,
      greaterThan: 0,
      message: "^debe ser un número mayor que 0"
    }
  },
  max: {
    presence: {
      allowEmpty: false,
      message: "^es requerido"
    },
    numericality: {
      onlyInteger: true,
      greaterThan: 0,
      message: "^debe ser un número mayor que 0"
    },
    stockValidator: {
      field: "min",
      message: "^no puede ser menor que Stock Min"
    }
  }
};
let form = document.getElementById("form-submit-combo")
if (!form.dataset.listenerAttached) {
  form.addEventListener("submit", function (e) {
    e.preventDefault();
    const products = document.querySelectorAll(".product");
    let formHasError = false;
    let combo = []
    products.forEach((product, i) => {
      const index = i + 1;
      const data = {
        nombre: product.querySelector(`input[name="nombre"]`).value,
        precio: product.querySelector(`input[name="precio"]`).value.replace(/\./g, '').replace(',', '.'),
        id_categoria: product.querySelector(`input[name="id_categoria"]`).getAttribute("data-id"),
        detalles: product.querySelector(`textarea[name="detalles"]`) ? product.querySelector(`textarea[name="detalles"]`).value : "",
        imagen: product.querySelector(`input[name="imagen"]`) ? product.querySelector(`input[name="imagen"]`).files[0] : "",
        min: product.querySelector(`input[name="min"]`).value,
        max: product.querySelector(`input[name="max"]`).value
      };
      combo.push(data)

      const errors = validate(data, rules);
      setValidationStyles(`input-name-combo-${index}`, errors?.nombre ? errors.nombre[0] : null);
      setValidationStyles(`input-price-combo-${index}`, errors?.precio ? errors.precio[0] : null);
      setValidationStyles(`input-category-combo-${index}`, errors?.id_categoria ? errors.id_categoria[0] : null);
      setValidationStyles(`input-details-combo-${index}`, errors?.detalles ? errors.detalles[0] : null);
      setValidationStyles(`input-image-combo-${index}`, errors?.imagen ? errors.imagen[0] : null);
      setValidationStyles(`input-min-combo-${index}`, errors?.min ? errors.min[0] : null);
      setValidationStyles(`input-max-combo-${index}`, errors?.max ? errors.max[0] : null);
      if (errors) {
        formHasError = true;
      }
    });
    if (!formHasError) {
      let data = new FormData()
      combo.forEach((combo, index) => {
        data.append(`lista[${index}][nombre]`, combo.nombre);
        data.append(`lista[${index}][precio]`, combo.precio);
        data.append(`lista[${index}][id_categoria]`, combo.id_categoria);
        data.append(`lista[${index}][detalles]`, combo.detalles);
        data.append(`lista[${index}][imagen_name]`, combo.imagen.name);
        data.append(`lista[${index}][imagen]`, combo.imagen);
        data.append(`lista[${index}][stock_min]`, combo.min);
        data.append(`lista[${index}][stock_max]`, combo.max);
      })
      resetForm("#products-container .product", form)
      add(config, 'productProcess', data, () => nuevaBitacora('Producto procesado', 'Agregar', 'Se agrego un producto procesado'))
      bootstrap.Modal.getOrCreateInstance('#register-product').hide()
    }
  });
  form.dataset.listenerAttached = "true";
}
attachValidationListeners(1)
print(config)
let hasError = false
function editData(response) {
  document.querySelector("#input-name-combo").value = response[0].nombre
  document.querySelector("#input-id-combo").value = response[0].id
  document.querySelector("#input-price-combo").value = (response[0].precio).toString().replace(/\./g, ',')
  document.querySelector("#input-category-combo").value = response[0].nombre_categoria
  document.querySelector("#input-category-combo").setAttribute("data-id", response[0].id_categoria)
  document.querySelector("#input-details-combo").value = response[0].detalles
  document.querySelector("#img-combo-response").src = `media/productProcess/${response[0].imagen}`
  document.querySelector("#input-min-combo").value = response[0].stock_min
  document.querySelector("#input-max-combo").value = response[0].stock_max
  let data = {
    nombre: document.querySelector(`#input-name-combo`).value,
    precio: document.querySelector(`#input-price-combo`).value.replace(/\./g, '').replace(',', '.'),
    id_categoria: document.querySelector(`#input-category-combo`).getAttribute("data-id"),
    detalles: document.querySelector(`#input-details-combo`) ? document.querySelector(`#input-details-combo`).value : "",
    min: document.querySelector(`#input-min-combo`).value,
    max: document.querySelector(`#input-max-combo`).value
  }
  const errors = validate(data, rules2);
  if (errors) hasError = true
  setValidationStyles(`input-name-combo`, errors?.nombre ? errors.nombre[0] : null);
  setValidationStyles(`input-price-combo`, errors?.precio ? errors.precio[0] : null);
  setValidationStyles(`input-category-combo`, errors?.id_categoria ? errors.id_categoria[0] : null);
  setValidationStyles(`input-details-combo`, errors?.detalles ? errors.detalles[0] : null);
  setValidationStyles(`input-min-combo`, errors?.min ? errors.min[0] : null);
  setValidationStyles(`input-max-combo`, errors?.max ? errors.max[0] : null);
}
let formEdit = document.getElementById("form-submit-edit-combo")
if (!formEdit.dataset.listenerAttached) {
  formEdit.addEventListener("submit", function (e) {
    e.preventDefault();
    let data = {
      nombre: document.querySelector(`#input-name-combo`).value,
      precio: document.querySelector(`#input-price-combo`).value.replace(/\./g, '').replace(',', '.'),
      imagen: document.querySelector(`#input-image-combo`).files[0],
      id_categoria: document.querySelector(`#input-category-combo`).getAttribute("data-id"),
      detalles: document.querySelector(`#input-details-combo`) ? document.querySelector(`#input-details-combo`).value : "",
      min: document.querySelector(`#input-min-combo`).value,
      max: document.querySelector(`#input-max-combo`).value
    }
    const errors = validate(data, rules3);
    if (errors) hasError = true
    else hasError = false
    setValidationStyles(`input-name-combo`, errors?.nombre ? errors.nombre[0] : null);
    setValidationStyles(`input-price-combo`, errors?.precio ? errors.precio[0] : null);
    setValidationStyles(`input-category-combo`, errors?.id_categoria ? errors.id_categoria[0] : null);
    setValidationStyles(`input-details-combo`, errors?.detalles ? errors.detalles[0] : null);
    setValidationStyles(`input-min-combo`, errors?.min ? errors.min[0] : null);
    setValidationStyles(`input-max-combo`, errors?.max ? errors.max[0] : null);
    setValidationStyles(`input-image-combo`, errors?.imagen ? errors.imagen[0] : null);

    if (!hasError) {
      let datafinal = new FormData()
      datafinal.append("nombre", document.querySelector("#input-name-combo").value)
      datafinal.append("precio", document.querySelector("#input-price-combo").value.replace(/\./g, '').replace(',', '.'))
      datafinal.append("id_categoria", document.querySelector("#input-category-combo").getAttribute("data-id"))
      datafinal.append("detalles", document.querySelector("#input-details-combo").value)
      datafinal.append("id", document.querySelector("#input-id-combo").value)
      datafinal.append("stock_min", document.querySelector("#input-min-combo").value)
      datafinal.append("stock_max", document.querySelector("#input-max-combo").value)
      if (document.querySelector("#input-image-combo").value != "") {
        console.log("object");
        datafinal.append("imagen_name", document.querySelector("#input-image-combo").files[0].name)
        datafinal.append("imagen", document.querySelector("#input-image-combo").files[0])
      }
      update(config, 'productProcess', datafinal, () => nuevaBitacora('Producto procesado', 'Actualizacion', 'Se agrego un producto procesado')
      )
      bootstrap.Modal.getOrCreateInstance('#edit-product').hide()
    }
  })
  form.dataset.listenerAttached = "true";
}