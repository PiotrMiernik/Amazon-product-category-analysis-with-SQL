-- Data source: https://www.kaggle.com/datasets/lokeshparab/amazon-products-dataset/data?select=All+Sports+Fitness+and+Outdoors.csv

-- Creating the beckup of dataset

create table all_sports_fitness_and_outdoors_beckup
as select * from all_sports_fitness_and_outdoors asfao;


-- Data cleaning and feature selection/engineering

	-- Checking the size of the dataset

select count(*)
from all_sports_fitness_and_outdoors asfao;

	-- Renaming columns (variables):

alter table all_sports_fitness_and_outdoors
replace column name to product_name;

alter table all_sports_fitness_and_outdoors
replace column rating to product_rating;

alter table all_sports_fitness_and_outdoors
replace column no_of_ratings to num_of_ratings;

	-- Checking duplicate values

select count(distinct product_name)
from all_sports_fitness_and_outdoors asfao;

select count(*), asfao.product_name, asfao.main_category, asfao.sub_category, asfao.image, asfao.link, asfao.product_rating, asfao.num_of_ratings, asfao.discount_price, asfao.actual_price  
from all_sports_fitness_and_outdoors asfao
group by asfao.product_name, asfao.main_category, asfao.sub_category, asfao.image, asfao.link, asfao.product_rating, asfao.num_of_ratings, asfao.discount_price, asfao.actual_price
having count(*) > 1; 

	-- Creating ID primary key column

alter table all_sports_fitness_and_outdoors 
add column id serial primary key;

	-- Deleting duplicate values

delete from all_sports_fitness_and_outdoors  
where id not in (
	select min(id)
	from all_sports_fitness_and_outdoors 
	group by product_name, main_category, sub_category, image, link, product_rating, num_of_ratings, discount_price, actual_price
);

select count(*)
from all_sports_fitness_and_outdoors asfao;

	-- Droping columns (variables) that are not important in the analysis (image, link) or have only one value (main_category, sub_category)

select 
	count(distinct product_name) as distinct_product_name, 
	count(distinct main_category) as distinct_main_category, 
	count(distinct sub_category) as distinct_sub_category, 
	count(distinct product_rating) as distinct_product_rating,
	count(distinct num_of_ratings) as distinct_num_of_ratings,
	count(distinct discount_price) as distinct_discount_price,
	count(distinct actual_price) as distinct_actual_price	
from all_sports_fitness_and_outdoors asfao; 

alter table all_sports_fitness_and_outdoors 
drop column image,
drop column link, 
drop column main_category,
drop column sub_category;

	-- Missing values analysis

select
	count(case when product_name is null then 1 end) as null_count_product_name,
	count(case when product_rating is null then 1 end) as null_count_product_rating,
	count(case when num_of_ratings is null then 1 end) as null_count_num_of_ratings,
	count(case when discount_price is null then 1 end) as null_count_discount_price,
	count(case when actual_price is null then 1 end) as null_count_actual_price
from all_sports_fitness_and_outdoors asfao 

	-- Droping missing values (NULL rows for "product_rating" column/variable - 26 rows)

select *
from all_sports_fitness_and_outdoors asfao 
where product_rating is null;

delete from all_sports_fitness_and_outdoors 
where product_rating is null;

select count(*)
from all_sports_fitness_and_outdoors asfao;

	-- Checking if data types are correct

select column_name, data_type
from information_schema.columns
where table_name = 'all_sports_fitness_and_outdoors';

	-- Removing '₹' (indian rupee) symbol, ',' separator from data and replace empty cells with NULL value (for actual_price and discount_price) 

update all_sports_fitness_and_outdoors 
set discount_price = nullif(replace(replace(discount_price, '₹', ''), ',', ''), '')::numeric,
	actual_price = nullif(replace(replace(actual_price, '₹', ''), ',', ''), '')::numeric,
	num_of_ratings = nullif(replace(num_of_ratings, ',', ''), '')::integer;

	-- Updating data types
	
alter table all_sports_fitness_and_outdoors 
alter column product_rating type numeric;

