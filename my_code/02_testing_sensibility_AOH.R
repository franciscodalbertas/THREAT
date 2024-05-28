# packages ---------------------------------------------------------------------

library(dplyr)
library(ConR)
library(geobr)
library(sf)
library(terra)
library(ggpubr)
library(foreach)
library(doParallel)
library(raster)

#-------------------------------------------------------------------------------

# try again to parallelize latter

# easier to convert everything to a projection to calculate areas easily!
# define a projection: albers! from this source: https://epsg.io/102033

# changing the foreach to spp

# focusing in CNCFlora data

# Albers projection

proj="+proj=aea +lat_0=-32 +lon_0=-60 +lat_1=-5 +lat_2=-42 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs +type=crs" 

#albers with 1000m

# subsampling observations from a spp with lots of entries to see when AOH starts to be really bad.

# Atlantic forest non-projected

af <- st_read(dsn= "data/AF_limits/merge_limites_MA11428_TNC_ARG_BR_PAR.shp")

# projected

af_pj <- af%>%
  st_transform(st_crs(proj))

################################################################################
# lulc data (isso tem q ser feito em outro script, pq o raster tem q entrar no foreach)
################################################################################

# hab2015 <- rast(paste0("data/ESA_Land_Cover_map_", 2000, "_2015_AF_1km.tif"))[[2]]
# # 
# # # habitat info.
# # 
# toto <- read.csv("data/ESACCI-LC-Legend.csv", as.is=TRUE)
# #hab.class <- toto$NB_LAB[grepl("ForestCover", toto$LegendTreeCoSimp)]
# # 
# # # reclassify raster to binary
# # 
# # Reclassify the raster: values in 'values_to_one' to 1, others to 0
# #hab2015_bin <- classify(hab2015, rcl=cbind(hab.class, 1))
# # 
# # Set all other values to 0
# #hab2015_bin[hab2015_bin != 1] <- 0
# # 
# # # project to albers with 1km res
# # 
# #hab2015_bin_proj <- terra::project(hab2015_bin,proj,method="near")
# # 
# # writeRaster(hab2015_bin_proj,"data/../../../Data/THREAT/reprojected_rasters/habitat_AF_reprojected.tif")

hab2015_bin_proj <- raster("data/../../../Data/THREAT/reprojected_rasters/habitat_AF_reprojected.tif")


# function to calculate AOH

source("my_code/functions/AOH.R")
source("my_code/functions/run_AOH.R")

#### LOADING THREAT OCCURRENCE DATA (HERBARIUM + PLOT INVENTORIES) ###

# oc.data <- readRDS("data/threat_occ_data_final.rds")
# 
# #Putting data in the ConR format
# MyData <- oc.data[, c("ddlat","ddlon",
#                       "tax","higher.tax.rank",
#                       "coly","vouchers",
#                       "detBy","dety",
#                       "tax.check2","tax.check.final","UC",
#                       "dist.eoo","tax.conf","source")]
# MyData$tax.check2 <- MyData$tax.check2 %in% "TRUE" # the super,hyper high confidence level
# 
# rm(oc.data)

# spp list suggested by CNCflora (only 2 were included in Renato's data)

# spp_flt <- c("Apuleia leiocarpa")

# filtering the data to the above spp. list

#MyData_f <- dplyr::filter(MyData,tax %in%spp_flt) # 913 obs within the AF

# check n obs from CNCFlora

p <- "../../Data/" # path for datasets

spp_files <- list.files(file.path(p,"CNCFlora"),full.names = T,recursive = F)[2:6]
spp_nms <- gsub(pattern = ".csv",replacement = "",list.files(file.path(p,"CNCFlora"),full.names = F,recursive = F)[2:6])

