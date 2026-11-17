* =============================================================================
* Guion Semana 13 · Sesión 1 — Automatización I: macros, resultados guardados,
*                                loops y matrices
* Fundamentos de Programación para Análisis Económico · UdeC-EAN
* =============================================================================
*
* Para qué es este archivo: seguir la clase EN VIVO. Todo el código ya está
*   escrito (no hay huecos). Lo corres bloque a bloque, en el orden de las
*   slides, y comparas con [DEBERÍAS VER].
*
* CÓMO CORRERLO (recap S12)
*   Selecciona líneas y ejecuta:  Windows Ctrl + D  ·  Mac Cmd + Shift + D
*
* ¡OJO, NUEVO EN ESTA SEMANA! Las macros LOCALES viven solo mientras corre el
*   bloque que ejecutaste. Si defines  local lista ...  y después ejecutas
*   OTRA selección que usa `lista', la macro ya no existe y sale vacía.
*   Regla: selecciona SIEMPRE el bloque completo (desde la definición de la
*   macro hasta la última línea que la usa). Cada bloque de este guion está
*   armado para correrse entero.
*
* MARCAS
*   [CORRE Y OBSERVA]  ejecútalo y mira el resultado
*   [PREDICE]          piensa qué saldrá ANTES de ejecutar
*   [SOLO MIRA]        se lee, no se corre
*   [DEBERÍAS VER]     el resultado esperado, para autoverificarte
*
* Datos: data/processed/casen_limpio.dta, la base que guardó el Bloque F del
*   guion S12S2 (CASEN con experiencia, pobre y etiquetas).
* =============================================================================


* -----------------------------------------------------------------------------
* BLOQUE 0 — Preparar la sesión (córrelo entero)
* -----------------------------------------------------------------------------
version 14
clear all
set more off

pwd
* Si no estás en la carpeta del proyecto (S12S1, Bloque 0):
* cd "PON/AQUI/LA/RUTA/DE/TU/PROYECTO"

* Si casen_limpio.dta no existe (no corriste el S12S2), este bloque lo crea.
* capture guarda el código de error en _rc: 0 = todo bien, otro número = falló.
capture confirm file "data/processed/casen_limpio.dta"
if _rc != 0 {
    display "No encontré casen_limpio.dta: lo creo ahora (S12S2, Bloque F)."
    import delimited "data/raw/casen_reducido.csv", clear varnames(1) encoding("utf-8")
    generate experiencia = edad - educ - 6
    replace  experiencia = 0 if experiencia < 0
    generate pobre = (ingreso < 216000) if !missing(ingreso)
    label variable experiencia "Experiencia potencial (años)"
    label define sino 0 "No pobre" 1 "Pobre"
    label values pobre sino
    save "data/processed/casen_limpio.dta", replace
}

use "data/processed/casen_limpio.dta", clear
generate mujer = (genero == "F")          // genero es texto: para la regresión, 0/1
label variable mujer "Mujer (1 = sí)"
describe, short

* [DEBERÍAS VER] Observations: 60 · Variables: 9


* -----------------------------------------------------------------------------
* BLOQUE A — Macros locales: local
* -----------------------------------------------------------------------------

* [CORRE Y OBSERVA] Una macro guarda un texto bajo un nombre. Se evalúa con
* `nombre' : tilde invertida (arriba a la izquierda del teclado) + apóstrofo.
local lista = "educ edad experiencia"
display "La lista es: `lista'"
summarize `lista'

* [DEBERÍAS VER] La lista es: educ edad experiencia, y el summarize de las tres.
*   Stata REEMPLAZA `lista' por su contenido antes de ejecutar la línea:
*   "summarize `lista'" se convierte en "summarize educ edad experiencia".

* [PREDICE] ¿Qué pasa si uso comillas simples rectas en vez de la tilde?
capture noisily summarize 'lista'

* [DEBERÍAS VER] ' invalid name
*   Con dos apóstrofos rectos Stata no reconoce la macro. Es el gotcha #1.

* --- Una lista, muchas regresiones (y filtros con if) ------------------------
* [CORRE Y OBSERVA] Corre las CUATRO líneas juntas.
local controles = "educ experiencia"
regress ingreso `controles'                         // toda la muestra
regress ingreso `controles' if genero == "F"        // solo mujeres
regress ingreso `controles' if genero == "M"        // solo hombres

* [DEBERÍAS VER] tres regresiones: N = 55, 27 y 28.
*   genero es TEXTO: no puede ir como regresor (Stata reclama "string variables
*   may not be used as factor variables"); por eso creamos mujer en el Bloque 0.
*   Si mañana agregas un control, lo cambias en UN lugar y las tres regresiones
*   quedan iguales. Sin la macro, es fácil olvidarlo en una.

* [SOLO MIRA] = o sin =: dos formas de definir una macro
*   local a = 2 + 2      // con = Stata CALCULA: `a' vale 4
*   local b   2 + 2      // sin = Stata guarda el TEXTO: `b' vale "2 + 2"
local a = 2 + 2
local b   2 + 2
display "a = `a'   ·   b = `b'"

