<?php
class Mplanilla extends CI_Model{
    public function __construct()
    {
        parent::__construct();
    }
    public function cargarDataPlanilla(){
        $consulta='SELECT p.per_nombre, p.per_apellido, p.per_dni, p.per_carnet, t.tra_cargo,t.id_trabajador, 
        t.tra_estado_boleta , t.id_afiliacion,c.con_asignacion_familiar , c.con_sueldo 
        FROM trabajador as t, persona as p,contrato as c WHERE p.id_persona=t.id_persona 
        AND t.id_trabajador=c.id_trabajador AND t.tra_estado=\'CONTRATADO\' and t.tra_estado_boleta=\'PROCESAR BOLETA\'';
        $data = $this->db->query($consulta);
        return $data->result_array();
    }
    public function cargarDataAporte(){
        $consulta='SELECT ap.caporte_denominacion, ap.caporte_interes,ap.caporte_primaseguros,ap.caporte_comisionvariable FROM config_aporte as ap';
        $data=$this->db->query($consulta);
        return $data->result_array();
    }
    public function cargarDataDescuento(){
        $consulta='SELECT des.cdes_denominacion,des.cdes_interes FROM config_descuento as des';
        $data=$this->db->query($consulta);
        return $data->result_array();
    }
    public function cargarDataRemuneracion(){
        $consulta='SELECT remu.remu_denominacion,remu.remu_interes FROM config_remuneracion as remu';
        $data=$this->db->query($consulta);
        return $data->result_array();
    }
    public function registrarTotales($data_planilla){
        $this->db->insert('planilla',$data_planilla);
        return $this->db->insert_id();
    }
    public function insertarDetPlanilla($data_det_planilla){
        $this->db->insert('det_planilla',$data_det_planilla);
    }
    public function insertarDetPlanillas($data_det_planilla){
        $this->db->insert('det_planilla_s',$data_det_planilla);
    }
    public function cargarDataTablaBoletaPago(){
        $consulta='SELECT p.per_nombre, p.per_apellido, p.per_dni,p.per_carnet, detpla.det_sueldo,tra.id_trabajador,tra.tra_estado_impresion 
        FROM persona as p, trabajador as tra, det_planilla as detpla 
        WHERE p.id_persona=tra.id_persona AND tra.id_trabajador=detpla.id_trabajador;';
        $data=$this->db->query($consulta);
        return $data->result_array();
    }
    public function cambiarEstadoImpresion($id_trabajador=null){
        $this->db->query("CALL ACTUALIZAR_ESTADO_IMPRESION($id_trabajador)");
    }
    public function cargarBoleta($id_trabajador=null){
        if($id_trabajador){
            $cons='SELECT t.id_afiliacion,p.per_nombre, p.per_apellido, p.per_dni,p.per_carnet,t.tra_cargo,empresa.em_ruc,empresa.em_nombre, dt.det_sueldo,dt.det_asignacionfamiliar, dt.det_essalud,dt.det_horaextra,dt.det_bonificacion, dt.det_gratificacionjulio,dt.det_horaextrasimple, dt.det_horaextradoble,dt.det_vacaciones,dt.det_gratificaciondiciembre,contrato.con_sueldo,dt.det_adelantosueldo,dt.det_tardanza,dt.det_faltas,dt.det_categoria, dt.det_totalafiliacion FROM persona as p, trabajador as t, det_planilla
 as dt, empresa,contrato WHERE p.id_persona=t.id_persona 
 AND t.id_trabajador=contrato.id_trabajador 
 AND contrato.id_trabajador=dt.id_trabajador
  AND dt.id_trabajador=?';
            $datos= $this->db->query($cons,$id_trabajador);
            return $datos->row_array();
        }
    }
    public function listarpagototal(){
        $consul='SELECT Concat(MONTH(pla_fecha),\'/\',YEAR(pla_fecha)) as fecha, SUM(planilla.pla_pago_total +det_planilla_s.det_essalud) as total FROM planilla, det_planilla_s WHERE planilla.id_planilla=det_planilla_s.id_planilla and MONTH(pla_fecha)=MONTH(now())';
        $pago=$this->db->query($consul);
        return $pago->result_array();
    }

    public function cambiarEstadoBoleta(){
        $consulta='UPDATE trabajador SET trabajador.tra_estado_boleta= \'PROCESAR BOLETA\'';
        $data=$this->db->query($consulta);
        return $data;
    }

    public function cambiarEstadoImpresions(){
        $consulta='UPDATE trabajador SET trabajador.tra_estado_impresion= \'IMPRIMIR BOLETA\' ';
        $data=$this->db->query($consulta);
        return $data;
    }

    public function eliminarDetPlanilla(){
        $consulta='DELETE FROM det_planilla';
        $data = $this->db->query($consulta);
        return $data;
    }

    public function call_detalle($fecha_ini,$fecha_fin){
        $list=array();
        $query = $this->db->query("SELECT p.per_nombre,p.per_apellido,p.per_dni,p.per_carnet,t.tra_cargo,pla.pla_pago_total, pla.pla_fecha  FROM planilla as pla, trabajador as t, persona as p WHERE p.id_persona=t.id_persona AND t.id_trabajador=pla.id_trabajador AND STR_TO_DATE(pla.pla_fecha, '%Y-%m-%d') BETWEEN STR_TO_DATE('$fecha_ini', '%Y-%m-%d') AND STR_TO_DATE('$fecha_fin', '%Y-%m-%d') ORDER BY pla.pla_fecha DESC");
        foreach ($query->result() as $row)
        {
            $list[] = $row;
        }
        return $list;
    }
}
?>