alter table all_sports_fitness_and_outdoors 
alter column num_of_ratings type int using num_of_ratings::integer;

alter table all_sports_fitness_and_outdoors 
alter column discount_price type numeric using discount_price::numeric;

alter table all_sports_fitness_and_outdoors 
alter column actual_price type numeric using actual_price::numeric;

	-- Droping missing values (NULL rows for "discount_price" column/variable - 50 rows). Final number of rows in the table: 734

select count(*)
from all_sports_fitness_and_outdoors asfao
where discount_price is null;

delete from all_sports_fitness_and_outdoors 
where discount_price is null;

select count(*)
from all_sports_fitness_and_outdoors;

	-- Changing values for columns: actual_price and discount_price from indian rupee (INR) to polish zloty (PLN)

update all_sports_fitness_and_outdoors
set actual_price = round((actual_price * 0.048), 2),
	discount_price = round((discount_price * 0.048), 2);

	-- Feature engineering 

	/* New features: discount_value and takings.
	Despite the absence of a column with the number of sold products in the dataset, 
	we can use the number of ratings (num_of_ratings) variable as a good predictor of sales value.
	 */

alter table all_sports_fitness_and_outdoors 
add column discount_value numeric,
add column takings numeric;


update all_sports_fitness_and_outdoors 
set discount_value = round((actual_price - discount_price), 2),
	takings = round((discount_price * num_of_ratings), 2);

	-- New feature: product_category (values: men, women, kids, unisex)
 
select count(*)
from all_sports_fitness_and_outdoors asfao 
where product_name ilike '%women%';

select count(*)
from all_sports_fitness_and_outdoors asfao 
where product_name ilike '% men%';

select count(*)
from all_sports_fitness_and_outdoors asfao 
where product_name ilike '%kid%' or product_name ilike '%child%';

select count(*)
from all_sports_fitness_and_outdoors asfao 
where product_name ilike '%unisex%';

alter table all_sports_fitness_and_outdoors 
add column product_category varchar(10);

update all_sports_fitness_and_outdoors 
set product_category =
	case 
		when product_name ilike '%women%' or product_name ilike '%woman%' then 'women'
		when product_name ilike '% men%' or product_name ilike '% man%' then 'men'
		when product_name ilike '%kid%' or product_name ilike '%child%' then 'kids'
		else 'unisex'
	end;

select product_category, count(*) as category_count 
from all_sports_fitness_and_outdoors asfaob 
group by product_category
order by category_count desc;

-- Data analysis:
	
	-- 'product_rating' variable

		-- Descriptive statistics

select 
	round(avg(product_rating), 2)  as avg_rating,
	percentile_disc(0.5) within group (order by product_rating) as median_rating,
	min(product_rating) as min_rating,
	max(product_rating) as max_rating,
	max(product_rating) - min(product_rating) as rating_range,
	round(stddev(product_rating), 2) as stddev_rating
from all_sports_fitness_and_outdoors;

		-- Descriptive statiscics by product category

select
	product_category,
	round(avg(product_rating), 2)  as avg_rating_by_product,
	percentile_disc(0.5) within group (order by product_rating) as median_rating_by_product,
	min(product_rating) as min_rating_by_product,
	max(product_rating) as max_rating_by_product,
	max(product_rating) - min(product_rating) as rating_range_by_product,
	round(stddev(product_rating), 2) as stddev_rating_by_product
from all_sports_fitness_and_outdoors
group by product_category
order by avg(product_rating) desc;

		-- rating ranking for all products and within product category

select
	product_name,
	product_rating,
	product_category,
	dense_rank() over (order by product_rating) as rating_rank
from all_sports_fitness_and_outdoors
order by product_rating;


select
	product_name,
	product_rating,
	product_category,
	dense_rank() over (partition by product_category order by product_rating) as rating_rank
from all_sports_fitness_and_outdoors;

		-- selecting products with lowest and highest rating where number of ratings is bigger than 1

select 
	product_name,
	product_rating,
	num_of_ratings 
