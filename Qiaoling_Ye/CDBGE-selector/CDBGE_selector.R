rm(list = ls()) ## clean up

#set directory
setwd("GitHub/CDBGE-selector")

# Load required libraries####
library(readxl)      
library(mclust)      
library(pheatmap)    
library(RColorBrewer) 
library(ggplot2)     
library(dplyr)
library(tidyr)
library(writexl)     
library(factoextra)  
library(purrr)  
# ============================================================================
# CartesianDistanceCalculation
# ============================================================================
##data normalizad functio
normalized <- function(x) {
  # Extract gene names (first column)
  gene <- x[, 1]
  
  # Create an empty dataframe to store normalized values
  normalized_cartesiana <- data.frame(matrix(ncol = 13, nrow = nrow(x)))
  
  # Select columns from different groups that correspond to the same time point
  h6 <- x[, c(2, 3, 4, 5)]
  h24 <- x[, c(2, 6, 7, 8)]
  h48 <- x[, c(2, 9, 10, 11)]
  
  # Find the maximum value in each time point
  max6 <- apply(h6, 1, max, na.rm = TRUE)
  max24 <- apply(h24, 1, max, na.rm = TRUE)
  max48 <- apply(h48, 1, max, na.rm = TRUE)
  
  # Initialize vectors
  MCSF_6h <- numeric(nrow(x))
  IFN_LPS_6h <- numeric(nrow(x))
  IL10_6h <- numeric(nrow(x))
  sec_HepG2_6h <- numeric(nrow(x))
  MCSF_24h <- numeric(nrow(x))
  IFN_LPS_24h <- numeric(nrow(x))
  IL10_24h <- numeric(nrow(x))
  sec_HepG2_24h <- numeric(nrow(x))
  MCSF_48h <- numeric(nrow(x))
  IFN_LPS_48h <- numeric(nrow(x))
  IL10_48h <- numeric(nrow(x))
  sec_HepG2_48h <- numeric(nrow(x))
  
  # Loop through each row
  for (i in 1:nrow(x)) {
    # Normalize values in the row by dividing the selected columns by their maximum value
    MCSF_6h[i] <- h6[i, 1] / max6[i]
    IFN_LPS_6h[i] <- h6[i, 4] / max6[i]
    IL10_6h[i] <- h6[i, 2] / max6[i]
    sec_HepG2_6h[i] <- h6[i, 3] / max6[i]
    MCSF_24h[i] <- h24[i, 1] / max24[i]
    IFN_LPS_24h[i] <- h24[i, 4] / max24[i]
    IL10_24h[i] <- h24[i, 2] / max24[i]
    sec_HepG2_24h[i] <- h24[i, 3] / max24[i]
    MCSF_48h[i] <- h48[i, 1] / max48[i]
    IFN_LPS_48h[i] <- h48[i, 4] / max48[i]
    IL10_48h[i] <- h48[i, 2] / max48[i]
    sec_HepG2_48h[i] <- h48[i, 3] / max48[i]
  }
  
  # Create a dataframe to store the normalized values
  normalized_cartesiana <- data.frame(
    gene = x[, 1],
    MCSF_h6 = MCSF_6h,
    IFN_LPS_h6 = IFN_LPS_6h,
    IL10_h6 = IL10_6h,
    sec_HepG2_h6 = sec_HepG2_6h,
    MCSF_h24 = MCSF_24h,
    IFN_LPS_h24 = IFN_LPS_24h,
    IL10_h24 = IL10_24h,
    sec_HepG2_h24 = sec_HepG2_24h,
    MCSF_h48 = MCSF_48h,
    IFN_LPS_h48 = IFN_LPS_48h,
    IL10_h48 = IL10_48h,
    sec_HepG2_h48 = sec_HepG2_48h
  )
  
  return(normalized_cartesiana)
}

