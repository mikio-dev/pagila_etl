-- load_dim_staff.sql
--
-- Load the dim table from the stg table
--   - For chg_flag = 'U' and 'D', close the existing records with valid_to set to the logical date - 1 day
--   - For chg_flag = 'I' and 'U', insert the records with valid_from set to the logical date and valid_to set to '9999-12-31'


-- Close the updated and deleted records
UPDATE public.dim_staff
   SET valid_to = cast('{{ ds }}' as DATE) - interval '1 day'
 WHERE staff_key in (
     SELECT tgt_staff_key 
       FROM public.stg_staff
      WHERE chg_flag in ('U', 'D')
 );

-- Insert the updated records
INSERT INTO public.dim_staff (
       staff_key,
       staff_id,
       first_name,
       last_name,
       store_id,
       active,
       last_update,
       valid_from,
       valid_to
)
SELECT src_staff_key as staff_key, 
       staff_id, 
       first_name,
       last_name,
       store_id,
       active,
       last_update,
       cast('{{ ds }}' as DATE) as valid_from,
       cast('9999-12-31' as DATE) as valid_to
  FROM public.stg_staff
 WHERE chg_flag in ('U', 'I')
;
