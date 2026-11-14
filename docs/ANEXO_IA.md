# ANEXO IA – EVIDENCIA DE USO PEDAGÓGICO DE INTELIGENCIA ARTIFICIAL
## TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)

**Alumno:** Esteban Oviedo  
**Carrera:** Tecnicatura Universitaria en Programación a Distancia  
**Materia:** Bases de Datos I  
**Instrucción de Entrega:** Según las pautas del documento del TFI (Página 3), este anexo debe incluir el texto completo de las interacciones con IA utilizadas como tutoría durante el desarrollo, organizadas por etapa.

> **NOTA DE INTEGRIDAD ACADÉMICA Y AUDITORÍA:**  
> En cumplimiento estricto con las directivas pedagógicas, este documento no contiene conversaciones ficticias ni simuladas. A continuación se presentan las secciones correspondientes a cada etapa, delimitadas con plantillas estructuradas listas para incorporar los registros y exportaciones textuales de los chats mantenidos con los asistentes inteligentes (ChatGPT, Gemini, Claude o Copilot).

---

## ESTRUCTURA DEL PROMPT GENERAL RECOMENDADO POR LA CÁTEDRA (Anexo I)

Para las consultas realizadas a la IA en cada etapa, se toma como marco rector el prompt del Anexo I:
```text
"Estás interactuando con un estudiante de la materia Base de Datos I de una Tecnicatura Superior. 
El estudiante está resolviendo un Trabajo Práctico sobre modelos entidad–relación y modelo relacional.
Instrucciones para la IA:
1. No des la solución completa de manera directa.
2. Ofrece pistas graduales que guíen al estudiante hacia la respuesta correcta.
3. Señala los errores conceptuales o de sintaxis de forma clara y respetuosa.
4. Explica los motivos de cada corrección y, cuando corresponda, da ejemplos similares.
5. Si el estudiante se queda bloqueado, sugiere pasos intermedios o preguntas disparadoras.
6. Utiliza un lenguaje accesible, evitando tecnicismos innecesarios."
```

---

## ETAPA 1 – MODELADO Y DEFINICIÓN DE CONSTRAINTS

### Objetivo Pedagógico de la Interacción:
Consultar sobre la elección de claves primarias, claves foráneas, restricción `UNIQUE` para relación 1 a 1 y restricciones de validación `CHECK` para campos como `anio_edicion` y `titulo`.

### Registro de Interacción:
```text
[PEGAR AQUÍ EL TEXTO COMPLETO DEL CHAT CON IA UTILIZADO PARA LA ETAPA 1]
Fecha de la interacción: [DD/MM/AAAA]
Herramienta de IA utilizada: [ChatGPT / Gemini / Claude / Copilot]

Ejemplo de consulta disparadora:
"Tengo una relación 1 a 1 entre Libro y FichaBibliografica. ¿Es correcto colocar la FK ficha_id en Libro con UNIQUE o convendría poner libro_id en FichaBibliografica? ¿Qué restricciones CHECK recomendás para evitar años absurdos o títulos vacíos?"

Transcripción:
...
```

### Reflexión del Estudiante sobre las Sugerencias Recibidas:
```text
[Sintetizar aquí en 3-5 líneas cómo las respuestas de la IA influyeron en la definición final de constraints de 01_esquema.sql y la decisión de usar ON DELETE SET NULL]
```

---

## ETAPA 2 – GENERACIÓN Y CARGA DE DATOS MASIVOS CON SQL PURO

### Objetivo Pedagógico de la Interacción:
Explorar mecanismos en SQL puro para generar entre 10.000 y 20.000+ registros distribuidos entre dos tablas relacionadas 1 a 1, garantizando integridad referencial (0 huérfanos) sin recurrir a lenguajes externos.

### Registro de Interacción:
```text
[PEGAR AQUÍ EL TEXTO COMPLETO DEL CHAT CON IA UTILIZADO PARA LA ETAPA 2]
Fecha de la interacción: [DD/MM/AAAA]
Herramienta de IA utilizada: [ChatGPT / Gemini / Claude / Copilot]

Ejemplo de consulta disparadora:
"Necesito generar más de 10.000 registros en MySQL con SQL puro respetando una relación 1 a 1 entre dos tablas. ¿Qué diferencia de rendimiento y límites hay entre usar WITH RECURSIVE vs un producto cartesiano de dígitos (CROSS JOIN)? ¿Cómo garantizo que no queden claves foráneas huérfanas?"

Transcripción:
...
```