##difference calcularion function
dif <- function(x) {
  gene <- x[, 1]
  
  # Create an empty dataframe to store difference value
  dif_h <- data.frame(matrix(ncol = 10, nrow = nrow(x)))
  
  # Set column names
  colnames(dif_h) <- c("gene", "dif_IFN_LPS_6h", "dif_IL10_6h", "dif_sec_HepG2_6h",
                       "dif_IFN_LPS_24h", "dif_IL10_24h", "dif_sec_HepG2_24h",
                       "dif_IFN_LPS_48h", "dif_IL10_48h", "dif_sec_HepG2_48h")
  
  # Convert vectors to numeric format
  dif_IFN_LPS_6h <- numeric(nrow(x))
  dif_IL10_6h <- numeric(nrow(x))
  dif_sec_HepG2_6h <- numeric(nrow(x))
  dif_IFN_LPS_24h <- numeric(nrow(x))
  dif_IL10_24h <- numeric(nrow(x))
  dif_sec_HepG2_24h <- numeric(nrow(x))
  dif_IFN_LPS_48h <- numeric(nrow(x))
  dif_IL10_48h <- numeric(nrow(x))
  dif_sec_HepG2_48h <- numeric(nrow(x))
  
  # Loop to calculate difference for each group and time point
  for (i in 1:nrow(x)) {
    # Calculate squared differences
    dif_IFN_LPS_6h[i] <- (x[i, 3] - x[i, 2])^2
    dif_IL10_6h[i] <- (x[i, 4] - x[i, 2])^2
    dif_sec_HepG2_6h[i] <- (x[i, 5] - x[i, 2])^2
    dif_IFN_LPS_24h[i] <- (x[i, 7] - x[i, 6])^2
    dif_IL10_24h[i] <- (x[i, 8] - x[i, 6])^2
    dif_sec_HepG2_24h[i] <- (x[i, 9] - x[i, 6])^2
    dif_IFN_LPS_48h[i] <- (x[i, 11] - x[i, 10])^2
    dif_IL10_48h[i] <- (x[i, 12] - x[i, 10])^2
    dif_sec_HepG2_48h[i] <- (x[i, 13] - x[i, 10])^2
  }
  
  # Assign differences to the dataframe
  dif_h$gene <- gene
  dif_h$dif_IFN_LPS_6h <- dif_IFN_LPS_6h
  dif_h$dif_IL10_6h <- dif_IL10_6h
  dif_h$dif_sec_HepG2_6h <- dif_sec_HepG2_6h
  dif_h$dif_IFN_LPS_24h <- dif_IFN_LPS_24h
  dif_h$dif_IL10_24h <- dif_IL10_24h
  dif_h$dif_sec_HepG2_24h <- dif_sec_HepG2_24h
  dif_h$dif_IFN_LPS_48h <- dif_IFN_LPS_48h
  dif_h$dif_IL10_48h <- dif_IL10_48h
  dif_h$dif_sec_HepG2_48h <- dif_sec_HepG2_48h
  
  # Clean up NAs
  dif_h <- dif_h[!is.na(dif_h$gene), ]
  dif_h[is.na(dif_h)] <- 0
  
  return(dif_h)
}

##Cartesian distance calculation function
CartDist <- function(x) {
  gene <- x[, 1]
  
  # Create an empty dataframe to store distance value
  dist <- data.frame(matrix(ncol = 4, nrow = nrow(x)))
  
  # Set column names
  colnames(dist) <- c("gene", "dist_IFN_LPS", "dist_IL10", "dist_sec_HepG2")
  
  # Convert vectors to numeric format
  dist_IFN_LPS <- numeric(nrow(x))
  dist_IL10 <- numeric(nrow(x))
  dist_sec_HepG2 <- numeric(nrow(x))
  
  # Loop to calculate Euclidean distance for each group
  for (i in 1:nrow(x)) {
    # Calculate distances (square root of sum of squared differences across time points)
    dist_IFN_LPS[i] <- sqrt(sum(x[i, 2], x[i, 5], x[i, 8]))
    dist_IL10[i] <- sqrt(sum(x[i, 3], x[i, 6], x[i, 9]))
    dist_sec_HepG2[i] <- sqrt(sum(x[i, 4], x[i, 7], x[i, 10]))
  }
  
  # Assign distances to the dataframe
  dist$gene <- gene
  dist$dist_IFN_LPS <- dist_IFN_LPS
  dist$dist_IL10 <- dist_IL10
  dist$dist_sec_HepG2 <- dist_sec_HepG2
  
  return(dist)
}

##process donor function
process_donor_from_file <- function(data, donor_cols, donor_name) {
  # Extract data for this donor (including gene column)
  donor_data <- data[, c(1, donor_cols)]
  
  # Remove rows with all NAs
  donor_data <- donor_data[rowSums(is.na(donor_data[, -1])) < ncol(donor_data[, -1]), ]
  
  # Process the donor
  normalized_data <- normalized(donor_data)
  dif_data <- dif(normalized_data)
  dist_data <- CartDist(dif_data)
  
  # Add donor name to column names (except gene)
  colnames(normalized_data)[-1] <- paste0(colnames(normalized_data)[-1], "_", donor_name)
  colnames(dif_data)[-1] <- paste0(colnames(dif_data)[-1], "_", donor_name)
  colnames(dist_data)[-1] <- paste0(colnames(dist_data)[-1], "_", donor_name)
  
  return(list(
    normalized = normalized_data,
    differences = dif_data,
    distance = dist_data
  ))
}

