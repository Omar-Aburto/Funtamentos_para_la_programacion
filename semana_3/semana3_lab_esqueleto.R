# =============================================================================
# Laboratorio Semana 3 — Tipos de datos y vectores económicos
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Autor: Omar Aburto
# Fecha: 2026-08-25
#
# Objetivo: practicar los cinco tipos de datos (Sesión 1) y el trabajo con
#           vectores: crear, indexar, operar y resumir (Sesión 2).
#
# CÓMO USARLO: donde veas ____ tienes que escribir tú. Corre cada bloque con
#              Cmd/Ctrl + Enter y compara con el "✅ Deberías ver".
#
# Regla IA: ChatGPT es CONSULTOR, no escritor. Debes poder explicar cada línea.
# =============================================================================


# -----------------------------------------------------------------------------
# PASO 1 — Los cinco tipos (repaso de la Sesión 1)
# -----------------------------------------------------------------------------
# TODO: completa cada línea con el valor del tipo que corresponde.

region  <- "Ñuble"                    # character: texto, SIEMPRE entre comillas
poblacion <- 480609                   # numeric
es_capital <- FALSE                        # logical: ¿Ñuble es capital regional? TRUE/FALSE
fecha_censo <- as.Date("2024-05-08")        # Date: usa el formato "AAAA-MM-DD"

# TODO: crea un factor ORDENADO con los tres niveles educativos.
nivel <- factor(c("media", "superior", "básica"),
                levels  = c("básica", "media", "superior"),
                ordered = TRUE)

# Verifica los tipos (el hábito profesional: mirar ANTES de calcular):
class(region)
class(poblacion)
class(nivel)

# ✅ Deberías ver: "character" ... "numeric" ... "ordered" "factor"


# -----------------------------------------------------------------------------
# PASO 2 — Crear los vectores de trabajo
# -----------------------------------------------------------------------------
# Salarios mensuales (pesos) de 6 trabajadores, su escolaridad y el año.

salario <- c(450000, 920000, 380000, 510000, 280000, 1250000)

# TODO: completa el vector de escolaridad: 12, 16, 8, 12, 10 y 18 años.
educ <- c(12,16,8,12,10,18)

# TODO: genera los años 2018 a 2023 SIN escribirlos uno por uno (pista: usa `:`).
anios <- 2018:2023

length(salario)     # ¿cuántos elementos?
length(educ)        # ¿coinciden los largos?

# ✅ Deberías ver: 6 y 6
# ⚠️ Si los largos NO coinciden, R "recicla" el vector corto sin avisarte.
#    Es una de las causas más frecuentes de resultados silenciosamente malos.


# -----------------------------------------------------------------------------
# PASO 3 — Seleccionar por POSICIÓN
# -----------------------------------------------------------------------------
# TODO: completa los corchetes.

salario[1]              # el primer salario
salario[c(1, 3, 5)]     # primero, tercero y quinto
salario[-6]           # todos MENOS el sexto (pista: posición negativa)

# ✅ Deberías ver, en la última: 450000 920000 380000 510000 280000

# TODO: extrae los DOS ÚLTIMOS salarios. Hay más de una forma correcta.
salario[c(5,6)]

# ✅ Deberías ver: 280000 1250000


# -----------------------------------------------------------------------------
# PASO 4 — Seleccionar por CONDICIÓN (subsetting lógico)
# -----------------------------------------------------------------------------
# Primero la condición sola: devuelve un TRUE/FALSE por elemento.
salario > 500000

# ✅ Deberías ver: FALSE TRUE FALSE TRUE FALSE TRUE

# TODO: ahora úsala DENTRO de los corchetes para quedarte solo con esos salarios.
salario[salario > 500000]

# ✅ Deberías ver: 920000 510000 1250000

# TODO: cuenta cuántos superan 500.000 y qué proporción del total representan.
sum(salario > 500000)        # ¿cuántos?
mean(salario > 500000)        # ¿qué proporción?

# ✅ Deberías ver: 3 y 0.5
# 💡 Este par sum()/mean() sobre una condición es EL patrón más usado en economía:
#    contar casos y calcular tasas (pobreza, informalidad, desempleo).

