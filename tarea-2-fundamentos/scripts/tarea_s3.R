# =============================================================================
#Autor: Omar Aburto
#Fecha: 2026-08-27
#
#
#
#Que hace: Análisis descriptivo del gasto en transporte público de un
#           grupo de usuarios  para practicar el manejo de vectores.
#==============================================================================
# 1. Creacion de 3 vectores
# Gastos mensueales, viajes mensuales, uso de Tne 
gasto_mensual <- c(15000, 42000, 18000, 55000, 12000, 38000)
viajes_sem <- c(10, 14, 12, 16, 8, 10)
usa_tne <- c(1,0,1,0,1,0)
#==============================================================================
# 2. Seleccion por posicion 
# Verificación de tipos
class(gasto_mensual)
class(viajes_sem)
class(usa_tne)
# Verificación de largo 
length(gasto_mensual)
length(viajes_sem)
length(usa_tne)
#==============================================================================
# 2. Selección por pocisión
#
# Extraer el primer gasto
gasto_mensual[1]
#
# Extraer los ultimos tres gastos
#
gasto_mensual[c(4,5,6)]
#
# Extraer todos menos el segundo gasto
gasto_mensual[-2]
#
#==============================================================================
# 3. Selección por condición
#
# Filtrar los gastos mensuales mayores a $30.000
gasto_mensual[gasto_mensual>30000]
#
# Contar cuántos usuarios gastan más de $30.000 y qué proporción son
sum(gasto_mensual>30000)
mean(gasto_mensual>30000)
#
# Extraer el gasto mensual solo de quienes NO usan TNE
gasto_mensual[usa_tne == 0]

# Contar cuántos usuarios SÍ usan TNE y qué proporción del total representan
sum(usa_tne)       
mean(usa_tne)
#
#==============================================================================
# 4. Operación vectorizada 
# Calcular el costo estimado de cada viaje
costo_por_viaje <- gasto_mensual / (viajes_sem * 4)
costo_por_viaje
#
#==============================================================================
# 5. Estadísticas 
mean(gasto_mensual)
median(gasto_mensual)
sd(gasto_mensual)
quantile(gasto_mensual)

# La media del gasto mensual es $30.000, lo que coincide con la mediana ($28.000).
# Esto indica que los datos están distribuidos de manera relativamente simétrica,
# sin valores atípicamente extremos que sesguen fuertemente el promedio hacia arriba.
