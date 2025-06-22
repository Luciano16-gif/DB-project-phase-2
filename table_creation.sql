
-- Limpieza inicial
DROP TABLE IF EXISTS Evento_Usa_Insumo CASCADE;
DROP TABLE IF EXISTS Pago_Seguro CASCADE;
DROP TABLE IF EXISTS Afiliacion_Seguro CASCADE;
DROP TABLE IF EXISTS Factura CASCADE;
DROP TABLE IF EXISTS Evento_Clinico CASCADE;
DROP TABLE IF EXISTS Inventario CASCADE;
DROP TABLE IF EXISTS Encargo_Detalle CASCADE;
DROP TABLE IF EXISTS Encargo CASCADE;
DROP TABLE IF EXISTS Proveedor_Suministra CASCADE;
DROP TABLE IF EXISTS Proveedor CASCADE;
DROP TABLE IF EXISTS Insumo_Medico CASCADE;
DROP TABLE IF EXISTS Historial_Medico CASCADE;
DROP TABLE IF EXISTS Paciente CASCADE;
DROP TABLE IF EXISTS Horario_Trabajo CASCADE;
DROP TABLE IF EXISTS Telefono_Personal CASCADE;
DROP TABLE IF EXISTS Personal CASCADE;
DROP TABLE IF EXISTS Habitacion CASCADE;
DROP TABLE IF EXISTS Telefono_Departamento CASCADE;
DROP TABLE IF EXISTS Departamento CASCADE;
DROP TABLE IF EXISTS Hospital CASCADE;
DROP TABLE IF EXISTS Aseguradora CASCADE;

-- =====================================================================
-- CREACIÓN DE TABLAS
-- =====================================================================

-- 1. Hospital (Entidad Fuerte)
CREATE TABLE Hospital (
    id_hospital SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    direccion TEXT NOT NULL,
    num_camas INTEGER DEFAULT 0
);

-- 2. Departamento (Entidad Débil de Hospital)
CREATE TABLE Departamento (
    id_hospital INTEGER NOT NULL,
    numero_departamento INTEGER NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    piso VARCHAR(10) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Medico', 'Administrativo', 'Apoyo')),
    PRIMARY KEY (id_hospital, numero_departamento),
    FOREIGN KEY (id_hospital) REFERENCES Hospital(id_hospital) ON DELETE CASCADE
);

-- 3. Teléfonos de Departamento (Multivaluado)
CREATE TABLE Telefono_Departamento (
    id_hospital INTEGER NOT NULL,
    numero_departamento INTEGER NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_hospital, numero_departamento, telefono),
    FOREIGN KEY (id_hospital, numero_departamento) 
        REFERENCES Departamento(id_hospital, numero_departamento) ON DELETE CASCADE
);

-- 4. Habitación
CREATE TABLE Habitacion (
    id_habitacion SERIAL PRIMARY KEY,
    id_hospital INTEGER NOT NULL,
    numero_departamento INTEGER NOT NULL,
    numero_habitacion VARCHAR(20) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Individual', 'Doble', 'Suite')),
    num_camas INTEGER NOT NULL CHECK (num_camas > 0),
    tarifa_dia DECIMAL(10,2) NOT NULL CHECK (tarifa_dia > 0),
    ocupada BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_hospital, numero_departamento) 
        REFERENCES Departamento(id_hospital, numero_departamento) ON DELETE CASCADE,
    UNIQUE(id_hospital, numero_habitacion)
);

-- 5. Personal (Unificado con tipo)
CREATE TABLE Personal (
    ci_personal VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    direccion TEXT NOT NULL,
    fecha_contratacion DATE NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Medico', 'Administrativo')),
    especialidad VARCHAR(100), -- Solo para médicos
    id_hospital_actual INTEGER,
    numero_departamento_actual INTEGER,
    salario DECIMAL(10,2) CHECK (salario > 0),
    FOREIGN KEY (id_hospital_actual, numero_departamento_actual) 
        REFERENCES Departamento(id_hospital, numero_departamento) ON DELETE SET NULL
);

-- 6. Teléfonos de Personal (Multivaluado)
CREATE TABLE Telefono_Personal (
    ci_personal VARCHAR(20) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    PRIMARY KEY (ci_personal, telefono),
    FOREIGN KEY (ci_personal) REFERENCES Personal(ci_personal) ON DELETE CASCADE
);

-- 7. Horarios de Trabajo
CREATE TABLE Horario_Trabajo (
    id_horario SERIAL PRIMARY KEY,
    ci_personal VARCHAR(20) NOT NULL,
    dia_semana VARCHAR(10) NOT NULL CHECK (dia_semana IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')),
    hora_entrada TIME NOT NULL,
    hora_salida TIME NOT NULL,
    FOREIGN KEY (ci_personal) REFERENCES Personal(ci_personal) ON DELETE CASCADE
);

-- 8. Paciente
CREATE TABLE Paciente (
    ci_paciente VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    sexo CHAR(1) CHECK (sexo IN ('M', 'F')),
    direccion TEXT,
    telefono VARCHAR(20),
    contacto_emergencia VARCHAR(100),
    telefono_emergencia VARCHAR(20),
    responsable_nombre VARCHAR(100), -- Opcional para menores
    responsable_telefono VARCHAR(20)
);

-- 9. Historial Médico (Multivaluado)
CREATE TABLE Historial_Medico (
    id_historial SERIAL PRIMARY KEY,
    ci_paciente VARCHAR(20) NOT NULL,
    fecha DATE NOT NULL,
    tipo VARCHAR(50) NOT NULL, -- 'Alergia', 'Enfermedad Cronica', 'Cirugia', etc.
    descripcion TEXT NOT NULL,
    FOREIGN KEY (ci_paciente) REFERENCES Paciente(ci_paciente) ON DELETE CASCADE
);

-- 10. Aseguradora
CREATE TABLE Aseguradora (
    id_aseguradora SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    direccion TEXT,
    telefono VARCHAR(20)
);

-- 11. Afiliación Seguro
CREATE TABLE Afiliacion_Seguro (
    id_afiliacion SERIAL PRIMARY KEY,
    ci_paciente VARCHAR(20) NOT NULL,
    id_aseguradora INTEGER NOT NULL,
    numero_poliza VARCHAR(50) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    monto_cobertura DECIMAL(12,2),
    FOREIGN KEY (ci_paciente) REFERENCES Paciente(ci_paciente),
    FOREIGN KEY (id_aseguradora) REFERENCES Aseguradora(id_aseguradora),
    UNIQUE(numero_poliza)
);

-- 12. Insumo Médico (Simplificado)
CREATE TABLE Insumo_Medico (
    id_insumo SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('Medicamento', 'Instrumental', 'Suministro')),
    subtipo VARCHAR(50), -- 'Tabletas', 'Inyectable', 'Gasas', etc.
    unidad_medida VARCHAR(20), -- 'Unidad', 'Caja', 'Ml', etc.
    fecha_vencimiento DATE -- Solo para medicamentos
);

-- 13. Proveedor
CREATE TABLE Proveedor (
    id_proveedor SERIAL PRIMARY KEY,
    nombre_empresa VARCHAR(150) NOT NULL UNIQUE,
    direccion TEXT,
    ciudad VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100)
);

-- 14. Proveedor Suministra (M:N)
CREATE TABLE Proveedor_Suministra (
    id_proveedor INTEGER NOT NULL,
    id_insumo INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario > 0),
    PRIMARY KEY (id_proveedor, id_insumo),
    FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor),
    FOREIGN KEY (id_insumo) REFERENCES Insumo_Medico(id_insumo)
);

-- 15. Inventario (M:N)
CREATE TABLE Inventario (
    id_hospital INTEGER NOT NULL,
    id_insumo INTEGER NOT NULL,
    cantidad INTEGER NOT NULL DEFAULT 0 CHECK (cantidad >= 0),
    stock_minimo INTEGER DEFAULT 10,
    PRIMARY KEY (id_hospital, id_insumo),
    FOREIGN KEY (id_hospital) REFERENCES Hospital(id_hospital),
    FOREIGN KEY (id_insumo) REFERENCES Insumo_Medico(id_insumo)
);

-- 16. Encargo
CREATE TABLE Encargo (
    id_encargo SERIAL PRIMARY KEY,
    id_hospital INTEGER NOT NULL,
    id_proveedor INTEGER NOT NULL,
    ci_responsable VARCHAR(20) NOT NULL,
    fecha_encargo DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_recepcion DATE,
    estado VARCHAR(20) DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Recibido', 'Cancelado')),
    FOREIGN KEY (id_hospital) REFERENCES Hospital(id_hospital),
    FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor),
    FOREIGN KEY (ci_responsable) REFERENCES Personal(ci_personal)
);

-- 17. Detalle del Encargo
CREATE TABLE Encargo_Detalle (
    id_encargo INTEGER NOT NULL,
    id_insumo INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario > 0),
    PRIMARY KEY (id_encargo, id_insumo),
    FOREIGN KEY (id_encargo) REFERENCES Encargo(id_encargo) ON DELETE CASCADE,
    FOREIGN KEY (id_insumo) REFERENCES Insumo_Medico(id_insumo)
);

-- 18. Evento Clínico (Unificado)
CREATE TABLE Evento_Clinico (
    id_evento SERIAL PRIMARY KEY,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Consulta', 'Operacion', 'Procedimiento')),
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    ci_paciente VARCHAR(20) NOT NULL,
    ci_medico VARCHAR(20) NOT NULL,
    id_hospital INTEGER NOT NULL,
    id_habitacion INTEGER, -- Solo para operaciones
    descripcion TEXT,
    observaciones TEXT,
    costo DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (ci_paciente) REFERENCES Paciente(ci_paciente),
    FOREIGN KEY (ci_medico) REFERENCES Personal(ci_personal),
    FOREIGN KEY (id_hospital) REFERENCES Hospital(id_hospital),
    FOREIGN KEY (id_habitacion) REFERENCES Habitacion(id_habitacion) ON DELETE SET NULL
);

-- 19. Evento Usa Insumo (M:N)
CREATE TABLE Evento_Usa_Insumo (
    id_evento INTEGER NOT NULL,
    id_insumo INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    PRIMARY KEY (id_evento, id_insumo),
    FOREIGN KEY (id_evento) REFERENCES Evento_Clinico(id_evento),
    FOREIGN KEY (id_insumo) REFERENCES Insumo_Medico(id_insumo)
);

