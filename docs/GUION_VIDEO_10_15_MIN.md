# GUION TÉCNICO Y DEFENSA ORAL EN VIDEO (10 A 15 MINUTOS)
## TFI BASES DE DATOS I – TECNICATURA UNIVERSITARIA EN PROGRAMACIÓN (UTN)

**Estudiante:** Esteban Oviedo  
**Duración Objetivo:** 12 a 14 minutos  
**Herramientas en Pantalla:** Visual Studio Code / IDE, MySQL Workbench / Terminal, Presentación o Diagrama DER.

---

### ESTRUCTURA TEMPORAL Y ESCALETA DEL VIDEO

```
┌──────────────┬────────────────────────────────────────────┬─────────────────────────────┐
│ Minuto       │ Sección / Tema                             │ Pantalla a Mostrar          │
├──────────────┼────────────────────────────────────────────┼─────────────────────────────┤
│ 00:00 - 01:30│ Presentación, Dominio y Arquitectura 1:1   │ DER + Estructura de Proyecto│
│ 01:30 - 03:30│ Etapa 1: DDL, Constraints y Pruebas Error  │ 01_esquema.sql + Terminal   │
│ 03:30 - 05:30│ Etapa 2: Carga Masiva (20k) y Consistencia │ 03_carga_masiva.sql + Conteo│
│ 05:30 - 08:00│ Etapa 3: Consultas y Benchmark con EXPLAIN │ 05_consultas + 05_explain   │
│ 08:00 - 10:30│ Etapa 4: Seguridad, Vistas y Anti-SQL Inj. │ 07_seguridad + Java Demo    │
│ 10:30 - 13:00│ Etapa 5: Concurrencia, Deadlock y Retry    │ 2 Terminales + Java Demo    │
│ 13:00 - 14:00│ Conclusiones finales y Cierre              │ Diapositiva / Conclusiones  │
└──────────────┴────────────────────────────────────────────┴─────────────────────────────┘
```

---

### MINUTO A MINUTO DETALLADO

#### 1. Presentación y Justificación del Dominio (00:00 - 01:30)
* **Qué mostrar:** Diagrama Entidad-Relación y diapositiva inicial con nombre y datos de la materia.
* **Qué decir:**
  > *"Buenas tardes, profesores. Mi nombre es Esteban Oviedo y a continuación presento la defensa oral y práctica de mi Trabajo Final Integrador de Bases de Datos I. Para este trabajo continué con el dominio abordado en Programación II: un sistema de gestión de Libros y Fichas Bibliográficas, modelado con una relación 1 a 1 unidireccional y desarrollado bajo una arquitectura híbrida entre MySQL 8+ y Java con JDBC nativo. El objetivo fue garantizar la integridad de los datos a nivel físico, simular un volumen real con carga masiva en SQL puro, optimizar consultas mediante indexación, proteger el sistema con mínimos privilegios y diseñar servicios transaccionales con tolerancia a fallos por concurrencia."*

---

#### 2. Etapa 1: Esquema, Restricciones y Pruebas de Fallo (01:30 - 03:30)
* **Qué mostrar:** Abrir `sql/01_esquema.sql` y luego ejecutar en terminal `sql/01_pruebas_restricciones.sql`.
* **Qué decir:**
  > *"Comenzando con la Etapa 1, en `01_esquema.sql` definimos las tablas `ficha_bibliografica` y `libro`. Para la relación 1 a 1, la clave foránea `ficha_id` en la tabla `libro` cuenta con una restricción `UNIQUE`, imposibilitando que dos libros apunten a la misma ficha.
  > Además de las claves primarias y foráneas con `ON DELETE SET NULL`, implementamos restricciones `CHECK` evaluadas en el motor: validación de longitud para títulos y autores no vacíos, y un rango histórico coherente para el año de edición (entre 868 y 2026).
  > En pantalla vemos la ejecución de `01_pruebas_restricciones.sql`: las inserciones correctas persisten sin inconvenientes, mientras que las inválidas son rechazadas por el motor con errores específicos: el Error 3819 por violación de la restricción CHECK de año, y el Error 1062 por duplicación de clave única."*

---

#### 3. Etapa 2: Carga Masiva con SQL Puro y Verificación (03:30 - 05:30)
* **Qué mostrar:** Abrir `sql/03_carga_masiva.sql` y ejecutar en MySQL `sql/03_verificaciones_consistencia.sql`.
* **Qué decir:**
  > *"Para la Etapa 2, la consigna exigía generar al menos 10.000 registros utilizando exclusivamente mecanismos nativos de SQL.
  > Diseñamos una estrategia sumamente eficiente basada en el producto cartesiano de 4 conjuntos de 10 dígitos, generando 10.000 números enteros en milisegundos. A partir de tablas semilla y aritmética modular, insertamos 10.000 fichas y 10.000 libros, alcanzando 20.000 registros en total.
  > La integridad referencial y la cardinalidad 1 a 1 se garantizaron asignando `libro.ficha_id = n`.
  > Al ejecutar `03_verificaciones_consistencia.sql`, comprobamos en vivo: 20.000 registros totales, exactamente 0 claves foráneas huérfanas, 0 duplicados en la relación 1 a 1, y un 2% de bajas lógicas para validar posteriormente las consultas y vistas."*

