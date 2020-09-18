# Path to shapefiles that are used
shp_path <- "C:/Users/gusta/Desktop/PhD/CERCWET/GCMs/Shapefiles/"

# Path to save the csv files

csv_path <- paste0("C:/Users/gusta/Box/VICELab/RESEARCH/PROJECTS/
  CERC-WET/Task7_San_Joaquin_Model/Pywrmodels/data/",basin,"/","hydrology/   gcms","/",GCM,"_",rcp,"/")

#if the directory doesn't exist, make it!
if (!dir.exists(csv_path)){
  dir.create(file.path(csv_path), recursive = TRUE)
}

extract_netCDF <- function(netCDF_metadata, shapefile, basin){
  
  for (GCM in GCMs){
    for(rcp in rcps) {
      for(variable in variables) {
        for(year in 2006:2099){
          # Read in the netCDF data 
          dpath <- paste0(wd,"/",GCM, "/",rcp,"/",variable,".",
                          as.character(year),".v0.CA_NV.nc")
          
          file <- brick(dpath)
          # Give me the number of layers in netCDF data
          nl <- nlayers(file) 
          
          # Set the dataframe we want, to be a list, in order to store all results of the loops
          df = list() 
          
          #Set the subbasin we want, to be a list, in order to store all results of the loops
          subbasin = list() 
          
          for (layers in 1:nl){
            
            # Extract the raster file of layers
            r <- raster(file, layer = layers)
            
            # Extract relevant information from shapefile
            shp_file <- shapefile(paste0(shp_path,shapefile))
            shp_file$SUBWAT <- gsub("^.{0,4}", "sb", shp_file$SUBWAT) #switch names in the attribute table of the shp file
            #these shapefiles have basin names as MER_01, MER_02, etc. So, here I'm selecting the first 4 digits, and switching them for "sb", so that I can use this attributes later to split the .csv file directly by subbasin, already with the same labels we currently have on Box
            Shp <- shp_file["SUBWAT"]
            
            # Ensure command extract is from raster package
            extract <- raster::extract
            # Extract the mean value of cells within the polygons
            # Alternative: look to "mask" function ?mask
            masked_file <- extract(r, 
                                   Shp, #shapefile
                                   fun = mean, #this gives the mean observed values in the region, if fun = NULL, we will have values for each point, with the respective weight for each point
                                   na.rm=TRUE, 
                                   df=T, #as a dataframe
                                   small=T, #return a number, also when the buffer does not include the center of a single cell
                                   sp=T,  #extracted values are added to the data.frame
                                   weights=TRUE, #the function returns, for each polygon, a matrix with the cell values and the approximate fraction of each cell that is covered by the polygon
                                   normalizedweights=TRUE) #weights are normalized (they add up to 1 for each polygon)
            
            # Generate variable depicting the date
            # Extract the information about the time
            #same name as the other files we have on Box 
            Date <- r@z[[1]] %>% as.Date(Date, origin = "1800-01-01")
            
            
            # Compile the codes for AMC and time variable in one dataframe
            df <- data.frame(Date, masked_file)
            
            # rename column with the variable that represents the extracted values
            colnames(df)[3] <- "flow" #same name as the one we have on Box (correcting typo "flw" of the previous versions) 
            
            for(j in unique(df$SUBWAT)) { #select the data for each subbasin separately
              
              #subsetting per basin
              subbasin <- subset(df, SUBWAT == j) %>% subbasin <- subbasin[-2]
              
              # save data as .csv
              write.table(subbasin, #vector we want to save
                          file= paste0(csv_path, "tot_runoff_",j,"_mcm.csv"), #save csv files per basin
                          append=TRUE, #this gathers all the loop's results, if FALSE we'll have results being overwritten over and over again in the first line
                          sep=",",
                          col.names=!file.exists(paste0(csv_path,"tot_runoff_",j,"_mcm.csv")), #if we set as TRUE, we'll have headings repeated per each row, in this way we just have one heading
                          row.names=FALSE, #no names for rows
                          quote = FALSE) #no column with quotes
            }
          }
        }
      }
    }
  }
  
}