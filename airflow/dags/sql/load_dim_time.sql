-- dim_time table
--
-- Load a static time dimension table (hour and minute)

BEGIN;

TRUNCATE public.dim_time
;

INSERT INTO public.dim_time (
       time_key,
       time_value,
       hours24,
       hours12,
       minutes,
       am_pm
)
WITH recursive tmp (t) AS (
    SELECT '0001-01-01 00:00:00'::timestamp
     UNION ALL
    SELECT t + interval '1 minute' 
      FROM tmp 
     WHERE t < '0001-01-01 23:59:59'::timestamp
)
SELECT md5(to_char(t::timestamp, 'HH24MI')) as time_key,
       to_char(t, 'HH24MISS')::time as time_value,
       to_char(t, 'HH24')::smallint as hours24,
       to_char(t, 'HH12')::smallint as hours12,
       to_char(t, 'MI')::smallint as minutes,
       to_char(t, 'AM') as am_pm
  FROM tmp
;

END;