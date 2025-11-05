SELECT
    s.listing_id,
    s.created_at,
    f.id,
    f.review_date
FROM {{ ref("fct_reviews") }} AS f
INNER JOIN {{ ref("dim_listings_cleansed") }} AS s ON f.id = s.listing_id
WHERE s.created_at > f.review_date
