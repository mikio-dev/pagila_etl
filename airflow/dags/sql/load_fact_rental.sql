-- fact_rental table
--
-- Load the fact table from the src table
-- As the fact table is append only, the data is directly loaded from the src table.
-- The ID columns are replaced with the surrogate key values by looking up the corresponding
-- dimension tables.

INSERT INTO public.fact_rental (
       rental_id,
       rental_date_key,
       store_key,
       customer_key,
       film_key,
       staff_key,
       return_date_key,
       return_time_key,
       rental_count, 
       return_count,
       last_update
)
SELECT r.rental_id,
       md5(to_char(r.rental_date::timestamptz, 'YYYYMMDD')) as rental_date_key,
       sto.store_key,
       c.customer_key,
       f.film_key,
       sta.staff_key,
       md5(to_char(r.return_date::timestamptz, 'YYYYMMDD')) as return_date_key,
       md5(to_char(r.return_date::timestamptz, 'HH24MI')) as return_time_key,
       1 as rental_count,
       CASE WHEN return_date IS NULL THEN 0 ELSE 1 END as return_count,
       r.last_update       
  FROM src_rental r
  LEFT OUTER JOIN public.src_inventory i 
    ON r.inventory_id = i.inventory_id 
  LEFT OUTER JOIN public.dim_store sto
    ON i.store_id = sto.store_id
   AND sto.valid_to = '9999-12-31'
  LEFT OUTER JOIN public.dim_customer c 
    ON r.customer_id = c.customer_id 
   AND c.valid_to = '9999-12-31'
  LEFT OUTER JOIN public.dim_film f 
    ON i.film_id = f.film_id
   AND f.valid_to = '9999-12-31'
  LEFT OUTER JOIN public.dim_staff sta 
    ON r.staff_id = sta.staff_id
   AND sta.valid_to = '9999-12-31'
;