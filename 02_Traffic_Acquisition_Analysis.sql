-- 02 | First-user traffic acquisition performance by channel
-- Source: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
-- Period: 1–31 January 2021
-- Important: traffic_source fields are first-user acquisition dimensions.
-- Purchase rate = purchasing users / users; this is not session conversion or ROAS.
-- BigQuery Standard SQL

WITH user_channel AS (
  SELECT
    user_pseudo_id,
    CASE
      WHEN LOWER(COALESCE(traffic_source.medium, '')) = 'organic'
        OR LOWER(COALESCE(traffic_source.source, '')) IN ('google', 'bing', 'yahoo')
           AND LOWER(COALESCE(traffic_source.medium, '')) NOT IN ('cpc', 'ppc')
        THEN 'Organic Search'
      WHEN LOWER(COALESCE(traffic_source.medium, '')) IN ('cpc', 'ppc', 'paidsearch')
        THEN 'Paid Search'
      WHEN LOWER(COALESCE(traffic_source.source, '')) = '(direct)'
        OR LOWER(COALESCE(traffic_source.medium, '')) = '(none)'
        THEN 'Direct'
      WHEN LOWER(COALESCE(traffic_source.medium, '')) = 'referral'
        THEN 'Referral'
      ELSE 'Other / Unclassified'
    END AS channel,
    COUNT(DISTINCT CONCAT(
      user_pseudo_id, '-',
      CAST((SELECT value.int_value FROM UNNEST(event_params)
            WHERE key = 'ga_session_id') AS STRING)
    )) AS total_sessions,
    COUNTIF(event_name = 'purchase') AS purchase_events,
    SUM(IF(event_name = 'purchase',
           COALESCE(ecommerce.purchase_revenue_in_usd, 0), 0)) AS revenue_usd
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
    AND user_pseudo_id IS NOT NULL
  GROUP BY user_pseudo_id, channel
),
user_summary AS (
  SELECT
    channel,
    COUNT(DISTINCT user_pseudo_id) AS total_users,
    SUM(total_sessions) AS total_sessions,
    COUNT(DISTINCT IF(purchase_events > 0, user_pseudo_id, NULL)) AS purchasing_users,
    SUM(revenue_usd) AS total_revenue_usd
  FROM user_channel
  GROUP BY channel
)
SELECT
  channel,
  total_users,
  total_sessions,
  purchasing_users,
  ROUND(100.0 * SAFE_DIVIDE(purchasing_users, total_users), 2) AS purchase_rate,
  ROUND(total_revenue_usd, 2) AS total_revenue_usd
FROM user_summary
ORDER BY total_users DESC;