---

#### 4. Etapa 3: Consultas Complejas, Índices y Benchmarking (05:30 - 08:00)
* **Qué mostrar:** Abrir `sql/05_consultas.sql` y luego ejecutar `sql/05_explain.sql`.
* **Qué decir:**
  > *"En la Etapa 3 desarrollamos 4 consultas complejas de valor para el negocio bibliotecario: dos con JOIN vinculando libros y fichas para localización física y análisis de inventario, una con GROUP BY y HAVING para detectar editoriales dominantes con más de 650 obras, y una consulta correlacionada para identificar libros que superan el promedio de año de edición de su autor.
  > Para el análisis de rendimiento con y sin índices, ejecutamos `05_explain.sql` comparando con `EXPLAIN ANALYZE` tres corridas.
  > En la consulta de igualdad por autor, sin índice el motor realiza un `Table scan` completo sobre las 10.000 filas tardando 9.2 milisegundos con un costo de 1418. Con el índice secundario `idx_libro_autor`, el motor realiza un `Index lookup` directo, bajando el tiempo a 2.3 milisegundos y el costo a 182, logrando una aceleración de casi 4 veces."*

---

#### 5. Etapa 4: Seguridad, Vistas y Mitigación de SQL Injection (08:00 - 10:30)
* **Qué mostrar:** Mostrar `sql/07_seguridad.sql`, ejecutar en terminal la prueba de comandos denegados y luego ejecutar la clase Java `DemoSqlInjection.java`.
* **Qué decir:**
  > *"En la Etapa 4 aplicamos el principio de menor privilegio. Creamos el usuario `usr_biblioteca_app`, al cual le otorgamos acceso de lectura a dos vistas seguras (`vista_catalogo_publico` y `vista_estadisticas_editorial`), que ocultan las bajas lógicas, las claves internas y la estantería física del depósito.
  > Si este usuario intenta ejecutar un `DELETE` físico o un `DROP TABLE`, MySQL responde con el `Error 1142: command denied`.
  > En la capa de aplicación, reutilizamos los DAO desarrollados en Java. En `DemoSqlInjection.java` realizamos la prueba comparativa: ante la entrada maliciosa `' OR '1'='1`, una consulta concatenada vulnerable evalúa a verdadero y expone ilegítimamente 9.801 registros. En contraste, nuestro `JdbcLibroDao` con `PreparedStatement` envía el valor como un literal aislado mediante el protocolo binario, devolviendo 0 registros y neutralizando por completo el vector de ataque."*

---

#### 6. Etapa 5: Concurrencia, Deadlock y Retry con Backoff (10:30 - 13:00)
* **Qué mostrar:** Dos ventanas de terminal abiertas simulando Sesión 1 y Sesión 2 (`sql/09_concurrencia_guiada.sql`), y a continuación ejecutar en terminal `DemoDeadlockRetry.java`.
* **Qué decir:**
  > *"Finalmente, en la Etapa 5 analizamos la concurrencia y las transacciones ACID.
  > En primer lugar, demostramos en dos sesiones simultáneas de MySQL cómo se produce un interbloqueo o Deadlock al cruzar actualizaciones sobre dos libros en orden inverso. InnoDB detecta el ciclo de espera circular y emite el `Error 1213: Deadlock found when trying to get lock`.
  > Luego comparamos los niveles de aislamiento: demostramos que en `READ COMMITTED` una transacción lectora puede experimentar lecturas no repetibles si otra transacción confirma cambios intermedios, mientras que en `REPEATABLE READ`, gracias al MVCC de InnoDB y los undo logs, la lectura se mantiene consistente a lo largo de toda la transacción.
  > Para cerrar la integración con Java, ejecutamos `DemoDeadlockRetry.java`. En este test, dos hilos entrelazan sus transacciones forzando el deadlock; el servicio captura el código 1213, aplica una pausa con retroceso exponencial (`backoff`) y reintenta automáticamente la operación, logrando que el 100% de las transacciones finalicen con éxito sin que la aplicación se caiga ni corrompa los datos."*

---

#### 7. Conclusiones y Cierre (13:00 - 14:00)
* **Qué mostrar:** Diapositiva final con resumen de logros y repositorio.
* **Qué decir:**
  > *"Como conclusión, pudimos verificar que la articulación entre una base de datos relacional robusta y una arquitectura de software orientada a servicios permite construir aplicaciones seguras, escalables y resilientes. Cada etapa de la consigna fue cumplida estrictamente sobre datos y pruebas reales en MySQL.
  > Muchas gracias por su atención."*
