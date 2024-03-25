/*
Asignatura: Bases de Datos
Curso: 2022/23
Convocatoria: Junio
Identificador: P2
Nombre de la práctica: Consultas en SQL

Practica: P2. Consultas en SQL

Equipo de practicas: 
 Equipo: bd2309
 Integrante 1: Christian Matas Conesa
 Integrante 2: Adrian Espín García
*/

-- EJERCICIOS:

/* Ejercicio 1 de la P2 
Socios que actualmente tienen prestadas (aún no devueltas) películas dirigidas por un
director no estadounidense. Columnas: (nombre, direccion).
*/
SELECT nombre, direccion
FROM SOCIO
WHERE idsocio IN (  SELECT socio
                    FROM PRESTAMO
                    WHERE finalizado = 'NO'
                      AND pelicula IN ( SELECT idpel
                                        FROM PELICULA
                                        WHERE director IN ( SELECT IDDIR
                                                            FROM DIRECTOR 
                                                            WHERE nacionalidad <> 'EEUU')));




/* Ejercicio 2 de la P2 
Lista de todos los socios, con indicación de las copias de las películas de nacionalidad
argentina que han tomado prestadas. Para aquellos socios que no han tomado
prestadas nunca películas argentinas, rellenar la columna titulo con tres guiones: '---' y
copia con un 0. Ordenado por idsocio, titulo y copia. Columnas: (idsocio, nombre,
titulo, copia).
*/                
SELECT idsocio,nombre,NVL(titulo,'---') titulo,NVL(copia,0) copia
FROM SOCIO
     LEFT JOIN( SELECT socio,copia,titulo
                FROM PRESTAMO
                    RIGHT JOIN (SELECT idpel,titulo
                                FROM PELICULA
                                WHERE nacionalidad = 'Argentina')
                    ON pelicula = idpel)          
    ON idsocio = socio
ORDER BY idsocio, titulo, copia
;




/* Ejercicio 3 de la P2 
Intérpretes que han participado en más de 2 películas del director 'WOODY ALLEN',
ordenados alfabéticamente. Columna: (idinter, nombre).
*/
SELECT idinter, nombre
FROM INTERPRETE
WHERE idinter IN (  SELECT interprete
                    FROM REPARTO
                    WHERE pelicula IN ( SELECT idpel
                                        FROM PELICULA
                                        WHERE director IN ( SELECT iddir
                                                            FROM DIRECTOR
                                                            WHERE nombre = 'WOODY ALLEN'))
                    GROUP BY interprete
                    HAVING COUNT(*) > 2)
ORDER BY nombre;




/* Ejercicio 4 de la P2 
Número total de copias de aquellas películas en las que ha actuado algún intérprete
australiano. Columnas: (idpel, titulo, total_copias).
*/
SELECT idpel, titulo, total_copias
FROM PELICULA
     JOIN(  SELECT pelicula, COUNT(*) total_copias
            FROM COPIA
            WHERE pelicula in ( SELECT pelicula
                                FROM REPARTO
                                WHERE interprete in(SELECT IDINTER
                                                    FROM INTERPRETE
                                                    WHERE nacionalidad = 'Australia'))
            GROUP BY pelicula)
            ON idpel = pelicula
;




/* Ejercicio 5 de la P2 
Lista de nombres y nacionalidades respectivas de personas no estadounidenses, que
han dirigido, participado, o ambas cosas, en películas de nacionalidad estadounidense.
Ordenado por nombre. Columnas: (nombre, nacionalidad). 
*/
(SELECT nombre, nacionalidad
FROM INTERPRETE 
WHERE nacionalidad <> 'EEUU'
  AND idinter IN (  SELECT interprete
                    FROM REPARTO
                    WHERE pelicula IN ( SELECT idpel
                                        FROM PELICULA
                                        WHERE nacionalidad = 'EEUU')))
                                        
UNION
(SELECT nombre, nacionalidad
 FROM DIRECTOR 
 WHERE nacionalidad <> 'EEUU'
   AND iddir IN (SELECT director
                 FROM PELICULA
                 WHERE nacionalidad = 'EEUU'));
 
 
 
                