* [DEBERÍAS VER] a = 4   ·   b = 2 + 2


* -----------------------------------------------------------------------------
* BLOQUE B — Resultados de un modelo: e()  (r() es recap S12)
* -----------------------------------------------------------------------------
* En R, el resultado de mean() o de lm() lo guardabas en un objeto. En Stata,
* cada comando deja sus resultados en una memoria con nombre:
*   r()  lo dejan los comandos de ESTADÍSTICA  (summarize, tabulate, correlate)
*   e()  lo dejan los comandos de ESTIMACIÓN   (regress, logit, ...)

* --- B1. r() (recap S12) --------------------------------------------------
* [CORRE Y OBSERVA] Lo que dejan summarize, tabulate, count... queda en r().
summarize ingreso, detail
display "p5 = " r(p5) "   ·   mediana = " r(p50) "   ·   p95 = " r(p95)

* [DEBERÍAS VER] p5 = 276000   ·   mediana = 672000   ·   p95 = 975000
*   Y r() se sobrescribe con el siguiente comando de estadística (S12).

* --- B2. e(): lo que deja una estimación -----------------------------------
* [CORRE Y OBSERVA]
regress ingreso educ experiencia mujer
ereturn list

* [DEBERÍAS VER] (entre otros)
*   e(N) = 55 · e(r2) = .4750212879928875 · e(r2_a) = .44414... · e(F) = 15.38...
*   e(depvar) : "ingreso" · e(cmdline) : "regress ingreso educ experiencia mujer"
*   e(b) : 1 x 4 (los coeficientes) · e(V) : 4 x 4 (varianzas y covarianzas)
*   e(sample) (las filas que usó el modelo)

* [CORRE Y OBSERVA] Los coeficientes y sus errores estándar tienen atajos:
display "beta educ = " _b[educ] "   ·   ee = " _se[educ]
display "N = " e(N) "   ·   R2 = " e(r2)
matrix list e(b)

* [DEBERÍAS VER]
*   beta educ = 42245.764   ·   ee = 6355.1872
*   N = 55   ·   R2 = .47502129
*   e(b): educ 42245.764 · experiencia -516.61 · mujer -55685.98 · _cons 158712.82
*   Cada año de educación se ASOCIA a $42.246 más de ingreso mensual, dejando
*   fijas la experiencia y el sexo. No dice que la educación lo cause.

* [CORRE Y OBSERVA] e(sample): las filas que usó la regresión.
summarize ingreso educ if e(sample)

* [DEBERÍAS VER] Obs 55 en las dos: la regresión dejó fuera a las 5 personas
*   sin ingreso. Con if e(sample) describes EXACTAMENTE la muestra del modelo.

* [PREDICE] Ahora corro summarize. ¿Se borra e()? ¿Y r()?
summarize edad
display "e(N) sigue siendo " e(N) "   ·   r(N) ahora es " r(N)

* [DEBERÍAS VER] e(N) sigue siendo 55   ·   r(N) ahora es 60
*   summarize reemplaza r(), pero NO toca e(). e() solo cambia con la
*   siguiente estimación.

* --- B3. Guardar un resultado en una macro antes de que se borre ----------
* [CORRE Y OBSERVA] Winsorizar el ingreso: recortar los extremos a los
* percentiles 5 y 95. Corre el bloque entero.
summarize ingreso, detail
local p5  = r(p5)                 // guardo el percentil 5 ANTES de que se borre
local p95 = r(p95)                // y el 95
generate ingreso_w = ingreso
replace  ingreso_w = `p5'  if ingreso < `p5'  & !missing(ingreso)
replace  ingreso_w = `p95' if ingreso > `p95' & !missing(ingreso)
summarize ingreso ingreso_w

* [DEBERÍAS VER] (2 real changes made) y (2 real changes made):
*   ingreso_w va de 276000 a 975000; la media pasa de 655290.9 a 655581.8 y
*   la desviación estándar baja de 209912.4 a 199988.3.
*   El & !missing(ingreso) del segundo replace es indispensable: sin él, los 5
*   missing (que son MAYORES que 975000, S12) quedarían convertidos en 975000.

