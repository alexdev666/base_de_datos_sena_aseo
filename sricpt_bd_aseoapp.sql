-- CREACION DE LA BASE DE DATOS POR: 
-- MR. ROBOT, LA AMIGA DE CHAT Y LOS GALLITOS

CREATE DATABASE IF NOT EXISTS aseo_app_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_spanish_ci;

USE aseo_app_db;

-- NO OLVIDAR LEER CADA COMENTARIO PUESTO
-- 1. TABLAS MAESTRAS O SEA LITERALMENTE PA QUE TODO SIRVA

CREATE TABLE rol (
    id_rol INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE programa_formacion (
    id_programa INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    codigo_programa VARCHAR(50) NOT NULL UNIQUE

) ENGINE=InnoDB;

CREATE TABLE jornada (
    id_jornada INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE ambiente (
    id_ambiente INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    
    nombre_numero VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    ubicacion VARCHAR(100)

) ENGINE=InnoDB;

CREATE TABLE estado_asistencia (
    id_estado_asistencia INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE estado_turno (
    id_estado_turno INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 2. TABLAS PRINCIPALES O SEA LOS PJ

CREATE TABLE usuario (
    id_usuario INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,

    n_documento VARCHAR(20) NOT NULL UNIQUE,
    n_telefono VARCHAR(20),

    email_correo VARCHAR(150) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,

    estado_usuario BOOLEAN DEFAULT 1,

    id_rol INT UNSIGNED NOT NULL,

    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (id_rol) 
        REFERENCES rol(id_rol)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB;

CREATE TABLE ficha (
    id_ficha INT UNSIGNED PRIMARY KEY,
    id_programa INT UNSIGNED NOT NULL,
    nivel_formacion VARCHAR(100) NOT NULL,
    id_jornada INT UNSIGNED NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_finalizacion DATE NOT NULL,

    CONSTRAINT fk_ficha_programa
        FOREIGN KEY (id_programa)
        REFERENCES programa_formacion(id_programa)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_ficha_jornada
        FOREIGN KEY (id_jornada)
        REFERENCES jornada(id_jornada)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB;

CREATE TABLE instructor (
    id_instructor INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    id_usuario INT UNSIGNED NOT NULL UNIQUE,

    CONSTRAINT fk_instructor_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE
        ON DELETE CASCADE

) ENGINE=InnoDB;

CREATE TABLE aprendiz (
    id_aprendiz INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    id_usuario INT UNSIGNED NOT NULL UNIQUE,
    id_ficha INT UNSIGNED NULL,

    CONSTRAINT fk_aprendiz_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_aprendiz_ficha
        FOREIGN KEY (id_ficha)
        REFERENCES ficha(id_ficha)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB;

-- 3. TABLAS DE RELACIONES Y DE CONTROL O SEA LAS INTERMEDIAS O QUE CONECTAN
-- PARA QUE OTRAS SIRVAN EN ESENCIA 

CREATE TABLE instructor_ficha (

    id_instructor INT UNSIGNED NOT NULL,
    id_ficha INT UNSIGNED NOT NULL,

    tipo_instructor ENUM('Líder', 'Transversal')
    DEFAULT 'Transversal',

    PRIMARY KEY (id_instructor, id_ficha),

    CONSTRAINT fk_if_instructor
        FOREIGN KEY (id_instructor)
        REFERENCES instructor(id_instructor)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_if_ficha
        FOREIGN KEY (id_ficha)
        REFERENCES ficha(id_ficha)
        ON UPDATE CASCADE
        ON DELETE CASCADE

) ENGINE=InnoDB;

CREATE TABLE historial_vocero (

    id_historial_vocero INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    id_aprendiz INT UNSIGNED NOT NULL,
    id_ficha INT UNSIGNED NOT NULL,

    fecha_inicio DATE NOT NULL,
    fecha_finalizacion DATE,

    estado_voceria ENUM('Activo', 'Finalizado')
    DEFAULT 'Activo',

    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_hv_aprendiz
        FOREIGN KEY (id_aprendiz)
        REFERENCES aprendiz(id_aprendiz)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_hv_ficha
        FOREIGN KEY (id_ficha)
        REFERENCES ficha(id_ficha)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB;

-- 4. TABLAS OPERATIVAS O SEA LA LOGICA DE AQUI PARA ALLA DE QUIEN VINO Y QUIEN NO
-- Y DE DONDE FUNCIONARA EL SORTEO EN GENERAL

CREATE TABLE asistencia (

    id_asistencia INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    id_aprendiz INT UNSIGNED NOT NULL,

    fecha DATE NOT NULL,

    id_estado_asistencia INT UNSIGNED NOT NULL,

    observacion TEXT,

    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_asistencia_aprendiz
        FOREIGN KEY (id_aprendiz)
        REFERENCES aprendiz(id_aprendiz)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_asistencia_estado
        FOREIGN KEY (id_estado_asistencia)
        REFERENCES estado_asistencia(id_estado_asistencia)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB;

CREATE TABLE turno (

    id_turno INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    id_ficha INT UNSIGNED NOT NULL,

    fecha DATE NOT NULL,

    id_ambiente INT UNSIGNED NOT NULL,

    id_usuario INT UNSIGNED NOT NULL,

    observacion TEXT,

    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_turno_ficha
        FOREIGN KEY (id_ficha)
        REFERENCES ficha(id_ficha)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_turno_ambiente
        FOREIGN KEY (id_ambiente)
        REFERENCES ambiente(id_ambiente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_turno_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB;

CREATE TABLE detalle_turno (

    id_detalle_turno INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    id_turno INT UNSIGNED NOT NULL,

    id_asistencia INT UNSIGNED NOT NULL,

    id_estado_turno INT UNSIGNED NOT NULL
    DEFAULT 3,

    CONSTRAINT fk_dt_turno
        FOREIGN KEY (id_turno)
        REFERENCES turno(id_turno)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_dt_asistencia
        FOREIGN KEY (id_asistencia)
        REFERENCES asistencia(id_asistencia)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_dt_estado
        FOREIGN KEY (id_estado_turno)
        REFERENCES estado_turno(id_estado_turno)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB;

-- INDICES

CREATE INDEX idx_aprendiz_ficha
ON aprendiz(id_ficha);

CREATE INDEX idx_asistencia_fecha
ON asistencia(fecha);

CREATE INDEX idx_turno_fecha
ON turno(fecha);

CREATE INDEX idx_turno_ficha
ON turno(id_ficha);

CREATE INDEX idx_historial_vocero
ON historial_vocero(id_ficha, id_aprendiz);

-- DATOS INICIALES

INSERT INTO rol (nombre)
VALUES
('Administrador'), ('Instructor'), ('Aprendiz');

INSERT INTO jornada (descripcion)
VALUES
('Mañana'), ('Tarde'), ('Noche'), ('Fin de Semana'), ('Mixta');

INSERT INTO estado_asistencia (descripcion)
VALUES
('Asistió'), ('No asistió'), ('Pendiente'), ('Excusa'), ('Retiro Temprano');

INSERT INTO estado_turno (descripcion)
VALUES
('Cumplió'), ('Evadió'), ('Pendiente');

-- =================================================================
-- PROCEDURE OTORGADO POR LA IA PARA CREAR USUARIOS AUTOMATICAMENTE
-- =================================================================

DELIMITER $$

CREATE PROCEDURE sp_crear_usuario(
    IN p_nombres VARCHAR(100),
    IN p_apellidos VARCHAR(100),
    IN p_n_documento VARCHAR(20),
    IN p_n_telefono VARCHAR(20),
    IN p_email VARCHAR(150),
    IN p_contrasena VARCHAR(255),
    IN p_id_rol INT,
    IN p_id_ficha INT UNSIGNED,
    IN p_tipo_instructor VARCHAR(11)
)
BEGIN
    DECLARE v_id_usuario   INT UNSIGNED;
    DECLARE v_id_instructor INT UNSIGNED;

    -- El INSERT dispara los triggers automaticamente
    INSERT INTO usuario (
        nombres, apellidos, n_documento, n_telefono,
        email_correo, contrasena, id_rol
    )
    VALUES (
        p_nombres, p_apellidos, p_n_documento, p_n_telefono,
        p_email, p_contrasena, p_id_rol
    );

    SET v_id_usuario = LAST_INSERT_ID();

    -- Si es aprendiz, asignamos la ficha
    IF p_id_rol = 3 AND p_id_ficha IS NOT NULL THEN
        UPDATE aprendiz
        SET id_ficha = p_id_ficha
        WHERE id_usuario = v_id_usuario;
    END IF;

    -- Si es instructor, conectamos a instructor_ficha
    IF p_id_rol = 2 AND p_id_ficha IS NOT NULL THEN

        -- El trigger ya creo el registro en instructor, solo lo buscamos
        SELECT id_instructor INTO v_id_instructor
        FROM instructor
        WHERE id_usuario = v_id_usuario;

        INSERT INTO instructor_ficha (id_instructor, id_ficha, tipo_instructor)
        VALUES (v_id_instructor, p_id_ficha, p_tipo_instructor);

    END IF;

END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER trg_usuario_instructor
AFTER INSERT ON usuario
FOR EACH ROW
BEGIN

    IF NEW.id_rol = 2 THEN

        INSERT INTO instructor (id_usuario)
        VALUES (NEW.id_usuario);

    END IF;

END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_usuario_aprendiz
AFTER INSERT ON usuario
FOR EACH ROW
BEGIN

    IF NEW.id_rol = 3 THEN

        INSERT INTO aprendiz (id_usuario)
        VALUES (NEW.id_usuario);

    END IF;

END$$

DELIMITER ;