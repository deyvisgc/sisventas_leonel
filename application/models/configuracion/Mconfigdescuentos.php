<?php
defined('BASEPATH') OR exit('No direct script acces allowed');

class Mconfigdescuentos extends CI_Model{


    public function registrarDatosDescuentos($data_descuentos){
        $this->db->insert('config_descuento', $data_descuentos);
        return $this->db->insert_id();
    }

    public function listardatosDescuento(){
        $this->db->select('id_configdescuento, cdes_denominacion, cdes_interes');
        $datos = $this->db->get('config_descuento');
        return $datos->result_array();
    }

    public function selectById($id_configdescuento=null){
        if($id_configdescuento){
            $consulta = 'SELECT * FROM config_descuento WHERE id_configdescuento=?';
            $data = $this->db->query($consulta,array($id_configdescuento));
            return $data->row_array();
        }
    }

    public function editardatosDescuento($id_configdescuento, $param){
        if($id_configdescuento){
            $this->db->where('id_configdescuento', $id_configdescuento);
            $sql=$this->db->update('config_descuento', $param);
            if($sql===true){
                return true;
            }else{
                return false;
            }
        }
    }

    public function eliminarDatos($id_configdescuento){
        $this->db->where('id_configdescuento',$id_configdescuento);
        $this->db->delete('config_descuento');
    }
}
?>