# =============================================================================
# GUION DE CLASE — Semana 9 · Sesión 1: Teoría de la Visualización
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: [TU NOMBRE]      Fecha: [FECHA]
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · 🔮 PREDICE · 🟢 TU TURNO
#   👀 SOLO MIRA · ✅ Deberías ver
#
# Esta semana es de CRITERIO, no de sintaxis: aprendemos a mirar un gráfico.
# Los gráficos de este guion usan ggplot2, que se enseña la próxima semana.
# Por ahora, córrelos y mira el resultado; NO hace falta entender cada línea
# de ggplot (están marcados 👀). Sí vas a escribir el código de R que calcula
# los números que hay detrás.
# =============================================================================


# -----------------------------------------------------------------------------
# 📦 PAQUETES DE HOY
# -----------------------------------------------------------------------------
# Si es la primera vez que los usas, instálalos UNA vez (luego no hace falta):
# install.packages(c("datasauRus", "colorspace", "RColorBrewer", "patchwork"))
#
#   dplyr        Semana 5: filter, mutate, group_by, summarise.
#   ggplot2      el paquete de gráficos de R (se enseña en la Semana 10).
#                Trae incluida la paleta viridis.
#   datasauRus   trae los 13 conjuntos del "Datasaurus Dozen" (Matejka y
#                Fitzmaurice, 2017): mismas estadísticas, dibujos distintos.
#   colorspace   herramientas de color. Hoy usamos deutan(), que SIMULA cómo ve
#                los colores una persona con deuteranopía (no distingue rojo
#                de verde), y swatchplot(), que dibuja muestras de color.
#   RColorBrewer las paletas de ColorBrewer (Cynthia Brewer), diseñadas para
#                mapas: secuenciales, divergentes y cualitativas.
#   patchwork    junta varios gráficos en una figura (Semana 11).
#
# Paquetes que NO hace falta instalar porque vienen con R:
#   datasets     trae `anscombe` (el cuarteto de Anscombe, 1973).
#   grDevices    trae col2rgb(), rgb(), colors(), palette.colors() y
#                adjustcolor(): todo lo que necesitas para trabajar con HEX.

library(dplyr)
library(ggplot2)
library(datasauRus)
library(colorspace)
library(RColorBrewer)
library(patchwork)


# -----------------------------------------------------------------------------
# BLOQUE 0 — ¿Por qué graficar? Dos experimentos
# -----------------------------------------------------------------------------

## El Datasaurus Dozen ---------------------------------------------------------
# 🔵 CORRE Y OBSERVA: ¿cuántas filas y cuántos conjuntos hay?
dim(datasaurus_dozen)
table(datasaurus_dozen$dataset)

# ✅ Deberías ver: 1846 filas y 3 columnas (dataset, x, y); 13 conjuntos de
#    142 puntos cada uno.

# ✏️ COMPLETA: media, desviación estándar y correlación de cada conjunto
#    (group_by + summarise, Semana 5; cor(), Semana 7).
datasaurus_dozen |>
  group_by(____) |>
  summarise(media_x = mean(x),
            media_y = mean(y),
            desv_x  = sd(x),
            desv_y  = ____(y),
            correl  = cor(x, ____)) |>
  mutate(across(where(is.numeric), \(z) round(z, 2)))

# ✅ Deberías ver: 13 filas casi IDÉNTICAS: media_x 54.3 · media_y 47.8 ·
#    desv_x 16.8 · desv_y 26.9 · correlación entre -0.06 y -0.07.

# 🔮 PREDICE: si las 13 tablas son iguales, ¿cómo serán los 13 gráficos? ____

# 👀 SOLO MIRA (la gramática la vemos en la S10)
ggplot(datasaurus_dozen, aes(x, y)) +
  geom_point(size = 0.5, color = "#223c6a") +
  facet_wrap(~ dataset, ncol = 5) +
  theme_void()

# ✅ Deberías ver: un dinosaurio, una estrella, círculos, líneas, una equis...
#    Mismas cifras, dibujos opuestos. Las estadísticas resumen; NO describen.

## El cuarteto de Anscombe (1973): el precursor ------------------------------
# `anscombe` viene con R. Tiene 11 filas y 8 columnas: x1, x2, x3, x4 e
# y1, y2, y3, y4 (cuatro conjuntos de 11 puntos, uno al lado del otro).
# 🔵 CORRE Y OBSERVA
anscombe

