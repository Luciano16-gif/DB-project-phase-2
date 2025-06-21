--Códigos de Prueba o de Consulta del Proyecto Base de Datos


--==========================================================================
--PRUEBA 3.1: Inserción de Habitaciones
--==========================================================================
--Descripción: Insertar nuevas habitaciones y verificar que num_camas del --hospital se actualiza.
--Resultado Esperado: Se calculará la suma inicial de camas para cada --hospital. Después de las inserciones, el num_camas de los hospitales se --actualizará para reflejar las nuevas camas.
--==========================================================================

-- Antes de la inserción:
SELECT id_hospital, nombre, num_camas FROM Hospital;
-- Calcule las camas iniciales para referencia:
-- Hospital Central (ID 1): 1+2+1+1+2+2+1+1 = 11 camas
-- Hospital Universitario (ID 2): 1+2+1+1+2+2+1+1 = 11 camas
-- Clínica Santa María (ID 3): 1+1+1+2+1+1+1+1 = 9 camas
-- Hospital Regional (ID 4): 2+2+1+1+1+1+2+2 = 12 camas


-- Insertar nuevas habitaciones
INSERT INTO Habitacion (id_hospital, numero_departamento, numero_habitacion, tipo, num_camas, tarifa_dia, ocupada) VALUES
(1, 1, '103', 'Individual', 1, 160.00, FALSE), -- Hospital 1: +1 cama
(2, 5, '305', 'Doble', 2, 230.00, FALSE), -- Hospital 2: +2 camas
(3, 1, '103', 'Individual', 1, 200.00, TRUE), -- Hospital 3: +1 cama
(4, 1, '103', 'Individual', 1, 180.00, FALSE); -- Hospital 4: +1 cama

-- Después de la inserción:
SELECT id_hospital, nombre, num_camas FROM Hospital;
-- Hospital Central debería tener 12 camas (11 + 1)
-- Hospital Universitario debería tener 13 camas (11 + 2)
-- Clínica Santa María debería tener 10 camas (9 + 1)
-- Hospital Regional debería tener 13 camas (12 + 1)

--==========================================================================
--PRUEBA 3.2: Actualización de Habitaciones
--========================================================================== 
--Descripción: Modificar el número de camas de una habitación existente y --verificar el impacto en el hospital.
--Resultado Esperado: El num_camas del Hospital 1 debería ajustarse --correctamente. Si la '101' del Hospital Central pasa de 1 a 2 camas, el --total de camas del Hospital Central debería ser 13 (12 + (2-1)).
--========================================================================== 

-- Antes de la actualización:
SELECT id_hospital, nombre, num_camas FROM Hospital WHERE id_hospital = 1;
SELECT numero_habitacion, num_camas FROM Habitacion WHERE numero_habitacion = '101' AND id_hospital = 1;

-- Actualizar una habitación (cambiar de 1 cama a 2 camas)
UPDATE Habitacion SET num_camas = 2 WHERE numero_habitacion = '101' AND id_hospital = 1;

-- Después de la actualización:
SELECT id_hospital, nombre, num_camas FROM Hospital WHERE id_hospital = 1;
SELECT numero_habitacion, num_camas FROM Habitacion WHERE numero_habitacion = '101' AND id_hospital = 1;

--==========================================================================
--==========================================================================
--PRUEBA 3.3: Eliminación de Habitaciones
--==========================================================================
--Descripción: Eliminar una habitación y verificar que num_camas del --hospital se decrementa.
--Resultado Esperado: El num_camas del Hospital 1 debería ajustarse --correctamente. Si se elimina la '102' del Hospital Central (2 camas), el --total de camas del Hospital Central debería ser 11 (13 - 2).
--==========================================================================

-- Antes de la eliminación:
SELECT id_hospital, nombre, num_camas FROM Hospital WHERE id_hospital = 1;
SELECT numero_habitacion, num_camas FROM Habitacion WHERE numero_habitacion = '102' AND id_hospital = 1;

-- Eliminar una habitación
DELETE FROM Habitacion WHERE numero_habitacion = '102' AND id_hospital = 1;

-- Después de la eliminación:
SELECT id_hospital, nombre, num_camas FROM Hospital WHERE id_hospital = 1;
SELECT numero_habitacion, num_camas FROM Habitacion WHERE numero_habitacion = '102' AND id_hospital = 1; -- Debería no retornar filas


--==========================================================================
--PRUEBA 4.1: Uso exitoso de insumo
--==========================================================================
--Descripción: Registrar el uso de un insumo que tiene stock suficiente.
--Resultado Esperado: La cantidad del insumo en Inventario debe disminuir en --la cantidad usada.
--========================================================================== 

-- Antes del uso (ejemplo con Insumo ID 1 - Paracetamol en Hospital 1):
SELECT I.nombre, INV.cantidad FROM Inventario INV JOIN Insumo_Medico I ON INV.id_insumo = I.id_insumo WHERE INV.id_hospital = 1 AND INV.id_insumo = 1;
-- Cantidad inicial: 100

-- Registrar uso de insumos para el Evento_Clinico con id_evento = 11 (Cateterismo cardíaco en Hospital Central)
INSERT INTO Evento_Usa_Insumo (id_evento, id_insumo, cantidad) VALUES (11, 1, 10); -- Usar 10 Paracetamol (ID 1)
INSERT INTO Evento_Usa_Insumo (id_evento, id_insumo, cantidad) VALUES (12, 12, 2); -- Usar 2 Guantes látex M (ID 12)

-- Después del uso:
SELECT I.nombre, INV.cantidad FROM Inventario INV JOIN Insumo_Medico I ON INV.id_insumo = I.id_insumo WHERE INV.id_hospital = 1 AND INV.id_insumo IN (1, 12);
-- Se espera que Paracetamol (ID 1) sea 90 y Guantes látex M (ID 12) sea 148.

--==========================================================================
--PRUEBA 4.2: Uso de insumo con stock insuficiente (ERROR esperado)
--==========================================================================
--Descripción: Intentar registrar el uso de un insumo en una cantidad mayor --a la disponible en el inventario.
--Resultado Esperado: La inserción debe fallar con el mensaje de error --"Stock insuficiente del insumo ID X en el hospital ID Y".
--==========================================================================

-- Antes del intento de uso (ejemplo con Insumo ID 1 - Paracetamol en Hospital 1):
SELECT I.nombre, INV.cantidad FROM Inventario INV JOIN Insumo_Medico I ON INV.id_insumo = I.id_insumo WHERE INV.id_hospital = 1 AND INV.id_insumo = 1;
-- Cantidad actual: 90

