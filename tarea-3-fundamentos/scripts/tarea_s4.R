# =============================================================================
# Autor: Omar Aburto
# Fecha: 2026-09-08
# Qué hace: Análisis exploratorio del dataset CASEN reducido (Actividad A2).
# =============================================================================

# 1. Cargar los datos con ruta relativa (por qué: asegura que 
#el código funcione en cualquier computador )
casen <- read.csv("data/raw/casen_reducido.csv")

# 2. Explorar la estructura 
str(casen)      # estructura y tipos de datos
head(casen)     # primeras 6 filas
dim(casen)      #(filas y columnas)
summary(casen)  # Entrega un resumen estadístico

# ¿Qué tipo de dato tiene cada columna? 
# datos de tipo character y numeric

# ¿Hay valores NA en el dataset? 
# si hay 5 NAs en la variable ingresos

# 3. Crear un subset con una condición compuesta
# Filtrar personas mayores de 30 años Y que sean mujeres
subset_grupo <- casen[casen$edad > 30 & casen$genero == "F", ]

# 4. Calcular sobre el subset y comparar con el total
# Cuántas observaciones hay:
nrow(subset_grupo)
nrow(casen)

# Promedios de edad e ingreso
#(usando na.rm = TRUE para ignorar los valores perdidos)
mean(subset_grupo$edad, na.rm = TRUE)
mean(casen$edad, na.rm = TRUE)

mean(subset_grupo$ingreso, na.rm = TRUE)
mean(casen$ingreso, na.rm = TRUE)

# COMENTARIO INTERPRETATIVO:
# ¿El grupo gana más que el promedio general? 
# En promedio las mujeres ganan menos aunque la brecha es bastante pequeña
# esto se puede dar por casos atipicos que inflen los promedios o simple discriminacion


# 5. Pregunta propia: 
#¿Cuál es la diferencia de ingresos promedio entre quienes tienen
#           solo educación media (12 años) y quienes completaron la educación 
#           superior (16 años o más)?
# 

# Primero, creamos dos nuevos subconjuntos (subsets) 
#filtrando por los años de educación.

subset_media <- casen[casen$educ == 12, ]
subset_superior <- casen[casen$educ >= 16, ]

# Ahora calculamos el ingreso promedio para ambos grupos.
promedio_media <- mean(subset_media$ingreso, na.rm = TRUE)
promedio_superior <- mean(subset_superior$ingreso, na.rm = TRUE)
promedio_superior - promedio_media
# Mostramos los resultados en la consola
print("Ingreso promedio con Educación Media")
print(promedio_media)

print("Ingreso promedio con Educación Superior")
print(promedio_superior)

#"Se observa que quienes estudian 16 años o más ganan en promedio 228181.8
# pesos más que quienes solo completan 12 años").


