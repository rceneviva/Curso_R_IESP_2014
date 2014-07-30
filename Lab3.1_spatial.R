##############################################
## LAB 3.1  Visualising Spatial Data
## Ricardo Ceneviva 
## via http://CRAN.R-project.org/ 
## packages: sp, #ASDAR
## IESP, Rio de Janeiro, Brazil, July 2014
## Curso de Inverno IESP 2014
## Analise de Dados Espaciais 
################################################



#Limpa todos os objetos da memoria
remove(list=ls(all=TRUE))
gc()

#Exige o seu diretorio de trabalho corrente
getwd()

#Fixa um diretorio de trabalho
setwd("~/Dropbox/iesp_uerj/escola_inverno/asdar_2014/")

# Carrega as bibliotecas que serao usadas nessa sessao


library("maps")
library("maptools")
library("sp")
library("rgdal")

gpclibPermit()

library("XML")
library("dismo")
    


## Carrega o banco de dados "meuse"
data(meuse)
str(meuse)
## Banco de Dados

# This data set gives locations and topsoil heavy metal 
# concentrations, along with a number of soil and 
# landscape variablesat the observation locations, 
# collected in a flood plain of the river Meuse,
# near the village of Stein (NL). Heavy metal concentrations
# are from composite samples of an area of 
# approximately 15 m x 15 m.

## Referencias

# M G J Rikken and R P G Van Rijn, 1993. Soil pollution
# with heavy metals - an inquiry into spatial variation, 
# cost of mapping and the risk evaluation of copper, 
# cadmium, lead and zinc in the floodplains of the Meuse
# west of Stein, the Netherlands. Doctoraalveldwerkverslag,
# Dept. of Physical Geography, Utrecht University

# Criando um objeto "Spatial" com a funcao
# coordinates

coordinates(meuse) <- c("x", "y")
class(meuse)
str(meuse)

# Visualizando os dados 
plot(meuse)
title("points")

# Criando um objeto SpatialLines por meio da 
# intersecco dos pontos geograficos

cc <- coordinates(meuse)
m.sl <- SpatialLines(list(Lines(list(Line(cc)), "line1")))
plot(m.sl)
title("lines")


## Vizualizacao de Poligonos
#carrega os dados
data(meuse.riv)
#cria uma lista de Poligonos
meuse.lst <- list(Polygons(list(Polygon(meuse.riv)), 
                           "meuse.riv"))
# Cria o objeto SpatialPoligons 
meuse.sr <- SpatialPolygons(meuse.lst)
#plota o "mapa"
plot(meuse.sr, col = "grey")
# acrescenta o titulo
title("polygons")


## Vilualizacao de Grids 
# carrega os dados
data(meuse.grid)
class(meuse.grid)  #extrai a classe do objeto
#cria o objeto espacial
coordinates(meuse.grid) <- c("x", "y")
# converte em "SpatialPixels"
meuse.grid <- as(meuse.grid, "SpatialPixels")
# exibe a imagem
image(meuse.grid, col = "grey")
title("grid")

##################
### IMPORTANTE ###
##################

## PROJECAO ##


# On each map, one unit in the x-direction equals one
# unit in the y- direction. This is the default when the
# coordinate reference system is not longlat or is unknown.
# For unprojected data in geographical coordinates 
# (longitude/latitude), the default aspect ratio depends
# on the (mean) latitude of the area plotted. The default
# aspect can be adjusted by passing the asp argument.

## Combinado os mapas

image(meuse.grid, col = "lightgrey")
plot(meuse.sr, col = "grey", add = TRUE)
plot(meuse, add = TRUE)


## Eixos e Elementos da Vizualizacao 
## de Objetos Espaciais

layout(matrix(c(1, 2), 1, 2))
# O comando axes controla a vizualizacao dos eixos
plot(meuse.sr, axes = TRUE)
plot(meuse.sr, axes = FALSE)

# O comando axis controla a manipulacao dos eixos
axis(1, at = c(178000 + 0:2 * 2000), cex.axis = 0.7) 
axis(2, at = c(326000 + 0:3 * 4000), cex.axis = 0.7) 
box()


## Os principais argumentos usados para a manipulacao
##  da aparencia dos graficos e mapas sao:


# fin  Figure region  (Inch) 
# pin Plotting region (Inch)
# mai Plotting margins (Inch)
# mar Plotting margins (Lines of text)

?par  ## para informacaoes mais detalhadas

## EXemplo

oldpar <- par(no.readonly = TRUE)
layout(matrix(c(1, 2), 1, 2))
plot(meuse, axes = TRUE, cex = 0.6)
plot(meuse.sr, add = TRUE)
title("Sample locations")


par(mar = c(0, 0, 0, 0) + 0.1)
plot(meuse, axes = FALSE, cex = 0.6)
plot(meuse.sr, add = TRUE)
box()
par(oldpar)


## Acrescentando um Escala (de distancias)
## ao grafico

plot(meuse)
plot(meuse.sr, add = TRUE)
plot(meuse)
SpatialPolygonsRescale(layout.scale.bar(), offset = locator(1),
                       scale = 1000, fill = c("transparent", "black"), 
                       plot.grid = FALSE)
text(locator(1), "0")
text(locator(1), "1 km")
SpatialPolygonsRescale(layout.north.arrow(), offset = locator(1),
                       scale = 400, plot.grid = FALSE)




## Reference Grid ## 
####################

# Unprojected data have coordinates in latitude and
# longitude degrees, with negative degrees referring 
# to degrees west (of the prime meridian) and south 
# (of the Equator). When unprojected spatial data are
# plotted using sp meth- ods (plot or spplot), the axis
# label marks will give units in decimal degrees N/S/E/W, 
# for example 50.5◦N. 


wrld <- map("world", interior = FALSE, xlim = c(-179, 179),
            ylim = c(-89, 89), plot = FALSE)
wrld_p <- pruneMap(wrld, xlim = c(-179, 179))

llCRS <- CRS("+proj=longlat +ellps=WGS84")
wrld_sp <- map2SpatialLines(wrld_p, proj4string = llCRS)
prj_new <- CRS("+proj=moll")

wrld_proj <- spTransform(wrld_sp, prj_new)
wrld_grd <- gridlines(wrld_sp, easts = c(-179, seq(-150, 150, 50), 179.5),
                      norths = seq(-75, 75, 15), ndiscr = 100) 
wrld_grd_proj <- spTransform(wrld_grd, prj_new)
at_sp <- gridat(wrld_sp, easts = 0, norths = seq(-75, 75, 15), offset = 0.3)

at_proj <- spTransform(at_sp, prj_new)
plot(wrld_proj, col = "grey60")
plot(wrld_grd_proj, add = TRUE, lty = 3, col = "grey70") 
text(coordinates(at_proj),pos = at_proj$pos, offset = at_proj$offset,
     labels = parse(text = as.character(at_proj$labels)), cex = 0.6)



## Area do Grafico, Tamanho do Mapa e multiplos mapas

