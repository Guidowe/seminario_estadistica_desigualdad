# =============================================================================
# CLASE 07 -- EJERCICIOS
# Pobreza multidimensional: NBI y metodo combinado
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
#   Estos ejercicios usan los objetos que se crean en el script de la clase
#   (07_pobreza_multidimensional.R): hogares_nbi, personas_nbi,
#   personas_combinado, individuos, hogares_desde_personas, id_hogar.
#   Corre primero ese script completo.
# =============================================================================


# ---- Preparacion ------------------------------------------------------------

library(tidyverse)


# ---- Ejercicio 1 ------------------------------------------------------------
#
# Calcular el % de PERSONAS con NBI (indice final, sin NBI 5) para cada
# region, en el primer y segundo semestre de 2025.
# Pista: la base personas_nbi ya tiene h_nbi, REGION y Anio.Semestre.
#

# ESCRIBI TU CODIGO ACA



# ---- Ejercicio 2 ------------------------------------------------------------
#
# Calcular la matriz del metodo combinado (las cuatro celdas de h_pobreza
# por h_nbi) solo para ninos, ninas y adolescentes de 0 a 17 anios (CH06),
# y compararla con la del total de la poblacion.
# Recorda: cuando hay ingresos de por medio, se pondera con PONDIH.
#

# ESCRIBI TU CODIGO ACA



# ---- Ejercicio 3 (tarea) ----------------------------------------------------
#
# NBI ampliado. Construir una version del indice que:
#   - en el NBI 4 considere a los chicos de 6 a 17 anios que no asisten,
#   - en el NBI 5 considere de bajo nivel educativo a los jefes con
#     NIVEL_ED < 3 (hasta primario completo),
#   - INCLUYA el NBI 5 en el indice final.
# Comparar el % de hogares y de personas con NBI con el indice de la clase.
#

# ESCRIBI TU CODIGO ACA



# ---- Ejercicio 4 (tarea) ----------------------------------------------------
#
# Sensibilidad del indice.
#   a) Recalcular el NBI 3 con el umbral de INDEC (MAS DE 3 personas por
#      cuarto) y ver cuanto cambia el % de hogares con NBI.
#   b) Revisar en el diseno de registro que significa NIVEL_ED == 7,
#      discutir si deberia incluirse en el NBI 5 y recalcular.
#

# ESCRIBI TU CODIGO ACA



# =============================================================================
# Si te trabas: volve al .html de la clase, que tiene el codigo comentado.
# Si seguis trabado, anotalo y lo vemos en la clase siguiente. Trabarse es
# informacion util para nosotros.
# =============================================================================
