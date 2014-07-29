##############################################
## LAB 2.2 - Applied Spatial Analysis
## Ricardo Ceneviva 
## via http://CRAN.R-project.org/ 
## packages: sp, #ASDAR
## IESP, Rio de Janeiro, Brazil, July 2014
## Curso de Inverno IESP 2014
## Introducao a programacao em R
################################################



#Limpa todos os objetos da memoria
remove(list=ls(all=TRUE))
gc()

#Exige o seu diretorio de trabalho corrente
getwd()

#Fixa um diretorio de trabalho
setwd("~/Dropbox/iesp_uerj/escola_inverno/asdar_2014/")


## MANIPULATING SPATIAL VECTOR DATA (points, lines, polygons)

# Example dataset: retrieve point occurrence data from GBIF

# Now, let's create an example dataset: retrieve occurrence
# data for the laurel tree (Laurus nobilis) from the Global
# Biodiversity Information Facility (GBIF)

library("dismo")
library("rgbif")      # check also the nice "rgbif" package 
laurus <- gbif("Laurus", "nobilis")

# get data frame with spatial coordinates (points)

locs <- subset(laurus, select = c("country", "lat", "lon"))
head(locs)  # a simple data frame with coordinates

# Discard data with errors in coordinates:
locs <- subset(locs, locs$lat < 90)

## Making data "spatial"

# So we have got a simple dataframe containing spatial
# coordinates. Let's make these data explicitly spatial

# set spatial coordinates
coordinates(locs) <- c("lon", "lat")
plot(locs)


# Did NOT work
# we need to define spatial projection

# geographical, datum WGS84
crs.geo <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84") 

# define projection system of our data
proj4string(locs) <- crs.geo 
summary(locs)

# Now we can quickly plot point data on a map

plot(locs, pch = 20, col = "steelblue")

#install.packages("rworldmap", dependencies=TRUE)
# library rworldmap provides different types of global maps, e.g:

library("rworldmap")
data(coastsCoarse)
data(countriesLow)
plot(coastsCoarse, add = TRUE)

## Subsetting and mapping again

table(locs$country)  # see localities of Laurus nobilis by country
# select only locs in UK
locs.gb <- subset(locs, locs$country == "United Kingdom")

plot(locs.gb, pch = 20, cex = 2, col = "steelblue")
title("Laurus nobilis occurrences in UK")
plot(countriesLow, add = TRUE)

summary(locs.gb)


## Mapping vectorial data using gmap from dismo

gbmap <- gmap(locs.gb, type = "satellite")
# Google Maps are in Mercator projection. 
# This function projects the points to that
# projection to enable mapping

locs.gb.merc <- Mercator(locs.gb) 
plot(gbmap)

## Acrescenta os pontos com a occorencia do
## Laurus nobilis

points(locs.gb.merc, pch = 20, col = "red")


## Mapping vectorial data with RgoogleMaps

install.packages("require(RgoogleMaps", dependencies=TRUE)
library("RgoogleMaps")

# retrieves coordinates 
# (1st column for longitude, 2nd column for latitude)

locs.gb.coords <- as.data.frame(coordinates(locs.gb))  

PlotOnStaticMap(lat = locs.gb.coords$lat, 
                lon = locs.gb.coords$lon, zoom = 5, 
                cex = 1.4, pch = 19, col = "red", 
                FUN = points, add = FALSE)

?PlotOnStaticMap

# Download base map from Google Maps and plot onto it

# define region of interest (bounding box)
map.lim <- qbbox(locs.gb.coords$lat, locs.gb.coords$lon,
                 TYPE = "all")

mymap <- GetMap.bbox(map.lim$lonR, map.lim$latR, 
                     destfile = "gmap.png", 
                     maptype = "satellite")

# see the file in the wd
PlotOnStaticMap(mymap, lat = locs.gb.coords$lat, 
                lon = locs.gb.coords$lon, zoom = NULL, 
                cex = 1.3, pch = 19, col = "red", 
                FUN = points, add = FALSE)

