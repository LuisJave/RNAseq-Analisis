# ============================================================================
# Crear el índice del genoma de humano Hg38 v49 para Rsubread
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Ir al directorio principal, en este directorio está la carpeta "RefData" 
# con los datos del genoma y los archivos de topología
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Si los recursos de la computadora son limitados
# cambiar:
# indexSplit = TRUE,
# memory = VALOR <-- igual al máximo de la memoria del computador menos 2GB
# Si la computadora tiene al menos 24GB de memoria se puede dejar como se muestra
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Cargar la librería de Rsubread

library(Rsubread)
if (file.exists("./RefData/Hg38v49/GRCh38.primary_assembly.genome.fa.gz"))
{ buildindex (basename = "./RefGen49/Hg38v49",
             reference = "./RefData/Hg38v49/GRCh38.primary_assembly.genome.fa.gz",
             gappedIndex = FALSE,
             indexSplit = FALSE,
             # memory = 10000
             )
} else { print(paste("El archivo del genoma no se encuentra en la carpeta ./RefData/"))}


