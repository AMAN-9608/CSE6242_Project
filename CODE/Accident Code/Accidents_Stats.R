############################################################################################################
# This code is used to get the average annual number of accidents per state and average severity per state.
# Running this notebook will result in an output .csv file containing the aforementioned information.
############################################################################################################

### Load the dataset
# Data c/o Sobhan Moosavi; download the dataset here: https://smoosavi.org/datasets/us_accidents
accidents <- read.csv('US_Accidents_Dec20.csv') # Assumes the downloaded file is in the working directory

### Get Year
accidents$Year <- as.numeric(substring(accidents$Start_Time, 1, 4))

### Consider data from 2017-2020 only
data_scope <- accidents[accidents$Year > 2016,]

### Summarize the data
library(dplyr)
# Get average annual number of accidents per state
ave_num <- data_scope %>% group_by(State) %>% summarise(Ave_Yrly_Acc = n()/4) %>% arrange(desc(Ave_Yrly_Acc))
# Get average severity of accidents per state
ave_sev <- data_scope %>% group_by(State) %>% summarise(Ave_Severity = mean(Severity))
# Join the two tables
join_ave <- inner_join(ave_num, ave_sev, by='State')
join_ave
# Save output to csv file
write.csv(join_ave, 'Accidents_Stats.csv')