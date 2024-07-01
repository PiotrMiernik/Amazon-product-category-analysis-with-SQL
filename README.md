Analysis of Sports, Fitness, and Outdoors Products on Amazon (2023)
Introduction
This project presents an analysis of data on sports, fitness, and outdoor products available on Amazon in 2023. The goal of the analysis was to identify patterns and relationships between various product features, such as rating, number of ratings, price, discount value, and revenue. The analysis also focuses on differences between product categories by gender (unisex, women, men, kids).

Data Description
The data used in the analysis comes from Kaggle and includes information on 734 products. The dataset initially contained the following columns:
product_name
rating
no_of_ratings
discount_price
actual_price

During the analysis, unnecessary columns were removed, data types were transformed, missing data was handled, and new variables were created:
discount_value
takings (revenue)
product_category
rating_category

The data analysis was conducted in SQL, using the PostgreSQL database. Descriptive statistics, rankings, correlations, and data visualizations were used to uncover relationships and patterns. Additionally, the data was transformed to obtain additional variables that enabled deeper analysis. Outliers were observed in the dataset, particularly in the "number of ratings" and "revenue" columns. Analysis of these values could provide additional insights.

Technologies
Query language: SQL
Database: PostgreSQL
Data visualization: Tableau Public (dashboard available at: https://public.tableau.com/app/profile/piotr.miernik/viz/Book1_17141432705880/SportsproductsatAmazonin)
Additional Notes

Potential Directions for Further Development
Customer segmentation: Analyzing customer demographic data could help to better understand the preferences of different groups and tailor the offer.
Sentiment analysis: Analyzing customer reviews could provide information on what customers value in products and what could be improved.
Sales forecasting: Predictive models could help to anticipate future sales trends and optimize inventory.