-- Intentar usar más de lo que hay (ej: 1000 Paracetamol, cuando solo hay 90)
-- ESTA INSERCIÓN DEBERÍA FALLAR
INSERT INTO Evento_Usa_Insumo (id_evento, id_insumo, cantidad) VALUES (11, 1, 1000);

-- Verificar que la cantidad no ha cambiado (si la inserción falla, no hay cambio)
SELECT I.nombre, INV.cantidad FROM Inventario INV JOIN Insumo_Medico I ON INV.id_insumo = I.id_insumo WHERE INV.id_hospital = 1 AND INV.id_insumo = 1;

--==========================================================================
--PRUEBA 4.3: Uso de insumo no existente en el inventario (ERROR esperado)
--==========================================================================
--Descripción: Intentar registrar el uso de un insumo que no está en el --inventario del hospital especificado.
--Resultado Esperado: La inserción debe fallar con el mensaje de error --"Stock insuficiente del insumo ID X en el hospital ID Y" (ya que la --v_cantidad_actual sería NULL).
--==========================================================================
-- Intentar usar un insumo que no existe en el inventario del Hospital 1 (ej: Insumo ID 999)
-- ESTA INSERCIÓN DEBERÍA FALLAR
INSERT INTO Evento_Usa_Insumo (id_evento, id_insumo, cantidad) VALUES (11, 999, 1);





--==========================================================================
--PRUEBA 5.1: Recepción de un encargo pendiente (UPDATE si ya existe)
--==========================================================================
--Descripción: Actualizar el estado de un encargo pendiente a 'Recibido'.
--Resultado Esperado: La cantidad de los insumos en Inventario debe --incrementarse según el detalle del encargo.
--==========================================================================

-- Antes de la recepción del encargo (Encargo ID 4 - Hospital 2, Insumos 9 y 10):
SELECT I.nombre, INV.cantidad
FROM Inventario INV
JOIN Insumo_Medico I ON INV.id_insumo = I.id_insumo
WHERE INV.id_hospital = 2 AND INV.id_insumo IN (9, 10);
-- El Inventario del Hospital 2 no tiene inicialmente los insumos 9 y 10, por lo que deberían aparecer con las cantidades del encargo.

-- Estado inicial del encargo 4
SELECT id_encargo, estado, fecha_recepcion FROM Encargo WHERE id_encargo = 4;

-- Cambiar el estado del encargo a 'Recibido' para activar el trigger
UPDATE Encargo SET estado = 'Recibido', fecha_recepcion = CURRENT_DATE WHERE id_encargo = 4;

-- Después de la recepción del encargo:
SELECT I.nombre, INV.cantidad
FROM Inventario INV
JOIN Insumo_Medico I ON INV.id_insumo = I.id_insumo
WHERE INV.id_hospital = 2 AND INV.id_insumo IN (9, 10);
-- Se espera que Bisturí (ID 9) aparezca con 8 unidades y Pinza Kelly (ID 10) con 6 unidades.
SELECT id_encargo, estado, fecha_recepcion FROM Encargo WHERE id_encargo = 4;

--==========================================================================  
--PRUEBA 5.2: Recepción de un encargo donde algunos insumos ya existían y --otros son nuevos
--==========================================================================
--Descripción: Actualizar el estado de otro encargo pendiente a 'Recibido', --que contiene insumos ya existentes y nuevos en el inventario del hospital.
--Resultado Esperado: Las cantidades de los insumos existentes deben sumarse --a las del encargo, y los nuevos deben insertarse.
--==========================================================================
-- Antes de la recepción del encargo (Encargo ID 6 - Hospital 3, Insumos 1 y 11):
SELECT I.nombre, INV.cantidad
FROM Inventario INV
JOIN Insumo_Medico I ON INV.id_insumo = I.id_insumo
WHERE INV.id_hospital = 3 AND INV.id_insumo IN (1, 11);
-- Insumo 1 (Paracetamol) tiene 90 en H3. Insumo 11 (Gasas) no existe en H3.

-- Estado inicial del encargo 6
SELECT id_encargo, estado, fecha_recepcion FROM Encargo WHERE id_encargo = 6;

-- Cambiar el estado del encargo a 'Recibido' para activar el trigger
UPDATE Encargo SET estado = 'Recibido', fecha_recepcion = CURRENT_DATE WHERE id_encargo = 6;

-- Después de la recepción del encargo:
SELECT I.nombre, INV.cantidad
FROM Inventario INV
JOIN Insumo_Medico I ON INV.id_insumo = I.id_insumo
WHERE INV.id_hospital = 3 AND INV.id_insumo IN (1, 11);
-- Se espera que Paracetamol (ID 1) sea 90 + 60 = 150.
-- Se espera que Gasas (ID 11) aparezca con 100 unidades.
SELECT id_encargo, estado, fecha_recepcion FROM Encargo WHERE id_encargo = 6;

--======================================================================
--PRUEBA 5.3: No activación del trigger si el estado no cambia a 'Recibido'
--====================================================================== 
--Descripción: Crear un encargo y cambiar su estado a algo diferente de --n'Recibido' (ej. 'Cancelado') o a 'Recibido' si ya estaba 'Recibido'.
--Resultado Esperado: La cantidad de los insumos en Inventario no debe --cambiar.
--======================================================================

-- Antes de la modificación del encargo (Encargo ID 8 - Hospital 4, Insumos 15 y 2):
SELECT I.nombre, INV.cantidad
FROM Inventario INV
JOIN Insumo_Medico I ON INV.id_insumo = I.id_insumo
WHERE INV.id_hospital = 4 AND INV.id_insumo IN (15, 2);
-- Insumo 15 (Mascarillas N95) tiene 25 en H4. Insumo 2 (Ibuprofeno) tiene 70 en H4.

-- Estado inicial del encargo 8
SELECT id_encargo, estado, fecha_recepcion FROM Encargo WHERE id_encargo = 8;

-- Cambiar el estado del encargo a 'Cancelado' (no debería activar el trigger de inventario)
UPDATE Encargo SET estado = 'Cancelado' WHERE id_encargo = 8;

-- Después de la modificación del encargo:
SELECT I.nombre, INV.cantidad
FROM Inventario INV
JOIN Insumo_Medico I ON INV.id_insumo = I.id_insumo
WHERE INV.id_hospital = 4 AND INV.id_insumo IN (15, 2);
-- Se espera que las cantidades de Mascarillas N95 y Ibuprofeno no hayan cambiado.
SELECT id_encargo, estado, fecha_recepcion FROM Encargo WHERE id_encargo = 8;