-- 20. Factura
CREATE TABLE Factura (
    id_factura SERIAL PRIMARY KEY,
    id_evento INTEGER NOT NULL,
    ci_paciente VARCHAR(20) NOT NULL,
    fecha_emision DATE NOT NULL DEFAULT CURRENT_DATE,
    subtotal DECIMAL(10,2) NOT NULL,
    iva DECIMAL(10,2) NOT NULL DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    estado VARCHAR(20) DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Pagada', 'Anulada')),
    metodo_pago VARCHAR(20) CHECK (metodo_pago IN ('Efectivo', 'Tarjeta', 'Seguro', 'Mixto')),
    FOREIGN KEY (id_evento) REFERENCES Evento_Clinico(id_evento),
    FOREIGN KEY (ci_paciente) REFERENCES Paciente(ci_paciente)
);

-- 21. Pago Seguro
CREATE TABLE Pago_Seguro (
    id_pago SERIAL PRIMARY KEY,
    id_factura INTEGER NOT NULL,
    id_afiliacion INTEGER NOT NULL,
    monto_cubierto DECIMAL(10,2) NOT NULL CHECK (monto_cubierto > 0),
    fecha_pago DATE NOT NULL DEFAULT CURRENT_DATE,
    numero_autorizacion VARCHAR(50),
    FOREIGN KEY (id_factura) REFERENCES Factura(id_factura),
    FOREIGN KEY (id_afiliacion) REFERENCES Afiliacion_Seguro(id_afiliacion)
);

-- =====================================================================
-- TRIGGERS
-- =====================================================================

-- Trigger 1: Actualizar número de camas del hospital
CREATE OR REPLACE FUNCTION actualizar_num_camas()
RETURNS TRIGGER AS $$
DECLARE
    v_id_hospital INTEGER;
    v_num_camas_old INTEGER := 0;
    v_num_camas_new INTEGER := 0;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_id_hospital := OLD.id_hospital;
        v_num_camas_old := OLD.num_camas;
    ELSE -- INSERT or UPDATE
        v_id_hospital := NEW.id_hospital;
        v_num_camas_new := NEW.num_camas;
        IF TG_OP = 'UPDATE' THEN
            v_num_camas_old := OLD.num_camas;
        END IF;
    END IF;

    UPDATE Hospital
    SET num_camas = num_camas - v_num_camas_old + v_num_camas_new
    WHERE id_hospital = v_id_hospital;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Se optimiza el trigger para que no haga un SUM completo cada vez
-- sino que sume y reste las diferencias, es mucho más eficiente.
CREATE TRIGGER trg_actualizar_camas
AFTER INSERT OR UPDATE OR DELETE ON Habitacion
FOR EACH ROW EXECUTE FUNCTION actualizar_num_camas();

-- Trigger 2: Actualizar inventario cuando se usa insumo (CORREGIDO)
CREATE OR REPLACE FUNCTION actualizar_inventario_uso()
RETURNS TRIGGER AS $$
DECLARE
    v_id_hospital INTEGER;
    v_cantidad_actual INTEGER;
    v_nombre_insumo VARCHAR(150);
    v_nombre_hospital VARCHAR(150);
BEGIN
    -- Obtener el hospital del evento
    SELECT id_hospital INTO v_id_hospital
    FROM Evento_Clinico
    WHERE id_evento = NEW.id_evento;
    
    -- Obtener información adicional para el mensaje de error
    SELECT cantidad INTO v_cantidad_actual
    FROM Inventario
    WHERE id_hospital = v_id_hospital AND id_insumo = NEW.id_insumo;
    
    SELECT nombre INTO v_nombre_insumo
    FROM Insumo_Medico
    WHERE id_insumo = NEW.id_insumo;
    
    SELECT nombre INTO v_nombre_hospital
    FROM Hospital
    WHERE id_hospital = v_id_hospital;
    
    -- Verificar stock disponible
    IF v_cantidad_actual IS NULL OR v_cantidad_actual < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente del insumo % (ID: %) en el hospital % (ID: %). Stock actual: %, Cantidad solicitada: %', 
            v_nombre_insumo, NEW.id_insumo, v_nombre_hospital, v_id_hospital, 
            COALESCE(v_cantidad_actual, 0), NEW.cantidad;
    END IF;
    
    -- Actualizar inventario
    UPDATE Inventario
    SET cantidad = cantidad - NEW.cantidad
    WHERE id_hospital = v_id_hospital AND id_insumo = NEW.id_insumo;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_uso_insumo
AFTER INSERT ON Evento_Usa_Insumo
FOR EACH ROW EXECUTE FUNCTION actualizar_inventario_uso();


-- Trigger 3: Actualizar inventario cuando se recibe encargo
CREATE OR REPLACE FUNCTION actualizar_inventario_recepcion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estado = 'Recibido' AND OLD.estado != 'Recibido' THEN
        -- Actualizar inventario para cada item del encargo
        INSERT INTO Inventario (id_hospital, id_insumo, cantidad)
        SELECT NEW.id_hospital, ed.id_insumo, ed.cantidad
        FROM Encargo_Detalle ed
        WHERE ed.id_encargo = NEW.id_encargo
        ON CONFLICT (id_hospital, id_insumo) 
        DO UPDATE SET cantidad = Inventario.cantidad + EXCLUDED.cantidad;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_recepcion_encargo
AFTER UPDATE ON Encargo
FOR EACH ROW EXECUTE FUNCTION actualizar_inventario_recepcion();

-- Trigger 4: Actualizar estado de factura cuando se paga con seguro
CREATE OR REPLACE FUNCTION actualizar_estado_factura()
RETURNS TRIGGER AS $$
DECLARE
    v_total_factura DECIMAL(10,2);
    v_total_pagado_seguro DECIMAL(10,2);
BEGIN
    -- Obtener total de la factura
    SELECT total INTO v_total_factura
    FROM Factura
    WHERE id_factura = NEW.id_factura;
    
    -- Obtener total pagado por seguros para esta factura
    SELECT COALESCE(SUM(monto_cubierto), 0) INTO v_total_pagado_seguro
    FROM Pago_Seguro
    WHERE id_factura = NEW.id_factura;
    
    -- Si está totalmente pagada, actualizar estado
    IF v_total_pagado_seguro >= v_total_factura THEN
        UPDATE Factura
        SET estado = 'Pagada',
            metodo_pago = 'Seguro'
        WHERE id_factura = NEW.id_factura;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pago_seguro
AFTER INSERT ON Pago_Seguro
FOR EACH ROW EXECUTE FUNCTION actualizar_estado_factura();


-- =====================================================================
-- INICIO DEL SCRIPT DE INSERCIÓN COMPLETO
-- =====================================================================

INSERT INTO Hospital (nombre, direccion, num_camas) VALUES
('Hospital de Especialidades Quirúrgicas', 'Av. Francisco de Miranda, Edif. Quirós, Caracas', 0),
('Centro Médico Integral La Trinidad', 'Calle El Hatillo, Urb. La Trinidad, Caracas', 0),
('Clínica Avila', 'Av. San Juan Bosco, Altamira, Caracas', 0),
('Hospital de Niños J.M. de los Ríos', 'Av. Andrés Bello, Los Chaguaramos, Caracas', 0),
('Hospital Cardiológico Universitario', 'Av. Principal de Los Teques, Los Teques', 0),
('Hospital General de Cumaná', 'Calle Sucre, Centro, Cumaná', 0),
('Clínica Maracaibo', 'Av. 15 Delicias, Maracaibo', 0),
('Hospital del Llano', 'Av. Los Llanos, Barinas', 0),
('Hospital Militar Dr. Carlos Arvelo', 'Av. San Martín, Caracas', 0);

INSERT INTO Departamento (id_hospital, numero_departamento, nombre, piso, tipo) VALUES
-- Hospital Central (id=1)
(1, 1, 'Emergencias', 'PB', 'Medico'),
(1, 2, 'Cardiología', '2', 'Medico'),
(1, 3, 'Administración', '1', 'Administrativo'),
(1, 4, 'Mantenimiento', 'S1', 'Apoyo'),
(1, 5, 'Pediatría', '3', 'Medico'),
-- Hospital Universitario (id=2)
(2, 1, 'Cirugía General', '1', 'Medico'),
(2, 2, 'Medicina Interna', '2', 'Medico'),
(2, 3, 'Recursos Humanos', 'PB', 'Administrativo'),
(2, 4, 'Laboratorio', 'PB', 'Apoyo'),
(2, 5, 'Traumatología', '3', 'Medico'),
-- Clínica Santa María (id=3)
(3, 1, 'Ginecología', '1', 'Medico'),
(3, 2, 'Neurología', '2', 'Medico'),
(3, 3, 'Facturación', 'PB', 'Administrativo'),
(3, 4, 'Farmacia', 'PB', 'Apoyo'),
(3, 5, 'UCI', '4', 'Medico'),
-- Hospital Regional (id=4)
(4, 1, 'Urgencias', 'PB', 'Medico'),
(4, 2, 'Oncología', '3', 'Medico'),
(4, 3, 'Contabilidad', '1', 'Administrativo'),
(4, 4, 'Radiología', 'S1', 'Apoyo'),
(4, 5, 'Psiquiatría', '2', 'Medico'), 

(5, 1, 'Cirugía Plástica', '4', 'Medico'),
(5, 2, 'Oftalmología', '3', 'Medico'),
(5, 3, 'Anestesiología', '2', 'Medico'),
(5, 4, 'Recuperación Post-quirúrgica', '5', 'Apoyo'),
(5, 5, 'Admisiones Quirúrgicas', 'PB', 'Administrativo'),

-- Centro Médico Integral La Trinidad (id=6)
(6, 1, 'Medicina Familiar', '1', 'Medico'),
(6, 2, 'Gastroenterología', '2', 'Medico'),
(6, 3, 'Nutrición', 'PB', 'Medico'),
(6, 4, 'Servicio al Cliente', 'PB', 'Administrativo'),
(6, 5, 'Rehabilitación', 'S1', 'Apoyo'),

-- Clínica Avila (id=7)
(7, 1, 'Dermatología', '3', 'Medico'),
(7, 2, 'Endocrinología', '2', 'Medico'),
(7, 3, 'Unidad de Cuidados Intensivos', '5', 'Medico'),
(7, 4, 'Comunicaciones', '1', 'Administrativo'),
(7, 5, 'Esterilización', 'S2', 'Apoyo'),

-- Hospital de Niños J.M. de los Ríos (id=8)
(8, 1, 'Neonatología', '4', 'Medico'),
(8, 2, 'Cardiología Pediátrica', '3', 'Medico'),
(8, 3, 'Odontología Pediátrica', '2', 'Medico'),
(8, 4, 'Trabajo Social', '1', 'Apoyo'),
(8, 5, 'Junta Directiva', 'PB', 'Administrativo'),

