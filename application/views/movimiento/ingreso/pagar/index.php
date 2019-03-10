<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
        <h1>
            Registro de Cuentas Por Pagar <small></small>
        </h1>
        <ol class="breadcrumb">
            <li>
                <a href="<?= base_url() ?>bienvenida"><i class="fa fa-home"></i> Movimiento</a>
            </li>
            <li class="active">Cuentas por pagar</li>
        </ol>
    </section>
    <!-- Main content -->
    <section class="content">
        <!-- Your Page Content Here -->
        <div class="row">
            <div class="col-md-12">
                <div class="nav-tabs-custom">
                    <ul class="nav nav-tabs pull-right">
                        <li class="active"><a href="#dv_panel_eleccion" data-toggle="tab" id="a_panel_eleccion">Cuentas por pagar</a></li>
                        <li class="pull-left header"><i class="fa fa-cart-arrow-down"></i> <span id="sp_etiqueta">Lista de Proveedores a pagar</span></li>
                    </ul>
					<p></p>
					<h2 style="margin-left: 10px">Filtrar Deudas Por Proveedor</h2>
					<div class="row">
						<div class="col-lg-4 col-sm-4 col-md-4 col-xs-12">
							<div class="input-group" style="margin-left: 10px">
								<span class="input-group-addon bg-gray">Proveedor:</span>
								<input type="text" class="form-control precios" id="in_proveedor" style="font-size: 20px; text-align: right; color: blue; font-weight: bold;" data-inputmask="'alias': 'numeric', 'autoGroup': true, 'digits': 2, 'digitsOptional': false, 'placeholder': '0'">

							</div>
						</div>
						<button style="margin-left: 550px" type="button" onclick="cancelarfiltroxproveedor();" class="btn btn-danger">CANCELAR FILTRO</button>
					</div><br><br>


                    <div class="tab-content"  style="margin-left: 10px">
                        <!-- TAB ELECCION -->
                        <div class="tab-pane active" id="dv_panel_eleccion">
                            <div class="row">
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="box box-primary">
                                            <div class="box-header">
                                                <h3 class="box-title"></h3>
                                            </div>
                                            <div class="box-body table-responsive">
                                                <table id="proveedores_deudores" class="table table-striped">
                                                    <thead >
                                                    <tr>
                                                        <th class="text-center">Proveedor</th>
                                                        <th class="text-center">Fecha</th>
                                                        <th class="text-center">Deuda</th>
                                                        <th class="text-center">Operacion</th>
                                                    </tr>
                                                    </thead>
                                                    <tbody class="text-center">
                                                    </tbody>
                                                    <tfoot>
                                                    <tr>
                                                        <th colspan="2">&nbsp;Total</th>
                                                        <th class="text-center"><span id="total_x_pagar">450.00</span></th>
                                                    </tr>
                                                    </tfoot>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <br>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section><!-- /.content -->
</div><!-- /.content-wrapper -->

