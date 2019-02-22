<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class kardex  extends CI_Controller
{

	function __construct() {
		parent::__construct();
		$this->load->library('session');

		$this->load->database();
		$this->load->model('kardex_model');
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
		$data_header['pri_nombre'] = 'Targeta Kardex';
		$data_header['usuario'] = get_usuario($this);
		$data_header['title'] = "KARDEX";
		$data_footer['inits_function'] = array("init_kardex");
		$this->load->view('header', $data_header);
		$this->load->view('reporte/kardex/kardex');
		$this->load->view('footer', $data_footer);
	}

	public function Listar_Productos(){
	    $result = array('data'=>array());
	    $data = $this->kardex_model->Cargar_Data_Productos();

	    foreach ($data as $key =>$value){
	        $clase = $value['clase_nombre'];
	        $subclase = $value['subclase_nombre'];
	        $producto = $value['pro_nombre'];
	        $cantidad = $value['pro_cantidad'];
	        $pcompra = $value['pro_val_compra'];
	        $pventa = $value['pro_val_venta'];
	        $button = '
	        <button type="button" onclick="Detalle_Kardex('.$value['pro_id_producto'].')" 
	        data-toggle="modal" data-target="#detalle_kardex" class="btn btn-facebook"><i class="fa fa-archive"></i> KARDEX</button>
	        ';

	        $result['data'][$key]=array(
	            $clase,$subclase,$producto,$cantidad,$pcompra,$pventa,$button
            );
        }
        echo json_encode($result);
    }

}
