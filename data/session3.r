### A Short Introduction to R
### Session 3: A Little More about the Workings of R

## 3.1 Classes and types

b <- 1:10
b
c <- seq(from=1.0, to=10.0, by=1)
c
c <- seq(1, 10, 1)
c
class(b)
class(c)
typeof(c)

b <- 1:10			
class(b)			# b is of class integer
b <- as.double(b)	# The class will be changed
class(b)
typeof(b)
class(c)			# c is of class numeric, type double
c <- as.integer(c)	# The class will be changed
c
c <- as.character(c)	# Changed to character type
class(c)
c				# Note the " " around each character

	# The operation of functions can depend on the class of object
class(b)
summary(b)		# A six number summary, suitable for continuous data
class(c)
summary(c)

	# Some examples using the plot command
	# Example 1
var1 <- rnorm(n=100, mean=100, sd=20)	# Generate some random data
set.seed(1)								# 'Fixes the draw'
var1 <- rnorm(n=100, mean=100, sd=20)
class(var1)
length(var1)	# The number of elements in the vector
summary(var1)
head(var1)		# The top of the data
tail(var1)		# The bottom of the data
plot(var1)		# A simple plot of the (unordered) data

	# Example 2
set.seed(101)
var2 <- 3 * var1 + 10 + rnorm(100, 0, 25)
			# Equivalent to var2 <- 3 * var1 + 10 + rnorm(n=100, mean=100, sd=20)
head(var2)
mydata <- data.frame(x = var1, y = var2)
			# Creates a data table with x and y as column variables
class(mydata)
head(mydata)
nrow(mydata)	# Number of rows in the data table
ncol(mydata)	# Number of columns
plot(mydata)	# A scatter plot
with(mydata, plot(x, y))	# Here the order is x, y
with(mydata, plot(y ~ x))	# Here it is y ~ x
plot(mydata$x, mydata$y)
plot(mydata[,1], mydata[,2])
plot(mydata[,2] ~ mydata[,1])

	# Example 3
model1 <- lm(y ~ x, data=mydata)	# Fits a linear model to the data
class(model1)
summary(model1)
plot(model1)	# A series of plots. Visual checks of the residuals

par(mfrow = c(2,2))	# Allows for four plots in a 2 by 2 grid
plot(model1)

par(mfrow = c(1,1))		# Resets the window to a single graph
plot(mydata)
abline(model1)	# Adds the regression line to the scatter plot


## 3.2 Data frames

class(mydata)
summary(mydata)
names(mydata)		# The column (variable) names
colnames(mydata)	# The same again
rownames(mydata)
class(rownames(mydata))
names(mydata)[1] <- "v1"	# Changes the (variable) name of column 1
names(mydata)[2] <- "v2"	# Changes the name of column 2
names(mydata)
names(mydata) <- c("x","y")	# Changes the names of both columns
rownames(mydata)[1] <- 0	# Changes the first row name to 0
rownames(mydata)
rownames(mydata) = seq(from=0, by=1, length.out=nrow(mydata))
		# Numbers the rows 0, 1, 2, etc. Useful for some GIS operations (e.g. Joins)
rownames(mydata) = 1:nrow(mydata)	# Numbers the rows 1, 2, 3, etc.
rownames(mydata)

# 3.2.1 Referencing rows and columns in a data frame

mydata[1,]				# The first row of data
mydata[2,]				# The second row of data
round(mydata[2,],2)		# The second row, rounded to 2 decimal places
mydata[nrow(mydata),]	# The final row of the data
mydata[,1]				# The first column of data
mydata[,2]				# The second column, which is also … 
mydata[,ncol(mydata)]	# … the final column of data
mydata[1,1]				# The data in the first row of the first column
mydata[5,2]				# The data in the fifth row of the second column
round(mydata[5,2],0)

