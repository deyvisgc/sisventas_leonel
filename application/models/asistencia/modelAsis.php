<?php


class modelAsis extends CI_Model
{

    public function __construct()
    {
        parent::__construct();
    }
 /**   public function datos($dn,$nombre){
        $this->db->like('per_nombre',$nombre);
        $this->db->like('per_dni',$dn);
        $consulta= $this->db->get('persona');
        return $consulta->row_array();


    }
  */
    public function data($testo){
        $consulta=$this->db->query(
            "SELECT p.id_persona ,p.per_nombre,p.per_dni,p.per_apellido 
            from persona as p WHERE( p.per_nombre LIKE '%".$testo."%' Or p.per_dni 
            LIKE '%".$testo."%')");

        $data=array();
        foreach ($consulta->result() as $con){
            $con->value=$con->per_nombre;
            $con->value=$con->per_apellido;
            $data[]=$con;
        }
        return $data;
    }
        public function guardar($persona){

        $campos=array(
            'asis_fecha'=>$persona['fecha'],
            'asis_hora_ingreso'=>$persona['hora'],
            'id_persona'=>$persona['id_persona'],
        );
        $this->db->insert('asistencia',$campos);

    }
    public function getasistencia(){
        $this->db->select('a.id_asistencia,a.asis_fecha,a.asis_hora_ingreso,p.per_dni,a.asis_hora_salida,p.per_nombre');
        $this->db->from('asistencia as a');
        $this->db->join('persona as p','a.id_persona=p.id_persona');
        $lista=$this->db->get();
        return  $lista->result_array();
    }
    public function carasistencia($id_asistencia=null){
        if($id_asistencia){
            $sql='SELECT p.per_dni,a.asis_hora_ingreso,a.asis_fecha,a.asis_hora_salida FROM asistencia as a INNER JOIN persona as p on a.id_persona=p.id_persona and a.id_asistencia=?';
            $data=$this->db->query($sql,array($id_asistencia));
            return $data->row_array();
        }

    }
    public function registrar($id_asistencia,$para,$para1){
        if($id_asistencia){

            $campos=array(
                'asis_fecha'=>$para['fecha'],
                'asis_hora_ingreso'=>$para['hora'],
                'per_dni'=>$para1['per_dni'],
                'asis_hora_salida'=>$para['asis_hora_salida'],
            );
            $this->db->where('id_asistencia', $id_asistencia);
            $sql=$this->db->update('asistencia', $para,$campos);
            $this->db->where('id_asistencia',$id_asistencia);
            $sq1=$this->db->update('persona',$para1,$campos);
            if($sql===true){
                return true;
            }else{
                return false;
            }
        }

    }
    public function eliminardatos($id_asistencia){
        $this->db->where('id_asistencia',$id_asistencia);
        $this->db->delete('asistencia');
    }
    public function cargarid($dni){
        $consulta=('SELECT id_persona FROM persona WHERE per_dni=?');
       $dni1= $this->db->query($consulta,$dni);
        return $dni1->row_array();

    }
    public function insertarAsis($parametros,$salida){
        $campos=array(
            'id_persona'=>$parametros['id_persona'],
        );
        $id_persona = implode($campos);
        $hsalida=array(
            'asis_hora_salida'=>$salida['asis_hora_salida'],
        );
        $this->db->where('id_persona',$id_persona);
        $this->db->update('asistencia',$hsalida);
    }

}