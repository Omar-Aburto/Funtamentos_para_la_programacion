# =============================================================================
# GUION DE CLASE — Semana 7 · Sesión 2: Correlación y Análisis Bivariado
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: Oma      Fecha: [FECHA]
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · 🔮 PREDICE · 🟢 TU TURNO · ✅ Deberías ver
#
# HILO DE LA SEMANA: en la Sesión 1 construiste una caja de herramientas para
# describir UNA variable. Hoy la amplías a DOS, con la misma lógica:
#   si la función recibe VECTORES        -> R base
#   si recibe NOMBRES DE COLUMNA (dplyr) -> {{ }}
# =============================================================================

library(dplyr)

casen <- read.csv("data/raw/casen_reducido.csv") |>
  mutate(experiencia = pmax(edad - educ - 6, 0))


# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA — recupera tus funciones de la Sesión 1
# -----------------------------------------------------------------------------
# (Si las guardaste en scripts/funciones.R, bastaría con source("scripts/funciones.R").)

cv <- function(x, na.rm = TRUE) {
  sd(x, na.rm = na.rm) / mean(x, na.rm = na.rm)
}

tabla_por_grupo <- function(datos, grupo, variable) {
  datos |>
    group_by({{ grupo }}) |>
    summarise(n       = sum(!is.na({{ variable }})),
              media   = mean({{ variable }}, na.rm = TRUE),
              mediana = median({{ variable }}, na.rm = TRUE),
              cv      = cv({{ variable }}),
              .groups = "drop") |>
    arrange(desc(media))
}


# -----------------------------------------------------------------------------
# BLOQUE A — Donde quedamos: la región dice poco del ingreso
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA
tabla_por_grupo(casen, region, ingreso)

# ✅ Deberías ver: medias de 633 a 697 mil pesos, y CV de 0,30 a 0,37.
#
# 💡 Entre regiones hay ~63 mil pesos de diferencia; dentro de cada región la
#    dispersión es de ~200 mil. Saber la región de alguien dice poco.
#
# 🔮 PREDICE: de las variables numéricas que tenemos (educ, edad,
#    experiencia), ¿cuál crees que dice MÁS sobre el ingreso? ______________


# -----------------------------------------------------------------------------
# BLOQUE B — Correlación: ¿qué variable sí dice algo?
# -----------------------------------------------------------------------------
# 🔮 PREDICE: ingreso tiene 5 NA. ¿Qué devuelve cor() si no le dices nada? ____
cor(casen$educ, casen$ingreso)

# ✅ Deberías ver: NA. Basta un NA en cualquiera de las dos para contagiar todo.
#
# 💡 cor() NO tiene na.rm. Tiene el argumento `use`, que dice qué filas usar:
#      "everything"            (por defecto) todas; si hay un NA, devuelve NA
#      "complete.obs"          solo las filas con dato en TODAS las variables
#      "pairwise.complete.obs" en una matriz, para cada par sus filas completas
#    Es el mismo criterio que complete.cases() de la Semana 6.

# 🔵 CORRE Y OBSERVA — dos formas de medir la relación
cor(casen$educ, casen$ingreso, use = "complete.obs")                       # Pearson
cor(casen$educ, casen$ingreso, use = "complete.obs", method = "spearman")  # Spearman

# ✅ Deberías ver: 0.6767 y 0.6670
#
# 💡 Pearson mide relación LINEAL; Spearman, relación MONÓTONA por rangos (más
#    robusto a outliers). Aquí casi coinciden: la relación es bastante recta.

# Tres variables candidatas x dos coeficientes = seis líneas casi iguales.
# Regla de las tres veces: función.

# ✏️ COMPLETA: relacion(), el describir() de DOS variables (R base: recibe vectores).
relacion <- function(x, y) {
  completos <- !is.na(x) & !is.na(y)      # filas con AMBOS datos
  c(n        = sum(completos),
    pearson  = cor(x[completos], y[completos]),
    spearman = cor(x[completos], y[completos], method = "spearman"))
}
round(relacion(casen$educ, casen$ingreso), 3)

# ✅ Deberías ver: n 55 | pearson 0.677 | spearman 0.667

# 🟢 TU TURNO: arma la tabla con las tres candidatas.
round(rbind(educ        = relacion(casen$educ,casen$ingreso),
            edad        = relacion(casen$edad, casen$ingreso),
            experiencia = relacion(casen$experiencia, casen$ingreso)), 3)

# ✅ Deberías ver:
#                 n pearson spearman
#    educ        55   0.677    0.667
#    edad        55   0.062    0.079
#    experiencia 55  -0.088   -0.061
#
# 💡 LA RESPUESTA A LA PREGUNTA DEL DÍA: la educación dice mucho más del
#    ingreso que la edad o la experiencia. ¿Acertaste tu predicción?


