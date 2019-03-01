<?php
defined('BASEPATH') OR exit('No direct script access allowed');


class Produccion extends CI_Controller
{
    function __construct()
    {
        parent::__construct();
        $this->load->library('session');

        $this->load->database();
        $this->load->model('temp_ingreso_model');
        $this->load->model('rol_has_privilegio_model');

        $this->load->helper('seguridad');
        $this->load->helper('util');
        $this->load->helper('url');
    }

    public function index(){
        is_logged_in_or_exit($this);
        $data_header['list_privilegio'] = get_privilegios($this);
        $data_header['pri_grupo'] = 'MOVIMIENTO';
        $data_header['pri_nombre'] = 'Ingresar Produccion';
        $data_header['usuario'] = get_usuario($this);
        $data_header['title'] = "Porductos Produccion";
        $data_footer['inits_function'] = array("init_produccion");
        $this->load->view('header', $data_header);
        $this->load->view('movimiento/produccion/produccion');
        $this->load->view('footer', $data_footer);
    }

}