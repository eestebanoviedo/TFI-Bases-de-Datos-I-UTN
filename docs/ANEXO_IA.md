# ANEXO IA – REGISTRO DE INTERACCIONES Y PROCESO PEDAGÓGICO
## TFI BASES DE DATOS I – TECNICATURA UNIVERSITARIA EN PROGRAMACIÓN (UTN)

**Estudiante:** Esteban Oviedo  
**Asistente IA:** Antigravity / Gemini  
**Criterio Metodológico:** En concordancia con el Anexo I de la cátedra, la Inteligencia Artificial fue utilizada exclusivamente como tutor pedagógico y guía reflexiva, brindando pistas progresivas y validando razonamientos sin proveer soluciones cerradas en bloque.

---

### ETAPA 1: Modelado y Definición de Constraints

**Prompt Inicial del Estudiante:**
> "Hola. Estoy comenzando la Etapa 1 del TFI de Bases de Datos I. Vengo de Programación II con un sistema de Libros y Fichas Bibliográficas (1 a 1). En MySQL 8 solo tenía claves primarias autoincrementales y una FK en `libro.ficha_id` con `UNIQUE`. ¿Mi elección de claves y restricciones es suficiente o me convendría incorporar restricciones adicionales para garantizar integridad física? Guíame con preguntas o pistas sin darme el código de golpe."

**Respuesta Pedagógica de la IA:**
> "¡Hola! Excelente inicio. Analicemos juntos las reglas del motor relacional:
> 1. Respecto a la clave foránea `ficha_id` con `UNIQUE`, vas por buen camino: eso modela físicamente una relación 1 a 1. Pero pensá: ¿qué ocurre si alguien borra una ficha física? ¿Querés que el libro se borre en cascada o que la referencia quede en NULL?
> 2. Pensemos ahora en el dominio de los atributos. Si alguien inserta un libro con año `3500` o con título vacío `""`, ¿el motor actualmente lo rechazaría o lo guardaría silenciosamente?
> 3. En MySQL 8, las restricciones `CHECK` ya son evaluadas estrictamente. ¿Qué condición matemática o de longitud podrías aplicar sobre `anio_edicion` y sobre `titulo` para evitar datos absurdos?"

**Reflexión y Decisión del Estudiante:**
> "Tiene sentido. Agregué `ON DELETE SET NULL` para no perder los libros si se elimina una ficha física. Además, incorporé restricciones `CHECK`: para el año definí que sea mayor o igual al 868 d.C. (año del Sutra del Diamante) y menor o igual al año corriente (2026). Para el título y el autor utilicé `CHAR_LENGTH(TRIM(columna)) > 0` para evitar espacios en blanco vacíos. Al probar con año 2999, MySQL disparó exitosamente el `Error 3819 (HY000): Check constraint 'chk_libro_anio_valido' is violated`."

---

### ETAPA 2: Carga Masiva con SQL Puro

**Prompt Inicial del Estudiante:**
> "Para la Etapa 2 tengo que generar al menos 10.000 registros repartidos entre libro y ficha bibliográfica usando exclusivamente SQL puro, respetando la relación 1 a 1 y sin usar Java ni scripts de Python externos. ¿Qué estrategia en SQL me recomendás explorar para lograr ese volumen de forma rápida y reproducible?"

**Respuesta Pedagógica de la IA:**
> "Pensemos en los mecanismos nativos de SQL:
> - Una opción es un `WITH RECURSIVE`, pero recordá que MySQL tiene un límite de profundidad (`cte_max_recursion_depth` que por defecto suele ser 1.000).
> - ¿Qué otra operación en SQL combina conjuntos multiplicativamente sin necesidad de recursión? Si creás una tabla temporal con 10 dígitos (del 0 al 9) y hacés un producto cartesiano (`CROSS JOIN`) de esa tabla consigo misma 4 veces, ¿cuántas combinaciones numéricas únicas obtenés?
> - Luego, ¿cómo usarías el operador módulo (`MOD`) para asignar autores y editoriales desde tablas semilla sin que queden todos con el mismo valor?"

**Reflexión y Decisión del Estudiante:**
> "¡Claro! Con 4 tablas de 10 dígitos en producto cartesiano obtengo exactamente $10 \times 10 \times 10 \times 10 = 10.000$ números en milisegundos sin preocuparme por la configuración de la recursión. Para mantener la cardinalidad 1 a 1 estricta, inserté primero las 10.000 fichas con ID del 1 al 10.000 y luego los 10.000 libros forzando `ficha_id = n`. Verifiqué con un `LEFT JOIN` y obtuve exactamente 0 claves huérfanas y 0 duplicados."

---

### ETAPA 3: Consultas Complejas, Índices y Benchmarking

