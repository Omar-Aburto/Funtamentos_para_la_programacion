* =============================================================================
* Guion Semana 12 · Sesión 1 — Introducción a Stata y do-files
* Fundamentos de Programación para Análisis Económico · UdeC-EAN
* =============================================================================
*
* Para qué es este archivo: seguir la clase EN VIVO. Todo el código ya está
*   escrito (no hay huecos). Lo corres bloque a bloque, en el mismo orden de las
*   slides, y comparas lo que sale con lo que dice [DEBERÍAS VER].
*
* CÓMO CORRERLO
*   1. Abre Stata y luego este archivo en el Do-file Editor
*      (File > Open..., o escribe  doedit  en la ventana Command).
*   2. Selecciona una o varias líneas y ejecútalas:
*        Windows: Ctrl + D        Mac: Cmd + Shift + D
*      o el botón "Execute (do)" de la barra del editor.
*      Sin nada seleccionado, ese botón corre el archivo COMPLETO.
*   3. Mira el resultado en la ventana Results.
*
* MARCAS (las mismas de los guiones de R, en texto porque Stata no muestra
* bien los emoji en todas las versiones):
*   [CORRE Y OBSERVA]  ejecútalo y mira el resultado
*   [PREDICE]          piensa qué saldrá ANTES de ejecutar
*   [SOLO MIRA]        ejemplo que se lee; si lo corres, da error a propósito
*   [DEBERÍAS VER]     el resultado esperado, para autoverificarte
*
* Datos: data/raw/casen_reducido.csv y data/processed/casen.dta (las mismas
*   60 personas de CASEN que usamos en R; 5 NA en ingreso), y en el Bloque E:
*   la ENE (S6), casen_ingresos.csv (S5) y casen_sucio.csv (lab S6).
* =============================================================================


* -----------------------------------------------------------------------------
* BLOQUE 0 — Pararse en la carpeta del proyecto (antes de todo)
* -----------------------------------------------------------------------------
* En R, el .Rproj fijaba la carpeta de trabajo por ti. Stata NO lee el .Rproj:
* busca los archivos a partir de su "directorio de trabajo" actual. Si no estás
* en la carpeta del proyecto, "data/raw/casen_reducido.csv" no existe para él.

* [CORRE Y OBSERVA] ¿Dónde está parado Stata ahora?
pwd

* Si lo que muestra NO es la carpeta de tu proyecto (la que tiene data/,
* scripts/, output/), cámbiala con cd. Quita el asterisco de la línea de abajo y
* pon TU ruta, entre comillas (las comillas son obligatorias si hay espacios):
*
*   Windows:  cd "C:/Users/tu_usuario/Documents/fppe-proyecto"
*   Mac:      cd "/Users/tu_usuario/Documents/fppe-proyecto"
*
* cd "PON/AQUI/LA/RUTA/DE/TU/PROYECTO"

* Usa siempre la barra /  (también en Windows): Stata la entiende en los dos
* sistemas, y así el mismo do-file corre en el computador de tu compañero.

* [CORRE Y OBSERVA] Comprueba que Stata ve el archivo de datos.
confirm file "data/raw/casen_reducido.csv"
confirm file "data/processed/casen.dta"

* [DEBERÍAS VER] nada (ningún mensaje). Si aparece
*   file data/raw/casen_reducido.csv not found
* es que no estás en la carpeta del proyecto: vuelve al cd de arriba.


* -----------------------------------------------------------------------------
* BLOQUE A — ¿Por qué Stata?
* -----------------------------------------------------------------------------
* Este bloque es conceptual (slides). Solo dos comandos para conocer tu Stata.

* [CORRE Y OBSERVA] ¿Qué versión tienes?
version

* [DEBERÍAS VER] version 14.x, 15.x, 16.x, 17.x o 18.x según tu instalación.
*   Todo lo de este curso corre desde la versión 14.

* [CORRE Y OBSERVA] display es el print() de R: muestra un texto o un cálculo.
display "Hola desde Stata"
display 2 + 2
display 655291 / 1000

