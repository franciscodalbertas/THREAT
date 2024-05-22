 AOH <- function(EOO,habitat,year){
   
   # packages needed -----------------------------------------------------------
   library(terra)
   library(sf)
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
   
   extracted_values <- extract(habitat, EOO, fun=sum, na.rm=TRUE)
   
   # Sum the values (since we are summing only the values of 1, the sum will be the count of pixels with value 1)
   
   AOH <- extracted_values[,2]
   
   pixel_resolution <- res(habitat)[1]*res(habitat)[1]
   
   pixel_area_hectares <- pixel_resolution/10^4
   
   AOH_area <- AOH*pixel_area_hectares
   
   #AOH_area <- as.numeric(st_area(AOH))/10^4
   
   # final table
   
   df <- data.frame(spp.nm=EOO$tax,EOO.area=EOO_area,AOH.area=AOH_area,year=year)
   
   return(df)
   
   
 }


