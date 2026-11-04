# =============================================================================
# Tarea 4 — Parte 1: Portafolio de visualización con ggplot2 (Semana 10)
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Autor: Omar Aburto
# Fecha: 03-11-2026
#
# Objetivo: Construir 3 gráficos evaluando herencia de aes(), pivot_longer,
# ponderación con fact_cal y principios de diseño honesto.
# =============================================================================

# 1. Carga de librerías
library(ggplot2)  
library(dplyr)    
library(tidyr)    
library(scales)   
library(ggrepel)  

# 2. Carga y limpieza de bases de datos
# CASEN: filtramos los 5 NA en la variable ingreso
casen <- read.csv("data/raw/casen_reducido.csv") |> 
  filter(!is.na(ingreso))

# Salario mínimo: no requiere limpieza previa
salario <- read.csv("data/raw/salario_minimo_chile.csv")

# ENE: filtramos solo ocupados y limpiamos centinelas en horas habituales
ene <- read.csv2("data/raw/ene-2026-06-mjj.csv") |> 
  filter(activ == 1) |> 
  mutate(habituales = na_if(na_if(habituales, 888), 999))

# -------------------------------------------------------------------------
# Gráfico 1 · CASEN: educación e ingreso por género
# -------------------------------------------------------------------------
ggplot(casen, aes(x = educ, y = ingreso, color = genero)) +     
  geom_point(alpha = 0.6, size = 2) +                           # puntos semitransparentes
  geom_smooth(method = "lm", se = FALSE) +                      # recta de regresión lineal por género
  scale_color_viridis_d(begin = 0.2, end = 0.8) +               # paleta accesible 
  scale_y_continuous(
    labels = label_currency(big.mark = ".", decimal.mark = ",") # eje en pesos chilenos
  ) +
  labs(
    title = "Hombres ganan más que las mujeres a igual nivel educativo", 
    x = "Años de escolaridad",
    y = "Ingreso mensual",
    color = "Género",
    caption = "Fuente: CASEN"
  ) +
    theme_minimal()                                             
    theme(plot.title = element_text(face = "bold"))
    
 # ¿Qué pregunta responde este gráfico que no respondería la versión con una sola recta?
 # Responde a la pregunta: ¿Existe una brecha salarial de género para un mismo nivel 
 # educativo? Al observar el gráfico, es evidente que la recta de regresión de los 
 # hombres se ubica consistentemente por encima de la recta de las mujeres a lo 
 # largo de todo el eje X. Una sola recta agruparía a todos los individuos, 
 # demostrando únicamente que a mayor escolaridad hay mayor ingreso, pero ocultaría 
 # por completo esta desigualdad estructural.

# -------------------------------------------------------------------------
# Gráfico 2 · Ingreso mínimo: nominal contra real
# -------------------------------------------------------------------------
    
# 1. Transformación de datos a formato largo
salario_largo <- salario |>
mutate(Real = salario_minimo / ipc * 100) |>                            # Calcula el salario real (base 2010)
select(anio, Nominal = salario_minimo, Real) |>                         # Selecciona las columnas a usar
pivot_longer(cols = c(Nominal, Real), names_to = "serie", values_to = "pesos") # Pasa de columnas anchas a formato largo
    
# 2. Creación del gráfico
ggplot(salario_largo, aes(x = anio, y = pesos, color = serie, linetype = serie)) + # Mapea color y tipo de línea a "serie"
geom_line(linewidth = 1.2) +                                            # Dibuja las líneas de tiempo
scale_color_manual(values = c("Nominal" = "#e69b0a", "Real" = "#223c6a")) + # Aplica paleta personalizada
  scale_x_continuous(limits = c(2014, 2027)) +                            # Margen fijo 
  scale_y_continuous(
    labels = label_currency(big.mark = ".", decimal.mark = ",")           # Formato chileno
  ) +
  labs(
    title = "El poder adquisitivo (real) sube más lento que el salario nominal",
    x = "Año", y = "Monto en pesos", color = "Serie"
  ) +
  theme_minimal() +                                                       
  theme(plot.title = element_text(face = "bold"), legend.position = "none") +
  # Etiquetas directas con el estilo del Bloque E de la Semana 10
  geom_text(data = filter(salario_largo, anio == 2025),                   
            aes(label = serie), hjust = -0.2)

# RESPUESTAS A LAS PREGUNTAS DEL GRÁFICO 2:
# 1) ¿Por qué aquí el eje Y no necesita partir en 0 y en un gráfico de barras sí?
# En los gráficos de barras, la magnitud se representa mediante la longitud desde 
# una base; si no parte en 0, se distorsiona visualmente la proporción real entre 
# las barras. En los gráficos de líneas, el objetivo principal es mostrar la 
# tendencia y variación , por lo que enfocar el rango del eje Y 
# permite visualizar mejor los cambios en el tiempo.
#
# 2) ¿Qué ganas usando color y tipo de línea?
# Se logra una codificación redundante. Esto hace que el gráfico sea más accesible, 
# permitiendo que la información se lea correctamente si se imprime en blanco y negro 
# o si es visualizado por personas con daltonismo, garantizando que el diseño sea honesto.

# -------------------------------------------------------------------------
# Gráfico 3 · ENE: en qué trabajan hombres y mujeres
# -------------------------------------------------------------------------

# 1. Crear las etiquetas para sexo y categoría ocupacional (como en S10S2)
ene_grafico3 <- ene |>
  mutate(
    sexo = ifelse(sexo == 1, "Hombre", "Mujer"),
    categoria = case_when(
      categoria_ocupacion == 3 ~ "Asal. privado",
      categoria_ocupacion == 4 ~ "Asal. público",
      categoria_ocupacion == 2 ~ "Cuenta propia",
      TRUE                     ~ "Otras"
    )
  )

# 2. Crear el gráfico de barras apiladas al 100%
ggplot(ene_grafico3, aes(x = sexo, fill = categoria, weight = fact_cal)) +
geom_bar(position = "fill") +                                       # position = "fill" hace que sumen 100%
scale_fill_brewer(palette = "Set2") +                               # Paleta accesible
scale_y_continuous(labels = label_percent()) +                      # Eje Y en formato de porcentaje
labs(
title = "Mujeres tienen mayor participación en el sector público que los hombres", 
x = NULL,
y = "Proporción",
fill = "Categoría ocupacional",
caption = "Fuente: ENE, mayo-julio 2026 (datos ponderados)"
  ) +
theme_minimal() +
theme(plot.title = element_text(face = "bold"))

ene_grafico3 |>
  group_by(sexo, categoria) |>
  summarise(pob = sum(fact_cal), .groups = "drop") |>
  group_by(sexo) |>
  mutate(pct = round(100 * pob / sum(pob), 1))

# RESPUESTAS A LAS PREGUNTAS DEL GRÁFICO 3:
# 1) ¿En qué categoría está la mayor diferencia entre hombres y mujeres, y en cuál casi no hay?
# La mayor diferencia está en "Asalariado público", donde las mujeres alcanzan un 17,0% 
# frente al 9,2% de los hombres. Por el contrario, casi no hay diferencia en "Cuenta propia", 
# representando un 21,2% en mujeres y un 21,1% en hombres.
#
# 2) ¿Qué cambiaría si borras weight = fact_cal?
# Si se elimina la ponderación, geom_bar() solo contaría el número de filas (personas 
# encuestadas en la muestra), en lugar de sumar los pesos (fact_cal) que representan a 
# la población real de Chile.