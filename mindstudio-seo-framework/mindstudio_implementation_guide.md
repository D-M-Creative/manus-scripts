# MindStudio Implementation Guide for SEO Agency App

## Introduction

This guide provides step-by-step instructions for implementing the SEO Agency App in MindStudio. The app will enable marketing agencies to generate professional SEO reports using DataForSEO APIs and provide interactive chat-based data exploration.

## Prerequisites

Before you begin, ensure you have the following:

1. **MindStudio Account**: Access to MindStudio with the ability to create new apps.
2. **DataForSEO Account**: An active DataForSEO account with sufficient API credits.
3. **API Credentials**: Your DataForSEO API login and password (available at https://app.dataforseo.com/api-access).
4. **Basic Understanding**: Familiarity with MindStudio's interface, variables, and workflow automation.

## Phase 1: Initial App Setup

### Step 1: Create a New MindStudio App

Navigate to MindStudio and create a new application with the following settings:

**App Name:** SEO Intelligence Hub

**App Description:** Professional SEO analysis and reporting tool for marketing agencies, powered by DataForSEO APIs.

**Primary Use Case:** Generate comprehensive SEO reports with interactive data exploration.

### Step 2: Configure AI Model

Select the appropriate AI model for your app. For the best results with complex SEO analysis, the recommended configuration is:

**Primary Model:** GPT-4 (for report generation and complex analysis)

**Secondary Model:** GPT-3.5 Turbo (for chat interactions and follow-up questions)

The primary model will handle the initial report generation, while the secondary model can be used for the interactive chat mode to optimize costs.

### Step 3: Set Up Environment Variables

Configure the following environment variables in MindStudio to securely store your DataForSEO credentials:

**Variable Name:** `DATAFORSEO_LOGIN`  
**Value:** Your DataForSEO API login (email address)

**Variable Name:** `DATAFORSEO_PASSWORD`  
**Value:** Your DataForSEO API password (auto-generated, different from account password)

These credentials will be used to authenticate all API requests to DataForSEO.

## Phase 2: Input Configuration

### Step 4: Create Input Variables

Set up the following input variables to capture user information:

**Variable: `URL`**
- **Type:** Text Input
- **Label:** "Website URL to Analyze"
- **Placeholder:** "https://example.com"
- **Required:** Yes
- **Validation:** URL format validation
- **Description:** "Enter the full URL of the website you want to analyze"

**Variable: `REPORT_TYPE`**
- **Type:** Dropdown Selection
- **Label:** "Select Report Type"
- **Options:**
  - Comprehensive SEO Audit (default)
  - E-E-A-T Content Evaluation
  - Competitor Intelligence Report
  - Keyword Strategy Report
  - Technical SEO Deep Dive
  - Backlink Profile Analysis
  - Custom Multi-Report
- **Required:** Yes
- **Description:** "Choose the type of SEO analysis you want to generate"

**Variable: `LOCATION_CODE`**
- **Type:** Dropdown Selection
- **Label:** "Target Location"
- **Options:**
  - United Kingdom (2826) - default
  - United States (2840)
  - Australia (2036)
  - Canada (2124)
  - Custom (allow manual input)
- **Required:** No
- **Default:** 2826
- **Description:** "Geographic location for search data"

**Variable: `LANGUAGE_CODE`**
- **Type:** Text Input
- **Label:** "Language Code"
- **Default:** "en"
- **Required:** No
- **Description:** "Language code for search results (e.g., en, es, fr)"

### Step 5: Create Advanced Options (Collapsible Section)

Add an optional "Advanced Options" section with the following variables:

**Variable: `COMPETITOR_COUNT`**
- **Type:** Number Input
- **Label:** "Number of Competitors to Analyze"
- **Default:** 5
- **Range:** 1-10
- **Required:** No

**Variable: `KEYWORD_LIMIT`**
- **Type:** Number Input
- **Label:** "Maximum Keywords to Retrieve"
- **Default:** 100
- **Range:** 10-1000
- **Required:** No

**Variable: `DEVICE_TYPE`**
- **Type:** Dropdown
- **Label:** "Device Type"
- **Options:** Desktop, Mobile
- **Default:** Desktop
- **Required:** No

## Phase 3: Workflow Automation

### Step 6: URL Validation Workflow

Create the first workflow step to validate the URL input before proceeding with API calls.

**Workflow Name:** URL Validation

**Trigger:** When user submits the form

**Logic:**
```
IF {{URL}} is empty OR {{URL}} does not match URL pattern:
  DISPLAY ERROR: "⚠️ Error: No valid target URL provided. Please provide a website URL to begin the SEO analysis."
  STOP WORKFLOW
ELSE:
  NORMALIZE URL (add https:// if missing, remove trailing slash)
  EXTRACT DOMAIN from {{URL}}
  STORE in variable {{DOMAIN}}
  CONTINUE to next step
```

### Step 7: DataForSEO API Integration

For each report type, you will need to configure HTTP requests to the DataForSEO API. The following example shows how to set up the Backlinks Summary API call for the Comprehensive SEO Audit.

**API Call Name:** Get Domain Authority

**Method:** POST

**URL:** `https://api.dataforseo.com/v3/backlinks/summary/live`

**Headers:**
```json
{
  "Content-Type": "application/json"
}
```

**Authentication:** Basic Auth
- **Username:** `{{DATAFORSEO_LOGIN}}`
- **Password:** `{{DATAFORSEO_PASSWORD}}`

**Request Body:**
```json
[
  {
    "target": "{{DOMAIN}}",
    "internal_list_limit": 10,
    "include_subdomains": true
  }
]
```

**Response Storage:**
- Store the full response in a variable called `{{BACKLINKS_DATA}}`
- Parse and extract key metrics:
  - `rank` → `{{DOMAIN_RANK}}`
  - `backlinks` → `{{BACKLINKS_COUNT}}`
  - `referring_domains` → `{{REFERRING_DOMAINS}}`
  - `dofollow` → `{{DOFOLLOW_COUNT}}`

**Error Handling:**
```
IF response.status_code == 40204:
  SET {{BACKLINKS_FALLBACK}} = true
  TRIGGER browser automation to Ahrefs Free Backlink Checker
  EXTRACT data from Ahrefs
ELSE IF response.status_code != 20000:
  LOG ERROR
  DISPLAY: "Error retrieving backlink data. Please try again."
  STOP WORKFLOW
```

### Step 8: Competitor Analysis API Call

**API Call Name:** Get Competitors

**Method:** POST

**URL:** `https://api.dataforseo.com/v3/dataforseo_labs/google/competitors_domain/live`

**Authentication:** Basic Auth (same as above)

**Request Body:**
```json
[
  {
    "target": "{{DOMAIN}}",
    "location_code": {{LOCATION_CODE}},
    "language_code": "{{LANGUAGE_CODE}}",
    "limit": {{COMPETITOR_COUNT}},
    "filters": ["metrics.organic.count", ">", 100]
  }
]
```

**Response Storage:**
- Store full response in `{{COMPETITORS_DATA}}`
- Extract top competitors into `{{COMPETITOR_LIST}}` (array of domains)
- Extract intersection counts for each competitor

### Step 9: Ranked Keywords API Call

**API Call Name:** Get Ranked Keywords

**Method:** POST

**URL:** `https://api.dataforseo.com/v3/dataforseo_labs/google/ranked_keywords/live`

**Request Body:**
```json
[
  {
    "target": "{{DOMAIN}}",
    "location_code": {{LOCATION_CODE}},
    "language_code": "{{LANGUAGE_CODE}}",
    "limit": {{KEYWORD_LIMIT}},
    "order_by": ["metrics.organic.pos_1,desc"]
  }
]
```

**Response Storage:**
- Store in `{{RANKED_KEYWORDS_DATA}}`
- Extract total count → `{{TOTAL_KEYWORDS}}`
- Extract top 10 keywords → `{{TOP_KEYWORDS}}` (array)

### Step 10: Domain Intersection API Call

**API Call Name:** Get Keyword Gaps

**Method:** POST

**URL:** `https://api.dataforseo.com/v3/dataforseo_labs/google/domain_intersection/live`

**Request Body:**
```json
[
  {
    "target1": "{{DOMAIN}}",
    "target2": "{{COMPETITOR_LIST[0]}}",
    "location_code": {{LOCATION_CODE}},
    "language_code": "{{LANGUAGE_CODE}}",
    "limit": 100,
    "filters": [
      ["intersection_result1.type", "=", null],
      "and",
      ["intersection_result2.type", "=", "organic"]
    ]
  }
]
```

**Response Storage:**
- Store in `{{KEYWORD_GAPS_DATA}}`
- Extract missing keywords (where target doesn't rank but competitor does)
- Identify high-volume, low-difficulty opportunities

### Step 11: Manual Website Review (Browser Automation)

**Workflow Name:** Technical Site Review

**Action:** Open browser and navigate to `{{URL}}`

**Tasks:**
1. Check page load time
2. Verify mobile responsiveness
3. Identify navigation structure
4. Look for schema markup
5. Check for obvious technical issues (404s, broken images, etc.)
6. Screenshot homepage and key pages

**Storage:**
- Store observations in `{{TECHNICAL_NOTES}}`
- Store screenshots in `{{SITE_SCREENSHOTS}}`

## Phase 4: Report Generation

### Step 12: Configure Master Prompt

Create a new prompt workflow that will generate the final report. Use the content from `comprehensive_seo_audit.yaml` as the base prompt.

**Prompt Name:** Generate Comprehensive SEO Audit

**System Prompt:**
```
You are a Senior SEO Strategist and Data Analyst. Your task is to audit a website's search performance, competition, and technical health using the DataForSEO API.
```

**User Prompt Template:**
Use the full Master_Prompt from the YAML file, replacing placeholders with actual variables:
- `{{URL}}` → The user-provided URL
- Reference the stored API data variables in the prompt context

**Context Variables to Include:**
- `{{BACKLINKS_DATA}}`
- `{{COMPETITORS_DATA}}`
- `{{RANKED_KEYWORDS_DATA}}`
- `{{KEYWORD_GAPS_DATA}}`
- `{{TECHNICAL_NOTES}}`

**Output Format:** Markdown

**Output Storage:** Store the generated report in `{{REPORT_CONTENT}}`

### Step 13: Scoring Calculations

Create a separate workflow to calculate the scores for each category based on the data collected.

**Domain Authority Score:**
```
IF {{DOMAIN_RANK}} < 50 AND {{REFERRING_DOMAINS}} > 1000:
  SCORE = 9-10
ELSE IF {{DOMAIN_RANK}} 50-200 AND {{REFERRING_DOMAINS}} 300-1000:
  SCORE = 7-8
ELSE IF {{DOMAIN_RANK}} 200-500 AND {{REFERRING_DOMAINS}} 100-300:
  SCORE = 5-6
ELSE IF {{DOMAIN_RANK}} 500-900 AND {{REFERRING_DOMAINS}} 20-100:
  SCORE = 3-4
ELSE:
  SCORE = 1-2

STORE in {{DOMAIN_AUTHORITY_SCORE}}
```

Apply similar logic for:
- `{{COMPETITIVE_STRENGTH_SCORE}}`
- `{{CONTENT_STRATEGY_SCORE}}`
- `{{TECHNICAL_HEALTH_SCORE}}`

Calculate the overall score as the average of all four scores.

### Step 14: Report Display

Create a display component that shows the generated report to the user with the following features:

**Display Elements:**
1. **Report Title:** "SEO Analysis Report for {{DOMAIN}}"
2. **Report Content:** Display `{{REPORT_CONTENT}}` with proper markdown rendering
3. **Export Options:**
   - Download as PDF
   - Download as DOCX
   - Copy to clipboard
4. **Action Button:** "Start Chat Analysis" (triggers chat mode)

## Phase 5: Interactive Chat Mode

### Step 15: Chat Mode Activation

When the user clicks "Start Chat Analysis," transition to chat mode with the following configuration:

**Chat Interface:** Enable conversational UI

**System Prompt for Chat Mode:**
```
You are now in Interactive Chat Mode. The full SEO report and all the raw DataForSEO API data are available in your context.

Your capabilities in this mode are:
1. Drill into specific metrics: Access the stored API data to provide detailed numbers, lists, and tables.
2. Answer comparative questions: Compare the target URL against its competitors using the stored data.
3. Explain the analysis: Justify the scores and recommendations from the report with specific data points.
4. Run new API calls: If a user asks for new information, you can use the DataForSEO tools again (with user confirmation).

When answering, be concise and directly reference the data. Use tables and lists to present data clearly.
```

**Context Variables Available in Chat:**
- `{{REPORT_CONTENT}}` - The full generated report
- `{{BACKLINKS_DATA}}` - Raw backlinks API response
- `{{COMPETITORS_DATA}}` - Raw competitors API response
- `{{RANKED_KEYWORDS_DATA}}` - Raw ranked keywords API response
- `{{KEYWORD_GAPS_DATA}}` - Raw keyword gaps API response
- `{{TECHNICAL_NOTES}}` - Manual review notes
- `{{URL}}` - Original URL analyzed
- `{{DOMAIN}}` - Extracted domain

**Initial Chat Message:**
```
Great! The SEO analysis for {{DOMAIN}} is complete. I have all the data from the report and the raw API responses available. 

You can ask me questions like:
- "Show me the top 10 referring domains"
- "Compare our backlink count to the top 3 competitors"
- "Why was the technical score a 6?"
- "What are the easiest keywords to target first?"

What would you like to explore?
```

### Step 16: Chat Response Handling

Configure the chat to handle different types of questions:

**Type 1: Data Retrieval Questions**
Examples: "Show me the top 10 keywords", "What are our referring domains?"

**Response Logic:**
- Parse the question to identify the requested data type
- Access the appropriate variable (e.g., `{{RANKED_KEYWORDS_DATA}}`)
- Extract and format the requested information
- Present in a table or list format

**Type 2: Comparative Questions**
Examples: "How do we compare to competitor X?", "What's the traffic gap?"

**Response Logic:**
- Identify the comparison targets
- Access both datasets
- Calculate the difference or ratio
- Present with context and interpretation

**Type 3: Explanation Questions**
Examples: "Why did you score X as Y?", "Explain the technical issues"

**Response Logic:**
- Reference the specific section of the report
- Cite the data points that led to the conclusion
- Provide additional context or examples

**Type 4: New Analysis Requests**
Examples: "Analyze competitor.com", "Check rankings for keyword X"

**Response Logic:**
- Identify the new API call required
- Ask user for confirmation: "This will require a new API call to DataForSEO, which will use credits. Would you like me to proceed?"
- If confirmed, execute the API call
- Store the new data and provide the analysis

## Phase 6: Testing and Optimization

### Step 17: Test the Complete Workflow

Test the app with various URLs and scenarios:

1. **Test Case 1: Established Website**
   - URL: A well-known website with strong SEO
   - Expected: High scores, comprehensive data

2. **Test Case 2: New Website**
   - URL: A recently launched site with minimal SEO
   - Expected: Low scores, limited data, but no errors

3. **Test Case 3: Invalid URL**
   - URL: Malformed or non-existent URL
   - Expected: Proper error handling and user guidance

4. **Test Case 4: API Error Simulation**
   - Scenario: Backlinks API returns error 40204
   - Expected: Fallback to Ahrefs Free Backlink Checker

5. **Test Case 5: Chat Mode**
   - Generate a report, then ask various types of questions
   - Expected: Accurate, data-driven responses

### Step 18: Optimize for Performance

**API Call Optimization:**
- Use Standard method (task_post) instead of Live method where possible to reduce costs
- Batch API requests when the DataForSEO API supports it
- Implement caching for frequently analyzed domains (with user permission)

**Response Time Optimization:**
- Show progress indicators during API calls
- Stream the report generation so users see content as it's created
- Preload chat mode context while the user is reading the report

**Cost Optimization:**
- Monitor DataForSEO credit usage
- Provide users with an estimate of credits required before running analysis
- Offer different analysis tiers (Basic, Standard, Premium) with varying API call depth

## Phase 7: Advanced Features

### Step 19: White-Label Export

Implement white-label PDF export functionality:

**Configuration:**
- Allow users to upload their agency logo
- Provide color scheme customization
- Add custom header/footer text
- Include agency contact information

**PDF Generation:**
- Use a PDF generation library or service
- Apply the custom branding to the report template
- Include all charts and tables from the report
- Add a professional cover page

### Step 20: Scheduled Monitoring

Enable users to schedule recurring analysis:

**Setup:**
- Add a "Schedule Monitoring" option after report generation
- Allow users to select frequency (weekly, monthly)
- Store the URL and settings for recurring analysis
- Send email notifications when new reports are ready

**Implementation:**
- Use MindStudio's scheduling features or external cron jobs
- Store scheduled tasks in a database
- Generate reports automatically and store them
- Provide a dashboard to view historical reports and trends

### Step 21: Batch Analysis

Allow users to analyze multiple URLs at once:

**Input:**
- Accept a list of URLs (up to 10)
- Option to upload a CSV file with URLs

**Processing:**
- Run the analysis workflow for each URL sequentially or in parallel (if MindStudio supports it)
- Show progress for each URL

**Output:**
- Generate individual reports for each URL
- Create a comparative summary report highlighting:
  - Best and worst performers across all URLs
  - Average scores by category
  - Recommendations for portfolio-wide improvements

## Conclusion

This implementation guide provides a comprehensive roadmap for building the SEO Agency App in MindStudio. By following these steps, you will create a powerful tool that leverages DataForSEO APIs to deliver professional-grade SEO analysis with interactive data exploration capabilities.

The modular design allows for easy expansion and customization. Start with the MVP (Comprehensive SEO Audit), validate with users, and then progressively add more report types and advanced features based on feedback and demand.
