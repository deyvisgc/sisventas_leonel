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
                                    <label for="" class="col-sm-2 col-lg-2 control-label">FECHA INICIO</label>
                                    <div class="col-sm-3">
                                        <input type="date" id="date_ini" name="fecha_ini" class="form-control" value="" placeholder="Fecha inicio">
                                    </div>
                                    <label for="" class="col-sm-2 col-lg-2 control-label">FECHA FIN</label>
                                    <div class="col-sm-3">
                                        <input type="date" id="date_fin" name="fecha_fin" class="form-control" value="" placeholder="Fecha fin">
                                    </div>
                                    <div class="form-group">
                                        <div class="col-sm-3 col-lg-2">
                                            <button type="button" class="btn btn-primary" onclick="filtrar_movimiento_diario_salida();" id="btn_filtrar"><i class="fa fa-check-circle"></i> Filtar por Fecha</button>
                                        </div>
                                    </div>
                                </div>
                                <br><br>
                                <hr>
                                <div class="form-group col-md-12">
                                    <button type="button" class="btn btn-danger pull-right" onclick="imprimir();"><i class="fa fa-print"></i> Imprimir </button>
										<button type="button" style="margin-left: 30px" class="btn btn-info" data-toggle="modal" data-target="#md_retiro"  id="btn_retiro"><i class="fas fa-eye"></i> RETIRO</button>
										<button type="button" class="btn btn-warning"  id="btn_ingreso" data-toggle="modal" data-target="#md_ingreso"><i class="fas fa-eye"></i> INGRESO</button>
                                </div><br>
                                <div id="imprimir">
                                <div class="row" style="margin: 16px;">
                                    <div class="col-sm-12 table-responsive">
                                        <table class="table table-responsive table-bordered" id="tb_efectivo">
                                            <caption id="titulo" hidden>REPORTE DE EFECTIVO EN CAJA</caption><br><br>
                                            <thead>
                                            <tr>
                                                <th>FECHA</th>
                                                <th>CLIENTE</th>
                                                <th>DOC.</th>
                                                <th>NRO.</th>
                                                <th>S/. VENTA TOTAL</th>
                                                <th>S/. PAGO EFECTIVO</th>
                                                <th>S/. PAGO CRÉDITO</th>
                                            </tr>
                                            </thead>
                                            <tbody id="cabecera">
                                            </tbody>
                                            <tfoot id="pie">
                                            <tr>
                                                <th colspan="4" class="alinear_derecha">&nbsp;Total:</th>
                                                <th  class="alinear_derecha"><span id="sp_total_salida"></span></th>
                                                <th  class="alinear_derecha"><span id="total_efectivo"></span></th>
                                                <th  class="alinear_derecha"><span id="total_credito"></span></th>
                                            </tr>
                                            <tr>
                                                <th colspan="6" class="alinear_derecha">Total ingreso efectivo:</th>
                                                <th  class="alinear_derecha"><span id="monto_ingreso"></span></th>
                                            </tr>
                                            <tr>
                                                <th colspan="6" class="alinear_derecha">Total salida efectivo:</th>
                                                <th  class="alinear_derecha"><span id="monto_retiro"></span></th>
                                            </tr>
                                            <tr>
                                                <th colspan="6" class="alinear_derecha">Efectivo en caja:</th>
                                                <th  class="alinear_derecha"><span id="t_efectivo"></span></th>
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
<!--modal tabla detalle retiro-->
<div class="modal" id="md_retiro">
	<div class="modal-dialog modal-lg " style="text-align: center">
		<div class="modal-content">

			<!-- Modal Header -->
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">&times;</button>
				<h4 class="text-capitalize" id="md_titulo" style="padding-left: 20px; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif ;color: #0c0c0c">Detalle del Retiro</h4>

			</div>

			<!-- Modal body -->
			<div class="modal-body">
				<div class="row">
					<div class="col-md-12">
						<br>
						<div class="row col-md-12">
							<div class="form-group col-md-4">
								<div class="input-group">
									<span class="input-group-addon bg-gray ">Desde: </span>
									<input type="date" id="in_fecha_desde" name="fecha_ini2" class="form-control" value="" placeholder="Fecha inicio">
								</div>
							</div>
							<div class="form-group col-md-4" >
								<div class="input-group">
									<span class="input-group-addon bg-gray">Hasta: </span>
									<input type="date" id="in_fecha_hasta" name="fecha_fin2" class="form-control" value="" placeholder="Fecha fin">
								</div>
							</div>
							<div class="form-group col-md-3">
								<div class="input-group" >
									<span class="input-group-addon bg-gray">Caja: </span>
									<select class="form-control custom-select" required id="fcaja" name="caja_form">

									</select>

								</div>
							</div>
							<div class="form-group col-md-1">
								<div class="input-group">
									<button class="btn btn-facebook" type="button" onclick="cargar_detalle();"> Consultar </button>
								</div>
							</div>
						</div>
						<table id="tabla_retiro" class="table table-striped">
							<thead>
							<tr>
								<th>Caja</th>
								<th>Monto</th>
								<th>Fecha</th>
								<th>Tipo Sangría</th>
								<th>Motivo</th>
								<th>Usuario</th>
							</tr>
							</thead>
							<tbody>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
			</div>
			</div>

			<!-- Modal footer -->


		</div>
	</div>
