<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Mempresa extends CI_Model{

    public function registrarDatosEmpresa($data_empresa){
        $this->db->insert('empresa', $data_empresa);
        return $this->db->insert_id();
    }


    public function dataEmpresa(){
        $consulta = 'SELECT em_nombre, em_ruc FROM empresa';
        $data = $this->db->query($consulta);
        return $data->row_array();
    }

    public function listardatosEmpresa(){
        /*$this->db->select('id_empresa,em_nombre,em_ruc,em_rubro');
        */
        $datos=$this->db->get('empresa');
        return $datos->result_array();
    }

    public function selectbyID($id_empresa=null){
        if($id_empresa){
            $consulta='SELECT * FROM empresa WHERE id_empresa=?';
            $data=$this->db->query($consulta,array($id_empresa));
            return $data->row_array();
        }
    }

    public function editardatosEmpresa($id_empresa,$param){
        if($id_empresa){
            $this->db->where('id_empresa',$id_empresa);
            $sql=$this->db->update('empresa',$param);
            if($sql === true){
                return true;
            }else{
                return false;
            }
        }
    }
}
?>