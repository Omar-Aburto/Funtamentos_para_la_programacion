# A2 — Análisis exploratorio con CASEN
### Módulo II · Semana 4 · **Actividad formativa — sin nota, entrega obligatoria**
#### Fundamentos de Programación para Análisis Económico · UdeC-EAN

**Tipo:** formativa. Es el **ensayo directo de la [T2 (S5, dplyr)](tarea_semana5.md)**:
quien hace bien esta actividad llega preparado a la tarea calificada.
No lleva nota, pero debe entregarse.
**Entrega:** script `.R` comentado, subido a tu repositorio de GitHub.

---

## Objetivo

Aplicar inspección, filtrado y estadísticas descriptivas a un dataset económico
**real** (CASEN reducido), documentando cada paso.

> Datos: [`data/raw/casen_reducido.csv`](../data/raw/casen_reducido.csv)
> Apoyo: [esqueleto del lab](../labs/semana4_lab_esqueleto.R) ·
> [cheatsheet de data frames](../materiales/cheatsheet_dataframes.md).

---

## Qué debes hacer

En un script `scripts/tarea_s4.R` con encabezado (autor, fecha, qué hace):

1. **Cargar** los datos con ruta **relativa**:
   ```r
   casen <- read.csv("data/raw/casen_reducido.csv")
   ```
2. **Explorar la estructura ANTES de analizar:** `str()`, `head()`, `dim()`,
   `summary()`. Responde en un comentario: ¿qué tipo tiene cada columna?
   ¿hay `NA`?
3. **Crear un subset** con una **condición compuesta** (usa `&` o `|`).
   Ej: mayores de 30 años Y con más de 12 años de educación.
4. **Calcular** sobre el subset y comparar con el total:
   - `nrow()` → cuántas observaciones
   - `mean()` de edad e ingreso (¡usa `na.rm = TRUE` en ingreso!)
   - ¿el grupo gana más que el promedio general? Comenta el porqué.
5. **Una pregunta propia:** formula y responde con código una pregunta sobre los
   datos (ej: brecha de ingreso por sector o por género).
6. **Documentar** cada bloque con un comentario del porqué.

---

## Qué se evalúa

- [ ] Carga con ruta relativa (no `C:/Users/...`).
- [ ] Inspección completa antes de analizar, con observaciones escritas.
- [ ] Subset con condición compuesta correcta.
- [ ] Estadísticas con `na.rm = TRUE` donde corresponde.
- [ ] Comparación subset vs. total interpretada.
- [ ] Pregunta propia respondida con código.
- [ ] Comentarios que explican el porqué; subido a GitHub con commit claro.

---

## Entrega

Pega el **enlace al script** (o al repositorio) en Canvas.
Debes poder **explicar cada línea** de tu código.
