# =============================================================================
# GUION DE CLASE — Semana 7 · Sesión 1: Descriptivos y Funciones Propias
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: Omar Aburto      Fecha: 2026-09-29
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · 🔮 PREDICE · 🟢 TU TURNO · ✅ Deberías ver
# =============================================================================

library(dplyr)
library(e1071)     # para skewness y kurtosis

casen <- read.csv("data/raw/casen_reducido.csv") |>
  mutate(experiencia = pmax(edad - educ - 6, 0))


# -----------------------------------------------------------------------------
# BLOQUE A — Repaso rápido: describir una variable
# -----------------------------------------------------------------------------
# Todo esto ya lo calculaste entre las Semanas 3 y 6. Va rápido.

# 🔵 CORRE Y OBSERVA — centro, dispersión y posición en una sola salida
c(media   = mean(casen$ingreso, na.rm = TRUE),
  mediana = median(casen$ingreso, na.rm = TRUE),
  sd      = sd(casen$ingreso, na.rm = TRUE),
  iqr     = IQR(casen$ingreso, na.rm = TRUE))
quantile(casen$ingreso, probs = c(0.10, 0.90), na.rm = TRUE)

# ✅ Deberías ver: media 655290.9 | mediana 672000 | sd 209912.4 | iqr 306500
#                  p10 384800 | p90 942400

# 🔮 PREDICE: la mediana es MAYOR que la media. ¿Hacia qué lado tiene la cola
#    esta distribución? ¿Es lo que esperarías de ingresos reales? hacia la izquierda
#    

# 🔵 CORRE Y OBSERVA — la forma
skewness(casen$ingreso, na.rm = TRUE)
kurtosis(casen$ingreso, na.rm = TRUE)

# ✅ Deberías ver: -0.17 y -0.68
#
# 💡 Asimetría -0,17: casi simétrica, con una leve cola a la IZQUIERDA,
#    consistente con mediana > media. En la CASEN real ocurre lo contrario
#    (media > mediana, cola derecha). Esta muestra de 60 no reproduce el
#    patrón: sirve para aprender la técnica, no para concluir sobre Chile.
#
# ⚠️ Con 55 datos válidos, asimetría y curtosis son muy inestables. Se reportan
#    como indicio, nunca como conclusión.


# -----------------------------------------------------------------------------
# BLOQUE B — El problema de copiar y pegar, y tu primera función
# -----------------------------------------------------------------------------
# El coeficiente de variación (CV = sd / media) compara dispersión entre
# variables de distinta escala: pesos contra años, por ejemplo.

# 🔵 CORRE Y OBSERVA — el CV de tres variables, "a mano"
sd(casen$ingreso, na.rm = TRUE) / mean(casen$ingreso, na.rm = TRUE)
sd(casen$educ,    na.rm = TRUE) / mean(casen$educ,    na.rm = TRUE)
sd(casen$edad,    na.rm = TRUE) / mean(casen$edad,    na.rm = TRUE)

# ✅ Deberías ver: 0.3203 | 0.2614 | 0.3405
#
# ⚠️ Tres copias de la misma idea. Si en la tercera escribieras
#    sd(casen$edad) / mean(casen$educ), el código correría, daría un número
#    razonable y estaría MAL. Nadie lo notaría.
#
# 💡 LA REGLA DE LAS TRES VECES: si copias y pegas el mismo cálculo tres
#    veces, escribe una función.

# 🔵 CORRE Y OBSERVA — la anatomía de una función
cv <- function(x) {                          # nombre <- function(argumentos)
  sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE) # cuerpo: lo que calcula
}                                            # devuelve la ÚLTIMA línea

cv(casen$ingreso)
cv(casen$educ)
cv(casen$edad)

# ✅ Deberías ver: los MISMOS tres números de arriba.
#
# 💡 Al correr cv(casen$educ), dentro de la función `x` vale casen$educ.
#    `x` es solo un nombre de trabajo.

