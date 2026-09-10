# =============================================================================
# CLASE 01 -- EJERCICIOS
# Introducción a la programación en R
#
# ANTES DE EMPEZAR:
#   Abri el proyecto con doble clic en "seminario.Rproj".
#   Si no lo hiciste, R no va a encontrar las bases y todo va a fallar.
#
# COMO TRABAJAR:
#   Para el cursor en una linea y apreta Ctrl + Enter (Cmd + Enter en Mac).
#   Se ejecuta esa linea y el cursor pasa a la siguiente.
#   Los errores son parte del proceso: leelos, casi siempre dicen que pasa.
# =============================================================================


# ---- Preparacion ------------------------------------------------------------
# Cargar la base Individual del 1er trimestre de 2025 de la EPH. Con el paquete “eph” pueden hacerlo así de sencillo


library(tidyverse)
library(eph)
baset117 <- get_microdata(year = 2025,trimester = 1)

# ---- Ejercicio 1 ------------------------------------------------------------
#
# Utilizando el métodos de acceso [], crear un objeto llamado base_estado que tome solo las variables "PONDERA", "CH04","CH06","ESTADO" y"CAT_OCUP"


# ESCRIBI TU CODIGO ACA



# ---- Ejercicio 2 ------------------------------------------------------------
#
# A partir del objeto previo creen un objeto que conserve sólo los primeros 100 casos.


# ESCRIBI TU CODIGO ACA


# ---- Ejercicio 3 ------------------------------------------------------------
#
# Corré la función summary() sobre el objeto base_estado. ¿Algo te llama la atención? 
#

# ESCRIBI TU CODIGO ACA


# ---- Ejercicio 4 ------------------------------------------------------------
#
# Aplicá la función sum() sobre la variable PONDERA de la base_estado. ¿Qué representa el resultado?
#

# ESCRIBI TU CODIGO ACA



# =============================================================================
# Si te trabas: volve al .html de la clase, que tiene el codigo comentado.
# Si seguis trabado, anotalo y lo vemos en la clase siguiente. Trabarse es
# informacion util para nosotros.
# =============================================================================
