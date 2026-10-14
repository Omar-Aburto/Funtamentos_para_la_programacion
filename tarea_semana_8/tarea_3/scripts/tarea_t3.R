# =============================================================================
# Autor: Omar Aburto
# Fecha: 2026-10-13
# Descripción: Tarea 3 - Regresión económica con CASEN y ENE
# =============================================================================
# A1
# 1. Cargar las librerías 
library(dplyr)
library(broom)
library(modelsummary)

# 2. Cargar los datos y crear la variable "experiencia"
casen <- read.csv("data/raw/casen_reducido.csv") |>
  mutate(experiencia = pmax(edad - educ - 6, 0))

# 3. Estimar los dos primeros modelos
m1 <- lm(ingreso ~ educ, data = casen)
m2 <- lm(ingreso ~ educ + experiencia + genero, data = casen)
# =============================================================================
# A2. La tabla de coeficientes con broom + dplyr
# =============================================================================

tabla_m2 <- tidy(m2, conf.int = TRUE) |>
  filter(term != "(Intercept)") |>
  mutate(across(c(estimate, conf.low, conf.high), round),
         significativo = p.value < 0.05) |>
  select(term, estimate, conf.low, conf.high, p.value, significativo) |>
  arrange(p.value)

# Imprimimos la tabla para verla
tabla_m2
# =============================================================================
# A3. Comparar modelos (Opción: interaccion educ * genero)
# =============================================================================

# 1. Creamos el tercer modelo con la interacción.
# El asterisco crea educ, genero y la interacción educ:generoM automáticamente.
m3 <- lm(ingreso ~ educ * genero + experiencia, data = casen)

# 2. Guardamos los tres modelos en una lista
modelos <- list(simple = m1, controles = m2, interaccion = m3)

# 3. Aplicamos glance() para comparar R-cuadrado ajustado
comparacion <- lapply(modelos, glance) |> 
  bind_rows(.id = "modelo") |>
  select(modelo, r.squared, adj.r.squared, AIC, nobs)

comparacion
# Al mirar la tabla, vemos que el R-cuadrado normal siempre sube (llega a 0.480), 
# pero el R-cuadrado AJUSTADO cae constantemente de 0.448 (modelo simple) a 
# 0.438 (interacción). Esto nos dice que agregar la experiencia, el género y la 
# interacción realmente NO mejora el modelo de forma genuina, ya que el R2 ajustado 
# nos penaliza por meter variables que aportan muy poco poder explicativo extra.

# =============================================================================
# A4. ¿Cambió el coeficiente de educación?
# =============================================================================

# Juntamos las tablas y filtramos la fila de "educ"
coef_educ <- bind_rows(
  simple      = tidy(modelos$simple),
  controles   = tidy(modelos$controles),
  interaccion = tidy(modelos$interaccion), 
  .id         = "modelo"
) |>
  filter(term == "educ") |>
  select(modelo, estimate, std.error, p.value)

coef_educ
# El coeficiente de educación cambia levemente con controles (de $42.080 a $42.246) 
# porque estamos aislando su efecto de otras variables (experiencia y género). 
# Sin embargo, en el modelo de interacción da un salto grande a $46.646. Esto 
# ocurre porque su interpretación cambió: en ese modelo, $46.646 es el retorno 
# por año de educación ÚNICAMENTE para la categoría base (mujeres), ya no es un 
# promedio general de todos.
# =============================================================================
# A5. Diagnóstico 
# =============================================================================

# 1. Las tres personas peor predichas (residuos más grandes)
peor_predichas <- augment(m2) |>
  arrange(desc(abs(.resid))) |>
  head(3) |>
  select(.rownames, ingreso, educ, genero, .fitted, .resid)

peor_predichas

# COMENTARIO PARA A5.1:
## Las tres observaciones peor predichas  tienen en común que 
# son hombres (genero M) con residuos negativos altísimos. Por ejemplo, el peor 
# de todos gana $298.210 menos en la realidad de lo que el modelo predice para 
# su nivel de educación y experiencia.

# 2. Máxima distancia de Cook y máximo apalancamiento (.hat)
influencia <- augment(m2) |>
  summarise(
    max_cook = max(.cooksd, na.rm = TRUE),
    max_hat  = max(.hat, na.rm = TRUE)
  )

influencia

# 3. Re-estimar el modelo m2 SIN la observación más influyente
indice_max_cook <- augment(m2) |>
  slice_max(.cooksd, n = 1) |>
  pull(.rownames)

m2_sin_influyente <- casen |>
  filter(row_number() != as.numeric(indice_max_cook)) |>
  lm(ingreso ~ educ + experiencia + genero, data = _)

# Comparar coeficiente
bind_rows(todos = tidy(m2), sin_el_peor = tidy(m2_sin_influyente), .id = "muestra") |>
  filter(term == "educ") |>
  select(muestra, estimate, std.error, p.value)

# Al excluir a una sola persona con alta Distancia de Cook, el coeficiente 
# de educación aumenta notablemente. Esto evidencia que con n = 55, el 
# resultado global es altamente dependiente de unas pocas observaciones atípicas.

# =============================================================================
# A6. Interpretación de la Parte A
# =============================================================================


