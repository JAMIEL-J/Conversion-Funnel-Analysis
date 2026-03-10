-- ======================================================
-- 01_data_validation.sql
-- Purpose: Validate GA sample data before funnel analysis
-- ======================================================

-- 1. Date coverage of GA sample dataset
SELECT
  MIN(PARSE_DATE('%Y%m%d', date)) AS min_date,
  MAX(PARSE_DATE('%Y%m%d', date)) AS max_date,
  COUNT(DISTINCT date) AS total_days
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`;

-- 2. Funnel event availability (eCommerce action types)
SELECT
  hits.eCommerceAction.action_type AS action_type,
  COUNT(*) AS event_count
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
UNNEST(hits) AS hits
WHERE hits.eCommerceAction.action_type IS NOT NULL
GROUP BY action_type
ORDER BY event_count DESC;

-- 3. Revenue sanity check (purchase events only)
SELECT
  COUNT(DISTINCT hits.transaction.transactionId) AS total_orders,
  SUM(hits.transaction.transactionRevenue) / 1e6 AS total_revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
UNNEST(hits) AS hits
WHERE hits.eCommerceAction.action_type = '6';

-- 4. Device category distribution
SELECT
  device.deviceCategory AS device_type,
  COUNT(DISTINCT CONCAT(fullVisitorId, CAST(visitId AS STRING))) AS sessions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
GROUP BY device_type
ORDER BY sessions DESC;

-- 5. Sessions with purchase but no product view
WITH events AS (
  SELECT
    CONCAT(fullVisitorId, CAST(visitId AS STRING)) AS session_id,
    hits.eCommerceAction.action_type AS action_type
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
  UNNEST(hits) AS hits
  WHERE hits.eCommerceAction.action_type IN ('2','3','5','6')
)
SELECT
  COUNT(*) AS purchase_without_view
FROM (
  SELECT session_id
  FROM events
  GROUP BY session_id
  HAVING
    MAX(CASE WHEN action_type = '6' THEN 1 ELSE 0 END) = 1
    AND MAX(CASE WHEN action_type = '2' THEN 1 ELSE 0 END) = 0
);
