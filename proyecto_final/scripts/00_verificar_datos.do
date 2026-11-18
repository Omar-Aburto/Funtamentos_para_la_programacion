/*==============================================================================
  PROYECTO FINAL · Fundamentos de Programación para Análisis Económico
  UdeC-EAN · 2026
  
  Archivo:     scripts/00_verificar_datos.do
  Equipo:      Luis Omar Aburto · Damian Ignacio Correa
  
  Propósito:   Verificar que la base CASEN 2024 se descargó y se abre
               correctamente, y confirmar que existen las variables clave
               del proyecto (Hito 1 · Propuesta).
  
  Pregunta:    ¿Cuánto más ganan al mes, en pesos, los ocupados de 25 a 64
               años de la Región de Ñuble con título técnico de nivel
               superior y con título profesional (4 o más años), respecto de
               quienes completaron solo la enseñanza media?
  
  Datos:       CASEN 2024, Ministerio de Desarrollo Social y Familia
               Descargada el 16/11/2026 desde
               https://observatorio.ministeriodesarrollosocial.gob.cl/encuesta-casen-2024
               Entrada:  data/raw/casen_2024.dta  (original, no se edita)
  
  Salida:      output/verificacion_datos.log
  
  Cómo correr: Abrir Stata con la carpeta raíz del proyecto como directorio
               de trabajo (las rutas son relativas) y ejecutar este archivo.
  
  Filtro:      región de Ñuble (region == 16), ocupados (activ == 1),
               25 a 64 años. Todas las cifras ponderadas usan expr
               (factor de expansión regional).
==============================================================================*/

log using "output/verificacion_datos.log", replace text

*------------------------------------------------------------------------------
* 1. Apertura de la base y tamaño muestral
*------------------------------------------------------------------------------
use "data/raw/casen_2024.dta", clear
describe, short
count                                                              // total nacional
count if region == 16                                              // Ñuble
count if region == 16 & activ == 1 & inrange(edad, 25, 64)         // ocupados 25-64

*------------------------------------------------------------------------------
* 2. Confirmación de variables clave
*------------------------------------------------------------------------------
describe yoprcor e6a e6c_completo esc edad sexo area expr

tab e6a         if region == 16 & activ == 1 & inrange(edad, 25, 64)
tab e6c_completo if region == 16 & activ == 1 & inrange(edad, 25, 64)
tab sexo area   if region == 16 & activ == 1 & inrange(edad, 25, 64)

*------------------------------------------------------------------------------
* 3. Ingreso de la ocupación principal: Ñuble vs. país (ponderado por expr)
*------------------------------------------------------------------------------
summarize yoprcor [aw=expr] if activ == 1 & inrange(edad, 25, 64)                      // país
summarize yoprcor [aw=expr] if region == 16 & activ == 1 & inrange(edad, 25, 64)       // Ñuble

*------------------------------------------------------------------------------
* 4. Definición de los grupos educativos
*------------------------------------------------------------------------------
tab e6a e6c_completo if region == 16 & activ == 1 & inrange(edad, 25, 64), missing
tab esc if e6a == 9  & region == 16 & activ == 1 & inrange(edad, 25, 64)   // media científico-humanista
tab esc if e6a == 11 & region == 16 & activ == 1 & inrange(edad, 25, 64)   // media técnico-profesional

*------------------------------------------------------------------------------
* 5. Distribución del ingreso (para decidir la regla de limpieza)
*------------------------------------------------------------------------------
summarize yoprcor [aw=expr] if region == 16 & activ == 1 & inrange(edad, 25, 64), detail

log close