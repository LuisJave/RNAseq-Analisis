# ============================================================================
# Crear el Indice del Genoma de Humano Hg38 v49 para Rsubread
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Tener una carpeta con los datos del genoma y los archivos de topología
# Los archivos se pueden descargar de --> https://www.gencodegenes.org/
# archivo GTF, GFF3 y Fasta del genoma de interés
# Crear las siguientes carpetas:
# ./RefData/Hg38v49/   <--- carpeta con los archivos del genoma Fasta, GTF y GFF
# ./RefGen49/          <--- carpeta donde se creará el índice del genoma
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

