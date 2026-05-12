create database if not exists sena_aseo;
use sena_aseo;

-- --------------------------------------------------------------------
-- ESTAS SERAN LAS TABLAS DE LOS DATOS YA DEFINIDOS / TABLAS MAESTRAS
-- --------------------------------------------------------------------

Create table rol (id_rol int UNSIGNED primary key, Roles varchar (40));
    insert into rol () values 
    (1, 'Administrador'),
    (2, 'Instructor'),
    (3, 'Aprendiz');

create table estado (id_estado int primary key, descripcion_estado varchar (30));
    insert into estado () values 
    (0, ' ' ), 
    (1, 'asistio'), 
    (2, 'no asistio a clase');

create table jornada (id_jornada int primary key, momento_jornada varchar (30));
    insert into jornada () values 
    (1, 'Mañana'),
    (2, 'tarde'),
    (3, 'noche'), 
    (4, 'fines de semana');

create table nivel_de_formacion (id_nivel_formacion int primary key, nivel_formacion varchar (30));
    insert into nivel_de_formacion () values 
    (1, 'tecnologo'), 
    (2, 'tecnico'), 
    (3, 'auxiliar'), 
    (4, 'operario'), 
    (5, 'cursos especiales'), 
    (6, 'cursos complementarios cortos');

create table estado_aseo (
id_estado_aseo int primary key, 
descripcion_realizado varchar(30)
);
    insert into estado_aseo () values 
    (1, 'realizado'), 
    (2, 'no realizado');
    
-- ---------------------------------------------------------
-- APARTIR DE ACA SON TABLAS DE USUARIOS Y FUNCIONALIDADES 
-- ---------------------------------------------------------


CREATE TABLE usuario (
    id_usuario INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,


 
	nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,

   	n_documento VARCHAR(20) NOT NULL UNIQUE,
    n_telefono VARCHAR(20),

    email_correo VARCHAR(150) NOT NULL UNIQUE,
    clave VARCHAR(255),
    estado_usuario BOOLEAN DEFAULT 1,

    id_rol INT UNSIGNED NOT NULL,

    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (id_rol) 
        REFERENCES rol(id_rol)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);



