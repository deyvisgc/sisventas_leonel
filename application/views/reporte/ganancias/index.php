<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<div class="content-wrapper">
	<!-- Content Header (Page header) -->
	<section class="content-header">
		<h1><small></small>
		</h1>
		<ol class="breadcrumb">
			<li>
				<a href="<?= base_url() ?>bienvenida"><i class="fa fa-home"></i> Home</a>
			</li>
			<li class="active">Reporte Ganancias.</li>
		</ol>
	</section>
	<!-- Main content -->
	<section class="content">
		<!-- Your Page Content Here -->
		<div class="row">
			<div class="col-md-12">
				<div class="nav-tabs-custom">
					<ul class="nav nav-tabs pull-right" style="background-color: #ffb40f;">
                        <li style="color: white;"><a href="#dv_productos_agrupados" data-toggle="tab" id="dv_productos_agrupado">Productos Agrupados</a></li>
                        <li class="active" style="color: white;"><a href="#dv_mov_diario_ingreso" data-toggle="tab" id="dv_producto_desagrupado">Productos Desagrupados</a></li>
                        <li class="pull-left header" style="color: white;"><i class="fa fa-chart-line"></i>  <span id="sp_tipo_movimiento">Reporte de Ganancias por Producto</span></li>
                    </ul>
                    <br>
					<div class="tab-content">
						<div class="tab-pane active" id="dv_mov_diario_ingreso">
							<div class="row">
								<div class="form-group">
                                    <div class="row" style="margin-left: 20px;">
                                        <label for="" class="col-sm-2 col-lg-2 control-label">FECHA INICIO</label>
                                        <div class="col-sm-3">
                                            <input type="date" id="in_fecha_ini" name="fecha_ini" class="form-control" value="" placeholder="Fecha inicio">
                                        </div>
                                        <label for="" class="col-sm-1 col-lg-2 control-label">FECHA FIN</label>
                                        <div class="col-sm-3">
                                            <input type="date" id="in_fecha_fin" name="fecha_fin" class="form-control" value="" placeholder="Fecha fin">
                                        </div>

                                        <div class="form-group">
                                            <div class="col-sm-2">
                                                <button type="button" class="btn btn-primary" onclick="filtrar_fecha_ganancias();" id="btn-altas"><i class="fa fa-calendar"></i> Filtar por Fecha</button>
                                            </div>
                                        </div>
                                    </div>
                                    <hr>
								</div>
                                <div class="form-group col-md-12">
                                    <button type="button" class="btn btn-facebook pull-right" onclick="imprimir_desagrupados();"><i class="fa fa-print"></i> IMPRIMIR </button>
                                </div>
                                <div id="imprimir_desagrupados">
                                    <div class="row" style="margin: 16px;">
                                        <div class="col-sm-12 table-responsive">
                                            <table class="table table-bordered" id="tb_reporte_ganancia">
                                                <caption id="titulo" hidden>REPORTE DE GANANCIAS POR PRODUCTO</caption><br><br>
                                                <thead>
                                                <tr>
                                                    <th>N° DOCUMENTO</th>
                                                    <th>CLIENTE</th>
                                                    <th>FECHA</th>
                                                    <th>PRODUCTO</th>
                                                    <th>CANTIDAD</th>
                                                    <th>PRECIO</th>
                                                    <th>GANANCIA</th>
                                                </tr>
                                                </thead>
                                                <tbody id="cabecera">
                                                </tbody>
                                                <tfoot id="pie">
                                                <tr>
                                                    <th colspan="6" class=" alinear_derecha">&nbsp;Total Ganancias:</th>
                                                    <th class=" alinear_derecha"><span id="sp_total_ingreso"></span></th>
                                                </tr>
                                                </tfoot>
                                            </table>
                                        </div>
                                    </div>
                                </div>
							</div>
						</div>
                        <div class="tab-pane" id="dv_productos_agrupados">
                            <div class="row">
                                <div class="form-group">
                                    <div class="row" style="margin-left: 20px;">
                                        <label for="" class="col-sm-2 col-lg-2 control-label">FECHA INICIO</label>
                                        <div class="col-sm-3">
                                            <input type="date" id="in_fecha_ini2" name="fecha_ini2" class="form-control" value="" placeholder="Fecha inicio">
                                        </div>
                                        <label for="" class="col-sm-1 col-lg-2 control-label">FECHA FIN</label>
                                        <div class="col-sm-3">
                                            <input type="date" id="in_fecha_fin2" name="fecha_fin2" class="form-control" value="" placeholder="Fecha fin">
                                        </div>

                                        <div class="form-group">
                                            <div class="col-sm-2">
                                                <button type="button" class="btn btn-primary" onclick="filtrar_fecha_ganancias_agrupados();" id="btn-altas"><i class="fa fa-calendar"></i> Filtar por Fecha</button>
                                            </div>
                                        </div>
                                    </div>
                                    <br>
                                    <hr>
                                </div>
                                <div class="form-group col-md-12">
                                    <button type="button" class="btn btn-facebook pull-right" onclick="imprimir();"><i class="fa fa-print"></i> IMPRIMIR </button>
                                </div>
                                <div id="imprimir_agrupado">
                                    <div class="row" style="margin: 0px 16px 16px 16px;">
                                        <div class="col-sm-12 table-responsive">
                                            <table class="table table-bordered" id="tb_reporte_ganancia_agrupado" style="width: 100%">
                                                <caption id="titulo2" hidden>REPORTE DE GANANCIAS POR PRODUCTO</caption><br><br>
                                                <thead>
                                                <tr>
                                                    <th>PRODUCTO</th>
                                                    <th>CANTIDAD</th>
                                                    <th>PRECIO</th>
                                                    <th>MONTO VENTA</th>
                                                    <th>GANANCIA</th>
                                                </tr>
                                                </thead>
                                                <tbody id="cabecera">
                                                </tbody>
                                                <tfoot id="pie">
                                                <tr>
                                                    <th colspan="4" class=" alinear_derecha">&nbsp;Total Ganancias:</th>
                                                    <th class=" alinear_derecha"><span id="sp_total_ingreso2"></span></th>
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
		</div>
	</section><!-- /.content -->
