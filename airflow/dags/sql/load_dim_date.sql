-- dim_date table
--
-- Load a static date dimension table
-- The start_date and end_date are specified in the dag.

BEGIN;

TRUNCATE public.dim_date
;

INSERT INTO public.dim_date (
       date_key,
       date_value,
       date_full,
       year_number,
       quarter,
       quarter_name,
       year_quarter,
       year_month,
       month_number,
       month_name,
       day_number,
       day_in_year,
       week_in_year,
       day_of_week
)
WITH recursive tmp (d) AS (
    SELECT '{{ params.start_date }}'::timestamp as d
     UNION ALL
    SELECT d + interval '1 day' 
      FROM tmp 
     WHERE d < '{{ params.end_date }}'::timestamp
)
SELECT md5(to_char(d, 'YYYYMMDD')) as date_key,
       trunc(d) as date_value,
       to_char(d, 'Day DD Month YYYY') as date_full,
       extract(year from d) as year_number,
       extract(quarter from d) as quarter,
       'Q' || extract(quarter from d) as quarter_name,
       to_char(d, 'YYYY') || '-Q' || to_char(d, 'Q') year_quarter,
       to_char(d, 'YYYY') || '-' || to_char(d, 'MM') as year_month,
       extract(month from d) as month_number,
       to_char(d, 'Month') as month_name,
       extract(day from d) as day_number,
       extract(dayofyear from d) as day_in_year,
       to_char(d, 'WW')::smallint as week_in_year,
       extract(dayofweek from d) as day_of_week
  FROM tmp
;

END;