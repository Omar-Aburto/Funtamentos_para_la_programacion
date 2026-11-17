# A5 — Do-file de limpieza y descriptivos en Stata
### Módulo IV · Semana 12 · **Actividad formativa — sin nota, entrega obligatoria**
#### Fundamentos de Programación para Análisis Económico · UdeC-EAN

**Tipo:** formativa. **Prepara directamente la [T5 (S13, automatización)](tarea_semana13.md)**:
aquí escribes el do-file «a mano»; en la T5 lo automatizas.
**Entrega:** martes 10 de noviembre, 23:59. `.do` comentado + su `.log`, en tu repositorio de GitHub.
**Uso de IA:** restringido (ver el final).

> **No lleva nota, pero es obligatoria.** Es tu primer do-file completo: la base
> sobre la que se construye toda la Semana 13.

---

## Objetivo

Escribir un do-file que **corra de principio a fin sin intervención** y produzca
un `.log` con la limpieza y los descriptivos de la CASEN — trasladando a Stata lo
que ya sabes hacer en R.

> Datos: `data/raw/casen_reducido.csv` (60 filas · las mismas variables que en R).
> Punto de partida: [esqueleto del laboratorio](../labs/semana12_lab_esqueleto.do)
> y la [comparación R ↔ Stata](../labs/semana12_comparacion_R.R).
>
> Antes de correr, Stata debe estar en la carpeta del proyecto (`pwd`, `cd`; S12S1).

---

## Qué debes hacer

Crea `scripts/tarea_a5.do`.

### 1. Encabezado y bitácora

```stata
* ============================================================
* A5 — Limpieza y descriptivos de CASEN
* Autor: [TU NOMBRE]      Fecha: [FECHA]
* ============================================================
clear all
set more off
capture mkdir "output"
capture log close
log using "output/tarea_a5.log", replace text
```

> `capture log close` antes de abrir el log evita el error más frecuente al
> re-ejecutar un do-file.

### 2. Carga los datos

```stata
import delimited "data/raw/casen_reducido.csv", clear varnames(1) encoding("utf-8")
describe
summarize
```

> `encoding("utf-8")` hace que «Construcción» y «Ñuble» se lean bien (S12S1). Si ya
> tienes `data/processed/casen.dta`, también puedes cargarla con `use ..., clear`.

### 3. Crea variables con `generate` y `replace`

- La **experiencia potencial de Mincer**:
  `generate experiencia = max(edad - educ - 6, 0)`
- Una variable **indicadora** (ej. `mujer`, o `alta_educ` para 13+ años).
- Al menos un uso de `replace` sobre una variable ya creada.

> Recuerda el *gotcha*: `generate` **crea**, `replace` **modifica**. Usar el
> equivocado da error, y eso es deliberado en Stata.

### 4. Etiqueta (la cultura de Stata)

Pon etiqueta a las variables que creaste:

```stata
label variable experiencia "Experiencia potencial (años)"
```

> En R esto es opcional; en Stata es parte de la buena práctica, y `haven` las
> conserva al volver a R.

**Recomendado (S12S2):** etiqueta también los **valores** de tu indicadora
(`label define` + `label values`), o crea una categórica con `encode sector,
generate(sector_n)` o con `recode educ (...), generate(nivel_educ)`.

### 5. Cuidado con los missing

`ingreso` tiene valores faltantes. Comprueba cuántos:

```stata
count if missing(ingreso)
```

**Deja un comentario** que responda: ¿por qué `summarize ingreso` no se equivoca
con los missing, pero `count if ingreso > 500000` **sí** puede equivocarse?

> El *gotcha* central de Stata: el missing (`.`) es **mayor que cualquier número**.
> Filtrar sin excluirlo cuenta como «altos» a los que no tienen dato.

### 6. Descriptivos

- `summarize` de las variables numéricas.
- `tabulate` de una categórica (`sector` o `region`).
- Un `tabulate` cruzado o un `summarize ... if` por grupo.
- `correlate` entre `ingreso`, `educ` y `experiencia`.
- **Recomendado:** guarda un resultado con `scalar` antes de que `r()` se
  sobrescriba (por ejemplo, la media de ingreso) y muéstralo con `display`.

### 7. Cierra la bitácora e interpreta

```stata
log close
```

Y al final del do-file, un comentario de **4 a 6 líneas** con lo que muestran tus
descriptivos: cifras en pesos, «se asocia» en vez de «causa».

---

## Qué se revisa (sin nota)

- [ ] El do-file corre **completo de una vez**, sin editar nada.
- [ ] Encabezado, `clear all`, y `log` abierto y cerrado correctamente.
- [ ] `experiencia` de Mincer correcta + indicadora + un uso de `replace`.
- [ ] Al menos una variable etiquetada.
- [ ] Comentario que explica el *gotcha* de los missing en Stata.
- [ ] `summarize`, `tabulate` y `correlate` presentes.
- [ ] Interpretación breve, en pesos, sin lenguaje causal.
- [ ] `.do` y `.log` subidos a GitHub.

---

## Entrega

Sube `scripts/tarea_a5.do` **y** `output/tarea_a5.log` a tu repositorio, y pega el
enlace en Canvas.

> El `.log` es la prueba de que tu do-file efectivamente corrió. Un `.do` sin
> `.log` está incompleto.

---

## Declaración de autoría y uso de IA

Añade al final de tu `README.md`:

```markdown
## Declaración de autoría y uso de IA
- Herramienta utilizada: ____ (o «ninguna»)
- Para qué la usé: ____ (ej.: recordar la sintaxis de label variable)
- Qué hice yo: ____
- Verificación: confirmo que entiendo y puedo explicar todo lo que entrego.
```

**Uso razonable aquí:** preguntar el equivalente en Stata de algo que ya sabes
hacer en R («¿cómo es `group_by` + `summarise` en Stata?»). Eso es exactamente el
«mapa R ↔ Stata» del curso y es un buen uso.

**Uso no permitido:** pedir el do-file completo. Si no puedes explicar por qué
pusiste `capture log close` o qué hace tu `if`, no aprendiste lo que esta
actividad busca — y la T5 se construye encima de esto.