<!--modal tabla detalle retiro finish-->
<!--modal tabla detalle ingreso-->
<div class="modal" id="md_ingreso">
	<div class="modal-dialog modal-lg " style="text-align: center">
		<div class="modal-content">

			<!-- Modal Header -->
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">&times;</button>
				<h4 class="text-capitalize" id="md_titulo" style="padding-left: 20px; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;color: #0c0c0c">Detalle del Ingreso</h4>

			</div>

			<!-- Modal body -->
			<div class="modal-body">
				<div class="row">
					<div class="col-md-12">
						<br>
						<div class="row col-md-12">
							<div class="form-group col-md-4">
								<div class="input-group">
									<span class="input-group-addon bg-gray ">Desde: </span>
									<input type="date" id="in_fecha_desde2" name="fecha_ini2" class="form-control" value="" placeholder="Fecha inicio">
								</div>
							</div>
							<div class="form-group col-md-4" >
								<div class="input-group">
									<span class="input-group-addon bg-gray">Hasta: </span>
									<input type="date" id="in_fecha_hasta2" name="fecha_fin2" class="form-control" value="" placeholder="Fecha fin">
								</div>
							</div>
							<div class="form-group col-md-3">
								<div class="input-group" >
									<span class="input-group-addon bg-gray">Caja: </span>
									<select class="form-control custom-select" required id="fcaja2" name="caja_form">

									</select>

								</div>
							</div>
							<div class="form-group col-md-1">
								<div class="input-group">
									<button class="btn btn-facebook" type="button" onclick="cargar_detalle_ingreso();"> Consultar </button>
								</div>
							</div>
						</div>
						<table id="tabla_ingreso" class="table table-striped">
							<thead>
							<tr>
								<th>Caja</th>
								<th>Monto</th>
								<th>Fecha</th>
								<th>Tipo Sangría</th>
								<th>Motivo</th>
								<th>Usuario</th>
							</tr>
							</thead>
							<tbody>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
			</div>
		</div>

		<!-- Modal footer -->


	</div>
</div>
<!--modal tabla detalle ingreso finish-->

