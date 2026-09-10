# =============================================================================
# CLASE 03 -- EJERCICIOS RESUELTOS
# Tabulados, medidas de resumen y asociacion bivariada
#
# USO DOCENTE. No se entrega junto con la consigna: se libera despues de la
# clase (ver la lista NO_ENTREGAR en _docente/armar_zip.R).
#
# Los valores de referencia corresponden a la EPH, 1er trimestre 2025.
# =============================================================================

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


# ---- Ejercicio 1 ------------------------------------------------------------

asalariados <- asalariados %>%
  mutate(nivel_ed = factor(
    case_when(NIVEL_ED %in% c(7, 1, 2, 3) ~ "Hasta secundaria inc.",
              NIVEL_ED %in% c(4, 5)       ~ "Secundaria completa",
              NIVEL_ED == 6               ~ "Superior completo",
              TRUE                        ~ "Ns/Nr"),
    levels = c("Hasta secundaria inc.", "Secundaria completa",
               "Superior completo", "Ns/Nr")))

base_ed <- asalariados %>% filter(nivel_ed != "Ns/Nr") %>% droplevels()

# a)
calculate_tabulates(base = base_ed, x = "registro", y = "nivel_ed",
                    weights = "PONDERA", add.percentage = "col")
# Tasas de no registro:  57,7%  /  35,8%  /  15,8%

# b)
coef_asociacion(base_ed, "nivel_ed", "registro")
# n = 14.627 | chi2 = 1540,5 | gl = 2 | p ~ 0 | V = 0,325

# c) Respuestas:
#    - Phi NO aplica: solo esta definida para tablas 2x2. Fuera de ahi puede
#      superar 1 y deja de ser interpretable. Por eso existe la V de Cramer,
#      que divide ademas por min(filas-1, columnas-1) y siempre queda entre 0 y 1.
#    - V = 0,325 (asociacion moderada) contra V = 0,029 para sexo: el nivel
#      educativo ordena MUCHISIMO mejor quien esta registrado. Casi 11 veces mas.
#    - No. Las dos dan p < 0,001, con lo cual el p-valor no distingue entre una
#      asociacion despreciable y una moderada. El p-valor responde "existe?",
#      no "cuanta?". Este es el punto central de la clase.


# ---- Ejercicio 2 ------------------------------------------------------------

asalariados <- asalariados %>%
  mutate(jornada = factor(
    case_when(PP3E_TOT < 35 & PP3E_TOT > 0 ~ "Parcial",
              TRUE                          ~ "Completa"),
    levels = c("Completa", "Parcial")))

# a)
coef_asociacion(asalariados, "jornada", "registro")
# n = 14.627 | chi2 = 664,1 | V = 0,213
# Tasas de no registro: jornada completa 28,8% / jornada parcial 51,3%

# b)
asalariados %>%
  group_by(sexo) %>%
  group_modify(~ coef_asociacion(.x, "jornada", "registro")) %>%
  ungroup()
# Mujeres: n = 6.732 | V = 0,248
# Varones: n = 7.895 | V = 0,178

# c) Respuestas:
#    - No desaparece: dentro de cada sexo la V sigue siendo del mismo orden que
#      la global (0,213). En mujeres incluso sube.
#    - Por lo tanto NO es espuria. El sexo no explica la relacion entre jornada
#      y registro: la relacion se sostiene por si sola dentro de cada grupo.
#      Moraleja: controlar no siempre "rompe" una asociacion. Cuando sobrevive,
#      el control es evidencia A FAVOR de que la relacion es propia.
#    - Es algo mas intensa entre las mujeres (0,248 vs 0,178). Hay una
#      interaccion, pero suave: no cambia el signo ni el orden de magnitud.


# ---- Ejercicio 3 ------------------------------------------------------------

# a)
brechas_ed <- base_ed %>%
  group_by(nivel_ed, sexo) %>%
  summarise(tasa_no_registro = weighted.mean(registro == "No registrado", PONDERA) * 100,
            .groups = "drop") %>%
  pivot_wider(names_from = sexo, values_from = tasa_no_registro) %>%
  mutate(brecha_pp = round(Mujeres - Varones, 1))

# b)
coef_ed <- base_ed %>%
  group_by(nivel_ed) %>%
  group_modify(~ coef_asociacion(.x, "sexo", "registro")) %>%
  ungroup()

brechas_ed %>% left_join(coef_ed, by = "nivel_ed")

#   nivel_ed                Varones  Mujeres  brecha_pp      p      V
#   Hasta secundaria inc.      54,7     63,3      +8,6    1e-08  0,092
#   Secundaria completa        30,6     42,2     +11,6    3e-25  0,124
#   Superior completo          15,5     16,1      +0,5    0,027  0,036
#
#   (recordar: la brecha TOTAL era de solo +2,7 pp)

# c) Respuestas:
#    - La brecha total es +2,7 pp, pero dentro de los dos primeros niveles
#      educativos es de +8,6 y +11,6 pp. Es decir: la brecha total es MENOR que
#      la brecha de casi todos los subgrupos.
#    - Como puede ser? Porque las asalariadas mujeres tienen, en promedio, mas
#      nivel educativo que los varones, y el nivel educativo protege muchisimo
#      del no registro (Ejercicio 1: V = 0,325). Esa ventaja educativa
#      COMPENSA en el agregado la desventaja que sufren dentro de cada nivel.
#      El promedio general esconde la desigualdad en lugar de mostrarla.
#      A este fenomeno se lo llama efecto de supresion, y es primo hermano de
#      la paradoja de Simpson que vimos en clase.
#    - Se parece al caso de la INTERACCION: la asociacion no desaparece al
#      controlar (al contrario, se agranda) y ademas cambia de intensidad segun
#      el grupo, siendo casi nula entre quienes tienen estudios superiores.
#
#    Cierre para discutir en clase: sexo y educacion, cada uno por su lado,
#    llevan a conclusiones opuestas sobre la brecha de genero. Ninguna tabla
#    bivariada, por si sola, alcanza para responder la pregunta.
