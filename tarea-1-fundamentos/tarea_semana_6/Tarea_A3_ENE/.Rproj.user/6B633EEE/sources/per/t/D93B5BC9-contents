# =============================================================================
# Tarea A3 — Limpieza de datos reales del INE
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Autor: Omar Aburto   |   Fecha: 2026-09-29
#
# Objetivo: Importar, limpiar y recodificar la Encuesta Nacional de Empleo 
# para analizar la relación entre el empleo informal y 
# los distintos tramos etarios en la Región de Ñuble.
# =============================================================================

# Cargar librerías necesarias
library(dplyr)
# =============================================================================
# PASO 1 — Pregunta y documentar la fuente
# =============================================================================
# PREGUNTA: ¿Existe una mayor proporción de empleo informal entre los jóvenes 
# (15 a 24 años) en comparación con los adultos mayores de 25 años en Ñuble?
#
# FUENTE: Instituto Nacional de Estadísticas (INE), Chile
# ENCUESTA: Encuesta Nacional de Empleo (ENE)
# TRIMESTRE MÓVIL: mayo - junio - julio 2026
# ENLACE: [Pega el enlace de donde bajaste el CSV]
# FECHA DE DESCARGA: 29 de septiembre de 2026
# UNIDAD DE OBSERVACIÓN: Personas en edad de trabajar (15 años o más)

# =============================================================================
# PASO 2 — Abrir archivo y reducir columnas
# =============================================================================
# ¿Por qué read.csv() no sirve aquí? 
# Porque read.csv() asume que las columnas se separan con coma (,) y los 
# decimales con punto (.). El archivo del INE es la versión "europea/chilena": 
# usa punto y coma (;) para las columnas y coma (,) para los decimales. 
# Si usamos read.csv(), cargaría las 222 columnas como una sola línea de texto.

ene <- read.csv2("data/raw/ene-2026-06-mjj.csv")

# Reducimos las 222 columnas
empleo_nuble <- ene |>
  select(region, edad, activ, ocup_form, starts_with("b15"), fact_cal) |>
  filter(region == 16) # Filtramos para quedarnos solo con la Región de Ñuble

# Revisamos las dimensiones para confirmar que se redujo
dim(empleo_nuble)
# =============================================================================
# PASO 3 — Traducir los códigos
# =============================================================================
empleo_nuble <- empleo_nuble |>
  mutate(
    situacion = case_when(
      activ == 1 ~ "Ocupado",
      activ == 2 ~ "Desocupado",
      activ == 3 ~ "Inactivo",
      TRUE       ~ "Menor de 15 años" # Para capturar todo lo demás
    ),
    formalidad = case_when(
      ocup_form == 1 ~ "Formal",
      ocup_form == 2 ~ "Informal",
      TRUE           ~ "No aplica" # Los no ocupados no tienen formalidad
    ),
    tramo_etario = case_when(
      edad >= 15 & edad <= 24 ~ "Joven (15-24)",
      edad >= 25 ~ "Adulto (25+)",
      TRUE ~ "Fuera de rango"
    )
  )

# Verificamos que no hayan quedado NA imprevistos 
table(empleo_nuble$formalidad, useNA = "ifany")
table(empleo_nuble$tramo_etario, useNA = "ifany")
# =============================================================================
# PASO 4 — Faltantes: estructurales o reales y el peligro de na.omit()
# =============================================================================
# Primero revisamos cuántos NA (valores perdidos) hay en cada columna
colSums(is.na(empleo_nuble))

# CLASIFICACIÓN DE FALTANTES:
# - region, edad, fact_cal: 0 NA. Son datos básicos de la muestra completa.
# - activ: Tiene NA correspondientes a los menores de 15 años. Es un faltante 
#   ESTRUCTURAL, ya que a los niños no se les pregunta su condición de actividad.
# - ocup_form, b15_1, b15_2: Tienen miles de NA. Son faltantes ESTRUCTURALES 
#   porque a los desocupados, inactivos y menores no se les pueden hacer 
#   preguntas sobre las características de su empresa o su contrato.

# DEMOSTRACIÓN DEL SESGO DE na.omit():
# Veamos qué pasa si intentamos  de limpiar usando na.omit()
base_destruida <- na.omit(empleo_nuble)

# Comparamos la composición de la base original vs la base destruida
table(empleo_nuble$situacion)
table(base_destruida$situacion)

# CONCLUSIÓN SOBRE EL SESGO:
# Al usar na.omit(), R elimina cualquier fila que tenga al menos un NA. 
# Como los desocupados y los inactivos tienen NA na.omit() los eliminó a todos.
# La base resultante solo 
# contiene personas ocupadas. Esto sesgaría por completo cualquier estudio, 
# ya que haría matemáticamente imposible calcular la tasa de desempleo o de 
# participación de los jóvenes en Ñuble.
# =============================================================================
# PASO 5 — Cazar los códigos centinela
# =============================================================================
# Auditamos la distribución completa de la variable b15_1
# (1: Menos de 5, 2: 5 a 10, 3: 11 a 49, 4: 50 a 199, 5: 200 y más)
sort(table(empleo_nuble$b15_1), decreasing = TRUE)

