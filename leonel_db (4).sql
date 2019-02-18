-- phpMyAdmin SQL Dump
-- version 4.8.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 18-02-2019 a las 16:05:27
-- Versión del servidor: 10.1.33-MariaDB
-- Versión de PHP: 7.2.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `leonel_db`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `editar_monto_sangria` (IN `in_id` INT, IN `in_tipo` VARCHAR(150), IN `in_monto` DOUBLE(15,2), IN `in_motivo` VARCHAR(150))  NO SQL
    COMMENT 'Actualizar monto de sangria'
UPDATE sangria SET tipo_sangria=in_tipo,monto=in_monto,san_motivo=in_motivo
WHERE id_sangria=in_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ELIMINAR_VENTA` (IN `id_salida` INT)  NO SQL
DELETE FROM sal,sd USING salida AS sal INNER JOIN salida_detalle as sd
WHERE sal.sal_id_salida=sd.sal_id_salida AND sd.sal_id_salida = id_salida$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERTAR_MOVIMIENTO_CLIENTE` (IN `monto_pagado` DOUBLE(15,2), IN `descripcion` VARCHAR(250), IN `id_salida` INT, IN `idcliente` INT, IN `monto_compra` DOUBLE(15,2))  NO SQL
cuerpo: BEGIN
DECLARE var_saldo DOUBLE(15,2);
--
SELECT IFNULL(SUM(sal_deuda),0)sum_total INTO var_saldo FROM salida as s WHERE s.pcl_id_cliente=idcliente ;
--
INSERT INTO mayor(ma_fecha,ma_descripcion,ma_debe,ma_haber,ma_saldo,sal_id_salida,pcl_id_cliente)VALUES(NOW(),descripcion,monto_pagado,monto_compra,var_saldo,id_salida,
idcliente);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_MOVIMIENTO_COMPRA_CLIENTE` (IN `monto_pagado` DOUBLE(15,2), IN `descripcion` VARCHAR(250), IN `id_salida` INT, IN `idcliente` INT, IN `monto_compra` DOUBLE(15,2))  NO SQL
cuerpo: BEGIN
DECLARE var_saldo DOUBLE(15,2);
--
SELECT IFNULL(SUM(sal_deuda + monto_compra),0)sum_total INTO var_saldo FROM salida as s WHERE s.pcl_id_cliente=idcliente ;
--
INSERT INTO mayor(ma_fecha,ma_descripcion,ma_debe,ma_haber,ma_saldo,sal_id_salida,pcl_id_cliente)VALUES(NOW(),descripcion,monto_pagado,monto_compra,var_saldo,id_salida,
idcliente);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_pagos_proveedor` (IN `in_id_provedor` INT)  NO SQL
SELECT * FROM mayor_ingreso as ing WHERE ing.id_provedor=in_id_provedor ORDER BY ing.id_mayor_ingreso DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MANAGE_SANGRIA` (IN `in_idusuario` INT(11), IN `in_monto` DOUBLE(15,2), IN `in_tipo_sangria` VARCHAR(150), IN `in_motivo` VARCHAR(250))  BEGIN
    DECLARE var_caj_id INT(15);
    --
    SELECT caj_id_caja 
      INTO 
      var_caj_id
    FROM
      caja
    WHERE
      usu_id_usuario=in_idusuario;
     --
     -- 
   	INSERT INTO sangria(
    	monto,
      fecha,
      tipo_sangria,
      san_motivo,  
      caj_id_caja,
     usu_id_usuario
    )
    VALUES(
        in_monto,
      	NOW(),
        in_tipo_sangria,
        in_motivo,
        var_caj_id,
        in_idusuario
    );
    --
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_ajustar_deuda` (IN `sal_monto` VARCHAR(150), IN `sal_id_sal` INT)  UPDATE salida SET sal_deuda=sal_monto WHERE salida.sal_id_salida=sal_id_sal$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_ajustar_deuda_proveedor` (IN `sal_monto` VARCHAR(150), IN `id_ingreso` INT)  UPDATE ingreso SET ing_deuda=sal_monto WHERE ingreso.ing_id_ingreso=id_ingreso$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_caja_aperturar` (OUT `out_hecho` VARCHAR(2), OUT `out_estado` VARCHAR(7), OUT `out_caj_codigo` VARCHAR(20), IN `in_usu_id_usuario` INT, IN `in_caj_id_caja` VARCHAR(4))  cuerpo: BEGIN
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
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_caja_cerrar` (OUT `out_hecho` VARCHAR(2), OUT `out_estado` VARCHAR(7), IN `in_usu_id_usuario` INT, IN `in_caj_id_caja` VARCHAR(4))  cuerpo: BEGIN
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
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_caja_guardar` (OUT `out_hecho` VARCHAR(2), OUT `out_estado` VARCHAR(7), OUT `out_caj_id_caja` VARCHAR(4), IN `in_caj_descripcion` VARCHAR(20), IN `in_est_id_estado` INT, IN `in_caj_id_caja` VARCHAR(4))  cuerpo: BEGIN
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
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_ingreso_registrar` (OUT `out_hecho` VARCHAR(2), OUT `out_estado` VARCHAR(7), IN `in_usu_id_usuario` INT, IN `in_pcl_id_proveedor` INT, IN `in_ing_fecha_doc_proveedor` VARCHAR(30), IN `in_tdo_id_tipo_documento` INT, IN `in_ing_numero_doc_proveedor` VARCHAR(30), IN `in_ing_monto_efectivo` DOUBLE(15,2), IN `in_ing_monto_tar_credito` DOUBLE(15,2), IN `in_ing_monto_tar_debito` DOUBLE(15,2), IN `in_ing_monto_deuda` DOUBLE(15,2), IN `in_tipo_ingreso` VARCHAR(150))  cuerpo: BEGIN
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
    DECLARE done INT DEFAULT FALSE;
    DECLARE var_saldo_final  DOUBLE(15,2);
    DECLARE var_deuda  DOUBLE(15,2);
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
    IF var_sum_total < var_sum_total_entrante THEN
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
        est_id_estado,
        ing_deuda,
        in_tipo
       
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
        1,
        in_ing_monto_deuda,
        in_tipo_ingreso
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
    UPDATE  producto SET producto.pro_val_compra=var_temp_valor WHERE producto.pro_id_producto=var_pro_id_producto;
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
    SELECT ifnull(SUM(ing_deuda),0)suma_total INTO var_saldo_final FROM ingreso as s WHERE s.pcl_id_proveedor=in_pcl_id_proveedor;
    --
 
    INSERT INTO mayor_ingreso
            (
            ma_descripcion,
            ma_debe,
            ma_haber,
            ma_saldo,
            id_provedor,
            id_ingresos,
            ma_fecha
            ) 
        VALUES(
            'Por la compra de productos',
            in_ing_monto_tar_credito,
            in_ing_monto_deuda,
            var_saldo_final,
            in_pcl_id_proveedor,
            var_ing_id_ingreso,
            CURDATE() 
        );
    --
    SET out_hecho = 'SI';
    SET out_estado = 'ING0305';
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_movimiento_registrar` (IN `in_ing_id_ingreso` INT, IN `in_sal_id_salida` INT, IN `in_pro_id_producto` INT, IN `in_sad_cantidad` DOUBLE(15,2), IN `in_operador_signo` INT, IN `in_mov_tipo` VARCHAR(3), IN `in_usu_id_usuario` INT)  cuerpo: BEGIN
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
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_salida_registrar` (OUT `out_hecho` VARCHAR(2), OUT `out_estado` VARCHAR(7), OUT `out_sal_id_salida` INT, IN `in_usu_id_usuario` INT, IN `in_pcl_id_cliente` INT, IN `in_sal_fecha_doc_cliente` VARCHAR(30), IN `in_tdo_id_tipo_documento` INT, IN `in_sal_monto_efectivo` DOUBLE(15,2), IN `in_sal_monto_tar_credito` DOUBLE(15,2), IN `in_sal_monto_tar_debito` DOUBLE(15,2), IN `in_sal_descuento` DOUBLE(15,2), IN `in_sal_motivo` VARCHAR(60), IN `in_sal_vuelto` VARCHAR(150), IN `in_tipo_venta` VARCHAR(60), IN `in_deuda` DOUBLE(15,2), IN `in_sal_chofer` VARCHAR(150), IN `in_sal_camion` VARCHAR(150), IN `in_sal_observación` VARCHAR(250), IN `in_sal_numero_doc_cliente` INT)  cuerpo: BEGIN
    DECLARE var_count_productos DOUBLE(15,2);
    DECLARE var_sum_total DOUBLE(15,2);
    DECLARE var_sum_total_entrante DOUBLE(15,2);
    DECLARE var_caj_id_caja VARCHAR(4);
    DECLARE var_caj_codigo VARCHAR(20);
    DECLARE var_sal_numero_doc_cliente VARCHAR(30);
    declare var_sal_id_salida int;
    declare var_pro_id_producto int;
    declare var_temp_cantidad DOUBLE(15,2);
    declare var_temp_ganancias DOUBLE(15,2);
    declare var_temp_kilogamos DOUBLE(15,2);
    declare var_temp_valor double(15,2);
    DECLARE var_saldo DOUBLE(15,2);
    --
    
    DECLARE done INT DEFAULT FALSE;
    DECLARE cursor_temp CURSOR FOR
    SELECT pro_id_producto, temp_cantidad,pro_ganancias,pro_sum_kilo, temp_valor
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
        sal_vuelto,
        usu_id_usuario,
        caj_id_caja,
        caj_codigo,
        est_id_estado,
        t_venta,
        sal_deuda,
        sal_camion,
        sal_chofer,
        sal_observacion
    )
    VALUES (
        in_pcl_id_cliente,
        in_tdo_id_tipo_documento,
        in_sal_fecha_doc_cliente,
        in_sal_numero_doc_cliente,
        NOW(),
        'C',
        var_sum_total,
        (var_sum_total-in_sal_descuento),
        in_sal_monto_efectivo,
        in_sal_monto_tar_credito,
        in_sal_monto_tar_debito,
        in_sal_descuento,
        in_sal_motivo,
        in_sal_vuelto,
        in_usu_id_usuario,
        var_caj_id_caja,
        var_caj_codigo,
        1,
        in_tipo_venta,
        in_deuda,
        in_sal_camion,
        in_sal_chofer,
        in_sal_observacion
    );
    
    --
    SET var_sal_id_salida = LAST_INSERT_ID();
      
    -- -- -- -- 
    OPEN cursor_temp;
    read_loop: LOOP
        FETCH cursor_temp INTO var_pro_id_producto, var_temp_cantidad,var_temp_ganancias,var_temp_kilogamos, var_temp_valor;
        IF done THEN
            LEAVE read_loop;
        END IF;
        -- 
       
        INSERT INTO salida_detalle (pro_id_producto,sal_id_salida,sad_cantidad,sad_ganancias,sad_sum_kilo,sad_valor,est_id_estado,sad_monto)
        values
        (var_pro_id_producto, var_sal_id_salida, var_temp_cantidad,var_temp_ganancias,var_temp_kilogamos,var_temp_valor, 1, (var_temp_cantidad*var_temp_valor));
       
        --
        call proc_movimiento_registrar(null, var_sal_id_salida, var_pro_id_producto,var_temp_cantidad, -1, 'SAC', in_usu_id_usuario);
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
    SELECT IFNULL(SUM(sal_deuda),0)sum_total INTO var_saldo FROM salida as s WHERE s.pcl_id_cliente=in_pcl_id_cliente ;
	--
	INSERT INTO mayor(ma_fecha,ma_descripcion,ma_debe,ma_haber,ma_saldo,sal_id_salida,pcl_id_cliente)VALUES(NOW(),'POR LA COMPRA DE PRODUCTOS',in_sal_monto_tar_credito,in_deuda,var_saldo,var_sal_id_salida, in_pcl_id_cliente);

    --
    SET out_hecho = 'SI';
    SET out_estado = 'SAL0305';
    set out_sal_id_salida = var_sal_id_salida;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_stock_ajustar` (OUT `out_hecho` VARCHAR(2), OUT `out_estado` VARCHAR(7), IN `in_pro_id_producto` INT, IN `in_pro_cantidad` DOUBLE(15,2), IN `in_operador_signo` INT, IN `in_usu_id_usuario` INT)  cuerpo: BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_temp_ingreso_agregar` (OUT `out_hecho` VARCHAR(2), OUT `out_estado` VARCHAR(7), IN `in_usu_id_usuario` INT, IN `in_pro_id_producto` INT, IN `in_valor` DOUBLE(15,2), IN `in_cantidad` DOUBLE(15,2), IN `in_numero_lote` VARCHAR(30), IN `in_fecha_vencimiento` VARCHAR(20))  cuerpo: BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_temp_ingreso_quitar` (OUT `out_hecho` VARCHAR(2), OUT `out_estado` VARCHAR(7), IN `in_usu_id_usuario` INT, IN `in_pro_id_producto` INT)  cuerpo: BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_temp_salida_agregar` (OUT `out_hecho` VARCHAR(2), OUT `out_estado` VARCHAR(7), IN `in_usu_id_usuario` INT, IN `in_pro_id_producto` INT, IN `in_cantidad` DOUBLE(15,2), IN `in_precio` DOUBLE(15,2), IN `in_ganancias` DOUBLE(15,2), IN `in_kilogramos` DOUBLE(15,2))  cuerpo: BEGIN
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
               
              IF(pro_xm_cantidad1<=in_cantidad AND pro_xm_cantidad1>0, pro_xm_valor1, in_precio
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
        temp_fecha_registro,
        pro_ganancias,
        pro_sum_kilo
       
    )
    VALUES (
        in_usu_id_usuario,
        in_pro_id_producto,
        'SALIDA',
        in_cantidad,
        var_pro_val_venta,
        NOW(),
        in_ganancias,
        in_kilogramos
       
    );
    -- 
    SET out_hecho = 'SI';
    SET out_estado = 'SAL0105';
    -- 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_temp_salida_quitar` (OUT `out_hecho` VARCHAR(2), OUT `out_estado` VARCHAR(7), IN `in_usu_id_usuario` INT, IN `in_pro_id_producto` INT)  cuerpo: BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_ingresos_pagos` (IN `in_id_ingreso` INT, IN `in_ma_debe` DOUBLE(15,2), IN `in_descripcion` VARCHAR(160), IN `in_idprovedor` INT, IN `in_ma_haber` DOUBLE(15,2))  BEGIN
DECLARE var_saldo DOUBLE(15,2);
--
SELECT ifnull(SUM(ing_deuda),0)suma_total INTO var_saldo FROM ingreso as s WHERE s.pcl_id_proveedor=in_idprovedor;
--
INSERT INTO mayor_ingreso(
id_ingresos,
ma_debe,
ma_descripcion,
id_provedor,
ma_haber,
ma_fecha,
ma_saldo)
VALUES(
    in_id_ingreso,
    in_ma_debe,
    in_descripcion,
    in_idprovedor,
    in_ma_haber,
    CURDATE(),
     var_saldo
     );

end$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `proc_efectivo_caja` (`date_ini` DATE, `date_fin` DATE) RETURNS DOUBLE(15,2) BEGIN
    DECLARE tsangria_ingreso Double(15,2);
    DECLARE tsangria_salida  Double(15,2);
    DECLARE total_credito  Double(15,2);
    DECLARE total_efectivo  Double(15,2);
    DECLARE t_sangria Double(15,2);
    DECLARE t_money Double(15,2);
    DECLARE efectivo_caja Double(15,2);
    --
    SELECT ifnull(round(SUM(monto),2),0) as monto_ingreso INTO tsangria_ingreso
    FROM sangria AS s 
    WHERE s.tipo_sangria='ingreso' 
    AND STR_TO_DATE(s.fecha, '%Y-%m-%d') 
    BETWEEN STR_TO_DATE(date_ini, '%Y-%m-%d')
    AND STR_TO_DATE(date_fin, '%Y-%m-%d');
    --
    SELECT ifnull(round(SUM(monto),2),0) as monto_retiro INTO tsangria_salida
    FROM sangria AS s 
    WHERE s.tipo_sangria='retiro' 
    AND STR_TO_DATE(s.fecha, '%Y-%m-%d') 
    BETWEEN STR_TO_DATE(date_ini, '%Y-%m-%d')
    AND STR_TO_DATE(date_fin, '%Y-%m-%d');
    --
    SELECT SUM(s.sal_monto_tar_credito) AS total_credito INTO total_credito
    FROM salida AS s WHERE STR_TO_DATE(s.sal_fecha_doc_cliente, '%Y-%m-%d') 
    BETWEEN STR_TO_DATE(date_ini, '%Y-%m-%d') 
    AND STR_TO_DATE(date_fin,'%Y-%m-%d');
    --
    SELECT SUM(s.sal_monto_efectivo) AS total_efectivo INTO total_efectivo
    FROM salida AS s WHERE STR_TO_DATE(s.sal_fecha_doc_cliente, '%Y-%m-%d')
    BETWEEN STR_TO_DATE(date_ini, '%Y-%m-%d') 
    AND STR_TO_DATE(date_fin,'%Y-%m-%d');
    --
    
   SET  t_sangria = tsangria_ingreso - tsangria_salida;
   SET t_money = total_credito + total_efectivo;
   SET efectivo_caja = t_money + t_sangria;
    RETURN efectivo_caja;
   
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja`
--

CREATE TABLE `caja` (
  `caj_id_caja` varchar(4) NOT NULL,
  `caj_descripcion` varchar(20) DEFAULT NULL,
  `caj_codigo` varchar(20) DEFAULT NULL,
  `caj_abierta` varchar(2) DEFAULT NULL,
  `usu_id_usuario` int(10) DEFAULT NULL,
  `est_id_estado` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `caja`
--

INSERT INTO `caja` (`caj_id_caja`, `caj_descripcion`, `caj_codigo`, `caj_abierta`, `usu_id_usuario`, `est_id_estado`) VALUES
('1801', 'CAJA1', '20190117030514', 'SI', 3, 11),
('1802', 'CAJA2', '20180907042002', 'SI', 2, 11);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clase`
--

CREATE TABLE `clase` (
  `cla_id_clase` int(10) UNSIGNED NOT NULL,
  `cla_nombre` varchar(60) DEFAULT NULL,
  `cla_id_clase_superior` int(10) UNSIGNED DEFAULT NULL,
  `est_id_estado` int(10) UNSIGNED DEFAULT NULL,
  `cla_eliminado` varchar(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `clase`
--

INSERT INTO `clase` (`cla_id_clase`, `cla_nombre`, `cla_id_clase_superior`, `est_id_estado`, `cla_eliminado`) VALUES
(33, 'Maiz', NULL, 11, 'NO'),
(34, 'Nacional', 33, 11, 'NO'),
(35, 'Importado', 33, 11, 'NO'),
(36, 'Repaso', 33, 11, 'NO'),
(37, 'Mezcla', NULL, 11, 'NO'),
(38, 'Mezcla ', 37, 11, 'NO'),
(39, 'Economico', 37, 11, 'NO'),
(40, 'Molido', 37, 11, 'NO'),
(41, 'Cuy R', 37, 11, 'NO'),
(42, 'Mezcla P', 37, 11, 'NO'),
(43, 'Mezcla C', 37, 11, 'NO'),
(44, 'Ponedora 2H', 37, 11, 'NO'),
(45, 'Vita Ovo', NULL, 11, 'NO'),
(46, 'Vita Ovo', 45, 11, 'NO'),
(47, 'Vita Ave', NULL, 11, 'NO'),
(48, 'Vita Cuy', 47, 11, 'NO'),
(49, 'Inicio Vita ', 47, 11, 'NO'),
(50, 'Engorde Vita', 47, 11, 'NO'),
(51, 'Crecimiento Vita', 47, 11, 'NO'),
(52, 'Ponedora Vita', 47, 11, 'NO'),
(53, 'Oscar', NULL, 11, 'NO'),
(54, 'Cuy Oscar', 53, 11, 'NO'),
(55, 'Conejo Oscar', 53, 11, 'NO'),
(56, 'Trigo', NULL, 11, 'NO'),
(57, 'Trigo negro', 56, 11, 'NO'),
(58, 'Trigo Blanco', 56, 11, 'NO'),
(59, 'Kompano', NULL, 11, 'NO'),
(60, 'Inicio Verde', 59, 11, 'NO'),
(61, 'Inicio Rojo', 59, 11, 'NO'),
(62, 'Engorde Simple', 59, 11, 'NO'),
(63, 'Crecimiento Simple', 59, 11, 'NO'),
(64, 'Hector', NULL, 11, 'NO'),
(65, 'Engorde Simple', 64, 11, 'NO'),
(66, 'Crecimiento Simple', 64, 11, 'NO'),
(67, 'Afrecho', NULL, 11, 'NO'),
(68, 'Afrecho Simple', 67, 11, 'NO'),
(69, 'Afrecho Compuesto', 67, 11, 'NO'),
(70, 'Cogorno', NULL, 11, 'NO'),
(71, 'Conejo', 70, 11, 'NO'),
(72, 'Pico & Navaja', 70, 11, 'NO'),
(73, 'BB Mycym', 70, 11, 'NO'),
(74, 'B12', NULL, 11, 'NO'),
(75, 'Inicio B12', 74, 11, 'NO'),
(76, 'Crecimiento B12', 74, 11, 'NO'),
(77, 'Engorde B12', 74, 11, 'NO'),
(78, 'Ponedora B12', 74, 11, 'NO'),
(79, 'Salud Total', 74, 11, 'NO'),
(80, 'Cuy B12', 74, 11, 'NO'),
(81, 'Conejo B12', 74, 11, 'NO'),
(82, 'Produccion', NULL, 11, 'NO'),
(83, 'Insumos', 82, 11, 'NO'),
(84, 'Alimento', NULL, 11, 'NO'),
(85, 'Gato', 84, 11, 'NO'),
(86, 'Perro', 84, 11, 'NO'),
(87, 'Lactante', 37, 11, 'NO'),
(88, 'INSUMOS', NULL, 11, 'NO'),
(89, 'INSUMOS', 88, 11, 'NO'),
(90, 'PURINA', 84, 11, 'NO'),
(91, 'INSUMOS', 88, 11, 'NO'),
(92, 'ENGORDE ', 70, 11, 'NO'),
(93, 'CRECIMIENTO', 70, 11, 'NO'),
(94, 'INICIO', 70, 11, 'NO'),
(95, 'CUY', 70, 11, 'NO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datos_empresa_local`
--

CREATE TABLE `datos_empresa_local` (
  `daemlo_id_datos_empresa_local` int(10) UNSIGNED NOT NULL,
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
  `daemlo_otros` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `datos_empresa_local`
--

INSERT INTO `datos_empresa_local` (`daemlo_id_datos_empresa_local`, `daemlo_ruc`, `daemlo_nombre_empresa_juridica`, `daemlo_nombre_empresa_fantasia`, `daemlo_codigo_postal`, `daemlo_direccion`, `daemlo_ciudad`, `daemlo_estado`, `daemlo_telefono`, `daemlo_telefono2`, `daemlo_telefono3`, `daemlo_telefono4`, `daemlo_contacto`, `daemlo_web`, `daemlo_facebook`, `daemlo_instagram`, `daemlo_twitter`, `daemlo_youtube`, `daemlo_otros`) VALUES
(1, '10404115184', 'GOLOSINAS ', 'GOLOSINAS ', '051', 'Av De La Cultura Nro. 701 Int. P-2 Mercado Productores Santa Anita - Lima - Lima', 'Lima', 'Lima', '965-421-048', '963-822-261', '', '', NULL, '', 'face', 'instagram', 'twitter', '', 'marlenecastrohermoza@gmail.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

CREATE TABLE `empresa` (
  `emp_id_empresa` int(10) UNSIGNED NOT NULL,
  `emp_ruc` varchar(11) DEFAULT NULL,
  `emp_razon_social` varchar(100) DEFAULT NULL,
  `emp_direccion` varchar(100) DEFAULT NULL,
  `emp_telefono` varchar(20) DEFAULT NULL,
  `emp_nombre_contacto` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `empresa`
--

INSERT INTO `empresa` (`emp_id_empresa`, `emp_ruc`, `emp_razon_social`, `emp_direccion`, `emp_telefono`, `emp_nombre_contacto`) VALUES
(1, '21344242223', 'SANTA ANITA 2', 'MZ', '', ''),
(2, '12345678901', 'MONTELEZ', 'HUACHIPA', 'XXXX', 'RAMIRO'),
(3, '21344111223', 'METRO S.R.L.', 'MIRAFLORES', '676-4108', ''),
(4, '21347716523', 'METRO LIMA SUR S.R.L.', 'LIMA SUR', '440-6040', 'ESTEPHANIA'),
(5, '15', '15', '15', '15', '15'),
(6, '61234000015', 'lupita', 'xxx', '', ''),
(7, '51234537815', '', '', '', ''),
(8, '', 'AC DISTRIBUIDORA EIRL', '', '960156138', 'SR JUAN'),
(15, '10425386781', 'Lima-Peru', 'Lima', '1234567', 'soporte tecnico'),
(16, '1042538976', 'Lima-Peru', 'Lima', '7654321', 'Soporte tecnico'),
(17, '10538678485', 'Lima-Peru', 'Lima', '1234547', 'Soporte tecnico'),
(21, '11001', 'AC DISTRIBUIDORA EIRL', '', '960156138', ''),
(22, '10001', 'OSCAR BRAVO', '', '', ''),
(23, '10002', 'ANGEL SOLORZANO', '', '', ''),
(24, '10003', 'COLEGIO DE LA INMACULADA', 'HERMANO SANTO GARCIA Nº 108 SURCO', '', ''),
(25, '10004', 'HERNAN', '', '', ''),
(26, '10005', 'MANUEL ROJO', '', '', ''),
(27, '10006', 'MIGUEL CUÑADO DE ROJO', '', '', ''),
(28, '10007', 'MARCOS IZAGUIRRE', '', '', ''),
(29, '10008', 'OMAR GARCIA', '', '', ''),
(30, '20001', 'EDUARDO', '', '', ''),
(31, '20002', 'BRAYAN', '', '', ''),
(32, '20003', 'GIOVANNA', '', '', ''),
(33, '20004', 'HELLEN', '', '', ''),
(34, '20005', 'IVAN ', 'UNICACHI', '', ''),
(35, '20006', 'JAN CARLOS', '', '', ''),
(36, '20007', 'KARINA', '', '', ''),
(37, '20008', 'MITZY ROJAS', '', '', ''),
(38, '20009', 'NUTRIMIX', 'LURIN', '', ''),
(39, '20010', 'NIEVES', '', '', ''),
(40, '20011', 'ROSARIO', '', '', ''),
(41, '20012', 'SERGIO', '', '', ''),
(42, '20013', 'TITO', '', '', ''),
(43, '20014', 'WILLIAMS TOSSETY', '', '', ''),
(44, '20015', 'WILLIAMS SMP', 'SAN MARTIN DE PORRAS', '981436607  ', 'SR OMAR'),
(45, '30001', 'CONDORITO', 'MERCADO SANTA ROSA', '', ''),
(46, '30002', 'FREDDY QUINTANILLA', '', '', ''),
(47, '30003', 'FIGUEROA', 'CHORRILLOS', '', ''),
(48, '30004', 'LANGUAZCO ABEL', '', '', ''),
(49, '30005', 'MARQUEZ', '', '', ''),
(50, '30006', 'MARLENE', '', '', ''),
(51, '30007', 'QUISPE', 'SAN JUAN DE LURIGANCHO', '', ''),
(52, '30008', 'ROSA IBAÑEZ', '', '992170580', ''),
(53, '30009', 'WILMER', '', '', ''),
(54, '40001', 'ANGEL DIAZ', '', '', ''),
(55, '40002', 'CARLOS SACONETA', 'VILLA MARIA', '', ''),
(56, '40003', 'SANTOS SACONETA', 'VILLA MARIA', '', ''),
(57, '40004', 'SACONETA PADRE', '', '', ''),
(58, '40005', 'FREDDY CANCHERO', '', '', ''),
(59, '40006', 'CUÑADO DE FREDDY', '', '', ''),
(60, '40007', 'PRIMO DE FREDDY', '', '', ''),
(61, '40008', 'FREDD NUEVA ESPERANZA', '', '', ''),
(62, '40009', 'LUNA', '', '', ''),
(63, '40010', 'MAXI', '', '', ''),
(64, '40011', 'MILAGROS LOLO', '', '', ''),
(65, '40012', 'MARGARITA', '', '', ''),
(66, '40013', 'ORMEÑO', '', '', ''),
(67, '40014', 'ROSA ', '', '', ''),
(68, '40015', 'VICTOR HNO SRA ROSA', '', '', ''),
(71, '1100000001', 'AC DISTRIBUIDORA EIRL', '', '960156138', 'SR JUAN'),
(72, '1100000002', 'AGROINDUSTRIAS KAIZEN', '', '998220730', 'SR JORGE'),
(73, '1100000003', 'ARMANDO ASCARATE', '', '994098702', ''),
(74, '1100000004', 'A&B EVER', '', '981299370', 'SR EVER'),
(75, '1100000005', 'COGORNO S.A', '', '981454607', 'OSCAR FLORES'),
(76, '1100000006', 'CALCIO ORGANICO', '', '995397444', 'SRA MARIELA'),
(77, '1100000007', 'CORPORACION KOMPANO', '', '946220185', 'YONAL'),
(78, '1100000008', 'DIVESUR', '', '941481278', 'WILLIAMS'),
(79, '1100000009', 'DIONISIO', '', '', ''),
(80, '1100000010', 'HECTOR VARGAS', '', '981516743', ''),
(81, '1100000011', 'JIMME ALFALFA', '', '957418162', ''),
(82, '1100000012', 'JUAN CARLOS', '', '', ''),
(83, '1100000013', 'MOLINOS OSCAR', '', '988672665', 'SRA JENNY'),
(93, '1100000014', 'REYES', '', '983458121', ''),
(94, '1100000015', 'SANDOVAL', '', '', ''),
(95, '1200000001', 'ANGEL MEZA', '', '943166126', ''),
(96, '1200000002', 'CLAVO', '', '955620521', ''),
(97, '1200000003', 'CALIN ', '', '994252198', ''),
(98, '1200000004', 'CONTACTO ( CESAR ZOÑE)', '', '959680237', ''),
(99, '1200000005', 'EDGAR ', '', '928895935', ''),
(100, '1200000006', 'EUSEBIO LOPEZ', '', '', ''),
(101, '1200000007', 'JAIME MANCILLA', '', '960186841', ''),
(102, '1200000008', 'JULIAN TEVEZ', '', '945588048', ''),
(103, '1200000009', 'JOHN FELIPA SANCA', '', '', ''),
(104, '1200000010', 'MARCO MANCILLA', '', '981283034', ''),
(105, '1200000011', 'MARCELINO ESCOBAR ', '', '', ''),
(106, '1200000012', 'MUNAYA', '', '', ''),
(107, '1200000013', 'MARCIAL', '', '', ''),
(108, '1200000014', 'MAURO M IMPORT', '', '', ''),
(109, '1200000015', 'RUSBER', '', '', ''),
(110, '1200000016', 'SUPERMAN', '', '', ''),
(111, '1200000017', 'WILMER MORY', '', '', ''),
(112, '1200000018', 'WILMER PINEDA', '', '', ''),
(113, '00000000000', 'ANONIMO', 'LIMA-PERU', '0000000', 'SOPORTE TECNICO'),
(114, '60000', 'LEONORA', '', '', ''),
(115, '60001', 'JUVENAL', '', '', ''),
(116, '60003', 'RONY', '', '', ''),
(117, '60004', 'MICAELA', '', '', ''),
(118, '60005', 'BOLIVAR ', '', '', ''),
(119, '60002', 'BOLIVAR 10', '', '', ''),
(120, '60006', 'BETTY', '', '', ''),
(121, '60007', 'LIZ', '', '', ''),
(122, '60008', 'TOÑO', '', '', ''),
(123, '60009', 'JUAN CARLOS', '', '', ''),
(124, '60010', 'VETERINARIO', '', '', ''),
(125, '60012', 'MIGUEL', '', '', ''),
(128, '60011', 'ANDRES', '', '', ''),
(129, '60013', 'FELIX', '', '', ''),
(130, '60014', 'ALICIA', '', '', ''),
(131, '60015', 'ANGELICA', '', '', ''),
(132, '60016', 'DANIEL', '', '', ''),
(133, '60017', 'DANIEL', '', '', ''),
(134, '60018', 'KAREN', '', '', ''),
(135, '60019', 'MILAGROS', '', '', ''),
(136, '60020', 'MARIO', '', '', ''),
(137, '60021', 'JESSICA', '', '', ''),
(138, '70001', 'GLADYS', 'MALA', '', ''),
(139, '70002', 'ELVIRA', '', '', ''),
(140, '70003', 'ZOYLA', '', '', ''),
(141, '70004', 'NELLY', '', '', ''),
(142, '70005', 'VICTOR', '', '', ''),
(143, '70006', 'JOSE LUIS', '', '', ''),
(144, '70007', 'SANTIAGO', '', '', ''),
(145, '70008', 'JAIME', '', '', ''),
(146, '70009', 'MARITZA CUYA', '', '', ''),
(147, '70010', 'LUIS GONZALEZ', '', '', ''),
(148, '70011', 'ELENA', '', '', ''),
(149, '70012', 'JONAS', '', '', ''),
(150, '70013', 'ELEAZAR', '', '', ''),
(151, '70014', 'IRMA', '', '', ''),
(152, '70015', 'SUAREZ', '', '', ''),
(153, '70016', 'JULIO', '', '', ''),
(154, '60022', 'ALEX ROBLES', '', '', ''),
(155, '10009', 'JOSE LUIS PROAVES', 'LURIN', '', '991778515'),
(159, '60023', 'ALFALFA', '', '', ''),
(160, '60024', 'RAUL', '', '', ''),
(161, '20016', 'UCHARIMA', '', '', ''),
(162, '10010', 'HERMOGENES', '', '', ''),
(163, '10011', 'EDITH', 'MERCADO SAN GABRIEL', '', ''),
(164, '70017', 'FELIPA', '', '', ''),
(165, '70018', 'LUCY', '', '', ''),
(166, '70019', 'NOEMY', '', '', ''),
(167, '10012', 'CHALCO', '', '', ''),
(168, '10013', 'JASSIER ROJAS', '', '', ''),
(169, '70020', 'JUAN', '', '', ''),
(170, '70021', 'MARIBEL', 'MALA', '', ''),
(171, '70022', 'PABLO', 'MALA', '', ''),
(172, '70023', 'BLANCA CUYA', '', '', ''),
(173, '10014', 'WILMER MARQUEZ', '', '', ''),
(174, '70024', 'JUANA GONZALEZ', '', '', ''),
(175, '10015', 'PAOLO TOSSETY', '', '', ''),
(176, '1100000016', 'FREDDY SOYA', '', '', ''),
(177, '1100000017', 'SR PEREZ SOYA', '', '', ''),
(178, '70025', 'ALBERTO', '', '', ''),
(179, '10016', 'ANGEL RIVERA', '', '', 'SR  ANGEL'),
(180, '60025', 'BOLIVAR 2', '', '', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado`
--

CREATE TABLE `estado` (
  `est_id_estado` int(10) UNSIGNED NOT NULL,
  `est_nombre` varchar(100) DEFAULT NULL,
  `est_tabla` varchar(100) DEFAULT NULL,
  `est_orden` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `estado`
--

INSERT INTO `estado` (`est_id_estado`, `est_nombre`, `est_tabla`, `est_orden`) VALUES
(1, 'CREADO', 'INGRESO', 1),
(2, 'FINALIZADO', 'INGRESO', 2),
(11, 'HABILITADO', 'ACCESO', 1),
(12, 'DESHABILITADO', 'ACCESO', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ingreso`
--

CREATE TABLE `ingreso` (
  `ing_id_ingreso` int(10) UNSIGNED NOT NULL,
  `pcl_id_cliente` int(10) UNSIGNED DEFAULT NULL,
  `pcl_id_proveedor` int(10) UNSIGNED DEFAULT NULL,
  `ing_fecha_doc_proveedor` date DEFAULT NULL,
  `tdo_id_tipo_documento` int(10) UNSIGNED DEFAULT NULL,
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
  `est_id_estado` int(10) UNSIGNED DEFAULT NULL,
  `in_tipo` varchar(150) NOT NULL,
  `ing_deuda` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `ingreso`
--

INSERT INTO `ingreso` (`ing_id_ingreso`, `pcl_id_cliente`, `pcl_id_proveedor`, `ing_fecha_doc_proveedor`, `tdo_id_tipo_documento`, `ing_numero_doc_proveedor`, `ing_fecha_registro`, `ing_tipo`, `ing_monto`, `ing_monto_base`, `ing_monto_efectivo`, `ing_monto_tar_credito`, `ing_monto_tar_debito`, `caj_id_caja`, `caj_codigo`, `usu_id_usuario`, `est_id_estado`, `in_tipo`, `ing_deuda`) VALUES
(1, NULL, 63, '2018-09-26', 15, '002', '2018-09-26 10:51:31', 'P', 2300.00, 2300.00, 2300.00, 0.00, 0.00, '1802', '20180907042002', 2, 2, '', 0),
(2, NULL, 151, '2018-11-01', 15, '001', '2018-11-01 09:09:48', 'P', 4225.00, 4225.00, 4225.00, 0.00, 0.00, '1802', '20180907042002', 2, 2, '', 0),
(3, NULL, 152, '2018-11-01', 15, '002', '2018-11-01 09:10:47', 'P', 24750.00, 24750.00, 24750.00, 0.00, 0.00, '1802', '20180907042002', 2, 2, '', 0),
(4, NULL, 67, '2018-11-02', 15, '17049', '2018-11-02 12:58:43', 'P', 38580.00, 38580.00, 38580.00, 0.00, 0.00, '1802', '20180907042002', 2, 2, 'deuda', 0),
(5, NULL, 67, '2018-11-02', 15, '17050', '2018-11-02 18:28:25', 'P', 15440.00, 15440.00, 15440.00, 0.00, 0.00, '1802', '20180907042002', 2, 2, 'contado', 0),
(6, NULL, 75, '2018-11-02', 15, '001', '2018-11-02 18:31:40', 'P', 37260.00, 37260.00, 37260.00, 0.00, 0.00, '1802', '20180907042002', 2, 2, 'deuda', 3000.59),
(7, NULL, 64, '2018-11-09', 15, '7632', '2018-11-09 12:35:42', 'P', 15889.95, 15889.95, 15889.95, 0.00, 0.00, '1802', '20180907042002', 2, 2, 'deuda', 0),
(8, NULL, 63, '2018-11-13', 15, '0012', '2018-11-13 09:29:18', 'P', 6150.00, 6150.00, 6150.00, 0.00, 0.00, '1802', '20180907042002', 2, 2, 'contado', 0),
(9, NULL, 63, '2018-11-13', 15, '0013', '2018-11-13 09:30:21', 'P', 6150.00, 6150.00, 6150.00, 0.00, 0.00, '1802', '20180907042002', 2, 2, 'contado', 1560.2),
(10, NULL, 62, '2018-12-05', 15, '1', '2018-12-05 16:14:40', 'P', 125.00, 125.00, 125.00, 0.00, 0.00, '1801', '20180928040101', 3, 2, 'deuda', 1600),
(11, NULL, 6, '2018-12-05', 15, '4515', '2018-12-05 17:21:41', 'P', 225.00, 225.00, 225.00, 0.00, 0.00, '1801', '20181205052121', 3, 2, 'deuda', 1600),
(12, NULL, 61, '2019-01-16', 12, '12121', '2019-01-16 01:57:10', 'P', 200.00, 200.00, 200.00, 0.00, 0.00, '1801', '20190107041440', 3, 2, 'contado', 200),
(13, NULL, 62, '2019-01-17', 15, '55', '2019-01-17 15:23:05', 'P', 8.00, 8.00, 8.00, 0.00, 0.00, '1801', '20190117030514', 3, 2, 'deuda', 8),
(14, NULL, 64, '2019-02-03', 15, '2', '2019-02-03 16:25:06', 'P', 6.00, 6.00, 6.00, 0.00, 0.00, '1801', '20190117030514', 3, 2, 'deuda', 6),
(15, NULL, 6, '2019-02-03', 15, '2', '2019-02-03 16:29:29', 'P', 150.00, 150.00, 150.00, 0.00, 0.00, '1801', '20190117030514', 3, 2, 'deuda', 125),
(16, NULL, 65, '2019-02-03', 15, '12', '2019-02-03 18:02:23', 'P', 480.00, 480.00, 0.00, 400.00, 0.00, '1801', '20190117030514', 3, 2, 'deuda', 100),
(17, NULL, 66, '2019-02-04', 15, 'LL45', '2019-02-04 11:48:56', 'P', 1300.00, 1300.00, 0.00, 130.00, 0.00, '1801', '20190117030514', 3, 2, 'deuda', 220),
(18, NULL, 70, '2019-02-04', 15, '33', '2019-02-04 12:34:08', 'P', 4500.00, 4500.00, 0.00, 500.00, 0.00, '1801', '20190117030514', 3, 2, 'deuda', 1000);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ingreso_detalle`
--

CREATE TABLE `ingreso_detalle` (
  `ind_id_ingreso_detalle` int(10) UNSIGNED NOT NULL,
  `pro_id_producto` int(10) UNSIGNED NOT NULL,
  `ing_id_ingreso` int(10) UNSIGNED NOT NULL,
  `ind_cantidad` double(15,2) UNSIGNED DEFAULT NULL,
  `ind_valor` double(15,2) DEFAULT NULL,
  `ind_monto` double(15,2) DEFAULT NULL,
  `ind_numero_lote` varchar(30) DEFAULT NULL,
  `ind_perecible` varchar(2) DEFAULT NULL,
  `ind_fecha_vencimiento` date DEFAULT NULL,
  `est_id_estado` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `ingreso_detalle`
--

INSERT INTO `ingreso_detalle` (`ind_id_ingreso_detalle`, `pro_id_producto`, `ing_id_ingreso`, `ind_cantidad`, `ind_valor`, `ind_monto`, `ind_numero_lote`, `ind_perecible`, `ind_fecha_vencimiento`, `est_id_estado`) VALUES
(1, 22, 1, 100.00, 23.00, 2300.00, '001', 'NO', '0000-00-00', 1),
(2, 113, 2, 50.00, 84.50, 4225.00, '001', 'SI', '2018-11-01', 1),
(3, 113, 3, 300.00, 82.50, 24750.00, '002', 'SI', '2018-10-31', 1),
(4, 79, 4, 200.00, 50.80, 10160.00, '001', 'SI', '2018-11-02', 1),
(5, 80, 4, 150.00, 62.20, 9330.00, '001', 'SI', '2018-11-02', 1),
(6, 81, 4, 150.00, 57.00, 8550.00, '001', 'SI', '2018-11-02', 1),
(7, 82, 4, 100.00, 57.00, 5700.00, '001', 'SI', '2018-11-02', 1),
(8, 83, 4, 20.00, 57.00, 1140.00, '001', 'SI', '2018-11-02', 1),
(9, 97, 4, 100.00, 37.00, 3700.00, '001', 'SI', '2018-11-02', 1),
(10, 88, 5, 80.00, 64.00, 5120.00, '001', 'SI', '2018-11-02', 1),
(11, 93, 5, 80.00, 59.00, 4720.00, '001', 'SI', '2018-11-02', 1),
(12, 95, 5, 80.00, 70.00, 5600.00, '001', 'SI', '2018-11-02', 1),
(13, 167, 6, 31050.00, 1.20, 37260.00, '001', 'SI', '2018-11-02', 1),
(14, 24, 7, 145.00, 85.55, 12404.75, '001', 'NO', '0000-00-00', 1),
(15, 164, 7, 10.00, 65.15, 651.50, '002', 'SI', '2018-11-09', 1),
(16, 169, 7, 25.00, 61.01, 1525.25, '001', 'SI', '2018-11-09', 1),
(17, 170, 7, 15.00, 64.09, 961.35, '001', 'SI', '2018-11-09', 1),
(18, 171, 7, 5.00, 69.42, 347.10, '001', 'SI', '2018-11-09', 1),
(19, 22, 8, 250.00, 24.60, 6150.00, '002', 'NO', '0000-00-00', 1),
(20, 22, 9, 250.00, 24.60, 6150.00, '003', 'NO', '0000-00-00', 1),
(21, 114, 10, 5.00, 25.00, 125.00, '4', 'SI', '2018-12-05', 1),
(22, 19, 11, 5.00, 45.00, 225.00, '45', 'NO', '0000-00-00', 1),
(23, 1, 12, 10.00, 20.00, 200.00, 'dsdsdsds', 'NO', '0000-00-00', 1),
(24, 19, 13, 4.00, 2.00, 8.00, '414', 'NO', '0000-00-00', 1),
(25, 114, 14, 2.00, 3.00, 6.00, '1', 'SI', '2019-02-03', 1),
(26, 114, 15, 6.00, 25.00, 150.00, '1', 'SI', '2019-02-03', 1),
(27, 22, 16, 6.00, 80.00, 480.00, '52', 'NO', '0000-00-00', 1),
(28, 19, 17, 26.00, 50.00, 1300.00, '25L', 'NO', '0000-00-00', 1),
(29, 22, 18, 5.00, 900.00, 4500.00, '25', 'NO', '0000-00-00', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mayor`
--

CREATE TABLE `mayor` (
  `id_mayor` int(11) NOT NULL,
  `ma_fecha` date NOT NULL,
  `ma_descripcion` varchar(250) NOT NULL,
  `ma_debe` double(15,2) DEFAULT '0.00',
  `ma_haber` double(15,2) DEFAULT '0.00',
  `ma_saldo` double(15,2) NOT NULL,
  `sal_id_salida` int(11) NOT NULL,
  `pcl_id_cliente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `mayor`
--

INSERT INTO `mayor` (`id_mayor`, `ma_fecha`, `ma_descripcion`, `ma_debe`, `ma_haber`, `ma_saldo`, `sal_id_salida`, `pcl_id_cliente`) VALUES
(9, '2019-01-31', '00.00', 20.00, 93.00, 0.00, 655, 599),
(10, '2019-01-31', 'pagos', 20.00, 0.00, 635.00, 599, 93),
(11, '2019-01-31', 'Pago de la deuda', 256.20, 0.00, 378.80, 599, 93),
(12, '2019-01-31', 'asdas', 26.00, 0.00, 352.80, 599, 93),
(13, '2019-01-31', 'losb bjs n', 59.00, 0.00, 319.80, 599, 93),
(14, '2019-01-31', 'genial', 25.00, 0.00, 385.00, 598, 93),
(15, '2019-01-31', 'asdas', 50.00, 0.00, 335.00, 598, 93),
(16, '2019-01-31', 'Ingresando pago de la cuenta de compras', 20.00, 0.00, 365.00, 601, 14),
(17, '2019-01-31', 'POR LA COMPRA DE PRODUCTOS', 0.00, 318.00, 0.00, 0, 0),
(18, '2019-01-31', 'POR LA COMPRA DE PRODUCTOS', 0.00, 318.00, 0.00, 0, 0),
(19, '2019-02-01', 'asa', 335.00, 0.00, 0.00, 598, 93),
(20, '2019-02-01', 'gil', 319.80, 0.00, 0.00, 599, 93),
(21, '2019-02-01', 'Hello', 50.00, 0.00, 0.00, 606, 93),
(22, '2019-02-01', 'Recontra gil', 318.00, 0.00, 0.00, 602, 16),
(23, '2019-02-01', 'MUy gil', 50.00, 0.00, 0.00, 603, 16),
(24, '2019-02-01', 'Gill', 50.00, 0.00, 0.00, 604, 16),
(25, '2019-02-01', 'Extremadamente gil', 50.00, 0.00, 0.00, 605, 16),
(26, '2019-02-01', 'Monto pagado de la deuda', 20.00, 0.00, 363.00, 608, 93),
(27, '2019-02-01', 'POR LA COMPRA DE PRODUCTOS', 20.00, 321.35, 642.70, 610, 13),
(28, '2019-02-01', 'POR LA COMPRA DE PRODUCTOS', 20.00, 160.00, 160.00, 611, 25),
(29, '2019-02-01', 'POR LA COMPRA DE PRODUCTOS', 0.00, 346.00, 506.00, 612, 25),
(30, '2019-02-01', 'Por la deuda del 2019-02-01', 320.00, 0.00, 186.00, 612, 25),
(31, '2019-02-03', 'POR LA COMPRA DE PRODUCTOS', 0.00, 0.00, 12268.00, 613, 93),
(32, '2019-02-04', 'hola', 500.00, 0.00, 11768.00, 608, 93),
(33, '2019-02-04', 'POR LA COMPRA DE PRODUCTOS', 500.00, 1061.35, 12829.35, 614, 93),
(34, '2019-02-17', 'POR LA COMPRA DE PRODUCTOS', 0.00, 520.00, 13349.35, 615, 93),
(35, '2019-02-17', 'POR LA COMPRA DE PRODUCTOS', 0.00, 0.00, 13349.35, 616, 93);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mayor_ingreso`
--

CREATE TABLE `mayor_ingreso` (
  `id_mayor_ingreso` int(11) NOT NULL,
  `ma_fecha` varchar(150) NOT NULL,
  `ma_descripcion` varchar(150) NOT NULL,
  `ma_debe` double(15,2) NOT NULL,
  `ma_haber` double(15,2) NOT NULL,
  `ma_saldo` double(15,2) NOT NULL,
  `id_provedor` int(11) NOT NULL,
  `id_ingresos` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `mayor_ingreso`
--

INSERT INTO `mayor_ingreso` (`id_mayor_ingreso`, `ma_fecha`, `ma_descripcion`, `ma_debe`, `ma_haber`, `ma_saldo`, `id_provedor`, `id_ingresos`) VALUES
(19, '2019-02-03', 'hola mundo', 100.00, 0.00, 600.00, 62, 37),
(20, '2019-02-03', 'falta cancelar el total', 300.00, 300.00, 800.00, 62, 40),
(21, '2019-02-03', 'falta cancelar el total', 200.00, 200.00, 1000.00, 62, 41),
(0, '2019-02-03', 'pago de la cuenta ', 25.00, 0.00, 1725.00, 6, 15),
(0, '2019-02-03', 'falta cancelar el total', 400.00, 400.00, 400.00, 65, 16),
(0, '2019-02-03', 'pago de la deuda', 200.00, 0.00, 200.00, 65, 16),
(0, '2019-02-03', 'pagooos', 100.00, 0.00, 200.00, 65, 16),
(0, '2019-02-04', 'falta cancelar el total', 130.00, 1170.00, 1170.00, 66, 17),
(0, '2019-02-04', 'Por la deuda de compra de productos ', 250.00, 0.00, 1170.00, 66, 17),
(0, '2019-02-04', 'Hola', 500.00, 0.00, 420.00, 66, 17),
(0, '2019-02-04', 'pago de la deuda', 200.00, 0.00, 220.00, 66, 17),
(0, '2019-02-04', 'Por la compra de productos', 500.00, 4000.00, 4000.00, 70, 18),
(0, '2019-02-04', 'PAGO DE LA DEUDA PENDIENTE', 3000.00, 0.00, 1000.00, 70, 18);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimiento`
--

CREATE TABLE `movimiento` (
  `mov_id_movimiento` int(10) UNSIGNED NOT NULL,
  `ind_id_ingreso_detalle` int(10) UNSIGNED DEFAULT NULL,
  `sad_id_salida_detalle` int(10) UNSIGNED DEFAULT NULL,
  `ing_id_ingreso` int(10) UNSIGNED DEFAULT NULL,
  `sal_id_salida` int(10) UNSIGNED DEFAULT NULL,
  `mov_tipo` varchar(3) DEFAULT NULL,
  `mov_cantidad_anterior` double(15,2) DEFAULT NULL,
  `mov_cantidad_entrante` double(15,2) DEFAULT NULL,
  `mov_cantidad_actual` double(15,2) DEFAULT NULL,
  `pro_id_producto` int(10) UNSIGNED DEFAULT NULL,
  `est_id_estado` int(10) UNSIGNED DEFAULT NULL,
  `usu_id_usuario` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `movimiento`
--

INSERT INTO `movimiento` (`mov_id_movimiento`, `ind_id_ingreso_detalle`, `sad_id_salida_detalle`, `ing_id_ingreso`, `sal_id_salida`, `mov_tipo`, `mov_cantidad_anterior`, `mov_cantidad_entrante`, `mov_cantidad_actual`, `pro_id_producto`, `est_id_estado`, `usu_id_usuario`) VALUES
(1, NULL, NULL, NULL, 1, 'SAC', 0.00, 1.00, 1.00, 54, 2, 2),
(2, NULL, NULL, NULL, 2, 'SAC', 1.00, 1.00, 0.00, 54, 2, 2),
(3, NULL, NULL, NULL, NULL, 'IN1', 0.00, 0.00, 0.00, 55, 1, 2),
(4, NULL, NULL, NULL, NULL, 'IN1', 0.00, 0.00, 0.00, 56, 1, 2),
(5, NULL, NULL, NULL, NULL, 'IN1', 0.00, 50.00, 50.00, 57, 1, 2),
(6, NULL, NULL, NULL, NULL, 'IN1', 0.00, 15.00, 15.00, 58, 1, 2),
(7, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 59, 1, 2),
(8, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 60, 1, 2),
(9, NULL, NULL, NULL, NULL, 'IN1', 0.00, 15.00, 15.00, 61, 1, 2),
(10, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 62, 1, 2),
(11, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 63, 1, 2),
(12, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 64, 1, 2),
(13, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 65, 1, 2),
(14, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 66, 1, 2),
(15, NULL, NULL, NULL, NULL, 'IN1', 0.00, 12.00, 12.00, 67, 1, 2),
(16, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 68, 1, 2),
(17, NULL, NULL, NULL, NULL, 'IN1', 0.00, 12.00, 12.00, 69, 1, 2),
(18, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 70, 1, 2),
(19, NULL, NULL, NULL, NULL, 'IN1', 0.00, 12.00, 12.00, 71, 1, 2),
(20, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 72, 1, 2),
(21, NULL, NULL, NULL, NULL, 'IN1', 0.00, 12.00, 12.00, 73, 1, 2),
(22, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 74, 1, 2),
(23, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 75, 1, 2),
(24, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 76, 1, 2),
(25, NULL, NULL, NULL, NULL, 'IN1', 0.00, 200.00, 200.00, 77, 1, 2),
(26, NULL, NULL, NULL, NULL, 'IN1', 0.00, 15.00, 15.00, 78, 1, 2),
(27, NULL, NULL, NULL, NULL, 'IN1', 0.00, 50.00, 50.00, 79, 1, 2),
(28, NULL, NULL, NULL, NULL, 'IN1', 0.00, 7.00, 7.00, 80, 1, 2),
(29, NULL, NULL, NULL, NULL, 'IN1', 0.00, 21.00, 21.00, 81, 1, 2),
(30, NULL, NULL, NULL, NULL, 'IN1', 0.00, 55.00, 55.00, 82, 1, 2),
(31, NULL, NULL, NULL, NULL, 'IN1', 0.00, 0.00, 0.00, 83, 1, 2),
(32, NULL, NULL, NULL, NULL, 'IN1', 0.00, 24.00, 24.00, 84, 1, 2),
(33, NULL, NULL, NULL, NULL, 'IN1', 0.00, 7.00, 7.00, 85, 1, 2),
(34, NULL, NULL, NULL, NULL, 'IN1', 0.00, 0.00, 0.00, 86, 1, 2),
(35, NULL, NULL, NULL, NULL, 'IN1', 0.00, 0.00, 0.00, 87, 1, 2),
(36, NULL, NULL, NULL, NULL, 'IN1', 0.00, 92.00, 92.00, 88, 1, 2),
(37, NULL, NULL, NULL, NULL, 'IN1', 0.00, 3.00, 3.00, 89, 1, 2),
(38, NULL, NULL, NULL, NULL, 'IN1', 0.00, 66.00, 66.00, 90, 1, 2),
(39, NULL, NULL, NULL, NULL, 'IN1', 0.00, 95.00, 95.00, 91, 1, 2),
(40, NULL, NULL, NULL, NULL, 'IN1', 0.00, 80.00, 80.00, 92, 1, 2),
(41, NULL, NULL, NULL, NULL, 'IN1', 0.00, 146.00, 146.00, 93, 1, 2),
(42, NULL, NULL, NULL, NULL, 'IN1', 0.00, 0.00, 0.00, 94, 1, 2),
(43, NULL, NULL, NULL, NULL, 'IN1', 0.00, 0.00, 0.00, 95, 1, 2),
(44, NULL, NULL, NULL, NULL, 'IN1', 0.00, 0.00, 0.00, 96, 1, 2),
(45, NULL, NULL, NULL, 3, 'SAC', 3.00, 2.00, 1.00, 89, 2, 2),
(46, NULL, NULL, NULL, 4, 'SAC', 0.00, 1.00, 1.00, 22, 2, 2),
(47, NULL, NULL, NULL, 5, 'SAC', 1.00, 1.00, 0.00, 22, 2, 2),
(48, NULL, NULL, NULL, 6, 'SAC', 0.00, 1.00, -1.00, 22, 2, 2),
(49, NULL, NULL, NULL, 7, 'SAC', 0.00, 0.00, 0.00, 22, 2, 2),
(50, NULL, NULL, NULL, 8, 'SAC', 0.00, 1.00, -1.00, 22, 2, 2),
(51, NULL, NULL, NULL, 9, 'SAC', 0.00, 0.00, 0.00, 22, 2, 2),
(52, NULL, NULL, NULL, NULL, 'INA', 0.00, 100.00, 100.00, 22, 2, 2),
(53, NULL, NULL, NULL, NULL, 'SAA', 100.00, 1000.00, -900.00, 22, 2, 2),
(54, NULL, NULL, 1, NULL, 'INP', 0.00, 0.00, 0.00, 22, 2, 2),
(55, NULL, NULL, NULL, NULL, 'IN1', 0.00, 50.00, 50.00, 97, 1, 2),
(56, NULL, NULL, NULL, NULL, 'IN1', 0.00, 150.00, 150.00, 98, 1, 2),
(57, NULL, NULL, NULL, 10, 'SAC', 0.00, 1.00, 1.00, 45, 2, 3),
(58, NULL, NULL, NULL, 11, 'SAC', 0.00, 1.00, -1.00, 22, 2, 3),
(59, NULL, NULL, NULL, 12, 'SAC', 1.00, 2.00, -1.00, 45, 2, 3),
(60, NULL, NULL, NULL, 13, 'SAC', 0.00, 0.00, 0.00, 22, 2, 3),
(61, NULL, NULL, NULL, 14, 'SAC', 0.00, 5.00, 5.00, 19, 2, 3),
(62, NULL, NULL, NULL, 15, 'SAC', 0.00, 2.00, -2.00, 22, 2, 3),
(63, NULL, NULL, NULL, 16, 'SAC', 0.00, 2.00, 2.00, 17, 2, 3),
(64, NULL, NULL, NULL, 17, 'SAC', 1.00, 1.00, 0.00, 89, 2, 3),
(65, NULL, NULL, NULL, 18, 'SAC', 0.00, 2.00, 2.00, 2, 2, 3),
(66, NULL, NULL, NULL, 18, 'SAC', 0.00, 2.00, 2.00, 4, 2, 3),
(67, NULL, NULL, NULL, 18, 'SAC', 0.00, 3.00, 3.00, 18, 2, 3),
(68, NULL, NULL, NULL, 18, 'SAC', 0.00, 2.00, 2.00, 36, 2, 3),
(69, NULL, NULL, NULL, 18, 'SAC', 0.00, 2.00, 2.00, 37, 2, 3),
(70, NULL, NULL, NULL, 18, 'SAC', 0.00, 0.00, 0.00, 45, 2, 3),
(71, NULL, NULL, NULL, 18, 'SAC', 0.00, 1.00, 1.00, 50, 2, 3),
(72, NULL, NULL, NULL, 18, 'SAC', 0.00, 2.00, -2.00, 54, 2, 3),
(73, NULL, NULL, NULL, 19, 'SAC', 0.00, 3.00, 3.00, 13, 2, 3),
(74, NULL, NULL, NULL, 19, 'SAC', 0.00, 2.00, 2.00, 15, 2, 3),
(75, NULL, NULL, NULL, 19, 'SAC', 5.00, 3.00, 2.00, 19, 2, 3),
(76, NULL, NULL, NULL, 19, 'SAC', 0.00, 0.00, 0.00, 22, 2, 3),
(77, NULL, NULL, NULL, 19, 'SAC', 0.00, 5.00, 5.00, 23, 2, 3),
(78, NULL, NULL, NULL, 19, 'SAC', 0.00, 4.00, 4.00, 24, 2, 3),
(79, NULL, NULL, NULL, 19, 'SAC', 0.00, 2.00, -2.00, 45, 2, 3),
(80, NULL, NULL, NULL, 19, 'SAC', 10.00, 3.00, 7.00, 65, 2, 3),
(81, NULL, NULL, NULL, 19, 'SAC', 10.00, 5.00, 5.00, 70, 2, 3),
(82, NULL, NULL, NULL, 20, 'SAC', 2.00, 23.00, -21.00, 15, 2, 3),
(83, NULL, NULL, NULL, 20, 'SAC', 2.00, 67.00, -65.00, 19, 2, 3),
(84, NULL, NULL, NULL, 20, 'SAC', 4.00, 4.00, 0.00, 24, 2, 3),
(85, NULL, NULL, NULL, 20, 'SAC', 0.00, 4.00, 4.00, 26, 2, 3),
(86, NULL, NULL, NULL, 20, 'SAC', 0.00, 2.00, 2.00, 40, 2, 3),
(87, NULL, NULL, NULL, 20, 'SAC', 0.00, 5.00, 5.00, 47, 2, 3),
(88, NULL, NULL, NULL, 20, 'SAC', 0.00, 0.00, 0.00, 54, 2, 3),
(89, NULL, NULL, NULL, 20, 'SAC', 24.00, 1.00, 23.00, 84, 2, 3),
(90, NULL, NULL, NULL, 21, 'SAC', 3.00, 1.00, 2.00, 18, 2, 3),
(91, NULL, NULL, NULL, 21, 'SAC', 0.00, 1.00, 1.00, 39, 2, 3),
(92, NULL, NULL, NULL, 21, 'SAC', 0.00, 1.00, 1.00, 46, 2, 3),
(93, NULL, NULL, NULL, 21, 'SAC', 0.00, 2.00, 2.00, 51, 2, 3),
(94, NULL, NULL, NULL, 22, 'SAC', 0.00, 0.00, 0.00, 19, 2, 3),
(95, NULL, NULL, NULL, 22, 'SAC', 0.00, 1.00, -1.00, 24, 2, 3),
(96, NULL, NULL, NULL, 22, 'SAC', 0.00, 1.00, 1.00, 30, 2, 3),
(97, NULL, NULL, NULL, 22, 'SAC', 0.00, 1.00, 1.00, 38, 2, 3),
(98, NULL, NULL, NULL, 22, 'SAC', 1.00, 2.00, -1.00, 50, 2, 3),
(99, NULL, NULL, NULL, 22, 'SAC', 0.00, 2.00, -2.00, 54, 2, 3),
(100, NULL, NULL, NULL, 22, 'SAC', 23.00, 1.00, 22.00, 84, 2, 3),
(101, NULL, NULL, NULL, 23, 'SAC', 0.00, 0.00, 0.00, 50, 2, 3),
(102, NULL, NULL, NULL, 23, 'SAC', 0.00, 0.00, 0.00, 54, 2, 3),
(103, NULL, NULL, NULL, 24, 'SAC', 1.00, 2.00, -1.00, 46, 2, 3),
(104, NULL, NULL, NULL, 24, 'SAC', 0.00, 2.00, -2.00, 50, 2, 3),
(105, NULL, NULL, NULL, 25, 'SAC', 0.00, 1.00, -1.00, 54, 2, 3),
(106, NULL, NULL, NULL, 25, 'SAC', 22.00, 2.00, 20.00, 84, 2, 3),
(107, NULL, NULL, NULL, 26, 'SAC', 0.00, 0.00, 0.00, 50, 2, 3),
(108, NULL, NULL, NULL, 26, 'SAC', 92.00, 2.00, 90.00, 88, 2, 3),
(109, NULL, NULL, NULL, 27, 'SAC', 5.00, 2.00, 3.00, 70, 2, 3),
(110, NULL, NULL, NULL, 27, 'SAC', 12.00, 1.00, 11.00, 71, 2, 3),
(111, NULL, NULL, NULL, 27, 'SAC', 80.00, 1.00, 79.00, 92, 2, 3),
(112, NULL, NULL, NULL, 28, 'SAC', 10.00, 1.00, 9.00, 68, 2, 3),
(113, NULL, NULL, NULL, 29, 'SAC', 0.00, 1.00, -1.00, 19, 2, 3),
(114, NULL, NULL, NULL, 29, 'SAC', 0.00, 0.00, 0.00, 24, 2, 3),
(115, NULL, NULL, NULL, 29, 'SAC', 0.00, 2.00, -2.00, 50, 2, 3),
(116, NULL, NULL, NULL, 30, 'SAC', 0.00, 0.00, 0.00, 50, 2, 3),
(117, NULL, NULL, NULL, 31, 'SAC', 3.00, 1.00, 2.00, 70, 2, 3),
(118, NULL, NULL, NULL, 32, 'SAC', 0.00, 0.00, 0.00, 54, 2, 3),
(119, NULL, NULL, NULL, 33, 'SAC', 1.00, 2.00, -1.00, 30, 2, 3),
(120, NULL, NULL, NULL, 33, 'SAC', 1.00, 2.00, -1.00, 39, 2, 3),
(121, NULL, NULL, NULL, 33, 'SAC', 0.00, 2.00, 2.00, 44, 2, 3),
(122, NULL, NULL, NULL, 33, 'SAC', 0.00, 0.00, 0.00, 46, 2, 3),
(123, NULL, NULL, NULL, 33, 'SAC', 5.00, 2.00, 3.00, 47, 2, 3),
(124, NULL, NULL, NULL, 33, 'SAC', 0.00, 2.00, -2.00, 50, 2, 3),
(125, NULL, NULL, NULL, 33, 'SAC', 0.00, 2.00, -2.00, 54, 2, 3),
(126, NULL, NULL, NULL, 33, 'SAC', 12.00, 2.00, 10.00, 73, 2, 3),
(127, NULL, NULL, NULL, 34, 'SAC', 0.00, 0.00, 0.00, 39, 2, 3),
(128, NULL, NULL, NULL, 34, 'SAC', 0.00, 0.00, 0.00, 50, 2, 3),
(129, NULL, NULL, NULL, 34, 'SAC', 2.00, 2.00, 0.00, 51, 2, 3),
(130, NULL, NULL, NULL, 34, 'SAC', 20.00, 2.00, 18.00, 84, 2, 3),
(131, NULL, NULL, NULL, 34, 'SAC', 90.00, 2.00, 88.00, 88, 2, 3),
(132, NULL, NULL, NULL, 35, 'SAC', 0.00, 0.00, 0.00, 30, 2, 3),
(133, NULL, NULL, NULL, 35, 'SAC', 0.00, 2.00, -2.00, 50, 2, 3),
(134, NULL, NULL, NULL, 35, 'SAC', 0.00, 0.00, 0.00, 54, 2, 3),
(135, NULL, NULL, NULL, 35, 'SAC', 2.00, 2.00, 0.00, 70, 2, 3),
(136, NULL, NULL, NULL, 35, 'SAC', 7.00, 2.00, 5.00, 85, 2, 3),
(137, NULL, NULL, NULL, 36, 'SAC', 0.00, 2.00, -2.00, 30, 2, 3),
(138, NULL, NULL, NULL, 36, 'SAC', 2.00, 2.00, 0.00, 44, 2, 3),
(139, NULL, NULL, NULL, 36, 'SAC', 0.00, 0.00, 0.00, 50, 2, 3),
(140, NULL, NULL, NULL, 37, 'SAC', 0.00, 0.00, 0.00, 30, 2, 3),
(141, NULL, NULL, NULL, 37, 'SAC', 0.00, 2.00, -2.00, 44, 2, 3),
(142, NULL, NULL, NULL, 37, 'SAC', 3.00, 2.00, 1.00, 47, 2, 3),
(143, NULL, NULL, NULL, 37, 'SAC', 0.00, 2.00, -2.00, 50, 2, 3),
(144, NULL, NULL, NULL, 37, 'SAC', 0.00, 2.00, -2.00, 54, 2, 3),
(145, NULL, NULL, NULL, 37, 'SAC', 18.00, 2.00, 16.00, 84, 2, 3),
(146, NULL, NULL, NULL, 38, 'SAC', 0.00, 1.00, -1.00, 30, 2, 3),
(147, NULL, NULL, NULL, 38, 'SAC', 1.00, 1.00, 0.00, 38, 2, 3),
(148, NULL, NULL, NULL, 38, 'SAC', 0.00, 0.00, 0.00, 44, 2, 3),
(149, NULL, NULL, NULL, 38, 'SAC', 1.00, 1.00, 0.00, 47, 2, 3),
(150, NULL, NULL, NULL, 38, 'SAC', 0.00, 2.00, -2.00, 51, 2, 3),
(151, NULL, NULL, NULL, 38, 'SAC', 10.00, 2.00, 8.00, 60, 2, 3),
(152, NULL, NULL, NULL, 38, 'SAC', 10.00, 3.00, 7.00, 72, 2, 3),
(153, NULL, NULL, NULL, 38, 'SAC', 16.00, 1.00, 15.00, 84, 2, 3),
(154, NULL, NULL, NULL, 39, 'SAC', 0.00, 2.00, -2.00, 46, 2, 3),
(155, NULL, NULL, NULL, 39, 'SAC', 0.00, 0.00, 0.00, 50, 2, 3),
(156, NULL, NULL, NULL, 40, 'SAC', 0.00, 0.00, 0.00, 54, 2, 3),
(157, NULL, NULL, NULL, 41, 'SAC', 0.00, 2.00, -2.00, 50, 2, 3),
(158, NULL, NULL, NULL, 41, 'SAC', 0.00, 0.00, 0.00, 51, 2, 3),
(159, NULL, NULL, NULL, 41, 'SAC', 15.00, 2.00, 13.00, 84, 2, 3),
(160, NULL, NULL, NULL, 42, 'SAC', 0.00, 0.00, 0.00, 45, 2, 3),
(161, NULL, NULL, NULL, 42, 'SAC', 0.00, 0.00, 0.00, 50, 2, 3),
(162, NULL, NULL, NULL, 42, 'SAC', 13.00, 2.00, 11.00, 84, 2, 3),
(163, NULL, NULL, NULL, 43, 'SAC', 0.00, 2.00, -2.00, 54, 2, 3),
(164, NULL, NULL, NULL, 44, 'SAC', 0.00, 2.00, -2.00, 50, 2, 3),
(165, NULL, NULL, NULL, 45, 'SAC', 0.00, 2.00, -2.00, 44, 2, 3),
(166, NULL, NULL, NULL, 46, 'SAC', 9.00, 2.00, 7.00, 68, 2, 3),
(167, NULL, NULL, NULL, 47, 'SAC', 0.00, 0.00, 0.00, 50, 2, 3),
(168, NULL, NULL, NULL, 48, 'SAC', 0.00, 0.00, 0.00, 54, 2, 3),
(169, NULL, NULL, NULL, 49, 'SAC', 0.00, 2.00, -2.00, 54, 2, 3),
(170, NULL, NULL, NULL, 50, 'SAC', 0.00, 0.00, 0.00, 44, 2, 3),
(171, NULL, NULL, NULL, 50, 'SAC', 0.00, 0.00, 0.00, 46, 2, 3),
(172, NULL, NULL, NULL, 51, 'SAC', 0.00, 0.00, 0.00, 54, 2, 3),
(173, NULL, NULL, NULL, 52, 'SAC', 0.00, 0.00, 0.00, 30, 2, 3),
(174, NULL, NULL, NULL, 52, 'SAC', 0.00, 2.00, -2.00, 44, 2, 3),
(175, NULL, NULL, NULL, 53, 'SAC', 0.00, 0.00, 0.00, 44, 2, 3),
(176, NULL, NULL, NULL, 53, 'SAC', 0.00, 2.00, -2.00, 46, 2, 3),
(177, NULL, NULL, NULL, 54, 'SAC', 66.00, 2.00, 64.00, 90, 2, 3),
(178, NULL, NULL, NULL, 55, 'SAC', 0.00, 2.00, -2.00, 54, 2, 3),
(179, NULL, NULL, NULL, 56, 'SAC', 0.00, 2.00, -2.00, 50, 2, 3),
(180, NULL, NULL, NULL, 57, 'SAC', 0.00, 0.00, 0.00, 54, 2, 3),
(181, NULL, NULL, NULL, 58, 'SAC', 0.00, 2.00, 2.00, 32, 2, 3),
(182, NULL, NULL, NULL, 58, 'SAC', 0.00, 0.00, 0.00, 46, 2, 3),
(183, NULL, NULL, NULL, 58, 'SAC', 0.00, 0.00, 0.00, 50, 2, 3),
(184, NULL, NULL, NULL, 59, 'SAC', 0.00, 10.00, -10.00, 22, 2, 3),
(185, NULL, NULL, NULL, 59, 'SAC', 0.00, 2.00, -2.00, 50, 2, 3),
(186, NULL, NULL, NULL, 59, 'SAC', 8.00, 3.00, 5.00, 60, 2, 3),
(187, NULL, NULL, NULL, 60, 'SAC', 0.00, 0.00, 0.00, 50, 2, 3),
(188, NULL, NULL, NULL, 60, 'SAC', 0.00, 2.00, -2.00, 51, 2, 3),
(189, NULL, NULL, NULL, 61, 'SAC', 0.00, 2.00, -2.00, 50, 2, 3),
(190, NULL, NULL, NULL, 62, 'SAC', 0.00, 2.00, -2.00, 54, 2, 3),
(191, NULL, NULL, NULL, 63, 'SAC', 7.00, 2.00, 5.00, 68, 2, 3),
(192, NULL, NULL, NULL, 64, 'SAC', 0.00, 0.00, 0.00, 54, 2, 3),
(193, NULL, NULL, NULL, 65, 'SAC', 0.00, 2.00, -2.00, 46, 2, 3),
(194, NULL, NULL, NULL, 66, 'SAC', 0.00, 2.00, -2.00, 54, 2, 3),
(195, NULL, NULL, NULL, 67, 'SAC', 0.00, 0.00, 0.00, 50, 2, 3),
(196, NULL, NULL, NULL, 68, 'SAC', 0.00, 2.00, -2.00, 30, 2, 3),
(197, NULL, NULL, NULL, 68, 'SAC', 0.00, 2.00, -2.00, 39, 2, 3),
(198, NULL, NULL, NULL, 68, 'SAC', 0.00, 0.00, 0.00, 46, 2, 3),
(199, NULL, NULL, NULL, 68, 'SAC', 0.00, 0.00, 0.00, 54, 2, 3),
(200, NULL, NULL, NULL, 68, 'SAC', 11.00, 2.00, 9.00, 84, 2, 3),
(201, NULL, NULL, NULL, 69, 'SAC', 0.00, 2.00, -2.00, 38, 2, 3),
(202, NULL, NULL, NULL, 69, 'SAC', 0.00, 2.00, -2.00, 50, 2, 3),
(203, NULL, NULL, NULL, 69, 'SAC', 0.00, 0.00, 0.00, 51, 2, 3),
(204, NULL, NULL, NULL, 70, 'SAC', 3.00, 2.00, 1.00, 13, 2, 3),
(205, NULL, NULL, NULL, 70, 'SAC', 0.00, 2.00, 2.00, 27, 2, 3),
(206, NULL, NULL, NULL, 70, 'SAC', 0.00, 0.00, 0.00, 30, 2, 3),
(207, NULL, NULL, NULL, 70, 'SAC', 0.00, 0.00, 0.00, 38, 2, 3),
(208, NULL, NULL, NULL, 70, 'SAC', 0.00, 2.00, -2.00, 46, 2, 3),
(209, NULL, NULL, NULL, 70, 'SAC', 0.00, 2.00, -2.00, 51, 2, 3),
(210, NULL, NULL, NULL, 70, 'SAC', 10.00, 2.00, 8.00, 59, 2, 3),
(211, NULL, NULL, NULL, 70, 'SAC', 7.00, 2.00, 5.00, 72, 2, 3),
(212, NULL, NULL, NULL, 71, 'SAC', 0.00, 2.00, -2.00, 30, 2, 3),
(213, NULL, NULL, NULL, 71, 'SAC', 0.00, 2.00, -2.00, 44, 2, 3),
(214, NULL, NULL, NULL, 71, 'SAC', 0.00, 0.00, 0.00, 51, 2, 3),
(215, NULL, NULL, NULL, 71, 'SAC', 0.00, 2.00, -2.00, 54, 2, 3),
(216, NULL, NULL, NULL, NULL, 'IN1', 0.00, 20.00, 20.00, 99, 1, 2),
(217, NULL, NULL, NULL, NULL, 'IN1', 0.00, 20.00, 20.00, 100, 1, 2),
(218, NULL, NULL, NULL, 72, 'SAC', 0.00, 6.00, 6.00, 14, 2, 2),
(219, NULL, NULL, NULL, 72, 'SAC', 0.00, 0.00, 0.00, 15, 2, 2),
(220, NULL, NULL, NULL, 72, 'SAC', 0.00, 0.00, 0.00, 22, 2, 2),
(221, NULL, NULL, NULL, 72, 'SAC', 5.00, 1.00, 4.00, 23, 2, 2),
(222, NULL, NULL, NULL, 72, 'SAC', 0.00, 1.00, -1.00, 24, 2, 2),
(223, NULL, NULL, NULL, 72, 'SAC', 0.00, 1.00, 1.00, 25, 2, 2),
(224, NULL, NULL, NULL, 72, 'SAC', 0.00, 10.00, 10.00, 34, 2, 2),
(225, NULL, NULL, NULL, 72, 'SAC', 2.00, 2.00, 0.00, 36, 2, 2),
(226, NULL, NULL, NULL, 72, 'SAC', 0.00, 5.00, -5.00, 38, 2, 2),
(227, NULL, NULL, NULL, 72, 'SAC', 0.00, 1.00, 1.00, 42, 2, 2),
(228, NULL, NULL, NULL, 72, 'SAC', 0.00, 4.00, 4.00, 48, 2, 2),
(229, NULL, NULL, NULL, 72, 'SAC', 50.00, 4.00, 46.00, 57, 2, 2),
(230, NULL, NULL, NULL, 72, 'SAC', 20.00, 1.00, 19.00, 99, 2, 2),
(231, NULL, NULL, NULL, NULL, 'INA', 6.00, 194.00, 200.00, 14, 2, 2),
(232, NULL, NULL, NULL, NULL, 'INA', 200.00, 2.00, 202.00, 14, 2, 2),
(233, NULL, NULL, NULL, 73, 'SAC', 202.00, 15.00, 187.00, 14, 2, 2),
(234, NULL, NULL, NULL, 73, 'SAC', 0.00, 43.00, -43.00, 15, 2, 2),
(235, NULL, NULL, NULL, 73, 'SAC', 1.00, 10.00, -9.00, 25, 2, 2),
(236, NULL, NULL, NULL, 73, 'SAC', 4.00, 27.00, -23.00, 48, 2, 2),
(237, NULL, NULL, NULL, 73, 'SAC', 5.00, 2.00, 3.00, 60, 2, 2),
(238, NULL, NULL, NULL, 73, 'SAC', 150.00, 55.00, 95.00, 98, 2, 2),
(239, NULL, NULL, NULL, 74, 'SAC', 187.00, 6.00, 181.00, 14, 2, 2),
(240, NULL, NULL, NULL, 74, 'SAC', 0.00, 0.00, 0.00, 15, 2, 2),
(241, NULL, NULL, NULL, 74, 'SAC', 0.00, 8.00, -8.00, 22, 2, 2),
(242, NULL, NULL, NULL, 74, 'SAC', 4.00, 1.00, 3.00, 23, 2, 2),
(243, NULL, NULL, NULL, 74, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(244, NULL, NULL, NULL, 74, 'SAC', 0.00, 0.00, 0.00, 25, 2, 2),
(245, NULL, NULL, NULL, 74, 'SAC', 10.00, 10.00, 0.00, 34, 2, 2),
(246, NULL, NULL, NULL, 74, 'SAC', 0.00, 2.00, -2.00, 36, 2, 2),
(247, NULL, NULL, NULL, 74, 'SAC', 0.00, 0.00, 0.00, 38, 2, 2),
(248, NULL, NULL, NULL, 74, 'SAC', 1.00, 1.00, 0.00, 42, 2, 2),
(249, NULL, NULL, NULL, 74, 'SAC', 0.00, 0.00, 0.00, 48, 2, 2),
(250, NULL, NULL, NULL, 74, 'SAC', 46.00, 4.00, 42.00, 57, 2, 2),
(251, NULL, NULL, NULL, 74, 'SAC', 19.00, 1.00, 18.00, 99, 2, 2),
(252, NULL, NULL, NULL, 75, 'SAC', 95.00, 10.00, 85.00, 98, 2, 2),
(253, NULL, NULL, NULL, NULL, 'SAA', 2.00, 80.00, -78.00, 2, 2, 2),
(254, NULL, NULL, NULL, NULL, 'SAA', 0.00, 22.00, 22.00, 3, 2, 2),
(255, NULL, NULL, NULL, NULL, 'SAA', 2.00, 16.00, -14.00, 4, 2, 2),
(256, NULL, NULL, NULL, NULL, 'SAA', 1.00, 999995.00, -999994.00, 13, 2, 2),
(257, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 13, 2, 2),
(258, NULL, NULL, NULL, NULL, 'SAA', 181.00, 42.00, 139.00, 14, 2, 2),
(259, NULL, NULL, NULL, NULL, 'SAA', 0.00, 6.00, -6.00, 15, 2, 2),
(260, NULL, NULL, NULL, NULL, 'SAA', 0.00, 1000.00, 1000.00, 16, 2, 2),
(261, NULL, NULL, NULL, NULL, 'SAA', 2.00, 988.00, -986.00, 17, 2, 2),
(262, NULL, NULL, NULL, NULL, 'SAA', 2.00, 999996.00, -999994.00, 18, 2, 2),
(263, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 19, 2, 2),
(264, NULL, NULL, NULL, NULL, 'SAA', 0.00, 4.00, 4.00, 20, 2, 2),
(265, NULL, NULL, NULL, NULL, 'SAA', 4.00, 265.00, -261.00, 20, 2, 2),
(266, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 22, 2, 2),
(267, NULL, NULL, NULL, NULL, 'SAA', 3.00, 290.00, -287.00, 23, 2, 2),
(268, NULL, NULL, NULL, NULL, 'SAA', 0.00, 180.00, -180.00, 24, 2, 2),
(269, NULL, NULL, NULL, NULL, 'INA', 0.00, 316.00, 316.00, 25, 2, 2),
(270, NULL, NULL, NULL, NULL, 'SAA', 4.00, 47.00, -43.00, 26, 2, 2),
(271, NULL, NULL, NULL, NULL, 'SAA', 2.00, 18.00, -16.00, 27, 2, 2),
(272, NULL, NULL, NULL, NULL, 'SAA', 0.00, 98.00, 98.00, 28, 2, 2),
(273, NULL, NULL, NULL, NULL, 'SAA', 0.00, 47.00, 47.00, 29, 2, 2),
(274, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 30, 2, 2),
(275, NULL, NULL, NULL, NULL, 'SAA', 0.00, 18.00, 18.00, 31, 2, 2),
(276, NULL, NULL, NULL, NULL, 'SAA', 2.00, 8.00, -6.00, 32, 2, 2),
(277, NULL, NULL, NULL, NULL, 'SAA', 0.00, 50.00, 50.00, 33, 2, 2),
(278, NULL, NULL, NULL, NULL, 'INA', 0.00, 36.00, 36.00, 34, 2, 2),
(279, NULL, NULL, NULL, NULL, 'SAA', 0.00, 24.00, 24.00, 35, 2, 2),
(280, NULL, NULL, NULL, NULL, 'INA', 0.00, 32.00, 32.00, 19, 2, 2),
(281, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 23, 2, 2),
(282, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 24, 2, 2),
(283, NULL, NULL, NULL, NULL, 'SAA', 316.00, 12.00, 304.00, 25, 2, 2),
(284, NULL, NULL, NULL, NULL, 'SAA', 18.00, 1.00, 17.00, 31, 2, 2),
(285, NULL, NULL, NULL, NULL, 'SAA', 36.00, 5.00, 31.00, 34, 2, 2),
(286, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 36, 2, 2),
(287, NULL, NULL, NULL, NULL, 'SAA', 2.00, 18.00, -16.00, 37, 2, 2),
(288, NULL, NULL, NULL, NULL, 'INA', 0.00, 104.00, 104.00, 38, 2, 2),
(289, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 39, 2, 2),
(290, NULL, NULL, NULL, NULL, 'INA', 2.00, 11.00, 13.00, 40, 2, 2),
(291, NULL, NULL, NULL, NULL, 'SAA', 0.00, 9.00, 9.00, 41, 2, 2),
(292, NULL, NULL, NULL, NULL, 'INA', 0.00, 13.00, 13.00, 42, 2, 2),
(293, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 44, 2, 2),
(294, NULL, NULL, NULL, NULL, 'SAA', 0.00, 1.00, -1.00, 45, 2, 2),
(295, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 46, 2, 2),
(296, NULL, NULL, NULL, NULL, 'INA', 0.00, 397.00, 397.00, 48, 2, 2),
(297, NULL, NULL, NULL, NULL, 'INA', 0.00, 4.00, 4.00, 49, 2, 2),
(298, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 50, 2, 2),
(299, NULL, NULL, NULL, NULL, 'SAA', 0.00, 4.00, -4.00, 51, 2, 2),
(300, NULL, NULL, NULL, NULL, 'SAA', 0.00, 8.00, 8.00, 52, 2, 2),
(301, NULL, NULL, NULL, NULL, 'INA', 0.00, 39.00, 39.00, 53, 2, 2),
(302, NULL, NULL, NULL, NULL, 'SAA', 42.00, 11.00, 31.00, 57, 2, 2),
(303, NULL, NULL, NULL, NULL, 'SAA', 15.00, 14.00, 1.00, 58, 2, 2),
(304, NULL, NULL, NULL, NULL, 'SAA', 8.00, 5.00, 3.00, 59, 2, 2),
(305, NULL, NULL, NULL, NULL, 'SAA', 3.00, 1.00, 2.00, 60, 2, 2),
(306, NULL, NULL, NULL, NULL, 'SAA', 15.00, 15.00, 0.00, 61, 2, 2),
(307, NULL, NULL, NULL, NULL, 'SAA', 10.00, 10.00, 0.00, 62, 2, 2),
(308, NULL, NULL, NULL, NULL, 'INA', 10.00, 1.00, 11.00, 63, 2, 2),
(309, NULL, NULL, NULL, NULL, 'SAA', 10.00, 10.00, 0.00, 64, 2, 2),
(310, NULL, NULL, NULL, NULL, 'INA', 7.00, 4.00, 11.00, 65, 2, 2),
(311, NULL, NULL, NULL, NULL, 'SAA', 10.00, 10.00, 0.00, 66, 2, 2),
(312, NULL, NULL, NULL, NULL, 'SAA', 12.00, 12.00, 0.00, 67, 2, 2),
(313, NULL, NULL, NULL, NULL, 'SAA', 5.00, 5.00, 0.00, 68, 2, 2),
(314, NULL, NULL, NULL, NULL, 'SAA', 12.00, 12.00, 0.00, 69, 2, 2),
(315, NULL, NULL, NULL, NULL, 'SAA', 11.00, 11.00, 0.00, 71, 2, 2),
(316, NULL, NULL, NULL, NULL, 'SAA', 5.00, 5.00, 0.00, 72, 2, 2),
(317, NULL, NULL, NULL, NULL, 'SAA', 10.00, 10.00, 0.00, 73, 2, 2),
(318, NULL, NULL, NULL, NULL, 'SAA', 10.00, 10.00, 0.00, 74, 2, 2),
(319, NULL, NULL, NULL, NULL, 'SAA', 10.00, 10.00, 0.00, 75, 2, 2),
(320, NULL, NULL, NULL, NULL, 'SAA', 10.00, 10.00, 0.00, 76, 2, 2),
(321, NULL, NULL, NULL, NULL, 'SAA', 200.00, 36.00, 164.00, 77, 2, 2),
(322, NULL, NULL, NULL, NULL, 'SAA', 15.00, 15.00, 0.00, 78, 2, 2),
(323, NULL, NULL, NULL, NULL, 'SAA', 18.00, 8.00, 10.00, 99, 2, 2),
(324, NULL, NULL, NULL, NULL, 'SAA', 20.00, 10.00, 10.00, 100, 2, 2),
(325, NULL, NULL, NULL, NULL, 'IN1', 0.00, 19.50, 19.50, 101, 1, 2),
(326, NULL, NULL, NULL, NULL, 'IN1', 0.00, 0.00, 0.00, 102, 1, 2),
(327, NULL, NULL, NULL, NULL, 'INA', 0.00, 90.00, 90.00, 102, 2, 2),
(328, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 103, 1, 2),
(329, NULL, NULL, NULL, NULL, 'INA', 50.00, 39.00, 89.00, 79, 2, 2),
(330, NULL, NULL, NULL, NULL, 'INA', 7.00, 46.00, 53.00, 80, 2, 2),
(331, NULL, NULL, NULL, NULL, 'INA', 21.00, 41.00, 62.00, 81, 2, 2),
(332, NULL, NULL, NULL, NULL, 'SAA', 55.00, 16.00, 39.00, 82, 2, 2),
(333, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 83, 2, 2),
(334, NULL, NULL, NULL, NULL, 'INA', 9.00, 4.00, 13.00, 84, 2, 2),
(335, NULL, NULL, NULL, NULL, 'SAA', 5.00, 2.00, 3.00, 85, 2, 2),
(336, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 87, 2, 2),
(337, NULL, NULL, NULL, NULL, 'INA', 88.00, 63.00, 151.00, 88, 2, 2),
(338, NULL, NULL, NULL, NULL, 'INA', 0.00, 39.00, 39.00, 89, 2, 2),
(339, NULL, NULL, NULL, NULL, 'INA', 64.00, 39.00, 103.00, 90, 2, 2),
(340, NULL, NULL, NULL, NULL, 'INA', 95.00, 111.00, 206.00, 91, 2, 2),
(341, NULL, NULL, NULL, NULL, 'INA', 79.00, 67.00, 146.00, 92, 2, 2),
(342, NULL, NULL, NULL, NULL, 'SAA', 146.00, 61.00, 85.00, 93, 2, 2),
(343, NULL, NULL, NULL, NULL, 'INA', 0.00, 75.00, 75.00, 95, 2, 2),
(344, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 104, 1, 2),
(345, NULL, NULL, NULL, NULL, 'IN1', 0.00, 36.00, 36.00, 105, 1, 2),
(346, NULL, NULL, NULL, NULL, 'IN1', 0.00, 3.00, 3.00, 106, 1, 2),
(347, NULL, NULL, NULL, NULL, 'IN1', 0.00, 3.00, 3.00, 107, 1, 2),
(348, NULL, NULL, NULL, NULL, 'IN1', 0.00, 2.00, 2.00, 108, 1, 2),
(349, NULL, NULL, NULL, NULL, 'IN1', 0.00, 129.00, 129.00, 109, 1, 2),
(350, NULL, NULL, NULL, NULL, 'IN1', 0.00, 126.00, 126.00, 110, 1, 2),
(351, NULL, NULL, NULL, NULL, 'IN1', 0.00, 131.00, 131.00, 111, 1, 2),
(352, NULL, NULL, NULL, NULL, 'IN1', 0.00, 384.00, 384.00, 112, 1, 2),
(353, NULL, NULL, NULL, NULL, 'IN1', 0.00, 124.00, 124.00, 113, 1, 2),
(354, NULL, NULL, NULL, NULL, 'IN1', 0.00, 4.00, 4.00, 114, 1, 2),
(355, NULL, NULL, NULL, NULL, 'IN1', 0.00, 0.00, 0.00, 115, 1, 2),
(356, NULL, NULL, NULL, NULL, 'IN1', 0.00, 112.00, 112.00, 116, 1, 2),
(357, NULL, NULL, NULL, NULL, 'IN1', 0.00, 172.00, 172.00, 117, 1, 2),
(358, NULL, NULL, NULL, NULL, 'IN1', 0.00, 52.00, 52.00, 118, 1, 2),
(359, NULL, NULL, NULL, 76, 'SAC', 0.00, 3.00, -3.00, 50, 2, 2),
(360, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 15, 2, 2),
(361, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 73, 2, 2),
(362, NULL, NULL, NULL, 77, 'SAC', 0.00, 5.00, -5.00, 15, 2, 2),
(363, NULL, NULL, NULL, 77, 'SAC', 1.00, 1.00, 0.00, 73, 2, 2),
(364, NULL, NULL, NULL, NULL, 'INA', 0.00, 95.00, 95.00, 13, 2, 2),
(365, NULL, NULL, NULL, NULL, 'INA', 1000.00, 10.00, 1010.00, 16, 2, 2),
(366, NULL, NULL, NULL, NULL, 'INA', 85.00, 87.00, 172.00, 98, 2, 2),
(367, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 22, 2, 2),
(368, NULL, NULL, NULL, 78, 'SAC', 95.00, 50.00, 45.00, 13, 2, 2),
(369, NULL, NULL, NULL, 78, 'SAC', 1010.00, 10.00, 1000.00, 16, 2, 2),
(370, NULL, NULL, NULL, 79, 'SAC', 0.00, 0.00, 0.00, 15, 2, 2),
(371, NULL, NULL, NULL, 79, 'SAC', 2.00, 2.00, 0.00, 22, 2, 2),
(372, NULL, NULL, NULL, 79, 'SAC', 31.00, 1.00, 30.00, 57, 2, 2),
(373, NULL, NULL, NULL, 79, 'SAC', 172.00, 2.00, 170.00, 98, 2, 2),
(374, NULL, NULL, NULL, 80, 'SAC', 0.00, 1.00, -1.00, 44, 2, 2),
(375, NULL, NULL, NULL, 80, 'SAC', 0.00, 0.00, 0.00, 50, 2, 2),
(376, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 22, 2, 2),
(377, NULL, NULL, NULL, 81, 'SAC', 139.00, 3.00, 136.00, 14, 2, 2),
(378, NULL, NULL, NULL, 81, 'SAC', 0.00, 11.00, -11.00, 15, 2, 2),
(379, NULL, NULL, NULL, 81, 'SAC', 10.00, 6.00, 4.00, 22, 2, 2),
(380, NULL, NULL, NULL, 81, 'SAC', 104.00, 2.00, 102.00, 38, 2, 2),
(381, NULL, NULL, NULL, 81, 'SAC', 0.00, 1.00, -1.00, 50, 2, 2),
(382, NULL, NULL, NULL, 81, 'SAC', 170.00, 12.00, 158.00, 98, 2, 2),
(383, NULL, NULL, NULL, 81, 'SAC', 10.00, 3.00, 7.00, 99, 2, 2),
(384, NULL, NULL, NULL, NULL, 'INA', 0.00, 14.00, 14.00, 1, 2, 2),
(385, NULL, NULL, NULL, 82, 'SAC', 14.00, 14.00, 0.00, 1, 2, 2),
(386, NULL, NULL, NULL, 82, 'SAC', 136.00, 3.00, 133.00, 14, 2, 2),
(387, NULL, NULL, NULL, 82, 'SAC', 0.00, 0.00, 0.00, 15, 2, 2),
(388, NULL, NULL, NULL, 82, 'SAC', 32.00, 7.00, 25.00, 19, 2, 2),
(389, NULL, NULL, NULL, 82, 'SAC', 31.00, 3.00, 28.00, 34, 2, 2),
(390, NULL, NULL, NULL, 82, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(391, NULL, NULL, NULL, 82, 'SAC', 397.00, 2.00, 395.00, 48, 2, 2),
(392, NULL, NULL, NULL, NULL, 'INA', 0.00, 14.00, 14.00, 1, 2, 2),
(393, NULL, NULL, NULL, NULL, 'INA', 0.00, 7.00, 7.00, 15, 2, 2),
(394, NULL, NULL, NULL, NULL, 'INA', 25.00, 7.00, 32.00, 19, 2, 2),
(395, NULL, NULL, NULL, NULL, 'INA', 28.00, 3.00, 31.00, 34, 2, 2),
(396, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 44, 2, 2),
(397, NULL, NULL, NULL, NULL, 'INA', 395.00, 2.00, 397.00, 48, 2, 2),
(398, NULL, NULL, NULL, NULL, 'INA', 133.00, 3.00, 136.00, 14, 2, 2),
(399, NULL, NULL, NULL, 83, 'SAC', 14.00, 14.00, 0.00, 1, 2, 2),
(400, NULL, NULL, NULL, 83, 'SAC', 136.00, 3.00, 133.00, 14, 2, 2),
(401, NULL, NULL, NULL, 83, 'SAC', 7.00, 7.00, 0.00, 15, 2, 2),
(402, NULL, NULL, NULL, 83, 'SAC', 32.00, 7.00, 25.00, 19, 2, 2),
(403, NULL, NULL, NULL, 83, 'SAC', 31.00, 3.00, 28.00, 34, 2, 2),
(404, NULL, NULL, NULL, 83, 'SAC', 2.00, 2.00, 0.00, 44, 2, 2),
(405, NULL, NULL, NULL, 83, 'SAC', 397.00, 2.00, 395.00, 48, 2, 2),
(406, NULL, NULL, NULL, 83, 'SAC', 53.00, 7.00, 46.00, 80, 2, 2),
(407, NULL, NULL, NULL, 83, 'SAC', 85.00, 20.00, 65.00, 93, 2, 2),
(408, NULL, NULL, NULL, 84, 'SAC', 158.00, 1.00, 157.00, 98, 2, 2),
(409, NULL, NULL, NULL, 85, 'SAC', 0.00, 1.00, -1.00, 15, 2, 2),
(410, NULL, NULL, NULL, 85, 'SAC', 89.00, 1.00, 88.00, 79, 2, 2),
(411, NULL, NULL, NULL, 85, 'SAC', 146.00, 1.00, 145.00, 92, 2, 2),
(412, NULL, NULL, NULL, 85, 'SAC', 65.00, 1.00, 64.00, 93, 2, 2),
(413, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 15, 2, 2),
(414, NULL, NULL, NULL, NULL, 'INA', 88.00, 1.00, 89.00, 79, 2, 2),
(415, NULL, NULL, NULL, NULL, 'INA', 145.00, 1.00, 146.00, 92, 2, 2),
(416, NULL, NULL, NULL, NULL, 'INA', 64.00, 1.00, 65.00, 93, 2, 2),
(417, NULL, NULL, NULL, 86, 'SAC', 0.00, 6.00, -6.00, 15, 2, 2),
(418, NULL, NULL, NULL, 86, 'SAC', 0.00, 1.00, -1.00, 23, 2, 2),
(419, NULL, NULL, NULL, 86, 'SAC', 28.00, 2.00, 26.00, 34, 2, 2),
(420, NULL, NULL, NULL, 86, 'SAC', 13.00, 3.00, 10.00, 42, 2, 2),
(421, NULL, NULL, NULL, 86, 'SAC', 395.00, 1.00, 394.00, 48, 2, 2),
(422, NULL, NULL, NULL, 86, 'SAC', 30.00, 3.00, 27.00, 57, 2, 2),
(423, NULL, NULL, NULL, 86, 'SAC', 151.00, 1.00, 150.00, 88, 2, 2),
(424, NULL, NULL, NULL, 86, 'SAC', 39.00, 3.00, 36.00, 89, 2, 2),
(425, NULL, NULL, NULL, 86, 'SAC', 7.00, 1.00, 6.00, 99, 2, 2),
(426, NULL, NULL, NULL, 87, 'SAC', 27.00, 1.00, 26.00, 57, 2, 2),
(427, NULL, NULL, NULL, 88, 'SAC', 36.00, 1.00, 35.00, 89, 2, 2),
(428, NULL, NULL, NULL, 89, 'SAC', 25.00, 3.00, 22.00, 19, 2, 2),
(429, NULL, NULL, NULL, 89, 'SAC', 2.00, 2.00, 0.00, 60, 2, 2),
(430, NULL, NULL, NULL, 90, 'SAC', 0.00, 0.00, 0.00, 15, 2, 2),
(431, NULL, NULL, NULL, 90, 'SAC', 26.00, 2.00, 24.00, 57, 2, 2),
(432, NULL, NULL, NULL, 90, 'SAC', 157.00, 1.00, 156.00, 98, 2, 2),
(433, NULL, NULL, NULL, NULL, 'INA', 0.00, 7.00, 7.00, 60, 2, 2),
(434, NULL, NULL, NULL, 91, 'SAC', 133.00, 1.00, 132.00, 14, 2, 2),
(435, NULL, NULL, NULL, 91, 'SAC', 0.00, 4.00, -4.00, 15, 2, 2),
(436, NULL, NULL, NULL, 91, 'SAC', 0.00, 1.00, -1.00, 44, 2, 2),
(437, NULL, NULL, NULL, 91, 'SAC', 394.00, 1.00, 393.00, 48, 2, 2),
(438, NULL, NULL, NULL, 91, 'SAC', 0.00, 0.00, 0.00, 50, 2, 2),
(439, NULL, NULL, NULL, 91, 'SAC', 24.00, 1.00, 23.00, 57, 2, 2),
(440, NULL, NULL, NULL, 91, 'SAC', 7.00, 1.00, 6.00, 60, 2, 2),
(441, NULL, NULL, NULL, 91, 'SAC', 6.00, 1.00, 5.00, 99, 2, 2),
(442, NULL, NULL, NULL, 92, 'SAC', 13.00, 1.00, 12.00, 40, 2, 2),
(443, NULL, NULL, NULL, 92, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(444, NULL, NULL, NULL, 93, 'SAC', 132.00, 1.00, 131.00, 14, 2, 2),
(445, NULL, NULL, NULL, 93, 'SAC', 0.00, 0.00, 0.00, 15, 2, 2),
(446, NULL, NULL, NULL, 94, 'SAC', 22.00, 1.00, 21.00, 19, 2, 2),
(447, NULL, NULL, NULL, 94, 'SAC', 23.00, 1.00, 22.00, 57, 2, 2),
(448, NULL, NULL, NULL, 95, 'SAC', 156.00, 100.00, 56.00, 98, 2, 2),
(449, NULL, NULL, NULL, 96, 'SAC', 0.00, 1.00, -1.00, 15, 2, 2),
(450, NULL, NULL, NULL, 96, 'SAC', 22.00, 1.00, 21.00, 57, 2, 2),
(451, NULL, NULL, NULL, 96, 'SAC', 89.00, 1.00, 88.00, 79, 2, 2),
(452, NULL, NULL, NULL, 96, 'SAC', 62.00, 1.00, 61.00, 81, 2, 2),
(453, NULL, NULL, NULL, 97, 'SAC', 164.00, 1.00, 163.00, 77, 2, 2),
(454, NULL, NULL, NULL, 98, 'SAC', 21.00, 2.00, 19.00, 57, 2, 2),
(455, NULL, NULL, NULL, 99, 'SAC', 3.00, 1.00, 2.00, 85, 2, 2),
(456, NULL, NULL, NULL, 99, 'SAC', 206.00, 2.00, 204.00, 91, 2, 2),
(457, NULL, NULL, NULL, 100, 'SAC', 88.00, 1.00, 87.00, 79, 2, 2),
(458, NULL, NULL, NULL, 100, 'SAC', 146.00, 1.00, 145.00, 92, 2, 2),
(459, NULL, NULL, NULL, 101, 'SAC', 102.00, 1.00, 101.00, 38, 2, 2),
(460, NULL, NULL, NULL, 101, 'SAC', 0.00, 1.00, -1.00, 44, 2, 2),
(461, NULL, NULL, NULL, 101, 'SAC', 87.00, 1.00, 86.00, 79, 2, 2),
(462, NULL, NULL, NULL, 102, 'SAC', 19.00, 2.00, 17.00, 57, 2, 2),
(463, NULL, NULL, NULL, 102, 'SAC', 36.00, 1.00, 35.00, 105, 2, 2),
(464, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 50, 2, 2),
(465, NULL, NULL, NULL, NULL, 'INA', 56.00, 100.00, 156.00, 98, 2, 2),
(466, NULL, NULL, NULL, 103, 'SAC', 156.00, 100.00, 56.00, 98, 2, 2),
(467, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 119, 1, 2),
(468, NULL, NULL, NULL, NULL, 'IN1', 0.00, 3.00, 3.00, 120, 1, 2),
(469, NULL, NULL, NULL, 104, 'SAC', 0.00, 0.00, 0.00, 15, 2, 2),
(470, NULL, NULL, NULL, 104, 'SAC', 21.00, 15.00, 6.00, 19, 2, 2),
(471, NULL, NULL, NULL, 104, 'SAC', 0.00, 3.00, -3.00, 24, 2, 2),
(472, NULL, NULL, NULL, 104, 'SAC', 101.00, 8.00, 93.00, 38, 2, 2),
(473, NULL, NULL, NULL, 104, 'SAC', 393.00, 2.00, 391.00, 48, 2, 2),
(474, NULL, NULL, NULL, 104, 'SAC', 17.00, 15.00, 2.00, 57, 2, 2),
(475, NULL, NULL, NULL, 104, 'SAC', 56.00, 15.00, 41.00, 98, 2, 2),
(476, NULL, NULL, NULL, 104, 'SAC', 1.00, 1.00, 0.00, 119, 2, 2),
(477, NULL, NULL, NULL, 104, 'SAC', 3.00, 3.00, 0.00, 120, 2, 2),
(478, NULL, NULL, NULL, NULL, 'INA', 0.00, 15.00, 15.00, 15, 2, 2),
(479, NULL, NULL, NULL, NULL, 'INA', 6.00, 9.00, 15.00, 19, 2, 2),
(480, NULL, NULL, NULL, NULL, 'INA', 2.00, 13.00, 15.00, 57, 2, 2),
(481, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 121, 1, 2),
(482, NULL, NULL, NULL, NULL, 'SAA', 0.00, 9.00, 9.00, 43, 2, 2),
(483, NULL, NULL, NULL, NULL, 'INA', 9.00, 2.00, 11.00, 43, 2, 2),
(484, NULL, NULL, NULL, 105, 'SAC', 15.00, 15.00, 0.00, 15, 2, 2),
(485, NULL, NULL, NULL, 105, 'SAC', 15.00, 15.00, 0.00, 19, 2, 2),
(486, NULL, NULL, NULL, 105, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(487, NULL, NULL, NULL, 105, 'SAC', 93.00, 8.00, 85.00, 38, 2, 2),
(488, NULL, NULL, NULL, 105, 'SAC', 11.00, 3.00, 8.00, 43, 2, 2),
(489, NULL, NULL, NULL, 105, 'SAC', 391.00, 2.00, 389.00, 48, 2, 2),
(490, NULL, NULL, NULL, 105, 'SAC', 15.00, 15.00, 0.00, 57, 2, 2),
(491, NULL, NULL, NULL, 105, 'SAC', 41.00, 15.00, 26.00, 98, 2, 2),
(492, NULL, NULL, NULL, 105, 'SAC', 1.00, 1.00, 0.00, 121, 2, 2),
(493, NULL, NULL, NULL, 106, 'SAC', 26.00, 20.00, 6.00, 98, 2, 2),
(494, NULL, NULL, NULL, 107, 'SAC', 0.00, 20.00, -20.00, 15, 2, 2),
(495, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 24, 2, 2),
(496, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 26, 2, 2),
(497, NULL, NULL, NULL, NULL, 'INA', 6.00, 429.00, 435.00, 98, 2, 2),
(498, NULL, NULL, NULL, NULL, 'SAA', 435.00, 6.00, 429.00, 98, 2, 2),
(499, NULL, NULL, NULL, NULL, 'INA', 1000.00, 20.00, 1020.00, 16, 2, 2),
(500, NULL, NULL, NULL, 108, 'SAC', 45.00, 4.00, 41.00, 13, 2, 2),
(501, NULL, NULL, NULL, 108, 'SAC', 131.00, 2.00, 129.00, 14, 2, 2),
(502, NULL, NULL, NULL, 108, 'SAC', 0.00, 0.00, 0.00, 15, 2, 2),
(503, NULL, NULL, NULL, 108, 'SAC', 1020.00, 2.00, 1018.00, 16, 2, 2),
(504, NULL, NULL, NULL, 108, 'SAC', 2.00, 3.00, -1.00, 24, 2, 2),
(505, NULL, NULL, NULL, 108, 'SAC', 304.00, 2.00, 302.00, 25, 2, 2),
(506, NULL, NULL, NULL, 108, 'SAC', 26.00, 10.00, 16.00, 34, 2, 2),
(507, NULL, NULL, NULL, 108, 'SAC', 6.00, 1.00, 5.00, 60, 2, 2),
(508, NULL, NULL, NULL, 108, 'SAC', 11.00, 5.00, 6.00, 63, 2, 2),
(509, NULL, NULL, NULL, 108, 'SAC', 11.00, 5.00, 6.00, 65, 2, 2),
(510, NULL, NULL, NULL, 108, 'SAC', 429.00, 20.00, 409.00, 98, 2, 2),
(511, NULL, NULL, NULL, 108, 'SAC', 5.00, 2.00, 3.00, 99, 2, 2),
(512, NULL, NULL, NULL, NULL, 'INA', 0.00, 50.00, 50.00, 15, 2, 2),
(513, NULL, NULL, NULL, NULL, 'INA', 0.00, 20.00, 20.00, 57, 2, 2),
(514, NULL, NULL, NULL, NULL, 'INA', 4.00, 229.00, 233.00, 22, 2, 2),
(515, NULL, NULL, NULL, 109, 'SAC', 41.00, 10.00, 31.00, 13, 2, 2),
(516, NULL, NULL, NULL, 109, 'SAC', 50.00, 10.00, 40.00, 15, 2, 2),
(517, NULL, NULL, NULL, 109, 'SAC', 1018.00, 10.00, 1008.00, 16, 2, 2),
(518, NULL, NULL, NULL, 109, 'SAC', 233.00, 5.00, 228.00, 22, 2, 2),
(519, NULL, NULL, NULL, 109, 'SAC', 24.00, 5.00, 19.00, 35, 2, 2),
(520, NULL, NULL, NULL, 109, 'SAC', 20.00, 5.00, 15.00, 57, 2, 2),
(521, NULL, NULL, NULL, 109, 'SAC', 409.00, 10.00, 399.00, 98, 2, 2),
(522, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 18, 2, 2),
(523, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 39, 2, 2),
(524, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 37, 2, 2),
(525, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 45, 2, 2),
(526, NULL, NULL, NULL, 110, 'SAC', 31.00, 2.00, 29.00, 13, 2, 2),
(527, NULL, NULL, NULL, 110, 'SAC', 40.00, 6.00, 34.00, 15, 2, 2),
(528, NULL, NULL, NULL, 110, 'SAC', 1008.00, 2.00, 1006.00, 16, 2, 2),
(529, NULL, NULL, NULL, 110, 'SAC', 0.00, 2.00, -2.00, 18, 2, 2),
(530, NULL, NULL, NULL, 110, 'SAC', 16.00, 1.00, 15.00, 34, 2, 2),
(531, NULL, NULL, NULL, 110, 'SAC', 19.00, 4.00, 15.00, 35, 2, 2),
(532, NULL, NULL, NULL, 110, 'SAC', 0.00, 2.00, -2.00, 37, 2, 2),
(533, NULL, NULL, NULL, 110, 'SAC', 1.00, 2.00, -1.00, 39, 2, 2),
(534, NULL, NULL, NULL, 110, 'SAC', 0.00, 2.00, -2.00, 45, 2, 2),
(535, NULL, NULL, NULL, 110, 'SAC', 389.00, 3.00, 386.00, 48, 2, 2),
(536, NULL, NULL, NULL, 110, 'SAC', 3.00, 1.00, 2.00, 59, 2, 2),
(537, NULL, NULL, NULL, 110, 'SAC', 399.00, 6.00, 393.00, 98, 2, 2),
(538, NULL, NULL, NULL, NULL, 'SAA', 34.00, 11.00, 23.00, 15, 2, 2),
(539, NULL, NULL, NULL, NULL, 'SAA', 52.00, 6.00, 46.00, 118, 2, 2),
(540, NULL, NULL, NULL, NULL, 'INA', 129.00, 14.00, 143.00, 14, 2, 2),
(541, NULL, NULL, NULL, NULL, 'INA', 1006.00, 7.00, 1013.00, 16, 2, 2),
(542, NULL, NULL, NULL, NULL, 'SAA', 386.00, 3.00, 383.00, 48, 2, 2),
(543, NULL, NULL, NULL, NULL, 'SAA', 4.00, 8.00, -4.00, 49, 2, 2),
(544, NULL, NULL, NULL, NULL, 'SAA', 15.00, 9.00, 6.00, 35, 2, 2),
(545, NULL, NULL, NULL, NULL, 'SAA', 6.00, 2.00, 4.00, 35, 2, 2),
(546, NULL, NULL, NULL, NULL, 'SAA', 15.00, 20.00, -5.00, 34, 2, 2),
(547, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 34, 2, 2),
(548, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 18, 2, 2),
(549, NULL, NULL, NULL, NULL, 'INA', 85.00, 4.00, 89.00, 38, 2, 2),
(550, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 36, 2, 2),
(551, NULL, NULL, NULL, NULL, 'SAA', 302.00, 20.00, 282.00, 25, 2, 2),
(552, NULL, NULL, NULL, NULL, 'SAA', 393.00, 153.00, 240.00, 98, 2, 2),
(553, NULL, NULL, NULL, NULL, 'INA', 240.00, 12.00, 252.00, 98, 2, 2),
(554, NULL, NULL, NULL, NULL, 'INA', 0.00, 25.00, 25.00, 1, 2, 2),
(555, NULL, NULL, NULL, NULL, 'INA', 29.00, 18.00, 47.00, 13, 2, 2),
(556, NULL, NULL, NULL, NULL, 'INA', 3.00, 14.00, 17.00, 99, 2, 2),
(557, NULL, NULL, NULL, NULL, 'SAA', 10.00, 4.00, 6.00, 100, 2, 2),
(558, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 44, 2, 2),
(559, NULL, NULL, NULL, NULL, 'SAA', 0.00, 18.00, -18.00, 46, 2, 2),
(560, NULL, NULL, NULL, NULL, 'INA', 46.00, 93.00, 139.00, 80, 2, 2),
(561, NULL, NULL, NULL, NULL, 'INA', 61.00, 36.00, 97.00, 81, 2, 2),
(562, NULL, NULL, NULL, NULL, 'SAA', 86.00, 27.00, 59.00, 79, 2, 2),
(563, NULL, NULL, NULL, NULL, 'INA', 35.00, 34.00, 69.00, 89, 2, 2),
(564, NULL, NULL, NULL, NULL, 'SAA', 75.00, 18.00, 57.00, 95, 2, 2),
(565, NULL, NULL, NULL, NULL, 'SAA', 145.00, 18.00, 127.00, 92, 2, 2),
(566, NULL, NULL, NULL, NULL, 'INA', 204.00, 32.00, 236.00, 91, 2, 2),
(567, NULL, NULL, NULL, NULL, 'SAA', 65.00, 38.00, 27.00, 93, 2, 2),
(568, NULL, NULL, NULL, NULL, 'SAA', 103.00, 4.00, 99.00, 90, 2, 2),
(569, NULL, NULL, NULL, NULL, 'SAA', 150.00, 11.00, 139.00, 88, 2, 2),
(570, NULL, NULL, NULL, NULL, 'SAA', 39.00, 4.00, 35.00, 82, 2, 2),
(571, NULL, NULL, NULL, NULL, 'SAA', 13.00, 5.00, 8.00, 84, 2, 2),
(572, NULL, NULL, NULL, NULL, 'SAA', 2.00, 2.00, 0.00, 85, 2, 2),
(573, NULL, NULL, NULL, NULL, 'INA', 3.00, 1.00, 4.00, 106, 2, 2),
(574, NULL, NULL, NULL, NULL, 'SAA', 4.00, 1.00, 3.00, 106, 2, 2),
(575, NULL, NULL, NULL, NULL, 'SAA', 3.00, 1.00, 2.00, 106, 2, 2),
(576, NULL, NULL, NULL, NULL, 'SAA', 3.00, 1.00, 2.00, 107, 2, 2),
(577, NULL, NULL, NULL, NULL, 'INA', 15.00, 27.00, 42.00, 57, 2, 2),
(578, NULL, NULL, NULL, NULL, 'INA', 1.00, 9.00, 10.00, 58, 2, 2),
(579, NULL, NULL, NULL, 111, 'SAC', 10.00, 5.00, 5.00, 42, 2, 2),
(580, NULL, NULL, NULL, 111, 'SAC', 42.00, 3.00, 39.00, 57, 2, 2),
(581, NULL, NULL, NULL, NULL, 'INA', 5.00, 1.00, 6.00, 42, 2, 2),
(582, NULL, NULL, NULL, NULL, 'INA', 39.00, 3.00, 42.00, 57, 2, 2),
(583, NULL, NULL, NULL, 112, 'SAC', 6.00, 5.00, 1.00, 42, 2, 2),
(584, NULL, NULL, NULL, 112, 'SAC', 42.00, 3.00, 39.00, 57, 2, 2),
(585, NULL, NULL, NULL, NULL, 'IN1', 0.00, 20.00, 20.00, 122, 1, 2),
(586, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 123, 1, 2),
(587, NULL, NULL, NULL, NULL, 'INA', 252.00, 20.00, 272.00, 98, 2, 2),
(588, NULL, NULL, NULL, NULL, 'INA', 10.00, 0.00, 10.00, 123, 2, 2),
(589, NULL, NULL, NULL, NULL, 'SAA', 272.00, 20.00, 252.00, 98, 2, 2),
(590, NULL, NULL, NULL, 113, 'SAC', 228.00, 8.00, 220.00, 22, 2, 2),
(591, NULL, NULL, NULL, 113, 'SAC', 383.00, 7.00, 376.00, 48, 2, 2),
(592, NULL, NULL, NULL, 113, 'SAC', 6.00, 3.00, 3.00, 63, 2, 2),
(593, NULL, NULL, NULL, 113, 'SAC', 6.00, 1.00, 5.00, 65, 2, 2),
(594, NULL, NULL, NULL, 113, 'SAC', 252.00, 20.00, 232.00, 98, 2, 2),
(595, NULL, NULL, NULL, 113, 'SAC', 20.00, 9.00, 11.00, 122, 2, 2),
(596, NULL, NULL, NULL, 113, 'SAC', 10.00, 1.00, 9.00, 123, 2, 2),
(597, NULL, NULL, NULL, NULL, 'INA', 0.00, 51.00, 51.00, 19, 2, 2),
(598, NULL, NULL, NULL, 114, 'SAC', 23.00, 20.00, 3.00, 15, 2, 2),
(599, NULL, NULL, NULL, 114, 'SAC', 51.00, 20.00, 31.00, 19, 2, 2),
(600, NULL, NULL, NULL, 114, 'SAC', 282.00, 150.00, 132.00, 25, 2, 2),
(601, NULL, NULL, NULL, 115, 'SAC', 376.00, 150.00, 226.00, 48, 2, 2),
(602, NULL, NULL, NULL, NULL, 'INA', 3.00, 150.00, 153.00, 15, 2, 2),
(603, NULL, NULL, NULL, 116, 'SAC', 153.00, 150.00, 3.00, 15, 2, 2),
(604, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 94, 2, 2),
(605, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 85, 2, 2),
(606, NULL, NULL, NULL, NULL, 'INA', 127.00, 2.00, 129.00, 92, 2, 2),
(607, NULL, NULL, NULL, NULL, 'INA', 236.00, 1.00, 237.00, 91, 2, 2),
(608, NULL, NULL, NULL, NULL, 'SAA', 50.00, 2.00, 48.00, 97, 2, 2),
(609, NULL, NULL, NULL, NULL, 'INA', 139.00, 1.00, 140.00, 80, 2, 2),
(610, NULL, NULL, NULL, NULL, 'INA', 11.00, 1.00, 12.00, 122, 2, 2),
(611, NULL, NULL, NULL, NULL, 'SAA', 31.00, 21.00, 10.00, 19, 2, 2),
(612, NULL, NULL, NULL, NULL, 'IN1', 0.00, 8.00, 8.00, 124, 1, 2),
(613, NULL, NULL, NULL, NULL, 'IN1', 0.00, 13.00, 13.00, 125, 1, 2),
(614, NULL, NULL, NULL, NULL, 'IN1', 0.00, 2.00, 2.00, 126, 1, 2),
(615, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 127, 1, 2),
(616, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 128, 1, 2),
(617, NULL, NULL, NULL, NULL, 'IN1', 0.00, 2.00, 2.00, 129, 1, 2),
(618, NULL, NULL, NULL, NULL, 'IN1', 0.00, 2.00, 2.00, 130, 1, 2),
(619, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 131, 1, 2),
(620, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 45, 2, 2),
(621, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 47, 2, 2),
(622, NULL, NULL, NULL, 117, 'SAC', 0.00, 1.00, -1.00, 45, 2, 2),
(623, NULL, NULL, NULL, 117, 'SAC', 1.00, 1.00, 0.00, 47, 2, 2),
(624, NULL, NULL, NULL, 117, 'SAC', 129.00, 1.00, 128.00, 92, 2, 2),
(625, NULL, NULL, NULL, 118, 'SAC', 47.00, 1.00, 46.00, 13, 2, 2),
(626, NULL, NULL, NULL, 118, 'SAC', 1013.00, 1.00, 1012.00, 16, 2, 2),
(627, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 73, 2, 2),
(628, NULL, NULL, NULL, NULL, 'SAA', 2.00, 2.00, 0.00, 73, 2, 2),
(629, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 39, 2, 2),
(630, NULL, NULL, NULL, 119, 'SAC', 0.00, 1.00, -1.00, 39, 2, 2),
(631, NULL, NULL, NULL, 119, 'SAC', 59.00, 1.00, 58.00, 79, 2, 2),
(632, NULL, NULL, NULL, 120, 'SAC', 35.00, 1.00, 34.00, 82, 2, 2),
(633, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 132, 1, 2),
(634, NULL, NULL, NULL, 121, 'SAC', 46.00, 1.00, 45.00, 13, 2, 2),
(635, NULL, NULL, NULL, 121, 'SAC', 1.00, 1.00, 0.00, 132, 2, 2),
(636, NULL, NULL, NULL, NULL, 'INA', 45.00, 1.00, 46.00, 13, 2, 2),
(637, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 132, 2, 2),
(638, NULL, NULL, NULL, 122, 'SAC', 46.00, 1.00, 45.00, 13, 2, 2),
(639, NULL, NULL, NULL, 122, 'SAC', 1.00, 1.00, 0.00, 132, 2, 2),
(640, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 37, 2, 2),
(641, NULL, NULL, NULL, 123, 'SAC', 0.00, 1.00, -1.00, 37, 2, 2),
(642, NULL, NULL, NULL, 123, 'SAC', 27.00, 1.00, 26.00, 93, 2, 2),
(643, NULL, NULL, NULL, 124, 'SAC', 3.00, 1.00, 2.00, 15, 2, 2),
(644, NULL, NULL, NULL, 124, 'SAC', 0.00, 1.00, -1.00, 34, 2, 2),
(645, NULL, NULL, NULL, 124, 'SAC', 58.00, 1.00, 57.00, 79, 2, 2),
(646, NULL, NULL, NULL, 124, 'SAC', 97.00, 1.00, 96.00, 81, 2, 2),
(647, NULL, NULL, NULL, 124, 'SAC', 5.00, 1.00, 4.00, 87, 2, 2),
(648, NULL, NULL, NULL, 124, 'SAC', 128.00, 1.00, 127.00, 92, 2, 2),
(649, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 20, 2, 2),
(650, NULL, NULL, NULL, 125, 'SAC', 132.00, 2.00, 130.00, 25, 2, 2),
(651, NULL, NULL, NULL, 125, 'SAC', 226.00, 5.00, 221.00, 48, 2, 2),
(652, NULL, NULL, NULL, 126, 'SAC', 0.00, 160.00, -160.00, 20, 2, 2),
(653, NULL, NULL, NULL, NULL, 'INA', 0.00, 4.00, 4.00, 64, 2, 2),
(654, NULL, NULL, NULL, 127, 'SAC', 3.00, 1.00, 2.00, 63, 2, 2),
(655, NULL, NULL, NULL, NULL, 'IN1', 0.00, 50.00, 50.00, 133, 1, 2),
(656, NULL, NULL, NULL, 128, 'SAC', 2.00, 2.00, 0.00, 15, 2, 2),
(657, NULL, NULL, NULL, 128, 'SAC', 0.00, 1.00, -1.00, 18, 2, 2),
(658, NULL, NULL, NULL, 128, 'SAC', 220.00, 1.00, 219.00, 22, 2, 2),
(659, NULL, NULL, NULL, 128, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(660, NULL, NULL, NULL, 128, 'SAC', 89.00, 1.00, 88.00, 38, 2, 2),
(661, NULL, NULL, NULL, 128, 'SAC', 0.00, 0.00, 0.00, 49, 2, 2),
(662, NULL, NULL, NULL, 128, 'SAC', 39.00, 1.00, 38.00, 57, 2, 2),
(663, NULL, NULL, NULL, 128, 'SAC', 2.00, 1.00, 1.00, 59, 2, 2),
(664, NULL, NULL, NULL, 128, 'SAC', 50.00, 1.00, 49.00, 133, 2, 2),
(665, NULL, NULL, NULL, NULL, 'IN1', 0.00, 40.00, 40.00, 134, 1, 2),
(666, NULL, NULL, NULL, NULL, 'IN1', 0.00, 5.00, 5.00, 135, 1, 2),
(667, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 136, 1, 2),
(668, NULL, NULL, NULL, 129, 'SAC', 0.00, 0.00, 0.00, 18, 2, 2),
(669, NULL, NULL, NULL, 129, 'SAC', 0.00, 1.00, -1.00, 34, 2, 2),
(670, NULL, NULL, NULL, 129, 'SAC', 0.00, 0.00, 0.00, 37, 2, 2),
(671, NULL, NULL, NULL, 129, 'SAC', 0.00, 0.00, 0.00, 39, 2, 2),
(672, NULL, NULL, NULL, 129, 'SAC', 1.00, 1.00, 0.00, 42, 2, 2),
(673, NULL, NULL, NULL, 129, 'SAC', 0.00, 1.00, -1.00, 49, 2, 2),
(674, NULL, NULL, NULL, 129, 'SAC', 1.00, 1.00, 0.00, 59, 2, 2),
(675, NULL, NULL, NULL, 129, 'SAC', 49.00, 1.00, 48.00, 133, 2, 2),
(676, NULL, NULL, NULL, 129, 'SAC', 40.00, 1.00, 39.00, 134, 2, 2),
(677, NULL, NULL, NULL, 129, 'SAC', 5.00, 1.00, 4.00, 135, 2, 2),
(678, NULL, NULL, NULL, 129, 'SAC', 10.00, 1.00, 9.00, 136, 2, 2),
(679, NULL, NULL, NULL, NULL, 'IN1', 0.00, 3.00, 3.00, 137, 1, 2),
(680, NULL, NULL, NULL, NULL, 'IN1', 0.00, 3.00, 3.00, 138, 1, 2),
(681, NULL, NULL, NULL, 130, 'SAC', 219.00, 7.00, 212.00, 22, 2, 2),
(682, NULL, NULL, NULL, 130, 'SAC', 0.00, 0.00, 0.00, 54, 2, 2),
(683, NULL, NULL, NULL, 130, 'SAC', 17.00, 2.00, 15.00, 99, 2, 2),
(684, NULL, NULL, NULL, 130, 'SAC', 8.00, 8.00, 0.00, 124, 2, 2),
(685, NULL, NULL, NULL, 130, 'SAC', 13.00, 13.00, 0.00, 125, 2, 2),
(686, NULL, NULL, NULL, 130, 'SAC', 2.00, 2.00, 0.00, 126, 2, 2),
(687, NULL, NULL, NULL, 130, 'SAC', 1.00, 1.00, 0.00, 127, 2, 2),
(688, NULL, NULL, NULL, 130, 'SAC', 3.00, 3.00, 0.00, 137, 2, 2),
(689, NULL, NULL, NULL, 130, 'SAC', 3.00, 3.00, 0.00, 138, 2, 2),
(690, NULL, NULL, NULL, 131, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(691, NULL, NULL, NULL, 131, 'SAC', 48.00, 2.00, 46.00, 133, 2, 2),
(692, NULL, NULL, NULL, 131, 'SAC', 39.00, 1.00, 38.00, 134, 2, 2),
(693, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 62, 2, 2),
(694, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 139, 1, 2),
(695, NULL, NULL, NULL, 132, 'SAC', 1.00, 1.00, 0.00, 62, 2, 2),
(696, NULL, NULL, NULL, 132, 'SAC', 1.00, 1.00, 0.00, 139, 2, 2),
(697, NULL, NULL, NULL, 133, 'SAC', 10.00, 10.00, 0.00, 128, 2, 2),
(698, NULL, NULL, NULL, 133, 'SAC', 2.00, 2.00, 0.00, 129, 2, 2),
(699, NULL, NULL, NULL, 133, 'SAC', 2.00, 1.00, 1.00, 130, 2, 2),
(700, NULL, NULL, NULL, 133, 'SAC', 10.00, 2.00, 8.00, 131, 2, 2),
(701, NULL, NULL, NULL, 134, 'SAC', 143.00, 1.00, 142.00, 14, 2, 2),
(702, NULL, NULL, NULL, 134, 'SAC', 212.00, 1.00, 211.00, 22, 2, 2),
(703, NULL, NULL, NULL, 134, 'SAC', 221.00, 1.00, 220.00, 48, 2, 2),
(704, NULL, NULL, NULL, 134, 'SAC', 8.00, 1.00, 7.00, 131, 2, 2),
(705, NULL, NULL, NULL, 134, 'SAC', 46.00, 3.00, 43.00, 133, 2, 2),
(706, NULL, NULL, NULL, 134, 'SAC', 38.00, 1.00, 37.00, 134, 2, 2),
(707, NULL, NULL, NULL, 135, 'SAC', 43.00, 2.00, 41.00, 133, 2, 2),
(708, NULL, NULL, NULL, 135, 'SAC', 37.00, 1.00, 36.00, 134, 2, 2),
(709, NULL, NULL, NULL, 136, 'SAC', 142.00, 1.00, 141.00, 14, 2, 2),
(710, NULL, NULL, NULL, 136, 'SAC', 7.00, 1.00, 6.00, 131, 2, 2),
(711, NULL, NULL, NULL, 136, 'SAC', 41.00, 1.00, 40.00, 133, 2, 2),
(712, NULL, NULL, NULL, 136, 'SAC', 36.00, 2.00, 34.00, 134, 2, 2),
(713, NULL, NULL, NULL, 137, 'SAC', 5.00, 1.00, 4.00, 65, 2, 2),
(714, NULL, NULL, NULL, 137, 'SAC', 6.00, 1.00, 5.00, 100, 2, 2),
(715, NULL, NULL, NULL, 138, 'SAC', 4.00, 1.00, 3.00, 65, 2, 2),
(716, NULL, NULL, NULL, 138, 'SAC', 5.00, 1.00, 4.00, 100, 2, 2),
(717, NULL, NULL, NULL, NULL, 'INA', 0.00, 4.00, 4.00, 125, 2, 2),
(718, NULL, NULL, NULL, NULL, 'SAA', 4.00, 4.00, 0.00, 125, 2, 2),
(719, NULL, NULL, NULL, NULL, 'IN1', 0.00, 4.00, 4.00, 140, 1, 2),
(720, NULL, NULL, NULL, NULL, 'IN1', 0.00, 2.00, 2.00, 141, 1, 2),
(721, NULL, NULL, NULL, 139, 'SAC', 211.00, 1.00, 210.00, 22, 2, 2),
(722, NULL, NULL, NULL, 139, 'SAC', 4.00, 2.00, 2.00, 135, 2, 2),
(723, NULL, NULL, NULL, 139, 'SAC', 4.00, 4.00, 0.00, 140, 2, 2),
(724, NULL, NULL, NULL, 139, 'SAC', 2.00, 2.00, 0.00, 141, 2, 2),
(725, NULL, NULL, NULL, 140, 'SAC', 38.00, 1.00, 37.00, 57, 2, 2),
(726, NULL, NULL, NULL, 140, 'SAC', 10.00, 2.00, 8.00, 58, 2, 2),
(727, NULL, NULL, NULL, 141, 'SAC', 210.00, 1.00, 209.00, 22, 2, 2),
(728, NULL, NULL, NULL, 141, 'SAC', 0.00, 2.00, -2.00, 34, 2, 2),
(729, NULL, NULL, NULL, 141, 'SAC', 220.00, 1.00, 219.00, 48, 2, 2),
(730, NULL, NULL, NULL, 141, 'SAC', 2.00, 1.00, 1.00, 63, 2, 2),
(731, NULL, NULL, NULL, 141, 'SAC', 40.00, 3.00, 37.00, 133, 2, 2),
(732, NULL, NULL, NULL, 141, 'SAC', 34.00, 4.00, 30.00, 134, 2, 2),
(733, NULL, NULL, NULL, NULL, 'INA', 0.00, 4.00, 4.00, 125, 2, 2),
(734, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 59, 2, 2),
(735, NULL, NULL, NULL, 142, 'SAC', 0.00, 1.00, -1.00, 18, 2, 2),
(736, NULL, NULL, NULL, 142, 'SAC', 219.00, 1.00, 218.00, 48, 2, 2),
(737, NULL, NULL, NULL, 142, 'SAC', 0.00, 1.00, -1.00, 54, 2, 2),
(738, NULL, NULL, NULL, 142, 'SAC', 8.00, 1.00, 7.00, 58, 2, 2),
(739, NULL, NULL, NULL, 142, 'SAC', 1.00, 1.00, 0.00, 59, 2, 2),
(740, NULL, NULL, NULL, 142, 'SAC', 232.00, 4.00, 228.00, 98, 2, 2),
(741, NULL, NULL, NULL, 142, 'SAC', 4.00, 4.00, 0.00, 125, 2, 2),
(742, NULL, NULL, NULL, 142, 'SAC', 6.00, 1.00, 5.00, 131, 2, 2),
(743, NULL, NULL, NULL, NULL, 'INA', 209.00, 10.00, 219.00, 22, 2, 2),
(744, NULL, NULL, NULL, NULL, 'INA', 218.00, 7.00, 225.00, 48, 2, 2),
(745, NULL, NULL, NULL, NULL, 'INA', 1.00, 4.00, 5.00, 63, 2, 2),
(746, NULL, NULL, NULL, NULL, 'INA', 3.00, 1.00, 4.00, 65, 2, 2),
(747, NULL, NULL, NULL, NULL, 'INA', 228.00, 20.00, 248.00, 98, 2, 2),
(748, NULL, NULL, NULL, NULL, 'INA', 12.00, 10.00, 22.00, 122, 2, 2),
(749, NULL, NULL, NULL, NULL, 'INA', 9.00, 1.00, 10.00, 123, 2, 2),
(750, NULL, NULL, NULL, 143, 'SAC', 219.00, 10.00, 209.00, 22, 2, 2),
(751, NULL, NULL, NULL, 143, 'SAC', 225.00, 7.00, 218.00, 48, 2, 2),
(752, NULL, NULL, NULL, 143, 'SAC', 5.00, 4.00, 1.00, 63, 2, 2),
(753, NULL, NULL, NULL, 143, 'SAC', 4.00, 1.00, 3.00, 65, 2, 2),
(754, NULL, NULL, NULL, 143, 'SAC', 248.00, 28.00, 220.00, 98, 2, 2),
(755, NULL, NULL, NULL, 143, 'SAC', 22.00, 10.00, 12.00, 122, 2, 2),
(756, NULL, NULL, NULL, 143, 'SAC', 10.00, 1.00, 9.00, 123, 2, 2),
(757, NULL, NULL, NULL, 144, 'SAC', 45.00, 20.00, 25.00, 13, 2, 2),
(758, NULL, NULL, NULL, 144, 'SAC', 209.00, 10.00, 199.00, 22, 2, 2),
(759, NULL, NULL, NULL, 144, 'SAC', 88.00, 10.00, 78.00, 38, 2, 2),
(760, NULL, NULL, NULL, 144, 'SAC', 0.00, 10.00, -10.00, 42, 2, 2),
(761, NULL, NULL, NULL, 144, 'SAC', 0.00, 10.00, -10.00, 44, 2, 2),
(762, NULL, NULL, NULL, NULL, 'INA', 5.00, 5.00, 10.00, 60, 2, 2),
(763, NULL, NULL, NULL, NULL, 'INA', 50.00, 3.00, 53.00, 33, 2, 2),
(764, NULL, NULL, NULL, 145, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(765, NULL, NULL, NULL, 145, 'SAC', 53.00, 3.00, 50.00, 33, 2, 2),
(766, NULL, NULL, NULL, 145, 'SAC', 78.00, 10.00, 68.00, 38, 2, 2),
(767, NULL, NULL, NULL, 145, 'SAC', 0.00, 0.00, 0.00, 42, 2, 2),
(768, NULL, NULL, NULL, 145, 'SAC', 10.00, 10.00, 0.00, 60, 2, 2),
(769, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 125, 2, 2);
INSERT INTO `movimiento` (`mov_id_movimiento`, `ind_id_ingreso_detalle`, `sad_id_salida_detalle`, `ing_id_ingreso`, `sal_id_salida`, `mov_tipo`, `mov_cantidad_anterior`, `mov_cantidad_entrante`, `mov_cantidad_actual`, `pro_id_producto`, `est_id_estado`, `usu_id_usuario`) VALUES
(770, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 140, 2, 2),
(771, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 137, 2, 2),
(772, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 60, 2, 2),
(773, NULL, NULL, NULL, NULL, 'INA', 0.00, 6.00, 6.00, 59, 2, 2),
(774, NULL, NULL, NULL, 146, 'SAC', 0.00, 0.00, 0.00, 18, 2, 2),
(775, NULL, NULL, NULL, 146, 'SAC', 0.00, 1.00, -1.00, 24, 2, 2),
(776, NULL, NULL, NULL, 146, 'SAC', 0.00, 1.00, -1.00, 26, 2, 2),
(777, NULL, NULL, NULL, 146, 'SAC', 1.00, 1.00, 0.00, 36, 2, 2),
(778, NULL, NULL, NULL, 146, 'SAC', 218.00, 1.00, 217.00, 48, 2, 2),
(779, NULL, NULL, NULL, 146, 'SAC', 0.00, 0.00, 0.00, 49, 2, 2),
(780, NULL, NULL, NULL, 146, 'SAC', 6.00, 2.00, 4.00, 59, 2, 2),
(781, NULL, NULL, NULL, 146, 'SAC', 220.00, 3.00, 217.00, 98, 2, 2),
(782, NULL, NULL, NULL, 146, 'SAC', 10.00, 2.00, 8.00, 125, 2, 2),
(783, NULL, NULL, NULL, 146, 'SAC', 1.00, 1.00, 0.00, 137, 2, 2),
(784, NULL, NULL, NULL, 146, 'SAC', 1.00, 1.00, 0.00, 140, 2, 2),
(785, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 18, 2, 2),
(786, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 127, 2, 2),
(787, NULL, NULL, NULL, NULL, 'SAA', 5.00, 5.00, 0.00, 131, 2, 2),
(788, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 36, 2, 2),
(789, NULL, NULL, NULL, NULL, 'INA', 217.00, 1.00, 218.00, 48, 2, 2),
(790, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 49, 2, 2),
(791, NULL, NULL, NULL, NULL, 'INA', 4.00, 2.00, 6.00, 59, 2, 2),
(792, NULL, NULL, NULL, NULL, 'INA', 217.00, 3.00, 220.00, 98, 2, 2),
(793, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 15, 2, 2),
(794, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 137, 2, 2),
(795, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 140, 2, 2),
(796, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 141, 2, 2),
(797, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 39, 2, 2),
(798, NULL, NULL, NULL, 147, 'SAC', 25.00, 1.00, 24.00, 13, 2, 2),
(799, NULL, NULL, NULL, 147, 'SAC', 2.00, 2.00, 0.00, 15, 2, 2),
(800, NULL, NULL, NULL, 147, 'SAC', 1.00, 1.00, 0.00, 18, 2, 2),
(801, NULL, NULL, NULL, 147, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(802, NULL, NULL, NULL, 147, 'SAC', 0.00, 0.00, 0.00, 26, 2, 2),
(803, NULL, NULL, NULL, 147, 'SAC', 4.00, 1.00, 3.00, 35, 2, 2),
(804, NULL, NULL, NULL, 147, 'SAC', 1.00, 1.00, 0.00, 36, 2, 2),
(805, NULL, NULL, NULL, 147, 'SAC', 1.00, 1.00, 0.00, 39, 2, 2),
(806, NULL, NULL, NULL, 147, 'SAC', 218.00, 1.00, 217.00, 48, 2, 2),
(807, NULL, NULL, NULL, 147, 'SAC', 1.00, 1.00, 0.00, 49, 2, 2),
(808, NULL, NULL, NULL, 147, 'SAC', 6.00, 2.00, 4.00, 59, 2, 2),
(809, NULL, NULL, NULL, 147, 'SAC', 220.00, 3.00, 217.00, 98, 2, 2),
(810, NULL, NULL, NULL, 147, 'SAC', 1.00, 1.00, 0.00, 137, 2, 2),
(811, NULL, NULL, NULL, 147, 'SAC', 1.00, 1.00, 0.00, 140, 2, 2),
(812, NULL, NULL, NULL, 148, 'SAC', 5.00, 2.00, 3.00, 94, 2, 2),
(813, NULL, NULL, NULL, 149, 'SAC', 24.00, 2.00, 22.00, 13, 2, 2),
(814, NULL, NULL, NULL, 149, 'SAC', 0.00, 1.00, -1.00, 26, 2, 2),
(815, NULL, NULL, NULL, 149, 'SAC', 47.00, 2.00, 45.00, 29, 2, 2),
(816, NULL, NULL, NULL, 149, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(817, NULL, NULL, NULL, 149, 'SAC', 4.00, 4.00, 0.00, 59, 2, 2),
(818, NULL, NULL, NULL, 149, 'SAC', 8.00, 2.00, 6.00, 84, 2, 2),
(819, NULL, NULL, NULL, 150, 'SAC', 45.00, 1.00, 44.00, 29, 2, 2),
(820, NULL, NULL, NULL, 151, 'SAC', 6.00, 3.00, 3.00, 84, 2, 2),
(821, NULL, NULL, NULL, 151, 'SAC', 1.00, 1.00, 0.00, 104, 2, 2),
(822, NULL, NULL, NULL, 151, 'SAC', 2.00, 1.00, 1.00, 107, 2, 2),
(823, NULL, NULL, NULL, 152, 'SAC', 22.00, 1.00, 21.00, 13, 2, 2),
(824, NULL, NULL, NULL, 152, 'SAC', 1012.00, 5.00, 1007.00, 16, 2, 2),
(825, NULL, NULL, NULL, 152, 'SAC', 0.00, 0.00, 0.00, 54, 2, 2),
(826, NULL, NULL, NULL, 152, 'SAC', 217.00, 5.00, 212.00, 98, 2, 2),
(827, NULL, NULL, NULL, 153, 'SAC', 21.00, 5.00, 16.00, 13, 2, 2),
(828, NULL, NULL, NULL, 153, 'SAC', 1007.00, 1.00, 1006.00, 16, 2, 2),
(829, NULL, NULL, NULL, 153, 'SAC', 212.00, 5.00, 207.00, 98, 2, 2),
(830, NULL, NULL, NULL, 154, 'SAC', 207.00, 50.00, 157.00, 98, 2, 2),
(831, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 15, 2, 2),
(832, NULL, NULL, NULL, 155, 'SAC', 16.00, 1.00, 15.00, 13, 2, 2),
(833, NULL, NULL, NULL, 155, 'SAC', 141.00, 1.00, 140.00, 14, 2, 2),
(834, NULL, NULL, NULL, 155, 'SAC', 1.00, 1.00, 0.00, 15, 2, 2),
(835, NULL, NULL, NULL, 155, 'SAC', 217.00, 1.00, 216.00, 48, 2, 2),
(836, NULL, NULL, NULL, 155, 'SAC', 126.00, 1.00, 125.00, 110, 2, 2),
(837, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 23, 2, 2),
(838, NULL, NULL, NULL, NULL, 'INA', 0.00, 20.00, 20.00, 15, 2, 2),
(839, NULL, NULL, NULL, 156, 'SAC', 25.00, 10.00, 15.00, 1, 2, 2),
(840, NULL, NULL, NULL, 156, 'SAC', 140.00, 2.00, 138.00, 14, 2, 2),
(841, NULL, NULL, NULL, 156, 'SAC', 20.00, 10.00, 10.00, 15, 2, 2),
(842, NULL, NULL, NULL, 156, 'SAC', 10.00, 10.00, 0.00, 19, 2, 2),
(843, NULL, NULL, NULL, 156, 'SAC', 0.00, 2.00, -2.00, 24, 2, 2),
(844, NULL, NULL, NULL, 156, 'SAC', 130.00, 1.00, 129.00, 25, 2, 2),
(845, NULL, NULL, NULL, 156, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(846, NULL, NULL, NULL, 156, 'SAC', 0.00, 3.00, -3.00, 44, 2, 2),
(847, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 18, 2, 2),
(848, NULL, NULL, NULL, 157, 'SAC', 15.00, 5.00, 10.00, 1, 2, 2),
(849, NULL, NULL, NULL, 157, 'SAC', 138.00, 3.00, 135.00, 14, 2, 2),
(850, NULL, NULL, NULL, 157, 'SAC', 10.00, 4.00, 6.00, 15, 2, 2),
(851, NULL, NULL, NULL, 157, 'SAC', 0.00, 1.00, -1.00, 18, 2, 2),
(852, NULL, NULL, NULL, 157, 'SAC', 129.00, 1.00, 128.00, 25, 2, 2),
(853, NULL, NULL, NULL, 157, 'SAC', 0.00, 1.00, -1.00, 42, 2, 2),
(854, NULL, NULL, NULL, 157, 'SAC', 216.00, 1.00, 215.00, 48, 2, 2),
(855, NULL, NULL, NULL, 157, 'SAC', 0.00, 1.00, -1.00, 54, 2, 2),
(856, NULL, NULL, NULL, 157, 'SAC', 37.00, 1.00, 36.00, 57, 2, 2),
(857, NULL, NULL, NULL, 157, 'SAC', 1.00, 1.00, 0.00, 60, 2, 2),
(858, NULL, NULL, NULL, 157, 'SAC', 15.00, 3.00, 12.00, 99, 2, 2),
(859, NULL, NULL, NULL, 158, 'SAC', 0.00, 1.00, -1.00, 34, 2, 2),
(860, NULL, NULL, NULL, 158, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(861, NULL, NULL, NULL, NULL, 'INA', 6.00, 7.00, 13.00, 15, 2, 2),
(862, NULL, NULL, NULL, NULL, 'SAA', 1006.00, 1.00, 1005.00, 16, 2, 2),
(863, NULL, NULL, NULL, NULL, 'INA', 135.00, 0.00, 135.00, 14, 2, 2),
(864, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 19, 2, 2),
(865, NULL, NULL, NULL, 159, 'SAC', 10.00, 7.00, 3.00, 1, 2, 2),
(866, NULL, NULL, NULL, 159, 'SAC', 135.00, 1.00, 134.00, 14, 2, 2),
(867, NULL, NULL, NULL, 159, 'SAC', 13.00, 7.00, 6.00, 15, 2, 2),
(868, NULL, NULL, NULL, 159, 'SAC', 5.00, 5.00, 0.00, 19, 2, 2),
(869, NULL, NULL, NULL, 159, 'SAC', 128.00, 1.00, 127.00, 25, 2, 2),
(870, NULL, NULL, NULL, 159, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(871, NULL, NULL, NULL, 159, 'SAC', 0.00, 5.00, -5.00, 44, 2, 2),
(872, NULL, NULL, NULL, 159, 'SAC', 215.00, 1.00, 214.00, 48, 2, 2),
(873, NULL, NULL, NULL, 159, 'SAC', 36.00, 10.00, 26.00, 57, 2, 2),
(874, NULL, NULL, NULL, 159, 'SAC', 12.00, 4.00, 8.00, 99, 2, 2),
(875, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 19, 2, 2),
(876, NULL, NULL, NULL, NULL, 'INA', 6.00, 1.00, 7.00, 15, 2, 2),
(877, NULL, NULL, NULL, NULL, 'INA', 134.00, 1.00, 135.00, 14, 2, 2),
(878, NULL, NULL, NULL, NULL, 'INA', 3.00, 4.00, 7.00, 1, 2, 2),
(879, NULL, NULL, NULL, NULL, 'INA', 26.00, 10.00, 36.00, 57, 2, 2),
(880, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 44, 2, 2),
(881, NULL, NULL, NULL, NULL, 'INA', 214.00, 1.00, 215.00, 48, 2, 2),
(882, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 34, 2, 2),
(883, NULL, NULL, NULL, NULL, 'INA', 8.00, 4.00, 12.00, 99, 2, 2),
(884, NULL, NULL, NULL, NULL, 'INA', 127.00, 1.00, 128.00, 25, 2, 2),
(885, NULL, NULL, NULL, 160, 'SAC', 7.00, 7.00, 0.00, 1, 2, 2),
(886, NULL, NULL, NULL, 160, 'SAC', 135.00, 1.00, 134.00, 14, 2, 2),
(887, NULL, NULL, NULL, 160, 'SAC', 7.00, 7.00, 0.00, 15, 2, 2),
(888, NULL, NULL, NULL, 160, 'SAC', 5.00, 5.00, 0.00, 19, 2, 2),
(889, NULL, NULL, NULL, 160, 'SAC', 128.00, 1.00, 127.00, 25, 2, 2),
(890, NULL, NULL, NULL, 160, 'SAC', 1.00, 1.00, 0.00, 34, 2, 2),
(891, NULL, NULL, NULL, 160, 'SAC', 0.00, 5.00, -5.00, 44, 2, 2),
(892, NULL, NULL, NULL, 160, 'SAC', 215.00, 1.00, 214.00, 48, 2, 2),
(893, NULL, NULL, NULL, 160, 'SAC', 36.00, 10.00, 26.00, 57, 2, 2),
(894, NULL, NULL, NULL, 160, 'SAC', 12.00, 4.00, 8.00, 99, 2, 2),
(895, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 15, 2, 2),
(896, NULL, NULL, NULL, NULL, 'INA', 1005.00, 5.00, 1010.00, 16, 2, 2),
(897, NULL, NULL, NULL, 161, 'SAC', 15.00, 10.00, 5.00, 13, 2, 2),
(898, NULL, NULL, NULL, 161, 'SAC', 10.00, 5.00, 5.00, 15, 2, 2),
(899, NULL, NULL, NULL, 161, 'SAC', 1010.00, 10.00, 1000.00, 16, 2, 2),
(900, NULL, NULL, NULL, 161, 'SAC', 0.00, 5.00, -5.00, 34, 2, 2),
(901, NULL, NULL, NULL, 161, 'SAC', 3.00, 5.00, -2.00, 35, 2, 2),
(902, NULL, NULL, NULL, 161, 'SAC', 157.00, 10.00, 147.00, 98, 2, 2),
(903, NULL, NULL, NULL, 162, 'SAC', 5.00, 1.00, 4.00, 15, 2, 2),
(904, NULL, NULL, NULL, 162, 'SAC', 0.00, 0.00, 0.00, 18, 2, 2),
(905, NULL, NULL, NULL, 162, 'SAC', 199.00, 1.00, 198.00, 22, 2, 2),
(906, NULL, NULL, NULL, 162, 'SAC', 147.00, 2.00, 145.00, 98, 2, 2),
(907, NULL, NULL, NULL, 162, 'SAC', 4.00, 1.00, 3.00, 100, 2, 2),
(908, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 129, 2, 2),
(909, NULL, NULL, NULL, 163, 'SAC', 2.00, 2.00, 0.00, 129, 2, 2),
(910, NULL, NULL, NULL, 163, 'SAC', 37.00, 4.00, 33.00, 133, 2, 2),
(911, NULL, NULL, NULL, 163, 'SAC', 30.00, 4.00, 26.00, 134, 2, 2),
(912, NULL, NULL, NULL, NULL, 'INA', 4.00, 50.00, 54.00, 15, 2, 2),
(913, NULL, NULL, NULL, NULL, 'INA', 0.00, 20.00, 20.00, 19, 2, 2),
(914, NULL, NULL, NULL, 164, 'SAC', 54.00, 5.00, 49.00, 15, 2, 2),
(915, NULL, NULL, NULL, 164, 'SAC', 20.00, 2.00, 18.00, 19, 2, 2),
(916, NULL, NULL, NULL, 164, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(917, NULL, NULL, NULL, 164, 'SAC', 127.00, 1.00, 126.00, 25, 2, 2),
(918, NULL, NULL, NULL, 164, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(919, NULL, NULL, NULL, 164, 'SAC', 68.00, 3.00, 65.00, 38, 2, 2),
(920, NULL, NULL, NULL, 164, 'SAC', 0.00, 0.00, 0.00, 46, 2, 2),
(921, NULL, NULL, NULL, 164, 'SAC', 26.00, 18.00, 8.00, 93, 2, 2),
(922, NULL, NULL, NULL, 164, 'SAC', 145.00, 8.00, 137.00, 98, 2, 2),
(923, NULL, NULL, NULL, NULL, 'INA', 0.00, 3.00, 3.00, 128, 2, 2),
(924, NULL, NULL, NULL, 165, 'SAC', 134.00, 2.00, 132.00, 14, 2, 2),
(925, NULL, NULL, NULL, 165, 'SAC', 49.00, 2.00, 47.00, 15, 2, 2),
(926, NULL, NULL, NULL, 165, 'SAC', 0.00, 0.00, 0.00, 42, 2, 2),
(927, NULL, NULL, NULL, 165, 'SAC', 26.00, 5.00, 21.00, 57, 2, 2),
(928, NULL, NULL, NULL, 165, 'SAC', 57.00, 2.00, 55.00, 79, 2, 2),
(929, NULL, NULL, NULL, 165, 'SAC', 96.00, 1.00, 95.00, 81, 2, 2),
(930, NULL, NULL, NULL, 165, 'SAC', 69.00, 3.00, 66.00, 89, 2, 2),
(931, NULL, NULL, NULL, 165, 'SAC', 99.00, 3.00, 96.00, 90, 2, 2),
(932, NULL, NULL, NULL, NULL, 'INA', 18.00, 20.00, 38.00, 19, 2, 2),
(933, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 142, 1, 2),
(934, NULL, NULL, NULL, 166, 'SAC', 38.00, 3.00, 35.00, 19, 2, 2),
(935, NULL, NULL, NULL, 166, 'SAC', 21.00, 1.00, 20.00, 57, 2, 2),
(936, NULL, NULL, NULL, 166, 'SAC', 1.00, 1.00, 0.00, 142, 2, 2),
(937, NULL, NULL, NULL, 167, 'SAC', 20.00, 1.00, 19.00, 57, 2, 2),
(938, NULL, NULL, NULL, 167, 'SAC', 137.00, 1.00, 136.00, 98, 2, 2),
(939, NULL, NULL, NULL, 168, 'SAC', 35.00, 1.00, 34.00, 19, 2, 2),
(940, NULL, NULL, NULL, 168, 'SAC', 19.00, 2.00, 17.00, 57, 2, 2),
(941, NULL, NULL, NULL, 169, 'SAC', 132.00, 1.00, 131.00, 14, 2, 2),
(942, NULL, NULL, NULL, 169, 'SAC', 47.00, 1.00, 46.00, 15, 2, 2),
(943, NULL, NULL, NULL, 170, 'SAC', 34.00, 1.00, 33.00, 19, 2, 2),
(944, NULL, NULL, NULL, 170, 'SAC', 17.00, 1.00, 16.00, 57, 2, 2),
(945, NULL, NULL, NULL, 170, 'SAC', 136.00, 1.00, 135.00, 98, 2, 2),
(946, NULL, NULL, NULL, 171, 'SAC', 16.00, 1.00, 15.00, 57, 2, 2),
(947, NULL, NULL, NULL, 172, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(948, NULL, NULL, NULL, 172, 'SAC', 0.00, 1.00, -1.00, 46, 2, 2),
(949, NULL, NULL, NULL, 172, 'SAC', 26.00, 4.00, 22.00, 134, 2, 2),
(950, NULL, NULL, NULL, 173, 'SAC', 33.00, 10.00, 23.00, 19, 2, 2),
(951, NULL, NULL, NULL, 173, 'SAC', 15.00, 2.00, 13.00, 57, 2, 2),
(952, NULL, NULL, NULL, 174, 'SAC', 8.00, 1.00, 7.00, 99, 2, 2),
(953, NULL, NULL, NULL, 175, 'SAC', 131.00, 1.00, 130.00, 14, 2, 2),
(954, NULL, NULL, NULL, 175, 'SAC', 8.00, 3.00, 5.00, 125, 2, 2),
(955, NULL, NULL, NULL, 176, 'SAC', 139.00, 2.00, 137.00, 88, 2, 2),
(956, NULL, NULL, NULL, 176, 'SAC', 127.00, 2.00, 125.00, 92, 2, 2),
(957, NULL, NULL, NULL, 177, 'SAC', 22.00, 1.00, 21.00, 134, 2, 2),
(958, NULL, NULL, NULL, 178, 'SAC', 13.00, 5.00, 8.00, 57, 2, 2),
(959, NULL, NULL, NULL, 179, 'SAC', 0.00, 1.00, -1.00, 34, 2, 2),
(960, NULL, NULL, NULL, 179, 'SAC', 0.00, 1.00, -1.00, 36, 2, 2),
(961, NULL, NULL, NULL, 179, 'SAC', 125.00, 1.00, 124.00, 92, 2, 2),
(962, NULL, NULL, NULL, 180, 'SAC', 55.00, 1.00, 54.00, 79, 2, 2),
(963, NULL, NULL, NULL, 180, 'SAC', 135.00, 1.00, 134.00, 98, 2, 2),
(964, NULL, NULL, NULL, 181, 'SAC', 134.00, 3.00, 131.00, 98, 2, 2),
(965, NULL, NULL, NULL, 182, 'SAC', 130.00, 3.00, 127.00, 14, 2, 2),
(966, NULL, NULL, NULL, 182, 'SAC', 46.00, 11.00, 35.00, 15, 2, 2),
(967, NULL, NULL, NULL, 182, 'SAC', 198.00, 8.00, 190.00, 22, 2, 2),
(968, NULL, NULL, NULL, 182, 'SAC', 0.00, 1.00, -1.00, 24, 2, 2),
(969, NULL, NULL, NULL, 182, 'SAC', 126.00, 3.00, 123.00, 25, 2, 2),
(970, NULL, NULL, NULL, 182, 'SAC', 214.00, 4.00, 210.00, 48, 2, 2),
(971, NULL, NULL, NULL, 182, 'SAC', 1.00, 1.00, 0.00, 50, 2, 2),
(972, NULL, NULL, NULL, 182, 'SAC', 131.00, 11.00, 120.00, 98, 2, 2),
(973, NULL, NULL, NULL, 182, 'SAC', 7.00, 2.00, 5.00, 99, 2, 2),
(974, NULL, NULL, NULL, NULL, 'INA', 1000.00, 2.00, 1002.00, 16, 2, 2),
(975, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 60, 2, 2),
(976, NULL, NULL, NULL, 183, 'SAC', 5.00, 4.00, 1.00, 13, 2, 2),
(977, NULL, NULL, NULL, 183, 'SAC', 35.00, 15.00, 20.00, 15, 2, 2),
(978, NULL, NULL, NULL, 183, 'SAC', 1002.00, 2.00, 1000.00, 16, 2, 2),
(979, NULL, NULL, NULL, 183, 'SAC', 190.00, 15.00, 175.00, 22, 2, 2),
(980, NULL, NULL, NULL, 183, 'SAC', 123.00, 2.00, 121.00, 25, 2, 2),
(981, NULL, NULL, NULL, 183, 'SAC', 10.00, 1.00, 9.00, 60, 2, 2),
(982, NULL, NULL, NULL, 183, 'SAC', 120.00, 26.00, 94.00, 98, 2, 2),
(983, NULL, NULL, NULL, 183, 'SAC', 5.00, 1.00, 4.00, 99, 2, 2),
(984, NULL, NULL, NULL, 184, 'SAC', 20.00, 2.00, 18.00, 15, 2, 2),
(985, NULL, NULL, NULL, 184, 'SAC', 1.00, 1.00, 0.00, 63, 2, 2),
(986, NULL, NULL, NULL, 184, 'SAC', 3.00, 1.00, 2.00, 65, 2, 2),
(987, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 18, 2, 2),
(988, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 143, 1, 2),
(989, NULL, NULL, NULL, 185, 'SAC', 18.00, 3.00, 15.00, 15, 2, 2),
(990, NULL, NULL, NULL, 185, 'SAC', 5.00, 1.00, 4.00, 18, 2, 2),
(991, NULL, NULL, NULL, 185, 'SAC', 23.00, 1.00, 22.00, 19, 2, 2),
(992, NULL, NULL, NULL, 185, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(993, NULL, NULL, NULL, 185, 'SAC', 0.00, 1.00, -1.00, 44, 2, 2),
(994, NULL, NULL, NULL, 185, 'SAC', 0.00, 0.00, 0.00, 46, 2, 2),
(995, NULL, NULL, NULL, 185, 'SAC', 0.00, 1.00, -1.00, 49, 2, 2),
(996, NULL, NULL, NULL, 185, 'SAC', 9.00, 1.00, 8.00, 60, 2, 2),
(997, NULL, NULL, NULL, 185, 'SAC', 94.00, 2.00, 92.00, 98, 2, 2),
(998, NULL, NULL, NULL, 185, 'SAC', 1.00, 1.00, 0.00, 143, 2, 2),
(999, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 144, 1, 2),
(1000, NULL, NULL, NULL, NULL, 'IN1', 0.00, 6.00, 6.00, 145, 1, 2),
(1001, NULL, NULL, NULL, NULL, 'IN1', 0.00, 5.00, 5.00, 146, 1, 2),
(1002, NULL, NULL, NULL, NULL, 'IN1', 0.00, 2.00, 2.00, 147, 1, 2),
(1003, NULL, NULL, NULL, NULL, 'INA', 15.00, 100.00, 115.00, 15, 2, 2),
(1004, NULL, NULL, NULL, 186, 'SAC', 127.00, 10.00, 117.00, 14, 2, 2),
(1005, NULL, NULL, NULL, 186, 'SAC', 115.00, 50.00, 65.00, 15, 2, 2),
(1006, NULL, NULL, NULL, 186, 'SAC', 210.00, 30.00, 180.00, 48, 2, 2),
(1007, NULL, NULL, NULL, 186, 'SAC', 92.00, 50.00, 42.00, 98, 2, 2),
(1008, NULL, NULL, NULL, 186, 'SAC', 10.00, 10.00, 0.00, 144, 2, 2),
(1009, NULL, NULL, NULL, 186, 'SAC', 6.00, 6.00, 0.00, 145, 2, 2),
(1010, NULL, NULL, NULL, 186, 'SAC', 5.00, 5.00, 0.00, 146, 2, 2),
(1011, NULL, NULL, NULL, 186, 'SAC', 2.00, 2.00, 0.00, 147, 2, 2),
(1012, NULL, NULL, NULL, NULL, 'INA', 65.00, 50.00, 115.00, 15, 2, 2),
(1013, NULL, NULL, NULL, NULL, 'INA', 42.00, 50.00, 92.00, 98, 2, 2),
(1014, NULL, NULL, NULL, NULL, 'INA', 117.00, 10.00, 127.00, 14, 2, 2),
(1015, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 144, 2, 2),
(1016, NULL, NULL, NULL, NULL, 'INA', 0.00, 6.00, 6.00, 145, 2, 2),
(1017, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 146, 2, 2),
(1018, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 147, 2, 2),
(1019, NULL, NULL, NULL, 187, 'SAC', 127.00, 10.00, 117.00, 14, 2, 2),
(1020, NULL, NULL, NULL, 187, 'SAC', 115.00, 50.00, 65.00, 15, 2, 2),
(1021, NULL, NULL, NULL, 187, 'SAC', 180.00, 30.00, 150.00, 48, 2, 2),
(1022, NULL, NULL, NULL, 187, 'SAC', 92.00, 50.00, 42.00, 98, 2, 2),
(1023, NULL, NULL, NULL, 187, 'SAC', 10.00, 10.00, 0.00, 144, 2, 2),
(1024, NULL, NULL, NULL, 187, 'SAC', 6.00, 6.00, 0.00, 145, 2, 2),
(1025, NULL, NULL, NULL, 187, 'SAC', 5.00, 5.00, 0.00, 146, 2, 2),
(1026, NULL, NULL, NULL, 187, 'SAC', 2.00, 2.00, 0.00, 147, 2, 2),
(1027, NULL, NULL, NULL, NULL, 'INA', 4.00, 20.00, 24.00, 99, 2, 2),
(1028, NULL, NULL, NULL, NULL, 'INA', 8.00, 7.00, 15.00, 57, 2, 2),
(1029, NULL, NULL, NULL, NULL, 'INA', 7.00, 13.00, 20.00, 58, 2, 2),
(1030, NULL, NULL, NULL, NULL, 'INA', 0.00, 14.00, 14.00, 1, 2, 2),
(1031, NULL, NULL, NULL, 188, 'SAC', 15.00, 10.00, 5.00, 57, 2, 2),
(1032, NULL, NULL, NULL, 188, 'SAC', 20.00, 20.00, 0.00, 58, 2, 2),
(1033, NULL, NULL, NULL, 188, 'SAC', 24.00, 15.00, 9.00, 99, 2, 2),
(1034, NULL, NULL, NULL, NULL, 'INA', 1.00, 50.00, 51.00, 13, 2, 2),
(1035, NULL, NULL, NULL, NULL, 'INA', 1000.00, 20.00, 1020.00, 16, 2, 2),
(1036, NULL, NULL, NULL, 189, 'SAC', 51.00, 50.00, 1.00, 13, 2, 2),
(1037, NULL, NULL, NULL, 189, 'SAC', 1020.00, 10.00, 1010.00, 16, 2, 2),
(1038, NULL, NULL, NULL, 190, 'SAC', 14.00, 14.00, 0.00, 1, 2, 2),
(1039, NULL, NULL, NULL, 190, 'SAC', 65.00, 10.00, 55.00, 15, 2, 2),
(1040, NULL, NULL, NULL, 190, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(1041, NULL, NULL, NULL, 190, 'SAC', 121.00, 1.00, 120.00, 25, 2, 2),
(1042, NULL, NULL, NULL, 190, 'SAC', 0.00, 4.00, -4.00, 34, 2, 2),
(1043, NULL, NULL, NULL, 190, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(1044, NULL, NULL, NULL, 191, 'SAC', 5.00, 5.00, 0.00, 57, 2, 2),
(1045, NULL, NULL, NULL, 191, 'SAC', 9.00, 1.00, 8.00, 99, 2, 2),
(1046, NULL, NULL, NULL, NULL, 'INA', 0.00, 14.00, 14.00, 1, 2, 2),
(1047, NULL, NULL, NULL, NULL, 'INA', 55.00, 10.00, 65.00, 15, 2, 2),
(1048, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 24, 2, 2),
(1049, NULL, NULL, NULL, NULL, 'INA', 120.00, 1.00, 121.00, 25, 2, 2),
(1050, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 34, 2, 2),
(1051, NULL, NULL, NULL, NULL, 'INA', 0.00, 3.00, 3.00, 44, 2, 2),
(1052, NULL, NULL, NULL, 192, 'SAC', 14.00, 14.00, 0.00, 1, 2, 2),
(1053, NULL, NULL, NULL, 192, 'SAC', 117.00, 3.00, 114.00, 14, 2, 2),
(1054, NULL, NULL, NULL, 192, 'SAC', 65.00, 10.00, 55.00, 15, 2, 2),
(1055, NULL, NULL, NULL, 192, 'SAC', 22.00, 7.00, 15.00, 19, 2, 2),
(1056, NULL, NULL, NULL, 192, 'SAC', 2.00, 2.00, 0.00, 24, 2, 2),
(1057, NULL, NULL, NULL, 192, 'SAC', 121.00, 1.00, 120.00, 25, 2, 2),
(1058, NULL, NULL, NULL, 192, 'SAC', 0.00, 4.00, -4.00, 34, 2, 2),
(1059, NULL, NULL, NULL, 192, 'SAC', 3.00, 3.00, 0.00, 44, 2, 2),
(1060, NULL, NULL, NULL, NULL, 'INA', 0.00, 550.00, 550.00, 23, 2, 2),
(1061, NULL, NULL, NULL, 193, 'SAC', 550.00, 8.00, 542.00, 23, 2, 2),
(1062, NULL, NULL, NULL, NULL, 'INA', 1.00, 10.00, 11.00, 13, 2, 2),
(1063, NULL, NULL, NULL, 194, 'SAC', 11.00, 10.00, 1.00, 13, 2, 2),
(1064, NULL, NULL, NULL, 195, 'SAC', 114.00, 1.00, 113.00, 14, 2, 2),
(1065, NULL, NULL, NULL, 195, 'SAC', 542.00, 1.00, 541.00, 23, 2, 2),
(1066, NULL, NULL, NULL, 195, 'SAC', 0.00, 1.00, -1.00, 24, 2, 2),
(1067, NULL, NULL, NULL, 195, 'SAC', 0.00, 1.00, -1.00, 50, 2, 2),
(1068, NULL, NULL, NULL, 196, 'SAC', 541.00, 3.00, 538.00, 23, 2, 2),
(1069, NULL, NULL, NULL, 197, 'SAC', 538.00, 5.00, 533.00, 23, 2, 2),
(1070, NULL, NULL, NULL, 198, 'SAC', 533.00, 10.00, 523.00, 23, 2, 2),
(1071, NULL, NULL, NULL, 198, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(1072, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 57, 2, 2),
(1073, NULL, NULL, NULL, NULL, 'INA', 5.00, 1.00, 6.00, 57, 2, 2),
(1074, NULL, NULL, NULL, 199, 'SAC', 6.00, 2.00, 4.00, 57, 2, 2),
(1075, NULL, NULL, NULL, 199, 'SAC', 42.00, 1.00, 41.00, 98, 2, 2),
(1076, NULL, NULL, NULL, NULL, 'INA', 2.00, 10.00, 12.00, 65, 2, 2),
(1077, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 63, 2, 2),
(1078, NULL, NULL, NULL, 200, 'SAC', 10.00, 5.00, 5.00, 63, 2, 2),
(1079, NULL, NULL, NULL, 200, 'SAC', 12.00, 5.00, 7.00, 65, 2, 2),
(1080, NULL, NULL, NULL, NULL, 'INA', 523.00, 5.00, 528.00, 23, 2, 2),
(1081, NULL, NULL, NULL, 201, 'SAC', 113.00, 2.00, 111.00, 14, 2, 2),
(1082, NULL, NULL, NULL, 201, 'SAC', 55.00, 7.00, 48.00, 15, 2, 2),
(1083, NULL, NULL, NULL, 201, 'SAC', 175.00, 5.00, 170.00, 22, 2, 2),
(1084, NULL, NULL, NULL, 201, 'SAC', 528.00, 5.00, 523.00, 23, 2, 2),
(1085, NULL, NULL, NULL, 201, 'SAC', 0.00, 1.00, -1.00, 24, 2, 2),
(1086, NULL, NULL, NULL, 201, 'SAC', 0.00, 0.00, 0.00, 36, 2, 2),
(1087, NULL, NULL, NULL, 201, 'SAC', 65.00, 2.00, 63.00, 38, 2, 2),
(1088, NULL, NULL, NULL, 201, 'SAC', 8.00, 2.00, 6.00, 93, 2, 2),
(1089, NULL, NULL, NULL, 201, 'SAC', 41.00, 8.00, 33.00, 98, 2, 2),
(1090, NULL, NULL, NULL, 201, 'SAC', 8.00, 2.00, 6.00, 99, 2, 2),
(1091, NULL, NULL, NULL, 202, 'SAC', 48.00, 7.00, 41.00, 15, 2, 2),
(1092, NULL, NULL, NULL, 202, 'SAC', 33.00, 7.00, 26.00, 98, 2, 2),
(1093, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 148, 1, 2),
(1094, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 149, 1, 2),
(1095, NULL, NULL, NULL, NULL, 'INA', 0.00, 20.00, 20.00, 58, 2, 2),
(1096, NULL, NULL, NULL, NULL, 'INA', 1.00, 5.00, 6.00, 148, 2, 2),
(1097, NULL, NULL, NULL, 203, 'SAC', 20.00, 1.00, 19.00, 58, 2, 2),
(1098, NULL, NULL, NULL, 203, 'SAC', 6.00, 1.00, 5.00, 148, 2, 2),
(1099, NULL, NULL, NULL, 203, 'SAC', 1.00, 1.00, 0.00, 149, 2, 2),
(1100, NULL, NULL, NULL, 204, 'SAC', 6.00, 1.00, 5.00, 93, 2, 2),
(1101, NULL, NULL, NULL, NULL, 'INA', 1010.00, 20.00, 1030.00, 16, 2, 2),
(1102, NULL, NULL, NULL, 205, 'SAC', 1030.00, 1.00, 1029.00, 16, 2, 2),
(1103, NULL, NULL, NULL, 206, 'SAC', 1029.00, 1.00, 1028.00, 16, 2, 2),
(1104, NULL, NULL, NULL, 206, 'SAC', 124.00, 1.00, 123.00, 92, 2, 2),
(1105, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 39, 2, 2),
(1106, NULL, NULL, NULL, 207, 'SAC', 41.00, 1.00, 40.00, 15, 2, 2),
(1107, NULL, NULL, NULL, 207, 'SAC', 1028.00, 1.00, 1027.00, 16, 2, 2),
(1108, NULL, NULL, NULL, 207, 'SAC', 4.00, 1.00, 3.00, 18, 2, 2),
(1109, NULL, NULL, NULL, 207, 'SAC', 170.00, 1.00, 169.00, 22, 2, 2),
(1110, NULL, NULL, NULL, 207, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(1111, NULL, NULL, NULL, 207, 'SAC', 2.00, 1.00, 1.00, 39, 2, 2),
(1112, NULL, NULL, NULL, 207, 'SAC', 26.00, 1.00, 25.00, 98, 2, 2),
(1113, NULL, NULL, NULL, 207, 'SAC', 2.00, 1.00, 1.00, 135, 2, 2),
(1114, NULL, NULL, NULL, 208, 'SAC', 0.00, 1.00, -1.00, 44, 2, 2),
(1115, NULL, NULL, NULL, 208, 'SAC', 54.00, 1.00, 53.00, 79, 2, 2),
(1116, NULL, NULL, NULL, 208, 'SAC', 95.00, 1.00, 94.00, 81, 2, 2),
(1117, NULL, NULL, NULL, 208, 'SAC', 137.00, 1.00, 136.00, 88, 2, 2),
(1118, NULL, NULL, NULL, 208, 'SAC', 123.00, 1.00, 122.00, 92, 2, 2),
(1119, NULL, NULL, NULL, 209, 'SAC', 40.00, 1.00, 39.00, 15, 2, 2),
(1120, NULL, NULL, NULL, 209, 'SAC', 63.00, 1.00, 62.00, 38, 2, 2),
(1121, NULL, NULL, NULL, 209, 'SAC', 150.00, 1.00, 149.00, 48, 2, 2),
(1122, NULL, NULL, NULL, 209, 'SAC', 25.00, 1.00, 24.00, 98, 2, 2),
(1123, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 150, 1, 2),
(1124, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 151, 1, 2),
(1125, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 74, 2, 2),
(1126, NULL, NULL, NULL, 210, 'SAC', 1.00, 1.00, 0.00, 74, 2, 2),
(1127, NULL, NULL, NULL, 210, 'SAC', 1.00, 1.00, 0.00, 150, 2, 2),
(1128, NULL, NULL, NULL, 210, 'SAC', 1.00, 1.00, 0.00, 151, 2, 2),
(1129, NULL, NULL, NULL, 211, 'SAC', 39.00, 1.00, 38.00, 15, 2, 2),
(1130, NULL, NULL, NULL, 211, 'SAC', 53.00, 1.00, 52.00, 79, 2, 2),
(1131, NULL, NULL, NULL, 211, 'SAC', 237.00, 1.00, 236.00, 91, 2, 2),
(1132, NULL, NULL, NULL, 211, 'SAC', 24.00, 3.00, 21.00, 98, 2, 2),
(1133, NULL, NULL, NULL, 212, 'SAC', 38.00, 3.00, 35.00, 15, 2, 2),
(1134, NULL, NULL, NULL, 212, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(1135, NULL, NULL, NULL, 212, 'SAC', 0.00, 2.00, -2.00, 34, 2, 2),
(1136, NULL, NULL, NULL, 212, 'SAC', 149.00, 1.00, 148.00, 48, 2, 2),
(1137, NULL, NULL, NULL, 212, 'SAC', 21.00, 3.00, 18.00, 98, 2, 2),
(1138, NULL, NULL, NULL, 212, 'SAC', 6.00, 1.00, 5.00, 99, 2, 2),
(1139, NULL, NULL, NULL, 213, 'SAC', 1.00, 2.00, -1.00, 13, 2, 2),
(1140, NULL, NULL, NULL, 213, 'SAC', 35.00, 1.00, 34.00, 15, 2, 2),
(1141, NULL, NULL, NULL, 213, 'SAC', 1027.00, 6.00, 1021.00, 16, 2, 2),
(1142, NULL, NULL, NULL, 213, 'SAC', 3.00, 1.00, 2.00, 18, 2, 2),
(1143, NULL, NULL, NULL, 213, 'SAC', 0.00, 0.00, 0.00, 49, 2, 2),
(1144, NULL, NULL, NULL, 214, 'SAC', 1021.00, 1.00, 1020.00, 16, 2, 2),
(1145, NULL, NULL, NULL, 214, 'SAC', 2.00, 1.00, 1.00, 18, 2, 2),
(1146, NULL, NULL, NULL, 215, 'SAC', 1.00, 1.00, 0.00, 135, 2, 2),
(1147, NULL, NULL, NULL, 216, 'SAC', 34.00, 1.00, 33.00, 15, 2, 2),
(1148, NULL, NULL, NULL, 216, 'SAC', 1.00, 1.00, 0.00, 18, 2, 2),
(1149, NULL, NULL, NULL, 216, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(1150, NULL, NULL, NULL, 216, 'SAC', 62.00, 1.00, 61.00, 38, 2, 2),
(1151, NULL, NULL, NULL, 216, 'SAC', 18.00, 1.00, 17.00, 98, 2, 2),
(1152, NULL, NULL, NULL, 216, 'SAC', 3.00, 1.00, 2.00, 100, 2, 2),
(1153, NULL, NULL, NULL, NULL, 'INA', 17.00, 40.00, 57.00, 98, 2, 2),
(1154, NULL, NULL, NULL, 217, 'SAC', 111.00, 35.00, 76.00, 14, 2, 2),
(1155, NULL, NULL, NULL, 217, 'SAC', 57.00, 35.00, 22.00, 98, 2, 2),
(1156, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 18, 2, 2),
(1157, NULL, NULL, NULL, 218, 'SAC', 33.00, 1.00, 32.00, 15, 2, 2),
(1158, NULL, NULL, NULL, 218, 'SAC', 1.00, 1.00, 0.00, 18, 2, 2),
(1159, NULL, NULL, NULL, NULL, 'INA', 22.00, 50.00, 72.00, 98, 2, 2),
(1160, NULL, NULL, NULL, NULL, 'INA', 5.00, 5.00, 10.00, 63, 2, 2),
(1161, NULL, NULL, NULL, 219, 'SAC', 148.00, 6.00, 142.00, 48, 2, 2),
(1162, NULL, NULL, NULL, 219, 'SAC', 10.00, 6.00, 4.00, 63, 2, 2),
(1163, NULL, NULL, NULL, 219, 'SAC', 7.00, 1.00, 6.00, 65, 2, 2),
(1164, NULL, NULL, NULL, 219, 'SAC', 72.00, 25.00, 47.00, 98, 2, 2),
(1165, NULL, NULL, NULL, 219, 'SAC', 12.00, 6.00, 6.00, 122, 2, 2),
(1166, NULL, NULL, NULL, 219, 'SAC', 9.00, 2.00, 7.00, 123, 2, 2),
(1167, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 13, 2, 2),
(1168, NULL, NULL, NULL, 220, 'SAC', 0.00, 10.00, -10.00, 13, 2, 2),
(1169, NULL, NULL, NULL, 220, 'SAC', 32.00, 10.00, 22.00, 15, 2, 2),
(1170, NULL, NULL, NULL, 220, 'SAC', 1020.00, 10.00, 1010.00, 16, 2, 2),
(1171, NULL, NULL, NULL, 220, 'SAC', 47.00, 10.00, 37.00, 98, 2, 2),
(1172, NULL, NULL, NULL, NULL, 'INA', 37.00, 10.00, 47.00, 98, 2, 2),
(1173, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 13, 2, 2),
(1174, NULL, NULL, NULL, NULL, 'INA', 22.00, 10.00, 32.00, 15, 2, 2),
(1175, NULL, NULL, NULL, NULL, 'INA', 1010.00, 10.00, 1020.00, 16, 2, 2),
(1176, NULL, NULL, NULL, 221, 'SAC', 0.00, 10.00, -10.00, 13, 2, 2),
(1177, NULL, NULL, NULL, 221, 'SAC', 32.00, 10.00, 22.00, 15, 2, 2),
(1178, NULL, NULL, NULL, 221, 'SAC', 1020.00, 10.00, 1010.00, 16, 2, 2),
(1179, NULL, NULL, NULL, 221, 'SAC', 47.00, 10.00, 37.00, 98, 2, 2),
(1180, NULL, NULL, NULL, NULL, 'SAA', 37.00, 15.00, 22.00, 98, 2, 2),
(1181, NULL, NULL, NULL, NULL, 'SAA', 523.00, 5.00, 518.00, 23, 2, 2),
(1182, NULL, NULL, NULL, NULL, 'INA', 142.00, 4.00, 146.00, 48, 2, 2),
(1183, NULL, NULL, NULL, NULL, 'INA', 0.00, 81.00, 81.00, 24, 2, 2),
(1184, NULL, NULL, NULL, NULL, 'SAA', 81.00, 1.00, 80.00, 24, 2, 2),
(1185, NULL, NULL, NULL, NULL, 'INA', 15.00, 1.00, 16.00, 19, 2, 2),
(1186, NULL, NULL, NULL, 222, 'SAC', 0.00, 3.00, -3.00, 34, 2, 2),
(1187, NULL, NULL, NULL, 222, 'SAC', 4.00, 1.00, 3.00, 63, 2, 2),
(1188, NULL, NULL, NULL, 222, 'SAC', 6.00, 1.00, 5.00, 65, 2, 2),
(1189, NULL, NULL, NULL, NULL, 'SAA', 22.00, 16.00, 6.00, 15, 2, 2),
(1190, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 18, 2, 2),
(1191, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 59, 2, 2),
(1192, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 35, 2, 2),
(1193, NULL, NULL, NULL, 223, 'SAC', 0.00, 0.00, 0.00, 13, 2, 2),
(1194, NULL, NULL, NULL, 223, 'SAC', 6.00, 1.00, 5.00, 15, 2, 2),
(1195, NULL, NULL, NULL, 223, 'SAC', 1010.00, 4.00, 1006.00, 16, 2, 2),
(1196, NULL, NULL, NULL, 223, 'SAC', 10.00, 2.00, 8.00, 18, 2, 2),
(1197, NULL, NULL, NULL, 223, 'SAC', 120.00, 1.00, 119.00, 25, 2, 2),
(1198, NULL, NULL, NULL, 223, 'SAC', 0.00, 2.00, -2.00, 35, 2, 2),
(1199, NULL, NULL, NULL, 223, 'SAC', 0.00, 2.00, -2.00, 49, 2, 2),
(1200, NULL, NULL, NULL, 223, 'SAC', 10.00, 1.00, 9.00, 59, 2, 2),
(1201, NULL, NULL, NULL, 223, 'SAC', 136.00, 1.00, 135.00, 88, 2, 2),
(1202, NULL, NULL, NULL, 223, 'SAC', 236.00, 1.00, 235.00, 91, 2, 2),
(1203, NULL, NULL, NULL, 223, 'SAC', 22.00, 1.00, 21.00, 98, 2, 2),
(1204, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 152, 1, 2),
(1205, NULL, NULL, NULL, NULL, 'IN1', 0.00, 15.00, 15.00, 153, 1, 2),
(1206, NULL, NULL, NULL, NULL, 'INA', 5.00, 20.00, 25.00, 15, 2, 2),
(1207, NULL, NULL, NULL, NULL, 'INA', 0.00, 20.00, 20.00, 1, 2, 2),
(1208, NULL, NULL, NULL, 224, 'SAC', 20.00, 14.00, 6.00, 1, 2, 2),
(1209, NULL, NULL, NULL, 224, 'SAC', 76.00, 3.00, 73.00, 14, 2, 2),
(1210, NULL, NULL, NULL, 224, 'SAC', 25.00, 12.00, 13.00, 15, 2, 2),
(1211, NULL, NULL, NULL, 224, 'SAC', 16.00, 5.00, 11.00, 19, 2, 2),
(1212, NULL, NULL, NULL, 224, 'SAC', 119.00, 1.00, 118.00, 25, 2, 2),
(1213, NULL, NULL, NULL, 224, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(1214, NULL, NULL, NULL, 224, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(1215, NULL, NULL, NULL, NULL, 'INA', 0.00, 4.00, 4.00, 44, 2, 2),
(1216, NULL, NULL, NULL, NULL, 'INA', 13.00, 12.00, 25.00, 15, 2, 2),
(1217, NULL, NULL, NULL, NULL, 'INA', 6.00, 14.00, 20.00, 1, 2, 2),
(1218, NULL, NULL, NULL, NULL, 'INA', 0.00, 4.00, 4.00, 34, 2, 2),
(1219, NULL, NULL, NULL, NULL, 'INA', 73.00, 3.00, 76.00, 14, 2, 2),
(1220, NULL, NULL, NULL, NULL, 'INA', 11.00, 5.00, 16.00, 19, 2, 2),
(1221, NULL, NULL, NULL, NULL, 'INA', 118.00, 1.00, 119.00, 25, 2, 2),
(1222, NULL, NULL, NULL, 225, 'SAC', 20.00, 14.00, 6.00, 1, 2, 2),
(1223, NULL, NULL, NULL, 225, 'SAC', 76.00, 3.00, 73.00, 14, 2, 2),
(1224, NULL, NULL, NULL, 225, 'SAC', 25.00, 12.00, 13.00, 15, 2, 2),
(1225, NULL, NULL, NULL, 225, 'SAC', 16.00, 5.00, 11.00, 19, 2, 2),
(1226, NULL, NULL, NULL, 225, 'SAC', 119.00, 1.00, 118.00, 25, 2, 2),
(1227, NULL, NULL, NULL, 225, 'SAC', 4.00, 4.00, 0.00, 34, 2, 2),
(1228, NULL, NULL, NULL, 225, 'SAC', 4.00, 4.00, 0.00, 44, 2, 2),
(1229, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 37, 2, 2),
(1230, NULL, NULL, NULL, 226, 'SAC', 13.00, 3.00, 10.00, 15, 2, 2),
(1231, NULL, NULL, NULL, 226, 'SAC', 169.00, 2.00, 167.00, 22, 2, 2),
(1232, NULL, NULL, NULL, 226, 'SAC', 1.00, 1.00, 0.00, 37, 2, 2),
(1233, NULL, NULL, NULL, 226, 'SAC', 1.00, 1.00, 0.00, 39, 2, 2),
(1234, NULL, NULL, NULL, 226, 'SAC', 0.00, 1.00, -1.00, 42, 2, 2),
(1235, NULL, NULL, NULL, 226, 'SAC', 0.00, 1.00, -1.00, 44, 2, 2),
(1236, NULL, NULL, NULL, 226, 'SAC', 146.00, 1.00, 145.00, 48, 2, 2),
(1237, NULL, NULL, NULL, 226, 'SAC', 4.00, 2.00, 2.00, 57, 2, 2),
(1238, NULL, NULL, NULL, 226, 'SAC', 21.00, 3.00, 18.00, 98, 2, 2),
(1239, NULL, NULL, NULL, 226, 'SAC', 9.00, 1.00, 8.00, 136, 2, 2),
(1240, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 137, 2, 2),
(1241, NULL, NULL, NULL, NULL, 'INA', 2.00, 2.00, 4.00, 137, 2, 2),
(1242, NULL, NULL, NULL, NULL, 'INA', 10.00, 10.00, 20.00, 15, 2, 2),
(1243, NULL, NULL, NULL, 227, 'SAC', 73.00, 4.00, 69.00, 14, 2, 2),
(1244, NULL, NULL, NULL, 227, 'SAC', 20.00, 12.00, 8.00, 15, 2, 2),
(1245, NULL, NULL, NULL, 227, 'SAC', 167.00, 8.00, 159.00, 22, 2, 2),
(1246, NULL, NULL, NULL, 227, 'SAC', 518.00, 4.00, 514.00, 23, 2, 2),
(1247, NULL, NULL, NULL, 227, 'SAC', 145.00, 2.00, 143.00, 48, 2, 2),
(1248, NULL, NULL, NULL, 227, 'SAC', 0.00, 0.00, 0.00, 50, 2, 2),
(1249, NULL, NULL, NULL, 227, 'SAC', 8.00, 1.00, 7.00, 52, 2, 2),
(1250, NULL, NULL, NULL, 227, 'SAC', 18.00, 10.00, 8.00, 98, 2, 2),
(1251, NULL, NULL, NULL, 227, 'SAC', 5.00, 2.00, 3.00, 99, 2, 2),
(1252, NULL, NULL, NULL, 227, 'SAC', 4.00, 4.00, 0.00, 137, 2, 2),
(1253, NULL, NULL, NULL, NULL, 'INA', 8.00, 20.00, 28.00, 98, 2, 2),
(1254, NULL, NULL, NULL, 228, 'SAC', 28.00, 25.00, 3.00, 98, 2, 2),
(1255, NULL, NULL, NULL, NULL, 'INA', 2.00, 10.00, 12.00, 57, 2, 2),
(1256, NULL, NULL, NULL, 229, 'SAC', 118.00, 2.00, 116.00, 25, 2, 2),
(1257, NULL, NULL, NULL, 229, 'SAC', 61.00, 10.00, 51.00, 38, 2, 2),
(1258, NULL, NULL, NULL, 229, 'SAC', 0.00, 0.00, 0.00, 42, 2, 2),
(1259, NULL, NULL, NULL, 229, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(1260, NULL, NULL, NULL, 229, 'SAC', 143.00, 5.00, 138.00, 48, 2, 2),
(1261, NULL, NULL, NULL, 229, 'SAC', 12.00, 10.00, 2.00, 57, 2, 2),
(1262, NULL, NULL, NULL, 229, 'SAC', 10.00, 10.00, 0.00, 152, 2, 2),
(1263, NULL, NULL, NULL, 229, 'SAC', 15.00, 15.00, 0.00, 153, 2, 2),
(1264, NULL, NULL, NULL, NULL, 'INA', 50.00, 10.00, 60.00, 33, 2, 2),
(1265, NULL, NULL, NULL, NULL, 'IN1', 0.00, 5.00, 5.00, 154, 1, 2),
(1266, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 30, 2, 2),
(1267, NULL, NULL, NULL, NULL, 'INA', 17.00, 9.00, 26.00, 31, 2, 2),
(1268, NULL, NULL, NULL, 230, 'SAC', 11.00, 1.00, 10.00, 19, 2, 2),
(1269, NULL, NULL, NULL, 230, 'SAC', 116.00, 1.00, 115.00, 25, 2, 2),
(1270, NULL, NULL, NULL, 230, 'SAC', 0.00, 0.00, 0.00, 26, 2, 2),
(1271, NULL, NULL, NULL, 230, 'SAC', 10.00, 1.00, 9.00, 30, 2, 2),
(1272, NULL, NULL, NULL, 230, 'SAC', 26.00, 1.00, 25.00, 31, 2, 2),
(1273, NULL, NULL, NULL, 230, 'SAC', 60.00, 3.00, 57.00, 33, 2, 2),
(1274, NULL, NULL, NULL, 230, 'SAC', 3.00, 1.00, 2.00, 98, 2, 2),
(1275, NULL, NULL, NULL, 230, 'SAC', 5.00, 1.00, 4.00, 154, 2, 2),
(1276, NULL, NULL, NULL, NULL, 'IN1', 0.00, 2.00, 2.00, 155, 1, 2),
(1277, NULL, NULL, NULL, NULL, 'INA', 2.00, 10.00, 12.00, 98, 2, 2),
(1278, NULL, NULL, NULL, NULL, 'INA', 8.00, 2.00, 10.00, 15, 2, 2),
(1279, NULL, NULL, NULL, 231, 'SAC', 0.00, 1.00, -1.00, 13, 2, 2),
(1280, NULL, NULL, NULL, 231, 'SAC', 10.00, 2.00, 8.00, 15, 2, 2),
(1281, NULL, NULL, NULL, 231, 'SAC', 1006.00, 1.00, 1005.00, 16, 2, 2),
(1282, NULL, NULL, NULL, 231, 'SAC', 12.00, 3.00, 9.00, 98, 2, 2),
(1283, NULL, NULL, NULL, 231, 'SAC', 2.00, 1.00, 1.00, 155, 2, 2),
(1284, NULL, NULL, NULL, NULL, 'INA', 9.00, 20.00, 29.00, 98, 2, 2),
(1285, NULL, NULL, NULL, NULL, 'INA', 8.00, 20.00, 28.00, 15, 2, 2),
(1286, NULL, NULL, NULL, NULL, 'INA', 2.00, 15.00, 17.00, 57, 2, 2),
(1287, NULL, NULL, NULL, NULL, 'INA', 10.00, 30.00, 40.00, 19, 2, 2),
(1288, NULL, NULL, NULL, 232, 'SAC', 28.00, 3.00, 25.00, 15, 2, 2),
(1289, NULL, NULL, NULL, 232, 'SAC', 514.00, 2.00, 512.00, 23, 2, 2),
(1290, NULL, NULL, NULL, 232, 'SAC', 138.00, 1.00, 137.00, 48, 2, 2),
(1291, NULL, NULL, NULL, 232, 'SAC', 17.00, 5.00, 12.00, 57, 2, 2),
(1292, NULL, NULL, NULL, 232, 'SAC', 52.00, 4.00, 48.00, 79, 2, 2),
(1293, NULL, NULL, NULL, 232, 'SAC', 94.00, 2.00, 92.00, 81, 2, 2),
(1294, NULL, NULL, NULL, 232, 'SAC', 135.00, 1.00, 134.00, 88, 2, 2),
(1295, NULL, NULL, NULL, 232, 'SAC', 66.00, 2.00, 64.00, 89, 2, 2),
(1296, NULL, NULL, NULL, 232, 'SAC', 235.00, 2.00, 233.00, 91, 2, 2),
(1297, NULL, NULL, NULL, 232, 'SAC', 122.00, 7.00, 115.00, 92, 2, 2),
(1298, NULL, NULL, NULL, 232, 'SAC', 29.00, 5.00, 24.00, 98, 2, 2),
(1299, NULL, NULL, NULL, 232, 'SAC', 3.00, 1.00, 2.00, 99, 2, 2),
(1300, NULL, NULL, NULL, 233, 'SAC', 25.00, 3.00, 22.00, 15, 2, 2),
(1301, NULL, NULL, NULL, 233, 'SAC', 512.00, 2.00, 510.00, 23, 2, 2),
(1302, NULL, NULL, NULL, 233, 'SAC', 137.00, 1.00, 136.00, 48, 2, 2),
(1303, NULL, NULL, NULL, 233, 'SAC', 12.00, 5.00, 7.00, 57, 2, 2),
(1304, NULL, NULL, NULL, 233, 'SAC', 48.00, 4.00, 44.00, 79, 2, 2),
(1305, NULL, NULL, NULL, 233, 'SAC', 92.00, 2.00, 90.00, 81, 2, 2),
(1306, NULL, NULL, NULL, 233, 'SAC', 134.00, 1.00, 133.00, 88, 2, 2),
(1307, NULL, NULL, NULL, 233, 'SAC', 64.00, 2.00, 62.00, 89, 2, 2),
(1308, NULL, NULL, NULL, 233, 'SAC', 233.00, 2.00, 231.00, 91, 2, 2),
(1309, NULL, NULL, NULL, 233, 'SAC', 115.00, 7.00, 108.00, 92, 2, 2),
(1310, NULL, NULL, NULL, 233, 'SAC', 24.00, 5.00, 19.00, 98, 2, 2),
(1311, NULL, NULL, NULL, 233, 'SAC', 2.00, 1.00, 1.00, 99, 2, 2),
(1312, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 156, 1, 2),
(1313, NULL, NULL, NULL, 234, 'SAC', 40.00, 3.00, 37.00, 19, 2, 2),
(1314, NULL, NULL, NULL, 234, 'SAC', 7.00, 2.00, 5.00, 57, 2, 2),
(1315, NULL, NULL, NULL, 234, 'SAC', 1.00, 1.00, 0.00, 156, 2, 2),
(1316, NULL, NULL, NULL, 235, 'SAC', 0.00, 1.00, -1.00, 44, 2, 2),
(1317, NULL, NULL, NULL, 235, 'SAC', 5.00, 1.00, 4.00, 57, 2, 2),
(1318, NULL, NULL, NULL, 235, 'SAC', 133.00, 1.00, 132.00, 88, 2, 2),
(1319, NULL, NULL, NULL, 235, 'SAC', 62.00, 1.00, 61.00, 89, 2, 2),
(1320, NULL, NULL, NULL, 236, 'SAC', 22.00, 1.00, 21.00, 15, 2, 2),
(1321, NULL, NULL, NULL, 237, 'SAC', 4.00, 1.00, 3.00, 57, 2, 2),
(1322, NULL, NULL, NULL, 237, 'SAC', 19.00, 1.00, 18.00, 98, 2, 2),
(1323, NULL, NULL, NULL, 238, 'SAC', 69.00, 1.00, 68.00, 14, 2, 2),
(1324, NULL, NULL, NULL, 238, 'SAC', 21.00, 2.00, 19.00, 15, 2, 2),
(1325, NULL, NULL, NULL, 238, 'SAC', 3.00, 2.00, 1.00, 57, 2, 2),
(1326, NULL, NULL, NULL, 238, 'SAC', 18.00, 4.00, 14.00, 98, 2, 2),
(1327, NULL, NULL, NULL, 239, 'SAC', 68.00, 1.00, 67.00, 14, 2, 2),
(1328, NULL, NULL, NULL, 239, 'SAC', 19.00, 1.00, 18.00, 15, 2, 2),
(1329, NULL, NULL, NULL, 239, 'SAC', 14.00, 2.00, 12.00, 98, 2, 2),
(1330, NULL, NULL, NULL, NULL, 'INA', 1.00, 10.00, 11.00, 57, 2, 2),
(1331, NULL, NULL, NULL, 240, 'SAC', 18.00, 1.00, 17.00, 15, 2, 2),
(1332, NULL, NULL, NULL, 240, 'SAC', 0.00, 1.00, -1.00, 34, 2, 2),
(1333, NULL, NULL, NULL, 240, 'SAC', 51.00, 1.00, 50.00, 38, 2, 2),
(1334, NULL, NULL, NULL, 240, 'SAC', 11.00, 2.00, 9.00, 57, 2, 2),
(1335, NULL, NULL, NULL, 240, 'SAC', 12.00, 2.00, 10.00, 98, 2, 2),
(1336, NULL, NULL, NULL, 241, 'SAC', 67.00, 1.00, 66.00, 14, 2, 2),
(1337, NULL, NULL, NULL, 241, 'SAC', 17.00, 1.00, 16.00, 15, 2, 2),
(1338, NULL, NULL, NULL, 241, 'SAC', 9.00, 2.00, 7.00, 57, 2, 2),
(1339, NULL, NULL, NULL, 242, 'SAC', 66.00, 1.00, 65.00, 14, 2, 2),
(1340, NULL, NULL, NULL, 242, 'SAC', 16.00, 4.00, 12.00, 15, 2, 2),
(1341, NULL, NULL, NULL, 242, 'SAC', 0.00, 1.00, -1.00, 50, 2, 2),
(1342, NULL, NULL, NULL, 242, 'SAC', 7.00, 1.00, 6.00, 57, 2, 2),
(1343, NULL, NULL, NULL, 243, 'SAC', 65.00, 1.00, 64.00, 14, 2, 2),
(1344, NULL, NULL, NULL, 244, 'SAC', 37.00, 30.00, 7.00, 19, 2, 2),
(1345, NULL, NULL, NULL, 244, 'SAC', 510.00, 1.00, 509.00, 23, 2, 2),
(1346, NULL, NULL, NULL, 244, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(1347, NULL, NULL, NULL, 244, 'SAC', 1.00, 1.00, 0.00, 99, 2, 2),
(1348, NULL, NULL, NULL, 245, 'SAC', 12.00, 1.00, 11.00, 15, 2, 2),
(1349, NULL, NULL, NULL, 245, 'SAC', 108.00, 2.00, 106.00, 92, 2, 2),
(1350, NULL, NULL, NULL, 246, 'SAC', 11.00, 1.00, 10.00, 15, 2, 2),
(1351, NULL, NULL, NULL, 246, 'SAC', 8.00, 1.00, 7.00, 60, 2, 2),
(1352, NULL, NULL, NULL, 246, 'SAC', 10.00, 3.00, 7.00, 98, 2, 2),
(1353, NULL, NULL, NULL, 247, 'SAC', 132.00, 2.00, 130.00, 88, 2, 2),
(1354, NULL, NULL, NULL, 247, 'SAC', 106.00, 2.00, 104.00, 92, 2, 2),
(1355, NULL, NULL, NULL, 248, 'SAC', 64.00, 1.00, 63.00, 14, 2, 2),
(1356, NULL, NULL, NULL, 248, 'SAC', 10.00, 1.00, 9.00, 15, 2, 2),
(1357, NULL, NULL, NULL, 248, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(1358, NULL, NULL, NULL, 248, 'SAC', 0.00, 1.00, -1.00, 46, 2, 2),
(1359, NULL, NULL, NULL, 249, 'SAC', 0.00, 1.00, -1.00, 44, 2, 2),
(1360, NULL, NULL, NULL, 249, 'SAC', 0.00, 0.00, 0.00, 46, 2, 2),
(1361, NULL, NULL, NULL, 250, 'SAC', 9.00, 1.00, 8.00, 15, 2, 2),
(1362, NULL, NULL, NULL, 250, 'SAC', 0.00, 1.00, -1.00, 36, 2, 2),
(1363, NULL, NULL, NULL, 250, 'SAC', 130.00, 1.00, 129.00, 88, 2, 2),
(1364, NULL, NULL, NULL, 250, 'SAC', 96.00, 1.00, 95.00, 90, 2, 2),
(1365, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 156, 2, 2),
(1366, NULL, NULL, NULL, 251, 'SAC', 8.00, 4.00, 4.00, 15, 2, 2),
(1367, NULL, NULL, NULL, 251, 'SAC', 509.00, 1.00, 508.00, 23, 2, 2),
(1368, NULL, NULL, NULL, 251, 'SAC', 0.00, 2.00, -2.00, 34, 2, 2),
(1369, NULL, NULL, NULL, 251, 'SAC', 136.00, 1.00, 135.00, 48, 2, 2),
(1370, NULL, NULL, NULL, 251, 'SAC', 6.00, 2.00, 4.00, 57, 2, 2),
(1371, NULL, NULL, NULL, 251, 'SAC', 7.00, 6.00, 1.00, 98, 2, 2),
(1372, NULL, NULL, NULL, 251, 'SAC', 2.00, 2.00, 0.00, 156, 2, 2),
(1373, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 39, 2, 2),
(1374, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 37, 2, 2),
(1375, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 47, 2, 2),
(1376, NULL, NULL, NULL, 252, 'SAC', 0.00, 0.00, 0.00, 13, 2, 2),
(1377, NULL, NULL, NULL, 252, 'SAC', 1005.00, 2.00, 1003.00, 16, 2, 2),
(1378, NULL, NULL, NULL, 252, 'SAC', 0.00, 0.00, 0.00, 35, 2, 2),
(1379, NULL, NULL, NULL, 252, 'SAC', 1.00, 1.00, 0.00, 37, 2, 2),
(1380, NULL, NULL, NULL, 252, 'SAC', 2.00, 2.00, 0.00, 39, 2, 2),
(1381, NULL, NULL, NULL, 252, 'SAC', 9.00, 1.00, 8.00, 41, 2, 2),
(1382, NULL, NULL, NULL, 252, 'SAC', 1.00, 1.00, 0.00, 47, 2, 2),
(1383, NULL, NULL, NULL, 252, 'SAC', 19.00, 1.00, 18.00, 58, 2, 2),
(1384, NULL, NULL, NULL, NULL, 'INA', 1.00, 200.00, 201.00, 98, 2, 2),
(1385, NULL, NULL, NULL, 253, 'SAC', 201.00, 150.00, 51.00, 98, 2, 2),
(1386, NULL, NULL, NULL, NULL, 'INA', 3.00, 10.00, 13.00, 63, 2, 2),
(1387, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 73, 2, 2),
(1388, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 99, 2, 2),
(1389, NULL, NULL, NULL, NULL, 'INA', 4.00, 20.00, 24.00, 15, 2, 2),
(1390, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 34, 2, 2),
(1391, NULL, NULL, NULL, 254, 'SAC', 63.00, 3.00, 60.00, 14, 2, 2),
(1392, NULL, NULL, NULL, 254, 'SAC', 24.00, 18.00, 6.00, 15, 2, 2),
(1393, NULL, NULL, NULL, 254, 'SAC', 7.00, 5.00, 2.00, 19, 2, 2),
(1394, NULL, NULL, NULL, 254, 'SAC', 80.00, 1.00, 79.00, 24, 2, 2),
(1395, NULL, NULL, NULL, 254, 'SAC', 0.00, 8.00, -8.00, 34, 2, 2),
(1396, NULL, NULL, NULL, 254, 'SAC', 135.00, 3.00, 132.00, 48, 2, 2),
(1397, NULL, NULL, NULL, 254, 'SAC', 4.00, 2.00, 2.00, 57, 2, 2),
(1398, NULL, NULL, NULL, 254, 'SAC', 9.00, 1.00, 8.00, 59, 2, 2),
(1399, NULL, NULL, NULL, 254, 'SAC', 13.00, 5.00, 8.00, 63, 2, 2),
(1400, NULL, NULL, NULL, 254, 'SAC', 5.00, 5.00, 0.00, 65, 2, 2),
(1401, NULL, NULL, NULL, 254, 'SAC', 2.00, 2.00, 0.00, 73, 2, 2),
(1402, NULL, NULL, NULL, 254, 'SAC', 163.00, 1.00, 162.00, 77, 2, 2),
(1403, NULL, NULL, NULL, 254, 'SAC', 51.00, 17.00, 34.00, 98, 2, 2),
(1404, NULL, NULL, NULL, 254, 'SAC', 10.00, 1.00, 9.00, 99, 2, 2),
(1405, NULL, NULL, NULL, NULL, 'INA', 6.00, 50.00, 56.00, 15, 2, 2),
(1406, NULL, NULL, NULL, NULL, 'INA', 1003.00, 20.00, 1023.00, 16, 2, 2),
(1407, NULL, NULL, NULL, NULL, 'INA', 8.00, 10.00, 18.00, 63, 2, 2),
(1408, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 65, 2, 2),
(1409, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 61, 2, 2),
(1410, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 73, 2, 2),
(1411, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 75, 2, 2),
(1412, NULL, NULL, NULL, 255, 'SAC', 0.00, 4.00, -4.00, 13, 2, 2),
(1413, NULL, NULL, NULL, 255, 'SAC', 60.00, 2.00, 58.00, 14, 2, 2),
(1414, NULL, NULL, NULL, 255, 'SAC', 56.00, 25.00, 31.00, 15, 2, 2),
(1415, NULL, NULL, NULL, 255, 'SAC', 1023.00, 2.00, 1021.00, 16, 2, 2),
(1416, NULL, NULL, NULL, 255, 'SAC', 159.00, 15.00, 144.00, 22, 2, 2),
(1417, NULL, NULL, NULL, 255, 'SAC', 79.00, 3.00, 76.00, 24, 2, 2),
(1418, NULL, NULL, NULL, 255, 'SAC', 57.00, 5.00, 52.00, 33, 2, 2),
(1419, NULL, NULL, NULL, 255, 'SAC', 7.00, 1.00, 6.00, 60, 2, 2),
(1420, NULL, NULL, NULL, 255, 'SAC', 2.00, 2.00, 0.00, 61, 2, 2),
(1421, NULL, NULL, NULL, 255, 'SAC', 18.00, 10.00, 8.00, 63, 2, 2),
(1422, NULL, NULL, NULL, 255, 'SAC', 10.00, 10.00, 0.00, 65, 2, 2),
(1423, NULL, NULL, NULL, 255, 'SAC', 1.00, 1.00, 0.00, 73, 2, 2),
(1424, NULL, NULL, NULL, 255, 'SAC', 1.00, 1.00, 0.00, 75, 2, 2),
(1425, NULL, NULL, NULL, 255, 'SAC', 162.00, 6.00, 156.00, 77, 2, 2),
(1426, NULL, NULL, NULL, 255, 'SAC', 34.00, 22.00, 12.00, 98, 2, 2),
(1427, NULL, NULL, NULL, 255, 'SAC', 9.00, 2.00, 7.00, 99, 2, 2),
(1428, NULL, NULL, NULL, NULL, 'INA', 12.00, 22.00, 34.00, 98, 2, 2),
(1429, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 13, 2, 2),
(1430, NULL, NULL, NULL, NULL, 'INA', 31.00, 25.00, 56.00, 15, 2, 2),
(1431, NULL, NULL, NULL, NULL, 'INA', 1021.00, 2.00, 1023.00, 16, 2, 2),
(1432, NULL, NULL, NULL, NULL, 'INA', 8.00, 10.00, 18.00, 63, 2, 2),
(1433, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 65, 2, 2),
(1434, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 61, 2, 2),
(1435, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 73, 2, 2),
(1436, NULL, NULL, NULL, NULL, 'INA', 58.00, 2.00, 60.00, 14, 2, 2),
(1437, NULL, NULL, NULL, NULL, 'INA', 6.00, 1.00, 7.00, 60, 2, 2),
(1438, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 75, 2, 2),
(1439, NULL, NULL, NULL, NULL, 'INA', 7.00, 2.00, 9.00, 99, 2, 2),
(1440, NULL, NULL, NULL, NULL, 'INA', 144.00, 15.00, 159.00, 22, 2, 2),
(1441, NULL, NULL, NULL, NULL, 'INA', 156.00, 6.00, 162.00, 77, 2, 2),
(1442, NULL, NULL, NULL, NULL, 'INA', 76.00, 3.00, 79.00, 24, 2, 2),
(1443, NULL, NULL, NULL, NULL, 'INA', 52.00, 5.00, 57.00, 33, 2, 2),
(1444, NULL, NULL, NULL, 256, 'SAC', 0.00, 4.00, -4.00, 13, 2, 2),
(1445, NULL, NULL, NULL, 256, 'SAC', 60.00, 2.00, 58.00, 14, 2, 2),
(1446, NULL, NULL, NULL, 256, 'SAC', 56.00, 25.00, 31.00, 15, 2, 2),
(1447, NULL, NULL, NULL, 256, 'SAC', 1023.00, 2.00, 1021.00, 16, 2, 2),
(1448, NULL, NULL, NULL, 256, 'SAC', 159.00, 15.00, 144.00, 22, 2, 2),
(1449, NULL, NULL, NULL, 256, 'SAC', 79.00, 3.00, 76.00, 24, 2, 2),
(1450, NULL, NULL, NULL, 256, 'SAC', 57.00, 5.00, 52.00, 33, 2, 2),
(1451, NULL, NULL, NULL, 256, 'SAC', 7.00, 1.00, 6.00, 60, 2, 2),
(1452, NULL, NULL, NULL, 256, 'SAC', 2.00, 2.00, 0.00, 61, 2, 2),
(1453, NULL, NULL, NULL, 256, 'SAC', 18.00, 10.00, 8.00, 63, 2, 2),
(1454, NULL, NULL, NULL, 256, 'SAC', 10.00, 10.00, 0.00, 65, 2, 2),
(1455, NULL, NULL, NULL, 256, 'SAC', 1.00, 1.00, 0.00, 73, 2, 2),
(1456, NULL, NULL, NULL, 256, 'SAC', 1.00, 1.00, 0.00, 75, 2, 2),
(1457, NULL, NULL, NULL, 256, 'SAC', 162.00, 6.00, 156.00, 77, 2, 2),
(1458, NULL, NULL, NULL, 256, 'SAC', 34.00, 22.00, 12.00, 98, 2, 2),
(1459, NULL, NULL, NULL, 256, 'SAC', 9.00, 2.00, 7.00, 99, 2, 2),
(1460, NULL, NULL, NULL, NULL, 'INA', 2.00, 10.00, 12.00, 19, 2, 2),
(1461, NULL, NULL, NULL, 257, 'SAC', 12.00, 3.00, 9.00, 19, 2, 2),
(1462, NULL, NULL, NULL, 257, 'SAC', 6.00, 1.00, 5.00, 60, 2, 2),
(1463, NULL, NULL, NULL, NULL, 'INA', 6.00, 10.00, 16.00, 1, 2, 2),
(1464, NULL, NULL, NULL, 258, 'SAC', 16.00, 12.00, 4.00, 1, 2, 2),
(1465, NULL, NULL, NULL, 258, 'SAC', 58.00, 5.00, 53.00, 14, 2, 2),
(1466, NULL, NULL, NULL, 258, 'SAC', 31.00, 10.00, 21.00, 15, 2, 2),
(1467, NULL, NULL, NULL, 258, 'SAC', 508.00, 2.00, 506.00, 23, 2, 2),
(1468, NULL, NULL, NULL, 258, 'SAC', 132.00, 1.00, 131.00, 48, 2, 2),
(1469, NULL, NULL, NULL, 258, 'SAC', 5.00, 1.00, 4.00, 60, 2, 2),
(1470, NULL, NULL, NULL, 258, 'SAC', 7.00, 2.00, 5.00, 99, 2, 2),
(1471, NULL, NULL, NULL, 259, 'SAC', 21.00, 1.00, 20.00, 15, 2, 2),
(1472, NULL, NULL, NULL, 259, 'SAC', 1021.00, 1.00, 1020.00, 16, 2, 2),
(1473, NULL, NULL, NULL, NULL, 'INA', 9.00, 20.00, 29.00, 19, 2, 2),
(1474, NULL, NULL, NULL, 260, 'SAC', 20.00, 4.00, 16.00, 15, 2, 2),
(1475, NULL, NULL, NULL, 260, 'SAC', 29.00, 15.00, 14.00, 19, 2, 2),
(1476, NULL, NULL, NULL, 260, 'SAC', 144.00, 7.00, 137.00, 22, 2, 2),
(1477, NULL, NULL, NULL, 260, 'SAC', 231.00, 5.00, 226.00, 91, 2, 2),
(1478, NULL, NULL, NULL, 260, 'SAC', 12.00, 3.00, 9.00, 98, 2, 2),
(1479, NULL, NULL, NULL, NULL, 'INA', 14.00, 20.00, 34.00, 19, 2, 2),
(1480, NULL, NULL, NULL, 261, 'SAC', 16.00, 4.00, 12.00, 15, 2, 2),
(1481, NULL, NULL, NULL, 261, 'SAC', 34.00, 15.00, 19.00, 19, 2, 2),
(1482, NULL, NULL, NULL, 261, 'SAC', 137.00, 7.00, 130.00, 22, 2, 2),
(1483, NULL, NULL, NULL, 261, 'SAC', 226.00, 5.00, 221.00, 91, 2, 2),
(1484, NULL, NULL, NULL, 261, 'SAC', 9.00, 3.00, 6.00, 98, 2, 2),
(1485, NULL, NULL, NULL, 262, 'SAC', 12.00, 4.00, 8.00, 15, 2, 2),
(1486, NULL, NULL, NULL, 262, 'SAC', 19.00, 15.00, 4.00, 19, 2, 2),
(1487, NULL, NULL, NULL, 262, 'SAC', 130.00, 7.00, 123.00, 22, 2, 2),
(1488, NULL, NULL, NULL, 262, 'SAC', 221.00, 5.00, 216.00, 91, 2, 2),
(1489, NULL, NULL, NULL, 262, 'SAC', 6.00, 3.00, 3.00, 98, 2, 2),
(1490, NULL, NULL, NULL, NULL, 'INA', 3.00, 100.00, 103.00, 98, 2, 2),
(1491, NULL, NULL, NULL, NULL, 'INA', 8.00, 80.00, 88.00, 15, 2, 2),
(1492, NULL, NULL, NULL, 263, 'SAC', 53.00, 15.00, 38.00, 14, 2, 2),
(1493, NULL, NULL, NULL, 263, 'SAC', 88.00, 55.00, 33.00, 15, 2, 2),
(1494, NULL, NULL, NULL, 263, 'SAC', 76.00, 10.00, 66.00, 24, 2, 2),
(1495, NULL, NULL, NULL, 263, 'SAC', 131.00, 10.00, 121.00, 48, 2, 2),
(1496, NULL, NULL, NULL, 263, 'SAC', 4.00, 2.00, 2.00, 60, 2, 2),
(1497, NULL, NULL, NULL, 263, 'SAC', 103.00, 50.00, 53.00, 98, 2, 2),
(1498, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 4, 2, 2),
(1499, NULL, NULL, NULL, NULL, 'INA', 33.00, 80.00, 113.00, 15, 2, 2),
(1500, NULL, NULL, NULL, 264, 'SAC', 38.00, 15.00, 23.00, 14, 2, 2),
(1501, NULL, NULL, NULL, 264, 'SAC', 113.00, 55.00, 58.00, 15, 2, 2),
(1502, NULL, NULL, NULL, 264, 'SAC', 66.00, 10.00, 56.00, 24, 2, 2),
(1503, NULL, NULL, NULL, 264, 'SAC', 121.00, 10.00, 111.00, 48, 2, 2),
(1504, NULL, NULL, NULL, 264, 'SAC', 2.00, 2.00, 0.00, 60, 2, 2),
(1505, NULL, NULL, NULL, 264, 'SAC', 53.00, 50.00, 3.00, 98, 2, 2),
(1506, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 60, 2, 2),
(1507, NULL, NULL, NULL, NULL, 'IN1', 0.00, 4.00, 4.00, 157, 1, 2),
(1508, NULL, NULL, NULL, NULL, 'IN1', 0.00, 100.00, 100.00, 158, 1, 2),
(1509, NULL, NULL, NULL, NULL, 'IN1', 0.00, 30.00, 30.00, 159, 1, 2),
(1510, NULL, NULL, NULL, NULL, 'IN1', 0.00, 40.00, 40.00, 160, 1, 2),
(1511, NULL, NULL, NULL, NULL, 'INA', 3.00, 50.00, 53.00, 98, 2, 2),
(1512, NULL, NULL, NULL, NULL, 'SAA', 100.00, 99.00, 1.00, 158, 2, 2),
(1513, NULL, NULL, NULL, NULL, 'SAA', 30.00, 29.00, 1.00, 159, 2, 2),
(1514, NULL, NULL, NULL, NULL, 'SAA', 40.00, 39.00, 1.00, 160, 2, 2),
(1515, NULL, NULL, NULL, 265, 'SAC', 10.00, 1.00, 9.00, 60, 2, 2),
(1516, NULL, NULL, NULL, 265, 'SAC', 53.00, 7.00, 46.00, 98, 2, 2),
(1517, NULL, NULL, NULL, 265, 'SAC', 4.00, 2.00, 2.00, 154, 2, 2),
(1518, NULL, NULL, NULL, 265, 'SAC', 4.00, 4.00, 0.00, 157, 2, 2),
(1519, NULL, NULL, NULL, 265, 'SAC', 1.00, 1.00, 0.00, 158, 2, 2),
(1520, NULL, NULL, NULL, 265, 'SAC', 1.00, 1.00, 0.00, 159, 2, 2),
(1521, NULL, NULL, NULL, 265, 'SAC', 1.00, 1.00, 0.00, 160, 2, 2),
(1522, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 13, 2, 2),
(1523, NULL, NULL, NULL, NULL, 'INA', 4.00, 10.00, 14.00, 1, 2, 2);
INSERT INTO `movimiento` (`mov_id_movimiento`, `ind_id_ingreso_detalle`, `sad_id_salida_detalle`, `ing_id_ingreso`, `sal_id_salida`, `mov_tipo`, `mov_cantidad_anterior`, `mov_cantidad_entrante`, `mov_cantidad_actual`, `pro_id_producto`, `est_id_estado`, `usu_id_usuario`) VALUES
(1524, NULL, NULL, NULL, NULL, 'INA', 14.00, 100.00, 114.00, 1, 2, 2),
(1525, NULL, NULL, NULL, NULL, 'INA', 2.00, 50.00, 52.00, 57, 2, 2),
(1526, NULL, NULL, NULL, NULL, 'INA', 18.00, 20.00, 38.00, 58, 2, 2),
(1527, NULL, NULL, NULL, 266, 'SAC', 114.00, 100.00, 14.00, 1, 2, 2),
(1528, NULL, NULL, NULL, 266, 'SAC', 52.00, 5.00, 47.00, 57, 2, 2),
(1529, NULL, NULL, NULL, 266, 'SAC', 38.00, 10.00, 28.00, 58, 2, 2),
(1530, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 37, 2, 2),
(1531, NULL, NULL, NULL, 267, 'SAC', 58.00, 3.00, 55.00, 15, 2, 2),
(1532, NULL, NULL, NULL, 267, 'SAC', 8.00, 1.00, 7.00, 18, 2, 2),
(1533, NULL, NULL, NULL, 267, 'SAC', 2.00, 1.00, 1.00, 37, 2, 2),
(1534, NULL, NULL, NULL, 267, 'SAC', 46.00, 3.00, 43.00, 98, 2, 2),
(1535, NULL, NULL, NULL, 267, 'SAC', 2.00, 1.00, 1.00, 100, 2, 2),
(1536, NULL, NULL, NULL, 267, 'SAC', 8.00, 1.00, 7.00, 136, 2, 2),
(1537, NULL, NULL, NULL, 268, 'SAC', 111.00, 3.00, 108.00, 48, 2, 2),
(1538, NULL, NULL, NULL, NULL, 'INA', 4.00, 20.00, 24.00, 19, 2, 2),
(1539, NULL, NULL, NULL, 269, 'SAC', 55.00, 3.00, 52.00, 15, 2, 2),
(1540, NULL, NULL, NULL, 269, 'SAC', 24.00, 15.00, 9.00, 19, 2, 2),
(1541, NULL, NULL, NULL, 269, 'SAC', 123.00, 7.00, 116.00, 22, 2, 2),
(1542, NULL, NULL, NULL, 269, 'SAC', 216.00, 5.00, 211.00, 91, 2, 2),
(1543, NULL, NULL, NULL, 269, 'SAC', 43.00, 3.00, 40.00, 98, 2, 2),
(1544, NULL, NULL, NULL, 270, 'SAC', 23.00, 2.00, 21.00, 14, 2, 2),
(1545, NULL, NULL, NULL, 270, 'SAC', 52.00, 10.00, 42.00, 15, 2, 2),
(1546, NULL, NULL, NULL, 270, 'SAC', 116.00, 5.00, 111.00, 22, 2, 2),
(1547, NULL, NULL, NULL, 270, 'SAC', 0.00, 0.00, 0.00, 36, 2, 2),
(1548, NULL, NULL, NULL, 270, 'SAC', 50.00, 3.00, 47.00, 38, 2, 2),
(1549, NULL, NULL, NULL, 270, 'SAC', 40.00, 13.00, 27.00, 98, 2, 2),
(1550, NULL, NULL, NULL, 270, 'SAC', 5.00, 2.00, 3.00, 99, 2, 2),
(1551, NULL, NULL, NULL, 271, 'SAC', 0.00, 2.00, -2.00, 13, 2, 2),
(1552, NULL, NULL, NULL, 271, 'SAC', 1020.00, 4.00, 1016.00, 16, 2, 2),
(1553, NULL, NULL, NULL, 271, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(1554, NULL, NULL, NULL, 271, 'SAC', 0.00, 0.00, 0.00, 49, 2, 2),
(1555, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 149, 2, 2),
(1556, NULL, NULL, NULL, NULL, 'INA', 0.00, 3.00, 3.00, 39, 2, 2),
(1557, NULL, NULL, NULL, 272, 'SAC', 3.00, 1.00, 2.00, 39, 2, 2),
(1558, NULL, NULL, NULL, 272, 'SAC', 129.00, 1.00, 128.00, 88, 2, 2),
(1559, NULL, NULL, NULL, 272, 'SAC', 1.00, 1.00, 0.00, 149, 2, 2),
(1560, NULL, NULL, NULL, 273, 'SAC', 1016.00, 1.00, 1015.00, 16, 2, 2),
(1561, NULL, NULL, NULL, 273, 'SAC', 140.00, 1.00, 139.00, 80, 2, 2),
(1562, NULL, NULL, NULL, 273, 'SAC', 211.00, 1.00, 210.00, 91, 2, 2),
(1563, NULL, NULL, NULL, 274, 'SAC', 210.00, 1.00, 209.00, 91, 2, 2),
(1564, NULL, NULL, NULL, 275, 'SAC', 0.00, 1.00, -1.00, 49, 2, 2),
(1565, NULL, NULL, NULL, 275, 'SAC', 28.00, 1.00, 27.00, 58, 2, 2),
(1566, NULL, NULL, NULL, 276, 'SAC', 0.00, 0.00, 0.00, 13, 2, 2),
(1567, NULL, NULL, NULL, 276, 'SAC', 2.00, 1.00, 1.00, 39, 2, 2),
(1568, NULL, NULL, NULL, 277, 'SAC', 0.00, 1.00, -1.00, 13, 2, 2),
(1569, NULL, NULL, NULL, 278, 'SAC', 42.00, 1.00, 41.00, 15, 2, 2),
(1570, NULL, NULL, NULL, 278, 'SAC', 111.00, 1.00, 110.00, 22, 2, 2),
(1571, NULL, NULL, NULL, 278, 'SAC', 0.00, 1.00, -1.00, 34, 2, 2),
(1572, NULL, NULL, NULL, 278, 'SAC', 0.00, 1.00, -1.00, 35, 2, 2),
(1573, NULL, NULL, NULL, 278, 'SAC', 1.00, 1.00, 0.00, 37, 2, 2),
(1574, NULL, NULL, NULL, 278, 'SAC', 1.00, 1.00, 0.00, 39, 2, 2),
(1575, NULL, NULL, NULL, 278, 'SAC', 0.00, 1.00, -1.00, 42, 2, 2),
(1576, NULL, NULL, NULL, 278, 'SAC', 0.00, 0.00, 0.00, 49, 2, 2),
(1577, NULL, NULL, NULL, 278, 'SAC', 8.00, 1.00, 7.00, 59, 2, 2),
(1578, NULL, NULL, NULL, 278, 'SAC', 8.00, 1.00, 7.00, 63, 2, 2),
(1579, NULL, NULL, NULL, 278, 'SAC', 27.00, 1.00, 26.00, 98, 2, 2),
(1580, NULL, NULL, NULL, 278, 'SAC', 1.00, 1.00, 0.00, 100, 2, 2),
(1581, NULL, NULL, NULL, 279, 'SAC', 41.00, 1.00, 40.00, 15, 2, 2),
(1582, NULL, NULL, NULL, 279, 'SAC', 7.00, 1.00, 6.00, 18, 2, 2),
(1583, NULL, NULL, NULL, 279, 'SAC', 7.00, 1.00, 6.00, 63, 2, 2),
(1584, NULL, NULL, NULL, 280, 'SAC', 40.00, 1.00, 39.00, 15, 2, 2),
(1585, NULL, NULL, NULL, 280, 'SAC', 90.00, 1.00, 89.00, 81, 2, 2),
(1586, NULL, NULL, NULL, 280, 'SAC', 128.00, 1.00, 127.00, 88, 2, 2),
(1587, NULL, NULL, NULL, 280, 'SAC', 26.00, 1.00, 25.00, 98, 2, 2),
(1588, NULL, NULL, NULL, 281, 'SAC', 21.00, 1.00, 20.00, 14, 2, 2),
(1589, NULL, NULL, NULL, 281, 'SAC', 39.00, 1.00, 38.00, 15, 2, 2),
(1590, NULL, NULL, NULL, 281, 'SAC', 506.00, 1.00, 505.00, 23, 2, 2),
(1591, NULL, NULL, NULL, 281, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(1592, NULL, NULL, NULL, 281, 'SAC', 25.00, 2.00, 23.00, 98, 2, 2),
(1593, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 62, 2, 2),
(1594, NULL, NULL, NULL, 282, 'SAC', 27.00, 1.00, 26.00, 58, 2, 2),
(1595, NULL, NULL, NULL, 282, 'SAC', 7.00, 1.00, 6.00, 59, 2, 2),
(1596, NULL, NULL, NULL, 282, 'SAC', 1.00, 1.00, 0.00, 62, 2, 2),
(1597, NULL, NULL, NULL, 283, 'SAC', 38.00, 1.00, 37.00, 15, 2, 2),
(1598, NULL, NULL, NULL, 283, 'SAC', 56.00, 1.00, 55.00, 24, 2, 2),
(1599, NULL, NULL, NULL, 283, 'SAC', 6.00, 1.00, 5.00, 59, 2, 2),
(1600, NULL, NULL, NULL, 283, 'SAC', 89.00, 1.00, 88.00, 81, 2, 2),
(1601, NULL, NULL, NULL, 283, 'SAC', 48.00, 1.00, 47.00, 97, 2, 2),
(1602, NULL, NULL, NULL, 283, 'SAC', 23.00, 3.00, 20.00, 98, 2, 2),
(1603, NULL, NULL, NULL, 284, 'SAC', 110.00, 3.00, 107.00, 22, 2, 2),
(1604, NULL, NULL, NULL, 284, 'SAC', 20.00, 2.00, 18.00, 98, 2, 2),
(1605, NULL, NULL, NULL, 285, 'SAC', 20.00, 1.00, 19.00, 14, 2, 2),
(1606, NULL, NULL, NULL, 285, 'SAC', 37.00, 3.00, 34.00, 15, 2, 2),
(1607, NULL, NULL, NULL, 285, 'SAC', 18.00, 2.00, 16.00, 98, 2, 2),
(1608, NULL, NULL, NULL, 286, 'SAC', 47.00, 1.00, 46.00, 57, 2, 2),
(1609, NULL, NULL, NULL, 287, 'SAC', 19.00, 1.00, 18.00, 14, 2, 2),
(1610, NULL, NULL, NULL, 287, 'SAC', 34.00, 3.00, 31.00, 15, 2, 2),
(1611, NULL, NULL, NULL, 287, 'SAC', 107.00, 1.00, 106.00, 22, 2, 2),
(1612, NULL, NULL, NULL, 287, 'SAC', 0.00, 1.00, -1.00, 34, 2, 2),
(1613, NULL, NULL, NULL, 287, 'SAC', 108.00, 1.00, 107.00, 48, 2, 2),
(1614, NULL, NULL, NULL, 287, 'SAC', 6.00, 1.00, 5.00, 63, 2, 2),
(1615, NULL, NULL, NULL, 287, 'SAC', 16.00, 3.00, 13.00, 98, 2, 2),
(1616, NULL, NULL, NULL, 288, 'SAC', 0.00, 0.00, 0.00, 13, 2, 2),
(1617, NULL, NULL, NULL, 288, 'SAC', 1015.00, 4.00, 1011.00, 16, 2, 2),
(1618, NULL, NULL, NULL, 288, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(1619, NULL, NULL, NULL, 288, 'SAC', 0.00, 1.00, -1.00, 49, 2, 2),
(1620, NULL, NULL, NULL, 289, 'SAC', 0.00, 1.00, -1.00, 13, 2, 2),
(1621, NULL, NULL, NULL, 289, 'SAC', 1011.00, 1.00, 1010.00, 16, 2, 2),
(1622, NULL, NULL, NULL, 289, 'SAC', 106.00, 1.00, 105.00, 22, 2, 2),
(1623, NULL, NULL, NULL, 289, 'SAC', 3.00, 1.00, 2.00, 99, 2, 2),
(1624, NULL, NULL, NULL, 290, 'SAC', 31.00, 3.00, 28.00, 15, 2, 2),
(1625, NULL, NULL, NULL, 290, 'SAC', 6.00, 1.00, 5.00, 18, 2, 2),
(1626, NULL, NULL, NULL, 290, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(1627, NULL, NULL, NULL, 290, 'SAC', 0.00, 2.00, -2.00, 46, 2, 2),
(1628, NULL, NULL, NULL, 290, 'SAC', 107.00, 1.00, 106.00, 48, 2, 2),
(1629, NULL, NULL, NULL, 290, 'SAC', 5.00, 1.00, 4.00, 59, 2, 2),
(1630, NULL, NULL, NULL, 290, 'SAC', 13.00, 3.00, 10.00, 98, 2, 2),
(1631, NULL, NULL, NULL, 291, 'SAC', 18.00, 1.00, 17.00, 14, 2, 2),
(1632, NULL, NULL, NULL, 291, 'SAC', 28.00, 1.00, 27.00, 15, 2, 2),
(1633, NULL, NULL, NULL, 291, 'SAC', 0.00, 1.00, -1.00, 34, 2, 2),
(1634, NULL, NULL, NULL, 291, 'SAC', 0.00, 1.00, -1.00, 44, 2, 2),
(1635, NULL, NULL, NULL, 291, 'SAC', 0.00, 0.00, 0.00, 49, 2, 2),
(1636, NULL, NULL, NULL, 291, 'SAC', 46.00, 1.00, 45.00, 57, 2, 2),
(1637, NULL, NULL, NULL, 291, 'SAC', 10.00, 1.00, 9.00, 98, 2, 2),
(1638, NULL, NULL, NULL, NULL, 'INA', 9.00, 50.00, 59.00, 98, 2, 2),
(1639, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 49, 2, 2),
(1640, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 13, 2, 2),
(1641, NULL, NULL, NULL, 292, 'SAC', 0.00, 15.00, -15.00, 13, 2, 2),
(1642, NULL, NULL, NULL, 292, 'SAC', 27.00, 5.00, 22.00, 15, 2, 2),
(1643, NULL, NULL, NULL, 292, 'SAC', 1010.00, 10.00, 1000.00, 16, 2, 2),
(1644, NULL, NULL, NULL, 292, 'SAC', 5.00, 5.00, 0.00, 18, 2, 2),
(1645, NULL, NULL, NULL, 292, 'SAC', 106.00, 5.00, 101.00, 48, 2, 2),
(1646, NULL, NULL, NULL, 292, 'SAC', 10.00, 5.00, 5.00, 49, 2, 2),
(1647, NULL, NULL, NULL, 292, 'SAC', 26.00, 5.00, 21.00, 58, 2, 2),
(1648, NULL, NULL, NULL, 292, 'SAC', 59.00, 15.00, 44.00, 98, 2, 2),
(1649, NULL, NULL, NULL, NULL, 'INA', 6.00, 1.00, 7.00, 122, 2, 2),
(1650, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 65, 2, 2),
(1651, NULL, NULL, NULL, 293, 'SAC', 505.00, 3.00, 502.00, 23, 2, 2),
(1652, NULL, NULL, NULL, 293, 'SAC', 115.00, 12.00, 103.00, 25, 2, 2),
(1653, NULL, NULL, NULL, 293, 'SAC', 101.00, 4.00, 97.00, 48, 2, 2),
(1654, NULL, NULL, NULL, 293, 'SAC', 5.00, 5.00, 0.00, 63, 2, 2),
(1655, NULL, NULL, NULL, 293, 'SAC', 5.00, 1.00, 4.00, 65, 2, 2),
(1656, NULL, NULL, NULL, 293, 'SAC', 44.00, 18.00, 26.00, 98, 2, 2),
(1657, NULL, NULL, NULL, 293, 'SAC', 7.00, 5.00, 2.00, 122, 2, 2),
(1658, NULL, NULL, NULL, NULL, 'INA', 22.00, 150.00, 172.00, 15, 2, 2),
(1659, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 34, 2, 2),
(1660, NULL, NULL, NULL, NULL, 'INA', 9.00, 30.00, 39.00, 19, 2, 2),
(1661, NULL, NULL, NULL, 294, 'SAC', 172.00, 150.00, 22.00, 15, 2, 2),
(1662, NULL, NULL, NULL, 294, 'SAC', 39.00, 30.00, 9.00, 19, 2, 2),
(1663, NULL, NULL, NULL, 294, 'SAC', 0.00, 40.00, -40.00, 34, 2, 2),
(1664, NULL, NULL, NULL, 295, 'SAC', 17.00, 1.00, 16.00, 14, 2, 2),
(1665, NULL, NULL, NULL, 295, 'SAC', 22.00, 3.00, 19.00, 15, 2, 2),
(1666, NULL, NULL, NULL, 295, 'SAC', 105.00, 1.00, 104.00, 22, 2, 2),
(1667, NULL, NULL, NULL, 295, 'SAC', 97.00, 2.00, 95.00, 48, 2, 2),
(1668, NULL, NULL, NULL, 295, 'SAC', 26.00, 2.00, 24.00, 98, 2, 2),
(1669, NULL, NULL, NULL, 295, 'SAC', 2.00, 1.00, 1.00, 99, 2, 2),
(1670, NULL, NULL, NULL, 296, 'SAC', 16.00, 1.00, 15.00, 14, 2, 2),
(1671, NULL, NULL, NULL, 296, 'SAC', 19.00, 7.00, 12.00, 15, 2, 2),
(1672, NULL, NULL, NULL, 296, 'SAC', 9.00, 2.00, 7.00, 19, 2, 2),
(1673, NULL, NULL, NULL, 296, 'SAC', 55.00, 1.00, 54.00, 24, 2, 2),
(1674, NULL, NULL, NULL, 296, 'SAC', 24.00, 5.00, 19.00, 98, 2, 2),
(1675, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 63, 2, 2),
(1676, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 18, 2, 2),
(1677, NULL, NULL, NULL, 297, 'SAC', 10.00, 1.00, 9.00, 18, 2, 2),
(1678, NULL, NULL, NULL, 297, 'SAC', 10.00, 1.00, 9.00, 63, 2, 2),
(1679, NULL, NULL, NULL, 297, 'SAC', 4.00, 1.00, 3.00, 65, 2, 2),
(1680, NULL, NULL, NULL, NULL, 'INA', 1000.00, 10.00, 1010.00, 16, 2, 2),
(1681, NULL, NULL, NULL, 298, 'SAC', 15.00, 1.00, 14.00, 14, 2, 2),
(1682, NULL, NULL, NULL, 298, 'SAC', 12.00, 1.00, 11.00, 15, 2, 2),
(1683, NULL, NULL, NULL, 298, 'SAC', 1010.00, 1.00, 1009.00, 16, 2, 2),
(1684, NULL, NULL, NULL, 298, 'SAC', 54.00, 1.00, 53.00, 24, 2, 2),
(1685, NULL, NULL, NULL, 298, 'SAC', 0.00, 0.00, 0.00, 35, 2, 2),
(1686, NULL, NULL, NULL, 298, 'SAC', 95.00, 2.00, 93.00, 48, 2, 2),
(1687, NULL, NULL, NULL, 298, 'SAC', 19.00, 2.00, 17.00, 98, 2, 2),
(1688, NULL, NULL, NULL, NULL, 'INA', 11.00, 30.00, 41.00, 15, 2, 2),
(1689, NULL, NULL, NULL, NULL, 'INA', 17.00, 50.00, 67.00, 98, 2, 2),
(1690, NULL, NULL, NULL, NULL, 'INA', 14.00, 50.00, 64.00, 1, 2, 2),
(1691, NULL, NULL, NULL, NULL, 'INA', 7.00, 20.00, 27.00, 19, 2, 2),
(1692, NULL, NULL, NULL, 299, 'SAC', 64.00, 14.00, 50.00, 1, 2, 2),
(1693, NULL, NULL, NULL, 299, 'SAC', 14.00, 4.00, 10.00, 14, 2, 2),
(1694, NULL, NULL, NULL, 299, 'SAC', 41.00, 8.00, 33.00, 15, 2, 2),
(1695, NULL, NULL, NULL, 299, 'SAC', 27.00, 5.00, 22.00, 19, 2, 2),
(1696, NULL, NULL, NULL, 299, 'SAC', 53.00, 1.00, 52.00, 24, 2, 2),
(1697, NULL, NULL, NULL, 299, 'SAC', 103.00, 2.00, 101.00, 25, 2, 2),
(1698, NULL, NULL, NULL, 299, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(1699, NULL, NULL, NULL, 299, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(1700, NULL, NULL, NULL, 299, 'SAC', 0.00, 0.00, 0.00, 46, 2, 2),
(1701, NULL, NULL, NULL, NULL, 'INA', 1.00, 20.00, 21.00, 99, 2, 2),
(1702, NULL, NULL, NULL, 300, 'SAC', 10.00, 2.00, 8.00, 14, 2, 2),
(1703, NULL, NULL, NULL, 300, 'SAC', 33.00, 11.00, 22.00, 15, 2, 2),
(1704, NULL, NULL, NULL, 300, 'SAC', 104.00, 7.00, 97.00, 22, 2, 2),
(1705, NULL, NULL, NULL, 300, 'SAC', 502.00, 5.00, 497.00, 23, 2, 2),
(1706, NULL, NULL, NULL, 300, 'SAC', 52.00, 2.00, 50.00, 24, 2, 2),
(1707, NULL, NULL, NULL, 300, 'SAC', 101.00, 3.00, 98.00, 25, 2, 2),
(1708, NULL, NULL, NULL, 300, 'SAC', 93.00, 2.00, 91.00, 48, 2, 2),
(1709, NULL, NULL, NULL, 300, 'SAC', 0.00, 0.00, 0.00, 50, 2, 2),
(1710, NULL, NULL, NULL, 300, 'SAC', 67.00, 12.00, 55.00, 98, 2, 2),
(1711, NULL, NULL, NULL, 300, 'SAC', 21.00, 2.00, 19.00, 99, 2, 2),
(1712, NULL, NULL, NULL, 301, 'SAC', 22.00, 3.00, 19.00, 15, 2, 2),
(1713, NULL, NULL, NULL, 301, 'SAC', 97.00, 3.00, 94.00, 22, 2, 2),
(1714, NULL, NULL, NULL, 301, 'SAC', 0.00, 1.00, -1.00, 44, 2, 2),
(1715, NULL, NULL, NULL, 301, 'SAC', 91.00, 1.00, 90.00, 48, 2, 2),
(1716, NULL, NULL, NULL, 301, 'SAC', 45.00, 1.00, 44.00, 57, 2, 2),
(1717, NULL, NULL, NULL, 301, 'SAC', 55.00, 1.00, 54.00, 98, 2, 2),
(1718, NULL, NULL, NULL, 301, 'SAC', 7.00, 1.00, 6.00, 136, 2, 2),
(1719, NULL, NULL, NULL, 302, 'SAC', 44.00, 5.00, 39.00, 57, 2, 2),
(1720, NULL, NULL, NULL, 303, 'SAC', 0.00, 50.00, -50.00, 4, 2, 2),
(1721, NULL, NULL, NULL, 304, 'SAC', 1009.00, 1.00, 1008.00, 16, 2, 2),
(1722, NULL, NULL, NULL, 304, 'SAC', 0.00, 1.00, -1.00, 35, 2, 2),
(1723, NULL, NULL, NULL, 304, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(1724, NULL, NULL, NULL, 304, 'SAC', 54.00, 1.00, 53.00, 98, 2, 2),
(1725, NULL, NULL, NULL, NULL, 'INA', 0.00, 20.00, 20.00, 100, 2, 2),
(1726, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 51, 2, 2),
(1727, NULL, NULL, NULL, 305, 'SAC', 19.00, 3.00, 16.00, 15, 2, 2),
(1728, NULL, NULL, NULL, 305, 'SAC', 497.00, 3.00, 494.00, 23, 2, 2),
(1729, NULL, NULL, NULL, 305, 'SAC', 0.00, 1.00, -1.00, 34, 2, 2),
(1730, NULL, NULL, NULL, 305, 'SAC', 0.00, 0.00, 0.00, 42, 2, 2),
(1731, NULL, NULL, NULL, 305, 'SAC', 90.00, 1.00, 89.00, 48, 2, 2),
(1732, NULL, NULL, NULL, 305, 'SAC', 39.00, 5.00, 34.00, 57, 2, 2),
(1733, NULL, NULL, NULL, 305, 'SAC', 53.00, 10.00, 43.00, 98, 2, 2),
(1734, NULL, NULL, NULL, 305, 'SAC', 19.00, 1.00, 18.00, 99, 2, 2),
(1735, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 156, 2, 2),
(1736, NULL, NULL, NULL, 306, 'SAC', 22.00, 3.00, 19.00, 19, 2, 2),
(1737, NULL, NULL, NULL, 306, 'SAC', 34.00, 1.00, 33.00, 57, 2, 2),
(1738, NULL, NULL, NULL, 306, 'SAC', 2.00, 2.00, 0.00, 156, 2, 2),
(1739, NULL, NULL, NULL, 307, 'SAC', 16.00, 1.00, 15.00, 15, 2, 2),
(1740, NULL, NULL, NULL, 308, 'SAC', 15.00, 1.00, 14.00, 15, 2, 2),
(1741, NULL, NULL, NULL, 308, 'SAC', 33.00, 1.00, 32.00, 57, 2, 2),
(1742, NULL, NULL, NULL, 309, 'SAC', 14.00, 1.00, 13.00, 15, 2, 2),
(1743, NULL, NULL, NULL, 309, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(1744, NULL, NULL, NULL, 309, 'SAC', 32.00, 1.00, 31.00, 57, 2, 2),
(1745, NULL, NULL, NULL, 310, 'SAC', 0.00, 1.00, -1.00, 36, 2, 2),
(1746, NULL, NULL, NULL, 310, 'SAC', 47.00, 1.00, 46.00, 38, 2, 2),
(1747, NULL, NULL, NULL, 311, 'SAC', 8.00, 1.00, 7.00, 14, 2, 2),
(1748, NULL, NULL, NULL, 311, 'SAC', 13.00, 3.00, 10.00, 15, 2, 2),
(1749, NULL, NULL, NULL, 311, 'SAC', 46.00, 1.00, 45.00, 38, 2, 2),
(1750, NULL, NULL, NULL, 312, 'SAC', 209.00, 2.00, 207.00, 91, 2, 2),
(1751, NULL, NULL, NULL, 312, 'SAC', 104.00, 2.00, 102.00, 92, 2, 2),
(1752, NULL, NULL, NULL, 313, 'SAC', 7.00, 1.00, 6.00, 14, 2, 2),
(1753, NULL, NULL, NULL, 313, 'SAC', 10.00, 4.00, 6.00, 15, 2, 2),
(1754, NULL, NULL, NULL, 313, 'SAC', 0.00, 1.00, -1.00, 44, 2, 2),
(1755, NULL, NULL, NULL, 313, 'SAC', 0.00, 1.00, -1.00, 46, 2, 2),
(1756, NULL, NULL, NULL, 313, 'SAC', 31.00, 1.00, 30.00, 57, 2, 2),
(1757, NULL, NULL, NULL, 313, 'SAC', 18.00, 1.00, 17.00, 99, 2, 2),
(1758, NULL, NULL, NULL, 314, 'SAC', 43.00, 3.00, 40.00, 98, 2, 2),
(1759, NULL, NULL, NULL, 315, 'SAC', 0.00, 1.00, -1.00, 34, 2, 2),
(1760, NULL, NULL, NULL, 315, 'SAC', 45.00, 1.00, 44.00, 38, 2, 2),
(1761, NULL, NULL, NULL, 315, 'SAC', 102.00, 1.00, 101.00, 92, 2, 2),
(1762, NULL, NULL, NULL, 316, 'SAC', 101.00, 1.00, 100.00, 92, 2, 2),
(1763, NULL, NULL, NULL, 317, 'SAC', 6.00, 1.00, 5.00, 14, 2, 2),
(1764, NULL, NULL, NULL, 317, 'SAC', 0.00, 1.00, -1.00, 51, 2, 2),
(1765, NULL, NULL, NULL, 317, 'SAC', 100.00, 1.00, 99.00, 92, 2, 2),
(1766, NULL, NULL, NULL, 317, 'SAC', 40.00, 1.00, 39.00, 98, 2, 2),
(1767, NULL, NULL, NULL, 318, 'SAC', 5.00, 1.00, 4.00, 14, 2, 2),
(1768, NULL, NULL, NULL, 318, 'SAC', 6.00, 2.00, 4.00, 15, 2, 2),
(1769, NULL, NULL, NULL, 318, 'SAC', 30.00, 1.00, 29.00, 57, 2, 2),
(1770, NULL, NULL, NULL, 318, 'SAC', 39.00, 5.00, 34.00, 98, 2, 2),
(1771, NULL, NULL, NULL, 319, 'SAC', 99.00, 2.00, 97.00, 92, 2, 2),
(1772, NULL, NULL, NULL, 320, 'SAC', 29.00, 1.00, 28.00, 57, 2, 2),
(1773, NULL, NULL, NULL, 320, 'SAC', 61.00, 1.00, 60.00, 89, 2, 2),
(1774, NULL, NULL, NULL, 321, 'SAC', 19.00, 10.00, 9.00, 19, 2, 2),
(1775, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 161, 1, 2),
(1776, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 142, 2, 2),
(1777, NULL, NULL, NULL, 322, 'SAC', 9.00, 1.00, 8.00, 19, 2, 2),
(1778, NULL, NULL, NULL, 322, 'SAC', 34.00, 1.00, 33.00, 98, 2, 2),
(1779, NULL, NULL, NULL, 322, 'SAC', 1.00, 1.00, 0.00, 142, 2, 2),
(1780, NULL, NULL, NULL, 322, 'SAC', 1.00, 1.00, 0.00, 161, 2, 2),
(1781, NULL, NULL, NULL, NULL, 'INA', 33.00, 150.00, 183.00, 98, 2, 2),
(1782, NULL, NULL, NULL, 323, 'SAC', 183.00, 100.00, 83.00, 98, 2, 2),
(1783, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 153, 2, 2),
(1784, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 152, 2, 2),
(1785, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 162, 1, 2),
(1786, NULL, NULL, NULL, NULL, 'INA', 1008.00, 30.00, 1038.00, 16, 2, 2),
(1787, NULL, NULL, NULL, 324, 'SAC', 0.00, 0.00, 0.00, 13, 2, 2),
(1788, NULL, NULL, NULL, 324, 'SAC', 1038.00, 10.00, 1028.00, 16, 2, 2),
(1789, NULL, NULL, NULL, 324, 'SAC', 9.00, 5.00, 4.00, 18, 2, 2),
(1790, NULL, NULL, NULL, 324, 'SAC', 94.00, 10.00, 84.00, 22, 2, 2),
(1791, NULL, NULL, NULL, 324, 'SAC', 44.00, 10.00, 34.00, 38, 2, 2),
(1792, NULL, NULL, NULL, 324, 'SAC', 89.00, 5.00, 84.00, 48, 2, 2),
(1793, NULL, NULL, NULL, 324, 'SAC', 39.00, 3.00, 36.00, 53, 2, 2),
(1794, NULL, NULL, NULL, 324, 'SAC', 10.00, 10.00, 0.00, 152, 2, 2),
(1795, NULL, NULL, NULL, 324, 'SAC', 10.00, 10.00, 0.00, 153, 2, 2),
(1796, NULL, NULL, NULL, 324, 'SAC', 10.00, 2.00, 8.00, 162, 2, 2),
(1797, NULL, NULL, NULL, NULL, 'INA', 0.00, 20.00, 20.00, 13, 2, 2),
(1798, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 163, 1, 2),
(1799, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 39, 2, 2),
(1800, NULL, NULL, NULL, 325, 'SAC', 20.00, 12.00, 8.00, 13, 2, 2),
(1801, NULL, NULL, NULL, 325, 'SAC', 4.00, 3.00, 1.00, 15, 2, 2),
(1802, NULL, NULL, NULL, 325, 'SAC', 1028.00, 10.00, 1018.00, 16, 2, 2),
(1803, NULL, NULL, NULL, 325, 'SAC', 4.00, 4.00, 0.00, 18, 2, 2),
(1804, NULL, NULL, NULL, 325, 'SAC', 8.00, 1.00, 7.00, 19, 2, 2),
(1805, NULL, NULL, NULL, 325, 'SAC', 34.00, 1.00, 33.00, 38, 2, 2),
(1806, NULL, NULL, NULL, 325, 'SAC', 2.00, 2.00, 0.00, 39, 2, 2),
(1807, NULL, NULL, NULL, 325, 'SAC', 5.00, 1.00, 4.00, 49, 2, 2),
(1808, NULL, NULL, NULL, 325, 'SAC', 83.00, 4.00, 79.00, 98, 2, 2),
(1809, NULL, NULL, NULL, 325, 'SAC', 20.00, 1.00, 19.00, 100, 2, 2),
(1810, NULL, NULL, NULL, 325, 'SAC', 1.00, 1.00, 0.00, 163, 2, 2),
(1811, NULL, NULL, NULL, 326, 'SAC', 79.00, 50.00, 29.00, 98, 2, 2),
(1812, NULL, NULL, NULL, NULL, 'INA', 1.00, 50.00, 51.00, 15, 2, 2),
(1813, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 61, 2, 2),
(1814, NULL, NULL, NULL, NULL, 'INA', 3.00, 10.00, 13.00, 65, 2, 2),
(1815, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 73, 2, 2),
(1816, NULL, NULL, NULL, 327, 'SAC', 4.00, 1.00, 3.00, 14, 2, 2),
(1817, NULL, NULL, NULL, 327, 'SAC', 51.00, 20.00, 31.00, 15, 2, 2),
(1818, NULL, NULL, NULL, 327, 'SAC', 84.00, 10.00, 74.00, 22, 2, 2),
(1819, NULL, NULL, NULL, 327, 'SAC', 98.00, 10.00, 88.00, 25, 2, 2),
(1820, NULL, NULL, NULL, 327, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(1821, NULL, NULL, NULL, 327, 'SAC', 9.00, 2.00, 7.00, 60, 2, 2),
(1822, NULL, NULL, NULL, 327, 'SAC', 5.00, 1.00, 4.00, 61, 2, 2),
(1823, NULL, NULL, NULL, 327, 'SAC', 9.00, 5.00, 4.00, 63, 2, 2),
(1824, NULL, NULL, NULL, 327, 'SAC', 13.00, 5.00, 8.00, 65, 2, 2),
(1825, NULL, NULL, NULL, 327, 'SAC', 1.00, 1.00, 0.00, 73, 2, 2),
(1826, NULL, NULL, NULL, 327, 'SAC', 29.00, 20.00, 9.00, 98, 2, 2),
(1827, NULL, NULL, NULL, 327, 'SAC', 17.00, 3.00, 14.00, 99, 2, 2),
(1828, NULL, NULL, NULL, NULL, 'INA', 9.00, 50.00, 59.00, 98, 2, 2),
(1829, NULL, NULL, NULL, 328, 'SAC', 3.00, 5.00, -2.00, 14, 2, 2),
(1830, NULL, NULL, NULL, 328, 'SAC', 1018.00, 10.00, 1008.00, 16, 2, 2),
(1831, NULL, NULL, NULL, 328, 'SAC', 28.00, 5.00, 23.00, 57, 2, 2),
(1832, NULL, NULL, NULL, 328, 'SAC', 59.00, 10.00, 49.00, 98, 2, 2),
(1833, NULL, NULL, NULL, 329, 'SAC', 7.00, 2.00, 5.00, 60, 2, 2),
(1834, NULL, NULL, NULL, 329, 'SAC', 156.00, 5.00, 151.00, 77, 2, 2),
(1835, NULL, NULL, NULL, 329, 'SAC', 172.00, 3.00, 169.00, 117, 2, 2),
(1836, NULL, NULL, NULL, NULL, 'INA', 49.00, 80.00, 129.00, 98, 2, 2),
(1837, NULL, NULL, NULL, 330, 'SAC', 129.00, 76.00, 53.00, 98, 2, 2),
(1838, NULL, NULL, NULL, 331, 'SAC', 84.00, 15.00, 69.00, 48, 2, 2),
(1839, NULL, NULL, NULL, 331, 'SAC', 151.00, 25.00, 126.00, 77, 2, 2),
(1840, NULL, NULL, NULL, 332, 'SAC', 50.00, 5.00, 45.00, 1, 2, 2),
(1841, NULL, NULL, NULL, 332, 'SAC', 0.00, 0.00, 0.00, 14, 2, 2),
(1842, NULL, NULL, NULL, 332, 'SAC', 7.00, 7.00, 0.00, 19, 2, 2),
(1843, NULL, NULL, NULL, 332, 'SAC', 0.00, 1.00, -1.00, 34, 2, 2),
(1844, NULL, NULL, NULL, 332, 'SAC', 207.00, 10.00, 197.00, 91, 2, 2),
(1845, NULL, NULL, NULL, 333, 'SAC', 31.00, 1.00, 30.00, 15, 2, 2),
(1846, NULL, NULL, NULL, 333, 'SAC', 1008.00, 1.00, 1007.00, 16, 2, 2),
(1847, NULL, NULL, NULL, 333, 'SAC', 88.00, 1.00, 87.00, 25, 2, 2),
(1848, NULL, NULL, NULL, 333, 'SAC', 0.00, 0.00, 0.00, 35, 2, 2),
(1849, NULL, NULL, NULL, 333, 'SAC', 53.00, 1.00, 52.00, 98, 2, 2),
(1850, NULL, NULL, NULL, 334, 'SAC', 30.00, 1.00, 29.00, 15, 2, 2),
(1851, NULL, NULL, NULL, 334, 'SAC', 0.00, 0.00, 0.00, 34, 2, 2),
(1852, NULL, NULL, NULL, 334, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(1853, NULL, NULL, NULL, NULL, 'IN1', 0.00, 20.00, 20.00, 164, 1, 2),
(1854, NULL, NULL, NULL, NULL, 'INA', 0.00, 30.00, 30.00, 19, 2, 2),
(1855, NULL, NULL, NULL, 335, 'SAC', 0.00, 5.00, -5.00, 14, 2, 2),
(1856, NULL, NULL, NULL, 335, 'SAC', 29.00, 20.00, 9.00, 15, 2, 2),
(1857, NULL, NULL, NULL, 335, 'SAC', 30.00, 10.00, 20.00, 19, 2, 2),
(1858, NULL, NULL, NULL, 335, 'SAC', 494.00, 2.00, 492.00, 23, 2, 2),
(1859, NULL, NULL, NULL, 335, 'SAC', 50.00, 3.00, 47.00, 24, 2, 2),
(1860, NULL, NULL, NULL, 335, 'SAC', 87.00, 3.00, 84.00, 25, 2, 2),
(1861, NULL, NULL, NULL, 335, 'SAC', 0.00, 2.00, -2.00, 26, 2, 2),
(1862, NULL, NULL, NULL, 335, 'SAC', 9.00, 2.00, 7.00, 30, 2, 2),
(1863, NULL, NULL, NULL, 335, 'SAC', 0.00, 2.00, -2.00, 44, 2, 2),
(1864, NULL, NULL, NULL, 335, 'SAC', 0.00, 0.00, 0.00, 46, 2, 2),
(1865, NULL, NULL, NULL, 335, 'SAC', 69.00, 10.00, 59.00, 48, 2, 2),
(1866, NULL, NULL, NULL, 335, 'SAC', 23.00, 2.00, 21.00, 57, 2, 2),
(1867, NULL, NULL, NULL, 335, 'SAC', 52.00, 20.00, 32.00, 98, 2, 2),
(1868, NULL, NULL, NULL, 335, 'SAC', 14.00, 3.00, 11.00, 99, 2, 2),
(1869, NULL, NULL, NULL, 335, 'SAC', 20.00, 2.00, 18.00, 164, 2, 2),
(1870, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 14, 2, 2),
(1871, NULL, NULL, NULL, NULL, 'INA', 9.00, 40.00, 49.00, 15, 2, 2),
(1872, NULL, NULL, NULL, NULL, 'INA', 18.00, 2.00, 20.00, 164, 2, 2),
(1873, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 26, 2, 2),
(1874, NULL, NULL, NULL, NULL, 'INA', 7.00, 2.00, 9.00, 30, 2, 2),
(1875, NULL, NULL, NULL, NULL, 'SAA', 0.00, 0.00, 0.00, 44, 2, 2),
(1876, NULL, NULL, NULL, NULL, 'SAA', 0.00, 15.00, -15.00, 46, 2, 2),
(1877, NULL, NULL, NULL, 336, 'SAC', 0.00, 5.00, -5.00, 14, 2, 2),
(1878, NULL, NULL, NULL, 336, 'SAC', 49.00, 20.00, 29.00, 15, 2, 2),
(1879, NULL, NULL, NULL, 336, 'SAC', 20.00, 10.00, 10.00, 19, 2, 2),
(1880, NULL, NULL, NULL, 336, 'SAC', 492.00, 2.00, 490.00, 23, 2, 2),
(1881, NULL, NULL, NULL, 336, 'SAC', 84.00, 3.00, 81.00, 25, 2, 2),
(1882, NULL, NULL, NULL, 336, 'SAC', 0.00, 2.00, -2.00, 26, 2, 2),
(1883, NULL, NULL, NULL, 336, 'SAC', 9.00, 2.00, 7.00, 30, 2, 2),
(1884, NULL, NULL, NULL, 336, 'SAC', 0.00, 2.00, -2.00, 44, 2, 2),
(1885, NULL, NULL, NULL, 336, 'SAC', 0.00, 0.00, 0.00, 46, 2, 2),
(1886, NULL, NULL, NULL, 336, 'SAC', 59.00, 10.00, 49.00, 48, 2, 2),
(1887, NULL, NULL, NULL, 336, 'SAC', 21.00, 2.00, 19.00, 57, 2, 2),
(1888, NULL, NULL, NULL, 336, 'SAC', 32.00, 20.00, 12.00, 98, 2, 2),
(1889, NULL, NULL, NULL, 336, 'SAC', 11.00, 3.00, 8.00, 99, 2, 2),
(1890, NULL, NULL, NULL, 336, 'SAC', 20.00, 2.00, 18.00, 164, 2, 2),
(1891, NULL, NULL, 2, NULL, 'INP', 124.00, 50.00, 174.00, 113, 2, 2),
(1892, NULL, NULL, 3, NULL, 'INP', 174.00, 300.00, 474.00, 113, 2, 2),
(1893, NULL, NULL, NULL, NULL, 'SAA', 47.00, 23.00, 24.00, 24, 2, 2),
(1894, NULL, NULL, NULL, 337, 'SAC', 24.00, 3.00, 21.00, 24, 2, 2),
(1895, NULL, NULL, NULL, 337, 'SAC', 5.00, 1.00, 4.00, 60, 2, 2),
(1896, NULL, NULL, NULL, 337, 'SAC', 126.00, 2.00, 124.00, 77, 2, 2),
(1897, NULL, NULL, NULL, 338, 'SAC', 21.00, 15.00, 6.00, 24, 2, 2),
(1898, NULL, NULL, NULL, 339, 'SAC', 6.00, 15.00, -9.00, 24, 2, 2),
(1899, NULL, NULL, NULL, 339, 'SAC', 1.00, 1.00, 0.00, 107, 2, 2),
(1900, NULL, NULL, NULL, NULL, 'INA', 12.00, 100.00, 112.00, 98, 2, 2),
(1901, NULL, NULL, NULL, NULL, 'INA', 29.00, 100.00, 129.00, 15, 2, 2),
(1902, NULL, NULL, NULL, NULL, 'INA', 4.00, 10.00, 14.00, 60, 2, 2),
(1903, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 14, 2, 2),
(1904, NULL, NULL, NULL, NULL, 'INA', 19.00, 10.00, 29.00, 57, 2, 2),
(1905, NULL, NULL, NULL, NULL, 'INA', 8.00, 2.00, 10.00, 65, 2, 2),
(1906, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 26, 2, 2),
(1907, NULL, NULL, NULL, NULL, 'INA', 0.00, 50.00, 50.00, 34, 2, 2),
(1908, NULL, NULL, NULL, 340, 'SAC', 0.00, 5.00, -5.00, 14, 2, 2),
(1909, NULL, NULL, NULL, 340, 'SAC', 129.00, 20.00, 109.00, 15, 2, 2),
(1910, NULL, NULL, NULL, 340, 'SAC', 74.00, 6.00, 68.00, 22, 2, 2),
(1911, NULL, NULL, NULL, 340, 'SAC', 490.00, 2.00, 488.00, 23, 2, 2),
(1912, NULL, NULL, NULL, 340, 'SAC', 0.00, 2.00, -2.00, 26, 2, 2),
(1913, NULL, NULL, NULL, 340, 'SAC', 50.00, 6.00, 44.00, 34, 2, 2),
(1914, NULL, NULL, NULL, 340, 'SAC', 0.00, 0.00, 0.00, 36, 2, 2),
(1915, NULL, NULL, NULL, 340, 'SAC', 33.00, 5.00, 28.00, 38, 2, 2),
(1916, NULL, NULL, NULL, 340, 'SAC', 0.00, 3.00, -3.00, 42, 2, 2),
(1917, NULL, NULL, NULL, 340, 'SAC', 49.00, 3.00, 46.00, 48, 2, 2),
(1918, NULL, NULL, NULL, 340, 'SAC', 29.00, 5.00, 24.00, 57, 2, 2),
(1919, NULL, NULL, NULL, 340, 'SAC', 14.00, 1.00, 13.00, 60, 2, 2),
(1920, NULL, NULL, NULL, 340, 'SAC', 10.00, 1.00, 9.00, 65, 2, 2),
(1921, NULL, NULL, NULL, 340, 'SAC', 112.00, 20.00, 92.00, 98, 2, 2),
(1922, NULL, NULL, NULL, 340, 'SAC', 8.00, 2.00, 6.00, 99, 2, 2),
(1923, NULL, NULL, NULL, 341, 'SAC', 0.00, 0.00, 0.00, 14, 2, 2),
(1924, NULL, NULL, NULL, 341, 'SAC', 109.00, 10.00, 99.00, 15, 2, 2),
(1925, NULL, NULL, NULL, 341, 'SAC', 68.00, 8.00, 60.00, 22, 2, 2),
(1926, NULL, NULL, NULL, 341, 'SAC', 488.00, 3.00, 485.00, 23, 2, 2),
(1927, NULL, NULL, NULL, 341, 'SAC', 81.00, 2.00, 79.00, 25, 2, 2),
(1928, NULL, NULL, NULL, 341, 'SAC', 28.00, 2.00, 26.00, 38, 2, 2),
(1929, NULL, NULL, NULL, 341, 'SAC', 0.00, 0.00, 0.00, 54, 2, 2),
(1930, NULL, NULL, NULL, 341, 'SAC', 92.00, 10.00, 82.00, 98, 2, 2),
(1931, NULL, NULL, NULL, 341, 'SAC', 6.00, 1.00, 5.00, 99, 2, 2),
(1932, NULL, NULL, NULL, 342, 'SAC', 0.00, 1.00, -1.00, 14, 2, 2),
(1933, NULL, NULL, NULL, 342, 'SAC', 99.00, 7.00, 92.00, 15, 2, 2),
(1934, NULL, NULL, NULL, 342, 'SAC', 60.00, 3.00, 57.00, 22, 2, 2),
(1935, NULL, NULL, NULL, 342, 'SAC', 46.00, 1.00, 45.00, 48, 2, 2),
(1936, NULL, NULL, NULL, 342, 'SAC', 0.00, 1.00, -1.00, 54, 2, 2),
(1937, NULL, NULL, NULL, 342, 'SAC', 24.00, 1.00, 23.00, 57, 2, 2),
(1938, NULL, NULL, NULL, 342, 'SAC', 4.00, 1.00, 3.00, 59, 2, 2),
(1939, NULL, NULL, NULL, 342, 'SAC', 82.00, 7.00, 75.00, 98, 2, 2),
(1940, NULL, NULL, NULL, 342, 'SAC', 5.00, 1.00, 4.00, 99, 2, 2),
(1941, NULL, NULL, NULL, 342, 'SAC', 169.00, 1.00, 168.00, 117, 2, 2),
(1942, NULL, NULL, NULL, 343, 'SAC', 92.00, 1.00, 91.00, 15, 2, 2),
(1943, NULL, NULL, NULL, 343, 'SAC', 57.00, 1.00, 56.00, 22, 2, 2),
(1944, NULL, NULL, NULL, 343, 'SAC', 79.00, 1.00, 78.00, 25, 2, 2),
(1945, NULL, NULL, NULL, 343, 'SAC', 45.00, 1.00, 44.00, 48, 2, 2),
(1946, NULL, NULL, NULL, 343, 'SAC', 197.00, 1.00, 196.00, 91, 2, 2),
(1947, NULL, NULL, NULL, 343, 'SAC', 97.00, 1.00, 96.00, 92, 2, 2),
(1948, NULL, NULL, NULL, 343, 'SAC', 75.00, 1.00, 74.00, 98, 2, 2),
(1949, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 47, 2, 2),
(1950, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 45, 2, 2),
(1951, NULL, NULL, NULL, 344, 'SAC', 8.00, 1.00, 7.00, 13, 2, 2),
(1952, NULL, NULL, NULL, 344, 'SAC', 0.00, 1.00, -1.00, 45, 2, 2),
(1953, NULL, NULL, NULL, 345, 'SAC', 7.00, 1.00, 6.00, 13, 2, 2),
(1954, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 165, 1, 2),
(1955, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 166, 1, 2),
(1956, NULL, NULL, NULL, 346, 'SAC', 6.00, 1.00, 5.00, 13, 2, 2),
(1957, NULL, NULL, NULL, 346, 'SAC', 1.00, 1.00, 0.00, 165, 2, 2),
(1958, NULL, NULL, NULL, 346, 'SAC', 1.00, 1.00, 0.00, 166, 2, 2),
(1959, NULL, NULL, NULL, 347, 'SAC', 88.00, 1.00, 87.00, 81, 2, 2),
(1960, NULL, NULL, NULL, 347, 'SAC', 95.00, 1.00, 94.00, 90, 2, 2),
(1961, NULL, NULL, NULL, 348, 'SAC', 1007.00, 1.00, 1006.00, 16, 2, 2),
(1962, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 18, 2, 2),
(1963, NULL, NULL, NULL, 349, 'SAC', 91.00, 2.00, 89.00, 15, 2, 2),
(1964, NULL, NULL, NULL, 349, 'SAC', 5.00, 1.00, 4.00, 18, 2, 2),
(1965, NULL, NULL, NULL, 349, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(1966, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 135, 2, 2),
(1967, NULL, NULL, NULL, 350, 'SAC', 89.00, 1.00, 88.00, 15, 2, 2),
(1968, NULL, NULL, NULL, 350, 'SAC', 2.00, 1.00, 1.00, 135, 2, 2),
(1969, NULL, NULL, NULL, NULL, 'INA', 0.00, 29.00, 29.00, 86, 2, 2),
(1970, NULL, NULL, NULL, NULL, 'INA', 4.00, 17.00, 21.00, 87, 2, 2),
(1971, NULL, NULL, NULL, 351, 'SAC', 26.00, 1.00, 25.00, 38, 2, 2),
(1972, NULL, NULL, NULL, 351, 'SAC', 87.00, 1.00, 86.00, 81, 2, 2),
(1973, NULL, NULL, NULL, 351, 'SAC', 21.00, 1.00, 20.00, 87, 2, 2),
(1974, NULL, NULL, NULL, 351, 'SAC', 96.00, 1.00, 95.00, 92, 2, 2),
(1975, NULL, NULL, NULL, 352, 'SAC', 88.00, 1.00, 87.00, 15, 2, 2),
(1976, NULL, NULL, NULL, 352, 'SAC', 56.00, 1.00, 55.00, 22, 2, 2),
(1977, NULL, NULL, NULL, 352, 'SAC', 44.00, 1.00, 43.00, 34, 2, 2),
(1978, NULL, NULL, NULL, 352, 'SAC', 25.00, 1.00, 24.00, 38, 2, 2),
(1979, NULL, NULL, NULL, 352, 'SAC', 23.00, 1.00, 22.00, 57, 2, 2),
(1980, NULL, NULL, NULL, 352, 'SAC', 74.00, 1.00, 73.00, 98, 2, 2),
(1981, NULL, NULL, NULL, 352, 'SAC', 4.00, 1.00, 3.00, 99, 2, 2),
(1982, NULL, NULL, NULL, 352, 'SAC', 19.00, 1.00, 18.00, 100, 2, 2),
(1983, NULL, NULL, NULL, 353, 'SAC', 5.00, 1.00, 4.00, 13, 2, 2),
(1984, NULL, NULL, NULL, 353, 'SAC', 87.00, 1.00, 86.00, 15, 2, 2),
(1985, NULL, NULL, NULL, 353, 'SAC', 4.00, 1.00, 3.00, 18, 2, 2),
(1986, NULL, NULL, NULL, 353, 'SAC', 18.00, 1.00, 17.00, 100, 2, 2),
(1987, NULL, NULL, NULL, 354, 'SAC', 4.00, 4.00, 0.00, 13, 2, 2),
(1988, NULL, NULL, NULL, 354, 'SAC', 1006.00, 6.00, 1000.00, 16, 2, 2),
(1989, NULL, NULL, NULL, 354, 'SAC', 4.00, 3.00, 1.00, 49, 2, 2),
(1990, NULL, NULL, NULL, 354, 'SAC', 4.00, 1.00, 3.00, 63, 2, 2),
(1991, NULL, NULL, NULL, 355, 'SAC', 43.00, 1.00, 42.00, 34, 2, 2),
(1992, NULL, NULL, NULL, 355, 'SAC', 24.00, 1.00, 23.00, 38, 2, 2),
(1993, NULL, NULL, NULL, 355, 'SAC', 73.00, 1.00, 72.00, 98, 2, 2),
(1994, NULL, NULL, NULL, 356, 'SAC', 86.00, 1.00, 85.00, 15, 2, 2),
(1995, NULL, NULL, NULL, 356, 'SAC', 55.00, 1.00, 54.00, 22, 2, 2),
(1996, NULL, NULL, NULL, 356, 'SAC', 72.00, 1.00, 71.00, 98, 2, 2),
(1997, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 39, 2, 2),
(1998, NULL, NULL, NULL, 357, 'SAC', 85.00, 1.00, 84.00, 15, 2, 2),
(1999, NULL, NULL, NULL, 357, 'SAC', 54.00, 1.00, 53.00, 22, 2, 2),
(2000, NULL, NULL, NULL, 357, 'SAC', 42.00, 1.00, 41.00, 34, 2, 2),
(2001, NULL, NULL, NULL, 357, 'SAC', 2.00, 1.00, 1.00, 39, 2, 2),
(2002, NULL, NULL, NULL, 357, 'SAC', 3.00, 1.00, 2.00, 59, 2, 2),
(2003, NULL, NULL, NULL, 357, 'SAC', 71.00, 1.00, 70.00, 98, 2, 2),
(2004, NULL, NULL, NULL, 357, 'SAC', 1.00, 1.00, 0.00, 135, 2, 2),
(2005, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 135, 2, 2),
(2006, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 151, 2, 2),
(2007, NULL, NULL, NULL, 358, 'SAC', 17.00, 1.00, 16.00, 100, 2, 2),
(2008, NULL, NULL, NULL, 358, 'SAC', 1.00, 1.00, 0.00, 135, 2, 2),
(2009, NULL, NULL, NULL, 358, 'SAC', 1.00, 1.00, 0.00, 151, 2, 2),
(2010, NULL, NULL, 4, NULL, 'INP', 44.00, 200.00, 244.00, 79, 2, 2),
(2011, NULL, NULL, 4, NULL, 'INP', 139.00, 150.00, 289.00, 80, 2, 2),
(2012, NULL, NULL, 4, NULL, 'INP', 86.00, 150.00, 236.00, 81, 2, 2),
(2013, NULL, NULL, 4, NULL, 'INP', 34.00, 100.00, 134.00, 82, 2, 2),
(2014, NULL, NULL, 4, NULL, 'INP', 10.00, 20.00, 30.00, 83, 2, 2),
(2015, NULL, NULL, 4, NULL, 'INP', 47.00, 100.00, 147.00, 97, 2, 2),
(2016, NULL, NULL, NULL, 359, 'SAC', 0.00, 1.00, -1.00, 13, 2, 2),
(2017, NULL, NULL, NULL, 359, 'SAC', 3.00, 2.00, 1.00, 18, 2, 2),
(2018, NULL, NULL, NULL, 359, 'SAC', 0.00, 1.00, -1.00, 35, 2, 2),
(2019, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 20, 2, 2),
(2020, NULL, NULL, NULL, 360, 'SAC', 0.00, 180.00, -180.00, 20, 2, 2),
(2021, NULL, NULL, NULL, NULL, 'INA', 1000.00, 5.00, 1005.00, 16, 2, 2),
(2022, NULL, NULL, NULL, NULL, 'INA', 1005.00, 10.00, 1015.00, 16, 2, 2),
(2023, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 13, 2, 2),
(2024, NULL, NULL, NULL, NULL, 'INA', 1.00, 10.00, 11.00, 18, 2, 2),
(2025, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 35, 2, 2),
(2026, NULL, NULL, NULL, NULL, 'INA', 1.00, 5.00, 6.00, 39, 2, 2),
(2027, NULL, NULL, NULL, 361, 'SAC', 0.00, 14.00, -14.00, 13, 2, 2),
(2028, NULL, NULL, NULL, 361, 'SAC', 84.00, 3.00, 81.00, 15, 2, 2),
(2029, NULL, NULL, NULL, 361, 'SAC', 1015.00, 8.00, 1007.00, 16, 2, 2),
(2030, NULL, NULL, NULL, 361, 'SAC', 11.00, 7.00, 4.00, 18, 2, 2),
(2031, NULL, NULL, NULL, 361, 'SAC', 41.00, 1.00, 40.00, 34, 2, 2),
(2032, NULL, NULL, NULL, 361, 'SAC', 0.00, 2.00, -2.00, 35, 2, 2),
(2033, NULL, NULL, NULL, 361, 'SAC', 6.00, 1.00, 5.00, 39, 2, 2),
(2034, NULL, NULL, NULL, 361, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(2035, NULL, NULL, NULL, 361, 'SAC', 2.00, 1.00, 1.00, 59, 2, 2),
(2036, NULL, NULL, NULL, 361, 'SAC', 70.00, 2.00, 68.00, 98, 2, 2),
(2037, NULL, NULL, NULL, 361, 'SAC', 16.00, 1.00, 15.00, 100, 2, 2),
(2038, NULL, NULL, 5, NULL, 'INP', 127.00, 80.00, 207.00, 88, 2, 2),
(2039, NULL, NULL, 5, NULL, 'INP', 5.00, 80.00, 85.00, 93, 2, 2),
(2040, NULL, NULL, 5, NULL, 'INP', 57.00, 80.00, 137.00, 95, 2, 2),
(2041, NULL, NULL, NULL, NULL, 'IN1', 0.00, 31050.00, 31050.00, 167, 1, 2),
(2042, NULL, NULL, 6, NULL, 'INP', 31050.00, 31050.00, 62100.00, 167, 2, 2),
(2043, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 4, 2, 2),
(2044, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 14, 2, 2),
(2045, NULL, NULL, NULL, 362, 'SAC', 0.00, 50.00, -50.00, 14, 2, 2),
(2046, NULL, NULL, NULL, NULL, 'INA', 0.00, 20.00, 20.00, 96, 2, 2),
(2047, NULL, NULL, NULL, 363, 'SAC', 81.00, 1.00, 80.00, 15, 2, 2),
(2048, NULL, NULL, NULL, 363, 'SAC', 3.00, 1.00, 2.00, 84, 2, 2),
(2049, NULL, NULL, NULL, 363, 'SAC', 29.00, 2.00, 27.00, 86, 2, 2),
(2050, NULL, NULL, NULL, 363, 'SAC', 20.00, 1.00, 19.00, 96, 2, 2),
(2051, NULL, NULL, NULL, NULL, 'INA', 3.00, 10.00, 13.00, 63, 2, 2),
(2052, NULL, NULL, NULL, NULL, 'INA', 9.00, 0.00, 9.00, 65, 2, 2),
(2053, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 73, 2, 2),
(2054, NULL, NULL, NULL, NULL, 'INA', 1.00, 10.00, 11.00, 59, 2, 2),
(2055, NULL, NULL, NULL, 364, 'SAC', 0.00, 0.00, 0.00, 14, 2, 2),
(2056, NULL, NULL, NULL, 364, 'SAC', 80.00, 18.00, 62.00, 15, 2, 2),
(2057, NULL, NULL, NULL, 364, 'SAC', 10.00, 6.00, 4.00, 19, 2, 2),
(2058, NULL, NULL, NULL, 364, 'SAC', 485.00, 1.00, 484.00, 23, 2, 2),
(2059, NULL, NULL, NULL, 364, 'SAC', 0.00, 1.00, -1.00, 24, 2, 2),
(2060, NULL, NULL, NULL, 364, 'SAC', 78.00, 1.00, 77.00, 25, 2, 2),
(2061, NULL, NULL, NULL, 364, 'SAC', 40.00, 5.00, 35.00, 34, 2, 2),
(2062, NULL, NULL, NULL, 364, 'SAC', 44.00, 2.00, 42.00, 48, 2, 2),
(2063, NULL, NULL, NULL, 364, 'SAC', 11.00, 3.00, 8.00, 59, 2, 2),
(2064, NULL, NULL, NULL, 364, 'SAC', 13.00, 5.00, 8.00, 63, 2, 2),
(2065, NULL, NULL, NULL, 364, 'SAC', 9.00, 5.00, 4.00, 65, 2, 2),
(2066, NULL, NULL, NULL, 364, 'SAC', 5.00, 1.00, 4.00, 73, 2, 2),
(2067, NULL, NULL, NULL, 364, 'SAC', 68.00, 14.00, 54.00, 98, 2, 2),
(2068, NULL, NULL, NULL, 364, 'SAC', 3.00, 2.00, 1.00, 99, 2, 2),
(2069, NULL, NULL, NULL, NULL, 'INA', 4.00, 5.00, 9.00, 65, 2, 2),
(2070, NULL, NULL, NULL, NULL, 'INA', 4.00, 1.00, 5.00, 73, 2, 2),
(2071, NULL, NULL, NULL, NULL, 'INA', 1.00, 10.00, 11.00, 99, 2, 2),
(2072, NULL, NULL, NULL, NULL, 'INA', 4.00, 10.00, 14.00, 19, 2, 2),
(2073, NULL, NULL, NULL, 365, 'SAC', 0.00, 5.00, -5.00, 14, 2, 2),
(2074, NULL, NULL, NULL, 365, 'SAC', 62.00, 18.00, 44.00, 15, 2, 2),
(2075, NULL, NULL, NULL, 365, 'SAC', 14.00, 6.00, 8.00, 19, 2, 2),
(2076, NULL, NULL, NULL, 365, 'SAC', 484.00, 1.00, 483.00, 23, 2, 2),
(2077, NULL, NULL, NULL, 365, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(2078, NULL, NULL, NULL, 365, 'SAC', 77.00, 1.00, 76.00, 25, 2, 2),
(2079, NULL, NULL, NULL, 365, 'SAC', 35.00, 5.00, 30.00, 34, 2, 2),
(2080, NULL, NULL, NULL, 365, 'SAC', 42.00, 2.00, 40.00, 48, 2, 2),
(2081, NULL, NULL, NULL, 365, 'SAC', 8.00, 3.00, 5.00, 59, 2, 2),
(2082, NULL, NULL, NULL, 365, 'SAC', 8.00, 5.00, 3.00, 63, 2, 2),
(2083, NULL, NULL, NULL, 365, 'SAC', 9.00, 5.00, 4.00, 65, 2, 2),
(2084, NULL, NULL, NULL, 365, 'SAC', 5.00, 1.00, 4.00, 73, 2, 2),
(2085, NULL, NULL, NULL, 365, 'SAC', 54.00, 14.00, 40.00, 98, 2, 2),
(2086, NULL, NULL, NULL, 365, 'SAC', 11.00, 2.00, 9.00, 99, 2, 2),
(2087, NULL, NULL, NULL, 366, 'SAC', 0.00, 0.00, 0.00, 14, 2, 2),
(2088, NULL, NULL, NULL, 366, 'SAC', 44.00, 12.00, 32.00, 15, 2, 2),
(2089, NULL, NULL, NULL, 366, 'SAC', 53.00, 5.00, 48.00, 22, 2, 2),
(2090, NULL, NULL, NULL, 366, 'SAC', 483.00, 2.00, 481.00, 23, 2, 2),
(2091, NULL, NULL, NULL, 366, 'SAC', 0.00, 1.00, -1.00, 24, 2, 2),
(2092, NULL, NULL, NULL, 366, 'SAC', 76.00, 2.00, 74.00, 25, 2, 2),
(2093, NULL, NULL, NULL, 366, 'SAC', 0.00, 1.00, -1.00, 36, 2, 2),
(2094, NULL, NULL, NULL, 366, 'SAC', 23.00, 2.00, 21.00, 38, 2, 2),
(2095, NULL, NULL, NULL, 366, 'SAC', 40.00, 3.00, 37.00, 48, 2, 2),
(2096, NULL, NULL, NULL, 366, 'SAC', 0.00, 0.00, 0.00, 54, 2, 2),
(2097, NULL, NULL, NULL, 366, 'SAC', 40.00, 12.00, 28.00, 98, 2, 2),
(2098, NULL, NULL, NULL, 366, 'SAC', 9.00, 2.00, 7.00, 99, 2, 2),
(2099, NULL, NULL, NULL, NULL, 'INA', 52.00, 10.00, 62.00, 33, 2, 2),
(2100, NULL, NULL, NULL, NULL, 'INA', 7.00, 10.00, 17.00, 99, 2, 2),
(2101, NULL, NULL, NULL, 367, 'SAC', 0.00, 30.00, -30.00, 4, 2, 2),
(2102, NULL, NULL, NULL, 367, 'SAC', 48.00, 30.00, 18.00, 22, 2, 2),
(2103, NULL, NULL, NULL, 367, 'SAC', 22.00, 10.00, 12.00, 57, 2, 2),
(2104, NULL, NULL, NULL, 367, 'SAC', 21.00, 10.00, 11.00, 58, 2, 2),
(2105, NULL, NULL, NULL, 367, 'SAC', 17.00, 10.00, 7.00, 99, 2, 2),
(2106, NULL, NULL, NULL, 368, 'SAC', 32.00, 4.00, 28.00, 15, 2, 2),
(2107, NULL, NULL, NULL, 368, 'SAC', 18.00, 2.00, 16.00, 22, 2, 2),
(2108, NULL, NULL, NULL, 368, 'SAC', 0.00, 2.00, -2.00, 46, 2, 2),
(2109, NULL, NULL, NULL, 368, 'SAC', 37.00, 1.00, 36.00, 48, 2, 2),
(2110, NULL, NULL, NULL, 369, 'SAC', 28.00, 1.00, 27.00, 15, 2, 2),
(2111, NULL, NULL, NULL, 369, 'SAC', 16.00, 1.00, 15.00, 22, 2, 2),
(2112, NULL, NULL, NULL, 369, 'SAC', 5.00, 1.00, 4.00, 39, 2, 2),
(2113, NULL, NULL, NULL, 369, 'SAC', 12.00, 1.00, 11.00, 57, 2, 2),
(2114, NULL, NULL, NULL, 369, 'SAC', 28.00, 2.00, 26.00, 98, 2, 2),
(2115, NULL, NULL, NULL, 370, 'SAC', 27.00, 1.00, 26.00, 15, 2, 2),
(2116, NULL, NULL, NULL, 370, 'SAC', 0.00, 0.00, 0.00, 36, 2, 2),
(2117, NULL, NULL, NULL, 370, 'SAC', 26.00, 1.00, 25.00, 98, 2, 2),
(2118, NULL, NULL, NULL, 371, 'SAC', 0.00, 4.00, -4.00, 14, 2, 2),
(2119, NULL, NULL, NULL, 371, 'SAC', 26.00, 8.00, 18.00, 15, 2, 2),
(2120, NULL, NULL, NULL, 371, 'SAC', 36.00, 2.00, 34.00, 48, 2, 2),
(2121, NULL, NULL, NULL, 371, 'SAC', 25.00, 8.00, 17.00, 98, 2, 2),
(2122, NULL, NULL, NULL, NULL, 'INA', 17.00, 100.00, 117.00, 98, 2, 2),
(2123, NULL, NULL, NULL, 372, 'SAC', 117.00, 100.00, 17.00, 98, 2, 2),
(2124, NULL, NULL, NULL, 373, 'SAC', 0.00, 0.00, 0.00, 14, 2, 2),
(2125, NULL, NULL, NULL, 373, 'SAC', 18.00, 3.00, 15.00, 15, 2, 2),
(2126, NULL, NULL, NULL, 373, 'SAC', 481.00, 3.00, 478.00, 23, 2, 2),
(2127, NULL, NULL, NULL, 373, 'SAC', 0.00, 0.00, 0.00, 42, 2, 2),
(2128, NULL, NULL, NULL, 373, 'SAC', 34.00, 1.00, 33.00, 48, 2, 2),
(2129, NULL, NULL, NULL, 373, 'SAC', 11.00, 5.00, 6.00, 57, 2, 2),
(2130, NULL, NULL, NULL, 373, 'SAC', 244.00, 5.00, 239.00, 79, 2, 2),
(2131, NULL, NULL, NULL, 373, 'SAC', 60.00, 3.00, 57.00, 89, 2, 2),
(2132, NULL, NULL, NULL, 373, 'SAC', 94.00, 1.00, 93.00, 90, 2, 2),
(2133, NULL, NULL, NULL, 373, 'SAC', 196.00, 2.00, 194.00, 91, 2, 2),
(2134, NULL, NULL, NULL, 373, 'SAC', 17.00, 10.00, 7.00, 98, 2, 2),
(2135, NULL, NULL, NULL, 373, 'SAC', 7.00, 1.00, 6.00, 99, 2, 2),
(2136, NULL, NULL, NULL, 374, 'SAC', 8.00, 1.00, 7.00, 19, 2, 2),
(2137, NULL, NULL, NULL, 374, 'SAC', 6.00, 1.00, 5.00, 57, 2, 2),
(2138, NULL, NULL, NULL, 375, 'SAC', 239.00, 1.00, 238.00, 79, 2, 2),
(2139, NULL, NULL, NULL, 376, 'SAC', 5.00, 1.00, 4.00, 57, 2, 2),
(2140, NULL, NULL, NULL, 377, 'SAC', 4.00, 2.00, 2.00, 57, 2, 2),
(2141, NULL, NULL, NULL, 378, 'SAC', 2.00, 2.00, 0.00, 57, 2, 2),
(2142, NULL, NULL, NULL, 378, 'SAC', 7.00, 1.00, 6.00, 98, 2, 2),
(2143, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 57, 2, 2),
(2144, NULL, NULL, NULL, 379, 'SAC', 15.00, 1.00, 14.00, 15, 2, 2),
(2145, NULL, NULL, NULL, 379, 'SAC', 7.00, 1.00, 6.00, 19, 2, 2),
(2146, NULL, NULL, NULL, 379, 'SAC', 10.00, 2.00, 8.00, 57, 2, 2),
(2147, NULL, NULL, NULL, 379, 'SAC', 6.00, 5.00, 1.00, 98, 2, 2),
(2148, NULL, NULL, NULL, NULL, 'INA', 1.00, 100.00, 101.00, 98, 2, 2),
(2149, NULL, NULL, NULL, 380, 'SAC', 14.00, 1.00, 13.00, 15, 2, 2),
(2150, NULL, NULL, NULL, 380, 'SAC', 30.00, 1.00, 29.00, 34, 2, 2),
(2151, NULL, NULL, NULL, 380, 'SAC', 8.00, 1.00, 7.00, 57, 2, 2),
(2152, NULL, NULL, NULL, 380, 'SAC', 101.00, 2.00, 99.00, 98, 2, 2),
(2153, NULL, NULL, NULL, 381, 'SAC', 0.00, 1.00, -1.00, 14, 2, 2),
(2154, NULL, NULL, NULL, 381, 'SAC', 13.00, 2.00, 11.00, 15, 2, 2),
(2155, NULL, NULL, NULL, 381, 'SAC', 29.00, 1.00, 28.00, 34, 2, 2),
(2156, NULL, NULL, NULL, 381, 'SAC', 7.00, 1.00, 6.00, 57, 2, 2),
(2157, NULL, NULL, NULL, 382, 'SAC', 0.00, 0.00, 0.00, 14, 2, 2),
(2158, NULL, NULL, NULL, 382, 'SAC', 11.00, 1.00, 10.00, 15, 2, 2),
(2159, NULL, NULL, NULL, 383, 'SAC', 6.00, 5.00, 1.00, 19, 2, 2),
(2160, NULL, NULL, NULL, NULL, 'INA', 1.00, 20.00, 21.00, 19, 2, 2),
(2161, NULL, NULL, NULL, 384, 'SAC', 0.00, 1.00, -1.00, 14, 2, 2),
(2162, NULL, NULL, NULL, 384, 'SAC', 10.00, 1.00, 9.00, 15, 2, 2),
(2163, NULL, NULL, NULL, 384, 'SAC', 21.00, 5.00, 16.00, 19, 2, 2),
(2164, NULL, NULL, NULL, 385, 'SAC', 0.00, 0.00, 0.00, 14, 2, 2),
(2165, NULL, NULL, NULL, 385, 'SAC', 9.00, 5.00, 4.00, 15, 2, 2),
(2166, NULL, NULL, NULL, 385, 'SAC', 0.00, 2.00, -2.00, 44, 2, 2),
(2167, NULL, NULL, NULL, 385, 'SAC', 0.00, 1.00, -1.00, 50, 2, 2),
(2168, NULL, NULL, NULL, 385, 'SAC', 6.00, 1.00, 5.00, 57, 2, 2),
(2169, NULL, NULL, NULL, 386, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(2170, NULL, NULL, NULL, 387, 'SAC', 194.00, 2.00, 192.00, 91, 2, 2),
(2171, NULL, NULL, NULL, 387, 'SAC', 95.00, 2.00, 93.00, 92, 2, 2),
(2172, NULL, NULL, NULL, 388, 'SAC', 238.00, 1.00, 237.00, 79, 2, 2),
(2173, NULL, NULL, NULL, 389, 'SAC', 13.00, 1.00, 12.00, 60, 2, 2),
(2174, NULL, NULL, NULL, 390, 'SAC', 4.00, 1.00, 3.00, 15, 2, 2),
(2175, NULL, NULL, NULL, 390, 'SAC', 99.00, 1.00, 98.00, 98, 2, 2),
(2176, NULL, NULL, NULL, 391, 'SAC', 3.00, 1.00, 2.00, 15, 2, 2),
(2177, NULL, NULL, NULL, 391, 'SAC', 5.00, 1.00, 4.00, 57, 2, 2),
(2178, NULL, NULL, NULL, 391, 'SAC', 98.00, 2.00, 96.00, 98, 2, 2),
(2179, NULL, NULL, NULL, 391, 'SAC', 35.00, 1.00, 34.00, 105, 2, 2),
(2180, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 153, 2, 2),
(2181, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 152, 2, 2),
(2182, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 13, 2, 2),
(2183, NULL, NULL, NULL, NULL, 'INA', 1007.00, 10.00, 1017.00, 16, 2, 2),
(2184, NULL, NULL, NULL, NULL, 'INA', 4.00, 10.00, 14.00, 18, 2, 2),
(2185, NULL, NULL, NULL, NULL, 'INA', 12.00, 0.00, 12.00, 60, 2, 2),
(2186, NULL, NULL, NULL, NULL, 'INA', 4.00, 10.00, 14.00, 57, 2, 2),
(2187, NULL, NULL, NULL, 392, 'SAC', 0.00, 10.00, -10.00, 13, 2, 2),
(2188, NULL, NULL, NULL, 392, 'SAC', 1017.00, 10.00, 1007.00, 16, 2, 2),
(2189, NULL, NULL, NULL, 392, 'SAC', 14.00, 5.00, 9.00, 18, 2, 2),
(2190, NULL, NULL, NULL, 392, 'SAC', 15.00, 10.00, 5.00, 22, 2, 2),
(2191, NULL, NULL, NULL, 392, 'SAC', 478.00, 5.00, 473.00, 23, 2, 2),
(2192, NULL, NULL, NULL, 392, 'SAC', 33.00, 10.00, 23.00, 48, 2, 2),
(2193, NULL, NULL, NULL, 392, 'SAC', 14.00, 5.00, 9.00, 57, 2, 2),
(2194, NULL, NULL, NULL, 392, 'SAC', 12.00, 1.00, 11.00, 60, 2, 2),
(2195, NULL, NULL, NULL, 392, 'SAC', 10.00, 10.00, 0.00, 152, 2, 2),
(2196, NULL, NULL, NULL, 392, 'SAC', 10.00, 10.00, 0.00, 153, 2, 2),
(2197, NULL, NULL, NULL, NULL, 'INA', 2.00, 10.00, 12.00, 15, 2, 2),
(2198, NULL, NULL, NULL, NULL, 'INA', 5.00, 20.00, 25.00, 22, 2, 2),
(2199, NULL, NULL, NULL, 393, 'SAC', 12.00, 1.00, 11.00, 15, 2, 2),
(2200, NULL, NULL, NULL, 393, 'SAC', 25.00, 1.00, 24.00, 22, 2, 2),
(2201, NULL, NULL, NULL, 393, 'SAC', 23.00, 1.00, 22.00, 48, 2, 2),
(2202, NULL, NULL, NULL, 393, 'SAC', 96.00, 2.00, 94.00, 98, 2, 2),
(2203, NULL, NULL, NULL, NULL, 'IN1', 0.00, 2.00, 2.00, 168, 1, 2),
(2204, NULL, NULL, NULL, 394, 'SAC', 0.00, 15.00, -15.00, 54, 2, 2),
(2205, NULL, NULL, NULL, 394, 'SAC', 5.00, 5.00, 0.00, 59, 2, 2),
(2206, NULL, NULL, NULL, 394, 'SAC', 2.00, 2.00, 0.00, 168, 2, 2),
(2207, NULL, NULL, NULL, NULL, 'INA', 1007.00, 20.00, 1027.00, 16, 2, 2),
(2208, NULL, NULL, NULL, 395, 'SAC', 1027.00, 10.00, 1017.00, 16, 2, 2),
(2209, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 59, 2, 2),
(2210, NULL, NULL, NULL, 396, 'SAC', 45.00, 1.00, 44.00, 1, 2, 2),
(2211, NULL, NULL, NULL, 396, 'SAC', 10.00, 1.00, 9.00, 59, 2, 2),
(2212, NULL, NULL, NULL, NULL, 'INA', 11.00, 20.00, 31.00, 15, 2, 2),
(2213, NULL, NULL, NULL, 397, 'SAC', 0.00, 4.00, -4.00, 14, 2, 2),
(2214, NULL, NULL, NULL, 397, 'SAC', 31.00, 12.00, 19.00, 15, 2, 2),
(2215, NULL, NULL, NULL, 397, 'SAC', 16.00, 7.00, 9.00, 19, 2, 2),
(2216, NULL, NULL, NULL, 397, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(2217, NULL, NULL, NULL, 397, 'SAC', 74.00, 2.00, 72.00, 25, 2, 2),
(2218, NULL, NULL, NULL, 397, 'SAC', 28.00, 6.00, 22.00, 34, 2, 2),
(2219, NULL, NULL, NULL, 397, 'SAC', 0.00, 4.00, -4.00, 44, 2, 2),
(2220, NULL, NULL, NULL, 397, 'SAC', 0.00, 0.00, 0.00, 46, 2, 2),
(2221, NULL, NULL, NULL, 398, 'SAC', 44.00, 13.00, 31.00, 1, 2, 2),
(2222, NULL, NULL, NULL, 398, 'SAC', 0.00, 0.00, 0.00, 14, 2, 2),
(2223, NULL, NULL, NULL, 398, 'SAC', 19.00, 10.00, 9.00, 15, 2, 2),
(2224, NULL, NULL, NULL, 398, 'SAC', 9.00, 5.00, 4.00, 19, 2, 2),
(2225, NULL, NULL, NULL, 398, 'SAC', 0.00, 1.00, -1.00, 24, 2, 2),
(2226, NULL, NULL, NULL, 398, 'SAC', 0.00, 2.00, -2.00, 42, 2, 2),
(2227, NULL, NULL, NULL, 398, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(2228, NULL, NULL, NULL, 398, 'SAC', 22.00, 4.00, 18.00, 48, 2, 2),
(2229, NULL, NULL, NULL, 398, 'SAC', 9.00, 5.00, 4.00, 57, 2, 2),
(2230, NULL, NULL, NULL, 398, 'SAC', 11.00, 1.00, 10.00, 60, 2, 2),
(2231, NULL, NULL, NULL, 398, 'SAC', 6.00, 4.00, 2.00, 99, 2, 2),
(2232, NULL, NULL, NULL, 399, 'SAC', 473.00, 2.00, 471.00, 23, 2, 2),
(2233, NULL, NULL, NULL, 399, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(2234, NULL, NULL, NULL, 399, 'SAC', 72.00, 3.00, 69.00, 25, 2, 2),
(2235, NULL, NULL, NULL, 399, 'SAC', 18.00, 2.00, 16.00, 164, 2, 2),
(2236, NULL, NULL, NULL, NULL, 'INA', 4.00, 20.00, 24.00, 57, 2, 2),
(2237, NULL, NULL, NULL, 400, 'SAC', 24.00, 22.00, 2.00, 22, 2, 2),
(2238, NULL, NULL, NULL, 400, 'SAC', 0.00, 2.00, -2.00, 36, 2, 2),
(2239, NULL, NULL, NULL, 400, 'SAC', 0.00, 0.00, 0.00, 42, 2, 2),
(2240, NULL, NULL, NULL, 400, 'SAC', 24.00, 5.00, 19.00, 57, 2, 2),
(2241, NULL, NULL, NULL, 400, 'SAC', 16.00, 10.00, 6.00, 164, 2, 2),
(2242, NULL, NULL, NULL, NULL, 'INA', 94.00, 150.00, 244.00, 98, 2, 2),
(2243, NULL, NULL, NULL, 401, 'SAC', 244.00, 150.00, 94.00, 98, 2, 2),
(2244, NULL, NULL, NULL, NULL, 'SAA', 0.00, 8.00, -8.00, 46, 2, 2),
(2245, NULL, NULL, NULL, NULL, 'INA', 4.00, 20.00, 24.00, 19, 2, 2),
(2246, NULL, NULL, NULL, NULL, 'INA', 2.00, 10.00, 12.00, 99, 2, 2),
(2247, NULL, NULL, NULL, 402, 'SAC', 0.00, 2.00, -2.00, 14, 2, 2),
(2248, NULL, NULL, NULL, 402, 'SAC', 9.00, 7.00, 2.00, 15, 2, 2),
(2249, NULL, NULL, NULL, 402, 'SAC', 471.00, 3.00, 468.00, 23, 2, 2),
(2250, NULL, NULL, NULL, 402, 'SAC', 3.00, 3.00, 0.00, 94, 2, 2),
(2251, NULL, NULL, NULL, 402, 'SAC', 94.00, 10.00, 84.00, 98, 2, 2),
(2252, NULL, NULL, NULL, 402, 'SAC', 12.00, 1.00, 11.00, 99, 2, 2),
(2253, NULL, NULL, NULL, NULL, 'INA', 2.00, 20.00, 22.00, 15, 2, 2),
(2254, NULL, NULL, NULL, NULL, 'INA', 0.00, 3.00, 3.00, 94, 2, 2),
(2255, NULL, NULL, NULL, 403, 'SAC', 0.00, 0.00, 0.00, 14, 2, 2),
(2256, NULL, NULL, NULL, 403, 'SAC', 22.00, 7.00, 15.00, 15, 2, 2),
(2257, NULL, NULL, NULL, 403, 'SAC', 24.00, 2.00, 22.00, 19, 2, 2),
(2258, NULL, NULL, NULL, 403, 'SAC', 468.00, 3.00, 465.00, 23, 2, 2),
(2259, NULL, NULL, NULL, 403, 'SAC', 22.00, 1.00, 21.00, 34, 2, 2),
(2260, NULL, NULL, NULL, 403, 'SAC', 0.00, 0.00, 0.00, 46, 2, 2),
(2261, NULL, NULL, NULL, 403, 'SAC', 3.00, 3.00, 0.00, 94, 2, 2),
(2262, NULL, NULL, NULL, 403, 'SAC', 84.00, 10.00, 74.00, 98, 2, 2),
(2263, NULL, NULL, NULL, 403, 'SAC', 11.00, 1.00, 10.00, 99, 2, 2),
(2264, NULL, NULL, NULL, 404, 'SAC', 15.00, 1.00, 14.00, 15, 2, 2),
(2265, NULL, NULL, NULL, 404, 'SAC', 9.00, 1.00, 8.00, 18, 2, 2),
(2266, NULL, NULL, NULL, 404, 'SAC', 0.00, 0.00, 0.00, 35, 2, 2),
(2267, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 14, 2, 2),
(2268, NULL, NULL, NULL, NULL, 'INA', 3.00, 5.00, 8.00, 63, 2, 2),
(2269, NULL, NULL, NULL, NULL, 'INA', 4.00, 5.00, 9.00, 65, 2, 2),
(2270, NULL, NULL, NULL, NULL, 'INA', 14.00, 50.00, 64.00, 15, 2, 2),
(2271, NULL, NULL, NULL, 405, 'SAC', 10.00, 3.00, 7.00, 14, 2, 2),
(2272, NULL, NULL, NULL, 405, 'SAC', 64.00, 20.00, 44.00, 15, 2, 2),
(2273, NULL, NULL, NULL, 405, 'SAC', 21.00, 10.00, 11.00, 34, 2, 2),
(2274, NULL, NULL, NULL, 405, 'SAC', 8.00, 5.00, 3.00, 63, 2, 2),
(2275, NULL, NULL, NULL, 405, 'SAC', 9.00, 5.00, 4.00, 65, 2, 2),
(2276, NULL, NULL, NULL, 405, 'SAC', 74.00, 20.00, 54.00, 98, 2, 2);
INSERT INTO `movimiento` (`mov_id_movimiento`, `ind_id_ingreso_detalle`, `sad_id_salida_detalle`, `ing_id_ingreso`, `sal_id_salida`, `mov_tipo`, `mov_cantidad_anterior`, `mov_cantidad_entrante`, `mov_cantidad_actual`, `pro_id_producto`, `est_id_estado`, `usu_id_usuario`) VALUES
(2277, NULL, NULL, NULL, 405, 'SAC', 10.00, 2.00, 8.00, 99, 2, 2),
(2278, NULL, NULL, NULL, NULL, 'INA', 3.00, 5.00, 8.00, 63, 2, 2),
(2279, NULL, NULL, NULL, NULL, 'INA', 4.00, 5.00, 9.00, 65, 2, 2),
(2280, NULL, NULL, NULL, NULL, 'INA', 8.00, 10.00, 18.00, 99, 2, 2),
(2281, NULL, NULL, NULL, NULL, 'INA', 7.00, 10.00, 17.00, 14, 2, 2),
(2282, NULL, NULL, NULL, 406, 'SAC', 17.00, 3.00, 14.00, 14, 2, 2),
(2283, NULL, NULL, NULL, 406, 'SAC', 44.00, 20.00, 24.00, 15, 2, 2),
(2284, NULL, NULL, NULL, 406, 'SAC', 11.00, 10.00, 1.00, 34, 2, 2),
(2285, NULL, NULL, NULL, 406, 'SAC', 8.00, 5.00, 3.00, 63, 2, 2),
(2286, NULL, NULL, NULL, 406, 'SAC', 9.00, 5.00, 4.00, 65, 2, 2),
(2287, NULL, NULL, NULL, 406, 'SAC', 54.00, 20.00, 34.00, 98, 2, 2),
(2288, NULL, NULL, NULL, 406, 'SAC', 18.00, 2.00, 16.00, 99, 2, 2),
(2289, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 37, 2, 2),
(2290, NULL, NULL, NULL, 407, 'SAC', 0.00, 0.00, 0.00, 13, 2, 2),
(2291, NULL, NULL, NULL, 407, 'SAC', 1017.00, 2.00, 1015.00, 16, 2, 2),
(2292, NULL, NULL, NULL, 407, 'SAC', 465.00, 1.00, 464.00, 23, 2, 2),
(2293, NULL, NULL, NULL, 407, 'SAC', 0.00, 2.00, -2.00, 35, 2, 2),
(2294, NULL, NULL, NULL, 407, 'SAC', 1.00, 1.00, 0.00, 37, 2, 2),
(2295, NULL, NULL, NULL, 407, 'SAC', 1.00, 1.00, 0.00, 49, 2, 2),
(2296, NULL, NULL, NULL, 407, 'SAC', 93.00, 1.00, 92.00, 92, 2, 2),
(2297, NULL, NULL, NULL, 408, 'SAC', 1015.00, 3.00, 1012.00, 16, 2, 2),
(2298, NULL, NULL, NULL, 408, 'SAC', 0.00, 0.00, 0.00, 35, 2, 2),
(2299, NULL, NULL, NULL, 408, 'SAC', 0.00, 1.00, -1.00, 49, 2, 2),
(2300, NULL, NULL, NULL, 408, 'SAC', 34.00, 1.00, 33.00, 98, 2, 2),
(2301, NULL, NULL, NULL, NULL, 'INA', 0.00, 50.00, 50.00, 13, 2, 2),
(2302, NULL, NULL, NULL, 409, 'SAC', 50.00, 11.00, 39.00, 13, 2, 2),
(2303, NULL, NULL, NULL, 409, 'SAC', 24.00, 2.00, 22.00, 15, 2, 2),
(2304, NULL, NULL, NULL, 409, 'SAC', 1012.00, 10.00, 1002.00, 16, 2, 2),
(2305, NULL, NULL, NULL, 409, 'SAC', 8.00, 2.00, 6.00, 18, 2, 2),
(2306, NULL, NULL, NULL, 409, 'SAC', 22.00, 1.00, 21.00, 19, 2, 2),
(2307, NULL, NULL, NULL, 409, 'SAC', 0.00, 1.00, -1.00, 35, 2, 2),
(2308, NULL, NULL, NULL, 409, 'SAC', 18.00, 1.00, 17.00, 48, 2, 2),
(2309, NULL, NULL, NULL, 409, 'SAC', 0.00, 0.00, 0.00, 49, 2, 2),
(2310, NULL, NULL, NULL, 409, 'SAC', 33.00, 2.00, 31.00, 98, 2, 2),
(2311, NULL, NULL, NULL, 410, 'SAC', 21.00, 2.00, 19.00, 19, 2, 2),
(2312, NULL, NULL, NULL, 410, 'SAC', 34.00, 20.00, 14.00, 105, 2, 2),
(2313, NULL, NULL, NULL, 411, 'SAC', 19.00, 2.00, 17.00, 19, 2, 2),
(2314, NULL, NULL, NULL, 411, 'SAC', 2.00, 2.00, 0.00, 22, 2, 2),
(2315, NULL, NULL, NULL, 412, 'SAC', 17.00, 3.00, 14.00, 19, 2, 2),
(2316, NULL, NULL, NULL, 413, 'SAC', 1.00, 1.00, 0.00, 155, 2, 2),
(2317, NULL, NULL, NULL, 414, 'SAC', 14.00, 2.00, 12.00, 19, 2, 2),
(2318, NULL, NULL, NULL, 415, 'SAC', 12.00, 2.00, 10.00, 19, 2, 2),
(2319, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 22, 2, 2),
(2320, NULL, NULL, NULL, 416, 'SAC', 39.00, 1.00, 38.00, 13, 2, 2),
(2321, NULL, NULL, NULL, 416, 'SAC', 1002.00, 1.00, 1001.00, 16, 2, 2),
(2322, NULL, NULL, NULL, 416, 'SAC', 10.00, 1.00, 9.00, 22, 2, 2),
(2323, NULL, NULL, NULL, 417, 'SAC', 1001.00, 1.00, 1000.00, 16, 2, 2),
(2324, NULL, NULL, NULL, 417, 'SAC', 0.00, 0.00, 0.00, 45, 2, 2),
(2325, NULL, NULL, NULL, NULL, 'INA', 1000.00, 10.00, 1010.00, 16, 2, 2),
(2326, NULL, NULL, NULL, 418, 'SAC', 1010.00, 1.00, 1009.00, 16, 2, 2),
(2327, NULL, NULL, NULL, 418, 'SAC', 237.00, 1.00, 236.00, 79, 2, 2),
(2328, NULL, NULL, NULL, 419, 'SAC', 0.00, 0.00, 0.00, 35, 2, 2),
(2329, NULL, NULL, NULL, 419, 'SAC', 192.00, 1.00, 191.00, 91, 2, 2),
(2330, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 45, 2, 2),
(2331, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 166, 2, 2),
(2332, NULL, NULL, NULL, 420, 'SAC', 38.00, 1.00, 37.00, 13, 2, 2),
(2333, NULL, NULL, NULL, 420, 'SAC', 1009.00, 1.00, 1008.00, 16, 2, 2),
(2334, NULL, NULL, NULL, 420, 'SAC', 4.00, 1.00, 3.00, 39, 2, 2),
(2335, NULL, NULL, NULL, 420, 'SAC', 2.00, 1.00, 1.00, 45, 2, 2),
(2336, NULL, NULL, NULL, 420, 'SAC', 11.00, 1.00, 10.00, 58, 2, 2),
(2337, NULL, NULL, NULL, 420, 'SAC', 236.00, 1.00, 235.00, 79, 2, 2),
(2338, NULL, NULL, NULL, 420, 'SAC', 1.00, 1.00, 0.00, 166, 2, 2),
(2339, NULL, NULL, NULL, 421, 'SAC', 37.00, 1.00, 36.00, 13, 2, 2),
(2340, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 135, 2, 2),
(2341, NULL, NULL, NULL, NULL, 'INA', 0.00, 2.00, 2.00, 37, 2, 2),
(2342, NULL, NULL, NULL, 422, 'SAC', 22.00, 1.00, 21.00, 15, 2, 2),
(2343, NULL, NULL, NULL, 422, 'SAC', 6.00, 1.00, 5.00, 18, 2, 2),
(2344, NULL, NULL, NULL, 422, 'SAC', 1.00, 1.00, 0.00, 34, 2, 2),
(2345, NULL, NULL, NULL, 422, 'SAC', 2.00, 1.00, 1.00, 37, 2, 2),
(2346, NULL, NULL, NULL, 422, 'SAC', 0.00, 1.00, -1.00, 42, 2, 2),
(2347, NULL, NULL, NULL, 422, 'SAC', 0.00, 1.00, -1.00, 44, 2, 2),
(2348, NULL, NULL, NULL, 422, 'SAC', 0.00, 1.00, -1.00, 49, 2, 2),
(2349, NULL, NULL, NULL, 422, 'SAC', 92.00, 1.00, 91.00, 92, 2, 2),
(2350, NULL, NULL, NULL, 422, 'SAC', 31.00, 1.00, 30.00, 98, 2, 2),
(2351, NULL, NULL, NULL, 422, 'SAC', 2.00, 1.00, 1.00, 135, 2, 2),
(2352, NULL, NULL, NULL, NULL, 'INA', 0.00, 100.00, 100.00, 34, 2, 2),
(2353, NULL, NULL, NULL, 423, 'SAC', 21.00, 1.00, 20.00, 15, 2, 2),
(2354, NULL, NULL, NULL, 423, 'SAC', 100.00, 1.00, 99.00, 34, 2, 2),
(2355, NULL, NULL, NULL, 423, 'SAC', 91.00, 1.00, 90.00, 92, 2, 2),
(2356, NULL, NULL, NULL, 424, 'SAC', 20.00, 1.00, 19.00, 15, 2, 2),
(2357, NULL, NULL, NULL, 424, 'SAC', 5.00, 1.00, 4.00, 18, 2, 2),
(2358, NULL, NULL, NULL, 424, 'SAC', 9.00, 1.00, 8.00, 22, 2, 2),
(2359, NULL, NULL, NULL, 424, 'SAC', 99.00, 1.00, 98.00, 34, 2, 2),
(2360, NULL, NULL, NULL, 424, 'SAC', 9.00, 1.00, 8.00, 59, 2, 2),
(2361, NULL, NULL, NULL, 424, 'SAC', 30.00, 1.00, 29.00, 98, 2, 2),
(2362, NULL, NULL, NULL, 424, 'SAC', 15.00, 1.00, 14.00, 100, 2, 2),
(2363, NULL, NULL, NULL, NULL, 'IN1', 0.00, 25.00, 25.00, 169, 1, 2),
(2364, NULL, NULL, NULL, NULL, 'IN1', 0.00, 15.00, 15.00, 170, 1, 2),
(2365, NULL, NULL, NULL, NULL, 'IN1', 0.00, 5.00, 5.00, 171, 1, 2),
(2366, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 172, 1, 2),
(2367, NULL, NULL, NULL, 425, 'SAC', 36.00, 1.00, 35.00, 13, 2, 2),
(2368, NULL, NULL, NULL, 425, 'SAC', 1008.00, 1.00, 1007.00, 16, 2, 2),
(2369, NULL, NULL, NULL, 425, 'SAC', 8.00, 1.00, 7.00, 22, 2, 2),
(2370, NULL, NULL, NULL, 426, 'SAC', 5.00, 1.00, 4.00, 47, 2, 2),
(2371, NULL, NULL, NULL, 426, 'SAC', 236.00, 1.00, 235.00, 81, 2, 2),
(2372, NULL, NULL, NULL, 426, 'SAC', 207.00, 1.00, 206.00, 88, 2, 2),
(2373, NULL, NULL, NULL, NULL, 'IN1', 0.00, 6.00, 6.00, 173, 1, 2),
(2374, NULL, NULL, NULL, NULL, 'IN1', 0.00, 6.00, 6.00, 174, 1, 2),
(2375, NULL, NULL, NULL, 427, 'SAC', 0.00, 2.00, -2.00, 24, 2, 2),
(2376, NULL, NULL, NULL, 427, 'SAC', 25.00, 6.00, 19.00, 169, 2, 2),
(2377, NULL, NULL, NULL, 427, 'SAC', 15.00, 4.00, 11.00, 170, 2, 2),
(2378, NULL, NULL, NULL, 427, 'SAC', 6.00, 5.00, 1.00, 173, 2, 2),
(2379, NULL, NULL, NULL, 427, 'SAC', 6.00, 5.00, 1.00, 174, 2, 2),
(2380, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 74, 2, 2),
(2381, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 66, 2, 2),
(2382, NULL, NULL, NULL, 428, 'SAC', 0.00, 0.00, 0.00, 26, 2, 2),
(2383, NULL, NULL, NULL, 428, 'SAC', 1.00, 1.00, 0.00, 66, 2, 2),
(2384, NULL, NULL, NULL, 428, 'SAC', 1.00, 1.00, 0.00, 74, 2, 2),
(2385, NULL, NULL, NULL, 429, 'SAC', 14.00, 4.00, 10.00, 14, 2, 2),
(2386, NULL, NULL, NULL, 429, 'SAC', 19.00, 8.00, 11.00, 15, 2, 2),
(2387, NULL, NULL, NULL, 429, 'SAC', 7.00, 5.00, 2.00, 22, 2, 2),
(2388, NULL, NULL, NULL, 429, 'SAC', 464.00, 2.00, 462.00, 23, 2, 2),
(2389, NULL, NULL, NULL, 429, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(2390, NULL, NULL, NULL, 429, 'SAC', 69.00, 2.00, 67.00, 25, 2, 2),
(2391, NULL, NULL, NULL, 429, 'SAC', 0.00, 0.00, 0.00, 54, 2, 2),
(2392, NULL, NULL, NULL, 429, 'SAC', 29.00, 8.00, 21.00, 98, 2, 2),
(2393, NULL, NULL, NULL, 429, 'SAC', 16.00, 1.00, 15.00, 99, 2, 2),
(2394, NULL, NULL, NULL, NULL, 'INA', 1.00, 0.00, 1.00, 173, 2, 2),
(2395, NULL, NULL, NULL, 430, 'SAC', 11.00, 1.00, 10.00, 15, 2, 2),
(2396, NULL, NULL, NULL, 430, 'SAC', 21.00, 2.00, 19.00, 98, 2, 2),
(2397, NULL, NULL, NULL, 430, 'SAC', 1.00, 1.00, 0.00, 173, 2, 2),
(2398, NULL, NULL, NULL, 431, 'SAC', 10.00, 1.00, 9.00, 15, 2, 2),
(2399, NULL, NULL, NULL, 431, 'SAC', 2.00, 1.00, 1.00, 22, 2, 2),
(2400, NULL, NULL, NULL, 431, 'SAC', 19.00, 1.00, 18.00, 98, 2, 2),
(2401, NULL, NULL, NULL, 431, 'SAC', 14.00, 1.00, 13.00, 100, 2, 2),
(2402, NULL, NULL, NULL, 431, 'SAC', 1.00, 1.00, 0.00, 174, 2, 2),
(2403, NULL, NULL, NULL, 432, 'SAC', 10.00, 1.00, 9.00, 14, 2, 2),
(2404, NULL, NULL, NULL, 432, 'SAC', 9.00, 1.00, 8.00, 15, 2, 2),
(2405, NULL, NULL, NULL, 432, 'SAC', 191.00, 1.00, 190.00, 91, 2, 2),
(2406, NULL, NULL, NULL, 432, 'SAC', 18.00, 4.00, 14.00, 98, 2, 2),
(2407, NULL, NULL, NULL, 433, 'SAC', 8.00, 1.00, 7.00, 15, 2, 2),
(2408, NULL, NULL, NULL, 433, 'SAC', 1.00, 1.00, 0.00, 22, 2, 2),
(2409, NULL, NULL, NULL, 433, 'SAC', 14.00, 2.00, 12.00, 98, 2, 2),
(2410, NULL, NULL, NULL, 434, 'SAC', 9.00, 1.00, 8.00, 14, 2, 2),
(2411, NULL, NULL, NULL, 434, 'SAC', 7.00, 4.00, 3.00, 15, 2, 2),
(2412, NULL, NULL, NULL, 434, 'SAC', 12.00, 1.00, 11.00, 98, 2, 2),
(2413, NULL, NULL, NULL, NULL, 'INA', 3.00, 50.00, 53.00, 15, 2, 2),
(2414, NULL, NULL, NULL, 435, 'SAC', 8.00, 1.00, 7.00, 14, 2, 2),
(2415, NULL, NULL, NULL, 435, 'SAC', 53.00, 4.00, 49.00, 15, 2, 2),
(2416, NULL, NULL, NULL, 435, 'SAC', 67.00, 1.00, 66.00, 25, 2, 2),
(2417, NULL, NULL, NULL, 435, 'SAC', 98.00, 2.00, 96.00, 34, 2, 2),
(2418, NULL, NULL, NULL, 435, 'SAC', 17.00, 2.00, 15.00, 48, 2, 2),
(2419, NULL, NULL, NULL, 435, 'SAC', 19.00, 1.00, 18.00, 57, 2, 2),
(2420, NULL, NULL, NULL, 435, 'SAC', 3.00, 1.00, 2.00, 63, 2, 2),
(2421, NULL, NULL, NULL, 435, 'SAC', 11.00, 3.00, 8.00, 98, 2, 2),
(2422, NULL, NULL, NULL, NULL, 'INA', 0.00, 20.00, 20.00, 22, 2, 2),
(2423, NULL, NULL, NULL, 436, 'SAC', 35.00, 1.00, 34.00, 13, 2, 2),
(2424, NULL, NULL, NULL, 436, 'SAC', 1007.00, 5.00, 1002.00, 16, 2, 2),
(2425, NULL, NULL, NULL, 436, 'SAC', 4.00, 1.00, 3.00, 18, 2, 2),
(2426, NULL, NULL, NULL, 436, 'SAC', 20.00, 1.00, 19.00, 22, 2, 2),
(2427, NULL, NULL, NULL, 436, 'SAC', 15.00, 1.00, 14.00, 48, 2, 2),
(2428, NULL, NULL, NULL, 436, 'SAC', 13.00, 1.00, 12.00, 100, 2, 2),
(2429, NULL, NULL, NULL, 437, 'SAC', 18.00, 1.00, 17.00, 57, 2, 2),
(2430, NULL, NULL, NULL, 438, 'SAC', 49.00, 2.00, 47.00, 15, 2, 2),
(2431, NULL, NULL, NULL, 438, 'SAC', 3.00, 1.00, 2.00, 18, 2, 2),
(2432, NULL, NULL, NULL, 438, 'SAC', 0.00, 1.00, -1.00, 24, 2, 2),
(2433, NULL, NULL, NULL, 438, 'SAC', 14.00, 1.00, 13.00, 48, 2, 2),
(2434, NULL, NULL, NULL, 438, 'SAC', 0.00, 1.00, -1.00, 54, 2, 2),
(2435, NULL, NULL, NULL, 438, 'SAC', 8.00, 5.00, 3.00, 98, 2, 2),
(2436, NULL, NULL, NULL, 439, 'SAC', 8.00, 1.00, 7.00, 59, 2, 2),
(2437, NULL, NULL, NULL, 439, 'SAC', 1.00, 1.00, 0.00, 135, 2, 2),
(2438, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 69, 2, 2),
(2439, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 74, 2, 2),
(2440, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 75, 2, 2),
(2441, NULL, NULL, NULL, 440, 'SAC', 7.00, 1.00, 6.00, 14, 2, 2),
(2442, NULL, NULL, NULL, 440, 'SAC', 47.00, 1.00, 46.00, 15, 2, 2),
(2443, NULL, NULL, NULL, 440, 'SAC', 1002.00, 1.00, 1001.00, 16, 2, 2),
(2444, NULL, NULL, NULL, 440, 'SAC', 2.00, 1.00, 1.00, 18, 2, 2),
(2445, NULL, NULL, NULL, 440, 'SAC', 10.00, 2.00, 8.00, 19, 2, 2),
(2446, NULL, NULL, NULL, 440, 'SAC', 2.00, 2.00, 0.00, 63, 2, 2),
(2447, NULL, NULL, NULL, 440, 'SAC', 4.00, 3.00, 1.00, 65, 2, 2),
(2448, NULL, NULL, NULL, 440, 'SAC', 1.00, 1.00, 0.00, 69, 2, 2),
(2449, NULL, NULL, NULL, 440, 'SAC', 1.00, 1.00, 0.00, 74, 2, 2),
(2450, NULL, NULL, NULL, 440, 'SAC', 1.00, 1.00, 0.00, 75, 2, 2),
(2451, NULL, NULL, NULL, 440, 'SAC', 235.00, 1.00, 234.00, 79, 2, 2),
(2452, NULL, NULL, NULL, 440, 'SAC', 85.00, 1.00, 84.00, 93, 2, 2),
(2453, NULL, NULL, NULL, 440, 'SAC', 3.00, 1.00, 2.00, 98, 2, 2),
(2454, NULL, NULL, NULL, NULL, 'INA', 0.00, 15.00, 15.00, 152, 2, 2),
(2455, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 153, 2, 2),
(2456, NULL, NULL, NULL, NULL, 'INA', 1001.00, 30.00, 1031.00, 16, 2, 2),
(2457, NULL, NULL, NULL, NULL, 'INA', 1.00, 20.00, 21.00, 18, 2, 2),
(2458, NULL, NULL, NULL, 441, 'SAC', 34.00, 15.00, 19.00, 13, 2, 2),
(2459, NULL, NULL, NULL, 441, 'SAC', 1031.00, 15.00, 1016.00, 16, 2, 2),
(2460, NULL, NULL, NULL, 441, 'SAC', 21.00, 4.00, 17.00, 18, 2, 2),
(2461, NULL, NULL, NULL, 441, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(2462, NULL, NULL, NULL, 441, 'SAC', 66.00, 5.00, 61.00, 25, 2, 2),
(2463, NULL, NULL, NULL, 441, 'SAC', 21.00, 5.00, 16.00, 38, 2, 2),
(2464, NULL, NULL, NULL, 441, 'SAC', 0.00, 0.00, 0.00, 44, 2, 2),
(2465, NULL, NULL, NULL, 441, 'SAC', 15.00, 15.00, 0.00, 152, 2, 2),
(2466, NULL, NULL, NULL, 441, 'SAC', 10.00, 10.00, 0.00, 153, 2, 2),
(2467, NULL, NULL, NULL, NULL, 'INA', 0.00, 15.00, 15.00, 152, 2, 2),
(2468, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 153, 2, 2),
(2469, NULL, NULL, NULL, NULL, 'INA', 0.00, 180.00, 180.00, 44, 2, 2),
(2470, NULL, NULL, NULL, 442, 'SAC', 19.00, 15.00, 4.00, 13, 2, 2),
(2471, NULL, NULL, NULL, 442, 'SAC', 1016.00, 15.00, 1001.00, 16, 2, 2),
(2472, NULL, NULL, NULL, 442, 'SAC', 17.00, 4.00, 13.00, 18, 2, 2),
(2473, NULL, NULL, NULL, 442, 'SAC', 0.00, 5.00, -5.00, 24, 2, 2),
(2474, NULL, NULL, NULL, 442, 'SAC', 61.00, 5.00, 56.00, 25, 2, 2),
(2475, NULL, NULL, NULL, 442, 'SAC', 16.00, 5.00, 11.00, 38, 2, 2),
(2476, NULL, NULL, NULL, 442, 'SAC', 180.00, 10.00, 170.00, 44, 2, 2),
(2477, NULL, NULL, NULL, 442, 'SAC', 15.00, 15.00, 0.00, 152, 2, 2),
(2478, NULL, NULL, NULL, 442, 'SAC', 10.00, 10.00, 0.00, 153, 2, 2),
(2479, NULL, NULL, NULL, 443, 'SAC', 46.00, 3.00, 43.00, 15, 2, 2),
(2480, NULL, NULL, NULL, 443, 'SAC', 19.00, 2.00, 17.00, 22, 2, 2),
(2481, NULL, NULL, NULL, 443, 'SAC', 13.00, 1.00, 12.00, 48, 2, 2),
(2482, NULL, NULL, NULL, 443, 'SAC', 17.00, 2.00, 15.00, 57, 2, 2),
(2483, NULL, NULL, NULL, NULL, 'INA', 8.00, 20.00, 28.00, 19, 2, 2),
(2484, NULL, NULL, NULL, 444, 'SAC', 31.00, 10.00, 21.00, 1, 2, 2),
(2485, NULL, NULL, NULL, 444, 'SAC', 28.00, 10.00, 18.00, 19, 2, 2),
(2486, NULL, NULL, NULL, 444, 'SAC', 96.00, 2.00, 94.00, 34, 2, 2),
(2487, NULL, NULL, NULL, 445, 'SAC', 43.00, 1.00, 42.00, 15, 2, 2),
(2488, NULL, NULL, NULL, 445, 'SAC', 17.00, 2.00, 15.00, 22, 2, 2),
(2489, NULL, NULL, NULL, 445, 'SAC', 2.00, 2.00, 0.00, 98, 2, 2),
(2490, NULL, NULL, NULL, 446, 'SAC', 94.00, 1.00, 93.00, 34, 2, 2),
(2491, NULL, NULL, 7, NULL, 'INP', 0.00, 0.00, 0.00, 24, 2, 2),
(2492, NULL, NULL, 7, NULL, 'INP', 6.00, 10.00, 16.00, 164, 2, 2),
(2493, NULL, NULL, 7, NULL, 'INP', 19.00, 25.00, 44.00, 169, 2, 2),
(2494, NULL, NULL, 7, NULL, 'INP', 11.00, 15.00, 26.00, 170, 2, 2),
(2495, NULL, NULL, 7, NULL, 'INP', 5.00, 5.00, 10.00, 171, 2, 2),
(2496, NULL, NULL, NULL, 447, 'SAC', 462.00, 3.00, 459.00, 23, 2, 2),
(2497, NULL, NULL, NULL, 447, 'SAC', 0.00, 0.00, 0.00, 42, 2, 2),
(2498, NULL, NULL, NULL, 447, 'SAC', 234.00, 4.00, 230.00, 79, 2, 2),
(2499, NULL, NULL, NULL, 447, 'SAC', 289.00, 3.00, 286.00, 80, 2, 2),
(2500, NULL, NULL, NULL, 447, 'SAC', 235.00, 3.00, 232.00, 81, 2, 2),
(2501, NULL, NULL, NULL, NULL, 'IN1', 0.00, 30.00, 30.00, 175, 1, 2),
(2502, NULL, NULL, NULL, 448, 'SAC', 30.00, 1.00, 29.00, 175, 2, 2),
(2503, NULL, NULL, NULL, NULL, 'INA', 0.00, 100.00, 100.00, 98, 2, 2),
(2504, NULL, NULL, NULL, 449, 'SAC', 42.00, 1.00, 41.00, 15, 2, 2),
(2505, NULL, NULL, NULL, 449, 'SAC', 206.00, 1.00, 205.00, 88, 2, 2),
(2506, NULL, NULL, NULL, 449, 'SAC', 100.00, 1.00, 99.00, 98, 2, 2),
(2507, NULL, NULL, NULL, NULL, 'INA', 18.00, 30.00, 48.00, 19, 2, 2),
(2508, NULL, NULL, NULL, 450, 'SAC', 48.00, 2.00, 46.00, 19, 2, 2),
(2509, NULL, NULL, NULL, 450, 'SAC', 15.00, 2.00, 13.00, 57, 2, 2),
(2510, NULL, NULL, NULL, 450, 'SAC', 90.00, 10.00, 80.00, 92, 2, 2),
(2511, NULL, NULL, NULL, 451, 'SAC', 13.00, 2.00, 11.00, 57, 2, 2),
(2512, NULL, NULL, NULL, 452, 'SAC', 6.00, 1.00, 5.00, 14, 2, 2),
(2513, NULL, NULL, NULL, 452, 'SAC', 41.00, 1.00, 40.00, 15, 2, 2),
(2514, NULL, NULL, NULL, 452, 'SAC', 99.00, 1.00, 98.00, 98, 2, 2),
(2515, NULL, NULL, NULL, 453, 'SAC', 5.00, 1.00, 4.00, 14, 2, 2),
(2516, NULL, NULL, NULL, 453, 'SAC', 40.00, 1.00, 39.00, 15, 2, 2),
(2517, NULL, NULL, NULL, 453, 'SAC', 11.00, 1.00, 10.00, 57, 2, 2),
(2518, NULL, NULL, NULL, NULL, 'INA', 39.00, 10.00, 49.00, 15, 2, 2),
(2519, NULL, NULL, NULL, 454, 'SAC', 49.00, 1.00, 48.00, 15, 2, 2),
(2520, NULL, NULL, NULL, 454, 'SAC', 93.00, 1.00, 92.00, 34, 2, 2),
(2521, NULL, NULL, NULL, 454, 'SAC', 10.00, 1.00, 9.00, 57, 2, 2),
(2522, NULL, NULL, NULL, 454, 'SAC', 98.00, 2.00, 96.00, 98, 2, 2),
(2523, NULL, NULL, NULL, 455, 'SAC', 9.00, 1.00, 8.00, 57, 2, 2),
(2524, NULL, NULL, NULL, 455, 'SAC', 10.00, 1.00, 9.00, 60, 2, 2),
(2525, NULL, NULL, NULL, 456, 'SAC', 4.00, 2.00, 2.00, 14, 2, 2),
(2526, NULL, NULL, NULL, 456, 'SAC', 48.00, 5.00, 43.00, 15, 2, 2),
(2527, NULL, NULL, NULL, 456, 'SAC', 12.00, 1.00, 11.00, 48, 2, 2),
(2528, NULL, NULL, NULL, 456, 'SAC', 0.00, 0.00, 0.00, 50, 2, 2),
(2529, NULL, NULL, NULL, 456, 'SAC', 8.00, 1.00, 7.00, 57, 2, 2),
(2530, NULL, NULL, NULL, 456, 'SAC', 9.00, 1.00, 8.00, 60, 2, 2),
(2531, NULL, NULL, NULL, 457, 'SAC', 46.00, 10.00, 36.00, 19, 2, 2),
(2532, NULL, NULL, NULL, 458, 'SAC', 43.00, 1.00, 42.00, 15, 2, 2),
(2533, NULL, NULL, NULL, 459, 'SAC', 92.00, 3.00, 89.00, 34, 2, 2),
(2534, NULL, NULL, NULL, 459, 'SAC', 170.00, 3.00, 167.00, 44, 2, 2),
(2535, NULL, NULL, NULL, 460, 'SAC', 42.00, 2.00, 40.00, 15, 2, 2),
(2536, NULL, NULL, NULL, 460, 'SAC', 36.00, 10.00, 26.00, 19, 2, 2),
(2537, NULL, NULL, NULL, 460, 'SAC', 12.00, 1.00, 11.00, 40, 2, 2),
(2538, NULL, NULL, NULL, 461, 'SAC', 2.00, 1.00, 1.00, 14, 2, 2),
(2539, NULL, NULL, NULL, 461, 'SAC', 11.00, 1.00, 10.00, 38, 2, 2),
(2540, NULL, NULL, NULL, 461, 'SAC', 205.00, 1.00, 204.00, 88, 2, 2),
(2541, NULL, NULL, NULL, 461, 'SAC', 57.00, 1.00, 56.00, 89, 2, 2),
(2542, NULL, NULL, NULL, 462, 'SAC', 204.00, 2.00, 202.00, 88, 2, 2),
(2543, NULL, NULL, NULL, 462, 'SAC', 80.00, 2.00, 78.00, 92, 2, 2),
(2544, NULL, NULL, NULL, 463, 'SAC', 78.00, 1.00, 77.00, 92, 2, 2),
(2545, NULL, NULL, NULL, 464, 'SAC', 40.00, 1.00, 39.00, 15, 2, 2),
(2546, NULL, NULL, NULL, 464, 'SAC', 93.00, 1.00, 92.00, 90, 2, 2),
(2547, NULL, NULL, NULL, 464, 'SAC', 77.00, 1.00, 76.00, 92, 2, 2),
(2548, NULL, NULL, NULL, 465, 'SAC', 39.00, 1.00, 38.00, 15, 2, 2),
(2549, NULL, NULL, NULL, 465, 'SAC', 7.00, 2.00, 5.00, 57, 2, 2),
(2550, NULL, NULL, NULL, 465, 'SAC', 96.00, 2.00, 94.00, 98, 2, 2),
(2551, NULL, NULL, NULL, 465, 'SAC', 14.00, 1.00, 13.00, 105, 2, 2),
(2552, NULL, NULL, NULL, NULL, 'INA', 5.00, 20.00, 25.00, 57, 2, 2),
(2553, NULL, NULL, NULL, NULL, 'INA', 1.00, 20.00, 21.00, 14, 2, 2),
(2554, NULL, NULL, NULL, 466, 'SAC', 21.00, 5.00, 16.00, 14, 2, 2),
(2555, NULL, NULL, NULL, 466, 'SAC', 38.00, 5.00, 33.00, 15, 2, 2),
(2556, NULL, NULL, NULL, 466, 'SAC', 26.00, 15.00, 11.00, 19, 2, 2),
(2557, NULL, NULL, NULL, 466, 'SAC', 89.00, 10.00, 79.00, 34, 2, 2),
(2558, NULL, NULL, NULL, 466, 'SAC', 0.00, 0.00, 0.00, 36, 2, 2),
(2559, NULL, NULL, NULL, 466, 'SAC', 11.00, 2.00, 9.00, 48, 2, 2),
(2560, NULL, NULL, NULL, 466, 'SAC', 25.00, 12.00, 13.00, 57, 2, 2),
(2561, NULL, NULL, NULL, 466, 'SAC', 94.00, 10.00, 84.00, 98, 2, 2),
(2562, NULL, NULL, NULL, 466, 'SAC', 2.00, 1.00, 1.00, 106, 2, 2),
(2563, NULL, NULL, NULL, 467, 'SAC', 84.00, 40.00, 44.00, 98, 2, 2),
(2564, NULL, NULL, 8, NULL, 'INP', 15.00, 250.00, 265.00, 22, 2, 2),
(2565, NULL, NULL, 9, NULL, 'INP', 265.00, 250.00, 515.00, 22, 2, 2),
(2566, NULL, NULL, NULL, NULL, 'INA', 0.00, 15.00, 15.00, 153, 2, 2),
(2567, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 176, 1, 2),
(2568, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 152, 2, 2),
(2569, NULL, NULL, NULL, NULL, 'INA', 4.00, 20.00, 24.00, 13, 2, 2),
(2570, NULL, NULL, NULL, 468, 'SAC', 24.00, 10.00, 14.00, 13, 2, 2),
(2571, NULL, NULL, NULL, 468, 'SAC', 0.00, 5.00, -5.00, 36, 2, 2),
(2572, NULL, NULL, NULL, 468, 'SAC', 10.00, 10.00, 0.00, 38, 2, 2),
(2573, NULL, NULL, NULL, 468, 'SAC', 10.00, 10.00, 0.00, 152, 2, 2),
(2574, NULL, NULL, NULL, 468, 'SAC', 15.00, 15.00, 0.00, 153, 2, 2),
(2575, NULL, NULL, NULL, 468, 'SAC', 10.00, 10.00, 0.00, 176, 2, 2),
(2576, NULL, NULL, NULL, 469, 'SAC', 16.00, 4.00, 12.00, 14, 2, 2),
(2577, NULL, NULL, NULL, 469, 'SAC', 33.00, 10.00, 23.00, 15, 2, 2),
(2578, NULL, NULL, NULL, 469, 'SAC', 11.00, 8.00, 3.00, 19, 2, 2),
(2579, NULL, NULL, NULL, 469, 'SAC', 0.00, 1.00, -1.00, 24, 2, 2),
(2580, NULL, NULL, NULL, 469, 'SAC', 56.00, 1.00, 55.00, 25, 2, 2),
(2581, NULL, NULL, NULL, 469, 'SAC', 79.00, 6.00, 73.00, 34, 2, 2),
(2582, NULL, NULL, NULL, 469, 'SAC', 167.00, 3.00, 164.00, 44, 2, 2),
(2583, NULL, NULL, NULL, 469, 'SAC', 0.00, 1.00, -1.00, 46, 2, 2),
(2584, NULL, NULL, NULL, 470, 'SAC', 23.00, 2.00, 21.00, 15, 2, 2),
(2585, NULL, NULL, NULL, 470, 'SAC', 13.00, 1.00, 12.00, 18, 2, 2),
(2586, NULL, NULL, NULL, 470, 'SAC', 13.00, 1.00, 12.00, 57, 2, 2),
(2587, NULL, NULL, NULL, 470, 'SAC', 44.00, 3.00, 41.00, 98, 2, 2),
(2588, NULL, NULL, NULL, 470, 'SAC', 12.00, 1.00, 11.00, 100, 2, 2),
(2589, NULL, NULL, NULL, 470, 'SAC', 6.00, 1.00, 5.00, 136, 2, 2),
(2590, NULL, NULL, NULL, 471, 'SAC', 9.00, 1.00, 8.00, 48, 2, 2),
(2591, NULL, NULL, NULL, 471, 'SAC', 12.00, 5.00, 7.00, 57, 2, 2),
(2592, NULL, NULL, NULL, 472, 'SAC', 0.00, 5.00, -5.00, 38, 2, 2),
(2593, NULL, NULL, NULL, 472, 'SAC', 8.00, 5.00, 3.00, 48, 2, 2),
(2594, NULL, NULL, NULL, NULL, 'INA', 21.00, 50.00, 71.00, 15, 2, 2),
(2595, NULL, NULL, NULL, NULL, 'INA', 41.00, 50.00, 91.00, 98, 2, 2),
(2596, NULL, NULL, NULL, NULL, 'IN1', 0.00, 100.00, 100.00, 177, 1, 2),
(2597, NULL, NULL, NULL, NULL, 'IN1', 0.00, 12.00, 12.00, 178, 1, 2),
(2598, NULL, NULL, NULL, NULL, 'IN1', 0.00, 12.00, 12.00, 179, 1, 2),
(2599, NULL, NULL, NULL, 473, 'SAC', 12.00, 7.00, 5.00, 14, 2, 2),
(2600, NULL, NULL, NULL, 473, 'SAC', 71.00, 55.00, 16.00, 15, 2, 2),
(2601, NULL, NULL, NULL, 473, 'SAC', 459.00, 5.00, 454.00, 23, 2, 2),
(2602, NULL, NULL, NULL, 473, 'SAC', 3.00, 10.00, -7.00, 48, 2, 2),
(2603, NULL, NULL, NULL, 473, 'SAC', 8.00, 3.00, 5.00, 60, 2, 2),
(2604, NULL, NULL, NULL, 473, 'SAC', 91.00, 50.00, 41.00, 98, 2, 2),
(2605, NULL, NULL, NULL, 473, 'SAC', 131.00, 2.00, 129.00, 111, 2, 2),
(2606, NULL, NULL, NULL, 473, 'SAC', 168.00, 3.00, 165.00, 117, 2, 2),
(2607, NULL, NULL, NULL, 473, 'SAC', 100.00, 7.00, 93.00, 177, 2, 2),
(2608, NULL, NULL, NULL, 473, 'SAC', 12.00, 12.00, 0.00, 178, 2, 2),
(2609, NULL, NULL, NULL, 473, 'SAC', 12.00, 12.00, 0.00, 179, 2, 2),
(2610, NULL, NULL, NULL, NULL, 'INA', 16.00, 40.00, 56.00, 15, 2, 2),
(2611, NULL, NULL, NULL, NULL, 'INA', 41.00, 20.00, 61.00, 98, 2, 2),
(2612, NULL, NULL, NULL, NULL, 'INA', 454.00, 5.00, 459.00, 23, 2, 2),
(2613, NULL, NULL, NULL, NULL, 'INA', 5.00, 5.00, 10.00, 60, 2, 2),
(2614, NULL, NULL, NULL, NULL, 'INA', 0.00, 12.00, 12.00, 178, 2, 2),
(2615, NULL, NULL, NULL, NULL, 'INA', 0.00, 12.00, 12.00, 179, 2, 2),
(2616, NULL, NULL, NULL, 474, 'SAC', 5.00, 7.00, -2.00, 14, 2, 2),
(2617, NULL, NULL, NULL, 474, 'SAC', 56.00, 50.00, 6.00, 15, 2, 2),
(2618, NULL, NULL, NULL, 474, 'SAC', 459.00, 10.00, 449.00, 23, 2, 2),
(2619, NULL, NULL, NULL, 474, 'SAC', 0.00, 0.00, 0.00, 48, 2, 2),
(2620, NULL, NULL, NULL, 474, 'SAC', 10.00, 3.00, 7.00, 60, 2, 2),
(2621, NULL, NULL, NULL, 474, 'SAC', 61.00, 55.00, 6.00, 98, 2, 2),
(2622, NULL, NULL, NULL, 474, 'SAC', 129.00, 2.00, 127.00, 111, 2, 2),
(2623, NULL, NULL, NULL, 474, 'SAC', 165.00, 3.00, 162.00, 117, 2, 2),
(2624, NULL, NULL, NULL, 474, 'SAC', 93.00, 7.00, 86.00, 177, 2, 2),
(2625, NULL, NULL, NULL, 474, 'SAC', 12.00, 12.00, 0.00, 178, 2, 2),
(2626, NULL, NULL, NULL, 474, 'SAC', 12.00, 12.00, 0.00, 179, 2, 2),
(2627, NULL, NULL, NULL, 475, 'SAC', 6.00, 2.00, 4.00, 15, 2, 2),
(2628, NULL, NULL, NULL, 475, 'SAC', 73.00, 2.00, 71.00, 34, 2, 2),
(2629, NULL, NULL, NULL, 475, 'SAC', 15.00, 2.00, 13.00, 99, 2, 2),
(2630, NULL, NULL, NULL, NULL, 'INA', 6.00, 100.00, 106.00, 98, 2, 2),
(2631, NULL, NULL, NULL, 476, 'SAC', 106.00, 50.00, 56.00, 98, 2, 2),
(2632, NULL, NULL, NULL, NULL, 'INA', 4.00, 50.00, 54.00, 15, 2, 2),
(2633, NULL, NULL, NULL, NULL, 'INA', 1001.00, 10.00, 1011.00, 16, 2, 2),
(2634, NULL, NULL, NULL, NULL, 'INA', 0.00, 15.00, 15.00, 35, 2, 2),
(2635, NULL, NULL, NULL, 477, 'SAC', 14.00, 15.00, -1.00, 13, 2, 2),
(2636, NULL, NULL, NULL, 477, 'SAC', 54.00, 10.00, 44.00, 15, 2, 2),
(2637, NULL, NULL, NULL, 477, 'SAC', 1011.00, 10.00, 1001.00, 16, 2, 2),
(2638, NULL, NULL, NULL, 477, 'SAC', 12.00, 5.00, 7.00, 18, 2, 2),
(2639, NULL, NULL, NULL, 477, 'SAC', 15.00, 5.00, 10.00, 35, 2, 2),
(2640, NULL, NULL, NULL, 477, 'SAC', 7.00, 5.00, 2.00, 57, 2, 2),
(2641, NULL, NULL, NULL, 477, 'SAC', 10.00, 5.00, 5.00, 58, 2, 2),
(2642, NULL, NULL, NULL, 477, 'SAC', 56.00, 10.00, 46.00, 98, 2, 2),
(2643, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 13, 2, 2),
(2644, NULL, NULL, NULL, NULL, 'INA', 1001.00, 50.00, 1051.00, 16, 2, 2),
(2645, NULL, NULL, NULL, 478, 'SAC', 0.00, 50.00, -50.00, 13, 2, 2),
(2646, NULL, NULL, NULL, 478, 'SAC', 1051.00, 10.00, 1041.00, 16, 2, 2),
(2647, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 49, 2, 2),
(2648, NULL, NULL, NULL, NULL, 'IN1', 0.00, 10.00, 10.00, 180, 1, 2),
(2649, NULL, NULL, NULL, 479, 'SAC', 0.00, 0.00, 0.00, 13, 2, 2),
(2650, NULL, NULL, NULL, 479, 'SAC', 44.00, 3.00, 41.00, 15, 2, 2),
(2651, NULL, NULL, NULL, 479, 'SAC', 1041.00, 1.00, 1040.00, 16, 2, 2),
(2652, NULL, NULL, NULL, 479, 'SAC', 7.00, 1.00, 6.00, 18, 2, 2),
(2653, NULL, NULL, NULL, 479, 'SAC', 3.00, 1.00, 2.00, 19, 2, 2),
(2654, NULL, NULL, NULL, 479, 'SAC', 515.00, 1.00, 514.00, 22, 2, 2),
(2655, NULL, NULL, NULL, 479, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(2656, NULL, NULL, NULL, 479, 'SAC', 10.00, 1.00, 9.00, 35, 2, 2),
(2657, NULL, NULL, NULL, 479, 'SAC', 0.00, 0.00, 0.00, 38, 2, 2),
(2658, NULL, NULL, NULL, 479, 'SAC', 3.00, 1.00, 2.00, 39, 2, 2),
(2659, NULL, NULL, NULL, 479, 'SAC', 0.00, 1.00, -1.00, 42, 2, 2),
(2660, NULL, NULL, NULL, 479, 'SAC', 0.00, 2.00, -2.00, 49, 2, 2),
(2661, NULL, NULL, NULL, 479, 'SAC', 5.00, 1.00, 4.00, 58, 2, 2),
(2662, NULL, NULL, NULL, 479, 'SAC', 46.00, 1.00, 45.00, 98, 2, 2),
(2663, NULL, NULL, NULL, 479, 'SAC', 10.00, 1.00, 9.00, 180, 2, 2),
(2664, NULL, NULL, NULL, NULL, 'INA', 45.00, 50.00, 95.00, 98, 2, 2),
(2665, NULL, NULL, NULL, NULL, 'INA', 41.00, 50.00, 91.00, 15, 2, 2),
(2666, NULL, NULL, NULL, NULL, 'INA', 2.00, 10.00, 12.00, 122, 2, 2),
(2667, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 63, 2, 2),
(2668, NULL, NULL, NULL, NULL, 'INA', 1.00, 5.00, 6.00, 65, 2, 2),
(2669, NULL, NULL, NULL, 480, 'SAC', 514.00, 4.00, 510.00, 22, 2, 2),
(2670, NULL, NULL, NULL, 480, 'SAC', 449.00, 5.00, 444.00, 23, 2, 2),
(2671, NULL, NULL, NULL, 480, 'SAC', 55.00, 5.00, 50.00, 25, 2, 2),
(2672, NULL, NULL, NULL, 480, 'SAC', 0.00, 2.00, -2.00, 48, 2, 2),
(2673, NULL, NULL, NULL, 480, 'SAC', 10.00, 5.00, 5.00, 63, 2, 2),
(2674, NULL, NULL, NULL, 480, 'SAC', 6.00, 1.00, 5.00, 65, 2, 2),
(2675, NULL, NULL, NULL, 480, 'SAC', 95.00, 28.00, 67.00, 98, 2, 2),
(2676, NULL, NULL, NULL, 480, 'SAC', 12.00, 8.00, 4.00, 122, 2, 2),
(2677, NULL, NULL, NULL, 480, 'SAC', 7.00, 1.00, 6.00, 123, 2, 2),
(2678, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 14, 2, 2),
(2679, NULL, NULL, NULL, 481, 'SAC', 0.00, 3.00, -3.00, 14, 2, 2),
(2680, NULL, NULL, NULL, 481, 'SAC', 91.00, 22.00, 69.00, 15, 2, 2),
(2681, NULL, NULL, NULL, 481, 'SAC', 510.00, 15.00, 495.00, 22, 2, 2),
(2682, NULL, NULL, NULL, 481, 'SAC', 7.00, 2.00, 5.00, 60, 2, 2),
(2683, NULL, NULL, NULL, 481, 'SAC', 5.00, 5.00, 0.00, 63, 2, 2),
(2684, NULL, NULL, NULL, 481, 'SAC', 5.00, 5.00, 0.00, 65, 2, 2),
(2685, NULL, NULL, NULL, 481, 'SAC', 67.00, 15.00, 52.00, 98, 2, 2),
(2686, NULL, NULL, NULL, 481, 'SAC', 13.00, 1.00, 12.00, 99, 2, 2),
(2687, NULL, NULL, NULL, 482, 'SAC', 69.00, 2.00, 67.00, 15, 2, 2),
(2688, NULL, NULL, NULL, 482, 'SAC', 2.00, 1.00, 1.00, 19, 2, 2),
(2689, NULL, NULL, NULL, 482, 'SAC', 71.00, 1.00, 70.00, 34, 2, 2),
(2690, NULL, NULL, NULL, 482, 'SAC', 52.00, 2.00, 50.00, 98, 2, 2),
(2691, NULL, NULL, NULL, 483, 'SAC', 495.00, 30.00, 465.00, 22, 2, 2),
(2692, NULL, NULL, NULL, 483, 'SAC', 444.00, 20.00, 424.00, 23, 2, 2),
(2693, NULL, NULL, NULL, 483, 'SAC', 0.00, 30.00, -30.00, 24, 2, 2),
(2694, NULL, NULL, NULL, 483, 'SAC', 70.00, 40.00, 30.00, 34, 2, 2),
(2695, NULL, NULL, NULL, 483, 'SAC', 0.00, 10.00, -10.00, 38, 2, 2),
(2696, NULL, NULL, NULL, 483, 'SAC', 5.00, 5.00, 0.00, 60, 2, 2),
(2697, NULL, NULL, NULL, 483, 'SAC', 124.00, 5.00, 119.00, 77, 2, 2),
(2698, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 166, 2, 2),
(2699, NULL, NULL, NULL, 484, 'SAC', 5.00, 1.00, 4.00, 148, 2, 2),
(2700, NULL, NULL, NULL, 484, 'SAC', 1.00, 1.00, 0.00, 166, 2, 2),
(2701, NULL, NULL, NULL, NULL, 'INA', 4.00, 1.00, 5.00, 148, 2, 2),
(2702, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 166, 2, 2),
(2703, NULL, NULL, NULL, 485, 'SAC', 5.00, 1.00, 4.00, 148, 2, 2),
(2704, NULL, NULL, NULL, 485, 'SAC', 5.00, 1.00, 4.00, 166, 2, 2),
(2705, NULL, NULL, NULL, 486, 'SAC', 232.00, 1.00, 231.00, 81, 2, 2),
(2706, NULL, NULL, NULL, 486, 'SAC', 76.00, 1.00, 75.00, 92, 2, 2),
(2707, NULL, NULL, NULL, 486, 'SAC', 84.00, 1.00, 83.00, 93, 2, 2),
(2708, NULL, NULL, NULL, 487, 'SAC', 0.00, 1.00, -1.00, 13, 2, 2),
(2709, NULL, NULL, NULL, 488, 'SAC', 2.00, 1.00, 1.00, 39, 2, 2),
(2710, NULL, NULL, NULL, 488, 'SAC', 0.00, 0.00, 0.00, 49, 2, 2),
(2711, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 13, 2, 2),
(2712, NULL, NULL, NULL, 489, 'SAC', 0.00, 1.00, -1.00, 13, 2, 2),
(2713, NULL, NULL, NULL, 490, 'SAC', 1040.00, 1.00, 1039.00, 16, 2, 2),
(2714, NULL, NULL, NULL, 491, 'SAC', 6.00, 1.00, 5.00, 18, 2, 2),
(2715, NULL, NULL, NULL, 491, 'SAC', 20.00, 1.00, 19.00, 87, 2, 2),
(2716, NULL, NULL, NULL, 491, 'SAC', 75.00, 1.00, 74.00, 92, 2, 2),
(2717, NULL, NULL, NULL, 492, 'SAC', 67.00, 1.00, 66.00, 15, 2, 2),
(2718, NULL, NULL, NULL, 492, 'SAC', 30.00, 1.00, 29.00, 34, 2, 2),
(2719, NULL, NULL, NULL, 492, 'SAC', 0.00, 0.00, 0.00, 38, 2, 2),
(2720, NULL, NULL, NULL, 492, 'SAC', 164.00, 1.00, 163.00, 44, 2, 2),
(2721, NULL, NULL, NULL, 492, 'SAC', 50.00, 1.00, 49.00, 98, 2, 2),
(2722, NULL, NULL, NULL, 493, 'SAC', 1039.00, 4.00, 1035.00, 16, 2, 2),
(2723, NULL, NULL, NULL, 493, 'SAC', 29.00, 1.00, 28.00, 34, 2, 2),
(2724, NULL, NULL, NULL, 493, 'SAC', 0.00, 0.00, 0.00, 48, 2, 2),
(2725, NULL, NULL, NULL, 493, 'SAC', 49.00, 1.00, 48.00, 98, 2, 2),
(2726, NULL, NULL, NULL, 494, 'SAC', 2.00, 1.00, 1.00, 57, 2, 2),
(2727, NULL, NULL, NULL, 495, 'SAC', 66.00, 1.00, 65.00, 15, 2, 2),
(2728, NULL, NULL, NULL, 496, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(2729, NULL, NULL, NULL, 496, 'SAC', 50.00, 2.00, 48.00, 25, 2, 2),
(2730, NULL, NULL, NULL, 497, 'SAC', 65.00, 1.00, 64.00, 15, 2, 2),
(2731, NULL, NULL, NULL, 497, 'SAC', 424.00, 1.00, 423.00, 23, 2, 2),
(2732, NULL, NULL, NULL, 497, 'SAC', 28.00, 1.00, 27.00, 34, 2, 2),
(2733, NULL, NULL, NULL, 497, 'SAC', 0.00, 1.00, -1.00, 38, 2, 2),
(2734, NULL, NULL, NULL, 497, 'SAC', 48.00, 2.00, 46.00, 98, 2, 2),
(2735, NULL, NULL, NULL, NULL, 'INA', 0.00, 0.00, 0.00, 14, 2, 2),
(2736, NULL, NULL, NULL, 498, 'SAC', 0.00, 4.00, -4.00, 14, 2, 2),
(2737, NULL, NULL, NULL, 498, 'SAC', 64.00, 11.00, 53.00, 15, 2, 2),
(2738, NULL, NULL, NULL, 498, 'SAC', 465.00, 5.00, 460.00, 22, 2, 2),
(2739, NULL, NULL, NULL, 498, 'SAC', 163.00, 3.00, 160.00, 44, 2, 2),
(2740, NULL, NULL, NULL, 498, 'SAC', 0.00, 0.00, 0.00, 46, 2, 2),
(2741, NULL, NULL, NULL, 498, 'SAC', 0.00, 3.00, -3.00, 48, 2, 2),
(2742, NULL, NULL, NULL, 498, 'SAC', 0.00, 2.00, -2.00, 50, 2, 2),
(2743, NULL, NULL, NULL, 498, 'SAC', 46.00, 10.00, 36.00, 98, 2, 2),
(2744, NULL, NULL, NULL, 498, 'SAC', 12.00, 2.00, 10.00, 99, 2, 2),
(2745, NULL, NULL, NULL, NULL, 'INA', 0.00, 20.00, 20.00, 63, 2, 2),
(2746, NULL, NULL, NULL, NULL, 'INA', 0.00, 1.00, 1.00, 66, 2, 2),
(2747, NULL, NULL, NULL, 499, 'SAC', 0.00, 0.00, 0.00, 42, 2, 2),
(2748, NULL, NULL, NULL, 499, 'SAC', 20.00, 1.00, 19.00, 63, 2, 2),
(2749, NULL, NULL, NULL, 499, 'SAC', 1.00, 1.00, 0.00, 66, 2, 2),
(2750, NULL, NULL, NULL, NULL, 'INA', 11.00, 5.00, 16.00, 100, 2, 2),
(2751, NULL, NULL, NULL, 500, 'SAC', 1035.00, 1.00, 1034.00, 16, 2, 2),
(2752, NULL, NULL, NULL, 500, 'SAC', 460.00, 1.00, 459.00, 22, 2, 2),
(2753, NULL, NULL, NULL, 500, 'SAC', 36.00, 1.00, 35.00, 98, 2, 2),
(2754, NULL, NULL, NULL, 500, 'SAC', 16.00, 1.00, 15.00, 100, 2, 2),
(2755, NULL, NULL, NULL, 501, 'SAC', 0.00, 0.00, 0.00, 14, 2, 2),
(2756, NULL, NULL, NULL, 501, 'SAC', 53.00, 4.00, 49.00, 15, 2, 2),
(2757, NULL, NULL, NULL, 501, 'SAC', 459.00, 2.00, 457.00, 22, 2, 2),
(2758, NULL, NULL, NULL, 501, 'SAC', 0.00, 1.00, -1.00, 24, 2, 2),
(2759, NULL, NULL, NULL, 501, 'SAC', 27.00, 2.00, 25.00, 34, 2, 2),
(2760, NULL, NULL, NULL, 501, 'SAC', 0.00, 0.00, 0.00, 48, 2, 2),
(2761, NULL, NULL, NULL, 501, 'SAC', 19.00, 1.00, 18.00, 63, 2, 2),
(2762, NULL, NULL, NULL, 501, 'SAC', 35.00, 3.00, 32.00, 98, 2, 2),
(2763, NULL, NULL, NULL, 502, 'SAC', 49.00, 2.00, 47.00, 15, 2, 2),
(2764, NULL, NULL, NULL, 502, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(2765, NULL, NULL, NULL, 502, 'SAC', 231.00, 1.00, 230.00, 81, 2, 2),
(2766, NULL, NULL, NULL, 502, 'SAC', 19.00, 1.00, 18.00, 87, 2, 2),
(2767, NULL, NULL, NULL, 502, 'SAC', 56.00, 1.00, 55.00, 89, 2, 2),
(2768, NULL, NULL, NULL, 502, 'SAC', 190.00, 1.00, 189.00, 91, 2, 2),
(2769, NULL, NULL, NULL, 502, 'SAC', 32.00, 4.00, 28.00, 98, 2, 2),
(2770, NULL, NULL, NULL, 503, 'SAC', 47.00, 1.00, 46.00, 15, 2, 2),
(2771, NULL, NULL, NULL, 503, 'SAC', 5.00, 1.00, 4.00, 18, 2, 2),
(2772, NULL, NULL, NULL, 503, 'SAC', 7.00, 1.00, 6.00, 59, 2, 2),
(2773, NULL, NULL, NULL, NULL, 'INA', 0.00, 5.00, 5.00, 135, 2, 2),
(2774, NULL, NULL, NULL, 504, 'SAC', 46.00, 1.00, 45.00, 15, 2, 2),
(2775, NULL, NULL, NULL, 504, 'SAC', 4.00, 1.00, 3.00, 18, 2, 2),
(2776, NULL, NULL, NULL, 504, 'SAC', 457.00, 1.00, 456.00, 22, 2, 2),
(2777, NULL, NULL, NULL, 504, 'SAC', 25.00, 1.00, 24.00, 34, 2, 2),
(2778, NULL, NULL, NULL, 504, 'SAC', 1.00, 1.00, 0.00, 45, 2, 2),
(2779, NULL, NULL, NULL, 504, 'SAC', 0.00, 1.00, -1.00, 49, 2, 2),
(2780, NULL, NULL, NULL, 504, 'SAC', 6.00, 1.00, 5.00, 59, 2, 2),
(2781, NULL, NULL, NULL, 504, 'SAC', 28.00, 1.00, 27.00, 98, 2, 2),
(2782, NULL, NULL, NULL, 504, 'SAC', 15.00, 1.00, 14.00, 100, 2, 2),
(2783, NULL, NULL, NULL, 504, 'SAC', 19.50, 1.00, 18.50, 101, 2, 2),
(2784, NULL, NULL, NULL, 504, 'SAC', 5.00, 1.00, 4.00, 135, 2, 2),
(2785, NULL, NULL, NULL, 505, 'SAC', 45.00, 4.00, 41.00, 15, 2, 2),
(2786, NULL, NULL, NULL, 505, 'SAC', 3.00, 1.00, 2.00, 18, 2, 2),
(2787, NULL, NULL, NULL, 505, 'SAC', 48.00, 1.00, 47.00, 25, 2, 2),
(2788, NULL, NULL, NULL, 505, 'SAC', 0.00, 1.00, -1.00, 46, 2, 2),
(2789, NULL, NULL, NULL, 505, 'SAC', 0.00, 1.00, -1.00, 48, 2, 2),
(2790, NULL, NULL, NULL, 505, 'SAC', 4.00, 1.00, 3.00, 58, 2, 2),
(2791, NULL, NULL, NULL, 505, 'SAC', 5.00, 1.00, 4.00, 59, 2, 2),
(2792, NULL, NULL, NULL, 505, 'SAC', 27.00, 5.00, 22.00, 98, 2, 2),
(2793, NULL, NULL, NULL, 505, 'SAC', 10.00, 1.00, 9.00, 99, 2, 2),
(2794, NULL, NULL, NULL, 506, 'SAC', 22.00, 21.00, 1.00, 98, 2, 2),
(2795, NULL, NULL, NULL, NULL, 'INA', 1.00, 200.00, 201.00, 98, 2, 2),
(2796, NULL, NULL, NULL, 507, 'SAC', 201.00, 150.00, 51.00, 98, 2, 2),
(2797, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 65, 2, 2),
(2798, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1.00, 1.00, 181, 1, 2),
(2799, NULL, NULL, NULL, NULL, 'INA', 1.00, 30.00, 31.00, 19, 2, 2),
(2800, NULL, NULL, NULL, 508, 'SAC', 0.00, 3.00, -3.00, 14, 2, 2),
(2801, NULL, NULL, NULL, 508, 'SAC', 41.00, 17.00, 24.00, 15, 2, 2),
(2802, NULL, NULL, NULL, 508, 'SAC', 31.00, 2.00, 29.00, 19, 2, 2),
(2803, NULL, NULL, NULL, 508, 'SAC', 423.00, 1.00, 422.00, 23, 2, 2),
(2804, NULL, NULL, NULL, 508, 'SAC', 0.00, 1.00, -1.00, 24, 2, 2),
(2805, NULL, NULL, NULL, 508, 'SAC', 24.00, 5.00, 19.00, 34, 2, 2),
(2806, NULL, NULL, NULL, 508, 'SAC', 0.00, 0.00, 0.00, 48, 2, 2),
(2807, NULL, NULL, NULL, 508, 'SAC', 1.00, 1.00, 0.00, 57, 2, 2),
(2808, NULL, NULL, NULL, 508, 'SAC', 4.00, 2.00, 2.00, 59, 2, 2),
(2809, NULL, NULL, NULL, 508, 'SAC', 18.00, 5.00, 13.00, 63, 2, 2),
(2810, NULL, NULL, NULL, 508, 'SAC', 10.00, 5.00, 5.00, 65, 2, 2),
(2811, NULL, NULL, NULL, 508, 'SAC', 119.00, 1.00, 118.00, 77, 2, 2),
(2812, NULL, NULL, NULL, 508, 'SAC', 51.00, 14.00, 37.00, 98, 2, 2),
(2813, NULL, NULL, NULL, 508, 'SAC', 9.00, 1.00, 8.00, 99, 2, 2),
(2814, NULL, NULL, NULL, 508, 'SAC', 1.00, 1.00, 0.00, 181, 2, 2),
(2815, NULL, NULL, NULL, 509, 'SAC', 0.00, 0.00, 0.00, 13, 2, 2),
(2816, NULL, NULL, NULL, 509, 'SAC', 1034.00, 2.00, 1032.00, 16, 2, 2),
(2817, NULL, NULL, NULL, 509, 'SAC', 2.00, 1.00, 1.00, 18, 2, 2),
(2818, NULL, NULL, NULL, 509, 'SAC', 19.00, 1.00, 18.00, 34, 2, 2),
(2819, NULL, NULL, NULL, 509, 'SAC', 37.00, 5.00, 32.00, 98, 2, 2),
(2820, NULL, NULL, NULL, 509, 'SAC', 5.00, 1.00, 4.00, 136, 2, 2),
(2821, NULL, NULL, NULL, NULL, 'INA', 21.00, 30.00, 51.00, 1, 2, 2),
(2822, NULL, NULL, NULL, NULL, 'INA', 0.00, 30.00, 30.00, 57, 2, 2),
(2823, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 168, 2, 2),
(2824, NULL, NULL, NULL, NULL, 'INA', 2.00, 5.00, 7.00, 59, 2, 2),
(2825, NULL, NULL, NULL, 510, 'SAC', 51.00, 20.00, 31.00, 1, 2, 2),
(2826, NULL, NULL, NULL, 510, 'SAC', 30.00, 25.00, 5.00, 57, 2, 2),
(2827, NULL, NULL, NULL, 510, 'SAC', 7.00, 5.00, 2.00, 59, 2, 2),
(2828, NULL, NULL, NULL, 510, 'SAC', 8.00, 5.00, 3.00, 99, 2, 2),
(2829, NULL, NULL, NULL, 510, 'SAC', 10.00, 5.00, 5.00, 168, 2, 2),
(2830, NULL, NULL, NULL, 511, 'SAC', 24.00, 1.00, 23.00, 15, 2, 2),
(2831, NULL, NULL, NULL, 511, 'SAC', 1032.00, 1.00, 1031.00, 16, 2, 2),
(2832, NULL, NULL, NULL, 511, 'SAC', 1.00, 1.00, 0.00, 18, 2, 2),
(2833, NULL, NULL, NULL, 511, 'SAC', 160.00, 1.00, 159.00, 44, 2, 2),
(2834, NULL, NULL, NULL, 511, 'SAC', 32.00, 1.00, 31.00, 98, 2, 2),
(2835, NULL, NULL, NULL, 512, 'SAC', 0.00, 0.00, 0.00, 46, 2, 2),
(2836, NULL, NULL, NULL, 512, 'SAC', 0.00, 2.00, -2.00, 48, 2, 2),
(2837, NULL, NULL, NULL, 512, 'SAC', 4.00, 1.00, 3.00, 73, 2, 2),
(2838, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 153, 2, 2),
(2839, NULL, NULL, NULL, NULL, 'INA', 0.00, 10.00, 10.00, 152, 2, 2),
(2840, NULL, NULL, NULL, 513, 'SAC', 0.00, 10.00, -10.00, 13, 2, 2),
(2841, NULL, NULL, NULL, 513, 'SAC', 0.00, 0.00, 0.00, 14, 2, 2),
(2842, NULL, NULL, NULL, 513, 'SAC', 1031.00, 10.00, 1021.00, 16, 2, 2),
(2843, NULL, NULL, NULL, 513, 'SAC', 0.00, 0.00, 0.00, 24, 2, 2),
(2844, NULL, NULL, NULL, 513, 'SAC', 5.00, 5.00, 0.00, 57, 2, 2),
(2845, NULL, NULL, NULL, 513, 'SAC', 10.00, 10.00, 0.00, 152, 2, 2),
(2846, NULL, NULL, NULL, 513, 'SAC', 10.00, 10.00, 0.00, 153, 2, 2),
(2847, NULL, NULL, NULL, 514, 'SAC', 456.00, 2.00, 454.00, 22, 2, 3),
(2848, NULL, NULL, NULL, 514, 'SAC', 127.00, 3.00, 124.00, 111, 2, 3),
(2849, NULL, NULL, NULL, 515, 'SAC', 29.00, 3.00, 26.00, 19, 2, 3),
(2850, NULL, NULL, NULL, 515, 'SAC', 4.00, 3.00, 1.00, 114, 2, 3),
(2851, NULL, NULL, NULL, 516, 'SAC', 454.00, 3.00, 451.00, 22, 2, 3),
(2852, NULL, NULL, NULL, 516, 'SAC', 46.00, 4.00, 42.00, 118, 2, 3),
(2853, NULL, NULL, 10, NULL, 'INP', 1.00, 5.00, 6.00, 114, 2, 3),
(2854, NULL, NULL, 11, NULL, 'INP', 26.00, 5.00, 31.00, 19, 2, 3),
(2855, NULL, NULL, NULL, 517, 'SAC', 6.00, 2.00, 4.00, 114, 2, 3),
(2856, NULL, NULL, NULL, 518, 'SAC', 4.00, 3.00, 1.00, 114, 2, 3),
(2857, NULL, NULL, NULL, 519, 'SAC', 1.00, 1.00, 0.00, 114, 2, 3),
(2858, NULL, NULL, NULL, 519, 'SAC', 42.00, 2.00, 40.00, 118, 2, 3),
(2859, NULL, NULL, NULL, 519, 'SAC', 40.00, 2.00, 38.00, 118, 2, 3),
(2860, NULL, NULL, NULL, 519, 'SAC', 13.00, 2.00, 11.00, 105, 2, 3),
(2861, NULL, NULL, NULL, 519, 'SAC', 11.00, 6.00, 5.00, 105, 2, 3),
(2862, NULL, NULL, NULL, 520, 'SAC', 451.00, 2.00, 449.00, 22, 2, 3),
(2863, NULL, NULL, NULL, 520, 'SAC', 449.00, 2.00, 447.00, 22, 2, 3),
(2864, NULL, NULL, NULL, 521, 'SAC', 447.00, 3.00, 444.00, 22, 2, 3),
(2865, NULL, NULL, NULL, 521, 'SAC', 5.00, 2.00, 3.00, 105, 2, 3),
(2866, NULL, NULL, NULL, 522, 'SAC', 444.00, 2.00, 442.00, 22, 2, 3),
(2867, NULL, NULL, NULL, 523, 'SAC', 31.00, 2.00, 29.00, 19, 2, 3),
(2868, NULL, NULL, NULL, 524, 'SAC', 442.00, 2.00, 440.00, 22, 2, 3),
(2869, NULL, NULL, NULL, 524, 'SAC', 440.00, 3.00, 437.00, 22, 2, 3),
(2870, NULL, NULL, NULL, 525, 'SAC', 124.00, 2.00, 122.00, 111, 2, 3),
(2871, NULL, NULL, NULL, 525, 'SAC', 0.00, 0.00, 0.00, 50, 2, 3),
(2872, NULL, NULL, NULL, 525, 'SAC', 55.00, 2.00, 53.00, 89, 2, 3),
(2873, NULL, NULL, NULL, 525, 'SAC', 18.00, 18.00, 0.00, 87, 2, 3),
(2874, NULL, NULL, NULL, NULL, 'IN1', 0.00, 1500.00, 1500.00, 182, 1, 3),
(2875, NULL, NULL, NULL, 526, 'SAC', 437.00, 2.00, 435.00, 22, 2, 3),
(2876, NULL, NULL, NULL, 526, 'SAC', 29.00, 20.00, 9.00, 19, 2, 3),
(2877, NULL, NULL, NULL, 527, 'SAC', 435.00, 5.00, 430.00, 22, 2, 3),
(2878, NULL, NULL, NULL, NULL, 'INA', 9.00, 80.00, 89.00, 19, 2, 3),
(2879, NULL, NULL, NULL, NULL, 'INA', 89.00, 100.00, 189.00, 19, 2, 3),
(2880, NULL, NULL, NULL, 528, 'SAC', 189.00, 9.00, 180.00, 19, 2, 3),
(2881, NULL, NULL, NULL, 529, 'SAC', 430.00, 2.00, 428.00, 22, 2, 3),
(2882, NULL, NULL, NULL, 530, 'SAC', 428.00, 2.00, 426.00, 22, 2, 3),
(2883, NULL, NULL, NULL, 530, 'SAC', 53.00, 1.00, 52.00, 89, 2, 3),
(2884, NULL, NULL, NULL, 530, 'SAC', 202.00, 2.00, 200.00, 88, 2, 3),
(2885, NULL, NULL, NULL, 530, 'SAC', 38.00, 2.00, 36.00, 118, 2, 3),
(2886, NULL, NULL, NULL, 530, 'SAC', 180.00, 2.00, 178.00, 19, 2, 3),
(2887, NULL, NULL, NULL, 531, 'SAC', 426.00, 2.00, 424.00, 22, 2, 3),
(2888, NULL, NULL, NULL, 531, 'SAC', 178.00, 3.00, 175.00, 19, 2, 3),
(2889, NULL, NULL, NULL, 532, 'SAC', 424.00, 4.00, 420.00, 22, 2, 3),
(2890, NULL, NULL, NULL, 533, 'SAC', 175.00, 2.00, 173.00, 19, 2, 3),
(2891, NULL, NULL, NULL, 534, 'SAC', 420.00, 2.00, 418.00, 22, 2, 3),
(2892, NULL, NULL, NULL, 535, 'SAC', 418.00, 2.00, 416.00, 22, 2, 3),
(2893, NULL, NULL, NULL, 536, 'SAC', 36.00, 2.00, 34.00, 118, 2, 3),
(2894, NULL, NULL, NULL, 536, 'SAC', 200.00, 3.00, 197.00, 88, 2, 3),
(2895, NULL, NULL, NULL, 537, 'SAC', 173.00, 3.00, 170.00, 19, 2, 3),
(2896, NULL, NULL, NULL, 537, 'SAC', 34.00, 3.00, 31.00, 118, 2, 3),
(2897, NULL, NULL, NULL, 538, 'SAC', 170.00, 3.00, 167.00, 19, 2, 3),
(2898, NULL, NULL, NULL, 538, 'SAC', 197.00, 3.00, 194.00, 88, 2, 3),
(2899, NULL, NULL, NULL, 538, 'SAC', 0.00, 0.00, 0.00, 36, 2, 3),
(2900, NULL, NULL, NULL, 539, 'SAC', 167.00, 3.00, 164.00, 19, 2, 3),
(2901, NULL, NULL, NULL, 540, 'SAC', 52.00, 3.00, 49.00, 89, 2, 3),
(2902, NULL, NULL, 12, NULL, 'INP', 31.00, 10.00, 41.00, 1, 2, 3),
(2903, NULL, NULL, NULL, 541, 'SAC', 164.00, 2.00, 162.00, 19, 2, 3),
(2904, NULL, NULL, NULL, 542, 'SAC', 162.00, 2.00, 160.00, 19, 2, 3),
(2905, NULL, NULL, NULL, 543, 'SAC', 1021.00, 3.00, 1018.00, 16, 2, 3),
(2906, NULL, NULL, NULL, 544, 'SAC', 31.00, 2.00, 29.00, 118, 2, 3),
(2907, NULL, NULL, NULL, 545, 'SAC', 160.00, 2.00, 158.00, 19, 2, 3),
(2908, NULL, NULL, NULL, 549, 'SAC', 29.00, 2.00, 27.00, 118, 2, 3),
(2909, NULL, NULL, NULL, 549, 'SAC', 49.00, 2.00, 47.00, 89, 2, 3),
(2910, NULL, NULL, NULL, 549, 'SAC', 158.00, 2.00, 156.00, 19, 2, 3),
(2911, NULL, NULL, NULL, 553, 'SAC', 156.00, 2.00, 154.00, 19, 2, 3),
(2912, NULL, NULL, NULL, 554, 'SAC', 154.00, 2.00, 152.00, 19, 2, 3),
(2913, NULL, NULL, NULL, 554, 'SAC', 41.00, 2.00, 39.00, 1, 2, 3),
(2914, NULL, NULL, NULL, 554, 'SAC', 0.00, 0.00, 0.00, 4, 2, 3),
(2915, NULL, NULL, NULL, 555, 'SAC', 152.00, 2.00, 150.00, 19, 2, 3),
(2916, NULL, NULL, NULL, 555, 'SAC', 1018.00, 2.00, 1016.00, 16, 2, 3),
(2917, NULL, NULL, NULL, 555, 'SAC', 39.00, 2.00, 37.00, 1, 2, 3),
(2918, NULL, NULL, NULL, 556, 'SAC', 150.00, 3.00, 147.00, 19, 2, 3),
(2919, NULL, NULL, NULL, 556, 'SAC', 1016.00, 2.00, 1014.00, 16, 2, 3),
(2920, NULL, NULL, NULL, 556, 'SAC', 0.00, 2.00, -2.00, 4, 2, 3),
(2921, NULL, NULL, NULL, 557, 'SAC', 147.00, 2.00, 145.00, 19, 2, 3),
(2922, NULL, NULL, NULL, 557, 'SAC', 1014.00, 2.00, 1012.00, 16, 2, 3),
(2923, NULL, NULL, NULL, 558, 'SAC', 145.00, 2.00, 143.00, 19, 2, 3),
(2924, NULL, NULL, NULL, 558, 'SAC', 37.00, 2.00, 35.00, 1, 2, 3),
(2925, NULL, NULL, NULL, 559, 'SAC', 143.00, 3.00, 140.00, 19, 2, 3),
(2926, NULL, NULL, NULL, 559, 'SAC', 1012.00, 2.00, 1010.00, 16, 2, 3),
(2927, NULL, NULL, NULL, 560, 'SAC', 140.00, 3.00, 137.00, 19, 2, 3),
(2928, NULL, NULL, NULL, 561, 'SAC', 137.00, 3.00, 134.00, 19, 2, 3),
(2929, NULL, NULL, NULL, 562, 'SAC', 134.00, 2.00, 132.00, 19, 2, 3),
(2930, NULL, NULL, NULL, 562, 'SAC', 35.00, 2.00, 33.00, 1, 2, 3),
(2931, NULL, NULL, NULL, 562, 'SAC', 0.00, 0.00, 0.00, 4, 2, 3),
(2932, NULL, NULL, NULL, 563, 'SAC', 132.00, 2.00, 130.00, 19, 2, 3),
(2933, NULL, NULL, NULL, 563, 'SAC', 0.00, 2.00, -2.00, 4, 2, 3),
(2934, NULL, NULL, NULL, 564, 'SAC', 130.00, 3.00, 127.00, 19, 2, 3),
(2935, NULL, NULL, NULL, 564, 'SAC', 1010.00, 2.00, 1008.00, 16, 2, 3),
(2936, NULL, NULL, NULL, 565, 'SAC', 127.00, 2.00, 125.00, 19, 2, 3),
(2937, NULL, NULL, NULL, 565, 'SAC', 0.00, 0.00, 0.00, 4, 2, 3),
(2938, NULL, NULL, NULL, 566, 'SAC', 125.00, 2.00, 123.00, 19, 2, 3),
(2939, NULL, NULL, NULL, 566, 'SAC', 0.00, 2.00, -2.00, 4, 2, 3),
(2940, NULL, NULL, NULL, 567, 'SAC', 123.00, 3.00, 120.00, 19, 2, 3),
(2941, NULL, NULL, NULL, 568, 'SAC', 120.00, 2.00, 118.00, 19, 2, 3),
(2942, NULL, NULL, NULL, 568, 'SAC', 47.00, 3.00, 44.00, 89, 2, 3),
(2943, NULL, NULL, NULL, 569, 'SAC', 118.00, 2.00, 116.00, 19, 2, 3),
(2944, NULL, NULL, NULL, 569, 'SAC', 0.00, 0.00, 0.00, 4, 2, 3),
(2945, NULL, NULL, NULL, 570, 'SAC', 116.00, 4.00, 112.00, 19, 2, 3),
(2946, NULL, NULL, NULL, 570, 'SAC', 0.00, 2.00, -2.00, 4, 2, 3),
(2947, NULL, NULL, NULL, 571, 'SAC', 112.00, 2.00, 110.00, 19, 2, 3),
(2948, NULL, NULL, NULL, 571, 'SAC', 0.00, 0.00, 0.00, 4, 2, 3),
(2949, NULL, NULL, NULL, 572, 'SAC', 110.00, 3.00, 107.00, 19, 2, 3),
(2950, NULL, NULL, NULL, 572, 'SAC', 0.00, 2.00, -2.00, 4, 2, 3),
(2951, NULL, NULL, NULL, 573, 'SAC', 107.00, 3.00, 104.00, 19, 2, 3),
(2952, NULL, NULL, NULL, 573, 'SAC', 0.00, 0.00, 0.00, 4, 2, 3),
(2953, NULL, NULL, NULL, 574, 'SAC', 104.00, 2.00, 102.00, 19, 2, 3),
(2954, NULL, NULL, NULL, 574, 'SAC', 0.00, 2.00, -2.00, 4, 2, 3),
(2955, NULL, NULL, NULL, 575, 'SAC', 102.00, 2.00, 100.00, 19, 2, 3),
(2956, NULL, NULL, NULL, 575, 'SAC', 23.00, 2.00, 21.00, 15, 2, 3),
(2957, NULL, NULL, NULL, 576, 'SAC', 100.00, 3.00, 97.00, 19, 2, 3),
(2958, NULL, NULL, NULL, 576, 'SAC', 21.00, 2.00, 19.00, 15, 2, 3),
(2959, NULL, NULL, NULL, 577, 'SAC', 97.00, 2.00, 95.00, 19, 2, 3),
(2960, NULL, NULL, NULL, 577, 'SAC', 19.00, 2.00, 17.00, 15, 2, 3),
(2961, NULL, NULL, NULL, 578, 'SAC', 95.00, 3.00, 92.00, 19, 2, 3),
(2962, NULL, NULL, NULL, 578, 'SAC', 17.00, 2.00, 15.00, 15, 2, 3),
(2963, NULL, NULL, NULL, 579, 'SAC', 92.00, 2.00, 90.00, 19, 2, 3),
(2964, NULL, NULL, NULL, 579, 'SAC', 15.00, 2.00, 13.00, 15, 2, 3),
(2965, NULL, NULL, NULL, 580, 'SAC', 90.00, 2.00, 88.00, 19, 2, 3),
(2966, NULL, NULL, NULL, 580, 'SAC', 13.00, 2.00, 11.00, 15, 2, 3),
(2967, NULL, NULL, NULL, 581, 'SAC', 88.00, 2.00, 86.00, 19, 2, 3),
(2968, NULL, NULL, NULL, 581, 'SAC', 11.00, 2.00, 9.00, 15, 2, 3),
(2969, NULL, NULL, NULL, 582, 'SAC', 86.00, 2.00, 84.00, 19, 2, 3),
(2970, NULL, NULL, NULL, 582, 'SAC', 9.00, 2.00, 7.00, 15, 2, 3),
(2971, NULL, NULL, NULL, 583, 'SAC', 84.00, 2.00, 82.00, 19, 2, 3),
(2972, NULL, NULL, NULL, 583, 'SAC', 1008.00, 3.00, 1005.00, 16, 2, 3),
(2973, NULL, NULL, NULL, 584, 'SAC', 82.00, 3.00, 79.00, 19, 2, 3),
(2974, NULL, NULL, NULL, 584, 'SAC', 7.00, 2.00, 5.00, 15, 2, 3),
(2975, NULL, NULL, NULL, 585, 'SAC', 79.00, 2.00, 77.00, 19, 2, 3),
(2976, NULL, NULL, NULL, 585, 'SAC', 5.00, 2.00, 3.00, 15, 2, 3),
(2977, NULL, NULL, NULL, 586, 'SAC', 77.00, 2.00, 75.00, 19, 2, 3),
(2978, NULL, NULL, NULL, 586, 'SAC', 3.00, 2.00, 1.00, 15, 2, 3),
(2979, NULL, NULL, NULL, 587, 'SAC', 75.00, 2.00, 73.00, 19, 2, 3),
(2980, NULL, NULL, NULL, 587, 'SAC', 1.00, 1.00, 0.00, 15, 2, 3),
(2981, NULL, NULL, NULL, 588, 'SAC', 73.00, 2.00, 71.00, 19, 2, 3),
(2982, NULL, NULL, NULL, 588, 'SAC', 1005.00, 2.00, 1003.00, 16, 2, 3),
(2983, NULL, NULL, NULL, 589, 'SAC', 71.00, 2.00, 69.00, 19, 2, 3),
(2984, NULL, NULL, NULL, 589, 'SAC', 1003.00, 2.00, 1001.00, 16, 2, 3),
(2985, NULL, NULL, NULL, 590, 'SAC', 69.00, 2.00, 67.00, 19, 2, 3),
(2986, NULL, NULL, NULL, 590, 'SAC', 1001.00, 1.00, 1000.00, 16, 2, 3),
(2987, NULL, NULL, NULL, 591, 'SAC', 67.00, 2.00, 65.00, 19, 2, 3),
(2988, NULL, NULL, NULL, 591, 'SAC', 33.00, 6.00, 27.00, 1, 2, 3),
(2989, NULL, NULL, NULL, 591, 'SAC', 0.00, 2.00, -2.00, 14, 2, 3),
(2990, NULL, NULL, NULL, 592, 'SAC', 65.00, 2.00, 63.00, 19, 2, 3),
(2991, NULL, NULL, NULL, 592, 'SAC', 0.00, 0.00, 0.00, 14, 2, 3),
(2992, NULL, NULL, NULL, 593, 'SAC', 0.00, 2.00, -2.00, 14, 2, 3),
(2993, NULL, NULL, NULL, 593, 'SAC', 63.00, 2.00, 61.00, 19, 2, 3),
(2994, NULL, NULL, NULL, 594, 'SAC', 61.00, 2.00, 59.00, 19, 2, 3),
(2995, NULL, NULL, NULL, 594, 'SAC', 0.00, 0.00, 0.00, 20, 2, 3),
(2996, NULL, NULL, NULL, 594, 'SAC', 27.00, 2.00, 25.00, 118, 2, 3),
(2997, NULL, NULL, NULL, 594, 'SAC', 4.00, 2.00, 2.00, 47, 2, 3),
(2998, NULL, NULL, NULL, 595, 'SAC', 59.00, 2.00, 57.00, 19, 2, 3),
(2999, NULL, NULL, NULL, 595, 'SAC', 0.00, 2.00, -2.00, 20, 2, 3),
(3000, NULL, NULL, NULL, 596, 'SAC', 57.00, 2.00, 55.00, 19, 2, 3),
(3001, NULL, NULL, NULL, 596, 'SAC', 0.00, 0.00, 0.00, 20, 2, 3),
(3002, NULL, NULL, NULL, 597, 'SAC', 55.00, 2.00, 53.00, 19, 2, 3),
(3003, NULL, NULL, NULL, 597, 'SAC', 0.00, 2.00, -2.00, 20, 2, 3),
(3004, NULL, NULL, NULL, 598, 'SAC', 416.00, 2.00, 414.00, 22, 2, 3),
(3005, NULL, NULL, NULL, 598, 'SAC', 44.00, 2.00, 42.00, 89, 2, 3),
(3006, NULL, NULL, 13, NULL, 'INP', 53.00, 4.00, 57.00, 19, 2, 3),
(3007, NULL, NULL, NULL, 599, 'SAC', 414.00, 2.00, 412.00, 22, 2, 3),
(3008, NULL, NULL, NULL, 600, 'SAC', 42.00, 2.00, 40.00, 89, 2, 3),
(3009, NULL, NULL, NULL, 601, 'SAC', 3.00, 1.00, 2.00, 73, 2, 3),
(3010, NULL, NULL, NULL, 601, 'SAC', 422.00, 5.00, 417.00, 23, 2, 3),
(3011, NULL, NULL, NULL, 602, 'SAC', 25.00, 3.00, 22.00, 118, 2, 3),
(3012, NULL, NULL, NULL, 602, 'SAC', 159.00, 3.00, 156.00, 44, 2, 3),
(3013, NULL, NULL, NULL, 607, 'SAC', 412.00, 2.00, 410.00, 22, 2, 3),
(3014, NULL, NULL, NULL, 608, 'SAC', 410.00, 5.00, 405.00, 22, 2, 3),
(3015, NULL, NULL, NULL, 609, 'SAC', 40.00, 2.00, 38.00, 89, 2, 3),
(3016, NULL, NULL, NULL, 609, 'SAC', 22.00, 2.00, 20.00, 118, 2, 3),
(3017, NULL, NULL, NULL, 610, 'SAC', 57.00, 5.00, 52.00, 19, 2, 3),
(3018, NULL, NULL, NULL, 610, 'SAC', 38.00, 5.00, 33.00, 89, 2, 3),
(3019, NULL, NULL, NULL, 611, 'SAC', 52.00, 3.00, 49.00, 19, 2, 3),
(3020, NULL, NULL, NULL, 611, 'SAC', 122.00, 3.00, 119.00, 111, 2, 3),
(3021, NULL, NULL, NULL, 612, 'SAC', 0.00, 3.00, -3.00, 26, 2, 3),
(3022, NULL, NULL, NULL, 612, 'SAC', 33.00, 2.00, 31.00, 89, 2, 3),
(3023, NULL, NULL, 14, NULL, 'INP', 0.00, 2.00, 2.00, 114, 2, 3),
(3024, NULL, NULL, 15, NULL, 'INP', 2.00, 6.00, 8.00, 114, 2, 3),
(3025, NULL, NULL, NULL, 613, 'SAC', 49.00, 2.00, 47.00, 19, 2, 3),
(3026, NULL, NULL, NULL, 613, 'SAC', 405.00, 20.00, 385.00, 22, 2, 3);
INSERT INTO `movimiento` (`mov_id_movimiento`, `ind_id_ingreso_detalle`, `sad_id_salida_detalle`, `ing_id_ingreso`, `sal_id_salida`, `mov_tipo`, `mov_cantidad_anterior`, `mov_cantidad_entrante`, `mov_cantidad_actual`, `pro_id_producto`, `est_id_estado`, `usu_id_usuario`) VALUES
(3027, NULL, NULL, NULL, 613, 'SAC', 31.00, 9.00, 22.00, 89, 2, 3),
(3028, NULL, NULL, 16, NULL, 'INP', 385.00, 6.00, 391.00, 22, 2, 3),
(3029, NULL, NULL, 17, NULL, 'INP', 47.00, 26.00, 73.00, 19, 2, 3),
(3030, NULL, NULL, NULL, 614, 'SAC', 8.00, 3.00, 5.00, 114, 2, 3),
(3031, NULL, NULL, NULL, 614, 'SAC', 73.00, 5.00, 68.00, 19, 2, 3),
(3032, NULL, NULL, 18, NULL, 'INP', 391.00, 5.00, 396.00, 22, 2, 3),
(3033, NULL, NULL, NULL, 615, 'SAC', 5.00, 1.00, 4.00, 114, 2, 3),
(3034, NULL, NULL, NULL, 616, 'SAC', 4.00, 2.00, 2.00, 114, 2, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pcliente`
--

CREATE TABLE `pcliente` (
  `pcl_id_pcliente` int(10) UNSIGNED NOT NULL,
  `per_id_persona` int(11) DEFAULT NULL,
  `emp_id_empresa` int(10) UNSIGNED DEFAULT NULL,
  `pcl_tipo` varchar(2) DEFAULT NULL,
  `est_id_estado` int(10) UNSIGNED DEFAULT NULL,
  `pcl_eliminado` varchar(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `pcliente`
--

INSERT INTO `pcliente` (`pcl_id_pcliente`, `per_id_persona`, `emp_id_empresa`, `pcl_tipo`, `est_id_estado`, `pcl_eliminado`) VALUES
(1, NULL, 1, '1', 11, 'SI'),
(2, NULL, 2, '2', 11, 'SI'),
(3, NULL, 3, '3', 11, 'SI'),
(4, NULL, 4, '3', 11, 'SI'),
(5, NULL, 5, '3', 11, 'SI'),
(6, NULL, 6, '2', NULL, 'NO'),
(7, NULL, 7, '1', NULL, 'NO'),
(8, NULL, 8, '3', NULL, 'NO'),
(9, NULL, 15, '1', 11, 'SI'),
(10, NULL, 16, '2', 11, 'SI'),
(11, NULL, 17, '3', 11, 'SI'),
(12, NULL, 21, '2', 11, 'SI'),
(13, NULL, 22, '1', 11, 'NO'),
(14, NULL, 23, '1', 11, 'NO'),
(15, NULL, 24, '1', 11, 'NO'),
(16, NULL, 25, '1', 11, 'NO'),
(17, NULL, 26, '1', 11, 'NO'),
(18, NULL, 27, '1', 11, 'NO'),
(19, NULL, 28, '1', 11, 'NO'),
(20, NULL, 29, '1', 11, 'NO'),
(21, NULL, 30, '1', 11, 'NO'),
(22, NULL, 31, '1', 11, 'NO'),
(23, NULL, 32, '1', 11, 'NO'),
(24, NULL, 33, '1', 11, 'NO'),
(25, NULL, 34, '1', 11, 'NO'),
(26, NULL, 35, '1', 11, 'NO'),
(27, NULL, 36, '1', 11, 'NO'),
(28, NULL, 37, '1', 11, 'NO'),
(29, NULL, 38, '1', 11, 'NO'),
(30, NULL, 39, '1', 11, 'NO'),
(31, NULL, 40, '1', 11, 'NO'),
(32, NULL, 41, '1', 11, 'NO'),
(33, NULL, 42, '1', 11, 'NO'),
(34, NULL, 43, '1', 11, 'NO'),
(35, NULL, 44, '1', 11, 'NO'),
(36, NULL, 45, '1', 11, 'NO'),
(37, NULL, 46, '1', 11, 'NO'),
(38, NULL, 47, '1', 11, 'NO'),
(39, NULL, 48, '1', 11, 'NO'),
(40, NULL, 49, '1', 11, 'NO'),
(41, NULL, 50, '1', 11, 'NO'),
(42, NULL, 51, '1', 11, 'NO'),
(43, NULL, 52, '1', 11, 'NO'),
(44, NULL, 53, '1', 11, 'NO'),
(45, NULL, 54, '1', 11, 'NO'),
(46, NULL, 55, '1', 11, 'NO'),
(47, NULL, 56, '1', 11, 'NO'),
(48, NULL, 57, '1', 11, 'NO'),
(49, NULL, 58, '1', 11, 'NO'),
(50, NULL, 59, '1', 11, 'NO'),
(51, NULL, 60, '1', 11, 'NO'),
(52, NULL, 61, '1', 11, 'NO'),
(53, NULL, 62, '1', 11, 'NO'),
(54, NULL, 63, '1', 11, 'NO'),
(55, NULL, 64, '1', 11, 'NO'),
(56, NULL, 65, '1', 11, 'NO'),
(57, NULL, 66, '1', 11, 'NO'),
(58, NULL, 67, '1', 11, 'NO'),
(59, NULL, 68, '1', 11, 'NO'),
(60, NULL, 71, '2', 11, 'NO'),
(61, NULL, 72, '2', 11, 'NO'),
(62, NULL, 73, '2', 11, 'NO'),
(63, NULL, 74, '2', 11, 'NO'),
(64, NULL, 75, '2', 11, 'NO'),
(65, NULL, 76, '2', 11, 'NO'),
(66, NULL, 77, '2', 11, 'NO'),
(67, NULL, 78, '2', 11, 'NO'),
(68, NULL, 79, '2', 11, 'NO'),
(69, NULL, 80, '2', 11, 'NO'),
(70, NULL, 81, '2', 11, 'NO'),
(71, NULL, 82, '2', 11, 'NO'),
(72, NULL, 83, '2', 11, 'NO'),
(73, NULL, 93, '2', 11, 'NO'),
(74, NULL, 94, '2', 11, 'NO'),
(75, NULL, 95, '2', 11, 'NO'),
(76, NULL, 96, '2', 11, 'NO'),
(77, NULL, 97, '2', 11, 'NO'),
(78, NULL, 98, '2', 11, 'NO'),
(79, NULL, 99, '2', 11, 'NO'),
(80, NULL, 100, '2', 11, 'NO'),
(81, NULL, 101, '2', 11, 'NO'),
(82, NULL, 102, '2', 11, 'NO'),
(83, NULL, 103, '2', 11, 'NO'),
(84, NULL, 104, '2', 11, 'NO'),
(85, NULL, 105, '2', 11, 'NO'),
(86, NULL, 106, '2', 11, 'NO'),
(87, NULL, 107, '2', 11, 'NO'),
(88, NULL, 108, '2', 11, 'NO'),
(89, NULL, 109, '2', 11, 'NO'),
(90, NULL, 110, '2', 11, 'NO'),
(91, NULL, 111, '2', 11, 'NO'),
(92, NULL, 112, '2', 11, 'NO'),
(93, NULL, 113, '1', 11, 'NO'),
(94, NULL, 114, '1', 11, 'NO'),
(95, NULL, 115, '1', 11, 'NO'),
(96, NULL, 116, '1', 11, 'NO'),
(97, NULL, 117, '1', 11, 'NO'),
(98, NULL, 118, '1', 11, 'NO'),
(99, NULL, 119, '1', 11, 'NO'),
(100, NULL, 120, '1', 11, 'NO'),
(101, NULL, 121, '1', 11, 'NO'),
(102, NULL, 122, '1', 11, 'NO'),
(103, NULL, 123, '1', 11, 'NO'),
(104, NULL, 124, '1', 11, 'NO'),
(105, NULL, 125, '1', 11, 'NO'),
(106, NULL, 128, '1', 11, 'NO'),
(107, NULL, 129, '1', 11, 'NO'),
(108, NULL, 130, '1', 11, 'NO'),
(109, NULL, 131, '1', 11, 'NO'),
(110, NULL, 132, '1', 11, 'NO'),
(111, NULL, 133, '1', 11, 'NO'),
(112, NULL, 134, '1', 11, 'NO'),
(113, NULL, 135, '1', 11, 'NO'),
(114, NULL, 136, '1', 11, 'NO'),
(115, NULL, 137, '1', 11, 'NO'),
(116, NULL, 138, '1', 11, 'NO'),
(117, NULL, 139, '1', 11, 'NO'),
(118, NULL, 140, '1', 11, 'NO'),
(119, NULL, 141, '1', 11, 'NO'),
(120, NULL, 142, '1', 11, 'NO'),
(121, NULL, 143, '1', 11, 'NO'),
(122, NULL, 144, '1', 11, 'NO'),
(123, NULL, 145, '1', 11, 'NO'),
(124, NULL, 146, '1', 11, 'NO'),
(125, NULL, 147, '1', 11, 'NO'),
(126, NULL, 148, '1', 11, 'NO'),
(127, NULL, 149, '1', 11, 'NO'),
(128, NULL, 150, '1', 11, 'NO'),
(129, NULL, 151, '1', 11, 'NO'),
(130, NULL, 152, '1', 11, 'NO'),
(131, NULL, 153, '1', 11, 'NO'),
(132, NULL, 154, '1', 11, 'NO'),
(133, NULL, 155, '1', 11, 'NO'),
(134, NULL, 159, '1', 11, 'NO'),
(135, NULL, 160, '1', 11, 'NO'),
(136, NULL, 161, '1', 11, 'NO'),
(137, NULL, 162, '1', 11, 'NO'),
(138, NULL, 163, '1', 11, 'NO'),
(139, NULL, 164, '1', 11, 'NO'),
(140, NULL, 165, '1', 11, 'NO'),
(141, NULL, 166, '1', 11, 'NO'),
(142, NULL, 167, '1', 11, 'NO'),
(143, NULL, 168, '1', 11, 'NO'),
(144, NULL, 169, '1', 11, 'NO'),
(145, NULL, 170, '1', 11, 'NO'),
(146, NULL, 171, '1', 11, 'NO'),
(147, NULL, 172, '1', 11, 'NO'),
(148, NULL, 173, '1', 11, 'NO'),
(149, NULL, 174, '1', 11, 'NO'),
(150, NULL, 175, '1', 11, 'NO'),
(151, NULL, 176, '2', 11, 'NO'),
(152, NULL, 177, '2', 11, 'NO'),
(153, NULL, 178, '1', 11, 'NO'),
(154, NULL, 179, '1', 11, 'NO'),
(155, NULL, 180, '1', 11, 'NO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `persona`
--

CREATE TABLE `persona` (
  `per_id_persona` int(11) NOT NULL,
  `per_nombre` varchar(100) DEFAULT NULL,
  `per_apellido` varchar(100) DEFAULT NULL,
  `tdo_id_tipo_documento` int(10) UNSIGNED NOT NULL,
  `per_numero_doc` varchar(30) DEFAULT NULL,
  `per_direccion` varchar(100) DEFAULT NULL,
  `per_tel_movil` varchar(30) DEFAULT NULL,
  `per_tel_fijo` varchar(30) DEFAULT NULL,
  `per_foto` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `persona`
--

INSERT INTO `persona` (`per_id_persona`, `per_nombre`, `per_apellido`, `tdo_id_tipo_documento`, `per_numero_doc`, `per_direccion`, `per_tel_movil`, `per_tel_fijo`, `per_foto`) VALUES
(1, 'Panel', 'Control', 1, '00000001', 'Admin', '955-123-128', '395-8590', 'Rgo9YsOmNCcBw4AkWT2l.jpg'),
(2, 'Area', 'Venta', 1, '44332233', 'Geraneos', '12', '132', 'V4Gwtn1chdFNAEPvyQeI.jpg'),
(3, 'Soporte', 'Tecnico', 1, '123456789', 'Lima', '123456789', '12354567', 'kIHKDecQmSRL4w0dbTpo.jpg'),
(4, 'colorado', 'chiclayano', 1, '78956985', 'alameda', '985236521', '14815151', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `privilegio`
--

CREATE TABLE `privilegio` (
  `pri_id_privilegio` int(10) UNSIGNED NOT NULL,
  `pri_nombre` varchar(100) DEFAULT NULL,
  `pri_acceso` varchar(100) DEFAULT NULL,
  `pri_grupo` varchar(20) DEFAULT NULL,
  `pri_orden` int(11) DEFAULT NULL,
  `est_id_estado` int(10) UNSIGNED DEFAULT NULL,
  `pri_ico` varchar(20) DEFAULT NULL,
  `pri_ico_grupo` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `privilegio`
--

INSERT INTO `privilegio` (`pri_id_privilegio`, `pri_nombre`, `pri_acceso`, `pri_grupo`, `pri_orden`, `est_id_estado`, `pri_ico`, `pri_ico_grupo`) VALUES
(1, 'Usuario', 'mantenimiento/usuario', 'ADMINISTRACION', 1, 1, 'user-cog', 'cog'),
(2, 'Cliente', 'mantenimiento/pcliente', 'MANTENIMIENTO', 12, 1, 'street-view', 'pencil-square-o'),
(3, 'Producto', 'mantenimiento/producto', 'MANTENIMIENTO', 3, 1, 'atlas', 'server'),
(4, 'Uni. Medida', 'mantenimiento/unidad_medida', 'MANTENIMIENTO', 4, 1, 'balance-scale', 'server'),
(5, 'Clase', 'mantenimiento/clase', 'MANTENIMIENTO', 5, 1, 'bezier-curve', 'server'),
(6, 'Rol', 'mantenimiento/rol', 'ADMINISTRACION', 6, 1, 'id-card', 'cog'),
(7, 'Compra', 'movimiento/ingreso/proveedor', 'MOVIMIENTO', 7, 1, 'cart-plus', 'shopping-cart'),
(8, 'Venta', 'movimiento/salida/cliente', 'MOVIMIENTO', 8, 1, 'cart-arrow-down', 'shopping-cart'),
(9, 'Datos Empresa Local', 'mantenimiento/datos_empresa_local', 'ADMINISTRACION', 9, 1, 'building', 'cog'),
(10, 'Stock', 'reporte/stock', 'REPORTE', 10, 1, 'calculator', 'table'),
(11, 'Movimiento', 'reporte/movimiento', 'REPORTE', 11, 1, 'chart-line', 'table'),
(12, 'Proveedor', 'mantenimiento/pcliente', 'MANTENIMIENTO', 13, 1, 'street-view', 'pencil-square-o'),
(13, 'Caja', 'mantenimiento/caja', 'ADMINISTRACION', 14, 1, 'money', 'cog'),
(14, 'Apertura Caja', 'movimiento/caja/apertura', 'MOVIMIENTO', 15, 1, 'lock-open', 'shopping-cart'),
(15, 'Cierre Caja', 'movimiento/caja/cierre', 'MOVIMIENTO', 16, 1, 'lock', 'shopping-cart'),
(16, 'Cambiar clave', 'administracion/usuario_cambio_clave', 'ADMINISTRACION', 17, 1, 'user-lock', 'cog'),
(17, 'Reset clave', 'administracion/usuario_reset_clave', 'ADMINISTRACION', 18, 1, 'user-lock', 'cog'),
(18, 'Ajuste stock', 'movimiento/ajuste/stock', 'MOVIMIENTO', 19, 1, 'atlas', 'shopping-cart'),
(19, 'Cuentas por Cobrar', 'movimiento/salida/cobrar', 'MOVIMIENTO', 20, 1, 'lock', 'shopping-cart'),
(20, 'Cuenta por Pagar', 'movimiento/ingreso/pagar', 'MOVIMIENTO', 21, 1, 'money', 'cog'),
(21, 'Sangria', 'movimiento/sangria', 'MOVIMIENTO', 40, 1, 'fire', 'cog'),
(22, 'Ventas del dia', 'reporte/ventas', 'REPORTE', 41, 1, 'money', 'cog'),
(23, 'Registrar Sangria', 'movimiento/sangria2', 'MOVIMIENTO', 45, 1, 'fire', 'cog'),
(24, 'Mis Ventas', 'reporte/miventa', 'REPORTE', 50, 1, 'money', 'cog'),
(25, 'Administrar ventas', 'reporte/imprimir/imprimir', 'REPORTE', 60, 1, 'print', 'cog'),
(26, 'Efectivo en caja', 'reporte/efectivo/caja', 'REPORTE', 51, 1, 'money', 'cog'),
(27, 'Ganancias', 'reporte/ganancias', 'REPORTE', 61, 1, 'dollar', 'cog'),
(28, 'Movimiento cliente', 'reporte/mcliente', 'REPORTE', 70, 1, 'line-chart', 'cog'),
(29, 'Movimiento proveedor', 'reporte/proveedor', 'REPORTE', 71, 1, 'line-chart', 'cog');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `pro_id_producto` int(10) UNSIGNED NOT NULL,
  `pro_codigo` varchar(20) DEFAULT NULL,
  `cla_clase` int(10) UNSIGNED DEFAULT NULL,
  `cla_subclase` int(10) UNSIGNED DEFAULT NULL,
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
  `pro_xm_valor1` double(15,3) DEFAULT '0.000',
  `pro_xm_cantidad2` double(15,2) DEFAULT '0.00',
  `pro_xm_valor2` double(15,3) DEFAULT '0.000',
  `pro_xm_cantidad3` double(15,2) DEFAULT '0.00',
  `pro_xm_valor3` double(15,3) DEFAULT '0.000',
  `pro_val_oferta` double(15,2) DEFAULT NULL,
  `est_id_estado` int(10) UNSIGNED DEFAULT NULL,
  `pro_eliminado` varchar(2) DEFAULT NULL,
  `pro_kilogramo` double(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`pro_id_producto`, `pro_codigo`, `cla_clase`, `cla_subclase`, `pro_nombre`, `pro_val_compra`, `pro_val_venta`, `pro_cantidad`, `pro_cantidad_min`, `unm_id_unidad_medida`, `pro_foto`, `pro_perecible`, `pro_fecha_vencimiento`, `pro_xm_cantidad1`, `pro_xm_valor1`, `pro_xm_cantidad2`, `pro_xm_valor2`, `pro_xm_cantidad3`, `pro_xm_valor3`, `pro_val_oferta`, `est_id_estado`, `pro_eliminado`, `pro_kilogramo`) VALUES
(1, '180810172633', 67, 69, 'M ENTERO X 50', 20.00, 63.40, 27.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/O2ohYFRGUbk1cynL4z9E.jpg', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 10.00),
(2, '180810173207', 67, 69, 'M REFINADO X 28', 30.80, 35.00, 0.00, 4.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/XCrKAvluFnemkhW7qNwj.jpg', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 8.00),
(3, '180810173314', 33, 34, 'M REFINADO X 50', 55.00, 62.50, 0.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/pDwG6itz2SqFU7gNkIuK.jpg', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 11.00),
(4, '180810173237', 67, 69, 'M PARTIDO X 50', 55.00, 66.70, 0.00, 5.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/S9siX7Cr0lvzyBD821Wb.jpg', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 10.00),
(13, '180924155530', 67, 69, 'M ENTERO X 30', 33.00, 38.00, 8.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/YMxlGbTd12zS0y4hgCk3.jpg', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(14, '180810173054', 67, 69, 'M REFINADO X 60 ', 66.00, 80.00, 35.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/BycCSQGi5dPxz9m7H14A.jpg', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 10.00),
(15, '180810172847', 67, 69, 'M PARTIDO X 60 ', 66.00, 79.00, 0.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/1ACcWqOGujfHdRkUFQEb.jpg', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 11.00),
(16, '180810172933', 67, 69, 'M PARTIDO X 30 ', 33.00, 39.50, 0.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/4nhzBmIGwRcdsbU9pDxl.jpg', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 12.00),
(17, '180810173020', 67, 69, 'M PARTIDO X 28', 54.00, 100.00, 0.00, 10.00, 4, 'http://localhost/index.php/../resources/sy_file_repository/clR14VhQ5O6jtGZU3DLy.jpg', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 9.00, 0.000, 0.00, 11, 'NO', 9.00),
(18, '180810173131', 67, 69, 'M REFINADO X 30', 33.00, 39.50, 0.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/c79LwPZjtBi62T4KEV5O.jpg', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 20.00),
(19, '180810172243', 67, 69, 'AFRECHO X 40', 50.00, 32.00, 68.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 5.00, 0.273, 8.00, 0.374, 9.00, 0.386, 0.00, 11, 'NO', 20.00),
(20, '180810173417', 67, 69, 'REPASO X 50', 40.00, 45.00, 12.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/faYPcol9h8sGDBE0TdQx.jpg', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 20.00),
(21, '180810173956', 37, 38, 'MEZCLA PAJ MAIZ', 54.00, 100.00, 147.00, 10.00, 3, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(22, '180823165028', 67, 69, 'AFRECHO X 30', 900.00, 25.00, 396.00, 20.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(23, '180823172439', 67, 69, 'CONEJO COGORNO X 40', 57.60, 62.00, 417.00, 20.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(24, '180823172555', 67, 69, 'BB MYCIN X 40', 82.20, 93.00, 132.00, 20.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(25, '180823172731', 67, 69, 'PICO & NAVAJA X 40', 79.57, 90.00, 335.00, 20.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(26, '180823172803', 67, 69, 'CONEJO B12 X 40', 65.80, 70.00, 4.00, 20.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(27, '180823173745', 74, 81, 'CONEJO BB X 25', 44.18, 45.00, 0.00, 5.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(28, '180823173927', 74, 75, 'INICIO B12 X 40', 79.90, 85.00, 2.00, 5.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(29, '180823182800', 74, 76, 'CRECIMIENTO B12 X 40', 70.50, 75.00, 0.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(30, '180823182810', 74, 77, 'ENGORDE B12 X 40', 65.80, 70.00, 7.00, 5.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(31, '180823182850', 74, 78, 'PONEDORA B12 X 40', 65.80, 70.00, 9.00, 2.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(32, '180823182935', 74, 79, 'SALUD TOTAL X 25', 56.40, 60.00, 0.00, 2.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(33, '180823183015', 74, 80, 'CUY B12 X 40', 67.68, 72.00, 12.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(34, '180823183130', 67, 69, 'VITA OVO X 60', 56.40, 82.00, 18.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(35, '180823183341', 67, 69, 'VITA OVO X 30', 28.20, 39.50, 11.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(36, '180827093606', 67, 69, 'CRECIMIENTO VITA X 40', 46.00, 48.00, 48.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(37, '180827093650', 67, 69, 'CRECIMIENTO VITA X 20', 23.00, 24.00, 1.00, 5.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(38, '180827093741', 67, 69, 'ENGORDE VITA X 40', 46.00, 50.00, 66.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(39, '180827093833', 67, 69, 'ENGORDE VITA X 20', 23.00, 25.00, 1.00, 5.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(40, '180827093907', 47, 49, 'INICIO VITA X 40', 46.00, 55.00, 17.00, 3.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(41, '180827093952', 47, 49, 'INICIO VITA X 20', 23.00, 24.00, 0.00, 3.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(42, '180827182351', 67, 69, 'VITA CUY X 40', 38.00, 40.00, 4.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(43, '180827182438', 47, 52, 'PONEDORA VITA X 40', 46.00, 50.00, 0.00, 3.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(44, '180827182515', 67, 69, 'CONEJO OSCAR X 40', 38.00, 40.00, 162.00, 15.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(45, '180827182553', 53, 55, 'CONEJO OSCAR X 20', 19.00, 21.00, 0.00, 2.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(46, '180827182630', 67, 69, 'CUY OSCAR X 40', 38.00, 42.00, 15.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img\r\n_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(47, '180827182710', 53, 54, 'CUY OSCAR X 20', 19.00, 20.00, 2.00, 3.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(48, '180827182745', 67, 69, 'TRIGO N X 60', 70.00, 83.00, 436.00, 20.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(49, '180827182837', 67, 69, 'TRIGO N X 30', 35.00, 41.50, 7.00, 5.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(50, '180827182913', 59, 63, 'CRECIMIENTO SIMPLE X 40', 23.00, 32.00, 46.00, 15.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(51, '180827183106', 67, 69, 'ENGORDE SIMPLE X 40', 23.00, 35.00, 0.00, 5.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(52, '180827183148', 59, 60, 'VERDE X 40', 50.00, 72.00, 41.00, 15.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(53, '180827183224', 67, 69, 'ROJO X 40', 50.00, 65.00, 46.00, 3.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(54, '180827183302', 64, 66, 'CRECIMIENTO SIMPLE X 40 E', 24.00, 30.00, 32.00, 10.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(55, '180915182313', 37, 41, 'CUY R X 50', 50.00, 60.00, 0.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(56, '180915185837', 37, 41, 'CUY R X 25', 25.00, 30.00, 0.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(57, '180915185942', 37, 39, 'ECONOMICO X 50', 44.00, 48.00, 0.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(58, '180915190423', 37, 39, 'ECONOMICO X 25', 22.00, 25.00, 3.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(59, '180920084511', 67, 69, 'M MOLIDO X 30', 33.00, 40.00, 2.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(60, '180920084546', 67, 69, 'M MOLIDO X 60', 66.00, 79.00, 0.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(61, '180920084644', 37, 42, 'P1 X 50', 67.04, 76.00, 4.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(62, '180920084759', 37, 42, 'P1 X 25', 33.52, 38.50, 0.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(63, '180920084904', 67, 69, 'P2 X 50', 59.03, 75.00, 13.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(64, '180920084948', 37, 42, 'P2 X 50', 29.52, 37.50, 4.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(65, '180920085100', 67, 69, 'P3 X 50', 61.43, 75.00, 5.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(66, '180920094119', 37, 42, 'P3 X 25', 30.72, 37.50, 0.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(67, '180920094216', 37, 43, 'C1 X 40', 47.51, 69.00, 0.00, 3.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(68, '180920094301', 37, 42, 'C1 X 20', 23.78, 34.50, 0.00, 3.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(69, '180920094359', 37, 42, 'C2 X 50', 59.30, 69.00, 0.00, 3.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(70, '180920094441', 37, 42, 'C2 X 25', 26.65, 34.50, 0.00, 3.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(71, '180920094526', 37, 42, 'C3 X 50', 54.48, 69.00, 0.00, 3.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(72, '180920094608', 37, 42, 'C3 X 25', 27.24, 34.50, 0.00, 3.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(73, '180920094655', 67, 69, '2H X 50', 41.96, 75.00, 2.00, 3.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(74, '180920095849', 37, 44, '2H X 25', 20.98, 38.50, 0.00, 3.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(75, '180924154346', 37, 87, 'LACTANTE X 50', 48.66, 75.00, 0.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(76, '180924154558', 37, 87, 'LACTANTE X 25', 24.33, 32.50, 0.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(77, '180924172107', 67, 69, 'TRIGO B X 60', 75.00, 102.00, 118.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(78, '180924172208', 56, 58, 'TRIGO B X 30', 37.50, 51.00, 0.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(79, '180925172116', 84, 85, 'SUPERCAT', 50.80, 56.00, 230.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(80, '180925172204', 67, 69, 'RICOCAT GATITO', 62.20, 64.00, 286.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(81, '180925172647', 67, 69, 'RICOCAT POLLO Y SARDINA', 57.00, 58.00, 230.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(82, '180925172735', 84, 85, 'RICOCAT CARNE Y LECHE', 57.00, 58.00, 134.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(83, '180925172829', 84, 85, 'RICOCAT TRUCHA', 57.00, 58.00, 30.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(84, '180925172919', 67, 69, 'DOG CHOW CACHORRO X 21', 129.00, 132.00, 2.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(85, '180925173000', 84, 86, 'DOG CHOW ADULTO X 21', 129.00, 138.00, 1.00, 2.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(86, '180925173054', 84, 86, 'MIMASKOT RAZA PEQUEÑA', 60.00, 65.00, 27.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(87, '180925173257', 84, 86, 'MIMASKOT ADULTO', 60.00, 68.00, 0.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(88, '180925173335', 67, 69, 'BABYCAN AZUL', 64.00, 65.00, 194.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(89, '180925175629', 84, 86, 'BABYCAN ADULTO VERDE', 64.00, 68.00, 22.00, 2.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(90, '180925175706', 67, 69, 'MULTISABOR', 64.00, 68.00, 92.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(91, '180925175755', 67, 69, 'RICOCAN CORDERO', 64.00, 68.00, 189.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(92, '180925183743', 84, 86, 'RICOCAN CLASICO', 82.62, 83.00, 74.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(93, '180925183835', 84, 86, 'SUPERCAN', 57.00, 58.00, 83.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(94, '180925183936', 84, 86, 'SUPERCAN CACHORRO', 65.00, 68.00, 0.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(95, '180925184020', 84, 86, 'THOR X 25', 70.00, 72.00, 137.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(96, '180925184049', 84, 86, 'NUTRICAN', 65.00, 76.00, 19.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(97, '180928112038', 84, 85, 'MICHICAT ADULTO', 42.30, 45.00, 147.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(98, '180928112230', 67, 69, 'M ENTERO X 60', 66.00, 76.00, 31.00, 50.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(99, '181005102843', 67, 69, 'CUY R X 50', 50.50, 60.00, 3.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(100, '181005102929', 67, 69, 'CUY R X 25', 25.25, 30.00, 14.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(101, '181005153518', 47, 48, 'VITA CUY X 20', 0.00, 0.00, 18.50, 2.00, 2, '', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(102, '181005153626', 33, 34, 'POLENTA X 30', 30.00, 39.00, 90.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(103, '181005153853', 45, 46, 'VITA OVO X 55', 51.70, 70.58, 1.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(104, '181005161021', 84, 86, 'DOG CHOW ADULTO X 15', 92.00, 95.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(105, '181005161115', 84, 86, 'BANDIDO', 40.00, 45.00, 3.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(106, '181005161406', 84, 90, 'CRECIMIENTO PAPIADITO', 79.23, 80.23, 1.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(107, '181005161542', 67, 69, 'AVEMICINA X 20', 64.60, 69.60, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(108, '181005161640', 84, 86, 'THOR X 15', 42.00, 43.00, 2.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(109, '181005164327', 88, 91, 'CONCHUELA  FINA', 25.00, 28.00, 129.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(110, '181005164503', 82, 83, 'CONCHUELA FINA', 25.00, 27.00, 125.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(111, '181005164534', 82, 83, 'CONCHUELA GRUESA', 25.00, 28.00, 119.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(112, '181005164614', 82, 83, 'CALCIO', 8.50, 8.50, 384.00, 30.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(113, '181005165409', 82, 83, 'SOYA', 80.00, 90.00, 474.00, 20.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(114, '181005165444', 82, 83, 'ACEITE DE SOYA', 25.00, 520.00, 2.00, 2.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(115, '181005165523', 82, 83, 'SAL INDUSTRIAL', 12.50, 12.50, 0.00, 0.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(116, '181005165600', 82, 83, 'GRANZA X 50', 42.50, 42.50, 112.00, 20.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(117, '181005165638', 67, 69, 'GRANZA X 60', 51.00, 70.00, 162.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(118, '181005165721', 82, 83, 'ALFALFA', 66.00, 66.00, 20.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(119, '181009121555', 84, 90, 'INICIO PAPIADITO X 40', 83.88, 88.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(120, '181009121656', 47, 52, 'PONEDORA VITA X 40', 46.00, 50.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(121, '181009123200', 84, 90, 'INICIO PAPIADITO X 40', 83.00, 88.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(122, '181011093743', 67, 69, 'M PARTIDO X 55', 63.25, 73.33, 4.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(123, '181011093901', 33, 34, 'M REFINADO X 55', 63.25, 72.42, 6.00, 2.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(124, '181011163310', 33, 34, 'M ENTERO X 60 F', 68.00, 76.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(125, '181011163746', 33, 34, 'M PARTIDO X 60 F', 68.00, 78.00, 5.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(126, '181011163925', 33, 34, 'M REFINADO X 60 F', 68.00, 78.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(127, '181011164009', 70, 73, 'BB MYCIN X 40', 89.00, 90.00, 1.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(128, '181011172328', 33, 34, 'M PARTIDO X 60 A', 68.00, 78.00, 3.00, 1.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/c79LwPZjtBi62T4KEV5O.jpg', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(129, '181011172408', 33, 34, 'M REFINADO X 60 A', 68.00, 83.00, 0.00, 1.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/c79LwPZjtBi62T4KEV5O.jpg', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(130, '181011172557', 37, 40, 'M MOLIDO X 60 A', 68.00, 77.00, 1.00, 1.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/c79LwPZjtBi62T4KEV5O.jpg', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(131, '181011172652', 70, 73, 'BB MYCIN X 40  L', 82.20, 92.00, 0.00, 1.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/c79LwPZjtBi62T4KEV5O.jpg', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(132, '181011181950', 33, 34, 'M PARTIDO X 15 L', 1725.00, 20.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(133, '181012091247', 67, 69, 'M ENTERO X 60 L', 68.00, 80.00, 33.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(134, '181012092032', 33, 34, 'M PARTIDO X 60 L', 68.00, 80.00, 21.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(135, '181012092306', 67, 69, 'P2 X 25', 10.00, 25.00, 4.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(136, '181012092509', 70, 73, 'BB MYCIN X 20', 40.00, 45.00, 4.00, 3.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(137, '181012093601', 70, 72, 'PICO & NAVAJA X 40 F', 80.00, 87.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(138, '181012093716', 70, 71, 'CONEJO COGORNO X 40 F', 60.00, 64.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(139, '181012094409', 37, 42, 'P3 X 25 E', 20.00, 25.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(140, '181012101024', 33, 34, 'M PARTIDO X 30 J', 33.00, 39.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(141, '181012101114', 33, 34, 'M ENTERO X 30 J', 30.00, 38.00, 1.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(142, '181016090832', 37, 39, 'ENGOR ECON X 50', 30.00, 60.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(143, '181016110603', 37, 42, 'P3 X 40', 55.00, 58.40, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(144, '181017083923', 33, 34, 'M ENTERO X 60 Q', 66.00, 76.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(145, '181017083959', 33, 34, 'M PARTIDO X 60 Q', 66.00, 79.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(146, '181017084030', 56, 57, 'TRIGO N X 60 Q', 70.00, 78.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(147, '181017084116', 37, 38, 'PAJA DE MAIZ X 60', 40.00, 48.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(148, '181018175206', 56, 57, 'TRIGO N X 15', 16.50, 22.50, 4.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(149, '181018175321', 33, 34, 'M ENTERO X 15', 16.50, 20.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(150, '181018183451', 37, 39, 'P2 X 50 E', 45.00, 50.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'SI', 0.00),
(151, '181018183539', 37, 39, 'P3 X 25 E', 22.50, 25.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(152, '181022101156', 33, 34, 'M ENTERO X 57', 66.00, 73.20, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(153, '181022103230', 33, 34, 'M PARTIDO X 57', 66.00, 76.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(154, '181022110817', 67, 69, 'ENGORDE PURINA', 74.17, 80.00, 2.00, 1.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(155, '181022150249', 84, 90, 'CASTA BRAVA X 40', 43.90, 48.90, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(156, '181022181131', 37, 39, 'ENGORDE ECON X 50', 43.00, 60.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(157, '181025102704', 67, 69, 'OVEJINA', 38.00, 48.00, 0.00, 1.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(158, '181025102747', 67, 69, 'PANKAMEL X 100 KGRS', 68.00, 80.00, 0.00, 1.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(159, '181025102846', 67, 69, 'GIRASOL X 30 KGRS', 80.00, 180.00, 0.00, 1.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(160, '181025102941', 67, 69, 'KOMBATE X 40 KGRS', 100.00, 136.80, 0.00, 1.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/img_vacio.png', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(161, '181030092610', 67, 69, 'CRECIMIENTO ECON X 50', 40.00, 60.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(162, '181030113325', 33, 34, 'M REFINADO X 57', 66.00, 76.00, 8.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(163, '181030153459', 37, 42, 'P2 X 20', 27.60, 30.00, 0.00, 1.00, 2, 'http://localhost/index.php/../resources/sy_file_repository/c79LwPZjtBi62T4KEV5O.jpg', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(164, '181031182727', 67, 69, 'CUY COGORNO X 40', 65.80, 67.00, 16.00, 2.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(165, '181102094831', 67, 69, 'M PARTIDO X 20', 10.00, 27.70, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(166, '181102094857', 67, 69, 'M REFINADO X 15', 5.00, 13.90, 4.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(167, '181102182906', 33, 34, 'MAIZ NACIONAL', 37260.00, 0.00, 62100.00, 200.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(168, '181106103601', 67, 69, 'M MOLIDO X 50', 50.00, 66.70, 5.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(169, '181109080710', 70, 92, 'ENGORDE COGORNO X 40', 61.01, 64.00, 44.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(170, '181109081303', 70, 93, 'CRECIMIENTO COGORNO X 40', 64.09, 66.00, 26.00, 5.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(171, '181109081336', 70, 94, 'INICIO GOGORNO X 40', 69.42, 72.00, 10.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(172, '181109081515', 70, 95, 'CUY COGORNO X 40', 65.15, 69.00, 10.00, 2.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(173, '181109083250', 37, 42, 'P2 X 40 COMEDERO', 51.00, 65.00, 0.00, 2.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(174, '181109083323', 37, 42, 'P3 X 40 COMEDERO', 53.00, 64.00, 0.00, 2.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(175, '181113072136', 84, 85, 'MIMASKOT GATO', 40.00, 54.00, 29.00, 3.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(176, '181113111058', 33, 34, 'M PARTIDO X 29', 32.00, 36.80, 0.00, 3.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(177, '181113114636', 33, 35, 'M PARTIDO IMPORT X 50', 40.00, 48.50, 86.00, 10.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(178, '181113115308', 33, 34, 'M PARTIDO X 60 Q', 74.00, 80.00, 0.00, 2.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(179, '181113115336', 33, 34, 'M ENTERO X 60 Q', 74.00, 77.00, 0.00, 3.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(180, '181114174944', 70, 72, 'PICO & NAVAJA X 20', 40.00, 43.50, 9.00, 2.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(181, '181116102111', 88, 91, 'SOYA X 25', 41.25, 49.00, 0.00, 1.00, 2, '', 'SI', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 0.00, 11, 'NO', 0.00),
(182, '190107112831', 70, 71, 'DEIVIS', 2.50, 2.60, 1500.00, 500.00, 2, '', 'NO', NULL, 0.00, 0.000, 0.00, 0.000, 0.00, 0.000, 2.80, 11, 'NO', 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `rol_id_rol` int(10) UNSIGNED NOT NULL,
  `rol_nombre` varchar(100) DEFAULT NULL,
  `est_id_estado` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`rol_id_rol`, `rol_nombre`, `est_id_estado`) VALUES
(1, 'ADMIN', 11),
(2, 'VENDEDOR', 11);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol_has_privilegio`
--

CREATE TABLE `rol_has_privilegio` (
  `rol_id_rol` int(10) UNSIGNED NOT NULL,
  `pri_id_privilegio` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `rol_has_privilegio`
--

INSERT INTO `rol_has_privilegio` (`rol_id_rol`, `pri_id_privilegio`) VALUES
(1, 1),
(1, 6),
(1, 9),
(1, 10),
(1, 11),
(1, 13),
(1, 16),
(1, 17),
(1, 18),
(1, 19),
(1, 20),
(1, 21),
(1, 26),
(1, 27),
(1, 28),
(1, 29),
(2, 2),
(2, 3),
(2, 4),
(2, 5),
(2, 7),
(2, 8),
(2, 11),
(2, 12),
(2, 14),
(2, 15),
(2, 16),
(2, 19),
(2, 20),
(2, 23),
(2, 25),
(2, 26),
(2, 27),
(2, 28),
(2, 29);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `salida`
--

CREATE TABLE `salida` (
  `sal_id_salida` int(10) UNSIGNED NOT NULL,
  `pcl_id_proveedor` int(10) UNSIGNED DEFAULT NULL,
  `pcl_id_cliente` int(10) UNSIGNED DEFAULT NULL,
  `tdo_id_tipo_documento` int(10) UNSIGNED DEFAULT NULL,
  `sal_fecha_doc_cliente` date DEFAULT NULL,
  `sal_numero_doc_cliente` varchar(30) DEFAULT NULL,
  `sal_fecha_registro` date DEFAULT NULL,
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
  `est_id_estado` int(10) UNSIGNED DEFAULT NULL,
  `t_venta` varchar(150) NOT NULL,
  `sal_deuda` double(15,2) NOT NULL DEFAULT '0.00',
  `sal_vuelto` double(15,2) NOT NULL,
  `sal_camion` varchar(150) NOT NULL,
  `sal_chofer` varchar(150) NOT NULL,
  `sal_observacion` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `salida`
--

INSERT INTO `salida` (`sal_id_salida`, `pcl_id_proveedor`, `pcl_id_cliente`, `tdo_id_tipo_documento`, `sal_fecha_doc_cliente`, `sal_numero_doc_cliente`, `sal_fecha_registro`, `sal_tipo`, `sal_monto_base`, `sal_monto`, `sal_monto_efectivo`, `sal_monto_tar_credito`, `sal_monto_tar_debito`, `sal_descuento`, `sal_motivo`, `caj_id_caja`, `caj_codigo`, `usu_id_usuario`, `est_id_estado`, `t_venta`, `sal_deuda`, `sal_vuelto`, `sal_camion`, `sal_chofer`, `sal_observacion`) VALUES
(561, NULL, 93, 1823, '2019-01-16', '0000001', '2019-01-16', 'C', 308.40, 308.40, 308.40, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(562, NULL, 93, 1823, '2019-01-16', '0000002', '2019-01-16', 'C', 390.90, 390.90, 390.90, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(563, NULL, 93, 1823, '2019-01-16', '0000003', '2019-01-16', 'C', 197.40, 197.40, 197.40, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(564, NULL, 93, 1823, '2019-01-16', '0000004', '2019-01-16', 'C', 175.00, 175.00, 175.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(565, NULL, 93, 1823, '2019-01-16', '0000005', '2019-01-16', 'C', 197.40, 197.40, 0.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(566, NULL, 93, 1823, '2019-01-16', '0000006', '2019-01-16', 'C', 197.40, 197.40, 197.40, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(567, NULL, 93, 1823, '2019-01-16', '0000007', '2019-01-16', 'C', 96.00, 96.00, 96.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(568, NULL, 93, 1823, '2019-01-16', '0000008', '2019-01-16', 'C', 268.00, 268.00, 268.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(569, NULL, 93, 1823, '2019-01-16', '0000009', '2019-01-16', 'C', 197.40, 197.40, 197.40, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(570, NULL, 93, 1823, '2019-01-16', '0000010', '2019-01-16', 'C', 261.40, 261.40, 261.40, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(571, NULL, 93, 1823, '2019-01-16', '0000011', '2019-01-16', 'C', 197.40, 197.40, 197.40, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(572, NULL, 93, 1823, '2019-01-16', '0000012', '2019-01-16', 'C', 229.40, 229.40, 229.40, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(573, NULL, 93, 1823, '2019-01-16', '0000013', '2019-01-16', 'C', 229.40, 229.40, 229.40, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(574, NULL, 93, 1823, '2019-01-16', '0000014', '2019-01-16', 'C', 197.40, 197.40, 197.40, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(575, NULL, 93, 1823, '2019-01-16', '0000015', '2019-01-16', 'C', 222.00, 222.00, 222.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(576, NULL, 93, 1823, '2019-01-16', '0000016', '2019-01-16', 'C', 254.00, 254.00, 254.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(577, NULL, 93, 1823, '2019-01-16', '0000017', '2019-01-16', 'C', 222.00, 222.00, 222.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(578, NULL, 93, 1823, '2019-01-16', '0000018', '2019-01-16', 'C', 254.00, 254.00, 254.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(579, NULL, 93, 1823, '2019-01-16', '0000019', '2019-01-16', 'C', 222.00, 222.00, 222.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(580, NULL, 93, 1823, '2019-01-16', '0000020', '2019-01-16', 'C', 222.00, 222.00, 222.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(581, NULL, 93, 1823, '2019-01-16', '0000021', '2019-01-16', 'C', 222.00, 222.00, 222.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(582, NULL, 93, 1823, '2019-01-16', '0000022', '2019-01-16', 'C', 222.00, 222.00, 222.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(583, NULL, 93, 1823, '2019-01-16', '0000023', '2019-01-16', 'C', 182.50, 182.50, 182.50, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(584, NULL, 93, 1823, '2019-01-16', '0000024', '2019-01-16', 'C', 254.00, 254.00, 254.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(585, NULL, 93, 1823, '2019-01-16', '0000025', '2019-01-16', 'C', 222.00, 222.00, 222.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(586, NULL, 93, 1823, '2019-01-16', '0000026', '2019-01-16', 'C', 222.00, 222.00, 222.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(587, NULL, 93, 1823, '2019-01-16', '0000027', '2019-01-16', 'C', 143.00, 143.00, 143.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(588, NULL, 93, 1823, '2019-01-16', '0000028', '2019-01-16', 'C', 143.00, 143.00, 143.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(589, NULL, 93, 1823, '2019-01-16', '0000029', '2019-01-16', 'C', 143.00, 143.00, 143.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(590, NULL, 93, 1823, '2019-01-16', '0000030', '2019-01-16', 'C', 103.50, 103.50, 103.50, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(591, NULL, 93, 1823, '2019-01-16', '0000031', '2019-01-16', 'C', 604.40, 604.40, 604.40, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(592, NULL, 93, 1823, '2019-01-16', '0000032', '2019-01-16', 'C', 224.00, 224.00, 224.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(593, NULL, 93, 1823, '2019-01-16', '0000033', '2019-01-16', 'C', 224.00, 224.00, 224.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(594, NULL, 93, 1823, '2019-01-16', '0000034', '2019-01-16', 'C', 326.00, 326.00, 326.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(595, NULL, 93, 1823, '2019-01-16', '0000035', '2019-01-16', 'C', 154.00, 154.00, 154.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(596, NULL, 93, 1823, '2019-01-16', '0000036', '2019-01-16', 'C', 154.00, 154.00, 154.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(597, NULL, 93, 1823, '2019-01-16', '0000037', '2019-01-16', 'C', 154.00, 154.00, 154.00, 0.00, 0.00, 0.00, '', '1801', '20190107041440', 3, 2, 'contado', 0.00, 0.00, '', '', ''),
(598, NULL, 93, 1823, '2019-01-17', '0000038', '2019-01-17', 'C', 186.00, 186.00, 0.00, 180.00, 0.00, 0.00, '', '1801', '20190117030514', 3, 2, 'deuda', 0.00, 0.00, '', '', ''),
(599, NULL, 93, 1823, '2019-01-23', '0000039', '2019-01-23', 'C', 50.00, 50.00, 0.00, 25.00, 0.00, 0.00, '', '1801', '20190117030514', 3, 2, 'deuda', 0.00, 0.00, '', '', ''),
(601, NULL, 14, 1823, '2019-01-31', '0000041', '2019-01-31', 'C', 385.00, 385.00, 0.00, 0.00, 0.00, 0.00, '', '1801', '20190117030514', 3, 2, 'deuda', 365.00, 0.00, '55444', 'genaro', 'dajsndajsnj asjda jnsdaj njsandja nsdjan jasdnaj s'),
(603, NULL, 16, 1823, '2019-01-31', '0000043', '2019-01-31', 'C', 50.00, 50.00, 0.00, 0.00, 0.00, 0.00, '', '1801', '20190117030514', 3, 1, 'deuda', 0.00, 0.00, '55', 'asds', 'kasnkdaks aksdk aksd a'),
(604, NULL, 16, 1823, '2019-01-31', '0000044', '2019-01-31', 'C', 50.00, 50.00, 0.00, 0.00, 0.00, 0.00, '', '1801', '20190117030514', 3, 1, 'deuda', 0.00, 0.00, '55', 'asds', 'kasnkdaks aksdk aksd a'),
(605, NULL, 16, 1823, '2019-01-31', '0000045', '2019-01-31', 'C', 50.00, 50.00, 0.00, 0.00, 0.00, 0.00, '', '1801', '20190117030514', 3, 1, 'deuda', 0.00, 0.00, '23', 'asd', 'asdasd'),
(607, NULL, 93, 1823, '2019-01-31', '0000047', '2019-01-31', 'C', 50.00, 50.00, 50.00, 0.00, 0.00, 0.00, '', '1801', '20190117030514', 3, 2, 'deuda', 0.00, 0.00, '5', 'asd', 'asd'),
(609, NULL, 93, 1823, '2019-02-01', '0000049', '2019-02-01', 'C', 268.00, 268.00, 0.00, 0.00, 0.00, 0.00, '', '1801', '20190117030514', 3, 2, 'deuda', 268.00, 0.00, '255', 'akksk', 'aksnka'),
(613, NULL, 93, 1823, '2019-02-03', '0000053', '2019-02-03', 'C', 1176.00, 940.80, 2000.00, 0.00, 0.00, 235.20, '', '1801', '20190117030514', 3, 2, 'contado', 0.00, 1059.20, 'as5', 'asda', 'asdasd'),
(614, NULL, 93, 1823, '2019-02-04', '0000054', '2019-02-04', 'C', 1561.35, 1561.35, 0.00, 500.00, 0.00, 0.00, '', '1801', '20190117030514', 3, 2, 'deuda', 1061.35, 0.00, '45-AS', 'JAIMITO EL CARTERO', 'kdkdkdk'),
(615, NULL, 93, 1822, '2019-02-17', '120', '2019-02-17', 'C', 520.00, 520.00, 0.00, 0.00, 0.00, 0.00, '', '1801', '20190117030514', 3, 2, 'deuda', 520.00, 0.00, '', '', ''),
(616, NULL, 93, 1821, '2019-02-17', '125', '2019-02-17', 'C', 1040.00, 1040.00, 1040.00, 0.00, 0.00, 0.00, '', '1801', '20190117030514', 3, 2, 'contado', 0.00, 0.00, '', '', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `salida_detalle`
--

CREATE TABLE `salida_detalle` (
  `sad_id_salida_detalle` int(10) UNSIGNED NOT NULL,
  `pro_id_producto` int(10) UNSIGNED NOT NULL,
  `sal_id_salida` int(10) UNSIGNED NOT NULL,
  `sad_cantidad` int(10) UNSIGNED DEFAULT NULL,
  `sad_ganancias` double(15,2) NOT NULL,
  `sad_sum_kilo` double(15,2) NOT NULL,
  `sad_valor` double(15,2) DEFAULT NULL,
  `sad_monto` double(15,2) DEFAULT NULL,
  `est_id_estado` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `salida_detalle`
--

INSERT INTO `salida_detalle` (`sad_id_salida_detalle`, `pro_id_producto`, `sal_id_salida`, `sad_cantidad`, `sad_ganancias`, `sad_sum_kilo`, `sad_valor`, `sad_monto`, `est_id_estado`) VALUES
(2205, 19, 561, 3, 15.60, 104.00, 32.00, 96.00, 1),
(2206, 19, 562, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2207, 1, 562, 2, 86.80, 20.00, 63.40, 126.80, 1),
(2208, 4, 562, 3, 35.10, 30.00, 66.70, 200.10, 1),
(2209, 19, 563, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2210, 4, 563, 2, 23.40, 20.00, 66.70, 133.40, 1),
(2211, 19, 564, 3, 15.60, 60.00, 32.00, 96.00, 1),
(2212, 16, 564, 2, 13.00, 24.00, 39.50, 79.00, 1),
(2213, 19, 565, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2214, 4, 565, 2, 23.40, 20.00, 66.70, 133.40, 1),
(2215, 19, 566, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2216, 4, 566, 2, 23.40, 20.00, 66.70, 133.40, 1),
(2217, 19, 567, 3, 15.60, 60.00, 32.00, 96.00, 1),
(2218, 19, 568, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2219, 89, 568, 3, 12.00, 0.00, 68.00, 204.00, 1),
(2220, 19, 569, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2221, 4, 569, 2, 23.40, 20.00, 66.70, 133.40, 1),
(2222, 19, 570, 4, 20.80, 80.00, 32.00, 128.00, 1),
(2223, 4, 570, 2, 23.40, 20.00, 66.70, 133.40, 1),
(2224, 19, 571, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2225, 4, 571, 2, 23.40, 20.00, 66.70, 133.40, 1),
(2226, 19, 572, 3, 15.60, 60.00, 32.00, 96.00, 1),
(2227, 4, 572, 2, 23.40, 20.00, 66.70, 133.40, 1),
(2228, 19, 573, 3, 15.60, 60.00, 32.00, 96.00, 1),
(2229, 4, 573, 2, 23.40, 20.00, 66.70, 133.40, 1),
(2230, 19, 574, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2231, 4, 574, 2, 23.40, 20.00, 66.70, 133.40, 1),
(2232, 19, 575, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2233, 15, 575, 2, 26.00, 22.00, 79.00, 158.00, 1),
(2234, 19, 576, 3, 15.60, 60.00, 32.00, 96.00, 1),
(2235, 15, 576, 2, 26.00, 22.00, 79.00, 158.00, 1),
(2236, 19, 577, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2237, 15, 577, 2, 26.00, 22.00, 79.00, 158.00, 1),
(2238, 19, 578, 3, 15.60, 60.00, 32.00, 96.00, 1),
(2239, 15, 578, 2, 26.00, 22.00, 79.00, 158.00, 1),
(2240, 19, 579, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2241, 15, 579, 2, 26.00, 22.00, 79.00, 158.00, 1),
(2242, 19, 580, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2243, 15, 580, 2, 26.00, 22.00, 79.00, 158.00, 1),
(2244, 19, 581, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2245, 15, 581, 2, 26.00, 22.00, 79.00, 158.00, 1),
(2246, 19, 582, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2247, 15, 582, 2, 26.00, 22.00, 79.00, 158.00, 1),
(2248, 19, 583, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2249, 16, 583, 3, 19.50, 36.00, 39.50, 118.50, 1),
(2250, 19, 584, 3, 15.60, 60.00, 32.00, 96.00, 1),
(2251, 15, 584, 2, 26.00, 22.00, 79.00, 158.00, 1),
(2252, 19, 585, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2253, 15, 585, 2, 26.00, 22.00, 79.00, 158.00, 1),
(2254, 19, 586, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2255, 15, 586, 2, 26.00, 22.00, 79.00, 158.00, 1),
(2256, 19, 587, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2257, 15, 587, 1, 13.00, 11.00, 79.00, 79.00, 1),
(2258, 19, 588, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2259, 16, 588, 2, 13.00, 24.00, 39.50, 79.00, 1),
(2260, 19, 589, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2261, 16, 589, 2, 13.00, 24.00, 39.50, 79.00, 1),
(2262, 19, 590, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2263, 16, 590, 1, 6.50, 12.00, 39.50, 39.50, 1),
(2264, 19, 591, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2265, 1, 591, 6, 260.40, 60.00, 63.40, 380.40, 1),
(2266, 14, 591, 2, 28.00, 20.00, 80.00, 160.00, 1),
(2267, 19, 592, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2268, 14, 592, 2, 28.00, 20.00, 80.00, 160.00, 1),
(2269, 14, 593, 2, 28.00, 20.00, 80.00, 160.00, 1),
(2270, 19, 593, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2271, 19, 594, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2272, 20, 594, 2, 10.00, 40.00, 45.00, 90.00, 1),
(2273, 118, 594, 2, 0.00, 0.00, 66.00, 132.00, 1),
(2274, 47, 594, 2, 2.00, 0.00, 20.00, 40.00, 1),
(2275, 19, 595, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2276, 20, 595, 2, 10.00, 40.00, 45.00, 90.00, 1),
(2277, 19, 596, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2278, 20, 596, 2, 10.00, 40.00, 45.00, 90.00, 1),
(2279, 19, 597, 2, 10.40, 40.00, 32.00, 64.00, 1),
(2280, 20, 597, 2, 10.00, 40.00, 45.00, 90.00, 1),
(2281, 22, 598, 2, 4.40, 0.00, 25.00, 50.00, 1),
(2282, 89, 598, 2, 8.00, 0.00, 68.00, 136.00, 1),
(2283, 22, 599, 2, 4.40, 0.00, 25.00, 50.00, 1),
(2285, 73, 601, 1, 33.04, 0.00, 75.00, 75.00, 1),
(2286, 23, 601, 5, 22.00, 0.00, 62.00, 310.00, 1),
(2290, 22, 607, 2, 4.40, 0.00, 25.00, 50.00, 1),
(2292, 89, 609, 2, 8.00, 0.00, 68.00, 136.00, 1),
(2293, 118, 609, 2, 0.00, 0.00, 66.00, 132.00, 1),
(2300, 19, 613, 2, 60.00, 40.00, 32.00, 64.00, 1),
(2301, 22, 613, 20, 44.00, 0.00, 25.00, 500.00, 1),
(2302, 89, 613, 9, 36.00, 0.00, 68.00, 612.00, 1),
(2303, 114, 614, 3, 1485.00, 0.00, 520.00, 1560.00, 1),
(2304, 19, 614, 5, -90.00, 100.00, 0.27, 1.35, 1),
(2305, 114, 615, 1, 495.00, 0.00, 520.00, 520.00, 1),
(2306, 115, 616, 2, 990.00, 0.00, 520.00, 1040.00, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sangria`
--

CREATE TABLE `sangria` (
  `id_sangria` int(11) NOT NULL,
  `monto` double(15,2) NOT NULL DEFAULT '0.00',
  `fecha` date NOT NULL,
  `tipo_sangria` varchar(150) NOT NULL,
  `san_motivo` varchar(250) NOT NULL,
  `caj_id_caja` int(11) NOT NULL,
  `usu_id_usuario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `sangria`
--

INSERT INTO `sangria` (`id_sangria`, `monto`, `fecha`, `tipo_sangria`, `san_motivo`, `caj_id_caja`, `usu_id_usuario`) VALUES
(19, 152.52, '2019-01-14', 'retiro', 'Pago a los trabajadores', 1801, 3),
(20, 500.00, '2019-01-14', 'ingreso', 'Pagos pendientes', 1801, 3),
(21, 80.00, '2019-01-17', 'retiro', 'Pagar deudas', 1801, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `temp`
--

CREATE TABLE `temp` (
  `usu_id_usuario` int(10) NOT NULL,
  `pro_id_producto` int(10) NOT NULL,
  `temp_tipo_movimiento` varchar(20) NOT NULL,
  `temp_cantidad` double(15,2) DEFAULT NULL,
  `temp_valor` double(15,2) DEFAULT '0.00',
  `temp_numero_lote` varchar(30) DEFAULT NULL,
  `temp_perecible` varchar(2) DEFAULT NULL,
  `temp_fecha_vencimiento` date DEFAULT NULL,
  `temp_fecha_registro` datetime DEFAULT NULL,
  `pro_ganancias` double(15,2) NOT NULL DEFAULT '0.00',
  `pro_sum_kilo` double(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_documento`
--

CREATE TABLE `tipo_documento` (
  `tdo_id_tipo_documento` int(10) UNSIGNED NOT NULL,
  `tdo_nombre` varchar(100) DEFAULT NULL,
  `tdo_tabla` varchar(100) DEFAULT NULL,
  `tdo_tamanho` int(10) UNSIGNED DEFAULT NULL,
  `tdo_orden` int(10) UNSIGNED DEFAULT NULL,
  `est_id_estado` int(10) UNSIGNED DEFAULT NULL,
  `tdo_valor1` double(15,2) DEFAULT NULL,
  `tdo_valor2` double(15,2) DEFAULT NULL,
  `tdo_valor3` double(15,2) DEFAULT NULL,
  `tdo_valor4` double(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tipo_documento`
--

INSERT INTO `tipo_documento` (`tdo_id_tipo_documento`, `tdo_nombre`, `tdo_tabla`, `tdo_tamanho`, `tdo_orden`, `est_id_estado`, `tdo_valor1`, `tdo_valor2`, `tdo_valor3`, `tdo_valor4`) VALUES
(1, 'DNI', 'PERSONA', 8, 1, 11, NULL, NULL, NULL, NULL),
(2, 'LE', 'PERSONA', 8, 2, 11, NULL, NULL, NULL, NULL),
(11, 'FACTURA', 'INGRESO', 30, 5, 11, NULL, NULL, NULL, NULL),
(12, 'BOLETA', 'INGRESO', 30, 2, 11, NULL, NULL, NULL, NULL),
(13, 'GUIA DE REMISION', 'INGRESO', 30, 3, 11, NULL, NULL, NULL, NULL),
(14, 'DEVOLUCION', 'INGRESO', 30, 4, 11, NULL, NULL, NULL, NULL),
(15, 'NOTA DE PEDIDO', 'INGRESO', 30, 1, 11, NULL, NULL, NULL, NULL),
(1821, 'FACTURA', 'SALIDA', 7, 2, 11, 18.00, NULL, 0.00, NULL),
(1822, 'BOLETA', 'SALIDA', 7, 3, 11, 0.00, NULL, 0.00, NULL),
(1823, 'NOTA DE PEDIDO', 'SALIDA', 7, 1, 11, 0.00, NULL, 0.00, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidad_medida`
--

CREATE TABLE `unidad_medida` (
  `unm_id_unidad_medida` int(11) NOT NULL,
  `unm_nombre` varchar(60) DEFAULT NULL,
  `unm_nombre_corto` varchar(10) DEFAULT NULL,
  `est_id_estado` int(10) UNSIGNED DEFAULT NULL,
  `unm_eliminado` varchar(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `unidad_medida`
--

INSERT INTO `unidad_medida` (`unm_id_unidad_medida`, `unm_nombre`, `unm_nombre_corto`, `est_id_estado`, `unm_eliminado`) VALUES
(1, 'xxx', 'xxx', 11, 'NO'),
(2, 'Kilogramo', 'Kgr', 11, 'NO'),
(3, 'Saco', 'Sac', 11, 'NO'),
(4, 'Saco', 'Sac', 11, 'NO'),
(5, 'Saco', 'Sac', NULL, 'NO'),
(6, 'Kilogramo', 'Kgr', NULL, 'NO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `usu_id_usuario` int(11) NOT NULL,
  `usu_nombre` varchar(20) DEFAULT NULL,
  `usu_clave` varchar(255) DEFAULT NULL,
  `rol_id_rol` int(10) UNSIGNED NOT NULL,
  `est_id_estado` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`usu_id_usuario`, `usu_nombre`, `usu_clave`, `rol_id_rol`, `est_id_estado`) VALUES
(1, 'admin', '$2y$12$.5eVZRxrEzu6NYFD3CkrI.vMy1ASiQja2/8.fcf3SdwZini3lCWi.', 1, 12),
(2, 'leonel', '$2y$12$TuYRyrArnPsMyKN2FwM94Or2dhcJvsBs6NbqPYrfdPscaqqrbDLoq', 2, 11),
(3, 'soporte', '$2y$12$T889H6wQJIHgXX0InZV1Qu.bWNqSe9yMjcFyqHvc6BTUzEBVpAjry', 2, 11),
(4, 'colorado', '$2y$12$vJCwXLIw9IzhA0GT2AVbJubNa6MEGjJxiDju2GKbjPrpVwAy5CjEK', 2, 12);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `caja`
--
ALTER TABLE `caja`
  ADD PRIMARY KEY (`caj_id_caja`),
  ADD UNIQUE KEY `caja_un_codigo` (`caj_codigo`);

--
-- Indices de la tabla `clase`
--
ALTER TABLE `clase`
  ADD PRIMARY KEY (`cla_id_clase`);

--
-- Indices de la tabla `datos_empresa_local`
--
ALTER TABLE `datos_empresa_local`
  ADD PRIMARY KEY (`daemlo_id_datos_empresa_local`);

--
-- Indices de la tabla `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`emp_id_empresa`),
  ADD UNIQUE KEY `empresa_un_ruc` (`emp_ruc`);

--
-- Indices de la tabla `estado`
--
ALTER TABLE `estado`
  ADD PRIMARY KEY (`est_id_estado`);

--
-- Indices de la tabla `ingreso`
--
ALTER TABLE `ingreso`
  ADD PRIMARY KEY (`ing_id_ingreso`),
  ADD KEY `ingreso_fk_tip_doc` (`tdo_id_tipo_documento`),
  ADD KEY `ingreso_fk_pcliente` (`pcl_id_proveedor`),
  ADD KEY `ingreso_fk_pcliente2` (`pcl_id_cliente`);

--
-- Indices de la tabla `ingreso_detalle`
--
ALTER TABLE `ingreso_detalle`
  ADD PRIMARY KEY (`ind_id_ingreso_detalle`),
  ADD KEY `ingreso_detalle_fk_ingreso` (`ing_id_ingreso`),
  ADD KEY `ingreso_detalle_fk_producto` (`pro_id_producto`);

--
-- Indices de la tabla `mayor`
--
ALTER TABLE `mayor`
  ADD PRIMARY KEY (`id_mayor`),
  ADD KEY `sal_id_salida` (`sal_id_salida`) USING BTREE,
  ADD KEY `pcl_id_cliente` (`pcl_id_cliente`);

--
-- Indices de la tabla `movimiento`
--
ALTER TABLE `movimiento`
  ADD PRIMARY KEY (`mov_id_movimiento`),
  ADD KEY `movimiento_fk_ingreso_detalle` (`ind_id_ingreso_detalle`),
  ADD KEY `movimiento_fk_salida_detalle` (`sad_id_salida_detalle`);

--
-- Indices de la tabla `pcliente`
--
ALTER TABLE `pcliente`
  ADD PRIMARY KEY (`pcl_id_pcliente`),
  ADD KEY `pcliente_fk_empresa` (`emp_id_empresa`),
  ADD KEY `pcliente_fk_persona` (`per_id_persona`);

--
-- Indices de la tabla `persona`
--
ALTER TABLE `persona`
  ADD PRIMARY KEY (`per_id_persona`),
  ADD UNIQUE KEY `persona_un_tipdoc_numerodoc` (`tdo_id_tipo_documento`,`per_numero_doc`),
  ADD KEY `persona_fk_tip_doc` (`tdo_id_tipo_documento`);

--
-- Indices de la tabla `privilegio`
--
ALTER TABLE `privilegio`
  ADD PRIMARY KEY (`pri_id_privilegio`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`pro_id_producto`),
  ADD UNIQUE KEY `producto_un_codigo` (`pro_codigo`),
  ADD KEY `producto_fk_uni_med` (`unm_id_unidad_medida`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`rol_id_rol`),
  ADD KEY `rol_fk_estado` (`est_id_estado`);

--
-- Indices de la tabla `rol_has_privilegio`
--
ALTER TABLE `rol_has_privilegio`
  ADD PRIMARY KEY (`rol_id_rol`,`pri_id_privilegio`),
  ADD KEY `rol_has_privilegio_fk_rol` (`rol_id_rol`),
  ADD KEY `rol_has_privilegio_fk_privilegio` (`pri_id_privilegio`);

--
-- Indices de la tabla `salida`
--
ALTER TABLE `salida`
  ADD PRIMARY KEY (`sal_id_salida`),
  ADD KEY `salida_fk_tip_doc` (`tdo_id_tipo_documento`),
  ADD KEY `salida_fk_pcliente` (`pcl_id_cliente`),
  ADD KEY `salida_fk_pcliente2` (`pcl_id_proveedor`),
  ADD KEY `r_salida_fk_caja` (`caj_id_caja`);

--
-- Indices de la tabla `salida_detalle`
--
ALTER TABLE `salida_detalle`
  ADD PRIMARY KEY (`sad_id_salida_detalle`),
  ADD KEY `salida_detalle_fk_salida` (`sal_id_salida`),
  ADD KEY `salida_detalle_fk_producto` (`pro_id_producto`);

--
-- Indices de la tabla `sangria`
--
ALTER TABLE `sangria`
  ADD PRIMARY KEY (`id_sangria`),
  ADD KEY `caj_id_caja` (`caj_id_caja`),
  ADD KEY `usu_id_usuario` (`usu_id_usuario`);

--
-- Indices de la tabla `temp`
--
ALTER TABLE `temp`
  ADD KEY `usu_id_usuario` (`usu_id_usuario`) USING BTREE;

--
-- Indices de la tabla `tipo_documento`
--
ALTER TABLE `tipo_documento`
  ADD PRIMARY KEY (`tdo_id_tipo_documento`);

--
-- Indices de la tabla `unidad_medida`
--
ALTER TABLE `unidad_medida`
  ADD PRIMARY KEY (`unm_id_unidad_medida`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`usu_id_usuario`),
  ADD UNIQUE KEY `usuario_un_nombre` (`usu_nombre`),
  ADD KEY `usuario_fk_estado` (`est_id_estado`),
  ADD KEY `usuario_fk_rol` (`rol_id_rol`),
  ADD KEY `usuario_fk_persona` (`usu_id_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `clase`
--
ALTER TABLE `clase`
  MODIFY `cla_id_clase` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=96;

--
-- AUTO_INCREMENT de la tabla `empresa`
--
ALTER TABLE `empresa`
  MODIFY `emp_id_empresa` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=181;

--
-- AUTO_INCREMENT de la tabla `ingreso`
--
ALTER TABLE `ingreso`
  MODIFY `ing_id_ingreso` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de la tabla `ingreso_detalle`
--
ALTER TABLE `ingreso_detalle`
  MODIFY `ind_id_ingreso_detalle` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `mayor`
--
ALTER TABLE `mayor`
  MODIFY `id_mayor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT de la tabla `movimiento`
--
ALTER TABLE `movimiento`
  MODIFY `mov_id_movimiento` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3035;

--
-- AUTO_INCREMENT de la tabla `pcliente`
--
ALTER TABLE `pcliente`
  MODIFY `pcl_id_pcliente` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=156;

--
-- AUTO_INCREMENT de la tabla `persona`
--
ALTER TABLE `persona`
  MODIFY `per_id_persona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `privilegio`
--
ALTER TABLE `privilegio`
  MODIFY `pri_id_privilegio` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `pro_id_producto` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=183;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `rol_id_rol` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `salida`
--
ALTER TABLE `salida`
  MODIFY `sal_id_salida` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=617;

--
-- AUTO_INCREMENT de la tabla `salida_detalle`
--
ALTER TABLE `salida_detalle`
  MODIFY `sad_id_salida_detalle` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2307;

--
-- AUTO_INCREMENT de la tabla `sangria`
--
ALTER TABLE `sangria`
  MODIFY `id_sangria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `unidad_medida`
--
ALTER TABLE `unidad_medida`
  MODIFY `unm_id_unidad_medida` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `ingreso`
--
ALTER TABLE `ingreso`
  ADD CONSTRAINT `ingreso_ibfk_1` FOREIGN KEY (`tdo_id_tipo_documento`) REFERENCES `tipo_documento` (`tdo_id_tipo_documento`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `ingreso_ibfk_2` FOREIGN KEY (`pcl_id_proveedor`) REFERENCES `pcliente` (`pcl_id_pcliente`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `ingreso_ibfk_3` FOREIGN KEY (`pcl_id_cliente`) REFERENCES `pcliente` (`pcl_id_pcliente`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `ingreso_detalle`
--
ALTER TABLE `ingreso_detalle`
  ADD CONSTRAINT `ingreso_detalle_ibfk_1` FOREIGN KEY (`ing_id_ingreso`) REFERENCES `ingreso` (`ing_id_ingreso`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `ingreso_detalle_ibfk_2` FOREIGN KEY (`pro_id_producto`) REFERENCES `producto` (`pro_id_producto`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `movimiento`
--
ALTER TABLE `movimiento`
  ADD CONSTRAINT `movimiento_ibfk_1` FOREIGN KEY (`ind_id_ingreso_detalle`) REFERENCES `ingreso_detalle` (`ind_id_ingreso_detalle`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `movimiento_ibfk_2` FOREIGN KEY (`sad_id_salida_detalle`) REFERENCES `salida_detalle` (`sad_id_salida_detalle`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `pcliente`
--
ALTER TABLE `pcliente`
  ADD CONSTRAINT `pcliente_ibfk_1` FOREIGN KEY (`emp_id_empresa`) REFERENCES `empresa` (`emp_id_empresa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `pcliente_ibfk_2` FOREIGN KEY (`per_id_persona`) REFERENCES `persona` (`per_id_persona`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `persona`
--
ALTER TABLE `persona`
  ADD CONSTRAINT `persona_ibfk_1` FOREIGN KEY (`tdo_id_tipo_documento`) REFERENCES `tipo_documento` (`tdo_id_tipo_documento`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`unm_id_unidad_medida`) REFERENCES `unidad_medida` (`unm_id_unidad_medida`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `rol`
--
ALTER TABLE `rol`
  ADD CONSTRAINT `rol_ibfk_1` FOREIGN KEY (`est_id_estado`) REFERENCES `estado` (`est_id_estado`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `rol_has_privilegio`
--
ALTER TABLE `rol_has_privilegio`
  ADD CONSTRAINT `rol_has_privilegio_ibfk_1` FOREIGN KEY (`rol_id_rol`) REFERENCES `rol` (`rol_id_rol`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `rol_has_privilegio_ibfk_2` FOREIGN KEY (`pri_id_privilegio`) REFERENCES `privilegio` (`pri_id_privilegio`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `salida`
--
ALTER TABLE `salida`
  ADD CONSTRAINT `salida_fk_caja` FOREIGN KEY (`caj_id_caja`) REFERENCES `caja` (`caj_id_caja`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `salida_ibfk_1` FOREIGN KEY (`tdo_id_tipo_documento`) REFERENCES `tipo_documento` (`tdo_id_tipo_documento`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `salida_ibfk_2` FOREIGN KEY (`pcl_id_cliente`) REFERENCES `pcliente` (`pcl_id_pcliente`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `salida_ibfk_3` FOREIGN KEY (`pcl_id_proveedor`) REFERENCES `pcliente` (`pcl_id_pcliente`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `salida_detalle`
--
ALTER TABLE `salida_detalle`
  ADD CONSTRAINT `salida_detalle_ibfk_1` FOREIGN KEY (`sal_id_salida`) REFERENCES `salida` (`sal_id_salida`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `salida_detalle_ibfk_2` FOREIGN KEY (`pro_id_producto`) REFERENCES `producto` (`pro_id_producto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `temp`
--
ALTER TABLE `temp`
  ADD CONSTRAINT `usu_id_usuario` FOREIGN KEY (`usu_id_usuario`) REFERENCES `usuario` (`usu_id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`est_id_estado`) REFERENCES `estado` (`est_id_estado`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `usuario_ibfk_2` FOREIGN KEY (`rol_id_rol`) REFERENCES `rol` (`rol_id_rol`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `usuario_ibfk_3` FOREIGN KEY (`usu_id_usuario`) REFERENCES `persona` (`per_id_persona`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