<!--MODAL RESTAR DEUDA-->
<div class="modal fade" id="disminuirDeuda" tabindex="-1" role="dialog" aria-labelledby="disminuirDeuda" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <h3 class="modal-title" id="disminuirDeuda">Deuda Actual con <strong id="cliente" class="text-danger text-bold"> </strong></h3><p id="idprovedor" hidden ></p>
            </div>
            <div class="modal-body">

                <input type="hidden" hidden id="sal_id_salida" name="sal_id_salida" class="form-control">
                <div class="row">
                    <div class="form-group col-md-12">
                        <div class="input-group">
                            <span class="input-group-addon bg-gray ">Deuda: </span>
                            <input type="text" id="deuda_actual" name="deuda_actual" class="form-control" value="" placeholder="Deuda Actual">

                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="form-group col-md-12">
                        <div class="input-group" >
                            <span class="input-group-addon bg-gray ">Monto pagado: </span>
                            <input type="text" id="monto_pagado" onkeyup="descontarDeuda();" autofocus="autofocus" name="monto_pagado" class="form-control" value="" placeholder="Ingresar Monto Pagado">
                        </div>
                    </div>
                </div>
				<div class="row">
					<div class="form-group col-md-12">
						<div class="input-group" >
							<span class="input-group-addon bg-gray ">Descripción: </span>
							<textarea rows="2" cols="50" class="form-control" placeholder="Ingresar el motivo" required name="descripcion_pago" autofocus id="descripcion_cobrar"></textarea>
						</div>
					</div>
				</div>
                <div class="row">
                    <div class="form-group col-md-12">
                        <div class="input-group" >
                            <span class="input-group-addon bg-gray ">Deuda Actualizada: </span>
                            <input type="text" id="monto_restante" readonly name="monto_restante" class="form-control" value="" placeholder="SALDO ACTUAL">
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                <button type="button" id="registrar_pago" onclick="editarDeuda();Cargar_Total_Cuentas_x_Pagar();" class="btn btn-primary">Guardar</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="corregirDeudaxPagar" tabindex="-1" role="dialog" aria-labelledby="corregirDeudaxPagar" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <h3 class="modal-title" id="disminuirDeuda">Corregir deuda actual con <strong id="client" class="text-danger text-bold"> </strong></h3>
            </div>
            <div class="modal-body">

                <input type="hidden" hidden id="id_salida" name="id_salida" class="form-control">
                <div class="row">
                    <div class="form-group col-md-12">
                        <div class="input-group">
                            <span class="input-group-addon bg-gray ">Deuda: </span>
                            <input type="text" id="corregir_debt" name="deuda_actual" class="form-control" value="" placeholder="Corregir deuda actual...">

                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" data-dismiss="modal">Cerrar</button>
                <button type="button" onclick="corregirDeuda();" class="btn btn-facebook">Modificar</button>
            </div>
        </div>
    </div>
</div>


