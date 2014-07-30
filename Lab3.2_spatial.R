##############################################
## LAB 3.2  Visualising Spatial Data II
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

install.packages("rgeos", dependencies=TRUE)
install.packages("mapproj", dependencies=TRUE)
install.packages("ggmap", dependencies=TRUE)
install.packages("geocode", dependencies=TRUE)


library("maps")
library("maptools")
library("sp")
library("rgdal")
library("XML")
library("dismo")
library("rgeos")
library("mapproj")
library("ggmap")
library("geocode")


## Carregando dados geograficos e espaciais no R
## A funcao "readShapePoly"
## Biblioteca rgdal “Geospatial Abstraction Library (GDAL)” 


sport <- readShapePoly("data/London_Sport1/london_sport.shp")

# testar projecao
sport@proj4string 

## Qual a projecao??

EPSG<- make_EPSG()
head(EPSG)


## Nesse caso, devemos usar o British National Grid.
# A gente pode procurar no objeto EPSG

with(EPSG, EPSG[grep("British National", note),])

## A projecao que procuramos tem o "code" = 27700. 
BNG<- CRS("+init=epsg:27700")
proj4string(sport)<-BNG

## Outra maneira mais simples de atribuir projecao
## a um objeto:

proj4string(sport) <- CRS("+init=epsg:27700")

# testar projecao
sport@proj4string 

# R uses EPSG codes to refer to different coordinate
# reference systems (CRS). 27700 is the code for British 
# National Grid. A commonly used geographical (‘lat/lon’) 
# CRS is ‘WGS84’, whose EPSG code is 4326. The following 
# code shows how to search the list of available EPSG 
# codes and create a new version of "sport" in WGS84:


EPSG <- make_EPSG() # cira um data.frame com todos EPSG codes 
EPSG[grepl("WGS 84$", EPSG$note), ] # procura por "WGS 84"

## Mudando a projecao

sport_wgs84 <- spTransform(sport, CRS("+init=epsg:4326"))


## Manipulando os Atributos de objetos espaciais ## 
###################################################


crime_data <- read.csv("data/data_asdar/mps-recordedcrime-borough.csv",
                       fileEncoding = "UCS-2LE")

class(crime_data)
str(crime_data)
head(crime_data)
# O que e MajorText?
summary(crime_data$MajorText)

# Extrai "Theft & Handling" e salva em um novo objeto
crime_theft <- crime_data[crime_data$MajorText == "Theft & Handling", ] 
head(crime_theft, 10) # vamos ver as 10 primeiras linhas


# Calcula o cumulativo de crimes por distrito e salva em um novo objeto
crime_ag <- aggregate(CrimeCount ~ Spatial_DistrictName, FUN = sum, data = crime_theft)
# Vamos ver as 10 primeiras linhas
head(crime_ag, 10)


## Nos temos informacoes geograficas (poligonos e projecao)
## no objeto sport e atributos em crime_data

## Como juntar as duas coisas em um único banco de dados??

sport$name %in% crime_ag$Spatial_DistrictName

# Compara o nome das colunas em "sport" com os  valores da
# variavel "Spatial_DistrictName" em crime_ag para ver o que bate

## Quais as linhas aonde ha discrepancia??

sport$name[!sport$name %in% crime_ag$Spatial_DistrictName]

# Quais os nomes do distritos em "names"
levels(crime_ag$Spatial_DistrictName)

## Agora temos de renomear 

levels(crime_ag$Spatial_DistrictName)[25] <- as.character(
  sport$name[!sport$name %in% crime_ag$Spatial_DistrictName])

sport$name %in% crime_ag$Spatial_DistrictName 

# Agora, todos os nomes conferem!!


## Entao, estamos prontos para juntar os
## bancos de dados. Vamos usar a funcao join
## da biblioteca plyr

help(join)
library(plyr)
help(join)


head(sport$name)
head(crime_ag$Spatial_DistrictName) # nossa variavel de interesse

crime_ag <- rename(crime_ag, replace = c("Spatial_DistrictName" = "name"))
head(join(sport@data, crime_ag)) # test it works

## agreda os dados
sport@data <- join(sport@data, crime_ag)  

