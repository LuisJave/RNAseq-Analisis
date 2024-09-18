# ----------------- Alineamiento con Rsubread (Align) -------------------------- 
# ==============================================================================
# cargar el paquete Rsubread
library(Rsubread)
# limpiar las variables del sistema
rm(list = ls())

# definir el directorio de trabajo en este directorio debe de estar la carpeta con
# los archivos de referencia y el directorio con el indice del genoma
# carpetas ./RefData  ./RefGen46 
# Estructura de las carpetas:
# ./RefData
# ./RefGen46
# ./Dir_analisis/RawData/fastq-files
# ./Dir_analisis/Resultados

# definir el directorio de análisis, donde estarán los resultados 

dir_analisis <- "./Analisis_Neutrofilos"

# Los datos (archivos fastq) colocarlos en el directorio de analisis en una carpeta con nombre ./RawData
# En el directorio de análisis Se crearan los directorios necesarios para los Resultados
setwd(dir_analisis)
dir.create("./Resultados")
dir.create("./Resultados/align")
dir.create("./Resultados/counts")
dir.create("./Resultados/counts/align")
dir.create("./Resultados/DESeq2_align")
setwd('../')

# ===========================================================================
# Alinear con align
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Crear un conjunto con los nombres de los archivos a analizar
dir_temp <- paste (dir_analisis,"/RawData/", sep = "", collapse=NULL)
archivo <- list.files(path= dir_temp, pattern = "fq.gz$")
archivo

# loop para analizar todos los archivos, se analizaran como single end
for (val in archivo)
{
  file1<-paste(dir_analisis,"/RawData/",val, sep = "", collapse=NULL)
  file2<-paste(dir_analisis,"/Resultados/align/",val,".BAM", sep = "", collapse = NULL)
  # alineamiento
  align(
    # index for reference sequences
    index = "./RefGen46/Hg38v46",
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
    annot.ext = "./RefData/gencode.v46.primary_assembly.annotation.gtf.gz",
    isGTF = TRUE,
    GTF.featureType = "exon",
    GTF.attrType = "gene_id",
    chrAliases = NULL)
}

# ==============================================================================
# Elaborar las tablas de conteo con el featureCount de Subread
# Esta hecho para serie de archivos con terminacion .BAM
# carpeta:
# ----------------------------  align ------------------------------------------

dir_temp <- paste (dir_analisis,"/Resultados/align/", sep = "", collapse=NULL)
archivo<-list.files(path = dir_temp, pattern = ".BAM$")
archivo

for (val in archivo)
{
  file1<-paste(dir_analisis,"/Resultados/align/",val, sep = "", collapse=NULL)
  cuentas<-featureCounts(files=file1,
                         annot.ext = "./RefData/gencode.v46.primary_assembly.annotation.gtf.gz",
                         isGTFAnnotationFile = TRUE,
                         nthreads = 22)
  write.table(
    x=data.frame(cuentas$annotation[,c("GeneID")],
                 cuentas$counts,stringsAsFactors = FALSE),
    file=paste(dir_analisis,"/Resultados/counts/align/",val,".count", sep = "", collapse = NULL),
    quote = FALSE,
    sep = "\t",
    row.names = FALSE)
}
