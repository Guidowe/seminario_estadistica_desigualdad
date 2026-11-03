# =============================================================================
# CLASE 07 -- EJERCICIOS
# Pobreza multidimensional
#
# ANTES DE EMPEZAR:
#   Abri el proyecto con doble clic en "seminario.Rproj".
#   Si no lo hiciste, R no va a encontrar las bases y todo va a fallar.
#
#   Estos ejercicios parten de la base "base_md" que construimos en la clase.
#   Corre primero el codigo de la clase (07_pobreza_multidimensional) hasta
#   la seccion "Pobreza multidimensional y pobreza por ingresos" inclusive.
#
# COMO TRABAJAR:
#   Para el cursor en una linea y apreta Ctrl + Enter (Cmd + Enter en Mac).
#   Se ejecuta esa linea y el cursor pasa a la siguiente.
#   Los errores son parte del proceso: leelos, casi siempre dicen que pasa.
# =============================================================================


# ---- Preparacion ------------------------------------------------------------

library(tidyverse)
library(openxlsx)


# ---- Ejercicio 1 ------------------------------------------------------------
#
# Calcular la incidencia de la pobreza multidimensional (umbral total y
# severo) para varones y mujeres (CH04), en cada semestre de 2025.
#

# ESCRIBI TU CODIGO ACA



# ---- Ejercicio 2 ------------------------------------------------------------
#
# Rehacer la dimension educacion SIN el criterio de cohorte: exigir
# secundario completo a todas las personas de 18 anios y mas.
# Recalcular la incidencia total por grupo de edad y compararla con la
# de la clase. ¿Que grupo de edad cambia mas? ¿Por que?
#
# Pista: crea una nueva variable (por ejemplo "edu_total_sin_cohorte"),
# recalcula la cantidad de privaciones y el indicador de pobreza.
#

# ESCRIBI TU CODIGO ACA



# ---- Ejercicio 3 ------------------------------------------------------------
#
# Construir la tipologia de Katzman usando el UMBRAL TOTAL de pobreza
# multidimensional (en lugar del severo). ¿Que grupo cambia mas?
#

# ESCRIBI TU CODIGO ACA



# =============================================================================
# Si te trabas: volve al .html de la clase, que tiene el codigo comentado.
# Si seguis trabado, anotalo y lo vemos en la clase siguiente. Trabarse es
# informacion util para nosotros.
# =============================================================================
