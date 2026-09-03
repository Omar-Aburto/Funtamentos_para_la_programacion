# =============================================================================
# Laboratorio Semana 4 (adicional) — Listas: la caja que guarda cualquier cosa
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Autor: Omar Aburto
# Fecha: 2025-09-03
#
# Objetivo: dominar las listas: crearlas, acceder con [[ ]] vs [ ], guardar
#           varios data frames en una sola, y usarlas para agregar filas.
#
# CÓMO USARLO: donde veas ____ tienes que escribir tú. Corre cada bloque con
#              Cmd/Ctrl + Enter y compara con el "✅ Deberías ver".
#
# ⚠️ Ábrelo desde el .Rproj, no con RStudio a secas, o la ruta no funcionará.
#
# Regla IA: ChatGPT es CONSULTOR, no escritor. Debes poder explicar cada línea.
# =============================================================================

casen <- read.csv("data/raw/casen_reducido.csv")


# -----------------------------------------------------------------------------
# PASO 1 — Una lista guarda cosas de tipos distintos
# -----------------------------------------------------------------------------
# Un vector obliga a que todo sea del mismo tipo. Una lista, no: puede mezclar
# texto, números, vectores y hasta tablas enteras.
# TODO: completa los dos elementos que faltan.

resultado <- list(
  fuente    = "CASEN 2022",          # un texto
  n         = nrow(casen),           # un número
  variables = ncol(casen),           # un vector de texto (pista: nombres de columna)
  tabla     = head(casen, 3)         # ¡un data frame completo!
)

length(resultado)     # ¿cuántos elementos tiene la lista?
names(resultado)      # ¿cómo se llaman?

# ✅ Deberías ver: 4 y "fuente" "n" "variables" "tabla"
# 💡 Una lista es el objeto que usan casi todas las funciones de R para
#    devolver resultados. Cuando corras una regresión (Semana 8), lo que
#    obtienes de vuelta es exactamente esto: una lista.


# -----------------------------------------------------------------------------
# PASO 2 — [[ ]] contra [ ]: el punto que más confunde
# -----------------------------------------------------------------------------
# TODO: corre las dos y compara la CLASE del resultado.

class(resultado[[2]])     # con doble corchete
class(resultado[2])       # con corchete simple

# ✅ Deberías ver: "integer" y "list"
#
# 🔮 PREDICE antes de correr: ¿cuál de estas dos va a funcionar?
   # resultado[[2]] + 1   ->
#    resultado[2] + 1     ->

resultado[[2]] + 1
resultado[2] + 1        # descoméntala solo para ver el error

# 💡 LA REGLA: [[ ]] saca el CONTENIDO; [ ] devuelve una lista más chica que
#    todavía envuelve el contenido. Para operar, casi siempre quieres [[ ]].

# TODO: extrae el data frame guardado en `tabla`, usando su nombre.
resultado$tabla



# -----------------------------------------------------------------------------
# PASO 3 — Un data frame ES una lista
# -----------------------------------------------------------------------------
# TODO: comprueba las dos afirmaciones.

is.list(casen)      # ¿es una lista por dentro?
length(casen)       # en una lista, length() cuenta ELEMENTOS

# ✅ Deberías ver: TRUE y 6
#
# Pregunta guía: `length(casen)` da 6, no 60. ¿Por qué?
# RESPUESTA: ____________________________________________________________
#
# 💡 Porque un data frame es una lista de COLUMNAS. Sus elementos son las 6
#    variables, no las 60 filas. Por eso casen[["ingreso"]] funciona igual
#    que casen$ingreso.


# -----------------------------------------------------------------------------
# PASO 4 — Una lista de data frames
# -----------------------------------------------------------------------------
# Es la forma habitual de tener varias bases juntas: una tabla por región,
# por año o por país, dentro de un solo objeto.
# TODO: completa el filtro de las dos regiones que faltan.
table(casen$region)

nuble  <- casen[casen$region == "Ñuble", ]
biobio <- casen[casen$region == "Biobío", ]
maule  <- casen[casen$region == "Maule", ]

regiones <- list(nuble = nuble, biobio = biobio, maule = maule)
regiones <- list(nuble, biobio, maule)

# TODO: ¿cuántas filas tiene cada tabla de la lista?
nrow(regiones$nuble)
nrow(regiones$biobio)
nrow(regiones$maule)

# ✅ Deberías ver: 15, 10 y 12

# TODO: calcula el ingreso promedio de Ñuble accediendo DENTRO de la lista.
#       Pista: lista$elemento$columna
mean(regiones$nuble$ingreso, na.rm = TRUE)

# ✅ Deberías ver: 696692.3
# 💡 Cada elemento sigue siendo un data frame completo: se le aplica todo lo
#    de la Sesión 1 ($, filtros, nrow).


