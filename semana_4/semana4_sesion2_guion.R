# =============================================================================
# GUION DE CLASE — Semana 4 · Sesión 2: Listas y Operaciones Básicas
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: Omar Aburto      Fecha: 2026-09-01
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · 🔮 PREDICE · 🟢 TU TURNO · ✅ Deberías ver
# =============================================================================

# Recreamos el dataset de la Sesión 1 (córrelo primero):
trabajadores <- data.frame(
  region  = c("Ñuble", "Biobío", "Ñuble", "Maule"),
  sector  = c("Agricultura", "Servicios", "Comercio", "Agricultura"),
  educ    = c(12, 16, 8, 12),
  edad    = c(34, 45, 52, 29),
  ingreso = c(450000, 920000, 380000, 510000),
  genero  = c("M", "F", "M", "F")
)


# -----------------------------------------------------------------------------
# BLOQUE A — Listas
# -----------------------------------------------------------------------------
# Una LISTA guarda CUALQUIER cosa: números, textos, vectores de distinto largo,
# incluso otros data frames. No exige largos iguales ni un tipo único.

# 🔵 CORRE Y OBSERVA
analisis <- list(
  pais     = "Chile",
  anios    = c(2020, 2021, 2022),
  ingresos = c(450000, 920000, 380000),
  fuente   = "CASEN",
  trabajadores <- data.frame(
    region  = c("Ñuble", "Biobío", "Ñuble", "Maule"),
    sector  = c("Agricultura", "Servicios", "Comercio", "Agricultura"),
    educ    = c(12, 16, 8, 12),
    edad    = c(34, 45, 52, 29),
    ingreso = c(450000, 920000, 380000, 510000),
    genero  = c("M", "F", "M", "F")
  )
)
analisis$anios          # acceso por nombre con $

## El punto fino que confunde a todos: [ ] vs [[ ]] ---------------------------
# 🔮 PREDICE: ¿en qué se diferencian estas dos líneas?
analisis[[1]]           # [[ ]] devuelve el CONTENIDO del elemento
analisis[1]             # [ ] devuelve una SUB-LISTA (una caja más chica)

# ✅ Deberías ver: "Chile"  vs  $pais [1] "Chile"  (una lista de un elemento)
# 💡 [[ ]] "saca" el objeto de adentro; [ ] "recorta" la lista.

## Un data frame ES una lista -------------------------------------------------
# 🔵 CORRE Y OBSERVA
is.list(trabajadores)   # TRUE: por dentro es una lista de vectores del mismo largo

# ✏️ COMPLETA: extrae el vector `ingresos` de la lista con [[ ]] (por nombre).
analisis[["ingresos"]]


# -----------------------------------------------------------------------------
# BLOQUE B — Funciones de resumen
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA
ingreso <- trabajadores$ingreso
sum(ingreso)        # total
mean(ingreso)       # promedio
median(ingreso)     # mediana (robusta a outliers)
sd(ingreso)         # desviación estándar (dispersión)

# 💡 En datos de ingreso, media ≠ mediana (distribución asimétrica).

## Cuantiles ------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA
quantile(ingreso)            # min, Q1, mediana, Q3, max
quantile(ingreso, 0.9)       # percentil 90
range(ingreso)               # min y max

## Cuidado con los NA ---------------------------------------------------------
# 🔮 PREDICE: ¿qué entrega cada una?
mean(c(450000, NA, 380000))                  # un faltante "contagia"
mean(c(450000, NA, 380000), na.rm = TRUE)    # lo ignora

# ✅ Deberías ver: NA  ...  415000
# 💡 na.rm = TRUE está en casi todas las funciones de resumen.


# -----------------------------------------------------------------------------
# BLOQUE C — Operadores lógicos: combinar condiciones
# -----------------------------------------------------------------------------
#   &  = Y (ambas)   |  = O (alguna)   !  = NO (negación)
# 🔵 CORRE Y OBSERVA
trabajadores$edad > 30 & trabajadores$educ >= 12   # vector lógico combinado

# 🔮 PREDICE: ¿cuántos cumplen? (cuenta los TRUE de arriba)
sum(trabajadores$edad > 30 & trabajadores$educ >= 12)

# ✏️ COMPLETA: proporción de mujeres ("F") en Agricultura (usa & y mean()).
mean(trabajadores$genero == "F" & trabajadores$sector == "Agricultura")

# 🟢 TU TURNO: ¿cuántos trabajadores son de "Ñuble" O de "Maule"? (usa | y sum())



# -----------------------------------------------------------------------------
# BLOQUE D — Ejemplo aplicado: filtrar (junta toda la semana)
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA
umbral <- median(trabajadores$ingreso)
sobre_mediana <- trabajadores[trabajadores$ingreso > umbral, ]
sobre_mediana
nrow(sobre_mediana)            # cuántos quedaron
mean(sobre_mediana$educ)       # su educación promedio

# 💡 Este es el flujo FILTRAR -> RESUMIR que se repetirá todo el curso.

# 👀 SOLO MIRA (lo de R base de hoy vs. dplyr de la Semana 5):
#    R base hoy:   trabajadores[trabajadores$ingreso > umbral & trabajadores$edad < 50, ]
#    dplyr (S5):   filter(trabajadores, ingreso > umbral, edad < 50)
#    -> entender la versión base hace que dplyr tenga sentido, no que sea magia.

# 🟢 TU TURNO: filtra los trabajadores con edad < 40 Y educ >= 12, y calcula
#    su ingreso promedio.
trabajadores$edad > 40 & trabajadores$educ >= 12


# -----------------------------------------------------------------------------
# CIERRE — lista (flexible) · resumen (mean/median/sd/quantile, ¡ojo NA!) ·
#          lógicos (& | !) · flujo filtrar -> resumir.
# Al laboratorio (2h): aplicar TODO a datos reales (CASEN).
# =============================================================================
