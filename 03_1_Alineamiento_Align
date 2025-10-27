# -----------------      Alineamiento con Rsubread (Align)     -------------------------- 
# =======================================================================================
# cargar el paquete Rsubread
library(Rsubread)

# limpiar las variables del sistema
rm(list = ls())

# Ir al directorio de análisis y definirlo como directorio de trabajo

setwd("./dir_analisis")  # cambiar el nombre dir_analisis por el nombre del directorio en uso
dir_analisis <- getwd()

setwd("../")

# =====================================================================================
#                             Alinear con align
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Crear la variable archivo con los nombres de los archivos a analizar
dir_temp <- paste (dir_analisis,"/RawData/", sep = "", collapse=NULL)
archivo <- list.files(path= dir_temp, pattern = ".gz$")
archivo

# loop para alinear/mapear todos los archivos, se alinearán como single end
for (val in archivo)
{
  file1<-paste(dir_analisis,"/RawData/",val, sep = "", collapse=NULL)
  file2<-paste(dir_analisis,"/Resultados/BAMs/align/",val,".BAM", sep = "", collapse = NULL)
  # alineamiento
  align(
    # index for reference sequences
    index = "./RefGen49/Hg38v49",
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
    annot.ext = "./RefData/Hg38v49/gencode.v49.primary_assembly.annotation.gtf.gz",
    isGTF = TRUE,
    GTF.featureType = "exon",
    GTF.attrType = "gene_id",
    chrAliases = NULL)
}
