# Plan de Refactorización JavaScript

## Objetivo
1. Consolidar validators y reglas de validación en `Validaciones.js`
2. Actualizar archivos JS para usar paginación del servidor (como `binnacle.js`)

---

## PARTE 1: Validación

### 1.1 validators ya añadidos a Validaciones.js
- [x] fileType
- [x] numero
- [x] precio
- [x] cantidad
- [x] number
- [x] validateTD
- [x] stockValidator
- [x] validateCategoryAndRecipe
- [x] validateCategoryAndUnit
- [x] validateRecipe

### 1.2 Reglas ya creadas en Validaciones.js
- [x] r.nombre (para nombres cortos)
- [x] r.nombreLargo (para nombres de 4+ caracteres)
- [x] r.sillas
- [x] r.imagen
- [x] reglas_validaciones para todos los campos

### 1.3 Archivos ya actualizados con if(errors) correcto
- [x] client.js
- [x] supplier.js
- [x] units.js
- [x] table.js

### 1.4 Archivos pendientes de validar (if(errors))

**categoryRawMaterial.js:**
- [ ] Líneas 121, 149, 161 - cambiar `if (errors)` por `if (errors.nombre)`
- [ ] Importar set_validaciones y reglas_validaciones

**categoryCombo.js:**
- [ ] Líneas 123, 150, 162 - cambiar `if (errors)` por `if (errors.nombre)`
- [ ] Importar set_validaciones y reglas_validaciones

**additional.js:**
- [ ] Líneas 236, 272, 291 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**payment.js:**
- [ ] Líneas 122, 149, 161 - cambiar `if (errors)` por `if (errors.nombre)`
- [ ] Importar set_validaciones y reglas_validaciones

**permissions.js:**
- [ ] Líneas 349, 375, 390 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**permisos.js:**
- [ ] Línea 107 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**profile.js:**
- [ ] Línea 350 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**capital.js:**
- [ ] Línea 60 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**recipe.js:**
- [ ] Líneas 118, 304 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**raw_material.js:**
- [ ] Línea 270 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**raw-material/entrys.js:**
- [ ] Líneas 821, 838, 1075, 1091, 1132, 1155, 1182 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**productProcess.js:**
- [ ] Líneas 406, 451, 473 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**productProcess/entrys.js:**
- [ ] Líneas 781, 798, 1013, 1036, 1063 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**productPrepared.js:**
- [ ] Líneas 275, 317, 336 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**package_reservation.js:**
- [ ] Líneas 146, 260 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**order/domicile_and_takeaway.js:**
- [ ] Líneas 437, 442 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**order/local.js:**
- [ ] Líneas 1093, 1099 - cambiar `if (errors)` por [ ] Importar campos específicos
- set_validaciones y reglas_validaciones

**order/reservationOrder.js:**
- [ ] Línea 169 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**calendar/addReservation.js:**
- [ ] Líneas 112, 161 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

**calendar/editReservation.js:**
- [ ] Línea 570 - cambiar `if (errors)` por campos específicos
- [ ] Importar set_validaciones y reglas_validaciones

---

## PARTE 2: Paginación del Servidor

### 2.1 Ejemplo de referencia: binnacle.js
```javascript
let table = $('.table_name').DataTable({
    processing: true,
    serverSide: true,
    pageLength: 10,
    ajax: function (data, callback, settings) {
        let page = Math.floor(data.start / data.length);
        let size = data.length;
        // obtener total
        let totalRaw = myfecth("endpoint/count", {}, filtros, null, 'POST');
        let total = JSON.parse(totalRaw) || 0;
        
        fetch(`endpoint/get_all/${page}/${size}/id/asc`, {
            method: 'POST',
            body: formData,
        })
        .then(res => res.json())
        .then(resp => {
            callback({
                draw: data.draw,
                data: resp.data || resp || [],
                recordsTotal: total,
                recordsFiltered: total
            });
        });
    },
    columns: [...]
});
```

### 2.2 Archivos que necesitan paginación del servidor

**units.js** - DataTable actual: línea 9
**raw_material.js** - DataTable actual: línea 16
**recipe.js** - DataTable actual: línea 167
**payment.js** - DataTable actual: línea 8
**categoryRawMaterial.js** - DataTable actual: línea 7
**categoryCombo.js** - DataTable actual: línea 9
**additional.js** - DataTable actual: línea 18
**capital.js** - DataTable actual: línea 10

---

## Pasos de Ejecución

1. **Ejecutar validación** - Corregir `if (errors)` en cada archivo
2. **Ejecutar paginación** - Convertir DataTables a serverSide
3. **Verificar** - Probar que todo funcione correctamente
