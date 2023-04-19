############################################################################################################
# This code is used for running the random forest algorithm for each state in the US Accidents dataset.
# Running this notebook will result in two output .csv files: 
#     (1) variable importance of all states, (2) OOB training error and test error.
############################################################################################################

### Set seed
set.seed(1)

### Load the dataset
# Data c/o Sobhan Moosavi; download the dataset here: https://smoosavi.org/datasets/us_accidents
accidents <- read.csv('US_Accidents_Dec20.csv') # Assumes the downloaded file is in the working directory
head(accidents, 3)
tail(accidents, 3)

### Get the count of observations per state
state_count <- data.frame(sort(table(accidents$State), decreasing=TRUE))
colnames(state_count)[1] <- 'State'
state_count$'%Freq' <- round(100 * state_count$Freq / sum(state_count$Freq), 4)
state_count
# Parition the states
g1 <- c('CA', 'TX', 'FL', 'SC', 'NC')
g2 <- c('NY', 'PA', 'VA', 'IL', 'OR', 'GA', 'MI', 'MN', 'AZ', 'TN', 'LA')
g3 <- c('WA', 'OH', 'MD', 'NJ', 'OK', 'UT', 'AL', 'CO', 'MA', 'MO', 'IN')
g4 <- c('CT', 'NE', 'KY', 'WI', 'IA', 'RI', 'NV', 'KS', 'NH', 'MS', 'DE')
g5 <- c('DC', 'NM', 'AR', 'ID', 'WV', 'MT', 'ME', 'VT', 'WY', 'ND', 'SD')

### Remove location, timestamp, desc, and other redundant columns
accident_df <- accidents[, c(1, 4, 11, 18, 24:46)] # Keep ID for possible matching later

### Check proportion of missing data
colMeans(is.na(accident_df))
accident_df <- accident_df[, -c(3,6)] # Remove Distance.mi., Wind_Chill.F.
accident_df$Precipitation.in.[is.na(accident_df$Precipitation.in.)] <- 0 # Assume missing precipitation means no precipitation

library(randomForest)
### Build random forest for each state
build_rf <- function(accident_df, state_list){ # input accident dataset and list of states to build a random forest for
  varImp <- NULL
  errRate <- NULL
  for (state in state_list){
    # Set random seed
    set.seed(1)
    
    # Filter data for that state
    state_df <- accident_df[accident_df$State==state,]
    state_df <- state_df[,-3] # Delete State column
    
    # Impute other missing values with mean value for that state
    state_df$Temperature.F.[is.na(state_df$Temperature.F.)] <- mean(state_df$Temperature.F.[!is.na(state_df$Temperature.F.)])
    state_df$Humidity...[is.na(state_df$Humidity...)] <- mean(state_df$Humidity...[!is.na(state_df$Humidity...)])
    state_df$Pressure.in.[is.na(state_df$Pressure.in.)] <- mean(state_df$Pressure.in.[!is.na(state_df$Pressure.in.)])
    state_df$Visibility.mi.[is.na(state_df$Visibility.mi.)] <- mean(state_df$Visibility.mi.[!is.na(state_df$Visibility.mi.)])
    state_df$Wind_Speed.mph.[is.na(state_df$Wind_Speed.mph.)] <- mean(state_df$Wind_Speed.mph.[!is.na(state_df$Wind_Speed.mph.)])
    
    #Split the dataset for training and test
    split <- sort(sample(1:nrow(state_df), round(0.8*nrow(state_df)))) # Use 80% of observations for training
    df_train <- state_df[split,]
    df_test <- state_df[-split,]
    
    # Build random forest
    cat('Building random forest for state ', state, '... ', sep='')
    rf <- randomForest(as.factor(Severity)~.-ID, data=df_train, ntree=100, importance=TRUE)
    
    # Append variable importance to varImp
    varImp <- rbind(varImp, data.frame(State=state, prop.table(importance(rf)[,c('MeanDecreaseAccuracy', 'MeanDecreaseGini')], 2)))
    
    # Get training and test error and append to errRate
    train_error <- mean(predict(rf, df_train) != df_train$Severity)
    test_error <- mean(predict(rf, df_test) != df_test$Severity)
    errRate <- rbind(errRate, data.frame(State=state, Train=train_error, Test=test_error))
    
    cat('Random forest successfully built for state ', state, '!\n', sep='')
  }
  return(list('varImp'=varImp, 'errRate'=errRate))
}

### Run the function
g1output <- build_rf(accident_df, g1)
g2output <- build_rf(accident_df, g2)
g3output <- build_rf(accident_df, g3)
g4output <- build_rf(accident_df, g4)
g5output <- build_rf(accident_df, g5)

### Consolidate results into single data frame
state_varImp <- rbind(g1output$varImp, g2output$varImp, g3output$varImp, g4output$varImp, g5output$varImp)
state_varImp
state_errRate <- rbind(g1output$errRate, g2output$errRate, g3output$errRate, g4output$errRate, g5output$errRate)
state_errRate

### Write results into csv files
write.csv(state_varImp, 'Accidents_varImp.csv')
write.csv(state_errRate, 'Accidents_errRate.csv')