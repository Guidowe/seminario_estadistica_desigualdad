# =============================================================================
# CLASE 07 -- EJERCICIOS RESUELTOS
# Pobreza multidimensional
#
# USO DOCENTE. No se entrega junto con la consigna: se libera despues de la
# clase (ver la lista NO_ENTREGAR en _docente/armar_zip.R).
#
# Parte de la base "base_md" construida en la clase.
# =============================================================================

library(tidyverse)
library(openxlsx)


# ---- Ejercicio 1 ------------------------------------------------------------

base_md %>%
  mutate(sexo = if_else(CH04 == 1, "Varones", "Mujeres")) %>%
  group_by(SEMESTRE, sexo) %>%
  summarise(total  = round(weighted.mean(pmd_total, PONDERA) * 100, 1),
            severo = round(weighted.mean(pmd_sev,   PONDERA) * 100, 1),
            .groups = "drop")


# ---- Ejercicio 2 ------------------------------------------------------------

base_sin_cohorte <- base_md %>%
  mutate(
    edu_total_sin_cohorte = case_when(
      CH06 %in% 4:17 ~ if_else(CH10 != 1 & NIVEL_ED %in% c(1, 2, 3, 7), 1, 0, missing = 0),
      CH06 >= 18     ~ if_else(NIVEL_ED %in% c(1, 2, 3, 7), 1, 0),
      TRUE ~ 0),
    n_priv_total_sin_cohorte = viv_total + san_total + ent_total + sal_total +
                               edu_total_sin_cohorte + emp_total,
    pmd_total_sin_cohorte = if_else(n_priv_total_sin_cohorte >= 1, 1, 0))

base_sin_cohorte %>%
  group_by(SEMESTRE, grupo_edad) %>%
  summarise(con_cohorte = round(weighted.mean(pmd_total,             PONDERA) * 100, 1),
            sin_cohorte = round(weighted.mean(pmd_total_sin_cohorte, PONDERA) * 100, 1),
            .groups = "drop") %>%
  mutate(diferencia = sin_cohorte - con_cohorte)

# Cambia sobre todo el grupo de 65 anios y mas (y en menor medida 30 a 64):
# son cohortes que hicieron su escolaridad cuando el secundario no era
# obligatorio y en las que el secundario incompleto es muy frecuente.
# Sin el criterio de cohorte, la pobreza multidimensional de los mayores
# queda "inflada" por una norma que no regia cuando estaban en edad escolar.


# ---- Ejercicio 3 ------------------------------------------------------------

base_md %>%
  filter(PONDIH > 0) %>%
  mutate(tipologia = factor(
    case_when(pobre_ingresos == 1 & pmd_total == 1 ~ "Pobreza crónica",
              pobre_ingresos == 1 & pmd_total == 0 ~ "Pobreza reciente",
              pobre_ingresos == 0 & pmd_total == 1 ~ "Pobreza inercial",
              pobre_ingresos == 0 & pmd_total == 0 ~ "Integración social"),
    levels = c("Pobreza crónica", "Pobreza reciente",
               "Pobreza inercial", "Integración social"))) %>%
  group_by(SEMESTRE, tipologia) %>%
  summarise(poblacion = sum(PONDIH), .groups = "drop_last") %>%
  mutate(porcentaje = round(poblacion / sum(poblacion) * 100, 1)) %>%
  ungroup() %>%
  select(-poblacion) %>%
  pivot_wider(names_from = SEMESTRE, values_from = porcentaje)

# Con el umbral total crece mucho la "pobreza inercial" (no pobres por
# ingresos pero con al menos una privacion) y casi desaparece la "pobreza
# reciente": casi todos los pobres por ingresos tienen alguna privacion en
# el umbral total.
