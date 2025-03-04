# -----------------      Alineamiento con Rsubread (Align)     -------------------------- 
# =======================================================================================
# cargar el paquete Rsubread
library(Rsubread)

# limpiar las variables del sistema
rm(list = ls())

# Estructura de las carpetas:
# definir el directorio de trabajo en este directorio deben de estar las carpetas: con
# ./RefData/Hg38v47       <--- archivos de referencia
# ./RefGen47              <--- indice del genoma
# ./dir_analisis          <--- directorio de análisis (cambiar el nombre a conveniencia)
# ./dir_analisis/RawData  <--- Los datos (archivos fastq) colocarlos en este directorio
# definir al directorio de análisis y como de trabajo:

setwd("./dir_analisis")
dir_analisis <- getwd()

dir.create("./Resultados")
dir.create("./Resultados/align")
dir.create("./Resultados/counts")
dir.create("./Resultados/counts/align")
dir.create("./Resultados/DESeq2_align")
setwd("../")

# =====================================================================================
#                             Alinear con align
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Crear la variable archivo con los nombres de los archivos a analizar
dir_temp <- paste (dir_analisis,"/RawData/", sep = "", collapse=NULL)
archivo <- list.files(path= dir_temp, pattern = ".gz$")
archivo

# loop para alinear/mapear todos los archivos, se alinearan como single end
for (val in archivo)
{
  file1<-paste(dir_analisis,"/RawData/",val, sep = "", collapse=NULL)
  file2<-paste(dir_analisis,"/Resultados/align/",val,".BAM", sep = "", collapse = NULL)
  # alineamiento
  align(
    # index for reference sequences
    index = "./RefGen47/Hg38v47",
    # input reads and output
    readfile1 = file1,
    type = "rna",
    input_format = "gzFASTQ",
    output_format = "BAM",
    output_file = file2,
    # offset value added to Phred quality scores of read bases
    phredOffset = 33,
    # thresholds for mapping
    nsubreads = 10,
    TH1 = 3,
    TH2 = 1,
    maxMismatches = 3,
    # unique mapping and multi-mapping
    unique = FALSE,
    nBestLocations = 1,
    # indel detection
    indels = 5,
    complexIndels = FALSE,
    # read trimming
    nTrim5 = 10,
    nTrim3 = 0,
    # distance and orientation of paired end reads
    minFragLength = 50,
    maxFragLength = 600,
    PE_orientation = "fr",
    # number of CPU threads
    nthreads = 22,
    # read group
    readGroupID = NULL,
    readGroup = NULL,
    # read order
    keepReadOrder = FALSE,
    sortReadsByCoordinates = TRUE,
    # color space reads
    color2base = FALSE,
    # dynamic programming
    DP_GapOpenPenalty = -1,
    DP_GapExtPenalty = 0,
    DP_MismatchPenalty = 0,
    DP_MatchScore = 2,
    # detect structural variants
    detectSV = FALSE,
    # gene annotation
    useAnnotation = TRUE,
    annot.ext = "./RefData/Hg38v47/gencode.v47.primary_assembly.annotation.gtf.gz",
    isGTF = TRUE,
    GTF.featureType = "exon",
    GTF.attrType = "gene_id",
    chrAliases = NULL)
}
