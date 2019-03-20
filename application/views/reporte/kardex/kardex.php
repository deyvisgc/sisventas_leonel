<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<style>
    .modal-dialog {
        width: 95%;
        padding: 0;
    }

    .modal-content {
        border-radius: 0;
    }
</style>
<div class="content-wrapper">
	<!-- Content Header (Page header) -->
	<section class="content-header">
		<h1><small></small>
		</h1>
		<ol class="breadcrumb">
			<li>
				<a href="<?= base_url() ?>bienvenida"><i class="fa fa-home"></i> Home</a>
			</li>
			<li class="active">Kardex.</li>
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

								<div id="imprimir_desagrupados">
									<div class="row" style="margin: 16px;">
										<div class="col-sm-12 table-responsive">
                                            <table class="table table-bordered" id="tb_producto_kardex" style="width: 100%">
                                                <thead>
                                                    <tr>
                                                        <th class="text-center">CLASE</th>
                                                        <th class="text-center">SUB-CLASE</th>
                                                        <th class="text-center">PRODUCTO</th>
                                                        <th class="text-center">CANTIDAD</th>
                                                        <th class="text-center">PRECIO</th>
                                                        <th class="text-center">MONTO VENTA</th>
                                                        <th class="text-center">DETALLE</th>
                                                    </tr>
                                                </thead>
                                                <tbody class="text-center">
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
		</div>
	</section><!-- /.content -->
</div><!-- /.content-wrapper -->

<!--MODAL DETALLE KARDEX-->
<div style="width: 100%" class="modal fade" id="detalle_kardex" tabindex="-1" role="dialog" aria-labelledby="detalle_kardex" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-12">
                        <div class="nav-tabs-custom">
                            <ul class="nav nav-tabs pull-right" style="background-color: #3ca4f3">
                                <li><a href="#dv_salidas" data-toggle="tab" id="a_salidas" >Salidas</a></li>
                                <li><a href="#dv_entradas" data-toggle="tab" id="a_entradas">Entradas</a></li>
                                <li class="active"><a href="#dv_existencias" data-toggle="tab" id="a_general">Existencias</a></li>
                                <li class="pull-left header" id="pro_nombre" style="color:white;"><i class="fa fa-calculator"></i></li>
                            </ul>
                            <div class="tab-content">
                                <div class="tab-pane active" id="dv_existencias">
                                    <div class="row">
                                        <br>
                                        <div class="col-md-6 col-lg-6 col-xs-12">
                                            <table class="table table-hover table-sm" id="tb_existencias" style="width: 100%">
                                                <thead>
                                                <tr>
                                                    <th class="text-center" colspan="3" style="background-color:#0d47a1;color: white;">EXISTENCIAS</th>
                                                </tr>
                                                <tr>

                                                    <th class="text-center" style="color: white;background-color:#304ffe;">Cantidad</th>
                                                    <th class="text-center" style="color: white;background-color:#304ffe;">Valor Unitario</th>
                                                    <th class="text-center" style="color: white;background-color:#304ffe;">Valor Total</th>
                                                </tr>
                                                </thead>
                                                <tbody class="text-center">
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <div class="tab-pane" id="dv_entradas">
                                    <div class="row">
                                        <div class="col-md-6 col-lg-6 col-xs-12">
                                            <table class="table table-hover table-sm" id="tb_entradas" style="width: 100%">
                                                <thead>
                                                <tr>
                                                    <th class="text-center" style="padding-bottom: 25px; background-color: #B03A2E; color: white" rowspan="2" >FECHA</th>

                                                    <th class="text-center" colspan="5" style="background-color: #E74C3C;color: white;">ENTRADAS DE COMPRAS</th>


                                                </tr>
                                                <tr>

                                                    <th class="text-center" style="color: white;background-color: #E74C3C;">N° DOC</th>
                                                    <th class="text-center" style="color: white;background-color: #E74C3C;">LOTE</th>
                                                    <th class="text-center" style="color: white;background-color: #E74C3C;">Cantidad</th>
                                                    <th class="text-center" style="color: white;background-color: #E74C3C;">Valor Unitario</th>
                                                    <th class="text-center" style="color: white;background-color: #E74C3C;">Valor Total</th>



                                                </tr>
                                                </thead>
                                                <tbody class="text-center">
                                                </tbody>
                                                <tfoot>
                                                <tr>
                                                    <th colspan="5" class=" alinear_derecha">&nbsp;Total</th>
                                                    <th class=" alinear_derecha"><span id="total_ingreso">00.00</span></th>
                                                </tfoot>
                                            </table>
                                        </div>
                                        <div class="col-md-6 col-lg-6 col-xs-12">
                                            <table class="table table-hover table-sm" id="tb_entradas_produccion" style="width: 100%">
                                                <thead>
                                                <tr>
                                                    <th class="text-center" style="padding-bottom: 25px; background-color: #B03A2E; color: white" rowspan="2" >FECHA</th>

                                                    <th class="text-center" colspan="4" style="background-color: #E74C3C;color: white;">ENTRADAS DE PRODUCCION</th>

                                                </tr>
                                                <tr>

                                                    <th class="text-center" style="color: white;background-color: #E74C3C;">LOTE</th>
                                                    <th class="text-center" style="color: white;background-color: #E74C3C;">Cantidad</th>
                                                    <th class="text-center" style="color: white;background-color: #E74C3C;">Valor Unitario</th>
                                                    <th class="text-center" style="color: white;background-color: #E74C3C;">Valor Total</th>



                                                </tr>
                                                </thead>
                                                <tbody class="text-center">
                                                </tbody>
                                                <tfoot>
                                                <tr>
                                                    <th colspan="4" class=" alinear_derecha">&nbsp;Total</th>
                                                    <th class=" alinear_derecha"><span id="total_ingreso_produccion">00.00</span></th>
                                                </tfoot>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <div class="tab-pane" id="dv_salidas">
                                    <div class="row">
                                        <div class="col-md-6 col-lg-6 col-xs-12">
                                            <table class="table table-hover table-sm" id="tb_salidas" style="width: 100%">
                                                <thead>
                                                <tr>
                                                    <th class="text-center" style="padding-bottom: 25px; background-color: #1f05d4; color: white" rowspan="2" >FECHA</th>
                                                    <th class="text-center" colspan="5" style="background-color: #1f05d4;color: white;">SALIDAS VENTAS</th>
                                                </tr>
                                                <tr>
                                                    <th class="text-center" style="color: white;background-color: #1978f3;">N° DOC</th>
                                                    <th class="text-center" style="color: white;background-color:  #1978f3;">LOTE</th>
                                                    <th class="text-center" style="color: white;background-color:  #1978f3;">Cantidad</th>
                                                    <th class="text-center" style="color: white;background-color:  #1978f3;">Valor Unitario</th>
                                                    <th class="text-center" style="color: white;background-color:  #1978f3;">Valor Total</th>
                                                </tr>
                                                </thead>
                                                <tbody class="text-center">
                                                </tbody>
                                                <tfoot>
                                                <tr>
                                                    <th colspan="5" class=" alinear_derecha">&nbsp;Total</th>
                                                    <th class=" alinear_derecha"><span id="total_salidas">00.00</span></th>
                                                    </tfoot>
                                            </table>
                                        </div>
                                        <div class="col-md-6 col-lg-6 col-xs-12">
                                            <table class="table table-hover table-sm" id="tb_salidas_produccion" style="width: 100%">
                                                <thead>
                                                <tr>
                                                    <th class="text-center" style="padding-bottom: 25px; background-color: #1f05d4; color: white" rowspan="2" >FECHA</th>
                                                    <th class="text-center" colspan="5" style="background-color: #1f05d4;color: white;">SALIDAS VENTAS</th>
                                                </tr>
                                                <tr>
                                                    <th class="text-center" style="color: white;background-color: #1978f3;">N° DOC</th>
                                                    <th class="text-center" style="color: white;background-color:  #1978f3;">LOTE</th>
                                                    <th class="text-center" style="color: white;background-color:  #1978f3;">Cantidad</th>
                                                    <th class="text-center" style="color: white;background-color:  #1978f3;">Valor Unitario</th>
                                                    <th class="text-center" style="color: white;background-color:  #1978f3;">Valor Total</th>
                                                </tr>
                                                </thead>
                                                <tbody class="text-center">
                                                </tbody>
                                                <tfoot>
                                                <tr>
                                                    <th colspan="5" class=" alinear_derecha">&nbsp;Total</th>
                                                    <th class=" alinear_derecha"><span id="total_salidas_produccion">00.00</span></th>
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
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>



