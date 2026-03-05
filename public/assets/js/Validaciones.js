// Acceder a validate desde window (cargado como script clásico en el HTML)
const validate = window.validate;

// Inicializar validators personalizados cuando se llame a set_validaciones
export function set_validaciones(){
    validate.validators.nombreValidator = function (value, options, key, attributes) {
        if (!value) return;
        if (!/^[A-Z]+/.test(value)) {
            return options.uppercaseMessage;
        }
        if (/\d/.test(value)) {
            return options.noNumber;
        }
        if (!/^[A-Za-z0-9\s]*$/.test(value)) {
            return options.specialCharMessage;
        }
        if (/\s{2,}/.test(value)) {
            return options.noDoubleSpace;
        }
    };
    validate.validators.validateID = function (value, options, key, attributes) {
        if (!value || value.toLowerCase() === "seleccione una opcion") {
            return options.message || "es requerido";
        }
        if (!/\d*/.test(value)) {
            return options.noNumber;
        }
    };
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
    validate.validators.email = function (value, options, key, attributes) {
        if (!value) return;
        if (!/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(value)) {
            return options.validateEmail
        }
    }
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
    validate.validators.numero = function (value, options, key, attributes) {
        if (!value) return;
        const num = parseFloat(value);
        if (isNaN(num) || num <= 0) {
            return options.message || "^debe ser un número mayor a 0";
        }
    };
    validate.validators.precio = function (value, options, key, attributes) {
        if (!value) return;
        const num = parseFloat(value);
        if (isNaN(num) || num <= 0) {
            return options.message || "^debe ser un número mayor a 0";
        }
    };
    validate.validators.cantidad = function (value, options, key, attributes) {
        if (!value) return;
        const num = parseFloat(value);
        if (isNaN(num) || num <= 0) {
            return options.message || "^debe ser mayor a 0";
        }
    };
    validate.validators.number = function (value, options, key, attributes) {
        if (!value) return;
        const num = parseFloat(value);
        if (isNaN(num)) {
            return options.message || "^debe ser un número";
        }
    };
    validate.validators.stockValidator = function (value, options, key, attributes) {
        if (!value) return;
        const num = parseFloat(value);
        if (isNaN(num) || num < 0) {
            return options.message || "^debe ser 0 o mayor";
        }
    };

}

const r = {
    nombre:{
        nombreValidator: {
            uppercaseMessage: "^debe tener la primera letra en mayúscula.",
            specialCharMessage: "^No se permiten signos como puntos (.) o comas (,).",
            noDoubleSpace: "^No se permiten espacios dobles",
            noNumber: "^No se permiten números"
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
    nombreLargo:{
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
    sillas: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        numero: { message: "^debe ser un número mayor a 0" }
    },
    imagen: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        fileType: {
            types: ['jpeg', 'png', 'webp', 'jpg']
        }
    },
    id_: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        validateID: {
            message: "^es requerido",
            noNumber: "El elemento no es un numero"
        }
    }
}

export const reglas_validaciones = {
    // Regla común para todos los IDs
    id_rol: r.id_,
    id_materia_prima: r.id_,
    id_producto: r.id_,
    id_categoria: r.id_,
    id_metodo_pago: r.id_,
    id_rawmaterial: r.id_,




    nombre: r.nombre,
    apellido: r.nombre,
    nombreLargo: r.nombreLargo,
    sillas: r.sillas,
    imagen: r.imagen,
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
        email: {
            validateEmail: "^El correo electrónico no es válido"
        }
    },
    // Reglas adicionales para otros módulos
    telefono: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        }
    },
    direccion: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        }
    },
    precio: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        precio: { message: "^debe ser un número mayor a 0" }
    },
    descripcion: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        }
    },
    alias: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        }
    },
    documento: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        format: {
            pattern: "^[0-9]+$",
            message: "^solo puede tener números"
        }
    },
    rif: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        format: {
            pattern: "^[0-9]+$",
            message: "^solo puede tener números"
        }
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
        }
    },
    tipo_documento: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        }
    },
    cantidad: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        cantidad: { message: "^debe ser mayor a 0" }
    },
    codigo: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        }
    },
    monto: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        precio: { message: "^debe ser un monto mayor a 0" }
    },
    imagen: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        fileType: {
            types: ['jpeg', 'png', 'webp', 'jpg']
        }
    },
}

// Exportar validate para que esté disponible en otros módulos
export { validate };