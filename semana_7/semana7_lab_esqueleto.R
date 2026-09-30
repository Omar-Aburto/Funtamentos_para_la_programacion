# =============================================================================
# Laboratorio Semana 7 — Funciones propias, descriptivos y correlación
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Autor: [TU NOMBRE]
# Fecha: [FECHA]
#
# Objetivo: construir tu caja de herramientas como FUNCIONES (Sesión 1: una
#           variable; Sesión 2: dos variables), usarlas para armar las tablas
#           de un informe y aplicarlas SIN CAMBIOS a una base real, la ENE del
#           INE. Prepara la T3 (S8, regresión): la correlación es su antesala.
#
# Las funciones de este laboratorio:
#   R base (reciben vectores):       cv() · razon_90_10() · describir() ·
#                                    relacion() · media_ponderada()
#   dplyr (reciben nombres, {{ }}):  tabla_por_grupo() · correlacion_por_grupo()
#                                    · tabla_cruzada()
#
# CÓMO USARLO: donde veas ____ tienes que escribir tú. Corre cada bloque con
#              Cmd/Ctrl + Enter y compara con el "✅ Deberías ver".
#
# ⚠️ Ábrelo desde el .Rproj, no con RStudio a secas, o la ruta no funcionará.
#
# Regla IA: ChatGPT es CONSULTOR, no escritor. Debes poder explicar cada línea.
# =============================================================================

library(dplyr)
library(e1071)
library(skimr)     # skim() — Sesión 1

casen <- read.csv("data/raw/casen_reducido.csv") |>
  mutate(experiencia = pmax(edad - educ - 6, 0))


# -----------------------------------------------------------------------------
# PASO 1 — Auditoría inicial
# -----------------------------------------------------------------------------
# TODO: corre las tres y anota lo que ves.

str(casen)
summary(casen)
colSums(is.na(casen))       # faltantes por columna

# TODO: el primer vistazo profesional, con skim() (Sesión 1).
skim(____)

# ✅ Deberías ver dos tablas (character y numeric). En la numérica, ingreso con
#    n_missing 5 y complete_rate 0.917; el resto con complete_rate 1.
#
# FALTANTES: ¿en qué columna(s) y cuántos? ____
# ¿Alguna variable tiene un rango sospechoso? (mira p0 y p100) ____


# -----------------------------------------------------------------------------
# PASO 2 — Tu caja de herramientas: tres funciones en R base
# -----------------------------------------------------------------------------
# Regla de las tres veces: lo que vas a calcular para varias variables, se
# escribe UNA vez, como función.
#
# TODO: completa las tres funciones.

# (a) Coeficiente de variación, con na.rm = TRUE como valor POR DEFECTO.
cv <- function(x, na.rm = ____) {
  sd(x, na.rm = na.rm) / mean(x, na.rm = na.rm)
}

# (b) Razón entre el percentil 90 y el percentil 10.
razon_90_10 <- function(x) {
  percentiles <- quantile(x, probs = c(0.10, 0.90), na.rm = TRUE)
  unname(percentiles[____] / percentiles[____])
}

# (c) Tu propio summary(): n válido, media, mediana, sd y cv.
describir <- function(x) {
  c(n       = sum(!is.na(x)),
    media   = mean(x, na.rm = TRUE),
    mediana = ____(x, na.rm = TRUE),
    sd      = sd(x, na.rm = TRUE),
    cv      = ____(x))              # usa tu propia función de (a)
}

# TODO: prueba las tres con el ingreso.
cv(casen$ingreso)
razon_90_10(casen$ingreso)
round(describir(casen$ingreso), 2)

# ✅ Deberías ver: 0.3203 | 2.449064 | n 55, media 655290.91, mediana 672000,
#    sd 209912.39, cv 0.32
#
# ⚠️ Fíjate en el n: 55, no 60. describir() cuenta solo los casos con dato,
#    que son los que se usaron para la media. Ese detalle separa un informe
#    serio de uno flojo.


# -----------------------------------------------------------------------------
# PASO 3 — La "Tabla 1" del informe, con tus funciones
# -----------------------------------------------------------------------------
# La Tabla 1 es la que lleva cualquier paper de economía aplicada: una fila
# por variable, las mismas medidas para todas.
# TODO: completa la tabla para las cuatro variables numéricas.

