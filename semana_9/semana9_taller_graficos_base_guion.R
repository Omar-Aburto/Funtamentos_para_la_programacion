# =============================================================================
# GUION DE CLASE — Semana 9 · Taller: Gráficos básicos con R base
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: [Omar Abruto]      Fecha: [2026-10-15]
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter y MIRA el panel Plots
#   después de cada paso. El gráfico se construye de a poco.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · 🔮 PREDICE · 🟢 TU TURNO
#   ✅ Deberías ver
#
# LA RUTINA DE CADA GRÁFICO (la misma cinco veces):
#   PASO 1 · ORGANIZAR los datos (dplyr, Semanas 5-7): el gráfico es tan bueno
#            como la tabla que lo alimenta.
#   PASO 2 · GRAFICAR lo mínimo: una función, los datos, nada más.
#   PASO 3 · CORREGIR de a un elemento: títulos, colores, formas, líneas,
#            etiquetas. Después de cada cambio, mirar.
#   PASO 4 · APLICAR el checklist de la Semana 9.
# =============================================================================


# -----------------------------------------------------------------------------
# 📦 HERRAMIENTAS DE HOY: R base, sin instalar nada
# -----------------------------------------------------------------------------
# R trae su propio sistema de gráficos desde 1997. Tres paquetes que vienen
# con R y se cargan solos:
#
#   graphics   las funciones que DIBUJAN:
#              plot()     scatter y líneas          hist()     histograma
#              barplot()  barras                    boxplot()  cajas
#              y las que AGREGAN a un gráfico ya dibujado:
#              abline()   rectas (horizontales, verticales, de regresión)
#              lines()    una línea más             points()   puntos más
#              text()     texto en una posición     legend()   leyenda
#              par()      ajustes generales (márgenes, paneles)
#   grDevices  colores y archivos: rgb(), adjustcolor(), palette.colors(),
#              png(), pdf(), dev.off() (Semana 9, sesión 1)
#   stats      los CÁLCULOS que se grafican: lm(), density(), median(),
#              quantile(), weighted.mean(), qqnorm()
#
# La lógica de R base es la de un PINTOR: cada función pinta ENCIMA de lo que
# ya hay. Lo pintado no se borra: si te equivocas, vuelves a correr desde el
# plot() inicial. La Semana 10 verá ggplot2, que piensa distinto (por capas que
# se suman con +). Hoy aprendes primero el pincel.
#
# Argumentos que se repiten en TODAS las funciones (apréndelos una vez):
#   main = título        xlab / ylab = nombres de los ejes
#   col  = color         pch = forma del punto (0 a 25)
#   cex  = tamaño        lty = tipo de línea (1 sólida, 2 guiones, 3 puntos)
#   lwd  = grosor        xlim / ylim = rango de los ejes
#   las  = orientación de las etiquetas de los ejes (1 = siempre horizontal)

library(dplyr)          # solo para ORGANIZAR los datos; los gráficos son base

azul <- "#223c6a"       # la paleta del curso, en HEX (Semana 9, sesión 1)
oro  <- "#e69b0a"
gris <- "grey75"

casen   <- read.csv("data/raw/casen_reducido.csv")
salario <- read.csv("data/raw/salario_minimo_chile.csv")
ene     <- read.csv2("data/raw/ene-2026-06-mjj.csv")       # 2-3 segundos


# =============================================================================
# GRÁFICO 1 — SCATTER: educación e ingreso (CASEN)
# =============================================================================

## PASO 1 · Organizar --------------------------------------------------------
# ✏️ COMPLETA: quita las filas sin ingreso y pasa el ingreso a miles de pesos.
casen1 <- casen |>
  filter(!is.na(ingreso)) |>
  mutate(ingreso_mil = ingreso / 1000)

nrow(casen1)
# ✅ Deberías ver: 55 (las 60 personas menos los 5 NA).

## PASO 2 · Graficar lo mínimo -----------------------------------------------
# 🔵 CORRE Y OBSERVA: plot(x, y) es todo lo que hace falta.
plot(casen1$educ, casen1$ingreso_mil)

# 🔮 PREDICE: ¿qué problemas tiene este gráfico? Anota al menos tres. ____

## PASO 3 · Corregir, de a un elemento ----------------------------------------
# (a) Títulos y ejes con unidades.
# ✏️ COMPLETA
plot(casen1$educ, casen1$ingreso_mil,
     main = "RElación entre ingreso y educación",
     xlab = "Años de educación",
     ylab = "Ingresos mensuales (en miles)")

