* =============================================================================
* Guion Semana 12 · Sesión 2 — Comandos básicos de manipulación en Stata
* Fundamentos de Programación para Análisis Económico · UdeC-EAN
* =============================================================================
*
* Para qué es este archivo: seguir la clase EN VIVO. Todo el código ya está
*   escrito (no hay huecos). Lo corres bloque a bloque, en el orden de las
*   slides, y comparas con [DEBERÍAS VER]. Cada comando trae al lado su
*   equivalente en R: no aprendemos desde cero, TRADUCIMOS.
*
* CÓMO CORRERLO (recap Sesión 1)
*   Selecciona líneas y ejecuta:  Windows Ctrl + D  ·  Mac Cmd + Shift + D
*   Antes de nada, Stata debe estar parado en la carpeta del proyecto (BLOQUE 0).
*
* MARCAS
*   [CORRE Y OBSERVA]  ejecútalo y mira el resultado
*   [PREDICE]          piensa qué saldrá ANTES de ejecutar
*   [SOLO MIRA]        se lee, no se corre
*   [DEBERÍAS VER]     el resultado esperado, para autoverificarte
*
* Datos: data/raw/casen_reducido.csv y data/processed/casen.dta
*   60 personas · region, sector, educ, edad, ingreso, genero · 5 missing en
*   ingreso (las mismas de R). Además: casen_sucio.csv (lab S6) en el Bloque D
*   y casen_ingresos.csv (S5) en el Bloque G.
* =============================================================================


* -----------------------------------------------------------------------------
* BLOQUE 0 — Preparar la sesión
* -----------------------------------------------------------------------------
version 14
clear all
set more off

* [CORRE Y OBSERVA] ¿Estás en la carpeta del proyecto?
pwd
* Si no, quita el * y escribe tu ruta (Sesión 1, Bloque 0):
* cd "PON/AQUI/LA/RUTA/DE/TU/PROYECTO"

confirm file "data/raw/casen_reducido.csv"

* [DEBERÍAS VER] ningún mensaje. "file ... not found" = carpeta equivocada.


* -----------------------------------------------------------------------------
* EL MAPA R <-> STATA (la slide de inicio)
* -----------------------------------------------------------------------------
*   Tarea              R (dplyr)          Stata
*   Cargar             read.csv()         use / import delimited
*   Elegir columnas    select()           keep / drop
*   Filtrar filas      filter()           keep if / drop if
*   Crear variable     mutate()           generate / replace
*   Renombrar          rename()           rename
*   Resumir            summarise()        summarize / tabstat
*   Por grupo          group_by()         by / bysort
*   Frecuencias        count()            tabulate


* -----------------------------------------------------------------------------
* BLOQUE A — use, import, describe, save
* -----------------------------------------------------------------------------

* [CORRE Y OBSERVA] Desde CSV (R: read.csv("data/raw/casen_reducido.csv")).
import delimited "data/raw/casen_reducido.csv", clear varnames(1) encoding("utf-8")

* [DEBERÍAS VER] (6 vars, 60 obs)
*   varnames(1) = "la fila 1 trae los nombres". Si un CSV no tiene encabezado,
*   Stata llama a las columnas v1, v2, v3... (ver rename, Bloque B).
*   encoding("utf-8") = "el archivo está en UTF-8" (recap S6: la codificación).
*   Sin esa opción, con version 14 al inicio, "Construcción" se lee como
*   "ConstrucciÃ³n" (verificado). Las tildes y la ñ lo necesitan.

* [CORRE Y OBSERVA] Desde el formato nativo de Stata (.dta).
use "data/processed/casen.dta", clear

* [CORRE Y OBSERVA] describe = el str() de R.
describe

* [DEBERÍAS VER]
*   region str13 · sector str13 · educ byte · edad byte · ingreso long ·
*   genero str1
*   str13 = texto de hasta 13 caracteres; byte = entero chico (-127 a 100);
*   long = entero grande. Son los tipos de datos de la Semana 3, con otros
*   nombres. El texto en Stata se llama "string".

* [CORRE Y OBSERVA] Un vistazo a las primeras filas (R: head(casen, 5)).
list in 1/5

