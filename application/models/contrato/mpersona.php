<?php
class Mpersona extends CI_Model{
        function __construct(){
            parent::__construct();
        }

        public function agregarPerson($data){      
            $this->db->insert('persona', $data);
            return $this->db->insert_id();            
        }

        public function listarTrabajador(){        					
            $datos = $this->db->query('SELECT p.id_persona, p.per_nombre, p.per_apellido,t.id_trabajador, t.tra_cargo, t.tra_area, t.tra_estado FROM persona as p, trabajador as t WHERE p.id_persona = t.id_persona');
            return $datos->result_array();
        }

        public function selectById($id_persona=null){
            if($id_persona){
                $consulta='SELECT p.per_nombre, p.per_apellido, p.per_direccion,
                p.per_telefono, p.per_email,p.per_genero, p.per_estado_civil, 
                p.per_dni,p.per_carnet, p.per_fech_nacimiento, t.tra_area, t.tra_cargo, t.id_afiliacion, 
                t.tra_numero_cuenta_aportacion 
                FROM persona AS p, trabajador AS t 
                WHERE p.id_persona=t.id_persona AND t.id_persona=?';
                $data = $this->db->query($consulta,array($id_persona));
                return $data->row_array();
            }
        }

        public function selectByIdContrato($id_trabajador=null){
            if($id_trabajador){
                $consulta='SELECT c.con_fecha_inicio, c.con_fecha_fin, c.con_asignacion_familiar,c.con_dias_laborales,
                c.con_horas_laborales,c.con_sueldo, c.con_periodo_pago
                FROM contrato as c
                WHERE c.id_trabajador=?';
                $data = $this->db->query($consulta,array($id_trabajador));
                return $data->row_array();
            }
        }

        public function editardatosTrabajador($id_persona,$param,$paramT){
            if($id_persona){
                $this->db->where('id_persona', $id_persona);
                $sql=$this->db->update('persona', $param);
                $this->db->where('id_persona',$id_persona);
                $sql2=$this->db->update('trabajador',$paramT);

                if($sql===true){
                    return true;
                }else{
                    return false;
                }
            }
        }

        public function editardatosContrato($id_trabajador,$paramC){            
            $this->db->where('id_trabajador',$id_trabajador);
            $sql3=$this->db->update('contrato',$paramC);
        }

        public function obtenerDataPersonaTrabajador($data_dni){
            $consulta='SELECT p.per_nombre, p.per_apellido, t.tra_cargo, c.con_sueldo 
            FROM persona as p, trabajador as t, contrato as c 
            WHERE p.id_persona=t.id_trabajador AND t.id_trabajador=c.id_trabajador 
            AND p.per_dni=?';
            $data=$this->db->query($consulta,$data_dni);
            return $data->row_array();
        }

    public function obtenerSueldo($id_trabajador){
        $consulta='SELECT c.con_sueldo 
        FROM trabajador as t, contrato as c 
        WHERE t.id_trabajador=c.id_trabajador 
        AND t.id_trabajador=?';
        $data=$this->db->query($consulta,$id_trabajador);
        return $data->row_array();
    }
    public function obtenerAfiliacion($id_trabajador){
            $consulta='SELECT t.id_afiliacion, cap.caporte_interes,cap.caporte_primaseguros,
            cap.caporte_comisionvariable ,c.con_sueldo,c.con_asignacion_familiar, 
            remu.remu_interes 
            FROM trabajador as t, contrato as c, config_aporte as cap, config_remuneracion as remu 
            WHERE t.id_trabajador=c.id_trabajador 
            AND cap.caporte_denominacion=t.id_afiliacion 
            AND remu.remu_denominacion=\'Asignacion Familiar\' 
            AND t.id_trabajador=?';
            $data =$this->db->query($consulta,$id_trabajador);
            return $data->row_array();
    }
    }
?>