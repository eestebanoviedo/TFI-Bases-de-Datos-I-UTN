# GUION PARA LA DEFENSA EN VIDEO (10 A 15 MINUTOS)
## TFI BASES DE DATOS I – TECNICATURA UNIVERSITARIA EN PROGRAMACIÓN (UTN)

**Alumno:** Esteban Oviedo  
**Duración estimada:** 12 a 13 minutos  
**Herramientas para mostrar en pantalla:**
1. Diapositiva o imagen con el diagrama DER.
2. Editor de código (VS Code) con los scripts SQL y archivos Java.
3. Consola / Terminal conectada a MySQL local (o Workbench / TablePlus).

---

### ESTRUCTURA DEL VIDEO (TIEMPOS RECOMENDADOS)

```text
+---------------+--------------------------------------------+-------------------------------+
| Minuto        | Bloque / Tema                              | Qué mostrar en pantalla       |
+---------------+--------------------------------------------+-------------------------------+
| 00:00 - 01:30 | 1. Presentación y explicación del dominio  | Portada y Diagrama DER        |
| 01:30 - 03:30 | 2. Etapa 1: Tablas, claves y errores CHECK | sql/01_esquema.sql + Terminal |
| 03:30 - 05:30 | 3. Etapa 2: Carga masiva y consistencia    | sql/03_carga_masiva.sql       |
| 05:30 - 08:00 | 4. Etapa 3: Consultas, índices y EXPLAIN   | sql/05_consultas y explain    |
| 08:00 - 10:30 | 5. Etapa 4: Seguridad, vistas y Java demo  | sql/07_seguridad y Java       |
| 10:30 - 13:00 | 6. Etapa 5: Deadlock en 2 terminales y Java| 2 terminales MySQL + Java     |
| 13:00 - 14:00 | 7. Conclusión y cierre                     | Diapositiva final / Resumen   |
+---------------+--------------------------------------------+-------------------------------+
```

---

## GUION PASO A PASO (QUÉ MOSTRAR Y QUÉ DECIR)

### 1. Presentación y Dominio (00:00 a 01:30)

* **En pantalla:** Portada con tus datos y el Diagrama Entidad-Relación (DER).
* **Qué decir:**
> *"Buenas tardes, profesores. Mi nombre es Esteban Oviedo y voy a presentar mi Trabajo Final Integrador de Bases de Datos I.*
> 
> *Para este proyecto continué con el sistema que había desarrollado en Programación II: una biblioteca para gestionar Libros y Fichas Bibliográficas.*
> 
> *El modelo tiene solamente dos tablas: `ficha_bibliografica`, donde guardamos los datos técnicos del ejemplar físico (como ISBN, clasificación Dewey y estantería), y `libro`, donde guardamos los datos de la obra (como título, autor y año de edición).*
> 
> *La relación entre ambas es de 1 a 1 estricta: cada libro tiene una sola ficha, y una ficha no se puede compartir entre varios libros. Para lograr esto a nivel físico en MySQL, pusimos la clave foránea `ficha_id` dentro de la tabla `libro` con una restricción `UNIQUE`.*
> 
> *A lo largo de este video voy a mostrar cómo resolvimos las cinco etapas exigidas por la cátedra directamente sobre nuestra base de datos local."*

---

### 2. Etapa 1: Tablas, Restricciones y Pruebas de Fallo (01:30 a 03:30)

* **En pantalla:** Abrís `sql/01_esquema.sql` en VS Code y luego mostrás la terminal con la salida de `sql/01_pruebas_restricciones.sql`.
* **Qué decir:**
> *"Comenzamos con la Etapa 1. En `01_esquema.sql` creamos las tablas usando el motor InnoDB.*
> 
> *Para asegurar que los datos no se rompan ni queden huérfanos, definimos varias restricciones en el motor:*
> * *Primero, la clave foránea `fk_libro_ficha` tiene `ON DELETE SET NULL`. Esto significa que si por alguna razón damos de baja una ficha física, el registro del libro no se pierde; simplemente queda su campo `ficha_id` en nulo.*
> * *Segundo, pusimos restricciones `CHECK`: validamos que el título y el autor no queden vacíos, y que el año de edición sea coherente, entre el año 868 y el 2026.*
> * *Tercero, pusimos `UNIQUE` tanto en el ISBN como en `ficha_id` para garantizar que no haya duplicados ni fichas repetidas.*
> 
> *Ahora vemos en la terminal las pruebas de `01_pruebas_restricciones.sql`. Cuando insertamos datos correctos, MySQL responde `Query OK`. Pero cuando intentamos cargar un libro con año 2999, MySQL lo frena con el `Error 3819` por violar el CHECK de año. Y si intentamos asignar una misma ficha a dos libros distintos, salta el `Error 1062` de clave duplicada. Con esto comprobamos que la base de datos se protege sola a nivel físico, sin depender de que la aplicación valide bien o mal."*

