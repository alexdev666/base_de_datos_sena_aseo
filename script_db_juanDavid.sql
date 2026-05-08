-- Base de Datos de Juan David Martinez y Daniel Andrade
create database if not exists sena_aseo;
use sena_aseo;

-- --------------------------------------------------------------------
-- ESTAS SERAN LAS TABLAS DE LOS DATOS YA DEFINIDOS / TABLAS MAESTRAS
-- --------------------------------------------------------------------

Create table rol (id_rol int primary key, Roles varchar (40));
    insert into rol () values 
    (1, 'Aprendiz'),
    (2, 'vocero'),
    (3, 'instructor lider'), 
    (4, 'instructor transversal');

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

create table instructor (
    id_instructor int primary key,
    nombres varchar(50) not null, 
    apellidos varchar(50) not null, 
    telefono varchar (17) not null, 
    correo varchar (100) not null,
    clave varchar (255) not null,
    rol int not null, 
    foreign key (rol) references rol(id_rol)
    );

CREATE table imparte(
    id_instructor int not null, 
    id_ficha varchar(30) not null, 
    foreign key (id_instructor) references instructor (id_instructor),
    foreign key (id_ficha) references ficha (numero_ficha)
    );

create table aprendiz (
    id_aprendiz int primary key,
    nombres varchar (50) not null, 
    apellidos varchar (50) not null, 
    telefono varchar (17) not null, 
    correo varchar(100) not null, 
    ficha varchar (30) not null, 
    rol int not null,
    foreign key (rol) references rol(id_rol), 
    foreign key (ficha) references ficha(numero_ficha), 
    unique key (id_aprendiz, ficha) 
    );

create table asistencia (
    id_asistencia int primary key auto_increment, 
    fecha date , 
    ficha varchar (30),
    foreign key (ficha) references ficha (numero_ficha), 
    unique key (fecha, ficha)
    );


-- -----------------------------------------------------------------------------------------------------------
-- ESTA FUNCION ES UN TRIGGER Y SIRVE PARA LLEVAR LA ID DE LA ASISTENCIA, LOS APRENDICES DE LA FICHA PUESTA, 
-- O SEA EL LUGAR DONDE SE VA A TOMAR LA ASISTENCIA
-- -----------------------------------------------------------------------------------------------------------

 DELIMITER $$

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

CREATE TABLE asistencia_aprendiz (
    id_asistencia INT NOT NULL,
    id_aprendiz   INT NOT NULL,
    estado        INT NOT NULL ,
	ficha 		varchar(30) not null,
    PRIMARY KEY (id_asistencia, id_aprendiz),        
    FOREIGN KEY (id_asistencia) REFERENCES asistencia(id_asistencia),
    FOREIGN KEY (id_aprendiz)   REFERENCES aprendiz(id_aprendiz),
    FOREIGN KEY (estado)        REFERENCES estado(id_estado));


 create table salon (
    id_salon varchar (20) primary key, 
    nombre_salon varchar(40) not null 
    );
 
 create table sorteo (
    id_sorteo int primary key auto_increment, 
    aprendices_sorteados int , 
    salon varchar(20) not null, 
    foreign key (salon) references salon (id_salon) 
    );
 
create table turno_realizado (
    id_turno_realizado int primary key auto_increment, 
    estado_aseo int not null, 
    sorteo int not null, 
    id_aprendiz int,
    foreign key (estado_aseo) references estado_aseo (id_estado_aseo),
    foreign key (sorteo) references sorteo (id_sorteo),
    foreign key (id_aprendiz) references aprendiz(id_aprendiz)
    );

CREATE TABLE ciclo_sorteo (
    id_aprendiz INT NOT NULL, 
    ficha VARCHAR(30) NOT NULL, 
    estado_aseo INT NOT NULL DEFAULT 2, 
    ciclo INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_aprendiz, ficha),
    FOREIGN KEY (id_aprendiz) REFERENCES aprendiz(id_aprendiz),
    FOREIGN KEY (ficha) REFERENCES ficha(numero_ficha),
    FOREIGN KEY (estado_aseo) REFERENCES estado_aseo(id_estado_aseo)
);


