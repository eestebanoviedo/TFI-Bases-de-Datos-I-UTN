# TFI - Bases de Datos I (UTN)
## Sistema de Gestión de Libros y Fichas Bibliográficas (Solución Híbrida MySQL 8+ / Java JDBC)

**Alumno:** Esteban Oviedo  
**Carrera:** Tecnicatura Universitaria en Programación a Distancia  
**Materia:** Bases de Datos I  
**Dominio:** 2 Entidades con Relación 1:1 Unidireccional (`Libro` $\rightarrow$ `FichaBibliografica`)  

---

## 📁 Estructura del Repositorio

```text
TFI-Bases-de-Datos-I-UTN/
├── docs/
│   ├── INFORME_TFI.md               # Memoria técnica completa para PDF del TFI
│   ├── ANEXO_IA.md                  # Registro pedagógico de interacción con IA (Anexo I)
│   └── GUION_VIDEO_10_15_MIN.md     # Escaleta y guion oral para la defensa en video
├── sql/
│   ├── 01_esquema.sql               # DDL base con PK, FK, UNIQUE, CHECK y dominios
│   ├── 01_pruebas_restricciones.sql # [Auxiliar] Pruebas de inserción válidas y fallidas
│   ├── 02_catalogos.sql             # Catálogos semilla auxiliares para generación
│   ├── 03_carga_masiva.sql          # Poblado masivo de 20.000 registros con SQL puro
│   ├── 03_verificaciones_consistencia.sql # [Auxiliar] Cuadro de control de integridad y conteos
│   ├── 04_indices.sql               # Creación idempotente de índices secundarios
│   ├── 05_consultas.sql             # 4 consultas complejas de negocio (JOIN, GROUP BY, subconsulta)
│   ├── 05_explain.sql               # Benchmarks comparativos CON/SIN índice (EXPLAIN ANALYZE)
│   ├── 06_vistas.sql                # 2 vistas seguras para ocultamiento de información
│   ├── 07_seguridad.sql             # Creación de usuario acotado (usr_biblioteca_app)
│   ├── 07_pruebas_seguridad.sql     # [Auxiliar] Pruebas de operaciones permitidas y denegadas
│   ├── 08_transacciones.sql         # Demostración ACID en SQL (COMMIT y ROLLBACK)
│   └── 09_concurrencia_guiada.sql   # Guía paso a paso para dos sesiones: Deadlocks y Niveles de Aislamiento
├── src/                             # Código Java 21+ con JDBC nativo (Programación II extendido)
│   ├── config.properties            # Configuración de conexión MySQL
│   └── tpi/biblioteca/
│       ├── config/                  # DatabaseConnection
│       ├── entities/                # BaseEntity, Libro, FichaBibliografica
│       ├── dao/                     # Interfaces y DAOs seguros con PreparedStatement
│       ├── service/                 # Servicios transaccionales y lógica de Retry ante Deadlock
│       ├── main/                    # Menú de consola existente de Programación II
│       └── demo/
│           ├── DemoSqlInjection.java # Prueba práctica comparativa anti-inyección SQL
│           └── DemoDeadlockRetry.java# Prueba concurrente multihilo con retry ante error 1213
├── lib/
│   └── mysql-connector-j-9.5.0.jar  # Driver oficial JDBC de MySQL
└── README.md
```

---

## 🚀 Guía de Ejecución de Scripts SQL (En Orden)

Todos los scripts deben ejecutarse en orden contra la base de datos MySQL local:

```bash
# 1. Crear el esquema y restricciones de integridad (Etapa 1)
mysql -u root -p < sql/01_esquema.sql

# 2. (Opcional) Probar restricciones válidas y rechazos (Etapa 1)
mysql -u root -p tpi_biblioteca < sql/01_pruebas_restricciones.sql

# 3. Cargar vocabularios y catálogos semilla (Etapa 2)
mysql -u root -p tpi_biblioteca < sql/02_catalogos.sql

# 4. Ejecutar la carga masiva de 20.000 registros en SQL puro (Etapa 2)
mysql -u root -p tpi_biblioteca < sql/03_carga_masiva.sql

# 5. Ejecutar verificaciones de consistencia (0 huérfanos, cardinalidad 1:1)
mysql -u root -p tpi_biblioteca < sql/03_verificaciones_consistencia.sql

# 6. Crear índices secundarios de optimización (Etapa 3)
mysql -u root -p tpi_biblioteca < sql/04_indices.sql

# 7. Ejecutar consultas analíticas complejas (Etapa 3)
mysql -u root -p tpi_biblioteca < sql/05_consultas.sql

# 8. Ejecutar mediciones comparativas de rendimiento (Etapa 3)
mysql -u root -p tpi_biblioteca < sql/05_explain.sql

# 9. Crear las vistas seguras de ocultamiento (Etapa 4)
mysql -u root -p tpi_biblioteca < sql/06_vistas.sql

# 10. Crear usuario restringido y asignar menores privilegios (Etapa 4)
mysql -u root -p tpi_biblioteca < sql/07_seguridad.sql

# 11. Ejecutar pruebas de acceso como usuario restringido (Etapa 4)
mysql -u usr_biblioteca_app -pAppPass123! tpi_biblioteca < sql/07_pruebas_seguridad.sql

# 12. Ejecutar transacciones SQL de prueba (Etapa 5)
mysql -u root -p tpi_biblioteca < sql/08_transacciones.sql

# 13. Para la simulación interactiva de Deadlock y niveles de aislamiento (Etapa 5):
# Seguir el guion guiado paso a paso en sql/09_concurrencia_guiada.sql en dos terminales simultáneas.
```

---

## ☕ Compilación y Ejecución de Demos en Java

Desde la raíz del proyecto:

### 1. Compilar todo el proyecto:
```bash
javac -cp "lib/mysql-connector-j-9.5.0.jar:src" $(find src -name "*.java")
```

### 2. Ejecutar Demo de Seguridad Anti-SQL Injection (Etapa 4):
```bash
java -cp "lib/mysql-connector-j-9.5.0.jar:src" tpi.biblioteca.demo.DemoSqlInjection
```

### 3. Ejecutar Demo Concurrente de Deadlock con Retry Automático (Etapa 5):
```bash
java -cp "lib/mysql-connector-j-9.5.0.jar:src" tpi.biblioteca.demo.DemoDeadlockRetry
```
