##############################################
## LAB 2.1 - Applied Spatial Analysis
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

# Types of Spatial Data

# Spatial data have spatial reference: 
# they have coordinate values and a system
# of reference for these coordinates.

# coordenadas
# sistema de projeção 


## EXEMPLO: Localizacao do Vulcoes Ativos
## na terra

# We could list the coordinates for all known volcanoes
# as pairs of longitude/latitude decimal degree values 
# with respect to the prime meridian at Greenwich and 
# zero latitude at the equator. The World Geodetic System
# (WGS84) is a frequently used representation of the Earth.

## PROJECTION

# This data set consists of points only. 
# When we want to draw these points on a (flat) map,
# we are faced with the problem of projection: 
# we have to translate from the spherical longitude/latitude
# system to a new, non-spherical coor- dinate system, 
# which inevitably changes their relative positions. 

## ATRIBUTES

# If we also have the date and time of the last observed
# eruption at the volcano, this information is called an
# attribute: it is non-spatial in itself, but this attribute
# information is believed to exist for each spatial entity (volcano).

## SPATIAL INFORMATION

# We represent the purely spatial information of entities
# by data models.The different types of data models that 
# we distinguish here include the following:


## Point: a single point location, such as a GPS reading or a geocoded
# address 

## Line, a set of ordered points, connected by straight
# line segments

## Polygon  an area, marked by one or more enclosing lines,
# possibly containing holes

## Grid, a collection of points or rectangular cells,
# organised in a regular lattice

##  Points, Lines and Poligons are vector data models and
## represent entities as exactly as possible,

## The Grid is a raster data model, 
## representing continuous surfaces by using a regular
## tessellation. 

## A representation of the world as a surface divided 
## into a regular grid of cells. Raster models are useful
## for storing data that varies continuously, as in an aerial
## photograph, a satellite image, a surface of chemical
## concentrations, or an elevation surface.


## Classes for Spatial Data in R ##
###################################

## Spatial Objects

# The foundation class is the "Spatial" class objects, 
# with just two slots. 

# 1. The first is a bounding box, 
# a matrix of numerical coordinates with column names
# c(‘min’, ‘max’), and at least two rows, with the 
# first row eastings (x-axis) and the second northings (y-axis).

# Most often the bounding box is generated automatically
# from the data in subclasses of Spatial. 

# 2. The second is a CRS class object defining the coordinate
# reference system, and may be set to ‘missing’, represented by
# NA in R, by CRS(as.character(NA)), its default value. Operations
# on Spatial* objects should update or copy these values to the
# new Spatial* objects being created. We can use getClass to 
# return the complete definition of a class, including its slot
# names and the types of their contents:

library(sp)

getClass("Spatial")

# As we see, getClass also returns known subclasses, 
# showing the classes that include the Spatial class 
# in their definitions. 

## CRS 
getClass("CRS")

# The class has a character string as its only slot value,
# which may be a missing value. If it is not missing, it 
# should be a PROJ.4-format string describing the projection


# For geographical coordinates, the simplest such string is
# "+proj=longlat", using "longlat", which also shows that 
# eastings always go before northings in sp classes.

# Let us build a simple Spatial object from a bounding box matrix,
# and a missing coordinate reference system:

CRAN_df <- read.table("data/CRAN051001a.txt", header = TRUE)
CRAN_mat <- cbind(CRAN_df$long, CRAN_df$lat)
row.names(CRAN_mat) <- 1:nrow(CRAN_mat)

str(CRAN_mat)

# The SpatialPoints class extends the Spatial class
# by adding a coords slot, into which a matrix of point
# coordinates can be inserted.

getClass("SpatialPoints")

llCRS <- CRS("+proj=longlat +ellps=WGS84")
CRAN_sp <- SpatialPoints(CRAN_mat, proj4string = llCRS)
summary(CRAN_sp)

# SpatialPoints objects may have more than two dimensions,
# but plot methods for the class use only the first two.


