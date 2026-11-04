# =============================================================================
# GUION DE CLASE — Semana 11 · Sesión 1: Distribuciones y Comparaciones
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: [Omar Aburto]      Fecha: [2026-10-27]
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter y mira el panel Plots.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · ✏️ ESCRIBE TÚ (el gráfico entero)
#   🔮 PREDICE · 🟢 TU TURNO · ✅ Deberías ver
#
# Hoy hay MUCHO que escribir: la gramática ya la conoces (Semana 10), así que
# en varios bloques el gráfico lo escribes tú desde cero, con una pista.
# =============================================================================


# -----------------------------------------------------------------------------
# 📦 PAQUETES DE HOY
# -----------------------------------------------------------------------------
# Si es la primera vez que los usas:
# install.packages(c("patchwork", "broom", "scales"))
#
#   dplyr      organizar los datos (Semanas 5-7).
#   ggplot2    los gráficos. Hoy: geom_histogram(), geom_density(),
#              geom_boxplot(), geom_violin(), geom_jitter(), geom_bin_2d(),
#              geom_pointrange().
#   patchwork  poner gráficos lado a lado:  p1 + p2 + p3  (lo profundiza la S11S2).
#   broom      tidy() convierte una regresión en tabla, con intervalos de
#              confianza (Semana 8). Hoy lo usamos para GRAFICAR esos intervalos.
#   scales     números del eje con formato chileno (S10S2).

library(dplyr)
library(ggplot2)
library(patchwork)
library(broom)
library(scales)

azul <- "#223c6a"; oro <- "#e69b0a"
miles <- label_number(big.mark = ".", decimal.mark = ",")   # formato chileno

casen <- read.csv("data/raw/casen_reducido.csv") |> filter(!is.na(ingreso))

regiones <- c("Tarapacá", "Antofagasta", "Atacama", "Coquimbo", "Valparaíso",
              "O'Higgins", "Maule", "Biobío", "La Araucanía", "Los Lagos",
              "Aysén", "Magallanes", "Metropolitana", "Los Ríos",
              "Arica y Parinacota", "Ñuble")

# ✏️ COMPLETA: los ocupados de la ENE (Semana 6), con dos variables lógicas.
ocupados <- read.csv2("data/raw/ene-2026-06-mjj.csv") |>
  filter(activ == 1) |>
  mutate(informal   = ocup_form == 2,
         mujer      = sexo == 2,
         region_txt = regiones[region])

nrow(casen); nrow(ocupados)

# ✅ Deberías ver: 55 personas en CASEN (sin los 5 NA) y 41.850 ocupados.


# -----------------------------------------------------------------------------
# BLOQUE A — Histograma y densidad: la forma de UNA variable
# -----------------------------------------------------------------------------
# ✏️ COMPLETA: un histograma del ingreso con 15 barras.
ggplot(casen, aes(ingreso)) +
  geom_histogram(bins = 15, fill = azul, color = "white") +
  scale_x_continuous(labels = scales::label_comma()) +
  labs(title = "El ingreso de la muestra es casi simétrico", x = "Ingreso ($)", 
       y = "Frecuencia")

# 🔮 PREDICE: ¿qué pasa con 5 barras? ¿Y con 50? Pruébalo cambiando bins. ____

# ✏️ ESCRIBE TÚ: el mismo histograma con DOS líneas verticales: la media (en
#    dorado) y la mediana (negra, punteada). Pista: geom_vline(xintercept = ).
#    Primero calcula media y mediana con mean() y median().



# ✅ Deberías ver: media $655.291 y mediana $672.000. La mediana queda a la
#    derecha de la media: una leve cola a la IZQUIERDA (Semana 7: −0,17).

# ✏️ COMPLETA: la versión suavizada.
ggplot(casen, aes(ingreso)) +
  geom_density(fill = azul, alpha = 0.5) +
  scale_x_continuous(labels = miles) +
  labs(title = "Densidad del ingreso", x = "Ingreso ($)", y = "Densidad")

