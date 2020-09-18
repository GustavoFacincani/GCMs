library(dplyr)
library(RCurl)
library(rvest)
library(utils)
library(readr)
library(drake)

download_netCDF <- function(netCDF_metadata){
  setwd("C:/Users/loren/Repos/GCMs/")
  
  for (GCM in netCDF_metadata$needed_GCMs){
    for(rcp in rcps) {
      for(variable in variables) {
        for ( year in 2006:2099){
          GCM_dir <- paste0(GCMs_loca,GCM,"/",rcp,"/") 
          
          # Setting the path to find the data online
          doc <- xml2::read_html(GCM_dir)
          
          # One liner for the code below?
          filenames <- html_attr(html_nodes(doc, "a"), "href") %>%
            lappy(filenames, grepl(paste0(tot_variables, year)))
          
          # Loop through all files and save them to working directory
          for (i in filenames2 ){ 
            # Determine the GCM and RCP directory
            main_path <- paste0("data/", GCM, "/", rcp, "/")
            # If the directory doesn't exist, make it!
            if (!dir.exists(main_path)){
              dir.create(file.path(main_path), recursive = TRUE)
            }
            download.file(paste0(GCM_dir, i), paste0(this.dir, GCM,"/", rcp, "/", i), mode="wb")
          }
        }	
      }
    }
  }
}