# Methods

# Methods are available to access the values of the slots 
# of Spatial objects. The bbox method returns the bounding 
# box of the object, and is used both for preparing plotting
# methods and internally in handling data objects. 

# The first row reports the west–east range and the second
# the south– north direction. If we want to take a subset 
# of the points in a SpatialPoints object, the bounding box
# is reset, as we will see.

bbox(CRAN_sp)

# proj4string #
##############

# proj4string eports the projection string contained as a
# CRS object in the proj4string slot of the object, but it
# also has an assignment form, allowing the user to alter
# the current value, which can also be a CRS object 
# containing a character NA value:

proj4string(CRAN_sp)


proj4string(CRAN_sp) <- llCRS


# Extracting the coordinates from a SpatialPoints object
# as a numeric matrix is as simple as using the coordinates
# method. Like all matrices, the indices can be used 
# to choose subsets, for example CRAN mirrors located
# in Brazil in 2005:


brasil <- which(CRAN_df$loc == "Brazil")

print(brasil)

coordinates(CRAN_sp)[brasil, ]

# a SpatialPoints object can also be accessed by index,
# using the "[ ]" operator

summary(CRAN_sp[brasil, ])

# The "[" operator also works for negative indices,
# which remove those coordinates from the object,
# here by removing mirrors south of the Equator:

south_of_equator <- which(coordinates(CRAN_sp)[, 2] < + 0)
summary(CRAN_sp[-south_of_equator, ])


## Data Frames for Spatial Point Data ## 
#########################################


str(row.names(CRAN_df))

# What we would like to do is to associate the correct 
# rows of our data frame object with ‘their’ point 
# coordinates – it often happens that data are collected
# from different sources, and the two need to be merged. 

# The SpatialPoints- DataFrame class is the container 
# for this kind of spatial point information, and can be
# constructed in a number of ways, for example from a 
# data frame and a matrix of coordinates.

# If the matrix of point coordinates has row names 
# and the match.ID argument is set to its default value 
# of TRUE, then the matrix row names are checked against 
# the row names of the data frame. If they match, but 
# are not in the same order, the data frame rows are 
# re-ordered to suit the points. If they do not match,
# no SpatialPointsDataFrame is constructed.


# Using other extraction operators, especially the $ operator,
# returns the data frame column referred to.

CRAN_spdf1 <- SpatialPointsDataFrame(CRAN_mat, CRAN_df,
                                     proj4string = llCRS, 
                                     match.ID = TRUE)

CRAN_spdf1[4, ]

str(CRAN_spdf1$loc)
str(CRAN_spdf1[["loc"]])

# If we re-order the data frame at random using sample,
# we still get the same result, because the data frame 
# is re-ordered to match the row names of the points:

s <- sample(nrow(CRAN_df))

CRAN_spdf2 <- SpatialPointsDataFrame(CRAN_mat, CRAN_df[s, ],
                                     proj4string = llCRS, 
                                     match.ID = TRUE)
all.equal(CRAN_spdf2, CRAN_spdf1)

CRAN_spdf2[4, ]


# But if we have non-matching ID values, 
# created by pasting pairs of letters together
# and sampling an appropriate number of them, 
# the result is an error:

CRAN_df1 <- CRAN_df

row.names(CRAN_df1) <- sample(c(outer(letters, 
                                      letters, paste, sep = "")),
                              nrow(CRAN_df1))

CRAN_spdf3 <- SpatialPointsDataFrame(CRAN_mat, 
                                     CRAN_df1, 
                                     proj4string = llCRS, 
                                     match.ID = TRUE)


## SpatialPointsDataFrame (data.frame)

getClass("SpatialPointsDataFrame")

# The Spatial*DataFrame classes have been designed to 
# behave as far as possi-ble like data frames, both 
# with respect to standard methods such as names, and
# more demanding modelling functions like model.frame 
# used in very many model fitting functions using formula
# and data arguments:

