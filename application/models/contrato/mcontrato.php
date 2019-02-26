<?php
class Mcontrato extends CI_Model{
        function __construct(){
            parent::__construct();
        }

        public function generarContrato($data3){      
            $this->db->insert('contrato', $data3);
            return $this->db->insert_id();
        }

    }
?>