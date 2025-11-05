WITH
fct_reviews AS (
    SELECT * FROM {{ ref("fct_reviews") }}
),

full_moon_dates AS (
    SELECT * FROM {{ ref("seed_full_moon_dates") }}
)

SELECT
    r.*,
    NOT coalesce(fm.full_moon_date IS NULL, FALSE) AS is_full_moon
FROM
    fct_reviews AS r
LEFT JOIN
    full_moon_dates AS fm
    ON to_date(r.review_date) = dateadd(DAY, 1, fm.full_moon_date)