<script>

    var table;
    function init_ingreso(){
        $(document).ready(function () {
            table = $('#proveedores_deudores').DataTable({
                'ajax':BASE_URL+'movimiento/ingreso/pagar/listarProveedores',
                order:([1,'desc']),
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
                    "search": "Buscar:",
                    "zeroRecords": "No se encontraron datos",
                    "paginate": {
                        "first": "Primero",
                        "last": "Ultimo",
                        "next": "Siguiente",
                        "previous": "Anterior"
                    }
                },
				destroy: true,
            });

            $.ajax({
                url:BASE_URL+'movimiento/ingreso/Pagar/Total_x_Pagar',
                type:'POST',
                dataType:'JSON',
                success:function(response){
                    $('#total_x_pagar').html(response.TOTAL);
                }
            });
        });

		$( "#in_proveedor" ).autocomplete({
			source: function( request, response ) {
				$.ajax( {
					url: BASE_URL+'movimiento/ingreso/pagar/buscar_x_proveedores',
					dataType: "json",
					type: "POST",
					data: {
						proveedor: request.term
					},
					success: function( data ) {
						if(data.lista_proveedor.length === 0) {
							add_mensaje(null, "Proveedores. ", ' 0 encontrados.', "info");
						}
						response( data.lista_proveedor );
					}
				} );
			},
			delay: 900,
			minLength: 1,
			select: function( event, ui ) {

				var url = BASE_URL + 'movimiento/ingreso/pagar/listarProveedorXID/'+ui.item.pcl_id_pcliente;

				var mov_diario_dataSrc = function (res) {
					$('#total_x_pagar').text(res.data_totales.deuda);

					return res.data;
				};

				var columns = [
					{data: "emp_razon_social"},
					{data: "ing_fecha_doc_proveedor"},
					{data: "ing_deuda"},
					{
						data: null,
						"render": function ( data, type, full, meta ) {
							return '<button type="button" onclick="cargarDatosDeuda('+full.pro_id_producto+')" data-toggle="modal" data-target="#disminuirDeuda"\n' +
								'class="btn btn-primary">Amortizar</button> '+
								' <button type="button" onclick="corregirDeuda('+full.pro_id_producto+')" data-toggle="modal" data-target="#editDeuda"\n' +
								'class="btn btn-success">Corregir</button>';
						}
					}
				];
				generar_deuda_Proveedor(url, 'POST', mov_diario_dataSrc, columns)

			}
		});

		function generar_deuda_Proveedor(url, type, dataSrc, columns) {
			tb = $('#proveedores_deudores').DataTable({

				ajax: {
					url: url,
					type: type,
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
					"search": "Buscar ",
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
				destroy: true,


			});

		}



		$('#registrar_pago').click(function () {
			var ma_saldo = $('#monto_restante').val();
			var id_ingreso = $('#sal_id_salida').val();
			var ma_debe=$("#monto_pagado").val();
			var ma_descripcion =$('#descripcion_cobrar').val();
			var idprovedor=$('#idprovedor').html();
			var data = {};
			data.ma_saldo = ma_saldo;
			data.id_ingreso = id_ingreso;
			data.ma_debe = ma_debe;
			data.ma_descripcion = ma_descripcion;
			data.idprovedor = idprovedor;
			$.ajax({
				type: "POST",
				url: "<?php echo base_url(); ?>movimiento/ingreso/pagar/registrar_pago",
				dataType: 'json',
				data: data,
				success: function(datos) {
					$('#monto_restante').val("");
					$('#monto_pagado').val("");
					$('#monto_restante').val("");
					$('#descripcion_cobrar').val("");
					$('#disminuirDeuda').modal('hide');
					swal({
						position: 'center',
						type: 'success',
						title: 'pagado',
						showConfirmButton: false,
						timer: 3000
					});
				}
			});

		});
    }

    function Cargar_Total_Cuentas_x_Pagar(){
        $.ajax({
            url:BASE_URL+'movimiento/ingreso/Pagar/Total_x_Pagar',
            type:'POST',
            dataType:'JSON',
            success:function(response){
                $('#total_x_pagar').html(response.TOTAL);
            }
        });
    }

    function cargarDatosDeuda(ing_id_ingreso=null){
        if(ing_id_ingreso){
            $.ajax({
                url:BASE_URL+'movimiento/ingreso/pagar/cargarDataDeuda/'+ing_id_ingreso,
                type:'post',
                dataType:'json',
                success:function(response){
                    $('#deuda_actual').val(response.ing_deuda);
                    $('#cliente').html(response.emp_razon_social);
                    $('#sal_id_salida').val(response.ing_id_ingreso);
                    $("#idprovedor").html(response.pcl_id_proveedor);
                }
            });
            setInterval( function () {
                table.ajax.reload( null, false ); // user paging is not reset on reload
            }, 3500 )
        }
    }
	function descontarDeuda(){
		var deuda_actual = $('#deuda_actual').val();
		var monto_pagado = $('#monto_pagado').val();
		var total = parseFloat(deuda_actual) - parseFloat(monto_pagado);
		$('#monto_restante').val(total.toFixed(2));
	}


	function editarDeuda(){
        var deuda = $('#monto_restante').val();
        var id = $('#sal_id_salida').val();
        var observacion =$('#descripcion_cobrar').val();
        var data = {};
        data.deuda = deuda;
        data.iddeuda = id;
        $.ajax({
            type: "POST",
            url: "<?php echo base_url(); ?>movimiento/ingreso/pagar/editarDeudas",
            dataType: 'json',
            data: data,
            success: function(datos) {
                $('#monto_pagado').val('');
                $('#monto_restante').val('');
                swal({
                    position: 'center',
                    type: 'success',
                    title: 'Deuda actualizada',
                    showConfirmButton: false,
                    timer: 3000
                });
            }
        });
    }


    function corregirDeudaxPagar(ing_id_ingreso=null){
        if(ing_id_ingreso){
            $.ajax({
                url:BASE_URL+'movimiento/ingreso/pagar/cargarDataDeuda/'+ing_id_ingreso,
                type:'post',
                dataType:'json',
                success:function(response){
                    $('#client').html(response.emp_razon_social);
                    $('#id_salida').val(response.ing_id_ingreso);
                }
            });
            setInterval( function () {
                table.ajax.reload( null, false ); // user paging is not reset on reload
            }, 3500 )
        }
    }

    function corregirDeuda(){
        var deuda = $('#corregir_debt').val();
        var id = $('#id_salida').val();
        var data = {};
        data.deuda = deuda;
        data.iddeuda = id;

        $.ajax({
            type: "POST",
            url: "<?php echo base_url(); ?>movimiento/ingreso/pagar/editarDeudas",
            dataType: 'json',
            data: data,
            success: function(datos) {
                $('#corregir_debt').val('');
                swal({
                    position: 'center',
                    type: 'success',
                    title: 'Monto de la deuda corregida',
                    showConfirmButton: false,
                    timer: 3000
                });
            }
        });
        return window.location.reload(true);
    }
    function cancelarfiltroxproveedor() {
    	location.reload();

	}
</script>
