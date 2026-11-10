with items as (
    select
        order_id,
        sum(line_amount)            as items_amount
    from {{ ref('fct_order_items') }}
    group by order_id
)

select
    coalesce(o.order_id, i.order_id) as order_id,
    o.order_amount,
    i.items_amount
from {{ ref('fct_orders') }} as o
full outer join items as i
    on i.order_id = o.order_id
where o.order_id is null
   or i.order_id is null
   or o.order_amount <> i.items_amount