* [CORRE Y OBSERVA] Guardar (R: write.csv / saveRDS). replace = sobrescribir.
save "data/processed/casen_copia.dta", replace

* [DEBERÍAS VER] file data/processed/casen_copia.dta saved
*   Sin replace, la segunda vez que corres el do-file Stata se niega:
*   "file ... already exists". Lo hace para que no borres un archivo sin querer.

* Borramos la copia: era solo para practicar save.
erase "data/processed/casen_copia.dta"


* -----------------------------------------------------------------------------
* BLOQUE B — keep, drop, rename
* -----------------------------------------------------------------------------

* [CORRE Y OBSERVA] Elegir columnas (R: select(region, sector, ingreso)).
keep region sector ingreso
list in 1/3

* [DEBERÍAS VER]
*   1. Ñuble          Agricultura   520000
*   2. Metropolitana  Agricultura   467000
*   3. Metropolitana  Industria          .
*   El punto (.) es el missing de Stata: el NA de R.

* keep cambió la base en memoria (Sesión 1: Stata es lineal). Recargamos.
use "data/processed/casen.dta", clear

* [CORRE Y OBSERVA] drop hace lo contrario: bota las columnas que nombras.
drop genero
describe, short

* [DEBERÍAS VER] Variables: 5
use "data/processed/casen.dta", clear

* --- El gotcha más importante de Stata: el missing es MAYOR que todo -------
* [PREDICE] Hay 55 personas con ingreso y 5 sin dato. ¿Cuántas cuenta Stata
*   con ingreso mayor a 500.000?
count if ingreso > 500000

* [DEBERÍAS VER] 46

count if ingreso > 500000 & !missing(ingreso)

* [DEBERÍAS VER] 41
*   La diferencia (5) son las personas SIN ingreso. Para Stata, el missing (.)
*   es un número más grande que cualquier otro, así que "> 500000" las incluye.
*   En R, filter(ingreso > 500000) las descartaba solo. En Stata, NO.
*   Regla: toda condición con > o >= sobre una variable con missing lleva
*   & !missing(variable).

* [CORRE Y OBSERVA] Filtrar filas (R: filter(edad > 30)).
keep if edad > 30 & !missing(edad)
count

* [DEBERÍAS VER] (14 observations deleted) y count = 46
use "data/processed/casen.dta", clear

* [CORRE Y OBSERVA] rename (R: rename(anios_educ = educ)).
rename educ anios_educ
describe, short
rename anios_educ educ

* rename *, lower pasa TODOS los nombres a minúscula de un golpe. Sirve cuando
* importas un Excel con nombres como "Region" o "INGRESO" (recap S6: limpiar
* nombres al cargar). Aquí no cambia nada porque ya están en minúscula.
rename *, lower


* -----------------------------------------------------------------------------
* BLOQUE C — generate, replace
* -----------------------------------------------------------------------------

* [CORRE Y OBSERVA] Crear variables (R: mutate()).
generate ingreso_miles = ingreso / 1000          // nueva variable
generate experiencia   = edad - educ - 6         // experiencia potencial de Mincer
replace  experiencia   = 0 if experiencia < 0    // MODIFICAR la que ya existe

* [DEBERÍAS VER]
*   (5 missing values generated)   en ingreso_miles: el missing se propaga
*   (0 real changes made)          en replace: en esta muestra nadie tiene
*                                  experiencia negativa, pero la regla protege
*                                  el do-file si mañana usas otra base.
*   En R esto era experiencia = pmax(edad - educ - 6, 0), en una línea.

* [PREDICE] ¿Qué pasa si uso generate sobre una variable que ya existe?
capture noisily generate experiencia = 1

* [DEBERÍAS VER] variable experiencia already defined
*   generate CREA, replace MODIFICA. Stata no te deja pisar una variable por
*   accidente: si quieres cambiarla, tienes que decirlo con replace.

* --- Variables 0/1 y el gotcha del missing (otra vez) ------------------------
* (ingreso < 216000) vale 1 si es verdad y 0 si es falso.
generate pobre_mal = (ingreso < 216000)
generate pobre     = (ingreso < 216000) if !missing(ingreso)

