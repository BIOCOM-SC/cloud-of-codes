# CDBGE selector
## Summary
### CDBGE selector is a bioinformatics tool designed to identify  differentially expressed genes between two or more conditions and to select  those that best characterize cellular phenotypes, based on the cartesian distance algorithm.
## Cartesian distance calculation workflow
### 1. DEG analysis
#### Perform the DEG between conditions to obtain log2 fold changes (log2FC), p-values, and false discovery rates (FDR)

### 2. Calculate the cartesian distance with the CDBGE_selector.R
#### Perform separately for each sample

### 3. Filter casrtesian distance file to include only genes with FDR less than 0.05 

### 4. Calculate the mean value across all samples, then calculate the difference between the groups you want to separate.

### 5. For each group, genes with the highest values are selected

### 6. Visualize the results using heatmaps and PCA based on normalized gene expression data of selected genes

## Polarization speed calculation workflow

### 1. Calculate distance separately for each gene cluster

### 2. Calculate the polarization speed as the ratio between the change in distance and the corresponding time interval. 

### 3. Visualize of the results