</div><!-- /.content-wrapper -->

<script>

	function init_ganancias() {
		$('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
			var target = $(e.target).attr("href");
			if(target === '#dv_mov_diario_salida') {
				$('#tb_reporte_ganancia').DataTable().ajax.reload();
			}
		});
		var fecha_actual_hoy = get_fhoy();
		$('#in_fecha_ini').val(fecha_actual_hoy);
		$('#in_fecha_fin').val(fecha_actual_hoy);
		$('#in_fecha_ini2').val(fecha_actual_hoy);
		$('#in_fecha_fin2').val(fecha_actual_hoy);

        var general_id_tabla = "tb_reporte_ganancia";
        var general_url = "<?php echo base_url(); ?>reporte/ganancias/rporte_ganancias";
        var mov_diario_dataSrc = function(res){
            $('#sp_total_ingreso').text(res.data_totales.monto_final);
            return res.data;
        }
        var mov_diario_data = function() {

            var data = {};

            data.fecha_ini = $("#in_fecha_ini").val();
            data.fecha_fin = $("#in_fecha_fin").val();

            return data;
        };
        var general_columns = [
            {data: "sal_numero_doc_cliente"},
            {data: "emp_razon_social"},
            {data: "sal_fecha_doc_cliente"},
            {data: "pro_nombre"},
            {data: "sad_cantidad"},
            {data: "sad_valor"},
            {data: "sad_ganancias",className: "alinear_derecha"}

        ];

        var general_id_tabla2 = "tb_reporte_ganancia_agrupado";
        var general_url2 = "<?php echo base_url(); ?>reporte/ganancias/Ganancias_x_Producto_Agrupado";
        var mov_diario_dataSrc2 = function(res){
            $('#sp_total_ingreso2').text(res.data_totales.monto_final);
            return res.data;
        }
        var mov_diario_data2 = function() {

            var data = {};

            data.fecha_ini = $("#in_fecha_ini2").val();
            data.fecha_fin = $("#in_fecha_fin2").val();

            return data;
        };
        var general_columns2 = [
            {data: "pro_nombre"},
            {data: "CANTIDAD_VENDIDA"},
            {data: "sad_valor"},
            {data: "MONTO"},
            {data: "GANANCIA_TOTAL",className: "alinear_derecha"}

        ];


        generar_tabla_ajx2(general_id_tabla, general_url, 'POST',mov_diario_data,mov_diario_dataSrc,general_columns);
        generar_tabla_pagrupados(general_id_tabla2, general_url2, 'POST',mov_diario_data2,mov_diario_dataSrc2,general_columns2);

    }
	function filtrar_fecha_ganancias() {
        $('#tb_reporte_ganancia').DataTable().ajax.reload();
	}
	function filtrar_fecha_ganancias_agrupados() {
        $('#tb_reporte_ganancia_agrupado').DataTable().ajax.reload();
	}
	function generar_tabla_ajx2(id_tabla, url, type, data, dataSrc, columns) {
		$('#'+id_tabla).DataTable({
			ajax: {
				url: url,
				type: type,
				data: data,
				dataSrc: dataSrc
			},
            order:([2,'desc']),
			columns: columns,
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
			destroy: true

		});
	}
    function generar_tabla_pagrupados(id_tabla2, url2, type2, data2, dataSrc2, columns2) {
        $('#'+id_tabla2).DataTable({
            ajax: {
                url: url2,
                type: type2,
                data: data2,
                dataSrc: dataSrc2
            },
            columns: columns2,
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
            destroy: true

        });
    }
    function imprimir() {
        $('#titulo2').show();
        $('#titulo').css({"margin-bottom":"10px","font-size":"35px","font-weight":"bold"});
        $('#cabecera').css({"text-align": "center","align-content":"center"});
        $('#pie').css({"text-align": "right","align-content":"right","font-size":"18px","font-weight": "bold","margin-right":"50px !important"});
        $('#a').css({"text-align": "center","align-content":"center","font-size":"20px","font-weight": "bold"});
        var printme= document.getElementById("tb_reporte_ganancia_agrupado");
        var wme= window.open();
        wme.document.write(printme.outerHTML);
        wme.document.close();
        wme.focus();
        wme.print();
        wme.close();

        return window.location.reload(true);
    }
    function imprimir_desagrupados() {
        $('#titulo').show();
        $('#titulo').css({"margin-bottom":"10px","font-size":"35px","font-weight":"bold"});
        $('#cabecera').css({"text-align": "center","align-content":"center"});
        $('#pie').css({"text-align": "right","align-content":"right","font-size":"18px","font-weight": "bold","margin-right":"50px !important"});
        $('#a').css({"text-align": "center","align-content":"center","font-size":"20px","font-weight": "bold"});
        var printme= document.getElementById("tb_reporte_ganancia");
        var wme= window.open();
        wme.document.write(printme.outerHTML);
        wme.document.close();
        wme.focus();
        wme.print();
        wme.close();

        return window.location.reload(true);
    }
</script>