# -----------------------------------------------------------------------------
# BLOQUE C — La matriz de correlación
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA
casen |>
  select(ingreso, educ, edad, experiencia) |>
  cor(use = "complete.obs") |>
  round(2)

# ✅ Deberías ver: la columna ingreso repite lo de relacion() (0,68 · 0,06 · -0,09).
#
# 🔮 PREDICE: edad y experiencia correlacionan 0,98. ¿Es un hallazgo sobre el
#    mercado laboral chileno, o algo más simple? ______________________
#
# ⚠️ No es un hallazgo: experiencia = edad - educ - 6. Dos variables fabricadas
#    una a partir de la otra SIEMPRE correlacionan. En la Semana 8 esto importa:
#    ponerlas juntas en una regresión trae problemas.


# -----------------------------------------------------------------------------
# BLOQUE D — Cuando la correlación engaña
# -----------------------------------------------------------------------------
# Primera trampa: un solo valor extremo. Un error de digitación clásico
# (Semana 6): alguien escribe 10.930.000 en vez de 1.093.000.

# 🔮 PREDICE: si al ingreso MÁS ALTO le agregas un cero, ¿qué le pasa a Pearson?
#    ¿Y a Spearman? __________________________________________

# 🔵 CORRE Y OBSERVA
ingreso_error <- casen$ingreso
fila <- which.max(ingreso_error)                  # el ingreso más alto
ingreso_error[fila] <- ingreso_error[fila] * 10   # le agregamos un cero

round(rbind(original  = relacion(casen$educ, casen$ingreso),
            con_error = relacion(casen$educ, ingreso_error)), 3)

# ✅ Deberías ver: Pearson cae de 0.677 a 0.382; Spearman queda en 0.667.
#
# 💡 Spearman trabaja con RANGOS: ese ingreso ya era el más alto, y con un cero
#    de más sigue siendo el más alto. Su rango no cambió.
#
# ⚠️ REGLA: si Pearson y Spearman difieren mucho, busca un valor extremo ANTES
#    de interpretar. Por eso relacion() reporta los dos.

# Segunda trampa: la correlación global puede esconder lo que pasa por grupo.
# Es la misma idea que tabla_por_grupo(), ahora con dos variables.

# ✏️ COMPLETA: los tres argumentos que son nombres de columna van con {{ }}.
correlacion_por_grupo <- function(datos, grupo, x, y) {
  datos |>
    group_by({{grupo}}) |>
    summarise(n = sum(!is.na({{x}}) & !is.na({{y}})),
              r = cor({{ x }}, {{ y }}, use = "complete.obs"),
              .groups = "drop")
}
correlacion_por_grupo(casen, genero, educ, ingreso)

# ✅ Deberías ver: F n 27, r 0.710 | M n 28, r 0.662

# 🟢 TU TURNO: ahora por sector.
correlacion_por_grupo(casen, sector, educ, ingreso)

# ✅ Deberías ver: todas entre 0,70 y 0,83; Construcción con n = 5.
#
# 🔮 PREDICE: ¿confiarías en la r de Construcción (0,70) tanto como en la de
#    Servicios (0,75)? ¿Por qué? ________________________________________
#
# ⚠️ Una correlación con 5 puntos cambia entera si uno solo se mueve.
#    El n va SIEMPRE al lado de la r.


# -----------------------------------------------------------------------------
# BLOQUE E — Dos variables categóricas: tablas cruzadas en la ENE
# -----------------------------------------------------------------------------
# La correlación es para números. Para categorías, tablas de contingencia.
# Y para eso volvemos a la base real de la Semana 6.
# ⏱ La lectura tarda 2-3 segundos.

# 🔵 CORRE Y OBSERVA — preparación (todo esto ya lo hiciste en la Semana 6)
ocupados <- read.csv2("data/raw/ene-2026-06-mjj.csv") |>
  filter(activ == 1) |>
  mutate(formal = case_when(ocup_form == 1 ~ "Formal",
                            ocup_form == 2 ~ "Informal"),
         sexo   = case_when(sexo == 1 ~ "Hombre", sexo == 2 ~ "Mujer"),
         tramo  = case_when(edad < 25 ~ "15-24",
                            edad < 45 ~ "25-44",
                            edad < 65 ~ "45-64",
                            TRUE      ~ "65+"))
nrow(ocupados)

# ✅ Deberías ver: 41850

# 🔵 CORRE Y OBSERVA — table() con DOS vectores cuenta cada combinación
tabla <- table(ocupados$sexo, ocupados$formal)
tabla

# ✅ Deberías ver: Hombre 16204 formal / 6513 informal | Mujer 13124 / 6009
#
# 💡 Las frecuencias no se comparan: hay más hombres ocupados, así que tienen
#    más de todo. Hay que pasar a PROPORCIONES.

