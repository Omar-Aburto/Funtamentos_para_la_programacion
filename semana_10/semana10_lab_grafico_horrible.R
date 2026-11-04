# =============================================================================
# Laboratorio Semana 10 — "El gráfico más horrible" (y su redención)
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Autor: [TU NOMBRE]
# Fecha: [FECHA]
#
# Objetivo: dominar la personalización de ggplot2 (escalas, el paquete scales,
#           paletas, facetas y theme) creando a propósito el PEOR gráfico posible
#           y luego arreglándolo. Cada elemento que saboteas te enseña una
#           decisión de diseño (Semana 9: chart junk, color, tipografía, claridad).
#
# Referencias útiles:
#   temas de ggplot2:  https://ggplot2.tidyverse.org/reference/ggtheme.html
#   paquete ggthemes:  https://jrnold.github.io/ggthemes/
#   paquete scales:    https://scales.r-lib.org/reference/
#
# Idea del ejercicio adaptada de: Gil-Clavel, S. (2026). R-Course: R for Social
#   Scientists (v.2). Zenodo. https://doi.org/10.5281/zenodo.20828330 (Licencia MIT)
#
# Lugar en la semana: primera parte del laboratorio (~40 min, sin nota). La
#   segunda parte es la T4 parte 1 (labs/semana10_tarea3_esqueleto.R).
#
# Regla IA: ChatGPT es CONSULTOR. Debes poder explicar cada capa de tu gráfico.
# =============================================================================

library(ggplot2)
library(dplyr)
library(scales)       # label_currency(), label_number(), label_percent()

casen <- read.csv("data/raw/casen_reducido.csv")


# -----------------------------------------------------------------------------
# PASO 0 — El gráfico base (neutro). De aquí partimos.
# -----------------------------------------------------------------------------
base <- ggplot(casen, aes(x = educ, y = ingreso, color = sector)) +
  geom_point()
base


# -----------------------------------------------------------------------------
# PASO 1 — EL DESAFÍO: hazlo lo MÁS HORRIBLE posible
# -----------------------------------------------------------------------------
# Abajo hay un punto de partida ya bastante feo (corre y observa el desastre).
# Tu misión: empeorarlo. Modifica TODOS los elementos que puedas.

horrible <- ggplot(casen, aes(x = educ, y = ingreso, color = sector)) +
  geom_point(size = 9, alpha = 0.4, shape = 18) +              # puntos enormes y tapados
  labs(title = "iNgReSoS!!!  vs  educacionnn (datos varios)",  # título inútil
       subtitle = "hecho rapidito",
       x = "x", y = "y",                                       # ejes sin sentido
       caption = "fuente: por ahi") +
  theme(
    panel.background = element_rect(fill = "limegreen"),        # fondo chillón
    plot.background  = element_rect(fill = "magenta"),
    panel.grid.major = element_line(color = "red", linewidth = 2),
    axis.text  = element_text(angle = 45, size = 18, color = "yellow"),
    axis.title = element_text(size = 28, family = "mono"),
    legend.background = element_rect(fill = "cyan"),
    legend.position = "top"
  )
horrible

# TODO: agrega AL MENOS 4 horrores más. Ideas (elige y empeóralas):
#   - scale_color_manual() con colores que choquen entre sí (rojo contra verde)
#   - coord_flip() innecesario, o ejes con límites absurdos con ylim()
#     (recuerda: ylim() BORRA los datos fuera del rango, S10S2)
#   - el eje Y en notación científica (5e+05) o con separadores en inglés
#   - más texto basura: annotate() con flechas y comentarios encima de los datos
#   - una segunda geometría que estorbe (geom_line sobre datos no temporales)
#   - leyenda gigante / título con 3 tamaños distintos
# Escribe tu versión empeorada aquí:




