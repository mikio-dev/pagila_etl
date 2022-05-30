-- load_stg_customer.sql
--
-- Load the staging table with the following data:
--   - New key value calculated by the md5 function
--   - The chg_flag indicating the changes required to the dim table

BEGIN;

TRUNCATE TABLE public.stg_customer
;

INSERT INTO public.stg_customer(
       src_customer_key, 
       tgt_customer_key, 
       customer_id,
       first_name,
       last_name,
       email,
       create_date,
       active,
       address_id,
       address,
       address2,
       district,
       city_id,
       city,
       postal_code,
       country_id,
       country,
       phone,
       last_update,
       chg_flag   
)
WITH tgt as (
  SELECT customer_key,
         customer_id
    FROM public.dim_customer
   WHERE valid_to = '9999-12-31'
),
src as (
  SELECT md5(
            coalesce(cast(first_name as text), '') ||
            coalesce(cast(last_name as text), '') ||
            coalesce(cast(email as text), '') ||
            coalesce(cast(create_date as text), '') ||
            coalesce(cast(active as text), '') ||
            coalesce(cast(address_id as text), '') ||
            coalesce(cast(address as text), '') ||
            coalesce(cast(address2 as text), '') ||
            coalesce(cast(district as text), '') ||
            coalesce(cast(city_id as text), '') ||
            coalesce(cast(city as text), '') ||
            coalesce(cast(postal_code as text), '') ||
            coalesce(cast(country_id as text), '') ||
            coalesce(cast(country as text), '') ||
            coalesce(cast(phone as text), '') 
         ) as customer_key,
         customer_id,
         first_name,
         last_name,
         email,
         create_date,
         active,
         address_id,
         address,
         address2,
         district,
         city_id,
         city,
         postal_code,
         country_id,
         country,
         phone,
         last_update
    FROM (
         SELECT cu.customer_id,
                cu.first_name,
                cu.last_name,
                cu.email,
                cu.create_date,
                cu.active,
                cu.address_id,
                a.address,
                a.address2,
                a.district,
                a.city_id,
                ci.city,
                a.postal_code,
                ci.country_id,
                co.country,
                a.phone,
                cu.last_update
           FROM public.src_customer cu
           LEFT OUTER JOIN public.src_address a
             ON cu.address_id = a.address_id
           LEFT OUTER JOIN public.src_city ci 
             ON a.city_id = ci.city_id
           LEFT OUTER JOIN public.src_country co 
             ON ci.country_id = co.country_id 
    )
)
SELECT src.customer_key as src_customer_key,
       tgt.customer_key as tgt_customer_key,
       coalesce(src.customer_id, tgt.customer_id) as customer_id,
       src.first_name,
       src.last_name,
       src.email,
       src.create_date,
       src.active,
       src.address_id,
       src.address,
       src.address2,
       src.district,
       src.city_id,
       src.city,
       src.postal_code,
       src.country_id,
       src.country,
       src.phone,
       src.last_update,
       CASE 
            WHEN tgt.customer_key is NULL THEN 'I'
            WHEN src.customer_key is NULL THEN 'D'
            WHEN tgt.customer_key <> src.customer_key THEN 'U'
            ELSE NULL
       END as chg_flag
  FROM src
  FULL OUTER JOIN tgt
    ON tgt.customer_id = src.customer_id
;

END;