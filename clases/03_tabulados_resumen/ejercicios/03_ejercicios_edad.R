# =============================================================================
# CLASE 03 -- EJERCICIOS  (version "grupos etarios")
# Tabulados, medidas de resumen y asociacion bivariada
#
# ANTES DE EMPEZAR:
#   Abri el proyecto con doble clic en "seminario.Rproj".
#   Si no lo hiciste, R no va a encontrar las bases y todo va a fallar.
#
# COMO TRABAJAR:
#   Para el cursor en una linea y apreta Ctrl + Enter (Cmd + Enter en Mac).
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
  filter(between(CH06, 14, 60)) %>%
  mutate(
    registro = factor(
      case_when(PP07H == 1 ~ "Registrado",
                PP07H == 2 ~ "No registrado"),
      levels = c("Registrado", "No registrado")),
    grupo_edad = factor(
      case_when(CH06 <= 35 ~ "14 a 35",
                CH06 >  35 ~ "36 a 60"),
      levels = c("14 a 35", "36 a 60")),
    nivel_ed = factor(
      case_when(NIVEL_ED %in% c(7, 1, 2, 3) ~ "Hasta secundaria inc.",
                NIVEL_ED %in% c(4, 5)       ~ "Secundaria completa",
                NIVEL_ED == 6               ~ "Superior completo",
                TRUE                        ~ "Ns/Nr"),
      levels = c("Hasta secundaria inc.", "Secundaria completa",
                 "Superior completo", "Ns/Nr")),
    estado_civil = factor(
      case_when(CH07 %in% c(1, 2)    ~ "Unido/Casado",
                CH07 %in% c(3, 4, 5) ~ "Soltero/Viudo/Separado",
                TRUE                 ~ "Ns/Nr"),
      levels = c("Unido/Casado", "Soltero/Viudo/Separado", "Ns/Nr")))

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
# a) Hace el tabulado de nivel_ed por registro con porcentajes por columna
#    (acordate de filtrar la categoria "Ns/Nr").
# b) Calcula los coeficientes con coef_asociacion().
# c) Preguntas para pensar:
#      - La tabla es de 3x2. Se podria calcular Phi? Por que?
#      - Compara esta V de Cramer con la de grupo_edad (0,226). Cual de las dos
#        variables ordena mejor quien esta registrado y quien no?
#      - Las dos dan p practicamente igual a cero. Sirve el p-valor para
#        responder la pregunta anterior?

# ESCRIBI TU CODIGO ACA



# ---- Ejercicio 2: otro control para la misma hipotesis ----------------------
#
# En clase pusimos a prueba si la relacion entre estado civil y registro era
# espuria, controlando por grupo etario. No lo era: se atenuaba pero sobrevivia.
#
# Probemos ahora con OTRO control: el nivel educativo. Quizas las personas
# solteras tengan menos credenciales educativas, y eso explique la brecha.
#
# a) Calcula la asociacion entre estado_civil y registro para el total.
# b) Repetila dentro de cada nivel educativo con group_by() + group_modify().
# c) Calcula tambien las tasas de no registro de cada grupo, con pivot_wider(),
#    para poder ver el sentido y el tamano de la brecha.
# d) Preguntas para pensar:
#      - La asociacion desaparece dentro de algun nivel educativo?
#      - En cual es mas intensa? En cual mas debil?
#      - Con dos controles distintos (edad y educacion) la relacion sobrevivio
#        siempre. Que fuerza tiene esa evidencia? Alcanza para decir que la
#        relacion es causal?

# ESCRIBI TU CODIGO ACA



# ---- Ejercicio 3: ahora si, una relacion espuria -----------------------------
#
# En clase no encontramos ninguna. Vamos a buscar una a proposito.
#
# Construi dos variables nuevas:
#     sexo       -> CH04: 1 = "Varones", 2 = "Mujeres"
#     ocupacion  -> PP04B1 == 1 -> "Servicio domestico", si no "Resto"
#
# a) Calcula la asociacion entre sexo y registro para el total de asalariados.
#    Vas a ver que da significativa, aunque con una V muy chica.
# b) Antes de controlar, verifica las dos condiciones de la espuriedad:
#      - El servicio domestico, esta asociado con el sexo?
#      - El servicio domestico, esta asociado con el registro?
# c) Ahora controla: repeti el analisis sexo-registro por separado dentro del
#    servicio domestico y dentro del resto de los asalariados.
# d) Preguntas para pensar:
#      - Que le paso a la brecha dentro de cada grupo? Mira el SIGNO, no solo
#        el tamano.
#      - Compara este resultado con el del estado civil que vimos en clase.
#        En que se diferencian los dos patrones?
#      - Si solo hubieras mirado la tabla bivariada, que habrias concluido
#        sobre la situacion de las mujeres asalariadas?

# ESCRIBI TU CODIGO ACA



# =============================================================================
# Si te trabas: volve al .html de la clase, que tiene el codigo comentado.
# Si seguis trabado, anotalo y lo vemos en la clase siguiente. Trabarse es
# informacion util para nosotros.
# =============================================================================
