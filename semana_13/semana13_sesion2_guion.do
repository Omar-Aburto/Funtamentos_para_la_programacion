* =============================================================================
* Guion Semana 13 · Sesión 2 — Automatización II: programas, combinar bases y
*                                guardar y exportar resultados
* Fundamentos de Programación para Análisis Económico · UdeC-EAN
* =============================================================================
*
* Para qué es este archivo: seguir la clase EN VIVO. Todo el código ya está
*   escrito (no hay huecos). Lo corres bloque a bloque, en el orden de las
*   slides, y comparas con [DEBERÍAS VER].
*
* CÓMO CORRERLO (recap S12 y S13S1)
*   Selecciona líneas y ejecuta:  Windows Ctrl + D  ·  Mac Cmd + Shift + D
*   Las macros locales (y los tempfile) mueren cuando termina la selección:
*   corre cada bloque ENTERO, desde su primera hasta su última línea.
*
* MARCAS
*   [CORRE Y OBSERVA]  ejecútalo y mira el resultado
*   [PREDICE]          piensa qué saldrá ANTES de ejecutar
*   [SOLO MIRA]        se lee, no se corre
*   [DEBERÍAS VER]     el resultado esperado, para autoverificarte
*
* Datos: data/processed/casen_limpio.dta (S12S2) y data/raw/casen_ingresos.csv
*   (las mismas 60 personas con el ingreso abierto por fuente y las horas; S5).
* Paquete: estout (Bloque E). Se instala una vez con  ssc install estout
* =============================================================================


* -----------------------------------------------------------------------------
* BLOQUE 0 — Preparar la sesión (córrelo entero)
* -----------------------------------------------------------------------------
version 14
clear all
set more off

pwd
 cd "C:\Users\omara\OneDrive\Documentos\Funtamentos_para_la_programacion\semana_13"

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

* estout no viene con Stata: es un paquete de la comunidad (como instalar un
* paquete de R con install.packages). which lo busca; si no está, lo instala.
capture which esttab
if _rc != 0 {
    ssc install estout
}

capture mkdir "output"


* -----------------------------------------------------------------------------
* BLOQUE A — Definir un programa: program ... end
* -----------------------------------------------------------------------------
* Un programa es el function() de R: un nombre, un cuerpo, se reutiliza.

* [CORRE Y OBSERVA] Corre las cuatro líneas juntas, y después la quinta.
capture program drop saludo
program saludo
    display "Hola, análisis económico"
end
saludo

* [DEBERÍAS VER] Hola, análisis económico

* [PREDICE] ¿Qué pasa si defino OTRA VEZ saludo, sin el capture program drop?
capture noisily program saludo

* [DEBERÍAS VER] program saludo already defined
*   Stata recuerda el programa toda la sesión. Por eso todo bloque que define
*   un programa empieza con  capture program drop nombre.

* [CORRE Y OBSERVA] La solución estándar: borrarlo antes de redefinirlo.
capture program drop saludo
program saludo
    display "Hola de nuevo"
end
saludo

* [DEBERÍAS VER] Hola de nuevo


* -----------------------------------------------------------------------------
* BLOQUE B — Argumentos: `1', `2', ...
* -----------------------------------------------------------------------------
* [CORRE Y OBSERVA]
capture program drop tester
program tester
    display "argumento 1 es |`1'|"
    display "argumento 2 es |`2'|"
end
tester ingreso sector

* [DEBERÍAS VER] argumento 1 es |ingreso| · argumento 2 es |sector|

* [CORRE Y OBSERVA] Un programa útil: descriptivos de una variable por grupo.
use "data/processed/casen_limpio.dta", clear
capture program drop describir_por
program describir_por
    tabstat `1', by(`2') stat(mean sd n)
end
describir_por ingreso sector
describir_por educ genero

* [DEBERÍAS VER] dos tablas. La segunda: educación media F 12.96552 (n 29) y
*   M 12.51613 (n 31). Es el tabstat de la S12, ahora como comando propio.


* -----------------------------------------------------------------------------
* BLOQUE C — Scope y variables temporales: tempvar
* -----------------------------------------------------------------------------
* [PREDICE] Una macro local del do-file, ¿existe dentro del programa?
local grupo = "sector"
capture program drop mal
program mal
    tabstat `1', by(`grupo')
end
capture noisily mal ingreso

* [DEBERÍAS VER] NINGÚN error, y eso es lo grave: sale una tabla con la media
*   de ingreso de toda la muestra (655290.9), sin separar por sector. Dentro de
*   mal, `grupo' no existe, se evalúa como nada, y Stata corre
*   "tabstat ingreso, by()", que acepta un by() vacío. Un error silencioso.
*   La solución es pasarlo como argumento: by(`2') y llamar  mal ingreso sector.

