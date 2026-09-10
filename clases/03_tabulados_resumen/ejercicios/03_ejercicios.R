# =============================================================================
# CLASE 03 -- EJERCICIOS
# Tabulados, medidas de resumen y asociacion bivariada
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

library(tidyverse)
library(eph)

individual_25_t1 <- read.table("bases_eph/usu_individual_T125.txt",
                               sep = ";", dec = ",", header = TRUE, fill = TRUE)

asalariados <- individual_25_t1 %>%
  filter(ESTADO == 1, CAT_OCUP == 3) %>%
  filter(PP07H %in% c(1, 2)) %>%
  mutate(
    registro = factor(
      case_when(PP07H == 1 ~ "Registrado",
                PP07H == 2 ~ "No registrado"),
      levels = c("Registrado", "No registrado")),
    sexo = factor(
      case_when(CH04 == 1 ~ "Varones",
                CH04 == 2 ~ "Mujeres"),
      levels = c("Varones", "Mujeres")))

# La funcion que escribimos en clase. La vas a usar en los tres ejercicios.
coef_asociacion <- function(datos, x, y) {
  tabla <- table(datos[[x]], datos[[y]])
  test  <- chisq.test(tabla, correct = FALSE)
  n     <- sum(tabla)
  tibble(
    n        = n,
    chi2     = round(unname(test$statistic), 1),
    gl       = unname(test$parameter),
    p_valor  = signif(test$p.value, 3),
    v_cramer = round(sqrt(unname(test$statistic) / (n * (min(dim(tabla)) - 1))), 3))
}


# ---- Ejercicio 1: una tabla que no es 2x2 -----------------------------------
#
# Construi la variable "nivel_ed" con tres categorias, usando NIVEL_ED:
#     7, 1, 2, 3  -> "Hasta secundaria inc."
#     4, 5        -> "Secundaria completa"
#     6           -> "Superior completo"
#     resto       -> "Ns/Nr"   (filtralo despues)
#
# a) Hace el tabulado de nivel_ed por registro, con porcentajes por columna.
# b) Calcula los coeficientes con coef_asociacion().
# c) Preguntas para pensar:
#      - La tabla es de 3x2. Se podria calcular Phi? Por que?
#      - Compara esta V de Cramer con la de sexo (0,029). Cual de las dos
#        variables ordena mejor quien esta registrado y quien no?
#      - Las dos dan p < 0,001. Sirve el p-valor para responder la pregunta
#        anterior?

# ESCRIBI TU CODIGO ACA



# ---- Ejercicio 2: controlar no siempre destruye la asociacion ---------------
#
# Construi la variable "jornada":
#     PP3E_TOT menor a 35 y mayor a 0  -> "Parcial"
#     el resto                          -> "Completa"
#
# a) Calcula la asociacion entre jornada y registro para el total.
# b) Ahora repeti el calculo por separado para varones y mujeres, usando
#    group_by() + group_modify(), como hicimos en clase.
# c) Preguntas para pensar:
#      - La asociacion desaparece dentro de cada grupo? Se debilita mucho?
#      - Entonces: la relacion entre jornada y registro, es espuria?
#      - En que grupo la asociacion es mas intensa?

# ESCRIBI TU CODIGO ACA



# ---- Ejercicio 3: la brecha de genero, otra vez -----------------------------
#
# En clase controlamos la relacion sexo-registro por grupo etario y vimos que
# la brecha crecia con la edad. Ahora controlala por nivel educativo (la
# variable que construiste en el Ejercicio 1).
#
# a) Calcula, dentro de cada nivel educativo, la tasa de no registro de varones
#    y de mujeres, y la brecha en puntos porcentuales.
# b) Agrega los coeficientes con group_modify().
# c) Preguntas para pensar:
#      - Cuanto daba la brecha total? Cuanto da dentro de cada nivel educativo?
#      - Ojo con esto: la brecha dentro de CADA nivel es mas grande que la
#        brecha total. Como puede ser? (Pista: pensa que nivel educativo tienen,
#        en promedio, las asalariadas mujeres comparadas con los varones, y como
#        se relaciona el nivel educativo con el registro.)
#      - Este patron, se parece mas al caso de la relacion espuria o al de la
#        interaccion que vimos en clase?

# ESCRIBI TU CODIGO ACA



# =============================================================================
# Si te trabas: volve al .html de la clase, que tiene el codigo comentado.
# Si seguis trabado, anotalo y lo vemos en la clase siguiente. Trabarse es
# informacion util para nosotros.
# =============================================================================
