*===============================================================================
* ¨Primera clase de Stata donde se aprendera su funcionamiento basico 
* Autor: Omar Aburto   Fecha: 2026-11-03
*===============================================================================

* 1.Fijamos el working directory 
cd "C:\Users\omara\OneDrive\Documentos\Funtamentos_para_la_programacion\semana_12"

* 2.Comprobar que las bases de datos estan en el working directory
confirm file "data/raw/casen_reducido.csv"
confirm file "data/raw/casen.dta"

* 3.El comando "use" es para utilizr una base de datos 
* Se usa clear para usar una nueva base de datos 
use "data/raw/casen.dta", clear

* 4.Se usa display para imprimir en pantalla 
display "hola mundo"

* 5.En Stata se pueden acortar las funciones "dis = display" pero si hay dos 
* funciones que empiezan igual hay que espicificar 

* 6.Se usa para mantener solo esos datos y se cambia la base de datos de la memoria ram
* no asi la de la del disco duro hay que usar save para guardar ahi
keep if edad > 30

* 7.Es el antonimo de keep (if filtra por fila  sin el se seleccionan columnas)
drop if <=30

* 8.Crear nuevas variables (se puede usar g = generate)
generate y = ingreso / 1000

* 9.Se usa para hacer cambios temporales y no cambiar la base de datos
preserve 
keep if sector == "Agricultura"
count                  
restore
count

* 10.Saltos de linea
tabstat ingreso educ edad, /// // forma 1 (la del curso): /// al final
by(sector) stat(mean sd n)
#delimit ; // forma 2: cada comando termina en ;
tabstat ingreso educ edad,
by(sector) stat(mean n) ;
summarize ingreso
summarize educ ; // ← olvidé el ; de la línea anterior
#delimit cr // volver a la regla normal (Enter)

* 11. Guardar la bitacora (mkdir = make directory)
capture mkdir "output" // crear la carpeta si no existe 
ccapture log close // cerrar un log que quedó abierto
log using "output/analisis.log", replace text // se guarda como texto
* ... todo el análisis ...
log close

* 12. Csv: formas de importar
import delimited "data/raw/casen_reducido.csv", clear varnames(1) encoding("utf-8")

* La ENE (S6): separador ; y decimales con coma
*version 14: import delimited "data/raw/ene-2026-06-mjj.csv", clear // (1 var)
*import delimited "data/raw/ene-2026-06-mjj.csv", clear ///
*delimiter(";") decimalseparator(",") 

* El "NA" de R: casen_ingresos.csv (S5) trae los faltantes como letras
import delimited "data/raw/casen_ingresos.csv", clear encoding("utf-8")
describe ing_total // str7: ¡texto!
destring ing_trabajo ing_capital ing_subsidios ing_total, replace ignore("NA")
summarize ing_total
* casen_sucio.csv (lab S6): "$730.480" y "s/i"
import delimited "data/raw/casen_sucio.csv", clear encoding("utf-8")
tabulate ingreso strpos(ingreso, "$") == 0, missing // no se puede porque stata no puede leer los valores perdidos 

replace ingreso = subinstr(ingreso, "$", "", .) // quitar el $
replace ingreso = subinstr(ingreso, ".", "", .) // quitar los puntos de miles
replace ingreso = "" if ingreso == "s/i" // sin información → vacío
destring ingreso, replace
summarize ingreso





























