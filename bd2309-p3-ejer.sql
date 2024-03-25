/*
Asignatura: Bases de Datos
Curso: 2022/23
Convocatoria: junio

Practica: P3. Definicion y Modificacion de Datos en SQL

Equipo de practicas: bd2309
 Integrante 1: Christian Matas Conesa
 Integrante 2: Adrian Espín García
*/

--------------------------------------------------------------------------------------
-- EJERCICIO 2. Insertar comentarios de tabla y de columna en el Diccionario de Datos
--a)
COMMENT ON TABLE SOLISTA IS 'Esta tabla contiene el identificador de los solistas, su nombre, su pais de origen (opcional) y una breve biografía sobre ellos (opcional).';
COMMENT ON COLUMN musico.id_musico IS 'Esta columna contiene los identificadores de todos los músicos que son parte de alguna banda.';
COMMENT ON COLUMN musico.nombre IS 'Esta columna contiene los nombres de todos los músicos que son parte de alguna banda.';
COMMENT ON COLUMN musico.banda IS 'Esta columna contiene la banda a la que pertenece el músico.';

--b)
SELECT comments
FROM USER_TAB_COMMENTS 
WHERE table_name = 'SOLISTA';

SELECT comments
FROM USER_COL_COMMENTS
WHERE table_name = 'MUSICO';

--c)
/*
No es una secuencia de definición de datos (LDD) porque no crea, modifica o elimina nada de la base de datos.
Por lo tanto, como no realiza cambios, no tiene implicación desde el punto de vista de las transacciones.
*/


--------------------------------------------------------------------------------------
-- EJERCICIO 3. Modificar valores de una columna
--a)
SELECT U2.id_usuario, U2.nombre, U2.cuota
FROM USUARIO U2
RIGHT JOIN USUARIO U1 ON U2.id_usuario = U1.invitador 
GROUP BY U2.id_usuario, U2.nombre, U2.cuota
HAVING COUNT(*) >= 2
    AND U2.id_usuario IS NOT NULL
    AND U2.nombre IS NOT NULL
    AND U2.cuota IS NOT NULL
ORDER BY U2.nombre;

--b)
UPDATE USUARIO
 SET cuota = cuota*0.95
WHERE id_usuario IN (   SELECT U2.id_usuario
                        FROM USUARIO U2
                        RIGHT JOIN USUARIO U1 ON U2.id_usuario = U1.invitador 
                        GROUP BY U2.id_usuario, U2.nombre, U2.cuota
                        HAVING COUNT(*) >= 2
                            AND U2.id_usuario IS NOT NULL
                            AND U2.nombre IS NOT NULL
                            AND U2.cuota IS NOT NULL);

SELECT U2.id_usuario, U2.nombre, U2.cuota
FROM USUARIO U2
RIGHT JOIN USUARIO U1 ON U2.id_usuario = U1.invitador 
GROUP BY U2.id_usuario, U2.nombre, U2.cuota
HAVING COUNT(*) >= 2
    AND U2.id_usuario IS NOT NULL
    AND U2.nombre IS NOT NULL
    AND U2.cuota IS NOT NULL
ORDER BY U2.nombre;

--c)
ROLLBACK;
SELECT U2.id_usuario, U2.nombre, U2.cuota
FROM USUARIO U2
RIGHT JOIN USUARIO U1 ON U2.id_usuario = U1.invitador 
GROUP BY U2.id_usuario, U2.nombre, U2.cuota
HAVING COUNT(*) >= 2
    AND U2.id_usuario IS NOT NULL
    AND U2.nombre IS NOT NULL
    AND U2.cuota IS NOT NULL
ORDER BY U2.nombre;


--------------------------------------------------------------------------------------
-- EJERCICIO 4. Modificar una clave primaria de manera ordenada. 
--a)
ALTER TABLE USUARIO 
    DISABLE CONSTRAINT usuario_fk_invitador;

ALTER TABLE LISTA 
    DISABLE CONSTRAINT lista_fk_usuario;
    
ALTER TABLE LISTA_CANCION 
    DISABLE CONSTRAINT anadida_a_fk_usuario_lista;

UPDATE USUARIO SET id_usuario = 'U901'
    WHERE id_usuario = 'U001';
    
UPDATE USUARIO SET invitador = 'U901'
    WHERE invitador = 'U001';
    
UPDATE LISTA SET usuario = 'U901'
    WHERE usuario = 'U001';
    