* --- B4. Macros con etiquetas: textos y números listos para reportar ------
* [CORRE Y OBSERVA] Corre el bloque entero.
quietly regress ingreso educ experiencia mujer
local n_obs   = e(N)                                  // un número de e()
local r2      = string(e(r2), "%5.3f")                // el R2 como texto, 3 decimales
local etq_exp : variable label experiencia            // LEE la etiqueta de una variable
global fuente "CASEN, muestra del curso (60 personas)"

display "Modelo con `etq_exp' · n = `n_obs' · R2 = `r2'"
display "Fuente: $fuente"

* [DEBERÍAS VER]
*   Modelo con Experiencia potencial (años) · n = 55 · R2 = 0.475
*   Fuente: CASEN, muestra del curso (60 personas)
*
*   local x : variable label v   lleva DOS PUNTOS, no =: es una "función de
*   macro" que pregunta algo a Stata (aquí, la etiqueta). Otras útiles:
*   local t : word count `lista'      (cuántas palabras tiene una lista)
*   local f : value label pobre       (el nombre de la etiqueta de valores)
*   quietly = corre el comando sin mostrar el output (pero guarda e() igual).
*   En la Sesión 2 pegamos estas macros a un modelo guardado (estadd).


* -----------------------------------------------------------------------------
* BLOQUE C — Macros globales: global
* -----------------------------------------------------------------------------
* [CORRE Y OBSERVA]
local  ruta = "data/processed"      // vive solo mientras corre este bloque
global ruta = "data/processed"      // vive toda la sesión de Stata
use "$ruta/casen_limpio.dta", clear
generate mujer = (genero == "F")
display "Cargué la base desde $ruta"

* [DEBERÍAS VER] Cargué la base desde data/processed
*   local  se evalúa con `nombre'   y vive mientras corre el bloque/do-file
*   global se evalúa con $nombre    y vive TODA la sesión de Stata
*
* [PREDICE] Ejecuta SOLO esta línea (sin el bloque de arriba):
display "fuente: $fuente   ·   lista: `lista'"

* [DEBERÍAS VER] la global $fuente del Bloque B4 SIGUE ahí; `lista' sale vacía
*   (si ejecutaste la línea sola). Las globales sobreviven entre ejecuciones y
*   entre do-files: útil para una ruta, peligroso para todo lo demás (otro
*   do-file puede pisarla sin que te enteres). Regla: local por defecto.

macro list fuente ruta

* [DEBERÍAS VER] fuente: CASEN, muestra del curso (60 personas) · ruta: data/processed


* -----------------------------------------------------------------------------
* BLOQUE D — Loops numéricos: forvalues
* -----------------------------------------------------------------------------
* [CORRE Y OBSERVA] Corre las tres líneas juntas (el loop entero).
forvalues i = 1/5 {
    display "Iteración `i'"
}

* [DEBERÍAS VER] Iteración 1 ... Iteración 5

* [CORRE Y OBSERVA] Con saltos: de 0 a 20 de 5 en 5. ¿Cuántas personas hay en
* cada tramo de educación?
forvalues t = 5(5)15 {
    quietly count if educ >= `t' & educ < `t' + 5
    display "Educación de `t' a " `t' + 4 " años: " r(N) " personas"
}

* [DEBERÍAS VER]
*   Educación de 5 a 9 años: 11 personas
*   Educación de 10 a 14 años: 31 personas
*   Educación de 15 a 19 años: 16 personas
*   (count deja el número en r(N). Faltan 2 personas: las de 20 años de
*   educación, fuera del último tramo.)
*   La { va al FINAL de la línea del forvalues; la } va SOLA en su línea.


* -----------------------------------------------------------------------------
* BLOQUE E — Loops sobre listas: foreach
* -----------------------------------------------------------------------------
* [CORRE Y OBSERVA] La misma transformación a varias variables.
foreach v of varlist ingreso educ edad {
    generate log_`v' = log(`v')
    label variable log_`v' "Log de `v'"
}
describe log_*


* [DEBERÍAS VER] (5 missing values generated) solo en log_ingreso, y tres
*   variables nuevas: log_ingreso, log_educ, log_edad, con su etiqueta.

* [CORRE Y OBSERVA] foreach ... in recorre una lista cualquiera de palabras.
foreach s in Agricultura Educación Servicios {
    display "Sector: `s'"
    summarize ingreso if sector == "`s'"
}

* [DEBERÍAS VER] tres summarize: medias 447846.2, 908857.1 y 788600.
*   sector es texto: dentro del if, la macro va entre comillas dobles "`s'".


