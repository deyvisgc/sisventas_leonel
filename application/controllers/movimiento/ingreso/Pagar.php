<?php
defined('BASEPATH') OR exit('No direct script access allowed');
class Pagar extends CI_Controller{
    function __construct()
    {
        parent::__construct();
        $this->load->library('session');

        $this->load->database();
        $this->load->model('ingreso_model');
        $this->load->model('rol_has_privilegio_model');

        $this->load->helper('seguridad');
        $this->load->helper('util');
        $this->load->helper('url');
    }
    public function index(){
        is_logged_in_or_exit($this);
        $data_header['list_privilegio'] = get_privilegios($this);
        $data_header['pri_grupo'] = 'MOVIMIENTO';
        $data_header['pri_nombre'] = 'Cuentas por Pagar';
        $data_header['usuario'] = get_usuario($this);
        $data_header['title'] = "Cuentas Por Pagar";

        $data_footer['inits_function'] = array("init_ingreso");

        $this->load->view('header', $data_header);
        $this->load->view('movimiento/ingreso/pagar/index');
        $this->load->view('footer', $data_footer);
    }

    public function listarProveedores(){
        $result = array('data'=>array());
        $data= $this->ingreso_model->listarProveedores();
        foreach($data as $key => $value){
            $cliente = $value['emp_razon_social'];
            $fecha =$value['ing_fecha_doc_proveedor'];
            $deuda =$value['ing_deuda'];
            $buttons = '
			<button type="button" onclick="cargarDatosDeuda('.$value['ing_id_ingreso'].')" data-toggle="modal" data-target="#disminuirDeuda"
			class="btn btn-md btn-danger">Amortizar</button>
			<button type="button" onclick="corregirDeudaxPagar('.$value['ing_id_ingreso'].')" data-toggle="modal" data-target="#corregirDeudaxPagar"
			class="btn btn-md btn-facebook">Corregir</button>';
            $result['data'][$key] = array(
                $cliente,$fecha,$deuda,
                $buttons
            );
        }
        echo json_encode($result);
    }

    public function cargarDataDeuda($ing_id_ingreso){
        $data = $this->ingreso_model->cargaData($ing_id_ingreso);
        echo json_encode($data);
    }

    public function editarDeudas(){
        $data_deuda = array(
            'ing_deuda' =>$this->input->post('deuda'),
            'ing_id_ingreso' => $this->input->post('iddeuda')
        );
        $data=$this->ingreso_model->ajustar_deuda($data_deuda);
        echo json_encode($data);
    }
    public function registrar_pago(){
		$data_ingreso_pago = array(
			'id_ingreso' => $this->input->post('id_ingreso'),
			'ma_debe' =>$this->input->post('ma_debe'),
			'ma_descripcion' => $this->input->post('ma_descripcion'),
			'idprovedor'=>$this->input->post('idprovedor'),
			'ma_haber'=>'0.0',

		);
		$data=$this->ingreso_model->registra_pago($data_ingreso_pago);
		echo json_encode($data);
	}
    public function Total_x_Pagar(){
        $data = $this->ingreso_model->Total_Cuentas_x_Pagar();
        echo json_encode($data);
    }
    public function buscar_x_proveedores(){
    	$proveedor=$this->input->post("proveedor");
    	$data=$this->ingreso_model->buscar_x_proveedores($proveedor);
    	$result=array('hecho','si','lista_proveedor'=>$data);
    	echo json_encode($result);
	}
	public function listarProveedorXID($idproveedor){

		$data= $this->ingreso_model->listarProveedorXID($idproveedor);
		$suma=$this->ingreso_model->sumardeudadProveedor($idproveedor);
		$data = array('hecho' => 'SI', 'data' => $data, 'data_totales' => $suma);
		echo  json_encode($data);
	}


}
