# =====================   Analisis con DESeq2   ================================
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# En la carpeta correspondiente tener los archivos necesarios:
# 1.- matriz de conteo
# 2.- descripcion de grupos en formato CSV archivo "experimento.csv"
#   Muestra,            Condicion
#   Muestra1.fq.gz.BAM, problema
#   Muestra2.fq.gz.BAM, problema
#   Muestra3.fq.gz.BAM, control
#   Muestra4.fq.gz.BAM, control

library(DESeq2)
library(apeglm)
library(pheatmap)
library(vsn)
library(biomaRt)
library(ReportingTools)
library(lattice)
library(RColorBrewer)
library(readr)

# limpiar las variables del sistema
rm(list = ls())

# Definir el directorio de trabajo principal
setwd("./dir_analisis")  # <-- Este directorio es propio de cada uno

# guardar el directorio principal
dir1 <- getwd()
DESeq2_dir <- file.path(dir1, "Resultados", "DESeq2_align")
setwd(DESeq2_dir)

# Cargar la informacion de la matriz de conteo de align
dsdata <- read.csv('./Matriz_conteo_align.csv',header = TRUE,row.names = 1)

#Cargar la informacion del experimento
experimento <- read.csv('./experimento.csv',header = TRUE,row.names = 1)

#checar que los nombres de las columnas sean iguales que las filas en ambas matrices
all(colnames(dsdata) %in% rownames(experimento))
all(colnames(dsdata) == rownames(experimento))
# el resultado de esto debe de ser:
# [1]TRUE [1]TRUE

#establecer el Factor de comparacion
experimento$Condicion <- factor(experimento$Condicion)

# Cargar la matriz en la variable dds para DESeq2 
dds <- DESeqDataSetFromMatrix(countData = dsdata,
                              colData = experimento,
                              design = ~ Condicion)

# Especificar el grupo de referencia
dds$Condicion <- relevel(dds$Condicion, ref = "control")

# filtrado de features "todas las features con una sumatoria menor a 10 reads son eliminadas"
Nmuestras = 4 # <- especificar el numero de muestras
keep <- rowSums(counts(dds))>= (Nmuestras*2)
dds <- dds[keep,]

# Correr DESeq2
dds <- DESeq(dds)
resultsNames(dds)

# guardar el resultado para análisis futuros
saveRDS(dds, file = "./Res_DS2_dds_Align")

# ==============================================================================
# Si se cuenta con un archivo guardado de DESeq2
# se puede empezar desde este punto y cargar el archivo en la variable "dds" 
dds <- readRDS("./Res_DS2_dds_Align")

# ==============================================================================
# Normalización y transformación de los datos
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 1. Log2 Normalization log2(n0+n1)
dds_lg2 <- normTransform(dds)

# 2.- VST (variance stabilizing transformation).... el recomendado para WGCNA
dds_vst <- vst(dds, blind = FALSE) 

# 3.- rlog transformation (regularized logarithm) "si son muchas muestras mejor usar VST"
dds_rlog <- rlog(dds, blind = FALSE)

# Normalización de datos
norm_dds <- counts(dds, normalized=TRUE)
write.csv(norm_dds, "./Data_DS2_align_norm.csv", row.names = TRUE)

# ==============================================================================
# ---------------  Graficar comportamiento de las muestras  --------------------
#
# Gráfico de dispersion de los datos por muestra
boxplot(log10(assays(dds)[["cooks"]]), range=0, las=2)

# Observar dispersión de la desviación estandar 
meanSdPlot(assay(dds_lg2))
meanSdPlot(assay(dds_rlog))
meanSdPlot(assay(dds_vst))

# Generar los PCA plots de las muestras
plotPCA (
  dds_rlog,
  intgroup = "Condicion",
  ntop = 500,
  returnData = FALSE,
  pcsToUse = 1:2)

plotPCA (
  dds_vst,
  intgroup = "Condicion",
  ntop = 500,
  returnData = FALSE,
  pcsToUse = 1:2)

plotPCA (
  dds_lg2,
  intgroup = "Condicion",
  ntop = 500,
  returnData = FALSE,
  pcsToUse = 1:2)

# Matriz de distancia de las muestras
sampleDists <- dist(t(assay(dds_vst)))
sampleDistMatrix <- as.matrix(sampleDists)
rownames(sampleDistMatrix) <- paste(colnames(dds_vst))
colnames(sampleDistMatrix) <- NULL
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
pheatmap(sampleDistMatrix,
         clustering_distance_rows=sampleDists,
         clustering_distance_cols=sampleDists,
         col=colors)

# Heatmap de la matriz de datos
select <- order(rowMeans(counts(dds,normalized=TRUE)),
                decreasing=TRUE)[1:30]
