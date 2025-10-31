{{ config(
    materialized = "incremental",
    on_schema_change = "fail"
    )
}}

WITH src_reviews AS (
    SELECT * FROM {{ ref("src_reviews") }}
)
SELECT *
FROM
    src_reviews
WHERE
    REVIEW_TEXT IS NOT NULL

{% if is_incremental() %}
 AND REVIEW_DATE > (SELECT MAX(REVIEW_DATE) FROM {{ this }})
{% endif %}