# (b) Forma, color y tamaño de los puntos.
#     pch = 19 es un círculo relleno; pch = 1 es un círculo vacío.
# ✏️ COMPLETA: puntos rellenos, azul del curso, un poco más grandes.
plot(casen1$educ, casen1$ingreso_mil,
     main = "A más educación, más ingreso",
     xlab = "Años de educación", ylab = "Ingreso mensual (miles de $)",
     pch = 19, col = azul, cex = 1.3, las = 1)

# 🔵 CORRE Y OBSERVA: todas las formas disponibles, del 0 al 25.
plot(0:25, rep(1, 26), pch = 0:25, cex = 2, ylim = c(0.5, 1.5),
     axes = FALSE, xlab = "pch", ylab = "", main = "Formas de punto (pch)")
axis(1, at = 0:25)

# (c) La recta de regresión de la Semana 8, ENCIMA del scatter.
#     abline() dibuja la recta de un modelo lm(). Primero el scatter de nuevo:
plot(casen1$educ, casen1$ingreso_mil,
     main = "A más educación, más ingreso",
     xlab = "Años de educación", ylab = "Ingreso mensual (miles de $)",
     pch = 19, col = azul, cex = 1.3, las = 1)
modelo <- lm(ingreso_mil ~ educ, data = casen1)
# ✏️ COMPLETA: dibuja la recta del modelo en dorado, con grosor 3.
abline(modelo, col = oro, lwd = 3)

coef(modelo)
# ✅ Deberías ver: pendiente 42.08 -> cada año de educación se asocia con
#    ~$42 mil más (la Semana 8 dio 42.080 en pesos).

# (d) Color según una variable: un color por género.
#     En R base el color se construye a mano: un vector con un color por fila.
# ✏️ COMPLETA: dorado para F, azul para M.
colores <- ifelse(casen1$genero == "F", oro, azul)
table(colores)
# ✅ Deberías ver: 27 puntos dorados (F) y 28 azules (M).

plot(casen1$educ, casen1$ingreso_mil,
     main = "A más educación, más ingreso",
     xlab = "Años de educación", ylab = "Ingreso mensual (miles de $)",
     pch = 19, col = colores, cex = 1.3, las = 1)
abline(modelo, col = "grey40", lwd = 2, lty = 2)
# ✏️ COMPLETA: la leyenda, arriba a la izquierda.
legend("topleft", legend = c("Mujeres", "Hombres"),
       col = c(oro, azul), pch = 19, bty = "n")

# (e) Etiquetar UN punto: la persona de mayor ingreso.
top <- casen1 |> slice_max(ingreso_mil, n = 1)
text(top$educ, top$ingreso_mil, labels = "mayor ingreso", pos = 1, cex = 0.9)
text(11, 689, labels = "el elegido", pos = 1, cex = 0.9)
# pos: 1 abajo · 2 izquierda · 3 arriba · 4 derecha

## PASO 4 · Checklist --------------------------------------------------------
# [x] título = hallazgo   [x] ejes con unidades   [x] color con función
# [ ] ¿falta la fuente? Agrégala abajo con mtext():
mtext("Fuente: CASEN (muestra del curso)", side = 1, line = 4, adj = 0,
      cex = 0.8, col = "grey40")

# 🟢 TU TURNO: haz el scatter de EDAD contra ingreso (en miles), con su recta.
#    ¿La pendiente es mayor o menor que la de educación? (Semana 8: casi plana)



# =============================================================================
# GRÁFICO 2 — HISTOGRAMA: horas trabajadas (ENE)
# =============================================================================

## PASO 1 · Organizar --------------------------------------------------------
# 🔵 CORRE Y OBSERVA: los ocupados, con las horas tal como vienen.
ocupados <- ene |> filter(activ == 1)
summary(ocupados$habituales)

# 🔮 PREDICE: el máximo es 999. ¿Qué es ese número? (Semana 6) ____

## PASO 2 · Graficar lo mínimo -----------------------------------------------
hist(ocupados$habituales)

# ✅ Deberías ver: casi todo aplastado a la izquierda y el eje hasta 1000.
#    Los centinelas 888 y 999 ESTIRAN el gráfico (S9S2).

# ✏️ COMPLETA: limpia los dos centinelas (Semana 6).
ocupados <- ocupados |>
  mutate(horas = na_if(na_if(habituales, 888), 999))
summary(ocupados$horas)
# ✅ Deberías ver: máximo 126 y 111 NA (los centinelas, ahora NA).

hist(ocupados$horas)

