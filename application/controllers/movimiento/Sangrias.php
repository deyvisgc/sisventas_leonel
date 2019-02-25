<?php
defined('BASEPATH') OR exit('No direct script access allowed');
class Sangrias extends CI_Controller{
    function __construct()
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

    public function index(){
        is_logged_in_or_exit($this);
        $data_header['list_privilegio'] = get_privilegios($this);
        $data_header['pri_grupo'] = 'MOVIMIENTO';
        $data_header['pri_nombre'] = 'Registrar Sangria';
        $data_header['usuario'] = get_usuario($this);
        $data_header['title'] = "Registrar Sangria";

        $data_footer['inits_function'] = array("init_ingreso");

        $this->load->view('header', $data_header);
        $this->load->view('movimiento/sangrias');
        $this->load->view('footer',$data_footer);
    }

}