-- Sakila Schema

-- public.actor definition

CREATE TABLE public.actor (
	actor_id serial4 NOT NULL,
	first_name varchar(45) NOT NULL,
	last_name varchar(45) NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT actor_pkey PRIMARY KEY (actor_id)
);
CREATE INDEX idx_actor_last_name ON actor USING btree (last_name);

-- Table Triggers

create trigger last_updated before
update
    on
    actor for each row execute procedure last_updated();


-- public.category definition

CREATE TABLE public.category (
	category_id serial4 NOT NULL,
	"name" varchar(25) NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT category_pkey PRIMARY KEY (category_id)
);

-- Table Triggers

create trigger last_updated before
update
    on
    category for each row execute procedure last_updated();


-- public.country definition

CREATE TABLE public.country (
	country_id serial4 NOT NULL,
	country varchar(50) NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT country_pkey PRIMARY KEY (country_id)
);

-- Table Triggers

create trigger last_updated before
update
    on
    country for each row execute procedure last_updated();


-- public."language" definition

CREATE TABLE public."language" (
	language_id serial4 NOT NULL,
	"name" bpchar(20) NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT language_pkey PRIMARY KEY (language_id)
);

-- Table Triggers

create trigger last_updated before
update
    on
    language for each row execute procedure last_updated();


-- public.city definition

