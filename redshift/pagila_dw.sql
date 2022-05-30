-- Src tables

CREATE TABLE IF NOT EXISTS public.src_actor (
    actor_id integer,
    first_name text,
    last_name text,
    last_update timestamp with time zone
);

CREATE TABLE IF NOT EXISTS public.src_address (
    address_id integer,
    address text,
    address2 text,
    district text,
    city_id integer,
    postal_code text,
    phone text,
    last_update timestamp with time zone
);

CREATE TABLE IF NOT EXISTS public.src_category (
    category_id integer,
    name text,
    last_update timestamp with time zone
);

CREATE TABLE IF NOT EXISTS public.src_city (
    city_id integer,
    city text,
    country_id integer,
    last_update timestamp with time zone
);

CREATE TABLE IF NOT EXISTS public.src_country (
    country_id integer,
    country text,
    last_update timestamp with time zone
);

CREATE TABLE IF NOT EXISTS public.src_customer (
    customer_id integer,
    store_id integer,
    first_name text,
    last_name text,
    email text,
    address_id integer,
    activebool boolean,
    create_date date,
    last_update timestamp with time zone,
    active integer
);

CREATE TABLE IF NOT EXISTS public.src_film (
    film_id integer,
    title text,
    description text,
    release_year integer,
    language_id integer,
    original_language_id integer,
    rental_duration smallint,
    rental_rate numeric(4,2),
    length smallint,
    replacement_cost numeric(5,2),
    rating varchar(5),
    last_update timestamp with time zone,
    special_features text,
    fulltext text
);

CREATE TABLE IF NOT EXISTS public.src_film_actor (
    actor_id integer,
    film_id integer,
    last_update timestamp with time zone
);

CREATE TABLE IF NOT EXISTS public.src_film_category (
    film_id integer,
    category_id integer,
    last_update timestamp with time zone
);

CREATE TABLE IF NOT EXISTS public.src_inventory (
    inventory_id integer,
    film_id integer,
    store_id integer,
    last_update timestamp with time zone
);

CREATE TABLE IF NOT EXISTS public.src_language (
    language_id integer,
    name character(20),
    last_update timestamp with time zone
);

CREATE TABLE IF NOT EXISTS public.src_payment (
    payment_id integer,
    customer_id integer,
    staff_id integer,
    rental_id integer,
    amount numeric(5,2),
    payment_date timestamp with time zone
);

CREATE TABLE IF NOT EXISTS public.src_rental (
    rental_id integer,
    rental_date timestamp with time zone,
    inventory_id integer,
    customer_id integer,
    return_date timestamp with time zone,
    staff_id integer,
    last_update timestamp with time zone
);

CREATE TABLE IF NOT EXISTS public.src_staff (
    staff_id integer,
    first_name text,
    last_name text,
    address_id integer,
    email text,
    store_id integer,
    active boolean,
    username text,
    password text,
    last_update timestamp with time zone,
    picture varchar
);

CREATE TABLE IF NOT EXISTS public.src_store (
    store_id integer,
    manager_staff_id integer,
    address_id integer,
    last_update timestamp with time zone
);

-- Staging tables

-- DROP TABLE IF EXISTS public.stg_actor;
CREATE TABLE IF NOT EXISTS public.stg_actor (
    src_actor_key text,
    tgt_actor_key text,
    actor_id integer,
    first_name text,
    last_name text,
    last_update timestamp with time zone,
    chg_flag char(1)
);

-- DROP TABLE IF EXISTS public.stg_film_actor;
CREATE TABLE IF NOT EXISTS public.stg_film_actor (
    src_film_key text,
    tgt_film_key text,
    src_actor_key text,
    tgt_actor_key text,
    film_id integer,
    actor_id integer,
    chg_flag char(1)
);

-- DROP TABLE IF EXISTS public.stg_film;
CREATE TABLE IF NOT EXISTS public.stg_film (
    src_film_key text,
    tgt_film_key text,
    film_id integer,
    title text,
    description text,
    release_year integer,
    language varchar(20),
    original_language varchar(20),
    rental_duration smallint,
    rental_rate numeric(4, 2),
    film_length smallint,
    replacement_cost numeric(5, 2),
    rating varchar(5),
    special_features text,
    category_action boolean,
    category_animation boolean,
    category_children boolean,
    category_classics boolean,
    category_comedy boolean,
    category_documentary boolean,
    category_drama boolean,
    category_family boolean,
    category_foreign boolean,
    category_games boolean,
    category_horror boolean,
    category_music boolean,
    category_new boolean,
    category_scifi boolean,
    category_sports boolean,
    category_travel boolean,
    last_update timestamp with time zone,
    chg_flag char(1)
);

-- DROP TABLE IF EXISTS public.stg_customer;
CREATE TABLE IF NOT EXISTS public.stg_customer (
    src_customer_key text,
    tgt_customer_key text,
    customer_id integer,
    first_name text,
    last_name text,
    email text,
    create_date date,
    active boolean,
    address_id integer,
    address text,
    address2 text,
    district text,
    city_id integer,
    city text,
    postal_code text,
    country_id integer,
    country text,
    phone text,
    last_update timestamp with time zone,
    chg_flag char(1)
);

-- DROP TABLE IF EXISTS public.stg_store;
CREATE TABLE IF NOT EXISTS public.stg_store (
    src_store_key text,
    tgt_store_key text,
    store_id integer,
    manager_staff_id integer,
    manager_first_name text,
    manager_last_name text,
    address_id integer,
    address text,
    address2 text,
    district text,
    city_id integer,
    city text,
    postal_code text,
    country_id integer,
    country text,
    phone text,
    last_update timestamp with time zone,
    chg_flag char(1)
);