* -----------------------------------------------------------------------------
* BLOQUE F — Regresiones en loops y matrices
* -----------------------------------------------------------------------------

* --- F1. Una regresión por sector: levelsof + foreach ---------------------
* [CORRE Y OBSERVA] Corre el bloque entero (levelsof crea la macro sectores).
levelsof sector, local(sectores)
foreach s of local sectores {
    quietly regress ingreso educ if sector == "`s'"
    display "`s'" _col(16) "beta educ = " %8.0fc _b[educ] "   n = " e(N)
}

* [DEBERÍAS VER]
*   Agricultura     beta educ =   37,519   n = 13
*   Comercio        beta educ =   24,487   n = 6
*   Construcción    beta educ =   23,783   n = 5
*   Educación       beta educ =   37,368   n = 7
*   Industria       beta educ =   42,713   n = 9
*   Servicios       beta educ =   32,308   n = 15
*   levelsof guarda en una macro los valores DISTINTOS de una variable.
*   _col(16) alinea en la columna 16; %8.0fc da formato con separador de miles.
*   Con 5 a 15 personas por sector, estos coeficientes son muy imprecisos: el
*   loop es útil, pero no vuelve más grande la muestra.

* --- F2. Guardar los resultados del loop en una matriz: J() --------------
* En F2 los resultados salieron en pantalla y se perdieron. Una matriz los
* guarda para usarlos después (exportarlos a Excel en la Sesión 2).
*
* J(filas, columnas, valor) crea una matriz llena con ese valor. Es el
* matrix(NA, nrow = 6, ncol = 3) de R.
*
* [CORRE Y OBSERVA] Corre el bloque ENTERO, desde levelsof hasta matrix list.
levelsof sector, local(sectores)
local k : word count `sectores'          // cuántos sectores hay
matrix R = J(`k', 3, .)                  // k filas, 3 columnas, todo missing

local i = 1                               // contador de fila
foreach s of local sectores {
    quietly regress ingreso educ if sector == "`s'"
    matrix R[`i', 1] = _b[educ]           // fila i, columna 1: el coeficiente
    matrix R[`i', 2] = _se[educ]          // columna 2: su error estándar
    matrix R[`i', 3] = e(N)               // columna 3: cuántas personas
    local i = `i' + 1                     // pasar a la fila siguiente
}

matrix colnames R = beta_educ ee n
matrix rownames R = `sectores'
matrix list R, format(%9.0f)

* [DEBERÍAS VER]
*                beta_educ    ee    n
*   Agricultura      37519  7556   13
*   Comercio         24487  8529    6
*   Construcción     23783 14122    5
*   Educación        37368 12642    7
*   Industria        42713 14514    9
*   Servicios        32308  7924   15
*
*   R[fila, columna] lee o escribe UNA celda. Prueba:
display "Industria: " R[5, 1] " pesos por año de educación"

* [DEBERÍAS VER] Industria: 42712.644 pesos por año de educación
*   La matriz sobrevive al loop: en la Sesión 2 la mandamos a Excel.
*   Construcción (n = 5) tiene el error estándar más grande: con tan pocas
*   personas, su coeficiente es el menos confiable de la tabla.


* -----------------------------------------------------------------------------
* BLOQUE G — Ejemplo integrador: descriptivos automatizados
* -----------------------------------------------------------------------------
* [CORRE Y OBSERVA] Corre el bloque entero.
use "data/processed/casen_limpio.dta", clear

local numericas = "ingreso educ edad experiencia"   // una sola fuente de verdad

foreach v of local numericas {
    display _newline "===== `v' ====="
    summarize `v', detail
}

* [DEBERÍAS VER] cuatro summarize, detail seguidos. Cambia la lista numericas
*   y el reporte completo se regenera.


* -----------------------------------------------------------------------------
* CIERRE — lo que nos llevamos hoy
* -----------------------------------------------------------------------------
*   local x = ... / `x'        guardar y evaluar (vive mientras corre el bloque)
*   global x ... / $x          vive toda la sesión: solo para rutas
*   e() / ereturn list         resultados de regress: e(N), e(r2), e(b)
*   _b[x] / _se[x]             coeficiente y error estándar de x
*   if e(sample)               las filas que usó el último modelo
*   local x : variable label   leer etiquetas y metadatos
*   forvalues / foreach        repetir sobre un rango o una lista
*   levelsof v, local(m)       los valores distintos de v, en una macro
*   matrix R = J(f, c, .)      una matriz vacía para llenar en un loop
*
* Sesión 2: programas, combinar bases (tempfile + merge) y guardar y exportar
* modelos (estimates store, estadd, putexcel).
* =============================================================================