**Prompt Inicial del Estudiante:**
> "Tengo 20.000 registros poblados. Diseñé una consulta para buscar libros por autor (`WHERE autor = 'Jorge Luis Borges'`) y otra por año de edición. Al ejecutar `EXPLAIN ANALYZE` sin índices veo que tarda varios milisegundos y dice 'Table scan'. ¿Cómo debería interpretar el costo y cómo aseguro en la prueba que MySQL use el índice o no lo use?"

**Respuesta Pedagógica de la IA:**
> "Fijate en dos elementos clave del plan de ejecución de MySQL:
> 1. `Table scan` significa que InnoDB debe leer página por página todo el espacio de almacenamiento de la tabla (las 10.000 filas) evaluando la condición fila por fila.
> 2. Si creás un índice B-Tree en `autor`, el motor realiza un `Index lookup`, yendo directamente a las ramas del árbol donde coinciden las claves.
> 3. Para la medición comparativa requerida por la consigna, podés usar las cláusulas del optimizador: `FORCE INDEX (nombre_indice)` para garantizar el camino indexado, y `IGNORE INDEX (nombre_indice)` para forzar el escaneo secuencial y comparar los tiempos reales con la mediana de 3 corridas."

**Reflexión y Decisión del Estudiante:**
> "Apliqué `FORCE INDEX` e `IGNORE INDEX`. Los resultados fueron concluyentes: en la búsqueda de igualdad por autor, el costo bajó de 1418 a 182 y el tiempo de ejecución se redujo de 9.21 ms a 2.34 ms (casi 4 veces más rápido). Comprendí que el índice B-Tree evita examinar las 10.000 páginas de datos de la tabla."

---

### ETAPA 4: Seguridad e Integridad

**Prompt Inicial del Estudiante:**
> "Para la Etapa 4 creé dos vistas para ocultar datos y un usuario acotado. En la parte de Java, mi proyecto anterior de Programación II ya usaba `PreparedStatement`. ¿Cómo demuestro pedagógicamente en la entrega que este código previene un ataque de SQL Injection frente a una consulta concatenada?"

**Respuesta Pedagógica de la IA:**
> "Para demostrarlo con rigor científico y evidencia práctica:
> 1. Diseñá una clase de demostración donde ejecutes la misma entrada del usuario maliciosa (por ejemplo, `' OR '1'='1`) a través de un `Statement` concatenado (`SELECT ... WHERE titulo LIKE '%" + input + "%'`) y luego a través del `PreparedStatement` de tu DAO.
> 2. Analizá qué le sucede al árbol sintáctico del SQL en cada caso: ¿Por qué en el primero la base de datos devuelve miles de registros no autorizados y en el segundo devuelve 0?"

**Reflexión y Decisión del Estudiante:**
> "Creé la clase `DemoSqlInjection.java`. Al pasarle `' OR '1'='1`, la consulta vulnerable con `Statement` alteró la lógica booleana del `WHERE` y devolvió los 9.801 libros de la base. En cambio, con el `PreparedStatement` del DAO, el driver transmitió el parámetro como un literal de búsqueda escapado, retornando 0 registros sin alterar la estructura gramatical del SQL."

---

### ETAPA 5: Concurrencia y Transacciones

**Prompt Inicial del Estudiante:**
> "Estoy con la simulación del Deadlock y el manejo de reintentos. Logré forzar el error 1213 en dos sesiones de terminal haciendo updates cruzados. En Java, ¿cuál es el patrón estándar para implementar el retry con backoff cuando la base de datos aborta una transacción por deadlock?"

**Respuesta Pedagógica de la IA:**
> "Pensemos en el ciclo de vida de la transacción ante una excepción:
> 1. Si capturás una `SQLException`, ¿qué códigos de error identifican inequívocamente al deadlock en MySQL? (Revisá tanto `getErrorCode()` como `getSQLState()`).
> 2. Al ocurrir el deadlock, InnoDB ya ejecutó el rollback de la transacción víctima. ¿Tiene sentido reintentar inmediatamente en el microsegundo 0 o conviene esperar una fracción de segundo para permitir que la otra transacción termine su commit?
> 3. ¿Cómo evitarías un bucle infinito si la contención persiste? Establecé una cantidad máxima de reintentos (ej. 2 reintentos) y multiplicá el tiempo de espera por cada intento fallido (*exponential backoff*)."

**Reflexión y Decisión del Estudiante:**
> "Implementé el método con reintento en `LibroServiceImpl` y lo validé mediante `DemoDeadlockRetry.java`. Capturé el código de error `1213` (o SQLSTATE `'40001'`), apliqué una pausa de espera exponencial (`200 ms * intento`) y logré que el hilo víctima se recuperara automáticamente en el intento #2, completando el 100% de las transacciones con éxito y sin pérdida de consistencia."