-- ----------------------------------------------------
-- DATOS INGRESADOS DE MANERA ARBITRARIA PARA TESTEOS
-- ----------------------------------------------------

use sena_aseo;
insert into ficha values
('213',	'tecnico en electricidad',	'2026-04-30',	'2026-11-30',	2,	2),
('222',	'auxiliar en enfermeria',	'2026-04-30',	'2026-09-30',	1,	3),
('231', 'tecnologo en contabilidad',	'2026-04-30',	'2027-04-30',	3,	1),
('3238063',	'Analisis y desarrollo de software',	'2026-04-30',	'2027-04-30',	1,	1),
('432',	'operario en cargas pesadas',	'2026-04-30',	'2026-08-30',	2,	4);

insert into aprendiz (id_aprendiz, nombres, apellidos, telefono, correo, ficha, rol) values
(1010135940,'Daniel','Andrade',3015649852,'daniel.andrade@gmail.com',3238063, 1),
(1070585723,'Juan','Martinez',3105678954,'juan.martinez@gmail.com',3238063, 1),
(1070587388,'Haider','Capera',3154786985,'jose.capera@hotmail.com',3238063, 1);
-- -----------------------------------
-- SECCION DE CODIGO SOBRE EL SORTEO
-- -----------------------------------

DELIMITER //
CREATE PROCEDURE realizar_sorteo(
    IN p_ficha    VARCHAR(30),
    IN p_salon    VARCHAR(20),
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
      AND realizado = 2;

    -- 2. Reset si ya todos pasaron
    IF pendientes = 0 THEN
        UPDATE ciclo_sorteo
        SET realizado = 2,
            ciclo = ciclo + 1
        WHERE ficha = p_ficha;
    END IF;

    -- 3. Crear registro del sorteo
    INSERT INTO sorteo (aprendices_sorteados, salon)
    VALUES (p_cantidad, p_salon);
    SET v_id_sorteo = LAST_INSERT_ID();

    -- 4. Insertar aprendices sorteados filtrando por estado=1 de la sesión actual
    INSERT INTO turno_realizado (realizado, sorteo, id_aprendiz)
    SELECT 1, v_id_sorteo, cs.id_aprendiz
    FROM ciclo_sorteo cs
    INNER JOIN asistencia_aprendiz aa 
        ON cs.id_aprendiz = aa.id_aprendiz
        AND aa.id_asistencia = v_id_asistencia
    WHERE cs.ficha = p_ficha
      AND aa.estado = 1
      AND cs.realizado = 2
    ORDER BY RAND()
    LIMIT p_cantidad;

    -- 5. Marcar como realizado = 1 en ciclo_sorteo
    UPDATE ciclo_sorteo cs
    INNER JOIN turno_realizado tr ON cs.id_aprendiz = tr.id_aprendiz
    SET cs.realizado = 1
    WHERE cs.ficha = p_ficha
      AND tr.sorteo = v_id_sorteo;

    COMMIT; 
    SET SQL_SAFE_UPDATES = 1;

    -- 6. Mostrar sorteados
    SELECT 
        a.id_aprendiz,
        a.nombres,
        a.apellidos,
        cs.ciclo,
        'Sorteado ✓' AS estado_sorteo
    FROM turno_realizado tr
    INNER JOIN aprendiz a ON tr.id_aprendiz = a.id_aprendiz
    INNER JOIN ciclo_sorteo cs 
        ON cs.id_aprendiz = a.id_aprendiz
        AND cs.ficha = p_ficha
    WHERE tr.sorteo = v_id_sorteo;
END //
DELIMITER ;
/*
SELECT * FROM sena_aseo.instructor;
use sena_aseo;
insert into instructor (id_instructor, nombres, apellidos, telefono, correo, clave, rol) values
(11305904, 'Jose', 'Alfonso', 3001009988, 'jalfonso@gmail.com', 'tukiTuki','3238063', 2);
*/
#--------------------------------------------------------------------------------------------------------------
-- SE LLAMA AL PROCEDURE 'realizar_sorteo' con los datos *en orden* de: id_ficha, id_salon, cantidad a sortear
-- ------------------------------------------------------------------------------------------------------------
call realizar_sorteo ('231', 1, 2)