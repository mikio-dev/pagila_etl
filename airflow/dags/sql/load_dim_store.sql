-- load_dim_store.sql
--
-- Load the dim table from the stg table
--   - For chg_flag = 'U' and 'D', close the existing records with valid_to set to the logical date - 1 day
--   - For chg_flag = 'I' and 'U', insert the records with valid_from set to the logical date and valid_to set to '9999-12-31'


-- Close the updated and deleted records
UPDATE public.dim_store
   SET valid_to = cast('{{ ds }}' as DATE) - interval '1 day'
 WHERE store_key in (
     SELECT tgt_store_key 
       FROM public.stg_store
      WHERE chg_flag in ('U', 'D')
 );

-- Insert the updated records
INSERT INTO public.dim_store (
       store_key,
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
       valid_from,
       valid_to
)
SELECT src_store_key as store_key, 
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
       cast('{{ ds }}' as DATE) as valid_from,
       cast('9999-12-31' as DATE) as valid_to
  FROM public.stg_store
 WHERE chg_flag in ('U', 'I')
;