##process all donors
process_all_donors <- function(file_path = "TPM.xlsx") {
  
  # Read the single TPM file
  cat("Reading file:", file_path, "\n")
  data <- read_excel(file_path)
  data <- as.data.frame(data)
  
  # First column should be gene names
  gene_col <- colnames(data)[1]
  cat("Gene column:", gene_col, "\n")
  cat("Total columns:", ncol(data), "\n")
  
  # Identify columns for each donor
  # Looking for patterns like D24, D25, D27 at the beginning of column names
  all_cols <- colnames(data)[-1]  # Exclude gene column
  
  # Find unique donor identifiers
  donor_patterns <- c("D24", "D25", "D27")
  donor_columns <- list()
  
  for (pattern in donor_patterns) {
    cols <- grep(pattern, all_cols, value = TRUE, ignore.case = TRUE)
    if (length(cols) > 0) {
      donor_columns[[pattern]] <- which(colnames(data) %in% cols)
      cat(sprintf("Donor %s: found %d columns\n", pattern, length(cols)))
    } else {
      cat(sprintf("Warning: No columns found for donor %s\n", pattern))
    }
  }
  
  # Process each donor
  donor_results <- list()
  
  for (donor in names(donor_columns)) {
    cat("\n========================================\n")
    cat("Processing donor:", donor, "\n")
    cat("========================================\n")
    
    result <- process_donor_from_file(data, donor_columns[[donor]], donor)
    
    donor_results[[donor]] <- result
    
    cat(sprintf("  Normalized: %d genes x %d conditions\n", 
                nrow(result$normalized), ncol(result$normalized) - 1))
    cat(sprintf("  Differences: %d genes x %d conditions\n", 
                nrow(result$differences), ncol(result$differences) - 1))
    cat(sprintf("  Distance: %d genes x 3 conditions\n", 
                nrow(result$distance)))
  }
  
  return(donor_results)
}

##Run analysis####
# Process all donors from the single TPM file
donor_results <- process_all_donors("TPM.xlsx")

# Extract results for each donor
D24_normalized <- donor_results$D24$normalized
D24_differences <- donor_results$D24$differences
D24_distance <- donor_results$D24$distance

D25_normalized <- donor_results$D25$normalized
D25_differences <- donor_results$D25$differences
D25_distance <- donor_results$D25$distance

D27_normalized <- donor_results$D27$normalized
D27_differences <- donor_results$D27$differences
D27_distance <- donor_results$D27$distance

####merge normalized data from all donors####
# Extract normalized data from each donor
normalized_list <- list(
  D24 = donor_results$D24$normalized,
  D25 = donor_results$D25$normalized,
  D27 = donor_results$D27$normalized
)

# Merge all normalized data by gene
normalized_all <- Reduce(function(x, y) merge(x, y, by = "gene", all = TRUE), normalized_list)

# Replace NAs with 0
normalized_all[is.na(normalized_all)] <- 0

cat("Merged Normalized Data:", nrow(normalized_all), "genes x", ncol(normalized_all), "columns\n")
cat("Column names:", paste(head(colnames(normalized_all), 5), collapse=", "), "...\n\n")

####merge difference data from all donors####
# Extract differences data from each donor
differences_list <- list(
  D24 = donor_results$D24$differences,
  D25 = donor_results$D25$differences,
  D27 = donor_results$D27$differences
)

# Merge all differences data by gene
differences_all <- Reduce(function(x, y) merge(x, y, by = "gene", all = TRUE), differences_list)

# Replace NAs with 0
differences_all[is.na(differences_all)] <- 0

cat("Merged Differences Data:", nrow(differences_all), "genes x", ncol(differences_all), "columns\n")
cat("Column names:", paste(head(colnames(differences_all), 5), collapse=", "), "...\n\n")

####merge distance data from all donors####
# Extract distance data from each donor
distance_list <- list(
  D24 = donor_results$D24$distance,
  D25 = donor_results$D25$distance,
  D27 = donor_results$D27$distance
)

# Merge all distance data by gene
distance_all <- Reduce(function(x, y) merge(x, y, by = "gene", all = TRUE), distance_list)

# Replace NAs with 0
distance_all[is.na(distance_all)] <- 0

cat("Merged Distance Data:", nrow(distance_all), "genes x", ncol(distance_all), "columns\n\n")

###calculate means of each macrophage type across time and differences for distance data####
# Identify distance columns for each condition across donors and time
dist_IFN_cols <- grep("dist_IFN_LPS", colnames(distance_all), value = TRUE)
dist_IL10_cols <- grep("dist_IL10", colnames(distance_all), value = TRUE)
dist_sec_cols <- grep("dist_sec_HepG2", colnames(distance_all), value = TRUE)

cat("Found distance columns:\n")
cat("  IFN_LPS:", paste(dist_IFN_cols, collapse=", "), "\n")
cat("  IL10:", paste(dist_IL10_cols, collapse=", "), "\n")
cat("  sec_HepG2:", paste(dist_sec_cols, collapse=", "), "\n\n")

# Calculate mean across donors and time for each condition
distance_all$mean_dist_IFN_LPS <- rowMeans(distance_all[, dist_IFN_cols, drop = FALSE], na.rm = TRUE)
distance_all$mean_dist_IL10 <- rowMeans(distance_all[, dist_IL10_cols, drop = FALSE], na.rm = TRUE)
distance_all$mean_dist_sec_HepG2 <- rowMeans(distance_all[, dist_sec_cols, drop = FALSE], na.rm = TRUE)

