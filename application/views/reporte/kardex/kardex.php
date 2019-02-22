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
			<li class="active">Targeta Kardex.</li>
		</ol>
	</section>
	<!-- Main content -->
	<section class="content">
		<!-- Your Page Content Here -->
		<div class="row">
			<div class="col-md-12">
				<div class="nav-tabs-custom">
					<ul class="nav nav-tabs pull-right" style="background-color: #00a300;">
						<li class="pull-left header" style="color: white;"><i class="fa fa-chart-line"></i>  <span id="sp_tipo_movimiento">Reporte de Mercaderias Utilizando el Metodo PEPS</span></li>
					</ul>
					<br>
					<div class="tab-content">
						<div class="tab-pane active" id="dv_mov_diario_ingreso">
							<div class="row">
								<div class="form-group">
									<hr>
								</div>
								<div class="form-group col-md-12">
									<STRONG><p>PRODUCTO</p></STRONG>
									<STRONG><p>UNIDAD DE MEDIDA</p></STRONG>
								</div>
								<div id="imprimir_desagrupados">
									<div class="row" style="margin: 16px;">
										<div class="col-sm-12 table-responsive">
											<table class="table table-bordered" id="tb_reporte_ganancia">
												<caption id="titulo" hidden>REPORTE DE GANANCIAS POR PRODUCTO</caption><br><br>
												<thead>
												<tr>
													<th >N° DOCUMENTO</th>
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
