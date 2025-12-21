# DataForSEO API Reference for AI Agents

This document provides a comprehensive schema reference for the DataForSEO API tools. Use this context to interpret tool outputs and accurately map data fields to the SEO Analysis report.

## 1. Domain Authority & Backlinks

**Tool**: `dataforseo_backlinks_summary` (Endpoint: `v3/backlinks/summary`)

### Request Parameters

- `target` (string, required): The domain to analyze (e.g., "example.com").
- `include_subdomains` (boolean): Default `true` to analyze the entire domain.

### Response Schema

The response is a JSON object. Key fields are located under `tasks[0].result[0]`.

```json
{
  "target": "example.com",
  "rank": 55, // Domain Rank (0-100). Primary authority metric.
  "backlinks": 12500, // Total backlinks found.
  "referring_domains": 1200, // Total unique domains linking.
  "referring_main_domains": 1150, // Count of root domains (filters out subdomains like blog.blogspot.com).
  "referring_pages": 4500, // Unique pages linking.
  "broken_backlinks": 150, // Links pointing to 4xx pages.
  "broken_pages": 50, // Target pages returning 4xx.
  "referring_links_tld": {
    // Distribution by TLD
    "com": 800,
    "org": 100,
    "net": 50
  },
  "backlinks_spam_score": 12, // (Optional) Proprietary spam metric if available.
  "first_seen": "2019-01-01 12:00:00"
}
```

**Interpretation**:

- **Authority**: `rank` > 50 is strong. `rank` > 80 is exceptional.
- **Trust Ratio**: `backlinks` / `referring_domains`. A very high ratio (e.g., > 100:1) suggests sitewide links or spam.
- **Health**: High `broken_backlinks` indicates a need for a redirect audit.

---

## 2. Competitor Intelligence

**Tool**: `dataforseo_competitors_domain` (Endpoint: `v3/dataforseo_labs/google/competitors_domain`)

### Request Parameters

- `target` (string): The domain to find competitors for.
- `location_code` (int): e.g., 2840 (US).
- `language_code` (string): e.g., "en".

### Response Schema

The response contains a list of competitors under `tasks[0].result[0].items`.

```json
[
  {
    "domain": "competitor-a.com",
    "avg_position": 12.5, // Average rank for keywords shared with target.
    "sum_position": 15000,
    "intersections": 450, // Number of keywords BOTH domains rank for.
    "full_domain_metrics": {
      "organic_etv": 54000, // Estimated Monthly Traffic Value (USD).
      "organic_count": 8500, // Total ranking keywords (Top 100).
      "organic_traffic": 12000 // Estimated Monthly Visits.
    },
    "metrics": { // Specific to the intersection context
      "organic_etv": ...
    }
  }
]
```

**Interpretation**:

- **True Competitors**: Look for high `intersections` AND comparable `organic_traffic`.
- **Market Leaders**: Domains with significantly higher `organic_etv` and `organic_count`.

---

## 3. Keyword Research & Gaps

**Tool**: `dataforseo_domain_intersection` (Endpoint: `v3/dataforseo_labs/google/domain_intersection`)

### Request Parameters

- `target1` (string): Your domain.
- `target2` (string): Competitor domain.
- `limit` (int): Number of results (suggest 10-20 for summaries).

### Response Schema

Items are under `tasks[0].result[0].items`.

```json
[
  {
    "keyword_data": {
      "keyword": "best running shoes",
      "search_volume": 45000, // Monthly searches.
      "keyword_difficulty": 78, // 0-100 (100 = Hardest).
      "cpc": 2.5, // Cost Per Click in USD.
      "competition": 0.9, // 0-1 (1 = High Ad density).
      "search_intent": "commercial" // informational, commercial, navigational.
    },
    "first_domain_serp_element": null, // Target domain ranking (null = not ranking).
    "second_domain_serp_element": {
      "rank_group": 3, // Competitor ranks #3.
      "type": "organic",
      "url": "https://competitor-a.com/best-running-shoes"
    }
  }
]
```

**Interpretation for "Easy Wins"**:

- Filter for: `first_domain_serp_element` is `null` (Gap).
- `search_volume` > 500.
- `keyword_difficulty` < 50.

