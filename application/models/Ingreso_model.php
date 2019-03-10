<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Ingreso_model extends CI_Model {
	function mregistrar($data) {
		$result = $this->db->query("call proc_ingreso_registrar( 
			@out_hecho, 
			@out_estado, 
			".$data['usu_id_usuario'].", 
			".$data['pcl_id_proveedor'].", 
			'".$data['ing_fecha_doc_proveedor']."', 
			".$data['tdo_id_tipo_documento'].", 
			'".$data['ing_numero_doc_proveedor']."', 
			".$data['ing_monto_efectivo'].", 
			".$data['ing_monto_tar_credito'].", 
			".$data['ing_monto_tar_debito'].",
			".$data['ing_deuda'].",
			'".$data['in_tipo']."'
			)");
		$result = $this->db->query("SELECT @out_hecho as hecho, @out_estado as estado");
		
		return $result->row();
	}
	public function listarProveedores(){
        $consulta = "SELECT ing.ing_id_ingreso, em.emp_razon_social ,
        ing.ing_fecha_doc_proveedor,ing.ing_deuda,ing.pcl_id_proveedor
        FROM ingreso as ing, pcliente as cli, empresa as em
        WHERE cli.emp_id_empresa=em.emp_id_empresa
         AND cli.pcl_id_pcliente=ing.pcl_id_proveedor 
         AND ing.in_tipo='deuda' AND ing_deuda > 0";
        $datos = $this->db->query($consulta);
        return $datos->result_array();
    }

    public function cargaData($ing_id_ingreso)
    {
        $consulta = "SELECT ing.ing_id_ingreso, em.emp_razon_social ,
        ing.ing_fecha_doc_proveedor,ing.ing_deuda,ing.pcl_id_proveedor
        FROM ingreso as ing, pcliente as cli, empresa as em
        WHERE cli.emp_id_empresa=em.emp_id_empresa
         AND cli.pcl_id_pcliente=ing.pcl_id_proveedor 
         AND ing.in_tipo='deuda' AND ing_deuda > 0
         AND ing.ing_id_ingreso=$ing_id_ingreso";

        $data = $this->db->query($consulta,array($ing_id_ingreso));
        return $data->row_array();
    }

    function ajustar_deuda($data) {
        $result = $this->db->query("call proc_ajustar_deuda_proveedor
        ( 
            ".$data['ing_deuda'].", 
			".$data['ing_id_ingreso']." 
		)");
        return $result;
    }

    function registra_pago($data_ingreso_pago){

			$result = $this->db->query("call registrar_ingresos_pagos( 
			'".$data_ingreso_pago['id_ingreso']."',
			'".$data_ingreso_pago['ma_debe']."',
			'".$data_ingreso_pago['ma_descripcion']."',
			'".$data_ingreso_pago['idprovedor']."',
			'".$data_ingreso_pago['ma_haber']."'
			)");
			return $result;


	}

    public function Total_Cuentas_x_Pagar(){
        $result = $this->db->query("SELECT FORMAT(ROUND(SUM(ing.ing_deuda),1),2) as TOTAL FROM ingreso as ing where ing.in_tipo=\"deuda\"");
        return $result->row_array();
    }
    public function buscar_x_proveedores($proveedor){
		$lista=array();
		$consulta=$this->db->query("SELECT em.emp_razon_social,cli.pcl_id_pcliente
        FROM  pcliente as cli, empresa as em
        WHERE cli.emp_id_empresa=em.emp_id_empresa
        AND(cli.pcl_tipo='2' or cli.pcl_tipo='3') and 
			  (em.emp_razon_social like '%".$proveedor."%')");

		foreach ($consulta->result() as $row) {
			$row->value = $row->emp_razon_social;
			$lista[] = $row;
		}

		return $lista;

	}
	public function listarProveedorXID($idproveedor){
		$lista1 = [];
		$consulta = $this->db->query ("SELECT ing.ing_id_ingreso, em.emp_razon_social ,
        ing.ing_fecha_doc_proveedor,ing.ing_deuda,ing.pcl_id_proveedor
        FROM ingreso as ing, pcliente as cli, empresa as em
        WHERE cli.emp_id_empresa=em.emp_id_empresa
         AND cli.pcl_id_pcliente=ing.pcl_id_proveedor 
         AND ing.in_tipo='deuda' AND ing_deuda > 0 AND ing.pcl_id_proveedor=$idproveedor");

		foreach ($consulta->result() as $lis) {

			$lista1[] = $lis;
		}
		return $lista1;

	}
	public function sumardeudadProveedor($idproveedor){

		$sql = $this->db->query("SELECT IFNULL(SUM(ing.ing_deuda),0)as deuda 
        FROM ingreso as ing, pcliente as cli, empresa as em
        WHERE cli.emp_id_empresa=em.emp_id_empresa
         AND cli.pcl_id_pcliente=ing.pcl_id_proveedor 
         AND ing.in_tipo='deuda' AND ing_deuda > 0 AND ing.pcl_id_proveedor=$idproveedor");
		foreach ($sql->result() as $row) {
			return $row;
		}
		return array('suma' => '0.00');
	}

}
?>
