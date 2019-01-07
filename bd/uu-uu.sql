/*
SQLyog Community v12.5.0 (64 bit)
MySQL - 10.1.32-MariaDB : Database - bd_punto_dventa
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`bd_punto_dventa` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `bd_punto_dventa`;

/*Table structure for table `caja` */

DROP TABLE IF EXISTS `caja`;

CREATE TABLE `caja` (
  `caj_id_caja` varchar(4) NOT NULL,
  `caj_descripcion` varchar(20) DEFAULT NULL,
  `caj_codigo` varchar(20) DEFAULT NULL,
  `caj_abierta` varchar(2) DEFAULT NULL,
  `usu_id_usuario` int(10) DEFAULT NULL,
  `est_id_estado` int(10) DEFAULT NULL,
  PRIMARY KEY (`caj_id_caja`),
  UNIQUE KEY `caja_un_codigo` (`caj_codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `caja` */

insert  into `caja`(`caj_id_caja`,`caj_descripcion`,`caj_codigo`,`caj_abierta`,`usu_id_usuario`,`est_id_estado`) values 
('1801','CAJA 1','20180906041044','NO',NULL,11),
('1802','CAJA 2',NULL,'NO',NULL,11);

/*Table structure for table `clase` */

DROP TABLE IF EXISTS `clase`;

CREATE TABLE `clase` (
  `cla_id_clase` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cla_nombre` varchar(60) DEFAULT NULL,
  `cla_id_clase_superior` int(10) unsigned DEFAULT NULL,
  `est_id_estado` int(10) unsigned DEFAULT NULL,
  `cla_eliminado` varchar(2) DEFAULT NULL,
  PRIMARY KEY (`cla_id_clase`)
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=latin1;

/*Data for the table `clase` */

insert  into `clase`(`cla_id_clase`,`cla_nombre`,`cla_id_clase_superior`,`est_id_estado`,`cla_eliminado`) values 
(33,'Maiz',NULL,11,'NO'),
(34,'Nacional',33,11,'NO'),
(35,'Importado',33,11,'NO'),
(36,'Repaso',33,11,'NO'),
(37,'Mezcla',NULL,11,'NO'),
(38,'Mezcla ',37,11,'NO'),
(39,'Economico',37,11,'NO'),
(40,'Molido',37,11,'NO'),
(41,'Cuy R',37,11,'NO'),
(42,'Mezcla P',37,11,'NO'),
(43,'Mezcla C',37,11,'NO'),
(44,'Ponedora 2H',37,11,'NO'),
(45,'Vita Ovo',NULL,11,'NO'),
(46,'Vita Ovo',45,11,'NO'),
(47,'Vita Ave',NULL,11,'NO'),
(48,'Vita Cuy',47,11,'NO'),
(49,'Inicio Vita ',47,11,'NO'),
(50,'Engorde Vita',47,11,'NO'),
(51,'Crecimiento Vita',47,11,'NO'),
(52,'Ponedora Vita',47,11,'NO'),
(53,'Oscar',NULL,11,'NO'),
(54,'Cuy Oscar',53,11,'NO'),
(55,'Conejo Oscar',53,11,'NO'),
(56,'Trigo',NULL,11,'NO'),
(57,'Trigo negro',56,11,'NO'),
(58,'Trigo Blanco',53,11,'NO'),
(59,'Kompano',NULL,11,'NO'),
(60,'Inicio Verde',59,11,'NO'),
(61,'Inicio Rojo',59,11,'NO'),
(62,'Engorde Simple',59,11,'NO'),
(63,'Crecimiento Simple',59,11,'NO'),
(64,'Hector',NULL,11,'NO'),
(65,'Engorde Simple',64,11,'NO'),
(66,'Crecimiento Simple',64,11,'NO'),
(67,'Afrecho',NULL,11,'NO'),
(68,'Afrecho Simple',67,11,'NO'),
(69,'Afrecho Compuesto',67,11,'NO'),
(70,'Cogorno',NULL,11,'NO'),
(71,'Conejo',70,11,'NO'),
(72,'Pico & Navaja',70,11,'NO'),
(73,'BB Mycym',70,11,'NO'),
(74,'B12',NULL,11,'NO'),
(75,'Inicio B12',74,11,'NO'),
(76,'Crecimiento B12',74,11,'NO'),
(77,'Engorde B12',74,11,'NO'),
(78,'Ponedora B12',74,11,'NO'),
(79,'Salud Total',74,11,'NO'),
(80,'Cuy B12',74,11,'NO'),
(81,'Conejo B12',74,11,'NO'),
(82,'Produccion',NULL,11,'NO'),
(83,'Insumos',82,11,'NO'),
(84,'Alimento',NULL,11,'NO'),
(85,'Gato',84,11,'NO'),
(86,'Perro',84,11,'NO');

/*Table structure for table `datos_empresa_local` */

DROP TABLE IF EXISTS `datos_empresa_local`;

CREATE TABLE `datos_empresa_local` (
  `daemlo_id_datos_empresa_local` int(10) unsigned NOT NULL,
  `daemlo_ruc` varchar(20) DEFAULT NULL,
  `daemlo_nombre_empresa_juridica` varchar(100) DEFAULT NULL,
  `daemlo_nombre_empresa_fantasia` varchar(100) DEFAULT NULL,
  `daemlo_codigo_postal` varchar(50) DEFAULT NULL,
  `daemlo_direccion` varchar(100) DEFAULT NULL,
  `daemlo_ciudad` varchar(100) DEFAULT NULL,
  `daemlo_estado` varchar(100) DEFAULT NULL,
  `daemlo_telefono` varchar(50) DEFAULT NULL,
  `daemlo_telefono2` varchar(50) DEFAULT NULL,
  `daemlo_telefono3` varchar(50) DEFAULT NULL,
  `daemlo_telefono4` varchar(50) DEFAULT NULL,
  `daemlo_contacto` varchar(100) DEFAULT NULL,
  `daemlo_web` varchar(100) DEFAULT NULL,
  `daemlo_facebook` varchar(100) DEFAULT NULL,
  `daemlo_instagram` varchar(100) DEFAULT NULL,
  `daemlo_twitter` varchar(100) DEFAULT NULL,
  `daemlo_youtube` varchar(100) DEFAULT NULL,
  `daemlo_otros` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`daemlo_id_datos_empresa_local`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `datos_empresa_local` */

insert  into `datos_empresa_local`(`daemlo_id_datos_empresa_local`,`daemlo_ruc`,`daemlo_nombre_empresa_juridica`,`daemlo_nombre_empresa_fantasia`,`daemlo_codigo_postal`,`daemlo_direccion`,`daemlo_ciudad`,`daemlo_estado`,`daemlo_telefono`,`daemlo_telefono2`,`daemlo_telefono3`,`daemlo_telefono4`,`daemlo_contacto`,`daemlo_web`,`daemlo_facebook`,`daemlo_instagram`,`daemlo_twitter`,`daemlo_youtube`,`daemlo_otros`) values 
(1,'10404115184','GOLOSINAS ','GOLOSINAS ','051','Av De La Cultura Nro. 701 Int. P-2 Mercado Productores Santa Anita - Lima - Lima','Lima','Lima','965-421-048','963-822-261','','',NULL,'','face','instagram','twitter','','marlenecastrohermoza@gmail.com');

/*Table structure for table `empresa` */

DROP TABLE IF EXISTS `empresa`;

CREATE TABLE `empresa` (
  `emp_id_empresa` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `emp_ruc` varchar(11) DEFAULT NULL,
  `emp_razon_social` varchar(100) DEFAULT NULL,
  `emp_direccion` varchar(100) DEFAULT NULL,
  `emp_telefono` varchar(20) DEFAULT NULL,
  `emp_nombre_contacto` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`emp_id_empresa`),
  UNIQUE KEY `empresa_un_ruc` (`emp_ruc`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

/*Data for the table `empresa` */

insert  into `empresa`(`emp_id_empresa`,`emp_ruc`,`emp_razon_social`,`emp_direccion`,`emp_telefono`,`emp_nombre_contacto`) values 
(1,'21344242223','SANTA ANITA 2','MZ','',''),
(2,'12345678901','MONTELEZ','HUACHIPA','XXXX','RAMIRO'),
(3,'21344111223','METRO S.R.L.','MIRAFLORES','676-4108',''),
(4,'21347716523','METRO LIMA SUR S.R.L.','LIMA SUR','440-6040','ESTEPHANIA'),
(5,'15','15','15','15','15'),
(6,'61234000015','lupita','xxx','',''),
(7,'51234537815','','','',''),
(8,'','AC DISTRIBUIDORA EIRL','','960156138','SR JUAN');

/*Table structure for table `estado` */

DROP TABLE IF EXISTS `estado`;

CREATE TABLE `estado` (
  `est_id_estado` int(10) unsigned NOT NULL,
  `est_nombre` varchar(100) DEFAULT NULL,
  `est_tabla` varchar(100) DEFAULT NULL,
  `est_orden` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`est_id_estado`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `estado` */

insert  into `estado`(`est_id_estado`,`est_nombre`,`est_tabla`,`est_orden`) values 
(1,'CREADO','INGRESO',1),
(2,'FINALIZADO','INGRESO',2),
(11,'HABILITADO','ACCESO',1),
(12,'DESHABILITADO','ACCESO',2);

/*Table structure for table `ingreso` */

DROP TABLE IF EXISTS `ingreso`;

CREATE TABLE `ingreso` (
  `ing_id_ingreso` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pcl_id_cliente` int(10) unsigned DEFAULT NULL,
  `pcl_id_proveedor` int(10) unsigned DEFAULT NULL,
  `ing_fecha_doc_proveedor` date DEFAULT NULL,
  `tdo_id_tipo_documento` int(10) unsigned DEFAULT NULL,
  `ing_numero_doc_proveedor` varchar(30) DEFAULT NULL,
  `ing_fecha_registro` datetime DEFAULT NULL,
  `ing_tipo` varchar(2) DEFAULT NULL,
  `ing_monto` double(15,2) DEFAULT NULL,
  `ing_monto_base` double(15,2) DEFAULT NULL,
  `ing_monto_efectivo` double(15,2) DEFAULT NULL,
  `ing_monto_tar_credito` double(15,2) DEFAULT NULL,
  `ing_monto_tar_debito` double(15,2) DEFAULT NULL,
  `caj_id_caja` varchar(4) DEFAULT NULL,
  `caj_codigo` varchar(20) DEFAULT NULL,
  `usu_id_usuario` int(11) DEFAULT NULL,
  `est_id_estado` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`ing_id_ingreso`),
  KEY `ingreso_fk_tip_doc` (`tdo_id_tipo_documento`),
  KEY `ingreso_fk_pcliente` (`pcl_id_proveedor`),
  KEY `ingreso_fk_pcliente2` (`pcl_id_cliente`),
  CONSTRAINT `ingreso_ibfk_1` FOREIGN KEY (`tdo_id_tipo_documento`) REFERENCES `tipo_documento` (`tdo_id_tipo_documento`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `ingreso_ibfk_2` FOREIGN KEY (`pcl_id_proveedor`) REFERENCES `pcliente` (`pcl_id_pcliente`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `ingreso_ibfk_3` FOREIGN KEY (`pcl_id_cliente`) REFERENCES `pcliente` (`pcl_id_pcliente`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `ingreso` */

/*Table structure for table `ingreso_detalle` */

DROP TABLE IF EXISTS `ingreso_detalle`;

CREATE TABLE `ingreso_detalle` (
  `ind_id_ingreso_detalle` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pro_id_producto` int(10) unsigned NOT NULL,
  `ing_id_ingreso` int(10) unsigned NOT NULL,
  `ind_cantidad` double(15,2) unsigned DEFAULT NULL,
  `ind_valor` double(15,2) DEFAULT NULL,
  `ind_monto` double(15,2) DEFAULT NULL,
  `ind_numero_lote` varchar(30) DEFAULT NULL,
  `ind_perecible` varchar(2) DEFAULT NULL,
  `ind_fecha_vencimiento` date DEFAULT NULL,
  `est_id_estado` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`ind_id_ingreso_detalle`),
  KEY `ingreso_detalle_fk_ingreso` (`ing_id_ingreso`),
  KEY `ingreso_detalle_fk_producto` (`pro_id_producto`),
  CONSTRAINT `ingreso_detalle_ibfk_1` FOREIGN KEY (`ing_id_ingreso`) REFERENCES `ingreso` (`ing_id_ingreso`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `ingreso_detalle_ibfk_2` FOREIGN KEY (`pro_id_producto`) REFERENCES `producto` (`pro_id_producto`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `ingreso_detalle` */

/*Table structure for table `movimiento` */

DROP TABLE IF EXISTS `movimiento`;

CREATE TABLE `movimiento` (
  `mov_id_movimiento` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ind_id_ingreso_detalle` int(10) unsigned DEFAULT NULL,
  `sad_id_salida_detalle` int(10) unsigned DEFAULT NULL,
  `ing_id_ingreso` int(10) unsigned DEFAULT NULL,
  `sal_id_salida` int(10) unsigned DEFAULT NULL,
  `mov_tipo` varchar(3) DEFAULT NULL,
  `mov_cantidad_anterior` double(15,2) DEFAULT NULL,
  `mov_cantidad_entrante` double(15,2) DEFAULT NULL,
  `mov_cantidad_actual` double(15,2) DEFAULT NULL,
  `pro_id_producto` int(10) unsigned DEFAULT NULL,
  `est_id_estado` int(10) unsigned DEFAULT NULL,
  `usu_id_usuario` int(11) DEFAULT NULL,
  PRIMARY KEY (`mov_id_movimiento`),
  KEY `movimiento_fk_ingreso_detalle` (`ind_id_ingreso_detalle`),
  KEY `movimiento_fk_salida_detalle` (`sad_id_salida_detalle`),
  CONSTRAINT `movimiento_ibfk_1` FOREIGN KEY (`ind_id_ingreso_detalle`) REFERENCES `ingreso_detalle` (`ind_id_ingreso_detalle`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `movimiento_ibfk_2` FOREIGN KEY (`sad_id_salida_detalle`) REFERENCES `salida_detalle` (`sad_id_salida_detalle`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `movimiento` */

/*Table structure for table `pcliente` */

DROP TABLE IF EXISTS `pcliente`;

CREATE TABLE `pcliente` (
  `pcl_id_pcliente` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `per_id_persona` int(11) DEFAULT NULL,
  `emp_id_empresa` int(10) unsigned DEFAULT NULL,
  `pcl_tipo` varchar(2) DEFAULT NULL,
  `est_id_estado` int(10) unsigned DEFAULT NULL,
  `pcl_eliminado` varchar(2) DEFAULT NULL,
  PRIMARY KEY (`pcl_id_pcliente`),
  KEY `pcliente_fk_empresa` (`emp_id_empresa`),
  KEY `pcliente_fk_persona` (`per_id_persona`),
  CONSTRAINT `pcliente_ibfk_1` FOREIGN KEY (`emp_id_empresa`) REFERENCES `empresa` (`emp_id_empresa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `pcliente_ibfk_2` FOREIGN KEY (`per_id_persona`) REFERENCES `persona` (`per_id_persona`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

/*Data for the table `pcliente` */

insert  into `pcliente`(`pcl_id_pcliente`,`per_id_persona`,`emp_id_empresa`,`pcl_tipo`,`est_id_estado`,`pcl_eliminado`) values 
(1,NULL,1,'1',11,'NO'),
(2,NULL,2,'2',11,'NO'),
(3,NULL,3,'3',11,'NO'),
(4,NULL,4,'3',11,'NO'),
(5,NULL,5,'3',11,'NO'),
(6,NULL,6,'2',NULL,'NO'),
(7,NULL,7,'1',NULL,'NO'),
(8,NULL,8,'3',NULL,'NO');

/*Table structure for table `persona` */

DROP TABLE IF EXISTS `persona`;

CREATE TABLE `persona` (
  `per_id_persona` int(11) NOT NULL AUTO_INCREMENT,
  `per_nombre` varchar(100) DEFAULT NULL,
  `per_apellido` varchar(100) DEFAULT NULL,
  `tdo_id_tipo_documento` int(10) unsigned NOT NULL,
  `per_numero_doc` varchar(30) DEFAULT NULL,
  `per_direccion` varchar(100) DEFAULT NULL,
  `per_tel_movil` varchar(30) DEFAULT NULL,
  `per_tel_fijo` varchar(30) DEFAULT NULL,
  `per_foto` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`per_id_persona`),
  UNIQUE KEY `persona_un_tipdoc_numerodoc` (`tdo_id_tipo_documento`,`per_numero_doc`),
  KEY `persona_fk_tip_doc` (`tdo_id_tipo_documento`),
  CONSTRAINT `persona_ibfk_1` FOREIGN KEY (`tdo_id_tipo_documento`) REFERENCES `tipo_documento` (`tdo_id_tipo_documento`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

/*Data for the table `persona` */

insert  into `persona`(`per_id_persona`,`per_nombre`,`per_apellido`,`tdo_id_tipo_documento`,`per_numero_doc`,`per_direccion`,`per_tel_movil`,`per_tel_fijo`,`per_foto`) values 
(1,'Panel','Control',1,'00000001','Admin','955-123-128','395-8590','cG6i8d1ntzfPvjLIbFYH.jpg'),
(2,'Area','Venta',1,'44332233','X','','','V4Gwtn1chdFNAEPvyQeI.jpg'),
(3,'Area','Caja',1,'123456789','Lima','123456789','12354567','img_vacio.png');

/*Table structure for table `privilegio` */

DROP TABLE IF EXISTS `privilegio`;

CREATE TABLE `privilegio` (
  `pri_id_privilegio` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pri_nombre` varchar(100) DEFAULT NULL,
  `pri_acceso` varchar(100) DEFAULT NULL,
  `pri_grupo` varchar(20) DEFAULT NULL,
  `pri_orden` int(11) DEFAULT NULL,
  `est_id_estado` int(10) unsigned DEFAULT NULL,
  `pri_ico` varchar(20) DEFAULT NULL,
  `pri_ico_grupo` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`pri_id_privilegio`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;

/*Data for the table `privilegio` */

insert  into `privilegio`(`pri_id_privilegio`,`pri_nombre`,`pri_acceso`,`pri_grupo`,`pri_orden`,`est_id_estado`,`pri_ico`,`pri_ico_grupo`) values 
(1,'Usuario','mantenimiento/usuario','ADMINISTRACION',1,1,'user-cog','cog'),
(2,'Cliente','mantenimiento/pcliente','MANTENIMIENTO',12,1,'street-view','pencil-square-o'),
(3,'Producto','mantenimiento/producto','MANTENIMIENTO',3,1,'atlas','server'),
(4,'Uni. Medida','mantenimiento/unidad_medida','MANTENIMIENTO',4,1,'balance-scale','server'),
(5,'Clase','mantenimiento/clase','MANTENIMIENTO',5,1,'bezier-curve','server'),
(6,'Rol','mantenimiento/rol','ADMINISTRACION',6,1,'id-card','cog'),
(7,'Compra','movimiento/ingreso/proveedor','MOVIMIENTO',7,1,'cart-plus','shopping-cart'),
(8,'Venta','movimiento/salida/cliente','MOVIMIENTO',8,1,'cart-arrow-down','shopping-cart'),
(9,'Datos Empresa Local','mantenimiento/datos_empresa_local','ADMINISTRACION',9,1,'building','cog'),
(10,'Stock','reporte/stock','REPORTE',10,1,'calculator','table'),
(11,'Movimiento','reporte/movimiento','REPORTE',11,1,'chart-line','table'),
(12,'Proveedor','mantenimiento/pcliente','MANTENIMIENTO',13,1,'street-view','pencil-square-o'),
(13,'Caja','mantenimiento/caja','ADMINISTRACION',14,1,'money','cog'),
(14,'Apertura Caja','movimiento/caja/apertura','MOVIMIENTO',15,1,'lock-open','shopping-cart'),
(15,'Cierre Caja','movimiento/caja/cierre','MOVIMIENTO',16,1,'lock','shopping-cart'),
(16,'Cambiar clave','administracion/usuario_cambio_clave','ADMINISTRACION',17,1,'user-lock','cog'),
(17,'Reset clave','administracion/usuario_reset_clave','ADMINISTRACION',18,1,'user-lock','cog'),
(18,'Ajuste stock','movimiento/ajuste/stock','MOVIMIENTO',19,1,'atlas','shopping-cart');

/*Table structure for table `producto` */

DROP TABLE IF EXISTS `producto`;

CREATE TABLE `producto` (
  `pro_id_producto` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pro_codigo` varchar(20) DEFAULT NULL,
  `cla_clase` int(10) unsigned DEFAULT NULL,
  `cla_subclase` int(10) unsigned DEFAULT NULL,
  `pro_nombre` varchar(100) DEFAULT NULL,
  `pro_val_compra` double(15,2) DEFAULT '0.00',
  `pro_val_venta` double(15,2) DEFAULT '0.00',
  `pro_cantidad` double(15,2) DEFAULT '0.00',
  `pro_cantidad_min` double(15,2) DEFAULT '0.00',
  `unm_id_unidad_medida` int(11) NOT NULL,
  `pro_foto` varchar(200) DEFAULT NULL,
  `pro_perecible` varchar(2) DEFAULT NULL,
  `pro_fecha_vencimiento` date DEFAULT NULL,
  `pro_xm_cantidad1` double(15,2) DEFAULT '0.00',
  `pro_xm_valor1` double(15,2) DEFAULT '0.00',
  `pro_xm_cantidad2` double(15,2) DEFAULT '0.00',
  `pro_xm_valor2` double(15,2) DEFAULT '0.00',
  `pro_xm_cantidad3` double(15,2) DEFAULT '0.00',
  `pro_xm_valor3` double(15,2) DEFAULT '0.00',
  `pro_val_oferta` double(15,2) DEFAULT NULL,
  `est_id_estado` int(10) unsigned DEFAULT NULL,
  `pro_eliminado` varchar(2) DEFAULT NULL,
  PRIMARY KEY (`pro_id_producto`),
  UNIQUE KEY `producto_un_codigo` (`pro_codigo`),
  KEY `producto_fk_uni_med` (`unm_id_unidad_medida`),
  CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`unm_id_unidad_medida`) REFERENCES `unidad_medida` (`unm_id_unidad_medida`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=latin1;

/*Data for the table `producto` */

insert  into `producto`(`pro_id_producto`,`pro_codigo`,`cla_clase`,`cla_subclase`,`pro_nombre`,`pro_val_compra`,`pro_val_venta`,`pro_cantidad`,`pro_cantidad_min`,`unm_id_unidad_medida`,`pro_foto`,`pro_perecible`,`pro_fecha_vencimiento`,`pro_xm_cantidad1`,`pro_xm_valor1`,`pro_xm_cantidad2`,`pro_xm_valor2`,`pro_xm_cantidad3`,`pro_xm_valor3`,`pro_val_oferta`,`est_id_estado`,`pro_eliminado`) values 
(1,'180810172633',33,34,'M ENTERO X50',54.00,100.00,0.00,10.00,3,'http://localhost/index.php/../resources/sy_file_repository/O2ohYFRGUbk1cynL4z9E.jpg','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(2,'180810173207',33,34,'M REFINADO X28',54.00,100.00,82.00,10.00,3,'http://localhost/index.php/../resources/sy_file_repository/XCrKAvluFnemkhW7qNwj.jpg','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(3,'180810173314',33,35,'M REFINADO X50',54.00,100.00,22.00,10.00,4,'http://localhost/index.php/../resources/sy_file_repository/pDwG6itz2SqFU7gNkIuK.jpg','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,12,'NO'),
(4,'180810173237',33,35,'M PARTIDO X50',54.00,10.00,18.00,10.00,4,'http://localhost/index.php/../resources/sy_file_repository/S9siX7Cr0lvzyBD821Wb.jpg','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(13,'180810172802',33,34,'M ENTERO X30',54.00,100.00,1000000.00,10.00,4,'http://localhost/index.php/../resources/sy_file_repository/YMxlGbTd12zS0y4hgCk3.jpg','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(14,'180810173054',33,34,'M REFINADO X60',54.00,100.00,20.00,10.00,3,'http://localhost/index.php/../resources/sy_file_repository/BycCSQGi5dPxz9m7H14A.jpg','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(15,'180810172847',33,34,'M PARTIDO X60',54.00,100.00,114.00,10.00,4,'http://localhost/index.php/../resources/sy_file_repository/1ACcWqOGujfHdRkUFQEb.jpg','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(16,'180810172933',33,34,'M PARTIDO X30',54.00,100.00,1000.00,10.00,3,'http://localhost/index.php/../resources/sy_file_repository/4nhzBmIGwRcdsbU9pDxl.jpg','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(17,'180810173020',33,34,'M PARTIDO X28',54.00,100.00,990.00,10.00,4,'http://localhost/index.php/../resources/sy_file_repository/clR14VhQ5O6jtGZU3DLy.jpg','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(18,'180810173131',33,34,'M REFINADO X30',54.00,100.00,1000000.00,10.00,3,'http://localhost/index.php/../resources/sy_file_repository/c79LwPZjtBi62T4KEV5O.jpg','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(19,'180810172243',67,69,'AFRECHO X 40',26.80,30.00,147.00,10.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(20,'180810173417',33,36,'REPASO X50',50.00,100.00,274.00,10.00,3,'http://localhost/index.php/../resources/sy_file_repository/faYPcol9h8sGDBE0TdQx.jpg','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(21,'180810173956',37,38,'MEZCLA PAJ MAIZ',54.00,100.00,147.00,10.00,3,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(22,'180823165028',67,68,'AFRECHO X 30',22.80,23.00,1000.00,20.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(23,'180823172439',70,71,'CONEJO COGORNO X 40',57.60,90.00,300.00,20.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(24,'180823172555',70,73,'BB MYCIN X 40',82.20,93.00,300.00,20.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(25,'180823172731',70,72,'PICO & NAVAJA X 40',79.57,87.00,300.00,20.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(26,'180823172803',74,81,'CONEJO B12 X 40',65.80,70.00,70.00,20.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(27,'180823173745',74,81,'CONEJO BB X 25',44.18,45.00,20.00,5.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(28,'180823173927',74,75,'INICIO B12 X 40',79.90,85.00,100.00,5.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(29,'180823182800',74,76,'CRECIMIENTO B12 X 40',70.50,75.00,50.00,10.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(30,'180823182810',74,77,'ENGORDE B12 X 40',65.80,70.00,30.00,5.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(31,'180823182850',74,78,'PONEDORA B12 X 40',65.80,70.00,20.00,2.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(32,'180823182935',74,79,'SALUD TOTAL X 25',56.40,60.00,10.00,2.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(33,'180823183015',74,80,'CUY B12 X 40',67.68,70.00,50.00,10.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(34,'180823183130',45,46,'VITA OVO X 60',56.40,75.00,96.00,10.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(35,'180823183341',45,46,'VITA OVO X 30',28.20,37.50,50.00,10.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(36,'180827093606',47,51,'CRECIMIENTO VITA X 40',46.00,50.00,100.00,10.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(37,'180827093650',47,51,'CRECIMIENTO VITA X 20',23.00,25.00,20.00,5.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(38,'180827093741',47,50,'ENGORDE VITA X 40',46.00,50.00,100.00,10.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(39,'180827093833',47,50,'ENGORDE VITA X 20',23.00,25.00,20.00,5.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(40,'180827093907',47,49,'INICIO VITA X 40',46.00,50.00,10.00,3.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(41,'180827093952',47,49,'INICIO VITA X 20',23.00,25.00,10.00,3.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(42,'180827182351',47,48,'VITA CUY X 40',38.00,45.00,80.00,10.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(43,'180827182438',47,52,'PONEDORA VITA X 40',46.00,50.00,10.00,3.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(44,'180827182515',53,55,'CONEJO OSCAR X 40',38.00,40.00,150.00,15.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(45,'180827182553',53,55,'CONEJO OSCAR X 20',19.00,20.00,10.00,2.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(46,'180827182630',53,54,'CUY OSCAR X 40',38.00,40.00,150.00,10.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(47,'180827182710',53,54,'CUY OSCAR X 20',19.00,20.00,10.00,3.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(48,'180827182745',56,57,'TRIGO N X 60',70.00,90.00,500.00,20.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(49,'180827182837',56,57,'TRIGO N X 30',35.00,45.00,20.00,5.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(50,'180827182913',59,63,'CRECIMIENTO SIMPLE X 40',23.00,30.00,200.00,15.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(51,'180827183106',59,62,'ENGORDE SIMPLE X 40',23.00,30.00,20.00,5.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(52,'180827183148',59,60,'VERDE X 40',50.00,75.00,50.00,15.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(53,'180827183224',59,61,'ROJO X 40',50.00,75.00,10.00,3.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO'),
(54,'180827183302',64,66,'CRECIMIENTO SIMPLE X 40 E',24.00,30.00,100.00,10.00,2,'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png','NO',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,11,'NO');

/*Table structure for table `rol` */

DROP TABLE IF EXISTS `rol`;

CREATE TABLE `rol` (
  `rol_id_rol` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rol_nombre` varchar(100) DEFAULT NULL,
  `est_id_estado` int(10) unsigned NOT NULL,
  PRIMARY KEY (`rol_id_rol`),
  KEY `rol_fk_estado` (`est_id_estado`),
  CONSTRAINT `rol_ibfk_1` FOREIGN KEY (`est_id_estado`) REFERENCES `estado` (`est_id_estado`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

/*Data for the table `rol` */

insert  into `rol`(`rol_id_rol`,`rol_nombre`,`est_id_estado`) values 
(1,'ADMIN',11),
(2,'VENDEDOR',11);

/*Table structure for table `rol_has_privilegio` */

DROP TABLE IF EXISTS `rol_has_privilegio`;

CREATE TABLE `rol_has_privilegio` (
  `rol_id_rol` int(10) unsigned NOT NULL,
  `pri_id_privilegio` int(10) unsigned NOT NULL,
  PRIMARY KEY (`rol_id_rol`,`pri_id_privilegio`),
  KEY `rol_has_privilegio_fk_rol` (`rol_id_rol`),
  KEY `rol_has_privilegio_fk_privilegio` (`pri_id_privilegio`),
  CONSTRAINT `rol_has_privilegio_ibfk_1` FOREIGN KEY (`rol_id_rol`) REFERENCES `rol` (`rol_id_rol`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `rol_has_privilegio_ibfk_2` FOREIGN KEY (`pri_id_privilegio`) REFERENCES `privilegio` (`pri_id_privilegio`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `rol_has_privilegio` */

insert  into `rol_has_privilegio`(`rol_id_rol`,`pri_id_privilegio`) values 
(1,1),
(1,6),
(1,9),
(1,10),
(1,11),
(1,13),
(1,16),
(1,17),
(2,2),
(2,3),
(2,4),
(2,5),
(2,7),
(2,8),
(2,12),
(2,14),
(2,15),
(2,16),
(2,18);

/*Table structure for table `salida` */

DROP TABLE IF EXISTS `salida`;

CREATE TABLE `salida` (
  `sal_id_salida` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pcl_id_proveedor` int(10) unsigned DEFAULT NULL,
  `pcl_id_cliente` int(10) unsigned DEFAULT NULL,
  `tdo_id_tipo_documento` int(10) unsigned DEFAULT NULL,
  `sal_fecha_doc_cliente` date DEFAULT NULL,
  `sal_numero_doc_cliente` varchar(30) DEFAULT NULL,
  `sal_fecha_registro` datetime DEFAULT NULL,
  `sal_tipo` varchar(2) DEFAULT NULL,
  `sal_monto_base` double(15,2) DEFAULT NULL,
  `sal_monto` double(15,2) DEFAULT NULL,
  `sal_monto_efectivo` double(15,2) DEFAULT NULL,
  `sal_monto_tar_credito` double(15,2) DEFAULT NULL,
  `sal_monto_tar_debito` double(15,2) DEFAULT NULL,
  `sal_descuento` double(15,2) DEFAULT NULL,
  `sal_motivo` varchar(60) DEFAULT NULL,
  `caj_id_caja` varchar(4) DEFAULT NULL,
  `caj_codigo` varchar(20) DEFAULT NULL,
  `usu_id_usuario` int(11) DEFAULT NULL,
  `est_id_estado` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`sal_id_salida`),
  KEY `salida_fk_tip_doc` (`tdo_id_tipo_documento`),
  KEY `salida_fk_pcliente` (`pcl_id_cliente`),
  KEY `salida_fk_pcliente2` (`pcl_id_proveedor`),
  KEY `r_salida_fk_caja` (`caj_id_caja`),
  CONSTRAINT `salida_fk_caja` FOREIGN KEY (`caj_id_caja`) REFERENCES `caja` (`caj_id_caja`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `salida_ibfk_1` FOREIGN KEY (`tdo_id_tipo_documento`) REFERENCES `tipo_documento` (`tdo_id_tipo_documento`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `salida_ibfk_2` FOREIGN KEY (`pcl_id_cliente`) REFERENCES `pcliente` (`pcl_id_pcliente`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `salida_ibfk_3` FOREIGN KEY (`pcl_id_proveedor`) REFERENCES `pcliente` (`pcl_id_pcliente`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `salida` */

/*Table structure for table `salida_detalle` */

DROP TABLE IF EXISTS `salida_detalle`;

CREATE TABLE `salida_detalle` (
  `sad_id_salida_detalle` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pro_id_producto` int(10) unsigned NOT NULL,
  `sal_id_salida` int(10) unsigned NOT NULL,
  `sad_cantidad` double(15,2) unsigned DEFAULT NULL,
  `sad_valor` double(15,2) DEFAULT NULL,
  `sad_monto` double(15,2) DEFAULT NULL,
  `est_id_estado` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`sad_id_salida_detalle`),
  KEY `salida_detalle_fk_salida` (`sal_id_salida`),
  KEY `salida_detalle_fk_producto` (`pro_id_producto`),
  CONSTRAINT `salida_detalle_ibfk_1` FOREIGN KEY (`sal_id_salida`) REFERENCES `salida` (`sal_id_salida`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `salida_detalle_ibfk_2` FOREIGN KEY (`pro_id_producto`) REFERENCES `producto` (`pro_id_producto`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `salida_detalle` */

/*Table structure for table `temp` */

DROP TABLE IF EXISTS `temp`;

CREATE TABLE `temp` (
  `usu_id_usuario` int(10) NOT NULL,
  `pro_id_producto` int(10) NOT NULL,
  `temp_tipo_movimiento` varchar(20) NOT NULL,
  `temp_cantidad` double(15,2) DEFAULT NULL,
  `temp_valor` double(15,2) DEFAULT NULL,
  `temp_numero_lote` varchar(30) DEFAULT NULL,
  `temp_perecible` varchar(2) DEFAULT NULL,
  `temp_fecha_vencimiento` date DEFAULT NULL,
  `temp_fecha_registro` datetime DEFAULT NULL,
  PRIMARY KEY (`pro_id_producto`,`usu_id_usuario`,`temp_tipo_movimiento`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `temp` */

/*Table structure for table `tipo_documento` */

DROP TABLE IF EXISTS `tipo_documento`;

CREATE TABLE `tipo_documento` (
  `tdo_id_tipo_documento` int(10) unsigned NOT NULL,
  `tdo_nombre` varchar(100) DEFAULT NULL,
  `tdo_tabla` varchar(100) DEFAULT NULL,
  `tdo_tamanho` int(10) unsigned DEFAULT NULL,
  `tdo_orden` int(10) unsigned DEFAULT NULL,
  `est_id_estado` int(10) unsigned DEFAULT NULL,
  `tdo_valor1` double(15,2) DEFAULT NULL,
  `tdo_valor2` double(15,2) DEFAULT NULL,
  `tdo_valor3` double(15,2) DEFAULT NULL,
  `tdo_valor4` double(15,2) DEFAULT NULL,
  PRIMARY KEY (`tdo_id_tipo_documento`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `tipo_documento` */

insert  into `tipo_documento`(`tdo_id_tipo_documento`,`tdo_nombre`,`tdo_tabla`,`tdo_tamanho`,`tdo_orden`,`est_id_estado`,`tdo_valor1`,`tdo_valor2`,`tdo_valor3`,`tdo_valor4`) values 
(1,'DNI','PERSONA',8,1,11,NULL,NULL,NULL,NULL),
(2,'LE','PERSONA',8,2,11,NULL,NULL,NULL,NULL),
(11,'FACTURA','INGRESO',30,5,11,NULL,NULL,NULL,NULL),
(12,'BOLETA','INGRESO',30,2,11,NULL,NULL,NULL,NULL),
(13,'GUIA DE REMISION','INGRESO',30,3,11,NULL,NULL,NULL,NULL),
(14,'DEVOLUCION','INGRESO',30,4,11,NULL,NULL,NULL,NULL),
(15,'NOTA DE PEDIDO','INGRESO',30,1,11,NULL,NULL,NULL,NULL),
(1821,'FACTURA','SALIDA',7,2,11,18.00,NULL,0.00,NULL),
(1822,'BOLETA','SALIDA',7,3,11,0.00,NULL,0.00,NULL),
(1823,'NOTA DE PEDIDO','SALIDA',7,1,11,0.00,NULL,0.00,NULL);

/*Table structure for table `unidad_medida` */

DROP TABLE IF EXISTS `unidad_medida`;

CREATE TABLE `unidad_medida` (
  `unm_id_unidad_medida` int(11) NOT NULL AUTO_INCREMENT,
  `unm_nombre` varchar(60) DEFAULT NULL,
  `unm_nombre_corto` varchar(10) DEFAULT NULL,
  `est_id_estado` int(10) unsigned DEFAULT NULL,
  `unm_eliminado` varchar(2) DEFAULT NULL,
  PRIMARY KEY (`unm_id_unidad_medida`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

/*Data for the table `unidad_medida` */

insert  into `unidad_medida`(`unm_id_unidad_medida`,`unm_nombre`,`unm_nombre_corto`,`est_id_estado`,`unm_eliminado`) values 
(1,'xxx','xxx',11,'NO'),
(2,'Kilogramo','Kgr',11,'NO'),
(3,'Saco','Sac',11,'NO'),
(4,'Saco','Sac',11,'NO'),
(5,'Saco','Sac',NULL,'NO'),
(6,'Kilogramo','Kgr',NULL,'NO');

/*Table structure for table `usuario` */

DROP TABLE IF EXISTS `usuario`;

CREATE TABLE `usuario` (
  `usu_id_usuario` int(11) NOT NULL,
  `usu_nombre` varchar(20) DEFAULT NULL,
  `usu_clave` varchar(255) DEFAULT NULL,
  `rol_id_rol` int(10) unsigned NOT NULL,
  `est_id_estado` int(10) unsigned NOT NULL,
  PRIMARY KEY (`usu_id_usuario`),
  UNIQUE KEY `usuario_un_nombre` (`usu_nombre`),
  KEY `usuario_fk_estado` (`est_id_estado`),
  KEY `usuario_fk_rol` (`rol_id_rol`),
  KEY `usuario_fk_persona` (`usu_id_usuario`),
  CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`est_id_estado`) REFERENCES `estado` (`est_id_estado`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `usuario_ibfk_2` FOREIGN KEY (`rol_id_rol`) REFERENCES `rol` (`rol_id_rol`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `usuario_ibfk_3` FOREIGN KEY (`usu_id_usuario`) REFERENCES `persona` (`per_id_persona`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `usuario` */

insert  into `usuario`(`usu_id_usuario`,`usu_nombre`,`usu_clave`,`rol_id_rol`,`est_id_estado`) values 
(1,'admin','$2y$12$.5eVZRxrEzu6NYFD3CkrI.vMy1ASiQja2/8.fcf3SdwZini3lCWi.',1,11),
(2,'vendedor','$2y$12$RgTTPW9BpweTRC9f9RP/eeqvmnHEeBK/tXQ/cOt7bj8UrfOKG8Bma',2,11),
(3,'caja','$2y$12$Ca5bmRc4kzkQTa9o1DdzmObxCHGjqTWqmnH389CDiWkJ7gkqUqmxC',1,11);

/* Procedure structure for procedure `proc_caja_cerrar` */

DELIMITER $$

CREATE PROCEDURE `proc_caja_cerrar`(
        OUT `out_hecho` VARCHAR(2),
        OUT `out_estado` VARCHAR(7),
        IN `in_usu_id_usuario` INT,
        IN `in_caj_id_caja` VARCHAR(4))
cuerpo: BEGIN
    -- 
    DECLARE var_usu_id_usuario INT;
    -- 
    SELECT usu_id_usuario INTO var_usu_id_usuario
    FROM caja
    WHERE usu_id_usuario=in_usu_id_usuario
      and caj_id_caja=in_caj_id_caja
      AND caj_abierta='SI';
    -- 
    IF var_usu_id_usuario IS NULL THEN
        SET out_hecho = 'NO';
        SET out_estado = 'CAJ0303';
        LEAVE cuerpo;
    END IF;
    -- 
    UPDATE caja SET
        caj_abierta='NO',
        usu_id_usuario=null
    WHERE caj_id_caja=in_caj_id_caja;
    -- 
    SET out_hecho = 'SI';
    SET out_estado = 'CAJ0301';
    
END $$
DELIMITER ;

/* Procedure structure for procedure `proc_caja_aperturar` */

DELIMITER $$

CREATE PROCEDURE `proc_caja_aperturar`(
        OUT `out_hecho` VARCHAR(2),
        OUT `out_estado` VARCHAR(7),
        OUT `out_caj_codigo` VARCHAR(20),
        IN `in_usu_id_usuario` int,
        IN `in_caj_id_caja` VARCHAR(4))
cuerpo: BEGIN
    -- 
    declare var_caj_codigo varchar(20);
    declare var_usu_id_usuario int;
    -- 
    select usu_id_usuario into var_usu_id_usuario
    from caja
    where usu_id_usuario=in_usu_id_usuario
      and caj_abierta='SI'
    limit 1;
    -- 
    if var_usu_id_usuario is not null THEN
        SET out_hecho = 'NO';
        SET out_estado = 'CAJ0204';
        SET out_caj_codigo = 'NoN';
        LEAVE cuerpo;
    end if;
    -- 
    set var_caj_codigo = DATE_FORMAT(NOW(),'%Y%m%d%h%i%s');
    -- 
    UPDATE caja SET
        caj_codigo=var_caj_codigo,
        caj_abierta='SI',
        usu_id_usuario=in_usu_id_usuario
    WHERE caj_id_caja=in_caj_id_caja;
    -- 
    SET out_hecho = 'SI';
    SET out_estado = 'CAJ0201';
    set out_caj_codigo = var_caj_codigo;
    
END $$
DELIMITER ;

/* Procedure structure for procedure `proc_caja_guardar` */

DELIMITER $$

CREATE PROCEDURE `proc_caja_guardar`(
        OUT `out_hecho` VARCHAR(2),
        OUT `out_estado` VARCHAR(7),
        OUT `out_caj_id_caja` VARCHAR(4),
        IN `in_caj_descripcion` VARCHAR(20),
        IN `in_est_id_estado` int,
        IN `in_caj_id_caja` VARCHAR(4))
cuerpo: BEGIN
    DECLARE var_caj_id_caja VARCHAR(4);
    IF in_caj_id_caja = "" THEN
        SELECT MAX(caj_id_caja)+1 INTO var_caj_id_caja FROM caja;
        -- 
        IF(var_caj_id_caja IS NULL) THEN
            SET var_caj_id_caja = '1801';
        END IF;
        -- 
        INSERT INTO caja(
            caj_id_caja,
            caj_descripcion,
            caj_codigo,
            caj_abierta,
            usu_id_usuario,
            est_id_estado
        )
        VALUES (
            var_caj_id_caja,
            in_caj_descripcion,
            '',
            'NO',
            null,
            in_est_id_estado
        );
    ELSE
        SET var_caj_id_caja = in_caj_id_caja;
        -- 
        UPDATE caja SET
            caj_descripcion=in_caj_descripcion,
            est_id_estado=in_est_id_estado
        WHERE caj_id_caja=var_caj_id_caja;
    END IF;
    -- 
    SET out_hecho = 'SI';
    SET out_estado = 'CAJ0001';
    SET out_caj_id_caja = var_caj_id_caja;
    
END $$
DELIMITER ;

/* Procedure structure for procedure `proc_ingreso_registrar` */

DELIMITER $$

CREATE PROCEDURE `proc_ingreso_registrar`(
        OUT `out_hecho` VARCHAR(2),
        OUT `out_estado` VARCHAR(7),
        IN `in_usu_id_usuario` INT,
        IN `in_pcl_id_proveedor` INT,
        IN `in_ing_fecha_doc_proveedor` VARCHAR(30),
        IN `in_tdo_id_tipo_documento` INT,
        IN `in_ing_numero_doc_proveedor` VARCHAR(30),
        IN `in_ing_monto_efectivo` DOUBLE(15,2),
        IN `in_ing_monto_tar_credito` DOUBLE(15,2),
        IN `in_ing_monto_tar_debito` DOUBLE(15,2))
cuerpo: BEGIN
    DECLARE var_count_productos DOUBLE(15,2);
    DECLARE var_sum_total DOUBLE(15,2);
    DECLARE var_sum_total_entrante DOUBLE(15,2);
    DECLARE var_caj_id_caja VARCHAR(4);
    DECLARE var_caj_codigo VARCHAR(20);
    DECLARE var_ing_id_ingreso INT;
    DECLARE var_pro_id_producto INT;
    DECLARE var_temp_cantidad DOUBLE(15,2);
    DECLARE var_temp_valor DOUBLE(15,2);
    DECLARE var_temp_numero_lote varchar(30);
    DECLARE var_temp_perecible varchar(2);
    DECLARE var_temp_fecha_vencimiento date;
    --
    DECLARE done INT DEFAULT FALSE;
    DECLARE cursor_temp CURSOR FOR
    SELECT pro_id_producto, temp_cantidad, temp_valor, temp_numero_lote, temp_perecible, temp_fecha_vencimiento
    FROM temp 
    WHERE
      usu_id_usuario=in_usu_id_usuario AND
      temp_tipo_movimiento='INGRESO';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    --
    DECLARE EXIT HANDLER FOR 1062 SELECT 'Duplicate keys error encountered';
    DECLARE EXIT HANDLER FOR SQLEXCEPTION SELECT 'SQLException encountered';
    DECLARE EXIT HANDLER FOR SQLSTATE '23000' SELECT 'SQLSTATE 23000';
    --
    SELECT
      IFNULL(COUNT(usu_id_usuario),0) count_productos,
      IFNULL(SUM(temp_cantidad*temp_valor),0) sum_total
      INTO
      var_count_productos,
      var_sum_total
    FROM temp t
    WHERE
      usu_id_usuario=in_usu_id_usuario AND
      temp_tipo_movimiento='INGRESO';
    --
    IF var_count_productos=0 THEN
        SET out_hecho = 'NO';
        SET out_estado = 'ING0301';
        LEAVE cuerpo;
    END IF;
    --
    SET var_sum_total_entrante = in_ing_monto_efectivo+in_ing_monto_tar_credito+in_ing_monto_tar_debito;
    --
    IF var_sum_total <> var_sum_total_entrante THEN
        SET out_hecho = 'NO';
        SET out_estado = 'ING0302';
        LEAVE cuerpo;
    END IF;
    --
    SELECT caj_id_caja, caj_codigo 
      INTO 
      var_caj_id_caja, var_caj_codigo
    FROM
      caja
    WHERE
      usu_id_usuario=in_usu_id_usuario;
    --
    IF var_caj_id_caja IS NULL THEN
        SET out_hecho = 'NO';
        SET out_estado = 'ING0303';
        LEAVE cuerpo;
    END IF;
    --
    INSERT INTO ingreso (
        pcl_id_proveedor,
        tdo_id_tipo_documento,
        ing_fecha_doc_proveedor,
        ing_numero_doc_proveedor,
        ing_fecha_registro,
        ing_tipo,
        ing_monto_base,
        ing_monto,
        ing_monto_efectivo,
        ing_monto_tar_credito,
        ing_monto_tar_debito,
        usu_id_usuario,
        caj_id_caja,
        caj_codigo,
        est_id_estado
    )
    VALUES (
        in_pcl_id_proveedor,
        in_tdo_id_tipo_documento,
        in_ing_fecha_doc_proveedor,
        in_ing_numero_doc_proveedor,
        NOW(),
        'P',
        var_sum_total,
        var_sum_total,
        in_ing_monto_efectivo,
        in_ing_monto_tar_credito,
        in_ing_monto_tar_debito,
        in_usu_id_usuario,
        var_caj_id_caja,
        var_caj_codigo,
        1
    );
    --
    SET var_ing_id_ingreso = LAST_INSERT_ID();
    -- -- -- -- 
    OPEN cursor_temp;
    read_loop: LOOP
        FETCH cursor_temp INTO var_pro_id_producto, var_temp_cantidad, var_temp_valor, var_temp_numero_lote, var_temp_perecible, var_temp_fecha_vencimiento;
        IF done THEN
            LEAVE read_loop;
        END IF;
        -- 
        INSERT INTO ingreso_detalle (pro_id_producto,
          ing_id_ingreso,
          ind_cantidad,
          ind_valor,
          ind_monto,
          ind_numero_lote,
          ind_perecible,
          ind_fecha_vencimiento,
          est_id_estado)
        VALUES
          (var_pro_id_producto,
          var_ing_id_ingreso,
          var_temp_cantidad,
          var_temp_valor,
          (var_temp_cantidad*var_temp_valor),
          var_temp_numero_lote,
          var_temp_perecible,
          var_temp_fecha_vencimiento,
          1);
        --
        CALL proc_movimiento_registrar(var_ing_id_ingreso, null, var_pro_id_producto, var_temp_cantidad, 1, 'INP', in_usu_id_usuario);
        --
    END LOOP;
    CLOSE cursor_temp;
    --
    UPDATE ingreso
    SET est_id_estado=2
    WHERE ing_id_ingreso=var_ing_id_ingreso;
    --
    DELETE FROM temp
    WHERE usu_id_usuario=in_usu_id_usuario AND
        temp_tipo_movimiento='INGRESO';
    --
    SET out_hecho = 'SI';
    SET out_estado = 'ING0305';
    
END $$
DELIMITER ;

/* Procedure structure for procedure `proc_movimiento_registrar` */

DELIMITER $$

CREATE PROCEDURE `proc_movimiento_registrar`(
        IN `in_ing_id_ingreso` INT,
        IN `in_sal_id_salida` INT,
        IN `in_pro_id_producto` INT,
        IN `in_sad_cantidad` double(15,2),
        IN `in_operador_signo` INT,
        in `in_mov_tipo` varchar(3),
        IN `in_usu_id_usuario` INT)
cuerpo: BEGIN
    DECLARE var_mov_cantidad_actual DOUBLE(15,2);
    DECLARE var_mov_id_movimiento INT;
    --
    UPDATE producto 
    SET pro_cantidad=pro_cantidad+(in_sad_cantidad*in_operador_signo)
    WHERE pro_id_producto=in_pro_id_producto;
    --
    SELECT mov_cantidad_actual, mov_id_movimiento INTO var_mov_cantidad_actual, var_mov_id_movimiento
    FROM movimiento
    WHERE pro_id_producto=in_pro_id_producto
    ORDER BY mov_id_movimiento DESC
    LIMIT 1;
    --
    IF var_mov_cantidad_actual IS NULL THEN
        INSERT INTO movimiento (
        ing_id_ingreso,
        sal_id_salida, 
        mov_tipo, 
        mov_cantidad_anterior,
        mov_cantidad_entrante,
        mov_cantidad_actual,
        pro_id_producto,
        est_id_estado,
        usu_id_usuario
        )
        VALUES (
        in_ing_id_ingreso,
        in_sal_id_salida,
        in_mov_tipo,
        0,
        in_sad_cantidad,
        in_sad_cantidad,
        in_pro_id_producto,
        2,
        in_usu_id_usuario
        );
    ELSEIF var_mov_cantidad_actual < 0 THEN
        INSERT INTO movimiento (
        ing_id_ingreso,
        sal_id_salida, 
        mov_tipo, 
        mov_cantidad_anterior,
        mov_cantidad_entrante,
        mov_cantidad_actual,
        pro_id_producto,
        est_id_estado,
        usu_id_usuario
        )
        VALUES (
        in_ing_id_ingreso,
        in_sal_id_salida,
        in_mov_tipo,
        0,
        0,
        0,
        in_pro_id_producto,
        2,
        in_usu_id_usuario
        );
    ELSE
        INSERT INTO movimiento (
        ing_id_ingreso,
        sal_id_salida, 
        mov_tipo, 
        mov_cantidad_anterior,
        mov_cantidad_entrante,
        mov_cantidad_actual,
        pro_id_producto,
        est_id_estado,
        usu_id_usuario
        )
        VALUES (
        in_ing_id_ingreso,
        in_sal_id_salida,
        in_mov_tipo,
        var_mov_cantidad_actual,
        in_sad_cantidad,
        var_mov_cantidad_actual+(in_sad_cantidad*in_operador_signo),
        in_pro_id_producto,
        2,
        in_usu_id_usuario
        );
    END IF;
    
END $$
DELIMITER ;

/* Procedure structure for procedure `proc_stock_ajustar` */

DELIMITER $$

CREATE PROCEDURE `proc_stock_ajustar`(
        OUT `out_hecho` VARCHAR(2),
        OUT `out_estado` VARCHAR(7),
        IN `in_pro_id_producto` INT,
        IN `in_pro_cantidad` double(15,2),
        IN `in_operador_signo` INT,
        IN `in_usu_id_usuario` INT)
cuerpo: BEGIN
    declare var_pro_cantidad DOUBLE(15,2);
    if in_operador_signo = -1 then
        SELECT
          -- pro_cantidad
          (pro_cantidad-(SELECT IFNULL(SUM(temp_cantidad),0) FROM temp t WHERE t.pro_id_producto=pro.pro_id_producto AND t.temp_tipo_movimiento='SALIDA'))
          INTO
          var_pro_cantidad
        FROM producto pro
        WHERE pro_id_producto=in_pro_id_producto;
        --
        if in_pro_cantidad > var_pro_cantidad then
            SET out_hecho = 'NO';
            SET out_estado = 'AJP0001';
            leave cuerpo;
        end if;
        --
        CALL proc_movimiento_registrar(NULL, NULL, in_pro_id_producto, in_pro_cantidad, -1, 'SAA', in_usu_id_usuario);
        SET out_hecho = 'SI';
        SET out_estado = 'AJP0011';
    elseif in_operador_signo = 1 THEN
        CALL proc_movimiento_registrar(NULL, NULL, in_pro_id_producto, in_pro_cantidad, 1, 'INA', in_usu_id_usuario);
        SET out_hecho = 'SI';
        SET out_estado = 'AJP0012';
    ELSE
        SET out_hecho = 'NO';
        SET out_estado = 'AJP0002';
    end if;
    --
END $$
DELIMITER ;

/* Procedure structure for procedure `proc_temp_ingreso_agregar` */

DELIMITER $$

CREATE PROCEDURE `proc_temp_ingreso_agregar`(
        OUT `out_hecho` VARCHAR(2),
        OUT `out_estado` VARCHAR(7),
        IN `in_usu_id_usuario` INT,
        IN `in_pro_id_producto` INT,
        IN `in_valor` double(15,2),
        IN `in_cantidad` DOUBLE(15,2),
        IN `in_numero_lote` varchar(30),
        IN `in_fecha_vencimiento` VARCHAR(20))
cuerpo: BEGIN
    DECLARE var_pro_perecible varchar(2);
    DECLARE var_pro_id_producto INT;
    --
     IF IFNULL(in_cantidad,0)<0.01 THEN
        SET out_hecho = 'NO';
        SET out_estado = 'ING0101';
        LEAVE cuerpo;
    END IF;
    --
    SELECT
      pro_id_producto,
      (select pro_perecible from producto p where p.pro_id_producto=t.pro_id_producto)
      into
      var_pro_id_producto,
      var_pro_perecible
    FROM
      temp t
    WHERE
      t.pro_id_producto=in_pro_id_producto and
      t.temp_tipo_movimiento='INGRESO' and
      t.usu_id_usuario=in_usu_id_usuario;
    -- 
    IF var_pro_id_producto IS NOT NULL THEN
        SET out_hecho = 'NO';
        SET out_estado = 'ING0102';
        LEAVE cuerpo;
    END IF;
    -- 
    INSERT INTO temp(
        usu_id_usuario,
        pro_id_producto,
        temp_tipo_movimiento,
        temp_cantidad,
        temp_valor,
        temp_fecha_registro,
        temp_numero_lote,
        temp_perecible,
        temp_fecha_vencimiento
    )
    VALUES (
        in_usu_id_usuario,
        in_pro_id_producto,
        'INGRESO',
        in_cantidad,
        in_valor,
        NOW(),
        in_numero_lote,
        (SELECT pro_perecible FROM producto p WHERE p.pro_id_producto=in_pro_id_producto),
        in_fecha_vencimiento
    );
    -- 
    SET out_hecho = 'SI';
    SET out_estado = 'ING0105';
    -- 
END $$
DELIMITER ;

/* Procedure structure for procedure `proc_salida_registrar` */

DELIMITER $$

CREATE PROCEDURE `proc_salida_registrar`(
        OUT `out_hecho` VARCHAR(2),
        OUT `out_estado` VARCHAR(7),
        out `out_sal_id_salida` INT,
        IN `in_usu_id_usuario` INT,
        IN `in_pcl_id_cliente` INT,
        IN `in_sal_fecha_doc_cliente` VARCHAR(30),
        IN `in_tdo_id_tipo_documento` INT,
        IN `in_sal_monto_efectivo` DOUBLE(15,2),
        IN `in_sal_monto_tar_credito` DOUBLE(15,2),
        IN `in_sal_monto_tar_debito` DOUBLE(15,2),
        IN `in_sal_descuento` DOUBLE(15,2),
        IN `in_sal_motivo` VARCHAR(60))
cuerpo: BEGIN
    DECLARE var_count_productos DOUBLE(15,2);
    DECLARE var_sum_total DOUBLE(15,2);
    DECLARE var_sum_total_entrante DOUBLE(15,2);
    DECLARE var_caj_id_caja VARCHAR(4);
    DECLARE var_caj_codigo VARCHAR(20);
    DECLARE var_sal_numero_doc_cliente VARCHAR(30);
    declare var_sal_id_salida int;
    declare var_pro_id_producto int;
    declare var_temp_cantidad DOUBLE(15,2);
    declare var_temp_valor double(15,2);
    --
    DECLARE done INT DEFAULT FALSE;
    DECLARE cursor_temp CURSOR FOR
    SELECT pro_id_producto, temp_cantidad, temp_valor
    FROM temp 
    WHERE
      usu_id_usuario=in_usu_id_usuario AND
      temp_tipo_movimiento='SALIDA';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    --
    DECLARE EXIT HANDLER FOR 1062 SELECT 'Duplicate keys error encountered';
    DECLARE EXIT HANDLER FOR SQLEXCEPTION SELECT 'SQLException encountered';
    DECLARE EXIT HANDLER FOR SQLSTATE '23000' SELECT 'SQLSTATE 23000';
    --
    SELECT
      IFNULL(COUNT(usu_id_usuario),0) count_productos,
      IFNULL(SUM(temp_cantidad*temp_valor),0) sum_total
      INTO
      var_count_productos,
      var_sum_total
    FROM temp t
    WHERE
      usu_id_usuario=in_usu_id_usuario AND
      temp_tipo_movimiento='SALIDA';
    --
    IF var_count_productos=0 THEN
        SET out_hecho = 'NO';
        SET out_estado = 'SAL0301';
        set out_sal_id_salida = 0;
        LEAVE cuerpo;
    END IF;
    --
    set var_sum_total_entrante = in_sal_monto_efectivo+in_sal_monto_tar_credito+in_sal_monto_tar_debito+in_sal_descuento;
    --
    IF var_sum_total <> var_sum_total_entrante THEN
        SET out_hecho = 'NO';
        SET out_estado = 'SAL0302';
        SET out_sal_id_salida = 0;
        LEAVE cuerpo;
    END IF;
    --
    SELECT caj_id_caja, caj_codigo INTO var_caj_id_caja, var_caj_codigo
    FROM caja
    WHERE usu_id_usuario=in_usu_id_usuario;
    --
    IF var_caj_id_caja IS NULL THEN
        SET out_hecho = 'NO';
        SET out_estado = 'SAL0303';
        SET out_sal_id_salida = 0;
        LEAVE cuerpo;
    END IF;
    --
    SELECT
      CONCAT(REPEAT('0',(tdo_tamanho-LENGTH(numero))),numero) numero
      INTO
      var_sal_numero_doc_cliente
    FROM 
      (SELECT tdo.tdo_tamanho, tdo.tdo_valor1
        FROM tipo_documento tdo
        WHERE tdo.tdo_id_tipo_documento=in_tdo_id_tipo_documento ) t1
      ,
      (SELECT IFNULL(MAX(CAST(sal.sal_numero_doc_cliente AS UNSIGNED)),0)+1 numero
        FROM salida sal
        WHERE sal.tdo_id_tipo_documento=in_tdo_id_tipo_documento ) t2;
    --
    IF var_sal_numero_doc_cliente IS NULL THEN
        SET out_hecho = 'NO';
        SET out_estado = 'SAL0304';
        SET out_sal_id_salida = 0;
        LEAVE cuerpo;
    END IF;
    --
    INSERT INTO salida (
        pcl_id_cliente,
        tdo_id_tipo_documento,
        sal_fecha_doc_cliente,
        sal_numero_doc_cliente,
        sal_fecha_registro,
        sal_tipo,
        sal_monto_base,
        sal_monto,
        sal_monto_efectivo,
        sal_monto_tar_credito,
        sal_monto_tar_debito,
        sal_descuento,
        sal_motivo,
        usu_id_usuario,
        caj_id_caja,
        caj_codigo,
        est_id_estado
    )
    VALUES (
        in_pcl_id_cliente,
        in_tdo_id_tipo_documento,
        in_sal_fecha_doc_cliente,
        var_sal_numero_doc_cliente,
        NOW(),
        'C',
        var_sum_total,
        (var_sum_total-in_sal_descuento),
        in_sal_monto_efectivo,
        in_sal_monto_tar_credito,
        in_sal_monto_tar_debito,
        in_sal_descuento,
        in_sal_motivo,
        in_usu_id_usuario,
        var_caj_id_caja,
        var_caj_codigo,
        1
    );
    --
    SET var_sal_id_salida = LAST_INSERT_ID();
    -- -- -- -- 
    OPEN cursor_temp;
    read_loop: LOOP
        FETCH cursor_temp INTO var_pro_id_producto, var_temp_cantidad, var_temp_valor;
        IF done THEN
            LEAVE read_loop;
        END IF;
        -- 
        INSERT INTO salida_detalle (pro_id_producto,sal_id_salida,sad_cantidad,sad_valor,est_id_estado,sad_monto)
        values
        (var_pro_id_producto, var_sal_id_salida, var_temp_cantidad, var_temp_valor, 1, (var_temp_cantidad*var_temp_valor));
        --
        call proc_movimiento_registrar(null, var_sal_id_salida, var_pro_id_producto, var_temp_cantidad, -1, 'SAC', in_usu_id_usuario);
        --
    END LOOP;
    CLOSE cursor_temp;
    --
    update salida
    set est_id_estado=2
    where sal_id_salida=var_sal_id_salida;
    --
    DELETE FROM temp
    WHERE usu_id_usuario=in_usu_id_usuario AND
        temp_tipo_movimiento='SALIDA';
    --
    SET out_hecho = 'SI';
    SET out_estado = 'SAL0305';
    set out_sal_id_salida = var_sal_id_salida;
    
END $$
DELIMITER ;

/* Procedure structure for procedure `proc_temp_ingreso_quitar` */

DELIMITER $$

CREATE PROCEDURE `proc_temp_ingreso_quitar`(
        OUT `out_hecho` VARCHAR(2),
        OUT `out_estado` VARCHAR(7),
        IN `in_usu_id_usuario` INT,
        IN `in_pro_id_producto` INT)
cuerpo: BEGIN
    DECLARE var_pro_id_producto INT;
    --
    SELECT
        pro_id_producto
        INTO
        var_pro_id_producto
    FROM
        temp
    WHERE
        usu_id_usuario=in_usu_id_usuario AND
        pro_id_producto=in_pro_id_producto AND
        temp_tipo_movimiento='INGRESO';
    -- 
    IF var_pro_id_producto IS NULL THEN
        SET out_hecho = 'NO';
        SET out_estado = 'ING0201';
        LEAVE cuerpo;
    END IF;
    -- 
    DELETE FROM temp
    WHERE 
        usu_id_usuario=in_usu_id_usuario AND
        pro_id_producto=in_pro_id_producto AND
        temp_tipo_movimiento='INGRESO';
    -- 
    SET out_hecho = 'SI';
    SET out_estado = 'ING0205';
    -- 
END $$
DELIMITER ;

/* Procedure structure for procedure `proc_temp_salida_agregar` */

DELIMITER $$

CREATE PROCEDURE `proc_temp_salida_agregar`(
        OUT `out_hecho` VARCHAR(2),
        OUT `out_estado` VARCHAR(7),
        IN `in_usu_id_usuario` int,
        IN `in_pro_id_producto` INT,
        IN `in_cantidad` DOUBLE(15,2))
cuerpo: BEGIN
    DECLARE var_pro_cantidad DOUBLE(15,2);
    DECLARE var_pro_val_venta double(15,2);
    DECLARE var_sum_cantidad DOUBLE(15,2);
    DECLARE var_pro_id_producto INT;
    --
     IF ifnull(in_cantidad,0)<0.01 THEN
        SET out_hecho = 'NO';
        SET out_estado = 'SAL0104';
        LEAVE cuerpo;
    END IF;
    --
    select
        pro_cantidad,
        -- pro_val_venta,
        IF(pro_val_oferta>0, pro_val_oferta, 
          IF(pro_xm_cantidad3<=in_cantidad AND pro_xm_cantidad3>0, pro_xm_valor3, 
            IF(pro_xm_cantidad2<=in_cantidad AND pro_xm_cantidad2>0, pro_xm_valor2, 
              IF(pro_xm_cantidad1<=in_cantidad AND pro_xm_cantidad1>0, pro_xm_valor1, pro_val_venta
              )
            )
          )
        ),
        (select ifnull(sum(temp_cantidad),0) from temp t where t.pro_id_producto=pro.pro_id_producto and t.temp_tipo_movimiento='SALIDA'),
        (select pro_id_producto from temp t where t.pro_id_producto=pro.pro_id_producto AND t.temp_tipo_movimiento='SALIDA' and t.usu_id_usuario=in_usu_id_usuario)
        into 
        var_pro_cantidad,
        var_pro_val_venta,
        var_sum_cantidad,
        var_pro_id_producto
    from
        producto pro
    where
        pro_id_producto=in_pro_id_producto and
        est_id_estado=11;
    -- 
    if var_pro_cantidad is null then
        SET out_hecho = 'NO';
        SET out_estado = 'SAL0101';
        leave cuerpo;
    end if;
    -- 
    IF var_pro_id_producto IS not NULL THEN
        SET out_hecho = 'NO';
        SET out_estado = 'SAL0102';
        LEAVE cuerpo;
    END IF;
    -- 
    IF var_pro_cantidad<(var_sum_cantidad+in_cantidad) THEN
        SET out_hecho = 'NO';
        SET out_estado = 'SAL0103';
        LEAVE cuerpo;
    END IF;
    -- 
    INSERT INTO temp(
        usu_id_usuario,
        pro_id_producto,
        temp_tipo_movimiento,
        temp_cantidad,
        temp_valor,
        temp_fecha_registro
    )
    VALUES (
        in_usu_id_usuario,
        in_pro_id_producto,
        'SALIDA',
        in_cantidad,
        var_pro_val_venta,
        now()
    );
    -- 
    SET out_hecho = 'SI';
    SET out_estado = 'SAL0105';
    -- 
END $$
DELIMITER ;

/* Procedure structure for procedure `proc_temp_salida_quitar` */

DELIMITER $$

CREATE PROCEDURE `proc_temp_salida_quitar`(
        OUT `out_hecho` VARCHAR(2),
        OUT `out_estado` VARCHAR(7),
        IN `in_usu_id_usuario` INT,
        IN `in_pro_id_producto` INT)
cuerpo: BEGIN
    DECLARE var_pro_id_producto INT;
    --
    select
        pro_id_producto
        into
        var_pro_id_producto
    from
        temp
    where
        usu_id_usuario=in_usu_id_usuario AND
        pro_id_producto=in_pro_id_producto AND
        temp_tipo_movimiento='SALIDA';
    -- 
    IF var_pro_id_producto IS NULL THEN
        SET out_hecho = 'NO';
        SET out_estado = 'SAL0201';
        LEAVE cuerpo;
    END IF;
    -- 
    delete from temp
    where 
        usu_id_usuario=in_usu_id_usuario and
        pro_id_producto=in_pro_id_producto and
        temp_tipo_movimiento='SALIDA';
    -- 
    SET out_hecho = 'SI';
    SET out_estado = 'SAL0205';
    -- 
END $$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
