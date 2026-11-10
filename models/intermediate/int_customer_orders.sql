with orders as (
    select * from {{ ref('int_orders_with_payments') }}
    where not is_test_order
),

customer_orders as (
    select
        customer_id,
        count(*)                                            as orders_count,
        min(ordered_at)                                     as first_ordered_at,
        count(*) filter (where is_confirmed)                as confirmed_orders_count,
        coalesce(sum(order_amount) filter (where is_confirmed), 0)
                                                            as confirmed_revenue
    from orders
    group by customer_id
),

confirmed_ranked as (
    select
        customer_id,
        order_id,
        ordered_at,
        row_number() over (
            partition by customer_id
            order by ordered_at, order_id
        )                                                   as confirmed_order_number
    from orders
    where is_confirmed
)

select
    c.customer_id,
    c.orders_count,
    c.first_ordered_at,
    c.confirmed_orders_count,
    c.confirmed_revenue,
    f.order_id                                              as first_confirmed_order_id,
    f.ordered_at                                            as first_confirmed_at
from customer_orders as c
left join confirmed_ranked as f
    on f.customer_id = c.customer_id
   and f.confirmed_order_number = 1