* [PREDICE] ¿En qué se diferencian las dos? Mira los missing:
tabulate pobre_mal, missing
tabulate pobre, missing

* [DEBERÍAS VER]
*   pobre_mal:  0 = 59 · 1 = 1          (las 5 sin ingreso quedaron como "no pobres")
*   pobre:      0 = 54 · 1 = 1 · . = 5  (las 5 sin ingreso quedaron sin dato)
*   pobre_mal está MAL: no sabemos si esas 5 personas son pobres.
*   La opción missing de tabulate muestra la fila de los ".", que por defecto
*   se esconde.
drop pobre_mal

* = asigna y == compara (igual que en R):
*   generate mujer = (genero == "F")      == compara; = asigna el resultado
generate mujer = (genero == "F")
tabulate mujer

* [DEBERÍAS VER] 0 = 31 · 1 = 29

* --- Variables por grupo: bysort + egen ---------------------------------------
* [CORRE Y OBSERVA] La media del sector, al lado de cada persona
* (R: group_by(sector) |> mutate(ing_medio_sector = mean(ingreso, na.rm = TRUE))).
bysort sector: egen ing_medio_sector = mean(ingreso)
list sector ingreso ing_medio_sector in 1/3

* [DEBERÍAS VER] las tres primeras personas de Agricultura con
*   ing_medio_sector = 447846.2 (la misma cifra repetida en cada fila).
*   Fíjate: bysort ORDENÓ la base por sector. La fila 1 ya no es la de antes,
*   y el orden DENTRO de cada sector puede cambiar de una corrida a otra (por
*   eso tu columna ingreso puede no coincidir con la del compañero).
*   egen ignora los missing al promediar, como na.rm = TRUE.
*   by sin "sort" exige que la base ya esté ordenada; bysort ordena y agrupa
*   en un paso, y evita el error "not sorted".


* -----------------------------------------------------------------------------
* BLOQUE D — Variables de texto (string)
* -----------------------------------------------------------------------------
* Trabajamos con casen_sucio.csv (lab S6) SIN perder la base de CASEN que
* tenemos en memoria: preserve guarda la foto, restore la devuelve (Sesión 1).
* [CORRE Y OBSERVA] Corre el bloque ENTERO, desde preserve hasta restore.
preserve

import delimited "data/raw/casen_sucio.csv", clear encoding("utf-8")
list sector_region in 1/3

* Partir una columna en dos (R: strsplit() / tidyr::separate()).
split sector_region, parse("_") generate(parte)
rename (parte1 parte2) (sector region)

* Lo mismo, a mano: ¿dónde está el "_"? y cortar hasta ahí.
generate pos     = strpos(sector_region, "_")
generate sector2 = substr(sector_region, 1, pos - 1)
assert sector == sector2

* Pegar textos con + (R: paste0()).
generate etiqueta = sector + " (" + region + ")"

* Reemplazar dentro de un texto (R: gsub()). El . final = todas las veces.
generate region_ascii = subinstr(region, "í", "i", .)

* Número -> texto (R: as.character()).
tostring educ, generate(educ_txt)

list sector_region sector region etiqueta educ_txt in 1/3
tabulate region_ascii

restore
describe, short

* [DEBERÍAS VER]
*   split: "variables created as string: parte1 parte2"
*   assert: sin mensaje (sector y sector2 coinciden en las 45 filas)
*   1. Comercio_Biobío     Comercio     Biobío  Comercio (Biobío)      17
*   2. Agricultura_Maule   Agricultura  Maule   Agricultura (Maule)    12
*   region_ascii: Araucania 12 · Biobio 7 · Maule 13 · Ñuble 13
*   y, después de restore, otra vez la CASEN de 60 personas.
*
*   Con texto, replace lleva comillas:  replace region = "Biobío" if region == "Bio Bio"
*   strtrim(s) quita espacios al inicio y al final (R: trimws()):
display "[" strtrim("   Maule  ") "]"

* [DEBERÍAS VER] [Maule]

