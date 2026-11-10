-- Бизнес-правило 3. По возвращённому заказу деньги вернулись полностью:
-- оплачено минус возвращено равно нулю (net_paid_amount = 0).
select
    order_id,
    paid_amount,
    refunded_amount,
    net_paid_amount
from {{ ref('fct_orders') }}
where order_status = 'returned'
  and net_paid_amount <> 0
