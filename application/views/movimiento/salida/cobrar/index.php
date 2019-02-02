<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
        <h1>
            Registro de Cuentas Por Cobrar <small></small>
        </h1>
        <ol class="breadcrumb">
            <li>
                <a href="<?= base_url() ?>bienvenida"><i class="fa fa-home"></i> Movimiento</a>
            </li>
            <li class="active">Cuentas por cobrar</li>
        </ol>
    </section>
    <!-- Main content -->
    <section class="content">
        <!-- Your Page Content Here -->
        <div class="row">
            <div class="col-md-12">
                <div class="nav-tabs-custom">
                    <ul class="nav nav-tabs pull-right">
                        <li class="active"><a href="#dv_panel_eleccion" data-toggle="tab" id="a_panel_eleccion">Cuentas por cobrar</a></li>
                        <li class="pull-left header"><i class="fa fa-cart-arrow-down"></i> <span id="sp_etiqueta">Lista de Deudores</span></li>
                    </ul>
                    <div class="tab-content">
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
                                                <table id="clientes_deudores" class="table table-striped">
                                                    <thead>
                                                    <tr>
                                                        <th>Cliente</th>
                                                        <th>Fecha</th>
                                                        <th>Deuda</th>
                                                        <th>Operacion</th>
                                                    </tr>
                                                    </thead>
                                                    <tbody>
                                                    </tbody>
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

<!--MODAL DISMINUIR DEUDA-->
<div class="modal fade" id="disminuirDeuda" tabindex="-1" role="dialog" aria-labelledby="disminuirDeuda" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <h3 class="modal-title" id="disminuirDeuda">Deuda Actual de <strong id="cliente" class="text-danger text-bold"> </strong></h3>
            </div>
            <div class="modal-body">

                <input type="hidden"  id="sal_id_salida" name="sal_id_salida" class="form-control">
                <input type="hidden"  id="id_cliente" name="id_cliente" class="form-control">
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
                            <input type="text" id="monto_pagado" onkeypress="descontarDeuda();" autofocus="autofocus" name="monto_pagado" class="form-control" value="" placeholder="Ingresar Monto Pagado">
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="form-group col-md-12">
                        <div class="input-group" >
                            <span class="input-group-addon bg-gray ">Descripción: </span>
                            <textarea rows="2" cols="50" class="form-control" placeholder="Ingresar el motivo" required name="descripcion_pago" autofocus id="descripcion_pago"></textarea>
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
                <button type="button" id="movimiento_deuda" onclick="editarDeuda();" class="btn btn-primary">Guardar</button>
            </div>
        </div>
    </div>
</div>

<!--MODAL CORREGIR O EDITAR MONTO DE LA DEUDA-->
<div class="modal fade" id="editDeuda" tabindex="-1" role="dialog" aria-labelledby="editDeuda" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <h3 class="modal-title" id="disminuirDeuda">Corregir deuda actual de <strong id="client" class="text-danger text-bold"> </strong></h3>
            </div>
            <div class="modal-body">
                <input type="hidden" hidden id="id_salida" name="sal_id_salida" class="form-control">
                <div class="row">
                    <div class="form-group col-md-12">
                        <div class="input-group">
                            <span class="input-group-addon bg-gray ">Deuda: </span>
                            <input type="text" id="edit_deuda" name="edit_deuda" class="form-control" value="" placeholder="Ingresar monto de la deuda">

                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-small btn-danger" data-dismiss="modal">Cerrar</button>
                <button type="button" onclick="confirmarCorreciónDeuda();" class="btn btn-small btn-facebook">Modificar</button>
            </div>
        </div>
    </div>
</div>


<script>

    var table;
    function init_salida(){
        $(document).ready(function () {
            table = $('#clientes_deudores').DataTable({
                dom: 'Bfrtip',
                buttons: [
                    {
                        extend: 'print',
                        text: 'Imprimir',
                        exportOptions: {
                            columns: [ 0, 1, 2]
                        }
                    }
                ],
                'ajax':BASE_URL+'movimiento/salida/Cobrar/listarClientes',
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
                }

            });
        });
        $('#movimiento_deuda').click(function () {
            var mpago = $('#monto_pagado').val();
            var descripcion = $('#descripcion_pago').val();
            var saldo = $('#monto_restante').val();
            var id = $('#sal_id_salida').val();
            var id_cliente = $('#id_cliente').val();

            var data = {};
            data.monto_pago = mpago;
            data.descripcion = descripcion;
            data.saldo = saldo;
            data.id_salida = id;
            data.idcliente = id_cliente;

            $.ajax({
                type:'POST',
                url:'<?php echo base_url();?>movimiento/salida/Cobrar/registrar_movimiento_pago',
                dataType:'JSON',
                data:data,
                success:function (datos) {

                }
            });
        });
    }

    function descontarDeuda(){
        var deuda_actual = $('#deuda_actual').val();
        var monto_pagado = $('#monto_pagado').val();
        var total = parseFloat(deuda_actual) - parseFloat(monto_pagado);
        $('#monto_restante').val(total.toFixed(2));
    }

    function cargarDatosDeuda(sal_id_salida=null){
        if(sal_id_salida){
            $.ajax({
                url:BASE_URL+'movimiento/salida/Cobrar/cargarDataDeuda/'+sal_id_salida,
                type:'post',
                dataType:'json',
                success:function(response){
                    $('#deuda_actual').val(response.sal_deuda);
                    $('#cliente').html(response.emp_razon_social);
                    $('#sal_id_salida').val(response.sal_id_salida);
                    $('#id_cliente').val(response.pcl_id_cliente);
                }
            });
            setInterval( function () {
                table.ajax.reload( null, false ); // user paging is not reset on reload
            }, 3500 )
        }
    }

    function editarDeuda(){
        var deuda = $('#monto_restante').val();
        var id = $('#sal_id_salida').val();
        var data = {};
        data.deuda = deuda;
        data.iddeuda = id;

        $.ajax({
            type: "POST",
            url: "<?php echo base_url(); ?>movimiento/salida/Cobrar/editarDeuda",
            dataType: 'json',
            data: data,
            success: function(datos) {
                $('#monto_pagado').val('');
                $('#monto_restante').val('');
                $('#descripcion_pago').val('');
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

    function corregirDeuda(sal_id_salida=null){
        if(sal_id_salida){
            $.ajax({
                url:BASE_URL+'movimiento/salida/Cobrar/cargarDataDeuda/'+sal_id_salida,
                type:'post',
                dataType:'json',
                success:function(response){
                    $('#client').html(response.emp_razon_social);
                    $('#id_salida').val(response.sal_id_salida);
                }
            });
            setInterval( function () {
                table.ajax.reload( null, false ); // user paging is not reset on reload
            }, 3500 )
        }
    }

    function confirmarCorreciónDeuda(){
        var ndeuda = $('#edit_deuda').val();
        var id = $('#id_salida').val();
        var data = {};
        data.deuda = ndeuda;
        data.iddeuda = id;

        $.ajax({
            type: "POST",
            url: "<?php echo base_url(); ?>movimiento/salida/Cobrar/editarDeuda",
            dataType: 'json',
            data: data,
            success: function(datos) {
                $('#edit_deuda').val('');
                swal({
                    position: 'center',
                    type: 'success',
                    title: 'Monto de la deuda corregida',
                    showConfirmButton: false,
                    timer: 3000
                });
            }
        });
    }

</script>
