<?php
/**
 * Created by PhpStorm.
 * User: GARCIA
 * Date: 24/10/2018
 * Time: 16:37
 */

class mmateria extends CI_Model
{
public function __construct()
{
    parent::__construct();


}
public function listarmate(){
    $mate='SELECT * FROM materia_prima as ma WHERE ma.mp_estado=\'Activo\'';
    $data=$this->db->query($mate);
    return $data->result_array();
}
public function insertarmateria($para){
    $data=array(

        'mp_nombre'=>$para['mp_nombre'],
        'mp_cantidad'=>$para['mp_cantidad'],
        'mp_unidad_medida'=>$para['mp_unidad_medida'],
        'mp_costo'=>$para['mp_costo'],
        'mp_estado'=>$para['mp_estado'],

    );
    $this->db->insert('materia_prima',$data);
}
public function cargardatos($id_materia){
    if($id_materia){
        $mat='select mp_nombre,mp_cantidad,mp_unidad_medida,mp_costo,mp_estado from materia_prima WHERE id_materia_prima=?';
        $data= $this->db->query($mat,array($id_materia));
        return $data->row_array();
    }

    }

    public function updatemedida($id_materia,$para){
    if($id_materia){
        $this->db->where('id_materia_prima',$id_materia);
        $sql=$this->db->update('materia_prima',$para);
        if($sql===true){
            return true;
        }else{
            return false;
        }
    }


    }
    public function canbioestado($id_materia){
    if($id_materia){
        $esta='UPDATE materia_prima set mp_estado="Activo" WHERE id_materia_prima=?';
       $this->db->query($esta,array($id_materia));

    }
    }

    public function canbioestado1($id_materia){
        if($id_materia){
            $esta='UPDATE materia_prima set mp_estado="Inactivo" WHERE id_materia_prima=?';
            $this->db->query($esta,array($id_materia));

        }
    }
    public function gastoMateria($id_producto_final){
        $consulta =("SELECT dm.det_cantidad_materia, mp.mp_costo 
        FROM det_materia as dm, materia_prima as mp 
        WHERE dm.id_materia_prima=mp.id_materia_prima AND dm.id_producto_final=?");
        $data= $this->db->query($consulta,array($id_producto_final));
        return $data->result_array();
    }
    public function listarmateInactiva(){
        $mate='SELECT * FROM materia_prima as ma WHERE ma.mp_estado=\'Inactivo\'';
        $data=$this->db->query($mate);
        return $data->result_array();
    }
}