* [DEBERÍAS VER] Hola desde Stata · 4 · 655.291


* -----------------------------------------------------------------------------
* BLOQUE B — La interfaz: las cuatro ventanas
* -----------------------------------------------------------------------------
*   Command        escribes un comando suelto y Enter        (= consola de R)
*   Do-file Editor el script reproducible: ESTE archivo       (= el .R)
*   Variables      las columnas de la base que está cargada  (= Environment)
*   Results        el output de todo lo que corres           (= consola)
*
* La ventana Command no deja registro: lo que escribes ahí no queda en ningún
* archivo. Todo lo que entregas va en un do-file.

* [CORRE Y OBSERVA] La ayuda se abre en el Viewer (el "panel Help" de Stata).
help summarize

* En la ayuda, mira el título: "summarize" aparece con las letras "su"
* SUBRAYADAS. Eso indica la abreviatura mínima del comando (Bloque D3).

* [CORRE Y OBSERVA] Busca un comando cuando no sabes su nombre.
search tabulate


* -----------------------------------------------------------------------------
* BLOQUE C — Stata es lineal: UNA base en memoria a la vez
* -----------------------------------------------------------------------------
* En R podías tener casen, casen_limpio, m1 y m2 al mismo tiempo. En Stata hay
* un único dataset cargado, y cada comando lo modifica.

* [CORRE Y OBSERVA] use carga una base .dta (el formato nativo de Stata).
use "data/processed/casen.dta", clear
describe, short
count

* [DEBERÍAS VER] Observations: 60 · Variables: 6 · count = 60

* [PREDICE] Vamos a quedarnos con las personas de más de 30 años. ¿Cuántas
*   filas quedan? ¿Se puede "deshacer" después?
keep if edad > 30
count

* [DEBERÍAS VER] (14 observations deleted) y count = 46.
*   No hay "deshacer": la base en memoria ya no tiene esas 14 personas. El
*   archivo casen.dta en el disco sigue intacto, porque no lo guardamos.

* [CORRE Y OBSERVA] generate agrega una variable a ESA base (la de 46 filas).
generate ingreso_miles = ingreso / 1000
describe, short

* [DEBERÍAS VER] (5 missing values generated) y ahora Variables: 7.
*   Las 5 personas sin ingreso tienen todas más de 30 años, así que siguen en
*   la base: donde ingreso es missing, ingreso_miles también. El missing se
*   propaga, igual que el NA en R.

* [PREDICE] ¿Qué pasa si intento cargar otra vez la base SIN la opción clear?
capture noisily use "data/processed/casen.dta"

* [DEBERÍAS VER] no; dataset in memory has changed since last saved
*   Stata se niega a borrar cambios que no guardaste. Por eso todo do-file
*   carga con  use ..., clear : vacía la memoria a propósito.
*   (capture noisily = "muestra el error, pero no detengas el do-file"; lo
*   usamos aquí solo para ver errores sin cortar el guion.)

use "data/processed/casen.dta", clear
count

* [DEBERÍAS VER] 60 otra vez.

* [CORRE Y OBSERVA] preserve / restore: una "foto" de la base para volver a ella.
*   Es la forma de hacer un cálculo sobre un subconjunto sin perder la base
*   completa (en R bastaba con crear otro objeto).

preserve
keep if sector == "Agricultura"
count
restore
count


* [DEBERÍAS VER] 13 dentro del preserve; 60 después del restore.
*   La foto de preserve vive en la memoria (no en el disco) y desaparece al
*   hacer restore o al terminar el do-file.


* -----------------------------------------------------------------------------
* BLOQUE D — Do-files
* -----------------------------------------------------------------------------

