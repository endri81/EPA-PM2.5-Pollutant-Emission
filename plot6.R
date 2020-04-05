# Instructions

# The data for this assignment are available from the course web site as a single zip file:
#   
# Data for Peer Assessment [29Mb]
# The zip file contains two files:
#   
# PM2.5 Emissions Data summarySCC_PM25.rds

# This file contains a data frame with all of the PM2.5 emissions data for 1999, 2002, 2005, and 2008. 
# For each year, the table contains number of tons of PM2.5 emitted 
# from a specific type of source for the entire year.

# ------------------------------------
# Load required libraries
if (!require('tidyverse')) install.packages('tidyverse')
library(tidyverse)

# Let's start with data download
# We copy link used in project description Data for Peer Assessment
# and assign it to fileurl

filename <- 'exdata_data_NEI_data.zip'

# Controll for already existing files
# If folder doesn't exist proceed with download
if (!file.exists(filename)){
  fileURL <- 'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip'
  download.file(fileURL, filename, method='curl')
}  

#If file exists proceed with unzip
if (!file.exists('Source_Classification_Code.rds')) { 
  unzip(filename) 
}
if (!file.exists('summarySCC_PM25.rds')) { 
  unzip(filename) 
}

# Now we read data frame

# from file Source_Classification_Code.rds
SCC <- readRDS('Source_Classification_Code.rds')



# from file summarySCC_PM25.rds
NEI <- readRDS('summarySCC_PM25.rds')

# info for SCC

glimpse(SCC)


# info for NEI

glimpse(NEI)

# Let's check for the number of missing values for each dataset

# nas for SCC
sum(is.na(SCC)) 

# nas for NEI
sum(is.na(NEI)) 


# We check classes of every column inside SCC
lapply(SCC,class)

# We check classes of every column inside NEI
lapply(NEI,class)

# Dataset SCC has variables in correct format
# In dataset NEI we will convert variables
# fips, SCC, Pollutant, type to factor class.

NEI <- NEI %>%
  mutate_if(sapply(NEI, is.character), as.factor)



####################################################
# Compare emissions from motor vehicle sources in Baltimore City 
# with emissions from motor vehicle sources 
# in Los Angeles County, California fips=='06037'
# Which city has seen greater changes over time in motor vehicle emissions?

# We will subset in two directions
# First we subset data related to motor vehicle sources 
# and then we subset data for Baltimore using fips==24510 and California fips=='06037'

# Subset data related to motor vehicle sources 
veh_data <- grepl('vehicle', SCC$SCC.Level.Two, ignore.case=TRUE)

# Subset from SCC
veh_scc <- SCC[veh_data,]$SCC

# Subset from NEi
veh_nei <- NEI[NEI$SCC %in% veh_scc,]

# Now we subset data related to Baltimore City from dataset veh_nei
veh_nei_balt <- veh_nei[veh_nei$fips=='24510',]
# Add city column to identify
veh_nei_balt$city <- 'Baltimore'

# Now we subset data related to California from dataset veh_nei
veh_nei_cal <- veh_nei[veh_nei$fips=='06037',]
# Add city column to identify
veh_nei_cal$city <- 'California'

# Merge data for both cities

tale_two_cities <- rbind(veh_nei_balt,veh_nei_cal)


## Code for construction plot6

png(filename='plot6.png') # save png

plot6 <- ggplot(tale_two_cities, aes(x=factor(year), y=Emissions, fill=city)) +
  geom_bar(aes(fill=year),stat='identity') +
  facet_grid(scales='free', space='free', .~city) +
  labs(x='Year', y= 'Total PM2.5 Pollution Emission') + 
  labs(title= 'PM2.5 Pollutant Emissions Comparision from vehicles in Baltimore vs LA 1999-2008')
print(plot6)

dev.off()
























