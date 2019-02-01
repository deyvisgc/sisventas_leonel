<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
        <h1><small></small>
        </h1>
        <ol class="breadcrumb">
            <li>
                <a href="<?= base_url() ?>bienvenida"><i class="fa fa-home"></i> Reporte</a>
            </li>
            <li class="active">Movimiento por cliente</li>
        </ol>
    </section>
    <!-- Main content -->
    <section class="content">
        <!-- Your Page Content Here -->
        <div class="row">
            <div class="col-md-12">
                <div class="nav-tabs-custom">
                    <ul class="nav nav-tabs pull-right">
                        <li class="active"><a href="#dv_mov_diario_ingreso" data-toggle="tab" id="a_mov_diario_ingreso">Registro de Clientes</a></li>
                        <li class="pull-left header"><i class="fa fa-chart-line"></i>  <span id="sp_tipo_movimiento">Movimientos por Clientes</span></li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane active" id="dv_mov_diario_ingreso">
                            <div class="row">
                                <div class="row" style="margin: 16px;">
                                    <div class="col-sm-12 table-responsive">
                                        <table class="table table-bordered" id="tb_clients">
                                            <thead>
                                            <tr>
                                                <th class="text-center">RUC</th>
                                                <th class="text-center">Razón Social</th>
                                                <th class="text-center">Movimientos</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section><!-- /.content -->
</div><!-- /.content-wrapper -->

<!--MODAL MOVIMINETO CLIENTES-->
<div class="modal fade" id="modal_movimiento_cliente" tabindex="-1" role="dialog" aria-labelledby="modal_movimiento_cliente" aria-hidden="true" style="overflow-y: scroll;">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <h3 class="modal-title text-center" id="disminuirDeuda">Movimiento de clientes</h3>
            </div>
            <div class="modal-body">
                <section class="content">
                    <!-- Your Page Content Here -->
                    <div class="row">
                        <div class="col-md-12">
                            <div class="nav-tabs-custom">
                                <ul class="nav nav-tabs">
                                    <li class="active"><a href="#dv_compras" data-toggle="tab" id="a_mov_diario_salida">Movimiento de Compras</a></li>
                                    <li><a href="#dv_pagos" data-toggle="tab" id="a_mov_diario_ingreso">Movimiento de Pagos</a></li>
                                    <li class="pull-left header"></span></li>
                                </ul>
                                <div class="tab-content">
                                    <div class="tab-pane active" id="dv_compras">
                                        <hr>
                                        <hr>
                                            <div class="row" style="margin: 16px;">
                                                <div class="col-sm-12 table-responsive">
                                                    <table class="table table-bordered" id="tb_mov_compras">
                                                        <thead>
                                                        <tr>
                                                            <th class="text-center">FECHA</th>
                                                            <th class="text-center">TOTAL</th>
                                                            <th class="text-center">DETALLE COMPRA</th>
                                                        </tr>
                                                        </thead>
                                                        <tbody>
                                                        </tbody>
                                                    </table>
                                                </div>

                                        </div>
                                    </div>

                                    <div class="tab-pane" id="dv_pagos">
                                        <hr>
                                        <hr>

                                        <div class="row" style="margin: 16px;">
                                            <div class="col-sm-12 table-responsive">
                                                <table class="table table-bordered" id="tb_mov_pagos">
                                                    <thead>
                                                        <tr>
                                                            <th class="text-center">FECHA</th>
                                                            <th class="text-center">DESCRIPCIÓN</th>
                                                            <th class="text-center">DEBE</th>
                                                            <th class="text-center">HABER</th>
                                                            <th class="text-center">SALDO</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section><!-- /.content -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-small btn-danger" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Detalle Compras-->