names(CRAN_spdf1)


str(model.frame(lat ~ long, data = CRAN_spdf1), 
    give.attr = FALSE)

# We can construct the object by giving the 
# SpatialPointsDataFrame function a SpatialPoints 
# object as its first argument:

CRAN_spdf4 <- SpatialPointsDataFrame(CRAN_sp, CRAN_df)
all.equal(CRAN_spdf4, CRAN_spdf2)


# We can also assign coordinates to a data frame 
# – this approach modifies the original data frame.
# The coordinate assignment function can take a matrix 
# of coordinates with the same number of rows as the 
# data frame on the right- hand side, or an integer 
# vector of column numbers for the coordinates, or 
# equivalently a character vector of column names, 
# assuming that the required columns already belong
# to the data frame.

CRAN_df0 <- CRAN_df
coordinates(CRAN_df0) <- CRAN_mat
proj4string(CRAN_df0) <- llCRS
all.equal(CRAN_df0, CRAN_spdf2)

str(CRAN_df0, max.level = 2)

# Objects created in this way differ slightly from those
# we have seen before, because the coords.nrs slot is 
# now used, and the coordinates are moved from the 
# data slot to the coords slot, but the objects are 
# otherwise the same:

RAN_df1 <- CRAN_df
names(CRAN_df1)


coordinates(CRAN_df1) <- c("long", "lat")
proj4string(CRAN_df1) <- llCRS
str(CRAN_df1, max.level = 2)

# Transect and tracking data may also be represented
# as points, because the observation at each point 
# contributes information that is associated with 
# the point itself, rather than the line as a whole.
# Sequence numbers can be entered into the data frame
# to make it possible to trace the points in order, 
# for example as part of a SpatialLines object

# As an example, we use a dataset from satellite telemetry
# of a single loggerhead turtle crossing the Pacific from 
# Mexico to Japan (Nichols et al., 2000).



turtle_df <- read.csv("data/seamap105_mod.csv")
summary(turtle_df)

# Before creating a SpatialPointsDataFrame, we will 
# timestamp the observations, and re-order the input
# data frame by timestamp to make it easier to add months
# to show progress westwards across the Pacific:

timestamp <- as.POSIXlt(strptime(as.character(turtle_df$obs_date),
                                 "%m/%d/%Y %H:%M:%S"), "GMT")

turtle_df1 <- data.frame(turtle_df, timestamp = timestamp)
turtle_df1$lon <- ifelse(turtle_df1$lon < 0, turtle_df1$lon +
                           360, turtle_df1$lon)

turtle_sp <- turtle_df1[order(turtle_df1$timestamp), ]
                                 
coordinates(turtle_sp) <- c("lon", "lat")
proj4string(turtle_sp) <- CRS("+proj=longlat +ellps=WGS84")


## SpatialLines ## 
##################

# The approach adopted in R (i.e. sp package) is to start
# with a Line object that is a matrix of 2D coordinates,
# without NA values. A list of Line objects forms the Lines
# slot of a Lines object. An identifying character tag is also
# required, and will be used for constructing SpatialLines 
# objects using the same approach as was used above for 
# matching ID values for spatial points.


getClass("Line")
getClass("Lines")

# Neither Line nor Lines objects inherit from the Spatial class.
# It is the Spa- tialLines object that contains the bounding box
# and projection information for the list of Lines objects 
# stored in its lines slot.

getClass("SpatialLines")

# Let us examine an example of an object of this class,
# created from lines retrieved from the maps package 
# world database, and converted to a SpatialLines 
# object using the map2SpatialLines function in maptools. 

library("maps")
library("maptools")
library("sp")
library("rgdal")
gpclibPermit()

japan <- map("world", "japan", plot = FALSE)
p4s <- CRS("+proj=longlat +ellps=WGS84")
SLjapan <- map2SpatialLines(japan, proj4string = p4s) 
str(SLjapan, max.level = 2)