-- Hospital Cardiológico Universitario (id=9)
(9, 1, 'Hemodinamia', '3', 'Medico'),
(9, 2, 'Cirugía Cardiovascular', '4', 'Medico'),
(9, 3, 'Electrocardiografía', '2', 'Medico'),
(9, 4, 'Investigación Clínica', '5', 'Apoyo'),
(9, 5, 'Contratos y Adquisiciones', 'PB', 'Administrativo');

INSERT INTO Telefono_Departamento (id_hospital, numero_departamento, telefono) VALUES
(1, 2, '555-1010'), 
(1, 2, '555-1011'), 
(1, 3, '555-2010'), 
(2, 5, '555-0010');

-- Habitaciones (8 por hospital = 32)
INSERT INTO Habitacion (id_hospital, numero_departamento, numero_habitacion, tipo, num_camas, tarifa_dia, ocupada) VALUES
-- Hospital Central (id_hospital = 1) - 15 habitaciones
(1, 1, '101', 'Individual', 1, 150.00, TRUE),
(1, 1, '102', 'Doble', 2, 200.00, FALSE),
(1, 1, '103', 'Individual', 1, 160.00, TRUE),
(1, 2, '201', 'Individual', 1, 180.00, TRUE),
(1, 2, '202', 'Suite', 1, 300.00, FALSE),
(1, 2, '203', 'Doble', 2, 220.00, TRUE),
(1, 3, '301', 'Individual', 1, 170.00, TRUE),
(1, 3, '302', 'Doble', 2, 220.00, FALSE),
(1, 3, '303', 'Individual', 1, 165.00, TRUE),
(1, 4, '401', 'Individual', 1, 190.00, TRUE),
(1, 4, '402', 'Doble', 2, 240.00, FALSE),
(1, 4, '403', 'Individual', 1, 185.00, TRUE),
(1, 5, '501', 'Individual', 1, 170.00, TRUE),
(1, 5, '502', 'Doble', 2, 225.00, FALSE),
(1, 5, '503', 'Individual', 1, 175.00, TRUE),

-- Hospital Universitario (id_hospital = 2) - 15 habitaciones
(2, 1, '101', 'Individual', 1, 160.00, TRUE),
(2, 1, '102', 'Doble', 2, 210.00, FALSE),
(2, 1, '103', 'Individual', 1, 170.00, TRUE),
(2, 2, '201', 'Individual', 1, 175.00, TRUE),
(2, 2, '202', 'Suite', 1, 320.00, FALSE),
(2, 2, '203', 'Doble', 2, 230.00, TRUE),
(2, 3, '301', 'Individual', 1, 180.00, TRUE),
(2, 3, '302', 'Doble', 2, 230.00, FALSE),
(2, 3, '303', 'Individual', 1, 175.00, TRUE),
(2, 4, '401', 'Individual', 1, 200.00, TRUE),
(2, 4, '402', 'Doble', 2, 250.00, FALSE),
(2, 4, '403', 'Individual', 1, 195.00, TRUE),
(2, 5, '501', 'Individual', 1, 180.00, TRUE),
(2, 5, '502', 'Doble', 2, 235.00, FALSE),
(2, 5, '503', 'Individual', 1, 185.00, TRUE),

-- Clínica Santa María (id_hospital = 3) - 15 habitaciones
(3, 1, '101', 'Suite', 1, 350.00, TRUE),
(3, 1, '102', 'Individual', 1, 200.00, FALSE),
(3, 1, '103', 'Individual', 1, 210.00, TRUE),
(3, 2, '201', 'Individual', 1, 190.00, TRUE),
(3, 2, '202', 'Doble', 2, 250.00, FALSE),
(3, 2, '203', 'Suite', 1, 370.00, TRUE),
(3, 3, '301', 'Individual', 1, 220.00, TRUE),
(3, 3, '302', 'Doble', 2, 270.00, FALSE),
(3, 3, '303', 'Individual', 1, 215.00, TRUE),
(3, 4, '401', 'Suite', 1, 400.00, TRUE),
(3, 4, '402', 'Individual', 1, 280.00, FALSE),
(3, 4, '403', 'Doble', 2, 330.00, TRUE),
(3, 5, '501', 'Individual', 1, 280.00, TRUE),
(3, 5, '502', 'Doble', 2, 330.00, FALSE),
(3, 5, '503', 'Individual', 1, 275.00, TRUE),

-- Hospital Regional (id_hospital = 4) - 15 habitaciones
(4, 1, '101', 'Doble', 2, 180.00, TRUE),
(4, 1, '102', 'Doble', 2, 180.00, FALSE),
(4, 1, '103', 'Individual', 1, 160.00, TRUE),
(4, 2, '201', 'Individual', 1, 220.00, TRUE),
(4, 2, '202', 'Suite', 1, 380.00, FALSE),
(4, 2, '203', 'Doble', 2, 270.00, TRUE),
(4, 3, '301', 'Individual', 1, 190.00, TRUE),
(4, 3, '302', 'Doble', 2, 240.00, FALSE),
(4, 3, '303', 'Individual', 1, 185.00, TRUE),
(4, 4, '401', 'Individual', 1, 210.00, TRUE),
(4, 4, '402', 'Doble', 2, 260.00, FALSE),
(4, 4, '403', 'Individual', 1, 205.00, TRUE),
(4, 5, '501', 'Individual', 1, 200.00, TRUE),
(4, 5, '502', 'Doble', 2, 250.00, FALSE),
(4, 5, '503', 'Individual', 1, 195.00, TRUE),

-- Hospital de Especialidades Quirúrgicas (id_hospital = 5) - 15 habitaciones
(5, 1, '101', 'Suite', 1, 400.00, TRUE),
(5, 1, '102', 'Individual', 1, 250.00, FALSE),
(5, 1, '103', 'Doble', 2, 300.00, TRUE),
(5, 2, '201', 'Individual', 1, 240.00, TRUE),
(5, 2, '202', 'Doble', 2, 300.00, FALSE),
(5, 2, '203', 'Suite', 1, 450.00, TRUE),
(5, 3, '301', 'Individual', 1, 230.00, TRUE),
(5, 3, '302', 'Doble', 2, 280.00, FALSE),
(5, 3, '303', 'Individual', 1, 225.00, TRUE),
(5, 4, '401', 'Doble', 2, 280.00, TRUE),
(5, 4, '402', 'Doble', 2, 280.00, FALSE),
(5, 4, '403', 'Individual', 1, 230.00, TRUE),
(5, 5, '501', 'Individual', 1, 240.00, TRUE),
(5, 5, '502', 'Doble', 2, 290.00, FALSE),
(5, 5, '503', 'Individual', 1, 235.00, TRUE),

-- Centro Médico Integral La Trinidad (id_hospital = 6) - 15 habitaciones
(6, 1, '101', 'Individual', 1, 170.00, TRUE),
(6, 1, '102', 'Doble', 2, 220.00, FALSE),
(6, 1, '103', 'Individual', 1, 180.00, TRUE),
(6, 2, '201', 'Individual', 1, 185.00, TRUE),
(6, 2, '202', 'Suite', 1, 330.00, FALSE),
(6, 2, '203', 'Doble', 2, 240.00, TRUE),
(6, 3, '301', 'Individual', 1, 190.00, TRUE),
(6, 3, '302', 'Doble', 2, 240.00, FALSE),
(6, 3, '303', 'Individual', 1, 185.00, TRUE),
(6, 4, '401', 'Individual', 1, 200.00, TRUE),
(6, 4, '402', 'Doble', 2, 250.00, FALSE),
(6, 4, '403', 'Individual', 1, 195.00, TRUE),
(6, 5, '501', 'Individual', 1, 190.00, TRUE),
(6, 5, '502', 'Doble', 2, 240.00, FALSE),
(6, 5, '503', 'Individual', 1, 185.00, TRUE),

-- Clínica Avila (id_hospital = 7) - 15 habitaciones
(7, 1, '101', 'Individual', 1, 210.00, TRUE),
(7, 1, '102', 'Doble', 2, 260.00, FALSE),
(7, 1, '103', 'Suite', 1, 380.00, TRUE),
(7, 2, '201', 'Individual', 1, 200.00, TRUE),
(7, 2, '202', 'Suite', 1, 360.00, FALSE),
(7, 2, '203', 'Doble', 2, 250.00, TRUE),
(7, 3, '301', 'Individual', 1, 300.00, TRUE),
(7, 3, '302', 'Individual', 1, 300.00, FALSE),
(7, 3, '303', 'Suite', 1, 450.00, TRUE),
(7, 4, '401', 'Individual', 1, 290.00, TRUE),
(7, 4, '402', 'Doble', 2, 340.00, FALSE),
(7, 4, '403', 'Individual', 1, 285.00, TRUE),
(7, 5, '501', 'Individual', 1, 280.00, TRUE),
(7, 5, '502', 'Doble', 2, 330.00, FALSE),
(7, 5, '503', 'Individual', 1, 275.00, TRUE),

-- Hospital de Niños J.M. de los Ríos (id_hospital = 8) - 15 habitaciones
(8, 1, '101', 'Individual', 1, 250.00, TRUE),
(8, 1, '102', 'Individual', 1, 250.00, FALSE),
(8, 1, '103', 'Doble', 2, 300.00, TRUE),
(8, 2, '201', 'Individual', 1, 200.00, TRUE),
(8, 2, '202', 'Doble', 2, 260.00, FALSE),
(8, 2, '203', 'Individual', 1, 210.00, TRUE),
(8, 3, '301', 'Individual', 1, 180.00, TRUE),
(8, 3, '302', 'Individual', 1, 180.00, FALSE),
(8, 3, '303', 'Doble', 2, 230.00, TRUE),
(8, 4, '401', 'Individual', 1, 190.00, TRUE),
(8, 4, '402', 'Doble', 2, 240.00, FALSE),
(8, 4, '403', 'Individual', 1, 185.00, TRUE),
(8, 5, '501', 'Individual', 1, 170.00, TRUE),
(8, 5, '502', 'Doble', 2, 220.00, FALSE),
(8, 5, '503', 'Individual', 1, 165.00, TRUE),