# Calculate differences between means
distance_all$mean_diff_IFN_vs_IL10 <- distance_all$mean_dist_IFN_LPS - distance_all$mean_dist_IL10
distance_all$mean_diff_IL10_vs_IFN <- distance_all$mean_dist_IL10 - distance_all$mean_dist_IFN_LPS
distance_all$mean_diff_sec_HepG2_vs_IFN <- distance_all$mean_dist_sec_HepG2 - distance_all$mean_dist_IFN_LPS

####select genes for each macrophage type when FDR<0.05 & highest difference of mean distances between groups####
##run pre-selection
Filter_posi <- function(x) {
  
  # Define filtering criteria
  fdrFilter <- 0.05
  
  # Apply filtering based on negative logFC and fdr criteria
  x_filter <- x[(as.numeric(as.vector(x$padj)) < fdrFilter), ]
  
  # Return the filtered data
  return(x_filter)
}

IFN_6h <- read_excel("INFLPSat6H.vs.MCSFat0H.xls")
IFN_24h <- read_excel("IFNLPSat24H.vs.MCSFat0H.xls")
IFN_48h<- read_excel("IFNLPSat48H.vs.MCSFat0H.xls")
IFN_6h_good<-Filter_posi(IFN_6h)
IFN_24h_good<-Filter_posi(IFN_24h)
IFN_48h_good<-Filter_posi(IFN_48h)
IFN_6h_good <- IFN_6h_good %>% filter(!is.na(ensembl_gene_id))
IFN_24h_good <- IFN_24h_good %>% filter(!is.na(ensembl_gene_id))
IFN_48h_good <- IFN_48h_good %>% filter(!is.na(ensembl_gene_id))


# Put your data frames into a list
df_list <- list(IFN_6h_good,IFN_24h_good,IFN_48h_good)

# Merge all by "gene" using inner join (only keep genes common to all)
IFN_LPS_2 <- reduce(df_list, ~ inner_join(.x, .y, by = "ensembl_gene_id"))
# Rename the second column as "gene"
colnames(IFN_LPS_2)[2] <- "gene"
IFN_sel<-merge(distance_all,IFN_LPS_2,by="gene")

###IL10
IL10_6h <- read_excel("IL10at6H.vs.MCSFat0H.xls")
IL10_24h <- read_excel("IL10at24H.vs.MCSFat0H.xls")
IL10_48h<- read_excel("IL10at48H.vs.MCSFat0H.xls")
IL10_6h_good<-Filter_posi(IL10_6h)
IL10_24h_good<-Filter_posi(IL10_24h)
IL10_48h_good<-Filter_posi(IL10_48h)
IL10_6h_good <- IL10_6h_good %>% filter(!is.na(ensembl_gene_id))
IL10_24h_good <- IL10_24h_good %>% filter(!is.na(ensembl_gene_id))
IL10_48h_good <- IL10_48h_good %>% filter(!is.na(ensembl_gene_id))

# Put your data frames into a list
df_list <- list(IL10_6h_good,IL10_24h_good,IL10_48h_good)

# Merge all by "gene" using inner join (only keep genes common to all)
IL10_2 <- reduce(df_list, ~ inner_join(.x, .y, by = "ensembl_gene_id"))
colnames(IL10_2)[2] <- "gene"
IL10_sel<-merge(distance_all,IL10_2,by="gene")

###Hep
Hep_6h <- read_excel("HEPG2at6H.vs.MCSFat0H.xls")
Hep_24h <- read_excel("HEPG2at24H.vs.MCSFat0H.xls")
Hep_48h<- read_excel("HEPG2at48H.vs.MCSFat0H.xls")
Hep_6h_good<-Filter_posi(Hep_6h)
Hep_24h_good<-Filter_posi(Hep_24h)
Hep_48h_good<-Filter_posi(Hep_48h)
Hep_6h_good <- Hep_6h_good %>% filter(!is.na(ensembl_gene_id))
Hep_24h_good <- Hep_24h_good %>% filter(!is.na(ensembl_gene_id))
Hep_48h_good <- Hep_48h_good %>% filter(!is.na(ensembl_gene_id))

# Put your data frames into a list
df_list <- list(Hep_6h_good,Hep_24h_good,Hep_48h_good)

# Merge all by "gene" using inner join (only keep genes common to all)
Hep_2 <- reduce(df_list, ~ inner_join(.x, .y, by = "ensembl_gene_id"))
colnames(Hep_2)[2] <- "gene"
Hep_sel<-merge(distance_all,Hep_2,by="gene")

