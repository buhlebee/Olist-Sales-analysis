---============================================
--- SQL to Excel E-Commerce Analytics Pipeline
---============================================
---DATASET FROM KAGGLE OLIST E-COMMERECE
---THIS SCRIPT FOCUSES ON THE CREATION,INSPECTION,CLEANING AND JOINING OF TABLES
---============================================

---STEP 1 Before i load/import the data i first have to create tables for the dataset

create table orders_data_raw (              ---Decided to have the table names end with raw as they're going to be raw when i import them and id have to clean them.
	order_id varchar ,                      ---Also assigned the different columns to specific datatypes to avoid doing it later on
	customer_id varchar,
	order_status varchar,                   ---VARCHAR/TEXT works well for columns with texts and integers. Chose VARCHAR cause its more flexible for different functions
	order_purchase_timestamp timestamp,
	order_approved_at timestamp,            ---TIMESTAMP captures the date and time 
	order_delivered_carrier_date timestamp,
	order_delivered_customer_date timestamp,
	order_estimated_delivery_date timestamp
);

---The same process will be repeated throughout step 1 till all tables can be created.
create table order_items_raw (
	order_id varchar,
	order_item_id bigint,                   ---BIGINT is more columns that have numbers without commas etc
	product_id varchar,
	seller_id varchar,
	shipping_limit_date	timestamp,
	price numeric,                          ---NUMERIC works well for columns that have decimals
	freight_value numeric
);

create table customers_raw(
	customer_id varchar,                   ---customer_id is order related.
	customer_unique_id varchar,            ---while customer_unique_id is for the person behind the order/orders
	customer_zip_code_prefix varchar,      --- some zip codes start with zero so using varchar instead of bigint to preserve the 0 
	customer_city varchar,
	customer_state varchar
);


create table products_raw (
	product_id varchar ,
	product_category_name varchar ,
	product_name_lenght bigint,
	product_description_lenght bigint,     ---lenght is a typo from the dataset
	product_photos_qty bigint,
	product_weight_g bigint,
	product_length_cm bigint,
	product_height_cm bigint,
	product_width_cm bigint
);
 create table sellers_raw (
 	seller_id varchar ,
 	seller_zip_code_prefix varchar,
 	seller_city	varchar,
 	seller_state varchar
 );

create table category_name_raw (
	product_category_name varchar ,
	product_category_name_english varchar 
);

create table order_payments_raw (
	order_id varchar ,
	payment_sequential bigint,
	payment_type varchar,
	payment_installments bigint,
	payment_value numeric
);

create table order_review_raw (
	review_id varchar ,
	order_id varchar,
	review_score bigint,
	review_comment_title varchar,
	review_comment_message varchar
);

create table geolocation_raw (
	geolocation_zip_code_prefix varchar,
	geolocation_lat numeric,
	geolocation_lng numeric,
	geolocation_city varchar,
	geolocation_state varchar
	);

---=============================================================
---NOW THAT IVE CREATED THE TABLES , I HAVE TO INSPECT AND CLEAN THE TABLES
---STEP 2 INSPECTION , DEDUPLICATE AND CLEAN THE DATA
---=============================================================

---2.1 Starting by checking null values and checking for duplicates .
select
  count(*) as total_rows,                                ---COUNT function will count the amount of rows i have.
  count(order_id) as nn_order_id,
  count(customer_id) as nn_customer_id,                  ---i used it on columns too , to compare the column rows vs the table rows as they should return the same value 
  count(order_status) as nn_status,
  count(order_purchase_timestamp) as nn_purchase_ts,
  count(order_approved_at) as nn_approved_at,
  count(order_delivered_carrier_date) as nn_carrier_date,
  count(order_delivered_customer_date) as nn_customer_date,
  count(order_estimated_delivery_date) as nn_estimated_date
from orders_data_raw;
---3 tables returned less rows: approved,carrier and customer date.
---the nulls returned relate to orders canclled or unavailable
---Decision is to leave them as null cause its not missing data ,rather incomplete orders

