{{ config(distributed_by='order_id') }}
-- Факт заказов: одна строка — один заказ. Тестовые заказы в витрину не попадают.
-- Хранение: distributed by (order_id), как raw.orders, raw.order_items, raw.payments и fct_order_items —
-- соединение fct_orders с fct_order_items по order_id идёт на каждом сегменте локально.
select
    order_id,
    customer_id,
    order_date,
    ordered_at,
    order_status,
    order_amount,
    items_count,
    paid_amount,
    refunded_amount,
    net_paid_amount,
    successful_payments_count,
    first_paid_at,
    is_confirmed
from {{ ref('int_orders_with_payments') }}
where not is_test_order