--======================================================================
--PRUEBA 6.1: Pago completo de factura por seguro
--======================================================================
--Descripción: Realizar un Pago_Seguro que cubra el monto total de una --factura.
--Resultado Esperado: El estado de la Factura debe cambiar a 'Pagada' y --metodo_pago a 'Seguro'.
--======================================================================

-- Antes del pago (Factura ID 8 - 220.40 Pendiente):
SELECT id_factura, total, estado, metodo_pago FROM Factura WHERE id_factura = 8;

-- Realizar un pago de seguro que cubra el total de la factura
INSERT INTO Pago_Seguro (id_factura, id_afiliacion, monto_cubierto, fecha_pago, numero_autorizacion) VALUES
(8, (SELECT id_afiliacion FROM Afiliacion_Seguro WHERE ci_paciente = 'V-10000003'), 220.40, CURRENT_DATE, 'AUT-008-FULL');

-- Después del pago:
SELECT id_factura, total, estado, metodo_pago FROM Factura WHERE id_factura = 8;
-- Se espera que el estado sea 'Pagada' y metodo_pago 'Seguro'.

--=====================================================================
--PRUEBA 6.2: Pago parcial de factura por seguro
--=====================================================================
--Descripción: Realizar un Pago_Seguro que no cubra el monto total de una --factura.
--Resultado Esperado: El estado de la Factura debe permanecer 'Pendiente'.
--=====================================================================

-- Antes del pctura ID 14 - 52ago (Fa20.00 Pendiente):
SELECT id_factura, total, estado, metodo_pago FROM Factura WHERE id_factura = 14;

-- Realizar un pago parcial de seguro (menos del total)
INSERT INTO Pago_Seguro (id_factura, id_afiliacion, monto_cubierto, fecha_pago, numero_autorizacion) VALUES
(14, (SELECT id_afiliacion FROM Afiliacion_Seguro WHERE ci_paciente = 'V-10000002'), 2000.00, CURRENT_DATE, 'AUT-014-PART1');

-- Después del pago:
SELECT id_factura, total, estado, metodo_pago FROM Factura WHERE id_factura = 14;
-- Se espera que el estado siga siendo 'Pendiente'.

--==========================================================================
--PRUEBA 6.3: Múltiples pagos hasta cubrir el total
--==========================================================================
--Descripción: Realizar varios Pago_Seguro que sumados cubran el monto total --de una factura.
--Resultado Esperado: El estado de la Factura debe cambiar a 'Pagada' y --metodo_pago a 'Seguro' solo después del último pago que complete o supere --el total.
--==========================================================================

-- Antes de los pagos adicionales (Factura ID 14 - 5220.00 Pendiente, ya con 2000.00 pagados):
SELECT id_factura, total, estado, metodo_pago FROM Factura WHERE id_factura = 14;

-- Realizar un segundo pago (no suficiente para cubrir el total)
INSERT INTO Pago_Seguro (id_factura, id_afiliacion, monto_cubierto, fecha_pago, numero_autorizacion) VALUES
(14, (SELECT id_afiliacion FROM Afiliacion_Seguro WHERE ci_paciente = 'V-10000002'), 1500.00, CURRENT_DATE, 'AUT-014-PART2');

-- Verificar el estado (debería seguir Pendiente, 2000+1500 = 3500 < 5220.00)
SELECT id_factura, total, estado, metodo_pago FROM Factura WHERE id_factura = 14;

-- Realizar un tercer pago (suficiente para cubrir o superar el total)
INSERT INTO Pago_Seguro (id_factura, id_afiliacion, monto_cubierto, fecha_pago, numero_autorizacion) VALUES
(14, (SELECT id_afiliacion FROM Afiliacion_Seguro WHERE ci_paciente = 'V-10000002'), 1720.00, CURRENT_DATE, 'AUT-014-FINAL'); -- Ahora 3500 + 1720 = 5220

-- Verificar el estado final (debería ser Pagada)
SELECT id_factura, total, estado, metodo_pago FROM Factura WHERE id_factura = 14;


--==========================================================================
--PRUEBA 7.1: Integridad Referencial (Inventario con id_hospital inexistente)
--==========================================================================--Descripción: Intenta insertar un registro en Inventario con un id_hospital --que no existe en la tabla Hospital.
--Resultado Esperado: La inserción debe fallar con un error de violación de --la foreign key.
--==========================================================================
-- ESTA INSERCIÓN DEBERÍA FALLAR
INSERT INTO Inventario (id_hospital, id_insumo, cantidad) VALUES (9999, 1, 100);

--==========================================================================
--PRUEBA 7.2: Integridad Referencial (Inventario con id_insumo inexistente)
--==========================================================================
--Descripción: Intenta insertar un registro en Inventario con un id_insumo --que no existe en la tabla Insumo_Medico.
--Resultado Esperado: La inserción debe fallar con un error de violación de --la foreign key.
--==========================================================================

-- ESTA INSERCIÓN DEBERÍA FALLAR
INSERT INTO Inventario (id_hospital, id_insumo, cantidad) VALUES (1, 9999, 100);
-- Considera usar un comando ROLLBACK si tu entorno lo requiere para deshacer la transacción de error.

--==========================================================================
--PRUEBA 7.3: Integridad Referencial (Evento_Clinico con ci_paciente --inexistente)
--==========================================================================
--Descripción: Intenta insertar un Evento_Clinico con un ci_paciente que no --existe.
--Resultado Esperado: La inserción debe fallar con un error de violación de --la foreign key.
--==========================================================================

INSERT INTO Evento_Clinico (tipo, fecha, hora, ci_paciente, ci_medico, id_hospital, descripcion, costo) VALUES
('Consulta', '2025-01-01', '09:00:00', 'V-00000000', 'V-12345678', 1, 'Paciente inexistente', 100.00);

--========================================================================== 
--PRUEBA 7.4: Integridad Referencial (Evento_Clinico con ci_medico --inexistente)
--==========================================================================
--Descripción: Intenta insertar un Evento_Clinico con un ci_medico que no --existe.
--Resultado Esperado: La inserción debe fallar con un error de violación de --la foreign key.
--==========================================================================

-- ESTA INSERCIÓN DEBERÍA FALLAR
INSERT INTO Evento_Clinico (tipo, fecha, hora, ci_paciente, ci_medico, id_hospital, descripcion, costo) VALUES
('Consulta', '2025-01-01', '09:00:00', 'V-10000001', 'V-00000000', 1, 'Medico inexistente', 100.00);

