# TFI - Bases de Datos I (UTN)
## Sistema de Gestión de Libros y Fichas Bibliográficas (MySQL 8+ / Java JDBC)

**Alumno:** Esteban Oviedo  
**Carrera:** Tecnicatura Universitaria en Programación a Distancia  
**Materia:** Bases de Datos I  
**Dominio:** 2 Entidades con Relación 1:1 (`Libro` -> `FichaBibliografica`)  

---

## Estructura del Proyecto

```text
TFI-Bases-de-Datos-I-UTN/
├── docs/
│   ├── INFORME_TFI.md               # Informe técnico completo del trabajo
│   ├── ANEXO_IA.md                  # Registro literal de interacción con IA
│   └── GUION_VIDEO_10_15_MIN.md     # Guion paso a paso para la defensa oral en video
├── sql/
│   ├── 01_esquema.sql               # Creación de tablas, claves y restricciones CHECK
│   ├── 01_pruebas_restricciones.sql # Pruebas de inserciones válidas y de rechazo
│   ├── 02_catalogos.sql             # Listas de autores, editoriales y categorías semilla
│   ├── 03_carga_masiva.sql          # Carga de 20.000 registros usando solo SQL
│   ├── 03_verificaciones_consistencia.sql # Conteo total, huérfanos y estado 1:1
│   ├── 04_indices.sql               # Creación de índices secundarios
│   ├── 05_consultas.sql             # 4 consultas de negocio (JOIN, agrupaciones, subconsulta)
│   ├── 05_explain.sql               # Benchmark de rendimiento con y sin índices
│   ├── 06_vistas.sql                # 2 vistas seguras para ocultar datos
│   ├── 07_seguridad.sql             # Usuario restringido (usr_biblioteca_app)
│   ├── 07_pruebas_seguridad.sql     # Pruebas de permisos permitidos y denegados (Error 1142)
│   ├── 08_transacciones.sql         # Pruebas de transacciones (COMMIT y ROLLBACK)
│   └── 09_concurrencia_guiada.sql   # Guía para dos terminales: Deadlock y Aislamiento
├── src/                             # Código Java con JDBC nativo
│   ├── config.properties            # Datos de conexión a MySQL
│   └── tpi/biblioteca/
│       ├── config/                  # Clase de conexión JDBC
│       ├── entities/                # Entidades Libro y FichaBibliografica
│       ├── dao/                     # Consultas con PreparedStatement
│       ├── service/                 # Lógica de negocio y reintento ante Deadlock
│       ├── main/                    # Menú de consola de Programación II
│       └── demo/
│           ├── DemoSqlInjection.java # Prueba práctica de prevención de SQL Injection
│           └── DemoDeadlockRetry.java# Prueba concurrente con retry ante Error 1213
├── lib/
│   └── mysql-connector-j-9.5.0.jar  # Driver JDBC oficial de MySQL
└── README.md
```

---

## Orden de Ejecución de los Scripts SQL

Todos los scripts se ejecutan en orden desde la consola de MySQL o desde tu cliente preferido:

```bash
# 1. Crear la base de datos y las tablas con sus restricciones (Etapa 1)
mysql -u root -p < sql/01_esquema.sql

# 2. Probar que las restricciones rechacen datos inválidos (Etapa 1)
mysql -u root -p tpi_biblioteca < sql/01_pruebas_restricciones.sql

# 3. Cargar las listas semilla de autores y editoriales (Etapa 2)
mysql -u root -p tpi_biblioteca < sql/02_catalogos.sql

# 4. Generar los 20.000 registros con SQL puro (Etapa 2)
mysql -u root -p tpi_biblioteca < sql/03_carga_masiva.sql

# 5. Comprobar que no haya huérfanos ni duplicados (Etapa 2)
mysql -u root -p tpi_biblioteca < sql/03_verificaciones_consistencia.sql

# 6. Crear los índices secundarios (Etapa 3)
mysql -u root -p tpi_biblioteca < sql/04_indices.sql

# 7. Ejecutar las 4 consultas de negocio (Etapa 3)
mysql -u root -p tpi_biblioteca < sql/05_consultas.sql

# 8. Medir los tiempos con y sin índices con EXPLAIN (Etapa 3)
mysql -u root -p tpi_biblioteca < sql/05_explain.sql

# 9. Crear las dos vistas seguras (Etapa 4)
mysql -u root -p tpi_biblioteca < sql/06_vistas.sql

# 10. Crear el usuario de aplicación usr_biblioteca_app (Etapa 4)
mysql -u root -p tpi_biblioteca < sql/07_seguridad.sql

# 11. Probar los permisos denegados con el usuario de aplicación (Etapa 4)
mysql -u usr_biblioteca_app -pAppPass123! tpi_biblioteca < sql/07_pruebas_seguridad.sql

# 12. Probar operaciones atómicas con COMMIT y ROLLBACK (Etapa 5)
mysql -u root -p tpi_biblioteca < sql/08_transacciones.sql

# 13. Para la simulación de Deadlock y Aislamiento en 2 terminales (Etapa 5):
# Seguir los pasos indicados en sql/09_concurrencia_guiada.sql
```

---

## Cómo Ejecutar las Demos en Java

Desde la carpeta raíz del proyecto:

1. **Compilar el código Java:**
   ```bash
   javac -cp "lib/mysql-connector-j-9.5.0.jar:src" -d bin src/tpi/biblioteca/**/*.java
   ```

2. **Copiar el archivo de configuración a la carpeta bin:**
   ```bash
   cp src/config.properties bin/
   ```

3. **Ejecutar la demostración de SQL Injection (Etapa 4):**
   ```bash
   java -cp "lib/mysql-connector-j-9.5.0.jar:bin" tpi.biblioteca.demo.DemoSqlInjection
   ```

4. **Ejecutar la prueba de Deadlock con Retry automático (Etapa 5):**
   ```bash
   java -cp "lib/mysql-connector-j-9.5.0.jar:bin" tpi.biblioteca.demo.DemoDeadlockRetry
   ```
