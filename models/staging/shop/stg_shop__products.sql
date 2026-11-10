-- Staging товаров: одна строка — один товар.
-- Категория в источнике записана текстом (названием из product_categories).
-- Связь с деревом категорий строится в intermediate-слое, здесь только переименование.
with source as (
    select * from {{ source('shop', 'products') }}
)

select
    product_id,
    product_name,
    brand,
    category                        as category_name
from source