## PASO 3 · Corregir ---------------------------------------------------------
# (a) Más barras: breaks decide cuántos intervalos. Prueba 10, 30 y 60.
hist(ocupados$horas, breaks = 10)
hist(ocupados$horas, breaks = 60)

# 🔮 PREDICE: ¿qué se ve con 60 que no se veía con 10? ____

# (b) Color, borde, títulos.
# ✏️ COMPLETA
hist(ocupados$horas, breaks = 60,
     col = azul, border = oro,
     main = "Cantidad de horas semanales por persona",
     xlab = "Horas habituales por semana", ylab = "Personas encuestadas", las = 1)

# (c) Líneas de referencia: la media y la mediana (stats).
# ✏️ COMPLETA: v = vertical. La media en dorado; la mediana punteada.
media   <- mean(ocupados$horas, na.rm = TRUE)
mediana <- median(ocupados$horas, na.rm = TRUE)
abline(v = media,   col = oro,     lwd = 3)
abline(v = mediana, col = "black", lwd = 2, lty = 2)
legend("topright", bty = "n",
       legend = c(paste("Media:", round(media, 1)), paste("Mediana:", mediana)),
       col = c(oro, "black"), lwd = c(3, 2), lty = c(1, 2))

c(media = media, mediana = mediana)
# ✅ Deberías ver: media 38.1, mediana 42. La media es MENOR: la cola izquierda
#    (jornadas parciales) la tira hacia abajo (asimetría, Semana 7).

# (d) La versión suavizada: density() (stats) dibujada con lines().
#     freq = FALSE pone el eje Y en densidad para que calcen las escalas.
hist(ocupados$horas, breaks = 60, freq = FALSE, col = gris, border = "white",
     main = "Horas habituales: histograma y densidad",
     xlab = "Horas habituales por semana", ylab = "Densidad", las = 1)
lines(density(ocupados$horas, na.rm = TRUE), col = azul, lwd = 3)

# 🔵 CORRE Y OBSERVA: el pico más alto, ¿en qué hora está?
sort(table(ocupados$horas), decreasing = TRUE)[1:3]
# ✅ Deberías ver: 42 horas (11.470 personas), luego 40 y 44. La jornada
#    máxima legal bajó de 44 a 42 horas en abril de 2026 (Ley 21.561).

# 🟢 TU TURNO: el histograma de la EDAD de los ocupados (columna edad), con
#    la mediana marcada. ¿Hay edades "redondas" que se repitan más?



# =============================================================================
# GRÁFICO 3 — BARRAS: informalidad por región (ENE, ponderada)
# =============================================================================

## PASO 1 · Organizar --------------------------------------------------------
regiones <- c("Tarapacá", "Antofagasta", "Atacama", "Coquimbo", "Valparaíso",
              "O'Higgins", "Maule", "Biobío", "La Araucanía", "Los Lagos",
              "Aysén", "Magallanes", "Metropolitana", "Los Ríos",
              "Arica y Parinacota", "Ñuble")

# ✏️ COMPLETA: tasa de informalidad PONDERADA por región, en %.
inf_region <- ocupados |>
  mutate(informal = ocup_form == 2, region_txt = regiones[region]) |>
  group_by(region_txt) |>
  summarise(tasa = 100 * weighted.mean(informal, fact_cal))

## PASO 2 · Graficar lo mínimo -----------------------------------------------
# barplot() necesita un VECTOR de alturas; names.arg pone los nombres.
barplot(inf_region$tasa, names.arg = inf_region$region_txt)

# 🔮 PREDICE: ¿qué tres cosas corregirías primero? ____

## PASO 3 · Corregir ---------------------------------------------------------
# (a) ORDENAR: el orden alfabético no dice nada (S9).
# ✏️ COMPLETA: de menor a mayor (arriba quedará la mayor al girarlo).
inf_ord <- inf_region |> arrange(tasa)

# (b) Horizontal y nombres legibles. Los nombres largos necesitan margen
#     izquierdo: par(mar = c(abajo, izquierda, arriba, derecha)).
par(mar = c(4, 10, 3, 2))
barplot(inf_ord$tasa, names.arg = inf_ord$region_txt,
        horiz = T, las = 1)

# (c) Un color con función: gris para todas, dorado para Ñuble.
# ✏️ COMPLETA
col_barras <- ifelse(inf_ord$region_txt == "Ñuble", oro, gris)
barplot(inf_ord$tasa, names.arg = inf_ord$region_txt, horiz = TRUE, las = 1,
        col = col_barras, border = NA, xlim = c(0, 40),
        main = "Ñuble, segunda región más informal",
        xlab = "% de ocupados informales")

