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
		$data_header['title'] = "TARGETA KARDEX";
		$data_footer['inits_function'] = array("init_kardex");
		$this->load->view('header', $data_header);
		$this->load->view('reporte/kardex/kardex');
		$this->load->view('footer', $data_footer);
	}

}
