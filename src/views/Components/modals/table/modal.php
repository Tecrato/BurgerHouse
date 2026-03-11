<!-- modal para agg mesas -->
<div class="modal fade p-0" id="registrar_mesa" tabindex="-1">
    <div class="modal-dialog modal-fullscreen modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="exampleModalLabel">Registrar Mesas</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="formulario_enviar_mesas">
                    <div id="contenedor_mesas">
                        <div class="row g-2 mesa" id="mesa-1">
                            <h4>Mesa 1</h4>
                            <div class="col-md-3">
                                <label for="inputEmail4" class="form-label">Nombre</label>
                                <input type="text" class="form-control" placeholder="Nombre" id="input_nombre_mesa" name="nombre">
                                <div class="text-danger mt-1 fs-6" id="error-input_nombre_mesa"></div>
                            </div>
                            <div class="col-md-3">
                                <label for="inputEmail4" class="form-label">Nro de sillas</label>
                                <input type="number" class="form-control" placeholder="Nro de sillas" id="input_numero_sillas_mesa" name="sillas">
                                <div class="text-danger mt-1 fs-6" id="error-input_numero_sillas_mesa"></div>
                            </div>
                            <div class="col-md-1">
                                <label for="inputAddress2" class="form-label">VIP</label>
                                <br>
                                <input type="checkbox" class="btn-check" id="input_vip_mesa" autocomplete="off" name="vip">
                                <label class="btn btn-outline-primary w-100" for="input_vip_mesa">VIP</label><br>
                                <div class="text-danger mt-1 fs-6" id="error-input_vip_mesa"></div>
                            </div>
                            <div class="col-md-5">
                                <label for="inputZip" class="form-label">Imagen</label>
                                <input class="form-control input-image" type="file" id="input_imagen_mesa" name="imagen">
                                <div class="text-danger mt-1 fs-6" id="error-input_imagen_mesa"></div>
                            </div>
                            <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
                        </div>
                    </div>
                    <input type="submit" class="d-none" id="enviar_mesas">
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn bh_5 text-white" data-bs-dismiss="modal">Cancelar</button>
                <label for="enviar_mesas" class="btn bh_1 text-white">Guardar</label>
            </div>
        </div>
    </div>
</div>


<!-- modal para editar mesas -->
<div class="modal fade p-0" id="editar_mesa" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="exampleModalLabel">Editar Mesa</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="formulario_editar_mesa">
                    <div id="contenedor_mesa_editar">
                        <input type="hidden" id="input_id_mesa">
                        <div class="row g-2 mesa" id="mesa_editar">
                            <div class="col-md-6">
                                <label for="inputEmail4" class="form-label">Nombre</label>
                                <input type="text" class="form-control" placeholder="Nombre" id="input_nombre_mesa_editar" name="nombre">
                                <div class="text-danger mt-1 fs-6" id="error-input_nombre_mesa_editar"></div>
                            </div>
                            <div class="col-md-6">
                                <label for="inputEmail4" class="form-label">Nro de sillas</label>
                                <input type="number" class="form-control" placeholder="Nro de sillas" id="input_numero_sillas_mesa_editar" name="sillas">
                                <div class="text-danger mt-1 fs-6" id="error-input_numero_sillas_mesa_editar"></div>
                            </div>
                            <div class="col-md-2">
                                <label for="inputAddress2" class="form-label">VIP</label>
                                <br>
                                <input type="checkbox" class="btn-check" id="input_vip_mesa_editar" autocomplete="off" name="vip">
                                <label class="btn btn-outline-primary w-100" for="input_vip_mesa_editar">VIP</label><br>
                                <div class="text-danger mt-1 fs-6" id="error-input_vip_mesa_editar"></div>
                            </div>
                            <div class="col-md-10">
                                <label for="inputZip" class="form-label">Imagen</label>
                                <input class="form-control input-image" type="file" id="input_imagen_mesa_editar" name="imagen">
                                <div class="text-danger mt-1 fs-6" id="error-input_imagen_mesa_editar"></div>
                            </div>
                            <img id="img_mesa_respuesta" class="mt-3" src="" alt="Vista previa" style="max-width: 200px;">
                        </div>
                    </div>
                    <input type="submit" class="d-none" id="enviar_mesa_editar">
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn bh_5 text-white" data-bs-dismiss="modal">Cancelar</button>
                <label for="enviar_mesa_editar" class="btn bh_1 text-white">Guardar</label>
            </div>
        </div>
    </div>
</div>