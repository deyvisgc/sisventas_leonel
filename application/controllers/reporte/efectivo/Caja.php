<?php
class Caja extends CI_Controller{
    function __construct()
    {
        parent::__construct();
        $this->load->library('session');
        $this->load->database();
        $this->load->model('reporte_model');
        $this->load->model('Sangria_model');
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

        $list_totales_cre = $this->reporte_model->movimiento_efectivo_total_credito($fecha_ini, $fecha_fin);
        $list_totales_efec = $this->reporte_model->movimiento_efectivo_total_contado($fecha_ini, $fecha_fin);

        $total_sangria_ingreso =$this->Sangria_model->sumar_total_ingreso_sangria_x_fecha($fecha_ini,$fecha_fin);
        $total_sangria_salida = $this->Sangria_model->sumar_total_salida_sangria_x_fecha($fecha_ini,$fecha_fin);

        $efectivo_caja = $this->reporte_model->efectivo_caja($fecha_ini,$fecha_fin);

        $data = array(
            'hecho' => 'SI', 'data' => $list,
            'data_totales' => $list_totales,
            'total_efec'=>$list_totales_efec,
            'total_cre'=>$list_totales_cre,
            'tsangria_ingreso'=>$total_sangria_ingreso,
            'tsangria_salida'=>$total_sangria_salida,
            'efectivo_caja'=>$efectivo_caja
        );
        echo json_encode($data);
    }
    public function buscarCaja(){
		is_logged_in_or_exit($this);

		$list_documento = $this->Sangria_model->buscarCaja();

		$data = array('hecho' => 'SI', 'list_documento' => $list_documento);
		echo json_encode($data);
	}
	public function buscarCajaXCaja($caja){
		is_logged_in_or_exit($this);
		$fecha_ini = $this->input->post('fecha1');
		$fecha_fin = $this->input->post('fecha2');
		$list_Caga = $this->Sangria_model->buscarCajaXCaja($fecha_ini, $fecha_fin,$caja);
		$data=array('hecho','si','data'=>$list_Caga);
		echo json_encode($data);



	}
	public function buscarCajaXCaja_Ingreso($caja){
		is_logged_in_or_exit($this);
		$fecha_ini = $this->input->post('fecha1');
		$fecha_fin = $this->input->post('fecha2');
		$list_Caga = $this->Sangria_model->buscarCajaXCaja_Ingreso($fecha_ini, $fecha_fin,$caja);
		$data=array('hecho','si','data'=>$list_Caga);
		echo json_encode($data);
	}
}
