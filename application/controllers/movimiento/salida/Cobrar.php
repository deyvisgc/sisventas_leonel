<?php
defined('BASEPATH') OR exit('No direct script access allowed');
class Cobrar extends CI_Controller{
    function __construct()
    {
        parent::__construct();
        $this->load->library('session');

        $this->load->database();
        $this->load->model('salida_model');
        $this->load->model('salida_detalle_model');
        $this->load->model('datos_empresa_local_model');
        $this->load->model('rol_has_privilegio_model');

        $this->load->helper('seguridad');
        $this->load->helper('util');
        $this->load->helper('url');
    }

    public function index(){
        is_logged_in_or_exit($this);
        $data_header['list_privilegio'] = get_privilegios($this);
        $data_header['pri_grupo'] = 'MOVIMIENTO';
        $data_header['pri_nombre'] = 'Cuentas por Cobrar';
        $data_header['usuario'] = get_usuario($this);
        $data_header['title'] = "Cuentas Por Cobrar";

        $data_body['datos_empresa_local'] = $this->datos_empresa_local_model->buscar_id_unico();

        $data_footer['inits_function'] = array("init_salida");

        $this->load->view('header', $data_header);
        $this->load->view('movimiento/salida/cobrar/index', $data_body);
        $this->load->view('footer', $data_footer);
    }

    public function listarClientes(){

        $result = array('data'=>array());
        $data= $this->salida_model->listarCliente();
        foreach($data as $key => $value){
            $cliente = $value['emp_razon_social'];
            $fecha =$value['sal_fecha_doc_cliente'];
            $deuda =$value['sal_deuda'];
            $buttons = '<button type="button" onclick="cargarDatosDeuda('.$value['sal_id_salida'].')" data-toggle="modal" data-target="#disminuirDeuda"
            class="btn btn-primary">Amortizar</button>
            <button type="button" onclick="corregirDeuda('.$value['sal_id_salida'].')" data-toggle="modal" data-target="#editDeuda"
            class="btn btn-success">Corregir</button>';

            $result['data'][$key] = array(
                $cliente,$fecha,$deuda,
                $buttons
            );
        }
        echo json_encode($result);
    }

    public function cargarDataDeuda($sal_id_salida){
        $data = $this->salida_model->cargaData($sal_id_salida);
        echo json_encode($data);
    }

    public function editarDeuda(){
        $data_deuda = array(
            'sal_deuda' =>$this->input->post('deuda'),
            'sal_id_salida' => $this->input->post('iddeuda')
        );
        $data=$this->salida_model->ajustar_deuda($data_deuda);
        echo json_encode($data);
    }

    public function registrar_movimiento_pago(){
        $data_movimiento = array(
            'monto_pagado' => $this->input->post('monto_pago'),
            'monto_compra' => '00.00',
            'descripcion' => $this->input->post('descripcion'),
            'saldo' => $this->input->post('saldo'),
            'id_salida' => $this->input->post('id_salida'),
            'idcliente' => $this->input->post('idcliente')
        );

        $data = $this->salida_model->insert_movimiento_pago($data_movimiento);
        echo json_encode($data);
    }
}
?>