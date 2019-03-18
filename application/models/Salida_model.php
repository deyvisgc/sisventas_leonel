<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Salida_model extends CI_Model {
    function mregistrar($data) {
        $result = $this->db->query("call proc_salida_registrar( 
			@out_hecho, 
			@out_estado, 
			@out_sal_id_salida, 
			".$data['usu_id_usuario'].", 
			".$data['pcl_id_cliente'].", 
			'".$data['sal_fecha_doc_cliente']."', 
			".$data['tdo_id_tipo_documento'].", 
			".$data['sal_monto_efectivo'].", 
			".$data['sal_monto_tar_credito'].", 
			".$data['sal_monto_tar_debito'].", 
			".$data['sal_descuento'].",
			'".$data['sal_motivo']."',
			'".$data['sal_vuelto']."',
			'".$data['t_venta']."',
			'".$data['sal_deuda']."',
			'".$data['sal_chofer']."',
			'".$data['sal_camion']."',
			'".$data['sal_observacion']."',
			'".$data['sal_numero_doc_cliente']."'
			)");
        $result = $this->db->query("SELECT @out_hecho as hecho, @out_estado as estado, @out_sal_id_salida as sal_id_salida");

        return $result->row();
    }
	function mbuscar_one($sal_id_salida) {
		$query = $this->db->query("
			SELECT 
			  sal_id_salida, 
			  sal_camion, 
			  sal_chofer,
			  sal_observacion, 
			  IFNULL(pcl_id_cliente, 0) pcl_id_cliente, 
			  IFNULL(DATE_FORMAT(sal_fecha_doc_cliente, '%d/%m/%Y'), '') sal_fecha_doc_cliente, 
			  IFNULL(td.tdo_id_tipo_documento, 0) tdo_id_tipo_documento, 
			  IFNULL(td.tdo_nombre, '') tdo_nombre, 
			  IFNULL(sal_numero_doc_cliente, '') sal_numero_doc_cliente, 
			  IFNULL(sal_descuento, 0.00) sal_descuento, 
			  IFNULL(sal_motivo, '') sal_motivo, 
			   IFNULL(sal_vuelto, 0.00) sal_vuelto,
			  IFNULL(sal_monto, 0.00) sal_monto, 
			  IFNULL(emp_ruc, '') emp_ruc, 
			  IFNULL(emp_razon_social, '') emp_razon_social, 
			  IFNULL(emp_direccion, '') emp_direccion, 
			  IFNULL(emp_telefono, '') emp_telefono, 
			  IFNULL(emp_telefono, '') emp_telefono, 
			  IFNULL(emp_nombre_contacto, '') emp_nombre_contacto, 
			  IFNULL(tdo_nombre, '') tdo_nombre 
			FROM salida s 
			  INNER JOIN tipo_documento td 
			  ON s.tdo_id_tipo_documento=td.tdo_id_tipo_documento 
			  INNER JOIN pcliente pc 
			  ON s.pcl_id_cliente=pc.pcl_id_pcliente 
			  LEFT JOIN empresa e 
			  ON pc.emp_id_empresa=e.emp_id_empresa 
			WHERE s.sal_id_salida=$sal_id_salida");
		foreach ($query->result() as $row)
		{
			return $row;
		}
		return false;
	}


    public function listarCliente(){
        $consulta = "SELECT DATE_FORMAT(s.sal_fecha_doc_cliente,'%d-%m-%Y') as sal_fecha_doc_cliente , s.sal_deuda, 
        s.sal_id_salida, em.emp_razon_social FROM salida as s, pcliente as cli, 
        empresa as em WHERE cli.emp_id_empresa=em.emp_id_empresa AND 
        cli.pcl_id_pcliente=s.pcl_id_cliente AND s.t_venta=\"deuda\" AND sal_deuda > 0";
        $datos = $this->db->query($consulta);
        return $datos->result_array();
    }
    public function buscar_cliente($descripcion){
		$list = array();
    	$consulta=$this->db->query("SELECT pcliente.pcl_id_pcliente,em.emp_razon_social
                                    FROM pcliente ,empresa as em 
                                    WHERE pcliente.emp_id_empresa=em.emp_id_empresa and pcliente.pcl_tipo=1 
                                      and em.emp_razon_social LIKE '%".$descripcion."%'");

		foreach ($consulta->result() as $row) {
			$row->value = $row->emp_razon_social;
			$list[] = $row;
		}

    	return $list;

	}
	public function listarClienteXID($idcliente){
		$lista1 = [];
		$consulta = $this->db->query ("SELECT s.sal_fecha_doc_cliente, s.sal_deuda, 
        s.sal_id_salida, em.emp_razon_social FROM salida as s, pcliente as cli, 
        empresa as em WHERE cli.emp_id_empresa=em.emp_id_empresa AND 
        cli.pcl_id_pcliente=s.pcl_id_cliente AND s.t_venta=\"deuda\" AND sal_deuda > 0 and s.pcl_id_cliente=$idcliente");

		foreach ($consulta->result() as $lis) {

			$lista1[] = $lis;
		}
		return $lista1;
	}
	public function sumardeudad($idcliente){

		$sql = $this->db->query("SELECT IFNULL(SUM(s.sal_deuda),0)  as sumadeudad FROM salida as s, pcliente as cli, empresa as em WHERE cli.emp_id_empresa=em.emp_id_empresa AND cli.pcl_id_pcliente=s.pcl_id_cliente AND s.t_venta=\"deuda\" AND sal_deuda > 0 and s.pcl_id_cliente=$idcliente");
		foreach ($sql->result() as $row) {
			return $row;
		}
		return array('suma' => '0.00');
	}

  

    public function cargaData($sal_id_salida)
    {
        $consulta = "SELECT s.sal_fecha_doc_cliente, s.sal_deuda, 
        s.sal_id_salida, em.emp_razon_social,s.pcl_id_cliente FROM salida as s, pcliente as cli, 
        empresa as em WHERE cli.emp_id_empresa=em.emp_id_empresa AND 
        cli.pcl_id_pcliente=s.pcl_id_cliente AND s.t_venta=\"deuda\" 
        AND s.sal_id_salida=$sal_id_salida";

        $data = $this->db->query($consulta,array($sal_id_salida));
        return $data->row_array();
    }

    public function editarDebt($data_deuda){

	    $consulta ="UPDATE salida SET sal_deuda = '".$data_deuda['sal_deuda']."' 
        WHERE salida.sal_id_salida = '".$data_deuda['sal_id_salida']."' ";
	    $this->db->query($consulta);
    }

    function ajustar_deuda($data) {
        $result = $this->db->query("call proc_ajustar_deuda
        ( 
            ".$data['sal_deuda'].", 
			".$data['sal_id_salida']." 
		)");
        return $result;
    }

    function listarVentas(){
        $consulta = "SELECT e.emp_razon_social,s.sal_id_salida,s.sal_fecha_doc_cliente,s.sal_monto
        FROM pcliente as c, empresa as e, salida as s 
        WHERE e.emp_id_empresa=c.emp_id_empresa 
        AND c.pcl_id_pcliente=s.pcl_id_cliente 
        ORDER BY s.sal_id_salida DESC ";
        $datos = $this->db->query($consulta);
        return $datos->result_array();
    }

    function detalle_compra_x_cliente($id_compra){
        $list = array();
        $consulta="SELECT p.pro_nombre,sd.sad_cantidad, sd.sad_valor,sd.sad_monto,sd.sad_ganancias,sal.sal_numero_doc_cliente 
        FROM producto as p, salida_detalle as sd,salida as sal
        WHERE p.pro_id_producto=sd.pro_id_producto 
        AND sal.sal_id_salida=sd.sal_id_salida  
        AND sd.sal_id_salida=$id_compra";
        $data = $this->db->query($consulta);
        foreach ($data -> result() as $row){
            $list[] = $row;
        }
        return $list;
    }
    function detalle_compra_x_cliente_totales($id_compra){
        $consulta="SELECT sal.sal_monto  FROM salida as sal WHERE sal.sal_id_salida=$id_compra";
        $data = $this->db->query($consulta);
        return $data->row_array();
    }
    function insert_movimiento_pago($data_movimiento){
        $result = $this->db->query("call INSERTAR_MOVIMIENTO_CLIENTE( 
			'".$data_movimiento['monto_pagado']."',
			'".$data_movimiento['descripcion']."',
			'".$data_movimiento['id_salida']."',
			'".$data_movimiento['idcliente']."',
			'".$data_movimiento['monto_compra']."'
			)");
        return $result;
    }
    function Eliminar_Ventas($data_venta){
        $result = $this->db->query("CALL ELIMINAR_VENTA(
            '".$data_venta['id_salida']."'
        )");
        return $result;
    }

	function listar_compras_x_cliente($idcliente){
		$consulta=$this->db->query("call listarClienteXid(
         ".$idcliente['idclinete'].")");

		$data =$consulta;
		return $data->result_array();

	}



    function listarVentas_Guia(){
        $consulta = "SELECT s.sal_id_salida,DATE_FORMAT(s.sal_fecha_doc_cliente,'%d-%m-%Y') as sal_fecha_doc_cliente,e.emp_razon_social,s.sal_monto
        FROM pcliente as c, empresa as e, salida as s 
        WHERE e.emp_id_empresa=c.emp_id_empresa 
        AND c.pcl_id_pcliente=s.pcl_id_cliente 
        ORDER BY s.sal_id_salida DESC ";
        $datos = $this->db->query($consulta);
        return $datos->result_array();
    }

    public function Seleccionar_Productos_Despacho($ids){

        $id_guia = implode(",", $ids);
        $result = $this->db->query('SELECT p.pro_nombre as PRODUCTO,p.cla_clase, SUM(sd.sad_cantidad) as CANTIDAD, p.pro_kilogramo * sd.sad_cantidad AS total_kilogramos, SUM(sd.sad_cantidad) as cantidad_sacos 
        FROM salida as sa, salida_detalle as sd, producto as p 
        WHERE sa.sal_id_salida=sd.sal_id_salida AND sd.pro_id_producto=p.pro_id_producto 
        AND FIND_IN_SET( sa.sal_id_salida ,"'.$id_guia.'") 
        GROUP BY p.pro_nombre,p.cla_clase 
        ORDER BY CANTIDAD DESC');
        return $result->result_array();
    }
    public function Totales_Productos_Despacho($ids){

        $id_guia = implode(",", $ids);
        $result = $this->db->query('SELECT SUM(sd.sad_sum_kilo) AS total_kilogramos, SUM(sd.sad_cantidad) as cantidad_sacos 
        FROM salida as sa, salida_detalle as sd, producto as p 
        WHERE sa.sal_id_salida=sd.sal_id_salida AND sd.pro_id_producto=p.pro_id_producto 
        AND FIND_IN_SET( sa.sal_id_salida ,"'.$id_guia.'") ');
        foreach ($result->result() as $row)
        {
            return $row;
        }
        return false;
    }

    public function Total_Cuentas_x_Cobrar(){
        $result = $this->db->query("SELECT FORMAT(ROUND(SUM(sal.sal_deuda),1),2) as TOTAL FROM salida as sal where sal.t_venta=\"deuda\"");
        return $result->row_array();
    }
}
?>
