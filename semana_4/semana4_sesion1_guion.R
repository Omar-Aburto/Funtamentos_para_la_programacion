# =============================================================================
# GUION DE CLASE — Semana 4 · Sesión 1: Data Frames
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: Omar Aburto      Fecha: 2026-09-01
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · 🔮 PREDICE · 🟢 TU TURNO · ✅ Deberías ver
# =============================================================================


# -----------------------------------------------------------------------------
# BLOQUE A — ¿Qué es un data frame?
# -----------------------------------------------------------------------------
# Una TABLA rectangular: filas = observaciones, columnas = variables.
# Dos reglas: (1) todas las columnas del mismo largo; (2) cada columna un solo
# tipo, pero columnas distintas pueden ser de tipos distintos.


# -----------------------------------------------------------------------------
# BLOQUE B — Crear data frames
# -----------------------------------------------------------------------------
# Construimos el mini-dataset de trabajadores, columna por columna.
# 🔵 CORRE Y OBSERVA
trabajadores <- data.frame(
  region  = c("Ñuble", "Biobío", "Ñuble", "Maule"),
  sector  = c("Agricultura", "Servicios", "Comercio", "Agricultura"),
  educ    = c(12, 16, 8, 12),          # años de escolaridad
  edad    = c(34, 45, 52, 29),
  ingreso = c(450000, 920000, 380000, 510000),
  genero  = c("M", "F", "M", "F")
)
trabajadores

# 💡 Cada argumento de data.frame() es una COLUMNA (un vector), todos del mismo largo.

## Las dimensiones de la tabla ------------------------------------------------
# 🔵 CORRE Y OBSERVA
nrow(trabajadores)   # observaciones (filas)
ncol(trabajadores)   # variables (columnas)
dim(trabajadores)    # filas, columnas
names(trabajadores)  # nombres de columnas

#Crear mi propio data frame
mis_gastos <- data.frame(
  concepto  = c("cafe","avena","huevos","energetica"),
  monto     = c(1500,890,5300,1800),
  escencial = c(TRUE,TRUE,TRUE,FALSE)
)
sum(mis_gastos$monto)  #cuanto se gasto en total
mean(mis_gastos$monto) #en promedio cuanto se gasto
mis_gastos[1]
mis_gastos[1,"monto"]
mis_gastos[mis_gastos$monto > 1700,]
mis_gastos[mis_gastos$concepto == "avena",]
mis_gastos[["concepto"]]
mean(mis_gastos$monto[mis_gastos$excencial==TRUE])
str(mis_gastos)      # estructura y tipo de cada columna  <- la más importante
summary(mis_gastos)  # resumen estadístico por columna
head(mis_gastos, 2)  # primeras filas
tail(mis_gastos, 2)  # ultimas filas

# ✅ Deberías ver: 4 ... 6 ... "4 6" ... los 6 nombres de columna


# -----------------------------------------------------------------------------
# BLOQUE C — Acceso: las tres formas
# -----------------------------------------------------------------------------

## $ — extraer una columna por nombre (la más usada) --------------------------
# 🔵 CORRE Y OBSERVA
trabajadores$ingreso          # el vector completo de ingresos
mean(trabajadores$ingreso)    # y se opera como cualquier vector (Semana 3)

# 💡 $ devuelve un VECTOR -> se le aplica todo lo de la Semana 3.

## [fila, col] — el sistema de coordenadas ------------------------------------
# Dejar un lado vacío = "todos".
# 🔵 CORRE Y OBSERVA
trabajadores[1, ]            # toda la fila 1 (un trabajador)
trabajadores[1, "ingreso"]   # una celda: ingreso del trabajador 1

# 🔮 PREDICE: ¿qué filas devuelve esta línea?
trabajadores[trabajadores$edad > 40, ]   # FILTRO: filas con edad > 40

# ✏️ COMPLETA: muestra solo las filas del sector "Servicios".
trabajadores[trabajadores$sector == "Servicios", ]

## [[ ]] — equivalente a $ -----------------------------------------------------
# 🔵 CORRE Y OBSERVA
trabajadores[["ingreso"]]    # equivalente a trabajadores$ingreso

# 🟢 TU TURNO: muestra la fila 3 completa Y, por separado, la edad del trabajador 3.



# -----------------------------------------------------------------------------
# BLOQUE D — Ejemplo económico aplicado
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA
mean(trabajadores$ingreso)                            # ingreso promedio
mean(trabajadores$ingreso[trabajadores$educ >= 12])   # solo educ >= 12 años

# Crear una COLUMNA DERIVADA (la base de todo análisis):
# 🔵 CORRE Y OBSERVA
trabajadores$estado_civil <- c("casado","soltero","casado","divorciado")

trabajadores$ingreso_miles <- trabajadores$ingreso / 1000
trabajadores

# 💡 df$nueva <- ... crea una columna nueva. En S5 esto será mutate() de dplyr.

## Brecha de ingreso por sector -----------------------------------------------
# 🔵 CORRE Y OBSERVA
mean(trabajadores$ingreso[trabajadores$sector == "Agricultura"])
mean(trabajadores$ingreso[trabajadores$sector == "Servicios"])

# 🟢 TU TURNO: crea la columna `ingreso_anual` (ingreso * 12) y muestra la tabla.
trabajadores$ingreso_anual <- trabajadores$ingreso*12
trabajadores

# -----------------------------------------------------------------------------
# BLOQUE E — Inspección: lo que se corre SIEMPRE primero
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA
str(trabajadores)      # estructura y tipo de cada columna  <- la más importante
summary(trabajadores)  # resumen estadístico por columna
head(trabajadores, 2)  # primeras filas
#------------------------------------------------------------------------------
# Eliminar fila
trabajadores <- trabajadores[-1,]
trabajadores[c(1,3,4),]

trabajadores[-c(1:3),]
trabajadores[, c("ingreso","genero")]
trabajadores[, c(1,2)]
# 💡 HÁBITO PROFESIONAL: al abrir cualquier dataset, correr str() y summary()
#    ANTES de nada, para auditar tipos y detectar problemas.


# -----------------------------------------------------------------------------
# CIERRE — crear data.frame() · dimensionar · acceder ($, [f,c], [[ ]]) ·
#          derivar (df$nueva <-) · inspeccionar (str/summary).
# Puente Sesión 2: el data frame es un caso particular de una LISTA.
# =============================================================================
