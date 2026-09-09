# Análisis Exploratorio con CASEN - Actividad A2

**Autor:** [Omar Aburto]
**Fecha:** 2026-09-08

## Descripción del Proyecto
Este repositorio contiene el script en R correspondiente 
a la Actividad Formativa A2 (Semana 4).
El código realiza un análisis exploratorio y cálculo de estadísticas
descriptivas sobre una base de datos real (encuesta CASEN)

A través de este script, se demuestra la aplicación práctica de:
1. **Carga de datos:** Uso de rutas relativas para leer archivos `.csv`.

2. **Exploración estructural:** Inspección del dataset antes del análisis 
  usando funciones como `str()`, `head()`, `dim()` y `summary()`.
  
3. **Subsetting lógico:** Filtrado de datos creando subconjuntos mediante
   el uso de condiciones  ( `&` y `|`).
   
4. **Estadísticas descriptivas:** Cálculo de promedios manejando valores perdidos
   con el argumento `na.rm = TRUE`.
   
5. **Análisis económico ("El nivel a la Educación"):** Formulación y respuesta 
   mediante código de una pregunta propia sobre la diferencia de ingresos
   promedio entre personas con educación media completa (12 años) y 
   educación superior (16 años o más).

## Estructura de los Datos
El análisis utiliza un dataset económico real proporcionado en el curso:
* **Archivo:** `casen_reducido.csv` ubicado en la ruta `data/raw/casen_reducido.csv`.
* **Contenido:** Contiene variables sociodemográficas y de ingresos, incluyendo edad, escolaridad y salarios de los encuestados.

## Instrucciones de Uso (Paso a Paso)
Para replicar este análisis exploratorio en tu computador, sigue estas instrucciones:

1. **Abrir RStudio:** Inicia la aplicación RStudio en tu equipo.
2. **Cargar el Proyecto:** Dirígete al menú superior `File` > `Open Project...` y selecciona el archivo `.Rproj` correspondiente a este repositorio.
3. **Abrir el Script:** En el panel inferior derecho (pestaña *Files*), entra a la carpeta `scripts/` y haz doble clic para abrir el archivo `tarea_s4.R`.
4. **Ejecutar el Código:** Sitúa el cursor en la primera línea del script. Presiona consecutivamente `Ctrl + Enter` (en Windows/Linux) o `Cmd + Enter` (en macOS) para correr el código bloque por bloque.
5. **Revisar Resultados:** Observa en la *Consola* (panel inferior izquierdo) cómo se imprimen los resúmenes estadísticos de la CASEN y la comparación final de la brecha de ingresos según los años de educación. Lee los comentarios en el script para entender la interpretación de cada resultado.