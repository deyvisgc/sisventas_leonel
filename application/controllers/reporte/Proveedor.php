<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Proveedor extends CI_Controller
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



}