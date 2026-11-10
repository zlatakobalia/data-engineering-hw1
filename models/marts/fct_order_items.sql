{{
    config(
        materialized='incremental',
        unique_key='order_item_id',
        incremental_strategy='delete+insert',
        distributed_by='order_id',
        orientation='column'
    )
}}
-- Факт позиций заказа: одна строка — один товар в заказе. Позиции тестовых заказов исключены.
--
-- Инкрементальная модель. Первый запуск (и --full-refresh) строит таблицу целиком.
-- Следующие запуски берут только заказы за последние N дней от самого позднего заказа в витрине
-- (var fct_order_items_lookback_days, по умолчанию 3) и перезаписывают их позиции:
-- delete+insert по ключу order_item_id. Какие изменения источника такой запуск пропустит — см. README.
--
-- Хранение: distributed by (order_id), как у fct_orders и сырых таблиц, + колоночная AO-таблица:
-- это самый большой факт, а отчёты читают из него несколько столбцов (product_id, order_date, line_amount).
with order_items as (
    select * from {{ ref('stg_shop__order_items') }}
),

orders as (
    select * from {{ ref('int_orders_with_payments') }}
    where not is_test_order
    {% if is_incremental() %}
      and ordered_at >= (
          select max(ordered_at) - interval '{{ var("fct_order_items_lookback_days", 3) }} days'
          from {{ this }}
      )
    {% endif %}
)

select
    i.order_item_id,
    i.order_id,
    i.product_id,
    o.customer_id,
    o.order_date,
    o.ordered_at,
    o.order_status,
    i.quantity,
    i.unit_price,
    i.discount_amount,
    i.gross_amount,
    i.line_amount,
    o.is_confirmed
from order_items as i
join orders as o
    on o.order_id = i.order_id
