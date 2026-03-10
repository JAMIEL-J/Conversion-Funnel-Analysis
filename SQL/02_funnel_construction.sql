-- ======================================================
-- 02_funnel_construction.sql
-- Purpose:
-- 1. Build session-level funnel table from GA hit data
-- 2. Compute overall funnel conversion metrics
-- ======================================================


-- ======================================================
-- QUERY 1: Build session-level funnel table
-- ======================================================

WITH base_events AS (
  SELECT
    CONCAT(fullVisitorId, CAST(visitId AS STRING)) AS session_id,
    fullVisitorId AS user_id,
    device.deviceCategory AS device_type,
    trafficSource.source AS traffic_source,
    geoNetwork.country AS country,
    hits.eCommerceAction.action_type AS action_type,
    hits.transaction.transactionRevenue / 1e6 AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
  UNNEST(hits) AS hits
  WHERE hits.eCommerceAction.action_type IN ('2','3','5','6')
),

session_funnel AS (
  SELECT
    session_id,
    user_id,
    device_type,
    traffic_source,
    country,

    MAX(CASE WHEN action_type = '2' THEN 1 ELSE 0 END) AS viewed_product,
    MAX(CASE WHEN action_type = '3' THEN 1 ELSE 0 END) AS added_to_cart,
    MAX(CASE WHEN action_type = '5' THEN 1 ELSE 0 END) AS checkout_started,
    MAX(CASE WHEN action_type = '6' THEN 1 ELSE 0 END) AS purchased,

    SUM(revenue) AS revenue
  FROM base_events
  GROUP BY
    session_id,
    user_id,
    device_type,
    traffic_source,
    country
)

SELECT * FROM session_funnel;


-- ======================================================
-- QUERY 2: Funnel-level conversion & revenue metrics
-- (Run on-demand; do NOT materialize)
-- ======================================================

SELECT
  COUNT(*) AS total_sessions,

  SUM(viewed_product) AS product_view_sessions,
  SUM(added_to_cart) AS add_to_cart_sessions,
  SUM(checkout_started) AS checkout_sessions,
  SUM(purchased) AS purchase_sessions,

  SAFE_DIVIDE(SUM(added_to_cart), SUM(viewed_product)) AS view_to_cart_rate,
  SAFE_DIVIDE(SUM(checkout_started), SUM(added_to_cart)) AS cart_to_checkout_rate,
  SAFE_DIVIDE(SUM(purchased), SUM(checkout_started)) AS checkout_to_purchase_rate,
  SAFE_DIVIDE(SUM(purchased), SUM(viewed_product)) AS overall_conversion_rate,

  SUM(revenue) AS total_revenue,
  SAFE_DIVIDE(SUM(revenue), COUNT(*)) AS revenue_per_session
FROM `da-funnel-analysis.analytics.session_funnel`;
