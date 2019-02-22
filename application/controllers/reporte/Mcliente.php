<?php
defined('BASEPATH') OR exit('No direct script access allowed');
class Mcliente extends CI_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->library('session');

        $this->load->database();
        $this->load->model('reporte_model');
        $this->load->model('rol_has_privilegio_model');
        $this->load->model('pcliente_model');
        $this->load->model('salida_model');
        $this->load->model('mayor_model');

        $this->load->helper('seguridad');
        $this->load->helper('util');
        $this->load->helper('url');
    }

    public function index()
    {
        is_logged_in_or_exit($this);
        $data_header['list_privilegio'] = get_privilegios($this);
        $data_header['pri_grupo'] = 'REPORTE';
        $data_header['pri_nombre'] = 'Movimiento cliente';
        $data_header['usuario'] = get_usuario($this);
        $data_header['title'] = "Mov. Cliente";
        $data_footer['inits_function'] = array("init_movimiento");
        $this->load->view('header', $data_header);
        $this->load->view('reporte/movimiento/cliente');
        $this->load->view('footer', $data_footer);
    }

    public function listarClientes(){
        is_logged_in_or_exit($this);
        $result = array('data'=>array());
        $data = $this->pcliente_model->listarClientes();

        foreach ($data as $key => $value){
            $ruc=$value['emp_ruc'];
			$razon_social=$value['emp_razon_social'];
            $buttons = '
            <div class="text-center">
            <button type="button" onclick="Movimiento_Clientes('.$value['pcl_id_pcliente'].')" data-toggle="modal" data-target="#modal_movimiento_cliente"
            class="btn btn-info">Movimientos</button>
            </div>';

            $result['data'][$key]=array(
                $ruc,
                $razon_social,
                $buttons
            );
        }
        echo json_encode($result);
    }

    public function listar_compras_x_cliente($id_cliente){
        is_logged_in_or_exit($this);
        $result = array('data'=>array());
        $data = $this->salida_model->listar_compras_x_cliente($id_cliente);
        foreach($data as $key =>$value){
			$fecha=$value['sal_fecha_doc_cliente'];
            $total=$value['sal_monto'];
            $buttons='
            <div class="text-center">
            <button type="button" onclick="cargar_detalle_compra('.$value['sal_id_salida'].')" data-toggle="modal" data-target="#detalles_compra"
            class="btn btn-success">Detalle Compras</button>
            </div>
            ';
            $result['data'][$key]=array(
                $fecha,
                $total,
                $buttons
            );
        }
        echo json_encode($result);
    }

    public function detalle_compra_x_clientes($id_salida){
        is_logged_in_or_exit($this);
        $list = $this->salida_model->detalle_compra_x_cliente($id_salida);
        $data = array('hecho' => 'SI', 'data'=>$list);
        echo json_encode($data);
    }

    public function detalle_compra_x_clientes_total($id_salida){
        is_logged_in_or_exit($this);
        $list_totales = $this->salida_model->detalle_compra_x_cliente_totales($id_salida);
        echo json_encode($list_totales);
    }

    public function datos_movimiento_pagos_x_cliente($id_cliente){
        is_logged_in_or_exit($this);
        $result = array('data'=>array());
        $data = $this->mayor_model->cargar_movimiento_pagos_x_cliente($id_cliente);
        foreach($data as $key =>$value){
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
    public function listarProductos($id_cliente){
		$fecha_ini = $this->input->post('fecha_ini');
		$fecha_fin = $this->input->post('fecha_fin');
		$listaproductos=$this->reporte_model->listaProductosxcliente($fecha_ini,$fecha_fin,$id_cliente);
		$operacion=$this->reporte_model->sumaroperaciones($fecha_fin,$fecha_fin,$id_cliente);
		$data = array('hecho' => 'SI', 'data' => $listaproductos, 'data_totales' => $operacion);
		echo  json_encode($data);

	}
	public function listaTransporte($id_salida){

		is_logged_in_or_exit($this);
		$result = array('data'=>array());
		$data = $this->pcliente_model->listarTransporte($id_salida);
		foreach($data as $key =>$value){
			$fecha=$value['sal_chofer'];
			$descripcion=$value['sal_observacion'];
			$debe=$value['sal_camion'];

			$result['data'][$key]=array(
				$fecha,
				$descripcion,
				$debe,
			);
		}
		echo json_encode($result);
	}

}