# (d) Referencia y valores. barplot() DEVUELVE la posición de cada barra:
#     guárdala para escribir el valor al lado.
pos <- barplot(inf_ord$tasa, names.arg = inf_ord$region_txt, horiz = TRUE,
               las = 1, col = col_barras, border = NA, xlim = c(0, 40),
               main = "Ñuble, segunda región más informal",
               xlab = "% de ocupados informales")
nacional <- 100 * weighted.mean(ocupados$ocup_form == 2, ocupados$fact_cal)
# ✏️ COMPLETA: línea vertical en el promedio nacional y el valor de cada barra.
abline(v = nacional, lty = 2)
text(inf_ord$tasa, pos, labels = round(inf_ord$tasa, 1), pos = 4, cex = 0.8)
par(mar = c(5, 4, 4, 2))                     # restaurar los márgenes

round(nacional, 1)
tail(inf_ord, 2)
# ✅ Deberías ver: Chile 26.5 %; arriba La Araucanía 35.0 y Ñuble 34.5.

# 🟢 TU TURNO: el mismo gráfico con las HORAS trabajadas promedio por región
#    (ponderadas; weighted.mean(horas, fact_cal, na.rm = TRUE)). Resalta la
#    región con más horas. ¿Cuánto más trabaja que la de menos horas?



# =============================================================================
# GRÁFICO 4 — LÍNEAS: ingreso mínimo nominal y real (Semana 2)
# =============================================================================

## PASO 1 · Organizar --------------------------------------------------------
# ✏️ COMPLETA: el salario real en pesos de 2010 (Semana 2).
salario <- salario |>
  mutate(real = salario_minimo / ipc * 100)

## PASO 2 · Graficar lo mínimo -----------------------------------------------
# type = "l" une los puntos con una línea (type = "b": línea + puntos).
plot(salario$anio, salario$salario_minimo, type = "b")

## PASO 3 · Corregir ---------------------------------------------------------
# (a) La segunda serie se AGREGA con lines(). Pero ojo:
lines(salario$anio, salario$real)

# 🔮 PREDICE: ¿por qué no aparece la línea real? ____

# (b) ylim: el rango del eje Y lo fija el PRIMER plot(). Hay que dárselo para
#     que quepan las dos series.
# ✏️ COMPLETA: desde 0 hasta el máximo nominal.
plot(salario$anio, salario$salario_minimo, type = "l",
     ylim = c(min(salario$real), max(salario$salario_minimo)),
     lwd = 3, col = azul, las = 1,
     main = "El mínimo nominal subió 135 %; el real, 44 %",
     xlab = "", ylab = "Pesos")
lines(salario$anio, salario$real, lwd = 3, col = oro, lty = 2)

# (c) Etiquetas directas en vez de leyenda (S9: codificación redundante).
text(2025, max(salario$salario_minimo), "Nominal", pos = 2, col = azul, font = 2)
text(2025, max(salario$real), "Real (pesos de 2010)", pos = 3, col = oro, font = 2)

# (d) Los ejes en formato chileno: format() con separador de miles.
plot(salario$anio, salario$salario_minimo, type = "l",
     ylim = c(0, 560000), lwd = 3, col = azul, axes = FALSE,
     main = "El mínimo nominal subió 135 %; el real, 44 %",
     xlab = "", ylab = "")
lines(salario$anio, salario$real, lwd = 3, col = oro, lty = 2)
axis(1, at = seq(2014, 2025, 2))
marcas <- seq(0, 500000, 100000)
axis(2, at = marcas, labels = format(marcas, big.mark = ".", decimal.mark = ",", scientific = FALSE),
     las = 1)
text(2025, 529000, "Nominal", pos = 3, col = azul, font = 2)
text(2025, 285175, "Real", pos = 3, col = oro, font = 2)

# 🔵 CORRE Y OBSERVA: las cifras del título
round(100 * (salario$salario_minimo[12] / salario$salario_minimo[1] - 1), 1)
round(100 * (salario$real[12] / salario$real[1] - 1), 1)
# ✅ Deberías ver: 135.1 y 43.9.

# 🟢 TU TURNO: grafica solo el salario REAL entre 2014 y 2025 con type = "b"
#    y marca con points() en rojo el único año en que bajó. ¿Cuál es?
#    (pista: diff(salario$real) < 0)



