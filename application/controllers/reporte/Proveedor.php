<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Proveedor extends CI_Controller
{
    function __construct()
    {
        parent::__construct();
        $this->load->library('session');

        $this->load->database();
        $this->load->model('reporte_model');
		$this->load->model('pcliente_model');
        $this->load->model('rol_has_privilegio_model');

        $this->load->helper('seguridad');
        $this->load->helper('util');
        $this->load->helper('url');
    }

	public function index()
	{
		is_logged_in_or_exit($this);
		$data_header['list_privilegio'] = get_privilegios($this);
		$data_header['pri_grupo'] = 'REPORTE';
		$data_header['pri_nombre'] = 'Movimiento proveedor';
		$data_header['usuario'] = get_usuario($this);
		$data_header['title'] = "Mov. Provedor";
		$data_footer['inits_function'] = array("init_movimiento");
		$this->load->view('header', $data_header);
		$this->load->view('reporte/movimiento/provedor');
		$this->load->view('footer', $data_footer);
	}
	public function listarProvedor(){
		is_logged_in_or_exit($this);
		$result = array('data'=>array());
		$data = $this->pcliente_model->listarProveedor();

		foreach ($data as $key => $value){
			$ruc=$value['emp_ruc'];
			$razon_social=$value['emp_razon_social'];
			$buttons = '
            <div class="text-center">
            <button type="button" onclick="Movimiento_Provedor('.$value['pcl_id_pcliente'].')" data-toggle="modal" data-target="#modal_movimiento_cliente"
            class="btn btn-success">Movimientos</button>
            </div>';

			$result['data'][$key]=array(
				$ruc,
				$razon_social,
				$buttons
			);
		}
		echo json_encode($result);
	}

	public function buscarcompras($pcl_id_pcliente){

		is_logged_in_or_exit($this);
		$result = array('data'=>array());
		$data = $this->pcliente_model->Buscar_compras_provedor($pcl_id_pcliente);

		foreach ($data as $key => $value){
			$monto=$value['ing_monto'];
			$fecha=$value['ing_fecha_doc_proveedor'];
			$buttons = '
            <div class="text-center">
            <button type="button" onclick="Detalles('.$value['ing_id_ingreso'].')" data-toggle="modal" data-target="#detalles_compras"
            class="btn btn-danger">Detalle Compra</button>
            </div>';

			$result['data'][$key]=array(
                $fecha,
				$monto,
				$buttons
			);
		}
		echo json_encode($result);
	}
	public function detalle_compra_provedor($ing_id_ingreso){

		is_logged_in_or_exit($this);
		$data = $this->pcliente_model->Buscar_detalle_compra($ing_id_ingreso);
		$data1 = $this->pcliente_model->suma_compras($ing_id_ingreso);

		$data = array('hecho' => 'SI', 'data' => $data,'data_totales' => $data1);
/*
		foreach ($data as $key => $value){
			$producto=$value['pro_nombre'];
			$cantidad=$value['ind_cantidad'];
			$precio_compra=$value['pro_val_compra'];
			$monto=$value['ind_monto'];
			$result['data'][$key]=array(
				$producto,
				$cantidad,
				$monto,
				$precio_compra,
				$monto
			);
		}
*/
		echo json_encode($data);
	}
	public function listar_pagos_provedor($pcl_id_pcliente){

		is_logged_in_or_exit($this);
		$result = array('data'=>array());
		$data = $this->pcliente_model->Listar_pagos_provedor($pcl_id_pcliente);

		foreach ($data as $key => $value){
			$fecha=$value['ma_fecha'];
			$descripcion=$value['ma_descripcion'];
			$debe=$value['ma_debe'];
			$haber=$value['ma_haber'];
			$saldo=$value['ma_saldo'];
			$result['data'][$key]=array(
				$fecha,
				$descripcion,
				$debe,
				$haber,
				$saldo
			);
		}
		echo json_encode($result);
	}
	public function listarProductos($pcl_id_pcliente){
    	$fecha_ini=$this->input->post('fecha_inicio');
    	$fecha_fin=$this->input->post('fecha_fin');
		$listaproductos=$this->pcliente_model->listarproductos($fecha_ini,$fecha_fin,$pcl_id_pcliente);
		$operacion=$this->pcliente_model->listarOperaciones($fecha_ini,$fecha_fin,$pcl_id_pcliente);
		$data = array('hecho' => 'SI', 'data' => $listaproductos, 'data_totales' => $operacion);
    	echo json_encode($data);


	}






}
