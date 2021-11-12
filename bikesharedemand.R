## ----setup, include=FALSE------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ------------------------------------------------------------------------------------------------------------
library(data.table)
library(tidyverse)
library(caTools)
library(readr)


## ------------------------------------------------------------------------------------------------------------
train <- read_csv("train.csv")
str(train)
test <- read_csv("test.csv")
str(test)


## ------------------------------------------------------------------------------------------------------------
# Convert season, holiday, workingday, and weather into factor
train$season <- as.factor(train$season)
test$season <- as.factor(test$season)
train$holiday <- as.factor(train$holiday)
test$holiday <- as.factor(test$holiday)
train$workingday <- as.factor(train$workingday)
test$workingday <- as.factor(test$workingday)
train$weather <- as.factor(train$weather)
test$weather <- as.factor(test$weather)
# Add a column for day of week in train.csv & test.csv dataset
train$day <- format(as.POSIXct(train$datetime), format = '%A')
test$day <- format(as.POSIXct(test$datetime), format = '%A')
aggregate(train[,"count"],list(train$day),mean)
# Create Sunday variable
train$sunday <- ifelse(train$day == 'Sunday',1,0)
train$sunday <- as.factor(train$sunday)
test$sunday <- ifelse(test$day == 'Sunday',1,0)
test$sunday <- as.factor(test$sunday)
# Add a column for time in train.csv & test.csv dataset
train$time <- format(as.POSIXct(train$datetime), format = '%H')
train$time <- as.numeric(train$time)
train$time <- as.factor(train$time)
test$time <- format(as.POSIXct(test$datetime), format = '%H')
test$time <- as.numeric(test$time)
test$time <- as.factor(test$time)
# Add a column for temperature squared in train.csv & test.csv dataset
train$tempsq <- train$temp*train$temp
test$tempsq <- test$temp*test$temp
# Holdout-validation approach for evaluating model performance (70/30 split)
# Divide the train.csv dataset into two groups: t.test and t.train
# Stratified random sampling 
library(caret) 
set.seed(3456)
data_part <- createDataPartition(y=train$weather, times = 1, p = 0.7, list = F)
t.train = train[data_part,] #Create the train dataset
dim(t.train)
t.test = train[-data_part,] #Create the test dataset
dim(t.test)


## ------------------------------------------------------------------------------------------------------------
# Linear regression model
factor <- (count~season+workingday+weather+temp+tempsq+humidity+time+sunday)
reg <- lm(factor,data=t.train)
summary(reg)
# Create the evaluation metrics function
eval_results <- function(true, predicted, df) {
                SSE <- sum((predicted - true)^2)
                SST <- sum((true - mean(true))^2)
                R_square <- 1 - SSE / SST
                RMSE = sqrt(SSE/nrow(df))
                data.frame(
                RMSE = RMSE,
                Rsquare = R_square)
}
# Predicting and evaluating the model on the train subset of the train.csv data
predictions1 = predict(reg, newdata = t.train)
eval_results(t.train$count, predictions1, t.train)
# Predicting and evaluating the model on test subset of the train.csv data
predictions2 = predict(reg, newdata = t.test)
eval_results(t.test$count,predictions2, t.test)


## ------------------------------------------------------------------------------------------------------------
library(glmnet)
Mx<- model.matrix(count~season+holiday+workingday+weather+temp+tempsq+atemp+humidity+windspeed+time+sunday, data=t.train)
My<- t.train$count
Mx_test <- model.matrix(count~season+holiday+workingday+weather+temp+tempsq+atemp+humidity+windspeed+time+sunday, data=t.test)
My_test<-t.test$count
lambdas <- 10^seq(2, -3, by = -.1)
# Setting alpha = 1 implements lasso regression
lasso_reg <- cv.glmnet(Mx,My, alpha = 1, lambda = lambdas, standardize = TRUE, nfolds = 5)
# Best lambda
lambda_best <- lasso_reg$lambda.min 
lambda_best
lasso_model <- glmnet(Mx,My, alpha = 1, lambda = lambda_best, standardize = TRUE)
predictions3 <- predict(lasso_model, s = lambda_best, newx = Mx)
eval_results(t.train$count,predictions3,t.train)
predictions4 <- predict(lasso_model, s = lambda_best, newx = Mx_test)
eval_results(t.test$count, predictions4, t.test)


