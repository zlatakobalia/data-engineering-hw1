with source_paid_orders as (
    select distinct order_id
    from {{ source('shop', 'payments') }}
    where payment_status = 'success'
      and amount > 0
),

source_totals as (
    select
        count(*)                        as confirmed_orders,
        coalesce(sum(o.total_amount), 0) as confirmed_amount
    from {{ source('shop', 'orders') }} as o
    join source_paid_orders as p
        on p.order_id = o.order_id
    where o.status = 'paid'
),

mart_orders as (
    select
        count(*)                        as confirmed_orders,
        coalesce(sum(order_amount), 0)  as confirmed_amount
    from {{ ref('fct_orders') }}
    where is_confirmed
),

mart_items as (
    select
        count(distinct order_id)        as confirmed_orders,
        coalesce(sum(line_amount), 0)   as confirmed_amount
    from {{ ref('fct_order_items') }}
    where is_confirmed
),

mart_customers as (
    select
        sum(confirmed_orders_count)     as confirmed_orders,
        sum(confirmed_revenue)          as confirmed_amount
    from {{ ref('dim_customers') }}
),

compared as (
    select 'fct_orders' as mart, m.confirmed_orders, m.confirmed_amount from mart_orders as m
    union all
    select 'fct_order_items', m.confirmed_orders, m.confirmed_amount from mart_items as m
    union all
    select 'dim_customers', m.confirmed_orders, m.confirmed_amount from mart_customers as m
)

select
    c.mart,
    c.confirmed_orders              as mart_orders,
    s.confirmed_orders              as source_orders,
    c.confirmed_amount              as mart_amount,
    s.confirmed_amount              as source_amount
from compared as c
cross join source_totals as s
where c.confirmed_orders <> s.confirmed_orders
   or c.confirmed_amount <> s.confirmed_amount