# -----------------------------------------------------------------------------
# PASO 5 — Las etiquetas son opcionales
# -----------------------------------------------------------------------------
# TODO: crea la misma lista pero SIN nombres (sin el `nombre =`).

sin_nombre <- list(____, ____)     # solo nuble y biobio

names(sin_nombre)        # ¿qué devuelve?
length(sin_nombre)

# ✅ Deberías ver: NULL y 2

# TODO: sin etiquetas, el acceso es por POSICIÓN. Saca la primera tabla.
nrow(sin_nombre[[____]])

# ✅ Deberías ver: 15
#
# 🔮 PREDICE: ¿qué devuelve `sin_nombre$nuble`? ¿Error o algo más?
sin_nombre$nuble

# ✅ Deberías ver: NULL — y esto es peligroso, porque NO da error.
#    El código sigue corriendo con un NULL adentro y falla más adelante,
#    lejos de donde estaba el problema. Por eso conviene etiquetar.


# -----------------------------------------------------------------------------
# PASO 6 — Usar una lista para agregar una fila
# -----------------------------------------------------------------------------
# Una fila nueva se escribe como una lista con UN valor por columna.
# TODO: completa los valores que faltan (inventa datos razonables).

fila_nueva <- list(
  region  = "Aysén",
  sector  = "Servicios",
  educ    = 15,
  edad    = 36,
  ingreso = 650000,
  genero  = "F"
)

casen_ampliado <- rbind(casen, fila_nueva)

dim(casen)             # antes
dim(casen_ampliado)    # después

# ✅ Deberías ver: 60 6 y luego 61 6
#
# ⚠️ rbind() exige que los nombres de columna COINCIDAN EXACTAMENTE. Prueba
#    a cambiar `educ` por `educacion` en la lista y mira el error. Es una
#    protección: evita pegar datos que no calzan.



nuble_region <- regiones$nuble
biobio_region <- regiones$biobio
nuble_biobio <- rbind(nuble_region, biobio_region)

# -----------------------------------------------------------------------------
# PASO 7 — Reunir todas las tablas de una lista
# -----------------------------------------------------------------------------
# do.call(rbind, lista) apila de una vez todos los data frames de la lista.
# TODO: complétalo y verifica que no se perdió ninguna fila.

juntas <- do.call(rbind, regiones)

dim(juntas)
nrow(nuble) + nrow(biobio) + nrow(maule)    # ¿coincide con las filas de arriba?

# ✅ Deberías ver: 37 6 en ambos casos
# 💡 Es el patrón real: procesas cada región por separado, guardas los
#    resultados en una lista y los reúnes al final en una sola tabla.


# -----------------------------------------------------------------------------
# PASO 8 — Guardar los resultados de un análisis en una lista
# -----------------------------------------------------------------------------
# Aquí se junta todo: una lista que documenta un análisis completo.
# TODO: complétala con tus propios cálculos sobre `casen`.

mi_analisis <- list(
  fuente      = "CASEN (muestra docente del curso)",
  fecha       = Sys.Date(),
  n_total     = nrow(casen),
  n_validos   = sum(!is.na(casen$ingreso)),
  ingreso_med = mean(casen$ingreso, na.rm = TRUE),     # promedio
  por_region  = regiones                                # la lista dentro de la lista
)

str(mi_analisis, max.level = 1)    # resumen de un nivel

# TODO: responde en comentarios.
# ¿Cuántos elementos tiene `mi_analisis`? ____
# ¿Qué clase tiene el elemento `por_region`? ____
#
# 💡 Una lista puede contener otra lista. Así se guarda un análisis completo
#    —datos, resultados y metadatos— en un solo objeto reproducible.


# -----------------------------------------------------------------------------
# PASO 9 — (Opcional) Desafío
# -----------------------------------------------------------------------------
# Sin usar dplyr todavía: construye una lista donde cada elemento sea el
# ingreso PROMEDIO de una región, y luego conviértela en un vector.
#
# Pista: sapply(regiones, function(x) mean(x$ingreso, na.rm = TRUE))
#
# TODO (opcional):
sapply(regiones, function(x) mean(x$ingreso, na.rm = TRUE))



# -----------------------------------------------------------------------------
# AUTOEVALUACIÓN antes de entregar
# -----------------------------------------------------------------------------
# [ ] No quedan ____ sin completar.
# [ ] El script corre completo de una vez (reinicia R y córrelo entero).
# [ ] Puedo explicar la diferencia entre [[ ]] y [ ].
# [ ] Entiendo por qué length() de un data frame cuenta columnas, no filas.
# [ ] Respondí las preguntas guía en los comentarios.


# -----------------------------------------------------------------------------
# ENTREGA: guarda este script y súbelo a tu repositorio de GitHub.
# Commit sugerido: "Lab S4 listas: listas, data frames y rbind"
# -----------------------------------------------------------------------------
