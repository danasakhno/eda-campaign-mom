# Metrics & MoM
CTR = clicks / impressions
CPC = spend / clicks
CPM = (spend / impressions) * 1000
ROMI = (value / spend) − 1

MoM % change:
prev = LAG(metric) by utm_campaign ordered by ad_month
change_pct = (metric − prev) / prev * 100
if prev null or 0 → null
