-- ======================================================
-- Device-level revenue leakage (View → Cart)
-- ======================================================

WITH baseline AS (
  SELECT
    SAFE_DIVIDE(SUM(revenue), COUNT(*)) AS avg_revenue
  FROM `da-funnel-analysis.analytics.session_funnel`
  WHERE purchased = 1
),

device_funnel AS (
  SELECT
    device_type,
    SUM(viewed_product) AS viewed,
    SUM(added_to_cart) AS added
  FROM `da-funnel-analysis.analytics.session_funnel`
  GROUP BY device_type
)

SELECT
  device_type,
  viewed,
  added,
  viewed - added AS drop_view_to_cart,
  (viewed - added) * b.avg_revenue AS revenue_leakage
FROM device_funnel
CROSS JOIN baseline b
ORDER BY revenue_leakage DESC;

-- ======================================================
-- Traffic source revenue leakage (View → Cart)
-- ======================================================

WITH baseline AS (
  SELECT
    SAFE_DIVIDE(SUM(revenue), COUNT(*)) AS avg_revenue
  FROM `da-funnel-analysis.analytics.session_funnel`
  WHERE purchased = 1
),

source_funnel AS (
  SELECT
    traffic_source,
    SUM(viewed_product) AS viewed,
    SUM(added_to_cart) AS added
  FROM `da-funnel-analysis.analytics.session_funnel`
  GROUP BY traffic_source
)

SELECT
  traffic_source,
  viewed,
  added,
  viewed - added AS drop_view_to_cart,
  (viewed - added) * b.avg_revenue AS revenue_leakage
FROM source_funnel
CROSS JOIN baseline b
ORDER BY revenue_leakage DESC
LIMIT 10;


-- ======================================================
-- Country-level leakage (Top 5 only)
-- ======================================================

WITH baseline AS (
  SELECT
    SAFE_DIVIDE(SUM(revenue), COUNT(*)) AS avg_revenue
  FROM `da-funnel-analysis.analytics.session_funnel`
  WHERE purchased = 1
),

country_funnel AS (
  SELECT
    country,
    SUM(viewed_product) AS viewed,
    SUM(added_to_cart) AS added
  FROM `da-funnel-analysis.analytics.session_funnel`
  GROUP BY country
)

SELECT
  country,
  viewed - added AS drop_view_to_cart,
  (viewed - added) * b.avg_revenue AS revenue_leakage
FROM country_funnel
CROSS JOIN baseline b
ORDER BY revenue_leakage DESC
LIMIT 5;
