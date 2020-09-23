## This script was written by David Rheinheimer
## Thanks to Vicky Espinoza for an earlier draft



## This script extracts a variable from a set of year-based netcdf (.nc) files
## for a given climate and variable ID


library(raster)
library(ncdf4)
library(maptools)
library(foreign)
library(RNetCDF)
library(rgdal)
library(lubridate)
# Load the coefficients
# The coefficients file has one row for each netcdf grid cell coordinate
# and an allocation coefficient for each subwatershed for that coordinate
coeffs <- read.csv('C:/Users/gusta/Box/VICE Lab/RESEARCH/PROJECTS/CERC-WET/Task7_San_Joaquin_Model/Pywr models/data/common/hydrology/NetCDF files/Total Runoff/coefficients.csv', header=1)



# Variables (for future functionalization)
climate <- "CCSM4"
varid <- 'runoff_plus_baseflow'

# This function extracts the climate data
# climate: The climate name
# varid: the variable ID to extract
# coeffs: the dataframe of coefficients with columns lon, lat, SUB_01, SUB_02, etc. and the associated coefficients
#extract_climate_data <- function(climate, varid, coeffs) {

subwats <- tail(names(coeffs), -2) # get subwats from coefficients table (this could be done manually)

climate_path <- "C:/Users/gusta/Box/VICE Lab/RESEARCH/PROJECTS/CERC-WET/Task7_San_Joaquin_Model/Pywr models/data/common/hydrology/NetCDF files/Total Runoff/CCSM4/rcp85" #paste(netcdf_path, "total runoff", climate, sep="/")
nc_files <- list.files(path = paste(climate_path,"/", sep =""), pattern = "\\.nc$")

# Function to get coordinate value from netcdf data
get_coord_values <- function(nc_data, lon, lat) {
  nc_values <- ncvar_get(nc_data, varid=varid,
                         start= c(which.min(abs(nc_data$dim$Lon$vals - lon)), # look for closest long
                                  which.min(abs(nc_data$dim$Lat$vals - lat)),  # look for closest lat
                                  1),
                         count = c(1,1,-1)) #count '-1' means 'all values along that dimension'that dimension'
  return(nc_values)
}

# Just use the first two nc files for testing
# This should be commented out during a full extraction
# nc_files <- head(nc_files, 2)

# Loop through the netcdf files
# Note that we probably don't want to open each file more than once

big_df <- data.frame()

for (nc_file in nc_files) {
  
  nc_path <- paste(climate_path, nc_file, sep="/")
  print(nc_path)
  
  # Open the data
  nc_data <- nc_open(nc_path)
  
  # print(nc_data)
  
  # Initialize the dataframe for the netcdf file with dates
  # Day numbers in the netcdf files are days from 1800-01-01
  # so we don't need to specify a start/end date
  dates <- as.Date(nc_data$dim$Time$vals, origin='1800-01-01')
  nc_df <- data.frame(dates=dates)
  
  # Loop through the grid cell coordinates (defined in the coefficients file)
  for (row in 1:nrow(coeffs)) {
    
    lon <- coeffs[row, "lon"]
    lat <- coeffs[row, "lat"]
    
    # print(paste('Lon: ', lon, 'Lat: ', lat))
    
    # Get the values for that coordinate from the opened dataset
    nc_values <- get_coord_values(nc_data, lon, lat)
    
    # Loop through the subwatersheds and apply the respective coefficient to
    # the grid cell values
    for (subwat in subwats) {
      coeff <- coeffs[row, subwat]
      new_values <- nc_values * coeff
      if (subwat %in% colnames(nc_df)) {
        nc_df[subwat] = nc_df[subwat] + new_values
      } else {
        nc_df[subwat] = new_values
      }
      
    }
  }
  
  big_df <- rbind(big_df, nc_df)
  
  
  
  # dir.create(climate, showWarnings = FALSE)
  #outpath <- paste(climate, "runoff_mm/day.csv", sep="/")
  write.csv(big_df, "C:/Users/gusta/Desktop/PhD/CERCWET/CCSM4_allbasins.csv", row.names = FALSE)
  
  
  
}