# ✏️ COMPLETA: la correlación y la recta de regresión (Semana 8) del
#    conjunto I. Luego cambia los números y repite para II, III y IV.
cor(anscombe$x1, anscombe$____)
coef(lm(y1 ~ ____, data = anscombe))

# ✅ Deberías ver: correlación 0.816 y recta y = 3.00 + 0.50 x. En los cuatro
#    conjuntos la correlación es 0.816 (o 0.817) y la recta es la misma.

# 🔵 CORRE Y OBSERVA: las cuatro correlaciones de una vez con sapply()
#    (Semana 4: aplicar una función a cada elemento).
sapply(1:4, \(i) cor(anscombe[[paste0("x", i)]], anscombe[[paste0("y", i)]]))

# 👀 SOLO MIRA: los cuatro gráficos
ans <- bind_rows(lapply(1:4, \(i) data.frame(
  conjunto = c("I", "II", "III", "IV")[i],
  x = anscombe[[paste0("x", i)]],
  y = anscombe[[paste0("y", i)]])))

ggplot(ans, aes(x, y)) +
  geom_smooth(method = "lm", se = FALSE, color = "#e69b0a") +
  geom_point(color = "#223c6a", size = 2.5) +
  facet_wrap(~ conjunto, nrow = 1)

# 🔮 PREDICE: en el conjunto III, una sola observación se sale de la recta.
#    ¿Cuál es? Encuéntrala con dplyr (pista: el y3 más alto).
anscombe |> filter(y3 == ____(y3))

# 💡 La misma regresión para cuatro realidades: I lineal con ruido, II una
#    curva, III una recta perfecta desviada por un punto, IV ninguna relación
#    (un único punto fabrica la pendiente). Antes de correr un lm(), GRAFICA.


# -----------------------------------------------------------------------------
# BLOQUE D — Color: nombres, HEX y RGB
# -----------------------------------------------------------------------------
# Un color en R se escribe de tres formas. Las tres dicen cuánto ROJO, VERDE
# y AZUL lleva:
#   nombre   "steelblue", "grey75"
#   HEX      "#223c6a"  = # + rojo (22) + verde (3c) + azul (6a), en base 16
#   RGB      rgb(34, 60, 106, maxColorValue = 255)

# 🔵 CORRE Y OBSERVA: ¿cuántos nombres de color conoce R?
length(colors())
head(colors(), 10)

# ✅ Deberías ver: 657 nombres.

# 🔵 CORRE Y OBSERVA: del HEX al RGB
col2rgb("#223c6a")          # el azul institucional del curso

# ✅ Deberías ver: red 34 · green 60 · blue 106 -> más azul que lo demás.

# 💡 LEER UN PAR HEXADECIMAL: cada par va de 00 (0) a FF (255).
#    "3c" = 3 × 16 + 12 = 60   (en hexadecimal, c = 12)
strtoi("3c", base = 16)     # R hace la cuenta por ti

# ✏️ COMPLETA: traduce el dorado del curso, "#e69b0a", a RGB.
col2rgb("____")

# ✅ Deberías ver: red 230 · green 155 · blue 10 -> mucho rojo y verde, casi
#    nada de azul: por eso es dorado.

# 🔵 CORRE Y OBSERVA: el camino inverso, de RGB a HEX
rgb(34, 60, 106, maxColorValue = 255)

# 🔵 CORRE Y OBSERVA: transparencia = un CUARTO par al final
adjustcolor("#223c6a", alpha.f = 0.5)

# ✅ Deberías ver: "#223C6A80" -> 80 en hexadecimal = 128 de 255 = 50 %.

# 🟢 TU TURNO: entra a https://htmlcolorcodes.com (o https://r-charts.com/colors/),
#    elige un color que te guste, copia su HEX y tradúcelo a RGB con col2rgb().
#    ¿Qué componente domina?



# -----------------------------------------------------------------------------
# BLOQUE D (cont.) — Las paletas que conviene conocer
# -----------------------------------------------------------------------------
# Una PALETA es un vector de colores en HEX. Hay tres tipos:
#   secuencial  (bajo -> alto)          viridis, Blues
#   divergente  (negativo <- 0 -> positivo)  RdBu
#   cualitativa (categorías sin orden)  Set2, Okabe-Ito

# 🔵 CORRE Y OBSERVA: cada paleta, como vector de HEX
viridisLite::viridis(5)                     # viene con ggplot2
brewer.pal(5, "Blues")                      # RColorBrewer, secuencial
brewer.pal(5, "RdBu")                       # RColorBrewer, divergente
palette.colors(palette = "Okabe-Ito")       # R base, cualitativa

