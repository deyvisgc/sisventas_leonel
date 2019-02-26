<?php
class Mgastodirecto extends CI_Model{
    function __construct()
    {
        parent::__construct();
    }

    public function listarProductos(){
        $data=$this->db->query('CALL listar_PF_produccion()');
        return $data->result_array();
    }

    public function listarGastos($id_gasto_directo=null){
        $data=$this->db->query("CALL listarDatosGastos($id_gasto_directo)");
        return $data->row_array();
    }

    public function registrarGastosProduccion($data_costes){
        $this->db->insert('gasto_directo',$data_costes);
    }
}
?>