# 🟢 TU TURNO: el CV de la experiencia potencial de Mincer.
cv(casen$experiencia)
# ✅ Deberías ver: 0.5941
#
# 🔮 PREDICE: la experiencia es la variable MÁS dispersa de las cuatro.
#    ¿Por qué crees que varía tanto más que la educación?


# -----------------------------------------------------------------------------
# BLOQUE C — Argumentos, varios cálculos y ámbito
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA — un argumento con valor POR DEFECTO
cv<- function(x, na.rm = TRUE) {
  sd(x, na.rm = na.rm) / mean(x, na.rm = na.rm)
}
cv(casen$ingreso)                  # usa el valor por defecto
cv(casen$ingreso, na.rm = FALSE)   # quien llama lo cambia

# ✅ Deberías ver: 0.3203 y luego NA
#
# 💡 na.rm = TRUE en la definición se usa si nadie dice otra cosa. Así
#    funcionan mean() y sd(). Y "na.rm = na.rm" se lee: "pásale a sd() lo
#    que me pasaron a mí".

# ✏️ COMPLETA: la razón p90/p10 (Semana 4) como función.
razon_90_10 <- function(x) {
  percentiles <- quantile(x, probs = c(0.10, 0.90), na.rm = TRUE)
  unname(percentiles[2] / percentiles[1])
}
razon_90_10(casen$ingreso)

# ✅ Deberías ver: 2.449064 -> el percentil 90 gana ~2,45 veces el percentil 10

# 🔵 CORRE Y OBSERVA — una función que devuelve VARIOS valores, y que usa otra
describir <- function(x) {
  c(n       = sum(!is.na(x)),
    media   = mean(x, na.rm= T),
    mediana = median(x, na.rm= T),
    sd      = sd(x, na.rm= T),
    cv      = cv(x))  # usa TU función cv()
}
round(describir(casen$ingreso), 2)

# ✅ Deberías ver: n 55 | media 655290.91 | mediana 672000 | sd 209912.39 | cv 0.32
#
# 💡 Es tu propio summary(), con las medidas que TÚ eliges y con el n
#    correcto: sum(!is.na(x)) da 55, no las 60 filas.

# 🟢 TU TURNO: describe la educación con tu función.
round(describir(casen$educ), 3)

# ✅ Deberías ver: n 60 | media 12.733 | mediana 12.5 | sd 3.329 | cv 0.261

# 🔮 PREDICE: razon_90_10() creó un objeto llamado `percentiles`.
#    ¿Existe ahora en tu Environment?
razon_90_10(casen$educ)
exists("percentiles")

# ✅ Deberías ver: 1.888889 y luego FALSE
#
# 💡 Lo que se crea DENTRO de una función se queda dentro (es "local"). No
#    ensucia tu Environment ni pisa objetos de afuera con el mismo nombre.
#
# ⚠️ REGLA: todo lo que la función necesita, entra por los argumentos. Una
#    función que usa un objeto que no recibió funciona hoy en tu computador
#    y falla mañana en otro.


# -----------------------------------------------------------------------------
# BLOQUE D — Funciones con dplyr: el problema de los nombres
# -----------------------------------------------------------------------------
# Queremos UNA función que dé la media de cualquier variable por cualquier grupo.

# 🔮 PREDICE: esta función se ve perfecta. ¿Funcionará? ____________
media_por_grupo <- function(datos, grupo, variable) {
  datos |>
    group_by(grupo) |>
    summarise(media = mean(variable, na.rm = TRUE))
}
media_por_grupo(casen, region, ingreso)

# ✅ Deberías ver: ERROR -> "Column `grupo` is not found."
#
# ⚠️ dplyr buscó una columna llamada LITERALMENTE "grupo". Dentro de
#    group_by(), dplyr lee los nombres como columnas de la tabla. Es lo que
#    te permite escribir group_by(region) sin comillas desde la Semana 5... y
#    es exactamente lo que ahora estorba.