###visualization of results####
##select interested genes
genes_to_select <- c("CSAG3", "CSF3",  "LINC01539","SERPINB7","BCL2L14",
                     "IDO1", "AMOTL2", "ACOD1",  "IDO2", 
                     
                     "TUBB3", "TDO2","CD163", "VWA1","GPR85",  
                     "FPR1","MARCO","PKIB","FCGR3B", 
                     
                     "ADGRE1","ANKRD22","ETS2","FCGR2A", "HSPA1A",   
                     "IL6", "MYO1G", "PTGIR", "SOCS3" )

# Filter the normalized_all dataframe based on the specified genes
Norm_sel <- normalized_all %>% filter(gene %in% genes_to_select)

Norm_sel <- Norm_sel %>%
  mutate(gene = factor(gene, levels = genes_to_select)) %>%
  arrange(gene)
#Remove the the MCSF columns
Norm_sel<-Norm_sel[, !grepl("^MCSF", names(Norm_sel))]

#####heatmap####
cartesiana_cluster<-t(Norm_sel)
# Set the first row as column names
colnames(cartesiana_cluster) <- as.character(cartesiana_cluster[1, ])

# Remove the first row (now used as column names)
cartesiana_cluster <- cartesiana_cluster[-1, ]
# Convert to numeric
cartesiana_cluster <- apply(cartesiana_cluster, 2, as.numeric)

# Convert to data frame
cartesiana_cluster <- as.data.frame(cartesiana_cluster)

# Run mixture modelling using mclust
sigs.BIC3 <- mclustBIC(cartesiana_cluster, G = 3)

# Apply optimal clustering in sigs.BIC
mod_sigs.BIC3 <- Mclust(cartesiana_cluster, x = sigs.BIC3)
table(mod_sigs.BIC3$cartesiana_cluster) # classification

# Define Real_Group (adjust the length if necessary)
Real_Group <- c('IFN_LPS_Macrophage', 'IL10_Macrophage', 'HepG2_Macrophage','IFN_LPS_Macrophage', 'IL10_Macrophage', 'HepG2_Macrophage','IFN_LPS_Macrophage', 'IL10_Macrophage', 'HepG2_Macrophage',
                'IFN_LPS_Macrophage', 'IL10_Macrophage', 'HepG2_Macrophage','IFN_LPS_Macrophage', 'IL10_Macrophage', 'HepG2_Macrophage','IFN_LPS_Macrophage', 'IL10_Macrophage', 'HepG2_Macrophage',
                'IFN_LPS_Macrophage', 'IL10_Macrophage', 'HepG2_Macrophage','IFN_LPS_Macrophage', 'IL10_Macrophage', 'HepG2_Macrophage','IFN_LPS_Macrophage', 'IL10_Macrophage', 'HepG2_Macrophage')

# Ensure Real_Group has enough values for the samples
Real_Group <- rep(Real_Group, length.out = nrow(cartesiana_cluster))

# Define Group_hour (adjust the length if necessary)
Group_hour <- c('IFN_LPS_Macrophage_6h', 'IL10_Macrophage_6h', 'HepG2_Macrophage_6h','IFN_LPS_Macrophage_24h', 'IL10_Macrophage_24h', 'HepG2_Macrophage_24h','IFN_LPS_Macrophage_48h', 'IL10_Macrophage_48h', 'HepG2_Macrophage_48h',
                'IFN_LPS_Macrophage_6h', 'IL10_Macrophage_6h', 'HepG2_Macrophage_6h','IFN_LPS_Macrophage_24h', 'IL10_Macrophage_24h', 'HepG2_Macrophage_24h','IFN_LPS_Macrophage_48h', 'IL10_Macrophage_48h', 'HepG2_Macrophage_48h',
                'IFN_LPS_Macrophage_6h', 'IL10_Macrophage_6h', 'HepG2_Macrophage_6h','IFN_LPS_Macrophage_24h', 'IL10_Macrophage_24h', 'HepG2_Macrophage_24h','IFN_LPS_Macrophage_48h', 'IL10_Macrophage_48h', 'HepG2_Macrophage_48h')

# Ensure Real_Group has enough values for the samples
Group_hour <- rep(Group_hour, length.out = nrow(cartesiana_cluster))

order_levels <-c('IFN_LPS_Macrophage_6h', 'IFN_LPS_Macrophage_24h','IFN_LPS_Macrophage_48h',
                 'IL10_Macrophage_6h','IL10_Macrophage_24h','IL10_Macrophage_48h',
                 'HepG2_Macrophage_6h','HepG2_Macrophage_24h','HepG2_Macrophage_48h')

# Create annotation with finite mixture model clusters
ann3 <- data.frame(
  BIC_clust3 = factor(mod_sigs.BIC3$classification, levels = 1:length(unique(mod_sigs.BIC3$classification))),
  Real_Group = factor(Real_Group),
  Group_hour = factor(Group_hour,levels = order_levels)
)