## El subset que de verdad importa: por encima del tercer cuartil -------------
# TODO: calcula el Q3 y quédate con los salarios que lo superan.

q3 <- quantile(salario, 0.75)
q3

# ✅ Deberías ver: 817500

salario[salario > q3]

# ✅ Deberías ver: 920000 1250000
# 💡 Usar un cuartil en vez de un número inventado hace que el corte dependa
#    de los datos, no de tu intuición.


# -----------------------------------------------------------------------------
# PASO 5 — Operaciones vectorizadas
# -----------------------------------------------------------------------------
# Una sola instrucción opera TODO el vector. No hay que repetir nada.

ipc <- c(1.000, 1.030, 1.055, 1.098, 1.140, 1.175)   # índice de precios por año

# TODO: calcula el salario real dividiendo cada salario por SU propio IPC.
salario_real <- salario / ipc
round(salario_real)

# ✅ Deberías ver: 450000 893204 360190 464481 245614 1063830
# 💡 R emparejó elemento con elemento: el salario de 2018 con el IPC de 2018,
#    y así con los seis. Eso es vectorización.

# TODO: ¿en qué AÑOS el salario real superó los 500.000?
#       Pista: usa el vector `anios` con una condición sobre `salario_real`.
anios[salario_real>500000]

# ✅ Deberías ver: 2019 2023


# -----------------------------------------------------------------------------
# PASO 6 — Estadísticas descriptivas
# -----------------------------------------------------------------------------
# TODO: completa las cuatro funciones de resumen.

mean(salario)        # promedio
median(salario)        # mediana
sd(salario)          # desviación estándar
quantile(salario)    # min, Q1, mediana, Q3, max

# ✅ Deberías ver: 631666.7 ... 480000 ... 374241.5

# Pregunta guía (responde en el comentario):
# La media (631.667) es bastante MAYOR que la mediana (480.000). ¿Por qué?
# Pista: mira el salario más alto del vector.
# RESPUESTA: porque el salario mas alto eleva el promedio porque esta alejado de
#           de la mediana 
#
# 💡 Esto es general en datos de ingreso: unos pocos valores muy altos tiran la
#    media hacia arriba. Por eso en economía se suele reportar la MEDIANA.


# -----------------------------------------------------------------------------
# PASO 7 — Pregúntale a ChatGPT (y verifica)
# -----------------------------------------------------------------------------
# Hazle esta pregunta tal cual:
#
#   "¿Cómo indexo un vector en R para obtener los valores mayores a 100.000?"
#
# TODO: pega abajo el código que te dio y CÓRRELO con nuestro vector `salario`.
#
valores_mayores <- salario[salario > 100000]
print(valores_mayores)


# TODO: responde en comentarios:
# ¿Funcionó a la primera? si
# ¿Usó la misma forma que aprendiste en el PASO 4, u otra distinta? distinta
# ¿Entiendes cada parte de lo que te dio? Si no, ¿qué parte no? si
#
# ⚠️ La regla del curso: si no puedes explicar el código, no es tuyo.


# -----------------------------------------------------------------------------
# PASO 8 — (Opcional) Una pregunta propia
# -----------------------------------------------------------------------------
# Formula UNA pregunta sobre estos datos y respóndela con código.
# Ejemplo: ¿cuál es el salario promedio de quienes tienen 12 años o más de
#          escolaridad? (pista: salario[educ >= 12])
#
# MI PREGUNTA: ____________________________________________________________




# -----------------------------------------------------------------------------
# AUTOEVALUACIÓN antes de entregar
# -----------------------------------------------------------------------------
# [ ] No quedan ____ sin completar.
# [ ] El script corre completo de una vez (reinicia R y córrelo entero).
# [ ] Verifiqué los tipos antes de calcular.
# [ ] Respondí las dos preguntas guía en los comentarios.
# [ ] Documenté el resultado de la consulta a ChatGPT.


# -----------------------------------------------------------------------------
# ENTREGA: guarda este script y súbelo a tu repositorio de GitHub.
# Commit sugerido: "Lab S3: tipos de datos y vectores"
#
# Este laboratorio es el ensayo de la A1 (formativa, sin nota): la actividad
# pide lo mismo, con tus propios datos.
# -----------------------------------------------------------------------------
