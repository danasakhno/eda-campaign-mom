WITH combined_ads AS (
  SELECT ad_date,url_parameters,
         COALESCE(spend,0)::numeric AS spend,
         COALESCE(impressions,0)::numeric AS impressions,
         COALESCE(reach,0)::numeric AS reach,
         COALESCE(clicks,0)::numeric AS clicks,
         COALESCE(leads,0)::numeric AS leads,
         COALESCE(value,0)::numeric AS value
  FROM public.facebook_ads_basic_daily
  UNION ALL
  SELECT ad_date,url_parameters,
         COALESCE(spend,0)::numeric,
         COALESCE(impressions,0)::numeric,
         COALESCE(reach,0)::numeric,
         COALESCE(clicks,0)::numeric,
         COALESCE(leads,0)::numeric,
         COALESCE(value,0)::numeric
  FROM public.google_ads_basic_daily
),
extracted_campaigns AS (
  SELECT
    date_trunc('month', ad_date)::date AS ad_month,
    lower(NULLIF(regexp_replace(regexp_replace(
      substring(url_parameters from 'utm_campaign=([^&#$]+)'),
      '\+|%20',' ','gi'),'%2F','/','gi'),'nan')) AS utm_campaign,
    spend, impressions, reach, clicks, leads, value
  FROM combined_ads
),
aggregated_data AS (
  SELECT
    ad_month, utm_campaign,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(reach) AS total_reach,
    SUM(clicks) AS total_clicks,
    SUM(leads) AS total_leads,
    SUM(value) AS total_value,
    CASE WHEN SUM(impressions)=0 THEN 0
         ELSE ROUND(SUM(clicks)::numeric/SUM(impressions),4) END AS ctr,
    CASE WHEN SUM(clicks)=0 THEN 0
         ELSE ROUND(SUM(spend)::numeric/NULLIF(SUM(clicks),0),2) END AS cpc,
    CASE WHEN SUM(impressions)=0 THEN 0
         ELSE ROUND((SUM(spend)::numeric/NULLIF(SUM(impressions),0))*1000,2) END AS cpm,
    CASE WHEN SUM(spend)=0 THEN 0
         ELSE ROUND(SUM(value)::numeric/NULLIF(SUM(spend),0)-1,4) END AS romi
  FROM extracted_campaigns
  WHERE utm_campaign IS NOT NULL AND utm_campaign <> ''
  GROUP BY ad_month, utm_campaign
),
with_changes AS (
  SELECT a.*,
         LAG(ctr)  OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS prev_ctr,
         LAG(cpm)  OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS prev_cpm,
         LAG(romi) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS prev_romi
  FROM aggregated_data a
)
SELECT ad_month, utm_campaign,
       total_spend,total_impressions,total_reach,total_clicks,total_leads,total_value,
       ctr,cpc,cpm,romi,
       CASE WHEN prev_ctr  IS NULL OR prev_ctr  = 0 THEN NULL ELSE ROUND(100*(ctr  - prev_ctr )/prev_ctr ,2) END AS ctr_change_pct,
       CASE WHEN prev_cpm  IS NULL OR prev_cpm  = 0 THEN NULL ELSE ROUND(100*(cpm  - prev_cpm )/prev_cpm ,2) END AS cpm_change_pct,
       CASE WHEN prev_romi IS NULL OR prev_romi = 0 THEN NULL ELSE ROUND(100*(romi - prev_romi)/prev_romi,2) END AS romi_change_pct
FROM with_changes
ORDER BY ad_month, utm_campaign;
