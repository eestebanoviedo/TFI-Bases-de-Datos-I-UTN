# TRABAJO FINAL INTEGRADOR (TFI) - BASES DE DATOS I
## TECNICATURA UNIVERSITARIA EN PROGRAMACIÓN A DISTANCIA (UTN)

**Alumno:** Esteban Oviedo  
**Proyecto:** Sistema de Gestión de Libros y Fichas Bibliográficas (Solución Híbrida MySQL 8+ / Java JDBC)  
**Dominio:** 2 Entidades — Relación 1:1 Unidireccional (`Libro` $\rightarrow$ `FichaBibliografica`)  
**Fecha:** Noviembre 2026  

---

## 1. Introducción y Justificación del Dominio

El presente Trabajo Final Integrador consolida las capacidades de modelado relacional, integridad declarativa, generación masiva de datos en SQL puro, optimización mediante índices, seguridad de accesos bajo el principio de menor privilegio y control de transacciones concurrentes con mitigación de deadlocks.

Se seleccionó el dominio del proyecto de **Programación II**, preservando intactas las dos entidades centrales:
* **`libro`**: Datos bibliográficos de la obra (título, autor, editorial, año de edición).
* **`ficha_bibliografica`**: Datos técnicos y físicos de catalogación (código ISBN-13, clasificación Dewey, estantería física, idioma).

La relación es **1 a 1 estricta y unidireccional**: la tabla `libro` contiene la clave foránea `ficha_id` con restricción de unicidad (`UNIQUE`), garantizando que un libro se vincule como máximo a una ficha y que ninguna ficha pueda ser compartida por más de un libro.

---

## 2. Etapa 1 – Modelado, Esquema y Definición de Restricciones

### 2.1 Modelo Entidad-Relación y Modelo Relacional
* **`ficha_bibliografica`**(`id` [PK], `eliminado`, `isbn` [UQ], `clasificacion_dewey`, `estanteria`, `idioma`)
* **`libro`**(`id` [PK], `eliminado`, `titulo`, `autor`, `editorial`, `anio_edicion`, `ficha_id` [FK, UQ])

### 2.2 Restricciones Implementadas en DDL (`01_esquema.sql`)
1. **Primary Key (PK)**: `pk_ficha_bibliografica` (`id`) y `pk_libro` (`id`) autoincrementales.
2. **Foreign Key (FK)**: `fk_libro_ficha` vinculando `libro.ficha_id` $\rightarrow$ `ficha_bibliografica.id` con `ON DELETE SET NULL` y `ON UPDATE CASCADE`.
3. **Unicidad (UNIQUE)**:
   - `uq_ficha_isbn`: Cada ISBN debe ser irrepetible.
   - `uq_libro_ficha_id`: Impone la cardinalidad 1:1 en el motor relacional.
4. **Restricciones de Validación (CHECK)**:
   - `chk_libro_titulo_no_vacio`: `CHAR_LENGTH(TRIM(titulo)) > 0`.
   - `chk_libro_autor_no_vacio`: `CHAR_LENGTH(TRIM(autor)) > 0`.
   - `chk_libro_anio_valido`: `anio_edicion IS NULL OR (anio_edicion >= 868 AND anio_edicion <= 2026)` (868 d.C., año del Sutra del Diamante, primer libro impreso fechado).
   - `chk_ficha_isbn_formato`: `isbn IS NULL OR CHAR_LENGTH(TRIM(isbn)) >= 10`.
   - `chk_ficha_dewey_no_vacio`: `clasificacion_dewey IS NULL OR CHAR_LENGTH(TRIM(clasificacion_dewey)) > 0`.
   - `chk_ficha_idioma_no_vacio`: `idioma IS NULL OR CHAR_LENGTH(TRIM(idioma)) > 0`.

### 2.3 Validación Práctica de Integridad (`01_pruebas_restricciones.sql`)

