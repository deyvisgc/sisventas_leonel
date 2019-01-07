<?php
defined('BASEPATH') OR exit('No direct script access allowed');
?>
<style>
.style_linea_der {
	display: inline-block;
	margin-left: 460px;
	margin-top:"-30px";
}

.style_linea_dat {
	display: inline-block;
	margin-left: 40px;
	width: 260px;
	font-family: Arial;
	font-style:normal;	
	font-weight: bold;
	font-size:20px;
}

.style_linea_tab1 {
	display: inline-block;
	width: 80px;
	font-family: Arial;
	font-style:normal;
	font-weight: bold;
	font-size:20px;
}
.style_linea_tab2 {
	display: inline-block;
	margin-left: 0;
	width: 410px;
	font-family: Arial;
	font-style:normal;
	font-weight: bold;
	font-size:20px;
}
.style_linea_tab3 {
	display: inline-block;
	width: 120px;
	margin-left:100px;
	font-family: Arial;
	font-style:normal;
	font-weight: bold;
	font-size:20px;
}
.style_linea_tab4 {
	display: inline-block;
	width: 120px;	
	margin-left:15px;
	font-family: Arial;
	font-weight: bold;
	font-style:normal;
	font-size:20px;
}

.style_linea_pie {
	display: inline-block;
	margin-left: 740px;
	width: 270px;
	margin-top: 130px;
	font-family: Arial;
	font-weight: bold;
	font-style:normal;
	font-size:30px;
}

.style_espacio_0 {
	display: block;
	margin-top: 170px;
}
.style_espacio_1 {
	display: block;
	height: 10px;
}
.style_espacio_2 {
	display: block;
	height: 20px;
}
.style_espacio_3 {
	display: block;
	height: 10px;
}
.style_espacio_4 {
	display: block;
	height: 40px;
}
/* .style_espacio_5 {
	display: block;
	height: 30px;
} */
.style_espacio_6 {
	display: block;
	height: 6px;
}
.style_tabla {
	display: block;
	height: 480px;
}
</style>
<p></p>
<div class="style_espacio_0"></div>
<span class="style_linea_der">&nbsp;</span>

<div class="style_espacio_1"></div>
<span class="style_linea_der"></span>

<div class="style_espacio_2"></div>
<span class="style_linea_dat" style="margin-left: 80px;"><?= $salida->emp_razon_social ?></span>
<span class="style_linea_dat" style="margin-left: 400px;margin-top:-20px"><?= $salida->emp_ruc ?></span>

<div class="style_espacio_3"></div>
<span class="style_linea_dat" style="margin-left: 80px;"><?= $salida->emp_direccion ?></span>
<span class="style_linea_dat" style="margin-left: 400px;margin-top:-20px"><?= $salida->sal_fecha_doc_cliente ?></span>
<div class="style_espacio_4"></div>

<div class="style_tabla">
<?php

foreach ($list_salida_detalle as $salida_detalle) {
?>
<span class="style_linea_tab1" style=""><?= $salida_detalle->sad_cantidad ?></span>
<span class="style_linea_tab2" style=""><?= $salida_detalle->pro_nombre ?></span>
<span class="style_linea_tab3" style=""><?= $salida_detalle->sad_valor ?></span>
<span class="style_linea_tab4" style=""><?= $salida_detalle->sad_monto ?></span>
<div class="style_espacio_6"></div>
<?php
}
?>
</div>
<span class="style_linea_pie" ><?= $salida->sal_monto ?></span>