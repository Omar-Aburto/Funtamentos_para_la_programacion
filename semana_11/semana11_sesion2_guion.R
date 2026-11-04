# =============================================================================
# GUION DE CLASE — Semana 11 · Sesión 2: Componer y Comunicar
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: [Omar Aburto]      Fecha: [2026-10-27]
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter y mira el panel Plots.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · ✏️ ESCRIBE TÚ (el código entero)
#   🔮 PREDICE · 🟢 TU TURNO · ✅ Deberías ver
#
# Hoy se construye UNA figura completa, pieza por pieza: tres gráficos de la
# ENE, compuestos con patchwork, con tu propio tema, contados como historia y
# exportados. Al final, armas otra figura tú solo.
# =============================================================================


# -----------------------------------------------------------------------------
# 📦 PAQUETES DE HOY
# -----------------------------------------------------------------------------
# Si es la primera vez que los usas:
# install.packages(c("patchwork", "scales"))
#
#   dplyr      organizar los datos.
#   ggplot2    los gráficos.
#   patchwork  COMPONER varios gráficos en una figura. Operadores:
#                p1 | p2   lado a lado      p1 / p2   uno sobre otro
#              plot_layout(widths = , heights = )   reparte el espacio
#              plot_annotation(title = , caption = , tag_levels = "A")
#                                                   título general y rótulos
#              Documentación: https://patchwork.data-imaginist.com
#   scales     formato de los ejes (S10S2).
#
# Para exportar en SVG haría falta además el paquete svglite (hoy no se usa).

library(dplyr)
library(ggplot2)
library(patchwork)
library(scales)

azul <- "#223c6a"; oro <- "#e69b0a"; gris <- "grey75"

regiones <- c("Tarapacá", "Antofagasta", "Atacama", "Coquimbo", "Valparaíso",
              "O'Higgins", "Maule", "Biobío", "La Araucanía", "Los Lagos",
              "Aysén", "Magallanes", "Metropolitana", "Los Ríos",
              "Arica y Parinacota", "Ñuble")

# ✏️ COMPLETA: los ocupados de la ENE con sexo y categoría ocupacional legibles.
ocupados <- read.csv2("data/raw/ene-2026-06-mjj.csv") |>
  filter(activ == 1) |>
  mutate(informal   = ocup_form == 2,
         sexo       = ifelse(sexo == 1, "Hombres", "Mujeres"),
         region_txt = regiones[region],
         categoria  = case_when(categoria_ocupacion == 3 ~ "Asal. privado",
                                categoria_ocupacion == 4 ~ "Asal. público",
                                categoria_ocupacion == 2 ~ "Cuenta propia",
                                T                     ~ "Otras"))


# -----------------------------------------------------------------------------
# BLOQUE A — Tres piezas y cómo componerlas
# -----------------------------------------------------------------------------
# ✏️ COMPLETA la pieza 1: informalidad por región, con Ñuble resaltado.
p_region <- ocupados |>
  group_by(region_txt) |>
  summarise(tasa = 100 * weighted.mean(informal, fact_cal)) |>
  ggplot(aes(tasa, reorder(region_txt, tasa), fill = region_txt == "Ñuble")) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = c(gris, oro)) +
  labs(x = "% informal", y = NULL)

# ✏️ COMPLETA la pieza 2: la U de la informalidad por edad (una línea).
p_edad <- ocupados |>
  filter(edad <= 80) |>
  group_by(edad) |>
  summarise(tasa = 100 * weighted.mean(informal, fact_cal)) |>
  ggplot(aes(edad, tasa)) +
  geom_line(color = azul, linewidth = 1) +
  labs(x = "edad", y = "% informal")

# ✏️ COMPLETA la pieza 3: composición del empleo por sexo (cada barra = 100 %).
p_cat <- ggplot(ocupados, aes(sexo, fill = categoria, weight = fact_cal)) +
  geom_bar(position = "fill") +
  scale_fill_brewer(palette = "Set2") +
  # scale_y_continuous(labels = ____()) +
  labs(x = NULL, y = NULL, fill = NULL)

# 🔵 CORRE Y OBSERVA: cada pieza sola
p_region
p_edad
p_cat

# ✏️ COMPLETA: las tres lado a lado, y después la primera arriba de las otras dos.
p_region + p_edad + p_cat
p_region + (p_edad | p_cat)

# ✏️ COMPLETA: región a la izquierda (toda la altura); edad y categoría
#    apiladas a la derecha, que ocupan 1,3 veces más ancho; paneles A, B, C.
(p_region | (p_edad / p_cat)) +
  plot_layout(widths = c(1, 1.3)) +
  plot_annotation(tag_levels = "I")

# 🔮 PREDICE: esta versión SIN los paréntesis externos, ¿mostrará A, B, C? ____
p_region | (p_edad / p_cat) +
  plot_layout(widths = c(1, 1.3)) +
  plot_annotation(tag_levels = "A")

# 💡 En R, + se evalúa ANTES que | y / (como × antes que +). Sin paréntesis
#    externos, plot_annotation() se pega solo al último grupo. R no avisa.

