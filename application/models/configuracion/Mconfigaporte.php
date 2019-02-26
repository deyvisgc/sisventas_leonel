<?php
defined('BASEPATH') OR exit('No direct script acces allowed');

class Mconfigaporte extends CI_Model{


    public function registrarDatosAportes($data_aportes){
        $this->db->insert('config_aporte', $data_aportes);
        return $this->db->insert_id();
    }
    public function listardatosAporte(){
        $this->db->select('id_configaporte, caporte_denominacion, caporte_interes, caporte_primaseguros, caporte_comisionvariable');
        $datos = $this->db->get('config_aporte');
        return $datos->result_array();
    }

    public function selectById($id_configaporte=null){
        if($id_configaporte){
            $consulta = 'SELECT * FROM config_aporte WHERE id_configaporte=?';
            $data = $this->db->query($consulta,array($id_configaporte));
            return $data->row_array();
        }
    }

    public function selectDataAporte(){
            $consulta = 'SELECT caporte_denominacion FROM config_aporte';
            $data = $this->db->query($consulta);
            return $data->result_array();
    }
    public function editardatosAporte($id_configaporte, $param){
        if($id_configaporte){
            $this->db->where('id_configaporte', $id_configaporte);
            $sql=$this->db->update('config_aporte', $param);
            if($sql===true){
                return true;
            }else{
                return false;
            }
        }
    }
    public function eliminarDatos($id_configaporte){
        $this->db->where('id_configaporte',$id_configaporte);
        $this->db->delete('config_aporte');
    }
}
?>