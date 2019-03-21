<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<!-- Content Wrapper. Contains page content -->
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
            <li class="active">Mov. Produccion.</li>
        </ol>
    </section>
    <!-- Main content -->
    <section class="content">
        <!-- Your Page Content Here -->
        <div class="row">
            <div class="col-12 grid-margin">
                <div class="nav-tabs-custom">
                    <ul class="nav nav-tabs pull-right" style="background-color: #f7d800">
                        <li class="active"><a href="#dv_panel_eleccion" data-toggle="tab" id="a_panel_eleccion">Eleccion
                                productos</a></li>
                        <li class="pull-left header"><i class="fa fa-cart-arrow-down"></i> <span id="sp_etiqueta">Productos.</span>
                        </li>
                    </ul>
                    <div class="tab-content"">
                        <!-- TAB ELECCION -->
                        <div class="tab-pane active" id="dv_panel_eleccion">


                                <div class="row" >
                                        <div class="col-md-12 grid-margin">
                                            <div>
                                                <div>
													<div class="row">
														<div class="col-lg-4 col-sm-4 col-md-4 col-xs-12">
															<div class="input-group">
																<div class="input-group-btn">
																	<button type="button" class="btn btn-success" id="bt_descripcion" disabled=""><i class="fa fa-search"></i></button>
																</div>
																<input type="text" class="form-control" autofocus="autofocus" id="in_descripcion_p" placeholder="Producto" style="font-size:20px; text-align:center; color: blue; font-weight: bold;">
																<input type="hidden" id="in_pro_id_producto" value="">
															</div>
														</div>
														<div class="col-lg-4 col-sm-4 col-md-4 col-xs-12">
															<div class="input-group">
																<span class="input-group-addon bg-gray">Precio Producción </span>
																<input type="number" class="form-control precios" id="in_valor" style="font-size: 20px; text-align: right; color: blue; font-weight: bold;" data-inputmask="'alias': 'numeric', 'autoGroup': true, 'digits': 2, 'digitsOptional': false, 'placeholder': '0'">
															</div>
														</div>
														<div class="col-lg-4 col-sm-4 col-md-4 col-xs-12" style="margin-left: -3px">
															<div class="input-group">
																<span class="input-group-addon bg-gray">Precio Venta </span>
																<input type="number" class="form-control precios" id="in_valor_venta" style="font-size: 20px; text-align: right; color: blue; font-weight: bold;" data-inputmask="'alias': 'numeric', 'autoGroup': true, 'digits': 2, 'digitsOptional': false, 'placeholder': '0'">
															</div>
														</div>
													</div><br>
												<div class="row">

													<div class="col-lg-4 col-sm-4 col-md-4 col-xs-12">
														<div class="input-group">
															<span class="input-group-addon bg-gray"><i class="fa fa-calendar"></i></span>
															<input type="date" class="form-control cantidades"
																   id="in_fecha_vencimiento"
																   style="font-size: 20px; text-align: right; color: blue; font-weight: bold;"
																   data-inputmask="'alias': 'numeric', 'autoGroup': true, 'digits': 2, 'digitsOptional': false, 'placeholder': '0'">
														</div>
													</div>
													<div class="col-lg-4 col-sm-4 col-md-4 col-xs-12" >
														<div class="input-group">
															<span class="input-group-addon bg-gray">Clase</span>
															<select class="form-control" id="clase" name="clase" onchange="mostrarSublase(null)">
															</select>
														</div>
													</div>
													<div class="col-lg-4 col-sm-4 col-md-4 col-xs-12">
														<div class="input-group">
															<span class="input-group-addon bg-gray">SubClase</span>
															<select class="form-control" id="subclase" name="sublcase">
															</select>
														</div>
													</div>
												</div><br>
													<div class="row">
														<div class="col-lg-4 col-sm-4 col-md-4 col-xs-12">
															<div class="input-group">
																<span class="input-group-addon bg-gray">Codigo</span>
																<input type="text" class="form-control cantidades" id="codigo">
															</div>
														</div>
														<div class="col-lg-4 col-sm-4 col-md-4 col-xs-12">
															<div class="input-group">
																<span class="input-group-addon bg-gray">Cantidad</span>
																<input type="text" class="form-control cantidades" id="in_cantidad">
															</div>
														</div>
														<div class="col-lg-4 col-sm-4 col-md-4 col-xs-12">
															<div class="input-group">
																<span class="input-group-addon bg-gray">Lote</span>
																<input type="text" class="form-control cantidades" id="in_numero_lote">
															</div>
														</div>
													</div><br>
												<center>
													<div class="btn-group">
										<button class="btn  btn-success" id="bt_registrar_producto"><i class="fa fa-money"></i> Registrar</button>
													</div></center>
                                        </div><!-- ./col -->
                                    	</div>
                                </div>
                            </div>

                    </div>
                </div>
        </div>
    </section><!-- /.content -->
</div><!-- /.content-wrapper -->

