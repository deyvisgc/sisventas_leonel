<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Pcliente_model extends CI_Model
{
    function mregistrar($data)
    {
        $this->db->insert('pcliente', $data);
        $insert_id = $this->db->insert_id();
        return $insert_id;
    }

    function mactualizar($pcl_id_pcliente, $data)
    {
        $this->db->where('pcl_id_pcliente', $pcl_id_pcliente);
        return $this->db->update('pcliente', $data);
    }

    function buscar_proveedores()
    {
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
        foreach ($query->result() as $row) {
            $list[] = $row;
        }
        return $list;
    }

    function buscar_clientes()
    {
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
        foreach ($query->result() as $row) {
            $list[] = $row;
        }
        return $list;
    }

    function buscar_x_razon_social_o_ruc($texto)
    {
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
			where (e.emp_ruc like '%" . $texto . "%' 
			  or e.emp_razon_social like '%" . $texto . "%') 
			  and pc.pcl_eliminado='NO'");
        foreach ($query->result() as $row) {
            $list[] = $row;
        }
        return $list;
    }

    function listarCliente()
    {
        $consulta = 'SELECT s.sal_numero_doc_cliente ,cli.pcl_id_pcliente,s.sal_id_salida, em.emp_ruc,em.emp_razon_social,s.sal_numero_doc_cliente,s.sal_observacion,s.sal_chofer,s.sal_camion FROM pcliente as cli, salida as s, empresa as em WHERE cli.emp_id_empresa=em.emp_id_empresa AND cli.pcl_tipo=1 AND cli.est_id_estado=11 AND cli.pcl_eliminado=\'NO\' and s.pcl_id_cliente=cli.pcl_id_pcliente';

        $datos = $this->db->query($consulta);

        return $datos->result_array();

    }

    function listarClientes()
    {
        $consulta = 'SELECT cli.pcl_id_pcliente, em.emp_ruc,em.emp_razon_social FROM pcliente as cli, 
            empresa as em WHERE cli.emp_id_empresa=em.emp_id_empresa AND cli.pcl_tipo=1 AND cli.est_id_estado=11 AND cli.pcl_eliminado=\'NO\'';

        $datos = $this->db->query($consulta);

        return $datos->result_array();

    }

    function listarProveedor()
    {
        $sql = "SELECT pcl_id_pcliente, emp_ruc, emp_razon_social FROM pcliente pc INNER JOIN empresa e ON pc.emp_id_empresa=e.emp_id_empresa where (pc.pcl_tipo='2' or pc.pcl_tipo='3') and pc.pcl_eliminado='NO' and pc.est_id_estado='11'";
        $datos = $this->db->query($sql);
        return $datos->result_array();
    }

    function Buscar_compras_provedor($pcl_id_pcliente)
    {
        $sql = "SELECT ing.ing_id_ingreso,ing.ing_monto,
		DATE_FORMAT(ing.ing_fecha_doc_proveedor, '%d-%m-%Y') as ing_fecha_doc_proveedor 
		FROM ingreso as ing ,pcliente as pc 
		WHERE ing.pcl_id_proveedor=pc.pcl_id_pcliente and 
		ing.pcl_id_proveedor=$pcl_id_pcliente ORDER BY ing.ing_fecha_doc_proveedor DESC";
        $datos = $this->db->query($sql);
        return $datos->result_array();
    }

    function Buscar_detalle_compra($ing_id_ingreso)
    {
        $sql = "SELECT ingdt.ind_monto,ingdt.ind_cantidad,p.pro_nombre,p.pro_val_compra FROM ingreso_detalle as ingdt , ingreso as ing , producto as p WHERE ingdt.ing_id_ingreso = ing.ing_id_ingreso and ingdt.pro_id_producto=p.pro_id_producto and ingdt.ing_id_ingreso=$ing_id_ingreso";
        $datos = $this->db->query($sql);
        return $datos->result_array();
    }

    public function suma_compras($ing_id_ingreso)
    {
        $query = $this->db->query("SELECT FORMAT(ROUND(IFNULL(SUM(ingdt.ind_monto),0),1),2)
  as monto_final FROM ingreso_detalle as ingdt , ingreso as ing WHERE ingdt.ing_id_ingreso=ing.ing_id_ingreso
                    and ingdt.ing_id_ingreso= $ing_id_ingreso");
        foreach ($query->result() as $row) {
            return $row;
        }
        return array('monto_final' => '0.00');
    }

    public function Listar_pagos_provedor($pcl_id_pcliente)
    {
        $consulta = "call listar_pagos_proveedor($pcl_id_pcliente)";
        $datos = $this->db->query($consulta);
        return $datos->result_array();
    }

    public function listarproductos($fecha_ini, $fecha_fin, $pcl_id_pcliente)
    {
        $lista1 = [];
        $consulta = $this->db->query("SELECT pr.pro_nombre ,SUM(id.ind_cantidad) as ind_cantidad , SUM(id.ind_monto) AS ind_monto  
		FROM ingreso_detalle as id ,ingreso as ing ,producto as pr ,pcliente as pc
		WHERE id.ing_id_ingreso=ing.ing_id_ingreso and id.pro_id_producto=.pr.pro_id_producto
		and ing.pcl_id_proveedor=pc.pcl_id_pcliente and
		STR_TO_DATE(ing.ing_fecha_doc_proveedor, '%Y-%m-%d') BETWEEN STR_TO_DATE('$fecha_ini', '%Y-%m-%d') AND STR_TO_DATE('$fecha_fin', '%Y-%m-%d')
		and ing.pcl_id_proveedor=$pcl_id_pcliente GROUP BY pr.pro_nombre ORDER BY ing.ing_id_ingreso DESC");

        foreach ($consulta->result() as $lis) {

            $lista1[] = $lis;
        }
        return $lista1;

    }

    public function listarOperaciones($fecha_ini, $fecha_fin, $pcl_id_pcliente)
    {
        $sql = $this->db->query("SELECT IFNULL(SUM(ingd.ind_cantidad),0.00) as cantidad, IFNULL(SUM(ingd.ind_monto),0.00)
  		as monto FROM ingreso_detalle as ingd , ingreso as ing,pcliente as pro WHERE pro.pcl_id_pcliente=ing.pcl_id_proveedor AND ingd.ing_id_ingreso=ing.ing_id_ingreso
    	and ing.pcl_id_proveedor=$pcl_id_pcliente and STR_TO_DATE(ing.ing_fecha_doc_proveedor, '%Y-%m-%d') 
      	BETWEEN STR_TO_DATE('$fecha_ini', '%Y-%m-%d') AND STR_TO_DATE('$fecha_fin', '%Y-%m-%d')");
        foreach ($sql->result() as $row) {
            return $row;
        }
        return array('monto' => '0.00',
            'cantidad' => '0.00');

    }

    public function listarTransporte($id_salida)
    {
        $sql = "SELECT * FROM salida WHERE salida.sal_id_salida=$id_salida";
        $datos = $this->db->query($sql);
        return $datos->result_array();

    }


}

?>
