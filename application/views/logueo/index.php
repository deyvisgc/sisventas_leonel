<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>LOGUEO</title>
    <link rel="icon" type="image/png" href="<?= base_url() ?>../imagen/gvm.ico" />
    <link rel="stylesheet" href="<?= base_url() ?>../js/bootstrap.min.css">
    <script src="<?= base_url() ?>../js/jquery.min.js"></script>
    <script src="<?= base_url() ?>../js/bootstrap.min.js"></script>
    <link rel="icon" type="image/png" href="<?= base_url() ?>../imagen/gvm.ico" />

    <!-- <link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/themes/base/jquery-ui.css"> -->
    <link rel="stylesheet" href="<?= base_url() ?>../resources/css/ui-1-12-1/jquery-ui.css">
    <link rel="stylesheet" type="text/css" href="<?= base_url() ?>../resources/css/ui-1-8-16/jquery-ui.css">

    <!-- <link rel="stylesheet" href="//resources/demos/style.css"> -->
    <!-- Main CSS -->
    <link rel="stylesheet" href="<?= base_url() ?>../resources/css/main.css">
    <!-- Ionicons -->
    <link rel="stylesheet" href="<?= base_url() ?>../resources/dist/css/ionicons.css">
    <!-- iCheck -->
    <link rel="stylesheet" href="<?= base_url() ?>../resources/plugins/iCheck/square/blue.css">

    <style>
        form {
            max-width: 360px;
            border: 2px solid #dedede;
            padding: 38px;
            margin-top: 120px;
            border-radius: 25px;
            background-color: rgba(0,0,0,0.4) !important;
        }
        html,body{
            background-color: white;
            background-size: cover;
            background-repeat: no-repeat;
            height: 100%;
            align-content: center;
        }


        form h1{
            color: white;
            font-size: 30px;
        }

        .footer{
            color:white ;
        }
        .footer .link{
            color:white;
            font-size:20px;

        }

        .form #span{
            width: 40px;
            background-color: #FFC312;
            color: black;
            border:0 !important;
        }


        .login_btn{
            color: black;
            background-color: #FFC312;
            width: 200px;
            margin-top: 20px;
            margin-bottom: 15px;
        }

        .login_btn hover{
            background-color: white;
        }

    </style>
</head>
<body>
<center>
    <form class="form-signin" action="<?php echo base_url(); ?>logueo/acceder" method="POST">
        <h1>PUNTO DE VENTA</h1>
        <hr>
        <br>

        <div class="form-group col-md-12">
            <div class="input-group">
                <span class="input-group-addon" style="background-color: #FFC312;color: #0f0f0f"><i class="fa fa-user"></i></span>
                <input type="text" id="in_usu_nombre" autofocus name="usu_nombre" class="form-control col-md-12" placeholder="Usuario" required >
            </div>
        </div>

        <div class="form-group col-md-12">
            <div class="input-group">
                <span class="input-group-addon" style="background-color: #FFC312; color: #0f0f0f"><i class="fa fa-lock"></i></span>
                <input type="password" id="in_usu_clave" name="usu_clave" class="form-control" placeholder="Contraseña" required>
            </div>
        </div>

        <button class="btn login_btn"  type="submit">Ingresar</button>
        <br>
        <hr>
        <a class="footer">
            <br>Copyright © 2018 Derechos reservados  <br>
            Implementado por:<a href="http://gruposystemvv.com/" class="link" style="color: yellow; font-family: 'Segoe UI Semilight', 'Open Sans', Verdana, Arial, Helvetica, sans-serif; font-weight: bold;"> GSVV</a>
        </a>
    </form>
</center>
</body>
</html>