# ✏️ ESCRIBE TÚ: otra distribución: la categoría ARRIBA, ocupando todo el
#    ancho, y abajo la región y la edad lado a lado. La fila de abajo debe ser
#    el doble de alta (plot_layout(heights = )). Con rótulos A, B, C.




# -----------------------------------------------------------------------------
# BLOQUE B — Un tema propio, como función
# -----------------------------------------------------------------------------
# ✏️ COMPLETA: una función que devuelve un tema (Semana 7: funciones propias).
tema_fppe <- function(base = 13){
  theme_minimal(base_size = base) +
    theme(panel.grid.minor   = element_blank(),
          panel.grid.major.y = element_blank(),
          plot.title    = element_text(face = "bold", color = azul),
          plot.subtitle = element_text(color = "grey40"),
          plot.caption  = element_text(color = "grey50", hjust = 0),
          legend.position = "bottom")}

# ✏️ COMPLETA: actívalo para TODOS los gráficos que vienen.
theme_set(tema_fppe())

# 🔵 CORRE Y OBSERVA: la misma pieza, ahora con el tema nuevo
p_cat

# ✏️ ESCRIBE TÚ: una segunda versión de la función, tema_fppe2(), con DOS
#    argumentos: base (tamaño) y color_titulo (el color del título, por defecto
#    oro). Pruébala con p_edad + tema_fppe2(base = 16).



# 💡 Temas de partida: https://ggplot2.tidyverse.org/reference/ggtheme.html
#    y el paquete ggthemes: https://jrnold.github.io/ggthemes/


# -----------------------------------------------------------------------------
# BLOQUE C — Contar la historia: la figura final
# -----------------------------------------------------------------------------
# ✏️ COMPLETA: una anotación en la U y un título por panel.
p_edad2 <- p_edad +
  annotate("text", x = 40, y = 45, label = "mínimo cerca\nde los 40 años", size = 3.5) +
  labs(title = "La U de la edad")

# ✏️ COMPLETA: la figura con título general, subtítulo, fuente y rótulos.
figura <- ((p_region + labs(title = "Ñuble, segunda región más informal")) |
           (p_edad2 / (p_cat + labs(title = "Más empleo público entre las mujeres")))) +
  plot_layout(widths = c(1, 1.3)) +
  plot_annotation(
    title    = "Uno de cada cuatro ocupados en Chile es informal",
    subtitle = "Encuesta Nacional de Empleo, mayo-julio 2026 · ponderado con fact_cal",
    caption = "Fuente: INE, ENE. Elaboración propia.",
    tag_levels = "A")
figura

# 🔵 CORRE Y OBSERVA: el dato del título general
round(100 * weighted.mean(ocupados$informal, ocupados$fact_cal), 1)

# ✅ Deberías ver: 26,5 -> "uno de cada cuatro" es una lectura honesta.

# 🟢 TU TURNO: cambia el título general por otro hallazgo que la figura
#    también respalde. ¿Cuál elegiste y qué panel lo sostiene? ______________


# -----------------------------------------------------------------------------
# BLOQUE D — Exportar
# -----------------------------------------------------------------------------
dir.create("output/figuras", recursive = TRUE, showWarnings = FALSE)

# ✏️ COMPLETA: PNG a 300 dpi (Word, web) y PDF vectorial (LaTeX, Quarto).
ggsave("output/figuras/s11_informalidad.png", figura, width = 11, height = 6, dpi = 300)
ggsave("output/figuras/s11_informalidad.pdf", figura, width = 11, height = 6)

# 🔮 PREDICE: si exportas la MISMA figura con width = 22 y height = 12, ¿las
#    letras se verán más grandes, iguales o más chicas en el archivo? ____
ggsave("output/figuras/s11_informalidad_grande.png", figura, width = 22, height = 12, dpi = 300)

# 💡 width y height están en pulgadas y deciden el tamaño del texto RELATIVO a
#    la figura. Exporta al tamaño en que se va a usar.


# -----------------------------------------------------------------------------
# 🟢 TU TURNO FINAL — Tu propia figura (ESCRIBE TODO TÚ)
# -----------------------------------------------------------------------------
# Arma una figura de DOS paneles sobre las HORAS trabajadas (habituales, sin
# los centinelas 888 y 999, Semana 6):
#   A) la distribución de las horas por sexo (densidad o boxplot, ponderado)
#   B) las horas promedio (ponderadas) por categoría ocupacional (barras)
# Con: tu tema, un título general que diga el hallazgo, la fuente y rótulos
# A y B. Expórtala en PNG a 300 dpi.






# -----------------------------------------------------------------------------
# CIERRE — patchwork: | / plot_layout() plot_annotation() (¡paréntesis
#          externos!) · tema como función + theme_set() · annotate() y un
#          título general con el hallazgo · ggsave() en PNG (300 dpi) o PDF.
# Al laboratorio (2 h): lab sin nota (labs/semana11_lab_esqueleto.R) y
#   T4 parte 2 (labs/semana11_tarea3p2_esqueleto.R).
# =============================================================================
