<?php
class Mproducto extends CI_Model{
    function __construct()
    {
        parent::__construct();
    }

    public function registrarProducto($data_producto){
        $this->db->insert('producto_final',$data_producto);
    }

    public function listarProducto(){
        $data=$this->db->query('call listar_producto()');
        return $data->result_array();
    }

    public function cargarDatosProducto($id_producto_final){
        $consulta = 'SELECT pf.pf_nombre,pf.pf_cantidad,pf.pf_unidad_medida,pf.pf_precio FROM producto_final as pf WHERE pf.id_producto_final=?';
        $data = $this->db->query($consulta,array($id_producto_final));
        return $data->row_array();
    }

    public function editarProducto($id_producto_final,$param){
        $this->db->where('id_producto_final',$id_producto_final);
        $this->db->update('producto_final',$param);
    }


    public function cambiarEstado($id_producto_final){
        $consulta= ('UPDATE producto_final set pf_estado=\'Inactivo\' where id_producto_final=?');
        $this->db->query($consulta,array($id_producto_final));
    }

    public function cambiarEstadoA($id_producto_final){
        $consulta= ('UPDATE producto_final set pf_estado=\'Activo\' where id_producto_final=?');
        $this->db->query($consulta,array($id_producto_final));
    }



public  function cargarProductos($testeo){
        $consulta=$this->db->query("SELECT p.id_producto_final, p.pf_nombre ,p.pf_cantidad FROM producto_final as p WHERE ( p.pf_nombre LIKE '%".$testeo."%')");

    $data=array();
    foreach ($consulta->result() as $con){
        $con->value=$con->pf_nombre;
        $data[]=$con;
    }
    return $data;
}

public function bucarinsu($insumo){
        $consul=$this->db->query("SELECT ins.id_insumo, ins.in_nombre,ins.in_costo,ins.in_cantidad FROM insumo
        as ins WHERE ins.in_estado='Activo' AND ins.in_cantidad>=5 AND (ins.in_nombre LIKE '%".$insumo."%')");
        $data=array();
        foreach ($consul->result() as  $insu){
            $insu->value=$insu->in_nombre;
            $data[]=$insu;
        }
        return $data;
    }

    public function insertarinsu($para){
        $datos=array(

            'id_producto_final'=>$para['id_producto_final'],
            'id_insumo'=>$para['id_insumo'],
            'det_cantidad'=>$para['det_cantidad'],
        );
        $this->db->insert('det_insumo',$datos);

    }
    public function bucarmate($materia){
        $consul=$this->db->query("SELECT ma.id_materia_prima,ma.mp_nombre,ma.mp_cantidad,ma.mp_costo 
        FROM materia_prima as ma WHERE ma.mp_estado='Activo' AND ma.mp_cantidad>=5 AND (ma.mp_nombre LIKE '%".$materia."%')");
        $data=array();
        foreach ($consul->result() as  $mate){
            $mate->value=$mate->mp_nombre;
            $data[]=$mate;
        }
        return $data;
    }

     public function insertMateria($parametros){
        $datos=array(

            'id_materia_prima'=>$parametros['id_materia_prima'],
            'id_producto_final'=>$parametros['id_producto_final'],
            'det_cantidad_materia'=>$parametros['det_cantidad_materia'],

        );
        $this->db->insert('det_materia',$datos);

     }

     public function bucarPro($prod){
         $consul=$this->db->query("SELECT p.id_producto_final, p.pf_nombre ,p.pf_cantidad FROM producto_final as p 
        WHERE p.pf_estado='Activo' AND p.pf_cantidad >=5 AND (p.pf_nombre LIKE '%".$prod."%')");
         $data=array();
         foreach ($consul->result() as  $producto){
             $producto->value=$producto->pf_nombre;
             $data[]=$producto;
         }
         return $data;
     }

     public function insertProdu($para){
        $datos=array(
            'id_producto_final'=>$para['id_producto_final'],
            'new_id_producto_final'=>$para['new_id_producto_final'],
            'det_cantidad_producto'=>$para['det_cantidad_producto'],
        );
        $this->db->insert('det_producto',$datos);
    }
    public function gastoProducto($id_producto_final){
        $consulta =("SELECT pf.pf_precio, dtp.det_cantidad_producto 
        FROM producto_final as pf, det_producto as dtp 
        WHERE pf.id_producto_final=dtp.id_producto_final AND dtp.new_id_producto_final=?");
        $data= $this->db->query($consulta,array($id_producto_final));
        return $data->result_array();
    }

public function listardatos($idproducto){

   $data= $this->db->query("CALL list_insumo($idproducto)");

 return $data->row_array();
}
public function listarMate($idproducto){
    $data= $this->db->query("CALL list_materia($idproducto)");
    return $data->row_array();
}
public function listarProduc($idproducto){
    $data= $this->db->query("CALL list_producto($idproducto)");
    return $data->row_array();
}
    public function listarinsu($idproducto){
        $data= $this->db->query("SELECT ins.in_nombre ,dti.det_cantidad,dti.id_producto_final, ins.in_costo,dti.id_detalle_insumo FROM
                       det_insumo AS dti, insumo AS ins WHERE dti.id_insumo=ins.id_insumo AND dti.id_producto_final=$idproducto");
        return $data->result_array();
    }




public function eliminar($idinsumo){
        if ($idinsumo){
            $this->db->where('id_detalle_insumo ',$idinsumo);
            $this->db->delete('det_insumo');
        }
}

public function listaMate($idproducto){
        if($idproducto){
          $data=  $this->db->query("SELECT dm.id_detalle_materia,mp.mp_nombre,mp.mp_costo,
dm.det_cantidad_materia, mp.id_materia_prima FROM det_materia as dm ,materia_prima mp ,producto_final as pf WHERE dm.id_materia_prima=mp.id_materia_prima
 and pf.id_producto_final=dm.id_producto_final and pf.id_producto_final=$idproducto");
            return $data->result_array();
        }
}
public function listarproductos($idproducto){
 if($idproducto){
     $data= $this->db->query("SELECT pf.pf_nombre as nombre, dtp.det_cantidad_producto as cantidad, dtp.id_producto_final,dtp.id_det_producto,pf.pf_precio FROM det_producto as dtp, producto_final as pf WHERE dtp.id_producto_final=pf.id_producto_final AND dtp.new_id_producto_final=$idproducto");
     return $data->result_array();
 }
}
public function elimianrMateria($idmateria){
        if($idmateria){

            $this->db->where('id_detalle_materia',$idmateria);
            $this->db->delete('det_materia');
        }
}
public function elimianrTraba($idtrabajador){
    if($idtrabajador){

        $this->db->where('id_det_trabajador',$idtrabajador);
        $this->db->delete('det_trabajador');
    }

}
public  function elimianrPr($idpro){

    if($idpro){

        $this->db->where('id_det_producto',$idpro);
        $this->db->delete('det_producto');
    }
}

}
?>