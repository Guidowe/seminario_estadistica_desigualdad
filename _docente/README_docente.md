# Notas para el equipo docente

## La idea en una línea

**Una sola fuente por clase (el `.qmd`), dos salidas para el estudiante
(el `.html` para leer y el `.R` para correr).** El estudiante nunca renderiza
nada: rendear es la parte frágil, y un error en el chunk 40 rompe el documento
entero con un mensaje que alguien que recién empieza no puede interpretar.

## Flujo de trabajo

```r
# 1. Editás la fuente
#    clases/06_distribucion_ingresos/06_distribucion_ingresos.qmd

# 2. Generás los materiales
source("_docente/build.R")
build(clases = "06")          # o build() para todas

# 3. Verificás que no haya rutas rotas
source("_docente/chequear_rutas.R")

# 4. Armás la entrega
source("_docente/armar_zip.R")
armar_zip(hasta_clase = 6)
```

## Reglas al escribir un `.qmd`

**Rutas.** Siempre relativas a la raíz del proyecto: `bases_eph/archivo.txt`,
nunca `../bases_eph/archivo.txt`. Esto funciona gracias a `execute-dir: project`
en `_quarto.yml`, que fija el directorio de trabajo de los chunks en la raíz.
Es lo que permite que la misma línea de código funcione dentro del `.qmd` y
dentro del `.R` que sale de él.

**Formato.** No pongas bloques de `format:` en los `.qmd`. Todo está
centralizado en `_quarto.yml`. En el `.qmd` va solo el `title:`.

**Chunks que no van al script.** Marcá con `#| purl: false` todo lo que existe
solo para el HTML: imágenes decorativas, y los chunks ocultos que cargan datos
para que se vea un resultado.

**Chunks que dependen de un archivo que puede faltar.** Usá el guard:

```r
#| eval: !expr file.exists("bases_eph/archivo.csv")
```

Así el render no se cae, y el output aparece solo cuando el archivo esté.

## Pendientes conocidos

Faltan dos bases que la clase 1 usa como ejemplos de importación. Los chunks
están escritos y guardados con el guard de arriba, así que el render funciona,
pero muestran vacío hasta que aparezcan:

- `bases_eph/base_sipa.csv` (ejemplo de lectura de `.csv`)
- `bases_eph/ipc_ceped_data.xlsx` (ejemplo de lectura de Excel)

Las clases 03, 04 y 08 están como plantilla, listas para escribir.

## Qué se arregló al migrar

- No había `.Rproj`: era el problema número uno de reproducibilidad.
- La clase 1 apuntaba a `imgs/` (3 veces) y la carpeta es `img/`.
- La clase 1 pedía los temas `teoria_claro.scss` / `teoria_oscuro.scss`, que
  no existían: se crearon como copia de los `practica_*`.
- Había rutas apuntando fuera del repositorio
  (`../../Clase 1 - Intro a R/bases/`, `../clase1/bases/`).
- Se referenciaba `usu_individual_T324.txt`, que no está en `bases_eph/`.
  Ahora apunta a `usu_individual_T125.txt`.
- El bloque `knitr: opts_chunk: dev: [svglite, darksvglite]` de la clase 1 se
  quitó al centralizar el YAML: requiere paquetes extra y era un punto de
  falla. Si querés recuperar las figuras claro/oscuro, hay que volver a
  agregarlo junto con `svglite` en `00_setup.R`.

## Carpetas viejas

`Practica 1_Intro R y EPH/` … `Practica 4_Pobreza/` y `VER_EJERCICIOS_Y_BORRAR/`
quedaron intactas para que puedas comparar. Cuando estés conforme, se borran:
todo está en git igual, y `_quarto.yml` ya las excluye del render.