create table ficha (
    numero_ficha varchar(30) primary key unique, 
    Nombre varchar (50) not null, 
    fecha_de_inicio date not null, 
    fecha_de_fin date not null, 
    nivel_de_formacion int not null, 
    jornada int not null,
    foreign key (nivel_de_formacion) references nivel_de_formacion(id_nivel_formacion), 
    foreign key (jornada) references jornada(id_jornada)
    );

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
    ficha varchar(30)  NULL,

    CONSTRAINT fk_aprendiz_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_aprendiz_ficha
        FOREIGN KEY (ficha)
        REFERENCES ficha(numero_ficha)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE instructor_ficha (

    id_instructor INT UNSIGNED NOT NULL,
    ficha varchar(30)  NOT NULL,

    tipo_instructor ENUM('Líder', 'Transversal')
    DEFAULT 'Transversal',

    PRIMARY KEY (id_instructor, ficha),

    CONSTRAINT fk_if_instructor
        FOREIGN KEY (id_instructor)
        REFERENCES instructor(id_instructor)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_if_ficha
        FOREIGN KEY (ficha)
        REFERENCES ficha(numero_ficha)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
    CREATE TABLE historial_vocero (

    id_historial_vocero INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    id_aprendiz INT UNSIGNED NOT NULL,
    ficha varchar(30)  NOT NULL,

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
        FOREIGN KEY (ficha)
        REFERENCES ficha(numero_ficha)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
    );

    create table asistencia (
    id_asistencia int primary key auto_increment, 
    fecha date DEFAULT (CURRENT_DATE), 
    ficha varchar (30),
    foreign key (ficha) references ficha (numero_ficha), 
    unique key (fecha, ficha)
    );

-- -----------------------------------------------------------------------------------------------------------
-- ESTA FUNCION ES UN TRIGGER Y SIRVE PARA LLEVAR LA ID DE LA ASISTENCIA, LOS APRENDICES DE LA FICHA PUESTA, 
-- OSEA EL LUGAR DONDE SE VA A TOMAR LA ASISTENCIA
-- -----------------------------------------------------------------------------------------------------------


DELIMITER //
CREATE TRIGGER poblar_asistencia_aprendiz
AFTER INSERT ON asistencia
FOR EACH ROW
BEGIN
    -- asistencia_aprendiz se llena normal por fecha
    INSERT INTO asistencia_aprendiz (id_asistencia, id_aprendiz, estado, ficha)
    SELECT NEW.id_asistencia, a.id_aprendiz, 0, a.ficha
    FROM aprendiz a
    WHERE a.ficha = NEW.ficha;

    -- ciclo_sorteo solo inserta si el aprendiz no existe aun
    INSERT IGNORE INTO ciclo_sorteo (id_aprendiz, ficha, estado_aseo, ciclo)
    SELECT a.id_aprendiz, a.ficha, 2, 0
    FROM aprendiz a
    WHERE a.ficha = NEW.ficha;
END;
//
DELIMITER ;


-- -----------------------------------------------------------------------------------------------------------
-- fin del trigger
-- -----------------------------------------------------------------------------------------------------------




CREATE TABLE asistencia_aprendiz (
    id_asistencia INT NOT NULL,
    id_aprendiz   INT UNSIGNED NOT NULL,
    estado        INT NOT NULL ,
	ficha 		varchar(30) not null,
    PRIMARY KEY (id_asistencia, id_aprendiz),        
    FOREIGN KEY (id_asistencia) REFERENCES asistencia(id_asistencia),
    FOREIGN KEY (id_aprendiz)   REFERENCES aprendiz(id_aprendiz),
    FOREIGN KEY (estado)        REFERENCES estado(id_estado));


 create table salon (
    id_salon int primary key, 
    nombre_salon varchar(40) not null 
    );
 
 create table sorteo (
    id_sorteo int primary key auto_increment, 
    aprendices_sorteados int , 
    salon int not null, 
    foreign key (salon) references salon (id_salon) 
    );
 
create table turno_realizado (
    id_turno_realizado int primary key auto_increment, 
    estado_aseo int not null, 
    sorteo int not null, 
    id_aprendiz int UNSIGNED not null,
    foreign key (estado_aseo) references estado_aseo (id_estado_aseo),
    foreign key (sorteo) references sorteo (id_sorteo),
    foreign key (id_aprendiz) references aprendiz(id_aprendiz)
    );

CREATE TABLE ciclo_sorteo (
    id_aprendiz INT UNSIGNED NOT NULL, 
    ficha VARCHAR(30) NOT NULL, 
    estado_aseo INT NOT NULL DEFAULT 2, 
    ciclo INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_aprendiz, ficha),
    FOREIGN KEY (id_aprendiz) REFERENCES aprendiz(id_aprendiz),
    FOREIGN KEY (ficha) REFERENCES ficha(numero_ficha),
    FOREIGN KEY (estado_aseo) REFERENCES estado_aseo(id_estado_aseo)
);

-- =================================================================
-- PROCEDURE OTORGADO POR LA IA PARA CREAR USUARIOS AUTOMATICAMENTE
-- =================================================================

DELIMITER $$

CREATE PROCEDURE sp_crear_usuario(
    IN p_nombres VARCHAR(100),
    IN p_apellidos VARCHAR(100),
    IN p_n_documento VARCHAR(20),
    IN p_clave VARCHAR(255),
    IN p_id_rol INT,
    IN p_ficha varchar(30),
    IN p_tipo_instructor VARCHAR(11)
)
BEGIN
    DECLARE v_id_usuario   INT UNSIGNED;
    DECLARE v_id_instructor INT UNSIGNED;

    -- El INSERT dispara los triggers automaticamente
    INSERT INTO usuario (
        nombres, apellidos, n_documento, clave, id_rol
    )
    VALUES (
        p_nombres, p_apellidos, p_n_documento, p_clave, p_id_rol
    );

    SET v_id_usuario = LAST_INSERT_ID();

    -- Si es aprendiz, asignamos la ficha
    IF p_id_rol = 3 AND p_ficha IS NOT NULL THEN
        UPDATE aprendiz
        SET ficha = p_ficha
        WHERE id_usuario = v_id_usuario;
    END IF;

    -- Si es instructor, conectamos a instructor_ficha
    IF p_id_rol = 2 AND p_ficha IS NOT NULL THEN

        -- El trigger ya creo el registro en instructor, solo lo buscamos
        SELECT id_instructor INTO v_id_instructor
        FROM instructor
        WHERE id_usuario = v_id_usuario;

        INSERT INTO instructor_ficha (id_instructor, ficha, tipo_instructor)
        VALUES (v_id_instructor, p_ficha, p_tipo_instructor);

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
-- ----------------------------------------------------
-- DATOS INGRESADOS DE MANERA ARBITRARIA PARA TESTEOS
-- ----------------------------------------------------


