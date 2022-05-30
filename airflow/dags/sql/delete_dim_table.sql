-- delete_dim_table.sql
--
-- Update the specified dimension table to reset the change made by the task
-- with the current logical date to make the task repeatable.

BEGIN;

-- Delete the records that were inserted by the task with the same logical date or later
-- i.e. valid_from >= "{{ ds }}"

DELETE FROM {{ params.table_name }}
 WHERE valid_from >= cast('{{ ds }}' as DATE)
;

-- Reopen the records that were closed by the task with the same logical date 
-- i.e. valid_to = "{{ ds }}" - 1 day

UPDATE {{ params.table_name }} 
   SET valid_to = '9999-12-31'
 WHERE valid_to = cast('{{ ds }}' as DATE) - interval '1 day'
;   

END;