| Caso | Operación | Resultado Esperado | Resultado Real Obtenido en MySQL |
| :--- | :--- | :--- | :--- |
| **Válido 1** | Inserción completa libro + ficha | Persistencia correcta | `Query OK, 1 row affected` |
| **Válido 2** | Inserción con opcionales nulos | Persistencia correcta | `Query OK, 1 row affected` |
| **Inválido 1** | Inserción con `anio_edicion = 2999` | Rechazo por `CHECK` | `ERROR 3819 (HY000): Check constraint 'chk_libro_anio_valido' is violated.` |
| **Inválido 2** | Duplicación de ISBN | Rechazo por `UNIQUE` | `ERROR 1062 (23000): Duplicate entry '978-0141439518' for key 'ficha_bibliografica.uq_ficha_isbn'` |
| **Inválido 3** | Asignar misma `ficha_id` a 2do libro | Rechazo por `UNIQUE 1:1` | `ERROR 1062 (23000): Duplicate entry '1' for key 'libro.uq_libro_ficha_id'` |
| **Inválido 4** | Inserción con `ficha_id = 999999` | Rechazo por `FOREIGN KEY` | `ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails` |

---

## 3. Etapa 2 – Carga Masiva con SQL Puro

### 3.1 Descripción Conceptual del Mecanismo Elegido
Para cumplir con la consigna de generar un volumen significativo (superior a los 10.000 registros mínimos) utilizando **exclusivamente mecanismos de SQL**, se implementó una estrategia basada en:
1. **Generación Determinística de Números**: Se utilizó un producto cartesiano (`CROSS JOIN`) de 4 tablas derivadas de 10 dígitos ($0..9$), produciendo una secuencia continua de $10^4 = 10.000$ números enteros ($1..10000$) en apenas 15 milisegundos sin depender de límites de recursión del motor (`cte_max_recursion_depth`).
2. **Catálogos Semilla**: Tablas de referencia auxiliares (`02_catalogos.sql`) con autores canónicos, editoriales históricas, vocabulario para títulos combinatorios, códigos Dewey estandarizados e idiomas.
3. **Mapeo Aritmético Modular (MOD)**: Para asociar de manera uniforme y pseudoaleatoria los atributos categóricos, evitando distribuciones planas y garantizando la coherencia semántica.
4. **Garantía de Cardinalidad 1:1 e Integridad Referencial**:
   - En la primera etapa del script (`03_carga_masiva.sql`), se insertaron 10.000 filas en `ficha_bibliografica` con IDs del 1 al 10.000 y formato ISBN-13 sintético (`CONCAT('978-', LPAD(n, 9, '0'), '-', MOD(n, 10))`).
   - En la segunda etapa, se insertaron 10.000 filas en `libro` asignando de forma unívoca `libro.id = n` y `libro.ficha_id = n`.
   - Esto asegura que **exactamente el 100% de las claves foráneas apunten a fichas válidas**, que **no existan huérfanos**, y que **ninguna ficha sea compartida**.

### 3.2 Cuadro de Verificaciones de Consistencia (`03_verificaciones_consistencia.sql`)

```text
+----------------------------+--------------+--------------+-----------------+
| Verificación               | total_fichas | total_libros | total_acumulado |
+----------------------------+--------------+--------------+-----------------+
| Conteo Total               | 10000        | 10000        | 20000           |
+----------------------------+--------------+--------------+-----------------+
| Claves Foráneas Huérfanas  | 0 huérfanos  |              |                 |
| Duplicados en Relación 1:1 | 0 colisiones |              |                 |
| Rango de Años Válidos      | Min: 1900    | Max: 2019    | Inválidos: 0    |
| Registros Activos          | 9800 (98%)   | Baja lógica  | 200 (2.0%)      |
+----------------------------+--------------+--------------+-----------------+
```

---

## 4. Etapa 3 – Consultas Complejas, Índices y Benchmarking

