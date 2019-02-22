<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Kardex_model extends CI_Model
{
    function Cargar_Data_Productos() {
        $query = $this->db->query("SELECT p.pro_id_producto,IFNULL((SELECT cc.cla_nombre FROM clase cc WHERE cc.cla_id_clase=p.cla_clase),'') clase_nombre, 
			  IFNULL((SELECT cc.cla_nombre FROM clase cc WHERE cc.cla_id_clase=p.cla_subclase),'') subclase_nombre, pro_nombre, 
			  FORMAT(pro_cantidad, 0, 'de_DE') pro_cantidad, pro_val_compra pro_val_compra, pro_val_venta pro_val_venta
			FROM producto p GROUP BY clase_nombre,subclase_nombre,pro_nombre");
        return $query->result_array();
    }
}