<script>
    function init_deuda() {

		var fecha_actual_hoy = get_fhoy();
		fecha1=	$('#date_ini').val(fecha_actual_hoy);
		fecha2=	$('#date_fin').val(fecha_actual_hoy);
		var fecha_Actual = get_fhoy();
		$('#in_fecha_desde').val(fecha_Actual);
	    $('#in_fecha_hasta').val(fecha_Actual);
	    $('#in_fecha_desde2').val(fecha_Actual);
	    $('#in_fecha_hasta2').val(fecha_Actual);


        var mov_diario_id_tabla2 = "tb_efectivo";
        var mov_diario_url2 = "<?php echo base_url(); ?>reporte/efectivo/Caja/movimiento_efectivo";
        var mov_diario_dataSrc2 = function(res){
            $('#sp_total_salida').text(res.data_totales.sal_monto);
            $('#total_efectivo').text(res.total_efec.total_efectivo);
            $('#total_credito').text(res.total_cre.total_credito);
            $('#monto_ingreso').text(res.tsangria_ingreso.monto_ingreso);
            $('#monto_retiro').text(res.tsangria_salida.monto_retiro);
            $('#t_efectivo').text(res.efectivo_caja.proc_efectivo_caja);
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
            {data: "sal_monto"},
            {data: "sal_monto_efectivo"},
            {data: "sal_monto_tar_credito", className: "alinear_derecha"}
        ];
        generar_tabla_ajx3(mov_diario_id_tabla2, mov_diario_url2, 'POST', mov_diario_data2, mov_diario_dataSrc2, mov_diario_columns2);



		cargarcaja();
    }
    function cargarcaja() {
     $.ajax({
		 type: "POST",
		 url: BASE_URL+"reporte/efectivo/Caja/buscarCaja",
		 dataType: 'json',
		 success:function (data) {
			 if(data.hecho == 'SI') {
				 var select = $('#fcaja');
				 var select2 = $('#fcaja2');
				 select.empty();
				 data.list_documento.forEach(function(documento) {
					 select.append('<option value="'+documento.caj_descripcion+'" >'+documento.caj_descripcion+'</option>');
					 select2.append('<option value="'+documento.caj_descripcion+'" >'+documento.caj_descripcion+'</option>');

				 });
			 }
		 }
	 });

	}
	function cargar_detalle_ingreso() {
		$cja2=$('#fcaja2').val();
		var url2=BASE_URL + 'reporte/efectivo/Caja/buscarCajaXCaja_Ingreso/' + $cja2;
		var fecha_caja_data_2 = function() {
			var data1={};
			data1.fecha1=$('#in_fecha_desde2').val();
			data1.fecha2=$('#in_fecha_hasta2').val();
			return data1;
		};

		var columns = [
			{data: "caj_descripcion"},
			{data: "monto"},
			{data: "fecha"},
			{data: "tipo_sangria"},
			{data: "san_motivo"},
			{data: "usu_nombre"},

		];
		generar_tabla_detalle_caja_ingreso(url2, 'POST',fecha_caja_data_2,columns);
	}
	function generar_tabla_detalle_caja_ingreso( url, type, data, columns) {
		$('#tabla_ingreso').DataTable({
			order:( [ 0, 'desc' ] ),
			ajax: {
				url: url,
				type: type,
				data: data
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
				"search": "Buscar  ",
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
	function cargar_detalle() {
		$cja=$('#fcaja').val();
		var url=BASE_URL + 'reporte/efectivo/Caja/buscarCajaXCaja/' + $cja;
		var fecha_caja_data = function() {
			var data1={};
			data1.fecha1=$('#in_fecha_desde').val();
			data1.fecha2=$('#in_fecha_hasta').val();
			return data1;
		};

		var columns = [
			{data: "caj_descripcion"},
			{data: "monto"},
			{data: "fecha"},
			{data: "tipo_sangria"},
			{data: "san_motivo"},
			{data: "usu_nombre"},

		];
		generar_tabla_detalle_caja_retiro(url, 'POST',fecha_caja_data,columns);



	}

	function generar_tabla_detalle_caja_retiro( url, type, data, columns) {
		$('#tabla_retiro').DataTable({
			order:( [ 0, 'desc' ] ),
			ajax: {
				url: url,
				type: type,
				data: data
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
				"search": "Buscar  ",
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


    function generar_tabla_ajx3(id_tabla, url, type, data, dataSrc, columns) {
        $('#'+id_tabla).DataTable({
            order:( [ 0, 'desc' ] ),
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
                "search": "Buscar  ",
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

    function imprimir() {
        $('#titulo').show();
        $('#titulo').css({"margin-bottom":"10px","font-size":"35px","font-weight":"bold"});
        $('#cabecera').css({"text-align": "center","align-content":"center"});
        $('#pie').css({"text-align": "right","align-content":"right","font-size":"20px","font-weight": "bold"});
        $('#a').css({"text-align": "center","align-content":"center","font-size":"20px","font-weight": "bold"});
        var printme= document.getElementById("tb_efectivo");
        var wme= window.open();
        wme.document.write(printme.outerHTML);
        wme.document.close();
        wme.focus();
        wme.print();
        wme.close();

        return window.location.reload(true);
    }


</script>