-- Hospital Cardiológico Universitario (id_hospital = 9) - 15 habitaciones
(9, 1, '101', 'Individual', 1, 280.00, TRUE),
(9, 1, '102', 'Individual', 1, 280.00, FALSE),
(9, 1, '103', 'Doble', 2, 350.00, TRUE),
(9, 2, '201', 'Suite', 1, 500.00, TRUE),
(9, 2, '202', 'Individual', 1, 300.00, FALSE),
(9, 2, '203', 'Doble', 2, 380.00, TRUE),
(9, 3, '301', 'Individual', 1, 250.00, TRUE),
(9, 3, '302', 'Doble', 2, 320.00, FALSE),
(9, 3, '303', 'Individual', 1, 260.00, TRUE),
(9, 4, '401', 'Individual', 1, 270.00, TRUE),
(9, 4, '402', 'Doble', 2, 340.00, FALSE),
(9, 4, '403', 'Individual', 1, 265.00, TRUE),
(9, 5, '501', 'Individual', 1, 250.00, TRUE),
(9, 5, '502', 'Doble', 2, 320.00, FALSE),
(9, 5, '503', 'Individual', 1, 255.00, TRUE);

-- Personal (30+ trabajadores)
INSERT INTO Personal (ci_personal, nombre, apellido, fecha_nacimiento, direccion, fecha_contratacion, tipo, especialidad, id_hospital_actual, numero_departamento_actual, salario) VALUES
('V-12345678', 'Carlos', 'Rodriguez', '1975-03-15', 'Av. Libertador 123', '2010-01-15', 'Medico', 'Cardiología', 1, 2, 5000.00),
('V-23456789', 'María', 'González', '1980-07-22', 'Calle 50 #45', '2012-03-20', 'Medico', 'Pediatría', 1, 5, 4800.00),
('V-34567890', 'Luis', 'Hernández', '1978-11-08', 'Urb. El Rosal', '2011-06-10', 'Medico', 'Emergencias', 1, 1, 5200.00),
('V-45678901', 'Ana', 'Martinez', '1982-04-30', 'Los Palos Grandes', '2013-09-05', 'Medico', 'Cirugía General', 2, 1, 5500.00),
('V-56789012', 'Pedro', 'Sanchez', '1970-12-25', 'El Cafetal', '2008-02-28', 'Medico', 'Medicina Interna', 2, 2, 5300.00),
('V-67890123', 'Carmen', 'Diaz', '1985-06-18', 'La Castellana', '2015-11-12', 'Medico', 'Traumatología', 2, 5, 4900.00),
('V-78901234', 'Roberto', 'Perez', '1973-09-03', 'Altamira', '2009-04-17', 'Medico', 'Ginecología', 3, 1, 5100.00),
('V-89012345', 'Laura', 'Gomez', '1983-01-20', 'La Trinidad', '2014-07-22', 'Medico', 'Neurología', 3, 2, 5400.00),
('V-90123456', 'Daniel', 'Morales', '1977-05-12', 'Chuao', '2010-10-30', 'Medico', 'UCI', 3, 5, 5600.00),
('V-01234567', 'Patricia', 'Silva', '1981-08-07', 'Santa Monica', '2013-12-15', 'Medico', 'Urgencias', 4, 1, 5000.00),
('V-11223344', 'Jorge', 'Ramirez', '1976-02-28', 'Las Mercedes', '2011-03-25', 'Medico', 'Oncología', 4, 2, 5700.00),
('V-22334455', 'Elena', 'Vargas', '1984-10-15', 'Campo Alegre', '2016-01-10', 'Medico', 'Psiquiatría', 4, 5, 4700.00),
('V-33445566', 'Fernando', 'Castro', '1974-07-19', 'El Paraíso', '2007-05-15', 'Medico', 'Cardiología', 1, 2, 5800.00),
('V-44556677', 'Gabriela', 'Rojas', '1979-11-23', 'San Bernardino', '2009-08-20', 'Medico', 'Pediatría', 2, 5, 5400.00),
('V-55667788', 'Miguel', 'Torres', '1972-03-08', 'La Candelaria', '2006-02-10', 'Medico', 'Cirugía General', 3, 1, 6000.00),
('V-66778899', 'Isabel', 'Mendoza', '1986-09-14', 'Chacaíto', '2017-04-05', 'Medico', 'Medicina Interna', 4, 2, 4600.00),
('V-77889900', 'Rafael', 'Blanco', '1980-12-01', 'Sabana Grande', '2012-06-15', 'Administrativo', NULL, 1, 3, 3000.00),
('V-88990011', 'Luisa', 'Herrera', '1985-04-17', 'Plaza Venezuela', '2014-09-20', 'Administrativo', NULL, 1, 3, 2800.00),
('V-99001122', 'José', 'Flores', '1978-08-25', 'Catia', '2010-11-10', 'Administrativo', NULL, 2, 3, 3200.00),
('V-00112233', 'Diana', 'Vega', '1983-02-12', 'Petare', '2013-01-25', 'Administrativo', NULL, 2, 3, 2900.00),
('V-12312312', 'Alberto', 'Ruiz', '1976-06-30', 'El Valle', '2008-03-15', 'Administrativo', NULL, 3, 3, 3100.00),
('V-23423423', 'Monica', 'Jimenez', '1982-10-08', 'Los Teques', '2011-07-20', 'Administrativo', NULL, 3, 3, 2700.00),
('V-34534534', 'Carlos', 'Medina', '1979-01-22', 'Guarenas', '2009-05-10', 'Administrativo', NULL, 4, 3, 3300.00),
('V-45645645', 'Teresa', 'Ortiz', '1984-05-16', 'La Guaira', '2015-08-25', 'Administrativo', NULL, 4, 3, 2600.00),
('V-56756756', 'Ricardo', 'Campos', '1977-09-11', 'Macaracuay', '2007-12-05', 'Administrativo', NULL, 1, 3, 3500.00),
('V-67867867', 'Sandra', 'Luna', '1981-03-27', 'El Hatillo', '2010-02-15', 'Administrativo', NULL, 2, 3, 3400.00),
('V-78978978', 'Andres', 'Paredes', '1975-07-03', 'Baruta', '2006-06-20', 'Administrativo', NULL, 3, 3, 3600.00),
('V-89089089', 'Natalia', 'Suarez', '1986-11-19', 'Chacao', '2016-10-10', 'Administrativo', NULL, 4, 3, 2500.00),
('V-10987654', 'Lorena', 'Acosta', '1979-03-01', 'Av. El Sol, Valencia', '2015-10-01', 'Medico', 'Cirugía Plástica', 5, 1, 8000.00),
('V-09876543', 'Daniela', 'Flores', '1991-07-19', 'Calle La Gracia, Caracas', '2023-01-01', 'Medico', 'Oftalmología', 5, 2, 6000.00),
('V-12121212', 'Miguel', 'Cordero', '1992-05-05', 'La Candelaria, Caracas', '2023-03-01', 'Administrativo', NULL, 5, 5, 3000.00), -- Dept Admisiones Quirúrgicas
('V-76543210', 'Sofia', 'Mendez', '1990-09-12', 'Los Cortijos de Lourdes, Caracas', '2022-01-20', 'Medico', 'Gastroenterología', 6, 2, 6900.00),
('V-65432109', 'Pablo', 'Quintero', '1983-04-03', 'El Marqués, Caracas', '2018-05-18', 'Medico', 'Nutrición', 6, 3, 6200.00),
('V-34343434', 'Andrea', 'Blanco', '1989-08-20', 'El Cafetal, Caracas', '2021-11-01', 'Administrativo', NULL, 6, 4, 3100.00), -- Dept Servicio al Cliente
('V-98765432', 'Andrea', 'Contreras', '1988-02-01', 'Urb. Las Acacias, Caracas', '2021-03-10', 'Medico', 'Dermatología', 7, 1, 6800.00),
('V-87654321', 'Felipe', 'Guerrero', '1976-11-20', 'Av. Rómulo Gallegos, Caracas', '2019-07-05', 'Medico', 'Endocrinología', 7, 2, 7000.00),
('V-56565656', 'Juan', 'Molina', '1987-01-10', 'Chacao, Caracas', '2020-09-15', 'Administrativo', NULL, 7, 4, 3200.00), -- Dept Comunicaciones
('V-44332211', 'Rosa', 'Velasquez', '1989-10-10', 'Zona Industrial, San Juan de los Morros', '2022-05-15', 'Medico', 'Unidad de Cuidados Intensivos', 7, 3, 6100.00), -- Reubicado a UCI del H7
('V-99887766', 'Marco', 'Peralta', '1973-05-28', 'Av. Principal, Puerto La Cruz', '2018-03-15', 'Medico', 'Neonatología', 8, 1, 7300.00),
('V-88776655', 'Valeria', 'Núñez', '1980-11-02', 'Urb. Las Mercedes, Caracas', '2019-06-20', 'Medico', 'Cardiología Pediátrica', 8, 2, 7100.00),
('V-00998877', 'Susana', 'Ortiz', '1985-01-30', 'Av. La Arboleda, Caracas', '2020-07-01', 'Medico', 'Odontología Pediátrica', 8, 3, 6000.00),
('V-78787878', 'Gabriela', 'Paz', '1993-04-25', 'Los Teques, Miranda', '2024-01-01', 'Administrativo', NULL, 8, 5, 2900.00), -- Dept Junta Directiva
('V-21098765', 'Gabriel', 'Vivas', '1986-08-14', 'Sector Centro, Los Teques', '2021-04-22', 'Medico', 'Hemodinamia', 9, 1, 7200.00),
('V-11009988', 'Esteban', 'Pinto', '1972-06-25', 'Sector El Carmen, Caracas', '2016-04-01', 'Medico', 'Cirugía Cardiovascular', 9, 2, 8800.00),
('V-90909090', 'Pedro', 'Reyes', '1986-11-11', 'Guatire, Miranda', '2019-06-01', 'Administrativo', NULL, 9, 5, 3300.00); -- Dept Contratos y Adquisiciones

-- Horarios de trabajo (5 por trabajador = 150)
-- Insertar horarios para los primeros trabajadores como ejemplo
INSERT INTO Horario_Trabajo (ci_personal, dia_semana, hora_entrada, hora_salida) VALUES
('V-12345678', 'Lunes', '08:00', '16:00'),
('V-12345678', 'Martes', '08:00', '16:00'),
('V-12345678', 'Miercoles', '08:00', '16:00'),
('V-12345678', 'Jueves', '08:00', '16:00'),
('V-12345678', 'Viernes', '08:00', '16:00'),

