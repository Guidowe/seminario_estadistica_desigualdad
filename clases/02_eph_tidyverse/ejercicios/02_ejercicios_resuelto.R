# =============================================================================
# CLASE 02 -- EJERCICIOS RESUELTOS
# La EPH:
#
# USO DOCENTE. No se entrega junto con la consigna: se libera despues de la
# clase.
# =============================================================================


# ---- Preparacion ------------------------------------------------------------

library(tidyverse)

individual_t125 <- read.table("bases_eph/usu_individual_T125.txt",
                              sep = ";", dec = ",",
                              header = TRUE, fill = TRUE)

individual_t225 <- read.table("bases_eph/usu_individual_T225.txt",
                              sep = ";", dec = ",",
                              header = TRUE, fill = TRUE)

regiones <- readxl::read_excel("bases_eph/Aglomerados y Regiones EPH.xlsx",
                               sheet = "Regiones EPH", skip = 1)


# ---- Ejercicio 1 ------------------------------------------------------------
# Tasas basicas, 1er trimestre 2025

tasas <- individual_t125 %>%
  summarise(Poblacion         = sum(PONDERA),
            Ocupados          = sum(PONDERA[ESTADO == 1]),
            Desocupados       = sum(PONDERA[ESTADO == 2]),
            PEA               = Ocupados + Desocupados,
            Ocupados_demand   = sum(PONDERA[ESTADO == 1 & PP03J == 1]),
            Suboc_demandante  = sum(PONDERA[ESTADO == 1 & INTENSI == 1 & PP03J == 1]),
            Suboc_no_demand   = sum(PONDERA[ESTADO == 1 & INTENSI == 1 & PP03J %in% c(2, 9)]),
            Subocupados       = Suboc_demandante + Suboc_no_demand,
            "Tasa Actividad"                  = PEA / Poblacion,
            "Tasa Empleo"                     = Ocupados / Poblacion,
            "Tasa Desocupacion"               = Desocupados / PEA,
            "Tasa ocupados demandantes"       = Ocupados_demand / PEA,
            "Tasa Subocupacion"               = Subocupados / PEA,
            "Tasa Subocupacion demandante"    = Suboc_demandante / PEA,
            "Tasa Subocupacion no demandante" = Suboc_no_demand / PEA) %>%
  select(-(1:8))   # elimino los niveles poblacionales

tasas


# ---- Ejercicio 2 ------------------------------------------------------------
# Tasas basicas por region, 1er trimestre 2025

tasas_regiones <- individual_t125 %>%
  group_by(REGION) %>%
  summarise(Poblacion         = sum(PONDERA),
            Ocupados          = sum(PONDERA[ESTADO == 1]),
            Desocupados       = sum(PONDERA[ESTADO == 2]),
            PEA               = Ocupados + Desocupados,
            Ocupados_demand   = sum(PONDERA[ESTADO == 1 & PP03J == 1]),
            Suboc_demandante  = sum(PONDERA[ESTADO == 1 & INTENSI == 1 & PP03J == 1]),
            Suboc_no_demand   = sum(PONDERA[ESTADO == 1 & INTENSI == 1 & PP03J %in% c(2, 9)]),
            Subocupados       = Suboc_demandante + Suboc_no_demand,
            "Tasa Actividad"                  = PEA / Poblacion,
            "Tasa Empleo"                     = Ocupados / Poblacion,
            "Tasa Desocupacion"               = Desocupados / PEA,
            "Tasa ocupados demandantes"       = Ocupados_demand / PEA,
            "Tasa Subocupacion"               = Subocupados / PEA,
            "Tasa Subocupacion demandante"    = Suboc_demandante / PEA,
            "Tasa Subocupacion no demandante" = Suboc_no_demand / PEA) %>%
  ungroup() %>%
  select(-(2:9))   # la 1ra columna ahora es REGION: la conservo

tasas_regiones_presentacion <- tasas_regiones %>%
  left_join(regiones, by = "REGION") %>%
  select(Region, everything(), -REGION)

tasas_regiones_presentacion


# ---- Ejercicio 3 ------------------------------------------------------------
# Tasas basicas por region y sexo, 1er trimestre 2025