Lines_len <- sapply(slot(SLjapan, "lines"),
                    function(x) length(slot(x, "Lines")))
table(Lines_len)

# We can use the ContourLines2SLDF function included 
# in maptools in our next example, converting data 
# returned by the base graphics function contourLines 
# into a SpatialLinesDataFrame object

volcano_sl <- ContourLines2SLDF(contourLines(volcano))
t(slot(volcano_sl, "data"))


# To import data that we will be using shortly,
# we use another utility function in maptools, which
# reads shoreline data in ‘Mapgen’ format from the 
# National Geophysical Data Center coastline extractor
# into a SpatialLines object directly

# http://www.ngdc.noaa.gov/mgg/shorelines/shorelines.html.


llCRS <- CRS("+proj=longlat +ellps=WGS84")
auck_shore <- MapGen2SL("data/auckland_mapgen.dat", llCRS)

summary(auck_shore)


# The shorelines are still just represented by lines,
# and so colour filling of apparent polygons formed by
# line rings is not possible. For this we need a class
# of polygon objects

## SpatialPolygons ##
#####################

# The basic representation of a polygon in R is 
# a closed line, a sequence of point coordinates
# where the first point is the same as the last
# point.

lns <- slot(auck_shore, "lines")
table(sapply(lns, function(x) length(slot(x, "Lines"))))


islands_auck <- sapply(lns, function(x) {
  crds <- slot(slot(x, "Lines")[[1]], "coords")
  identical(crds[1, ], crds[nrow(crds), ])
  }
)

table(islands_auck)

# Since all the Lines in the auck_shore object contain only
# single Line objects, checking the equality of the first
# and last coordinates of the first Line object in each 
# Lines object tells us which sets of coordinates can 
# validly be made into polygons. The nesting of classes
# for polygons is the same as that for lines, but the 
# successive objects have more slots.

getClass("Polygon")

# The Polygon class extends the Line class by adding slots
# needed for polygons and checking that the first and last
# coordinates are identical. The extra slots are a label
# point, taken as the centroid of the polygon, the area of
# the polygon in the metric of the coordinates, whether 
# the polygon is declared as a hole or not – the default 
# value is a logical NA

getClass("SpatialPolygons")

# The top level representation of polygons is as a 
# SpatialPolygons object, a set of Polygons objects 
# with the additional slots of a Spatial object to 
# contain the bounding box and projection information 
# of the set as a whole.


# Choosing only the lines in the Auckland shoreline
# data set which are closed polygons, we can build
# a SpatialPolygons object.

islands_sl <- auck_shore[islands_auck]
list_of_Lines <- slot(islands_sl, "lines")

islands_sp <- SpatialPolygons(lapply(list_of_Lines, function(x) {
  Polygons(list(Polygon(slot(slot(x, "Lines")[[1]],
                             "coords"))), ID = slot(x, "ID"))
}), proj4string = CRS("+proj=longlat +ellps=WGS84"))

summary(islands_sp)

slot(islands_sp, "plotOrder")

order(sapply(slot(islands_sp, "polygons"), function(x) slot(x,
                 "area")), decreasing = TRUE)


# As we saw with the construction of SpatialLines objects 
# from raw co- ordinates, here we build a list of Polygon 
# objects for each Polygons object, corresponding to a single
# identifying tag. A list of these Polygons objects is then 
# passed to the SpatialPolygons function, with a coordinate 
# reference sys- tem, to create the SpatialPolygons object.
# Again, like SpatialLines objects, SpatialPolygons objects
# are most often created by functions that import or manipulate
# such data objects, and seldom from scratch.


## SpatialPolygonsDataFrame Objects ##
######################################


# As with other spatial data objects, SpatialPolygonsDataFrame 
# objects bring together the spatial representations of the 
# polygons with data. The identify- ing tags of the Polygons
# in the polygon slot of a SpatialPolygons object are matched
# with the row names of the data frame to make sure that the
# correct data rows are associated with the correct spatial 
# objects. The data frame is re-ordered by row to match the
# spatial objects if need be, provided all the objects can 
# be matched to row names. If any differences are found,
# an error results.

