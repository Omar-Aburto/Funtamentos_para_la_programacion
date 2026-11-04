# =============================================================================
# Tarea 4 — Parte 2: Portafolio y figura compuesta 
# Fundamentos de Programación para Análisis Económico 
#
# Autor: Omar Aburto
# Fecha: 2026-11-03
#
# Objetivo: Analizar la distribución del ingreso (CASEN) y la informalidad 
# laboral (ENE), justificando la elección de geometrías y componiendo una 
# figura final con patchwork.
# =============================================================================
# 1. Carga de librerías
library(ggplot2)
library(dplyr)
library(patchwork)
library(scales)
library(ggrepel)

# Carga y limpieza
casen <- read.csv("data/raw/casen_reducido.csv") |> filter(!is.na(ingreso))
ene <- read.csv2("data/raw/ene-2026-06-mjj.csv") |> filter(activ == 1)

regiones <- c("Tarapacá", "Antofagasta", "Atacama", "Coquimbo", "Valparaíso",
              "O'Higgins", "Maule", "Biobío", "La Araucanía", "Los Lagos",
              "Aysén", "Magallanes", "Metropolitana", "Los Ríos",
              "Arica y Parinacota", "Ñuble")

ocupados <- ene |>
  mutate(informal   = ocup_form == 2,
         mujer      = sexo == 2,
         region_txt = regiones[region])
# -------------------------------------------------------------------------
# Gráfico 1 · Scatter CASEN 
# -------------------------------------------------------------------------
grafico_1 <- ggplot(casen, aes(x = educ, y = ingreso, color = genero)) + 
  geom_point(size = 2, alpha = 0.7) +                                    # Dibuja los puntos 
  scale_color_manual(values = c("F" = "#e69b0a", "M" = "#223c6a")) +     # Fija colores manuales (dorado y azul institucional)
  scale_y_continuous(
    labels = label_currency(big.mark = ".", decimal.mark = ",")          # Eje Y en pesos chilenos
  ) +
  labs(
    title = "A mayor educación, mayor ingreso",                          
    x = "Años de escolaridad",                                           # Etiqueta del eje X
    y = NULL,                                                            # Oculta la etiqueta del eje Y (ya se entiende por el $)
    color = NULL,                                                        # Oculta el título de la leyenda
    caption = "Fuente: CASEN "                                           # Fuente de los datos
  ) +
  theme_minimal(base_size = 11) +                                        # Tema limpio sin chart junk
  theme(
    plot.title = element_text(face = "bold", color = "#223c6a"),         # Título principal en negrita y color azul
    legend.position = "bottom"                                           # Mueve la leyenda abajo
  )

grafico_1                                                                # Imprime el gráfico en pantalla

# -------------------------------------------------------------------------
# Gráfico 2 · Barras de informalidad por región (ENE)
# -------------------------------------------------------------------------
# 1. Preparar los datos y calcular promedios ponderados
inf_region <- ocupados |>
  group_by(region_txt) |>                                            # Agrupa por región
  summarise(total = 100 * weighted.mean(informal, fact_cal))         # Calcula el % ponderado por región

inf_nacional <- 100 * weighted.mean(ocupados$informal, ocupados$fact_cal) # Calcula el % ponderado de todo Chile

# Revisa los primeros resultados ordenados
head(arrange(inf_region, desc(total)), 3)                            # Muestra las 3 regiones más informales


# 2. Construir el gráfico resaltando a Ñuble
grafico_2 <- inf_region |>
  mutate(destacar = region_txt == "Ñuble") |>                              # Variable lógica: TRUE para Ñuble, FALSE el resto
  ggplot(aes(x = total, y = reorder(region_txt, total), fill = destacar)) + # Ordena las barras de menor a mayor
  geom_col(show.legend = FALSE) +                                          # Dibuja la altura ya calculada y oculta leyenda
  scale_fill_manual(values = c(`TRUE` = "#e69b0a", `FALSE` = "grey75")) +  # Dorado para Ñuble, gris para el resto
  geom_text(aes(label = round(total, 1)), hjust = -0.15, size = 3.3) +     # Escribe el valor al lado de cada barra
  geom_vline(xintercept = inf_nacional, linetype = "dashed") +             # Línea punteada para el promedio nacional
  annotate("text", x = inf_nacional + 0.5, y = 2, hjust = 0,               # Etiqueta de texto para la línea de referencia
           label = "Promedio de Chile: 26,5 %") +
  scale_x_continuous(limits = c(0, 45)) +                                  # Amplía el margen para que los números no se corten
  labs(
    title = "Ñuble es la segunda región con\nmayor informalidad laboral",   
    x = "% de ocupados informales",                                      
    y = NULL                                                               # Borra el nombre del eje Y
  ) +
  theme_minimal(base_size = 11) +                                          # Tema base limpio sin chart junk
  theme(
    plot.title = element_text(face = "bold", color = "#223c6a"),           # Título en negrita y color institucional
    panel.grid.major.y = element_blank()                                   # Borra las líneas horizontales de fondo
  )

grafico_2                                                                  # Imprime el gráfico en pantalla

