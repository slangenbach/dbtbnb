{% test min_row_count(model, row_count) %}
{{ config(severity = "warn")}}
SELECT COUNT(*) FROM {{ model }} HAVING COUNT(*) < {{ row_count }}
{% endtest %}
