<?php
class Caja extends CI_Controller{
    function __construct()
    {
        parent::__construct();
        $this->load->library('session');
        $this->load->database();
        $this->load->model('reporte_model');
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
        $data_header['pri_nombre'] = 'Efectivo en caja';
        $data_header['usuario'] = get_usuario($this);
        $data_header['title'] = "REPORTE EFECTIVO";
        $data_footer['inits_function'] = array("init_deuda");
        $this->load->view('header', $data_header);
        $this->load->view('reporte/efectivo/index');
        $this->load->view('footer', $data_footer);
    }

    public function movimiento_efectivo()
    {
        is_logged_in_or_exit($this);
        $fecha_ini = $this->input->post('fecha_ini');
        $fecha_fin = $this->input->post('fecha_fin');
        $list = $this->reporte_model->movimiento_efectivo_diario($fecha_ini, $fecha_fin);
        $list_totales = $this->reporte_model->movimiento_efectivo_totales($fecha_ini, $fecha_fin);
        $data = array('hecho' => 'SI', 'data' => $list, 'data_totales' => $list_totales);
        echo json_encode($data);
    }
}