* --- D1. La estructura de un buen do-file -----------------------------------
* [SOLO MIRA] El encabezado que tendrá TODO do-file que entregues:
*
*   * ============================================
*   * Proyecto: Análisis CASEN
*   * Autor: Nombre Apellido      Fecha: 2026-11-xx
*   * Propósito: limpieza y descriptivos
*   * ============================================
*   version 14            // corre con las reglas de Stata 14, aunque tengas uno más nuevo
*   clear all             // empezar sin datos ni resultados previos
*   set more off          // no pausar el output con --more--
*   capture log close     // cerrar un log que haya quedado abierto
*   log using "output/analisis.log", replace text
*
*   * --- 1. Cargar datos ---
*   * --- 2. Limpiar y crear variables ---
*   * --- 3. Analizar ---
*
*   log close
*
* version 14 hace que tu do-file se comporte igual en Stata 14 que en Stata 18:
* es el equivalente a fijar la versión de un paquete en R.


* --- D2. TODAS las formas de comentar ---------------------------------------
* Stata tiene cinco marcas de comentario. Cuatro sirven en cualquier do-file y
* una cambia cómo se terminan las líneas.

* (1) El asterisco *  al INICIO de la línea: la línea entera es comentario.
*     Es el único que funciona también en la ventana Command.

* (2) Doble barra //  : comentario hasta el final de la línea. Puede ir sola en
*     una línea o DESPUÉS de un comando.
// esta línea entera es un comentario
display 3 * 2          // y esto es un comentario después de un comando

* [DEBERÍAS VER] 6

* (3) Barra-asterisco /* ... */ : comentario que puede ocupar varias líneas, o
*     ir en MEDIO de un comando.
/*
   Todo lo que está entre la apertura y el cierre se ignora.
   Sirve para desactivar un bloque de código mientras pruebas otra cosa,
   o para escribir una explicación larga.
*/
display 3 /* este pedazo se ignora */ + 4

* [DEBERÍAS VER] 7

* (4) Triple barra ///  : "el comando sigue en la línea de abajo". Lo que va
*     después de /// en esa línea también es comentario.
display 5 ///            el comando no termina aquí
        + 1

* [DEBERÍAS VER] 6

* (5) #delimit ;  : cambia la regla para terminar un comando (bloque D4).

* GOTCHAS de los comentarios (verificados):
*   - El * solo es comentario al INICIO de la línea. En medio es multiplicar:
*     display 5 * 2 * comentario   da error "comentario invalid name".
*   - // y /// necesitan un ESPACIO antes. Pegados al código no funcionan:
*         display 3//sin espacio        da error "3/ invalid name"
*   - //, /// y /* */ funcionan en do-files, NO en la ventana Command. Si
*     copias una línea con // a la ventana Command, falla.
*   - Comenta el PORQUÉ, no el QUÉ (Semana 2):
*         generate pobre = (ingreso < 216000)   // mal: "crea pobre"
*         generate pobre = (ingreso < 216000)   // bien: umbral de pobreza que usa el curso


* --- D3. Abreviaturas de comandos y de variables ------------------------
* Stata acepta comandos abreviados. La abreviatura mínima es la parte que
* aparece SUBRAYADA en la ayuda (help summarize: "su" subrayado).

* [CORRE Y OBSERVA] Los cuatro hacen lo mismo:
summarize ingreso
summ ingreso
sum ingreso
su ingreso

* Las abreviaturas que vas a ver en do-files de otros (y en ChatGPT):
*   Comando completo    Abreviaturas comunes
*   summarize           su, sum
*   generate            g, gen
*   tabulate            ta, tab
*   describe            d, des
*   list                l
*   regress             reg
*   label variable      lab var
*   keep / drop         no se abrevian (ya son cortos)
*   replace             NO se puede abreviar (a propósito: modifica datos)

* [CORRE Y OBSERVA] replace no acepta abreviatura.
capture noisily rep educ = educ

* [DEBERÍAS VER] command rep is unrecognized

* Stata también acepta VARIABLES abreviadas, si la abreviatura es única:
su ing

* [DEBERÍAS VER] la tabla de ingreso (ing solo puede ser ingreso).

