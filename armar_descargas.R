# =============================================================================
# armar_descargas.R  --  arma los ZIP que se bajan desde el sitio web
#
# USO DOCENTE. Con el proyecto abierto (seminario.Rproj):
#
#     source("armar_descargas.R")
#
#     armar_zip_clase(2)                         # arma descargas/clase_02.zip
#     armar_zip_clase(2, con_soluciones = TRUE)  # idem, con los _resuelto.R
#     armar_zip_clase(2, publicar = FALSE)       # arma el zip sin tocar la web
#
#     armar_zip_proyecto()                       # arma descargas/seminario.zip
#
# Que lleva el zip de una clase (dentro de una carpeta con el nombre de la
# clase, para descomprimir en seminario/clases):
#   - el/los .html de la clase       (lo que se lee)
#   - el/los .R de la clase          (lo que se corre; si falta, se genera
#                                     a partir del .qmd con knitr::purl)
#   - ejercicios/*.R                 (sin los _resuelto.R, salvo que se pidan)
#
# Con publicar = TRUE (por defecto) ademas habilita el boton de esa clase en
# index.html. Despues queda subir los cambios:
#     git add descargas index.html
#     git commit -m "Clase N"
#     git push
# =============================================================================


armar_zip_clase <- function(n,
                            con_soluciones = FALSE,
                            publicar       = TRUE,
                            destino        = "descargas") {

  .chequear_proyecto()

  nn <- sprintf("%02d", n)

  # ---- 1. Ubicamos la carpeta de la clase ----------------------------------

  carpetas <- list.dirs("clases", recursive = FALSE)
  carpeta  <- carpetas[startsWith(basename(carpetas), paste0(nn, "_"))]

  if (length(carpeta) == 0) {
    stop("No encuentro ninguna carpeta 'clases/", nn, "_...'.", call. = FALSE)
  }
  if (length(carpeta) > 1) {
    stop("Hay mas de una carpeta para la clase ", nn, ":\n  ",
         paste(carpeta, collapse = "\n  "), call. = FALSE)
  }
  nombre <- basename(carpeta)

  # ---- 2. HTML de la clase -------------------------------------------------

  qmds  <- list.files(carpeta, pattern = "\\.qmd$", full.names = TRUE)
  htmls <- list.files(carpeta, pattern = "\\.html$", full.names = TRUE)

  if (length(htmls) == 0) {
    stop("No hay ningun .html en ", carpeta, ".\n",
         "  Renderizalo antes con:  quarto render ",
         if (length(qmds) > 0) qmds[1] else carpeta, call. = FALSE)
  }

  # Aviso si el .qmd se modifico despues de renderizar el .html
  for (q in qmds) {
    h <- sub("\\.qmd$", ".html", q)
    if (file.exists(h) && file.mtime(q) > file.mtime(h)) {
      warning("El .qmd es mas nuevo que su .html: ", basename(q),
              "\n  Quizas convenga volver a renderizarlo.", call. = FALSE)
    }
  }

  # ---- 3. Script .R de la clase --------------------------------------------

  # Si falta el .R de un .qmd, lo generamos (solo el codigo, con los
  # titulos de seccion como comentarios). Nunca pisamos un .R existente.
  for (q in qmds) {
    r <- sub("\\.qmd$", ".R", q)
    if (!file.exists(r)) {
      if (!requireNamespace("knitr", quietly = TRUE)) install.packages("knitr")
      knitr::purl(q, output = r, documentation = 1, quiet = TRUE)
      message("Generado a partir del .qmd: ", r)
    }
  }

  scripts <- list.files(carpeta, pattern = "\\.R$", full.names = TRUE)

  if (length(scripts) == 0) {
    warning("La clase ", nn, " no tiene script .R propio.", call. = FALSE)
  }

  # ---- 4. Ejercicios -------------------------------------------------------

  ejercicios <- list.files(file.path(carpeta, "ejercicios"),
                           pattern = "\\.R$", full.names = TRUE)
  if (!con_soluciones) {
    ejercicios <- ejercicios[!grepl("_resuelto", basename(ejercicios))]
  }

  if (length(ejercicios) == 0) {
    warning("La clase ", nn, " no tiene ejercicios .R.", call. = FALSE)
  }

  # ---- 5. Armamos el zip ---------------------------------------------------

  # Rutas relativas a 'clases/', asi el zip trae la carpeta de la clase
  incluir <- c(file.path(nombre, basename(htmls)),
               file.path(nombre, basename(scripts)),
               file.path(nombre, "ejercicios", basename(ejercicios)))

  archivo <- sprintf("clase_%s.zip", nn)
  .zipear(incluir, root = "clases", destino = destino, archivo = archivo)

  # ---- 6. Habilitamos el boton en la web -----------------------------------

  if (publicar) .habilitar_en_web(n)

  invisible(file.path(destino, archivo))
}


armar_zip_proyecto <- function(destino = "descargas") {

  .chequear_proyecto()

  # Armamos la carpeta 'seminario' en un temporal, con la estructura que
  # tiene que encontrar el estudiante al descomprimir.
  tmp <- file.path(tempdir(), "armado_proyecto")
  unlink(tmp, recursive = TRUE)
  base <- file.path(tmp, "seminario")
  dir.create(file.path(base, "clases"),     recursive = TRUE)
  dir.create(file.path(base, "Resultados"), recursive = TRUE)
  file.create(file.path(base, "clases",     ".gitkeep"))
  file.create(file.path(base, "Resultados", ".gitkeep"))

  file.copy(c("seminario.Rproj", "00_setup.R"), base)
  file.copy("bases_eph", base, recursive = TRUE)

  incluir <- list.files(tmp, recursive = TRUE, all.files = TRUE)
  .zipear(incluir, root = tmp, destino = destino, archivo = "seminario.zip")

  unlink(tmp, recursive = TRUE)
  invisible(file.path(destino, "seminario.zip"))
}


# ---- Funciones auxiliares (no hace falta llamarlas) -------------------------

.chequear_proyecto <- function() {
  if (!file.exists("seminario.Rproj")) {
    stop("Corre esto con el proyecto abierto (doble clic en seminario.Rproj).",
         call. = FALSE)
  }
  if (!requireNamespace("zip", quietly = TRUE)) install.packages("zip")
}

.zipear <- function(incluir, root, destino, archivo) {
  dir.create(destino, showWarnings = FALSE)
  salida <- file.path(normalizePath(destino), archivo)
  unlink(salida)

  zip::zip(zipfile = salida, files = incluir, root = root)

  cat("\nListo:", file.path(destino, archivo),
      sprintf("(%.1f MB)\n", file.size(salida) / 1024^2))
  cat(paste0("  ", incluir, collapse = "\n"), "\n\n")
}

.habilitar_en_web <- function(n) {
  if (!file.exists("index.html")) {
    warning("No encuentro index.html: no habilite el boton.", call. = FALSE)
    return(invisible())
  }
  html <- readLines("index.html", encoding = "UTF-8", warn = FALSE)
  i <- grep(sprintf("\\{ n: %d,", n), html)

  if (length(i) != 1) {
    warning("No encuentro la clase ", n, " en la lista CLASES de index.html.",
            call. = FALSE)
  } else if (grepl("disponible: true", html[i])) {
    cat("La clase", n, "ya estaba habilitada en index.html.\n")
  } else {
    html[i] <- sub("disponible: false", "disponible: true ", html[i])
    writeLines(html, "index.html", useBytes = TRUE)
    cat("Boton de la clase", n, "habilitado en index.html.\n")
  }
}