## testanto se funcionou
ls()
class(sport)
names(sport)

##  Clipping & spatial joins
dir("data/data_asdar")
stations <- readShapePoints("data/data_asdar/lnd-stns.shp")

class(stations)
proj4string(stations) 

proj4string(sport)
# Extrai o bounding box para stations
bbox(stations)
# Extrai o bounding box para sports
bbox(sport)


## Qual a projecao de stations??

# Atribui uma projecao a stations
stations27700 <- spTransform(stations, CRSobj <- CRS(proj4string(sport))) 
# overwrite the stations object with stations27700 
stations <- stations27700 
# remove stations27700 da memoria
rm(stations27700) 

## Se nao funcionar usar o comando

proj4string(stations) <- CRS("+init=epsg:27700")

plot(sport) # plot de Londres
# sobrepoem as estacoes
points(stations, col = "red")

## As estacoes estao fora do mapa de Londres
stations <- stations[sport, ]
plot(stations)


## ggplot2 e Mapas

install.packages("gpclib", dependencies=TRUE)
library("gpclib")

gpclibPermit()

## “Fortifying” spatial objects for ggplot2 maps

sport_geom <- fortify(sport, region="ons_label")

# Para fazer mapas com o pacote ggplot2, nos precisamos
# da funcao fortify (disponivel nos pacotes maptools ou rgeos)
# grosseriamente, ela limpa os slots do Shapefiles para serem
# plotados.


sport_geom <- merge(sport_geom, sport@data, 
                    by.x="id", by.y="ons_label")


# Have a look at the sport_geom object to see its
# contents. You should see a large data frame containing 
# the latitude and longitude (they are actually eastings and 
# northings as the data are in British National Grid format)
# coordinates alongside the attribute information associated
# with each London Borough. If you type 

# print(sport_geom) 

# you will just how many coordinate pairs are required!

head(sport_geom, 10)

# It is now straightforward to produce a map 
# using all the built in tools (such as setting 
# the breaks in the data) that ggplot2 has to 
# offer. coord_equal() is the equivalent 
# of asp=T in regular plots with R:

Map <- ggplot(sport_geom, aes(long,lat, group=group,
                              fill=Partic_Per)) +
  geom_polygon() + coord_equal() + 
  labs(x="Easting (m)", y="Northing (m)", fill= "% Sport Partic.") +
  ggtitle ("London Sports Participation")

# to print the MAP objetc
print(Map)


# para transformar o mapa em uma escala de branco e preto
Map + scale_fill_gradient(low="white", high="black")

## Adicionando Bases aos mapas com o ggmap

# ggmap is a package that uses the ggplot2 syntax as a
# template to create maps with image tiles taken from map 
# servers such as Google and OpenStreetMap

# carrega a biblioteca
library(ggmap)

ls()

# Agora, vamos trabalhar com o objeto "sport_wgs84", 
# criado anteriormente que contem informacoes sobre
# a pratica de esportes em Londres e esta referido
# na projeto WGS84


# rescalona longitude e latitude (aumentando a bb em 5% para o mapa)
# substitua o 1.05 por 1.xx para um aumento de xx% no tamanho do mapa

b <- bbox(sport_wgs84)
b[1, ] <- (b[1, ] - mean(b[1, ])) * 1.05 + mean(b[1, ])
b[2, ] <- (b[2, ] - mean(b[2, ])) * 1.05 + mean(b[2, ])


plot1 <- ggmap(get_map(location = b)) # cria as fundacoes do nosso mapa

## seguindo os mesmos passos da construcao do mapa de Londres
## precisamos usar a funcao fortify e adicionar os atributos
## do nosso mapa ao objeto sport_wgs84

sport_wgs84_f <- fortify(sport_wgs84, region = "ons_label")

sport_wgs84_f <- merge(sport_wgs84_f, sport_wgs84@data,
                     by.x = "id", by.y = "ons_label")

## Agora, podemos sobrepor essas informacoes ao nosso mapa

plot1 + geom_polygon(data = sport_wgs84_f,
                     aes(x = long, y = lat, 
                         group = group, fill = Partic_Per), 
                     alpha = 0.5)

# download basemap 

plot2 <- ggmap(get_map(location = b, source = "stamen", 
                       maptype = "toner", crop = TRUE))

