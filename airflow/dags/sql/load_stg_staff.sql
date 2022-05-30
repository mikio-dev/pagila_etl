-- load_stg_staff.sql
--
-- Load the staging table with the following data:
--   - New key value calculated by the md5 function
--   - The chg_flag indicating the changes required to the dim table

BEGIN;

TRUNCATE TABLE public.stg_staff
;

INSERT INTO public.stg_staff(
       src_staff_key,
       tgt_staff_key,
       staff_id,
       first_name,
       last_name,
       store_id,
       active,
       last_update,
       chg_flag
)
WITH tgt as (
     SELECT staff_key, 
            staff_id
       FROM public.dim_staff
      WHERE valid_to = '9999-12-31'
),
src as (
     SELECT md5(
                coalesce(cast(first_name as text), '') ||
                coalesce(cast(last_name as text), '') ||
                coalesce(cast(address_id as text), '') ||
                coalesce(cast(email as text), '') ||
                coalesce(cast(store_id as text), '') ||
                coalesce(cast(active as integer), 0) ||
                coalesce(cast(username as text), '') ||
                coalesce(cast(password as text), '')
		     ) as staff_key,
            staff_id,
            first_name,
            last_name,
            address_id,
            email,
            store_id,
            active,
            username,
            password,
            last_update
       FROM public.src_staff
)
SELECT src.staff_key as src_staff_key,
       tgt.staff_key as tgt_staff_key,
       coalesce(src.staff_id, tgt.staff_id) as staff_id,
       src.first_name,
       src.last_name,
       src.store_id,
       src.active,
       src.last_update,
       CASE 
            WHEN tgt.staff_key is NULL THEN 'I'
            WHEN src.staff_key is NULL THEN 'D'
            WHEN tgt.staff_key <> src.staff_key THEN 'U'
            ELSE NULL
       END as chg_flag
  FROM src
  FULL OUTER JOIN tgt
    ON tgt.staff_id = src.staff_id
;

END;