--==========================================================================
--PRUEBA 7.5: Integridad Referencial (Habitacion con Departamento inexistente)
--==========================================================================
--Descripción: Intenta insertar una Habitacion referenciando un id_hospital --y numero_departamento que no existen juntos.
--Resultado Esperado: La inserción debe fallar con un error de violación de --la foreign key.
--==========================================================================

-- ESTA INSERCIÓN DEBERÍA FALLAR
INSERT INTO Habitacion (id_hospital, numero_departamento, numero_habitacion, tipo, num_camas, tarifa_dia, ocupada) VALUES
(1, 999, 'H999', 'Individual', 1, 100.00, FALSE);


--==========================================================================      
-- PRUEBA 7.6: Restricción CHECK (Evento_Clinico - Tipo Inválido)
--============================================================================
-- Descripción: Intenta insertar un Evento_Clinico con un tipo no permitido por 
-- la restricción CHECK. Solo se permiten 'Consulta', 'Operacion', 'Procedimiento'.
-- Resultado Esperado: La inserción debe fallar con un error de violación de la 
-- restricción check en el campo 'tipo'.
--==========================================================================

-- ESTA INSERCIÓN DEBERÍA FALLAR
INSERT INTO Evento_Clinico (tipo, fecha, hora, ci_paciente, ci_medico, id_hospital, descripcion, costo) 
VALUES ('Cirugia', '2025-06-20', '10:00:00', 'V-10000001', 'V-12345678', 1, 'Tipo inválido', 100.00);


-- Verificar que los tipos válidos sí funcionan
INSERT INTO Evento_Clinico (tipo, fecha, hora, ci_paciente, ci_medico, id_hospital, descripcion, costo) 
VALUES ('Consulta', '2025-06-20', '12:00:00', 'V-10000003', 'V-34567890', 1, 'Consulta de control', 120.00);
ROLLBACK; -- Revertir la inserción exitosa



--==========================================================================
--PRUEBA 8.1: Listar hospitales con su número total de camas actualizadas
--==========================================================================
--Descripción: Consulta el nombre y el número total de camas para cada --hospital, reflejando las actualizaciones realizadas por el trigger.
--Resultado Esperado: Una lista de hospitales con sus num_camas actuales.
--========================================================================== 

SELECT id_hospital, nombre, num_camas FROM Hospital;

--========================================================================== 
--PRUEBA 8.2: Mostrar el inventario actual de un hospital específico
--========================================================================== 
--Descripción: Visualiza el inventario actual (nombre del insumo, cantidad y --stock mínimo) para un hospital particular (ej. Hospital Central - ID 1), --verificando los cambios por el uso y recepción de insumos. 
--Resultado Esperado: Una lista detallada del inventario del Hospital Central.
--========================================================================== 

SELECT
    H.nombre AS hospital,
    IM.nombre AS insumo,
    INV.cantidad,
    INV.stock_minimo
FROM Inventario INV
JOIN Hospital H ON INV.id_hospital = H.id_hospital
JOIN Insumo_Medico IM ON INV.id_insumo = IM.id_insumo
WHERE H.id_hospital = 1
ORDER BY IM.nombre;

--==========================================================================
--PRUEBA 8.3: Obtener todas las facturas y su estado de pago
--========================================================================== --Descripción: Muestra un resumen de todas las facturas, incluyendo detalles --del paciente, tipo de evento, fecha, total y su estado de pago final --(Pagada o Pendiente), para verificar el trigger de pagos de seguro.
--Resultado Esperado: Una lista completa de facturas con su estado --actualizado.
--==========================================================================

SELECT
    F.id_factura,
    P.nombre AS paciente_nombre,
    P.apellido AS paciente_apellido,
    EC.tipo AS tipo_evento,
    F.fecha_emision,
    F.total,
    F.estado,
    F.metodo_pago
FROM Factura F
JOIN Paciente P ON F.ci_paciente = P.ci_paciente
JOIN Evento_Clinico EC ON F.id_evento = EC.id_evento
ORDER BY F.id_factura;

--==========================================================================
--PRUEBA 8.4: Detalle de los pagos de seguro para una factura específica
--========================================================================== --Descripción: Proporciona un desglose de todos los pagos realizados por --seguro para una factura concreta (ej. Factura ID 12), mostrando el monto --cubierto y la fecha del pago.
--Resultado Esperado: Los detalles de los pagos de seguro para la factura --especificada
--==========================================================================

SELECT
    PS.id_pago,
    F.id_factura,
    ASG.numero_poliza,
    ASE.nombre AS aseguradora,
    PS.monto_cubierto,
    PS.fecha_pago
FROM Pago_Seguro PS
JOIN Factura F ON PS.id_factura = F.id_factura
JOIN Afiliacion_Seguro ASG ON PS.id_afiliacion = ASG.id_afiliacion
JOIN Aseguradora ASE ON ASG.id_aseguradora = ASE.id_aseguradora
WHERE F.id_factura = 12
ORDER BY PS.fecha_pago;
--========================================================================== 
--PRUEBA 8.5: Eventos clínicos y los insumos usados en ellos
--==========================================================================
--Descripción: Lista todos los eventos clínicos, junto con el paciente y --médico involucrados, y cualquier insumo médico que haya sido registrado --como usado en dicho evento.
--Resultado Esperado: Un reporte completo de eventos clínicos y el uso de --insumos.
--==========================================================================


SELECT
    EC.id_evento,
    EC.tipo AS tipo_evento,
    EC.fecha,
    P.nombre AS paciente_nombre,
    P.apellido AS paciente_apellido,
    PER.nombre AS medico_nombre,
    PER.apellido AS medico_apellido,
    IM.nombre AS insumo_usado,
    EUI.cantidad AS cantidad_usada
FROM Evento_Clinico EC
JOIN Paciente P ON EC.ci_paciente = P.ci_paciente
JOIN Personal PER ON EC.ci_medico = PER.ci_personal
LEFT JOIN Evento_Usa_Insumo EUI ON EC.id_evento = EUI.id_evento
LEFT JOIN Insumo_Medico IM ON EUI.id_insumo = IM.id_insumo
ORDER BY EC.id_evento, IM.nombre;

--==========================================================================
--PRUEBA 8.6: Encargos y su estado, incluyendo los ítems pedidos
--==========================================================================
--Descripción: Muestra un resumen de los encargos realizados a proveedores, --su estado actual y el detalle de los insumos solicitados en cada uno.
--Resultado Esperado: Un listado de encargos con sus detalles.
--==========================================================================

SELECT
    E.id_encargo,
    H.nombre AS hospital,
    PR.nombre_empresa AS proveedor,
    PER.nombre AS responsable_nombre,
    E.fecha_encargo,
    E.estado,
    IM.nombre AS insumo_encargado,
    ED.cantidad AS cantidad_encargada,
    ED.precio_unitario
