# Campaign Performance (Monthly, MoM %) — FB + Google

**What it is:** SQL pipeline that unifies Facebook & Google Ads daily data, aggregates by month & `utm_campaign`, computes core marketing KPIs (CTR, CPC, CPM, ROMI), and adds month-over-month % deltas per campaign.

**Why it matters (consulting/EDA):**
- Multi-source → unified model → business metrics → MoM trends.
- Clear, decision-ready outputs for growth/efficiency discussions.
- Easy to plug into Power BI/Tableau dashboard.

## Data & Fields
- `public.facebook_ads_basic_daily`
- `public.google_ads_basic_daily`
Columns: `ad_date`, `url_parameters`, `spend`, `impressions`, `reach`, `clicks`, `leads`, `value`.

`utm_campaign` parsed from `url_parameters` and normalized to lower case.

## Metrics
- CTR = clicks / impressions  
- CPC = spend / clicks  
- CPM = (spend / impressions) * 1000  
- ROMI = (value / spend) − 1  
- MoM % for CTR/CPM/ROMI via `LAG()` by `utm_campaign`.

## How to Run
1) Ensure both daily tables exist (or load sample CSVs).
2) Run `sql/hw_l7_campaign_mom.sql` in Postgres (v13+).
3) Use the result for a Power BI/Tableau dashboard.

## Suggested Dashboard
Pages: **Overview**, **Trends**, **Campaign Deep-Dive**.  
Export screenshots to `dashboard/screenshots/*.png`.

## Repo Map
- `sql/` — core query  
- `dashboard/` — BI files & screenshots  
- `docs/metrics.md` — formulas  
- `docs/data_dictionary.md` — fields

## License
MIT

## Insights (from my run)
- **spring_sale (Jun vs May):** CTR ↓ **6.60%**, CPM ↓ **6.28%**, ROMI ↓ **1.24%** — impressions got cheaper, but value per $ spend softened; review creatives/landing and refine targeting segments.
- **summer_promo (Jun only):** CTR ≈ **4.52%**, CPM ≈ **11.90**, ROMI ≈ **3.00x** — solid starting efficiency; test ways to lift CTR while keeping CPM under control.
- **Tracking hygiene:** ensure `utm_campaign` is always present and standardized (lowercase, decoded spaces).
- **Governance:** set a ROMI target and alerts when CTR/ROMI drop by more than *X%* MoM.