tabla1 <- rbind(
  ingreso     = describir(casen$ingreso),
  educ        = describir(casen$____),
  edad        = describir(casen$____),
  experiencia = describir(casen$____)
)
round(tabla1, 2)

# ✅ Deberías ver:
#                 n     media  mediana       sd   cv
#    ingreso     55 655290.91 672000.0 209912.39 0.32
#    educ        60     12.73     12.5      3.33 0.26
#    edad        60     44.52     45.5     15.16 0.34
#    experiencia 60     25.78     27.0     15.32 0.59
#
# 💡 Compara con escribir mean(), median() y sd() cuatro veces cada uno: 20
#    líneas copiadas, 20 oportunidades de equivocarse en una sola.
#
# TODO: ¿qué variable es la MÁS dispersa en términos relativos? ¿Por qué no
#       podrías responder esto mirando solo la columna sd? ____

# TODO: otra forma de aplicar TUS funciones a varias columnas: across() (Sesión 1).
casen |>
  summarise(across(c(ingreso, educ, edad),
                   list(cv = ____, r9010 = razon_90_10))) |>
  round(3)

# ✅ Deberías ver: ingreso_cv 0.32 | educ_cv 0.261 | edad_cv 0.341
#                  ingreso_r9010 2.449 | educ_r9010 1.889 | edad_r9010 2.795


# -----------------------------------------------------------------------------
# PASO 4 — Elegir entre media y mediana (con criterio)
# -----------------------------------------------------------------------------
# TODO: compara ambas para el ingreso y decide cuál reportarías.

mean(casen$ingreso, na.rm = TRUE)
median(casen$ingreso, na.rm = TRUE)
skewness(casen$ingreso, na.rm = TRUE)

# ¿Cuál reportarías y POR QUÉ? ____
#
# 💡 Pista: cuando hay asimetría fuerte o valores extremos, la mediana
#    representa mejor al "típico". Con distribuciones casi simétricas (como
#    esta, asimetría -0,17) da casi igual. En la CASEN real, con asimetría
#    positiva marcada, la diferencia importa mucho más.


# -----------------------------------------------------------------------------
# PASO 5 — Descriptivos por grupo con UNA función de dplyr
# -----------------------------------------------------------------------------
# Quieres la misma tabla por región, por sector y por género. Eso son tres
# veces: toca función. Como usa verbos de dplyr, los argumentos que son
# nombres de columnas van entre {{ }}.
#
# TODO: completa la función.

tabla_por_grupo <- function(datos, grupo, variable) {
  datos |>
    group_by({{ ____ }}) |>
    summarise(n       = sum(!is.na({{ variable }})),
              media   = mean({{ ____ }}, na.rm = TRUE),
              mediana = median({{ variable }}, na.rm = TRUE),
              cv      = cv({{ variable }}),
              .groups = "drop") |>
    arrange(desc(media))
}

# TODO: tres preguntas, una función.
tabla_por_grupo(casen, region, ingreso)
tabla_por_grupo(casen, ____, ingreso)
tabla_por_grupo(casen, ____, ingreso)

# ✅ Deberías ver:
#    region -> Ñuble arriba (696692) y Biobío abajo (633200)
#    sector -> Educación arriba (908857, n = 7) y Agricultura abajo (447846)
#    genero -> M 673607 (n 28) | F 636296 (n 27)
#
# 🔮 PREDICE: ¿qué pasa si olvidas las {{ }} en group_by()? Pruébalo en una
#    copia de la función y anota el mensaje de error: ______________________
#
# TODO: ¿algún grupo con n < 8? ¿Cuáles? ¿Qué haces con ellos al reportar? ____

# TODO: la versión de R base. tapply(X, INDEX, FUN) calcula el CV del ingreso
#       por sector, usando TU función cv() como FUN.
tapply(casen$ingreso, casen$____, cv)