FROM Encargo E
JOIN Hospital H ON E.id_hospital = H.id_hospital
JOIN Proveedor PR ON E.id_proveedor = PR.id_proveedor
JOIN Personal PER ON E.ci_responsable = PER.ci_personal
JOIN Encargo_Detalle ED ON E.id_encargo = ED.id_encargo
JOIN Insumo_Medico IM ON ED.id_insumo = IM.id_insumo
ORDER BY E.id_encargo, IM.nombre;

--=========================================================================  PRUEBA 8.7: Personal y sus horarios de trabajo
--==========================================================================
--Descripción: Obtiene los horarios de trabajo específicos para algunos --miembros del personal (ejemplo para Carlos Rodriguez y María González).
--Resultado Esperado: Los días y horas de entrada y salida para el personal --especificado.
--==========================================================================

SELECT
    P.nombre,
    P.apellido,
    HT.dia_semana,
    HT.hora_entrada,
    HT.hora_salida
FROM Personal P
JOIN Horario_Trabajo HT ON P.ci_personal = HT.ci_personal
WHERE P.ci_personal IN ('V-12345678', 'V-23456789')
ORDER BY P.apellido, HT.dia_semana;

--==========================================================================
--PRUEBA 8.8: Pacientes sin afiliación de seguro
--==========================================================================
--Descripción: Identifica a todos los pacientes que no tienen ninguna --afiliación de seguro registrada en la base de datos.
--Resultado Esperado: Una lista de pacientes sin seguro.
--========================================================================== 

SELECT
    P.ci_paciente,
    P.nombre,
    P.apellido,
    P.telefono
FROM Paciente P
LEFT JOIN Afiliacion_Seguro ASG ON P.ci_paciente = ASG.ci_paciente
WHERE ASG.id_afiliacion IS NULL;

--==========================================================================
-- PRUEBA 8.9: Insumos con stock bajo el mínimo
--========================================================================== 
--Descripción: Identifica todos los insumos médicos cuyo stock actual está por 
-- debajo del stock mínimo establecido, agrupados por hospital. Esta consulta es 
-- crítica para la gestión de inventarios y reabastecimiento.
-- Resultado Esperado: Lista de insumos que necesitan reabastecimiento urgente,
-- con información del déficit.
--==========================================================================

-- Consulta principal de insumos bajo mínimo
SELECT 
    H.nombre AS hospital,
    IM.nombre AS insumo,
    IM.tipo AS tipo_insumo,
    INV.cantidad AS stock_actual,
    INV.stock_minimo,
    (INV.stock_minimo - INV.cantidad) AS unidades_faltantes,
    CASE 
        WHEN INV.cantidad = 0 THEN 'SIN STOCK'
        WHEN INV.cantidad < INV.stock_minimo * 0.5 THEN 'CRÍTICO'
        ELSE 'BAJO'
    END AS nivel_urgencia
FROM Inventario INV
JOIN Hospital H ON INV.id_hospital = H.id_hospital
JOIN Insumo_Medico IM ON INV.id_insumo = IM.id_insumo
WHERE INV.cantidad < INV.stock_minimo
ORDER BY H.nombre, nivel_urgencia DESC, unidades_faltantes DESC;

-- Resumen por hospital del estado de inventario
SELECT 
    H.nombre AS hospital,
    COUNT(CASE WHEN INV.cantidad < INV.stock_minimo THEN 1 END) AS insumos_bajo_minimo,
    COUNT(CASE WHEN INV.cantidad = 0 THEN 1 END) AS insumos_sin_stock,
    COUNT(*) AS total_insumos,
    ROUND(
        COUNT(CASE WHEN INV.cantidad < INV.stock_minimo THEN 1 END)::NUMERIC / 
        COUNT(*)::NUMERIC * 100, 2
    ) AS porcentaje_bajo_minimo
FROM Inventario INV
JOIN Hospital H ON INV.id_hospital = H.id_hospital
GROUP BY H.id_hospital, H.nombre
ORDER BY porcentaje_bajo_minimo DESC;

-- Insumos críticos que necesitan encargo inmediato (0 stock o menos del 20% del mínimo)
SELECT 
    H.nombre AS hospital,
    IM.nombre AS insumo,
    IM.descripcion,
    INV.cantidad AS stock_actual,
    INV.stock_minimo,
    P.nombre_empresa AS proveedor_sugerido,
    PS.precio_unitario AS precio_ultima_compra
FROM Inventario INV
JOIN Hospital H ON INV.id_hospital = H.id_hospital
JOIN Insumo_Medico IM ON INV.id_insumo = IM.id_insumo
LEFT JOIN (
    -- Obtener el último proveedor usado para cada insumo
    SELECT DISTINCT ON (ed.id_insumo) 
        ed.id_insumo, 
        e.id_proveedor,
        ed.precio_unitario
    FROM Encargo_Detalle ed
    JOIN Encargo e ON ed.id_encargo = e.id_encargo
    ORDER BY ed.id_insumo, e.fecha_encargo DESC
) AS ultima_compra ON IM.id_insumo = ultima_compra.id_insumo
LEFT JOIN Proveedor P ON ultima_compra.id_proveedor = P.id_proveedor
LEFT JOIN Proveedor_Suministra PS ON IM.id_insumo = PS.id_insumo AND P.id_proveedor = PS.id_proveedor
WHERE INV.cantidad <= INV.stock_minimo * 0.2
ORDER BY H.nombre, INV.cantidad ASC;

--==========================================================================
-- PRUEBA 9.1: ON DELETE CASCADE (Departamento -> Habitaciones)
--==========================================================================
-- Descripción: Elimina un departamento y verifica que todas sus habitaciones 
-- asociadas también son eliminadas en cascada. Además verifica que el num_camas 
-- del hospital se actualiza correctamente.
-- Resultado Esperado: Las habitaciones del departamento eliminado no deben 
-- existir y el num_camas del hospital debe decrementarse apropiadamente.
--==========================================================================

-- Antes de la eliminación: verificar habitaciones del departamento a eliminar
SELECT H.nombre AS hospital, D.nombre AS departamento, HAB.numero_habitacion, HAB.num_camas
FROM Hospital H
JOIN Departamento D ON H.id_hospital = D.id_hospital
JOIN Habitacion HAB ON D.id_hospital = HAB.id_hospital AND D.numero_departamento = HAB.numero_departamento
WHERE D.id_hospital = 1 AND D.numero_departamento = 2; -- Departamento de Emergencias

