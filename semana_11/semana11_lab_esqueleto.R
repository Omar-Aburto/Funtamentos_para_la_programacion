# =============================================================================
# Laboratorio Semana 11 — Distribuciones, incertidumbre y una figura propia
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Autor: [TU NOMBRE]
# Fecha: [FECHA]
#
# Lugar en la semana: primera parte del laboratorio (~40 min, sin nota). La
#   segunda parte es la T4 parte 2 (labs/semana11_tarea3p2_esqueleto.R).
#
# Objetivo: aplicar las herramientas de la Semana 11 a una base que en clase NO
#   usamos para graficar: casen_ingresos.csv (Semana 5), las mismas 60 personas
#   de CASEN con el ingreso abierto por fuente y las HORAS trabajadas.
#   - S11S1: histograma, boxplot, violín, puntos crudos, intervalos de confianza
#   - S11S2: patchwork, un tema propio como función, exportar
#
# Pregunta del lab: ¿cómo se reparte el ingreso entre sectores, y qué tan
#   seguros podemos estar de las diferencias con solo 55 personas?
#
# CÓMO USARLO: donde veas ____ tienes que escribir tú. Corre cada bloque con
#              Cmd/Ctrl + Enter y compara con el "✅ Deberías ver".
#
# ⚠️ Ábrelo desde el .Rproj, no con RStudio a secas, o la ruta no funcionará.
#
# Regla IA: ChatGPT es CONSULTOR, no escritor. Debes poder explicar cada capa.
# =============================================================================

library(dplyr)
library(ggplot2)
library(patchwork)
library(scales)

azul <- "#223c6a"; oro <- "#e69b0a"

ingresos <- read.csv("data/raw/casen_ingresos.csv") |>
  filter(!is.na(ing_total))           # las 5 personas sin ingreso quedan fuera

nrow(ingresos)

# ✅ Deberías ver: 55

# Formato chileno para los ejes en pesos (S10S2)
pesos <- label_currency(big.mark = ".", decimal.mark = ",")


# -----------------------------------------------------------------------------
# PASO 1 — La forma del ingreso: histograma + media + mediana
# -----------------------------------------------------------------------------
# TODO: completa el histograma con 12 barras y marca la media y la mediana.
media   <- mean(ingresos$ing_total)
mediana <- ____(ingresos$ing_total)

p1 <- ggplot(ingresos, aes(ing_total)) +
  geom_histogram(bins = ____, fill = azul, color = "white") +
  geom_vline(xintercept = media,   color = oro,     linewidth = 1) +
  geom_vline(xintercept = mediana, color = "black", linewidth = 1, linetype = "dashed") +
  scale_x_continuous(labels = pesos) +
  labs(title = "____", x = "Ingreso total mensual", y = "Personas")
p1

c(media = media, mediana = mediana)

# ✅ Deberías ver: media $655.291 y mediana $672.000. La media queda algo
#    por DEBAJO de la mediana.
#
# En la Semana 7 se dijo que en ingresos la media suele superar a la mediana
# (cola a la derecha). Aquí pasa lo contrario. Mirando el histograma, ¿hacia
# qué lado está la cola? ¿Qué personas la forman? ____________________________


# -----------------------------------------------------------------------------
# PASO 2 — Una pregunta, tres geoms: ¿trabajan más horas los hombres?
# -----------------------------------------------------------------------------
# En clase comparamos el INGRESO por género. Aquí, las HORAS (columna horas).
# TODO: completa los tres gráficos.
h_dens <- ggplot(ingresos, aes(horas, fill = genero)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c(F = oro, M = azul)) +
  labs(title = "Densidad", x = "Horas semanales", y = NULL, fill = NULL)

h_box <- ggplot(ingresos, aes(genero, horas, fill = genero)) +
  ____(show.legend = FALSE) +                                     # el boxplot
  scale_fill_manual(values = c(F = oro, M = azul)) +
  labs(title = "Boxplot", x = NULL, y = "Horas semanales")

h_puntos <- ggplot(ingresos, aes(genero, horas, color = genero)) +
  geom_jitter(width = 0.15, size = 2, show.legend = FALSE) +
  stat_summary(fun = median, geom = "crossbar", width = 0.4, color = "black") +
  scale_color_manual(values = c(F = oro, M = azul)) +
  labs(title = "Puntos + mediana", x = NULL, y = "Horas semanales")

h_dens + h_box + h_puntos

ingresos |> group_by(genero) |> summarise(n = n(), mediana = median(horas))

# ✅ Deberías ver: mediana 42 horas (mujeres, 27) y 40 (hombres, 28). En esta
#    muestra las mujeres trabajan algo MÁS horas, al revés de la ENE.
#
# Con 27 y 28 personas por grupo, ¿cuál de los tres gráficos es el más honesto?
# ¿Por qué la densidad puede sugerir más precisión de la que hay? (S11S1) _____
# _____________________________________________________________________________