# -------------------------------------------------------------------------
# Gráfico 3 · Distribución de horas habituales por sexo (ENE)
# -------------------------------------------------------------------------

# 1. Limpieza de datos: quitar centinelas
horas_limpias <- ocupados |>
  mutate(habituales = na_if(na_if(habituales, 888), 999))                        # Convierte los valores 888 y 999 en NA


# 2. Construir el gráfico de densidad separando por sexo
grafico_3 <- horas_limpias |>
  mutate(sexo_txt = ifelse(sexo == 1, "Hombres", "Mujeres")) |>                  # Transforma 1 y 2 en texto
  ggplot(aes(x = habituales, fill = sexo_txt, weight = fact_cal)) +              # Mapea el relleno a la nueva variable
  geom_density(alpha = 0.5) +                                                    
  scale_fill_manual(values = c("Mujeres" = "#e69b0a", "Hombres" = "#223c6a")) +  
  scale_x_continuous(limits = c(0, 80)) +                                        
  labs(
    title = "Las jornadas laborales se concentran\nfuertemente en 40 y 45 horas", 
    x = "Horas habituales por semana",
    y = "Densidad",
    fill = NULL                                                                  
  ) +
  theme_minimal(base_size = 11) +                                                
  theme(
    plot.title = element_text(face = "bold", color = "#223c6a"),                 
    legend.position = "bottom"                                                   
  )

grafico_3                                                                        # Imprime el gráfico


# Elegí geom_density porque, al trabajar con una muestra tan grande de la ENE, 
# permite visualizar con precisión la forma de la distribución. 
# Esto revela inmediatamente los picos (modas) exactos en las jornadas legales de 
# 40 y 45 horas, un comportamiento estructural del mercado laboral chileno que 
# un geom_boxplot habría ocultado dentro de los cuartiles de la caja.

# -------------------------------------------------------------------------
# Gráfico 4 · Informalidad de hombres contra mujeres por región (ENE)
# -------------------------------------------------------------------------

# 1. Calcular la informalidad ponderada separada por sexo para cada región
inf_sexo_region <- ocupados |>
  group_by(region_txt) |>
  summarise(
    hombres = 100 * weighted.mean(informal[!mujer], fact_cal[!mujer]),           # % de informalidad en hombres
    mujeres = 100 * weighted.mean(informal[mujer],  fact_cal[mujer])             # % de informalidad en mujeres
  )

# 2. Construir el gráfico de dispersión con ggrepel
grafico_4 <- ggplot(inf_sexo_region, aes(x = hombres, y = mujeres)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") + # Línea diagonal de referencia y=x
  geom_point(color = "#223c6a", size = 2.5) +                                    
  geom_text_repel(aes(label = region_txt), size = 3, max.overlaps = Inf, seed = 1) + # Etiquetas que evitan pisarse
  labs(
    title = "Las mujeres enfrentan mayor informalidad en casi todas las regiones", # Título tipo hallazgo[cite: 1]
    x = "Informalidad hombres (%)",
    y = "Informalidad mujeres (%)"
  ) +
  theme_minimal(base_size = 11) +                                                
  theme(plot.title = element_text(face = "bold", color = "#223c6a"))             # Título en negrita

grafico_4


# -------------------------------------------------------------------------
# Gráfico 5 · Gráfico libre: La U de la informalidad por edad (ENE)
# -------------------------------------------------------------------------
# Pregunta: ¿Cómo varía la informalidad a lo largo de la vida laboral?

grafico_5 <- ocupados |>
  filter(edad <= 80) |>                                                  # Filtra hasta los 80 años para evitar distorsiones en edades extremas
  group_by(edad) |>
  summarise(tasa = 100 * weighted.mean(informal, fact_cal)) |>           # Calcula la tasa ponderada para cada edad exacta
  ggplot(aes(x = edad, y = tasa)) +
  geom_line(color = "#223c6a", linewidth = 1) +                          # Dibuja la línea que forma la "U"
  scale_y_continuous(limits = c(0, 50)) +                                # Fija el eje Y para mejor proporción
  labs(
    title = "La informalidad laboral es menor entre los 35 y 45 años",   
    x = "Edad",
    y = "% de ocupados informales"
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", color = "#223c6a"))

grafico_5



# =============================================================================
# Figura final compuesta con Patchwork
# =============================================================================
# Unimos los gráficos 2, 3 y 4 usando el operador / para dividir filas 
# y + (o |) para columnas.

figura_final <- (grafico_2 | grafico_3) / grafico_4 +
  plot_annotation(
    title = "Radiografía del mercado laboral chileno: Informalidad y jornadas",
    subtitle = "Análisis basado en la Encuesta Nacional de Empleo (trimestre MJJ)",
    caption = "Elaboración propia para Fundamentos de Programación."
  )
figura_final 
# Reflexión Final en el achivo readme

ggsave("output/figura_compuesta_t4.png", plot = figura_final, width = 12, height = 8, dpi = 300)
ggsave("output/figura_compuesta_t4.pdf", plot = figura_final, width = 12, height = 8)

