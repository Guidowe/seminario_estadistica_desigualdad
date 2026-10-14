# =============================================================================
# CLASE 03 -- EJERCICIOS RESUELTOS  (version "grupos etarios")
#
# USO DOCENTE. No se entrega junto con la consigna: armar_zip.R excluye
# automaticamente todo archivo terminado en "_resuelto.R".
#
# Valores de referencia: EPH, 1er trimestre 2025.
# Universo: asalariados de 14 a 60 anios con PP07H valido (n = 13.795).
# =============================================================================

library(tidyverse)
library(eph)

# (misma preparacion que en la consigna: base, variables y coef_asociacion)
source_preparacion <- "ver 03_ejercicios_edad.R, bloque Preparacion"


# ---- Ejercicio 1 ------------------------------------------------------------

base_ed <- asalariados %>% filter(nivel_ed != "Ns/Nr") %>% droplevels()

# a)
calculate_tabulates(base = base_ed, x = "registro", y = "nivel_ed",
                    weights = "PONDERA", add.percentage = "col")
# Tasas de no registro:  57,4%  /  35,9%  /  15,2%

# b)
coef_asociacion(base_ed, "nivel_ed", "registro")
# n = 13.795 | chi2 = 1499,9 | gl = 2 | p ~ 0 | V = 0,330

# c) Respuestas:
#    - Phi NO aplica: solo esta definida para tablas 2x2. Fuera de ahi puede
#      superar 1 y deja de ser interpretable. Por eso existe la V de Cramer,
#      que divide ademas por min(filas-1, columnas-1) y siempre queda entre 0 y 1.
#    - V = 0,330 contra V = 0,226 de grupo_edad: el nivel educativo ordena
#      mejor el registro que la edad. Las dos son asociaciones sustantivas
#      (moderadas), pero la educativa es claramente mas fuerte.
#    - No. Las dos dan p ~ 0. El p-valor no distingue entre una asociacion
#      moderada y una fuerte: responde "existe?", no "cuanta?".


# ---- Ejercicio 2 ------------------------------------------------------------

base_ec <- asalariados %>% filter(estado_civil != "Ns/Nr") %>% droplevels()
base_ec_ed <- base_ec %>% filter(nivel_ed != "Ns/Nr") %>% droplevels()

# a)
coef_asociacion(base_ec, "estado_civil", "registro")
# n = 13.795 | chi2 = 467,8 | V = 0,184
# Tasas: solteros/viudos/separados 44,5% | unidos/casados 28,6%

# b)
coef_por_educ <- base_ec_ed %>%
  group_by(nivel_ed) %>%
  group_modify(~ coef_asociacion(.x, "estado_civil", "registro")) %>%
  ungroup()

# c)
brechas_educ <- base_ec_ed %>%
  group_by(nivel_ed, estado_civil) %>%
  summarise(tasa_no_registro = weighted.mean(registro == "No registrado", PONDERA) * 100,
            .groups = "drop") %>%
  pivot_wider(names_from = estado_civil, values_from = tasa_no_registro) %>%
  rename(solteros = `Soltero/Viudo/Separado`, unidos = `Unido/Casado`) %>%
  mutate(brecha_pp = round(solteros - unidos, 1))

brechas_educ %>% left_join(coef_por_educ, by = "nivel_ed")

#   nivel_ed                unidos  solteros  brecha_pp      p        V
#   Hasta secundaria inc.     49,1      67,6     +18,5    1,5e-28  0,186
#   Secundaria completa       27,6      43,5     +15,9    1,9e-65  0,208
#   Superior completo         12,4      19,8      +7,4    8,9e-10  0,103
#   (la V global era 0,184)