### 4.1 Utilidad Práctica de las Consultas Diseñadas (`05_consultas.sql`)
1. **Consulta 1 (JOIN 1:1)**: Vincula cada ejemplar activo con su estantería física y clasificación Dewey para la localización rápida de libros en la biblioteca.
2. **Consulta 2 (JOIN + Agregación Multi-tabla)**: Reporte analítico de inventario por código Dewey e idioma, calculando totales y promedios de antigüedad para gestión de adquisiciones.
3. **Consulta 3 (GROUP BY + HAVING)**: Segmenta a las casas editoriales con más de 650 obras en catálogo activo, facilitando convenios y compras institucionales por volumen.
4. **Consulta 4 (Subconsulta Correlacionada)**: Identifica libros cuya fecha de edición supera el año promedio del propio autor, permitiendo destacar las obras de madurez literaria en recomendaciones al público.

### 4.2 Medición Comparativa de Rendimiento con Índices (`05_explain.sql`)

Se realizaron 3 corridas consecutivas en MySQL 9.5 sobre las 10.000 filas por tabla, tomando la **mediana de tiempos** reportada por `EXPLAIN ANALYZE`:

| Tipo de Consulta | Expresión Representativa | Sin Índice (Table Scan) | Con Índice (Index Lookup/Range) | Mejora Observada |
| :--- | :--- | :---: | :---: | :---: |
| **Igualdad** | `WHERE autor = 'Jorge Luis Borges'` | 9.21 ms (`cost=1418`, 10.000 rows leídas) | 2.34 ms (`cost=182`, 400 rows leídas) | **~3.9x más rápida** |
| **Rango** | `WHERE anio_edicion BETWEEN 1970 AND 1980` | 4.09 ms (`cost=1418`, 10.000 rows leídas) | 2.79 ms (`cost=0.71`, escaneo por rango) | **~1.5x más rápida** |
| **JOIN Multi-tabla**| `l.ficha_id = f.id WHERE f.dewey = '823.9'`| 5.88 ms (`cost=1082`, Table scan en `f`) | 2.40 ms (`cost=530`, Index lookup `f`) | **~2.4x más rápida** |

**Conclusión técnica de optimización:**  
En consultas de igualdad y JOIN, el índice secundario transforma un recorrido secuencial de todo el espacio de almacenamiento (`Table scan`) en un acceso logarítmico directo (`Index lookup`), reduciendo el costo estimado en más de un 85% y disminuyendo sustancialmente el I/O en disco.

---

## 5. Etapa 4 – Seguridad e Integridad

### 5.1 Principio de Menor Privilegio (`07_seguridad.sql`)
Se creó el usuario acotado `usr_biblioteca_app` con permisos estrictos de lectura y manipulación de datos sobre el catálogo, denegando comandos destructivos (`DELETE` físico, `DROP`, `ALTER`, `GRANT`):
```sql
GRANT SELECT ON tpi_biblioteca.vista_catalogo_publico TO 'usr_biblioteca_app'@'localhost';
GRANT SELECT ON tpi_biblioteca.vista_estadisticas_editorial TO 'usr_biblioteca_app'@'localhost';
GRANT SELECT, INSERT, UPDATE ON tpi_biblioteca.libro TO 'usr_biblioteca_app'@'localhost';
GRANT SELECT, INSERT, UPDATE ON tpi_biblioteca.ficha_bibliografica TO 'usr_biblioteca_app'@'localhost';
```

### 5.2 Vistas Seguras para Ocultamiento de Información (`06_vistas.sql`)
1. **`vista_catalogo_publico`**: Oculta columnas de baja lógica (`eliminado`), claves primarias técnicas y la ubicación del depósito físico confidencial (`estanteria`).
2. **`vista_estadisticas_editorial`**: Expone datos agregados por editorial sin permitir ver los títulos ni autores individuales.

