<?php
class Mdespido extends CI_Model{
        function __construct(){
            parent::__construct();
        }

        public function insertarDatosDespido($data_despido){
            $this->db->insert('despido', $data_despido);
        }
        public function editardatoContrato($data_despido){
            $id_trabajador = $data_despido['id_trabajador'];
            $query = 'UPDATE trabajador SET tra_estado = \'DESPEDIDO\' WHERE trabajador.id_trabajador = ?';
            $this->db->query($query,array($id_trabajador));
        }
    }
?>