# «En el modelo con controles, cada año adicional de educación se asocia con
# $42.246 más de ingreso mensual, en promedio, manteniendo experiencia y
# género constantes (IC 95 %: $29.508 a $54.985).»
#
# El coeficiente de generoM es económicamente grande ($55.686 es una brecha 
# de ingresos importante en la realidad), pero su p-value es mayor a 0.05, por 
# lo que NO es estadísticamente significativo. Con una muestra tan pequeña (n = 55), 
# hay mucho "ruido" estadístico, por lo que no tenemos evidencia suficiente para 
# afirmar con seguridad que esta diferencia no sea cero en la población completa.

# # =============================================================================
# PARTE B — ENE: 
# =============================================================================

# B1. 
# PREGUNTA: ¿Existe una brecha en las horas habituales trabajadas entre hombres
# y mujeres ocupados, y cuánto de esta diferencia se mantiene al comparar 
# personas con el mismo nivel educativo y la misma edad?


# =============================================================================
# B2. Prepara la base
# =============================================================================

# Cargamos la base cruda
ene <- read.csv2("data/raw/ene-2026-06-mjj.csv")

ocupados <- ene |>
  filter(activ == 1) |>                        # Filtramos solo a los ocupados
  mutate(
    mujer = sexo == 2,                         # TRUE si es mujer, FALSE si es hombre
    
    # AUDITORÍA 1 (Horas): Limpiar los centinelas 888 y 999 que distorsionan el promedio
    habituales = na_if(na_if(habituales, 888), 999),
    
    # AUDITORÍA 2 (Educación): Limpiar el código 9 ("Sin clasificación")
    educ_nivel = na_if(cine11_1d, 9),
    educ_nivel = as.character(educ_nivel)      # Lo pasamos a texto para que sea categoría
  ) |>
  # Filtramos a los que quedaron como NA para tener una base impecable
  filter(!is.na(habituales), !is.na(educ_nivel)) 

# Revisamos cuántas personas nos quedaron en la muestra limpia
nrow(ocupados)
# =============================================================================
# B3. Al menos dos modelos
# =============================================================================

# Modelo 1: Base (solo el efecto del género sobre las horas)
e1_base <- lm(habituales ~ mujer, data = ocupados, weights = fact_cal)

# Modelo 2: Con controles (género + nivel educativo + edad)
e2_controles <- lm(habituales ~ mujer + educ_nivel + edad, 
                   data = ocupados, weights = fact_cal)


# =============================================================================
# B4. Extrae y compara con broom + dplyr
# =============================================================================

# 1. Tabla con el coeficiente de interés ("mujerTRUE") en ambos modelos
coef_mujer_ene <- bind_rows(
  base      = tidy(e1_base),
  controles = tidy(e2_controles),
  .id       = "modelo"
) |>
  filter(term == "mujerTRUE") |>
  mutate(estimate = round(estimate, 1)) |> # Redondeamos a 1 decimal (horas)
  select(modelo, estimate, std.error, p.value)

coef_mujer_ene

# 2. Resumen global de ambos modelos con glance()
glance_ene <- bind_rows(
  base      = glance(e1_base),
  controles = glance(e2_controles),
  .id       = "modelo"
) |>
  select(modelo, r.squared, adj.r.squared, nobs)

glance_ene

# 3. Interacción: ¿La brecha de horas entre hombres y mujeres es distinta 
#    según el nivel educativo?
e3_interaccion <- lm(habituales ~ mujer * educ_nivel + edad, 
                     data = ocupados, weights = fact_cal)

tidy(e3_interaccion) |> 
  filter(grepl(":", term)) |>  # Filtramos solo las filas de la interacción
  select(term, estimate, p.value)
# =============================================================================
# B5. Sensibilidad
# =============================================================================

# Estimamos el mismo modelo con controles, pero SIN el factor de expansión
e2_sin_ponderar <- lm(habituales ~ mujer + educ_nivel + edad, data = ocupados)

# Comparamos el coeficiente de la mujer en ambos casos
sensibilidad <- bind_rows(
  ponderado    = tidy(e2_controles),
  sin_ponderar = tidy(e2_sin_ponderar),
  .id          = "decision"
) |>
  filter(term == "mujerTRUE") |>
  mutate(estimate = round(estimate, 1)) |>
  select(decision, estimate, std.error)

sensibilidad

# Estimar el modelo con y sin ponderación poblacional 
# (fact_cal). Al no ponderar, asumimos erróneamente que la muestra representa 
# perfectamente al país. Esto mueve el coeficiente de la brecha de horas de 
# -4.4 (ponderado) a -4.8, demostrando que el diseño muestral 
# sí afecta la estimación del parámetro.

# =============================================================================
# B6. Interpretación de la Parte B
# =============================================================================


# El modelo base responde a la pregunta de la brecha general, mostrando que ser 
# mujer se asocia con trabajar 4,1 horas habituales menos a la semana en comparación 
# con los hombres. Al incorporar controles, la pregunta cambia a: ¿cuál es la brecha 
# entre un hombre y una mujer que tienen exactamente la misma edad y nivel educativo? 
# Bajo estas condiciones (ceteris paribus), la asociación sube a 4,4 horas menos. 
# Con más de 40.000 observaciones, los valores p son minúsculos haciendo que todo sea 
# estadísticamente significativo; sin embargo, esta brecha sí es económicamente 
# importante, ya que 4,4 horas equivalen a más de media jornada laboral semanal perdida. 
# Primera limitación: los errores estándar de la función lm() con "weights" no consideran 
# el diseño muestral complejo de la ENE , por lo que la significancia está 
# sobreestimada. Segunda limitación: existe un claro sesgo por variables omitidas 
# (por ejemplo, el número de hijos menores), por lo que la regresión solo describe 
# asociaciones y no una causalidad.