# -----------------------------------------------------------------------------
# PASO 2 — Reflexión (responde en comentarios)
# -----------------------------------------------------------------------------
# Lista 5 elementos que empeoraste y QUÉ principio de la Semana 9 viola cada uno
# (chart junk / color / claridad / precisión / tipografía):
#   1. ____________________________________________________________
#   2. ____________________________________________________________
#   3. ____________________________________________________________
#   4. ____________________________________________________________
#   5. ____________________________________________________________


# -----------------------------------------------------------------------------
# PASO 3 — LA REDENCIÓN: el mismo dato, bien hecho
# -----------------------------------------------------------------------------
# Aplica lo OPUESTO a cada horror: color con propósito, texto que informa,
# theme limpio, etiquetas legibles. Completa los ____.

bueno <- ggplot(casen, aes(x = educ, y = ingreso, color = sector)) +
  geom_point(size = 2, alpha = 0.8) +
  # TODO: una paleta ACCESIBLE para los 6 sectores (S9 y S10S2):
  #       "Set2" es una paleta cualitativa de ColorBrewer.
  scale_color_brewer(palette = "____") +
  # TODO: el eje Y en pesos chilenos con el paquete scales
  #       (big.mark = "." y decimal.mark = ",", siempre juntos).
  scale_y_continuous(labels = label_currency(big.mark = "____", decimal.mark = "____")) +
  labs(
    title    = "____",   # TODO: un título que diga el HALLAZGO, no la variable
    subtitle = "____",   # TODO: a quién/qué describe
    x = "Años de escolaridad",
    y = NULL,
    color = "Sector",
    caption = "Fuente: CASEN (subconjunto)"
  ) +
  theme_minimal() +      # TODO: prueba theme_bw(), theme_classic() y elige
  # TODO: con theme() + element_*(): título en negrita, sin grilla menor,
  #       leyenda abajo.
  theme(plot.title       = element_text(face = "____"),
        panel.grid.minor = element_blank(),
        legend.position  = "____")

bueno


# -----------------------------------------------------------------------------
# PASO 3b — Otra redención: seis colores son demasiados → FACETAS
# -----------------------------------------------------------------------------
# Con 6 sectores en un solo gráfico hay que buscar cada color en la leyenda.
# Un panel por sector (S10S2) se lee sin leyenda.
# TODO: completa. Un solo color (no hace falta mapearlo) y un panel por sector.
bueno_facetas <- ggplot(casen, aes(x = educ, y = ingreso)) +
  geom_point(color = "#223c6a", size = 2) +
  facet_wrap(~ ____, ncol = 3) +
  scale_y_continuous(labels = label_number(scale = 1e-3, suffix = " mil",
                                           big.mark = ".", decimal.mark = ",")) +
  labs(title = "____", x = "Años de escolaridad", y = NULL,
       caption = "Fuente: CASEN (subconjunto)") +
  theme_minimal() +
  theme(strip.text = element_text(face = "bold"))

bueno_facetas

# ¿Cuál de las dos redenciones (colores o facetas) comunica mejor? ¿Por qué? __


# -----------------------------------------------------------------------------
# PASO 4 — Guardar ambos (para comparar en tu entrega)
# -----------------------------------------------------------------------------
dir.create("output/figuras", recursive = TRUE, showWarnings = FALSE)
ggsave("output/figuras/s10_grafico_horrible.png", horrible,      width = 8, height = 5, dpi = 300)
ggsave("output/figuras/s10_grafico_bueno.png",    bueno,         width = 8, height = 5, dpi = 300)
ggsave("output/figuras/s10_grafico_facetas.png",  bueno_facetas, width = 9, height = 5, dpi = 300)


# -----------------------------------------------------------------------------
# ENTREGA: sube este script + las 3 imágenes a GitHub.
# Commit sugerido: "Lab S10: gráfico horrible y su versión corregida"
# En el README o en un comentario, explica en 3 líneas qué cambió entre ambos.
# -----------------------------------------------------------------------------