from all_sports_fitness_and_outdoors 
where (product_rating = 1 or product_rating = 5) and num_of_ratings > 1
order by product_rating;

	-- 'number of rating' variable (num_of_ratings)
		
		-- Descriptive statistics

select 
	round(avg(num_of_ratings), 2)  as avg_num_of_ratings,
	percentile_disc(0.5) within group (order by num_of_ratings) as median_num_of_ratings,
	min(num_of_ratings) as min_num_of_ratings,
	max(num_of_ratings) as max_num_of_ratings,
	max(num_of_ratings) - min(num_of_ratings) as num_of_ratings_range,
	round(stddev(num_of_ratings), 2) as stddev_num_of_ratings
from all_sports_fitness_and_outdoors;

		-- Descriptive statiscics by product category

select
	product_category,
	round(avg(num_of_ratings), 2)  as avg_num_of_ratings_by_product,
	percentile_disc(0.5) within group (order by num_of_ratings) as median_num_of_ratings_by_product,
	min(num_of_ratings) as min_num_of_ratings_by_product,
	max(num_of_ratings) as max_num_of_ratings_by_product,
	max(num_of_ratings) - min(num_of_ratings) as num_of_ratings_range_by_product,
	round(stddev(num_of_ratings), 2) as stddev_num_of_ratings_by_product
from all_sports_fitness_and_outdoors
group by product_category
order by avg(num_of_ratings) desc;

		/* Due to the presence of outliers and skewness of the distribution (right-skewed distribution - positively skewed), 
		   descriptive statistics will be calculated after removing the outliers (5% of cases with the highest and lowest values of the variable)
		*/
		-- Descriptive statistics without outliers

with perceltiles as (
	select 
		percentile_disc(0.05) within group (order by num_of_ratings) as lowest_values,
		percentile_disc(0.95) within group (order by num_of_ratings) as highest_values 
	from all_sports_fitness_and_outdoors
)
select
	round(avg(num_of_ratings), 2)  as avg_num_of_ratings,
	percentile_disc(0.5) within group (order by num_of_ratings) as median_num_of_ratings,
	min(num_of_ratings) as min_num_of_ratings,
	max(num_of_ratings) as max_num_of_ratings,
	max(num_of_ratings) - min(num_of_ratings) as num_of_ratings_range,
	round(stddev(num_of_ratings), 2) as stddev_num_of_ratings
from all_sports_fitness_and_outdoors, perceltiles
where num_of_ratings > lowest_values and num_of_ratings < highest_values; 

		-- Descriptive statiscics without outliers by product category

with perceltiles as (
	select 
		percentile_disc(0.05) within group (order by num_of_ratings) as lowest_values,
		percentile_disc(0.95) within group (order by num_of_ratings) as highest_values 
	from all_sports_fitness_and_outdoors
)
select
	product_category,
	round(avg(num_of_ratings), 2)  as avg_num_of_ratings_by_product,
	percentile_disc(0.5) within group (order by num_of_ratings) as median_num_of_ratings_by_product,
	min(num_of_ratings) as min_num_of_ratings_by_product,
	max(num_of_ratings) as max_num_of_ratings_by_product,
	max(num_of_ratings) - min(num_of_ratings) as num_of_ratings_range_by_product,
	round(stddev(num_of_ratings), 2) as stddev_num_of_ratings_by_product
from all_sports_fitness_and_outdoors, perceltiles
where num_of_ratings > lowest_values and num_of_ratings < highest_values
group by product_category
order by avg(num_of_ratings) desc;

		-- 10 products with the highest and lowest number of takings
(select
	product_category,
	product_name,
	num_of_ratings
from all_sports_fitness_and_outdoors
order by num_of_ratings desc 
limit 10)
union all 
(select
	product_category,
	product_name,
	num_of_ratings
from all_sports_fitness_and_outdoors
order by num_of_ratings asc 
limit 10);
	
	-- 'Discount value' variable

		-- Descriptive statiscics