### 5.3 Pruebas de Acceso Denegado (`07_pruebas_seguridad.sql`)
* **Intento de DELETE**: `ERROR 1142 (42000): DELETE command denied to user 'usr_biblioteca_app'@'localhost' for table 'libro'`
* **Intento de DROP TABLE**: `ERROR 1142 (42000): DROP command denied to user 'usr_biblioteca_app'@'localhost' for table 'libro'`
* **Intento de lectura a `mysql.user`**: `ERROR 1142 (42000): SELECT command denied to user 'usr_biblioteca_app'@'localhost' for table 'user'`

### 5.4 Demostración de Mitigación de SQL Injection en Java (`DemoSqlInjection.java`)
Se probó la entrada maliciosa `' OR '1'='1`:
* **Concatenación con `Statement` vulnerable**:
  Generó `SELECT ... WHERE (titulo LIKE '%' OR '1'='1%')`, evaluando como verdadera la condición para todas las filas y **exponiendo 9.801 registros** ilegítimamente.
* **Consulta con `PreparedStatement` (`JdbcLibroDao`)**:
  El parámetro se transmitió tipado mediante el protocolo binario. La cadena maliciosa se interpretó como valor literal exacto, devolviendo **0 registros** y manteniendo la integridad absoluta de la base.

---

## 6. Etapa 5 – Concurrencia y Transacciones

### 6.1 Simulación de Deadlock en Dos Sesiones (`09_concurrencia_guiada.sql`)
Al ejecutar dos transacciones concurrentes que intentan actualizar los registros `id=1` e `id=2` en orden inverso, InnoDB detecta el ciclo circular de dependencias de bloqueo exclusivo (X-Locks) y aborta a la transacción de menor costo:
```text
ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction
```

### 6.2 Recuperación Automática con Retry y Backoff en Java (`DemoDeadlockRetry.java`)
Se implementó en `LibroServiceImpl` y se probó concurrentemente mediante dos hilos compitiendo por los mismos recursos:
1. El hilo víctima captura la excepción `SQLException` comprobando `e.getErrorCode() == 1213 || "40001".equals(e.getSQLState())`.
2. Aplica un tiempo de espera no lineal (*exponential backoff*, 200 ms).
3. Reintenta la transacción automáticamente (hasta 2 reintentos).
4. **Resultado real obtenido**: 1 Deadlock detectado y gestionado satisfactoriamente; 2/2 transacciones completadas con éxito sin intervención manual ni falla de sistema.

### 6.3 Comparación de Niveles de Aislamiento
* **`READ COMMITTED`**: Cada sentencia `SELECT` genera su propia vista consistente (*read view*). Por ello, si otra transacción modifica y confirma un registro en el intermedio, la transacción lectora observa datos distintos (fenómeno de *Lectura No Repetible*).
* **`REPEATABLE READ`**: La vista consistente se genera en el primer `SELECT` de la transacción. Las modificaciones confirmadas por otras sesiones no alteran el *snapshot* original gracias a los registros de deshacer (*undo logs / MVCC*), garantizando lecturas repetibles.

---

## 7. Conclusiones Generales del Proyecto

1. La combinación de restricciones declarativas (`CHECK`, `UNIQUE`, `FK`) en MySQL 8+ constituye la primera barrera indispensable para la integridad de datos, imposibilitando inconsistencias antes de que lleguen a la capa de almacenamiento.
2. La carga masiva con SQL puro permitió simular un entorno de producción realista de 20.000 filas, revelando la necesidad crítica de indexación en campos de alta selectividad (`autor`, `dewey`).
3. La solución híbrida demuestra que la seguridad debe ser en profundidad: usuarios con menores privilegios en el motor, vistas para ocultar esquemas internos y `PreparedStatement` en Java para neutralizar vectores de inyección.
4. Los deadlocks son un comportamiento natural de los motores transaccionales ACID ante alta concurrencia; implementar un mecanismo de reintento automático con retroceso en la capa de servicio Java garantiza resiliencia y alta disponibilidad del software.
