# =============================================================================
# Laboratorio Semana 4 — Análisis Exploratorio Inicial con CASEN
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Autor: Omar ABurto
# Fecha: 2025-09-01
#
# Objetivo: cargar un subconjunto de CASEN, explorar su estructura, crear un
#           subset con una condición compuesta y calcular estadísticas básicas.
#
# Regla IA: ChatGPT es CONSULTOR, no escritor. Debes poder explicar cada línea.
# =============================================================================


# -----------------------------------------------------------------------------
# PASO 1 — Cargar los datos
# -----------------------------------------------------------------------------
# El archivo está en data/raw/. Usa una ruta RELATIVA (no C:/Users/...).
# TODO: carga el CSV en un objeto llamado `casen`.

casen <- read.csv("data/raw/casen_reducido.csv")
rm(casen_reducido)
# -----------------------------------------------------------------------------
# PASO 2 — Explorar la estructura ANTES de analizar
# -----------------------------------------------------------------------------
# Corre cada una y observa: ¿qué tipo tiene cada columna? ¿hay NA? ¿cuántas filas?
# TODO: completa las cuatro funciones de inspección.

str(casen)        # tipos de cada columna  ← la más importante
head(casen)       # primeras filas
dim(casen)        # filas x columnas
summary(casen)    # resumen estadístico por columna

# Pregunta guía (responde en un comentario):
# ¿La columna `ingreso` quedó como numérica? ¿Cuántos NA detectas?
# RESPUESTA: ____________________________________________________________


# -----------------------------------------------------------------------------
# PASO 3 — Crear un subset con una condición COMPUESTA
# -----------------------------------------------------------------------------
# Trabajadores mayores de 30 años Y con más de 12 años de educación.
# TODO: completa la condición lógica dentro de los corchetes [ , ].

sub <- casen[casen$edad > 30 & casen$educ > 12, ]


# -----------------------------------------------------------------------------
# PASO 4 — Calcular estadísticas descriptivas
# -----------------------------------------------------------------------------
# Sobre el subset y comparando con el total.
# TODO: completa los cálculos. OJO con los NA en `ingreso` → usa na.rm = TRUE.

n_sub          <- nrow(sub)                              # cantidad de observaciones
edad_prom      <- mean(sub$edad)                         # edad promedio del grupo
ingreso_prom   <- mean(sub$ingreso, na.rm = TRUE)        # ingreso promedio del grupo
ingreso_total  <- mean(casen$ingreso, na.rm = TRUE)      # ingreso promedio general

# Imprime los resultados
n_sub
edad_prom
ingreso_prom
ingreso_total

# Pregunta guía:
# ¿El grupo (mayores de 30 con educación > 12) gana MÁS que el promedio general?
# ¿Por qué crees que ocurre eso? (relación educación–ingreso)
# RESPUESTA: ____________________________________________________________


# -----------------------------------------------------------------------------
# PASO 5 — (Opcional) Una pregunta propia
# -----------------------------------------------------------------------------
# Formula UNA pregunta sobre estos datos y respóndela con código.
# Ejemplo: ¿cuál es el ingreso promedio por sector? ¿hay brecha por género?
# TODO: escribe tu propio análisis aquí.
mean(casen$ingreso[casen$sector == "Agricultura"])



# -----------------------------------------------------------------------------
# ENTREGA: guarda este script y súbelo a tu repositorio de GitHub.
# Commit sugerido: "Lab S4: análisis exploratorio CASEN"
# -----------------------------------------------------------------------------