# ✅ Deberías ver: vectores de texto como "#440154FF" (viridis trae un cuarto
#    par: FF = opaco) o "#EFF3FF". Okabe-Ito trae 9 colores; el primero es el
#    negro "#000000".

# 🔵 CORRE Y OBSERVA: todas las paletas de ColorBrewer aptas para daltónicos
display.brewer.all(colorblindFriendly = TRUE)

# 🔵 CORRE Y OBSERVA: ver una paleta como muestras de color (colorspace)
swatchplot(viridisLite::viridis(7))

# ✏️ COMPLETA: compara en una sola figura viridis, Okabe-Ito y rainbow.
swatchplot(
  "viridis"   = viridisLite::viridis(7),
  "Okabe-Ito" = unname(palette.colors(palette = "Okabe-Ito"))[2:8],
  "rainbow"   = ____(7)
)


# -----------------------------------------------------------------------------
# BLOQUE D (cont.) — Cómo las ve una persona daltónica
# -----------------------------------------------------------------------------
# ~8 % de los hombres tiene alguna forma de daltonismo. La más común es la
# deuteranopía: no distingue rojo de verde. colorspace::deutan() simula cómo
# se ve un color para esa persona.

# 🔮 PREDICE: ¿cómo verá una persona con deuteranopía el rojo puro y el verde
#    puro? ¿Seguirán siendo distintos? ____
deutan(c("#FF0000", "#00FF00"))
swatchplot("original" = c("#FF0000", "#00FF00"),
           "deutan"   = deutan(c("#FF0000", "#00FF00")))

# ✅ Deberías ver: "#A39000" y "#EFD63A": dos amarillos-ocre. El rojo y el
#    verde se vuelven casi el mismo color.

# ✏️ COMPLETA: simula rainbow y viridis. ¿Cuál sigue distinguiéndose?
swatchplot(
  "rainbow"         = rainbow(7),
  "rainbow, deutan" = deutan(rainbow(7)),
  "viridis"         = viridisLite::viridis(7),
  "viridis, deutan" = ____(viridisLite::viridis(7))
)

# 💡 viridis conserva el ORDEN (de oscuro a claro) aunque se pierda el tono.
#    rainbow pierde el orden y varios colores se confunden. Para revisar un
#    gráfico ya hecho: https://www.color-blindness.com/coblis-color-blindness-simulator/


# -----------------------------------------------------------------------------
# BLOQUE D (cont.) — No depender solo del color: el ingreso mínimo
# -----------------------------------------------------------------------------
# La serie de la Semana 2: ingreso mínimo nominal e IPC (2010 = 100), 2014-2025.
salario <- read.csv("data/raw/salario_minimo_chile.csv")

# ✏️ COMPLETA: el salario real, como en la Semana 2.
salario <- salario |>
  mutate(real = salario_minimo / ____ * 100)

# ✏️ COMPLETA: ¿cuánto subió cada uno entre 2014 y 2025, en %?
#    (primera fila = 2014, última = 2025)
100 * (salario$salario_minimo[12] / salario$salario_minimo[1] - 1)
100 * (salario$____[12] / salario$____[1] - 1)

# ✅ Deberías ver: nominal +135,1 % · real +43,9 %.

# 👀 SOLO MIRA: las dos series con CODIFICACIÓN REDUNDANTE: color + tipo de
#    línea + etiqueta junto a la línea. Se entiende en blanco y negro, con
#    daltonismo y en una fotocopia.
salario |>
  mutate(Nominal = 100 * salario_minimo / salario_minimo[1],
         Real    = 100 * real / real[1]) |>
  tidyr::pivot_longer(c(Nominal, Real), names_to = "serie", values_to = "indice") |>
  ggplot(aes(anio, indice, color = serie, linetype = serie)) +
  geom_line(linewidth = 1.2) +
  scale_color_manual(values = c(Nominal = "#223c6a", Real = "#e69b0a")) +
  labs(title = "El mínimo nominal subió 135 %; el real, 44 %",
       x = NULL, y = "Índice, 2014 = 100")


# -----------------------------------------------------------------------------
# CIERRE — Las cifras resumen, el gráfico revela (Datasaurus, Anscombe).
#          Un color es nombre, HEX o RGB: tres formas de decir rojo-verde-azul.
#          Paletas seguras: viridis, ColorBrewer, Okabe-Ito. Nada de rainbow.
#          No depender solo del color: forma, tipo de línea, etiqueta.
# Puente Sesión 2: con este criterio, a juzgar gráficos REALES (y engañosos).
# =============================================================================
