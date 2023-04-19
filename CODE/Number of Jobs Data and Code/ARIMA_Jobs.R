
library(forecast) # or require(forecast)

rm(list = ls())
library(tidyverse)
setwd('/Users/yogesh/downloads/project 6242')
df <- read_csv(file='jobs_qtly_data.csv')
df[,-1] <- df[,-1]/1000



ts_pop <- ts(df[,-1], start = 1969, frequency = 1)
plot(ts_pop[,1:6], main = 'State Jobs in Thousands')



### Order Selection for ARIMA using AIC criteria
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
    # print(current.aic)
    
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


### Predicting population n years ahead for each state
n = 5

forecast <- data.frame(matrix(ncol=53,nrow=n, dimnames=list(NULL, colnames(ts_pop))))
stderr <- data.frame(matrix(ncol=53,nrow=n, dimnames=list(NULL, colnames(ts_pop))))

for (i in 1:51) {
  mod = arima(ts_pop[,i], order = final.order[i,], method = "ML")
  pop.pred = as.vector(predict(mod, n.ahead=n))
  
  forecast[,i] = pop.pred$pred
  stderr[,i] = pop.pred$se
}

accuracy(mod)




### Final dataframe containing population with predicted values
pop.with.forecast <- rbind(ts_pop, forecast)
write.csv(pop.with.forecast, "jobForecast.csv")