# As an example, we take a set of scores by US state of 1999
# Scholastic Aptitude Test (SAT) used for spatial data analysis 
# by Melanie Wall.9 In the data source, there are also results 
# for Alaska, Hawaii, and for the US as a whole. If we would
# like to associate the data with state boundary polygons 
# provided in the maps package, it is convenient to convert
# the boundaries to a SpatialPolygons object

state.map <- map("state", plot = FALSE, fill = TRUE)

IDs <- sapply(strsplit(state.map$names, ":"), function(x) x[1])

state.sp <- map2SpatialPolygons(state.map, IDs = IDs,
           proj4string = CRS("+proj=longlat +ellps=WGS84"))


# Then we can use identifying tag matching to suit the rows of
# the data frame to the SpatialPolygons. Here, the rows of the
# data frame for which there are no matches will be dropped;
# all the Polygons objects are matched:

sat <- read.table("data/state.sat.data_mod.txt",
                  row.names = 5, header = TRUE)

str(sat)

id <- match(row.names(sat), sapply(slot(state.sp, "polygons"), 
                                   function(x) slot(x, "ID")))
row.names(sat)[is.na(id)]

## NAO FUNCIONA
## NAO REMOVE AS LINHAS

############################################
state.spdf <- SpatialPolygonsDataFrame(state.sp, sat, match.ID=TRUE)
str(slot(state.spdf, "data"))

str(state.spdf, max.level = 2)


##############################################



# Remover as linhas: "alaska" "hawaii" "usa"   
# Removes Alaska
Alaska <- "alaska"
not_alaska <- !(row.names(sat) == Alaska)
# Merges into new dataset
sat1 <- sat[not_alaska, ]
dim(sat1)

# Removes "hawaii"
Hawaii <- "hawaii"
not_hawaii <- !(row.names(sat1) == Hawaii)
# Merges into new dataset
sat2 <- sat1[not_hawaii, ]
dim(sat2)

# Removes "usa"
Usa <- "usa"
not_usa <- !(row.names(sat2) == Usa)
# Merges into new dataset
sat3 <- sat2[not_usa, ]
dim(sat3)


## AGORA FUNCIONA!!! 
############################################
state.spdf <- SpatialPolygonsDataFrame(state.sp, sat3, match.ID=TRUE)
str(slot(state.spdf, "data"))

str(state.spdf, max.level = 2)


##############################################

# Rather than having to manipulate polygons and their
# data separately, when using a SpatialPolygonsDataFrame
# object, we can say:

# Removes DC
DC <- "district of columbia"
not_dc <- !(row.names(slot(state.spdf, "data")) == DC)
state.spdf1 <- state.spdf[not_dc, ]
length(slot(state.spdf1, "polygons"))

summary(state.spdf1)

### SpatialGrid and SpatialPixel Objects ###
############################################


# The point, line, and polygon objects we have considered
# until now have been handled one-by-one. Grids are regular
# objects requiring much less information to define
# their structure.

#  Once the single point of origin is known, the extent
# of the grid can be given by the cell resolution and
# the numbers of rows and columns present in the full
# grid. This representation is typical for remote sensing
# and raster GIS, and is used widely for storing data
# in regular rectangular cells, such as digital elevation
# models, satellite imagery, and interpolated data from 
# point measurements, as well as image processing.


getClass("GridTopology")

# example, we make a GridTopology object from the bounding box
# of the Manitoulin Island vector data set. If we choose a cell
# size of 0.01◦ in each direction, we can offset the south-west
# cell centre to make sure that at least the whole area is covered,
# and find a suitable number of cells in each dimension.

manitoulin_sp <-load("data/high.RData")
bb <- bbox(manitoulin_sp)

bb