<div class="modal fade" id="detalles_compra" tabindex="-1" role="dialog" aria-labelledby="detalles_compra" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <h1 class="modal-title" id="detalles_compra">Detalle Compra</h1>
            </div>
            <div class="modal-body">
                <div class="row" style="margin: 16px;">
                    <div class="col-sm-12 table-responsive">
                        <table class="table table-bordered" id="tb_detalle_salida">
                            <thead>
                            <tr>
                                <th>PRODUCTO</th>
                                <th>CANTIDAD</th>
                                <th>PRECIO VENTA</th>
                                <th>GANANCIA</th>
                                <th>MONTO</th>
                            </tr>
                            </thead>
                            <tbody>
                            </tbody>
                            <tfoot>
                            <tr>
                                <th colspan="4" class=" alinear_derecha">&nbsp;Total Venta:</th>
                                <th class=" alinear_derecha"><span id="sp_total_salida"></span></th>
                            </tr>
                            </tfoot>
                        </table>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<script>
    var tb;
    function init_movimiento() {
        tb = $('#tb_clients').DataTable({
            'ajax':BASE_URL+'reporte/Mcliente/listarClientes',
            order:([1,'asc']),
            language: {
                "decimal": "",
                "emptyTable": "No hay información",
                "info": "Mostrando _START_ a _END_ de _TOTAL_ Datos",
                "infoEmpty": "Mostrando 0 to 0 of 0 Datos",
                "infoFiltered": "(Filtrado de _MAX_ total datos)",
                "infoPostFix": "",
                "thousands": ",",
                "lengthMenu": "Mostrar _MENU_ Entradas",
                "loadingRecords": "Cargando...",
                "processing": "Procesando...",
                "search": "Buscar: ",
                "zeroRecords": "No se encontraron datos",
                "paginate": {
                      "first": "Primero",
                      "last": "Ultimo",
                      "next": "Siguiente",
                      "previous": "Anterior"
                }
           },
            destroy:true
        });

        var fecha_actual_hoy = get_fhoy();
        $('#in_fecha_ini').val(fecha_actual_hoy);
        $('#in_fecha_fin').val(fecha_actual_hoy);
        $('#in_fecha_ini2').val(fecha_actual_hoy);
        $('#in_fecha_fin2').val(fecha_actual_hoy);
    }

    function Movimiento_Clientes(id_cliente=null){
        tb = $('#tb_mov_compras').DataTable({
            'ajax':BASE_URL+'reporte/Mcliente/listar_compras_x_cliente/'+id_cliente,
            order:([0,'desc']),
            language: {
                "decimal": "",
                "emptyTable": "No hay información",
                "info": "Mostrando _START_ a _END_ de _TOTAL_ Datos",
                "infoEmpty": "Mostrando 0 to 0 of 0 Datos",
                "infoFiltered": "(Filtrado de _MAX_ total datos)",
                "infoPostFix": "",
                "thousands": ",",
                "lengthMenu": "Mostrar _MENU_ Entradas",
                "loadingRecords": "Cargando...",
                "processing": "Procesando...",
                "search": "Buscar: ",
                "zeroRecords": "No se encontraron datos",
                "paginate": {
                    "first": "Primero",
                    "last": "Ultimo",
                    "next": "Siguiente",
                    "previous": "Anterior"
                }
            },
            destroy:true
        });

        $('#tb_mov_pagos').DataTable({
            'ajax':BASE_URL+'reporte/Mcliente/datos_movimiento_pagos_x_cliente/'+id_cliente,
            order:([0,'asc']),
            language: {
                "decimal": "",
                "emptyTable": "No hay información",
                "info": "Mostrando _START_ a _END_ de _TOTAL_ Datos",
                "infoEmpty": "Mostrando 0 to 0 of 0 Datos",
                "infoFiltered": "(Filtrado de _MAX_ total datos)",
                "infoPostFix": "",
                "thousands": ",",
                "lengthMenu": "Mostrar _MENU_ Entradas",
                "loadingRecords": "Cargando...",
                "processing": "Procesando...",
                "search": "Buscar: ",
                "zeroRecords": "No se encontraron datos",
                "paginate": {
                    "first": "Primero",
                    "last": "Ultimo",
                    "next": "Siguiente",
                    "previous": "Anterior"
                }
            },
            destroy:true
        });
    }
    /*FUNCION PARA CARGAR LOS DETALLES DE CADA COMPRA DE ACUERDO AL USUARIO SELECCIONADO*/
    function cargar_detalle_compra(id_salida=null){

        var tab_id = 'tb_detalle_salida';
        var url = BASE_URL+'reporte/mcliente/detalle_compra_x_clientes/'+id_salida;
        var columns = [
            {data:"pro_nombre"},
            {data:"sad_cantidad"},
            {data:"sad_valor"},
            {data:"sad_ganancias"},
            {data:"sad_monto"}
        ];
        generar_tabla_ajx3(tab_id,url,'POST',columns);

        $.ajax({
            type:'POST',
            url:BASE_URL+'reporte/mcliente/detalle_compra_x_clientes_total/'+id_salida,
            dataType:'JSON',
            success:function(datos){
                $('#sp_total_salida').text(datos.sal_monto);
            }
        });
    }

    function generar_tabla_ajx3(id_tabla, url, type, columns) {
        $('#'+id_tabla).DataTable({
            ajax: {
                url: url,
                type: type
            },
            columns: columns,
            "language": {
                "decimal": "",
                "emptyTable": "Tabla vacia.",
                "info": "Mostrando _START_ a _END_ de _TOTAL_ entradas.",
                "infoEmpty": "Mostrando 0 a 0 de 0 entradas.",
                "infoFiltered": "(filtrado de _MAX_ entradas totales)",
                "infoPostFix": "",
                "thousands": ",",
                "lengthMenu": "Mostrar _MENU_ entradas",
                "loadingRecords": "Cargando...",
                "processing": "Procesando...",
                "search": "Buscar: ",
                "zeroRecords": "No se encontraron registros coincidentes.",
                "paginate": {
                    "first": "Primero",
                    "last": "Final",
                    "next": "Siguiente",
                    "previous": "Anterior"
                },
                "aria": {
                    "sortAscending": ": activar para ordenar la columna ascendente.",
                    "sortDescending": ": activar para ordenar la columna descendente."
                }
            },
            destroy:true
        });
    }

</script>