* [PREDICE] ¿Y "e"? Hay dos variables que empiezan con e (educ y edad).
capture noisily su e

* [DEBERÍAS VER] e ambiguous abbreviation

* Las variables abreviadas son peligrosas: si mañana creas una variable
* "ingreso_miles", "ing" deja de ser única y tu do-file se rompe. Se pueden
* prohibir:
set varabbrev off
capture noisily su ing
set varabbrev on

* [DEBERÍAS VER] variable ing not found

* REGLA DEL CURSO: en los do-files que entregas, comandos completos o con su
* abreviatura común (gen, sum, tab, reg); variables SIEMPRE con su nombre
* completo. El do-file se lee más veces de las que se escribe.


* --- D4. Comandos largos: /// y #delimit ----------------------------------
* Un comando de Stata termina donde termina la línea. Si es muy largo, hay
* dos formas de partirlo.

* Forma 1 (la recomendada): /// al final de cada línea que continúa.
tabstat ingreso educ edad, ///
    by(sector)             ///
    stat(mean sd n)

* [DEBERÍAS VER] una tabla con la media, desviación estándar y n de ingreso,
*   educ y edad para los 6 sectores. Agricultura: ingreso medio 447.846, n 13.

* Forma 2: #delimit ;  — desde aquí cada comando termina con ;
*   y los saltos de línea dejan de importar (como en C o SAS).
#delimit ;
tabstat ingreso educ edad,
    by(sector)
    stat(mean n) ;
summarize ingreso ;
#delimit cr

* #delimit cr devuelve la regla normal (cr = "carriage return", el Enter).
* SIEMPRE hay que volver con #delimit cr; si no, todo lo que sigue necesita ;.

* [PREDICE] ¿Qué pasa si olvidas un ; con #delimit activo?
#delimit ;
capture noisily summarize ingreso
summarize educ ;
#delimit cr

* [DEBERÍAS VER] variable summarize not found
*   Sin el ;, Stata leyó las dos líneas como UN solo comando:
*   "summarize ingreso summarize educ", y buscó una variable llamada summarize.
*   Por eso en este curso preferimos ///: el error es más visible.

* #delimit solo funciona dentro de un do-file (no en la ventana Command).


* --- D5. El log: el registro de todo lo que sale en pantalla ---------------
* capture mkdir crea la carpeta output si no existe (y no reclama si ya existe).
capture mkdir "output"

capture log close
log using "output/s12s1_prueba.log", replace text
display "Esto queda escrito en el log"
summarize edad
log close

* [CORRE Y OBSERVA] Abre output/s12s1_prueba.log con cualquier editor de texto:
*   ahí está todo lo que salió entre log using y log close.
*
*   replace  sobrescribe el log anterior (sin replace, la segunda vez da error)
*   text     log de texto plano (.log), legible en cualquier lado; sin text,
*            Stata usa su formato SMCL (.smcl), que solo se lee bien en Stata.
*   capture log close  evita el error "log file already open" cuando un
*            do-file anterior se cortó a la mitad y dejó el log abierto.


* -----------------------------------------------------------------------------
* BLOQUE E — Importar datos: CSV, Excel y tipos
* -----------------------------------------------------------------------------

* --- E1. CSV: las opciones que importan ------------------------------------
* [CORRE Y OBSERVA]
import delimited "data/raw/casen_reducido.csv", clear varnames(1) encoding("utf-8")
describe, short

* [DEBERÍAS VER] (6 vars, 60 obs)
*   varnames(1)        la fila 1 trae los nombres          (R: header = TRUE)
*   encoding("utf-8")  tildes y ñ bien leídas              (R: fileEncoding)

* [PREDICE] La ENE (Semana 6) usa ; como separador y coma decimal. ¿Cuántas
*   variables crees que lee Stata si no se lo dices? (Tarda unos segundos:
*   son 97.946 personas.)
import delimited "data/raw/ene-2026-06-mjj.csv", clear
describe, short
version 14: import delimited "data/raw/ene-2026-06-mjj.csv", clear
describe, short

