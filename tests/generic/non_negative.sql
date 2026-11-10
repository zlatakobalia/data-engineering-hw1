{#
    Свой generic-тест: значение колонки не меньше нуля.
    Возвращает «плохие» строки — те, где значение отрицательное. Пустые значения не проверяет:
    для этого есть not_null.

    Использование в YAML:
        columns:
          - name: line_amount
            data_tests:
              - non_negative
#}
{% test non_negative(model, column_name) %}

select {{ column_name }} as negative_value
from {{ model }}
where {{ column_name }} < 0

{% endtest %}
