# A1 — Vectores de datos económicos
### Módulo II · Semana 3 · **Actividad formativa — sin nota, entrega obligatoria**
#### Fundamentos de Programación para Análisis Económico · UdeC-EAN

**Tipo:** formativa. **Prepara la [T2 (S5, dplyr)](tarea_semana5.md).**
No lleva nota, pero debe entregarse: recibes retroalimentación escrita y en Canvas
la actividad debe estar entregada para avanzar en el módulo.
**Entrega:** script `.R` comentado, subido a tu repositorio de GitHub.

---

## Objetivo

Crear y manipular vectores con datos económicos, seleccionar subconjuntos por
posición y por condición, y calcular estadísticas descriptivas — todo documentado.

> Punto de partida: [esqueleto del laboratorio](../labs/semana3_lab_esqueleto.R)
> y el [cheatsheet de tipos](../materiales/cheatsheet_tipos_datos.md).

---

## Qué debes hacer

En un script `scripts/tarea_s3.R` con encabezado (autor, fecha, qué hace):

1. **Crea al menos 3 vectores** con datos económicos coherentes entre sí
   (ej: `salario`, `educ` y `anios` para un grupo de trabajadores). Verifica su
   `class()` y su `length()`.
2. **Selecciona por posición:** extrae elementos específicos (ej: el primero, los
   tres últimos, todos menos uno).
3. **Selecciona por condición:** filtra con una condición lógica (ej: salarios
   sobre cierto umbral) y **cuenta** cuántos y qué **proporción** la cumplen
   (`sum()` / `mean()`).
4. **Operación vectorizada:** calcula una variable derivada sobre todo el vector
   (ej: salario real = salario / ipc).
5. **Estadísticas:** calcula `mean`, `median`, `sd` y `quantile` de un vector, y
   **comenta** en una línea qué te dice cada una sobre los datos.
6. **Comenta el porqué**, no el qué: cada bloque con un comentario que explique la
   decisión, no que repita el código.

---

## Qué se evalúa

- [ ] Vectores creados correctamente, con tipos verificados.
- [ ] Subsetting por posición y por condición funcionando.
- [ ] Uso del patrón `sum()`/`mean()` de una condición.
- [ ] Al menos una operación vectorizada (variable derivada).
- [ ] Estadísticas descriptivas con interpretación breve.
- [ ] Comentarios que explican el porqué; nombres descriptivos.
- [ ] Subido a GitHub con un commit de mensaje claro.

---

## Entrega

Pega el **enlace al script** (o al repositorio) en Canvas.
Recuerda: debes poder **explicar cada línea** de tu código.