('V-23456789', 'Lunes', '07:00', '15:00'),
('V-23456789', 'Martes', '07:00', '15:00'),
('V-23456789', 'Miercoles', '07:00', '15:00'),
('V-23456789', 'Jueves', '07:00', '15:00'),
('V-23456789', 'Viernes', '07:00', '15:00'),

('V-34567890', 'Lunes', '07:00', '15:00'),
('V-34567890', 'Martes', '07:00', '15:00'),
('V-34567890', 'Miercoles', '07:00', '15:00'),
('V-34567890', 'Jueves', '07:00', '15:00'),
('V-34567890', 'Viernes', '07:00', '15:00'),

('V-45678901', 'Lunes', '08:00', '18:00'),
('V-45678901', 'Martes', '08:00', '18:00'),
('V-45678901', 'Miercoles', '08:00', '18:00'),
('V-45678901', 'Jueves', '08:00', '18:00'),
('V-45678901', 'Viernes', '08:00', '18:00'),

('V-56789012', 'Lunes', '09:00', '17:00'),
('V-56789012', 'Martes', '09:00', '17:00'),
('V-56789012', 'Miercoles', '09:00', '17:00'),
('V-56789012', 'Jueves', '09:00', '17:00'),
('V-56789012', 'Viernes', '09:00', '17:00'),

('V-01234567', 'Lunes', '09:00', '17:00'),
('V-01234567', 'Martes', '09:00', '17:00'),
('V-01234567', 'Miercoles', '09:00', '17:00'),
('V-01234567', 'Jueves', '09:00', '17:00'),
('V-01234567', 'Viernes', '09:00', '17:00'),

('V-11223344', 'Lunes', '08:30', '16:30'),
('V-11223344', 'Martes', '08:30', '16:30'),
('V-11223344', 'Miercoles', '08:30', '16:30'),
('V-11223344', 'Jueves', '08:30', '16:30'),
('V-11223344', 'Viernes', '08:30', '16:30'),

('V-22334455', 'Lunes', '09:00', '17:00'),
('V-22334455', 'Martes', '10:00', '18:00'),
('V-22334455', 'Miercoles', '09:00', '17:00'),
('V-22334455', 'Jueves', '10:00', '18:00'),
('V-22334455', 'Viernes', '09:00', '17:00'),

('V-33445566', 'Lunes', '07:00', '17:00'),
('V-33445566', 'Martes', '07:00', '17:00'),
('V-33445566', 'Miercoles', '07:00', '17:00'),
('V-33445566', 'Jueves', '07:00', '17:00'),
('V-33445566', 'Viernes', '07:00', '17:00'),

('V-44556677', 'Lunes', '09:00', '17:00'),
('V-44556677', 'Martes', '09:00', '17:00'),
('V-44556677', 'Miercoles', '09:00', '17:00'),
('V-44556677', 'Jueves', '09:00', '17:00'),
('V-44556677', 'Viernes', '09:00', '17:00'),

('V-77889900', 'Lunes', '08:00', '16:00'),
('V-77889900', 'Martes', '08:00', '16:00'),
('V-77889900', 'Miercoles', '08:00', '16:00'),
('V-77889900', 'Jueves', '08:00', '16:00'),
('V-77889900', 'Viernes', '08:00', '16:00'),

('V-88990011', 'Lunes', '08:30', '16:30'),
('V-88990011', 'Martes', '08:30', '16:30'),
('V-88990011', 'Miercoles', '08:30', '16:30'),
('V-88990011', 'Jueves', '08:30', '16:30'),
('V-88990011', 'Viernes', '08:30', '16:30'),

('V-99001122', 'Lunes', '08:00', '16:00'),
('V-99001122', 'Martes', '08:00', '16:00'),
('V-99001122', 'Miercoles', '08:00', '16:00'),
('V-99001122', 'Jueves', '08:00', '16:00'),
('V-99001122', 'Viernes', '08:00', '16:00'),

('V-00112233', 'Lunes', '09:00', '17:00'),
('V-00112233', 'Martes', '09:00', '17:00'),
('V-00112233', 'Miercoles', '09:00', '17:00'),
('V-00112233', 'Jueves', '09:00', '17:00'),
('V-00112233', 'Viernes', '09:00', '17:00'),

('V-12312312', 'Lunes', '08:00', '16:00'),
('V-12312312', 'Martes', '08:00', '16:00'),
('V-12312312', 'Miercoles', '08:00', '16:00'),
('V-12312312', 'Jueves', '08:00', '16:00'),
('V-12312312', 'Viernes', '08:00', '16:00'),

('V-23423423', 'Lunes', '08:30', '16:30'),
('V-23423423', 'Martes', '08:30', '16:30'),
('V-23423423', 'Miercoles', '08:30', '16:30'),
('V-23423423', 'Jueves', '08:30', '16:30'),
('V-23423423', 'Viernes', '08:30', '16:30'),

('V-55667788', 'Lunes', '08:00', '16:00'),
('V-55667788', 'Martes', '08:00', '16:00'),
('V-55667788', 'Miercoles', '08:00', '16:00'),
('V-55667788', 'Jueves', '08:00', '16:00'),
('V-55667788', 'Viernes', '08:00', '16:00'),

('V-66778899', 'Lunes', '09:00', '17:00'),
('V-66778899', 'Martes', '09:00', '17:00'),
('V-66778899', 'Miercoles', '09:00', '17:00'),
('V-66778899', 'Jueves', '09:00', '17:00'),
('V-66778899', 'Viernes', '09:00', '17:00'),

('V-78901234', 'Lunes', '08:00', '16:00'),
('V-78901234', 'Martes', '08:00', '16:00'),
('V-78901234', 'Miercoles', '08:00', '16:00'),
('V-78901234', 'Jueves', '08:00', '16:00'),
('V-78901234', 'Viernes', '08:00', '16:00'),

('V-89012345', 'Lunes', '07:00', '15:00'),
('V-89012345', 'Martes', '07:00', '15:00'),
('V-89012345', 'Miercoles', '07:00', '15:00'),
('V-89012345', 'Jueves', '07:00', '15:00'),
('V-89012345', 'Viernes', '07:00', '15:00'),

('V-90123456', 'Lunes', '09:00', '17:00'),
('V-90123456', 'Martes', '09:00', '17:00'),
('V-90123456', 'Miercoles', '09:00', '17:00'),
('V-90123456', 'Jueves', '09:00', '17:00'),
('V-90123456', 'Viernes', '09:00', '17:00');

-- Pacientes (20+)
INSERT INTO Paciente (ci_paciente, nombre, apellido, fecha_nacimiento, sexo, direccion, telefono, contacto_emergencia, telefono_emergencia, responsable_nombre, responsable_telefono) VALUES
-- Pacientes con seguro (10)
('V-10000001', 'Juan', 'Pérez', '1990-05-15', 'M', 'Av. Universidad 123', '0414-1234567', 'María Pérez', '0414-7654321', NULL, NULL),
('V-10000002', 'Ana', 'López', '1985-08-22', 'F', 'Calle Real 456', '0424-2345678', 'Pedro López', '0424-8765432', NULL, NULL),
('V-10000003', 'Carlos', 'García', '1978-03-10', 'M', 'Urb. Vista Hermosa', '0412-3456789', 'Laura García', '0412-9876543', NULL, NULL),
('V-10000004', 'María', 'Rodríguez', '1992-11-28', 'F', 'Los Naranjos', '0416-4567890', 'José Rodríguez', '0416-0987654', NULL, NULL),
('V-10000005', 'Luis', 'Martínez', '1970-07-05', 'M', 'El Paraíso', '0414-5678901', 'Carmen Martínez', '0414-1098765', NULL, NULL),
('V-10000006', 'Carmen', 'Fernández', '1988-12-18', 'F', 'La Florida', '0424-6789012', 'Roberto Fernández', '0424-2109876', NULL, NULL),
('V-10000007', 'Pedro', 'Sánchez', '1995-04-03', 'M', 'Altamira', '0412-7890123', 'Ana Sánchez', '0412-3210987', NULL, NULL),
('V-10000008', 'Laura', 'Gómez', '1982-09-25', 'F', 'Las Mercedes', '0416-8901234', 'Daniel Gómez', '0416-4321098', NULL, NULL),
('V-10000009', 'Daniel', 'Díaz', '1975-01-12', 'M', 'Chuao', '0414-9012345', 'Patricia Díaz', '0414-5432109', NULL, NULL),
('V-10000010', 'Patricia', 'Herrera', '1998-06-30', 'F', 'Santa Mónica', '0424-0123456', 'Jorge Herrera', '0424-6543210', NULL, NULL),
-- Pacientes sin seguro (10)
('V-20000001', 'Roberto', 'Vargas', '1980-02-14', 'M', 'Catia', '0412-1111111', 'Elena Vargas', '0412-2222222', NULL, NULL),
('V-20000002', 'Elena', 'Morales', '1993-10-07', 'F', 'Petare', '0416-3333333', 'Fernando Morales', '0416-4444444', NULL, NULL),
('V-20000003', 'Fernando', 'Castro', '1987-05-20', 'M', 'El Valle', '0414-5555555', 'Gabriela Castro', '0414-6666666', NULL, NULL),
('V-20000004', 'Gabriela', 'Rojas', '1972-08-13', 'F', 'La Vega', '0424-7777777', 'Miguel Rojas', '0424-8888888', NULL, NULL),
('V-20000005', 'Miguel', 'Torres', '1996-03-26', 'M', 'Antímano', '0412-9999999', 'Isabel Torres', '0412-0000000', NULL, NULL),
('V-20000006', 'Isabel', 'Mendoza', '1983-11-09', 'F', 'Caricuao', '0416-1212121', 'Rafael Mendoza', '0416-2323232', NULL, NULL),
('V-20000007', 'Rafael', 'Silva', '2010-07-15', 'M', 'Guarenas', '0414-3434343', NULL, NULL, 'Luisa Silva', '0414-4545454'),
('V-20000008', 'Luisa', 'Ramos', '2012-12-22', 'F', 'Los Teques', '0424-5656565', NULL, NULL, 'José Ramos', '0424-6767676'),
('V-20000009', 'José', 'Flores', '1969-04-08', 'M', 'La Guaira', '0412-7878787', 'Diana Flores', '0412-8989898', NULL, NULL),
('V-20000010', 'Diana', 'Vega', '1991-09-17', 'F', 'Maiquetía', '0416-9090909', 'Alberto Vega', '0416-0101010', NULL, NULL);

