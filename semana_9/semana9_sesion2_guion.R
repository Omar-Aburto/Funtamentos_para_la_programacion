# =============================================================================
# GUION DE CLASE — Semana 9 · Sesión 2: Análisis de Gráficos Reales
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: [TU NOMBRE]      Fecha: [FECHA]
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · 🔮 PREDICE · 🟢 TU TURNO
#   👀 SOLO MIRA · ✅ Deberías ver
#
# Hoy juzgamos gráficos. Detrás de cada engaño hay un NÚMERO que se puede
# calcular: cuánto subió de verdad, cuánto exagera un eje, qué esconde un
# recorte. Este guion calcula esos números. Los gráficos (👀) son ggplot2:
# la gramática se enseña en la Semana 10, hoy basta con mirarlos.
# =============================================================================


# -----------------------------------------------------------------------------
# 📦 PAQUETES DE HOY
# -----------------------------------------------------------------------------
# Si es la primera vez que los usas, instálalos UNA vez:
# install.packages(c("ggrepel", "patchwork", "scales"))
#
#   dplyr      Semana 5: filter, mutate, group_by, summarise, arrange.
#   ggplot2    gráficos (Semana 10).
#   patchwork  pone dos gráficos lado a lado con  p1 + p2  (Semana 11).
#   ggrepel    geom_text_repel(): escribe etiquetas junto a los puntos y las
#              DESPLAZA para que no se pisen. Ideal para etiquetar regiones o
#              países en un scatter. Ejemplos: https://ggrepel.slowkow.com
#   scales     formatea los números de los ejes: label_number(big.mark = ".")
#              escribe 285.175 en vez de 285175 o 2.85e+05. Viene instalado
#              con ggplot2; se usa con  scales::  delante, sin library().

library(dplyr)
library(ggplot2)
library(patchwork)
library(ggrepel)

miles <- scales::label_number(big.mark = ".", decimal.mark = ",")   # formato chileno


# -----------------------------------------------------------------------------
# BLOQUE A — El eje truncado: el ingreso mínimo real
# -----------------------------------------------------------------------------
salario <- read.csv("data/raw/salario_minimo_chile.csv") |>
  mutate(real = salario_minimo / ipc * 100)      # pesos de 2010 (Semana 2)

# ✏️ COMPLETA: quédate con 2021 a 2025.
ult <- salario |> filter(anio >= ____)
ult |> select(anio, real)

# ✏️ COMPLETA: ¿cuánto subió el mínimo real entre 2021 y 2025, en %?
100 * (ult$real[5] / ult$real[____] - 1)

# ✅ Deberías ver: 20,2 % (de $237.157 a $285.175, pesos de 2010).

# 🔮 PREDICE: si el eje Y empieza en 230.000 en vez de 0, ¿cuántas veces más
#    alta se verá la barra de 2025 que la de 2021? Tu predicción: ____
# ✏️ COMPLETA: lo que el ojo ve es la parte de la barra SOBRE el corte.
(ult$real[5] - 230000) / (ult$real[1] - ____)

# ✅ Deberías ver: 7,71 -> la barra de 2025 parece casi OCHO veces la de
#    2021, cuando en realidad es 1,2 veces (20 % más).
ult$real[5] / ult$real[1]

# 👀 SOLO MIRA: el mismo dato, dos ejes
mal <- ggplot(ult, aes(factor(anio), real)) +
  geom_col(fill = "#e69b0a") +
  coord_cartesian(ylim = c(230000, 290000)) +
  scale_y_continuous(labels = miles) +
  labs(title = "Mal · eje desde 230.000", x = NULL, y = NULL)
bien <- ggplot(ult, aes(factor(anio), real)) +
  geom_col(fill = "#223c6a") +
  scale_y_continuous(labels = miles) +
  labs(title = "Bien · eje desde 0", x = NULL, y = NULL)
mal + bien

# 💡 En BARRAS la longitud ES el dato: el eje debe partir en 0. En LÍNEAS el
#    ojo lee pendiente y posición, así que el eje puede ajustarse (Wilke,
#    cap. 17, "proportional ink").