* [PREDICE] ¿Cuántas letras tiene "Ñuble"? ¿Y qué hace lower() con la Ñ?
display strlen("Ñuble") "  " ustrlen("Ñuble")
display lower("ÑUBLE")  "  " ustrlower("ÑUBLE")
display upper("Biobío") "  " ustrupper("Biobío")

* [DEBERÍAS VER]
*   6  5
*   Ñuble  ñuble
*   BIOBíO  BIOBÍO
*   strlen cuenta BYTES (la Ñ ocupa 2) y lower/upper solo conocen el alfabeto
*   inglés. Con texto en español: ustrlen, ustrlower, ustrupper, usubstr.


* -----------------------------------------------------------------------------
* BLOQUE E — Categóricas y etiquetas: label, encode, recode, codebook
* -----------------------------------------------------------------------------

* [CORRE Y OBSERVA] Etiquetar: la base se documenta sola.
label variable ingreso     "Ingreso mensual ($)"
label variable experiencia "Experiencia potencial (años)"
label define sino 0 "No pobre" 1 "Pobre"
label values pobre sino

tabulate pobre

* [DEBERÍAS VER] No pobre 54 (98,18 %) · Pobre 1 (1,82 %)
*   label define crea el "diccionario" 0 = No pobre, 1 = Pobre; label values
*   lo pega a la variable. Es la idea del factor() de R (Semana 3), pero el
*   dato sigue siendo 0/1.

* [CORRE Y OBSERVA] De texto a categoría: encode (R: factor()).
encode sector, generate(sector_n)
describe sector sector_n
label list sector_n

* [DEBERÍAS VER] sector es str13; sector_n es long con la etiqueta sector_n:
*   1 Agricultura · 2 Comercio · 3 Construcción · 4 Educación · 5 Industria ·
*   6 Servicios   (los códigos siguen el orden alfabético)

tabulate sector_n
tabulate sector_n, nolabel

* [DEBERÍAS VER] la misma tabla dos veces: con nombres y con códigos 1 a 6.

decode sector_n, generate(sector_txt)          // y de vuelta a texto
assert sector_txt == sector

* [PREDICE] ¿Y si uso destring en vez de encode?
capture noisily destring sector, generate(sector_mal)

* [DEBERÍAS VER] sector: contains nonnumeric characters; no generate
*   destring sirve para números escritos como texto ("730480"); una categoría
*   no tiene números que rescatar. Para categorías: encode.

* [CORRE Y OBSERVA] Etiquetar una 0/1 que ya existe.
label define mujer_lbl 0 "Hombre" 1 "Mujer"
label values mujer mujer_lbl
tabulate mujer

* [DEBERÍAS VER] Hombre 31 · Mujer 29

* [CORRE Y OBSERVA] Agrupar y etiquetar en un paso: recode (R: case_when(), S5).
recode educ (0/8 = 1 "Básica") (9/12 = 2 "Media") (13/max = 3 "Superior"), ///
    generate(nivel_educ)
label list nivel_educ
label define nivel_educ 3 "Superior (13+ años)", modify     // corregir una etiqueta
tabstat ingreso, by(nivel_educ) stat(mean n)

* [DEBERÍAS VER] (60 differences between educ and nivel_educ)
*   Básica 354400 (5) · Media 576739.1 (23) · Superior (13+ años) 777925.9 (27)
*   recode con generate() crea una variable NUEVA: educ no se toca.
*   label define ..., modify cambia una etiqueta sin borrar las otras.

label list

* [DEBERÍAS VER] todas las etiquetas de la base: mujer_lbl, nivel_educ, sector_n, sino.


* [CORRE Y OBSERVA] codebook: tipo, rango, missing y percentiles de una variable.
codebook ingreso

* [DEBERÍAS VER]
*   Type: Numeric (long) · Range: [180000,1093000] · Missing .: 5/60
*   Mean: 655291 · Percentiles 10% 384000 · 25% 497000 · 50% 672000 ·
*   75% 807000 · 90% 948000
*   El título ahora dice "Ingreso mensual ($)": la etiqueta que acabas de poner.