CREATE TABLE public.city (
	city_id serial4 NOT NULL,
	city varchar(50) NOT NULL,
	country_id int2 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT city_pkey PRIMARY KEY (city_id),
	CONSTRAINT city_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.country(country_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_country_id ON city USING btree (country_id);

-- Table Triggers

create trigger last_updated before
update
    on
    city for each row execute procedure last_updated();


-- public.film definition

CREATE TABLE public.film (
	film_id serial4 NOT NULL,
	title varchar(255) NOT NULL,
	description text NULL,
	release_year public."year" NULL,
	language_id int2 NOT NULL,
	original_language_id int2 NULL,
	rental_duration int2 DEFAULT 3 NOT NULL,
	rental_rate numeric(4, 2) DEFAULT 4.99 NOT NULL,
	length int2 NULL,
	replacement_cost numeric(5, 2) DEFAULT 19.99 NOT NULL,
	rating public."mpaa_rating" DEFAULT 'G'::mpaa_rating NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	special_features _text NULL,
	fulltext tsvector NOT NULL,
	CONSTRAINT film_pkey PRIMARY KEY (film_id),
	CONSTRAINT film_language_id_fkey FOREIGN KEY (language_id) REFERENCES public."language"(language_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT film_original_language_id_fkey FOREIGN KEY (original_language_id) REFERENCES public."language"(language_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX film_fulltext_idx ON film USING gist (fulltext);
CREATE INDEX idx_fk_language_id ON film USING btree (language_id);
CREATE INDEX idx_fk_original_language_id ON film USING btree (original_language_id);
CREATE INDEX idx_title ON film USING btree (title);

-- Table Triggers

create trigger film_fulltext_trigger before
insert
    or
update
    on
    film for each row execute procedure tsvector_update_trigger('fulltext', 'pg_catalog.english', 'title', 'description');
create trigger last_updated before
update
    on
    film for each row execute procedure last_updated();


-- public.film_actor definition

CREATE TABLE public.film_actor (
	actor_id int2 NOT NULL,
	film_id int2 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT film_actor_pkey PRIMARY KEY (actor_id, film_id),
	CONSTRAINT film_actor_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actor(actor_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT film_actor_film_id_fkey FOREIGN KEY (film_id) REFERENCES public.film(film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_film_id ON film_actor USING btree (film_id);

-- Table Triggers

create trigger last_updated before
update
    on
    film_actor for each row execute procedure last_updated();


-- public.film_category definition

CREATE TABLE public.film_category (
	film_id int2 NOT NULL,
	category_id int2 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT film_category_pkey PRIMARY KEY (film_id, category_id),
	CONSTRAINT film_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(category_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT film_category_film_id_fkey FOREIGN KEY (film_id) REFERENCES public.film(film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Table Triggers

create trigger last_updated before
update
    on
    film_category for each row execute procedure last_updated();


-- public.address definition

CREATE TABLE public.address (
	address_id serial4 NOT NULL,
	address varchar(50) NOT NULL,
	address2 varchar(50) NULL,
	district varchar(20) NOT NULL,
	city_id int2 NOT NULL,
	postal_code varchar(10) NULL,
	phone varchar(20) NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT address_pkey PRIMARY KEY (address_id),
	CONSTRAINT address_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.city(city_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_city_id ON address USING btree (city_id);

-- Table Triggers

create trigger last_updated before
update
    on
    address for each row execute procedure last_updated();


-- public.customer definition

CREATE TABLE public.customer (
	customer_id serial4 NOT NULL,
	store_id int2 NOT NULL,
	first_name varchar(45) NOT NULL,
	last_name varchar(45) NOT NULL,
	email varchar(50) NULL,
	address_id int2 NOT NULL,
	activebool bool DEFAULT true NOT NULL,
	create_date date DEFAULT 'now'::text::date NOT NULL,
	last_update timestamp DEFAULT now() NULL,
	active int4 NULL,
	CONSTRAINT customer_pkey PRIMARY KEY (customer_id)
);
CREATE INDEX idx_fk_address_id ON customer USING btree (address_id);
CREATE INDEX idx_fk_store_id ON customer USING btree (store_id);
CREATE INDEX idx_last_name ON customer USING btree (last_name);

-- Table Triggers

create trigger last_updated before
update
    on
    customer for each row execute procedure last_updated();


-- public.inventory definition

CREATE TABLE public.inventory (
	inventory_id serial4 NOT NULL,
	film_id int2 NOT NULL,
	store_id int2 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT inventory_pkey PRIMARY KEY (inventory_id)
);
CREATE INDEX idx_store_id_film_id ON inventory USING btree (store_id, film_id);

-- Table Triggers

create trigger last_updated before
update
    on
    inventory for each row execute procedure last_updated();


-- public.payment definition

CREATE TABLE public.payment (
	payment_id serial4 NOT NULL,
	customer_id int2 NOT NULL,
	staff_id int2 NOT NULL,
	rental_id int4 NOT NULL,
	amount numeric(5, 2) NOT NULL,
	payment_date timestamp NOT NULL,
	CONSTRAINT payment_pkey PRIMARY KEY (payment_id)
);
CREATE INDEX idx_fk_customer_id ON payment USING btree (customer_id);
CREATE INDEX idx_fk_staff_id ON payment USING btree (staff_id);

-- Table Rules

-- DROP RULE payment_insert_p2007_01 ON public.payment;

CREATE RULE payment_insert_p2007_01 AS
    ON INSERT TO payment
   WHERE ((new.payment_date >= '2007-01-01 00:00:00'::timestamp without time zone) AND (new.payment_date < '2007-02-01 00:00:00'::timestamp without time zone)) DO INSTEAD  INSERT INTO payment_p2007_01 (payment_id, customer_id, staff_id, rental_id, amount, payment_date)
  VALUES (DEFAULT, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);
-- DROP RULE payment_insert_p2007_02 ON public.payment;

CREATE RULE payment_insert_p2007_02 AS
    ON INSERT TO payment
   WHERE ((new.payment_date >= '2007-02-01 00:00:00'::timestamp without time zone) AND (new.payment_date < '2007-03-01 00:00:00'::timestamp without time zone)) DO INSTEAD  INSERT INTO payment_p2007_02 (payment_id, customer_id, staff_id, rental_id, amount, payment_date)
  VALUES (DEFAULT, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);
-- DROP RULE payment_insert_p2007_03 ON public.payment;

CREATE RULE payment_insert_p2007_03 AS
    ON INSERT TO payment
   WHERE ((new.payment_date >= '2007-03-01 00:00:00'::timestamp without time zone) AND (new.payment_date < '2007-04-01 00:00:00'::timestamp without time zone)) DO INSTEAD  INSERT INTO payment_p2007_03 (payment_id, customer_id, staff_id, rental_id, amount, payment_date)
  VALUES (DEFAULT, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);
-- DROP RULE payment_insert_p2007_04 ON public.payment;

CREATE RULE payment_insert_p2007_04 AS
    ON INSERT TO payment
   WHERE ((new.payment_date >= '2007-04-01 00:00:00'::timestamp without time zone) AND (new.payment_date < '2007-05-01 00:00:00'::timestamp without time zone)) DO INSTEAD  INSERT INTO payment_p2007_04 (payment_id, customer_id, staff_id, rental_id, amount, payment_date)
  VALUES (DEFAULT, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);
-- DROP RULE payment_insert_p2007_05 ON public.payment;

CREATE RULE payment_insert_p2007_05 AS
    ON INSERT TO payment
   WHERE ((new.payment_date >= '2007-05-01 00:00:00'::timestamp without time zone) AND (new.payment_date < '2007-06-01 00:00:00'::timestamp without time zone)) DO INSTEAD  INSERT INTO payment_p2007_05 (payment_id, customer_id, staff_id, rental_id, amount, payment_date)
  VALUES (DEFAULT, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);
-- DROP RULE payment_insert_p2007_06 ON public.payment;

CREATE RULE payment_insert_p2007_06 AS
    ON INSERT TO payment
   WHERE ((new.payment_date >= '2007-06-01 00:00:00'::timestamp without time zone) AND (new.payment_date < '2007-07-01 00:00:00'::timestamp without time zone)) DO INSTEAD  INSERT INTO payment_p2007_06 (payment_id, customer_id, staff_id, rental_id, amount, payment_date)
  VALUES (DEFAULT, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);


-- public.payment_p2007_01 definition

CREATE TABLE public.payment_p2007_01 (
	CONSTRAINT payment_p2007_01_payment_date_check CHECK (((payment_date >= '2007-01-01 00:00:00'::timestamp without time zone) AND (payment_date < '2007-02-01 00:00:00'::timestamp without time zone)))
)
INHERITS (public.payment);
CREATE INDEX idx_fk_payment_p2007_01_customer_id ON payment_p2007_01 USING btree (customer_id);
CREATE INDEX idx_fk_payment_p2007_01_staff_id ON payment_p2007_01 USING btree (staff_id);


-- public.payment_p2007_02 definition

CREATE TABLE public.payment_p2007_02 (
	CONSTRAINT payment_p2007_02_payment_date_check CHECK (((payment_date >= '2007-02-01 00:00:00'::timestamp without time zone) AND (payment_date < '2007-03-01 00:00:00'::timestamp without time zone)))
)
INHERITS (public.payment);
CREATE INDEX idx_fk_payment_p2007_02_customer_id ON payment_p2007_02 USING btree (customer_id);
CREATE INDEX idx_fk_payment_p2007_02_staff_id ON payment_p2007_02 USING btree (staff_id);


-- public.payment_p2007_03 definition

CREATE TABLE public.payment_p2007_03 (
	CONSTRAINT payment_p2007_03_payment_date_check CHECK (((payment_date >= '2007-03-01 00:00:00'::timestamp without time zone) AND (payment_date < '2007-04-01 00:00:00'::timestamp without time zone)))
)
INHERITS (public.payment);
CREATE INDEX idx_fk_payment_p2007_03_customer_id ON payment_p2007_03 USING btree (customer_id);
CREATE INDEX idx_fk_payment_p2007_03_staff_id ON payment_p2007_03 USING btree (staff_id);


-- public.payment_p2007_04 definition

CREATE TABLE public.payment_p2007_04 (
	CONSTRAINT payment_p2007_04_payment_date_check CHECK (((payment_date >= '2007-04-01 00:00:00'::timestamp without time zone) AND (payment_date < '2007-05-01 00:00:00'::timestamp without time zone)))
)
INHERITS (public.payment);
CREATE INDEX idx_fk_payment_p2007_04_customer_id ON payment_p2007_04 USING btree (customer_id);
CREATE INDEX idx_fk_payment_p2007_04_staff_id ON payment_p2007_04 USING btree (staff_id);


-- public.payment_p2007_05 definition

CREATE TABLE public.payment_p2007_05 (
	CONSTRAINT payment_p2007_05_payment_date_check CHECK (((payment_date >= '2007-05-01 00:00:00'::timestamp without time zone) AND (payment_date < '2007-06-01 00:00:00'::timestamp without time zone)))
)
INHERITS (public.payment);
CREATE INDEX idx_fk_payment_p2007_05_customer_id ON payment_p2007_05 USING btree (customer_id);
CREATE INDEX idx_fk_payment_p2007_05_staff_id ON payment_p2007_05 USING btree (staff_id);


-- public.payment_p2007_06 definition

CREATE TABLE public.payment_p2007_06 (
	CONSTRAINT payment_p2007_06_payment_date_check CHECK (((payment_date >= '2007-06-01 00:00:00'::timestamp without time zone) AND (payment_date < '2007-07-01 00:00:00'::timestamp without time zone)))
)
INHERITS (public.payment);
CREATE INDEX idx_fk_payment_p2007_06_customer_id ON payment_p2007_06 USING btree (customer_id);
CREATE INDEX idx_fk_payment_p2007_06_staff_id ON payment_p2007_06 USING btree (staff_id);


-- public.rental definition

CREATE TABLE public.rental (
	rental_id serial4 NOT NULL,
	rental_date timestamp NOT NULL,
	inventory_id int4 NOT NULL,
	customer_id int2 NOT NULL,
	return_date timestamp NULL,
	staff_id int2 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT rental_pkey PRIMARY KEY (rental_id)
);
CREATE INDEX idx_fk_inventory_id ON rental USING btree (inventory_id);
CREATE UNIQUE INDEX idx_unq_rental_rental_date_inventory_id_customer_id ON rental USING btree (rental_date, inventory_id, customer_id);

-- Table Triggers

create trigger last_updated before
update
    on
    rental for each row execute procedure last_updated();


-- public.staff definition

CREATE TABLE public.staff (
	staff_id serial4 NOT NULL,
	first_name varchar(45) NOT NULL,
	last_name varchar(45) NOT NULL,
	address_id int2 NOT NULL,
	email varchar(50) NULL,
	store_id int2 NOT NULL,
	active bool DEFAULT true NOT NULL,
	username varchar(16) NOT NULL,
	"password" varchar(40) NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	picture bytea NULL,
	CONSTRAINT staff_pkey PRIMARY KEY (staff_id)
);

-- Table Triggers

create trigger last_updated before
update
    on
    staff for each row execute procedure last_updated();


-- public.store definition

CREATE TABLE public.store (
	store_id serial4 NOT NULL,
	manager_staff_id int2 NOT NULL,
	address_id int2 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT store_pkey PRIMARY KEY (store_id)
);
CREATE UNIQUE INDEX idx_unq_manager_staff_id ON store USING btree (manager_staff_id);

-- Table Triggers

create trigger last_updated before
update
    on
    store for each row execute procedure last_updated();


-- public.customer foreign keys

ALTER TABLE public.customer ADD CONSTRAINT customer_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.customer ADD CONSTRAINT customer_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.store(store_id) ON DELETE RESTRICT ON UPDATE CASCADE;


-- public.inventory foreign keys

ALTER TABLE public.inventory ADD CONSTRAINT inventory_film_id_fkey FOREIGN KEY (film_id) REFERENCES public.film(film_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.inventory ADD CONSTRAINT inventory_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.store(store_id) ON DELETE RESTRICT ON UPDATE CASCADE;


-- public.payment foreign keys

ALTER TABLE public.payment ADD CONSTRAINT payment_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.payment ADD CONSTRAINT payment_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES public.rental(rental_id) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE public.payment ADD CONSTRAINT payment_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE;


-- public.payment_p2007_01 foreign keys

ALTER TABLE public.payment_p2007_01 ADD CONSTRAINT payment_p2007_01_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);
ALTER TABLE public.payment_p2007_01 ADD CONSTRAINT payment_p2007_01_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES public.rental(rental_id);
ALTER TABLE public.payment_p2007_01 ADD CONSTRAINT payment_p2007_01_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id);


-- public.payment_p2007_02 foreign keys

ALTER TABLE public.payment_p2007_02 ADD CONSTRAINT payment_p2007_02_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);
ALTER TABLE public.payment_p2007_02 ADD CONSTRAINT payment_p2007_02_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES public.rental(rental_id);
ALTER TABLE public.payment_p2007_02 ADD CONSTRAINT payment_p2007_02_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id);


-- public.payment_p2007_03 foreign keys

ALTER TABLE public.payment_p2007_03 ADD CONSTRAINT payment_p2007_03_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);
ALTER TABLE public.payment_p2007_03 ADD CONSTRAINT payment_p2007_03_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES public.rental(rental_id);
ALTER TABLE public.payment_p2007_03 ADD CONSTRAINT payment_p2007_03_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id);


-- public.payment_p2007_04 foreign keys

ALTER TABLE public.payment_p2007_04 ADD CONSTRAINT payment_p2007_04_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);
ALTER TABLE public.payment_p2007_04 ADD CONSTRAINT payment_p2007_04_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES public.rental(rental_id);
ALTER TABLE public.payment_p2007_04 ADD CONSTRAINT payment_p2007_04_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id);


-- public.payment_p2007_05 foreign keys

ALTER TABLE public.payment_p2007_05 ADD CONSTRAINT payment_p2007_05_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);
ALTER TABLE public.payment_p2007_05 ADD CONSTRAINT payment_p2007_05_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES public.rental(rental_id);
ALTER TABLE public.payment_p2007_05 ADD CONSTRAINT payment_p2007_05_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id);


-- public.payment_p2007_06 foreign keys

ALTER TABLE public.payment_p2007_06 ADD CONSTRAINT payment_p2007_06_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);
ALTER TABLE public.payment_p2007_06 ADD CONSTRAINT payment_p2007_06_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES public.rental(rental_id);
ALTER TABLE public.payment_p2007_06 ADD CONSTRAINT payment_p2007_06_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id);


-- public.rental foreign keys

ALTER TABLE public.rental ADD CONSTRAINT rental_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.rental ADD CONSTRAINT rental_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES public.inventory(inventory_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.rental ADD CONSTRAINT rental_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE;


-- public.staff foreign keys

ALTER TABLE public.staff ADD CONSTRAINT staff_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.staff ADD CONSTRAINT staff_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.store(store_id);


-- public.store foreign keys

ALTER TABLE public.store ADD CONSTRAINT store_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.store ADD CONSTRAINT store_manager_staff_id_fkey FOREIGN KEY (manager_staff_id) REFERENCES public.staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE;
