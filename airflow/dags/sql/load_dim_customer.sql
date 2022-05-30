-- load_dim_customer.sql
--
-- Load the dim table from the stg table
--   - For chg_flag = 'U' and 'D', close the existing records with valid_to set to the logical date - 1 day
--   - For chg_flag = 'I' and 'U', insert the records with valid_from set to the logical date and valid_to set to '9999-12-31'


-- Close the updated and deleted records
UPDATE public.dim_customer
   SET valid_to = cast('{{ ds }}' as DATE) - interval '1 day'
 WHERE customer_key in (
     SELECT tgt_customer_key 
       FROM public.stg_customer
      WHERE chg_flag in ('U', 'D')
 );

-- Insert the updated records
INSERT INTO public.dim_customer (
       customer_key,
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
       valid_from,
       valid_to
)
SELECT src_customer_key as customer_key, 
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
       cast('{{ ds }}' as DATE) as valid_from,
       cast('9999-12-31' as DATE) as valid_to
  FROM public.stg_customer
 WHERE chg_flag in ('U', 'I')
;