-- Usamos las cédulas de los pacientes que acabas de crear.
INSERT INTO Historial_Medico (ci_paciente, fecha, tipo, descripcion) VALUES
('V-10000001', '2022-01-20', 'Alergia', 'Alergia confirmada a la penicilina.'),
('V-10000001', '2023-11-05', 'Cirugia', 'Apendicectomía de emergencia. Sin complicaciones.'),
('V-10000001', '2024-03-10', 'Enfermedad Cronica', 'Diagnóstico de Hipertensión Arterial. Se inicia tratamiento.'),
('V-10000002', '2023-08-15', 'Consulta', 'Chequeo anual, todo en orden.'),
('V-10000002', '2024-01-22', 'Procedimiento', 'Limpieza dental de rutina.'),
('V-20000001', '2024-05-01', 'Lesion', 'Fractura de radio en brazo izquierdo por caída.');

-- Aseguradoras (2+)
INSERT INTO Aseguradora (nombre, direccion, telefono) VALUES
('Mercantil Seguros', 'Av. Ávila, Centro Seguros La Paz', '0212-2401000'),
('Mapfre Seguros', 'Calle Madrid, Las Mercedes', '0212-9995000'),
('BMI Seguros', 'Av. Francisco de Miranda, Torre Cavendes', '0212-3001500'),
('Seguros Qualitas', 'Centro Comercial El Recreo, Sabana Grande', '0212-7603000'),
('InterBank Seguros', 'Calle Elice, El Rosal', '0212-9051000');

-- Afiliaciones de seguro (para los 10 pacientes asegurados)
INSERT INTO Afiliacion_Seguro (ci_paciente, id_aseguradora, numero_poliza, fecha_inicio, fecha_fin, monto_cobertura) VALUES
('V-10000001', 1, 'POL-001-2024', '2024-01-01', '2024-12-31', 50000.00),
('V-10000002', 1, 'POL-002-2024', '2024-01-15', '2024-12-31', 45000.00),
('V-10000003', 2, 'POL-003-2024', '2024-02-01', '2025-01-31', 60000.00),
('V-10000004', 2, 'POL-004-2024', '2024-02-15', '2025-02-14', 55000.00),
('V-10000005', 3, 'POL-005-2024', '2024-03-01', '2025-02-28', 70000.00),
('V-10000006', 1, 'POL-006-2024', '2024-03-15', '2025-03-14', 48000.00),
('V-10000007', 2, 'POL-007-2024', '2024-04-01', '2025-03-31', 52000.00),
('V-10000008', 3, 'POL-008-2024', '2024-04-15', '2025-04-14', 65000.00),
('V-10000009', 1, 'POL-009-2024', '2024-05-01', '2025-04-30', 58000.00),
('V-10000010', 2, 'POL-010-2024', '2024-05-15', '2025-05-14', 62000.00);

INSERT INTO Insumo_Medico (id_insumo, nombre, descripcion, tipo, subtipo, unidad_medida, fecha_vencimiento) VALUES
-- Medicamentos (Asignando IDs del 1 al 6)
(1, 'Paracetamol 500mg', 'Analgésico y antipirético', 'Medicamento', 'Tabletas', 'Caja', '2026-12-31'),
(2, 'Ibuprofeno 400mg', 'Antiinflamatorio no esteroideo', 'Medicamento', 'Tabletas', 'Caja', '2026-11-30'),
(3, 'Amoxicilina 500mg', 'Antibiótico de amplio espectro', 'Medicamento', 'Cápsulas', 'Caja', '2025-10-31'),
(4, 'Omeprazol 20mg', 'Inhibidor de bomba de protones', 'Medicamento', 'Cápsulas', 'Caja', '2026-09-30'),
(5, 'Loratadina 10mg', 'Antihistamínico', 'Medicamento', 'Tabletas', 'Caja', '2026-08-31'),
(6, 'Dipirona 500mg', 'Analgésico', 'Medicamento', 'Inyectable', 'Ampolla', '2025-07-31'),
-- Instrumental (Asignando IDs del 7 al 10)
(7, 'Bisturí #11', 'Bisturí quirúrgico desechable', 'Instrumental', 'Cortante', 'Unidad', NULL),
(8, 'Pinza Kelly', 'Pinza hemostática', 'Instrumental', 'Hemostasia', 'Unidad', NULL),
(9, 'Tijera Mayo', 'Tijera quirúrgica', 'Instrumental', 'Cortante', 'Unidad', NULL),
(10, 'Separador Farabeuf', 'Separador quirúrgico', 'Instrumental', 'Separación', 'Unidad', NULL),
-- Suministros (Asignando IDs del 11 al 15)
(11, 'Gasas estériles', 'Gasas 10x10cm estériles', 'Suministro', 'Curación', 'Paquete', NULL),
(12, 'Guantes látex M', 'Guantes de examinación', 'Suministro', 'Protección', 'Caja', NULL),
(13, 'Jeringas 5ml', 'Jeringas desechables', 'Suministro', 'Inyección', 'Unidad', NULL),
(14, 'Alcohol 70%', 'Solución antiséptica', 'Suministro', 'Antiséptico', 'Litro', NULL),
(15, 'Mascarillas N95', 'Mascarillas de protección', 'Suministro', 'Protección', 'Caja', NULL);

-- Proveedores (5)
INSERT INTO Proveedor (nombre_empresa, direccion, ciudad, telefono, email) VALUES
('Distribuidora Médica Central', 'Zona Industrial La Yaguara', 'Caracas', '0212-4441234', 'ventas@medcentral.com'),
('Suministros Hospitalarios Valencia', 'Av. Bolívar Norte', 'Valencia', '0241-8882345', 'contacto@suhosval.com'),
('Farma Express', 'Centro Comercial Maracaibo', 'Maracaibo', '0261-7773456', 'pedidos@farmaexpress.com'),
('Medical Supplies CA', 'Parque Industrial Sur', 'Barquisimeto', '0251-2224567', 'ventas@medicalsupplies.com'),
('Equipos Médicos Andinos', 'Zona Industrial Paramillo', 'San Cristóbal', '0276-3335678', 'info@equiposandinos.com');

-- Relación Proveedor-Insumo
INSERT INTO Proveedor_Suministra (id_proveedor, id_insumo, precio_unitario) VALUES
-- Proveedor 1
(1, 1, 25.00), (1, 2, 30.00), (1, 3, 45.00), (1, 11, 5.00), (1, 12, 35.00),
-- Proveedor 2 (Valencia)
(2, 4, 28.00), (2, 5, 18.00), (2, 6, 15.00), (2, 13, 8.00), (2, 14, 40.00),
-- Proveedor 3
(3, 1, 24.00), (3, 2, 29.00), (3, 7, 12.00), (3, 8, 85.00), (3, 15, 120.00),
-- Proveedor 4
(4, 3, 43.00), (4, 4, 27.00), (4, 9, 95.00), (4, 10, 110.00), (4, 11, 4.50),
-- Proveedor 5
(5, 5, 17.00), (5, 6, 14.00), (5, 12, 34.00), (5, 13, 7.50), (5, 14, 38.00);

-- Inventario inicial
INSERT INTO Inventario (id_hospital, id_insumo, cantidad, stock_minimo) VALUES
-- Hospital 1
(1, 1, 50, 10),  -- Paracetamol
(1, 2, 40, 8),   -- Ibuprofeno
(1, 3, 30, 6),   -- Amoxicilina
(1, 4, 30, 6),   -- Omeprazol
(1, 5, 20, 4),   -- Loratadina
(1, 6, 20, 4),   -- Dipirona
(1, 7, 50, 10),  -- Bisturí #11
(1, 8, 40, 8),   -- Pinza Kelly
(1, 9, 30, 6),   -- Tijera Mayo
(1, 10, 20, 4),  -- Separador Farabeuf
(1, 11, 200, 40), -- Gasas estériles
(1, 12, 150, 30), -- Guantes látex M
(1, 13, 180, 35), -- Jeringas 5ml
(1, 14, 50, 10),  -- Alcohol 70% (Litros)
(1, 15, 60, 12),  -- Mascarillas N95

-- Hospital 2
(2, 1, 60, 12), (2, 2, 50, 10), (2, 3, 35, 7), (2, 4, 35, 7), (2, 5, 25, 5), (2, 6, 25, 5),
(2, 7, 60, 12), (2, 8, 45, 9), (2, 9, 35, 7), (2, 10, 25, 5),
(2, 11, 220, 45), (2, 12, 170, 35), (2, 13, 200, 40), (2, 14, 60, 12), (2, 15, 70, 14),

-- Hospital 3
(3, 1, 70, 14), (3, 2, 60, 12), (3, 3, 40, 8), (3, 4, 40, 8), (3, 5, 30, 6), (3, 6, 30, 6),
(3, 7, 70, 14), (3, 8, 50, 10), (3, 9, 40, 8), (3, 10, 30, 6),
(3, 11, 250, 50), (3, 12, 200, 40), (3, 13, 220, 45), (3, 14, 70, 14), (3, 15, 80, 16),

-- Hospital 4
(4, 1, 80, 16), (4, 2, 70, 14), (4, 3, 45, 9), (4, 4, 45, 9), (4, 5, 35, 7), (4, 6, 35, 7),
(4, 7, 80, 16), (4, 8, 55, 11), (4, 9, 45, 9), (4, 10, 35, 7),
(4, 11, 280, 55), (4, 12, 220, 45), (4, 13, 250, 50), (4, 14, 80, 16), (4, 15, 90, 18),

-- Hospital 5
(5, 1, 90, 18), (5, 2, 80, 16), (5, 3, 50, 10), (5, 4, 50, 10), (5, 5, 40, 8), (5, 6, 40, 8),
(5, 7, 90, 18), (5, 8, 60, 12), (5, 9, 50, 10), (5, 10, 40, 8),
(5, 11, 300, 60), (5, 12, 250, 50), (5, 13, 280, 55), (5, 14, 90, 18), (5, 15, 100, 20),

-- Hospital 6
(6, 1, 70, 14), (6, 2, 60, 12), (6, 3, 30, 6), (6, 4, 30, 6), (6, 5, 20, 4), (6, 6, 20, 4),
(6, 7, 60, 12), (6, 8, 40, 8), (6, 9, 30, 6), (6, 10, 20, 4),
(6, 11, 200, 40), (6, 12, 150, 30), (6, 13, 180, 35), (6, 14, 50, 10), (6, 15, 60, 12),

-- Hospital 7
(7, 1, 80, 16), (7, 2, 70, 14), (7, 3, 35, 7), (7, 4, 35, 7), (7, 5, 25, 5), (7, 6, 25, 5),
(7, 7, 70, 14), (7, 8, 45, 9), (7, 9, 35, 7), (7, 10, 25, 5),
(7, 11, 220, 45), (7, 12, 170, 35), (7, 13, 200, 40), (7, 14, 60, 12), (7, 15, 70, 14),

