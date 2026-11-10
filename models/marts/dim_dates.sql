{{ config(distributed_replicated=true) }}
with bounds as (
    select
        min(order_date)             as min_date,
        max(order_date)             as max_date
    from {{ ref('stg_shop__orders') }}
),

days as (
    select d::date                  as date_day
    from bounds
    cross join lateral generate_series(
        bounds.min_date::timestamp,
        bounds.max_date::timestamp,
        interval '1 day'
    ) as d
)

select
    date_day,
    extract(year from date_day)::int            as year,
    extract(quarter from date_day)::int         as quarter,
    extract(month from date_day)::int           as month,
    to_char(date_day, 'FMMonth')                as month_name,
    to_char(date_day, 'YYYY-MM')                as year_month,
    extract(week from date_day)::int            as iso_week,
    extract(day from date_day)::int             as day_of_month,
    extract(isodow from date_day)::int          as day_of_week,
    to_char(date_day, 'FMDay')                  as day_of_week_name,
    extract(isodow from date_day) in (6, 7)     as is_weekend
from days
