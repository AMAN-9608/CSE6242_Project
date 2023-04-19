#  Forecasting Aggregate National Data with Interactive Visualizations

## Project Description
<p align="justify">
The goal of this project is to provide users with an easy-to-use and interactive tool that allows them to visualize key metrics such as population, income, housing price index, temperature, road safety, and job growth in various communities, from past and current behavior to forecasted outcomes. Local governments can use the tool to identify areas that need more attention in their community – for example, which areas in their community are most accident-prone and what are the factors contributing the most to these accidents. The general population can also benefit greatly from this tool – for example, a family seeking to move may want to compare the average rent prices in Georgia to that in Texas over the next 5 years. 
</p>

<p align="justify">
As for the interactivity of the project our HTML page allows for users to hover over each of the individual states in order to see the exact trend for that state for the dataset and time period selected. It also allows for users to click on and select multiple states in order to get a graph that compares them over the years and even forecasts them into the future. For each of the different data sets, besides car accidents, we used time series data in order to create a forecast five years into the future in order to give the user an idea of the potential for that state into the future. For the car accident data the goal was to focus on identifying the most important features for determining the severity of an accident for each state, which would help state governments get a better idea of which factors influence accidents the most and thus work on improving road safety.
</p>

<p align="justify">
Data collection and cleaning were significant challenges for this project due to the decentralized nature of demographic data. Our data come from the Census Bureau, Bureau of Economic Analyses, National Oceanic and Atmospheric Adminsistration, the FRED, and the Bureau of Justice Statistics. Additionally, these organizations have varying standards and formats.  Some aggregate by state and others county. Each dataset was individualy standardized to an NxD format where N represents the observation time and D represents the state.
</p>

<p align="justify">
Prior research indicated two types of models that proved successful for predicting and forecasting new data:
</p>

- ARIMA models fit to time series data and forecast futures values based on past data. Parameters were optimized using cross validation based on the minimum AIC to determine the models
- Random forest models aggregrate decision trees to predict values and variable importance.We tuned the number of trees, node size, and variable usage parameters with cross validation


<p align="justify">
For the prediction accuracy, we have divided our data into train and test sets. The ARIMA models use the last 5 years as the test set with all other years as the training set. Our table with results for Root Mean Squared Error on all predicted variables is below. The Random Forest model indicated through the variable importance output that the presence of a traffic signal was the most significant variable for accident severity in the majority of states. Our results are considered reliable after comparison from similar models in our literature survey. State trends for 2020 differed markedly from previous years so the pandemic has created significant amounts of error for our models.
</p>


| Metric  | Population | Income | Temperature | Housing Price Index | Jobs Added |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| RMSE |  1,323,000 | 6,230 | 1.45 | 5.7 | 0.7 |


## Installation
There is no installation, all of the packages are acquired from online or are already in the file. You will need python 3 in order to run the python http server.

## Execution
In order to execute the HTML file locally, you can open up a terminal in the code folder, run the command "python -m http.server 8000" and in a web browser go to "localhost:8000", then click on project.html in order to run the page. In case you want to run the models for time-series or feature data, execute the relevant .R files. Links to the datasets and instructions are enclosed within those files.<br>
Note: A strong and stable internet connection is recommended to properly load the data and choropleth map.
