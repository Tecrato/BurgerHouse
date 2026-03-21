import functionGeneral from "../../Functions.js";
import { myfecth, sessionInfo } from "../../Functions2.js";
const { permission } = functionGeneral()
let [session, permisos] = sessionInfo();
permission("Mantenimiento")

document.body.addEventListener("click", (e) => {
    const btn = e.target.closest(".btn_export");
    if (btn) {
        Swal.fire({
            title: "¿Deseas hacer una copia de seguridad?",
            icon: "warning",
            showCancelButton: true,
            confirmButtonText: "Si, quiero hacerla",
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
                let type = btn.getAttribute("data-id")
                let db = btn.getAttribute("data-db")
                data.append("route", type);
                data.append("db", db);
                let response = myfecth(`mantenimiento/export`, {}, data).json();
                if (response.success == true) {
                    Swal.close();
                    Swal.fire({
                        title: "Exito!",
                        text: "La copia de seguridad se realizo correctamente",
                        icon: "success",
                        confirmButtonColor: "#FF4B00",
                    })
                    table_backup_system.ajax.reload();
                    table_backup_user.ajax.reload();
                } else {
                    Swal.close();
                    Swal.fire({
                        title: "Error!",
                        text: "La copia de seguridad no se realizo correctamente",
                        icon: "error",
                        confirmButtonColor: "#FF4B00",
                    })
                }
            }
        });
    }
})