select 
	round(avg(discount_value), 2)  as avg_discount_value,
	percentile_disc(0.5) within group (order by discount_value) as median_discount_value,
	min(discount_value) as min_discount_value,
	max(discount_value) as max_discount_value,
	max(discount_value) - min(discount_value) as discount_value_range,
	round(stddev(discount_value), 2) as stddev_discount_value
from all_sports_fitness_and_outdoors;

		-- Descriptive statiscics by product category

select 
	product_category,
	round(avg(discount_value), 2)  as avg_discount_value_by_product,
	percentile_disc(0.5) within group (order by discount_value) as median_discount_value_by_product,
	min(discount_value) as min_discount_value_by_product,
	max(discount_value) as max_discount_value_by_product,
	max(discount_value) - min(discount_value) as discount_value_range_by_product,
	round(stddev(discount_value), 2) as stddev_discount_value_by_product
from all_sports_fitness_and_outdoors
group by product_category 
order by avg(discount_value) desc;

	-- Takings variable

		-- Descriptive statiscics

select 
	round(avg(takings), 2)  as avg_takings,
	percentile_disc(0.5) within group (order by takings) as median_takings,
	min(takings) as min_takings,
	max(takings) as max_takings,
	max(takings) - min(takings) as takings_range,
	round(stddev(takings), 2) as stddev_takings
from all_sports_fitness_and_outdoors;

		-- Descriptive statistics without outliers

with perceltiles as (
	select 
		percentile_disc(0.10) within group (order by takings) as lowest_values,
		percentile_disc(0.90) within group (order by takings) as highest_values 
	from all_sports_fitness_and_outdoors
)
select
	round(avg(takings), 2)  as avg_takings,
	percentile_disc(0.5) within group (order by takings) as median_takings,
	min(takings) as min_takings,
	max(takings) as max_takings,
	max(takings) - min(takings) as takings_range,
	round(stddev(takings), 2) as stddev_takings
from all_sports_fitness_and_outdoors, perceltiles
where takings > lowest_values and takings < highest_values; 

		-- Descriptive statiscics without outliers by product category

with perceltiles as (
	select 
		percentile_disc(0.10) within group (order by takings) as lowest_values,
		percentile_disc(0.90) within group (order by takings) as highest_values 
	from all_sports_fitness_and_outdoors
)
select
	product_category,
	round(avg(takings), 2)  as avg_takings_by_product,
	percentile_disc(0.5) within group (order by takings) as median_takings_by_product,
	min(takings) as min_takings_by_product,
	max(takings) as max_takings_by_product,
	max(takings) - min(takings) as takings_range_by_product,
	round(stddev(takings), 2) as stddev_takings_by_product
from all_sports_fitness_and_outdoors, perceltiles
where takings > lowest_values and takings < highest_values
group by product_category
order by avg(takings) desc;

		-- 10 products with the highest and lowest takings (revenue)

(select
	product_category,
	product_name,
	takings
from all_sports_fitness_and_outdoors
order by takings desc 
limit 10)
union all 
(select
	product_category,
	product_name,
	takings
from all_sports_fitness_and_outdoors
order by takings asc 
limit 10);

	-- Relationships between variables

select
	corr(product_rating, num_of_ratings) as correlation_1,
	corr(product_rating, actual_price) as correlation_2,
	corr(product_rating, discount_price) as correlation_3,
	corr(product_rating, discount_value) as correlation_4,
	corr(product_rating, takings) as correlation_5,
	corr(num_of_ratings, actual_price) as correlation_6,
	corr(num_of_ratings, discount_price) as correlation_7,
	corr(num_of_ratings, discount_value) as correlation_8
from all_sports_fitness_and_outdoors;

select
	product_category,
	corr(product_rating, num_of_ratings) as correlation_1,
	corr(product_rating, actual_price) as correlation_2,
	corr(product_rating, discount_price) as correlation_3,
	corr(product_rating, discount_value) as correlation_4,
	corr(product_rating, takings) as correlation_5,
	corr(num_of_ratings, actual_price) as correlation_6,
	corr(num_of_ratings, discount_price) as correlation_7,
	corr(num_of_ratings, discount_value) as correlation_8
