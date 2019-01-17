<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
        <h1>
            Reporte de Efectivo<small></small>
        </h1>
        <ol class="breadcrumb">
            <li>
                <a href="<?= base_url() ?>bienvenida"><i class="fa fa-home"></i> Home</a>
            </li>
            <li class="active">Reporte de efectivo.</li>
        </ol>
    </section>
    <!-- Main content -->
    <section class="content">
        <!-- Your Page Content Here -->
        <div class="row">
            <div class="col-md-12">
                <div class="nav-tabs-custom">
                    <ul class="nav nav-tabs pull-right">
                        <li class="active"><a href="#dv_mov_diario_ingreso" data-toggle="tab" id="a_mov_diario_ingreso">Efectivo en caja</a></li>
                        <li class="pull-left header"><i class="fa fa-chart-line"></i> Reportes de <span id="sp_tipo_movimiento">Efectivo.</span></li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane active" id="dv_mov_diario_ingreso">
                            <div class="row">
                                <div class="form-group">
                                    <label for="" class="col-sm-2 control-label">FECHA INICIO</label>
                                    <div class="col-sm-3">
                                        <input type="date" id="date_ini" name="fecha_ini" class="form-control" value="" placeholder="Fecha inicio">
                                    </div>
                                    <label for="" class="col-sm-2 control-label">FECHA FIN</label>
                                    <div class="col-sm-3">
                                        <input type="date" id="date_fin" name="fecha_fin" class="form-control" value="" placeholder="Fecha fin">
                                    </div>
                                </div>
                                <br>
                                <hr>
                                <div class="form-group">
                                    <div class="col-sm-3">
                                        <button type="button" class="btn btn-primary" onclick="filtrar_movimiento_diario_salida();" id="btn_filtrar"><i class="fa fa-check-circle"></i> Filtar por Fecha</button>
                                    </div>
                                </div>
                                <br>
                                <br>
                                <hr>
                                <div class="row" style="margin: 16px;">
                                    <div class="col-sm-12 box-body table-responsive">
                                        <table class="table table-bordered" id="tb_efectivo">
                                            <thead>
                                            <tr>
                                                <th>FECHA</th>
                                                <th>CLIENTE</th>
                                                <th>DOC.</th>
                                                <th>NRO.</th>
                                                <th>S/. VENTA</th>
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
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section><!-- /.content -->
</div><!-- /.content-wrapper -->
<script>
    function init_deuda() {
        var fecha_actual_hoy = get_fhoy();
        $('#date_ini').val(fecha_actual_hoy);
        $('#date_fin').val(fecha_actual_hoy);

        var mov_diario_id_tabla2 = "tb_efectivo";
        var mov_diario_url2 = "<?php echo base_url(); ?>reporte/efectivo/Caja/movimiento_efectivo";
        var mov_diario_dataSrc2 = function(res){
            $('#sp_total_salida').text(res.data_totales.sal_monto);
            return res.data;
        }
        var mov_diario_data2 = function() {
            var data = {};
            data.fecha_ini = $("#date_ini").val();
            data.fecha_fin = $("#date_fin").val();
            return data;
        };
        var mov_diario_columns2 = [
            {data: "sal_fecha_registro"},
            {data: "emp_razon_social"},
            {data: "tdo_nombre"},
            {data: "sal_numero_doc_cliente"},
            {data: "sal_monto", className: "alinear_derecha"}
        ];
        generar_tabla_ajx3(mov_diario_id_tabla2, mov_diario_url2, 'POST', mov_diario_data2, mov_diario_dataSrc2, mov_diario_columns2);

    }
    function generar_tabla_ajx3(id_tabla, url, type, data, dataSrc, columns) {
        $('#'+id_tabla).DataTable({
            dom: 'Bfrtip',
            buttons: [
                {
                    extend: 'print',
                    text: 'Imprimir'
                }
            ],
            ajax: {
                url: url,
                type: type,
                data: data,
                dataSrc: dataSrc
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
                "search": "Buscar",
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
            }

        });
    }
    function filtrar_movimiento_diario_salida() {
        $('#tb_efectivo').DataTable().ajax.reload();
    }
</script>