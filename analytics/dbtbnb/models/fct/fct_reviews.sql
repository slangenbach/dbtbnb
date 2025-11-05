{{ config(
    materialized = "incremental",
    on_schema_change = "fail"
    )
}}

WITH src_reviews AS (
    SELECT * FROM {{ ref("src_reviews") }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(["listing_id", "review_date", "reviewer_name", "review_text"]) }} AS review_id,
    *
FROM
    src_reviews
WHERE
    src_reviews.review_text IS NOT NULL -- noqa: disable=RF03

{% if is_incremental() %}
    AND src_reviews.review_date > (SELECT MAX(review_date) FROM {{ this }}) -- noqa: disable=all
{% endif %}
