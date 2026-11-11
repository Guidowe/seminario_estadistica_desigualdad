#carga####
library(eph)
library(tidyverse)
library(openxlsx)
# carga eph####
base <- read.table(file = "bases_eph/usu_individual_T125.txt",sep = ";",header = TRUE)
#filtros a la base ####
ocupados <- base |> filter(ESTADO == 1, DECOCUR >=1 & DECOCUR <=10,EMPLEO!=9)
# creamos categorias de analisis ####
ocupados_categorias  <- ocupados |>
  mutate(bajos.ingresos = ifelse(DECOCUR<4,"si","no"),
         empleo = ifelse(EMPLEO==1,"Formal","Informal"))

#Analisis de asociacion
resultado <- calculate_tabulates(base = ocupados_categorias,
                    x = "bajos.ingresos",y = "empleo",
                    weights = "PONDIIO",add.percentage = "col")
#Exportacion de resultados#
write.xlsx(x = resultado,file = "Resultados/sol.xlsx")

