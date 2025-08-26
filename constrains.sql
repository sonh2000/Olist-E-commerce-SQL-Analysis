--add primary key and foreign key constraints about order_id
ALTER TABLE olist_orders
ADD CONSTRAINT pk_order_id PRIMARY KEY (order_id);

ALTER TABLE olist_order_items
ADD CONSTRAINT fk_order_id FOREIGN KEY (order_id)
REFERENCES olist_orders(order_id);

ALTER TABLE olist_order_reviews
add CONSTRAINT fk_order_id_review FOREIGN KEY (order_id)
REFERENCES olist_orders(order_id);

ALTER TABLE olist_order_payments
add CONSTRAINT fk_order_id_payment FOREIGN KEY (order_id)
REFERENCES olist_orders(order_id);





--add primary key and foreign key constraints about seller_id
ALTER TABLE olist_sellers
ADD CONSTRAINT pk_seller_id PRIMARY KEY (seller_id);

ALTER TABLE olist_order_items
add CONSTRAINT fk_seller_id FOREIGN KEY (seller_id)
REFERENCES olist_sellers(seller_id);






--add primary key and foreign key constraints about product_id
ALTER TABLE olist_products
ADD CONSTRAINT pk_product_id PRIMARY KEY (product_id);

ALTER TABLE olist_order_items
ADD CONSTRAINT fk_product_id FOREIGN KEY (product_id)
REFERENCES olist_products(product_id);






--add primary key and foreign key constraints about zip_code_prefix
ALTER TABLE olist_geolocation
ADD CONSTRAINT pk_zip_code foreign KEY (geolocation_zip_code_prefix);

ALTER TABLE olist_sellers
ADD CONSTRAINT fk_zip_code FOREIGN KEY (seller_zip_code_prefix)
REFERENCES olist_geolocation(geolocation_zip_code_prefix);

ALTER TABLE olist_customers 
ADD CONSTRAINT fk_zip_code_customer FOREIGN KEY (customer_zip_code_prefix)
REFERENCES olist_geolocation(geolocation_zip_code_prefix);





--add primary key and foreign key constraints about customer_id
ALTER table olist_customers
ADD CONSTRAINT pk_customer_id PRIMARY KEY (customer_id);

ALTER TABLE olist_orders
ADD CONSTRAINT fk_customer_id FOREIGN KEY (customer_id)
REFERENCES olist_customers(customer_id);

