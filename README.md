# Bike Sharing Demand Predictions for Capital Bikeshare in Washington, D.C.

[Capital Bikeshare](https://www.capitalbikeshare.com) is metro DC's bikeshare service, with 4,500 bikes and 500+ stations across 7 jurisdictions: Washington, DC.; Arlington, VA; Alexandria, VA; Montgomery, MD; Prince George's County, MD; Fairfax County, VA; and the City of Falls Church, VA. Designed for quick trips with convenience in mind, it’s a fun and affordable way to get around.

![CaBi-how-it-works-hero2](https://user-images.githubusercontent.com/93355594/139561008-607a884b-785c-4fa6-a6c9-ace57caca446.jpg)

The [dataset](https://www.kaggle.com/c/bike-sharing-demand/overview) includes hourly rental data spanning two years of Capital Bikeshare. The training set is comprised of the first 19 days of each month, while the test set is the 20th to the end of the month. 

## I. Business Understanding
Bike-share programs are gaining popularity in major cities worldwide, like Hangzhou, Paris, London, and New York. Despite these programs' advantages and popularity, significant operational challenges remain in areas such as distribution of bikes and availability of parking docs. According to Daniel Freund in [Scientific American](https://blogs.scientificamerican.com/observations/how-bike-sharing-can-be-more-efficient/), “because of commuting patterns, residential neighborhoods face shortages of bicycles in the morning rush, while business districts have a dearth of bikes in the evening.” 

Every day, many people use bike sharing to get around, whether for work or leisure. Acknowledging the importance of convenience, availability, and affordability in maintaining a successful bike-share program, I aim to build a predictive model that can closely and accurately predict the actual hourly demand of bikes for each day. If bike-share programs don't have enough bikes available, riders will lower their expectations, abandon bike sharing, and switch to other transportation methods. When sufficient numbers of functioning bikes are on the ground in trafficked areas, riders will trust the bike share as a reliable means of transportation.

## II. Data Understanding
I combine historical usage patterns with weather data in the train dataset to forecast bike rental demand in the test dataset, allowing Capital Bikeshare to optimize the resource allocation for bike stations across Washington, D.C.

I recognize that the dataset may be incomplete due to censored demand. That is, Capital Bikeshare only observed the realized rentals at stations at which bikes were available, not those that were not realized due to the unavailability of bikes.

## III. Data Preparation
Since the datasets are extracted from Kaggle, they are already fairly clean, but I make a few changes.

<p align="center"><img width="796" alt="Screen Shot 2021-11-05 at 4 27 01 PM" src="https://user-images.githubusercontent.com/93355594/140574373-bd18c72b-d222-409d-bd08-7ee355383755.png">

First, I convert _season, holiday, workingday_ and _weather_ to factors rather than numerics. I also extract _time_ and _day_ from the _datetime_ variable so that I can see demand over time and include time in modeling. I create a dummy variable named _sunday_ because I see that Sunday is the day where bike-sharing is least frequently used.

<p align="center"><img width="766" alt="Screen Shot 2021-11-05 at 4 33 20 PM" src="https://user-images.githubusercontent.com/93355594/140575046-79ef1712-265a-446d-87a2-343513d14ee9.png">

Lastly, I include a non-linear transformation <img src="https://render.githubusercontent.com/render/math?math=temp^2">, recognizing that the bike demand will be high when the temperature is nice, but if the temperature reaches too high then the demand will start declining.

<p align="center"><img width="387" alt="Screen Shot 2021-11-05 at 4 53 13 PM" src="https://user-images.githubusercontent.com/93355594/140577148-2c8c8798-52d9-4acd-ab6d-8f01d61cd24a.png">

In the correlation matrix above, I am able to see that _temp_ (the actual temperature) and _atemp_ (the "feels like" temperature) are almost perfectly correlated. Thus, I choose to exclude _atemp_ in my linear regression model.

By making these various adjustments, I am able to incorporate factors that are necessary for the next step - modeling, produce the format required for data mining, and avoid major multicollinearity issues.

### IV. Modeling
I employ four different supervised machine learning models: Multiple linear regression, Lasso regression, Classification and regression tree (CART), and Random forest. For each model, I implement holdout sampling - spliting the training dataset to 70/30: 70% for modeling and 30% for model evaluation - in order to minimize overfitting. Each individual model provides me with the expected value of our target variable, _count_. Using these outputs, I create a prediction of demand for bikes, which aids in solving the business problem highlighted in the ****Business Understanding**** section above.

**Multiple Linear Regression**

Multiple linear regression takes input variables and creates an output of the expected value of the target variable, which is determined by creating a linear model that minimizes the sum of squared errors (SSE). I create a multiple regression model to predict the _count_ variable using the season, whether or not it was a working day, the weather patterns, the observed temperature along with a quadratic transformation of the same variable, the humidity, the time of day, and whether or not it was a Sunday as input variables. I implement a backwards stepwise method using a 95 percent confidence level for feature selection. Using the multiple linear regression model is advantageous because it is very simple to understand and also provides a measurement of the effect of variable interaction, which can be utilized in further empirical analysis.

**Lasso Regression**

Lasso regression is very similar to the multiple linear regression implemented above. The main difference is attaching a penalizing function to the end of the model that reduces the model's complexity. Using this penealizing function, I am  able to perform feature selection and parameter tuning that ensures the relevance of input variables and reduces the overfitting of the model. I create a lasso regression model to predict _count_ using the variables that are determined by the lasso method. In a five-fold cross validation, I am able to determine an optimal lambda value of 0.001. Using this optimal lambda, the model determines that all input variables are significant; this means that the main value-added properties of the model come in the form of parameter tuning. Like the multiple linear regression model above, using a linear model to predict expected values may be overly simple and may miss some characteristics of the data that are relevant to making predictions.

**Classification and Regression Tree (CART)**

The CART model takes a set of input variables and splits them into separate groups based upon each of the input variables to determine a numerical label for the target variable. This can be interpreted as a prediction of bike demand. I create the CART model to predict the count given all variables in the dataset with the exceptions of casual and registered, which sum to count. To determine the best complexity parameter, I conduct a ten-fold cross validations; this resulted in a complexity parameter of 0.0085. CART model is beneficial when analyzing datasets that contain clearly stratified groups, can interpret non-linear relationships, and is easily interpreted. However, it is more prone to error related to outliers in the independent variable.

**Random Forest**

The random forest model is a collection of CART models trained on boostrapped data. It then takes the numerical labels that the CART models produce and averages them to create one single prediction value of the target variable. I create the random forest model with 500 trees, having three variables tried at each split. Using this model is beneficial because it is more complex, allowing it to pick up more trends and minimize variance, which improves model performance. Additionally, it assigns feature importance, allowing me to determine which variables should be included when making predictions. The trade-off with this model is that it is robust to overfitting and has a slight increase in bias when compared to the CART model. It is also much harder to interpret due to its complexity.

Possible alternatives to the models used above are Ridge regression which is similar to the Lasso model and Neural networks which are a combination of many layers of predictive models. Additionally, any combination of the models mentioned above can be used in ensemble learning, potentially increasing generalization and predictive accuracy.

### V. Evaluation
It is important to evaluate the results of the selected data mining techniques before deploying them. This scrutiny will allow me to have confidence in my models and provide significant cost savings in case my models are inaccurate. Consequently, I evaluate my predictive models on the basis of the following two measures:
1) <img src="https://render.githubusercontent.com/render/math?math=R^2">/ Out-of-sample <img src="https://render.githubusercontent.com/render/math?math=R^2">
2) Root Mean Square Error (RMSE)

I conclude that the most relevant measures of accuracy are <img src="https://render.githubusercontent.com/render/math?math=R^2"> and RMSE since my goals are to minimize prediction errors (the standard deviation of residuals) and be able to predict bike demand as close to the actual demand. Since I have both train and test data, I am able to calculate these measures in both an in-sample and out-of-sample context.

<img src="https://render.githubusercontent.com/render/math?math=R^2"> measures the proportion of variability in the dependent variable that can be explained by the independent variables, and thus sheds light on the fit of the models. In my models, random forest performs the best with an in-sample <img src="https://render.githubusercontent.com/render/math?math=R^2"> of 0.95 and an out-of-sample <img src="https://render.githubusercontent.com/render/math?math=R^2"> of 0.81.

RMSE is a good measure of how spread out the residuals of a predictive model are, meaning the lower the RMSE, the better the predictions made by the model. From the four models above, random forest has the lowest RMSE values (by a good margin) for both in-sample and out-of-sample data. Details of measurement metrics for each model can be seen below:

<p align="center"><img width="649" alt="Screen Shot 2021-11-07 at 11 56 21 PM" src="https://user-images.githubusercontent.com/93355594/140686479-6ea0ce3e-107c-4321-834b-d51a7259b1d0.png">

In order to project expected improvement, bike-sharing firms can look at ROI (return on investment). Since firms will likely invest in additional bikes in order to cater to the demand levels, they should at least break even in terms of additional revenue. Furthermore, firms should measure utilization of all bikes as well. Additional bikes may be needed for times with higher demand, but during the day there are many time slots where demand is not that high. Utilization would enable the business to know the times at which it has the sparest capacity, and the business could then tailor promotional strategies to influence higher demand during those times. 

![Hours](https://user-images.githubusercontent.com/93355594/140846658-91fca2c2-d790-4584-bf28-c3d9978823d7.png)

Lastly, it is very important to measure customer satisfaction. Given the context of the data and model, prediction accuracy is extremely important, but firms must also look at the model beyond just numbers and keep qualitative factors in mind. For example, accuracy for the 8 a.m. forecast might be more important than accuracy for a 2 p.m. forecast since the former would relate to passengers having to get to work on time, while the latter may relate to leisure activities such as going to lunch. Therefore, the dissatisfaction felt by a passenger who is late to work because of inaccurate predictions is likely to be more serious than that felt by a passenger who is late to a friends' lunch. Bike-sharing companies can include a simple single-tap rating survey every time a customer attempts to book a bike; this will enable programs to monitor improvement on a more qualitative level.
  
### VI. Deployment
Bike riders in Washington, D.C., as well as in other big cities such as New York and San Francisco count on bike-sharing to make their commutes faster, cheaper, and more fun. By deploying the result of the data mining, bike-share programs can predict the demand for bikes according to holidays, seasons, temperatures, and time of the day. By utilizing the information that is available ahead of time such as weather patterns, humidity, windspeed, and temperatures, bike-share firms can forecast the bike demand within the next week and thus reduce the uncertainty and ambiguity in their daily operations. Specifically, firms can supply and refill sufficient bikes at each docks, increase customer representative staff to assist customers on their cycling journeys, and implement an appropriate repair and mainteance schedule to minimize service disruption. Being able to predict demands ahead of time will enable bike-sharing programs to improve their operational efficiency, customer satisfaction, and business profits.
  
My recommendationed random forest model is versatile, meaning that there is very little pre-processing required and the data does not need to be rescaled or transformed. Additionally, the model has low bias, moderate variance, and is robust to outliers and non-linear data. Needless to say, besides these advantages in utilizing random forest, there are several drawbacks that firms should be aware of regarding deployment. Firstly, the random forest model is not easily interpretable. It is a predictive modeling tool and not a descriptive tool, meaning if firms are looking for a description of the relationships in their bike demand data, other approaches would be better. Secondly, random forest can't extrapolate, it can only make a prediction that is an average of previously observed labels. Consequently, if there are operational disruptions caused by natural disasters such as winter storms, tornadoes, or pandemics, the random forest model will not make accurate predictions. Firms can mitigate these limitations by using the random forest model as a part of ensemble learning.
  
### Acknowledgement
This project is part of a class project in Data Science class at Fuqua. I would like to thank professor Alex Belloni, and my teammates Joey Soeder, Annike Cummings, Areeba Farooq, and Shiza Sheikh for making this happen!







  
  






