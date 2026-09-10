# =============================================================================
# chequear_rutas.R  --  control de integridad de los materiales
#
# Busca en todos los .qmd de clases/ las rutas de archivo que aparecen entre
# comillas y avisa cuales NO existen. Es la red de seguridad contra el error
# mas comun y mas caro: que en clase un script no encuentre una base.
#
# Se corre desde la raiz del proyecto:   source("_docente/chequear_rutas.R")
# =============================================================================

stopifnot(file.exists("seminario.Rproj"))

qmds <- list.files("clases", pattern = "\\.qmd$", recursive = TRUE,
                   full.names = TRUE)
scripts <- list.files("clases", pattern = "\\.R$", recursive = TRUE,
                      full.names = TRUE)
archivos <- c(qmds, scripts)

# Extensiones que nos interesan (datos, imagenes, estilos)
ext <- "txt|csv|xlsx|xls|rds|dta|sav|png|jpg|jpeg|JPG|svg|scss|html|js"

# 1) rutas entre comillas, dentro del codigo:      read_csv("bases_eph/x.txt")
patron_codigo <- paste0('"([^"]+\\.(', ext, '))"')

# 2) imagenes en sintaxis markdown:                 ![pie](img/x.png)
patron_imagen <- "!\\[[^]]*\\]\\(([^)]+?)(\\{[^}]*\\})?\\)"

problemas <- list()

for (f in archivos) {
  lineas <- readLines(f, warn = FALSE, encoding = "UTF-8")
  for (i in seq_along(lineas)) {
    citas <- character(0)

    # rutas en el codigo (salvo las lineas que ESCRIBEN un archivo)
    if (!grepl("write|ggsave|dir\\.create|file\\.exists|^\\s*file\\s*=|filename", lineas[i])) {
      m <- regmatches(lineas[i], gregexpr(patron_codigo, lineas[i], perl = TRUE))[[1]]
      citas <- c(citas, gsub('^"|"$', "", m))
    }

    # imagenes en markdown
    mi <- regmatches(lineas[i], regexec(patron_imagen, lineas[i], perl = TRUE))[[1]]
    if (length(mi) >= 2) citas <- c(citas, trimws(mi[2]))

    for (ruta in citas) {
      if (grepl("^https?://", ruta)) next
      if (nchar(ruta) == 0) next
      if (!file.exists(ruta)) {
        problemas[[length(problemas) + 1]] <- data.frame(
          archivo = f, linea = i, ruta = ruta, stringsAsFactors = FALSE
        )
      }
    }
  }
}

cat("\n=============================================================\n")
if (length(problemas) == 0) {
  cat("  Todas las rutas resuelven. Los materiales estan sanos.\n")
} else {
  res <- do.call(rbind, problemas)
  cat("  RUTAS QUE NO EXISTEN:", nrow(res), "\n")
  cat("=============================================================\n\n")
  for (i in seq_len(nrow(res))) {
    cat(sprintf("  %s:%d\n    -> %s\n\n", res$archivo[i], res$linea[i], res$ruta[i]))
  }
  cat("  Recorda: las rutas son relativas a la RAIZ del proyecto\n")
  cat("  (por 'execute-dir: project' en _quarto.yml), no a la carpeta\n")
  cat("  donde esta el .qmd.\n")
}
cat("=============================================================\n\n")