from all_sports_fitness_and_outdoors
group by product_category
order by corr(product_rating, num_of_ratings) desc;


-- Data visualizations:
	
	-- Recoding product rating into 5 rating categories (discrete values) for visualization purpose

alter table all_sports_fitness_and_outdoors
add column rating_category varchar(10); 

update all_sports_fitness_and_outdoors
set rating_category =
	case 
		when product_rating >= 1 and product_rating < 2 then 'Very poor'
		when product_rating >= 2 and product_rating < 3 then 'Poor'
		when product_rating >= 3 and product_rating < 4 then 'Fair'
		when product_rating >= 4 and product_rating < 5 then 'Good'
		when product_rating >= 5 then 'Very good'
		else 'rating unknown'
	end;
	
	-- Dashboard in Tableau Public: https://public.tableau.com/app/profile/piotr.miernik/viz/Book1_17141432705880/SportsproductsatAmazonin

/*
Key Findings from the analysis:
* Within the analyzed product categories (sports, fitness, and outdoor), the following linear relationships exist between variables:
	- For all product categories:
		- There is a weak positive linear relationship between the variable 'Number of ratings' and 'Takings' (R-squared value of 0.32).
	- For the 'kids' product category:
		- There is a strong positive linear relationship between the variable 'Number of ratings' and 'Takings' (R-squared value of 0.89).
	- For the 'men' product category:
		- There is a weak positive linear relationship between the variable 'Number of ratings' and 'Takings' (R-squared value of 0.39).
	- For the 'unisex' product category:
		- There is a weak positive linear relationship between the variable 'Number of ratings' and 'Takings' (R-squared value of 0.24).
	- For the 'women' product category:
		- There is a strong positive linear relationship between the variable 'Number of ratings' and 'Takings' (R-squared value of 0.9).
* On average, products from the 'women' category are rated the highest, and products from the 'kids' category are rated the lowest. However, these differences are small (both for arithmetic means and medians).
* On average, products from the 'men' category are rated (and therefore purchased?) the most frequently, and products from the 'women' category are rated the least frequently.
* On average, the highest discount values occur in the 'men' and 'kids' categories, and the lowest for the 'women' category.
* On average, the highest revenue (takings) value occurs for products in the 'men' category.
* For the 'Number of ratings' and 'Takings' columns, there are significant differences between the arithmetic mean and median values. This indicates the presence of outliers for these variables.
* The degree of product differentiation in terms of their various characteristics:
	- The most diverse product ratings occur in the 'women' category. On average, the analyzed products differ by 0.63 points (stars) in terms of this variable.
	- On average, the greatest variation in the number of ratings occurs in the 'men' product category. On average, the analyzed products differ by 3,506 ratings in terms of this variable.
	- The greatest variation in discount value occurs in the 'unisex' product category. On average, the analyzed products differ by 148.9 PLN in terms of this variable.
	- The greatest variation in revenue (takings) occurs in the 'men' product category. On average, the analyzed products differ by 203,305 PLN in terms of this variable.
* Overall, the highest revenue is generated by products classified in the 'unisex' (there are the most of them) and 'men' categories. Products from the 'kids' category generate over 11 times less revenue than the leading category, and products from the 'women' category generate 7 times less.
* There may be potential to increase the number of products in the 'women' category, and especially in the 'kids' category, in the offer, and thus increase the revenue generated from these product categories. However, verification of this hypothesis requires additional research and analysis.
* In the Top 10 products category:
	- For the variables 'Number of ratings' and 'Takings', products from the 'unisex' and 'men' categories clearly dominate. These products can be defined as bestsellers and advertised as such to increase sales.
	- Among the top 10 products with the highest number of ratings, there are only two products from the 'women' category and none from the 'kids' category. Perhaps products from these categories with the highest ratings (4 and above) should be additionally promoted.
	- Products available in the analysis with a rating of 1 and more than 1 rating should be individually checked for the reasons for such low ratings (analysis of negative comments for each product).
* There are outliers in the dataset, especially for the 'Number of ratings' and 'Takings' columns. These values should be analyzed separately.
 */














