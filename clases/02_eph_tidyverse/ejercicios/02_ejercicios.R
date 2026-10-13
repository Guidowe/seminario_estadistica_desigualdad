# =============================================================================
# CLASE 02 -- EJERCICIOS
#
# ANTES DE EMPEZAR:
#   Abri el proyecto con doble clic en "seminario.Rproj".
#   Si no lo hiciste, R no va a encontrar las bases y todo va a fallar.
#
# COMO TRABAJAR:
#   Para el cursor en una linea y apreta Ctrl + Enter (Cmd + Enter en Mac).
#   Se ejecuta esa linea y el cursor pasa a la siguiente.
#   Los errores son parte del proceso: leelos, casi siempre dicen que pasa.
#
# Reinicia R antes de empezar (Session > Restart R) para arrancar de cero.
# =============================================================================


# ---- Preparacion ------------------------------------------------------------
#
# Levantar desde la carpeta "bases_eph":
#   - las bases individuales del 1er y del 2do trimestre de 2025
#     (usu_individual_T125.txt y usu_individual_T225.txt)
#   - la hoja "Regiones EPH" del archivo "Aglomerados y Regiones EPH.xlsx"
#
# Pista para el Excel: la tabla empieza en la segunda fila de la hoja.
# Mira los argumentos 'sheet' y 'skip' de readxl::read_excel().
#

library(tidyverse)

# ESCRIBI TU CODIGO ACA



# ---- Ejercicio 1 ------------------------------------------------------------
#
# Calcular para el 1er trimestre de 2025 el conjunto de tasas basicas del
# mercado de trabajo que figuran en el Cuadro 1.1 del informe tecnico
# "Mercado de trabajo. Tasas e indicadores socioeconomicos (EPH)" del INDEC:
#
#   - Tasa de actividad
#   - Tasa de empleo
#   - Tasa de desocupacion
#   - Tasa de ocupados demandantes de empleo
#   - Tasa de subocupacion (y su apertura en demandante / no demandante)
#
# Variables utiles: ESTADO, INTENSI, PP03J, PONDERA.
#

# ESCRIBI TU CODIGO ACA



# ---- Ejercicio 2 ------------------------------------------------------------
#
# Calcular las mismas tasas basicas del 1er trimestre de 2025 para cada una
# de las regiones EPH. El resultado tiene que mostrar el NOMBRE de la region,
# no solo su codigo (usa la tabla de regiones que levantaste al principio).
#




# ---- Ejercicio 3 ------------------------------------------------------------
#
# Calcular las tasas basicas del 1er trimestre de 2025 para cada region EPH,
# desagregadas por sexo (CH04). Mostrar el nombre de la region y el sexo
# como texto ("Varon" / "Mujer"), no como codigo.
#




# ---- Ejercicio 4 ------------------------------------------------------------
#
# Calcular, al mismo tiempo para los dos trimestres (1er y 2do trimestre de
# 2025), las tasas de actividad, empleo y desocupacion segun sexo, para la
# poblacion de 18 a 35 anios.
#
# Pista: explora la funcion bind_rows() para unir las dos bases en una sola.
#   ?bind_rows
# Recomendacion: antes de unirlas, quedate solo con las variables necesarias.
#




# ---- Ejercicio 5 ------------------------------------------------------------
#
# Calcular para el 1er trimestre de 2025 el salario promedio (P21) por sexo,
# para dos grupos de edad: 18 a 35 anios y 36 a 70 anios.
#
# Recordatorio: la base tiene que quedar filtrada a OCUPADOS ASALARIADOS
# (ESTADO == 1 y CAT_OCUP == 3).
# Ojo con el ponderador: para la ocupacion principal (P21) se usa PONDIIO.
#




# ---- Ejercicio 6 ------------------------------------------------------------
#
# Exportar algunos de los resultados anteriores a un archivo de Excel en la
# carpeta "Resultados".
#
# Pista: openxlsx::write.xlsx() acepta una lista de tablas y pone cada una
# en una hoja distinta.



