<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class imprimir extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();

        $this->load->library('session');

        $this->load->database();
        $this->load->model('salida_model');
        $this->load->model('datos_empresa_local_model');
        $this->load->model('rol_has_privilegio_model');
        $this->load->model('Sangria_model');
        $this->load->model('reporte_model');

        $this->load->helper('seguridad');
        $this->load->helper('util');
        $this->load->helper('url');
    }

    public function index()
    {
        is_logged_in_or_exit($this);
        $data_header['list_privilegio'] = get_privilegios($this);
        $data_header['pri_grupo'] = 'REPORTE';
        $data_header['pri_nombre'] = 'Administrar ventas';
        $data_header['usuario'] = get_usuario($this);
        $data_header['title'] = "Reimprimir";

        $data_footer['inits_function'] = array("init_salida");

        $this->load->view('header', $data_header);
        $this->load->view('reporte/imprimir/reimprimir');
        $this->load->view('footer', $data_footer);
    }

    public function listarVentas(){

        $result = array('data'=>array());
        $data= $this->salida_model->listarVentas();
        foreach($data as $key => $value){
            $cliente = $value['emp_razon_social'];
            $fecha =$value['sal_fecha_doc_cliente'];
            $deuda =$value['sal_monto'];
            $buttons = '
            <div class="row">
                <div class="col-md-12">
                    <div class="text-center">                
                    <button type="button" onclick="func_mostrar_documento('.$value['sal_id_salida'].')" data-toggle="modal" data-target="#"
                    class="btn btn-facebook"><i class="fa fa-print"></i> Imprimir</button>
                    <button type="button" onclick="func_eliminar_venta('.$value['sal_id_salida'].')" data-toggle="modal" data-target="#elimiminar_deuda"
                    class="btn btn-danger"><i class="fa fa-trash"></i> Eliminar</button>
                    </div>                
                </div>
            </div>';
            $result['data'][$key] = array(
                $cliente,$fecha,$deuda,
                $buttons
            );
        }
        echo json_encode($result);
    }

    public function Eliminar_Venta(){
        is_logged_in_or_exit($this);
        $data_venta = array(
            'id_salida' => $this->input->post('sal_id_salida')
        );
        $respuesta = $this->salida_model->Eliminar_Ventas($data_venta);
        echo json_encode($respuesta);
    }


}