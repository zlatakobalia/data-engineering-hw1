{{ config(severity='warn') }}
-- Бизнес-правило 4. С подтверждённого заказа не списали больше его суммы.
--
-- Тест находит реальную проблему в данных источника, поэтому severity: warn:
-- dbt build проходит, а проблема видна в выводе и в analytics_dbt_test__audit.
-- Найдено: заказ 113 на 200,00 оплачен двумя успешными платежами по 200,00
-- (1015 в 20:03 и 1016 в 20:04) — двойное списание, клиенту нужно вернуть 200,00.
-- Данные под тест не подгоняем: это задача для команды платежей, подробности — в README.
select
    order_id,
    customer_id,
    order_amount,
    paid_amount,
    successful_payments_count,
    paid_amount - order_amount      as overcharged_amount
from {{ ref('fct_orders') }}
where is_confirmed
  and paid_amount > order_amount