* -----------------------------------------------------------------------------
* BLOQUE E2 — Un primer modelo: filtros con if y categóricas con i.
* -----------------------------------------------------------------------------
* La regresión es la de la Semana 8 en R (lm). Aquí solo la sintaxis.

* [CORRE Y OBSERVA] Corre las líneas de a una y mira "Number of obs".
regress ingreso educ
regress ingreso educ if sector != "Agricultura"

* [DEBERÍAS VER] N = 55 · beta educ = 42079.87
*               N = 42 · beta educ = 40707.87 (sin Agricultura)
*   if filtra la muestra de la regresión, igual que filter() antes de lm().

* [CORRE Y OBSERVA] Una categórica en la regresión: i.
regress ingreso educ i.sector_n

* [DEBERÍAS VER] educ 33028.2 · Comercio 108168.5 · Construcción 149172.8 ·
*   Educación 339060.7 · Industria 216167.7 · Servicios 331099.4 · R2 0.8474
*   i.sector_n crea una dummy por sector; la base es el código más bajo
*   (1 = Agricultura), que no aparece. Con igual educación, Servicios se asocia
*   a $331.099 más al mes que Agricultura (R: factor(sector) en lm()).

regress ingreso educ ib6.sector_n

* [DEBERÍAS VER] la base ahora es Servicios (código 6): Agricultura -331099.4,
*   Educación 7961.258 (no distinguible de Servicios: p = 0.850).

* [PREDICE] ¿Y con genero, que es texto?
capture noisily regress ingreso educ i.genero

* [DEBERÍAS VER] genero:  string variables may not be used as factor variables
*   Por eso existe encode (o mujer = (genero == "F")).


* -----------------------------------------------------------------------------
* BLOQUE F — summarize, tabstat, tabulate, correlate
* -----------------------------------------------------------------------------

* [CORRE Y OBSERVA] summarize = summary() de R.
summarize ingreso educ edad

* [DEBERÍAS VER]
*   ingreso  Obs 55  Mean 655290.9  Std. dev. 209912.4  Min 180000  Max 1093000
*   educ     Obs 60  Mean 12.73333  Std. dev. 3.328697  Min 6       Max 20
*   edad     Obs 60  Mean 44.51667  Std. dev. 15.15959  Min 20      Max 70
*   Obs 55 en ingreso: summarize NO se equivoca con los missing, los deja fuera.

* [CORRE Y OBSERVA] Con percentiles, asimetría y curtosis (recap S7).
summarize ingreso, detail

* [DEBERÍAS VER] 50% = 672000 (la mediana) · Mean 655290.9 · Skewness -.1743
*   La media queda algo por debajo de la mediana: la cola de esta muestra está
*   a la izquierda (recap lab S11).

* [CORRE Y OBSERVA] Por grupo (R: group_by(sector) |> summarise(...)).
tabstat ingreso, by(sector) stat(mean sd n)

* [DEBERÍAS VER] (las 6 filas; aquí tres)
*   Agricultura   447846.2   156716.2   13
*   Educación     908857.1   117920.1    7
*   Servicios       788600   112702.4   15
*   Total         655290.9   209912.4   55

* [CORRE Y OBSERVA] Frecuencias (R: count(sector)).
tabulate sector

* [DEBERÍAS VER] Servicios 17 · Agricultura 13 · Industria 11 · Educación 8 ·
*   Comercio 6 · Construcción 5 · Total 60

* [CORRE Y OBSERVA] Tabla cruzada con % por fila (R: table() + prop.table(), S7).
tabulate genero pobre, row

* [DEBERÍAS VER]
*   F:  No pobre 26 (96,30 %) · Pobre 1 (3,70 %) · Total 27
*   M:  No pobre 28 (100 %)   · Pobre 0          · Total 28
*   Total 55: las 5 personas sin ingreso no entran (pobre es missing).

* [CORRE Y OBSERVA] Correlación (R: cor(..., use = "complete.obs")).
correlate ingreso educ experiencia

* [DEBERÍAS VER] (obs=55) · ingreso-educ 0.6767 · ingreso-experiencia -0.0875
*   correlate usa solo las filas completas en las tres variables.


