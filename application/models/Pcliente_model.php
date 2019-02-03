<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Pcliente_model extends CI_Model {
	function mregistrar($data) {
		$this->db->insert('pcliente',$data);
		$insert_id = $this->db->insert_id();
		return  $insert_id;
	}
	function mactualizar($pcl_id_pcliente, $data) {
		$this->db->where('pcl_id_pcliente', $pcl_id_pcliente);
        return $this->db->update('pcliente', $data);
	}
	function buscar_proveedores() {
		$list = array();
		$query = $this->db->query("SELECT 
			  pcl_id_pcliente, 
			  emp_ruc, 
			  emp_razon_social, 
			  emp_direccion, 
			  emp_nombre_contacto 
			FROM pcliente pc 
			  INNER JOIN empresa e 
			  ON pc.emp_id_empresa=e.emp_id_empresa 
			where (pc.pcl_tipo='2' 
			  or pc.pcl_tipo='3') 
			  and pc.pcl_eliminado='NO'");
		foreach ($query->result() as $row)
		{
			$list[] = $row;
		}
		return $list;
	}
	function buscar_clientes() {
		$list = array();
		$query = $this->db->query("SELECT 
			  pcl_id_pcliente, 
			  emp_ruc, 
			  emp_razon_social, 
			  emp_direccion, 
			  emp_nombre_contacto 
			FROM pcliente pc 
			  INNER JOIN empresa e 
			  ON pc.emp_id_empresa=e.emp_id_empresa 
			where (pc.pcl_tipo='1' 
			  or pc.pcl_tipo='3') 
			  and pc.pcl_eliminado='NO'");
		foreach ($query->result() as $row)
		{
			$list[] = $row;
		}
		return $list;
	}
	function buscar_x_razon_social_o_ruc($texto) {
		$list = array();
		$query = $this->db->query("SELECT 
			  pc.pcl_id_pcliente, 
			  IF(pc.pcl_tipo = '1', 'CLIENTE', IF(pc.pcl_tipo = '2', 'PROVEEDOR', IF(pc.pcl_tipo = '3', 'AMBOS', 'X'))) pcl_tipo_nombre, 
			  pc.pcl_tipo, 
			  est.est_id_estado, 
			  est.est_nombre, 
			  e.emp_id_empresa, 
			  e.emp_ruc, 
			  e.emp_razon_social, 
			  e.emp_direccion, 
			  e.emp_telefono, 
			  e.emp_nombre_contacto 
			FROM pcliente pc 
			  INNER JOIN empresa e 
			  ON pc.emp_id_empresa=e.emp_id_empresa 
			  INNER JOIN estado est 
			  ON pc.est_id_estado=est.est_id_estado 
			where (e.emp_ruc like '%".$texto."%' 
			  or e.emp_razon_social like '%".$texto."%') 
			  and pc.pcl_eliminado='NO'");
		foreach ($query->result() as $row)
		{
			$list[] = $row;
		}
		return $list;
	}

	function listarCliente(){
            $consulta = 'SELECT cli.pcl_id_pcliente, em.emp_ruc,em.emp_razon_social FROM pcliente as cli, 
            empresa as em WHERE cli.emp_id_empresa=em.emp_id_empresa AND cli.pcl_tipo=1 AND cli.est_id_estado=11 AND cli.pcl_eliminado=\'NO\'';

	    $datos = $this->db->query($consulta);

        return $datos->result_array();

    }

     function listarProveedor(){
		$sql="SELECT pcl_id_pcliente, emp_ruc, emp_razon_social FROM pcliente pc INNER JOIN empresa e ON pc.emp_id_empresa=e.emp_id_empresa where (pc.pcl_tipo='2' or pc.pcl_tipo='3') and pc.pcl_eliminado='NO' and pc.est_id_estado='11'";
		$datos = $this->db->query($sql);
		return $datos->result_array();
	}
	function Buscar_compras_provedor($pcl_id_pcliente){
		$sql="SELECT ing.ing_id_ingreso,ing.ing_monto,ing.ing_fecha_doc_proveedor FROM ingreso as ing ,pcliente as pc WHERE
                      ing.pcl_id_proveedor=pc.pcl_id_pcliente and ing.pcl_id_proveedor=$pcl_id_pcliente";
		$datos = $this->db->query($sql);
		return $datos->result_array();
	}
	function Buscar_detalle_compra($ing_id_ingreso){
		$sql="SELECT ingdt.ind_monto,ingdt.ind_cantidad,p.pro_nombre,p.pro_val_compra FROM ingreso_detalle as ingdt , ingreso as ing , producto as p WHERE ingdt.ing_id_ingreso = ing.ing_id_ingreso and ingdt.pro_id_producto=p.pro_id_producto and ingdt.ing_id_ingreso=$ing_id_ingreso";
		$datos = $this->db->query($sql);
		return $datos->result_array();
	}
	public function suma_compras($ing_id_ingreso){
		$query = $this->db->query("SELECT FORMAT(ROUND(IFNULL(SUM(ingdt.ind_monto),0),1),2)
  as monto_final FROM ingreso_detalle as ingdt , ingreso as ing WHERE ingdt.ing_id_ingreso=ing.ing_id_ingreso
                    and ingdt.ing_id_ingreso= $ing_id_ingreso");
		foreach ($query->result() as $row)
		{
			return $row;
		}
		return array('monto_final' => '0.00');
	}
	public function Listar_pagos_provedor($pcl_id_pcliente){
		$consulta="call listar_pagos_proveedor($pcl_id_pcliente)";
		$datos = $this->db->query($consulta);
		return $datos->result_array();
	}
}
?>
