<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
			<!-- Content Wrapper. Contains page content -->
			<div class="content-wrapper">
				<!-- Content Header (Page header) -->
				<section class="content-header">
					<h1>
						<small><?= $fecha_actual ?></small>
					</h1>
					<ol class="breadcrumb">
						<li>
							<a href="<?= base_url() ?>bienvenida"><i class="fa fa-home"></i> Inicio</a>
						</li>
						<li class="active">Bienvenida</li>
					</ol>
				</section>
				<!-- Main content -->
				<section class="content">
					<div class="row">
                        <div class="col-md-12">
                            <div class="center-block">
                                <div id="pone_compras">
                                    <div class="col-lg-6 col-xs-6 col-md-6">
                                        <!-- small box -->
                                        <div class="small-box bg-aqua">
                                            <div class="inner">
                                                <h3><span id="sp_stock_minimo">0</span></h3>
                                                <p>STOCK MINIMO</p>
                                            </div>
                                            <div class="icon">
                                                <i class="ion ion-stats-bars"></i>
                                            </div>
                                            <a href="#" class="small-box-footer">Ver otras entradas <i class="fa fa-arrow-circle-right"></i></a>
                                        </div>
                                    </div><!-- ./col -->
                                </div>
                                <div id="pone_ventas">
                                    <div class="col-lg-6 col-xs-6 col-md-6"><!-- small box -->
                                        <div class="small-box bg-red">
                                            <div class="inner">
                                                <h3><span id="sp_ventas_del_dia">0.00</span></h3>
                                                <p><b>VENTAS DEL DÍA</b></p>
                                            </div>
                                            <div class="icon">
                                                <i class="ion ion-bag"></i>
                                            </div>
                                            <a href="#" class="small-box-footer">Consultar otra fecha <i class="fa fa-arrow-circle-right"></i></a>
                                        </div>
                                    </div><!-- ./col -->
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="center-block">
                                <div id="pone_gastos">
                                    <div class="col-lg-6 col-md-6 col-xs-6">
                                        <!-- small box -->
                                        <div class="small-box bg-yellow">
                                            <div class="inner">
                                                <h3><span id="sp_gastos_registrados">0.00</span></h3>
                                                <p><b>GASTOS DEL DÍA</p>
                                            </div>
                                            <div class="icon">
                                                <i class="ion ion-calendar"></i>
                                            </div>
                                            <a href="#" class="small-box-footer">Consultar otros <i class="fa fa-arrow-circle-right"></i></a>
                                        </div>
                                    </div><!-- ./col -->
                                </div>
                                <div id="pone_users">
                                    <div class="col-lg-6 col-xs-6 col-md-6">
                                        <!-- small box -->
                                        <div class="small-box bg-green">
                                            <div class="inner">
                                                <h3><span id="sp_numero_clientes">0</span></h3>
                                                <p><b>NUMERO CLIENTE</b>S</p>
                                            </div>
                                            <div class="icon">
                                                <i class="ion ion-person-add"></i>
                                            </div>
                                            <a href="#" class="small-box-footer">Operaciones con usuarios <i class="fa fa-arrow-circle-right"></i></a>
                                        </div>
                                    </div><!-- ./col -->
                                </div>
                            </div>
                        </div>
                    </div>
				</section>
			</div><!-- /.content-wrapper -->
			<script>
			function init_bienvenida() {
				reload_bienvenida();
			}
			function reload_bienvenida() {
				$.ajax({
					type: "POST",
					url: BASE_URL+"bienvenida/reload_bienvenida",
					dataType: 'json',
					data: null,
					success: function(datos) {
						if(datos.hecho === 'SI') {
							$('#sp_stock_minimo').text(datos.data.stock_minimo);
							$('#sp_ventas_del_dia').text(datos.data.ventas_del_dia);
							$('#sp_gastos_registrados').text(datos.data.gastos_registrados);
							$('#sp_numero_clientes').text(datos.data.numero_clientes);
						}
					}
				});
			}
			</script>
