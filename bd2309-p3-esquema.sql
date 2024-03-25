/*
Asignatura: Bases de Datos
Curso: 2022/23
Convocatoria: junio

Practica: P3. Definicion y Modificacion de Datos en SQL

Equipo de practicas: bd2309
 Integrante 1: Christian Matas Conesa
 Integrante 2: Adrian Espín García
*/

DROP TABLE MUSICO_INSTRUMENTO CASCADE CONSTRAINTS;
DROP TABLE SOLISTA CASCADE CONSTRAINTS;
DROP TABLE MUSICO CASCADE CONSTRAINTS;
DROP TABLE BANDA CASCADE CONSTRAINTS;
DROP TABLE ALBUM CASCADE CONSTRAINTS;
DROP TABLE LISTA_CANCION CASCADE CONSTRAINTS;
DROP TABLE CANCION CASCADE CONSTRAINTS;
DROP TABLE LISTA CASCADE CONSTRAINTS;
DROP TABLE USUARIO CASCADE CONSTRAINTS;

CREATE TABLE MUSICO(
id_musico CHAR(4) NOT NULL, 
nombre VARCHAR(20) NOT NULL, 

CONSTRAINT musico_pk PRIMARY KEY (id_musico)
);


CREATE TABLE BANDA(
id_artista CHAR(4) NOT NULL,
nombre VARCHAR(20) NOT NULL,
pais_origen VARCHAR(15) NULL,
a_fundacion NUMBER(4) NOT NULL,
lider CHAR(4) NOT NULL,

CONSTRAINT banda_pk PRIMARY KEY(id_artista),
UNIQUE (nombre),
UNIQUE (lider),
CONSTRAINT banda_fk_lider FOREIGN KEY(lider) REFERENCES MUSICO(id_musico)
				-- ON DELETE NO ACTION ON UPDATE CASCADE   
);

ALTER TABLE MUSICO ADD(
banda CHAR(4) NOT NULL,
CONSTRAINT musico_fk_artista FOREIGN KEY (banda) REFERENCES BANDA (id_artista)
				-- ON DELETE NO ACTION ON UPDATE CASCADE
);


CREATE TABLE SOLISTA (
id_artista CHAR(4) NOT NULL, 
nombre VARCHAR(20) NOT NULL, 
pais_origen VARCHAR(15) NULL, 
bio_breve VARCHAR(30) NULL,

CONSTRAINT solista_pk PRIMARY KEY (id_artista),
UNIQUE (nombre)
);


CREATE TABLE ALBUM(
titulo VARCHAR(30) NOT NULL,
anno NUMBER(4) NOT NULL,
genero VARCHAR(9) NOT NULL,
id_album CHAR(4) NOT NULL,
solista CHAR(4) NULL,
banda CHAR(4) NULL,

CONSTRAINT album_pk PRIMARY KEY(id_album),
CONSTRAINT album_fk_solista FOREIGN KEY (solista) REFERENCES SOLISTA(id_artista),
                -- ON DELETE NO ACTION ON UPDATE CASCADE
CONSTRAINT album_pk_banda FOREIGN KEY (banda) REFERENCES BANDA(id_artista),
                -- ON DELETE NO ACTION ON UPDATE CASCADE
CONSTRAINT genero_album CHECK(genero IN ('POP', 'ROCK', 'INDIE', 'K-POP', 'CLASICA', 'LATINO','FLAMENCO','OTRO')),
CONSTRAINT album_solista_o_banda CHECK (((solista IS NOT NULL) AND (banda IS NULL)) OR ((solista IS NULL) AND (banda IS NOT NULL))) 
);


CREATE TABLE CANCION (
album CHAR(4) NOT NULL, 
posicion NUMBER(2) NOT NULL, 
titulo VARCHAR(30) NOT NULL, 
duracion NUMBER(3,2) NOT NULL, 
cuantas_listas NUMBER(1) DEFAULT 0 NOT NULL,

CONSTRAINT cancion_pk PRIMARY KEY (album, posicion),
CONSTRAINT cancion_fk_album FOREIGN KEY (album) REFERENCES ALBUM (id_album),
				-- ON DELETE CASCADE ON UPDATE CASCADE
CONSTRAINT cuantas_listas_ok CHECK (cuantas_listas >= 0),
CONSTRAINT posicion_positivo CHECK (posicion >= 0),
CONSTRAINT duracion_positivo CHECK (duracion >= 0)
);


CREATE TABLE USUARIO (
ultimo_acceso DATE NOT NULL, 
id_usuario CHAR(4) NOT NULL, 
nombre VARCHAR(20) NOT NULL, 
email VARCHAR(20) NULL, 
telefono NUMBER(12) NULL, 
tipo VARCHAR(20) DEFAULT 'GRATUITO' NOT NULL, 
cuota NUMBER(4,2) NOT NULL, 
invitador CHAR(4) NULL,

CONSTRAINT usuario_pk PRIMARY KEY (id_usuario),
UNIQUE (email),
UNIQUE (telefono),
CONSTRAINT usuario_fk_invitador FOREIGN KEY (invitador) REFERENCES USUARIO (id_usuario),
				-- ON DELETE SET NULL ON UPDATE CASCADE
CONSTRAINT tipo_cuenta CHECK(tipo IN ('GRATUITO', 'PREMIUM INDIVIDUAL', 'PREMIUM DOS', 'PREMIUM FAMILIAR')),
CONSTRAINT usuario_email_o_telefono CHECK (((email IS NOT NULL) AND (telefono IS NULL)) OR ((email IS NULL) AND (telefono IS NOT NULL))))
;


CREATE TABLE LISTA(
usuario CHAR(4) NOT NULL,
num_lista NUMBER(1) NOT NULL,
nombre VARCHAR(30) NOT NULL,
descripcion VARCHAR(30) NULL,

CONSTRAINT lista_pk PRIMARY KEY(usuario, num_lista),
CONSTRAINT lista_fk_usuario FOREIGN KEY (usuario) REFERENCES USUARIO(id_usuario),
				-- ON DELETE CASCADE ON UPDATE CASCADE
CONSTRAINT num_lista_positivo CHECK (num_lista >= 0)
);


CREATE TABLE LISTA_CANCION(
usuario CHAR(4) NOT NULL,
lista NUMBER(1) NOT NULL,
album CHAR(4) NOT NULL,
cancion NUMBER(1) NOT NULL,
fecha DATE NOT NULL,
                                            
CONSTRAINT anadida_a_pk PRIMARY KEY(album, cancion, usuario, lista),
CONSTRAINT anadida_a_fk_album_cancion FOREIGN KEY(album, cancion) REFERENCES CANCION(album, posicion),
                -- ON DELETE CASCADE ON UPDATE CASCADE
CONSTRAINT anadida_a_fk_usuario_lista FOREIGN KEY(usuario,lista) REFERENCES LISTA(usuario, num_lista)  
                -- ON DELETE CASCADE ON UPDATE CASCADE  
);

CREATE TABLE MUSICO_INSTRUMENTO (
musico CHAR (4) NOT NULL, 
instrumento VARCHAR(15) NOT NULL,

PRIMARY KEY (musico, instrumento),
FOREIGN KEY (musico) REFERENCES MUSICO (id_musico),
				-- ON DELETE CASCADE ON UPDATE CASCADE
CONSTRAINT instrumento_musico CHECK (instrumento IN ('VOZ', 'GUITARRA', 'BAJO', 'PIANO', 'BATERIA', 'OTRO'))
);
                                          AND L.cancion = C.posicion);