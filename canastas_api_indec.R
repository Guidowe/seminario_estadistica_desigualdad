# =============================================================================
# SEMINARIO: Estadistica y programacion para estudios del trabajo,
#            desigualdad y pobreza  (Doctorado en Ciencias Sociales, UBA)
#
#   CANASTAS BASICAS (CBA y CBT) DESDE LA API DEL INDEC
#
# Que hace este script:
#   1. Lee tu token personal de la API del INDEC.
#   2. Descarga la valorizacion mensual de la CBA y la CBT (GBA, desde 2016).
#   3. Arma una tabla ancha con una fila por mes, lista para usar.
#   4. Guarda el resultado en Resultados/canastas_api_indec.xlsx
#
# Fuente: Catalogo API-INDEC, servicio "valorizacion_canastas_cba_cbt"
#   https://api.indec.gob.ar/datasets/valorizacion_canastas_cba_cbt
#   Documentacion: https://api.indec.gob.ar/docs
#
# ANTES DE CORRERLO (una sola vez):
#   a. Crea una cuenta en https://api.indec.gob.ar (Crear cuenta).
#   b. Confirma el mail con el codigo que te mandan.
#   c. En tu perfil, genera el "JWT Token" y copialo.
#      OJO: se muestra una sola vez. Si lo perdes, generas otro.
#   d. En la consola de R corre:   file.edit("~/.Renviron")
#      y agrega esta linea (con tu token, sin comillas):
#           INDEC_TOKEN=eyJhbGciOi...
#      Guarda el archivo y reinicia R (Session > Restart R).
#
#   El token es personal: no lo pegues en el script ni lo subas a GitHub.
# =============================================================================


# ---- 0. Paquetes ------------------------------------------------------------

# httr2 sirve para hablar con APIs. Si no lo tenes, se instala solo.
if (!requireNamespace("httr2", quietly = TRUE)) {
  install.packages("httr2", repos = "https://cloud.r-project.org")
}

library(httr2)
library(tidyverse, warn = FALSE)
library(openxlsx, warn = FALSE)


# ---- 1. Token ---------------------------------------------------------------

#token <- Sys.getenv("INDEC_TOKEN")
token <- "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNDUwMTM2MS0wYTNmLTQzMTYtYmRiMi1mN2JiNzEyNWJiZjciLCJqdGkiOiIzOTM2ZGJlNS02ZjNmLTQzNDEtOWU0MC03MTljYTZmMTg5ZGQiLCJleHAiOjE4MTA2NTEzOTgsImlhdCI6MTc5NTA5OTM5OCwicm9sZSI6ImJhc2ljIn0.33ScWs4goHuH-xEGR1mZEl1bikfb34UbrQvaA0jTW1g"

if (token == "") {
  stop(
    "\n\n",
    "  No encontre tu token de la API del INDEC.\n",
    "  Segui los pasos a-d del encabezado de este script\n",
    "  (y acordate de reiniciar R despues de editar .Renviron).\n\n",
    call. = FALSE
  )
}


# ---- 2. Funcion para descargar una tabla completa de la API ----------------

# La API devuelve como maximo 1000 filas por pedido. Para traer todo hay que
# pedir "paginas": filas 0 a 999, despues 1000 a 1999, y asi.
# Para que las paginas no se pisen, el INDEC pide ordenar por la clave
# completa de la tabla (todas las columnas que identifican una fila).

url_base <- "https://api.indec.gob.ar/v1"

descargar_indec <- function(tabla, clave, filtros = list(), token) {

  filas_por_pagina <- 1000
  offset <- 0
  total  <- Inf
  paginas <- list()

  while (offset < total) {

    resp <- request(url_base) |>
      req_url_path_append(tabla) |>
      req_auth_bearer_token(token) |>
      req_headers(Prefer = "count=exact") |>     # para saber el total de filas
      req_url_query(
        order  = paste(clave, collapse = ","),
        limit  = filas_por_pagina,
        offset = offset,
        !!!filtros
      ) |>
      req_retry(max_tries = 3) |>
      req_error(body = function(resp) {
        # Si algo falla, mostramos el mensaje que devuelve la API
        cuerpo <- tryCatch(resp_body_json(resp), error = function(e) list())
        c(as.character(unlist(cuerpo$message)), as.character(unlist(cuerpo$hint)),
          if (resp_status(resp) == 401) "Revisa tu INDEC_TOKEN: falta, vencio o esta mal copiado.")
      }) |>
      req_perform()

    # El total viene en el header Content-Range, con formato "0-999/1234"
    rango <- resp_header(resp, "Content-Range")
    if (!is.null(rango) && grepl("/", rango)) {
      total <- as.numeric(sub(".*/", "", rango))
    }

    pagina <- resp_body_json(resp, simplifyVector = TRUE)
    if (length(pagina) == 0 || NROW(pagina) == 0) break

    paginas[[length(paginas) + 1]] <- as_tibble(pagina)
    offset <- offset + NROW(pagina)

    cat("  Descargadas", offset, "de", total, "filas\n")

    if (NROW(pagina) < filas_por_pagina && !is.finite(total)) break
  }

  bind_rows(paginas)
}


# ---- 3. Descargamos las canastas -------------------------------------------

clave_canastas <- c(
  "clasificador", "nivel", "codigo", "descripcion", "periodo", "anio", "mes",
  "indicador", "tipo_de_indicador", "tipo_de_indicador_descripcion",
  "region", "unidad_de_medida"
)

cat("\nDescargando valorizacion de canastas (CBA y CBT)...\n")

canastas_largo <- descargar_indec(
  tabla = "valorizacion_canastas_cba_cbt",
  clave = clave_canastas,
  token = token
  # Si quisieras traer solo un pedazo, podes filtrar. Por ejemplo,
  # solo desde 2023:  filtros = list(anio = "gte.2023")
)

cat("\nListo:", nrow(canastas_largo), "filas.\n\n")


# ---- 4. Que trae la base? --------------------------------------------------

# La base viene en formato "largo": una fila por mes y por serie.
# Antes de usarla conviene mirar que series hay.

series <- canastas_largo |>
  distinct(codigo, descripcion, indicador, tipo_de_indicador,
           tipo_de_indicador_descripcion, unidad_de_medida, region)

print(series, n = Inf, width = Inf)


# ---- 5. Tabla ancha: una fila por mes --------------------------------------

# Cada serie (combinacion de descripcion + tipo de indicador) pasa a ser una
# columna. Asi queda parecida a la hoja de canastas_eph.xlsx.

canastas_ancho <- canastas_largo |>
  mutate(
    fecha = make_date(anio, mes, 1),
    serie = paste(descripcion, tipo_de_indicador, sep = " | ")
  ) |>
  select(fecha, anio, mes, region, serie, valor) |>
  pivot_wider(names_from = serie, values_from = valor) |>
  arrange(fecha)

print(canastas_ancho)


# ---- 6. Guardamos ----------------------------------------------------------

if (!dir.exists("Resultados")) dir.create("Resultados")

write.xlsx(
  list(ancho = canastas_ancho, largo = canastas_largo, series = series),
  file = "Resultados/canastas_api_indec.xlsx",
  overwrite = TRUE
)

cat("\nGuardado en Resultados/canastas_api_indec.xlsx\n")


# ---- Nota ------------------------------------------------------------------
# Esta serie es la del Gran Buenos Aires (adulto equivalente). Para las otras
# regiones EPH seguimos usando bases_eph/canastas_eph.xlsx, como en la clase 6.