<script>
    function init_produccion() {

        $("#in_descripcion_p").autocomplete({
            source: function (request, response) {
                $.ajax({
                    url: BASE_URL + 'movimiento/ingreso/detalle/buscar_productos_x_descripcion',
                    dataType: "json",
                    type: "POST",
                    data: {
                        descripcion: request.term
                    },
                    success: function (data) {
                        if (data.list_producto.length === 0) {
                            add_mensaje(null, " Productos. ", ' 0 encontrados.', "info");
                        }
                        response(data.list_producto);
                    }
                });
            },
            delay: 100,
            minLength: 1,
            select: function (event, ui) {
                 $('#in_pro_id_producto').val(ui.item.pro_id_producto);
            }
        });

        var objeto = {
            ajax: {
                url: BASE_URL + 'movimiento/ingreso/detalle/buscar_productos_elejidos',
                type: 'POST',
                data: {},
                "dataSrc": function (json) {
                    $('.sp_count_productos').text(json.tcompra.count_productos);
                    $('.sp_sum_total').text(json.tcompra.sum_total);
                    return json.data;
                }
            },
            columns: [
                {data: "codigo"},
                {data: "descripcion"},
                {data: "numero_lote"},
                {data: "fecha_vencimiento"},
                {data: "uni_med"},
                {data: "cantidad"},
                {data: "precio"},
                {data: "total"},
                {
                    data: null,
                    "render": function (data, type, full, meta) {
                        return '<button class="btn btn-danger  btn-sm" type="button" onclick="func_quitar_producto(event)"><i class="fa fa-times" aria-hidden="true"></i> Quitar</button>' +
                            '<input type="hidden" name="pro_id_producto" value="' + full.pro_id_producto + '">';
                    }
                }
            ],
            ordering: false,
            searching: false,
            info: false,
            paging: false
        };

        generar_data_table('tb_ingreso_detalle', objeto);

        $('#bt_cancelar_producto').click(func_cancelar_producto);
        $('#bt_agregar_producto').click(func_agregar_producto);
        $('#bt_registrar_producto').click(func_registrar_producto);
        add_mensaje(null, 'OK ', ' Ingrese sus productos.', 'info');

		func_clase();
		var fecha_actual_hoy = get_fhoy();
		$('#in_fecha_vencimiento').val(fecha_actual_hoy);

    }
