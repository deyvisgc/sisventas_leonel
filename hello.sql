DELIMITER $$
CREATE DEFINER=`fqp29breluu1`@`localhost` PROCEDURE `proc_salida_registrar`(OUT `out_hecho` VARCHAR(2), OUT `out_estado` VARCHAR(7), OUT `out_sal_id_salida` INT,
IN `in_usu_id_usuario` INT, IN `in_pcl_id_cliente` INT, IN `in_sal_fecha_doc_cliente` VARCHAR(30), IN `in_tdo_id_tipo_documento` INT, IN `in_sal_monto_efectivo` DOUBLE(15,2), IN `in_sal_monto_tar_credito` DOUBLE(15,2), IN `in_sal_monto_tar_debito` DOUBLE(15,2), IN `in_sal_descuento` DOUBLE(15,2), IN `in_sal_motivo` VARCHAR(60), IN `in_sal_vuelto` VARCHAR(150), IN `in_tipo_venta` VARCHAR(60), IN `in_deuda` DOUBLE(15,2), IN `in_sal_chofer` VARCHAR(150), IN `in_sal_camion` VARCHAR(150), IN `in_sal_observación` VARCHAR(250), IN `in_numero_doc` INT)
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
        in_numero_doc,
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
DELIMITER ;