* [DEBERÍAS VER] depende de tu versión de Stata:
*   la primera (tu versión):  Stata 18 detecta el ; solo -> 222 variables.
*   la segunda (version 14:): (1 var) -> UNA sola columna con todo pegado.
*   "version 14:" delante de un comando lo corre con las reglas de Stata 14.
*   Si tienes Stata 14, las DOS salen con 1 variable. Es la misma trampa
*   de read.csv() contra read.csv2() en la Semana 6. Para que el do-file
*   funcione igual en cualquier versión, el separador se escribe siempre:

import delimited "data/raw/ene-2026-06-mjj.csv", clear ///
    delimiter(";") decimalseparator(",")
describe, short
summarize fact_cal

* [DEBERÍAS VER] (222 vars, 97,946 obs) · fact_cal: media 207.4408,
*   mínimo 6.347554 (con decimales: la coma se leyó bien).
*   Stata avisa "(encoding automatically selected: ISO-8859-1)": la ENE no
*   viene en UTF-8, por eso aquí NO se pone encoding("utf-8").
*   delimiter(";")        separador distinto de la coma   (R: sep = ";")
*   decimalseparator(",") decimales con coma              (R: dec = ",")

* --- E2. Excel: export excel e import excel --------------------------------
* No tenemos un Excel en data/raw, así que fabricamos uno con la CASEN y lo
* volvemos a leer.
* [CORRE Y OBSERVA]
capture mkdir "output"
use "data/processed/casen.dta", clear
export excel using "output/casen.xlsx", firstrow(variables) sheet("personas") replace

import excel "output/casen.xlsx", sheet("personas") firstrow clear
describe, short

* [DEBERÍAS VER] file output/casen.xlsx saved · (6 vars, 60 obs)

* [PREDICE] ¿Y si olvido firstrow?
import excel "output/casen.xlsx", sheet("personas") clear
list in 1/2

* [DEBERÍAS VER] (6 vars, 61 obs): las columnas se llaman A, B, C... y la
*   fila 1 trae los NOMBRES como si fueran datos (region, sector, educ...).
*   Por eso educ ahora es texto: una de sus "celdas" dice "educ".
*
*   firstrow           la fila 1 trae los nombres
*   sheet("personas")  qué hoja leer (por defecto, la primera)
*   cellrange(A3:F63)  leer solo un rango, si el Excel trae un título arriba
*
* Gotcha: export excel escribe las ETIQUETAS de valores como texto. Si una
* variable 0/1 tiene la etiqueta "Hombre"/"Mujer", al volver a importarla es un
* string. Para exportar los códigos: export excel ..., nolabel

* --- E3. Cuando un número llega como texto: destring ----------------------
* [CORRE Y OBSERVA] casen_ingresos.csv (S5) lo escribió R.
import delimited "data/raw/casen_ingresos.csv", clear encoding("utf-8")
describe ing_*

* [DEBERÍAS VER] ing_trabajo str7 · ing_capital str6 · ing_subsidios str5 ·
*   ing_total str7. ¡Texto! R guardó los faltantes como las letras NA, y una
*   columna con letras es texto para Stata.

destring ing_trabajo ing_capital ing_subsidios ing_total, replace ignore("NA")
summarize ing_total

* [DEBERÍAS VER] "characters N A removed; replaced as long" y
*   (5 missing values generated) en cada una · ing_total: Obs 55, media 655290.9
*   (el mismo ingreso de casen_reducido).

* [CORRE Y OBSERVA] casen_sucio.csv: el archivo que limpiaste en R en el lab S6.
import delimited "data/raw/casen_sucio.csv", clear encoding("utf-8")
describe
list in 1/4

* [DEBERÍAS VER] 45 personas; ingreso es str11 con valores como "$730.480";
*   sector y región vienen pegados en sector_region ("Comercio_Biobío").

