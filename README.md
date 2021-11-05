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

<img width="796" alt="Screen Shot 2021-11-05 at 4 27 01 PM" src="https://user-images.githubusercontent.com/93355594/140574373-bd18c72b-d222-409d-bd08-7ee355383755.png">

First, I convert _season, holiday, workingday_ and _weather_ to factors rather than numerics. I also extract _time_ and _day_ from the _datetime_ variable so that I can see demand over time and include time in modeling. I create a dummy variable named _sunday_ because I see that Sunday is the day where bike-sharing is least frequently used.

<img width="766" alt="Screen Shot 2021-11-05 at 4 33 20 PM" src="https://user-images.githubusercontent.com/93355594/140575046-79ef1712-265a-446d-87a2-343513d14ee9.png">

Lastly, I include a non-linear transformation <img src="https://render.githubusercontent.com/render/math?math=temp^2">, recognizing that the bike demand will be high when the temperature is nice, but if the temperature reaches too high then the demand will start declining.

<img width="387" alt="Screen Shot 2021-11-05 at 4 53 13 PM" src="https://user-images.githubusercontent.com/93355594/140577148-2c8c8798-52d9-4acd-ab6d-8f01d61cd24a.png">

In the correlation matrix above, I am able to see that _temp_ (the actual temperature) and _atemp_ (the "feels like" temperature) are almost perfectly correlated. Thus, I choose to exclude _atemp_ in my linear regression model.

By making these various adjustments, I am able to incorporate factors that are necessary for the next step - modeling, produce the format required for data mining, and avoid major multicollinearity issues.

### IV. Modeling
I employ four different supervised machine learning models: Multiple linear regression, Lasso regression, Classification and regression tree (CART), and Random forest. For each model, I implement holdout sampling - spliting the training dataset to 70/30: 70% for modeling and 30% for model evaluation - in order to minimize overfitting. Each individual model provides me with the expected value of our target variable, _count_. Using these outputs, I create a prediction of demand for bikes, which aids in solving the business problem highlighted in the ****Business Understanding**** section above.

**Multiple Linear Regression**

Multiple linear regression takes input variables and creates an output of the expected value of the target variable, which is determined by creating a linear model that minimizes the sum of squared errors (SSE). I create a multiple regression model to predict the _count_ variable using the season, whether or not it was a working day, the weather patterns, the observed temperature along with a quadratic transformation of the same variable, the humidity, the time of day, and whether or not it was a Sunday as input variables. I implement a backwards stepwise method using a 95 percent confidence level for feature selection. Using the multiple linear regression model is advantageous because it is very simple to understand and also provides a measurement of the effect of variable interaction, which can be utilized in further empirical analysis.

**Lasso Regression**

Lasso regression is very similar to the multiple linear regression implemented above. The main difference is attaching a penalizing function to the end of the model that reduces the model's complexity. Using this penealizing function, I am  able to perform feature selection and parameter tuning that ensures the relevance of input variables and reduces the overfitting of the model. I create a lasso regression model to predict _count_ using the variables that are determined by the lasso method. In a five-fold cross validation, I am able to determine an optimal lambda value of 0.007. Using this optimal lambda, the model determines that all input variables are significant; this means that the main value-added properties of the model come in the form of parameter tuning. Like the multiple linear regression model above, using a linear model to predict expected values may be overly simple and may miss some characteristics of the data that are relevant to making predictions.