-- Verificar num_camas actual del hospital
SELECT id_hospital, nombre, num_camas FROM Hospital WHERE id_hospital = 1;

-- Contar habitaciones antes de eliminar
SELECT COUNT(*) AS habitaciones_antes 
FROM Habitacion 
WHERE id_hospital = 1 AND numero_departamento = 2;

-- Eliminar el departamento (debería eliminar sus habitaciones en cascada)
DELETE FROM Departamento WHERE id_hospital = 1 AND numero_departamento = 2;

-- Después de la eliminación: verificar que no existen habitaciones
SELECT COUNT(*) AS habitaciones_despues 
FROM Habitacion 
WHERE id_hospital = 1 AND numero_departamento = 2;
-- Debe retornar 0

-- Verificar que el num_camas del hospital se actualizó
SELECT id_hospital, nombre, num_camas FROM Hospital WHERE id_hospital = 1;
-- El num_camas debe haber disminuido por la suma de camas de las habitaciones eliminadas

ROLLBACK; -- Revertir para mantener integridad de datos

--==========================================================================
-- PRUEBA 9.2: ON DELETE CASCADE (Hospital -> Departamentos -> Habitaciones)
--==========================================================================
-- Descripción: Elimina un hospital completo y verifica la eliminación en cascada
-- de todos sus departamentos y habitaciones.
-- Resultado Esperado: No deben existir departamentos ni habitaciones del 
-- hospital eliminado.
--==========================================================================

-- Crear un hospital temporal para la prueba
INSERT INTO Hospital (nombre, direccion) VALUES ('Hospital Temporal Test', 'Dirección Test');

-- Obtener el ID del hospital insertado
-- Asumiendo que es el último ID insertado, usar RETURNING o consultar
INSERT INTO Departamento (id_hospital, numero_departamento, nombre, piso, tipo) 
VALUES (currval('hospital_id_hospital_seq'), 1, 'Depto Test', '1', 'Medico');

INSERT INTO Habitacion (id_hospital, numero_departamento, numero_habitacion, tipo, num_camas, tarifa_dia, ocupada) 
VALUES (currval('hospital_id_hospital_seq'), 1, 'TEST-101', 'Individual', 2, 100.00, FALSE);

-- Verificar que existen
SELECT COUNT(*) AS deptos_antes FROM Departamento WHERE id_hospital = currval('hospital_id_hospital_seq');
SELECT COUNT(*) AS habs_antes FROM Habitacion WHERE id_hospital = currval('hospital_id_hospital_seq');

-- Eliminar el hospital
DELETE FROM Hospital WHERE id_hospital = currval('hospital_id_hospital_seq');

-- Verificar eliminación en cascada
SELECT COUNT(*) AS deptos_despues FROM Departamento WHERE id_hospital = currval('hospital_id_hospital_seq');
SELECT COUNT(*) AS habs_despues FROM Habitacion WHERE id_hospital = currval('hospital_id_hospital_seq');
-- Ambos deben retornar 0

ROLLBACK;





PRUEBA 8.9: Médicos por especialidad y hospital
Descripción: Muestra los médicos, su especialidad y el hospital/departamento donde trabajan actualmente.
Resultado Esperado: Una lista de médicos con su información de especialidad y ubicación.
=============================================================================
SELECT
    P.nombre AS medico_nombre,
    P.apellido AS medico_apellido,
    P.especialidad,
    H.nombre AS hospital_actual,
    D.nombre AS departamento_actual
FROM Personal P
JOIN Hospital H ON P.id_hospital_actual = H.id_hospital
JOIN Departamento D ON P.id_hospital_actual = D.id_hospital AND P.numero_departamento_actual = D.numero_departamento
WHERE P.tipo = 'Medico'
ORDER BY P.especialidad, P.apellido;
=============================================================================

PRUEBA 8.10: Habitaciones disponibles por tipo y hospital
Descripción: Lista las habitaciones que no están ocupadas, agrupadas por tipo de habitación y hospital, para mostrar la disponibilidad.
Resultado Esperado: Un listado de habitaciones disponibles.
=============================================================================
SELECT
    H.nombre AS hospital,
    HR.numero_habitacion,
    HR.tipo AS tipo_habitacion,
    HR.num_camas,
    HR.tarifa_dia
FROM Habitacion HR
JOIN Hospital H ON HR.id_hospital = H.id_hospital
WHERE HR.ocupada = FALSE
ORDER BY H.nombre, HR.tipo, HR.numero_habitacion;
============================================================================

PRUEBA 8.11: Proveedores y los insumos que suministran
Descripción: Muestra cada proveedor y los insumos médicos específicos que suministran, incluyendo el precio unitario de cada insumo.
Resultado Esperado: Una relación entre proveedores y los insumos que ofrecen.
============================================================================
SELECT
    PR.nombre_empresa AS proveedor_nombre,
    IM.nombre AS insumo_suministrado,
    PS.precio_unitario
FROM Proveedor_Suministra PS
JOIN Proveedor PR ON PS.id_proveedor = PR.id_proveedor
JOIN Insumo_Medico IM ON PS.id_insumo = IM.id_insumo
ORDER BY PR.nombre_empresa, IM.nombre;
=============================================================================


PRUEBA 8.12: Teléfonos de los departamentos
Descripción: Lista cada departamento y todos los números de teléfono asociados a él.
Resultado Esperado: Una lista de departamentos con sus teléfonos.
============================================================================
SELECT
    H.nombre AS hospital_nombre,
    D.nombre AS departamento_nombre,
    TD.telefono
FROM Telefono_Departamento TD
JOIN Departamento D ON TD.id_hospital = D.id_hospital AND TD.numero_departamento = D.numero_departamento
JOIN Hospital H ON D.id_hospital = H.id_hospital
ORDER BY H.nombre, D.nombre;
============================================================================

PRUEBA 8.13: Historial médico de un paciente específico
Descripción: Recupera todos los registros del historial médico para un paciente dado (ej. Paciente 'V-10000001').
Resultado Esperado: El historial médico completo del paciente.
============================================================================
SELECT
    P.nombre AS paciente_nombre,
    P.apellido AS paciente_apellido,
    HM.fecha,
    HM.tipo,
    HM.descripcion
FROM Historial_Medico HM
JOIN Paciente P ON HM.ci_paciente = P.ci_paciente
WHERE P.ci_paciente = 'V-10000001'
ORDER BY HM.fecha DESC;
============================================================================