<script type="text/javascript">
    function init_kardex() {
        $(document).ready(function () {
            $('#tb_producto_kardex').DataTable({
                ajax:BASE_URL+'reporte/kardex/kardex/Listar_Productos',
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
                },
                destroy:true
            });
        });
    }
    function Detalle_Kardex(pro_id_producto=null){

        $('#tb_entradas').DataTable({
            ajax:{
                url:BASE_URL+'reporte/kardex/kardex/Kardex_Entrada/'+pro_id_producto,
                type:'post',
                dataType:'json',
                dataSrc:function(res){
                    $('#total_ingreso').text(res.totales_entrada.total_entradas);
                    return res.data;
                }
            },
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
            },
            destroy:true,
            "ordering": false
        });


		$('#tb_entradas_produccion').DataTable({
			ajax:{
				url:BASE_URL+'reporte/kardex/kardex/Kardex_EntradaXproduccion/'+pro_id_producto,
				type:'post',
				dataType:'json',
				dataSrc:function(res){
					$('#total_ingreso_produccion').text(res.totales_entrada.total_entradas);
					return res.data;
				}
			},
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
			},
			destroy:true,
			"ordering": false
		});
        $('#tb_salidas').DataTable({

            ajax:{
                url:BASE_URL+'reporte/kardex/kardex/Kardex_Existencias/'+pro_id_producto,
                type:'post',
                dataType:'json'
            },
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
            },
            destroy:true
        });

        $('#tb_salidas_produccion').DataTable({
            ajax:{
                url:BASE_URL+'reporte/kardex/kardex/Kardex_Salidas_Produccion/'+pro_id_producto,
                type:'post',
                dataType:'json',
                dataSrc:function(res){
                    $('#total_salidas_produccion').text(res.totales_salidas_produccion.total_salidas_produccion);
                    return res.data;
                }
            },
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
            destroy:true,
            ordering:false
        });
        $('#tb_salidas').DataTable({
            ajax:{
                oreder:[[0,'desc']],
                url:BASE_URL+'reporte/kardex/kardex/Kardex_Salidas/'+pro_id_producto,
                type:'post',
                dataType:'json',
                dataSrc:function(res){
                    $('#total_salidas').text(res.total_salida.total_salidas);
                    $('#pro_nombre').text(res.total_salida.pro_nombre);
                    return res.data;
                }
            },
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
            },
            destroy:true,
            "ordering": false
        });
    }
</script>
