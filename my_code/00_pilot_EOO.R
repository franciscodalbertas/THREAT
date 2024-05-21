
# install packages -----------------------------------------------------------
install.packages("ConR")
install.packages("sp")
install.packages("devtools")
devtools::install_github("gdauby/ConR")
install.packages('lwgeom')

#- packages -----------------------------------------------------------------

library(dplyr)
library(ConR)
b
#----------------------------------------------------------------------------

# use spp suggested by CNCflora

# Narrow distribution: Griffinia colatinensis; Discocactus horstii
# Wide distribution: Euterpe edulis; Caryocar cuneatum
# Many records (non-endemic to BR): Apuleia leiocarpa

# R/ script 10 has how they calculated EOO

#### LOADING ACCESSORY FUNCTIONS ###

source("./R/99_functions.R")

#### LOADING THE NEOTROPICS MAP ###
neotrop.simp <- readRDS("data/Contour_Neotrop_simplified_tol_005_no_small.rds")

#### LOADING THREAT OCCURRENCE DATA (HERBARIUM + PLOT INVENTORIES) ###

oc.data <- readRDS("data/threat_occ_data_final.rds")

#Putting data in the ConR format
MyData <- oc.data[, c("ddlat","ddlon",
                      "tax","higher.tax.rank",
                      "coly","vouchers",
                      "detBy","dety",
                      "tax.check2","tax.check.final","UC",
                      "dist.eoo","tax.conf","source")]

MyData$tax.check2 <- MyData$tax.check2 %in% "TRUE" # the super confidence level

rm(oc.data)

# spp list suggested by CNCflora (only 2 were included in Renato's data)

spp_flt <- c("Euterpe edulis","Apuleia leiocarpa")

# filtering the data to the above spp. list

MyData_f <- filter(MyData, tax %in% spp_flt)


#---- EXTENT OF OCCURRENCE (EOO) -----------------------------------------------

## Convex Hull method
system.time(
EOO.hull <- ConR::EOO.computing(XY = MyData_f[grepl("high", MyData_f$tax.check.final), c(1:3)],
                    method.range = "convex.hull",
                    export_shp = TRUE,
                    parallel = F, # parallelize
                    NbeCores = 1) # how many cores?
)

 
#extracting the EOO from the object
EOO <- do.call(rbind.data.frame, EOO.hull[grepl("eoo", names(EOO.hull$results))])

# saving spp. ranges

getwd()
dir.create("EOO")
saveRDS(EOO, "EOO/spp.convex.hull.polys_sf_uncropped.rds")