# Order samples by classification
sigs_order3 <- as.data.frame(t(cartesiana_cluster[rownames(ann3), ]))

library(grDevices)
# Set colours
cols3 <- colorRampPalette(brewer.pal(9,'Set1'))
cols_BIC3 <- rainbow(length(unique(ann3$BIC_clust3)))
names(cols_BIC3) <- unique(ann3$BIC_clust3)

ann_colors3 = list(BIC_clust3 = cols_BIC3)

# Use white -> navy scale
cols_scale3 <- colorRampPalette(colors = c('white','navy'))(1000)

pheno <- c('IFN_LPS_Macrophage', 'IL10_Macrophage', 'HepG2_Macrophage')


ann3$Phenotype <- factor(pheno[as.numeric(ann3$BIC_clust3)],
                         levels = sort(pheno))

ann3 <- ann3[order(ann3$Phenotype), ]

sigs_order3 <- sigs_order3[, rownames(ann3)]

# Redo heatmap with phenotype labels
cols_Pheno3 <- rainbow(length(unique(ann3$Phenotype)))
names(cols_Pheno3) <- unique(ann3$Phenotype)

cols_RealGroup <- rainbow(length(unique(ann3$Real_Group)))
names(cols_RealGroup) <- levels(ann3$Real_Group)

# Define custom colors for Phenotype
cols_Pheno3 <- c(
  "IFN_LPS_Macrophage" = "green",
  "IL10_Macrophage" = "blue",
  "HepG2_Macrophage" = "orange"
)

# Assign colors to Real_Group if needed (example)
cols_RealGroup <- c(
  "IFN_LPS_Macrophage" = "green",
  "IL10_Macrophage" = "blue",
  "HepG2_Macrophage" = "orange"
)

# Ensure the names match the levels of `ann3$Phenotype` and `ann3$Real_Group`
names(cols_Pheno3) <- levels(factor(ann3$Phenotype))
names(cols_RealGroup) <- levels(factor(ann3$Real_Group))

# Now you can use these color mappings for your heatmap


# Generate a custom color palette for Group_hour using colorRampPalette
cols_GroupHour <- colorRampPalette(brewer.pal(12, "Paired"))(length(unique(ann3$Group_hour)))
names(cols_GroupHour) <- levels(ann3$Group_hour)

#assign diferent intensity of color
df <- ann3
df$Group <- sub("_[0-9]+h$", "", df$Group_hour)     # extract "x_group"
df$Hour  <- sub(".*_([0-9]+)h$", "\\1", df$Group_hour)  # extract numeric hour
df$Hour  <- as.numeric(df$Hour)

library(scales)  # for lighten() and darken()
library(colorspace)

cols_GroupHour <- c()

for (g in unique(df$Group)) {
  
  base_col <- cols_RealGroup[g]
  
  # timepoints for this group
  hrs <- unique(df$Group_hour[df$Group == g])
  n <- length(hrs)
  
  # generate lighter → original colors
  pal <- seq(0.6, 0, length.out = n)  # 0.6 = lighter, 0 = original
  pal <- lighten(base_col, pal)       # produce lighter to base color
  
  names(pal) <- hrs
  cols_GroupHour <- c(cols_GroupHour, pal)
}


ann_colors3 <- list(Phenotype = cols_Pheno3,
                    Real_Group = cols_RealGroup,
                    Group_hour = cols_GroupHour
)

p <- pheatmap(sigs_order3, 
              cluster_cols = FALSE, 
              show_colnames = FALSE,
              annotation_col = ann3[c('Phenotype','Real_Group','Group_hour')], 
              annotation_colors = ann_colors3,
              color = cols_scale3, 
              fontsize = 14, 
              fontsize_row = 14,
              labels_row = parse(text = paste0("italic('", rownames(sigs_order3), "')"))
)

print(p)

#####PCA##########
library(vegan)
library(factoextra)

df <- t(Norm_sel)
# Convert to data frame
df <- as.data.frame(df)

# Set the first row as column names
colnames(df) <- as.character(df[1, ])

# Remove the first row (now used as column names)
df <- df[-1, ]

Group<-rep(c("IFN_LPS_macrophage","IL10_macrophage","HepG2_macrophage"),9)
# Add rownames as a new column
df$Group <- Group
# Convert only non-Group columns to numeric
num_cols <- setdiff(names(df), "Group")
df[, num_cols] <- lapply(df[, num_cols], as.numeric)

cR.pca<-prcomp(df[,1:27])
summary(cR.pca)
fviz_eig(cR.pca, addlabels = T)
names(cR.pca)
fviz_pca_ind(cR.pca,col.ind = df$Group,
             addEllipses = T,geom = ("point"))