mydata$x				# Equivalent to mydata[,1] because the column name is x
mydata$y
summary(mydata$x)
summary(mydata$y)
mean(mydata$x)
median(mydata$y)
sd(mydata$x)			# Gives the standard deviation of x
boxplot(mydata$y)
boxplot(mydata$y, horizontal=T, main="Boxplot of variable y")

with(mydata, var(x))	# Uses the with() function to gives the variance of x
with(mydata, plot(y, xlab="Observation number"))

# 3.2.2 Attaching a data frame

mean(x)			# Generates an error message. There is no object in the workspace called x
attach(mydata)
mean(x)			# Once the object is attached the variable names can be referenced directly
detach(mydata)
mean(x)			# An error message again!

attach(mydata)
mean(x)			# The mean of mydata$x
mydata2 = data.frame(x = 1:10, y=11:20)
head(mydata2)
attach(mydata2)	# The two attachments are beginning to conflict with each other
mean(x)			# The mean of mydata2$x
detach(mydata2)
mean(x)			# The mean of mydata$x
detach(mydata)
rm(mydata2)

# 3.2.3 Sub-setting the data table and logical queries

attach(mydata)

	# Example 1
subset <- which(x > mean(x))
class(subset)
subset				# The observations in x with values greater than the mean
mydata.sub <- mydata[subset,]
head(mydata.sub)	# The row names are inherited from the source data frame 

	# Example 2
subset <- x > mean(x)	# A logical statement. The answer is TRUE or FALSE (or missing)
class(subset)
subset
mydata.sub <- mydata[subset,]
head(mydata.sub)

	# Example 3
mydata.sub <- mydata[x > mean(x),]
			# Selects those rows that meet the logical condition, and all columns
head(mydata.sub)

mydata.sub <- mydata[x >= mean(x) & y >= mean(y),]		# The symbol & is used for and
mydata.sub <- mydata[x < mean(x) | y < mean(y),]		# The symbol | is used for or

# 3.2.4 Missing data

mydata[1,1] = NA	# Missing data are given the value NA
mydata[2,2] = NA
head(mydata)
mean(mydata$x)		# R will warn about missing data
quantile(mydata$y)
mean(mydata$x, na.rm=T)		# Ignore the NAs
quantile(mydata$y, na.rm=T)

	# To remove the method data
	# Example 1
	
subset <- !is.na(mydata$x)
			# TRUE if an observation is not missing for the specified column, x
head(subset)
x2 <- mydata$x[subset]
mean(x2)

	# More succinctly ...
with(mydata, mean(x[!is.na(x)]))

	# Example 2
	
subset <- complete.cases(mydata)
			# TRUE only if a row contains no missing data across all columns
head(subset)
mydata.complete = mydata[subset,]
head(mydata.complete)

# 3.2.5 Reading data from a file into a data frame

?read.table		# Help file
schools.data <- read.table("schools.csv", header=T, sep=",")
				# Relies on schools.csv being in the current working directory
schools.data <- read.table(file.choose(), header=T, sep=",")
schools.data <- read.csv(file.choose())

head(schools.data, n=3)		# Some simple checks of the data
ncol(schools.data)
nrow(schools.data)
summary(schools.data)


## 3.3 Lists

mylist <- list(schools.data, model1, "a")
class(mylist)
length(mylist)
head(mylist[[1]], n=3)		# Note the use of double square brackets
summary(mylist[[2]])
class(mylist[[3]])
mylist[[1]][1,]				# First row of the first part of the list
mylist[[1]][1,1]			# First cell in the first part of the list


# 3.4 Writing a function

my.function <- function(x1, x2) {
result <- (x1 * x2) / (x1 + x2)
return(result)
}

my.function(3, 7)

## 3.5 R packages for mapping and spatial data analysis

# 3.5.1 Installing and loading one or more of the packages

#* Note that these commands are 'commented out' to prevent them being accidentally run
#* They are provided for information only
#* If you wish to run them at home remove the #* symbols before each line

#* install.packages("ctv")
#* library("ctv")
#* install.views("Spatial")






