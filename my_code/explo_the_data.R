library(sp)

head(readRDS( "data/AOO.rds"))
head(readRDS("data/EOO_AtlanticForest_cropped.rds"))

EOO_af <- readRDS("data/EOO_AtlanticForest_cropped.rds")
EOO_conv_hull <- readRDS("data/EOO.convex.hull_uncropped.rds")
af_g <-  readRDS("data/af_hex_grid_50km.rds")
results <- readRDS("data/grid.results_50km.rds")
AOO <- readRDS("data/AOO.rds")
head(EOO_af)
head(af_g)
head(results[[1]])
nrow(results[[1]])
head(EOO_conv_hull)
treeco <- readRDS("data/treeco_inventory_records.rds")
threat <- readRDS("data/threat_occ_data_final.rds")
# not clear how to connect spp. entries with spatial data (yet). 
sppEOO <- readRDS("data/")

grid_res <- readRDS("C:/Users/franc/OneDrive - University of Cambridge/repositories/THREAT/data/grid.results_50km.rds")

grid_res[[1]]

plot(grid_res[[2]])
# It looks like EOO and AOO are not supplied, but the code on how to get it is. Would have to calculate it.
# 
# the ConR cam solve most of it:
# the ConR package provides functions for calculating the Extent of Occurrence (EOO - ConR::EOO.computing()), Area of Occupancy (AOO - ConR::AOO.computing()), Number of Subpopulations (ConR::subpop.comp()) and Number of Locations (ConR:::locations.comp
# the package provides a function ConR::AOH.estimation() to calculate the amount and the change in available habitat within the species EOO. 


install.packages("devtools")
devtools::install_github("gdauby/ConR")

library(ConR)

?ConR::EOO.comp()