-- Hospital 8
(8, 1, 90, 18), (8, 2, 80, 16), (8, 3, 40, 8), (8, 4, 40, 8), (8, 5, 30, 6), (8, 6, 30, 6),
(8, 7, 80, 16), (8, 8, 50, 10), (8, 9, 40, 8), (8, 10, 30, 6),
(8, 11, 250, 50), (8, 12, 200, 40), (8, 13, 220, 45), (8, 14, 70, 14), (8, 15, 80, 16),

-- Hospital 9
(9, 1, 100, 20), (9, 2, 90, 18), (9, 3, 45, 9), (9, 4, 45, 9), (9, 5, 35, 7), (9, 6, 35, 7),
(9, 7, 90, 18), (9, 8, 55, 11), (9, 9, 45, 9), (9, 10, 35, 7),
(9, 11, 280, 55), (9, 12, 220, 45), (9, 13, 250, 50), (9, 14, 80, 16), (9, 15, 90, 18);

-- Encargos
INSERT INTO Encargo (id_hospital, id_proveedor, ci_responsable, fecha_encargo, fecha_recepcion, estado) VALUES
(1, 1, 'V-77889900', '2025-01-15', '2025-01-20', 'Recibido'),
(1, 3, 'V-77889900', '2025-02-10', '2025-02-15', 'Recibido'),
(2, 2, 'V-99001122', '2025-03-05', '2025-03-10', 'Recibido'),
(2, 4, 'V-99001122', '2025-04-01', NULL, 'Pendiente'),
(3, 5, 'V-12312312', '2025-04-15', '2025-04-20', 'Recibido'),
(3, 1, 'V-12312312', '2025-05-01', NULL, 'Pendiente'),
(4, 2, 'V-34534534', '2025-05-10', '2025-05-15', 'Recibido'),
(4, 3, 'V-34534534', '2025-06-01', NULL, 'Pendiente'),
(5, 1, 'V-12121212', '2025-06-15', '2025-06-20', 'Recibido'),
(5, 2, 'V-12121212', '2025-07-01', NULL, 'Pendiente'),
(6, 3, 'V-34343434', '2025-05-20', '2025-05-25', 'Recibido'),
(6, 4, 'V-34343434', '2025-06-10', NULL, 'Pendiente'),
(7, 5, 'V-56565656', '2025-04-01', '2025-04-05', 'Recibido'),
(7, 1, 'V-56565656', '2025-06-01', '2025-06-05', 'Recibido'),
(8, 2, 'V-78787878', '2025-03-10', '2025-03-15', 'Recibido'),
(8, 3, 'V-78787878', '2025-06-21', NULL, 'Pendiente'), -- Fecha actual
(9, 4, 'V-90909090', '2025-05-05', '2025-05-10', 'Recibido'),
(9, 5, 'V-90909090', '2025-06-18', NULL, 'Pendiente');


-- Detalle de encargos
INSERT INTO Encargo_Detalle (id_encargo, id_insumo, cantidad, precio_unitario) VALUES
(1, 1, 50, 25.00), (1, 2, 40, 30.00), (1, 3, 30, 45.00),
(2, 7, 10, 12.00), (2, 8, 5, 85.00),
(3, 4, 40, 28.00), (3, 5, 30, 18.00), (3, 6, 50, 15.00),
(4, 9, 8, 95.00), (4, 10, 6, 110.00),
(5, 12, 100, 34.00), (5, 13, 60, 7.50),
(6, 1, 60, 25.00), (6, 11, 100, 5.00),
(7, 14, 20, 40.00), (7, 6, 40, 15.00),
(8, 15, 15, 120.00), (8, 2, 35, 29.00),
(9, 1, 30, 26.00), (9, 4, 10, 32.00),
(10, 5, 15, 19.00), (10, 9, 7, 98.00),

-- Encargo: (6, 3, 'V-34343434', '2025-05-20', '2025-05-25', 'Recibido')
(11, 2, 50, 31.00),
(11, 6, 25, 16.00),
(11, 10, 5, 115.00),
(12, 11, 80, 5.50),
(12, 14, 10, 42.00),
(13, 3, 20, 48.00),
(13, 7, 8, 13.00),
(14, 8, 4, 88.00),
(14, 12, 70, 35.00),
(15, 1, 45, 27.00),
(15, 5, 25, 19.50),
(16, 9, 12, 96.00),
(16, 13, 50, 8.00),
(17, 2, 60, 30.50),
(17, 6, 35, 15.50),
(18, 10, 9, 112.00),
(18, 15, 10, 125.00);

-- Eventos Clínicos (30+ procedimientos)
INSERT INTO Evento_Clinico (tipo, fecha, hora, ci_paciente, ci_medico, id_hospital, id_habitacion, descripcion, observaciones, costo) VALUES
-- Consultas
('Consulta', '2025-01-10', '09:00', 'V-10000001', 'V-12345678', 5, NULL, 'Consulta cardiológica', 'Paciente con hipertensión', 150.00),
('Consulta', '2025-01-15', '10:30', 'V-10000002', 'V-23456789', 5, NULL, 'Control pediátrico', 'Desarrollo normal', 120.00),
('Consulta', '2025-01-20', '11:00', 'V-10000003', 'V-34567890', 8, NULL, 'Consulta de emergencia', 'Dolor torácico', 200.00),
('Consulta', '2025-02-05', '14:00', 'V-10000004', 'V-45678901', 6, NULL, 'Evaluación pre-operatoria', 'Apto para cirugía', 180.00),
('Consulta', '2025-02-10', '15:30', 'V-10000005', 'V-56789012', 4, NULL, 'Control medicina interna', 'Diabetes controlada', 160.00),
('Consulta', '2025-02-15', '16:00', 'V-20000001', 'V-67890123', 5, NULL, 'Consulta traumatología', 'Fractura de muñeca', 170.00),
('Consulta', '2025-03-01', '08:30', 'V-20000002', 'V-78901234', 7, NULL, 'Control ginecológico', 'Embarazo normal', 140.00),
('Consulta', '2025-03-10', '09:30', 'V-20000003', 'V-89012345', 8, NULL, 'Consulta neurológica', 'Migraña crónica', 190.00),
('Consulta', '2025-03-15', '10:00', 'V-20000004', 'V-90123456', 9, NULL, 'Evaluación UCI', 'Paciente estable', 250.00),
('Consulta', '2025-04-01', '11:30', 'V-20000005', 'V-01234567', 9, NULL, 'Urgencias', 'Gastroenteritis', 130.00),
-- Operaciones (15)
('Operacion', '2025-01-25', '07:00', 'V-10000001', 'V-12345678', 1, 1, 'Cateterismo cardíaco', 'Sin complicaciones', 5000.00),
('Operacion', '2025-02-08', '08:00', 'V-10000004', 'V-45678901', 2, 9, 'Apendicectomía', 'Cirugía exitosa', 3500.00),
('Operacion', '2025-02-20', '07:30', 'V-20000001', 'V-67890123', 2, 13, 'Reducción de fractura', 'Con fijación interna', 4000.00),
('Operacion', '2025-03-05', '09:00', 'V-20000002', 'V-78901234', 3, 17, 'Cesárea', 'Madre y bebé estables', 4500.00),
('Operacion', '2025-03-18', '08:30', 'V-10000006', 'V-55667788', 3, 18, 'Colecistectomía', 'Laparoscópica', 3800.00),
('Operacion', '2025-04-02', '07:00', 'V-10000007', 'V-33445566', 6, 3, 'Bypass coronario', 'Triple bypass', 12000.00),
('Operacion', '2025-04-12', '08:00', 'V-10000008', 'V-44556677', 2, 10, 'Hernioplastia', 'Hernia inguinal', 2800.00),
('Operacion', '2025-04-20', '09:30', 'V-10000009', 'V-66778899', 4, 26, 'Tiroidectomía', 'Total', 4200.00),
('Operacion', '2025-04-25', '07:30', 'V-10000010', 'V-11223344', 4, 27, 'Resección tumoral', 'Tumor benigno', 6500.00),
('Operacion', '2025-05-05', '08:00', 'V-20000006', 'V-12345678', 1, 4, 'Angioplastia', 'Con stent', 8000.00),
('Operacion', '2025-05-10', '09:00', 'V-20000007', 'V-23456789', 1, 5, 'Amigdalectomía', 'Pediátrica', 2200.00),
('Operacion', '2025-05-15', '07:00', 'V-20000008', 'V-45678901', 2, 11, 'Septoplastia', 'Desviación septal', 3200.00),
('Operacion', '2025-05-20', '08:30', 'V-20000009', 'V-78901234', 3, 19, 'Histerectomía', 'Laparoscópica', 5200.00),
('Operacion', '2025-05-25', '09:00', 'V-20000010', 'V-89012345', 3, 20, 'Craneotomía', 'Evacuación hematoma', 15000.00),
('Operacion', '2025-06-01', '07:30', 'V-10000003', 'V-01234567', 4, 25, 'Gastrectomía', 'Parcial', 7500.00),
-- Procedimientos/Tratamientos (5+)
('Procedimiento', '2025-01-12', '10:00', 'V-10000001', 'V-12345678', 1, NULL, 'Ecocardiograma', 'Estudio completo', 300.00),
('Procedimiento', '2025-01-18', '11:00', 'V-10000002', 'V-23456789', 1, NULL, 'Nebulización', 'Tratamiento respiratorio', 80.00),
('Procedimiento', '2025-02-12', '14:30', 'V-10000005', 'V-56789012', 2, NULL, 'Glucometría', 'Control diabetes', 50.00),
('Procedimiento', '2025-03-08', '15:00', 'V-20000003', 'V-89012345', 3, NULL, 'Electroencefalograma', 'Estudio completo', 400.00),
('Procedimiento', '2025-04-05', '16:00', 'V-20000005', 'V-01234567', 4, NULL, 'Endoscopia', 'Digestiva alta', 600.00);

INSERT INTO Evento_Usa_Insumo (id_evento, id_insumo, cantidad) VALUES
-- Las Consultas (IDs 1-10) no suelen usar insumos rastreables de esta forma.

-- Operaciones (ID de Evento: del 11 al 25, siguiendo el orden de tu script)
-- Evento 11: Cateterismo cardíaco (Operacion)
(11, 13, 2),  -- Guantes látex M
(11, 12, 1),  -- Guantes látex M (por si es de los que requieren más de un par o tipo)
(11, 14, 1),  -- Jeringas 5ml (para inyección de contraste, etc.)

