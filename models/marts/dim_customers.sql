{{ config(distributed_replicated=true) }}
with customers as (
    select * from {{ ref('stg_shop__customers') }}
),

customer_orders as (
    select * from {{ ref('int_customer_orders') }}
)

select
    c.customer_id,
    c.registered_at,
    c.registration_date,
    c.city,
    c.acquisition_channel,
    coalesce(o.orders_count, 0)             as orders_count,
    o.first_ordered_at,
    o.first_confirmed_order_id,
    o.first_confirmed_at,
    coalesce(o.confirmed_orders_count, 0)   as confirmed_orders_count,
    coalesce(o.confirmed_revenue, 0)        as confirmed_revenue,
    coalesce(o.confirmed_orders_count, 0) > 0
                                            as is_buyer
from customers as c
left join customer_orders as o
    on o.customer_id = c.customer_id