# ✏️ COMPLETA: envuelve cada argumento que entra a un verbo de dplyr con {{ }}.
media_por_grupo <- function(datos, grupo, variable) {
  datos |>
    group_by({{grupo }}) |>
    summarise(n     = sum(!is.na({{ variable }})),
              media = mean({{variable }}, na.rm = TRUE),
              .groups = "drop")
}
media_por_grupo(casen, region, ingreso)

# ✅ Deberías ver: 5 regiones. Ñuble arriba en media (696692), con n = 13.

# 🟢 TU TURNO: misma función, otra variable y otro grupo. Sin tocarla.
media_por_grupo(casen, genero, educ)

# ✅ Deberías ver (con genero): F 29 13.0 | M 31 12.5
#
# 💡 {{ grupo }} le dice a dplyr: "no busques una columna llamada grupo;
#    usa la que me pasaron". Regla práctica: todo argumento que termina
#    dentro de un verbo de dplyr va entre {{ }}.

# --- tapply(): agrupar en R base, sin dplyr ---------------------------------
# tapply(X, INDEX, FUN, ...)
#   X     = el vector a resumir
#   INDEX = el vector que define los grupos
#   FUN   = la función que se aplica a cada grupo
#   ...   = argumentos extra que se le pasan a FUN (por ejemplo na.rm = TRUE)

# 🔵 CORRE Y OBSERVA
tapply(casen$ingreso, casen$region, mean, na.rm = TRUE)

# ✅ Deberías ver: las 5 regiones con su media. Ñuble 696692.3 la más alta.
#
# 💡 Es lo mismo que group_by(region) |> summarise(mean(ingreso, na.rm = TRUE)),
#    pero devuelve un VECTOR con nombres, no un data frame.
#
# ⚠️ GOTCHA: na.rm = TRUE va DESPUÉS de la función, separado por coma.
#    tapply(x, g, mean(na.rm = TRUE)) da error.

# 🟢 TU TURNO: tapply() acepta TU función cv() como FUN. CV del ingreso por región.
tapply(casen$ingreso, casen$region, cv)

# ✅ Deberías ver: Araucanía 0.374 | Biobío 0.300 | Maule 0.329 |
#                  Metropolitana 0.309 | Ñuble 0.333

# 🔵 CORRE Y OBSERVA — la MISMA media_por_grupo(), ahora en R base con tapply()
media_por_grupo_base <- function(datos, grupo, variable) {
  tapply(datos[[variable]], datos[[grupo]], mean, na.rm = TRUE)
}
media_por_grupo_base(casen, "region", "ingreso")   # CON comillas

# ✅ Deberías ver: las mismas 5 medias que con la versión de dplyr.

# 🔮 PREDICE: ¿qué pasa si la llamas SIN comillas, como en dplyr? ____________
media_por_grupo_base(casen, region, ingreso)

# ✅ Deberías ver: ERROR -> "object 'region' not found"
#
# 💡 LA DIFERENCIA, en una tabla:
#                    R base                dplyr (tidyverse)
#    al llamar       "region" (comillas)   region (sin comillas)
#    dentro          datos[[grupo]]        {{ grupo }}
#    error típico    object not found      Column is not found
#    Las dos sirven. Lo único que no se puede es MEZCLARLAS.


# -----------------------------------------------------------------------------
# BLOQUE E — Tus funciones de R base ya funcionan dentro de dplyr
# -----------------------------------------------------------------------------
# cv() y razon_90_10() reciben un VECTOR. Por eso entran directo en
# summarise(), sin {{ }}.

# ✏️ COMPLETA: CV y razón 90/10 del ingreso por región.
casen |>
  group_by(region) |>
  summarise(n     = sum(!is.na(ingreso)),
            cv    = round(cv(ingreso), 3),
            r9010 = round(razon_90_10(ingreso), 2)) |>
  arrange(desc(cv))

# ✅ Deberías ver: Araucanía la más dispersa (cv 0.374), Biobío la menos (0.300)