# instala e carrega as bibliotecas maps e mapproj
#install.packages("mapproj", dependencies=TRUE)
library(mapproj)

plot2 + geom_polygon(data = sport_wgs84_f,
                     aes(x = long, y = lat, group = group,
                         fill = Partic_Per), alpha = 0.5)

# Agora, podemos usar o argumento get_map’s zoom para aumentar
# o detalhamento do nosso mapa

plot3 <- ggmap(get_map(location = b, source = "stamen", 
                          maptype = "toner", crop = TRUE, zoom = 11))


plot3 + geom_polygon(data = sport_wgs84_f,
                     aes(x = long, y = lat, group = group, 
                         fill = Partic_Per), alpha = 0.5)

## salvando o resultado em um objeto

Map2 <- plot3 + geom_polygon(data = sport_wgs84_f,
                             aes(x = long, y = lat, group = group, 
                                 fill = Partic_Per), alpha = 0.5)

print(Map2)

# para transformar o mapa em uma escala de branco e preto
Map2 + scale_fill_gradient(low="white", high="black")



## A funcao geocode 

## A funcao geocode pode ser usada para georeferenciar
## bases de enderecos

# Exemplo

library(ggmap)
geocode("Av. Paulista, 1578, Bela Vista, Sao Paulo, Brasil")

?geocode

# A função geocode acessa o API do Google Maps e faz uma pesquisa
# pelo endereço informado.

# É possível também procurar vários endereços de uma vez só.
# Basta que cada endereço esteja gravado dentro de um 
# elemento de um vetor de caracteres (string ou character)

# Baixando, na página da prefeitura de SP, os endereços dos SESCs
pag_pref <- readLines("http://www9.prefeitura.sp.gov.br/secretarias/smpp/sites/saopaulomaisjovem/cultura/index.php?p=25")[71]

# testando

class(pag_pref)
length(pag_pref)

# É preciso fazer uma limpeza do código HTML
# e extrair apenas o conteúdo desejado:


# Separando as linhas e removendo conteúdos desnecessários
pag_pref = unlist(strsplit(pag_pref,"<br />|/ Tel"))
pag_pref =gsub("<strong>|</strong>","",pag_pref)

# Mantém apenas as linhas que contêm a expressão "Endereço"
pag_pref = pag_pref[grep("Endereço",pag_pref)]

# Remove a expressão "Endereço"
pag_pref = gsub("Endereço: ","",pag_pref)

# Retira todos os caracteres especiais
pag_pref = gsub("[[:punct:]]", ",", pag_pref)

# Remove conteúdo desnecessário da linha 1
pag_pref = gsub("esquina com a Rua 24 de Maio","Sao Paulo, SP",pag_pref)

# Adiciona a cidade à linha 8
pag_pref[8] = paste(pag_pref[8],", Sao Paulo, SP")

# Adiciona o país a todas as linhas
pag_pref = paste(pag_pref,", Brasil")

# Remove todos os acentos
pag_pref = iconv(pag_pref, to="ASCII//TRANSLIT")

## O que queremos e uma lista de endereços guardada em
## vetor de caracteres:

pag_pref

# Agora é só aplicar a função geocode para gerar as coordenadas

latlong <- geocode(pag_pref)

# A função get_map do pacote ggmap acessa um repositório
# público de mapas, o stamen, copia a imagem (geocodificada) 
# da região desejada e a retorna como um objeto do R. Há várias
# opções de formatação, cores etc. E há também outros 
# repositórios de mapas (inclusive o próprio Google Maps).

# Baixa o mapa de SP (centrado na Sé - isto pode ser alterado)

sp.map <- get_map(location="Sao Paulo", 
                  zoom = 11,
                  source = "stamen", 
                  maptype = "toner",
                  color = "color")

# Transforma o arquivo de mapa em um grafico (ggplot2)
sp.map.2012 <- ggmap(sp.map, base_layer =
                       ggplot(aes(x = lon, y = lat), 
                              data = latlong),
                     extent = "device")

#Plota o resultado (os pontos dos endereços)

sp.map.2012 + geom_point(size = I(4),colour="red", alpha = 2/3)

