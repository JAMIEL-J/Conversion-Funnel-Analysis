-- ======================================================
-- 03_revenue_leakage.sql
-- Purpose:
-- Quantify revenue leakage across funnel stages
-- ======================================================


-- ======================================================
-- QUERY 1: Baseline revenue per purchase session
-- ======================================================

SELECT
  COUNT(*) AS purchase_sessions,
  SUM(revenue) AS total_revenue,
  SAFE_DIVIDE(SUM(revenue), COUNT(*)) AS avg_revenue_per_purchase
FROM `da-funnel-analysis.analytics.session_funnel`
WHERE purchased = 1;


-- ======================================================
-- QUERY 2: Funnel drop-off volumes
-- ======================================================

WITH funnel_counts AS (
  SELECT
    SUM(viewed_product) AS viewed,
    SUM(added_to_cart) AS added,
    SUM(checkout_started) AS checkout,
    SUM(purchased) AS purchased
  FROM `da-funnel-analysis.analytics.session_funnel`
)

SELECT
  viewed - added AS drop_view_to_cart,
  added - checkout AS drop_cart_to_checkout,
  checkout - purchased AS drop_checkout_to_purchase
FROM funnel_counts;


-- ======================================================
-- QUERY 3: Revenue leakage estimation by funnel stage
-- ======================================================

WITH baseline AS (
  SELECT
    SAFE_DIVIDE(SUM(revenue), COUNT(*)) AS avg_revenue_per_purchase
  FROM `da-funnel-analysis.analytics.session_funnel`
  WHERE purchased = 1
),

funnel_counts AS (
  SELECT
    SUM(viewed_product) AS viewed,
    SUM(added_to_cart) AS added,
    SUM(checkout_started) AS checkout,
    SUM(purchased) AS purchased
  FROM `da-funnel-analysis.analytics.session_funnel`
),

drops AS (
  SELECT
    viewed - added AS drop_view_to_cart,
    added - checkout AS drop_cart_to_checkout,
    checkout - purchased AS drop_checkout_to_purchase
  FROM funnel_counts
)

SELECT
  drop_view_to_cart,
  drop_cart_to_checkout,
  drop_checkout_to_purchase,

  drop_view_to_cart * avg_revenue_per_purchase AS revenue_leak_view_to_cart,
  drop_cart_to_checkout * avg_revenue_per_purchase AS revenue_leak_cart_to_checkout,
  drop_checkout_to_purchase * avg_revenue_per_purchase AS revenue_leak_checkout_to_purchase
FROM drops
CROSS JOIN baseline;
