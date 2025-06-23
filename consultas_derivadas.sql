-- =====================================================================
-- CONSULTAS PARA ATRIBUTOS DERIVADOS (Consideración B)
-- Hay varias consultas aqui que como tal ya se almacenan en la base de 
-- por lo que como tal no es necesario hacerlo en si (amenos que se requiera
-- de reducir el tamaño/peso de la base de datos), pero en este caso tambien
-- es util para revisar la integridad de los datos.
-- =====================================================================

-- 1. Calcular la EDAD de los pacientes (derivado de fecha_nacimiento)
SELECT 
    ci_paciente,
    nombre,
    apellido,
    fecha_nacimiento,
    EXTRACT(YEAR FROM AGE(fecha_nacimiento)) AS edad
FROM Paciente
ORDER BY edad DESC;

-- 2. Calcular el NÚMERO DE CAMAS por hospital (derivado de habitaciones)
SELECT 
    h.id_hospital,
    h.nombre AS hospital_nombre,
    SUM(hab.num_camas) AS num_camas_calculado,
    h.num_camas AS num_camas_almacenado,
    CASE 
        WHEN SUM(hab.num_camas) = h.num_camas THEN 'Correcto'
        ELSE 'Desincronizado'
    END AS estado_sincronizacion
FROM Hospital h
LEFT JOIN Habitacion hab ON h.id_hospital = hab.id_hospital
GROUP BY h.id_hospital, h.nombre, h.num_camas
ORDER BY h.id_hospital;

-- 3. Calcular el TOTAL de facturas (derivado de subtotal + iva)
SELECT 
    id_factura,
    subtotal,
    iva,
    total AS total_almacenado,
    (subtotal + iva) AS total_calculado,
    CASE 
        WHEN ABS(total - (subtotal + iva)) < 0.01 THEN 'Correcto'
        ELSE 'Error de cálculo'
    END AS estado_calculo
FROM Factura
ORDER BY id_factura;

-- 4. Calcular TIEMPO DE TRABAJO por empleado (derivado de horarios)
SELECT 
    p.ci_personal,
    p.nombre,
    p.apellido,
    p.tipo,
    COUNT(ht.dia_semana) AS dias_trabajo,
    SUM(
        EXTRACT(HOUR FROM ht.hora_salida) - EXTRACT(HOUR FROM ht.hora_entrada)
    ) AS horas_semanales_total,
    ROUND(
        SUM(
            EXTRACT(HOUR FROM ht.hora_salida) - EXTRACT(HOUR FROM ht.hora_entrada)
        ) / COUNT(ht.dia_semana), 
        2
    ) AS horas_promedio_por_dia
FROM Personal p
LEFT JOIN Horario_Trabajo ht ON p.ci_personal = ht.ci_personal
GROUP BY p.ci_personal, p.nombre, p.apellido, p.tipo
ORDER BY horas_semanales_total DESC;

-- 5. Calcular AÑOS DE EXPERIENCIA del personal (derivado de fecha_contratacion)
SELECT 
    ci_personal,
    nombre,
    apellido,
    fecha_contratacion,
    EXTRACT(YEAR FROM AGE(fecha_contratacion)) AS experience_years, --lo puse en ingles pq en español queda... bueno, gracioso.
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(fecha_contratacion)) < 1 THEN 'Novato'
        WHEN EXTRACT(YEAR FROM AGE(fecha_contratacion)) < 5 THEN 'Junior'
        WHEN EXTRACT(YEAR FROM AGE(fecha_contratacion)) < 10 THEN 'Senior'
        ELSE 'Veterano'
    END AS categoria_experiencia
FROM Personal
ORDER BY experience_years DESC;

-- 6. Calcular STOCK DISPONIBLE vs STOCK CRÍTICO (derivado de inventario)
SELECT 
    h.nombre AS hospital_nombre,
    im.nombre AS insumo_nombre,
    inv.cantidad AS stock_actual,
    inv.stock_minimo,
    (inv.cantidad - inv.stock_minimo) AS diferencia,
    ROUND(
        (inv.cantidad * 100.0 / inv.stock_minimo), 
        2
    ) AS porcentaje_del_minimo,
    CASE 
        WHEN inv.cantidad < inv.stock_minimo THEN 'CRÍTICO'
        WHEN inv.cantidad < (inv.stock_minimo * 1.5) THEN 'BAJO'
        WHEN inv.cantidad < (inv.stock_minimo * 3) THEN 'NORMAL'
        ELSE 'ALTO'
    END AS nivel_stock
FROM Inventario inv
JOIN Hospital h ON inv.id_hospital = h.id_hospital
JOIN Insumo_Medico im ON inv.id_insumo = im.id_insumo
ORDER BY h.nombre, nivel_stock, diferencia;

-- 7. Calcular COSTO TOTAL por paciente (derivado de facturas)
SELECT 
    p.ci_paciente,
    p.nombre,
    p.apellido,
    COUNT(f.id_factura) AS numero_facturas,
    SUM(f.total) AS gasto_total,
    AVG(f.total) AS gasto_promedio_por_factura,
    MAX(f.total) AS factura_mas_cara,
    MIN(f.total) AS factura_mas_barata,
    CASE 
        WHEN EXISTS (SELECT 1 FROM Afiliacion_Seguro a WHERE a.ci_paciente = p.ci_paciente) 
        THEN 'Con Seguro' 
        ELSE 'Sin Seguro' 
    END AS estado_seguro
FROM Paciente p
LEFT JOIN Factura f ON p.ci_paciente = f.ci_paciente
GROUP BY p.ci_paciente, p.nombre, p.apellido
HAVING COUNT(f.id_factura) > 0
ORDER BY gasto_total DESC;

-- 8. Calcular UTILIZACIÓN de habitaciones por hospital (derivado de ocupación)
SELECT 
    h.nombre AS hospital_nombre,
    COUNT(hab.id_habitacion) AS total_habitaciones,
    SUM(CASE WHEN hab.ocupada = TRUE THEN 1 ELSE 0 END) AS habitaciones_ocupadas,
    SUM(CASE WHEN hab.ocupada = FALSE THEN 1 ELSE 0 END) AS habitaciones_libres,
    ROUND(
        (SUM(CASE WHEN hab.ocupada = TRUE THEN 1 ELSE 0 END) * 100.0) / COUNT(hab.id_habitacion), 
        2
    ) AS porcentaje_ocupacion,
    SUM(hab.num_camas) AS total_camas,
    SUM(CASE WHEN hab.ocupada = TRUE THEN hab.num_camas ELSE 0 END) AS camas_ocupadas
FROM Hospital h
LEFT JOIN Habitacion hab ON h.id_hospital = hab.id_hospital
GROUP BY h.id_hospital, h.nombre
ORDER BY porcentaje_ocupacion DESC;
