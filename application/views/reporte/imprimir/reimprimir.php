<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<style>
    .modal {
        text-align: center;
        padding: 0!important;
    }

    .modal:before {
        content: '';
        display: inline-block;
        height: 100%;
        vertical-align: middle;
        margin-right: -4px;
    }

    .modal-dialog {
        display: inline-block;
        text-align: left;
        vertical-align: middle;
    }
</style>
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
            <li class="active">Reimprimir documentos.</li>
        </ol>
    </section>
    <!-- Main content -->
    <section class="content">
        <!-- Your Page Content Here -->
        <div class="row">
            <div class="col-md-12">
                <div class="nav-tabs-custom">
                    <ul class="nav nav-tabs pull-right" style="background-color: #7b41d4;">
                        <li style="color: white;"><a href="#dv_despacho" data-toggle="tab" id="dv_despachos">Guía Despacho</a></li>
                        <li class="active" style="color: white;"><a href="#dv_reporte" data-toggle="tab" id="dv_reportes">Ventas</a></li>
                        <li class="pull-left header" style="color: white;"><i class="fa fa-chart-line"></i>  Reporte de Ventas</li>
                    </ul>
                    <br>
                    <div class="tab-content">
                        <div class="tab-pane active" id="dv_reporte">
                            <div class="row">
                                <div class="col-sm-12 table-responsive">
                                    <p></p>
                                    <table class="table table-responsive table-bordered" id="tb_ventas">
                                        <thead>
                                        <tr>
                                            <th>Cliente</th>
                                            <th>Fecha</th>
                                            <th>Importe de Venta</th>
                                            <th class="text-center">OPCIONES</th>
                                        </tr>
                                        </thead>
                                        <tbody >
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div class="tab-pane" id="dv_despacho">
                            <div class="row">
                                <div class="col-sm-12 col-lg-12 table-responsive">
                                    <p></p>
                                    <!--method="POST" action="reporte/imprimir/imprimir/Imprimir_Reporte_Despacho"-->
                                    <form id="myform">

                                        <button type="button" data-toggle="modal" data-target="#guia" data id="btn_guia" class="btn btn-facebook pull-right" style="margin-right: 10px;">
                                            <i class="fa fa-car"></i> GENERAR GUÍA
                                        </button>
                                        <br><br><br>

                                        <pre id="ids" name="ids" class="form-control"></pre>

                                        <p class="text-bold">Guía seleccionadas:</p>

                                        <input readonly="readonly" type="text" id="id_guia" name="id_guia" class="form-control col-md-6 col-lg-6">

                                        <br><br><br>

                                        <table class="table table-responsive table-bordered" id="tb_generar_guias" style="width: 100%">
                                            <thead>
                                            <tr>

                                                <th class="text-center"></th>
                                                <th>Cliente</th>
                                                <th>Fecha</th>
                                                <th>Importe de Venta</th>
                                            </tr>
                                            </thead>
                                            <tbody class="text-center">
                                            </tbody>
                                        </table>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id="dv_contenedor_impresion" style="display: none;"></div>
        <div id="dv_imprimir_guia" style="display: none;"></div>
    </section><!-- /.content -->
</div><!-- /.content-wrapper -->

<div class="modal" id="guia" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <h3 class="modal-title">GENERANDO GUÍA</h3>
            </div>
            <div class="modal-body">
                <p class="text-justify">Está seguro de procesar la guía.Revise todos los items seleccionados.</p>
            </div>
            <div class="modal-footer">
                <button id="btn_guia" onclick="func_mostrar_guia_despacho();" class="btn btn-facebook">
                    <i class="fa fa-car"></i> GENERAR GUÍA
                </button>
                <button type="button" class="btn btn-danger" data-dismiss="modal"><i class="fa fa-times-circle"></i> Cancelar</button>
            </div>
        </div>
    </div>
</div>

