# area of EOO covered by habitat in a certain moment in time


# AF limits

af <- st_read(dsn= "data/AF_limits/merge_limites_MA11428_TNC_ARG_BR_PAR.shp")


# habitat info.

toto <- read.csv("data/ESACCI-LC-Legend.csv", as.is=TRUE)
hab.class <- toto$NB_LAB[grepl("ForestCover", toto$LegendTreeCoSimp)]

# reclassify raster to binary

# Reclassify the raster: values in 'values_to_one' to 1, others to 0
hab2015_bin <- classify(hab2015, rcl=cbind(hab.class, 1))

# Set all other values to 0
hab2015_bin[hab2015_bin != 1] <- 0

pixel_resolution <- 0.008333333

pixel_area_km2 <- (pixel_resolution * 111.32) * (pixel_resolution * 111.32)
# Convert square kilometers to hectares (1 km^2 = 100 hectares)
pixel_area_hectares <- pixel_area_km2 * 100


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
EOO_area <- as.numeric(st_area(EOO))/10^4 # in ha
# Extract raster values within the polygon
extracted_values <- extract(hab2015_bin, EOO, fun=sum, na.rm=TRUE)

# Sum the values (since we are summing only the values of 1, the sum will be the count of pixels with value 1)

AOH <- extracted_values[,2]
AOH_area <- AOH*pixel_area_hectares
# final table

df <- data.frame(spp.nm=EOO$tax,EOO.area=EOO_area,AOH.area=AOH_area)

