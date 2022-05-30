-- load_stg_film_actor.sql
--
-- Load the staging table with the following data:
--   - New key value calculated by the md5 function
--   - The chg_flag indicating the changes required to the dim table

BEGIN;

TRUNCATE TABLE public.stg_film_actor
;

INSERT INTO public.stg_film_actor(
       src_film_key,
       tgt_film_key,
       src_actor_key,
       tgt_actor_key,
       film_id,
       actor_id,
       chg_flag   
)
WITH tgt as (
     SELECT film_key, 
            actor_key,
            film_id,
            actor_id
       FROM public.dim_film_actor
      WHERE valid_to = '9999-12-31'
),
src as (
     SELECT f.src_film_key as film_key,
            a.src_actor_key as actor_key,
            s.film_id,
            s.actor_id
       FROM public.src_film_actor s
       LEFT OUTER JOIN public.stg_film f
         ON s.film_id = f.film_id
       LEFT OUTER JOIN public.stg_actor a 
         ON s.actor_id = a.actor_id 
)
SELECT src.film_key as src_film_key,
       tgt.film_key as tgt_film_key,
       src.actor_key as src_actor_key,
       tgt.actor_key as tgt_actor_key,
       src.film_id,
       src.actor_id,
       CASE 
            WHEN tgt.film_key is NULL THEN 'I'
            WHEN src.film_key is NULL THEN 'D'
            WHEN tgt.film_key <> src.film_key THEN 'U'
            ELSE NULL
       END as chg_flag
  FROM src
  FULL OUTER JOIN tgt
    ON tgt.film_id = src.film_id
   AND tgt.actor_id = src.actor_id
;

END;