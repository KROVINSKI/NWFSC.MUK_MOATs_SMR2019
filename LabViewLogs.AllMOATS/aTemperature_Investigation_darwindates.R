##Hello World

## Author: OA Lab, NWFSC
## Title: Aquarium Temperature Investigation
## Date: April 2020

# R script below will subselect and plot temperature data for MOATs
# Overall goal is to determine if MOATs (per treatment) are true replicates
# Steps 1 thru 9+


#*********************************
##Libraries
#*********************************
library(shiny)
library(tidyverse)
library(ggplot)
library(stringr)
library(readxl)
library(readr)
library(tidyr)
library(data.table)
library (sparklyr)
library(xts)
library(TSstudio)
library(lubridate)


#*********************************
## 1.) Set working directory
#*********************************

setwd("/Users/katherinerovinski/GIT/NWFSC.MUK_MOATS_SMR2019/LabViewLogs.AllMOATS/")


#*********************************
## 2.) Spolling Data into one CSV 
#*********************************
#Combining multiple CSV files into 1 document. Original input files from individual LVM (logical volumne management) files off each MOATs.
#LVM files were then inputed to the Moats Graphy (Shiny) app
#Output from app are the CSV files manipulated below. 
#Critical user inputs at the U/I on app is the observation window- will default to 4 and average those four windows. LVM files were generated at a rate of 1:6secs. The default of 4 observation windows will generate observations 24seconds apart.

## 2.1 Create a list of files |
# All files to be joined have ext. "csv" can use that pattern to join 
files <- list.files(pattern = ".csv")
print(files)

## 2.2 Create a temporary place for files |
temp <- lapply(files, fread, sep= ",")
print(temp)

## 2.3 Create a new vector for Moats data logs |
# "M01thruM13Moatslog_data" via rbind
M01thruM13moatslog_data <- rbindlist(temp)
print(M01thruM13moatslog_data)

## 2.4 Write the new csv document | 
# "M01thruM13moatslog"
write.csv(M01thruM13moatslog_data, file = "M01thruM13moatslog.csv", row.names = FALSE)

#*********************************
## 3.) Creating the Dataframe "dml" 
#*********************************

## 3.1 Reading the CSV |  
## ensuring column names and types
## Data Moats Log = dml
dml <- read.csv(file = "M01thruM13moatslog.csv", stringsAsFactors = FALSE)
dim(dml)
#current results should read 
#[1] 14792440        7


# * * * * * * * * * * * * * * * *
## 3.1a Sub sampling dataframe "dml"  
# * * * * * * * * * * * * * * * *
## creating a sub sample of the data moats log dml dataframe to allow for quick graphs 
#subsample every 17th row (because prime numbers are indeed cool)
dml <- dml %>% arrange(moats, dateTime) %>% filter(row_number() %% 17 == 0)
dim(dml)
# after subsampling results should read
# [1] 870143      7

## 3.2 Checking variables | 
## Looking to ensure the different variables are treated as the correct variable type
## Checking the names in the dataframe
names(dml)
## Checking variable type/class 
class(dml$moats)
factor(moats)

## 3.3 Changing variables | 
## Changing MOATs to Factors for the 13 different MOATs- these will be the discrete units for follow analysis
dml$moats <- factor(dml$moats)
# Checking the names of the different levels
levels(dml$moats)
##checking the dataset, dimensions
dim(dml)

#*********************************
## 4.) Creating dateTime objects  
#*********************************

# 4.0 establish the date time object of the CSV |
dml$dateTime <- as.POSIXct(dml$dateTime, format="%Y-%m-%d %H:%M:%OS")
ReferenceTime <- as.POSIXct("2019-09-20 23:59:00")
class(ReferenceTime)

# QA check
dim(dml)
# [1] 870143      7

#*********************************
## 5.) Creating Treatment Variables  
#*********************************

