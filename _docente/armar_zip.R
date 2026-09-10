# =============================================================================
# armar_zip.R  --  arma el paquete que se entrega a los estudiantes
#
# USO DOCENTE. Desde la raiz del proyecto:
#
#     source("_docente/armar_zip.R")
#     armar_zip()                          # sin soluciones (lo normal)
#     armar_zip(con_soluciones = TRUE)     # despues de la clase
#     armar_zip(hasta_clase = 3)           # entrega parcial
#
# Deja el resultado en:  entrega/seminario_YYYY-MM-DD.zip
#
# QUE NO VA EN EL ZIP:
#   - los .qmd fuente        (son la cocina, no el plato)
#   - la carpeta _docente/   (idem)
#   - las soluciones         (salvo que las pidas explicitamente)
#   - las carpetas viejas    (Practica 1 a 4, VER_EJERCICIOS_Y_BORRAR)
#   - .git, .Rproj.user, _freeze, .Rhistory
# =============================================================================

armar_zip <- function(con_soluciones = FALSE,
                      hasta_clase    = 8,
                      salida         = "entrega") {

  if (!file.exists("seminario.Rproj")) {
    stop("Corre esto desde la raiz del proyecto.", call. = FALSE)
  }

  # ---- 1. Que se lleva --------------------------------------------------

  incluir <- c("seminario.Rproj", "00_setup.R", "README.md",
               "bases_eph", "img", "assets", "Resultados")

  incluir <- incluir[file.exists(incluir)]

  clases <- list.dirs("clases", recursive = FALSE)
  numeros <- suppressWarnings(as.integer(substr(basename(clases), 1, 2)))
  clases <- clases[!is.na(numeros) & numeros <= hasta_clase]

  if (length(clases) == 0) {
    stop("No hay clases para incluir (revisa 'hasta_clase').", call. = FALSE)
  }

  # ---- 2. Copiamos a una carpeta temporal -------------------------------

  tmp <- file.path(tempdir(), "seminario")
  unlink(tmp, recursive = TRUE)
  dir.create(tmp, recursive = TRUE)

  for (x in incluir) {
    file.copy(x, tmp, recursive = TRUE)
  }

  dir.create(file.path(tmp, "clases"))
  for (cl in clases) {
    file.copy(cl, file.path(tmp, "clases"), recursive = TRUE)
  }

  # ---- 3. Sacamos lo que no se entrega ----------------------------------

  # Las fuentes .qmd: el estudiante recibe el .html y el .R, no la cocina.
  file.remove(list.files(tmp, pattern = "\\.qmd$",
                         recursive = TRUE, full.names = TRUE))

  # Los archivos de trabajo de Quarto
  unlink(list.files(tmp, pattern = "_files$", include.dirs = TRUE,
                    recursive = TRUE, full.names = TRUE), recursive = TRUE)
  unlink(file.path(tmp, "clases", "_freeze"), recursive = TRUE)

  # Las soluciones, salvo pedido expreso
  if (!con_soluciones) {
    sol <- list.files(tmp, pattern = "_resuelto\\.R$",
                      recursive = TRUE, full.names = TRUE)
    file.remove(sol)
  }

  # ---- 4. Control: no falte el material principal ------------------------

  faltan <- character(0)
  for (cl in basename(clases)) {
    html <- file.path(tmp, "clases", cl, paste0(cl, ".html"))
    scr  <- file.path(tmp, "clases", cl, paste0(cl, ".R"))
    if (!file.exists(html)) faltan <- c(faltan, paste0(cl, "/", cl, ".html"))
    if (!file.exists(scr))  faltan <- c(faltan, paste0(cl, "/", cl, ".R"))
  }

  if (length(faltan) > 0) {
    cat("\n  ATENCION: faltan materiales generados:\n")
    for (f in faltan) cat("    -", f, "\n")
    cat("\n  Corre primero:  source('_docente/build.R')\n\n")
  }

  # ---- 5. Comprimimos ----------------------------------------------------

  if (!dir.exists(salida)) dir.create(salida)
  zip_final <- normalizePath(
    file.path(salida, sprintf("seminario_%s.zip", Sys.Date())),
    mustWork = FALSE
  )
  if (file.exists(zip_final)) file.remove(zip_final)

  wd <- setwd(dirname(tmp))
  on.exit(setwd(wd), add = TRUE)
  utils::zip(zip_final, "seminario", flags = "-r9Xq")
  setwd(wd)

  peso <- round(file.size(zip_final) / 1024^2, 1)

  cat("\n=============================================================\n")
  cat("  Zip listo\n")
  cat("=============================================================\n")
  cat("  Archivo:      ", zip_final, "\n")
  cat("  Peso:         ", peso, "MB\n")
  cat("  Clases:       ", length(clases), "(hasta la", hasta_clase, ")\n")
  cat("  Soluciones:   ", if (con_soluciones) "SI (revisa que sea a proposito)"
                          else "no", "\n")
  cat("=============================================================\n\n")

  if (peso > 100) {
    cat("  El zip pesa mas de 100 MB. Conviene subirlo a Drive y compartir\n")
    cat("  el link, en vez de mandarlo por mail.\n\n")
  }

  invisible(zip_final)
}
