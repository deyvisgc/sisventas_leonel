<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
        <h1>
            Registro de Ventas<small></small>
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
                    <ul class="nav nav-tabs pull-right">
                        <li class="pull-left header"><i class="fa fa-atlas"></i> Ventas</li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane active" id="dv_reporte">
                            <div class="row">
                                <div class="col-sm-12 box-body table-responsive">
                                    <p></p>
                                    <table class="table table-responsive table-bordered" id="tb_ventas">
                                        <thead>
                                        <tr>
                                            <th>Empresa</th>
                                            <th>Fecha</th>
                                            <th>Importe de Venta</th>
                                            <th>OPCIONES</th>
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
        <div id="dv_contenedor_impresion" style="display: none;"></div>
    </section><!-- /.content -->
</div><!-- /.content-wrapper -->
<script>
    var table;
    function init_salida(){

        $(document).ready(function () {
            table = $('#tb_ventas').DataTable({
                dom: 'Bfrtip',
                buttons: [
                    {
                        extend: 'print',
                        text: 'Imprimir',
                        className: 'excelButton',
                        exportOptions: {
                            columns: [ 0, 1, 2]
                        }
                    }
                ],
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
        });
    }
    function func_mostrar_documento(sal_id_salida) {
        var data = {};
        data.sal_id_salida = sal_id_salida;
        $.ajax({
            type: "POST",
            url: BASE_URL+"reporte/salida/cliente/mostrar_documento",
            data: data,
            success: function(datos) {
                $('#dv_contenedor_impresion').empty();
                $('#dv_contenedor_impresion').append(datos);
                func_imprimir();
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
</script>