-- DROP TABLE IF EXISTS public.stg_staff;
CREATE TABLE IF NOT EXISTS public.stg_staff (
    src_staff_key text,
    tgt_staff_key text,
    staff_id integer,
    first_name text,
    last_name text,
    store_id integer,
    active boolean,
    last_update timestamp with time zone,
    chg_flag char(1)
);

CREATE TABLE IF NOT EXISTS public.fact_rental (
    rental_id integer NOT NULL,
    rental_date_key text NOT NULL,
    store_key text NOT NULL,
    customer_key text NOT NULL,
    film_key text NOT NULL,
    staff_key text NOT NULL,
    return_date_key text NOT NULL,
    return_time_key text NOT NULL,
    rental_count integer NOT NULL, 
    return_count integer NOT NULL,
    last_update timestamp with time zone NOT NULL
);

-- DW tables

CREATE TABLE IF NOT EXISTS public.dim_actor (
    actor_key text NOT NULL,
    actor_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    last_update timestamp with time zone NOT NULL,
    valid_from date NOT NULL,
    valid_to date NOT NULL
);

CREATE TABLE IF NOT EXISTS public.dim_film_actor (
    film_key text NOT NULL,
    actor_key text NOT NULL,
    film_id integer NOT NULL,
    actor_id integer NOT NULL,
    valid_from date NOT NULL,
    valid_to date NOT NULL
);

-- DROP TABLE IF EXISTS public.dim_film;
CREATE TABLE IF NOT EXISTS public.dim_film (
    film_key text NOT NULL,
    film_id integer NOT NULL,
    title text NOT NULL,
    description text,
    release_year integer,
    language varchar(20) NOT NULL,
    original_language varchar(20),
    rental_duration smallint NOT NULL,
    rental_rate numeric(4, 2) NOT NULL,
    film_length smallint,
    replacement_cost numeric(5, 2) NOT NULL,
    rating varchar(5),
    special_features text,
    category_action boolean,
    category_animation boolean,
    category_children boolean,
    category_classics boolean,
    category_comedy boolean,
    category_documentary boolean,
    category_drama boolean,
    category_family boolean,
    category_foreign boolean,
    category_games boolean,
    category_horror boolean,
    category_music boolean,
    category_new boolean,
    category_scifi boolean,
    category_sports boolean,
    category_travel boolean,
    last_update timestamp with time zone NOT NULL,
    valid_from date NOT NULL,
    valid_to date NOT NULL
);

CREATE TABLE IF NOT EXISTS public.dim_customer (
    customer_key text NOT NULL,
    customer_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text,
    create_date date NOT NULL,
    active boolean NOT NULL,
    address_id integer NOT NULL,
    address text NOT NULL,
    address2 text,
    district text NOT NULL,
    city_id integer NOT NULL,
    city text NOT NULL,
    postal_code text,
    country_id integer NOT NULL,
    country text NOT NULL,
    phone text NOT NULL,
    last_update timestamp with time zone NOT NULL,
    valid_from date NOT NULL,
    valid_to date NOT NULL
);

CREATE TABLE IF NOT EXISTS public.dim_store (
    store_key text NOT NULL,
    store_id integer NOT NULL,
    manager_staff_id integer NOT NULL,
    manager_first_name text NOT NULL,
    manager_last_name text NOT NULL,
    address_id integer NOT NULL,
    address text NOT NULL,
    address2 text,
    district text NOT NULL,
    city_id integer NOT NULL,
    city text NOT NULL,
    postal_code text NOT NULL,
    country_id integer NOT NULL,
    country text NOT NULL,
    phone text NOT NULL,
    last_update timestamp with time zone NOT NULL,
    valid_from date NOT NULL,
    valid_to date NOT NULL
);

CREATE TABLE IF NOT EXISTS public.dim_staff (
    staff_key text NOT NULL,
    staff_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    store_id integer NOT NULL,
    active boolean NOT NULL,
    last_update timestamp with time zone NOT NULL,
    valid_from date NOT NULL,
    valid_to date NOT NULL
);

CREATE TABLE IF NOT EXISTS public.dim_date (
    date_key text NOT NULL,
    date_value date NOT NULL,
    date_full text NOT NULL,
    year_number smallint NOT NULL,
    quarter smallint NOT NULL,
    quarter_name char(2) NOT NULL,
    year_quarter char(7) NOT NULL,
    year_month char(7) NOT NULL,
    month_number smallint NOT NULL,
    month_name char(12) NOT NULL,
    day_number smallint NOT NULL,
    day_in_year smallint NOT NULL,
    week_in_year smallint NOT NULL,
    day_of_week smallint NOT NULL
);

CREATE TABLE IF NOT EXISTS public.dim_time (
    time_key text NOT NULL,
    time_value time NOT NULL,
    hours24 smallint NOT NULL,
    hours12 smallint NOT NULL,
    minutes smallint NOT NULL,
    am_pm char(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.fact_rental (
    rental_id integer NOT NULL,
    rental_date_key text NOT NULL,
    store_key text NOT NULL,
    customer_key text NOT NULL,
    film_key text NOT NULL,
    staff_key text NOT NULL,
    return_date_key text NOT NULL,
    return_time_key text NOT NULL,
    rental_count integer NOT NULL, 
    return_count integer NOT NULL,
    last_update timestamp with time zone NOT NULL
);