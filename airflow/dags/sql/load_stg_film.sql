-- load_stg_film.sql
--
-- Load the staging table with the following data:
--   - New key value calculated by the md5 function
--   - The chg_flag indicating the changes required to the dim table
-- The many to many relationship between src_film and src_category is encoded in the 
-- boolean columns category_*.

BEGIN;

TRUNCATE TABLE public.stg_film
;

INSERT INTO public.stg_film(
       src_film_key, 
       tgt_film_key, 
       film_id,
       title,
       description,
       release_year,
       language,
       original_language,
       rental_duration,
       rental_rate,
       film_length,
       replacement_cost,
       rating,
       special_features,
       category_action,
       category_animation,
       category_children,
       category_classics,
       category_comedy,
       category_documentary,
       category_drama,
       category_family,
       category_foreign,
       category_games,
       category_horror,
       category_music,
       category_new,
       category_scifi,
       category_sports,
       category_travel,
       last_update,
       chg_flag
)
WITH tgt as (
     SELECT film_key,
            film_id
       FROM public.dim_film
	 WHERE valid_to = '9999-12-31'
),
src as (
     SELECT md5(
                coalesce(cast(title as text), '') ||
                coalesce(cast(description as text), '') ||
                coalesce(cast(release_year as text), '') ||
                coalesce(cast(language as text), '') ||
                coalesce(cast(original_language as text), '') ||
                coalesce(cast(rental_duration as text), '') ||
                coalesce(cast(rental_rate as text), '') ||
                coalesce(cast(film_length as text), '') ||
                coalesce(cast(replacement_cost as text), '') ||
                coalesce(cast(rating as text), '') ||
                coalesce(cast(special_features as text), '') ||
                coalesce(cast(category_action as integer), 0) ||
                coalesce(cast(category_animation as integer), 0) ||
                coalesce(cast(category_children as integer), 0) ||
                coalesce(cast(category_classics as integer), 0) ||
                coalesce(cast(category_comedy as integer), 0) ||
                coalesce(cast(category_documentary as integer), 0) ||
                coalesce(cast(category_drama as integer), 0) ||
                coalesce(cast(category_family as integer), 0) ||
                coalesce(cast(category_foreign as integer), 0) ||
                coalesce(cast(category_games as integer), 0) ||
                coalesce(cast(category_horror as integer), 0) ||
                coalesce(cast(category_music as integer), 0) ||
                coalesce(cast(category_new as integer), 0) ||
                coalesce(cast(category_scifi as integer), 0) ||
                coalesce(cast(category_sports as integer), 0) ||
                coalesce(cast(category_travel as integer), 0)
		     ) as film_key,
            film_id,
            title,
            description,
            release_year,
            language,
            original_language,
            rental_duration,
            rental_rate,
            film_length,
            replacement_cost,
            rating,
            special_features,
            category_action,
            category_animation,
            category_children,
            category_classics,
            category_comedy,
            category_documentary,
            category_drama,
            category_family,
            category_foreign,
            category_games,
            category_horror,
            category_music,
            category_new,
            category_scifi,
            category_sports,
            category_travel,
            last_update
       FROM (
            SELECT DISTINCT
                   f.film_id,
                   f.title,
                   f.description,
                   f.release_year,
                   l.name as language,
                   ol.name as original_language,
                   f.rental_duration,
                   f.rental_rate,
                   f.length as film_length,
                   f.replacement_cost,
                   f.rating,
                   f.special_features,
                   sum(case when c.category_id = 1 then 1 else 0 end)::boolean as category_action,
                   sum(case when c.category_id = 2 then 1 else 0 end)::boolean as category_animation,
                   sum(case when c.category_id = 3 then 1 else 0 end)::boolean as category_children,
                   sum(case when c.category_id = 4 then 1 else 0 end)::boolean as category_classics,
                   sum(case when c.category_id = 5 then 1 else 0 end)::boolean as category_comedy,
                   sum(case when c.category_id = 6 then 1 else 0 end)::boolean as category_documentary,
                   sum(case when c.category_id = 7 then 1 else 0 end)::boolean as category_drama,
                   sum(case when c.category_id = 8 then 1 else 0 end)::boolean as category_family,
                   sum(case when c.category_id = 9 then 1 else 0 end)::boolean as category_foreign,
                   sum(case when c.category_id = 10 then 1 else 0 end)::boolean as category_games,
                   sum(case when c.category_id = 11 then 1 else 0 end)::boolean as category_horror,
                   sum(case when c.category_id = 12 then 1 else 0 end)::boolean as category_music,
                   sum(case when c.category_id = 13 then 1 else 0 end)::boolean as category_new,
                   sum(case when c.category_id = 14 then 1 else 0 end)::boolean as category_scifi,
                   sum(case when c.category_id = 15 then 1 else 0 end)::boolean as category_sports,
                   sum(case when c.category_id = 16 then 1 else 0 end)::boolean as category_travel,
                   f.last_update
              FROM src_film f 
              LEFT OUTER JOIN src_language l 
                ON f.language_id = l.language_id 
              LEFT OUTER JOIN src_language ol 
                ON f.original_language_id = ol.language_id
              LEFT OUTER JOIN src_film_category fc 
                ON f.film_id = fc.film_id 
              LEFT OUTER JOIN src_category c
                ON fc.category_id = c.category_id 
             GROUP BY f.film_id,
                   f.title,
                   f.description,
                   f.release_year,
                   l.name,
                   ol.name,
                   f.rental_duration,
                   f.rental_rate,
                   f.length,
                   f.replacement_cost,
                   f.rating,
                   f.special_features,
                   f.last_update
       )
)
SELECT src.film_key as src_film_key,
       tgt.film_key as tgt_film_key,
       coalesce(src.film_id, tgt.film_id) as film_id,
       src.title,
       src.description,
       src.release_year,
       src.language,
       src.original_language,
       src.rental_duration,
       src.rental_rate,
       src.film_length,
       src.replacement_cost,
       src.rating,
       src.special_features,
       src.category_action,
       src.category_animation,
       src.category_children,
       src.category_classics,
       src.category_comedy,
       src.category_documentary,
       src.category_drama,
       src.category_family,
       src.category_foreign,
       src.category_games,
       src.category_horror,
       src.category_music,
       src.category_new,
       src.category_scifi,
       src.category_sports,
       src.category_travel,
       src.last_update,
       CASE 
            WHEN tgt.film_key is NULL THEN 'I'
            WHEN src.film_key is NULL THEN 'D'
            WHEN tgt.film_key <> src.film_key THEN 'U'
            ELSE NULL
       END as chg_flag
  FROM src
  FULL OUTER JOIN tgt
    ON tgt.film_id = src.film_id
;

END;