## Un histograma delata los centinelas ----------------------------------------
# ✏️ COMPLETA: las horas tal como vienen, y limpias de 888 y 999 (Semana 6).
h_sucia <- ggplot(ocupados, aes(habituales)) +
  geom_histogram(binwidth = 10, fill = "grey60") +
  labs(title = "Tal como viene", x = "horas", y = NULL)

h_limpia <- ocupados |>
  mutate(habituales = na_if(na_if(habituales, 888), 999)) |>
  ggplot(aes(habituales)) +
  geom_histogram(binwidth = 2, fill = azul) +
  labs(title = "Sin 888 ni 999", x = "horas", y = NULL)

h_sucia + h_limpia                 # patchwork: lado a lado

# 🔵 CORRE Y OBSERVA: el número que estira el eje
max(ocupados$habituales)
sum(ocupados$habituales %in% c(888, 999))

# ✅ Deberías ver: máximo 999 y 111 centinelas. Limpios, el máximo es 126 y el
#    pico está en 42 horas (la jornada legal desde abril de 2026).


# -----------------------------------------------------------------------------
# BLOQUE B — Boxplot y violín: comparar grupos
# -----------------------------------------------------------------------------
# ✏️ COMPLETA: el ingreso por sector, ORDENADO por la mediana (reorder, S10).
ggplot(casen, aes(____, reorder(sector, ingreso, FUN = ____))) +
  ____(fill = azul, alpha = 0.5) +
  scale_x_continuous(labels = miles) +
  labs(title = "Educación y Servicios, las medianas más altas", x = "Ingreso ($)", y = NULL)

# 🔵 CORRE Y OBSERVA: los números que dibuja la caja
casen |>
  group_by(sector) |>
  summarise(n = n(), q1 = quantile(ingreso, 0.25), mediana = median(ingreso),
            q3 = quantile(ingreso, 0.75)) |>
  arrange(mediana)

# ✅ Deberías ver: Agricultura (mediana 467.000) abajo y Educación (934.000)
#    arriba. Construcción tiene solo 5 personas.

# 🔮 PREDICE: la caja va de Q1 a Q3. ¿Qué parte de las personas de cada sector
#    queda DENTRO de la caja? ____

# ✏️ COMPLETA: violín con un boxplot angosto encima (forma + resumen).
ggplot(casen, aes(ingreso, reorder(sector, ingreso, FUN = median))) +
  ____(fill = azul, alpha = 0.4) +
  geom_boxplot(width = ____) +
  scale_x_continuous(labels = miles) +
  labs(title = "Forma + resumen", x = "Ingreso ($)", y = NULL)


# -----------------------------------------------------------------------------
# BLOQUE C — Comparar distribuciones: tres geoms para una pregunta
# -----------------------------------------------------------------------------
# ¿Difiere el ingreso entre mujeres y hombres?
# ✏️ COMPLETA los tres gráficos.
colores <- c(F = oro, M = azul)

d <- ggplot(casen, aes(ingreso, fill = ____)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = colores) +
  labs(title = "Densidad", x = NULL, y = NULL)

b <- ggplot(casen, aes(genero, ingreso, fill = genero)) +
  ____(show.legend = FALSE) +
  scale_fill_manual(values = colores) +
  labs(title = "Boxplot", x = NULL, y = NULL)

v <- ggplot(casen, aes(genero, ingreso, fill = genero)) +
  ____(show.legend = FALSE) +
  scale_fill_manual(values = colores) +
  labs(title = "Violín", x = NULL, y = NULL)

d + b + v

casen |> group_by(genero) |> summarise(n = n(), mediana = median(ingreso))

# ✅ Deberías ver: mediana $659.000 (F, 27 personas) y $680.500 (M, 28).

