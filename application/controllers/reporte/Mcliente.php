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
        $data = $this->pcliente_model->listarCliente();

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
}