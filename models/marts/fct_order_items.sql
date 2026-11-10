{{
    config(
        materialized='incremental',
        unique_key='order_item_id',
        incremental_strategy='delete+insert',
        distributed_by='order_id',
        orientation='column'
    )
}}
with order_items as (
    select * from {{ ref('stg_shop__order_items') }}
),

orders as (
    select * from {{ ref('int_orders_with_payments') }}
    where not is_test_order
    {% if is_incremental() %}
      and ordered_at >= (
          select coalesce(max(ordered_at), timestamp '1900-01-01')
                 - interval '{{ var("fct_order_items_lookback_days", 3) }} days'
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