# prop.table() divide cada celda por un total. margin dice CUÁL total:
#    sin margin -> sobre el total de la tabla
#    margin = 1 -> dentro de cada FILA
#    margin = 2 -> dentro de cada COLUMNA

# 🔮 PREDICE: quieres saber si las mujeres son más informales que los hombres.
#    ¿Cuál de las tres necesitas? ______________

round(prop.table(tabla), 3)
round(prop.table(tabla, margin = 1), 3)
round(prop.table(tabla, margin = 2), 3)

# ✅ Deberías ver, en la celda Hombre-Informal:
#    sin margin 0.156 | margin = 1 0.287 | margin = 2 0.520
#
# 💡 Cada una responde otra pregunta:
#    0.156 -> el 15,6 % de TODOS los ocupados son hombres informales
#    0.287 -> el 28,7 % de los HOMBRES son informales      <- la que queríamos
#    0.520 -> el 52,0 % de los INFORMALES son hombres
#
# ⚠️ Para comparar grupos, el grupo va en las filas y se usa margin = 1.

# ✏️ COMPLETA: la versión dplyr, con un argumento POR DEFECTO para el peso.
tabla_cruzada <- function(datos, fila, columna, peso = NULL) {
  datos |>
    count({{ fila }}, {{ columna }}, wt = {{ peso }}) |>   # sin peso: cuenta filas
    group_by({{ fila }}) |>
    mutate(prop = round(n / sum(n), 3)) |>
    ungroup()
}
tabla_cruzada(ocupados, sexo, formal)                      # sin ponderar
tabla_cruzada(ocupados, sexo, formal, peso = fact_cal)         # ponderada (Semana 6)

# ✅ Deberías ver:
#    sin ponderar -> Hombre informal 0.287 | Mujer informal 0.314
#    ponderada    -> Hombre informal 0.251 | Mujer informal 0.283
#
# 💡 Sin peso cuenta FILAS; con fact_cal cuenta PERSONAS. La ponderada es la
#    comparable con la cifra que publica el INE.

# 🔵 CORRE Y OBSERVA — ¿la diferencia entre hombres y mujeres es significativa?
chisq.test(tabla)$p.value

# ✅ Deberías ver: 1.208783e-09
#
# 🔮 PREDICE: p casi cero para una brecha de 3 puntos. ¿Eso la vuelve
#    importante? ____________________
#
# ⚠️ Con 41.850 casos casi cualquier diferencia es "significativa".
#    SIGNIFICANCIA ESTADÍSTICA NO ES IMPORTANCIA ECONÓMICA.

# 🟢 TU TURNO: la informalidad por tramo de edad, ponderada. Quédate solo con
#    las filas de informales.
tabla_cruzada(ocupados, ____, formal, peso = fact_cal) |>
  filter(formal == "Informal")

# ✅ Deberías ver: 15-24 0.328 | 25-44 0.222 | 45-64 0.261 | 65+ 0.562
#
# 💡 Esto sí es grande: la informalidad forma una U con la edad, y más de la
#    mitad de los ocupados sobre 65 años trabaja sin contrato ni cotizaciones.


# -----------------------------------------------------------------------------
# BLOQUE F — Ejemplo integrador: triangular con funciones propias
# -----------------------------------------------------------------------------
# ✏️ COMPLETA: tramos de educación con case_when (Semana 5) y la función
#    de la Sesión 1.
casen |>
  mutate(tramo_educ = case_when(educ <  12 ~ "1. Menos de 12",
                                educ == 12 ~ "2. Media completa",
                                ____       ~ "3. Superior")) |>
  tabla_por_grupo(tramo_educ, ____)

# ✅ Deberías ver: Superior 777926 | Media completa 584000 | Menos de 12 521381
#
# 💡 TRIANGULACIÓN: la correlación (0,68) y las medias por tramo cuentan lo
#    mismo desde dos ángulos. Un hallazgo robusto se ve por varios caminos.
#
# ⚠️ Y el límite: educación e ingreso SE ASOCIAN. No podemos decir que estudiar
#    CAUSE mayor ingreso: habilidad, origen y redes afectan a ambos.


# -----------------------------------------------------------------------------
# CIERRE — la caja de herramientas de la semana:
#   R base (vectores):         cv() · describir() · relacion()
#   dplyr con {{ }} (columnas): tabla_por_grupo() · correlacion_por_grupo() ·
#                              tabla_cruzada()
#   El n va al lado de toda cifra · significativo no es importante ·
#   correlación no es causalidad.
# Al laboratorio: escribir estas funciones y aplicarlas sin cambios a la ENE.
# =============================================================================
