-- load_dim_actor.sql
--
-- Load the dim table from the stg table
--   - For chg_flag = 'U' and 'D', close the existing records with valid_to set to the logical date - 1 day
--   - For chg_flag = 'I' and 'U', insert the records with valid_from set to the logical date and valid_to set to '9999-12-31'


-- Close the updated and deleted records
UPDATE public.dim_actor
   SET valid_to = cast('{{ ds }}' as DATE) - interval '1 day'
 WHERE actor_key in (
     SELECT tgt_actor_key 
       FROM public.stg_actor
      WHERE chg_flag in ('U', 'D')
 );

-- Insert the updated records
INSERT INTO public.dim_actor (
       actor_key,
       actor_id,
       first_name,
       last_name,
       last_update,
       valid_from,
       valid_to
)
SELECT src_actor_key as actor_key, 
       actor_id, 
       first_name, 
       last_name, 
       last_update, 
       cast('{{ ds }}' as DATE) as valid_from,
       cast('9999-12-31' as DATE) as valid_to
  FROM public.stg_actor
 WHERE chg_flag in ('U', 'I')
;