PRUEBA 8.14: Ingresos totales por hospital
Descripción: Calcula el monto total (suma de los total de las facturas) generado por cada hospital.
Resultado Esperado: El ingreso total para cada hospital.
============================================================================
SELECT
    H.nombre AS hospital_nombre,
    SUM(F.total) AS ingresos_totales
FROM Factura F
JOIN Evento_Clinico EC ON F.id_evento = EC.id_evento
JOIN Hospital H ON EC.id_hospital = H.id_hospital
WHERE F.estado = 'Pagada' -- Considerar solo facturas pagadas
GROUP BY H.nombre
ORDER BY ingresos_totales DESC;
===========================================================================

PRUEBA 8.15: Conteo de eventos clínicos por tipo y médico
Descripción: Cuenta la cantidad de cada tipo de evento clínico (Consulta, Operación, Procedimiento) realizado por cada médico.
Resultado Esperado: Un desglose de la carga de trabajo por tipo de evento para cada médico.
=============================================================================



SELECT
    P.nombre AS medico_nombre,
    P.apellido AS medico_apellido,
    EC.tipo AS tipo_evento,
    COUNT(EC.id_evento) AS total_eventos
FROM Evento_Clinico EC
JOIN Personal P ON EC.ci_medico = P.ci_personal
GROUP BY P.nombre, P.apellido, EC.tipo
ORDER BY P.apellido, EC.tipo;
=============================================================================

PRUEBA 8.16: Insumos con cantidad actual por debajo del stock mínimo
Descripción: Identifica los insumos en cada hospital cuya cantidad en inventario es igual o inferior a su stock mínimo.
Resultado Esperado: Una lista de insumos que necesitan ser reabastecidos.
=============================================================================
SELECT
    H.nombre AS hospital,
    IM.nombre AS insumo,
    INV.cantidad,
    INV.stock_minimo
FROM Inventario INV
JOIN Hospital H ON INV.id_hospital = H.id_hospital
JOIN Insumo_Medico IM ON INV.id_insumo = IM.id_insumo
WHERE INV.cantidad <= INV.stock_minimo
ORDER BY H.nombre, IM.nombre;
=============================================================================

PRUEBA 8.17: Eventos clínicos por paciente en un rango de fechas
Descripción: Muestra todos los eventos clínicos de un paciente específico dentro de un rango de fechas dado.
Resultado Esperado: Los eventos del paciente en el periodo.
=============================================================================
SELECT
    P.nombre AS paciente_nombre,
    P.apellido AS paciente_apellido,
    EC.tipo,
    EC.fecha,
    EC.hora,
    EC.descripcion,
    EC.costo
FROM Evento_Clinico EC
JOIN Paciente P ON EC.ci_paciente = P.ci_paciente
WHERE P.ci_paciente = 'V-10000001'
  AND EC.fecha BETWEEN '2025-01-01' AND '2025-03-31'
ORDER BY EC.fecha, EC.hora;
=============================================================================


PRUEBA 8.18: Total facturado por aseguradora
Descripción: Calcula el monto total facturado que ha sido pagado por cada aseguradora.
Resultado Esperado: El total pagado por cada aseguradora.
=============================================================================
SELECT
    A.nombre AS aseguradora_nombre,
    SUM(PS.monto_cubierto) AS total_pagado_por_seguro
FROM Pago_Seguro PS
JOIN Afiliacion_Seguro AF ON PS.id_afiliacion = AF.id_afiliacion
JOIN Aseguradora A ON AF.id_aseguradora = A.id_aseguradora
GROUP BY A.nombre
ORDER BY total_pagado_por_seguro DESC;
=============================================================================

PRUEBA 8.19: Personal administrativo por hospital y departamento
Descripción: Lista todo el personal de tipo 'Administrativo' y el hospital/departamento al que están asignados.
Resultado Esperado: Un listado de personal administrativo con su ubicación.
=============================================================================
SELECT
    P.nombre,
    P.apellido,
    H.nombre AS hospital_asignado,
    D.nombre AS departamento_asignado,
    P.salario
FROM Personal P
LEFT JOIN Hospital H ON P.id_hospital_actual = H.id_hospital
LEFT JOIN Departamento D ON P.id_hospital_actual = D.id_hospital AND P.numero_departamento_actual = D.numero_departamento
WHERE P.tipo = 'Administrativo'
ORDER BY H.nombre, D.nombre, P.apellido;
=============================================================================

PRUEBA 8.20: Número de habitaciones y camas por departamento
Descripción: Cuenta el número de habitaciones y el total de camas para cada departamento en cada hospital.
Resultado Esperado: El conteo de habitaciones y camas por departamento.
=============================================================================
SELECT
    H.nombre AS hospital_nombre,
    D.nombre AS departamento_nombre,
    COUNT(HR.id_habitacion) AS total_habitaciones,
    SUM(HR.num_camas) AS total_camas_departamento
FROM Departamento D
JOIN Hospital H ON D.id_hospital = H.id_hospital
LEFT JOIN Habitacion HR ON D.id_hospital = HR.id_hospital AND D.numero_departamento = HR.numero_departamento
GROUP BY H.nombre, D.nombre
ORDER BY H.nombre, D.nombre;
=============================================================================


PRUEBA 9.1: Actualizar la dirección de un hospital
Descripción: Cambia la dirección de un hospital existente.
Resultado Esperado: La dirección del Hospital Central (ID 1) se actualizará.
=============================================================================
-- Antes de la actualización
SELECT id_hospital, nombre, direccion FROM Hospital WHERE id_hospital = 1;

-- Actualizar dirección
UPDATE Hospital
SET direccion = 'Nueva Av. Principal 456, Caracas'
WHERE id_hospital = 1;

-- Después de la actualización
SELECT id_hospital, nombre, direccion FROM Hospital WHERE id_hospital = 1;
=============================================================================

PRUEBA 9.2: Actualizar el nombre de un departamento
Descripción: Modifica el nombre de un departamento específico.
Resultado Esperado: El nombre del departamento de Cardiología del Hospital Central (ID 1, Depto. 2) se actualizará.
=============================================================================
-- Antes de la actualización
SELECT id_hospital, numero_departamento, nombre FROM Departamento WHERE id_hospital = 1 AND numero_departamento = 2;

-- Actualizar nombre del departamento
UPDATE Departamento
SET nombre = 'Cardiología Avanzada'
WHERE id_hospital = 1 AND numero_departamento = 2;

-- Después de la actualización
SELECT id_hospital, numero_departamento, nombre FROM Departamento WHERE id_hospital = 1 AND numero_departamento = 2;
============================================================================

