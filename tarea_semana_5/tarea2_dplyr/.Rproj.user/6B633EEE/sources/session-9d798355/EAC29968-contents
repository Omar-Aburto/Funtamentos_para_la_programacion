# =============================================================================
# Tarea T2 — Limpieza y agregación con dplyr
# Autor: Omar Aburto
# Fecha: 2026-09-22
# Qué hace: Analiza cómo los sueldos extremos distorsionan la brecha salarial 
#           de género, comparando el promedio versus la mediana de ingresos.
# =============================================================================

# -----------------------------------------------------------------------------
# PASO 1 — Declara tu pregunta
# -----------------------------------------------------------------------------
# MI PREGUNTA: ¿Cómo cambia la brecha salarial de género al comparar la mediana 
#              de ingresos en lugar del promedio, logrando así mitigar el 
#              efecto de los sueldos extremadamente altos?

library(dplyr)

# -----------------------------------------------------------------------------
# PASO 2 — Carga y explora
# -----------------------------------------------------------------------------
# Se ejecutan desde la RAÍZ del proyecto
casen    <- read.csv("data/raw/casen_reducido.csv")
ingresos <- read.csv("data/raw/casen_ingresos.csv")

# Auditoría inicial de los datos
dim(casen)
str(casen)
summary(casen$ingreso)
sum(is.na(casen$ingreso))

# - Dimensiones: 60 filas y 6 columnas.
# - Tipos: region, sector y genero son texto (character)
#          educ, edad e ingreso son números.
# - valores perdidos: Existen exactamente 5 NA en la variable 'ingreso'.

# -----------------------------------------------------------------------------
# PASO 2b — Elige columnas por patrón
# -----------------------------------------------------------------------------
# Usando los selectores en la base de apoyo casen_ingresos.csv
names(select(ingresos, starts_with("ing")))   # por cómo EMPIEZA el nombre
names(select(ingresos, where(is.numeric)))    # por el TIPO de contenido

# El primero devuelve 4 columnas porque filtra estrictamente las que empiezan 
# con el texto "ing_". El segundo devuelve 7 columnas porque incluye a TODAS las 
# que son números.
# -----------------------------------------------------------------------------
# PASO 3 — Preparar las variables (mutate y case_when)
# -----------------------------------------------------------------------------
casen <- casen |>
  mutate(experiencia = pmax(edad - educ - 6, 0),     #Experiencia de Mincer 
    nivel_educ = case_when(
      educ <  12 ~ "Sin media completa",             # Creamos las categorias
      educ == 12 ~ "Media completa",                 # para los niveles de 
      TRUE       ~ "Superior") )                     # educacion 


# -----------------------------------------------------------------------------
# PASO 4 y 5 — Cadena de verbos (pipe) y Tratamiento explícito de NA
# -----------------------------------------------------------------------------
# Filtramos (!is.na) para que los 5 casos sin dato en 'ingreso' no contaminen 
# el codigo. 
# Es aceptable perderlos porque no podemos inventar salarios sin sesgar 
# artificialmente las diferencias entre el promedio y la mediana.

# (a) Dos agregaciones con summarise() que colapsan a una tabla de grupos:

# 1. Por UN grupo (Brecha de género general: Promedio vs Mediana)
brecha_general <- casen |>
  filter(!is.na(ingreso) & edad >= 18) |>  # Condición combinada (con ingreso y mayores de edad)
  group_by(genero) |>                      # agrupamos por genero 
  summarise(
    n = n(),                              
    ing_promedio = mean(ingreso, na.rm = TRUE), # ingreso promedio
    ing_mediano = median(ingreso, na.rm = TRUE) # ingreso mediano
  ) |>
  arrange(desc(ing_promedio))                   # ordenamos de mayor a menor 

print(" Brecha General (Promedio vs Mediana) ")
print(brecha_general)

# 2. Por DOS grupos cruzados (Género cruzado por nivel educativo)
brecha_cruzada <- casen |>
  filter(!is.na(ingreso) & edad >= 18) |>   # Condición combinada (con ingreso y mayores de edad)
  group_by(nivel_educ, genero) |>           # agrupamos por nivel educativo y genero 
  summarise(
    n = n(),
    ing_promedio = mean(ingreso, na.rm = TRUE),
    ing_mediano = median(ingreso, na.rm = TRUE),
    .groups = "drop"                       # Evita que el resultado quede agrupado
  ) |>
  arrange(nivel_educ, desc(ing_promedio))

print("Brecha Cruzada por Educación")
print(brecha_cruzada)


# (b) Una comparación con group_by() + mutate() (Conserva las filas)
# Responde algo que summarise no puede: en vez de colapsar a 2 filas (H y M), 
# conserva a las 60 personas y sitúa el ingreso de cada individuo respecto 
# a la MEDIANA de su propio género para ver su dispersión.
casen <- casen |>
  group_by(genero) |>
  mutate(distancia_mediana = ingreso - median(ingreso, na.rm = TRUE)) |>
  ungroup()

# Revisamos las primeras filas para comprobar que conservamos a las personas
head(select(casen, genero, ingreso, distancia_mediana))

# -----------------------------------------------------------------------------
# PASO 6 — Guardar los datos procesados
# -----------------------------------------------------------------------------
# Guardamos la base de datos limpia con nuestras variables nuevas.
write.csv(casen, "data/processed/casen_t2_limpia.csv", row.names = FALSE)
# -----------------------------------------------------------------------------
# PASO 7 — Interpretar 
# -----------------------------------------------------------------------------
# INTERPRETACIÓN:
# Al analizar los datos, la brecha de ingresos se asocia al género, pero su 
# magnitud cambia según la métrica. Usando el promedio, los hombres ganan 
# $673.607 y las mujeres $636.296, existiendo una brecha a favor de los 
# hombres de $37.311. Sin embargo, al usar la mediana para mitigar el efecto 
# de ingresos extremos, esta brecha se reduce a $21.500 (mediana masculina 
# de $680.500 vs $659.000 femenina). Esto responde la pregunta: mitigar los 
# sueldos atípicos disminuye la brecha observable. Una limitación central de 
# este análisis es el tamaño muestral pequeño (solo 55 casos válidos).