---

### 3. Etapa 2: Carga Masiva y Verificación de Consistencia (03:30 a 05:30)

* **En pantalla:** Mostrás rápido `sql/03_carga_masiva.sql` y ejecutás en terminal `sql/03_verificaciones_consistencia.sql`.
* **Qué decir:**
> *"En la Etapa 2, la consigna pedía cargar más de 10.000 registros usando exclusivamente SQL puro, sin scripts externos ni código Java.*
> 
> *Para hacerlo de forma rápida y sin trabar el servidor, armamos un generador de números usando un producto cartesiano (`CROSS JOIN`) de cuatro tablas chicas de 10 dígitos. Eso nos genera una secuencia de 10.000 números en apenas milisegundos.*
> 
> *Usando esa serie y tablas de catálogo con autores y editoriales reales, insertamos 10.000 fichas y 10.000 libros. Cada libro se vinculó exactamente con su ficha correspondiente mediante `ficha_id = id`, manteniendo la relación 1 a 1.*
> 
> *En pantalla vemos el resultado de `03_verificaciones_consistencia.sql`: tenemos exactamente 20.002 filas en total (10.001 de cada tabla sumando los datos iniciales), 0 claves foráneas huérfanas, 0 duplicados en la relación 1 a 1, y un 2% de bajas lógicas para poder probar los filtros más adelante."*

---

### 4. Etapa 3: Consultas Complejas, Índices y Rendimiento (05:30 a 08:00)

* **En pantalla:** Mostrás `sql/05_consultas.sql` y la tabla comparativa de `05_explain.sql`.
* **Qué decir:**
> *"En la Etapa 3 diseñamos cuatro consultas útiles para la gestión de la biblioteca:*
> 1. *La primera hace un `JOIN` entre libros y fichas para mostrar qué libros en español tenemos activos y en qué estantería están guardados.*
> 2. *La segunda agrupa por categoría temática e idioma, calculando totales de libros y años promedio de publicación.*
> 3. *La tercera usa `GROUP BY` y `HAVING` para encontrar las editoriales que tienen más de 650 libros en el catálogo.*
> 4. *La cuarta es una subconsulta correlacionada: busca los libros de cada autor que se publicaron después de su año promedio, es decir, sus obras más recientes.*
> 
> *Para la parte de optimización, la consigna exigía comparar el rendimiento con y sin índices, haciendo 3 corridas de cada una y calculando la mediana real.*
> 
> *Tomemos por ejemplo la búsqueda por autor:*
> * *Sin índice, MySQL tiene que revisar las 10.000 filas una por una (`Table scan`). La mediana de tiempo fue de casi 8 milisegundos.*
> * *Cuando creamos el índice secundario `idx_libro_autor`, MySQL va directo a las filas usando una búsqueda indexada (`Index lookup`). El tiempo bajó a 2.4 milisegundos, es decir, más de 3 veces más rápido.*
> 
> *Hicimos las 18 mediciones reales y verificamos los planes con `EXPLAIN ANALYZE`, comprobando cómo el índice reduce el costo de procesamiento del motor."*

---

### 5. Etapa 4: Seguridad, Vistas y Prevención de SQL Injection (08:00 a 10:30)