# 🔵 CORRE Y OBSERVA — across() aplica TUS funciones a varias columnas
casen |>
  summarise(across(c(ingreso, educ, edad),
                   list(cv = cv, r9010 = razon_90_10))) |>
  round(3)

# ✅ Deberías ver: ingreso_cv 0.32 | educ_cv 0.261 | edad_cv 0.341 ...
#                  ingreso_r9010 2.449 | educ_r9010 1.889 | edad_r9010 2.795


# -----------------------------------------------------------------------------
# BLOQUE F — skim() y una función para el informe
# -----------------------------------------------------------------------------
# skim() viene del paquete skimr: install.packages("skimr") UNA vez.
library(skimr)

# 🔵 CORRE Y OBSERVA — un reporte completo de una variable, en una línea
casen |> select(ingreso) |> skim()

# ✅ Deberías ver dos partes:
#    1. Data Summary: 60 filas, 1 columna, tipo numeric.
#    2. Variable type: numeric -> n_missing 5 | complete_rate 0.917 |
#       mean 655291 | sd 209912 | p0 180000 | p25 499500 | p50 672000 |
#       p75 806000 | p100 1093000 | hist (mini-histograma)
#
# 💡 Cómo leerla: cada columna es algo que ya sabes calcular.
#      n_missing      = sum(is.na(x))
#      complete_rate  = mean(!is.na(x))   (0.917 = 55 de 60)
#      p0 / p100      = min() / max()
#      p25, p50, p75  = quantile()        (p50 es la mediana)
#
# 🔮 PREDICE: skim() recibe un data frame completo. ¿Qué crees que muestra si le
#    pasas también una columna de TEXTO, como region? ________________________

casen |> select(ingreso, region) |> skim()

# ✅ Deberías ver: DOS tablas, una por tipo (character y numeric). Para el texto
#    reporta otras cosas: n_unique (5 regiones), largo mínimo y máximo.
#
# 💡 skim() es para el PRIMER VISTAZO a una base que no conoces. Para la tabla
#    de un informe, una función propia como describir().

# 🔵 CORRE Y OBSERVA — la tabla que usarías en un informe, como función
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
tabla_por_grupo(casen, sector, ingreso)

# ✅ Deberías ver: Educación arriba (908857, cv 0.130) y Agricultura abajo
#    (447846, cv 0.350). Pero Educación tiene solo n = 7.

# 🟢 TU TURNO: dos preguntas más, CERO código nuevo.
tabla_por_grupo(casen, ____, ingreso)     # por región
tabla_por_grupo(casen, ____, ingreso)     # por género

# ✅ Deberías ver:
#    región -> Ñuble arriba (696692) y Biobío abajo (633200)
#    género -> M 673607 | F 636296
#
# 🔮 PREDICE: en la tabla por región, compara la diferencia ENTRE regiones
#    (633 a 697 mil) con la dispersión DENTRO de cada una (cv ~0,30 a 0,37,
#    o sea ~200 mil pesos). ¿Qué es más grande? ¿Qué implica? ______________
#
# 💡 La variación dentro de cada región es mucho mayor que entre regiones:
#    saber la región de alguien dice poco sobre su ingreso. Un hallazgo que
#    se pierde si solo miras promedios.


# -----------------------------------------------------------------------------
# CIERRE — función: nombre <- function(argumentos) { cuerpo } ·
#          valor por defecto · lo local se queda dentro ·
#          R base: columnas como texto, datos[["region"]] ·
#          dplyr: columnas sin comillas, {{ grupo }} dentro de la función ·
#          regla de las tres veces.
# Puente Sesión 2: tabla_por_grupo() mostró que la región dice poco del
#   ingreso. ¿Qué variable dice más? Para responderlo, la caja de
#   herramientas pasa de una variable a dos: relacion(),
#   correlacion_por_grupo() y tabla_cruzada().
# GUARDA TUS FUNCIONES: la Sesión 2 empieza usándolas.
# =============================================================================
