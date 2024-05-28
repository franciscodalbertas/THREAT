 
proj="+proj=aea +lat_0=-32 +lon_0=-60 +lat_1=-5 +lat_2=-42 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs +type=crs" 
AOH <- function(EOO,habitat,year){
   
   # packages needed -----------------------------------------------------------
  library(terra)
  library(sf)
  library(ConR)#
  library(raster)
   #----------------------------------------------------------------------------
   
   EOO_area <- as.numeric(st_area(EOO))/10^4 # in ha
   
   # Convert the binary raster to polygons
   
   # habitat_pol <- as.polygons(habitat, dissolve=TRUE)
   # names(habitat_pol) <-"class"
   # habitat_pol <- st_as_sf(habitat_pol)
   
   # Filter out polygons with a value of 1

   #habitat_pol <- habitat_pol[habitat_pol$class == 1,]
   
   # Intersect the binary raster polygons with the given polygon
   
   #AOH <- st_intersection(EOO,habitat_pol)
   
   # Extract raster values within the polygon
   
   extracted_values <- raster::extract(habitat, EOO, fun=sum, na.rm=TRUE)
   
   # Sum the values (since we are summing only the values of 1, the sum will be the count of pixels with value 1)
   
   AOH <- extracted_values[1,1] # no terra eh [,2]
   
   pixel_resolution <- raster::res(habitat)[1]*raster::res(habitat)[1]
   
   pixel_area_hectares <- pixel_resolution/10^4
   
   AOH_area <- AOH*pixel_area_hectares
   
   #AOH_area <- as.numeric(st_area(AOH))/10^4
   
   # final table
   
   df <- data.frame(spp.nm=EOO$tax,EOO.area=EOO_area,AOH.area=AOH_area,year=year)
   
   return(df)
   
   
 }

 run_analysis <- function(nn,data,ncores,parallel,country_map,habitat) {
   n= nrow(data)
   df <- data[sample(1:n, nn),]
   EOO_s <- ConR::EOO.computing(XY = df,
                                method.range = "convex.hull",
                                export_shp = TRUE,
                                parallel = parallel,
                                NbeCores = ncores,
                                exclude.area = TRUE,
                                country_map = af)
   
   # Extracting the EOO from the object
   EOO_s <- do.call(rbind.data.frame, EOO_s[grepl("eoo", names(EOO_s$results))])
   EOO_s <- st_transform(EOO_s, proj)
   AOH_s <- AOH(EOO_s, habitat = habitat, year = 2015)
   
   # Adding sample size
   AOH_s$sample <- nn
   return(AOH_s)
 }