p <- fviz_pca_ind(cR.pca,
                  alpha.ind = 1,
                  habillage = df$Group,
                  geom = c("point"),
                  invisible = "quali",
                  addEllipses = TRUE,
                  ellipse.level = 0.95,
                  palette = c("green", "blue", "orange")  # Custom colors
)+
  
  # Customize theme
  theme(
    plot.title = element_text(size = 20, hjust = 0.5),
    legend.title = element_text(size = 15),
    legend.text = element_text(size = 15),
    
    # Make axis text and labels bold and bigger
    axis.text = element_text(size = 16, face = "bold"),  # Tick labels
    axis.title = element_text(size = 18, face = "bold")  # Axis labels
  )

print(p)

# ============================================================================
# Polarization speed analysis
# ============================================================================

##3D distance calculation function
calculate_3D_distance <- function(x, n_group = 9) {
  
  # Remove the gene column if it exists
  if ("gene" %in% colnames(x)) {
    dif_matrix <- x %>% select(-gene)
  } else {
    dif_matrix <- x
  }
  
  n_total <- nrow(dif_matrix)
  n_groups <- ceiling(n_total / n_group)
  
  # Function to calculate sqrt(sum) for each block
  dist_3D_cal <- function(vec, block_size = n_group) {
    sapply(seq(1, length(vec), by = block_size), function(i) {
      sqrt(sum(vec[i:min(i + block_size - 1, length(vec))], na.rm = TRUE))
    })
  }
  
  # Calculate 3D distance for all columns
  result_3D <- sapply(dif_matrix, dist_3D_cal, block_size = n_group)
  result_3D <- as.data.frame(result_3D)
  
  # Set row names for clusters
  cluster_names <- c("IFN_LPS_cluster", "IL10_cluster", "HepG2_cluster")
  if (nrow(result_3D) == length(cluster_names)) {
    rownames(result_3D) <- cluster_names
  } else {
    rownames(result_3D) <- paste0("Cluster_", 1:nrow(result_3D))
  }
  
  return(result_3D)
}
##polarization speed calcularion function
pol_cal <- function(x) {  # Initialize dataframe for polar coordinates
  # Initialize dataframe for polarization speed (1 row × 27 columns: 9 per donor)
  pol <- data.frame(matrix(ncol = 27, nrow = 1))
  
  # Set column names for each donor
  donor_names <- c("D24", "D25", "D27")
  conditions <- c("IFNLPS", "IL10", "HepG2")
  time_points <- c("6h", "24h", "48h")
  
  col_names <- c()
  for (donor in donor_names) {
    for (condition in conditions) {
      for (time in time_points) {
        col_names <- c(col_names, paste0(condition, "_", time, "_", donor))
      }
    }
  }
  colnames(pol) <- col_names
  
  # Process each donor separately
  for (donor_idx in 1:3) {
    donor_name <- donor_names[donor_idx]
    
    # Calculate column indices for this donor (9 columns per donor)
    start_col <- (donor_idx - 1) * 9 + 1
    end_col <- donor_idx * 9
    
    # Extract data for this donor (3 rows × 9 columns)
    donor_data <- x[, start_col:end_col]
    
    # Extract rows for each cluster
    IFN_LPS_vals <- as.numeric(donor_data["IFN_LPS_cluster", ])
    IL10_vals <- as.numeric(donor_data["IL10_cluster", ])
    HepG2_vals <- as.numeric(donor_data["HepG2_cluster", ])
    
    # Calculate polarization speed for IFN_LPS gene cluster
    IFNLPS_6h <- sqrt(IFN_LPS_vals[1]^2 + IL10_vals[1]^2 + HepG2_vals[1]^2) / 6
    IFNLPS_24h <- sqrt((IFN_LPS_vals[4] - IFN_LPS_vals[1])^2 + 
                         (IL10_vals[4] - IL10_vals[1])^2 + 
                         (HepG2_vals[4] - HepG2_vals[1])^2) / (24 - 6)
    IFNLPS_48h <- sqrt((IFN_LPS_vals[7] - IFN_LPS_vals[4])^2 + 
                         (IL10_vals[7] - IL10_vals[4])^2 + 
                         (HepG2_vals[7] - HepG2_vals[4])^2) / (48 - 24)
    
    # Calculate polarization speed for IL10 gene cluster
    IL10_6h <- sqrt(IFN_LPS_vals[2]^2 + IL10_vals[2]^2 + HepG2_vals[2]^2) / 6
    IL10_24h <- sqrt((IFN_LPS_vals[5] - IFN_LPS_vals[2])^2 + 
                       (IL10_vals[5] - IL10_vals[2])^2 + 
                       (HepG2_vals[5] - HepG2_vals[2])^2) / (24 - 6)
    IL10_48h <- sqrt((IFN_LPS_vals[8] - IFN_LPS_vals[5])^2 + 
                       (IL10_vals[8] - IL10_vals[5])^2 + 
                       (HepG2_vals[8] - HepG2_vals[5])^2) / (48 - 24)
    
    # Calculate polarization speed for HepG2 cluster
    HepG2_6h <- sqrt(IFN_LPS_vals[3]^2 + IL10_vals[3]^2 + HepG2_vals[3]^2) / 6
    HepG2_24h <- sqrt((IFN_LPS_vals[6] - IFN_LPS_vals[3])^2 + 
                        (IL10_vals[6] - IL10_vals[3])^2 + 
                        (HepG2_vals[6] - HepG2_vals[3])^2) / (24 - 6)
    HepG2_48h <- sqrt((IFN_LPS_vals[9] - IFN_LPS_vals[6])^2 + 
                        (IL10_vals[9] - IL10_vals[6])^2 + 
                        (HepG2_vals[9] - HepG2_vals[6])^2) / (48 - 24)
    
    # Assign values to polarization speed dataframe with donor suffix
    pol[[paste0("IFNLPS_6h_", donor_name)]] <- IFNLPS_6h
    pol[[paste0("IFNLPS_24h_", donor_name)]] <- IFNLPS_24h
    pol[[paste0("IFNLPS_48h_", donor_name)]] <- IFNLPS_48h
    pol[[paste0("IL10_6h_", donor_name)]] <- IL10_6h
    pol[[paste0("IL10_24h_", donor_name)]] <- IL10_24h
    pol[[paste0("IL10_48h_", donor_name)]] <- IL10_48h
    pol[[paste0("HepG2_6h_", donor_name)]] <- HepG2_6h
    pol[[paste0("HepG2_24h_", donor_name)]] <- HepG2_24h
    pol[[paste0("HepG2_48h_", donor_name)]] <- HepG2_48h
  }
  
  return(pol)
}

