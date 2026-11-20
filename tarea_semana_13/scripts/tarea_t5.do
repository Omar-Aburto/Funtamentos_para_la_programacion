* =============================================================================
* Proyecto: Tarea T5 — Do-file automatizado (Análisis CASEN)
* Autor:Omar Aburto 
* Fecha: 2026-11-19
* =============================================================================
version 14
clear all
set more off
capture mkdir "output"
capture log close
log using "output/tarea_t5.log", replace text

* --- 1. Parámetros (lo único que se edita) -----------------------------------
* Se usa local por defecto porque vive solo mientras corre este do-file
local datos     "data/raw/casen_reducido.csv"
local depvar    "ingreso"
local numericas "ingreso educ edad experiencia"
local controles "educ experiencia"
local grupos    "sector region genero"
local grp_reg   "sector"

* Se usa global para valores de referencia transversales que podrían
* reutilizarse en otros do-files del proyecto durante la misma sesión.
global umbral = 500000
global fuente "CASEN, muestra del curso (60 personas)"

* --- 2. Carga y preparación de datos -----------------------------------------
import delimited "`datos'", clear varnames(1) encoding("utf-8")

* Experiencia potencial de Mincer: acotada en 0 para evitar valores negativos
generate experiencia = max(edad - educ - 6, 0)
label variable experiencia "Experiencia potencial (años)"

* Indicadora 0/1 para sexo (genero es string y no entra como factor en regress)
generate mujer = (genero == "F")
label variable mujer "Mujer (1 = sí)"
label define mujer_lbl 0 "Hombre" 1 "Mujer"
label values mujer mujer_lbl

* --- 3. Descriptivos automatizados sobre variables numéricas (foreach) -------
foreach v of local numericas {
    display _newline "===== Estadísticos detallados: `v' ====="
    summarize `v', detail
}

* --- 4. Conteo por tramos económicos (forvalues) -----------------------------
* Agrupa los años de escolaridad en tramos de 4 años (básica, media, superior)
display _newline "===== Distribución por tramos de educación ====="
forvalues t = 4(4)16 {
    quietly count if educ >= `t' & educ < `t' + 4 
    display "Educación de `t' a " `t' + 3 " años: " r(N) " personas"
}

* --- 5. Programa reutilizable llamado desde un loop (program + foreach) -------
* capture program drop evita el error "program already defined" al re-ejecutar
capture program drop descriptivos_grupo
program define descriptivos_grupo
    display _newline "=== Descriptivos por `1' ==="
    tabulate `1'
    tabstat `depvar' educ, by(`1') statistics(mean sd n)
end

foreach g of local grupos {
    descriptivos_grupo `g'
}

* --- 6. Variable temporal (tempvar) -------------------------------------------
* tempvar es más seguro que generate + drop porque asigna un nombre interno único
* (no sobrescribe variables existentes) y se borra solo al terminar, incluso si hay error.
tempvar ing_miles
generate `ing_miles' = `depvar' / 1000
label variable `ing_miles' "Ingreso mensual en miles ($)"
summarize `ing_miles'

* --- 7. Manejo explícito de missing al filtrar --------------------------------
* En Stata, el missing (.) es mayor que cualquier número positivo. Sin
* "& !missing(...)", Stata incluiría a las 5 personas sin dato de ingreso.
count if `depvar' > $umbral & !missing(`depvar')
display "Personas con `depvar' sobre $" $umbral ": " r(N)

* --- 8. Modelos guardados y comparados (estimates store) ----------------------
quietly regress `depvar' `controles'
estimates store m1

quietly regress `depvar' `controles' i.mujer
estimates store m2

estimates table m1 m2, b(%9.0f) se stats(N r2) stfmt(%5.3f)

* Mostrar coeficiente de educación de m2 sin copiarlo a mano
estimates restore m2
display "Coeficiente de educación (m2): $" %9.0fc _b[educ] " (EE = " %7.0fc _se[educ] ")"

* --- 9. Regresión por sector en matriz J() y exportación a Excel --------------
levelsof `grp_reg', local(sectores)
local k : word count `sectores'
matrix R = J(`k', 3, .)

local i = 1
foreach s of local sectores {
    quietly regress `depvar' educ if `grp_reg' == "`s'"
    matrix R[`i', 1] = _b[educ]
    matrix R[`i', 2] = _se[educ]
    matrix R[`i', 3] = e(N)
    local i = `i' + 1
}

matrix colnames R = beta_educ ee n
matrix rownames R = `sectores'
matrix list R, format(%9.0f)

putexcel set "output/tarea_t5_por_sector.xlsx", replace
putexcel A1 = ("Sector") B1 = ("Beta educ") C1 = ("Error est.") D1 = ("n")
putexcel B2 = matrix(R)

local fila = 2
foreach s of local sectores {
    putexcel A`fila' = ("`s'")
    local fila = `fila' + 1
}
putexcel A9 = ("Fuente: $fuente")

* --- 10. Cierre del log e interpretación económica ----------------------------
log close

* =============================================================================
* INTERPRETACIÓN DE RESULTADOS:
* En el modelo m2, cada año adicional de educación se asocia a un aumento de
* \$42.246 en el ingreso mensual, manteniendo constantes la experiencia y el sexo.
* Entre m1 y m2, al agregar la variable indicadora de mujer (i.mujer), el
* coeficiente de educación casi no cambia (pasa de \$42.199 a \$42.246) y el R2
* sube levemente de 0,458 a 0,475. En las regresiones por sector, los coeficientes
* son poco precisos debido al bajo número de observaciones por grupo (entre n = 5
* en Construcción y n = 15 en Servicios), generando errores estándar elevados.
* Como limitación, el reducido tamaño muestral (n = 55) y la ausencia de controles
* por variables no observadas (como habilidad) impiden establecer causalidad.
* =============================================================================