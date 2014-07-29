### A Short Introduction to R
### Session 2: A Demonstration of R

# You can ignore this ...
wait  = function() tmp <- readline(prompt = "Please press return")
# ... it is just a simple function to prompt for Return when required


## 2.1 Getting Started

## Read in the file schools.csv file
wait()
schools.data <- read.csv(file.choose())

#  This is just some primitive error checking...
if(nrow(schools.data) != 367) stop("Whoops! Wrong file. Please start again", call. = F)

## 2.2 Checking the data

head(schools.data)		# The top of the data
wait()

tail(schools.data)		# The bottom of the data
wait()

summary(schools.data)
wait()

names(schools.data)		# The column names (variable names)
ncol(schools.data)		# The number of columns in the data table
nrow(schools.data)		# The number of rows
wait()

# Check by row to see if the data are complete:
complete.cases(schools.data)
wait()

## 2.4 Some simple graphics
# Beginning with a strip chart
attach(schools.data)
stripchart(attainment, method="stack", xlab="Mean Prior Attainment by School")
wait()

# Now a histogram
hist(attainment, col="light blue", border="dark blue", freq=F, ylim=c(0,0.30), xlab="Mean attainment")
wait()

# Add a rug plot
rug(attainment)
wait()

# Add a density curve
lines(density(sort(attainment)))
wait()

# Add a Normal curve
xx = seq(from=23, to=35, by=0.1)
yy = dnorm(xx, mean(attainment), sd(attainment))
lines(xx, yy, lty="dotted")
rm(xx, yy)
wait()

# Add a legend
legend("topright", legend=c("density curve","Normal curve"), lty=c("solid","dotted"))
wait()

# We will draw box plots to look at attainment differences between schools
# But first we require a categorical variable of school types

school.type <- rep("Not Faith/Selective", times=nrow(schools.data))
school.type[coe==1] <- "VA CoE"
school.type[rc==1] <- "VA RC"
school.type[vol.con==1] <- "VC"
school.type[other.faith==1] <- "Other Faith"
school.type[selective==1] <- "Selective"

school.type <- factor(school.type)
levels(school.type)
wait()

# Now to draw the box plots

par(mai=c(1,1.4,0.5,0.5))		# Changes the graphic margins
boxplot(attainment ~ school.type, horizontal=T, xlab="Mean attainment", las=1, cex.axis=0.8)
# Includes options to draw the boxes and labels horizontally
abline(v=mean(attainment), lty="dashed")
# Adds the mean value to the plot
legend("topright", legend="Grand Mean", lty="dashed")
wait()

## 2.4 Some simple statistics

# An analysis of variance (attainment by school type)
summary(aov(attainment ~ school.type))
wait()

# A t-test to compare the attainment scores of schools with high and low proportions
# of Free School Meal eligible pupils

attainment.high.fsm.schools <- attainment[fsm > quantile(fsm, probs=0.75)]
# Finds the attainment scores for schools with the highest proportions of FSM pupils
attainment.low.fsm.schools <- attainment[fsm < quantile(fsm, probs=0.25)]
# Finds the attainment scores for schools with the lowest proportions of FSM pupils

t.test(attainment.high.fsm.schools, attainment.low.fsm.schools) 
wait()

# A Pearson correlation and test of its significance
round(cor(fsm, attainment),3)
cor.test(fsm, attainment)
wait()

# A scatter plot and (OLS) line of best fit
plot(attainment ~ fsm)
abline(lm(attainment ~ fsm))	# Adds a line of best fit (a regression line)
wait()

# Some regression models
# First, model 1
model1 <- lm(attainment ~ fsm, data=schools.data)
summary(model1)
wait()

# Model 2
model2 <- lm(attainment ~ fsm + white, data=schools.data)
summary(model2)
wait()

# Model 3
model3 <- update(model2, . ~ . + selective)
summary(model3)
wait()

# Model 4 (drops the white ethnicity variable)
model4 <- update(model3, . ~ . - white)
# An ANOVA to judge if that variable ought to be dropped
anova(model4, model3)
wait()


## 2.5 Some simple maps

# A simple plot of point data
plot(Easting, Northing, asp=1, main="Map of London schools")
wait()

# With symbols proportional to English as a Secondary Language
plot(Easting, Northing, asp=1, main="Map of London schools", cex=sqrt(esl*5))
wait()

# With the symbols in a different colour
plot(Easting, Northing, asp=1, main="Map of London schools", cex=sqrt(esl*5), pch=21, bg="yellow")
wait()

# Would be more interesting to colour by the proportion of FSM pupils per school

# First, create a simple colour palette
palette <- c("yellow","orange","red","purple")

# Second, divide the schools into class according to FSM
map.class <- cut(fsm, quantile(fsm), labels=FALSE, include.lowest=TRUE)

# Finally, the map
plot(Easting, Northing, asp=1, main="Map of London schools", cex=sqrt(esl*5), pch=21, bg=palette[map.class])
wait()

# And something more ambitious!
library(RgoogleMaps)
MyMap <- MapBackground(lat=Lat, lon=Long)
PlotOnStaticMap(MyMap, Lat, Long, cex=sqrt(esl*5), pch=21, bg=palette[map.class])
legend("topleft", legend=paste("<",tapply(fsm, map.class, max)), pch=21, pt.bg=palette, pt.cex=1.5, bg="white", title="P(FSM-eligible)")
legVals <- seq(from=0.2,to=1,by=0.2)
legend("topright", legend=round(legVals,3), pch=21, pt.bg="white", pt.cex=sqrt(legVals*5), bg="white", title="P(ESL)")
wait()


## 2.6 Some simple geographical analysis

# Converting the schools data into a spatial object in R
detach(schools.data)
schools.xy <- schools.data
library(sp)
attach(schools.xy)
coordinates(schools.xy) <- c("Easting", "Northing")
# Converts into a spatial object
class(schools.xy)
detach(schools.xy)
proj4string(schools.xy) <- CRS("+proj=tmerc datum=OSGB36")
# Sets the Coordinate Referencing System
wait()

# find the six nearest neighbours for each school
library(spdep)
nearest.six <- knearneigh(schools.xy, k=6, RANN=F)
# RANN = F to override the use of the RANN package that may not be installed

# The six nearest schools for school 1:
nearest.six$nn[1,]
class(nearest.six)
wait()

# Converting into a more generic neighbours class
neighbours <- knn2nb(nearest.six)
class(neighbours)
summary(neighbours)
wait()

# Plotting the connections
plot(neighbours, coordinates(schools.xy))
wait()

# Convert into a spatial weights object and test for dependencies
spatial.weights <- nb2listw(neighbours)
lm.morantest(model4, spatial.weights)
wait()


## 2.7 Tidying up

# Save the workspace
# We won't actually do it but the command (without the hashtag is)
# save.image(file.choose(new=T))

# Clear the contents of the workspace
rm(list=ls())