##run analysis
### Filter the differences_all dataframe based on the specified genes
diff_sel <- differences_all %>% filter(gene %in% genes_to_select)

diff_sel <- diff_sel %>%
  mutate(gene = factor(gene, levels = genes_to_select)) %>%
  arrange(gene)

###calculate 3D distances
Distance_3D <- calculate_3D_distance(diff_sel, n_group = 9)

###calculate polarization speed
pol_speed<-pol_cal(Distance_3D)

#####Reshape from wide to long format
pol_long <- pol_speed %>%
  pivot_longer(
    cols = everything(),
    names_to = c("Group", "Time_h", "Donor"),
    names_pattern = "(.+)_(\\d+)h_(D\\d+)",
    values_to = "speed"
  ) %>%
  mutate(
    # Convert Time from string to numeric
    Hours = as.numeric(Time_h),
    # Rename Group values to full names
    Group = case_when(
      Group == "IFNLPS" ~ "IFN_LPS_Macrophage",
      Group == "IL10" ~ "IL10_Macrophage",
      Group == "HepG2" ~ "HepG2_Macrophage"
    )
  ) %>%
  # Remove the temporary Time_h column
  select(-Time_h) %>%
  # Reorder columns
  select(Donor, Group, Hours, speed) %>%
  # Arrange for better readability
  arrange(Donor, Group, Hours)

####visualization of result####
# Define colors for IFN_LPS, IL10 and HepG2
colors <- c("IFN_LPS_Macrophage" = "blue", "IL10_Macrophage" = "orange", "HepG2_Macrophage" = "green")

# Convert Hours to numeric
pol_long$Hours <- as.numeric(as.character(pol_long$Hours))

# Create intervals for display on x-axis
pol_long <- pol_long %>%
  mutate(HourGroup = cut(Hours, breaks = c(0, 6, 24, 48),
                         labels = c("[0,6]", "[6,24]", "[24,48]"),
                         include.lowest = TRUE))

# Calculate the mean speed per group per interval
mean_data <- pol_long %>%
  group_by(Group, HourGroup) %>%
  summarise(mean_speed = mean(speed), .groups = "drop")

# Create the plot
p <- ggplot(pol_long, aes(x = HourGroup, y = speed, color = Group)) +
  
  # Individual points (jitter to separate overlapping)
  geom_point(size = 2, alpha = 0.6, position = position_jitter(width = 0.1)) +
  
  # Mean points
  geom_point(data = mean_data, aes(x = HourGroup, y = mean_speed),
             size = 3, shape = 17, position = position_dodge(width = 0.3)) +
  
  # Lines for mean values (grouped)
  geom_line(data = mean_data, aes(x = HourGroup, y = mean_speed, group = Group),
            size = 1.2, position = position_dodge(width = 0.3)) +
  
  scale_color_manual(values = colors) +
  
  ylim(-0.01, 1.2) +
  
  labs(
    x = "Time Interval (h)",
    y = "Polarization Speed (/h)"
  ) +
  
  theme(
    plot.title = element_text(size = 20, hjust = 0.5),
    axis.title = element_text(size = 18, face = "bold"),
    axis.text = element_text(size = 15, face = "bold"),
    legend.title = element_text(size = 18),
    legend.text = element_text(size = 15)
  )

print(p)