* [CORRE Y OBSERVA] tempvar: una variable auxiliar con un nombre único que se
* borra sola al terminar el programa.
capture program drop centrar
program centrar
    tempvar media
    quietly summarize `1'
    generate `media' = `1' - r(mean)
    summarize `media'
end
centrar educ
describe, short

* [DEBERÍAS VER] la variable temporal (educ menos su media) tiene media ~0 (un número tipo 1e-07,
*   error de redondeo) y desviación 3.328697 (la misma de educ). Después,
*   describe sigue mostrando las variables de antes: la temporal ya no existe.


* -----------------------------------------------------------------------------
* BLOQUE D — Bases temporales: tempfile (el merge de la S12, sin archivos sueltos)
* -----------------------------------------------------------------------------
* En la S12 la base que se pegaba con merge quedaba guardada en
* data/processed/ (ingresos_s12.dta, sectores_s12.dta). tempfile la guarda en
* un archivo temporal que Stata borra solo al terminar: el tempvar de las bases.

* --- merge m:1 con tempfile (recap S12: collapse) ---------------------
* [CORRE Y OBSERVA] El ingreso medio del sector al lado de cada persona,
* armando primero una base de sectores con collapse. Corre el bloque entero.
use "data/processed/casen_limpio.dta", clear

preserve
collapse (mean) ing_sector = ingreso (count) n_sector = ingreso, by(sector)
list
tempfile sectores
save `sectores'
restore

merge m:1 sector using `sectores'
list sector ingreso ing_sector n_sector in 1/3

* [DEBERÍAS VER]
*   collapse deja UNA fila por sector (6 filas): Agricultura 447846.15 (13),
*   Educación 908857.14 (7), Servicios 788600 (15)...
*   merge: Matched 60. m:1 = muchas personas (m) con un sector (1).
*   collapse es el group_by() |> summarise() de dplyr; con merge m:1 se
*   obtiene lo mismo que bysort sector: egen (S12), pero el patrón sirve
*   para pegar CUALQUIER base de otro nivel (una tasa regional, un precio).
*   El tempfile sectores ya no existe cuando termina el bloque: no ensucia
*   la carpeta del proyecto.


* -----------------------------------------------------------------------------
* BLOQUE E — Guardar modelos y pegarles información: estimates store, estadd
* -----------------------------------------------------------------------------
* [CORRE Y OBSERVA] Corre el bloque ENTERO.
use "data/processed/casen_limpio.dta", clear
generate mujer = (genero == "F")
label variable educ  "Años de educación"
label variable mujer "Mujer"

quietly regress ingreso educ
estimates store m1                                  // guardar el modelo con un nombre

quietly regress ingreso educ experiencia mujer
estimates store m2

quietly regress ingreso educ experiencia mujer if sector != "Agricultura"
estimates store m3

estimates dir
estimates table m1 m2 m3, b(%9.0f) se stats(N r2) stfmt(%5.3f)

* [DEBERÍAS VER]
*   estimates dir: m1, m2, m3 (regress ingreso, 2, 4 y 4 parámetros)
*   educ:  42080 (6289) · 42246 (6355) · 41921 (5644)
*   N      55 · 55 · 42      r2  0.458 · 0.475 · 0.592
*   estimates store guarda TODO e() del modelo (S13S1) con un nombre. Es como
*   guardar m1 <- lm(...) en R: ya no se pierde con la siguiente regresión.

* [CORRE Y OBSERVA] Volver a un modelo guardado.
estimates restore m1
display "m1 tiene N = " e(N) " y beta educ = " _b[educ]

* [DEBERÍAS VER] m1 tiene N = 55 y beta educ = 42079.866

* --- E2. estadd: pegar locales y globales (con etiqueta) a cada modelo -----
* [CORRE Y OBSERVA] Corre el bloque ENTERO (usa los modelos de arriba).
global fuente "CASEN, muestra del curso"

foreach m in m1 m2 m3 {
    estimates restore `m'
    quietly summarize ingreso if e(sample)          // la media de y EN la muestra del modelo
    local media_y = r(mean)
    local muestra = cond(e(N) == 55, "Completa", "Sin Agricultura")
    estadd scalar media_y = `media_y' : `m'
    estadd local  muestra "`muestra'"   : `m'
    estadd local  fuente  "$fuente"     : `m'
}
estadd local controles "No" : m1
estadd local controles "Sí" : m2 m3

esttab m1 m2 m3, se label b(%9.0f) varwidth(30) ///
    stats(N r2 media_y controles muestra, ///
          labels("Observaciones" "R2" "Ingreso medio" "Controles" "Muestra") ///
          fmt(%9.0f %5.3f %9.0fc))

