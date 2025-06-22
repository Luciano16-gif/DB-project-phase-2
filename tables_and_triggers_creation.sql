
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