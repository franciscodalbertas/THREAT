# packages ---------------------------------------------------------------------
library(tidyr)
library(ConR)
library(dplyr)
library(rgeos)
library(geobr)
#-------------------------------------------------------------------------------

#### LOADING ACCESSORY FUNCTIONS ###
source("./R/99_functions.R")

# testin EOO for one spp

#### LOADING THREAT OCCURRENCE DATA (HERBARIUM + PLOT INVENTORIES) ###

oc.data <- readRDS("data/threat_occ_data_final.rds")

#Putting data in the ConR format
MyData <- oc.data[, c("ddlat","ddlon",
                      "tax","higher.tax.rank",
                      "coly","vouchers",
                      "detBy","dety",
                      "tax.check2","tax.check.final","UC",
                      "dist.eoo","tax.conf","source")]
MyData$tax.check2 <- MyData$tax.check2 %in% "TRUE" # the super,hyper high confidence level
rm(oc.data)

#### OBTAINING THE NAME AND NUMBER OF OCCURRENCES (TOTAL AND SPATIALLY-UNIQUE) PER SPECIES 
resultado <- readRDS("data/assess_iucn_spp.rds")

names(resultado)[which(names(resultado) %in% 
                         c("family.correct1","species.correct2"))] <- c("family","tax")



# filtering for one spp. only

MyData_filt <- filter(.data = MyData, MyData$tax == resultado$tax[1])





system.time(
  EOO.hull <- my.EOO.computing(MyData_filt[grepl("high", MyData_filt$tax.check.final), c(1:3)], 
                               method = "convex.hull",
                               method.less.than3 = "not comp",
                               export_shp = TRUE,
                               # exclude.area = TRUE, country_map = neotrop.simp, # If 'exclude.area' is TRUE, the EEO is cropped using the shapefile defined in the argument country_map
                               exclude.area = FALSE, country_map = NULL, # If 'exclude.area' is TRUE, the EEO is cropped using the shapefile defined in the argument country_map
                               write_shp = FALSE, # If TRUE, a directory named 'shapesIUCN' is created to receive all the shapefiles created for computing EOO
                               write_results=FALSE, file.name = "EOO.hull", # If TRUE, a csv fiel is created in the working directory
                               parallel = F, NbeCores = 0) # run on parallel? How many cores?
)

Br <- read_country()
eoo_test <- ConR::EOO.computing(XY = MyData_filt,exclude.area = F,export_shp = T,show_progress = T)

plot(st_geometry(Br))
plot(eoo_test[[2]],add=T)

AOO <- ConR::AOO.computing(MyData_filt,show_progress = T,export_shp = T)
plot(AOO[[2]],add=T)
AOO$AOO
?AOO.computing

plot(AOO$AOO_poly)

?AOH.estimation() # computes the amount of habit within EOO of each species.

# #extracting the EOO from the object
# EOO <- do.call(rbind.data.frame, eoo_test[grepl("eoo", names(eoo_test))])
# plot(eoo_test)
# shps <- eoo_test[grepl("spatial.polygon", names(eoo_test))]