* -----------------------------------------------------------------------------
* BLOQUE F2 — Guardar e invocar resultados: r() y scalar
* -----------------------------------------------------------------------------
* En R, el resultado de mean() lo guardabas en un objeto. En Stata, cada
* comando de estadística deja sus resultados en una memoria temporal llamada
* r(), que puedes listar y usar. La Semana 13 se apoya en esto.

* [CORRE Y OBSERVA] ¿Qué dejó guardado summarize?
summarize ingreso
return list

* [DEBERÍAS VER] r(N) = 55 · r(mean) = 655290.9090909091 · r(sd) = 209912.38...
*   r(min) = 180000 · r(max) = 1093000 · r(sum) = 36041000

* [CORRE Y OBSERVA] Usar un resultado guardado.
display r(mean)
display r(max) - r(min)

* [DEBERÍAS VER] 655290.91 y 913000

* [PREDICE] Ahora corro OTRO comando. ¿Sigue existiendo r(mean)?
tabulate sector
display r(mean)

* [DEBERÍAS VER] un punto (.). tabulate reemplazó TODO lo que había en r()
*   (ahora r() solo tiene r(N) = 60 y r(r) = 6, el número de filas de la tabla).
*   r() se sobrescribe con cada comando: hay que guardarlo ANTES.

* [CORRE Y OBSERVA] Guardar un resultado con scalar, para usarlo después.
summarize ingreso if genero == "F"
scalar media_f = r(mean)
summarize ingreso if genero == "M"
scalar media_m = r(mean)
display "Brecha de ingreso medio (M - F): " %9.0fc media_m - media_f

* [DEBERÍAS VER] mujeres 636296.3 · hombres 673607.1 · Brecha ... 37,311
*   %9.0fc es un formato: 9 espacios, 0 decimales, separador de miles (c).
*   Stata usa la coma para los miles (formato de EE. UU.), no el punto chileno.
*   Esta brecha es descriptiva: con 27 y 28 personas no dice nada sobre causas.

scalar list media_f media_m

* [DEBERÍAS VER] media_f = 636296.3 · media_m = 673607.14
*
*   r()       resultados del ÚLTIMO comando de estadística (se borran solos)
*   e()       resultados de la última ESTIMACIÓN (regress): ereturn list
*   scalar    un número que TÚ guardas, dura toda la sesión
*   local     una macro: la Semana 13 la explica a fondo
*   preserve  una foto de la BASE completa (Sesión 1)


* -----------------------------------------------------------------------------
* BLOQUE G — Combinar bases: merge
* -----------------------------------------------------------------------------
* Stata tiene UNA base en memoria. Para juntar dos, la que se pega se guarda
* en un archivo .dta y merge la trae (R: left_join()).

* --- G1. merge 1:1: una persona con una persona ----------------------------
* [CORRE Y OBSERVA] Corre el bloque ENTERO.
import delimited "data/raw/casen_ingresos.csv", clear encoding("utf-8")
destring ing_*, replace ignore("NA")                  // el NA de R (Sesión 1)
generate id = _n                                      // la llave: número de fila
keep id horas ing_trabajo ing_capital ing_subsidios ing_total
save "data/processed/ingresos_s12.dta", replace

use "data/processed/casen.dta", clear
generate id = _n
merge 1:1 id using "data/processed/ingresos_s12.dta"

* [DEBERÍAS VER]
*   Not matched   0
*   Matched      60  (_merge==3)
*
*   La llave identifica a cada persona en las dos bases. En la CASEN real es
*   folio + id_persona. Nuestros dos CSV traen a las mismas 60 personas en el
*   mismo orden, así que el número de fila sirve. Hay que COMPROBARLO:
assert ingreso == ing_total if !missing(ingreso)
tabulate _merge
describe, short

* [DEBERÍAS VER] assert sin mensaje (si fallara, detiene el do-file con
*   "assertion is false") · _merge = 3 en las 60 filas · Variables: 13.
*   _merge: 1 = solo en la base en memoria, 2 = solo en la que pegaste,
*   3 = en las dos.