/* Ejercicio 6 de la P2 
Película que más veces ha sido prestada a un mismo socio, indicando a quién ha sido.
Columnas: (titulo, nombre).
*/
SELECT titulo, nombre
FROM PELICULA, SOCIO
WHERE idpel IN  (   SELECT pelicula
                    FROM PRESTAMO
                    GROUP BY pelicula, socio
                    HAVING COUNT(*) = ( SELECT MAX(COUNT(*))
                                        FROM PRESTAMO
                                        GROUP BY pelicula, socio))
    AND idsocio IN (SELECT socio
                    FROM PRESTAMO
                    GROUP BY pelicula, socio
                    HAVING COUNT(*) = ( SELECT MAX(COUNT(*))
                                        FROM PRESTAMO
                                        GROUP BY pelicula, socio));
                                        
                
                
/* Ejercicio 7 de la P2 
Para cada intérprete mostrar el número de ocasiones en las que ha participado en
películas como protagonista y como secundario (nombre, veces_prota, veces_secun),
ordenado por nombre del intérprete. Si un intérprete no ha participado nunca como
protagonista y/o como secundario, debe aparecer un 0 en la columna correspondiente.
*/   
SELECT nombre, NVL(veces_prota, 0) veces_prota, NVL (veces_secun, 0) veces_secun
FROM INTERPRETE
    LEFT JOIN ( SELECT interprete i, COUNT (*) veces_prota    
                FROM REPARTO
                WHERE tipo_papel = 'PROTAGONISTA'
                GROUP BY interprete)
    ON idinter = i
    LEFT JOIN ( SELECT interprete i2, COUNT (*) veces_secun    
                FROM REPARTO
                WHERE tipo_papel = 'SECUNDARIO'
                GROUP BY interprete)
    ON idinter = i2
ORDER BY nombre;




/* Ejercicio 8 de la P2 
Socios que han tomado prestadas todas las películas de la actriz 'CECILIA ROTH'.
Columnas: (idsocio, nombre).
*/
SELECT idsocio, nombre
FROM SOCIO S
WHERE NOT EXISTS (  SELECT socio
                    FROM PRESTAMO T
                    WHERE pelicula IN(  SELECT pelicula
                                        FROM REPARTO 
                                        WHERE interprete IN (   SELECT idinter
                                                                FROM INTERPRETE
                                                                WHERE nombre = 'CECILIA ROTH'))
                        AND NOT EXISTS (SELECT * 
                                        FROM PRESTAMO
                                        WHERE socio = S.idsocio
                                         AND pelicula = T.pelicula));
                                         
                                         
                                         
                                         
/* Ejercicio 9 de la P2 
Socios responsables de aquellos socios que no han devuelto alguna de las películas que
tienen en préstamo. Para aquellos socios que no tengan responsable, mostrar la cadena
'*sin responsable*' en la columna nombre_respo. Ordenado por nombre_socio.
Columnas: (nombre_respo, telef_respo, nombre_socio).
*/
SELECT NVL(S2.nombre, '*sin responsable*') nombre_respo, NVL(S2.telefono, ' ') telef_respo, S.nombre nombre_socio
FROM SOCIO S2
RIGHT JOIN SOCIO S ON S2.idsocio = S.responsable
WHERE S.idsocio IN (SELECT socio
                    FROM PRESTAMO
                    WHERE finalizado = 'NO')
ORDER BY S.nombre;

               


/* Ejercicio 10 de la P2 
Nombre del socio que ha tomado prestadas el mayor número de películas diferentes y
cuántas han sido. Columnas: (nombre, cuantas_peliculas)
*/
SELECT nombre, cuantas_peliculas                          
FROM SOCIO
    RIGHT JOIN( SELECT socio, COUNT(DISTINCT pelicula) cuantas_peliculas
                FROM PRESTAMO
                GROUP BY socio
                HAVING COUNT(DISTINCT pelicula) = ( SELECT MAX(COUNT(DISTINCT pelicula)) 
                                                    FROM PRESTAMO
                                                    GROUP BY socio))
    ON idsocio = socio;
    
    