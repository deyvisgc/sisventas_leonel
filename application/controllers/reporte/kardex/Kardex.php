<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Kardex  extends CI_Controller
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
        $data_header['title'] = "KARDEX";
        $data_footer['inits_function'] = array("init_kardex");
        $this->load->view('header', $data_header);
        $this->load->view('reporte/kardex/kardex');
        $this->load->view('footer', $data_footer);
    }

    public function Listar_Productos(){
        is_logged_in_or_exit($this);
        $result = array('data'=>array());
        $data = $this->kardex_model->Cargar_Data_Productos();

        foreach ($data as $key =>$value){
            $clase = $value['clase_nombre'];
            $subclase = $value['subclase_nombre'];
            $producto = $value['pro_nombre'];
            $cantidad = $value['pro_cantidad'];
            $pcompra = $value['pro_val_compra'];
            $pventa = $value['pro_val_venta'];
            $button = '
	        <button type="button" onclick="Detalle_Kardex('.$value['pro_id_producto'].')" 
	        data-toggle="modal" data-target="#detalle_kardex" class="btn btn-facebook"><i class="fa fa-archive"></i> KARDEX</button>
	        ';

            $result['data'][$key]=array(
                $clase,$subclase,$producto,$cantidad,$pcompra,$pventa,$button
            );
        }
        echo json_encode($result);
    }

    public function Kardex_Entrada($id_producto){
        is_logged_in_or_exit($this);

        $entradas = $this->kardex_model->Kardex_Entradas($id_producto);
        $totales_entrada = $this->kardex_model->Kardex_Entradas_Total($id_producto);
        $result = array('data'=>array(),'totales_entrada'=>$totales_entrada);

        foreach ($entradas as $key =>$value){
            $fecha = $value['ing_fecha_registro'];
            $doc = $value['ing_numero_doc_proveedor'];
            $lote = $value['ind_numero_lote'];
            $cantidad = $value['ind_cantidad'];
            $precio = $value['ind_valor'];
            $stotal = $value['precio_compra'];

            $result['data'][$key]=array(
                $fecha,$doc,$lote,$cantidad,$precio,$stotal
            );
        }

        echo json_encode($result);
    }

    public function Kardex_EntradaXproduccion($id_producto){
		is_logged_in_or_exit($this);

		$entradasxproduccion = $this->kardex_model->Kardex_EntradasXPRODUCCION($id_producto);
		$totales_entrada = $this->kardex_model->Kardex_Entradas_Total_SUMAS($id_producto);
		$result = array('data'=>array(),'totales_entrada'=>$totales_entrada);

		foreach ($entradasxproduccion as $key =>$value){
			$fecha = $value['ing_fecha_registro'];
			$lote = $value['ind_numero_lote'];
			$cantidad = $value['ind_cantidad'];
			$precio = $value['ind_valor'];
			$stotal = $value['precio_compra'];

			$result['data'][$key]=array(
				$fecha,$lote,$cantidad,$precio,$stotal
			);
		}

		echo json_encode($result);
	}

    public function Kardex_Salidas($id_producto){
        is_logged_in_or_exit($this);
        $salidas = $this->kardex_model->Kardex_Salidas($id_producto);
        $totales_salida = $this->kardex_model->Kardex_Salidas_Total($id_producto);

        $result = array('data'=>array(),'total_salida'=>$totales_salida);

        foreach ($salidas as $key =>$value){
            $fecha = $value['sal_fecha_registro'];
            $doc = $value['sal_numero_doc_cliente'];
            $lote = $value['sad_numero_lote'];
            $cantidad = $value['sad_cantidad'];
            $precio = $value['sad_valor'];
            $stotal = $value['total_venta'];

            $result['data'][$key]=array(
                $fecha,$doc,$lote,$cantidad,$precio,$stotal
            );
        }

        echo json_encode($result);
    }

    public function Kardex_Existencias($id_producto){
        is_logged_in_or_exit($this);

        $result = array('data'=>array());

        $existencias = $this->kardex_model->Kardex_Existencias($id_producto);

        foreach ($existencias as $key =>$value){
            $cantidad = $value['pro_cantidad'];
            $precio = $value['pro_val_compra'];
            $stotal = $value['total_compra'];

            $result['data'][$key]=array(
                $cantidad,$precio,$stotal
            );
        }

        echo json_encode($result);
    }

    public function Kardex_Salidas_Produccion($id_producto){
        is_logged_in_or_exit($this);

        $salida_produccion = $this->kardex_model->kardex_salida_produccion($id_producto);
        $totales_salidas_produccion = $this->kardex_model->Kardex_Salidas_Total_Produccion($id_producto);
        $result = array('data'=>array(),'totales_salidas_produccion'=>$totales_salidas_produccion);

        foreach ($salida_produccion as $key => $item) {
            $fecha=$item['pro_fecha'];
            $doc = '000';
            $lote = $item['pro_lote'];
            $cantidad = $item['pro_cantidad'];
            $v_unitario = $item['pro_val_compra'];
            $v_total = $item['pro_monto'];
            $result['data'][$key]=array(
                $fecha,$doc,$lote,$cantidad,$v_unitario,$v_total
            );
        }
        echo json_encode($result);
    }
}
