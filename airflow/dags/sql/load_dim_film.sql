-- load_dim_film.sql
--
-- Load the dim table from the stg table
--   - For chg_flag = 'U' and 'D', close the existing records with valid_to set to the logical date - 1 day
--   - For chg_flag = 'I' and 'U', insert the records with valid_from set to the logical date and valid_to set to '9999-12-31'


-- Close the updated and deleted records
UPDATE public.dim_film
   SET valid_to = cast('{{ ds }}' as DATE) - interval '1 day'
 WHERE film_key in (
     SELECT tgt_film_key 
       FROM public.stg_film
      WHERE chg_flag in ('U', 'D')
 );

-- Insert the updated records
INSERT INTO public.dim_film (
       film_key,
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
       valid_from,
       valid_to
)
SELECT src_film_key as film_key, 
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
       cast('{{ ds }}' as DATE) as valid_from,
       cast('9999-12-31' as DATE) as valid_to
  FROM public.stg_film
 WHERE chg_flag in ('U', 'I')
;
