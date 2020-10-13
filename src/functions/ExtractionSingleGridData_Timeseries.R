##This script was written by Vicky Espinoza
##For use by Aditya Sood for CERC-WET
#this script extracts rainfall data from a single grid point (in this case the grid cell closest to 37.9491N, 119.7739W associated with Hetch Hethcy)
#prints csv file with date and water year, month

library(raster)
library(ncdf4)
library(maptools)
library(foreign)
library(RNetCDF)
library(rgdal)
library(lubridate)
library(readxl)
rm(list=ls(all=TRUE)) #start with empty workspace


extract_single_grid <- function(path, nc_file, output_path){
  date.start<- '2006-01-01'
  date.end<-'2099-12-31'
  
  obsdata <- nc_open(paste(path, nc_file, sep = "/"))
  print(obsdata) # check that dims are lon-lat-time
  
  # location of interest
  lon <- 37.9491  # longitude of a
  lat <- -119.7739 # latitude  of location
  
  # get values at location lonlat
  obsoutput <- ncvar_get(obsdata, varid = 'rainfall',
                         start= c(which.min(abs(obsdata$dim$Lon$vals - lon)), # look for closest long
                                  which.min(abs(obsdata$dim$Lat$vals - lat)),  # look for closest lat
                                  1),
                         count = c(1,1,-1)) #count '-1' means 'all values along that dimension'that dimension'
  # create dataframe
  #datafinal <- data.frame(dates= obsdatadates, obs = obsoutput)
  datafinal <- data.frame(obs = obsoutput)
  
  # get dates
  #obsdatadates <- as.Date(obsdata$dim$Time$vals, origin = '1950-01-01')
  
  # d <- seq(as.Date(date.start), as.Date(date.end),1)
  # datafinal$dates <- d
  # datafinal$month <-month(d)
  # datafinal$year <-year(d)
  # datafinal$day <-day(d)
  # datafinal$WY <- datafinal$year + (datafinal$month %in% 10:12) #this method is called vectorization
  
  write.csv(x = datafinal, file = paste0(output_path,"/rainfall_HetchHetchy-",date.start,"-",date.end,".csv"))
}

precipitation_path <- "../../Box/CERC-WET/Task7_San_Joaquin_Model/pywr_models/precipitation"

GCMs <- list.files(precipitation_path)
rcps <- c("rcp85", "rcp45")

output_path <- "../../Box/CERC-WET/Task7_San_Joaquin_Model/pywr_models/data/Tuolumne River/hydrology/gcms/MIROC5_rcp85/precipitation"

# Loop through all GCMs for this specific funciton

for(gcm in GCMs){
  if (gcm == 'Livneh') {
    next
  }
  gcm_path <- paste(precipitation_path,gcm, sep="/")
  
  for(rcp in rcps){
    rcp_path <- paste(gcm_path, rcp, sep="/")
    nc_files <- list.files(path = rcp_path)
    for(nc_file in nc_files){
      extract_single_grid(rcp_path, nc_file, output_path)
    }
  }
}