let table_backup_system = $('.table_db_backup_system').DataTable({
    order: [[0, "desc"]],
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    ajax: {
        url: 'mantenimiento/search',
        data: { route: "system" },
        dataSrc: function (json) {
            return JSON.parse(json);
        },
        type: 'POST',
    },
    columns: [
        { data: 'id' },
        { data: 'name' },
        {
            data: null, render: function (data, type, row) {
                return `
            <a data-id="${row.name}" data-bs-toggle="tooltip" data-module-delete="Mantenimiento" data-bs-title="Eliminar" class="btn bh_1 rounded-circle btn-circle text-white"><i data-feather="trash-2"></i></a>
            <a data-id="${row.name}" data-bs-toggle="tooltip" data-module-import="Mantenimiento" data-bs-title="Importar" class="btn bh_5 rounded-circle btn-circle text-white"><i data-feather="download"></i></a>
            `
            }
        }
    ],
    drawCallback: function (settings) {
        document.querySelectorAll(".btn-circle").forEach((btn) => {
            const tooltip = new bootstrap.Tooltip(btn);
        })
        document.querySelectorAll("[data-bs-title]").forEach((btn) => {
            btn.addEventListener("click", async (e) => {
                Swal.fire({
                    title: "Ingrese su contraseña",
                    html: `
    <form autocomplete="off" onsubmit="return false;">
      <input id="swal-input-password" type="password" placeholder="Contraseña" class="form-control" autocomplete="new-password" autocapitalize="off" autofocus />
    </form>
  `,
                    focusConfirm: false,
                    showCancelButton: true,
                    cancelButtonText: "Cancelar",
                    confirmButtonColor: "#FF4B00",
                    confirmButtonText: "Comprobar",
                    showLoaderOnConfirm: true,
                    preConfirm: async () => {

                        const password = document.getElementById("swal-input-password").value;
                        const type = btn.getAttribute("data-bs-title");
                        const id = btn.getAttribute("data-id");
                        const data = new FormData();

                        if (type === "Eliminar") {
                            data.append("password", password);
                            data.append("id", session.message.id);
                            data.append("archive", id);
                            data.append("route", "system");
                            let response = myfecth(`maintenance/delete`, {}, data).json();
                            return response;
                        } else {
                            data.append("password", password);
                            data.append("id", session.message.id);
                            data.append("archive", id);
                            data.append("route", "system");
                            data.append("db", "agenda");
                            let response = myfecth(`mantenimiento/import`, {}, data).json();
                            return response;
                        }
                    },
                    allowOutsideClick: () => !Swal.isLoading()
                }).then((result) => {
                    if (result.isConfirmed) {
                        console.log(result);
                        if (result.value.success == true) {
                            Swal.fire({
                                title: `Exito!`,
                                text: "Base de datos restaurada correctamente",
                                icon: "success",
                            });
                            table_backup_system.ajax.reload();
                        } else {
                            Swal.fire({
                                title: `Error!`,
                                text: result.value.message,
                                icon: "error",
                            });
                        }
                    }
                });

            })
        })
        feather.replace();
        permission("Mantenimiento")
    },
    "dom": 'tipr',
    "paging": true,
    "info": true,
});
let table_backup_user = $('.table_db_backup_users').DataTable({
    order: [[0, "desc"]],
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    ajax: {
        url: 'mantenimiento/search',
        data: { route: "users" },
        dataSrc: function (json) {
            return JSON.parse(json);
        },
        type: 'POST',
    },
    columns: [
        { data: 'id' },
        { data: 'name' },
        {
            data: null, render: function (data, type, row) {
                return `
            <a data-id="${row.name}" data-bs-toggle="tooltip" data-module-delete="Mantenimiento" data-bs-title="Eliminar" class="btn bh_1 rounded-circle btn-circle text-white"><i data-feather="trash-2"></i></a>
            <a data-id="${row.name}" data-bs-toggle="tooltip" data-module-import="Mantenimiento" data-bs-title="Importar" class="btn bh_5 rounded-circle btn-circle text-white"><i data-feather="download"></i></a>
            `
            }
        }
    ],
    drawCallback: function (settings) {
        document.querySelectorAll(".btn-circle").forEach((btn) => {
            const tooltip = new bootstrap.Tooltip(btn);
        })
        document.querySelectorAll("[data-bs-title]").forEach((btn) => {
            btn.addEventListener("click", async (e) => {
                Swal.fire({
                    title: "Ingrese su contraseña",
                    html: `
    <form autocomplete="off" onsubmit="return false;">
      <input id="swal-input-password" type="password" placeholder="Contraseña" class="form-control" autocomplete="new-password" autocapitalize="off" autofocus />
    </form>
  `,
                    focusConfirm: false,
                    showCancelButton: true,
                    cancelButtonText: "Cancelar",
                    confirmButtonColor: "#FF4B00",
                    confirmButtonText: "Comprobar",
                    showLoaderOnConfirm: true,
                    preConfirm: async () => {
                        const password = document.getElementById("swal-input-password").value;
                        const type = btn.getAttribute("data-bs-title");
                        const id = btn.getAttribute("data-id");
                        const data = new FormData();

                        if (type === "Eliminar") {
                            data.append("password", password);
                            data.append("id", session.message.id);
                            data.append("archive", id);
                            data.append("route", "users");
                            let response = myfecth(`mantenimiento/delete`, {}, data).json();
                            return response;
                        } else {
                            data.append("password", password);
                            data.append("id", session.message.id);
                            data.append("archive", id);
                            data.append("route", "users");
                            data.append("db", "agenda");
                            let response = myfecth(`mantenimiento/import`, {}, data).json();
                            return response;
                        }
                    },
                    allowOutsideClick: () => !Swal.isLoading()
                }).then((result) => {
                    if (result.isConfirmed) {
                        if (result.value.success == true) {
                            Swal.fire({
                                title: `Exito!`,
                                text: "Base de datos restaurada correctamente",
                                icon: "success",
                            });
                            table_backup_system.ajax.reload();
                        } else {
                            Swal.fire({
                                title: `Error!`,
                                text: result.value.message,
                                icon: "error",
                            });
                        }
                    }
                });

            })
        })
        feather.replace();
        permission("Mantenimiento")
    },
    "dom": 'tipr',
    "paging": true,
    "info": true,
});

$('#searchBackupSystem').on('keyup', function () { table_backup_system.search(this.value).draw() });
$('#searchBackupUser').on('keyup', function () { table_backup_user.search(this.value).draw() });