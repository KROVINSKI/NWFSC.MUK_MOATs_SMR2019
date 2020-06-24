##Hello World

##Simple R Script to change all the LVM (Logictal Volume Manager - Lab View Files) into simple text files
# packages installed aren't needed as of the 2020.04.09 committ 
install.packages("tidyverse")
library(readxl)
library(readr)

## *S*H*E*L*L*   *O*N*L*Y* 
##written in shell for lvm to txt 
# Rename all files from .lvm to .txt
# for f in *.lvm; do
# mv -- "$f" "${f%.lvm}.txt"
# done
## *S*H*E*L*L*   *O*N*L*Y* 

#set working directory, read in files
#Setting at the main MUK MOATS Summer 2019 Folder only shows access to zip files
#setwd("/Users/katherinerovinski/GIT/NWFSC.MUK_MOATS_SMR2019/")

setwd("/Users/katherinerovinski/GIT/NWFSC.MUK_MOATS_SMR2019/LabViewLogs.AllMOATS/")

files_list = list.files(
  path = "/Users/katherinerovinski/GIT/NWFSC.MUK_MOATs_SMR2019/LabViewLogs.AllMOATS/",
  recursive = TRUE,
  pattern = "^.*\\.lvm$"
)

#creating a new files list to change file extension
for (f in files_list) {
  renamed_file <- gsub(".lvm$", ".tsv", f)
  file.rename(f, renamed_file) 
}
