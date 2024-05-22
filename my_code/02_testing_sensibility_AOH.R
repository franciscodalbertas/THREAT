library(dplyr)
library(ConR)
library(geobr)

# easier to convert everything to a projection to calculate areas easily!
# define a projection: albers! from this source: https://epsg.io/102033

proj="+proj=aea +lat_0=-32 +lon_0=-60 +lat_1=-5 +lat_2=-42 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs +type=crs" 

#albers with 1000m

# subsampling observations from a spp with lots of entries to see when AOH starts to be really bad.

af <- st_read(dsn= "data/AF_limits/merge_limites_MA11428_TNC_ARG_BR_PAR.shp")

af_pj <- af%>%
  st_transform(st_crs(proj)) 

# Apuleia leiocarpa

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

# spp list suggested by CNCflora (only 2 were included in Renato's data)

spp_flt <- c("Apuleia leiocarpa")

# filtering the data to the above spp. list

MyData_f <- dplyr::filter(MyData,tax %in%spp_flt) # 913 obs within the AF

# check n obs from CNCFlora

p <- "../../Data/" # path for datasets

Apuleira_CNCflora <- read.csv(file.path(p,"CNCFlora","Apuleia_leiocarpa.csv")) # 951. very similar
Apuleira_CNCflora_high_acc <- dplyr::filter(Apuleira_CNCflora,valid == "true") # 613

#Putting data in the ConR format

CNCfloraData_high_acc <- Apuleira_CNCflora_high_acc[, c("decimalLatitude","decimalLongitude",
                      "scientificName")]



# using only measurements with high accuracy

MyData_f_high_acc <- dplyr::filter(MyData_f,tax.check.final == "high") # only 236!!

# comparing EOO from the different datasets -- for now using the AF for which I have habitat data

EOO.CNCFlora <- ConR::EOO.computing(XY = CNCfloraData_high_acc,
                                method.range = "convex.hull",
                                export_shp = TRUE,
                                parallel = F,
                                exclude.area = T,
                                country_map = af)

EOO.THREAT <- ConR::EOO.computing(XY = MyData_f_high_acc,
                                    method.range = "convex.hull",
                                    export_shp = TRUE,
                                    parallel = F,
                                  exclude.area = T,
                                  country_map = af)

#extracting the EOO from the object
EOO.CNCFlora <- do.call(rbind.data.frame, EOO.CNCFlora[grepl("eoo", names(EOO.CNCFlora$results))])
EOO.THREAT <- do.call(rbind.data.frame, EOO.THREAT[grepl("eoo", names(EOO.THREAT$results))])

# transforming to albers

EOO.CNCFlora <- st_transform(EOO.CNCFlora,proj)
EOO.THREAT <- st_transform(EOO.THREAT,proj)

# vizualizing

plot(af$geometry)
plot(EOO.CNCFlora$geometry,add=T,col='red')
plot(EOO.THREAT,add=T,col="green") # small changes

# habitat for the AF

hab2015 <- rast(paste0("data/ESA_Land_Cover_map_", 2000, "_2015_AF_1km.tif"))[[2]]

# habitat info.

toto <- read.csv("data/ESACCI-LC-Legend.csv", as.is=TRUE)
hab.class <- toto$NB_LAB[grepl("ForestCover", toto$LegendTreeCoSimp)]

# reclassify raster to binary

# Reclassify the raster: values in 'values_to_one' to 1, others to 0
hab2015_bin <- classify(hab2015, rcl=cbind(hab.class, 1))

# Set all other values to 0
hab2015_bin[hab2015_bin != 1] <- 0

# project to albers with 1km res

hab2015_bin_proj <- terra::project(hab2015_bin,proj,method="near")

# calculating AOH from the 2 datasets. This has already some differences

source("my_code/functions/AOH.R")

AOH_CNCFlora <- AOH(EOO.CNCFlora,habitat =hab2015_bin_proj,year = 2015 )
AOH_THREAT <- AOH(EOO.THREAT,habitat =hab2015_bin_proj,year = 2015 )

# sampling the dataset
# 100-15% in 15% junps

nCNCFlora <- nrow(CNCfloraData)
sample_sizes <- c(round(seq(.15,1,.15)*nCNCFlora),nCNCFlora)

AOH_list <- list()
c <- 1
for (i in sample_sizes){
  # will need to do it 100x 
  df<-CNCfloraData[ sample(1:nCNCFlora, i),]
  EOO_s <- ConR::EOO.computing(XY = df,
                      method.range = "convex.hull",
                      export_shp = TRUE,
                      parallel = F,
                      exclude.area = T,
                      country_map = af)
  
  #extracting the EOO from the object
  EOO_s <- do.call(rbind.data.frame, EOO_s[grepl("eoo", names(EOO_s$results))])
  EOO_s <- st_transform(EOO_s,proj)
  AOH_s <- AOH(EOO_s,habitat =hab2015_bin_proj,year = 2015 )
  # adding sample size
  AOH_s$sample <- i
  AOH_list[[c]] <- AOH_s
  c = c + 1
  }

AOH_combined <- do.call(rbind,AOH_list)

AOH_combined$ratio <- AOH_combined$sample/613

plot(AOH_combined$AOH.area~AOH_combined$ratio)

# continue but generate more simulation points!!!