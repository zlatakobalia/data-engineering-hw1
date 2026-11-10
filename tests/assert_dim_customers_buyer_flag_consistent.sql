select
    customer_id,
    is_buyer,
    confirmed_orders_count,
    confirmed_revenue,
    first_confirmed_order_id
from {{ ref('dim_customers') }}
where is_buyer <> (confirmed_orders_count > 0)
   or is_buyer <> (first_confirmed_order_id is not null)
   or (is_buyer and confirmed_revenue <= 0)
   or (not is_buyer and confirmed_revenue <> 0)