-- -----------------------------------
-- SECCION DE CODIGO SOBRE EL SORTEO
-- -----------------------------------

DELIMITER //
CREATE PROCEDURE realizar_sorteo(
    IN p_ficha    VARCHAR(30),
    IN p_salon    int,
    IN p_cantidad INT
)
BEGIN
    DECLARE pendientes INT;
    DECLARE v_id_sorteo INT;
    DECLARE v_id_asistencia INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;                       
        SET SQL_SAFE_UPDATES = 1;         
    END;
    SET SQL_SAFE_UPDATES = 0;
    START TRANSACTION; 

    -- 0. Obtener el último id_asistencia de la ficha
    SELECT MAX(id_asistencia) INTO v_id_asistencia
    FROM asistencia
    WHERE ficha = p_ficha;

    -- 1. Verificar pendientes en ciclo_sorteo
    SELECT COUNT(*) INTO pendientes
    FROM ciclo_sorteo
    WHERE ficha = p_ficha
    AND estado_aseo = 2;

    -- 2. Reset si ya todos pasaron
    IF pendientes = 0 THEN
        UPDATE ciclo_sorteo
        SET estado_aseo = 2,
            ciclo = ciclo + 1
        WHERE ficha = p_ficha;
    END IF;

    -- 3. Crear registro del sorteo
    INSERT INTO sorteo (aprendices_sorteados, salon)
    VALUES (p_cantidad, p_salon);
    SET v_id_sorteo = LAST_INSERT_ID();

    -- 4. Insertar aprendices sorteados filtrando por estado=1 de la sesión actual
    INSERT INTO turno_realizado (estado_aseo, sorteo, id_aprendiz)
    SELECT 1, v_id_sorteo, cs.id_aprendiz
    FROM ciclo_sorteo cs
    INNER JOIN asistencia_aprendiz aa 
        ON cs.id_aprendiz = aa.id_aprendiz
        AND aa.id_asistencia = v_id_asistencia
    WHERE cs.ficha = p_ficha
      AND aa.estado = 1
      AND cs.estado_aseo = 2
    ORDER BY RAND()
    LIMIT p_cantidad;

    -- 5. Marcar como realizado = 1 en ciclo_sorteo
    UPDATE ciclo_sorteo cs
    INNER JOIN turno_realizado tr ON cs.id_aprendiz = tr.id_aprendiz
    SET cs.estado_aseo = 1
    WHERE cs.ficha = p_ficha
      AND tr.sorteo = v_id_sorteo;

    COMMIT; 
    SET SQL_SAFE_UPDATES = 1;

    -- 6. Mostrar sorteados
    SELECT 
        a.id_aprendiz,
        u.nombres,
        u.apellidos,
        cs.ciclo,
        'Sorteado ✓' AS estado_sorteo
    FROM turno_realizado tr
    INNER JOIN aprendiz a ON tr.id_aprendiz = a.id_aprendiz
    INNER JOIN usuario u ON a.id_usuario = u.id_usuario
    INNER JOIN ciclo_sorteo cs 
        ON cs.id_aprendiz = a.id_aprendiz
        AND cs.ficha = p_ficha
    WHERE tr.sorteo = v_id_sorteo;
END //
DELIMITER ;



