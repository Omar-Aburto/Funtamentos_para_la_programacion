# A4 — Crítica de un gráfico económico real
### Módulo III · Semana 9 · **Actividad formativa — sin nota, entrega obligatoria**
#### Fundamentos de Programación para Análisis Económico · UdeC-EAN

**Tipo:** formativa. **Prepara directamente la [T4 (S10–S11, portafolio de
visualización)](tarea_semana10.md)**: aquí entrenas el ojo que
después usarás para construir.
**Entrega:** documento de 1–2 páginas (PDF) + la imagen del gráfico.
**Uso de IA:** restringido (ver el final).

> **No lleva nota, pero es obligatoria.** Esta es la única entrega del curso que
> **no** se programa: se mira y se argumenta. Y es la que más rápido mejora tus
> gráficos después.

---

## Objetivo

Aplicar la teoría de la visualización a un gráfico **publicado de verdad**:
identificar qué falla, explicar **por qué** falla usando los conceptos de la
sesión, y proponer una alternativa mejor.

> Apoyo: [plantilla de crítica](../labs/semana9_plantilla_critica.md).

---

## Qué debes hacer

### 1. Encuentra un gráfico económico real (y malo)

De prensa chilena, un informe institucional, un banco, una consultora o redes
sociales. Requisitos:

- Debe ser sobre un **tema económico** (precios, empleo, crecimiento, pobreza…).
- Debe tener **problemas reales** de diseño (no basta con que sea «feo»).
- Guarda la **imagen** y la **fuente** (medio, fecha, enlace).

> No uses gráficos de los ejemplos vistos en clase. Buscar el tuyo es parte del
> ejercicio.

### 2. Diagnostica usando los conceptos del curso

Identifica **al menos tres** problemas y nombra el concepto que se viola en cada
uno. No vale «se ve mal»: hay que decir *por qué* se ve mal.

Vocabulario que se espera que uses (el que corresponda):

| Concepto | Pregunta que te ayuda |
|---|---|
| Jerarquía de Cleveland-McGill | ¿codifica lo importante con posición/longitud, o con área/color? |
| *Chart junk* | ¿hay tinta que no aporta información? |
| Eje truncado | ¿el eje Y parte de cero? ¿exagera la diferencia? |
| Tinta proporcional | ¿son barras o áreas (deben partir en 0) o líneas (pueden no hacerlo)? |
| Rango elegido (*cherry-picking*) | ¿la ventana de tiempo es completa o se eligió para contar una historia? |
| Escala de color | ¿es secuencial/divergente/categórica según el dato? |
| Accesibilidad | ¿funciona para alguien con daltonismo? Pruébalo en Coblis |
| Codificación redundante | ¿la diferencia se marca solo con color, o también con forma, línea o etiqueta? |
| Razón dato-tinta | ¿cuánta decoración por unidad de información? |
| Etiquetado | ¿hay que ir y volver a una leyenda para entenderlo? |

### 3. Evalúa la honestidad del gráfico

Responde explícitamente: **¿el gráfico induce a una conclusión que los datos no
respaldan?** Si el eje está truncado o la escala distorsiona, dilo y explica en
qué dirección sesga la lectura.

### 4. Propón la mejora

Describe el gráfico que tú harías:

- **Qué tipo** de gráfico (barras, líneas, puntos…) y por qué ese.
- **Qué codificas** en cada canal (posición, color, tamaño).
- **Qué eliminas** de lo que había.
- Un **título** que diga el hallazgo, no la variable.

Puedes acompañarlo de un **bosquejo a mano** fotografiado. **No necesitas
programarlo** — eso viene en la T4.

---

## Qué se revisa (retroalimentación, sin nota)

- [ ] Gráfico económico real, con fuente completa (medio, fecha, enlace).
- [ ] Al menos **tres** problemas, cada uno nombrando el concepto que viola.
- [ ] Juicio explícito sobre la **honestidad** del gráfico.
- [ ] Propuesta de mejora concreta: tipo, codificación, qué se elimina, título.
- [ ] Se argumenta con conceptos, no con gustos personales.
- [ ] 1–2 páginas: se valora la precisión, no la extensión.

---

## Entrega

PDF de 1–2 páginas con la imagen original incluida. Súbelo a Canvas y también a
tu repositorio (carpeta `output/` o `docs/`).

---

## Declaración de autoría y uso de IA

Incluye al final del documento:

```markdown
## Declaración de autoría y uso de IA
- Herramienta utilizada: ____ (o «ninguna»)
- Para qué la usé: ____
- Qué hice yo: ____
- Verificación: confirmo que las ideas y el juicio crítico son míos.
```

**Atención especial en esta actividad:** aquí lo que se entrena es **tu criterio**.
Puedes usar IA para revisar la redacción o para preguntar qué significa un
concepto que no te quedó claro. **No** para que diagnostique el gráfico por ti:
si el análisis lo hace la IA, la actividad no cumple ninguna función — y en la T4
tendrás que aplicar este criterio sin ayuda.
