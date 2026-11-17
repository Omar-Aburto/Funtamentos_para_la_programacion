* =============================================================================
* A5 — Limpieza y descriptivos de CASEN
* Autor: Omar Aburto      Fecha: 2026-11-17
* Propósito: Limpieza inicial, creación de variables y descriptivos en Stata
* =============================================================================

* --- 1. Configuración y bitácora (S12S1, Bloques D1 y D5) ---
version 14
clear all
set more off

* Recuerda estar posicionado en la carpeta raíz del proyecto (pwd / cd) antes de correr
capture mkdir "output"
capture log close
log using "output/tarea_a5.log", replace text


* --- 2. Carga e inspección inicial de los datos (S12S1, Bloque E1 / S12S2, Bloque A) ---
import delimited "data/raw/casen_reducido.csv", clear varnames(1) encoding("utf-8")
describe
summarize


* --- 3. Creación y modificación de variables (S12S2, Bloque C) ---
* Experiencia potencial de Mincer: se crea y luego se corrigen posibles negativos con replace
generate experiencia = edad - educ - 6
replace  experiencia = 0 if experiencia < 0

* Variable indicadora de género (1 si es mujer, 0 si es hombre)
generate mujer = (genero == "F")

* Variable indicadora de alta educación (13 o más años), respetando missing si existieran
generate alta_educ = (educ >= 13) if !missing(educ)


* --- 4. Etiquetas de variables y valores (S12S2, Bloque E) ---
label variable experiencia "Experiencia potencial (años)"
label variable mujer       "Indicadora de género (1 = Mujer)"
label variable alta_educ   "Educación superior (13+ años)"

* Etiquetamos los valores de la indicadora mujer
label define mujer_lbl 0 "Hombre" 1 "Mujer"
label values mujer mujer_lbl

* Convertimos sector (texto) en categórica numérica etiquetada (recomendado S12S2)
encode sector, generate(sector_n)


* --- 5. Manejo y explicación de valores faltantes / missing (S12S2, Bloque B) ---
count if missing(ingreso)
count if ingreso > 500000
count if ingreso > 500000 & !missing(ingreso)

/*
   EXPLICACIÓN SOBRE MISSING EN STATA:
   El comando summarize excluye automáticamente los valores faltantes (.) al calcular
   estadísticos como la media o el máximo (por eso reporta Obs = 55 de un total de 60).
   En cambio, al filtrar con expresiones lógicas como "ingreso > 500000", Stata trata
   internamente al punto (.) como un valor numérico mayor que cualquier número real.
   Por ello, si no se añade "& !missing(ingreso)", Stata cuenta erróneamente a las 5
   personas sin dato de ingreso dentro del grupo con ingresos superiores a $500.000.
*/


* --- 6. Estadísticos descriptivos (S12S2, Bloques F y F2) ---
* Resumen de variables numéricas principales
summarize ingreso educ edad experiencia

* Frecuencias de variables categóricas
tabulate sector_n

* Tabla cruzada con porcentajes por fila (educación superior según género)
tabulate mujer alta_educ, row

* Resumen de ingreso por sector económico usando tabstat
tabstat ingreso, by(sector_n) stat(mean sd n)

* Correlación entre ingreso, educación y experiencia (usa observaciones completas)
correlate ingreso educ experiencia

* Guardamos la media de ingreso en un scalar antes de que r() sea sobrescrito
summarize ingreso
scalar media_ingreso = r(mean)
display "Ingreso mensual promedio de la muestra: $" %9.0fc media_ingreso


* --- 7. Cierre de bitácora e interpretación ---
log close

/*
   INTERPRETACIÓN DE LOS DESCRIPTIVOS:
   En la muestra analizada de 60 personas (55 con dato válido de ingreso), el ingreso
   mensual promedio alcanza los $655.291, con una escolaridad media de 12,7 años y una
   experiencia potencial promedio de 25,8 años. Al desagregar por sector económico, los
   mayores ingresos promedio se observan en Educación ($908.857) y Servicios ($788.600),
   mientras que Agricultura presenta el promedio más bajo ($447.846). Asimismo, un mayor
   nivel de escolaridad se asocia positivamente con el ingreso mensual (correlación de
   0,68), mientras que la experiencia potencial muestra una asociación leve y
   negativa (-0,09) en esta muestra descriptiva.
*/