select order_id, count(*) 
from orders_data_raw 
group by order_id 
having count(*) > 1;


--- now im going to repeat the process for remaining tables
---2.
select
  count(*) as total_rows,                               
  count(order_id) as nn_order_id,
  count(order_item_id) as nn_order_item_id,               
  count(product_id) as nn_product_id,
  count(seller_id) as nn_seller_id,
  count(shipping_limit_date) as nn_shipping_limit_date,
  count(price) as nn_price,
  count(freight_value) as nn_freight_value
 from order_items_raw;

select order_id,order_item_id, count(*) 
from order_items_raw 
group by order_id,order_item_id 
having count(*) > 1;

--3. 
select
  count(*) as total_rows,                                
  count(customer_id) as nn_customer_id,
  count(customer_unique_id) as nn_customer_unique_id,                 
  count(customer_zip_code_prefix) as nn_customer_zip_code_prefix,
  count(customer_city) as nn_customer_city,
  count(customer_state) as customer_state
 from customers_raw;
--4. 
select
  count(*) as total_rows,                                
  count(product_id) as nn_product_id,
  count(product_category_name) as nn_product_category_name,                  
  count(product_name_lenght) as nn_product_name_lenght,
  count(product_description_lenght) as nn_product_description_lenght,
  count(product_photos_qty) as nn_product_photos_qty,
  count(product_weight_g) as nn_product_weight_g,
  count(product_length_cm) as nn_product_length_cm,     
  count(product_width_cm) as nn_product_width_cm
from products_raw;  
--- product_name lentgh ,despcription lenght and photos qty returned null values
---likely incomplete entries as not all products will have their specs written out
---decided to leave them as null cause i wont use them in my funnel

select product_id, count(*) 
from products_raw 
group by product_id 
having count(*) > 1;


--5. 
select
  count(*) as total_rows,                               
  count(seller_id) as nn_seller_id,
  count(seller_zip_code_prefix) as nn_seller_zip_code_prefix,                 
  count(seller_city) as nn_seller_city,
  count(seller_state) as nn_seller_state
 from sellers_raw;

select seller_id, count(*) 
from sellers_raw 
group by seller_id 
having count(*) > 1;
--6.
select
  count(*) as total_rows,                                
  count(product_category_name) as nn_product_category_name,
  count(product_category_name_english) as nn_product_category_name_english                  
 from category_name_raw;

select product_category_name,product_category_name_english, count(*)
from category_name_raw 
group by product_category_name,product_category_name_english 
having count(*) > 1;

--7. 
select
  count(*) as total_rows,                                
  count(order_id) as nn_order_id,
  count(payment_sequential) as nn_payment_sequential,                  
  count(payment_type) as nn_payment_type,
  count(payment_installments) as nn_payment_installments,
  count(payment_value) as nn_payment_value
 from order_payments_raw;

---8
select order_id,payment_sequential, count(*) ---counting both columns as some orders will have multiple payment methods
from order_payments_raw 
group by order_id,payment_sequential 
having count(*) > 1;

--9. 
select
  count(*) as total_rows,                               
  count(order_id) as nn_order_id,
  count(review_id) as nn_review_id,
  count(review_score) as nn_review_score,
  count(review_comment_title) as nn_review_comment_title,
  count(review_comment_message) as nn_review_comment_message
 from order_review_raw;

select order_id, count(*) 
from orders_data_raw 
group by order_id 
having count(*) > 1;



SELECT order_id, customer_id, order_status, order_purchase_timestamp, count(*)
FROM orders_data_raw
GROUP BY order_id, customer_id, order_status, order_purchase_timestamp
HAVING count(*) > 1;

---==================================================
---SUMMARY
---TABLE CREATION
---IMPORTING DATA USING IMPORT WIZARD
---DATA INSPECTION
------No duplicates where found i checked sinle columns 
------null value where found in order data raw and products raw
---
--- I WILL GO TO THE NEXT STEP. CREATING CLEAN VIEWS
---=================================================