# -----------------------------------------------------------------------------
# PASO 3 — El ingreso por sector: boxplot ORDENADO con los puntos encima
# -----------------------------------------------------------------------------
ingresos |> count(sector)

# ✅ Deberías ver: entre 5 personas (Construcción) y 15 (Servicios).

# TODO: ordena los sectores por su mediana y muestra cada persona.
p3 <- ggplot(ingresos, aes(ing_total, reorder(sector, ing_total, FUN = ____))) +
  geom_boxplot(outlier.shape = NA, fill = "grey90") +
  geom_jitter(height = 0.15, color = azul, size = 2, alpha = 0.7) +
  scale_x_continuous(labels = pesos) +
  labs(title = "____", x = "Ingreso total mensual", y = NULL)
p3

# 💡 outlier.shape = NA evita dibujar dos veces los valores atípicos: los
#    puntos de geom_jitter() ya los muestran.


# -----------------------------------------------------------------------------
# PASO 4 — ¿Qué tan seguros estamos? Media por sector con su IC al 95 %
# -----------------------------------------------------------------------------
# En la S11S1 los intervalos venían de una regresión. Aquí los CALCULAS tú:
#   error estándar  = desviación estándar / raíz(n)
#   IC 95 %         = media ± t × error estándar, con t = qt(0.975, n - 1)
# TODO: completa.
ic_sector <- ingresos |>
  group_by(sector) |>
  summarise(n     = n(),
            media = mean(ing_total),
            se    = sd(ing_total) / sqrt(____),
            t     = qt(0.975, df = n - 1),
            bajo  = media - t * se,
            alto  = media + ____ * se)

ic_sector |> arrange(media)

# ✅ Deberías ver: Agricultura $447.846 (IC 353.143 a 542.549) en el extremo
#    bajo; Educación $908.857 (IC 799.799 a 1.017.915) en el alto.

# TODO: grafica cada media con su intervalo (S11S1).
p4 <- ggplot(ic_sector, aes(media, reorder(sector, media))) +
  ____(aes(xmin = bajo, xmax = alto), color = azul) +            # punto + intervalo
  scale_x_continuous(labels = pesos) +
  labs(title = "____", x = "Ingreso medio (IC 95 %)", y = NULL)
p4

# PREGUNTAS:
# a) Los intervalos de Construcción (n = 5) y Comercio (n = 6) se solapan casi
#    por completo. ¿Se puede afirmar que uno gana más que el otro? ____________
# b) ¿Y Agricultura contra Educación? __________________________________________
# c) ¿Por qué el intervalo de Servicios es el más angosto? ______________________


# -----------------------------------------------------------------------------
# PASO 5 — Una figura con tu propio tema
# -----------------------------------------------------------------------------
# TODO: escribe tu tema como FUNCIÓN (Semana 7 + S11S2) y actívalo para todo.
tema_lab <- function(base = 12) {
  theme_minimal(base_size = base) +
    theme(plot.title       = element_text(face = "____", color = azul),
          panel.grid.minor = element_blank())
}
theme_set(tema_lab())

# 🔮 PREDICE: ¿aparecerán el título general y los rótulos A, B, C? ____
p1 | (p3 / p4) + plot_annotation(title = "Ingreso y sectores en CASEN",
                                  tag_levels = "A")

# TODO: arréglalo con los paréntesis EXTERNOS (S11S2).
figura <- (p1 | (p3 / p4)) +
  plot_layout(widths = c(1, 1.3)) +
  plot_annotation(title   = "____",
                  caption = "Fuente: CASEN (muestra del curso). IC al 95 %.",
                  tag_levels = "A")
figura


# -----------------------------------------------------------------------------
# PASO 6 — Exportar en dos formatos
# -----------------------------------------------------------------------------
dir.create("output/figuras", recursive = TRUE, showWarnings = FALSE)
# TODO: PNG a 300 dpi para un informe en Word; PDF vectorial para LaTeX/Quarto.
ggsave("output/figuras/lab11_figura.png", figura, width = 12, height = 6, dpi = ____)
ggsave("output/figuras/lab11_figura.____", figura, width = 12, height = 6)

# 💡 Para SVG hace falta instalar el paquete svglite: install.packages("svglite").


# -----------------------------------------------------------------------------
# AUTOEVALUACIÓN
# -----------------------------------------------------------------------------
# [ ] Sé leer media contra mediana en un histograma.
# [ ] Elegí el geom según el tamaño de la muestra, no según el gusto.
# [ ] Ordené un boxplot por la mediana y mostré los puntos crudos.
# [ ] Calculé un IC al 95 % con sd, n y qt(), y sé leer cuándo dos se solapan.
# [ ] Escribí un tema como función y compuse una figura con paneles A, B, C.
#
# ENTREGA: este script + lab11_figura.png y .pdf en tu repositorio.
# Commit sugerido: "Lab S11: distribuciones e incertidumbre con CASEN"
# -----------------------------------------------------------------------------
