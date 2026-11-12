-- 01 | Website engagement by device category
-- Source: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
-- Period: 1–31 January 2021
-- BigQuery Standard SQL

WITH event_data AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value
     FROM UNNEST(event_params)
     WHERE key = 'ga_session_id') AS ga_session_id,
    event_name,
    device.category AS device_category,
    COALESCE(
      (SELECT value.int_value
       FROM UNNEST(event_params)
       WHERE key = 'engagement_time_msec'), 0
    ) AS engagement_time_msec,
    (SELECT value.int_value
     FROM UNNEST(event_params)
     WHERE key = 'session_engaged') AS session_engaged
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
),
session_level AS (
  SELECT
    CONCAT(user_pseudo_id, '-', CAST(ga_session_id AS STRING)) AS session_id,
    device_category,
    MAX(IF(session_engaged = 1, 1, 0)) AS is_engaged,
    SUM(engagement_time_msec) / 1000.0 AS engagement_seconds,
    COUNTIF(event_name = 'page_view') AS page_views
  FROM event_data
  WHERE user_pseudo_id IS NOT NULL
    AND ga_session_id IS NOT NULL
  GROUP BY session_id, device_category
)
SELECT
  device_category,
  COUNT(*) AS total_sessions,
  SUM(is_engaged) AS engaged_sessions,
  ROUND(100.0 * SAFE_DIVIDE(SUM(is_engaged), COUNT(*)), 2) AS engagement_rate,
  ROUND(AVG(engagement_seconds), 2) AS avg_engagement_seconds,
  SUM(page_views) AS total_page_views,
  ROUND(AVG(page_views), 2) AS page_views_per_session
FROM session_level
GROUP BY device_category
ORDER BY total_sessions DESC;
