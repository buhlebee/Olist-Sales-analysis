---========================================
--- using the CREATE VIEW function so that i dont have to constantly update my table when it recieves new data.

create view orders_clean as 
	select* from orders_data_raw ;

create view order_items_clean as 
	select* from order_items_raw;

create view customers_clean as   
	select * from customers_raw; 

create view products_clean as   
	select 
	product_id,
    coalesce(product_category_name, 'uncategorized') AS product_category_name, ---labelling nulls to avoid blanks in excell
    product_name_lenght as product_name_length,---Fixing the typos from the original dataset
    product_description_lenght as product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
from products_raw;

create view sellers_clean as  
	select * from sellers_raw;

create view order_payments_clean as  
	select* from order_payments_raw;

create view category_names_clean as   
	select * from category_name_raw;

create view order_reviewes_clean as  
	select* from order_review_raw;

create view geolocation_clean as 
 	select* from geolocation_raw;

create view products_english as  
	select 
	pc.product_id,
	pc.product_category_name,
    coalesce(cnc.product_category_name_english,'uncategorized') as product_category_name_english,
    pc.product_name_length,
    pc.product_description_length,
    pc.product_photos_qty,
    pc.product_weight_g,
    pc.product_length_cm,
    pc.product_height_cm,
    pc.product_width_cm
    from products_clean pc 
    join category_names_clean cnc 
    on pc.product_category_name=cnc.product_category_name
    order by product_id;

	
--2 JOINS AND SALES CALCULATIONS
create view base_order_join as ---created this base join between the two tables that connect to every table in this dataset
	select    
	oc.order_id,
	oc.order_purchase_timestamp,
	oc.order_status,
	oc.customer_id,
	oic.order_item_id,
	oic.product_id,
	oic.seller_id,
	oic.price,
	oic.freight_value
	from orders_clean oc 
	join order_items_clean oic --used inner join to match the tables properly
	on oc.order_id= oic.order_id
	where order_status not in ('canceled','unavailable');--- this eliminates orders that didnt generate revenue.

create view sales_per_category as 
	select
	coalesce(pe.product_category_name_english ,'uncategorized')as category,
	sum(boj.price) as total_price,
	sum(boj.freight_value) as total_freight_value,
	count(distinct boj.order_id) as order_count
	from base_order_join boj 
	left join products_english pe --- used left join to have prices for products that might not have names
	on boj.product_id=pe.product_id
	group by category
	order by total_price desc;

create view sales_per_customer_region as  
	select
	cc.customer_state,
	sum(boj.price)as total_price,
	count(distinct boj.order_id) as order_count
	from base_order_join boj 
	join customers_clean cc 
	on  boj.customer_id=cc.customer_id
	group by customer_state
	order by total_price desc;
	
create view sales_per_seller_region as  
	select
	sc.seller_state,
	sum(boj.price)as total_price,
	count(distinct boj.order_id) as order_count
	from base_order_join boj 
	join sellers_clean sc 
	on  boj.seller_id=sc.seller_id
	group by seller_state
	order by total_price desc;
	
create view sales_per_category_region as 
	select
	coalesce(pe.product_category_name_english,'uncategorized') as category,
	cc.customer_state,
	sum(boj.price) as total_price,
	count(distinct order_id) as order_count 
	from base_order_join boj 
	left join products_english pe 
	on boj.product_id=pe.product_id
	join customers_clean cc  
	on boj.customer_id=cc.customer_id
	group by category,customer_state
	order by total_price desc;

create view monthly_sales as
	select 
	date_trunc('month',order_purchase_timestamp) as month,
	sum(price) as total_price,
	count(distinct order_id) as order_count
	from base_order_join
	group by month
	order by month;

--=============================================================
---I created 16 views in total
---5 of which were for sales
---Im going to use those 5 to create pivot tables and a dashboard on excel to complete the analysis.
--=============================================================