# d) Respuestas:
#    - No desaparece en ninguno. Incluso en secundaria completa es algo MAS
#      intensa que en el total (0,208 vs 0,184).
#    - Mas intensa en secundaria completa; mas debil entre quienes tienen
#      estudios superiores (0,103), donde ademas las tasas son bajas para todos.
#      Notar que aparece el mismo patron que vimos en clase con la edad: la
#      credencial universitaria amortigua las desigualdades.
#    - Es evidencia razonablemente fuerte de que la relacion NO es espuria por
#      esas dos vias. Pero NO alcanza para afirmar causalidad: siempre puede
#      existir una cuarta variable no observada. Controlar descarta
#      explicaciones alternativas de a una; nunca las descarta todas.


# ---- Ejercicio 3 ------------------------------------------------------------

asalariados <- asalariados %>%
  mutate(sexo = factor(case_when(CH04 == 1 ~ "Varones",
                                 CH04 == 2 ~ "Mujeres"),
                       levels = c("Varones", "Mujeres")),
         ocupacion = factor(case_when(PP04B1 == 1 ~ "Servicio domestico",
                                      TRUE        ~ "Resto de asalariados"),
                            levels = c("Resto de asalariados", "Servicio domestico")))

# a)
coef_asociacion(asalariados, "sexo", "registro")
# n = 13.795 | chi2 = 4,0 | p = 0,045 | V = 0,017
# Tasas: mujeres 37,1% | varones 35,1%   ->  brecha de +2,0 pp

# b) Las dos condiciones de la espuriedad
calculate_tabulates(base = asalariados, x = "sexo", y = "ocupacion",
                    weights = "PONDERA", add.percentage = "col")
# El servicio domestico es 98% femenino  -> Z esta asociada con X

asalariados %>%
  group_by(ocupacion) %>%
  summarise(tasa_no_registro = weighted.mean(registro == "No registrado", PONDERA) * 100,
            .groups = "drop")
# 74,7% de no registro contra 32,7% en el resto  -> Z esta asociada con Y

# c)
coef_ocup <- asalariados %>%
  group_by(ocupacion) %>%
  group_modify(~ coef_asociacion(.x, "sexo", "registro")) %>%
  ungroup()

brechas_ocup <- asalariados %>%
  group_by(ocupacion, sexo) %>%
  summarise(tasa_no_registro = weighted.mean(registro == "No registrado", PONDERA) * 100,
            .groups = "drop") %>%
  pivot_wider(names_from = sexo, values_from = tasa_no_registro) %>%
  mutate(brecha_pp = round(Mujeres - Varones, 1))

brechas_ocup %>% left_join(coef_ocup, by = "ocupacion")

#   ocupacion              Varones  Mujeres  brecha_pp      p        V
#   Resto de asalariados      35,0     29,3      -5,7     1,6e-14  0,068
#   Servicio domestico        69,3     74,8      +5,5     0,911    0,003
#   (en el total la brecha era +2,0 pp)

# d) Respuestas:
#    - La brecha CAMBIA DE SIGNO. En el total las mujeres aparecian levemente
#      peor (+2,0 pp); en el resto de los asalariados estan claramente MEJOR
#      (-5,7 pp). Y dentro del servicio domestico no hay diferencia alguna
#      (p = 0,91): ahi estan todos igual de desprotegidos.
#    - Contraste con el estado civil: alli la asociacion se ATENUABA pero
#      sobrevivia en los dos grupos (relacion propia). Aca la asociacion se
#      DESTRUYE y se invierte: era enteramente un producto de la composicion
#      ocupacional. Eso es una relacion espuria.
#      (Cuando la asociacion se invierte al controlar, se lo conoce como
#      paradoja de Simpson.)
#    - Habriamos concluido que las asalariadas mujeres estan mas desprotegidas
#      que los varones. Es falso: hay una ocupacion casi enteramente femenina
#      (el servicio domestico, con 75% de no registro) que arrastra el promedio
#      del grupo. Fuera de ella las mujeres estan mejor registradas.
#
#    Cierre para discutir en clase: los dos ejercicios de control usan
#    exactamente el mismo procedimiento y llegan a conclusiones opuestas. Por
#    eso el patron hay que MIRARLO, no suponerlo de antemano.
