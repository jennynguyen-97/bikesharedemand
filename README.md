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



