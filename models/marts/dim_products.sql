{{ config(distributed_replicated=true) }}
-- Измерение товаров: одна строка — один товар, с брендом и полной иерархией категорий.
-- Товар ссылается на категорию по названию; иерархию даёт int_product_categories_tree.
-- Хранение: distributed replicated — маленький справочник (13 строк).
with products as (
    select * from {{ ref('stg_shop__products') }}
),

categories as (
    select * from {{ ref('int_product_categories_tree') }}
)

select
    p.product_id,
    p.product_name,
    p.brand,
    c.category_id,
    p.category_name,
    c.parent_category_name,
    c.root_category_name,
    c.category_level,
    c.category_path
from products as p
left join categories as c
    on c.category_name = p.category_name
