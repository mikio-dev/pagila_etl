-- load_stg_store.sql
--
-- Load the staging table with the following data:
--   - New key value calculated by the md5 function
--   - The chg_flag indicating the changes required to the dim table

BEGIN;

TRUNCATE TABLE public.stg_store
;

INSERT INTO public.stg_store(
       src_store_key, 
       tgt_store_key, 
       store_id,
       manager_staff_id,
       manager_first_name,
       manager_last_name,
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
     SELECT store_key, 
            store_id
       FROM public.dim_store
      WHERE valid_to = '9999-12-31'
),
src as (
     SELECT md5(
                coalesce(cast(manager_staff_id as text), '') ||
                coalesce(cast(manager_first_name as text), '') ||
                coalesce(cast(manager_last_name as text), '') ||
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
		     ) as store_key,
            store_id,
            manager_staff_id,
            manager_first_name,
            manager_last_name,
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
            SELECT sto.store_id,
                   sto.manager_staff_id,
                   sta.first_name as manager_first_name,
                   sta.last_name as manager_last_name,
                   sto.address_id,
                   a.address,
                   a.address2,
                   a.district,
                   a.city_id,
                   ci.city, 
                   a.postal_code,
                   ci.country_id,
                   co.country,
                   a.phone,
                   sto.last_update
              FROM public.src_store sto 
              LEFT OUTER JOIN public.src_staff sta
                ON sto.manager_staff_id = sta.staff_id 
              LEFT OUTER JOIN public.src_address a 
                ON sto.address_id = a.address_id
              LEFT OUTER JOIN public.src_city ci
                ON a.city_id = ci.city_id
              LEFT OUTER JOIN public.src_country co 
                ON ci.country_id = co.country_id
       )
)
SELECT src.store_key as src_store_key,
       tgt.store_key as tgt_store_key,
       coalesce(src.store_id, tgt.store_id) as store_id,
       manager_staff_id,
       manager_first_name,
       manager_last_name,
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
       CASE 
            WHEN tgt.store_key is NULL THEN 'I'
            WHEN src.store_key is NULL THEN 'D'
            WHEN tgt.store_key <> src.store_key THEN 'U'
            ELSE NULL
       END as chg_flag
  FROM src
  FULL OUTER JOIN tgt
    ON tgt.store_id = src.store_id
;

END;