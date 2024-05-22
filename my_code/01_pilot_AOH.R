#### LOADING THE REQUIRED PACKAGES AND FUNCTIONS ####
require(ConR)
require(raster)
require(sf)
require(lwgeom)
# require(rgdal)
# require(rgeos)
require(cleangeo)
#source("R//99_functions.R")
library(terra)

# AF limits

af <- st_read(dsn= "data/AF_limits/merge_limites_MA11428_TNC_ARG_BR_PAR.shp")

#### LOADING THREAT OCCURRENCE DATA (HERBARIUM + PLOT INVENTORIES) ###

oc.data <- readRDS("data/threat_occ_data_final.rds")

# Putting data in the ConR format
MyData <- oc.data[, c("ddlat","ddlon",
                      "tax","higher.tax.rank",
                      "coly","vouchers",
                      "detBy","dety",
                      "tax.check2","tax.check.final","UC",
                      "dist.eoo","tax.conf","source")]
MyData$tax.check2 <- MyData$tax.check2 %in% "TRUE" # the super,hyper high confidence level

rm(oc.data)


# spp list suggested by CNCflora (only 2 were included in Renato's data)

spp_flt <- c("Euterpe edulis","Apuleia leiocarpa")

# filtering the data to the above spp. list

MyData_f <- dplyr::filter(MyData,tax %in%spp_flt[1])

## Loading aggregated rasters and extracting the habitat loss/quality (2000-2015)
# ano1 = 2000
# hab.map <- raster::stack(paste0("data/ESA_Land_Cover_map_", ano1, "_2015_AF_1km.tif"))
# names(hab.map) <- paste("ESA",c(ano1,2015), sep=".")
# anos <- 2015 - ano1 

hab2015 <- rast(paste0("data/ESA_Land_Cover_map_", ano1, "_2015_AF_1km.tif"))[[2]]

## Getting forest cover classes fro ESA LC map

toto <- read.csv("data/ESACCI-LC-Legend.csv", as.is=TRUE)
hab.class <- toto$NB_LAB[grepl("ForestCover", toto$LegendTreeCoSimp)]




# entry data must be xy data
# problem with package raster!!
# 

AOH <- ConR::AOH.estimation(XY =MyData_f,
                            show_progress = T,
                            hab.map =hab2015, # 2015
                            hab.class = hab.class,
                            #country_map = af,
                            parallel = F,
                            NbeCores = 1,
                            exclude.area = T)



# from the LIFE paper
# For current AOH we used a map of the estimated distribution of habitats (43) in 2016. For original AOH we used a map of Potential Natural Vegetation (PNV) (44) which estimates 35 the distribution of habitat types in the absence of human impacts.
# 43: Jung M, Dahal PR, Butchart SHM, Donald PF, De Lamo X, Lesiv M, et al. A global map of terrestrial 29 habitat types. Sci Data. 2020 Aug 5;7(1):256.
# 44: Jung M. A layer of global potential habitats [Internet]. 2020. Available from: 31 https://zenodo.org/record/4038749
# 
