# ============================================================================
# Crear el Indice del Genoma de Humano Hg38 v45 para Rsubread
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Tener una carpeta con los datos del genoma y los archivos de topología
# https://www.gencodegenes.org/
# Cargar la libreria de Rsubread

library(Rsubread)

# cambiar indexsplit y memory dependiendo de las caracteristicas de la computadora
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

buildindex(
  basename = "./RefGen46/Hg38v46",
  reference = "./RefData/GRCh38.primary_assembly.genome.fa.gz",
  gappedIndex = FALSE, 
  indexSplit = FALSE,
  # memory = 10000
  )
