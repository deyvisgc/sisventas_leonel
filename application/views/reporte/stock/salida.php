<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>

<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
        <h1>
<small></small>
        </h1>
        <ol class="breadcrumb">
            <li>
                <a href="<?= base_url() ?>bienvenida"><i class="fa fa-home"></i> Home</a>
            </li>
            <li class="active">Salida de Productos.</li>
        </ol>
    </section>
    <!-- Main content -->
    <section class="content">
        <!-- Your Page Content Here -->
        <div class="row">
            <div class="col-md-12">
                <div class="nav-tabs-custom">
                    <ul class="nav nav-tabs pull-right" style="background-color: #00ca6d">
                        <li class="active" ><a href="#dv_general" data-toggle="tab" id="a_general">Productos</a></li>
                        <li class="pull-left header" style="color: white;"><i class="fa fa-shopping-basket" style="color: white;"></i> Salida de Productos</li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane active" id="dv_general">
                            <div class="form-group col-md-4">
                                <div class="input-group">
                                    <span class="input-group-addon bg-gray ">Desde: </span>
                                    <input type="date" id="fecha_ini" name="fecha_ini" class="form-control" value="" placeholder="Fecha inicio">
                                </div>
                            </div>
                            <div class="form-group col-md-4" >
                                <div class="input-group">
                                    <span class="input-group-addon bg-gray">Hasta: </span>
                                    <input type="date" id="fecha_fin" name="fecha_fin" class="form-control" value="" placeholder="Fecha fin">
                                </div>
                            </div>
                            <div class="form-group col-md-4 text-center" >
                                <div class="input-group">
                                    <button class="btn btn-facebook btn-md" type="button" onclick="filtrar_movimiento_diario_salida();"><i class="fa fa-calendar-alt"></i> Filtrar </button>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-12 table-responsive">
                                    <p></p>
                                    <table class="table table-bordered" id="tb_salida_productos" style="width: 100%;">
                                        <thead>
                                        <tr>
                                            <th class="text-center">FECHA</th>
                                            <th class="text-center">PRODUCTO</th>
                                            <th class="text-center">CANTIDAD</th>
                                            <th class="text-center">MONTO</th>
                                        </tr>
                                        </thead>
                                        <tbody class="text-center">
                                        </tbody>
                                        <tfoot>
                                        <tr>
                                            <th colspan="3" class=" alinear_derecha">&nbsp;Total</th>
                                            <th class="text-center text-bold"><span id="total_cantidad">00.00</span></th>
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
    </section><!-- /.content -->
</div><!-- /.content-wrapper -->

<script>
    function init_salida_produccion() {
        var fecha_actual_hoy = get_fhoy();
        fecha1=	$('#fecha_ini').val(fecha_actual_hoy);
        fecha2=	$('#fecha_fin').val(fecha_actual_hoy);




        var general_id_tabla = "tb_salida_productos";
        var general_url = "<?php echo base_url(); ?>reporte/salida/Cargar_Productos_Salida";
        var general_data = function() {
            var data = {};
            data.fecha_ini = $("#fecha_ini").val();
            data.fecha_fin = $("#fecha_fin").val();
            return data;
        };;
        var general_dataSrc = function (res) {
            $('#total_cantidad').text(res.data_totales.monto);
            return res.data;
        };
        var general_columns = [
            {data: "pro_fecha"},
            {data: "pro_nombre"},
            {data: "pro_cantidad"},
            {data: "pro_monto"}
        ];



        generar_tabla2(general_id_tabla, general_url, general_data, general_dataSrc, general_columns);
    }

    function generar_tabla2(id_tabla, url, data, dataSrc, columns) {
        $('#' + id_tabla).DataTable({
            dom: 'Bfrtip',
            buttons: [
                {
                    extend: 'print',
                    text: 'Imprimir'
                }
            ],
            ajax: {
            url: url,
                type: "POST",
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
        $('#tb_salida_productos').DataTable().ajax.reload();
    }
</script>
