library(drake)
library(dplyr)
library(rvest)
library(utils)
library(readr)
library(future.batchtools)

funcs <- list.files("src/functions", full.names = T) %>% map(source)

plan <- drake_plan(
  netCDF_metadata <- readr::read_csv(drake::file_in("data/inputs/netCDF_metadata.csv")),
  
  
  
  # Calling the function to download all of the netCDF data.
  download_NetCDF <- drake::target(dynamic = map(netCDF_metadata),
                                   download_netcDF(netCDF_metadata = netCDF_metadata)),
  
  # Extracts the data from all of the downloaded netCDF files
  extract_NetCDF <- drake::target(dynamic = map(netCDF_metadata),
                                  extract_netCDF(netCDF_metadata = netCDF_metadata)),
  
)

my_plan <- mutate(my_plan)

drake::drake_config(my_plan)
