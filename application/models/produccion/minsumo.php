<?php
class Minsumo extends CI_Model{
    function __construct()
    {
        parent::__construct();
    }

    public function registrarInsumo($data_insumo){
        $this->db->insert('insumo', $data_insumo);
    }

    public function listarInsumo(){
        $data = $this->db->query('call listar_insumos()');
        return $data->result_array();
    }

    public function listarInsumoInactivo(){
        $data = $this->db->query('call listar_insumosInactivos()');
        return $data->result_array();
    }


    public function cargarDataInsumo($id_insumo){
        if($id_insumo){
            $consulta='select insumo.in_nombre,insumo.in_cantidad,insumo.in_unidad_medida,insumo.in_costo from insumo WHERE insumo.id_insumo=?';
            $data = $this->db->query($consulta,array($id_insumo));
            return $data->row_array();
        }
    }

    public function editarInsumos($id_insumo,$param){
        if($id_insumo){
            $this->db->where('id_insumo',$id_insumo);
            $sql=$this->db->update('insumo',$param);
            if($sql===true){
                return true;
            }else{
                return false;
            }
        }
    }

    public function cambiarEstado($id_insumo){
        $consulta= ('UPDATE insumo set in_estado=\'Inactivo\' where id_insumo=?');
        $this->db->query($consulta,array($id_insumo));
    }

    public function cambiarEstadoA($id_insumo){
        $consulta= ('UPDATE insumo set in_estado=\'Activo\' where id_insumo=?');
        $this->db->query($consulta,array($id_insumo));
    }

    public function gastoInsumo($id_producto_final){
        $consulta =("SELECT din.det_cantidad, ins.in_costo 
        FROM det_insumo as din, insumo as ins 
        WHERE din.id_insumo=ins.id_insumo AND din.id_producto_final=?");
        $data= $this->db->query($consulta,array($id_producto_final));
        return $data->result_array();
    }

}
?>