function func_clase(clases ,subclase){
    	if (clases==null){
			clases='';
		}

    	$.ajax({
			type: "POST",
			url: "<?php echo base_url(); ?>movimiento/ingreso/detalle/buscar_clases",
			dataType: 'json',
			success: function (datos) {
				if (datos.hecho=='SI'){
					var select=$('#clase');
					select.empty();
					vlista_clases = [];
                   datos.list_clase.forEach(function (clase) {
                   	var selecedt='';
                   	if (clases==clase.cla_id_clase){
						selecedt = 'selected';
					}

					   if (clase.cla_id_clase_superior == '') {
						   select.append('<option value="' + clase.cla_id_clase + '" ' + selecedt + '>' + clase.cla_nombre + '</option>');
					   }
					   else {
						   vlista_clases.push({
							   cla_id_clase: clase.cla_id_clase,
							   cla_nombre: clase.cla_nombre,
							   cla_id_clase_superior: clase.cla_id_clase_superior
						   });
					   }
					   
				   });
                   mostrarSublase(subclase);


				}
			}
		});

}
function mostrarSublase(subclase){
    	if(subclase== null){
    		subclase= '';
    		var nombre_clase=$('#clase').val();
    		var select=$('#subclase');
    		select.empty();
			vlista_clases.forEach(function (clase) {
				var selected = '';
				if (subclase == clase.cla_id_clase) {
					selected = 'selected';
				}
				if (nombre_clase == clase.cla_id_clase_superior) {
					select.append('<option value="' + clase.cla_id_clase + '" ' + selected + '>' + clase.cla_nombre + '</option>');
				}
			});


		}

}


    function func_cancelar_todo(e) {
        func_cancelar_producto(null);
        $('#in_texto_proveedor').val('');
        $('#in_pcl_id_proveedor').val('');
        $('#in_texto_ruc').val('');
        $('#in_ing_fecha_doc_proveedor').val(get_fhoy());
        $('#in_ing_numero_doc_proveedor').val('');
        $('#in_ing_monto_efectivo').val('');
        $('#in_ing_monto_tar_credito').val('');
        $('#in_ing_monto_tar_debito').val('');
    }

    function func_cancelar_producto(e) {
        $('#in_descripcion_p').val('');
        $('#in_valor').prop('disabled', true);
        $('#in_valor').val('');
        $('#in_cantidad').prop('disabled', true);
        $('#in_cantidad').val('');
        $('#in_numero_lote').prop('disabled', true);
        $('#in_numero_lote').val('');
        $('#in_fecha_vencimiento').prop('disabled', true);
        $('#in_fecha_vencimiento').val('');
        $('#in_pro_id_producto').val('');
        $('#img_foto').attr("src", BASE_URL + '../resources/sy_file_repository/img_vacio.png');
        $('#sp_precio_unitario').text('0.00');
        $('#sp_uni_med_nombre').text('...');
        $('#sp_stock').text('0.00');
    }

    function func_quitar_producto(e) {
        var tr = $(e.target).closest('tr');
        var pro_id_producto = tr.find('input[name="pro_id_producto"]').val();
        var data = {};
        data.pro_id_producto = pro_id_producto;
        $.ajax({
            type: "POST",
            url: BASE_URL + "movimiento/ingreso/detalle/quitar_producto",
            dataType: 'json',
            data: data,
            success: function (datos) {
                if (datos.hecho == 'SI') {
                    add_mensaje(null, " Correcto. ", _msj_system[datos.estado], "success");
                    $('#tb_ingreso_detalle').DataTable().ajax.reload();
                }
                else {
                    add_mensaje(null, " Alerta. ", _msj_system[datos.estado], "warning");
                }
            }
        });
    }
    function func_registrar_producto() {

        var nombre_product = $('#in_descripcion_p').val();
        var id_producto = $('#in_pro_id_producto').val();


        var valor = $('#in_valor').val();

        if (valor == '') {
            add_mensaje(null, '!!! ', ' Ingrese precio.', 'warning');
            return;
        }
        var valor_venta = $('#in_valor_venta').val();
        if (valor_venta == '') {
            add_mensaje(null, '!!! ', ' Ingrese precio.', 'warning');
            return;
        }
        var cantidad = $('#in_cantidad').val();
        if (cantidad == '') {
            add_mensaje(null, '!!! ', ' Ingrese cantidad.', 'warning');
            return;
        }
        var numero_lote = $('#in_numero_lote').val();
        if (numero_lote == '') {
            add_mensaje(null, '!!! ', ' Ingrese #Lote.', 'warning');
            return;
        }
        var fecha_vencimiento = $('#in_fecha_vencimiento').val();
        if (!$('#in_fecha_vencimiento').prop('disabled')) {
            if (fecha_vencimiento == '') {
                add_mensaje(null, '!!! ', ' Ingrese fecha de vencimiento.', 'warning');
                return;
            }
        }
        var data = {};
        data.id_producto = id_producto;
        data.valor = valor;
        data.valor_venta = valor_venta;
        data.cantidad = cantidad;
        data.numero_lote = numero_lote;
        data.fecha_vencimiento = fecha_vencimiento;
        data.nombre_product = nombre_product;
		data.nom_Clase=$('#clase').val();
		data.sub_Clase=$('#subclase').val();
		data.codigo=$('#codigo').val();


        $.ajax({
            type: "POST",
            url: BASE_URL + "movimiento/ingreso/detalle/registrar_producto",
            dataType: 'json',
            data: data,
            success: function (datos) {

                Swal.fire({
                    position: 'center',
                    type: 'success',
                    title: 'Proceso Completado',
                    showConfirmButton: false,
                    timer: 1500
                });

                $('#in_descripcion_p').val("");
                $('#in_valor').val("");
                $('#in_valor_venta').val("");
                $('#in_cantidad').val("");
                $('#in_numero_lote').val("");
                $('#in_fecha_vencimiento').val("");
				$('#codigo').val("");
            }
        });
    }



    function func_agregar_producto(e) {
        var pro_id_producto = $('#in_pro_id_producto').val();
        if (pro_id_producto == '') {
            add_mensaje(null, '!!! ', ' Ingrese producto.', 'warning');
            return;
        }
        var valor = $('#in_valor').val();
        if (valor == '') {
            add_mensaje(null, '!!! ', ' Ingrese precio.', 'warning');
            return;
        }
        var cantidad = $('#in_cantidad').val();
        if (cantidad == '') {
            add_mensaje(null, '!!! ', ' Ingrese cantidad.', 'warning');
            return;
        }
        var numero_lote = $('#in_numero_lote').val();
        if (numero_lote == '') {
            add_mensaje(null, '!!! ', ' Ingrese #Lote.', 'warning');
            return;
        }
        var fecha_vencimiento = $('#in_fecha_vencimiento').val();
        if (!$('#in_fecha_vencimiento').prop('disabled')) {
            if (fecha_vencimiento == '') {
                add_mensaje(null, '!!! ', ' Ingrese fecha de vencimiento.', 'warning');
                return;
            }
        }
        var data = {};
        data.pro_id_producto = pro_id_producto;
        data.valor = valor;
        data.cantidad = cantidad;
        data.numero_lote = numero_lote;
        data.fecha_vencimiento = fecha_vencimiento;


        $.ajax({
            type: "POST",
            url: BASE_URL + "movimiento/ingreso/detalle/agregar_producto",
            dataType: 'json',
            data: data,
            success: function (datos) {
                if (datos.hecho == 'SI') {
                    add_mensaje(null, " Correcto. ", _msj_system[datos.estado], "success");
                    func_cancelar_producto(null);
                    $('#tb_ingreso_detalle').DataTable().ajax.reload();
                }
                else {
                    add_mensaje(null, " Alerta. ", _msj_system[datos.estado], "warning");
                }
            }
        });
    }


</script>

