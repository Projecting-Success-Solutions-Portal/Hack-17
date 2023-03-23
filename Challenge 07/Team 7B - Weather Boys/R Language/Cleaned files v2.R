# Assume live data in 15min intervals

#load in libraries
library(openxlsx)
library(tidyverse)
library(datetimeutils)
library(janitor)
library(readxl)
library(gsubfn)
library(data.table)

#read in data

#create empty list to iterate in
weather_station_sheets <- list()
#read in file
mysheetlist <- excel_sheets(path="C:/Users/JohnGalve/Downloads/Challenge 7/1MC05-ALJ-IM-DAT-CS01-CL01-000001.xlsx") #change directory to pull in from as this is not appropriate
#set minimum to look at with for loop
i = 1
for (i in 1:length(mysheetlist[])){
  tempdf <- read_excel("C:/Users/JohnGalve/Downloads/Challenge 7/1MC05-ALJ-IM-DAT-CS01-CL01-000001.xlsx" , sheet = mysheetlist[i], 
                       skip = 5, na ="--" ) #change directory to pull in from, same as above
  #janitor::clean_names to normalise names
  tempdf <- clean_names(tempdf)
  #iterate through names of excel sheet
  weather_station_sheets[[i]] <- tempdf
  #remove empty columns
  tempdf <- tempdf[,colSums(is.na(tempdf))<nrow(tempdf)]
  #keep only columns needed, specified for the extreme weather thresholds
  weather_cols <- c("date_time", "low_temp_c", "high_temp_c", "high_wind_speed_m_s", 
                    "high_wind_direction", "rain_mm")
  tempdf <- tempdf[, names(tempdf) %in% c(weather_cols)]
  
  #paste the above transformations to apply to all sheets and converxt to data frames
  assign(gsubfn(".", list("_" = ".", "-" = "."),mysheetlist[[i]]), tempdf) #replace special characters with accepted ones
  rm(tempdf)
  }

#print data frames into csv
dataframe_env = names(which(unlist(eapply(.GlobalEnv,is.data.frame))))
count <- 0
for(i in dataframe_env){
  count <- 1 + count
  name <- paste("C:/Users/JohnGalve/Downloads/Challenge 7/", dataframe_env[count]) # change directory output to match your one
  name <- paste0(name, ".csv") 
  write.csv(get((dataframe_env[count])), name )
}
