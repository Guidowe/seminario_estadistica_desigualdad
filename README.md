# Seminario: Estadística y programación para estudios del trabajo, desigualdad y pobreza

Doctorado en Ciencias Sociales — Universidad de Buenos Aires.
Equipo docente: Dr. Santiago Poy y Dr. Guido Weksler.

Este repositorio contiene los materiales de la **parte práctica** del seminario:
8 clases de trabajo con la Encuesta Permanente de Hogares (EPH) usando R.

---

## Cómo empezar (para estudiantes)

No hace falta saber programar. Son tres pasos, una sola vez.

### 1. Instalar R y RStudio

Son dos programas distintos y hay que instalar **los dos, en este orden**:

1. **R** (el motor): https://cran.r-project.org/
2. **RStudio Desktop** (la interfaz donde vamos a trabajar): https://posit.co/download/rstudio-desktop/

Ambos son gratuitos. Elegir la versión que corresponda al sistema operativo
(Windows, macOS o Linux).

### 2. Descargar los materiales

Descargar el archivo `.zip` del seminario y **descomprimirlo** en una carpeta
fácil de encontrar (por ejemplo `Documentos/seminario`).

> **Importante:** hay que descomprimirlo de verdad, no abrirlo "espiando"
> adentro del zip. Si al abrir los archivos aparece un error de que no
> encuentra las bases de datos, casi siempre es porque el zip nunca se
> descomprimió.

### 3. Abrir el proyecto y correr el setup

1. Entrar a la carpeta y hacer **doble clic en `seminario.Rproj`**.
   Se abre RStudio ya ubicado en el lugar correcto.
2. En RStudio, abrir el archivo `00_setup.R` (panel de abajo a la derecha,
   pestaña *Files*).
3. Apretar el botón **Source** (arriba a la derecha del editor) y esperar.
   La primera vez puede tardar varios minutos: está instalando paquetes.
4. Cuando termine, en la consola tiene que aparecer un mensaje de que está
   todo listo.

Si aparece algún error, mandarlo por mail al equipo docente **copiando el
texto completo del error**. No hace falta resolverlo solo.

---

## Cómo trabajar en cada clase

Cada clase vive en su propia carpeta dentro de `clases/` y tiene dos archivos
con el mismo nombre:

| Archivo | Para qué sirve |
|---|---|
| `NN_tema.html` | **Para leer.** Se abre en el navegador. Tiene la explicación, el código comentado y los resultados. Es el material de consulta. |
| `NN_tema.R` | **Para correr.** Se abre en RStudio. Es el mismo código, sin el texto, listo para ejecutar línea por línea. |

Además, en `ejercicios/` está la consigna de la práctica de esa clase.

**La regla más importante:** siempre abrir el proyecto haciendo doble clic en
`seminario.Rproj` antes de abrir cualquier script. Si no, R no va a encontrar
las bases de datos.

> No hace falta `setwd()` nunca. Si en algún tutorial de internet ves
> `setwd("C:/Users/...")`, no lo copies: el proyecto ya resuelve eso.

### Cómo se ejecuta el código

Con el cursor parado en una línea del script, apretar **Ctrl + Enter**
(en Mac, **Cmd + Enter**). Eso manda esa línea a la consola y avanza a la
siguiente. Es la forma en la que vamos a trabajar en clase: de a una línea,
mirando qué devuelve cada una.

---

## Estructura del repositorio

```
seminario/
├── seminario.Rproj          ← doble clic acá para empezar
├── 00_setup.R               ← se corre una sola vez, al principio
├── README.md
├── bases_eph/               ← bases de datos (EPH, canastas, tablas auxiliares)
├── img/                     ← imágenes usadas en los materiales
├── assets/                  ← estilos de los documentos HTML
├── clases/
│   ├── 01_intro_r/
│   ├── 02_eph_ponderadores/
│   ├── 03_tabulados_resumen/
│   ├── 04_calidad_empleo/
│   ├── 05_distribucion_ingresos/
│   ├── 06_pobreza/
│   ├── 07_pobreza_parte2/
│   └── 08_taller_trabajo_final/
└── _docente/                ← fuentes y scripts de armado (no hace falta tocar)
```

---

## Cronograma de la parte práctica

| # | Fecha | Tema de la práctica |
|---|---|---|
| 1 | 08/10 | Introducción a la programación en R. Importación de bases, renombrado y creación de variables |
| 2 | 15/10 | La EPH: diseño de registro, uso de ponderadores y tratamiento de datos faltantes |
| 3 | 22/10 | Tabulados, medidas de resumen y asociación bivariada (Chi², V de Cramer). Exportación de resultados |
| 4 | 29/10 | Informalidad y calidad del empleo: construcción de variables complejas e índices |
| 5 | 05/11 | Distribución del ingreso: agregación (ITF), medidas de ingreso y visualización |
| 6 | 12/11 | Pobreza: joins con canastas y tablas de equivalencias, hogares repetidos |
| 7 | 19/11 | Pobreza (parte 2) |
| 8 | 26/11 | Taller de trabajo final |

---

## Para el equipo docente

Las fuentes de cada clase son los archivos `.qmd` (Quarto) que están en la
carpeta de cada clase. El HTML y el script `.R` que reciben los estudiantes
**no se escriben a mano**: se generan a partir del `.qmd`.

```r
source("_docente/build.R")   # renderiza los HTML y genera los .R
source("_docente/armar_zip.R")  # arma el zip que se entrega
```

Ver `_docente/README_docente.md` para el detalle.
