### A Short Introduction to R
### Session 1: Getting Started with R

## 1.2 Getting Started

# 1.2.1 Using R as a calculator

1 + 1
10 - 5
10 * 2
10 - 5 * 2		# The order of operations gives priority to multiplication
(10 - 5) * 2	# The use of brackets changes the order
sqrt(100)		# Uses the function that calculates the square root
10^2			# 10 raised to the power of 2 (i.e. squared)
100^0.5			# The square root again
10^3
log10(100)		# Uses the function that calculates the common log
log10(1000)
100 / 5
100^0.5 / 5

# 1.2.2 Incomplete commands
sqrt(			# If you execute just this (incomplete) line a + sign will appear
100
)
for(i in 1:10) {
print(i)
}				


## 1.3 Scripting and Logging in R

# 1.3.1 Scripting

a <- 1:10
print(a)


## 1.4 Some R Basics

# 1.4.1 Functions, assignments and getting help

ls()			# Lists the objects in the workspace
?ls()			# Launch the help pages for the function ls()
help(ls)
?log()
a <- 10 - 5
print(a)		
b <- 10 * 2
print(b)
print(a * b)
a <- a * b
print(a)
f = a * b
print(f)		# print(...) can usually be omitted
f				# ... as it is here
sqrt(b)
print(sqrt(b), digits=3)	# Here print gives more control on the output
c(a,b)			# The c(...) function combines its arguments
c(a,sqrt(b))
print(c(a,sqrt(b)), digits=3)

_a <- 10		# Generates an error as the object name is not permitted
2a <- 10		# Also not permitted
a <- 10			# R is case sensitive ...
A <- 20			# ... therefore a and A are different objects
a == A			# and not equal to each other here

.a <- 10		# This will work but ...
ls()			# ... will not appear in the workspace (though it is there)
rm(.a, A)

# 1.4.2 Removing objects from the workspace

ls()			# Lists all the objects in the workspace
ls()[1]			# Lists the first object (alphabetically)
ls()[2]			# The second
ls()[3]			# The third
ls()[c(1,3)]	# The first and third, using the combine function
ls()[c(1,2,3)]	# The first, second and third
ls()[c(1:3)]	# And again: 1:3 means numbers 1 to 3

rm(list=ls()[c(1,3)])	# Removes the first and third objects from the workspace
ls()
rm(b)			# They can also be removed by name

rm(list=ls())	# Removes everything
ls()			# The workspace is now empty

# 1.4.3 Saving and loading workspaces

save.image(file.choose(new=T))
load(file.choose())
getwd()


## 1.5 Quitting R

q()			# Quits R. Best to save your workspace first to a file of your choosing!
q(save = "no")
q("no")