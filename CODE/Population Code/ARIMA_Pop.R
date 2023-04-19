rm(list = ls())

################################################################################
################################################################################
########################### Data Pre-processing ################################
################################################################################
################################################################################
# This section takes the csv file that can be downloaded from this link 
# https://seer.cancer.gov/popdata/download.html and organizes it into a table
# format grouped by year and state population
library(dplyr)
library(tidyverse)

df <- read.table('Pop1969_2019.txt')


df['Year'] <- as.numeric(substr(df$V1,1,4))
df['State'] <- substr(df$V1,5,6)
# df['County'] <- substr(df$V1,9,11)
# df['Race'] <- substr(df$V1,14,14)
# df['Sex'] <- substr(df$V1,16,16)
# df['Age'] <- substr(df$V1,17,18)
df['Population'] <- as.numeric(substr(df$V1,19,26))


df <- df[,-1]


temp <- df %>%
  group_by(Year, State) %>%
  summarise(Population = sum(Population))


StatePop <- temp %>%
  spread(State, Population)


# Optional line to write summarized file to a csv
write.csv(StatePop, "StatePop1969_2019.csv", row.names = FALSE)


################################################################################
################################################################################
####################### ARIMA Modeling & Forecasting ###########################
################################################################################
################################################################################

# Read in the dataset created by the pre-processing above
df <- read.csv('StatePop1969_2019.csv')
df[,-1] <- df[,-1]/1000


# Converts the data into time series format and plots the trend for the first 
# 6 states
ts_pop <- ts(df[,-1], start = 1969, frequency = 1)
plot(ts_pop[,1:6], main = 'State Population in Thousands')


# Order Selection for ARIMA using AIC criteria
p.order <- c()
d.order <- c()
q.order <- c()


for (i in 1:51) {
  cat('Order selection for state ', colnames(ts_pop)[i], ': ')
  final.aic = Inf
  for (p in 1:6) for (d in 0:1) for (q in 1:6) {
    # cat('Iteration:', p, d, q, '\n')
    skip <- FALSE
    tryCatch(
      model <- arima(ts_pop[,i], order=c(p, d, q), method = 'ML'),
      error = function(e) {skip <<- TRUE})
    if(skip) { next }
    current.aic = AIC(model)
    if (current.aic < final.aic) {
      final.aic = current.aic
      final.p = p
      final.d = d
      final.q = q
    }
  }
  p.order[i] = final.p
  d.order[i] = final.d
  q.order[i] = final.q
  cat('(', final.p, ',', final.d, ',', final.q, ')\n')
}

final.order <- cbind('p' = p.order, 'd' = d.order, 'q' = q.order)


# Predicting population n years ahead for each state
n = 5

forecast <- data.frame(matrix(ncol=51,nrow=n, dimnames=list(NULL, colnames(ts_pop))))
stderr <- data.frame(matrix(ncol=51,nrow=n, dimnames=list(NULL, colnames(ts_pop))))

for (i in 1:51) {
  mod = arima(ts_pop[,i], order = final.order[i,], method = "ML")
  pop.pred = as.vector(predict(mod, n.ahead=n))
  forecast[,i] = pop.pred$pred
  stderr[,i] = pop.pred$se
}


# Plot population including forecast for a selected state
state <- 35
t <- time(ts_pop) + n

ubound <- forecast[,state] + 1.96*stderr[,state]
lbound <- forecast[,state] - 1.96*stderr[,state]

ymin <- min(ts_pop[,state])
ymax <- max(ubound)

plot(ts_pop[,state], xlab = 'Year', ylab = 'Population in Thousands', main = colnames(ts_pop)[state], ylim = c(ymin,ymax), xlim = c(1970, 2030))
points(t[(length(t)-n+1):length(t)], forecast[,state],col="red")
lines(t[(length(t)-n+1):length(t)], ubound, lty=3, lwd= 2, col="blue")
lines(t[(length(t)-n+1):length(t)], lbound, lty=3, lwd= 2, col="blue")


# Final dataset containing population with predicted values
pop.with.forecast <- rbind(ts_pop, forecast)
write.csv(pop.with.forecast, "PopForecast.csv")


# Prediction error
RMSE <- data.frame(matrix(ncol=51,nrow=1, dimnames=list(NULL, colnames(ts_pop))))

for (i in 1:30) {
  cat('Prediction for ', colnames(ts_pop)[i])
  mod = arima(ts_pop[1:46,i], order = final.order[i,], method = "ML")
  pred = as.vector(predict(mod, n.ahead = 5))
  actual = as.vector(ts_pop[47:51,i])
  error = mean((pred$pred - actual)**2)
  RMSE[1,i] = sqrt(error)
}

for (i in 32:51) {
  cat('Prediction for ', colnames(ts_pop)[i])
  mod = arima(ts_pop[1:46,i], order = final.order[i,], method = "ML")
  pred = as.vector(predict(mod, n.ahead = 5))
  actual = as.vector(ts_pop[47:51,i])
  error = mean((pred$pred - actual)**2)
  RMSE[1,i] = error
}

rowMeans(RMSE, na.rm = TRUE)