* **En pantalla:** Mostrás `sql/07_seguridad.sql`, las pruebas de acceso denegado y la ejecución de `DemoSqlInjection.java` en consola.
* **Qué decir:**
> *"En la Etapa 4 aplicamos el principio de menor privilegio. Creamos un usuario específico para la aplicación llamado `usr_biblioteca_app`.*
> 
> *A este usuario no le dimos permisos de administrador ni de borrado físico. Solo le permitimos consultar dos vistas seguras y hacer operaciones básicas sobre libros y fichas.*
> 
> *Las vistas cumplen dos funciones de privacidad: `vista_catalogo_publico` oculta los libros dados de baja, las claves internas y la estantería del depósito; y `vista_estadisticas_editorial` muestra solo números agregados sin exponer títulos individuales.*
> 
> *Si este usuario intenta hacer un `DELETE` directo o borrar una tabla con `DROP TABLE`, MySQL lo rechaza inmediatamente con el `Error 1142: comando denegado`.*
> 
> *Por último, en Java probamos la seguridad frente a SQL Injection con `DemoSqlInjection.java`:*
> * *Si armamos la consulta concatenando texto con `Statement` y el usuario ingresa comillas con `' OR '1'='1`, la consulta se altera, la condición se vuelve siempre verdadera y expone los 9.801 libros de la base.*
> * *En cambio, usando `PreparedStatement` como en nuestro DAO, el valor viaja separado como un dato literal. La base de datos busca literalmente ese texto, no encuentra nada y devuelve 0 filas, evitando que nos alteren la consulta."*

---

### 6. Etapa 5: Concurrencia, Deadlock y Retry en Java (10:30 a 13:00)

* **En pantalla:** Dos terminales abiertas ejecutando paso a paso `sql/09_concurrencia_guiada.sql`, y luego ejecutás `DemoDeadlockRetry.java`.
* **Qué decir:**
> *"En la Etapa 5 trabajamos con transacciones concurrentes y control de bloqueos.*
> 
> *Primero provocamos un Deadlock en vivo usando dos terminales de MySQL:*
> * *En la Terminal 1 abrimos una transacción y modificamos el libro 1.*
> * *En la Terminal 2 abrimos otra transacción y modificamos el libro 2.*
> * *Ahora la Terminal 1 intenta modificar el libro 2, y se queda esperando porque está bloqueado.*
> * *Y cuando la Terminal 2 intenta modificar el libro 1, se produce un ciclo de espera mutua: ninguna puede avanzar.*
> 
> *Ahí vemos cómo InnoDB detecta automáticamente el interbloqueo y cancela una de las dos con el `Error 1213: Deadlock found`.*
> 
> *También comparamos niveles de aislamiento:*
> * *En `READ COMMITTED`, si una sesión modifica un dato y hace commit, la otra sesión ve el cambio en medio de su transacción (lectura no repetible).*
> * *En `REPEATABLE READ`, que es el nivel por defecto de MySQL, la transacción mantiene una foto fija de los datos (gracias al mecanismo MVCC de InnoDB) y no ve cambios ajenos hasta terminar su propia transacción.*
> 
> *Para resolver el problema del Deadlock desde el software, en Java implementamos una política de reintentos con pausa progresiva (`retry con backoff`).*
> 
> *Al ejecutar `DemoDeadlockRetry.java`, dos hilos compiten por los mismos libros en orden cruzado. Cuando uno recibe el error 1213 de MySQL, en lugar de caerse la aplicación, el servicio atrapa la excepción, espera 200 milisegundos y vuelve a intentar la operación. En el segundo intento, como el otro hilo ya liberó los registros, la transacción termina con éxito (2 de 2 completadas)."*

---

### 7. Conclusiones y Cierre (13:00 a 14:00)

* **En pantalla:** Diapositiva con resumen de los puntos clave o el repositorio GitHub.
* **Qué decir:**
> *"Para cerrar, este trabajo integrador nos permitió comprobar en la práctica que el diseño de una base de datos no termina en armar las tablas:*
> * *Las restricciones físicas garantizan que los datos sigan sanos aunque la aplicación falle.*
> * *La carga masiva nos permitió medir con datos reales el impacto positivo de los índices.*
> * *La seguridad con usuarios restringidos y vistas evita accesos indebidos.*
> * *Y el manejo de transacciones con reintento automático hace que el sistema sea tolerante a fallos cuando varios usuarios operan al mismo tiempo.*
> 
> *Todos los scripts y el código Java quedaron organizados y listos para ser reproducidos en orden.*
> 
> *Muchas gracias por su tiempo."*

---

### CHECKLIST RÁPIDA ANTES DE GRABAR EL VIDEO

- [ ] Tener MySQL levantado con la base `tpi_biblioteca` cargada (20.002 registros).
- [ ] Tener dos terminales listas para la prueba de Deadlock.
- [ ] Tener compilado el proyecto Java (`javac -cp "lib/*" -d bin src/tpi/biblioteca/**/*.java`).
- [ ] Tener abierto VS Code con los archivos SQL visibles en el explorador.
- [ ] Mantener un tono tranquilo, hablar pausado y mostrar la pantalla mientras explicás cada punto.