# ✅ Deberías ver los mismos CV de la columna cv de tabla_por_grupo() por sector:
#    Agricultura 0.350 | Comercio 0.259 | Construcción 0.222 | Educación 0.130 |
#    Industria 0.222 | Servicios 0.143
#
# TODO: responde en un comentario.
# tapply() y tabla_por_grupo() dan los mismos números. ¿Qué devuelve cada una
# (un vector o una tabla)? ¿Cuál preferirías para un informe y por qué? ____


# -----------------------------------------------------------------------------
# PASO 6 — La misma función, otra base: la ENE del INE
# -----------------------------------------------------------------------------
# Aquí se ve para qué sirve de verdad una función: tabla_por_grupo() se
# escribió pensando en CASEN y funciona SIN CAMBIOS sobre la Encuesta Nacional
# de Empleo, con 97.946 filas.
#
# ⏱ La lectura tarda 2-3 segundos.

ene <- read.csv2("data/raw/ene-2026-06-mjj.csv")

# Preparación mínima (todo esto lo hiciste en el laboratorio de la Semana 6):
regiones <- c("Tarapacá", "Antofagasta", "Atacama", "Coquimbo", "Valparaíso",
              "O'Higgins", "Maule", "Biobío", "La Araucanía", "Los Lagos",
              "Aysén", "Magallanes", "Metropolitana", "Los Ríos",
              "Arica y Parinacota", "Ñuble")

ocupados <- ene |>
  filter(activ == 1) |>                                    # solo ocupados
  mutate(horas  = na_if(na_if(habituales, 888), 999),     # los dos centinelas
         formal = case_when(ocup_form == 1 ~ "Formal",
                            ocup_form == 2 ~ "Informal"),
         sexo   = case_when(sexo == 1 ~ "Hombre",
                            sexo == 2 ~ "Mujer"),
         region_txt = regiones[region])                    # Semana 6

nrow(ocupados)

# ✅ Deberías ver: 41850

# TODO: aplica TU función a las horas trabajadas, por formalidad y por sexo.
tabla_por_grupo(ocupados, ____, horas)
tabla_por_grupo(ocupados, ____, horas)

# ✅ Deberías ver:
#    formal -> Formal 41,5 h (cv 0,242) | Informal 30,0 h (cv 0,578)
#    sexo   -> Hombre 40,0 h (cv 0,319) | Mujer 35,7 h (cv 0,404)
#
# TODO: responde en un comentario.
# ¿Qué dice el CV de los informales (0,578) comparado con el de los formales
# (0,242)? ¿Qué nos dice eso sobre cómo son las jornadas informales? ______

# --- Una función más: la media PONDERADA ---
# Recuerda la Semana 6: en la ENE una fila no vale una persona. fact_cal dice
# cuántos chilenos representa cada una.
# TODO: completa la función. Solo se usan las filas donde x tiene dato.

media_ponderada <- function(x, w) {
  validos <- !is.na(x)
  sum(x[validos] * w[____]) / sum(w[validos])
}

mean(ocupados$horas, na.rm = TRUE)                        # sin ponderar
media_ponderada(ocupados$horas, ocupados$____)            # ponderada

# ✅ Deberías ver: 38.05 sin ponderar | 38.70 ponderada
#
# 🔮 PREDICE: R ya trae weighted.mean(). Corre esta línea tal cual.
#    ¿Qué devuelve y por qué? ______________
weighted.mean(ocupados$horas, ocupados$fact_cal)

# ✅ Deberías ver: NA. weighted.mean() también necesita na.rm = TRUE.
#    Tu función ya lo resuelve adentro: quien la use no tiene que acordarse.

# TODO (opcional): tu función de R base dentro de summarise(), por formalidad.
ocupados |>
  group_by(formal) |>
  summarise(sin_ponderar = round(mean(horas, na.rm = TRUE), 2),
            ponderada    = round(media_ponderada(horas, fact_cal), 2))

# ✅ Deberías ver: Formal 41,5 -> 41,4 | Informal 30,0 -> 31,2
#    La brecha formal-informal baja de 11,5 a 10,2 horas al ponderar.


# -----------------------------------------------------------------------------
# PASO 7 — De una variable a dos: relacion()
# -----------------------------------------------------------------------------
# En la Sesión 1 la región dijo poco del ingreso. ¿Qué variable dice más?
# Tres candidatas, dos coeficientes cada una: toca función (R base, vectores).
#
# TODO: completa la función.

