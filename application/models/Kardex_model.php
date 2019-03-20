<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Kardex_model extends CI_Model
{
    function Cargar_Data_Productos() {
        $query = $this->db->query("SELECT p.pro_id_producto,IFNULL((SELECT cc.cla_nombre FROM clase cc WHERE cc.cla_id_clase=p.cla_clase),'') clase_nombre, 
			  IFNULL((SELECT cc.cla_nombre FROM clase cc WHERE cc.cla_id_clase=p.cla_subclase),'') subclase_nombre, pro_nombre, 
			  FORMAT(pro_cantidad, 0, 'de_DE') pro_cantidad, pro_val_compra pro_val_compra, pro_val_venta pro_val_venta
			FROM producto p where p.pro_cantidad >=1 GROUP BY clase_nombre,subclase_nombre,pro_nombre");
        return $query->result_array();
    }

    function Kardex_Entradas($id_producto){
        $query = $this->db->query("
        
        SELECT DATE_FORMAT(ing.ing_fecha_registro,'%d-%m-%Y') as ing_fecha_registro,ingd.ind_cantidad,ingd.ind_valor, FORMAT(ROUND((ingd.ind_valor * ingd.ind_cantidad),1),2) AS precio_compra,ingd.tipo_entrada
            FROM ingreso as ing, ingreso_detalle as ingd,producto as p 
            where ingd.ing_id_ingreso=ing.ing_id_ingreso AND p.pro_id_producto=ingd.pro_id_producto
            AND ingd.pro_id_producto =$id_producto  UNION ALL
            
            SELECT   DATE_FORMAT(ingreso_detalle.ing_fecha_registro,'%d-%m-%Y') as ing_fecha_registro,ingreso_detalle.ind_cantidad,ingreso_detalle.ind_valor,ingreso_detalle.ind_monto,ingreso_detalle.tipo_entrada FROM ingreso_detalle WHERE ingreso_detalle.tipo_entrada=\"produccion\" and ingreso_detalle.pro_id_producto=$id_producto;
       
        ");
		$data =$query;
        return $data->result_array();
    }


    function Kardex_Entradas_Total($id_producto){
		$query = $this->db->query("SELECT FORMAT(ROUND(SUM(ingd.ind_cantidad*ingd.ind_valor),1),2) AS total_entradas 
            FROM  ingreso_detalle as ingd,producto as p 
            WHERE p.pro_id_producto=ingd.pro_id_producto
            AND ingd.pro_id_producto=$id_producto");
		$data =$query;
        return $data->row_array();
    }



    function Kardex_Salidas($idprodcuto){
        $query = $this->db->query(
            "SELECT DATE_FORMAT(sal.sal_fecha_registro,'%d-%m-%Y') as sal_fecha_registro,
            sd.sad_cantidad, sad_valor,FORMAT(ROUND((sd.sad_cantidad * sd.sad_valor),1),2) as total_venta 
            FROM producto as p, salida as sal, salida_detalle as sd
            WHERE sal.sal_id_salida=sd.sal_id_salida
            AND p.pro_id_producto = sd.pro_id_producto
            AND sd.pro_id_producto=$idprodcuto"
        );
        return $query->result_array();
    }

    function Kardex_Salidas_Total($idprodcuto){
        $query = $this->db->query(
            "SELECT FORMAT(ROUND(SUM(sd.sad_cantidad * sd.sad_valor),1),2) as total_salidas,p.pro_nombre 
            FROM producto as p, salida as sal, salida_detalle as sd
            WHERE sal.sal_id_salida=sd.sal_id_salida
            AND p.pro_id_producto = sd.pro_id_producto
            AND sd.pro_id_producto=$idprodcuto"
        );
        return $query->row_array();
    }

    function Kardex_Existencias($idprodcuto){
        $query = $this->db->query(
            "SELECT p.pro_cantidad,p.pro_val_compra,FORMAT(ROUND((p.pro_cantidad*p.pro_val_compra),1),2) as total_compra 
            FROM producto as p WHERE p.pro_id_producto=$idprodcuto"
        );
        return $query->result_array();
    }
}