* [PREDICE] ¿Basta con ignorar el $ y los puntos?
capture noisily destring ingreso, generate(ingreso_num) ignore("$.")

* [DEBERÍAS VER] ingreso: contains characters not specified in ignore(); no generate
*   Hay algo más que $ y puntos. Busquemos qué:
tabulate ingreso if strpos(ingreso, "$") == 0, missing

* [DEBERÍAS VER] 2 vacíos y 2 "s/i" (sin información).

replace ingreso = subinstr(ingreso, "$", "", .)     // quitar el signo $
replace ingreso = subinstr(ingreso, ".", "", .)     // quitar los puntos de miles
replace ingreso = "" if ingreso == "s/i"            // sin información = vacío
destring ingreso, replace
summarize ingreso

* [DEBERÍAS VER] (41 real changes made) dos veces, (2 real changes made), y
*   "ingreso: all characters numeric; replaced as long (4 missing values
*   generated)". summarize: Obs 41, máximo 5.00e+07: el ingreso de 50 millones
*   que en el lab S6 decidiste tratar como error. Es la misma limpieza que en
*   R hiciste con gsub() y na_if(). (La sector_region se separa en la
*   Sesión 2, Bloque D.)


* -----------------------------------------------------------------------------
* BLOQUE F — Ejemplo integrador: un do-file documentado de principio a fin
* -----------------------------------------------------------------------------
* [CORRE Y OBSERVA] Selecciona TODO este bloque (hasta log close) y córrelo de
* una vez. Es exactamente la estructura del bloque D1.

* ===== Análisis descriptivo CASEN =====
version 14
clear all
set more off
capture log close
log using "output/s12s1_casen.log", replace text

* 1. Cargar (desde el CSV, como read.csv en R)
*    encoding("utf-8"): el CSV trae tildes y ñ; sin esta opción, con version 14,
*    "Construcción" se leería "ConstrucciÃ³n".
import delimited "data/raw/casen_reducido.csv", clear varnames(1) encoding("utf-8")

* 2. Inspeccionar la estructura (el str() de R)
describe

* 3. Crear una variable derivada (con intención económica)
generate ingreso_miles = ingreso / 1000   // en miles: más fácil de leer en tablas

* 4. Describir
summarize ingreso educ edad

log close

* [DEBERÍAS VER]
*   import:    (6 vars, 60 obs)
*   describe:  region str13 · sector str13 · educ byte · edad byte ·
*              ingreso long · genero str1
*   generate:  (5 missing values generated)
*   summarize: ingreso  Obs 55  Mean 655290.9  Min 180000  Max 1093000
*              educ     Obs 60  Mean 12.73333  Min 6       Max 20
*              edad     Obs 60  Mean 44.51667  Min 20      Max 70
*
* Las mismas cifras que en R con summary(): mismo dato, otra herramienta.
* str13 = texto de hasta 13 caracteres; byte y long = enteros chicos y grandes
* (recap S3: los tipos de datos).


* -----------------------------------------------------------------------------
* CIERRE — lo que nos llevamos hoy
* -----------------------------------------------------------------------------
*   pwd / cd           Stata no usa el .Rproj: párate en la carpeta del proyecto
*   use ..., clear     una sola base en memoria; clear la reemplaza a propósito
*   preserve/restore   una foto de la base para volver a ella
*   * // /* */         comentarios; /// parte un comando largo
*   #delimit ;         otra forma de partir comandos (volver con #delimit cr)
*   su, gen, tab       abreviaturas de comandos; variables, nunca abreviadas
*   log using / close  el registro que se entrega junto al do-file
*   import delimited   varnames(1), encoding("utf-8"), delimiter(";")
*   import excel       firstrow, sheet(); export excel (ojo con las etiquetas)
*   destring           texto -> número: ignore("NA"), subinstr() antes si hace falta
*
* Sesión 2: los comandos para manipular datos (keep, generate, texto,
* categóricas con etiquetas, summarize, merge), siempre con su equivalente en R.
* =============================================================================
