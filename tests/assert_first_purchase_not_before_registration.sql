-- Дополнительная проверка. Клиент не может купить раньше, чем зарегистрировался:
-- первая подтверждённая покупка не раньше регистрации.
select
    customer_id,
    registered_at,
    first_confirmed_order_id,
    first_confirmed_at
from {{ ref('dim_customers') }}
where first_confirmed_at < registered_at
