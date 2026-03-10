reports/assumptions_and_limitations.md

# Assumptions & Limitations

## Data Scope & Time Coverage
- The analysis is based on the Google Analytics public e-commerce sample dataset.
- The dataset spans **366 days**, from **2016-08-01 to 2017-08-01**, providing sufficient historical coverage to minimize short-term seasonality bias.
- All funnel metrics are assumed to be stable across this time window.

## Funnel Event Assumptions
- The conversion funnel is constructed using Google Analytics eCommerce action types:
  - Product View (`action_type = 2`)
  - Add to Cart (`action_type = 3`)
  - Checkout (`action_type = 5`)
  - Purchase (`action_type = 6`)
- Additional action types (e.g., `action_type = 1` and `action_type = 4`) exist in the data but are excluded from the core funnel to maintain a clear, decision-focused analysis.
- Funnel steps are assumed to occur within the same session and are evaluated at the **session level**.

## Revenue Assumptions
- Revenue is recorded **only at the purchase stage** and is not available for intermediate funnel steps.
- Transaction revenue is stored in **micros** and converted to standard currency units during analysis.
- A total of **11,552 orders** and approximately **17.8 million** in total revenue are present, which is sufficient for revenue leakage analysis.

## Data Quality & Tracking Limitations
- The dataset contains **sessions with purchases but no recorded product views** (2,163 sessions), indicating:
  - Incomplete event tracking, or
  - Users entering the funnel mid-stream (e.g., direct checkout links, bookmarked pages).
- These sessions are treated as valid but highlight real-world data imperfections common in analytics systems.
- The analysis does not attempt to reconstruct missing user actions beyond what is recorded.

## Device Segmentation Considerations
- Traffic is dominated by **desktop sessions**, followed by **mobile**, with **tablet traffic forming a small minority**.
- Tablet traffic is retained in high-level metrics but excluded from deep-dive analysis due to low volume.
- Differences in conversion performance across devices are assumed to be driven by user experience and interaction constraints rather than traffic availability.

## General Limitations
- The dataset represents a **sample GA property** and does not reflect the full complexity of a live production environment.
- User identity is session-based; cross-session user behavior cannot be reliably tracked.
- Results should be interpreted as **directional insights** rather than exact production benchmarks.

## Analytical Boundary
- This project focuses on **identifying revenue leakage and prioritizing funnel optimization opportunities**, not on predicting user behavior or implementing real-time personalization.