<script>
    var table;
    var id_venta;
    var form = "myform";

    function init_salida(){
        $(document).ready(function () {
            $('#ids').hide();
            table = $('#tb_ventas').DataTable({

                'order': [[ 1, "desc" ]],
                'ajax':BASE_URL+'reporte/imprimir/imprimir/listarVentas',

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

            var mytable = $("#tb_generar_guias").DataTable({
                ajax:{
                    'url':BASE_URL+'reporte/imprimir/imprimir/Listar_Ventas_Imprimir_Guias',
                    'dataSrc':''
                },
                columns:[
                    {'data':'sal_id_salida'},
                    {'data':'emp_razon_social'},
                    {'data':'sal_fecha_doc_cliente'},
                    {'data':'sal_monto'}
                ],
                'columnDefs': [
                    {
                        'targets': 0,
                        'checkboxes': {
                            'selectRow': true
                        }
                    }
                ],
                select: {
                    style:    'multi'
                }

            });


            $('#btn_guia').on('click', function(e){


                var rows_selected = mytable.column(0).checkboxes.selected();

                // Iterate over all selected checkboxes
                $.each(rows_selected, function(index, rowId){
                    // Create a hidden element
                    $(form).append(
                        $('<input>')
                            .attr('type', 'hidden')
                            .attr('name', 'ids')
                            .val(rowId)
                    );
                });
                id_venta = rows_selected.join(",");
                $('#ids').text(id_venta);
                $('#id_guia').val(id_venta);
                // Output form data to a console
                // Remove added elements
                $('input[name="ids"]', form).remove();
                // Prevent actual form submission
                e.preventDefault();
            });

        });


    }

    function cargarDatosInput() {

    }

    //CARGAR DATA PARA IMPRIMIR LA GUIA DE DESPACHO
    function func_mostrar_guia_despacho() {
        var data ={};
        data.id_guia = $('#id_guia').val();
        $.ajax({
            type: "POST",
            url: BASE_URL+"reporte/imprimir/imprimir/Imprimir_Reporte_Despacho",
            data:data,
            success: function(datos) {
                $('#dv_imprimir_guia').empty();
                $('#dv_imprimir_guia').append(datos);
                func_imprimir_guia_despacho();
            }
        });
    }
    //IMPRIMIR DETALLE DE COMPRA
    function func_mostrar_documento(sal_id_salida) {
        var data = {};
        data.sal_id_salida = sal_id_salida;
        $.ajax({
            type: "POST",
            url: BASE_URL+"movimiento/salida/cliente/mostrar_documento",
            data: data,
            success: function(datos) {
                $('#dv_contenedor_impresion').empty();
                $('#dv_contenedor_impresion').append(datos);
                func_imprimir();
            }
        });
    }

    function func_eliminar_venta(sal_id_salida){
        var data = {};
        data.sal_id_salida = sal_id_salida;
        $.ajax({
            type:'POST',
            url:BASE_URL+'reporte/imprimir/Imprimir/Eliminar_Venta',
            data: data,
            success:function (datos) {
                swal({
                    position: 'center',
                    type: 'success',
                    title: 'Se anulo correctamente la venta',
                    showConfirmButton: false,
                    timer: 3000
                });
                filtrar_movimiento_diario_salida();
            }
        });
    }

    function func_imprimir() {
        var divToPrint = document.getElementById('dv_contenedor_impresion');
        var newWin = window.open('','Print-Window');
        newWin.document.open();
        newWin.document.write('<ht'+'ml><bo'+'dy onload="window.print()">'+divToPrint.innerHTML+'</'+'bo'+'dy></'+'ht'+'ml>');
        newWin.document.close();
        setTimeout(function(){
            newWin.close();
        }, 10);
    }

    function func_imprimir_guia_despacho() {
        var divToPrint = document.getElementById('dv_imprimir_guia');
        var newWin = window.open('','Print-Window');
        newWin.document.open();
        newWin.document.write('<html><head><title>Imprimir</title>');
        newWin.document.write('<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" type="text/css" />');
        newWin.document.write('</head><body onload="window.print();window.close()">');
        newWin.document.write(divToPrint.innerHTML);
        newWin.document.write('</body></html>');
        newWin.document.close();
        setTimeout(function(){
            newWin.close();
        }, 10);
    }

    function filtrar_movimiento_diario_salida() {
        $('#tb_ventas').DataTable().ajax.reload();
    }
</script>