# -----------------------------------------------------------------------------
# BLOQUE A (cont.) — Elegir el rango: cherry-picking
# -----------------------------------------------------------------------------
# ✏️ COMPLETA: variación del mínimo real entre 2020 y 2021.
r20 <- salario |> filter(anio == 2020) |> pull(real)
r21 <- salario |> filter(anio == ____) |> pull(real)
100 * (r21 / r20 - 1)

# ✅ Deberías ver: -1,29 %. El dato es CIERTO: en 2021 la inflación le ganó
#    al reajuste.

# ✏️ COMPLETA: y la variación en toda la serie, 2014-2025.
100 * (salario$real[12] / salario$real[____] - 1)

# ✅ Deberías ver: +43,9 %. Un titular "¡Cae el mínimo real!" con solo
#    2020-2021 dice algo verdadero que engaña. La defensa: pedir la serie
#    COMPLETA.


# -----------------------------------------------------------------------------
# BLOQUE B — Dos casos reales (slide "Dos casos reales para diagnosticar")
# -----------------------------------------------------------------------------
## Caso 1 · Hogares sin luz por comuna (matinal de TV, agosto de 2024) --------
# Los 20 valores que muestra la torta, transcritos de la imagen:
sin_luz <- data.frame(
  comuna = c("Lampa", "Maipú", "Colina", "Pudahuel", "Quilicura", "Las Condes",
             "Renca", "Padre Hurtado", "Lo Barnechea", "Conchalí", "La Florida",
             "Huechuraba", "Quinta Normal", "Recoleta", "Cerrillos",
             "San José de Maipo", "Peñalolén", "Ñuñoa", "Peñaflor", "Providencia"),
  hogares = c(14555, 10429, 10221, 9370, 6658, 6042, 4050, 3955, 3817, 3207,
              2948, 2930, 2248, 2139, 2064, 2005, 1552, 1243, 865, 691))

# ✏️ COMPLETA: ¿cuántos hogares suma la torta?
sum(sin_luz$____)

# 🔮 PREDICE: mirando SOLO la torta de la slide, ¿Lampa tiene el doble que
#    Maipú, un 40 % más o lo mismo? ____
# ✏️ COMPLETA: calcula la razón.
14555 / ____

# ✅ Deberías ver: 90.989 hogares en total; Lampa tiene 1,40 veces lo de
#    Maipú (40 % más). En una torta, los ángulos de 16 % y 11 % casi no se
#    distinguen.

# 🟢 TU TURNO: haz el rediseño. Completa para obtener barras ORDENADAS.
#    Copia el gráfico de abajo y cambia lo que haga falta.
ggplot(sin_luz, aes(hogares, reorder(comuna, ____))) +
  geom_col(fill = "#223c6a") +
  scale_x_continuous(labels = miles) +
  labs(title = "Lampa, Maipú y Colina: casi 4 de cada 10 hogares sin luz",
       x = "Hogares sin luz", y = NULL)

# 💡 Con barras ordenadas se lee en un segundo cuál comuna tuvo más cortes y
#    cuánto más. Ninguna torta con 20 porciones lo permite (Cleveland-McGill:
#    longitud > ángulo).

## Caso 2 · Elección presidencial de Venezuela, 2013 --------------------------
# ✏️ COMPLETA: ¿cuál fue la diferencia real, en puntos porcentuales?
50.66 - ____

# ✏️ COMPLETA: en barras honestas (desde 0), ¿qué tan alta sería la segunda
#    barra respecto de la primera?
49.07 / 50.66

# ✅ Deberías ver: 1,59 puntos; la segunda barra mediría el 96,9 % de la
#    primera. En la imagen, un cilindro es alto y el otro está aplastado:
#    eje truncado + 3D. Para una diferencia así, los dos números bastan.


# -----------------------------------------------------------------------------
# BLOQUE C — El rediseño con datos reales: informalidad por región (ENE)
# -----------------------------------------------------------------------------
# La ENE de la Semana 6. Tarda 2-3 segundos en leerse.
ene <- read.csv2("data/raw/ene-2026-06-mjj.csv")