UPDATE LISTA_CANCION SET usuario = 'U901'
    WHERE usuario = 'U001';
    
ALTER TABLE USUARIO 
    ENABLE CONSTRAINT usuario_fk_invitador;

ALTER TABLE LISTA 
    ENABLE CONSTRAINT lista_fk_usuario;
    
ALTER TABLE LISTA_CANCION 
    ENABLE CONSTRAINT anadida_a_fk_usuario_lista;


--------------------------------------------------------------------------------------
-- EJERCICIO 5. Intercambio. 
--a)
SELECT  id_album, titulo, genero
FROM ALBUM
WHERE genero = 'INDIE' 
    OR genero = 'POP';
    
--b)
UPDATE ALBUM SET genero = 'OTRO'
    WHERE id_album IN (SELECT id_album
                        FROM ALBUM
                        WHERE genero = 'INDIE');

UPDATE ALBUM SET genero = 'INDIE'
    WHERE id_album IN (SELECT id_album
                        FROM ALBUM
                        WHERE genero = 'POP');

UPDATE ALBUM SET genero = 'POP'
    WHERE id_album IN (SELECT id_album
                        FROM ALBUM
                        WHERE genero = 'OTRO');
                        
SELECT  id_album, titulo, genero
FROM ALBUM
WHERE genero = 'INDIE' 
    OR genero = 'POP';

--c)
ROLLBACK;

--Si, ha vuelto al estado original, simplemente ha desecho los cambios que le hice a la columna genero.
--Aproveche que ninguna columna de genero tenía el valor de 'OTRO' para usarlo como valor auxiliar, ya que en el enunciado no dice que no se pueda.


--------------------------------------------------------------------------------------
-- EJERCICIO 6. Borrar algunas filas de una tabla. 
--a)
SELECT id_usuario
FROM USUARIO 
WHERE id_usuario NOT IN (SELECT invitador
                     FROM USUARIO
                     WHERE invitador IS NOT NULL)
    AND tipo = 'GRATUITO'
    AND ultimo_acceso < TO_DATE('2019-11-19', 'YYYY-MM-DD')
    AND id_usuario NOT IN ( SELECT usuario
                            FROM LISTA);
                            
DELETE FROM USUARIO
WHERE id_usuario IN (SELECT id_usuario
                     FROM USUARIO 
                     WHERE id_usuario NOT IN (SELECT invitador
                                            FROM USUARIO
                                            WHERE invitador IS NOT NULL)
                        AND tipo = 'GRATUITO'
                        AND ultimo_acceso < TO_DATE('2019-11-19', 'YYYY-MM-DD')
                        AND id_usuario NOT IN ( SELECT usuario
                                                FROM LISTA));
                
                    
            
--------------------------------------------------------------------------------------
-- EJERCICIO 7. Borrar algunas filas de varias tablas. 
--a)     
--B001
DELETE FROM MUSICO_INSTRUMENTO
WHERE musico IN (SELECT id_musico
                     FROM MUSICO
                     WHERE banda = 'B001');

ALTER TABLE BANDA 
    DISABLE CONSTRAINT banda_fk_lider;

DELETE FROM MUSICO  
WHERE banda = 'B001';

DELETE FROM LISTA_CANCION
WHERE album IN (SELECT id_album
                FROM ALBUM
                WHERE banda = 'B001');
                
DELETE FROM CANCION
WHERE album IN (SELECT id_album
                FROM ALBUM
                WHERE banda = 'B001');
                
DELETE FROM ALBUM 
WHERE banda = 'B001';

DELETE FROM BANDA
WHERE id_artista = 'B001';

ALTER TABLE BANDA 
    ENABLE CONSTRAINT banda_fk_lider;
    


--------------------------------------------------------------------------------------
-- EJERCICIO 8. Eliminar algunas columnas. 
--a)
ALTER TABLE SOLISTA
DROP COLUMN pais_origen;

ALTER TABLE SOLISTA
DROP COLUMN bio_breve;

--b) Si que se puede, hay que hacerlo de la siguiente forma:
ALTER TABLE SOLISTA DROP (pais_origen, bio_breve);