## ------------------------------------------------------------------------------------------------------------
library(rpart)
# Fit the model on the t.train set
set.seed(123)
cart <- train(
  count~season+holiday+workingday+weather+temp+tempsq+atemp+humidity+windspeed+time+sunday,
  data=t.train, method = "rpart",
  trControl = trainControl("cv", number = 10),
  tuneLength = 10
  )
# Print the best tuning parameter cp that
# minimize the model RMSE
cart$bestTune
# Decision rules in the model
cart$finalModel
# Make predictions on the test data
predictions5 <- cart %>% predict(t.train)
eval_results(t.train$count,predictions5,t.train)
predictions6 <- cart %>% predict(t.test)
eval_results(t.test$count,predictions6,t.test)


## ------------------------------------------------------------------------------------------------------------
library(randomForest)
# Using random forest to rank variables according to their importance
rf <- randomForest(count~season+holiday+workingday+weather+temp+tempsq+humidity+windspeed+time+sunday,data=t.train,importance = TRUE)
imp <- importance(rf, type=1)
featureImportance <- data.frame(Feature=row.names(imp), Importance=imp[,1])
# Graph variables based on its importance
ggplot(featureImportance, aes(x=reorder(Feature, Importance), y=Importance)) +
  geom_bar(stat="identity", fill="#53cfff") +
  coord_flip() + 
  theme_light(base_size=20) +
  xlab("Importance") +
  ylab("") + 
  ggtitle("Random Forest Feature Importance\n") +
  theme(plot.title=element_text(size=18))
# Evaluate random forest
predictions7 <- predict(rf, newdata = t.train)
eval_results(t.train$count,predictions7,t.train)
predictions8 <- predict(rf, newdata = t.test)
eval_results(t.test$count, predictions8,t.test)


## ------------------------------------------------------------------------------------------------------------
# Predict count on test.csv using random forest
finalpredictions <- round(predict(rf, newdata = test))
result <- data.frame(datetime = test$datetime, count=finalpredictions)


## ------------------------------------------------------------------------------------------------------------
test$count <- finalpredictions
complete <- dplyr::bind_rows(train, test)


## ------------------------------------------------------------------------------------------------------------
ggplot()+ aes(x=factor(complete$season),y=complete$count)+geom_bar(stat="identity",fill="blue")+scale_y_continuous(name="Total bike count",labels = scales::comma) + scale_x_discrete(name="Seasons",labels = c("Spring", "Summer", "Fall", "Winter")) + ggtitle("Bike Demand based on Seasons")


## ------------------------------------------------------------------------------------------------------------
ggplot()+ aes(x=factor(complete$time),y=complete$count)+geom_bar(stat="identity",color="blue")+scale_y_continuous(name="Total bike count",labels = scales::comma)+xlab("Time")+ggtitle("Bike Demand based on Hours")


## ------------------------------------------------------------------------------------------------------------
ggplot()+ aes(x=factor(complete$weather),y=complete$count)+geom_bar(stat="identity",color="blue")+scale_y_continuous(name="Total bike count",labels = scales::comma)+scale_x_discrete(name="Weather patterns",labels = c("Clear, partly cloudy","Mist, cloudy","Light snow, light rain","Heavy rain, snow"))+ggtitle("Bike Demand based on Weather patterns")


## ------------------------------------------------------------------------------------------------------------
ggplot(data = complete, mapping = aes(x = temp, y = count, color = temp)) +
geom_point(alpha = 1) + scale_colour_gradientn(colors=rainbow(4), trans="reverse") + xlab("Temperature") + ylab ("Count of Bikes") + ggtitle("Bike Demand based on Temp")


## ------------------------------------------------------------------------------------------------------------
ggplot(train, aes(x=time, y=count,)) + 
  geom_boxplot() + xlab("hour") + ylab("count") + ggtitle("Hourly Bike Demand for Total Users")

ggplot(train, aes(x=time, y=casual)) + 
  geom_boxplot() + xlab("hour") + ylab("casual users")+ ggtitle("Hourly Bike Demand for Casual Users")

ggplot(train, aes(x=time, y=registered)) + 
  geom_boxplot() + xlab("hour") + ylab("registered users")+ggtitle("Hourly Bike Demand for Registered Users")

