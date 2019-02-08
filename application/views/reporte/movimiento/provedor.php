<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper" xmlns="">
	<!-- Content Header (Page header) -->
	<section class="content-header">
		<h1><small></small>
		</h1>
		<ol class="breadcrumb">
			<li>
				<a href="<?= base_url() ?>bienvenida"><i class="fa fa-home"></i> Reporte</a>
			</li>
			<li class="active">Movimiento por provedor</li>
		</ol>
	</section>
	<!-- Main content -->
	<section class="content">
		<!-- Your Page Content Here -->
		<div class="row">
			<div class="col-md-12">
				<div class="nav-tabs-custom">
					<ul class="nav nav-tabs pull-right">
						<li class="active"><a href="#dv_mov_diario_ingreso" data-toggle="tab" id="a_mov_diario_ingreso">Registro de Provedores</a></li>
						<li class="pull-left header"><i class="fa fa-chart-line"></i>  <span id="sp_tipo_movimiento">Movimientos por Provedor</span></li>
					</ul>
					<div class="tab-content">
						<div class="tab-pane active" id="dv_mov_diario_ingreso">
							<div class="row">
								<div class="row" style="margin: 16px;">
									<div class="col-sm-12 table-responsive">
										<table class="table table-bordered" id="tb_provedor">
											<thead>
											<tr>
												<th class="text-center">RUC</th>
												<th class="text-center">Proveedor</th>
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
				<h3 class="modal-title text-center" id="disminuirDeuda">Movimientos de Compras</h3>
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
												<table class="table table-bordered" id="tb_compras">
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
										<div class="row" style="margin: 16px;">
											<div class="col-sm-12 table-responsive">
												<table class="table table-bordered" id="tb_pagos_provedor">
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
<div class="modal fade" id="detalles_compras" tabindex="-1" role="dialog" aria-labelledby="detalles_compra" aria-hidden="true">
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
						<table class="table table-bordered" id="tb_detalle_ingreso">
							<thead>
							<tr>
								<th>PRODUCTO</th>
								<th>CANTIDAD</th>
								<th>PRECIO COMPRA</th>
								<th>MONTO</th>
							</tr>
							</thead>
							<tbody>
							</tbody>
							<tfoot>
							<tr>
								<th colspan="3" class=" alinear_derecha">&nbsp;Total Compra:</th>
								<th class=" alinear_derecha"><span id="sp_total_ingreso"></span></th>
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
		tb = $('#tb_provedor').DataTable({
			'ajax':BASE_URL+'reporte/proveedor/listarProvedor',
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






	}

	function Movimiento_Provedor(pcl_id_pcliente) {
		if(pcl_id_pcliente){
			tb = $('#tb_compras').DataTable({
				'ajax':BASE_URL+'reporte/proveedor/buscarcompras/'+pcl_id_pcliente,
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
		} else {
			alert('Error al cargar las compras del provedor');
		}


		tb = $('#tb_pagos_provedor').DataTable({
			'ajax':BASE_URL+'reporte/proveedor/listar_pagos_provedor/'+pcl_id_pcliente,
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

	function Detalles(ing_id_ingreso) {
		if (ing_id_ingreso) {
			var url = BASE_URL + 'reporte/proveedor/detalle_compra_provedor/'+ing_id_ingreso;
			var columns = [
				{data: "pro_nombre"},
				{data: "ind_cantidad"},
				{data: "pro_val_compra"},
				{data: "ind_monto"},
			];
			generar_tabla_provedor(url, 'POST', columns);
			$.ajax({
				type:'POST',
				url:BASE_URL + 'reporte/proveedor/detalle_compra_provedor/'+ing_id_ingreso,
				dataType:'JSON',
				success:function(datos){
					$('#sp_total_ingreso').text(datos.data_totales.monto_final);
				}
			});


		}
	}
			function generar_tabla_provedor(url, type, columns) {
				$('#tb_detalle_ingreso').DataTable({
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