--------------------------------------------------------------------------------------
-- EJERCICIO 9. Crear y manipular una vista. 
--a)
CREATE VIEW DATOS_USUARIO AS 
SELECT id_usuario usuario, tipo, cuota, NVL(listas, 0) listas, NVL(canciones, 0) canciones, CAST((SYSDATE - ultimo_acceso) AS INT) desconexion
FROM USUARIO 
    LEFT JOIN ( SELECT usuario u1, COUNT(*) listas
                FROM LISTA 
                GROUP BY usuario) 
    ON id_usuario = u1
    
    LEFT JOIN ( SELECT usuario u2, COUNT(*) canciones
                FROM LISTA_CANCION
                GROUP BY usuario)
    ON id_usuario = u2
WHERE tipo <> 'GRATUITO';

--b)
SELECT *
FROM DATOS_USUARIO;

--c)
CREATE OR REPLACE VIEW DATOS_USUARIO AS
SELECT id_usuario usuario, cuota*1.21 cuota, NVL(listas, 0) listas, NVL(canciones, 0) canciones, CAST((SYSDATE - ultimo_acceso) AS INT) desconexion
FROM USUARIO 
    LEFT JOIN ( SELECT usuario u1, COUNT(*) listas
                FROM LISTA 
                GROUP BY usuario) 
    ON id_usuario = u1
    
    LEFT JOIN ( SELECT usuario u2, COUNT(*) canciones
                FROM LISTA_CANCION
                GROUP BY usuario)
    ON id_usuario = u2
WHERE tipo <> 'GRATUITO';
    
SELECT *
FROM DATOS_USUARIO;

--d)
INSERT INTO USUARIO (id_usuario, nombre, email, telefono, tipo, cuota, invitador, ultimo_acceso)
VALUES ('U007', 'CHRISTIAN', 'chris@mail.com', NULL, 'PREMIUM DOS', 14, NULL, TO_DATE('10/05/2023', 'dd/mm/yyyy'));

--e)
SELECT *
FROM DATOS_USUARIO;
--Si, aparece el nuevo usuario y se le ha aplicado el cambio del 21%, esto se debe a que cuando he hecho el select sobre la vista, esta extrae los datos que hay en ese momento en la tabla y como ya había insertado el nuevo usuario, este se ve reflejado en la vista.



--------------------------------------------------------------------------------------
-- EJERCICIO 10. Crear y cargar una tabla, y modificar (alterar) su estructura 
--a)
CREATE TABLE HITS AS
(SELECT cancion, album, banda artista, cuantas_listas
 FROM ALBUM
    RIGHT JOIN (SELECT cancion, album, COUNT(*) cuantas_listas
                FROM LISTA_CANCION
                GROUP BY album, cancion
                HAVING COUNT(*) >= 2)
    ON id_album = album
 WHERE banda IS NOT NULL) 
UNION
(SELECT cancion, album, solista artista, cuantas_listas
 FROM ALBUM
    RIGHT JOIN (SELECT cancion, album, COUNT(*) cuantas_listas
                FROM LISTA_CANCION
                GROUP BY album, cancion
                HAVING COUNT(*) >= 2)
    ON id_album = album
 WHERE solista IS NOT NULL);

--b)
SELECT *
FROM HITS
ORDER BY cuantas_listas DESC;

--c)
ALTER TABLE HITS ADD(
cuando NUMBER(4) DEFAULT 1972 NOT NULL
);

--d)
UPDATE HITS SET cuando = (SELECT anno
                          FROM ALBUM
                          WHERE id_album = album)
WHERE album IN (SELECT id_album
                FROM ALBUM);
                
SELECT *
FROM HITS
ORDER BY cuantas_listas DESC;


--------------------------------------------------------------------------------------
-- EJERCICIO 11. Restricciones de integridad. 
--a)
--RI1.Todo solista ha de tener al menos un álbum
--RI2.Todo álbum contiene al menos 7 canciones.
--RI3.El líder de una banda ha de ser uno de los músicos que pertenecen a dicha banda

--CREATE ASSERTION RI1
CHECK (NOT EXISTS (SELECT id_artista
                   FROM SOLISTA
                   WHERE id_artista NOT IN (SELECT solista
                                            FROM ALBUM
                                            GROUP BY solista
                                            HAVING COUNT(*)>0)));

--CREATE ASSERTION RI2
CHECK (NOT EXISTS (SELECT album
                  FROM CANCION
                  GROUP BY album
                  HAVING COUNT(*) < 7));

--CREATE ASSERTION RI3
CHECK (NOT EXISTS (SELECT lider
                   FROM BANDA
                   WHERE id_artista NOT IN (SELECT banda 
                                            FROM MUSICO
                                            WHERE id_musico = lider)));





