<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">

    </section>
    <!-- Main content -->
    <section class="content">
        <!-- Your Page Content Here -->
        <div class="row">
            <div class="col-md-12">
                <div class="nav-tabs-custom">
                    <ul class="nav nav-tabs pull-right" style="background-color: #7b41d4;">

                    </ul>
                    <br>
                    <div class="tab-content">
                        <div class="tab-pane active" id="dv_reporte">
                            <div class="row">
                                <div class="col-sm-12 table-responsive">
                                    <p></p>

                                    <h1 class="text-center">GUIA DE DESPACHO</h1>

                                    <table class="table table-striped" style="width=100%;" id="tb_guia">
                                        <thead class="table-bordered text-center">
                                        <tr>
                                            <th class="text-center text-bold">Producto</th>
                                            <th class="text-center text-bold">Cantidad</th>
                                        </tr>
                                        </thead>
                                        <tbody>

                                        <?php foreach ($data as $key): ?>
                                        <tr class="text-center">
                                            <td class="text-center" style="margin-left: 20px"><?php echo $key['PRODUCTO']; ?></td>
                                            <td class="text-center" style="margin-left: 20px"><?php echo $key['CANTIDAD']; ?></td>
                                        </tr>
                                        <?php endforeach ?>
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
</div><!-- /.content-wrapper -->