PRUEBA 9.3: Actualizar la tarifa diaria de una habitación y su estado de ocupación
Descripción: Cambia la tarifa y el estado de ocupación de una habitación.
Resultado Esperado: La tarifa y el estado de la habitación '201' del Hospital Central (ID 1) se actualizarán.

-- Antes de la actualización
SELECT id_habitacion, numero_habitacion, tarifa_dia, ocupada FROM Habitacion WHERE id_habitacion = 3; -- Habitacion '201' de Hospital 1

-- Actualizar tarifa y estado de ocupación
UPDATE Habitacion
SET tarifa_dia = 200.00, ocupada = FALSE
WHERE id_habitacion = 3;

-- Después de la actualización
SELECT id_habitacion, numero_habitacion, tarifa_dia, ocupada FROM Habitacion WHERE id_habitacion = 3;



-- PRUEBA 9.4: Aumentar el salario de un médico
-- Descripción: Incrementa el salario de un médico específico.
-- Resultado Esperado: El salario del Dr. Carlos Rodriguez (CI 'V-12345678') se actualizará.
--=======================================================================
-- Antes de la actualización
SELECT ci_personal, nombre, apellido, salario FROM Personal WHERE ci_personal = 'V-12345678';

-- Aumentar salario
UPDATE Personal
SET salario = salario * 1.10 -- Aumenta el salario en un 10%
WHERE ci_personal = 'V-12345678';

-- Después de la actualización
SELECT ci_personal, nombre, apellido, salario FROM Personal WHERE ci_personal = 'V-12345678';
--=========================================================================


-- PRUEBA 9.5: Actualizar el teléfono de un paciente
-- Descripción: Modifica el número de teléfono de un paciente. 
Resultado Esperado: El teléfono del paciente Juan Pérez (CI 'V-10000001') se actualizará.

-- Antes de la actualización
SELECT ci_paciente, nombre, apellido, telefono FROM Paciente WHERE ci_paciente = 'V-10000001';

-- Actualizar teléfono del paciente
UPDATE Paciente
SET telefono = '0412-9988776'
WHERE ci_paciente = 'V-10000001';

-- Después de la actualización
SELECT ci_paciente, nombre, apellido, telefono FROM Paciente WHERE ci_paciente = 'V-10000001';


-- PRUEBA 9.6: Actualizar el teléfono de una aseguradora
-- Descripción: Modifica el número de teléfono de una aseguradora.
-- Resultado Esperado: El teléfono de Seguros Caracas (ID 1) se actualizará.

-- Antes de la actualización
SELECT id_aseguradora, nombre, telefono FROM Aseguradora WHERE id_aseguradora = 1;

-- Actualizar teléfono de la aseguradora
UPDATE Aseguradora
SET telefono = '0212-9990000'
WHERE id_aseguradora = 1;

-- Después de la actualización
SELECT id_aseguradora, nombre, telefono FROM Aseguradora WHERE id_aseguradora = 1;


-- PRUEBA 9.7: Actualizar la descripción de un insumo médico
-- Descripción: Cambia la descripción de un insumo médico.
-- Resultado Esperado: La descripción de Paracetamol 500mg (ID 1) se actualizará.

-- Antes de la actualización
SELECT id_insumo, nombre, descripcion FROM Insumo_Medico WHERE id_insumo = 1;

-- Actualizar descripción del insumo
UPDATE Insumo_Medico
SET descripcion = 'Analgésico y antipirético de acción rápida'
WHERE id_insumo = 1;

-- Después de la actualización
SELECT id_insumo, nombre, descripcion FROM Insumo_Medico WHERE id_insumo = 1;


-- PRUEBA 9.8: Actualizar el precio unitario de un insumo suministrado por un proveedor
-- Descripción: Modifica el precio al que un proveedor suministra un insumo específico.
-- Resultado Esperado: El precio unitario del Paracetamol (ID 1) suministrado por Distribuidora Médica Central (ID 1) se actualizará.

-- Antes de la actualización
SELECT id_proveedor, id_insumo, precio_unitario FROM Proveedor_Suministra WHERE id_proveedor = 1 AND id_insumo = 1;

-- Actualizar precio unitario
UPDATE Proveedor_Suministra
SET precio_unitario = 26.50
WHERE id_proveedor = 1 AND id_insumo = 1;

-- Después de la actualización
SELECT id_proveedor, id_insumo, precio_unitario FROM Proveedor_Suministra WHERE id_proveedor = 1 AND id_insumo = 1;



-- PRUEBA 9.9: Actualizar el stock mínimo de un insumo en el inventario de un hospital
-- Descripción: Ajusta el nivel de stock mínimo para un insumo en un hospital.
-- Resultado Esperado: El stock mínimo de Paracetamol (ID 1) en el Hospital Central (ID 1) se actualizará.

-- Antes de la actualización
SELECT id_hospital, id_insumo, stock_minimo FROM Inventario WHERE id_hospital = 1 AND id_insumo = 1;

-- Actualizar stock mínimo
UPDATE Inventario
SET stock_minimo = 25
WHERE id_hospital = 1 AND id_insumo = 1;

-- Después de la actualización
SELECT id_hospital, id_insumo, stock_minimo FROM Inventario WHERE id_hospital = 1 AND id_insumo = 1;




-- PRUEBA 9.10: Cambiar el estado de un encargo pendiente a cancelado
-- Descripción: Modifica el estado de un encargo que estaba pendiente a cancelado.
-- Resultado Esperado: El estado del encargo ID 8 cambiará a 'Cancelado'.
-- Nota: Este cambio NO activará el trigger de inventario trg_recepcion_encargo porque el estado no cambia a 'Recibido'.

-- Antes de la actualización
SELECT id_encargo, estado FROM Encargo WHERE id_encargo = 8;

-- Actualizar estado a 'Cancelado'
UPDATE Encargo
SET estado = 'Cancelado'
WHERE id_encargo = 8;

-- Después de la actualización
SELECT id_encargo, estado FROM Encargo WHERE id_encargo = 8;


-- PRUEBA 9.11: Actualizar las observaciones de un evento clínico
-- Descripción: Agrega o modifica las observaciones de un evento clínico.
-- Resultado Esperado: Las observaciones del evento clínico ID 1 se actualizarán.

-- Antes de la actualización
SELECT id_evento, descripcion, observaciones FROM Evento_Clinico WHERE id_evento = 1;

-- Actualizar observaciones
UPDATE Evento_Clinico
SET observaciones = 'Paciente respondió bien al tratamiento inicial.'
WHERE id_evento = 1;

-- Después de la actualización
SELECT id_evento, descripcion, observaciones FROM Evento_Clinico WHERE id_evento = 1;

