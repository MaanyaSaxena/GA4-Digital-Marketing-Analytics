# Digital Marketing & Website Conversion Performance Analysis (GA4)

## Project overview
This project analyzes website engagement, first-user acquisition performance, and the e-commerce conversion funnel using the public Google Analytics 4 (GA4) sample ecommerce dataset in BigQuery.

**Analysis period:** 1–31 January 2021  
**Data source:** `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`  
**Tools:** Google BigQuery (SQL), Microsoft Excel, PowerPoint

## Business questions
1. How does website engagement differ across desktop, mobile, and tablet users?
2. Which first-user acquisition channels bring users and purchasing users to the website?
3. At which stage does the largest relative drop-off occur in the observed conversion funnel?
4. What practical areas should the digital team investigate to improve conversion?

## Repository contents
```text
GA4-Digital-Marketing-Analytics/
├── README.md
├── .gitignore
├── SQL/
│   ├── 01_Website_Engagement_Analysis.sql
│   ├── 02_Traffic_Acquisition_Analysis.sql
│   └── 03_Conversion_Funnel_Analysis.sql
├── Dashboard/
│   └── Digital_Marketing_Performance_Dashboard.xlsx
├── Presentation/
│   └── GA4_Website_Engagement_Conversion_Analysis.pptx
└── Results/
    ├── engagement_analysis.csv
    ├── acquisition_analysis.csv
    └── conversion_funnel.csv
```

## Key findings

### 1. Website engagement by device
- Overall engagement rate is approximately **90.75%** (weighted by sessions).
- Desktop accounts for the largest observed volume: **68,649 sessions** and **244,577 page views**.
- Average engagement time is similar across devices, ranging from approximately **46 to 50 seconds**.
- The engagement metrics are close across device categories; device-level conversion should be examined alongside engagement before prioritizing UX changes.

### 2. First-user acquisition
- Organic Search has the largest user volume (**38,489 users**) and the largest reported revenue (**$16,940**) among the displayed channels.
- Referral has the highest purchasing-user rate in this output (**1.31%**), followed by Other / Unclassified (**1.21%**).
- Paid Search has the lowest displayed purchase rate (**0.71%**) and the smallest reported revenue (**$1,839**) among the listed channels.

### 3. Sequential conversion funnel
| Funnel stage | Sessions | Conversion from previous stage | Drop-off |
|---|---:|---:|---:|
| Landing (first page_view proxy) | 111,200 | 100.00% | 0.00% |
| Product View | 22,686 | 20.40% | 79.60% |
| Add to Cart | 4,155 | 18.32% | 81.68% |
| Begin Checkout | 1,440 | 34.66% | 65.34% |
| Purchase | 803 | 55.76% | 44.24% |

The largest relative stage-to-stage drop-off is from **Product View to Add to Cart (81.68%)**. This is a point for further investigation, not proof of a specific cause.

## Recommendations
1. Investigate product-page engagement and add-to-cart usability, including product information, pricing clarity, availability, and mobile interaction.
2. Review landing-page relevance and the journey from the first page view to product discovery.
3. Evaluate acquisition channels using consistent attribution and cost data before reallocating campaign budgets.
4. Pair funnel monitoring with controlled experiments (for example, A/B tests) before claiming that a change caused conversion improvement.

## Methodology and interpretation notes
- Engagement analysis groups activity by GA4 session identifier and device category. The exported table reports sessions, engaged sessions, engagement rate, average engagement time, page views, and page views per session.
- Acquisition analysis uses GA4 **first-user** source/medium fields to classify users into channels. The displayed purchase rate is purchasing users divided by users in the channel. It is **not** a session conversion rate and does not represent ROAS.
- “Other / Unclassified” is a combined residual category and should not be treated as a single actionable marketing channel.
- The funnel requires an ordered sequence of events within a session. The initial “Landing” stage is represented by the first `page_view` event and is therefore a proxy, not a separately validated landing-page dimension.
- Sessions without the identifiers or qualifying events required by the query are not represented in the funnel.
- These are observational analytics. They do not establish why users drop off or prove that a proposed intervention will improve conversion.
- Revenue and purchase metrics are based on the sample dataset and should not be interpreted as current commercial performance.

## Reproducing the analysis
1. Open Google Cloud BigQuery and select a project with BigQuery access.
2. Open each `.sql` file in the `SQL/` folder and run it against the public GA4 sample dataset.
3. The queries are written for BigQuery Standard SQL and use the January 2021 event tables.
4. Compare query outputs with the CSV snapshots in `Results/`.
5. Open the Excel workbook in `Dashboard/` and the presentation in `Presentation/`.

## Dataset
Google Analytics 4 obfuscated sample ecommerce dataset:
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

The dataset is publicly available through Google BigQuery. Table availability and access are subject to Google's dataset terms and platform access.
