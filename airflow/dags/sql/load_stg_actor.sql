-- load_stg_actor.sql
--
-- Load the staging table with the following data:
--   - New key value calculated by the md5 function
--   - The chg_flag indicating the changes required to the dim table

BEGIN;

TRUNCATE TABLE public.stg_actor
;

INSERT INTO public.stg_actor(
       src_actor_key, 
       tgt_actor_key, 
       actor_id, 
       first_name, 
       last_name, 
       last_update, 
       chg_flag   
)
WITH tgt as (
     SELECT actor_key, 
            actor_id
       FROM public.dim_actor
      WHERE valid_to = '9999-12-31'
),
src as (
     SELECT md5(
                coalesce(cast(first_name as text), '') ||
                coalesce(cast(last_name as text), '')
		     ) as actor_key,
            actor_id,
            first_name,
            last_name,
            last_update
       FROM public.src_actor
)
SELECT src.actor_key as src_actor_key,
       tgt.actor_key as tgt_actor_key,
       coalesce(src.actor_id, tgt.actor_id) as actor_id,
       src.first_name,
       src.last_name,
       src.last_update,
       CASE 
            WHEN tgt.actor_key is NULL THEN 'I'
            WHEN src.actor_key is NULL THEN 'D'
            WHEN tgt.actor_key <> src.actor_key THEN 'U'
            ELSE NULL
       END as chg_flag
  FROM src
  FULL OUTER JOIN tgt
    ON tgt.actor_id = src.actor_id
;

END;