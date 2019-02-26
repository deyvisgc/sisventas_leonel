<?php
class Mtrabajador extends CI_Model{

    function __construct(){
        parent::__construct();
    }

    public function addTrabajador($data2){
        $this->db->insert('trabajador', $data2);
        return $this->db->insert_id();
    }
public function bucartra($trabajador){
    $consulta=$this->db->query("SELECT t.id_trabajador, Concat(p.per_nombre,' ',p.per_apellido) fulname, c.con_sueldo, c.con_horas_laborales from persona as p, trabajador as t, contrato as c WHERE p.id_persona=t.id_persona AND t.id_trabajador=c.id_trabajador AND t.tra_estado='CONTRATADO' AND (p.per_nombre LIKE '%".$trabajador."%')");
    $data=array();
    foreach ($consulta->result() as $con){
        $con->value=$con->fulname;
        $data[]=$con;
    }
    return $data;
}
public function insertTraba($para){
        $datos=array(
            'id_producto_final'=>$para['id_producto_final'],
            'id_trabajador'=>$para['id_trabajador'],
            'det_horas_trabajo'=>$para['det_horas_trabajo'],
        );
        $this->db->insert('det_trabajador',$datos);
}
public function calcularGastoManoObra($id_producto_final){
        $consulta=("SELECT p.per_nombre,p.per_apellido, c.con_sueldo, c.con_horas_laborales,dt.det_horas_trabajo FROM det_trabajador as dt, trabajador as t, contrato as c, persona as p WHERE p.id_persona=t.id_persona AND t.id_trabajador=c.id_trabajador AND dt.id_trabajador=t.id_trabajador AND dt.id_producto_final=?");
    $data= $this->db->query($consulta,array($id_producto_final));
    return $data->result_array();
    }

    public function listarTra($idproducto){
        $data= $this->db->query("CALL lis_trabajador($idproducto)");
        return $data->row_array();

    }
    public function listaTra($idproducto){
        if($idproducto){
            $data=$this->db->query("SELECT dtra.det_horas_trabajo as cantidad, concat(p.per_nombre,' ', p.per_apellido) as nombre,dtra.id_producto_final, dtra.id_det_trabajador FROM det_trabajador AS dtra, trabajador as t,persona as p WHERE p.id_persona=t.id_persona AND t.id_trabajador=dtra.id_trabajador AND dtra.id_producto_final=$idproducto");
            return $data->result_array();
        }

    }
}
?>