<!-- modal para agg categorias -->
<div class="modal fade p-0" id="registrar_categoria_producto" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog  modal-dialog-scrollable modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="exampleModalLabel">Registrar Categoria (Combo)</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form class="row g-2" id="formulario_enviar_categoria_producto">
                    <div id="contenedor_categorias_producto">
                        <div class="row g-2 categoria_producto" id="categoria_producto-1">
                            <div class="col-md-12">
                                <label for="inputEmail4" class="form-label">Nombre</label>
                                <input type="text" class="form-control" placeholder="Nombre" id="input_nombre_categoria_producto-1" name="nombre">
                                <div class="text-danger mt-1 fs-6" id="error-input_nombre_categoria_producto-1"></div>
                            </div>
                        </div>
                    </div>
                    <input type="submit" class="d-none" id="enviar_categoria_producto">
                    <button type="button" id="btn_agregar_categoria_producto" class="btn btn-secondary mt-3">Agregar categoria</button>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn bh_5 text-white" data-bs-dismiss="modal">Cancelar</button>
                <label for="enviar_categoria_producto" class="btn bh_1 text-white">Guardar</label>
            </div>
        </div>
    </div>
</div>

<!-- modal para agg categorias -->
<div class="modal fade p-0" id="editar_categoria_producto" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog  modal-dialog-scrollable modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="exampleModalLabel">Editar Categoria (Combo)</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form class="row g-2" id="formulario_editar_categoria_producto">
                    <div id="contenedor_categoria_producto_editar">
                        <div class="row g-2 categoria_producto" id="categoria_producto_editar">
                            <input type="hidden" id="input_id_categoria_producto">
                            <div class="col-md-12">
                                <label for="inputEmail4" class="form-label">Nombre</label>
                                <input type="text" class="form-control" placeholder="Nombre" id="input_nombre_categoria_producto_editar" name="nombre">
                                <div class="text-danger mt-1 fs-6" id="error-input_nombre_categoria_producto_editar"></div>
                            </div>
                        </div>
                    </div>
                    <input type="submit" class="d-none" id="enviar_categoria_producto_editar">
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn bh_5 text-white" data-bs-dismiss="modal">Cancelar</button>
                <label for="enviar_categoria_producto_editar" class="btn bh_1 text-white">Guardar</label>
            </div>
        </div>
    </div>
</div>