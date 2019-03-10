<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/**
 * Created by PhpStorm.
 * User: Def-CON
 * Date: 31-Jan-19
 * Time: 17:42
 */

class Mayor_model extends CI_Model
{
    function cargar_movimiento_pagos_x_cliente($id_cliente){
        $consulta="SELECT ma.ma_fecha, ma.ma_descripcion,ma.ma_debe,ma.ma_haber,ma.ma_saldo 
        FROM mayor as ma WHERE ma.pcl_id_cliente='$id_cliente'";
        $data = $this->db->query($consulta);
        return $data->result_array();
    }

}