# ==============================================================================
# ********************************   align  ************************************
# crea una tabla matriz con los datos de conteo de align
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# cargar las librerias necesarias

library(dbplyr)
library(tidyverse)

# limpiar las variables del sistema
rm(list = ls())

# Definir el directorio de trabajo principal
setwd("./dir_analisis")  # <-- Este directorio es propio de cada uno

# guardar el directorio principal
dir1 <- getwd()

# definir el directorio de los archivos de conteo de align
align_dir <- file.path(dir1, "Resultados", "counts", "align")
setwd(align_dir)

# genera la variable archivos con la lista de nombres de los archivos de conteo
archivos<-list.files(path = "./", pattern = ".count$")
Data_file <- map(archivos,read.delim, stringsAsFactors = FALSE, check.names = FALSE, row.names = NULL)
Matriz<- Data_file %>% reduce(inner_join, by = "cuentas.annotation...c..GeneID...")
res_dir <- file.path(dir1, "Resultados", "DESeq2_align")
setwd(res_dir)
write.csv(Matriz, "./Matriz_conteo_align.csv", row.names = F)