* --- G2. merge m:1: pegar un dato de GRUPO a cada persona -----------------
* [CORRE Y OBSERVA] Corre el bloque ENTERO.
use "data/processed/casen.dta", clear

preserve
collapse (mean) ing_sector = ingreso (count) n_sector = ingreso, by(sector)
list
save "data/processed/sectores_s12.dta", replace
restore

merge m:1 sector using "data/processed/sectores_s12.dta"
list sector ingreso ing_sector n_sector in 1/3

* [DEBERÍAS VER]
*   collapse: una fila por sector (6): Agricultura 447846.15 (13) ·
*   Comercio 523833.33 (6) · Construcción 520800 (5) · Educación 908857.14 (7) ·
*   Industria 697888.89 (9) · Servicios 788600 (15)
*   merge: Matched 60. m:1 = muchas personas (m) con un sector (1).
*   collapse es group_by() |> summarise(); el resultado es el mismo de
*   bysort sector: egen (Bloque C), pero el patrón pega CUALQUIER base de otro
*   nivel: una tasa regional, un precio por año.
*   Los archivos intermedios quedaron en data/processed/. En la Semana 13,
*   tempfile hace lo mismo sin dejar archivos sueltos.


* -----------------------------------------------------------------------------
* BLOQUE H — Ejemplo integrador: limpiar CASEN en Stata
* -----------------------------------------------------------------------------
* [CORRE Y OBSERVA] Selecciona TODO el bloque (hasta log close) y córrelo de una
* vez. Es el mismo flujo de las Semanas 4 a 6: cargar, crear, etiquetar,
* describir, guardar.

* ===== Limpieza y descriptivos CASEN =====
version 14
clear all
set more off
capture mkdir "output"
capture log close
log using "output/casen_s12.log", replace text

import delimited "data/raw/casen_reducido.csv", clear varnames(1) encoding("utf-8")

* Variables derivadas (con intención económica)
generate experiencia = edad - educ - 6                       // años desde que dejó de estudiar
replace  experiencia = 0 if experiencia < 0                  // nadie tiene experiencia negativa
generate pobre = (ingreso < 216000) if !missing(ingreso)     // sin ingreso = sin dato, no "no pobre"

* Etiquetas
label variable experiencia "Experiencia potencial (años)"
label define sino 0 "No pobre" 1 "Pobre"
label values pobre sino

* Descriptivos
summarize ingreso educ edad
tabstat ingreso, by(sector) stat(mean sd n)
tabulate genero pobre, row

save "data/processed/casen_limpio.dta", replace
log close

* [DEBERÍAS VER]
*   (6 vars, 60 obs) · (0 real changes made) · (5 missing values generated)
*   las mismas tablas del Bloque E
*   file data/processed/casen_limpio.dta saved
*   Y un archivo nuevo: output/casen_s12.log, con todo lo anterior.
*
* casen_limpio.dta es la base con la que parte la Semana 13.


* -----------------------------------------------------------------------------
* CIERRE — lo que nos llevamos esta semana
* -----------------------------------------------------------------------------
*   R (dplyr)                          Stata
*   read.csv() / select() / filter()   import delimited / keep / keep if
*   mutate()                           generate / replace
*   group_by() |> mutate()             bysort: egen
*   group_by() |> summarise()          tabstat, by()
*   summary() / count()                summarize / tabulate
*   factor()                           encode / label define + label values
*   case_when()                        recode ..., generate()
*   paste0() / gsub() / strsplit()     + / subinstr() / split
*   lm(y ~ x + factor(g)) con filtro   regress y x i.g if ...
*   cor()                              correlate
*   guardar un resultado en un objeto  r() + scalar
*   left_join()                        merge 1:1 / merge m:1 (+ collapse)
*
* Los dos gotchas que no se olvidan:
*   1. El missing (.) es mayor que cualquier número: & !missing(x).
*   2. generate crea, replace modifica; = asigna, == compara.
*
* Al laboratorio: labs/semana12_lab_esqueleto.do (tu primer do-file completo)
* y labs/semana12_comparacion_R.R (el mismo análisis en R, lado a lado).
* =============================================================================