## 5.1 Identifying moats per treatment |
## creating a new dataframe
## establishing treatments
dml$treatment <- ""
dml$treatment[dml$moats == "M03"| dml$moats== "M07" | dml$moats== "M10" | dml$moats== "M12"] <- "current"
dml$treatment[dml$moats == "M01"| dml$moats== "M06" | dml$moats== "M11"] <- "hightemperature"
dml$treatment[dml$moats == "M02"| dml$moats== "M08" | dml$moats== "M13"] <- "allchange"
dml$treatment[dml$moats == "M04"| dml$moats== "M05"] <- "ambient"
#verify that this new column has been created
names(dml)
#results should include:
#[1] "moats"        "dateTime"     "aTemperature" "sTemperature" "pH"          
#[6] "DO"           "salinity"     "treatment"  

# QA check
dim(dml)
#[1] 870143      8
# increase due to "treatment" addition


#*********************************
## 6.) Creating Night and Day Periods  
#*********************************

## 6.1 Narrative (Overall)
# Creating a day and night variables 
# Day and night periods will only refer to time under treatment as a way to exclude the acclimation period.
# day and night changed at about ~ 1230 on 05OCT19 
# Treatment start date considered to begin Monday 23SEP19 at 1200pm
# Krill Night Starts 1200 (~1230*) and ends 2100
# Krill Days Starts 2101 and ends 1159 (~1229*) 
# Interval 1 start 1200 23SEP19, end 1229 05OCT19
# Interval 2 start 1230 05OCT19, end 2100 30OCT19
# graphic for the loop saved at /Users/katherinerovinski/GIT/NWFSC.MUK_KRL_SMR2019/06. MOATS replication verification/Day_Night Period Loop.pdf/

# 6.2 ) creating a new column, new variable "period"
dml$period <- "" 

# 6.3 ) make new coumn with same date (Darwin's Bday) for all rows, but keeping the original time
#copy dateTime to new column
dml$time1809 <- dml$dateTime 



# _ # QA check
dim(dml)
names(dml)
# Results 
# > names(dml)
# [1] "moats"        "dateTime"     "aTemperature" "sTemperature" "pH"          
# [6] "DO"           "salinity"     "treatment"    "period"       "time1809" 


# 6.4 ) Now change the date with the date() lubridate function. This fucntion can be used to get or set the date
date(dml$time1809) <- "1809-02-12"

# _ # QA check
print(dml$time1809)
# Results
# [997] "1809-02-12 21:58:22 LMT" "1809-02-12 21:58:46 LMT" "1809-02-12 21:59:10 LMT"
# [1000] "1809-02-12 21:59:34 LMT" etc. etc. 



#define day and night start stop times on darwin's birthday
# Day and Night not broken into intervals with this R script version 
# the "ramp time" the time between noon and 12:30 will just not be included
dayStart <- as.POSIXct("1809-02-12 21:01:00")
dayStop <- as.POSIXct("1809-02-12 11:59:00")
nightStart <- as.POSIXct("1809-02-12 12:31:00")
nightStop <- as.POSIXct("1809-02-12 21:00:00")

#Now make a new column called dayNight and assign a category based on time in time1809
#this uses tidy functions. Mutate() makes a new column and case_when() assigns the categories based on conditions
# I had not used case_when() before - it is a bit cleaner than how I have done it the past
# old way is dml$dayNight[dml$time1809 >= dayStart & dml$time1809 < dayStop] <- "Day", etc.
#either way works
#have to split night into two different conditional statements at midnight 
dml <- dml %>% mutate(dayNight = case_when(time1809 >= dayStart & time1809 < dayStop ~ "Day",
                                           time1809 >= dayStop & time1809 < nightStart ~ "TransDayToNight",
                                           time1809 >= nightStart & time1809 <= as.POSIXct("1809-02-12 23:59:59") ~ "Night",
                                           time1809 >= as.POSIXct("1809-02-12 00:00:00") & time1809 <= nightStop ~ "Night",
                                           time1809 >= nightStop & time1809 < dayStart ~ "TransNightToDay"))









