-- Staging категорий: одна строка — одна категория.
-- Дерево задано ссылкой parent_category_id; у корневой категории она пустая.
with source as (
    select * from {{ source('shop', 'product_categories') }}
)

select
    category_id,
    parent_category_id,
    category_name,
    parent_category_id is null      as is_root_category
from source
