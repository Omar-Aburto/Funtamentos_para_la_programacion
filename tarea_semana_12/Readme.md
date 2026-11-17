# Fundamentos de Programación para Análisis Económico

* **Estudiante:** Omar Aburto
* **Actividad:** A5 — Do-file de limpieza y descriptivos en Stata (Módulo IV · Semana 12)
* **Datos:** `data/raw/casen_reducido.csv` (muestra de 60 observaciones de la encuesta CASEN)

---

## Estructura del Repositorio

```text
├── data/
│   └── raw/
│       └── casen_reducido.csv    # Base de datos original en formato CSV (UTF-8)
├── scripts/
│   └── tarea_a5.do               # Script reproducible con limpieza, etiquetas y descriptivos
├── output/
│   └── tarea_a5.log              # Bitácora en texto plano con los resultados de la ejecución
└── README.md                     # Documentación general y declaración de autoría
```

---

## ¿Qué hace el código (`scripts/tarea_a5.do`)?

El script ejecuta un flujo completo de análisis reproducible en Stata sin intervención manual, siguiendo las convenciones vistas en clases:

1. **Configuración y bitácora (`version 14`, `clear all`, `log using`):** Fija la versión de Stata, limpia la memoria de trabajo, crea la carpeta `output/` si no existe y abre el registro `output/tarea_a5.log` para documentar toda la sesión.
2. **Carga e inspección (`import delimited`, `describe`, `summarize`):** Importa la base CASEN respetando la codificación `utf-8` para leer tildes y caracteres especiales (`Ñuble`, `Construcción`), e inspecciona los tipos de variables y rangos iniciales.
3. **Creación y modificación de variables (`generate`, `replace`):**
   * Calcula la **experiencia potencial de Mincer** (`edad - educ - 6`) y corrige posibles valores negativos a cero mediante `replace`.
   * Construye las variables indicadoras `mujer` (1 si `genero == "F"`) y `alta_educ` (1 si `educ >= 13`, excluyendo valores faltantes).
4. **Etiquetado (`label variable`, `label define`, `label values`, `encode`):** Documenta las variables creadas con descripciones claras, asigna etiquetas de valor (`0 = Hombre`, `1 = Mujer`) y transforma la variable de texto `sector` en la categórica numérica `sector_n`.
5. **Control de valores faltantes (`missing`):** Verifica los 5 registros sin dato en `ingreso` y documenta el comportamiento interno de Stata (donde `.` se evalúa como mayor que cualquier número real al aplicar filtros con `>`), asegurando el uso de `& !missing(ingreso)`.
6. **Estadísticos descriptivos (`summarize`, `tabulate`, `tabstat`, `correlate`, `scalar`):** Genera tablas de resumen general, frecuencias por sector, cruces porcentuales por fila (`mujer` vs. `alta_educ`), ingresos promedio por sector económico, matriz de correlaciones y almacena el ingreso medio en un `scalar` antes de que se sobrescriba la memoria temporal `r()`.
7. **Cierre e interpretación (`log close`):** Cierra la bitácora y presenta una síntesis descriptiva en pesos chilenos sin lenguaje causal.

---

## Instrucciones de ejecución

1. Abrir Stata y posicionarse en la carpeta raíz del repositorio mediante `cd "ruta/a/tu/proyecto"` (verificar con `pwd`).
2. Abrir `scripts/tarea_a5.do` en el *Do-file Editor* y ejecutar el archivo completo (`Ctrl + D` en Windows / `Cmd + Shift + D` en Mac).
3. Revisar los resultados generados en `output/tarea_a5.log`.

---

## Declaración de autoría y uso de IA
- Herramienta utilizada: Gemini
- Para qué la usé: Recordar la sintaxis específica de comandos en Stata (`encode`, `label values`, `tabstat`, `scalar`), estructurar el flujo del do-file respetando las convenciones vistas en las sesiones 1 y 2 de la Semana 12, y redactar la plantilla de documentación del repositorio.
- Qué hice yo: Personalicé los datos de autoría, configuré el directorio de trabajo en Stata, ejecuté el do-file completo para comprobar que corriera sin errores, generé la bitácora `output/tarea_a5.log` y verifiqué los resultados descriptivos e interpretaciones económicas.
- Verificación: confirmo que entiendo y puedo explicar todo lo que entrego.