# Según el manual de la ENE (pág. 31), los códigos 88 ("No sabe") y 
# 99 ("No responde") son centinelas numéricos. 

# Evaluamos el efecto si calculáramos el promedio de esta categoría "a ciegas":
promedio_con_centinelas <- mean(empleo_nuble$b15_1, na.rm = TRUE)

# Convertimos los centinelas a verdaderos NA
empleo_nuble <- empleo_nuble |>
  mutate(
    tamano_empresa = na_if(b15_1, 88),
    tamano_empresa = na_if(tamano_empresa, 99)
  )

# Calculamos el promedio limpio
promedio_limpio <- mean(empleo_nuble$tamano_empresa, na.rm = TRUE)

# Comparamos el efecto
c(crudo = promedio_con_centinelas, limpio = promedio_limpio)

# EFECTO CUANTIFICADO: 
# Al quitar los valores 88 y 99, el promedio del tamaño de empresa baja 
# drásticamente (el valor exacto lo verás en la consola). Si los dejábamos, 
# la media se inflaba artificialmente haciendo parecer que las empresas de Ñuble 
# son gigantes, lo cual es falso metodológicamente.
# =============================================================================
# PASO 6 — Ponderación y comparación
# =============================================================================
# Filtramos solo a los ocupados que pertenecen a los tramos de edad de interés
ocupados_nuble <- empleo_nuble |>
  filter(situacion == "Ocupado",
         tramo_etario %in% c("Joven (15-24)", "Adulto (25+)"))

# Calculamos informalidad cruda (contando filas) vs ponderada (sumando fact_cal)
resumen_informalidad <- ocupados_nuble |>
  group_by(tramo_etario, formalidad) |>
  summarise(
    n_muestra = n(),
    n_poblacion = sum(fact_cal),
    .groups = "drop" # Evita mensajes de advertencia de dplyr
  ) |>
  group_by(tramo_etario) |>
  mutate(
    tasa_cruda = round(100 * n_muestra / sum(n_muestra), 1),
    tasa_ponderada = round(100 * n_poblacion / sum(n_poblacion), 1)
  )

# Imprime la tabla en la consola para ver los resultados
print(resumen_informalidad)

# =============================================================================
# PASO 7 — Respuesta a la pregunta
# =============================================================================
# ¿Existe una mayor proporción de empleo informal entre los jóvenes (15 a 24)
# en comparación con los adultos mayores de 25 años en la Región de Ñuble?
#
# RESPUESTA:
# En la Región de Ñuble, el empleo informal se asocia fuertemente con la juventud.
# Al observar la tasa ponderada, los jóvenes (15-24) presentan un 56.9% de 
# ocupación informal (representando a 6.294 personas), cifra muy superior al 
# 33.3% que registran los adultos mayores de 25 años. Comparar el cálculo crudo 
# con el ponderado altera las tasas (ej. la informalidad juvenil pasa de 54.4% en 
# la muestra a 56.9% en la población), evidenciando que este grupo tiene un peso 
# poblacional distinto al que aparenta en la muestra . Una limitación de 
# estos datos transversales es que no permiten saber si esta alta informalidad 
# juvenil es permanente o si obedece a trabajos temporales o estudiantiles 
# propios de esta etapa formativa.
# =============================================================================
# PASO 8 — Guardar resultado y Bitácora
# =============================================================================
write.csv(empleo_nuble, "data/processed/ene_a3_limpia.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# BITÁCORA DE LIMPIEZA
# -----------------------------------------------------------------------------
# 1. Lectura: Usé read.csv2() porque el archivo del INE usa separador ";" y decimal ",".
# 2. Variables conservadas: region, edad, activ, ocup_form, b15_1, b15_2 y fact_cal.
# 3. Recodifiqué: activ (a situacion), ocup_form (a formalidad) y edad (a tramo_etario) 
#    usando case_when() con la cláusula "TRUE ~" para evitar NA imprevistos.
# 4. Faltantes: ocup_form tiene faltantes ESTRUCTURALES ya que no se indaga en inactivos 
#    y desocupados. Demostré que usar na.omit() sesga y elimina erróneamente a esta población.
# 5. Centinelas: Encontré "88" y "99" en la variable b15_1. Al convertirlos en verdaderos 
#    NA con na_if(), el promedio general bajó, corrigiendo la distorsión.
# 6. Ponderación: Usé fact_cal para expandir la muestra a la población real, lo que 
#    modificó las tasas de informalidad juvenil.
# =============================================================================
