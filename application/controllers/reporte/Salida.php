<?php


class Salida extends CI_Controller
{
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
        $data_header['pri_nombre'] = 'Salida Produccion';
        $data_header['usuario'] = get_usuario($this);
        $data_header['title'] = "Salida Produccion";
        $data_footer['inits_function'] = array("init_salida_produccion");
        $this->load->view('header', $data_header);
        $this->load->view('reporte/stock/salida');
        $this->load->view('footer', $data_footer);
    }

    public function Cargar_Productos_Salida()
    {
        is_logged_in_or_exit($this);
        $fecha_ini = $this->input->post('fecha_ini');
        $fecha_fin = $this->input->post('fecha_fin');

        $request = $this->reporte_model->Salida_Productos_Produccion($fecha_ini,$fecha_fin);
        $totales = $this->reporte_model->Total_Salida_Produccion($fecha_ini,$fecha_fin);

        $data = array('hecho' => 'SI', 'data' => $request, 'data_totales' => $totales);

        echo json_encode($data);
    }
}