---

## 4. On-Page / Technical SEO

**Tool**: `dataforseo_on_page_summary` (Endpoint: `v3/on_page/task_summary`)

### Request Parameters

- `target` (string): The domain.
- `id` (string): Task ID (if polling).

### Response Schema

Data under `tasks[0].result[0]`.

```json
{
  "domain_info": {
    "name": "example.com",
    "cms": "wordpress",
    "ip": "192.168.1.1",
    "server": "nginx",
    "ssl_certificate_expiration_date": "2025-01-01"
  },
  "page_metrics": {
    "duplicate_title": 12,
    "duplicate_description": 5,
    "missing_title": 0,
    "missing_h1": 2,
    "checks_failed": 150, // Total issues found.
    "non_200": 10, // Broken pages (4xx/5xx).
    "canonical": 50 // Pages with canonical tags.
  },
  "onpage_score": 85.5 // 0-100 proprietary health score.
}
```

---

## 5. Live SERP Analysis

**Tool**: `dataforseo_serp_advanced` (Endpoint: `v3/serp/google/organic/live/advanced`)

### Request Parameters

- `keyword` (string): Search term.
- `location_code`: e.g., 2840.

### Response Schema

Items under `tasks[0].result[0].items`.

```json
[
  {
    "type": "organic",
    "rank_group": 1,
    "title": "Page Title",
    "url": "https://example.com/page",
    "domain": "example.com",
    "snippet": "Description text shown in Google...",
    "items": [
      // Sitelinks or nested elements
      { "type": "sitelink", "title": "Contact Us", "url": "..." }
    ]
  },
  {
    "type": "featured_snippet",
    "rank_group": 0, // Position 0
    "title": "Defined Answer",
    "description": "Text in the snippet box."
  },
  {
    "type": "people_also_ask",
    "items": ["Question 1?", "Question 2?"]
  }
]
```

## General Handling Rules for AI

- **Nulls**: Missing data is common (e.g., `cpc: null`). Report as "N/A" rather than 0.
- **Traffic**: `organic_traffic` is an _estimate_ based on Click-Through-Rates (CTR) and positions. It is not analytics data.

---

# Additional APIs (General Purpose)

These APIs are outside the scope of the standard SEO Analysis but are available for other agentic tools.

## 6. Local SEO & Business Data

**Tool**: `dataforseo_business_data` (endpoint: `v3/business_data/google/my_business_info/live`)

### Description

Retrieves detailed Google Maps / Google Business Profile data. Essential for "Local SEO" audits.

### Key Response Fields

- `title`: Business Name.
- `address`: Full address string.
- `latitude` / `longitude`: Geolocation.
- `rating`: Aggregate user rating (0-5).
- `reviews_count`: Total number of reviews.
- `is_claimed`: Boolean (critical for Local SEO leads).
- `category`: Primary business category (e.g., "Plumber").
- `hours`: Opening hours object.

## 7. Content Analysis (Brand & Sentiment)

**Tool**: `dataforseo_content_analysis` (endpoint: `v3/content_analysis/summary`)

### Description

Analyzes text content for sentiment, readability, and topic categorization. Useful for "Brand Monitoring" or "Content Audits".

### Key Response Fields

- `sentiment_connotations`:
  - `positive`: Score (0-1).
  - `negative`: Score (0-1).
- `content_quality_score`: Proprietary metric of writing quality.
- `readability_score`: Flesch-Kincaid or similar metric.
- `social_metrics`: Shares/Likes (Facebook, Pinterest, Reddit).

## 8. E-Commerce Data (Merchant API)

**Tool**: `dataforseo_merchant_products` (endpoint: `v3/merchant/google/products`)

### Description

Scrapes Google Shopping results. Useful for "Price Intelligence" or "Product Research" agents.

### Key Response Fields

- `title`: Product name.
- `price`: Current price (integer or float).
- `currency`: Currency code (e.g., "USD").
- `seller`: Name of the vendor.
- `product_rating`: Average star rating.
- `reviews_count`: Number of product reviews.
- `delivery_info`: Shipping costs and times.
