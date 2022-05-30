-- load_dim_film_actor.sql
--
-- Load the dim table from the stg table
--   - For chg_flag = 'U' and 'D', close the existing records with valid_to set to the logical date - 1 day
--   - For chg_flag = 'I' and 'U', insert the records with valid_from set to the logical date and valid_to set to '9999-12-31'


-- Close the updated and deleted records
UPDATE public.dim_film_actor
   SET valid_to = cast('{{ ds }}' as DATE) - interval '1 day'
 WHERE (film_key, actor_key) in (
     SELECT tgt_film_key,
            tgt_actor_key 
       FROM public.stg_film_actor
      WHERE chg_flag in ('U', 'D')
 );

-- Insert the updated records
INSERT INTO public.dim_film_actor (
       film_key,
       actor_key,
       film_id,
       actor_id,
       valid_from,
       valid_to
)
SELECT src_film_key as film_key,
       src_actor_key as actor_key, 
       film_id, 
       actor_id,
       cast('{{ ds }}' as DATE) as valid_from,
       cast('9999-12-31' as DATE) as valid_to
  FROM public.stg_film_actor
 WHERE chg_flag in ('U', 'I')
;
