<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<link href="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
<script src="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<!------ Include the above in your HEAD tag ---------->

<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <!--Made with love by Mutiullah Samim -->

    <link rel="icon" type="image/png" href="<?= base_url() ?>../imagen/gvm.ico" />
    <!--Bootsrap 4 CDN-->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">

    <!--Fontawesome CDN-->
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.3.1/css/all.css" integrity="sha384-mzrmE5qonljUremFsqc01SB46JvROS7bZs3IO2EmfFsd15uHvIt+Y8vEf7N7fWAU" crossorigin="anonymous">

    <!--Custom styles-->
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>

<style>
    /* Made with love by Mutiullah Samim*/


    html,body{
        background-image: url('<?= base_url() ?>/imagen/logo.png ');
        background-size: cover;
        background-repeat: no-repeat;
        height: 100%;
    }

    .container{
        height: 100%;
        align-content: center;
    }

    .card{
        height: 400px;
        margin-top: auto;
        margin-bottom: auto;
        width: 350px;
        background-color: rgba(0,0,0,0.5) !important;
    }

    .card-header h3{
        color: white;
    }


    .input-group-prepend span{
        width: 40px;
        background-color: #FFC312;
        color: black;
        border:0 !important;
    }

    input:focus{
        outline: 0 0 0 0  !important;
        box-shadow: 0 0 0 0 !important;

    }

    .remember{
        color: white;
    }

    .remember input
    {
        width: 20px;
        height: 20px;
        margin-left: 15px;
        margin-right: 5px;
    }

    .login_btn{
        color: black;
        background-color: #FFC312;
        width: 200px;
        margin-top: 20px;
        margin-bottom: -20px;
    }

    .login_btn:hover{
        color: black;
        background-color: white;
    }

    .links{
        color: white;
    }

    .links a{
        margin-left: 4px;
    }
</style>

<body>
<div class="container">
    <div class="d-flex justify-content-center h-100">
        <div class="card">
            <div class="card-header"><br>
                <h3 class="text-center text-bold text-uppercase">Punto de Venta</h3>
                <div class="d-flex justify-content-end social_icon">
                </div>
            </div>
            <div class="card-body">
                <form class="form-signin" action="<?php echo base_url(); ?>logueo/acceder" method="POST"><br>
                    <div class="input-group form-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text"><i class="fas fa-user"></i></span>
                        </div>
                        <input type="text" id="in_usu_nombre" autofocus name="usu_nombre" class="form-control" placeholder="Usuario" required >
                    </div>
                    <div class="input-group form-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text"><i class="fas fa-key"></i></span>
                        </div>
                        <input type="password" id="in_usu_clave" name="usu_clave" class="form-control" placeholder="Clave" required>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="text-center">
                                <div class="form-group">
                                    <input class="btn login_btn" value="INGRESAR" type="submit" >
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="card-footer">
                <div class="d-flex justify-content-center links">
                    Copyright © 2019 Derechos reservados
                </div>
                <div class="d-flex justify-content-center links">
                    Implementado por: <a href="http://gruposystemvv.com/" class="d-flex justify-content-center links">  GSVV</a>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