# =============================================================================
# GRÁFICO 5 — BOXPLOT: ingreso por sector (CASEN)
# =============================================================================

## PASO 1 · Organizar --------------------------------------------------------
# casen1 ya está limpia (Gráfico 1). Mira cuántas personas hay por sector:
table(casen1$sector)

## PASO 2 · Graficar lo mínimo -----------------------------------------------
# boxplot() usa una FÓRMULA, como lm(): variable ~ grupo.
boxplot(ingreso_mil ~ sector, data = casen1)

## PASO 3 · Corregir ---------------------------------------------------------
# (a) Ordenar los sectores por su MEDIANA con reorder() (stats).
# ✏️ COMPLETA
casen1 <- casen1 |>
  mutate(sector_ord = reorder(sector, ingreso_mil, FUN = ____))
levels(casen1$sector_ord)

# (b) Horizontal, color, títulos.
par(mar = c(5, 8, 4, 2))
boxplot(ingreso_mil ~ sector_ord, data = casen1, horizontal = ____, las = 1,
        col = adjustcolor(azul, alpha.f = 0.3), border = azul,
        main = "Educación: el sector con la mediana más alta",
        xlab = "Ingreso mensual (miles de $)", ylab = "")

# (c) Con pocos datos, mostrar los puntos (S11 lo retoma). stripchart() agrega
#     cada persona encima de su caja; method = "jitter" las separa un poco.
# ✏️ COMPLETA: add = TRUE para pintar ENCIMA y no en un gráfico nuevo.
stripchart(ingreso_mil ~ sector_ord, data = casen1, method = "jitter",
           pch = 19, col = oro, add = ____, vertical = FALSE)
par(mar = c(5, 4, 4, 2))

# 🔵 CORRE Y OBSERVA: las medianas que dibujó la caja
casen1 |> group_by(sector) |> summarise(n = n(), mediana = median(ingreso_mil)) |>
  arrange(mediana)
# ✅ Deberías ver: 6 sectores; Construcción tiene solo 5 personas. Con tan
#    pocos datos, la caja "sugiere" más información de la que hay: por eso
#    se muestran los puntos.


# =============================================================================
# CIERRE — Varios gráficos en una figura y exportar
# =============================================================================
# par(mfrow = c(filas, columnas)) divide la ventana en paneles.
# png() abre un ARCHIVO, los gráficos se dibujan ahí, dev.off() lo cierra.

dir.create("output/figuras", recursive = TRUE, showWarnings = FALSE)
# ✏️ COMPLETA: 300 dpi (Semana 10, T4).
png("output/figuras/taller_s9.png", width = 12, height = 5, units = "in",
    res = ____)
par(mfrow = c(1, ____))
plot(casen1$educ, casen1$ingreso_mil, pch = 19, col = colores, las = 1,
     main = "A más educación, más ingreso",
     xlab = "Años de educación", ylab = "Ingreso (miles de $)")
abline(modelo, col = "grey40", lwd = 2, lty = 2)
hist(ocupados$horas, breaks = 60, col = azul, border = "white", las = 1,
     main = "La mayoría trabaja entre 40 y 45 horas",
     xlab = "Horas habituales", ylab = "Personas")
dev.off()
par(mfrow = c(1, 1))

# ✅ Deberías ver: el archivo output/figuras/taller_s9.png con los dos paneles.
#    (El gráfico NO aparece en el panel Plots: se dibujó en el archivo.)


# -----------------------------------------------------------------------------
# MAPA R base -> ggplot2 (lo que viene en la Semana 10)
# -----------------------------------------------------------------------------
#   R base                         ggplot2
#   plot(x, y)                     ggplot(datos, aes(x, y)) + geom_point()
#   plot(..., type = "l")          + geom_line()
#   hist(x)                        + geom_histogram()
#   barplot(alturas)               + geom_col()
#   boxplot(y ~ g)                 + geom_boxplot()
#   abline(modelo)                 + geom_smooth(method = "lm")
#   abline(v = 26.5)               + geom_vline(xintercept = 26.5)
#   text(x, y, etiqueta)           + geom_text() / annotate()
#   col = ifelse(...)              aes(color = variable)  (sin ifelse)
#   legend(...)                    automática
#   par(mfrow = c(1, 2))           patchwork:  p1 | p2
#   png(); ...; dev.off()          ggsave()
#
# R base: rápido para explorar, control total, pero cada detalle es a mano.
# ggplot2: más código al inicio, pero el color, la leyenda y los paneles
# salen solos de los datos. Los dos se usan en la práctica.
# =============================================================================