pheatmap(assay(dds_lg2)[select,], cluster_rows=FALSE, show_rownames=FALSE,
         cluster_cols=FALSE, annotation_col=experimento)

pheatmap(assay(dds_vst)[select,], cluster_rows=FALSE, show_rownames=FALSE,
         cluster_cols=FALSE, annotation_col=experimento)

# ==============================================================================
#                   RESULTADOS DEGs y Anotación de DEGs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Cargar los datos para anotación 
mart <- useDataset("hsapiens_gene_ensembl", useMart("ensembl"))

# Crear las tablas de resultados y escribir el resultado
res <- results(dds, contrast=c("Condicion","problema","control"))

# informacion sobre las variables y las pruebas estadisticas de los resultados
mcols(res)$description
# Resumen de los resultados
summary(res)

#           Anotar resultados DESeq2 (ENSEMBL IDs --> Gene Names) 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Res_DS2_align <- data.frame(res)
Res_DS2_align$Ensembl <- rownames(Res_DS2_align)

# Crear una tabla con los datos ENSEMBL y los resultados de DESeq2 con align
Lista_align <- getBM(filters= "ensembl_gene_id_version", 
                     attributes= c("ensembl_gene_id_version",
                                   "external_gene_name",
                                   "description"),
                     values=Res_DS2_align$Ensembl, mart= mart)

# Fusiona las tablas
res_align<-merge(Res_DS2_align,Lista_align,by.x="Ensembl",by.y="ensembl_gene_id_version")
# Escribir el archivo final anotado
write.csv(res_align, "./Res_DS2_align_annot.csv", row.names = TRUE)

# ==============================================================================
#                       Reporte con ReportingTools
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

add.anns <-  function(df, mart, ...)
{
  nm <- rownames(df)
  anns <- getBM( attributes = c("ensembl_gene_id_version", "external_gene_name", "description"),
                 filters = "ensembl_gene_id_version",
                 values = nm,
                 mart = mart)
  anns <- anns[match(nm, anns[, 1]), ]
  colnames(anns) <- c("Ensembl", "Gene_Name", "Gene_Description")
  df <- cbind(anns, df[, 2:ncol(df)])
  rownames(df) <- nm
  df
  }

des2Report <- HTMLReport(shortName = "Reporte_align",
                         title="Expresion diferencial DESeq2",
                         reportDirectory="./reporte_align")
publish(dds,
        des2Report,
        .modifyDF = list(add.anns,modifyReportDF),
        mart = mart,
        pvalueCutoff=0.05,
        lfc= 1.5,
        factor = experimento$Condicion,
        n = 10000,
        reportDir="./reporte_align")
finish(des2Report)

# =============================================================================
# Compactación de datos para mejor visualización
# apeglm is the adaptive t prior shrinkage estimator from the apeglm package (Zhu, Ibrahim, and Love 2018).
# ashr is the adaptive shrinkage estimator from the ashr package (Stephens 2016). Here DESeq2 uses the ashr option to fit a mixture of Normal distributions to form the prior, with method="shrinkage".
# normal is the the original DESeq2 shrinkage estimator, an adaptive Normal distribution as prior.

resultsNames(dds)

resApg <- lfcShrink(dds, coef=2, type="apeglm")
resAsh <- lfcShrink(dds, coef=2, type="ashr")
resNor <- lfcShrink(dds, coef=2, type="normal")

# -----------------------------------------------------------------------------
# Graficar los datos de DESeq2 
# -----------------------------------------------------------------------------

# Crear el MAplot
plotMA(res, ylim = c(-8,8)) # modificar los parametros de ylim de acuerdo al LogFC
abline(h=c(-1,1), col="red", lwd=1)

plotMA(resApg, ylim = c(-10,10))
abline(h=c(-1,1), col="red", lwd=1)

plotMA(resAsh, ylim = c(-6,6))
abline(h=c(-1,1), col="red", lwd=1)

plotMA(resNor, ylim = c(-6,6))
abline(h=c(-1,1), col="red", lwd=1)

# Para identificar algunos genes en el MAplot correr las siguientes lineas:
idx <- identify(res$baseMean, res$log2FoldChange)
rownames(res)[idx]

# Para determinar el comportamiento del gen con el máximo valor de fold change
plotCounts(dds, gene = which.max(res$log2FoldChange), intgroup = "Condicion")

# Para determinar el comportamiento del gen con el valor minimo de padj
plotCounts(dds, gene = which.min(res$padj), intgroup = "Condicion")

# Para determinar el comportamiento de un gen particular sabiendo su codigo Ensembl
plotCounts(dds, gene = "ENSG00000145794.17", intgroup = "Condicion")