-- Evento 12: Apendicectomía (Operacion)
(12, 7, 1),   -- Bisturí #11
(12, 11, 10), -- Gasas estériles
(12, 12, 2),  -- Guantes látex M
(12, 13, 2),  -- Jeringas 5ml

-- Evento 13: Reducción de fractura (Operacion)
(13, 7, 1),   -- Bisturí #11
(13, 8, 2),   -- Pinza Kelly (para manipulación ósea o hemostasia)
(13, 11, 10), -- Gasas estériles
(13, 12, 4),  -- Guantes látex M

-- Evento 14: Cesárea (Operacion)
(14, 7, 1),   -- Bisturí #11
(14, 9, 1),   -- Tijera Mayo
(14, 11, 15), -- Gasas estériles
(14, 12, 4),  -- Guantes látex M
(14, 13, 2),  -- Jeringas 5ml

-- Evento 15: Colecistectomía (Operacion)
(15, 7, 1),   -- Bisturí #11
(15, 8, 2),   -- Pinza Kelly
(15, 10, 1),  -- Separador Farabeuf (para laparoscopia si es abierto)
(15, 11, 8),  -- Gasas estériles
(15, 12, 3),  -- Guantes látex M

-- Evento 16: Bypass coronario (Operacion)
(16, 7, 2),   -- Bisturí #11 (varios)
(16, 8, 4),   -- Pinza Kelly (varias)
(16, 11, 20), -- Gasas estériles (muchas)
(16, 12, 6),  -- Guantes látex M (varios cambios)
(16, 13, 5),  -- Jeringas 5ml (para drogas, etc.)

-- Evento 17: Hernioplastia (Operacion)
(17, 7, 1),   -- Bisturí #11
(17, 11, 5),  -- Gasas estériles
(17, 12, 2),  -- Guantes látex M

-- Evento 18: Tiroidectomía (Operacion)
(18, 7, 1),   -- Bisturí #11
(18, 8, 2),   -- Pinza Kelly
(18, 11, 10), -- Gasas estériles
(18, 12, 3),  -- Guantes látex M

-- Evento 19: Resección tumoral (Operacion)
(19, 7, 1),   -- Bisturí #11
(19, 11, 12), -- Gasas estériles
(19, 12, 3),  -- Guantes látex M

-- Evento 20: Angioplastia (Operacion)
(20, 13, 2),  -- Jeringas 5ml
(20, 12, 2),  -- Guantes látex M
(20, 14, 1), -- Alcohol 70% (para desinfección) - **Nota: si unidad_medida es Litro, 0.5 es medio litro**

-- Evento 21: Amigdalectomía (Operacion)
(21, 7, 1),   -- Bisturí #11
(21, 11, 8),  -- Gasas estériles
(21, 12, 2),  -- Guantes látex M

-- Evento 22: Septoplastia (Operacion)
(22, 7, 1),   -- Bisturí #11
(22, 11, 7),  -- Gasas estériles
(22, 12, 2),  -- Guantes látex M

-- Evento 23: Histerectomía (Operacion)
(23, 7, 1),   -- Bisturí #11
(23, 8, 3),   -- Pinza Kelly
(23, 11, 15), -- Gasas estériles
(23, 12, 4),  -- Guantes látex M

-- Evento 24: Craneotomía (Operacion)
(24, 7, 2),   -- Bisturí #11
(24, 8, 4),   -- Pinza Kelly
(24, 11, 25), -- Gasas estériles
(24, 12, 6),  -- Guantes látex M
(24, 13, 3),  -- Jeringas 5ml

-- Evento 25: Gastrectomía (Operacion)
(25, 7, 1),   -- Bisturí #11
(25, 8, 3),   -- Pinza Kelly
(25, 11, 18), -- Gasas estériles
(25, 12, 4),  -- Guantes látex M


-- Procedimientos/Tratamientos (ID de Evento: del 26 al 30, siguiendo el orden de tu script)
-- Evento 26: Ecocardiograma (Procedimiento)
(26, 12, 1),  -- Guantes látex M (para protección del personal)

-- Evento 27: Nebulización (Procedimiento)
(27, 1, 1),   -- Paracetamol 500mg (asumiendo que se diluye, aunque sea un medicamento) - **Este sería un uso de medicamento**
(27, 13, 1),  -- Jeringas 5ml (para preparar la solución)

-- Evento 28: Glucometría (Procedimiento)
(28, 12, 1),  -- Guantes látex M
(28, 13, 1),  -- Jeringas 5ml (para muestra de sangre, o lanceta si la consideras jeringa pequeña)

-- Evento 29: Electroencefalograma (Procedimiento)
(29, 12, 1),  -- Guantes látex M (para el técnico)
(29, 14, 2), -- Alcohol 70% (para limpieza de la piel)

-- Evento 30: Endoscopia (Procedimiento)
(30, 11, 5),  -- Gasas estériles
(30, 12, 2),  -- Guantes látex M
(30, 13, 1);  -- Jeringas 5ml (para sedación ligera, etc.)

-- Facturas
INSERT INTO Factura (id_evento, ci_paciente, fecha_emision, subtotal, iva, total, estado, metodo_pago) VALUES
-- Facturas de consultas (Corresponden a id_evento 1-10 de Evento_Clinico)
(1, 'V-10000001', '2025-01-10', 150.00, 24.00, 174.00, 'Pagada', 'Seguro'),
(2, 'V-10000002', '2025-01-15', 120.00, 19.20, 139.20, 'Pagada', 'Seguro'),
(3, 'V-10000003', '2025-01-20', 200.00, 32.00, 232.00, 'Pagada', 'Seguro'),
(4, 'V-10000004', '2025-02-05', 180.00, 28.80, 208.80, 'Pagada', 'Seguro'),
(5, 'V-10000005', '2025-02-10', 160.00, 25.60, 185.60, 'Pagada', 'Seguro'),
(6, 'V-20000001', '2025-02-15', 170.00, 27.20, 197.20, 'Pagada', 'Efectivo'),
(7, 'V-20000002', '2025-03-01', 140.00, 22.40, 162.40, 'Pagada', 'Tarjeta'),
(8, 'V-20000003', '2025-03-10', 190.00, 30.40, 220.40, 'Pendiente', NULL),
(9, 'V-20000004', '2025-03-15', 250.00, 40.00, 290.00, 'Pagada', 'Efectivo'),
(10, 'V-20000005', '2025-04-01', 130.00, 20.80, 150.80, 'Pendiente', NULL),

-- Facturas de operaciones (Corresponden a id_evento 11-25 de Evento_Clinico)
(11, 'V-10000001', '2025-01-25', 5000.00, 800.00, 5800.00, 'Pagada', 'Seguro'),
(12, 'V-10000004', '2025-02-08', 3500.00, 560.00, 4060.00, 'Pagada', 'Seguro'),
(13, 'V-20000001', '2025-02-20', 4000.00, 640.00, 4640.00, 'Pagada', 'Mixto'),
(14, 'V-20000002', '2025-03-05', 4500.00, 720.00, 5220.00, 'Pendiente', NULL),
(15, 'V-10000006', '2025-03-18', 3800.00, 608.00, 4408.00, 'Pagada', 'Seguro'),
(16, 'V-10000007', '2025-04-02', 12000.00, 1920.00, 13920.00, 'Pagada', 'Seguro'),
(17, 'V-10000008', '2025-04-12', 2800.00, 448.00, 3248.00, 'Pagada', 'Seguro'),
(18, 'V-10000009', '2025-04-20', 4200.00, 672.00, 4872.00, 'Pagada', 'Seguro'),
(19, 'V-10000010', '2025-04-25', 6500.00, 1040.00, 7540.00, 'Pagada', 'Seguro'),
(20, 'V-20000006', '2025-05-05', 8000.00, 1280.00, 9280.00, 'Pagada', 'Seguro'),
(21, 'V-20000007', '2025-05-10', 2200.00, 352.00, 2552.00, 'Pagada', 'Tarjeta'),
(22, 'V-20000008', '2025-05-15', 3200.00, 512.00, 3712.00, 'Pagada', 'Seguro'),
(23, 'V-20000009', '2025-05-20', 5200.00, 832.00, 6032.00, 'Pagada', 'Mixto'),
(24, 'V-20000010', '2025-05-25', 15000.00, 2400.00, 17400.00, 'Pagada', 'Seguro'), 
(25, 'V-10000003', '2025-06-01', 7500.00, 1200.00, 8700.00, 'Pagada', 'Efectivo'),


-- Facturas de procedimientos (Corresponden a id_evento 26-30 de Evento_Clinico)
(26, 'V-10000001', '2025-01-12', 300.00, 48.00, 348.00, 'Pagada', 'Seguro'),
(27, 'V-10000002', '2025-01-18', 80.00, 12.80, 92.80, 'Pagada', 'Efectivo'),
(28, 'V-10000005', '2025-02-12', 50.00, 8.00, 58.00, 'Pagada', 'Efectivo'),
(29, 'V-20000003', '2025-03-08', 400.00, 64.00, 464.00, 'Pendiente', NULL),
(30, 'V-20000005', '2025-04-05', 600.00, 96.00, 696.00, 'Pagada', 'Tarjeta');

-- Pagos de seguro
INSERT INTO Pago_Seguro (id_factura, id_afiliacion, monto_cubierto, fecha_pago, numero_autorizacion) VALUES
(1, 1, 174.00, '2025-01-11', 'AUT-001-2025'),
(2, 2, 139.20, '2025-01-16', 'AUT-002-2025'),
(3, 3, 232.00, '2025-01-21', 'AUT-003-2025'),
(4, 4, 208.80, '2025-02-06', 'AUT-004-2025'),
(5, 5, 185.60, '2025-02-11', 'AUT-005-2025'),
(11, 1, 5800.00, '2025-01-26', 'AUT-011-2025'),
(12, 4, 4060.00, '2025-02-09', 'AUT-012-2025'),
(15, 6, 4408.00, '2025-03-19', 'AUT-015-2025'),
(16, 7, 13920.00, '2025-04-03', 'AUT-016-2025'),
(17, 8, 3248.00, '2025-04-13', 'AUT-017-2025'),
(18, 9, 4872.00, '2025-04-21', 'AUT-018-2025'),
(19, 10, 7540.00, '2025-04-26', 'AUT-019-2025'),
(20, 1, 348.00, '2025-01-13', 'AUT-026-2025');