* [DEBERÍAS VER] una tabla de 3 columnas:
*   "Años de educación" y "Mujer" en vez de educ y mujer (la opción label usa
*   las etiquetas de variable); al pie: Observaciones 55 55 42 · R2 · Ingreso
*   medio 655,291 en m1 y m2 y 719,500 en m3 (la muestra sin Agricultura) ·
*   Controles No Sí Sí · Muestra Completa Completa Sin Agricultura.
*   Educación: 42080, 42246 y 41921 (***): el coeficiente casi no se mueve al
*   agregar controles ni al sacar Agricultura. Se asocia; no prueba causa.
*   varwidth(30) da espacio a las etiquetas largas (sin él, "Experiencia
*   potencial (años)" se corta).
*
*   estadd local   pega un TEXTO al modelo (una fila "Sí/No" de la tabla)
*   estadd scalar  pega un NÚMERO
*   : m1 m2        a qué modelos guardados se lo pegas
*   Lo que pegaste queda en e(): pruébalo con  estimates restore m3  y
*   ereturn list  (aparecen e(muestra), e(controles), e(media_y)).
*   cond(condición, a, b) es el if_else() de R.

* [CORRE Y OBSERVA] La misma tabla, a un archivo (para Word: .rtf; LaTeX: .tex).
esttab m1 m2 m3 using "output/s13_modelos.rtf", replace se label b(%9.0f) ///
    stats(N r2 media_y controles muestra, ///
          labels("Observaciones" "R2" "Ingreso medio" "Controles" "Muestra"))

* [DEBERÍAS VER] (output written to output/s13_modelos.rtf). Ábrelo con Word.


* --- E3. putexcel: la matriz del loop a Excel -------------------------------
* [CORRE Y OBSERVA] Corre el bloque ENTERO. Primero rehacemos la matriz R de
* la Sesión 1 (una regresión por sector, guardada con J()).
use "data/processed/casen_limpio.dta", clear

levelsof sector, local(sectores)
local k : word count `sectores'
matrix R = J(`k', 3, .)
local i = 1
foreach s of local sectores {
    quietly regress ingreso educ if sector == "`s'"
    matrix R[`i', 1] = _b[educ]
    matrix R[`i', 2] = _se[educ]
    matrix R[`i', 3] = e(N)
    local i = `i' + 1
}

* Ahora, a Excel.
putexcel set "output/s13_por_sector.xlsx", replace       // qué archivo y qué hoja
putexcel A1 = ("Sector") B1 = ("Beta educ") C1 = ("Error est.") D1 = ("n")
putexcel B2 = matrix(R)                                   // la matriz entera, desde B2

local fila = 2
foreach s of local sectores {                             // los nombres, uno por fila
    putexcel A`fila' = ("`s'")
    local fila = `fila' + 1
}
putexcel A9 = ("Fuente: $fuente")

* [DEBERÍAS VER] varias líneas "file output/s13_por_sector.xlsx saved".
*   Abre el Excel: Sector, Beta educ, Error est., n en la fila 1; los 6
*   sectores en A2:A7, y la nota en A9.
*   El texto va entre PARÉNTESIS: ("Sector"). Así funciona igual en Stata 14
*   y en Stata 18 (verificado).
*   putexcel escribe celda por celda: es útil para un reporte con formato fijo
*   que alguien abre en Excel. Para una tabla de regresión, esttab (Bloque E).


* -----------------------------------------------------------------------------
* BLOQUE F — ¿Cuándo usar cada cosa?
* -----------------------------------------------------------------------------
* [SOLO MIRA] Este bloque es conceptual (slides); no tiene código.
*   Interactivo (ventana Command)  explorar, probar, revisar supuestos
*   do-file                        el análisis completo, de principio a fin
*   programa dentro del do-file    un paso que se repite más de una vez
*   ado-file (carpeta del proyecto) un programa que usan varios do-files
*   ado-file (carpeta personal)    un programa general para todos tus proyectos


* -----------------------------------------------------------------------------
* BLOQUE G — Ejemplo integrador: programa + loop
* -----------------------------------------------------------------------------
* [CORRE Y OBSERVA] Corre el bloque entero.
use "data/processed/casen_limpio.dta", clear

capture program drop resumen
program resumen
    display _newline "===== `1' ====="
    summarize `1', detail
end

foreach v of varlist ingreso educ edad {
    resumen `v'
}

* [DEBERÍAS VER] tres resúmenes con percentiles. El programa dice QUÉ hacer
*   con una variable; el loop lo aplica a todas.


* -----------------------------------------------------------------------------
* CIERRE — lo que nos llevamos esta semana
* -----------------------------------------------------------------------------
*   program ... end / capture program drop   un comando propio (= function())
*   `1', `2'                                 sus argumentos
*   tempvar / tempfile                       variable / base que se borra sola
*   assert                                   verificar; detiene el do-file si falla
*   estimates store / restore / table        guardar y comparar modelos
*   estadd local / scalar                    pegar macros a un modelo guardado
*   esttab ..., label stats()                la tabla de regresión, a pantalla o archivo
*   putexcel set / putexcel A1 = ...         escribir celdas y matrices en Excel
* =============================================================================