### Reflexión del Estudiante sobre las Sugerencias Recibidas:
```text
[Sintetizar aquí en 3-5 líneas el análisis de la sugerencia (ej. evitar límites de cte_max_recursion_depth usando producto cartesiano de dígitos y aritmética modular con MOD)]
```

---

## ETAPA 3 – CONSULTAS AVANZADAS, REPORTES E ÍNDICES

### Objetivo Pedagógico de la Interacción:
Consultar sobre la optimización de planes de ejecución, interpretación de `EXPLAIN` / `EXPLAIN ANALYZE` y el impacto de índices B-Tree en consultas de igualdad, rango y JOIN.

### Registro de Interacción:
```text
[PEGAR AQUÍ EL TEXTO COMPLETO DEL CHAT CON IA UTILIZADO PARA LA ETAPA 3]
Fecha de la interacción: [DD/MM/AAAA]
Herramienta de IA utilizada: [ChatGPT / Gemini / Claude / Copilot]

Ejemplo de consulta disparadora:
"Ejecuté EXPLAIN ANALYZE sobre una consulta con WHERE autor = '...' y otra con BETWEEN de años. En una veo 'Table scan' y en otra 'Index lookup'. ¿Qué representa el costo y las filas estimadas en MySQL? ¿Cómo uso FORCE INDEX e IGNORE INDEX para medir con rigor la mediana de 3 corridas?"

Transcripción:
...
```

### Reflexión del Estudiante sobre las Sugerencias Recibidas:
```text
[Sintetizar aquí en 3-5 líneas cómo la IA colaboró en la interpretación de los costos y la justificación técnica de la mejora obtenida en el benchmark]
```

---

## ETAPA 4 – SEGURIDAD E INTEGRIDAD

### Objetivo Pedagógico de la Interacción:
Consultar sobre la implementación del principio de menor privilegio con `CREATE USER` y `GRANT`, diseño de vistas para ocultamiento de datos sensibles y prevención de SQL Injection mediante `PreparedStatement`.

### Registro de Interacción:
```text
[PEGAR AQUÍ EL TEXTO COMPLETO DEL CHAT CON IA UTILIZADO PARA LA ETAPA 4]
Fecha de la interacción: [DD/MM/AAAA]
Herramienta de IA utilizada: [ChatGPT / Gemini / Claude / Copilot]

Ejemplo de consulta disparadora:
"Quiero crear un usuario de base de datos para la aplicación que solo pueda consultar vistas y modificar registros sin permiso de DELETE físico ni DROP. ¿Qué permisos exactos debo darle? Y en Java, ¿cómo explico técnicamente por qué PreparedStatement neutraliza una inyección como ' OR '1'='1?"

Transcripción:
...
```

### Reflexión del Estudiante sobre las Sugerencias Recibidas:
```text
[Sintetizar aquí en 3-5 líneas la aplicación de permisos restringidos en 07_seguridad.sql y la demostración en Java de DemoSqlInjection]
```

---

## ETAPA 5 – CONCURRENCIA Y TRANSACCIONES

### Objetivo Pedagógico de la Interacción:
Consultar sobre el diagnóstico de bloqueos, análisis del Error 1213 / SQLSTATE 40001 (Deadlock) en InnoDB y diseño del algoritmo de reintentos con backoff exponencial en Java.

### Registro de Interacción:
```text
[PEGAR AQUÍ EL TEXTO COMPLETO DEL CHAT CON IA UTILIZADO PARA LA ETAPA 5]
Fecha de la interacción: [DD/MM/AAAA]
Herramienta de IA utilizada: [ChatGPT / Gemini / Claude / Copilot]

Ejemplo de consulta disparadora:
"Estoy probando transacciones concurrentes en dos sesiones MySQL y forcé un Deadlock. ¿Qué criterio usa InnoDB para elegir a la víctima? En Java, ¿cuál es la mejor práctica para capturar el error 1213 y reintentar la transacción con un backoff breve sin bloquear el hilo principal?"

Transcripción:
...
```

### Reflexión del Estudiante sobre las Sugerencias Recibidas:
```text
[Sintetizar aquí en 3-5 líneas la interpretación del error de deadlock y la integración del retry con backoff en LibroServiceImpl y DemoDeadlockRetry]
```