for(j in seq_along(spp_files)[2:5]){
  
  # open file
  
  spp_CNCflora <- read.csv(spp_files[j]) 
  
  # filter validated data
  
  spp_CNCflora_high_acc <- dplyr::filter(spp_CNCflora,valid == "true") # 613
  
  # disconsidering subspecies
  
  spp_CNCflora_high_acc$spp <- spp_nms[j]
  
  #Putting data in the ConR format
  
  spp_CNCflora_high_acc <- spp_CNCflora_high_acc[, c("decimalLatitude","decimalLongitude","spp")]
  
  # using only measurements with high accuracy
  
  # MyData_f_high_acc <- dplyr::filter(MyData_f,tax.check.final == "high") # only 236!!
  
  # comparing EOO from the different datasets -- for now using the AF for which I have habitat data
  
  # EOO.CNCFlora <- ConR::EOO.computing(XY = spp_CNCflora_high_acc,
  #                                 method.range = "convex.hull",
  #                                 export_shp = TRUE,
  #                                 parallel = F,
  #                                 exclude.area = T,
  #                                 country_map = af)
  # 
  # EOO.THREAT <- ConR::EOO.computing(XY = MyData_f_high_acc,
  #                                     method.range = "convex.hull",
  #                                     export_shp = TRUE,
  #                                     parallel = F,
  #                                   exclude.area = T,
  #                                   country_map = af)
  
  #extracting the EOO from the object
  # EOO.CNCFlora <- do.call(rbind.data.frame, EOO.CNCFlora[grepl("eoo", names(EOO.CNCFlora$results))])
  # EOO.THREAT <- do.call(rbind.data.frame, EOO.THREAT[grepl("eoo", names(EOO.THREAT$results))])
  
  # transforming to albers
  
  # EOO.CNCFlora <- st_transform(EOO.CNCFlora,proj)
  # EOO.THREAT <- st_transform(EOO.THREAT,proj)
  
  # vizualizing
  
  # plot(af_pj$geometry)
  # plot(EOO.CNCFlora$geometry,add=T,col='red')
  # plot(EOO.THREAT,add=T,col="green") # small changes
  
  # habitat for the AF
  
  
  
  # calculating AOH from the 2 datasets. This has already some differences
  
  
  
  # AOH_CNCFlora <- AOH(EOO.CNCFlora,habitat =hab2015_bin_proj,year = 2015 )
  # AOH_THREAT <- AOH(EOO.THREAT,habitat =hab2015_bin_proj,year = 2015 )
  
  # sampling the dataset
  # 100-15% in 15% junps
  
  # getting n. occurences
  
  nocurr <- nrow(spp_CNCflora_high_acc)
  
  sample_sizes <- c(round(seq(.15,1,.15)*nocurr),nocurr)
  
  #iterations <- 1 # Number of iterations
  
  # run iterations in parallel
  # Export necessary objects and packages to each worker
  # clusterExport(cl, varlist = c("run_analysis", "spp_CNCflora_high_acc", "af", "hab2015_bin_proj", "iterations"))
  # clusterEvalQ(cl, {
  #   library(ConR)
  #   library(sf)
  #   library(dplyr)
  #   library(raster)
  # })
  iterations <- 100
  # Initialize list to store results
  
  AOH_list <- vector("list", length(sample_sizes) * iterations)
  # 
  # # Counter for the list index
  # 
  c <- 1
  # 
  # Run the analysis for each sample size, 100 times each (needs parallelizing)
  
  for (nn in sample_sizes) {
  # results <- replicate(iterations,
  #                      run_analysis(nn,
  #                                   data = spp_CNCflora_high_acc,
  #                                   ncores=1,
  #                                   parallel=F,
  #                                   country_map=af,
  #                                   habitat=hab2015_bin_proj),
  #                      simplify = F)
    results <- replicate(iterations,
                         tryCatch(
                           run_analysis(nn,
                                        data = spp_CNCflora_high_acc,
                                        ncores=1,
                                        parallel=F,
                                        country_map=af,
                                        habitat=hab2015_bin_proj),
                           error = function(e) NULL
                         ),
                         simplify = F)
    
    # Filter out NULL results (which were errors)
    
    valid_results <- Filter(Negate(is.null), results)
    
    if (length(valid_results) > 0) {
      AOH_combined <- do.call(rbind, valid_results)
      AOH_list[[c]] <- AOH_combined
      c <- c + 1
    
    # for (result in results) {
    #   AOH_combined <- do.call(rbind, results)
    #   AOH_list[[c]] <- AOH_combined
    #   c <- c + 1
    # 
    }
  }

  
  # Number of cores to use
  #ncores <- 4 # Leave one core free
  #cl <- makeCluster(ncores,outfile = "")
  #registerDoParallel(cl)
  # pra funcionar supostamente precisa abrir os objetos dentro do foreach, se abrir antes nao vai. E o export deixar de ser necessario
  
  #results <- foreach(i = sample_sizes, 
#                     .combine = 'c', 
#                     .packages = c('ConR', 'sf', 'dplyr',"raster","terra")
#                     ,.export = c('spp_CNCflora_high_acc','run_analysis', 'AOH')
#                     ) %dopar% {
#    source("my_code/functions/AOH.R")
    # Load the data within each worker
    #spp_CNCflora_high_acc <- read.csv("data/../../../Data/CNCFlora/AOH_sim/testing.csv") # ver se funciona sem abrir o df. talvez so os raster ja role
    #af <- st_read("data/AF_limits/merge_limites_MA11428_TNC_ARG_BR_PAR.shp")
    #hab2015_bin_proj <- raster("data/../../../Data/THREAT/reprojected_rasters/habitat_AF_reprojected.tif")
    # nocurr <- nrow(spp_CNCflora_high_acc)
    #sample_sizes <- c(round(seq(.15,1,.15)*nocurr),nocurr)
    #iterations <- 1 # Number of iterations
    #proj="+proj=aea +lat_0=-32 +lon_0=-60 +lat_1=-5 +lat_2=-42 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs +type=crs"
    # replicate(iterations,
    # run_analysis(nn = i,
    #                        data = spp_CNCflora_high_acc,
    #                        ncores = 1,
    #                        parallel = F,
    #                        country_map = af,
    #                        habitat = hab2015_bin_proj),
    #           simplify = F)
    # 
 #   }
  
  # Stop the cluster
  
 # stopCluster(cl)
  
  # Flatten the list of lists
  
  
  
  AOH_combined <- do.call(rbind,AOH_list)
  
  AOH_combined$ratio <- as.numeric(AOH_combined$sample)/nocurr
  
  # plotando
  
  #plot(AOH_combined$AOH.area~AOH_combined$ratio)
  
  # Convert "ratio" column to a factor
  
  AOH_combined$ratio_f <- as.factor(round(AOH_combined$ratio,2))
  AOH_combined$AOH.area <- as.numeric(AOH_combined$AOH.area)
  AOH_combined$AOH.area_1000 <- AOH_combined$AOH.area/1000
  
  spp_nm <- gsub(pattern =" ",replacement = "_" ,unique(AOH_combined$spp.nm))
  
  # saving temp file
  
  write.csv(AOH_combined,paste0("C:/Users/franc/OneDrive - University of Cambridge/Data/CNCFlora/AOH_sim/",spp_nm,".csv"),row.names = F)

  
  }

# ggboxplot(AOH_combined,x ="ratio_f",y = "AOH.area_1000",ylab = "AOH (1000 ha)",xlab=" sample ratio")+
#   geom_jitter(aes(color = ratio), width = 0.2, alpha = 0.5) +
#     theme_minimal() +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1))

  