tasas_regiones_sexo <- individual_t125 %>%
  group_by(REGION, CH04) %>%
  summarise(Poblacion         = sum(PONDERA),
            Ocupados          = sum(PONDERA[ESTADO == 1]),
            Desocupados       = sum(PONDERA[ESTADO == 2]),
            PEA               = Ocupados + Desocupados,
            Ocupados_demand   = sum(PONDERA[ESTADO == 1 & PP03J == 1]),
            Suboc_demandante  = sum(PONDERA[ESTADO == 1 & INTENSI == 1 & PP03J == 1]),
            Suboc_no_demand   = sum(PONDERA[ESTADO == 1 & INTENSI == 1 & PP03J %in% c(2, 9)]),
            Subocupados       = Suboc_demandante + Suboc_no_demand,
            "Tasa Actividad"                  = PEA / Poblacion,
            "Tasa Empleo"                     = Ocupados / Poblacion,
            "Tasa Desocupacion"               = Desocupados / PEA,
            "Tasa ocupados demandantes"       = Ocupados_demand / PEA,
            "Tasa Subocupacion"               = Subocupados / PEA,
            "Tasa Subocupacion demandante"    = Suboc_demandante / PEA,
            "Tasa Subocupacion no demandante" = Suboc_no_demand / PEA) %>%
  ungroup() %>%
  select(-(3:10)) %>%   # ahora conservo las 2 primeras columnas (REGION y CH04)
  mutate(Sexo = case_when(CH04 == 1 ~ "Varon",
                          CH04 == 2 ~ "Mujer")) %>%
  left_join(regiones, by = "REGION") %>%
  select(Region, Sexo, everything(), -REGION, -CH04)

tasas_regiones_sexo


# ---- Ejercicio 4 ------------------------------------------------------------
# Actividad, empleo y desocupacion por sexo, 18 a 35 anios,
# 1er y 2do trimestre 2025 en una sola tabla

variables <- c("ANO4", "TRIMESTRE", "CH04", "CH06", "ESTADO", "PONDERA")

base_unida <- bind_rows(individual_t125 %>% select(all_of(variables)),
                        individual_t225 %>% select(all_of(variables)))

tasas_jovenes <- base_unida %>%
  filter(CH06 %in% 18:35) %>%
  group_by(ANO4, TRIMESTRE, CH04) %>%
  summarise(Poblacion   = sum(PONDERA),
            Ocupados    = sum(PONDERA[ESTADO == 1]),
            Desocupados = sum(PONDERA[ESTADO == 2]),
            PEA         = Ocupados + Desocupados,
            "Tasa Actividad"    = PEA / Poblacion,
            "Tasa Empleo"       = Ocupados / Poblacion,
            "Tasa Desocupacion" = Desocupados / PEA) %>%
  ungroup() %>%
  mutate(Sexo = case_when(CH04 == 1 ~ "Varon",
                          CH04 == 2 ~ "Mujer")) %>%
  select(ANO4, TRIMESTRE, Sexo, starts_with("Tasa"))

tasas_jovenes


# ---- Ejercicio 5 ------------------------------------------------------------
# Salario promedio de asalariados por sexo y grupo de edad, 1er trimestre 2025
# P21 = ingreso de la ocupacion principal -> ponderador PONDIIO
# (corrige la no respuesta de ingresos; PONDERA subestimaria los montos)

salario_sexo_edad <- individual_t125 %>%
  filter(ESTADO == 1, CAT_OCUP == 3) %>%
  mutate(Grupo_Etario = case_when(CH06 %in% 18:35 ~ "18 a 35",
                                  CH06 %in% 36:70 ~ "36 a 70"),
         Sexo = case_when(CH04 == 1 ~ "Varon",
                          CH04 == 2 ~ "Mujer")) %>%
  filter(!is.na(Grupo_Etario)) %>%
  group_by(Sexo, Grupo_Etario) %>%
  summarise(Salario_Promedio = weighted.mean(P21, PONDIIO)) %>%
  ungroup()

salario_sexo_edad


# ---- Ejercicio 6 ------------------------------------------------------------
# Exportacion: una hoja por tabla

openxlsx::write.xlsx(
  x = list("Tasas T1 2025"      = tasas,
           "Tasas por region"   = tasas_regiones_presentacion,
           "Region y sexo"      = tasas_regiones_sexo,
           "18 a 35 T1 y T2"    = tasas_jovenes,
           "Salarios"           = salario_sexo_edad),
  file = "Resultados/clase02_ejercicios.xlsx",
  overwrite = TRUE)
