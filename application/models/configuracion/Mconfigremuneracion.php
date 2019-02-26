<?php
defined('BASEPATH') OR exit('No direct script acces allowed');

class Mconfigremuneracion extends CI_Model{


    public function registrarDatosRemuneracion($data_remuneracion){
        $this->db->insert('config_remuneracion', $data_remuneracion);
        return $this->db->insert_id();
    }

    public function listardatosRemuneracion(){
        $this->db->select('id_config_remuneracion, remu_denominacion, remu_interes');
        $datos = $this->db->get('config_remuneracion');
        return $datos->result_array();
    }

    public function selectbyID($id_config_remuneracion=null){
        if($id_config_remuneracion){
            $consulta ="SELECT * FROM config_remuneracion WHERE id_config_remuneracion=?";
            $data = $this->db->query($consulta, array($id_config_remuneracion));
            return $data->row_array();    
        }
    }
    public function editarDatosRemuneracion($id_config_remuneracion,$param){
        if($id_config_remuneracion) {
                $this->db->where('id_config_remuneracion', $id_config_remuneracion);
                $sql = $this->db->update('config_remuneracion', $param);
        	if($sql === true) {
				return true; 
			} else {
				return false;
			}
		}
    }
    public function eliminarDatos($id_config_remuneracion){
        $this->db->where('id_config_remuneracion',$id_config_remuneracion);
        $this->db->delete('config_remuneracion');
    }
}
?>