relacion <- function(x, y) {
  completos <- !is.na(x) & !is.na(y)          # filas con AMBOS datos
  c(n        = sum(completos),
    pearson  = cor(x[completos], y[completos]),
    spearman = cor(x[completos], y[completos], method = "____"))
}

# TODO: la tabla con las tres candidatas.
round(rbind(educ        = relacion(casen$educ, casen$ingreso),
            edad        = relacion(casen$____, casen$ingreso),
            experiencia = relacion(casen$____, casen$ingreso)), 3)

# ✅ Deberías ver:
#                 n pearson spearman
#    educ        55   0.677    0.667
#    edad        55   0.062    0.079
#    experiencia 55  -0.088   -0.061
#
# 🔮 PREDICE antes de correr: ¿cuál esperabas que fuera la más fuerte?
#    ¿Se cumplió? ____


# -----------------------------------------------------------------------------
# PASO 8 — La matriz de correlaciones
# -----------------------------------------------------------------------------
# TODO: la matriz completa de las cuatro numéricas.

casen |>
  select(ingreso, educ, edad, experiencia) |>
  cor(use = "complete.obs") |>
  round(3)

# ✅ Deberías ver: ingreso-educ 0,677 (la más fuerte con el ingreso) y una
#    correlación edad-experiencia de 0,975.
#
# TODO: mira la correlación entre edad y experiencia. ¿Por qué es casi 1,
#       dado cómo construimos experiencia (edad - educ - 6)? ____
#
# ⚠️ Esa correlación no es un hallazgo: es una consecuencia de la fórmula.
#    Dos variables construidas una a partir de la otra SIEMPRE van a
#    correlacionar. Tenlo presente en la Semana 8: poner edad y experiencia
#    juntas en una regresión trae problemas justamente por esto.


# -----------------------------------------------------------------------------
# PASO 9 — La correlación por grupo: correlacion_por_grupo()
# -----------------------------------------------------------------------------
# La correlación global puede esconder lo que pasa dentro de cada grupo. Es
# tabla_por_grupo() (PASO 5) llevada a dos variables: tres argumentos son
# nombres de columna, así que van con {{ }}.
#
# TODO: completa la función.

correlacion_por_grupo <- function(datos, grupo, x, y) {
  datos |>
    group_by({{ ____ }}) |>
    summarise(n = sum(!is.na({{ x }}) & !is.na({{ y }})),
              r = cor({{ ____ }}, {{ ____ }}, use = "complete.obs"),
              .groups = "drop")
}

# TODO: educación e ingreso, por género y por región.
correlacion_por_grupo(casen, genero, educ, ingreso)
correlacion_por_grupo(casen, ____, educ, ingreso)

# ✅ Deberías ver:
#    genero -> F 0.710 (n 27) | M 0.662 (n 28)
#    region -> de Metropolitana 0.536 (n 11) a Ñuble 0.838 (n 13)
#
# TODO: responde en un comentario.
# ¿En qué región la educación "ordena" mejor el ingreso? ¿Con cuántos casos
# se calculó esa r? ¿Te basta ese n para afirmarlo? ____


# -----------------------------------------------------------------------------
# PASO 10 — Tablas cruzadas en la ENE: prop.table() y tabla_cruzada()
# -----------------------------------------------------------------------------
# En clase cruzamos informalidad con sexo y con edad. Aquí, con REGIÓN.

# --- Primero, la versión de R base ---
tabla_region <- table(ocupados$region_txt, ocupados$formal)

# 🔮 PREDICE: quieres saber qué parte de los ocupados de CADA REGIÓN es
#    informal. ¿Qué margin usas: ninguno, 1 o 2? ____
# TODO: completa y mira Ñuble y la Metropolitana.
round(prop.table(tabla_region, margin = ____), 3)[c("Ñuble", "Metropolitana"), ]

# ✅ Deberías ver: Ñuble 0.378 informal | Metropolitana 0.262 informal
#
# ⚠️ Con margin = 2 obtendrías 0.049 para Ñuble-Informal: "el 4,9 % de TODOS
#    los informales del país está en Ñuble". Otra pregunta, no la que queríamos.

