select p.payment_id, p.order_id, p.amount, o.order_status
from {{ ref('stg_shop__payments') }} as p
join {{ ref('stg_shop__orders') }} as o
    on o.order_id = p.order_id
where p.is_refund
  and o.order_status <> 'returned'
