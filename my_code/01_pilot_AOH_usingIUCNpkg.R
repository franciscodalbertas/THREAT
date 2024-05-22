# packages required ------------------------------------------------------------

if (!require(remotes)) install.packages("remotes")
remotes::install_github("prioritizr/aoh")

#https://prioritizr.github.io/aoh/

library(aoh)
library(terra)
library(rappdirs)
library(ggplot2)

#-------------------------------------------------------------------------------



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

spp_flt <- c("Euterpe edulis")

# filtering the data to the above spp. list

MyData_f <- dplyr::filter(MyData,tax %in%spp_flt[1])

## Convex Hull method
system.time(
  EOO.hull <- ConR::EOO.computing(XY = MyData_f[grepl("high", MyData_f$tax.check.final), c(1:3)],
                                  method.range = "convex.hull",
                                  export_shp = TRUE,
                                  parallel = F)
)


#extracting the EOO from the object
EOO <- do.call(rbind.data.frame, EOO.hull[grepl("eoo", names(EOO.hull$results))])

# create and Id for each spp. (the package need it to run)

EOO$id_no <- 1 



# specify cache directory

cache_dir <- user_data_dir("aoh")

# create cache_dir if needed
if (!file.exists(cache_dir)) {
  dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)
}

# prepare information
# prepare information

spp_info_data <- create_spp_info_data(spp_range_data, cache_dir = cache_dir)
spp_info_data <- create_spp_info_data(EOO, cache_dir = cache_dir)

# only works with IUCN spp.