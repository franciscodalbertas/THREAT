#### LOADING THE REQUIRED PACKAGES AND FUNCTIONS ####
require(ConR)
require(raster)
require(sf)
require(lwgeom)
# require(rgdal)
# require(rgeos)
require(cleangeo)
source("R//99_functions.R")
#### GETTING SPECIES EOOs ####
EOO.poly <- readRDS(file = "EOO/spp.convex.hull.polys_sf_uncropped.rds")
EOO.poly <- sf::st_make_valid(EOO.poly)
#### ESA land-use cover: forest cover as habitat ####
## Getting forest cover classes fro ESA LC map
toto <- read.csv("data/ESACCI-LC-Legend.csv", as.is=TRUE)
hab.class <- toto$NB_LAB[grepl("ForestCover", toto$LegendTreeCoSimp)]

## Loading aggregated rasters and extracting the habitat loss/quality (2000-2015)
ano1 = 2000
hab.map <- raster::stack(paste0("data/ESA_Land_Cover_map_", ano1, "_2015_AF_1km.tif"))
names(hab.map) <- paste("ESA",c(ano1,2015), sep=".")
anos <- 2015 - ano1 
plot(hab.map)

# does not matter. sherwood can be used to acess AOH
AOH <- ConR::AOH.estimation(XY =MyData_f,show_progress = T,hab.map = hab.map[[1]])

EOO.habitat(EOO.poly, hab.map, years = anos)

# from the LIFE paper
# For current AOH we used a map of the estimated distribution of habitats (43) in 2016. For original AOH we used a map of Potential Natural Vegetation (PNV) (44) which estimates 35 the distribution of habitat types in the absence of human impacts.
# 43: Jung M, Dahal PR, Butchart SHM, Donald PF, De Lamo X, Lesiv M, et al. A global map of terrestrial 29 habitat types. Sci Data. 2020 Aug 5;7(1):256.
# 44: Jung M. A layer of global potential habitats [Internet]. 2020. Available from: 31 https://zenodo.org/record/4038749
# 
