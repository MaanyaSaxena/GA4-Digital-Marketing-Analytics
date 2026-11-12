-- 03 | Ordered session conversion funnel
-- Source: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
-- Period: 1–31 January 2021
-- Landing is represented by the first page_view in a session (proxy).
-- BigQuery Standard SQL

WITH event_data AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value
     FROM UNNEST(event_params)
     WHERE key = 'ga_session_id') AS ga_session_id,
    event_name,
    event_timestamp
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
    AND event_name IN ('page_view', 'view_item', 'add_to_cart',
                       'begin_checkout', 'purchase')
),
session_events AS (
  SELECT
    CONCAT(user_pseudo_id, '-', CAST(ga_session_id AS STRING)) AS session_id,
    MIN(IF(event_name = 'page_view', event_timestamp, NULL)) AS landing_ts,
    MIN(IF(event_name = 'view_item', event_timestamp, NULL)) AS product_view_ts,
    MIN(IF(event_name = 'add_to_cart', event_timestamp, NULL)) AS add_to_cart_ts,
    MIN(IF(event_name = 'begin_checkout', event_timestamp, NULL)) AS checkout_ts,
    MIN(IF(event_name = 'purchase', event_timestamp, NULL)) AS purchase_ts
  FROM event_data
  WHERE user_pseudo_id IS NOT NULL
    AND ga_session_id IS NOT NULL
  GROUP BY session_id
),
eligible AS (
  SELECT *
  FROM session_events
  WHERE landing_ts IS NOT NULL
),
stage_counts AS (
  SELECT
    COUNTIF(landing_ts IS NOT NULL) AS landing_sessions,
    COUNTIF(product_view_ts > landing_ts) AS product_view_sessions,
    COUNTIF(product_view_ts > landing_ts
            AND add_to_cart_ts > product_view_ts) AS add_to_cart_sessions,
    COUNTIF(product_view_ts > landing_ts
            AND add_to_cart_ts > product_view_ts
            AND checkout_ts > add_to_cart_ts) AS checkout_sessions,
    COUNTIF(product_view_ts > landing_ts
            AND add_to_cart_ts > product_view_ts
            AND checkout_ts > add_to_cart_ts
            AND purchase_ts > checkout_ts) AS purchase_sessions
  FROM eligible
),
stages AS (
  SELECT 1 AS stage_order, 'Landing' AS stage, landing_sessions AS sessions FROM stage_counts
  UNION ALL
  SELECT 2, 'Product View', product_view_sessions FROM stage_counts
  UNION ALL
  SELECT 3, 'Add to Cart', add_to_cart_sessions FROM stage_counts
  UNION ALL
  SELECT 4, 'Begin Checkout', checkout_sessions FROM stage_counts
  UNION ALL
  SELECT 5, 'Purchase', purchase_sessions FROM stage_counts
),
with_previous AS (
  SELECT
    stage_order,
    stage,
    sessions,
    LAG(sessions) OVER (ORDER BY stage_order) AS previous_sessions
  FROM stages
)
SELECT
  stage,
  sessions,
  ROUND(100.0 * SAFE_DIVIDE(sessions, previous_sessions), 2) AS conversion_from_previous,
  ROUND(100.0 * (1 - SAFE_DIVIDE(sessions, previous_sessions)), 2) AS dropoff_rate
FROM with_previous
ORDER BY stage_order;
