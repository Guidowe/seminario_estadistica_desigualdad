# =============================================================================
# SEMINARIO: Estadistica y programacion para estudios del trabajo,
#            desigualdad y pobreza  (Doctorado en Ciencias Sociales, UBA)
#
#   PUESTA A PUNTO -- SE CORRE UNA SOLA VEZ, ANTES DE LA PRIMERA CLASE
#
# Que hace este script:
#   1. Verifica que estes trabajando dentro del proyecto (esto es importante).
#   2. Instala los paquetes que vamos a usar durante el seminario.
#   3. Comprueba que las bases de datos esten en su lugar.
#   4. Te avisa si algo fallo, y que hacer.
#
# COMO SE CORRE:
#   Apreta el boton "Source" (arriba a la derecha de esta ventana).
#   La primera vez puede tardar varios minutos. Es normal.
#   No hace falta que entiendas este codigo: es solo instalacion.
# =============================================================================


# ---- 1. Verificamos que estemos dentro del proyecto -------------------------

# Si abriste el proyecto con doble clic en "seminario.Rproj", R esta parado
# en la carpeta correcta y todo lo demas va a funcionar solo.

if (!file.exists("seminario.Rproj")) {
  stop(
    "\n\n",
    "  ------------------------------------------------------------------\n",
    "  R no esta parado en la carpeta del seminario.\n\n",
    "  Como se arregla:\n",
    "    1. Cerra RStudio.\n",
    "    2. Abri la carpeta del seminario en tu explorador de archivos.\n",
    "    3. Hace DOBLE CLIC en el archivo 'seminario.Rproj'.\n",
    "    4. Volve a abrir este script y aprieta Source de nuevo.\n\n",
    "  (No uses setwd(): el proyecto ya se encarga de esto.)\n",
    "  ------------------------------------------------------------------\n\n",
    call. = FALSE
  )
}

cat("\n[1/3] Estas trabajando en la carpeta correcta.\n")
cat("      Carpeta del proyecto:", getwd(), "\n\n")


# ---- 2. Instalamos los paquetes --------------------------------------------

# Un "paquete" es un conjunto de funciones que alguien programo y publico para
# que otros lo usen. R viene con lo basico; todo lo demas se instala.
# Se instala UNA VEZ por computadora; despues solo se carga con library().

paquetes <- c(
  # -- Manejo de datos y graficos (el corazon del seminario)
  "tidyverse",   # dplyr, ggplot2, tidyr, readr y companiia
  "readxl",      # leer archivos de Excel
  "openxlsx",    # escribir archivos de Excel
  "lubridate",   # trabajar con fechas

  # -- Tablas y presentacion de resultados
  "gt",          # tablas con formato para los informes
  "scales",      # formatos de numeros y ejes (%, miles, $)

  # -- Graficos
  "ggthemes",    # temas visuales para ggplot2
  "ggridges",    # graficos de densidades apiladas
  "plotly",      # graficos interactivos
  "GGally",      # matrices de correlacion y graficos combinados

  # -- Especificos del seminario
  "eph",          # funciones para trabajar con la EPH (INDEC)
  "statar"       # funciones útiles de stata (Ej: constuir percentiles)
)

faltantes <- paquetes[!paquetes %in% rownames(installed.packages())]

if (length(faltantes) == 0) {
  cat("[2/3] Los", length(paquetes), "paquetes ya estaban instalados.\n\n")
} else {
  cat("[2/3] Faltan", length(faltantes), "paquetes. Instalando...\n")
  cat("      (", paste(faltantes, collapse = ", "), ")\n")
  cat("      Esto puede tardar varios minutos. Podes ir a hacerte un cafe.\n\n")

  install.packages(faltantes, repos = "https://cloud.r-project.org")
}


# ---- 3. Verificamos que todo cargue de verdad -------------------------------

# Que un paquete se haya instalado no garantiza que cargue bien.
# Aca los cargamos uno por uno y anotamos cual falla.

cat("[3/3] Verificando que los paquetes carguen...\n\n")

resultado <- sapply(paquetes, function(p) {
  suppressPackageStartupMessages(
    suppressWarnings(
      requireNamespace(p, quietly = TRUE)
    )
  )
})

fallaron <- names(resultado)[!resultado]


# ---- 4. Verificamos que esten las bases de datos ----------------------------

bases_necesarias <- c(
  "bases_eph/usu_individual_T125.txt",
  "bases_eph/usu_hogar_T125.txt",
  "bases_eph/canastas_eph.xlsx",
  "bases_eph/ADEQUI.xlsx",
  "bases_eph/Aglomerados y Regiones EPH.xlsx"
)

bases_faltantes <- bases_necesarias[!file.exists(bases_necesarias)]

# Carpeta donde van a parar los resultados que exportemos (Excel, graficos).
# La creamos ahora para que ninguna exportacion falle por no encontrarla.
if (!dir.exists("Resultados")) dir.create("Resultados")


# ---- 5. Informe final -------------------------------------------------------

cat("\n")
cat("=============================================================\n")

if (length(fallaron) == 0 && length(bases_faltantes) == 0) {

  cat("  TODO LISTO. Ya podes empezar el seminario.\n")
  cat("=============================================================\n\n")
  cat("  R:        ", R.version.string, "\n")
  cat("  Paquetes: ", length(paquetes), "instalados y funcionando\n")
  cat("  Bases:    ", length(bases_necesarias), "encontradas\n\n")
  cat("  Proxima parada: clases/01_intro_r/\n")
  cat("    - Abri el .html en el navegador para leer.\n")
  cat("    - Abri el .R en RStudio para ejecutar.\n\n")

} else {

  cat("  HAY ALGO PARA REVISAR.\n")
  cat("=============================================================\n\n")

  if (length(fallaron) > 0) {
    cat("  Estos paquetes no se pudieron cargar:\n")
    cat("   ", paste(fallaron, collapse = ", "), "\n\n")
    cat("  Que probar:\n")
    cat("    1. Volve a correr este script (a veces alcanza).\n")
    cat("    2. Si sigue fallando, intenta instalarlo a mano:\n")
    cat("         install.packages(\"", fallaron[1], "\")\n", sep = "")
    cat("    3. Si aparece una pregunta sobre 'compile from source',\n")
    cat("       responde 'no' (escribi n y apreta Enter).\n\n")
  }

  if (length(bases_faltantes) > 0) {
    cat("  No se encontraron estas bases de datos:\n")
    for (b in bases_faltantes) cat("    -", b, "\n")
    cat("\n")
    cat("  Casi siempre esto pasa porque el .zip del seminario no se\n")
    cat("  descomprimio del todo. Proba descomprimirlo de nuevo.\n\n")
  }

  cat("  Si no se resuelve, escribinos copiando el texto completo\n")
  cat("  del error. No pierdas tiempo peleandote con esto.\n\n")
}

cat("=============================================================\n\n")