regiones <- c("Tarapacá", "Antofagasta", "Atacama", "Coquimbo", "Valparaíso",
              "O'Higgins", "Maule", "Biobío", "La Araucanía", "Los Lagos",
              "Aysén", "Magallanes", "Metropolitana", "Los Ríos",
              "Arica y Parinacota", "Ñuble")

# ✏️ COMPLETA: informalidad PONDERADA por región y sexo (Semanas 6 y 7).
inf_region <- ene |>
  filter(activ == 1) |>
  mutate(informal   = ocup_form == 2,
         mujer      = sexo == 2,
         region_txt = regiones[region]) |>
  group_by(region_txt) |>
  summarise(total   = 100 * weighted.mean(informal, ____),
            hombres = 100 * weighted.mean(informal[!mujer], fact_cal[!mujer]),
            mujeres = 100 * weighted.mean(informal[mujer],  fact_cal[mujer]))

# ✏️ COMPLETA: ordena de mayor a menor. ¿En qué lugar queda Ñuble?
inf_region |> arrange(____(total)) |> head(5)

# ✅ Deberías ver: La Araucanía 35,0 · Ñuble 34,5 · Los Ríos 33,2 ·
#    Arica y Parinacota 32,0 · Maule 30,6. Ñuble, segunda.

# 👀 SOLO MIRA: el "después" del rediseño (lo construimos en la S10)
inf_region |>
  mutate(destacar = region_txt == "Ñuble") |>
  ggplot(aes(total, reorder(region_txt, total), fill = destacar)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = round(total, 1)), hjust = -0.15, size = 3.3) +
  geom_vline(xintercept = 26.5, linetype = "dashed") +
  scale_fill_manual(values = c(`TRUE` = "#e69b0a", `FALSE` = "grey75")) +
  labs(title = "Ñuble, segunda región más informal",
       subtitle = "Línea: promedio de Chile (26,5 %)",
       x = "% de ocupados informales", y = NULL)

# 👀 SOLO MIRA: ggrepel. 16 regiones con nombre, sin que se pisen.
ggplot(inf_region, aes(hombres, mujeres)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(color = "#223c6a", size = 2.5) +
  geom_text_repel(aes(label = region_txt), size = 3, max.overlaps = Inf, seed = 1) +
  labs(x = "Informalidad hombres (%)", y = "Informalidad mujeres (%)")

# 🔮 PREDICE: ¿qué pasa si cambias geom_text_repel() por geom_text() en el
#    gráfico anterior? Pruébalo. ____

# ✏️ COMPLETA: ¿en qué regiones la informalidad de las mujeres supera a la
#    de los hombres por más de 8 puntos?
inf_region |>
  mutate(brecha = mujeres - hombres) |>
  filter(brecha > ____) |>
  arrange(desc(brecha))

# ✅ Deberías ver: Tarapacá (11,7) y Atacama (11,1): el norte minero, donde
#    los hombres son mucho más formales.


# -----------------------------------------------------------------------------
# CHECKLIST para el laboratorio (copia esto en tu plantilla de crítica)
# -----------------------------------------------------------------------------
# [ ] El mensaje se entiende solo
# [ ] Barras y áreas desde 0 (en líneas no es obligatorio)
# [ ] Rango temporal completo, o justificado
# [ ] Tipo de gráfico adecuado al dato (¿una torta con más de 5 porciones?)
# [ ] Color con función y accesible; no depende SOLO del color
# [ ] Etiquetas directas y líneas de referencia en vez de leyendas largas
# [ ] Título = hallazgo
# [ ] Sin chart junk (3D, fondos, grillas densas)
# [ ] Fuente y unidades citadas


# -----------------------------------------------------------------------------
# CIERRE — Detrás de cada engaño hay una cuenta: el eje truncado exagera 7,7
#          veces una subida de 20 %; el recorte 2020-2021 convierte +44 % en
#          -1,3 %; la torta esconde que Lampa tiene 40 % más que Maipú.
# Al laboratorio: diagnostica un gráfico de la prensa chilena con la plantilla
#   (labs/semana9_plantilla_critica.md). La A4 se entrega igual.
# =============================================================================
