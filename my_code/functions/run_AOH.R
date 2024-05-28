#Function to run the AOH analysis for a given sample size

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
  AOH_s <- AOH(EOO_s, habitat = habitat, year = 2015)# aqui q ta dando merda
  
  # Adding sample size
  AOH_s$sample <- nn
  return(AOH_s)
}