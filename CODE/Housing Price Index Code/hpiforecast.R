####################################################################################
#This code is used to get the forecast for the House Prices Index per state.
#Running this file will result in an output .csv file containing the forecasted data.
####################################################################################

rm(list = ls())
library(forecast)
library(reshape2)

#Download the Housing Price Index Dataset from the below link
#https://www.fhfa.gov/DataTools/Downloads/Documents/HPI/HPI_AT_state.csv

df <- read.csv("HPI_AT_state.csv",header = FALSE,col.names = c("State","Year","Quarter","HPI"))

states <- unique(df$State)

n = 5 #Forecast for how many years

################################################################################
################################################################################
####################### ARIMA Modeling & Forecasting ###########################
################################################################################
################################################################################
forecast <- data.frame()
combined <- data.frame()

for (i in 1:51){
    temp <- df[df$State==states[i],] 
    tempts <- ts(temp[,4],frequency = 4,start = c(1975,1)) 
    arm = auto.arima(tempts,ic = 'aic',
                     max.p = 10,
                     max.q = 10,
                     max.P = 10,
                     max.Q = 10,
                     max.order = 10,
                     max.d = 10,
                     max.D = 10)
    f <- forecast(arm,20)
    tempdf <- data.frame(matrix(ncol=4,nrow=n*4, dimnames=list(NULL, colnames(df))))
    tempdf$State <- states[i]
    tempdf$Year <- rep(c(2021,2022,2023,2024,2025), each = 4)
    tempdf$Quarter <- rep(c(1,2,3,4), 5)
    tempdf$HPI <- melt(f$mean)[1:20,]
    if (i==1){forecast <- rbind(tempdf,forecast)}
    else {forecast <- rbind(forecast,tempdf)}
    combined <- rbind(combined,temp,tempdf)
}

#Running the below line of code will output a csv file with the results
#write.csv(combined,"hpiforecastcombined.csv", row.names = FALSE)

################################################################################
################################################################################
####################### Prediction Error #######################################
################################################################################
################################################################################
error <- data.frame()
errorstatewise <- data.frame(matrix(ncol=2,nrow=51, dimnames=list(NULL, c("State","AverageMSE"))))
errorstatewise$State <- states
for (i in 1:51){
    temp <- df[df$State==states[i],]
    row.names(temp) <- NULL
    train <- temp[1:164,]
    test <- temp[165:184,]
    tempts <- ts(train[,4],frequency = 4,start = c(1975,1))
    arm = auto.arima(tempts,ic = 'aic',
                     max.p = 10,
                     max.q = 10,
                     max.P = 10,
                     max.Q = 10,
                     max.order = 10,
                     max.d = 10,
                     max.D = 10)
    f <- forecast(arm,20)
    tempdf <- data.frame(matrix(ncol=4,nrow=n*4, dimnames=list(NULL, colnames(df))))
    tempdf$State <- states[i]
    tempdf$Year <- rep(c(2016,2017,2018,2019,2020), each = 4)
    tempdf$Quarter <- rep(c(1,2,3,4), 5)
    tempdf$HPI <- melt(f$mean)[1:20,]
    tempdf$mse <- (tempdf$HPI - test$HPI)**2
    if (i==1){error <- rbind(tempdf,error)}
    else {error <- rbind(error,tempdf)}
    errorstatewise$AverageMSE[i] <- sqrt(mean(tempdf$mse))
}

rmse <- sqrt(mean(errorstatewise$AverageMSE))
