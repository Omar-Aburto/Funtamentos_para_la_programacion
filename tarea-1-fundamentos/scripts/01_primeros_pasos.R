# Autor: Omar Aburto 
# Fecha: 2026-08-25
# Calcula y compara la variación porcentual del precio del pasaje 
# interurbano para usuarios con TNE y sin TNE (2025 vs 2026).

# 1. Se definen las variables de los pasajes del año pasado (2025)
pasaje_tne_2025 <- 500
pasaje_normal_2025 <- 1500

# 2. Se definen las variables de los pasajes actuales (2026)
pasaje_tne_2026 <- 750
pasaje_normal_2026 <- 2100

# 3. Realizamos el cálculo de la Tasa de variación porcentual
#: ((Precio Nuevo - Precio Viejo) / Precio Viejo) * 100
variacion_tne <- ((pasaje_tne_2026 - pasaje_tne_2025) / pasaje_tne_2025) * 100
variacion_normal <- ((pasaje_normal_2026 - pasaje_normal_2025) / pasaje_normal_2025) * 100

# 4. Revisamos los resultados
print(variacion_tne) 
print(variacion_normal)