## Con pocos datos, mostrar los puntos crudos -----------------------------------
# ✏️ COMPLETA: boxplot SIN dibujar los atípicos + cada persona encima.
ggplot(casen, aes(genero, ingreso)) +
  geom_boxplot(outlier.shape = NA, fill = "grey90") +
  geom_jitter(width = 0.15, alpha = 0.6, color = azul) +
  scale_y_continuous(labels = miles) +
  labs(title = "Boxplot + datos crudos", x = NULL, y = "Ingreso ($)")

# 🔮 PREDICE: ¿por qué outlier.shape = NA? ¿Qué pasaría sin él? ____

# 🟢 TU TURNO: con 27 y 28 personas por grupo, ¿cuál de los cuatro gráficos
#    del Bloque C es el más honesto? Responde en una línea. ___________________


# -----------------------------------------------------------------------------
# BLOQUE D — Muchos datos e incertidumbre
# -----------------------------------------------------------------------------
## 41.850 puntos: la mancha -----------------------------------------------------
horas <- ocupados |> mutate(habituales = na_if(na_if(habituales, 888), 999))

g <- ggplot(horas, aes(edad, habituales)) + labs(x = "Edad", y = "Horas")

# 🔵 CORRE Y OBSERVA: la mancha
g + geom_point(color = azul)

# ✏️ COMPLETA: dos soluciones.
g + geom_point(color = azul, alpha = 0.03)          # transparencia
g + geom_bin_2d(bins = 40) + scale_fill_viridis_c()  # contar por celda

# ✏️ ESCRIBE TÚ: el mismo gráfico de celdas, pero separado por sexo
#    (facet_wrap, S10S2). Pista: crea primero una columna sexo_txt con
#    ifelse(mujer, "Mujer", "Hombre").



# 🔮 PREDICE: ¿quién concentra más casos en la franja de 40-45 horas? ____

## Graficar la incertidumbre: la brecha de género por región (lab S8) --------
# ✏️ COMPLETA: una regresión por región y el coeficiente de mujer con su IC.
brecha_region <- ocupados |>
  group_by(region_txt) |>
  group_modify(~ tidy(lm(informal ~ mujer + edad + I(edad^2), data = .x,
                         weights = fact_cal), conf.int = T)) |>
  filter(term == "mujerTRUE") |>
  ungroup()

# ✏️ COMPLETA: punto (estimación) + línea (intervalo), con la referencia en 0.
ggplot(brecha_region, aes(100 * estimate, reorder(region_txt, estimate))) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_pointrange(aes(xmin = 100 * estimate, xmax = 100 * conf.high),
                    color = azul, size = 0.3) +
  labs(x = "Brecha mujer - hombre en informalidad (pp)", y = NULL)

# ✏️ ESCRIBE TÚ: con dplyr, ¿cuántas regiones tienen un intervalo que CRUZA
#    el cero? ¿Cuáles son? Pista: filter(conf.low < 0).



# ✅ Deberías ver: 6 regiones: Arica y Parinacota, Aysén, La Araucanía,
#    Los Ríos, O'Higgins y Ñuble.
#
# ⚠️ Los intervalos de lm() con weights no consideran el diseño muestral de la
#    ENE: los verdaderos son más anchos (lab de la Semana 8).


# -----------------------------------------------------------------------------
# BLOQUE E — ¿Cuándo usar cada uno?
# -----------------------------------------------------------------------------
# 🟢 TU TURNO: para cada pregunta, escribe el gráfico que corresponde (geom y
#    datos). Corre cada uno y pon un título que diga el hallazgo.
#
# 1) ¿Cómo se reparte la EDAD de los ocupados de la ENE?



# 2) ¿Difieren las horas habituales (limpias) entre hombres y mujeres? (ENE)



# 3) ¿Cómo se reparten los años de educación en CASEN (60 personas)?




# -----------------------------------------------------------------------------
# CIERRE — Una variable: histograma / densidad. Grupos: boxplot / violín.
#          Pocos datos: los puntos. Muchos datos: alpha / geom_bin_2d.
#          Precisión de una estimación: geom_pointrange.
# Puente S11S2: de un gráfico a una FIGURA (patchwork, tema propio, exportar).
# =============================================================================
