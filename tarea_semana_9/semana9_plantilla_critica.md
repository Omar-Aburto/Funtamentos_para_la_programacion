# Análisis Crítico de un Gráfico — Plantilla
## Fundamentos de Programación para Análisis Económico · Semana 9

> Laboratorio grupal / Tarea individual. Usa esta plantilla para diagnosticar un
> gráfico real de la prensa económica y proponer una mejora. ChatGPT puede ayudar a
> generar ideas de crítica, pero **el grupo valida cada punto** contra el checklist.

---

**Integrantes:** ____________________________________________
**Fecha:** __________

## 1. El gráfico original

- **Fuente:** (medio/organismo, fecha, enlace) _______________________________
- **Pega o adjunta el gráfico aquí.**

## 2. Las cuatro preguntas

1. **¿Cuál es el mensaje?** ¿Se entiende en 5 segundos?
   _______________________________________________________________________
2. **¿Los datos están bien representados?** (eje, escala, baseline, tipo de gráfico)
   _______________________________________________________________________
3. **¿Algo distorsiona o engaña?**
   _______________________________________________________________________
4. **¿Cómo lo mejorarías (en una frase)?**
   _______________________________________________________________________

## 3. Diagnóstico con el checklist

Marca lo que el gráfico **cumple**; comenta lo que falla.

- [ ] El mensaje se entiende solo
- [ ] Eje Y desde 0 en barras y áreas (en líneas no es obligatorio, pero el eje debe estar rotulado)
- [ ] Rango temporal completo, o justificado (sin *cherry-picking*)
- [ ] Tipo de gráfico adecuado al dato
- [ ] Color con función y accesible (no rojo-verde como único contraste; pruébalo en [Coblis](https://www.color-blindness.com/coblis-color-blindness-simulator/))
- [ ] No depende solo del color: forma, tipo de línea o etiqueta (codificación redundante)
- [ ] Etiquetas directas y líneas de referencia en vez de leyendas largas
- [ ] Título = hallazgo (no solo el tema)
- [ ] Sin chart junk (3D, fondos, grillas densas)
- [ ] Fuente y unidades citadas

## 4. Clasificación de los problemas

| Problema detectado | Familia (percepción / honestidad / estética) |
|---|---|
| | |
| | |
| | |

## 5. Propuesta de mejora (bosquejo)

> Diseña la **intención**, no el código (eso es la Semana 10 con ggplot2).

- **Tipo de gráfico propuesto:** _______________________________________
- **Qué resaltar (y con qué color, en HEX):** __________________________
- **Paleta propuesta** (viridis, ColorBrewer, Okabe-Ito…) y por qué: ____________
- **Qué quitar:** _____________________________________________________
- **Título propuesto (el hallazgo):** _________________________________
- **Bosquejo** (dibujo a mano / mockup): adjunta.

## 6. Uso de ChatGPT (declaración)

- ¿Qué le preguntaron? _______________________________________________
- ¿Qué de su respuesta **descartaron** por no calzar con el checklist?
  _______________________________________________________________________

---

**Entrega (GitHub):** este documento completo + el gráfico original + el bosquejo de
mejora. Commit sugerido: "Tarea S9: crítica de gráfico".
