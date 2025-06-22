-- A. Obtener los nombres de los pacientes asegurados atendidos por médicos que han tenido más de un cargo en el hospital

SELECT DISTINCT
    p.nombre,
    p.apellido
FROM
    Paciente p
JOIN
    -- Unimos con los eventos clínicos para saber quién atendió al paciente
    Evento_Clinico ec ON p.ci_paciente = ec.ci_paciente
WHERE
    -- Filtramos para que el paciente tenga un seguro activo
    p.ci_paciente IN (
        SELECT DISTINCT ci_paciente FROM Afiliacion_Seguro
    )
AND
    -- Filtramos para que el médico que lo atendió cumpla la condición de "más de un cargo"
    ec.ci_medico IN (
        -- Subconsulta: Selecciona médicos que han trabajado en más de un hospital
        SELECT ci_medico
        FROM Evento_Clinico
        GROUP BY ci_medico
        HAVING COUNT(DISTINCT id_hospital) > 1
    );




-- B. Listar los hospitales que hayan facturado más de $1000

SELECT
    h.nombre AS nombre_hospital,
    SUM(f.total) AS facturacion_total
FROM
    Factura f
JOIN
    Evento_Clinico ec ON f.id_evento = ec.id_evento
JOIN
    Hospital h ON ec.id_hospital = h.id_hospital
GROUP BY
    h.id_hospital, h.nombre
HAVING
    SUM(f.total) > 1000
ORDER BY
    facturacion_total DESC;



-- C. Top 2 de médicos con más procedimientos realizados que el promedio

WITH ConteoProcedimientos AS (
    -- Paso 1: Contar los procedimientos (eventos) por cada médico
    SELECT
        ci_medico,
        COUNT(id_evento) as cantidad_procedimientos
    FROM
        Evento_Clinico
    GROUP BY
        ci_medico
),
PromedioGeneral AS (
    -- Paso 2: Calcular el promedio de procedimientos de todos los médicos
    SELECT AVG(cantidad_procedimientos) as promedio
    FROM ConteoProcedimientos
)
-- Paso 3: Seleccionar los médicos que superan el promedio
SELECT
    per.nombre,
    per.apellido,
    cp.cantidad_procedimientos
FROM
    ConteoProcedimientos cp
JOIN
    Personal per ON cp.ci_medico = per.ci_personal
WHERE
    cp.cantidad_procedimientos > (SELECT promedio FROM PromedioGeneral)
ORDER BY
    cp.cantidad_procedimientos DESC
LIMIT 2;


-- D. Listar los trabajadores que han sido responsables de encargos a proveedores de “Valencia”

SELECT DISTINCT
    p.nombre,
    p.apellido,
    p.ci_personal
FROM
    Personal p
JOIN
    Encargo e ON p.ci_personal = e.ci_responsable
JOIN
    Proveedor prov ON e.id_proveedor = prov.id_proveedor
WHERE
    prov.ciudad = 'Valencia';


-- E. Listar los procedimientos que necesiten instrumental que ha sido encargado en el último mes

SELECT DISTINCT
    ec.id_evento,
    ec.tipo,
    ec.descripcion,
    ec.fecha,
    ec.hora
FROM
    Evento_Clinico ec
JOIN
    Evento_Usa_Insumo eui ON ec.id_evento = eui.id_evento
WHERE
    eui.id_insumo IN (
        -- Subconsulta: Obtiene el ID de los insumos de tipo 'Instrumental'
        -- que fueron encargados en el último mes.
        SELECT
            ed.id_insumo
        FROM
            Encargo_Detalle ed
        JOIN
            Encargo e ON ed.id_encargo = e.id_encargo
        JOIN
            Insumo_Medico im ON ed.id_insumo = im.id_insumo
        WHERE
            im.tipo = 'Instrumental'
            AND e.fecha_encargo >= (CURRENT_DATE - INTERVAL '1 month')
    );


-- F. Departamentos que tengan más horas de trabajo que el promedio

WITH HorasPorDepartamento AS (
    -- Paso 1: Calcular la suma de horas de trabajo para cada departamento
    SELECT
        p.id_hospital_actual,
        p.numero_departamento_actual,
        SUM(ht.hora_salida - ht.hora_entrada) AS total_horas_semanales
    FROM
        Horario_Trabajo ht
    JOIN
        Personal p ON ht.ci_personal = p.ci_personal
    WHERE
        p.id_hospital_actual IS NOT NULL AND p.numero_departamento_actual IS NOT NULL
    GROUP BY
        p.id_hospital_actual, p.numero_departamento_actual
),
PromedioHorasGeneral AS (
    -- Paso 2: Calcular el promedio de las horas totales de todos los departamentos
    SELECT AVG(total_horas_semanales) as promedio_horas
    FROM HorasPorDepartamento
)
-- Paso 3: Seleccionar los departamentos que superan el promedio
SELECT
    d.nombre AS nombre_departamento,
    h.nombre AS nombre_hospital,
    hpd.total_horas_semanales
FROM
    HorasPorDepartamento hpd
JOIN
    Departamento d ON hpd.id_hospital_actual = d.id_hospital AND hpd.numero_departamento_actual = d.numero_departamento
JOIN
    Hospital h ON hpd.id_hospital_actual = h.id_hospital
WHERE
    hpd.total_horas_semanales > (SELECT promedio_horas FROM PromedioHorasGeneral)
ORDER BY
    hpd.total_horas_semanales DESC;