# --- Ahora la versión dplyr, con ponderador ---
# TODO: completa la función. peso = NULL por defecto: sin peso cuenta filas.

tabla_cruzada <- function(datos, fila, columna, peso = ____) {
  datos |>
    count({{ fila }}, {{ columna }}, wt = {{ peso }}) |>
    group_by({{ fila }}) |>
    mutate(prop = round(n / sum(n), 3)) |>
    ungroup()
}

# TODO: informalidad por región, PONDERADA, ordenada de mayor a menor.
tabla_cruzada(ocupados, region_txt, formal, peso = ____) |>
  filter(formal == "Informal") |>
  arrange(desc(prop))

# ✅ Deberías ver: La Araucanía arriba (0,350) y Ñuble segunda (0,345);
#    Antofagasta y Magallanes abajo (0,211). El promedio nacional es 0,265.
#
# TODO: responde en comentarios.
# Sin ponderar (prop.table) Ñuble daba 0,378; ponderando da 0,345. ¿Por qué
# cambia? ¿Cuál reportarías? ____
# En el laboratorio de la Semana 6, Ñuble tuvo la tasa de desocupación más
# alta del país (10,96 %). ¿Qué agrega saber que además está segunda en
# informalidad? ____
# ¿Por qué hay que usar peso = fact_cal para comparar regiones? (Recuerda
# cómo se muestrean las regiones chicas.) ____


# -----------------------------------------------------------------------------
# PASO 11 — Interpretar con honestidad
# -----------------------------------------------------------------------------
# TODO: escribe 5 a 8 líneas sobre lo que encontraste en TODO el laboratorio
#       (descriptivos, grupos, correlaciones y ENE).
#
# Tres exigencias:
#   1. "Se asocia", NUNCA "causa". Una correlación NO es causalidad.
#   2. Comenta la MAGNITUD, no solo el signo ni el p-valor.
#   3. Nombra una limitación (n pequeño, sin controles, muestra no aleatoria).
#
# INTERPRETACIÓN:
# ____________________________________________________________________________
# ____________________________________________________________________________
# ____________________________________________________________________________
#
# ⚠️ Trampa clásica: una correlación alta entre A y B puede deberse a una
#    tercera variable C que afecta a ambas. Eso es exactamente lo que la
#    regresión múltiple de la Semana 8 permitirá empezar a manejar.


# -----------------------------------------------------------------------------
# AUTOEVALUACIÓN antes de entregar
# -----------------------------------------------------------------------------
# [ ] El script corre completo de una vez (reinicia R y córrelo entero).
# [ ] Escribí cv(), razon_90_10() y describir(), y sé qué hace cada argumento.
# [ ] Mi Tabla 1 reporta el n correcto (casos con dato, no filas totales).
# [ ] tabla_por_grupo() usa {{ }} y la apliqué a tres agrupaciones distintas.
# [ ] Apliqué la misma función a la ENE sin modificarla.
# [ ] Justifiqué la elección entre media y mediana.
# [ ] Usé skim() para el primer vistazo y tapply() como alternativa de R base.
# [ ] Elegí el margin correcto en prop.table() y sé qué pregunta responde cada uno.
# [ ] Escribí relacion(), correlacion_por_grupo() y tabla_cruzada().
# [ ] Sé decir cuáles de mis funciones son de R base y cuáles de dplyr, y por qué.
# [ ] Reporté el n junto a cada correlación por grupo.
# [ ] Usé fact_cal en la tabla cruzada de la ENE.
# [ ] Calculé e interpreté las correlaciones con lenguaje asociativo.
# [ ] Nombré al menos una limitación.


# -----------------------------------------------------------------------------
# ENTREGA: guarda este script y súbelo a tu repositorio de GitHub.
# Commit sugerido: "Lab S7: funciones propias, descriptivos y correlación"
#
# Tus funciones son reutilizables: guárdalas también en un archivo aparte,
# por ejemplo scripts/funciones.R, y cárgalas con source("scripts/funciones.R")
# en la T3 y en el Proyecto Final.
# -----------------------------------------------------------------------------
