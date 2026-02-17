# Building the SEO Agency App: A Step-by-Step MindStudio Guide

## Introduction

This guide provides a detailed, platform-specific walkthrough for building the SEO Intelligence Hub within MindStudio. It translates the architectural concepts from the previous documents into concrete actions inside the MindStudio visual builder, referencing specific blocks, settings, and workflows. This document assumes you have a MindStudio account and a DataForSEO account with API credentials.

---

## Phase 1: Project Setup & Global Configuration

This phase involves creating the AI agent and setting up the necessary global configurations that will be used across the entire application.

### Step 1: Create a New AI Agent

1.  From your MindStudio dashboard, click **"Create New AI"**.
2.  Select **"Start from Scratch"**.
3.  **Name your AI Agent:** `SEO Intelligence Hub`.
4.  **Provide a description:** `An advanced SEO analysis tool for marketing agencies, using DataForSEO to generate comprehensive reports with interactive chat.`

### Step 2: Configure Global Variables for API Keys

Storing your API keys in Global Variables makes them reusable and secure. They will not be exposed to end-users.

1.  Navigate to the **Automations** tab.
2.  In the left-hand panel, select the **Variables** tab.
3.  Click **"Add Global Variable"**.
4.  Create the following two variables:

| Variable Name | Type | Value | Description |
| :--- | :--- | :--- | :--- |
| `DATAFORSEO_LOGIN` | Secret | Your DataForSEO Login Email | Your API login credential. |
| `DATAFORSEO_PASSWORD` | Secret | Your DataForSEO API Password | Your secret API password from the DataForSEO dashboard. |

These variables can now be called as `{{DATAFORSEO_LOGIN}}` and `{{DATAFORSEO_PASSWORD}}` in any block that requires them, such as the HTTP Request block.

### Step 3: Define the System Prompt

The System Prompt provides the AI with its core identity and high-level instructions that persist across the entire workflow.

1.  Go to the **Automations** tab.
2.  In the main canvas, click on the **System Prompt** tab (next to Automations).
3.  Copy and paste the following prompt. This sets the stage for all subsequent AI interactions.

```text
You are a world-class Senior SEO Strategist and Data Analyst. Your name is Manus. You are an expert at interpreting complex API data and translating it into actionable business insights for marketing agencies. You are precise, data-driven, and your goal is to provide brutally honest, yet constructive, feedback to help users improve their search engine performance. You will be using the DataForSEO API to conduct your analysis.
```

---

## Phase 2: Building the User Interface (The Input Form)

This phase focuses on creating the initial form that users will interact with to start an analysis.

### Step 1: Add a User Input Block

1.  In the **Automations** canvas, click the `+` icon after the **Start Block**.
2.  Select the **User Input** block from the menu.

### Step 2: Configure the Input Fields

Within the User Input block, you will add fields to collect the necessary information.

1.  Click **"Add Input"** and create the following fields:

    *   **URL Input:**
        *   **Input Type:** `Text`
        *   **Variable Name:** `URL`
        *   **Label:** `Enter Website URL to Analyze`
        *   **Is Required:** `Yes`

    *   **Report Type Selection:**
        *   **Input Type:** `Single-Select`
        *   **Variable Name:** `REPORT_TYPE`
        *   **Label:** `Select Report Type`
        *   **Options:** Add the seven report types from our architecture document (e.g., "Comprehensive SEO Audit", "E-E-A-T Content Evaluation", etc.).
        *   **Is Required:** `Yes`

    *   **Location Selection (Optional):**
        *   **Input Type:** `Single-Select`
        *   **Variable Name:** `LOCATION_CODE`
        *   **Label:** `Select Target Location`
        *   **Options:** `United Kingdom (2826)`, `United States (2840)`, etc.
        *   **Default Value:** `2826`

### Step 3: (Optional) Design a Custom Interface

For a more professional look, you can use the Interface Designer.

1.  In the User Input block settings, under **Optional Settings**, switch the **Interface** toggle from `Default` to `Custom (Beta)`.
2.  Click **"Configure Interface"**.
3.  In the **Chat** tab of the designer, use a "vibe-coding" prompt like:
    > "Create a clean, professional form. It should have a large heading that says 'SEO Intelligence Hub'. Below that, include a text input field for 'URL' and a dropdown menu for 'Report Type'. Add a submit button at the bottom that says 'Generate Report'."
4.  The AI will generate the React code. You can refine it with further instructions or edit the code directly in the **Code** tab.
5.  Click **Compile** when you are satisfied.

---

## Phase 3: Creating the Core Workflow (DataForSEO API Calls)

This is where you will chain together **HTTP Request** blocks to fetch data from DataForSEO. We will use the "Comprehensive SEO Audit" as our example workflow.

### Step 1: Add a Logic Block for Routing

To handle different report types, you'll start with a Logic Block.

1.  After the User Input block, add a **Logic Block**.
2.  Set the **Condition** to check the `{{REPORT_TYPE}}` variable.
3.  Create branches for each report type. For now, we will build out the "Comprehensive SEO Audit" branch.

### Step 2: Configure the First API Call (Backlinks Summary)

1.  In the "Comprehensive SEO Audit" branch, add an **HTTP Request** block.
2.  **Name the block:** `Get Backlinks Summary`.
3.  Configure the block with the following settings:

| Setting | Value |
| :--- | :--- |
| **URL** | `https://api.dataforseo.com/v3/backlinks/summary/live` |
| **Method** | `POST` |
| **Headers** | `Content-Type`: `application/json` <br> `Authorization`: `Basic {{base64(concat(DATAFORSEO_LOGIN, ":", DATAFORSEO_PASSWORD))}}` |
| **Body** | `[{"target": "{{URL}}"}]` |
| **Output Variable** | `backlinks_data` |

*Note on Authorization:* MindStudio's HTTP Request block has built-in Basic Auth. You can select it and provide `{{DATAFORSEO_LOGIN}}` and `{{DATAFORSEO_PASSWORD}}` directly. The `base64` method is an alternative if manual header construction is needed.

### Step 3: Chain Subsequent API Calls

Repeat the process for the other required endpoints. Add a new **HTTP Request** block after the previous one and configure it. Each block will save its output to a new variable.

*   **Get Competitors:**
    *   **URL:** `https://api.dataforseo.com/v3/dataforseo_labs/google/competitors_domain/live`
    *   **Body:** `[{"target": "{{URL}}", "location_code": {{LOCATION_CODE}}}]`
    *   **Output Variable:** `competitors_data`

*   **Get Ranked Keywords:**
    *   **URL:** `https://api.dataforseo.com/v3/dataforseo_labs/google/ranked_keywords/live`
    *   **Body:** `[{"target": "{{URL}}", "location_code": {{LOCATION_CODE}}}]`
    *   **Output Variable:** `ranked_keywords_data`

Your workflow for this branch should now look like: `Start -> User Input -> Logic Block -> Get Backlinks -> Get Competitors -> Get Ranked Keywords`.

---

## Phase 4: Generating and Displaying the Report

Now that you have the data stored in variables, you will use an AI block to write the report.

### Step 1: Add a Generate Text Block

1.  After the last HTTP Request block in your chain, add a **Generate Text** block.
2.  **Name the block:** `Generate SEO Report`.

### Step 2: Configure the Prompt

This is where you'll use the detailed master prompt from your YAML files.

1.  In the **Prompt** field of the Generate Text block, copy the `Master_Prompt` from the `comprehensive_seo_audit.yaml` file.
2.  Crucially, you must tell the AI to use the data you've collected. Add a preamble to the prompt like this:

    ```text
    You are a Senior SEO Strategist. Analyze the following data and generate a comprehensive SEO audit for the target URL: {{URL}}.

    **Backlinks Data:**
    {{backlinks_data}}

    **Competitors Data:**
    {{competitors_data}}

    **Ranked Keywords Data:**
    {{ranked_keywords_data}}

    --- (Paste the rest of the Master_Prompt from the YAML here) ---
    ```

### Step 3: Configure the Output

1.  **Response Behavior:** Set this to `Display to User`.
2.  **Output Schema:** Set this to `Text (Default)` to allow for Markdown formatting.
3.  **Model Settings (Optional):** You can override the workspace default and select a more powerful model like GPT-4 for this specific task to ensure a high-quality report.

---

## Phase 5: Implementing the Interactive Chat

This feature allows users to ask follow-up questions after the report is generated.

### Step 1: Add a Chat Block

1.  After the `Generate SEO Report` block, add a **Chat Block**.

### Step 2: Configure the Chat Block

1.  **System Introduction:** Write a welcome message that appears above the chat box. Example:
    > "Your report is ready. You can now ask me follow-up questions about the data. For example, 'Show me the top 10 referring domains' or 'Why was my content score a 6?'"

2.  **Conversation Starters:** Add a few predefined questions to guide the user, such as `"What are my top 5 competitors?"`.

3.  **Continuation Settings:**
    *   **Transition Control:** Set this to `Next Button`.
    *   **Button Label:** `End Chat`.
    *   **Destination Block:** Connect this to a **Terminator Block**.
    *   **History Variable:** `chat_history` (This saves the conversation).

### Step 3: Provide Context with RAG

To make the chat 
"aware" of the report and the raw data, you need to provide it as context.

1.  First, you must modify the `Generate SEO Report` block. Change its **Response Behavior** from `Display to User` to `Assign to Variable` and name the variable `report_content`.
2.  Add a **Display Content** block immediately after the `Generate SEO Report` block to show the `{{report_content}}` to the user.
3.  In the **Chat Block** settings, you will pass the report and the raw data variables in the System Prompt. This gives the chat session the necessary context to answer detailed questions.

    ```text
    You are in Interactive Chat Mode. The user has just received the following SEO report. Your task is to answer their follow-up questions by referencing both the report and the raw API data provided below.

    **Generated Report:**
    {{report_content}}

    **Raw Backlinks Data:**
    {{backlinks_data}}

    **Raw Competitors Data:**
    {{competitors_data}}

    **Raw Ranked Keywords Data:**
    {{ranked_keywords_data}}

    When a user asks a question, use the raw data to provide specific numbers, lists, and tables. Use the report content to explain the reasoning behind the analysis.
    ```

Now, when a user asks a question, the AI will have access to both the formatted report and the raw JSON data, enabling it to provide precise, data-driven answers.

---

## Phase 6: Deployment and Testing

### Step 1: Test Your Workflow

MindStudio's **Testing Suite** is essential for ensuring your app works as expected.

1.  Click the **"Test"** button in the top-right corner of the Automations canvas.
2.  Enter a test URL and select a report type in the input form.
3.  Run the workflow and observe the execution.
4.  **Profiler:** Use the Profiler tab to inspect the inputs and outputs of each individual block. This is critical for debugging API calls and ensuring variables are being passed correctly.
5.  **Debugger:** Use the Debugger to step through the workflow and identify any errors or unexpected behavior.

### Step 2: Publish and Deploy

1.  Once you are satisfied with the testing, click the **"Publish"** button.
2.  Provide a version name (e.g., `v1.0 - Initial SEO Audit`).
3.  Navigate to the **Deployments** tab.
4.  Under **AI-Powered Web App**, click **"Publish"**.
5.  Your app will be assigned a unique URL and is now live for users to access.

---

## Phase 7: Building Additional Report Types

Now that you have the "Comprehensive SEO Audit" working, you can replicate this workflow for the other six report types.

### Workflow for Each Report Type

For each report type, you will:

1.  Add a new branch to the **Logic Block** that checks for the specific `{{REPORT_TYPE}}` value.
2.  Chain together the relevant **HTTP Request** blocks for the DataForSEO endpoints required by that report.
3.  Add a **Generate Text** block with the specific master prompt from the corresponding YAML file.
4.  Connect it to the same **Display Content** and **Chat Block** structure.

### Example: E-E-A-T Content Evaluation

For the "E-E-A-T Content Evaluation" report:

1.  In the Logic Block, add a condition: `{{REPORT_TYPE}} equals "E-E-A-T Content Evaluation"`.
2.  Add HTTP Request blocks for:
    *   **On-Page API:** `https://api.dataforseo.com/v3/on_page/instant_pages`
    *   **Content Analysis API:** `https://api.dataforseo.com/v3/content_analysis/search/live`
    *   **Backlinks Summary:** (reuse the same endpoint as before)
3.  Add a **Generate Text** block with the `Master_Prompt` from `eeat_content_evaluation.yaml`.
4.  Connect to the display and chat blocks.

Repeat this pattern for all seven report types.

---

## Phase 8: Advanced Features and Enhancements

Once your core functionality is working, you can add advanced features to make your app more powerful and user-friendly.

### Feature 1: Export Reports as PDF

MindStudio has a **Generate Asset** block that can create PDFs.

1.  After the **Display Content** block (before the Chat Block), add a **Generate Asset** block.
2.  Configure it to generate a PDF using the `{{report_content}}` variable.
3.  Set the **Output Variable** to `report_pdf`.
4.  Add a button in the Display Content block that allows users to download the `{{report_pdf}}`.

### Feature 2: Save Reports to a Database

To allow users to access their reports later, you can integrate with Airtable or another database.

1.  Add a **Create/Update Airtable Record** block after the report is generated.
2.  Configure it to save the `{{URL}}`, `{{REPORT_TYPE}}`, `{{report_content}}`, and a timestamp to your Airtable base.
3.  Optionally, add a **User Input** block at the start to collect the user's email address, and save that as well for future retrieval.

### Feature 3: Scheduled Monitoring

For recurring reports, you can use MindStudio's **Scheduled Agents** feature.

1.  Navigate to the **Deployments** tab.
2.  Select **"Scheduled AI Agents"**.
3.  Configure the agent to run weekly or monthly.
4.  Set the **Launch Variables** to specific URLs you want to monitor.
5.  Configure the **Terminator Block** to send the report via email using the **Send Email** block.

### Feature 4: Batch Analysis

To analyze multiple URLs at once:

1.  Modify the **User Input** block to accept a **Multi-line Text** input for `URLs` (one URL per line).
2.  Add a **Run Function** block that splits the `{{URLs}}` variable into an array.
3.  Use a **Loop** (via a combination of **Logic Block** and **Jump Block**) to iterate through each URL.
4.  For each URL, run the API calls and generate a mini-report.
5.  Aggregate all mini-reports into a single summary document.

---

## Phase 9: Optimization and Best Practices

### Prompt Engineering

The quality of your reports depends heavily on your prompts. Follow these best practices:

*   **Be Specific:** Instead of "Analyze the backlinks," say "Identify the top 10 referring domains by domain authority and explain their impact on SEO."
*   **Provide Examples:** Show the AI the format you want. For instance, "Present the data in a table with columns: Domain, Authority, Backlinks."
*   **Use Conditional Logic:** Use `{{#if}}` statements in your prompts to handle edge cases, such as when a website has zero backlinks.

### Model Selection

Different AI models excel at different tasks. Consider using:

*   **GPT-4 or Claude Opus** for complex analysis and report generation.
*   **GPT-4 Mini or Claude Haiku** for the chat interface to reduce costs.
*   **Gemini Pro** for tasks that require large context windows (e.g., analyzing very long API responses).

You can configure model selection at the workspace level or override it for individual blocks.

### Error Handling

Add error handling to your HTTP Request blocks:

1.  After each HTTP Request block, add a **Logic Block** to check if the API call was successful.
2.  Use a condition like: `{{backlinks_data.status_code}} equals 200`.
3.  If the call fails, route the workflow to a **Display Content** block that shows an error message to the user, such as "Unable to fetch backlinks data. Please check the URL and try again."

### Cost Management

DataForSEO API calls can be expensive. To manage costs:

*   **Cache Results:** Store API responses in a database (like Airtable) with a timestamp. Before making a new API call, check if you already have recent data for that URL.
*   **Rate Limiting:** Add a **User Input** block that requires users to enter an access code or email address, allowing you to control who can use the app.
*   **Tiered Access:** Offer different report types at different price points. Free users get basic reports, while paid users get comprehensive audits.

---

## Conclusion

You now have a complete, step-by-step guide to building a professional SEO Intelligence Hub in MindStudio. This app leverages the power of DataForSEO's API to provide marketing agencies with actionable insights, and the interactive chat feature sets it apart from static report generators.

The modular design of MindStudio's workflow system makes it easy to expand this app with additional report types, integrations, and features. As you become more comfortable with the platform, you can explore advanced capabilities like custom JavaScript functions, self-hosted AI models, and MCP server integrations.

**Next Steps:**

1.  **Build the MVP:** Start with the Comprehensive SEO Audit and get it working end-to-end.
2.  **Test with Real Data:** Use actual client URLs to validate the accuracy and usefulness of your reports.
3.  **Gather Feedback:** Share the app with colleagues or beta users and iterate based on their input.
4.  **Expand:** Add the remaining six report types and advanced features.
5.  **Monetize:** Once your app is polished, consider deploying it as a paid service for marketing agencies.

MindStudio's visual builder, combined with DataForSEO's comprehensive API, gives you everything you need to create a best-in-class SEO analysis tool. Good luck building!

---

## Appendix: Quick Reference

### Key MindStudio Blocks Used

| Block Name | Purpose | Key Settings |
| :--- | :--- | :--- |
| **User Input** | Collect data from users | Input fields, custom interface |
| **Logic Block** | Conditional branching | If/else conditions based on variables |
| **HTTP Request** | Call external APIs | URL, method, headers, body, output variable |
| **Generate Text** | AI-powered text generation | Prompt, response behavior, output schema, model |
| **Display Content** | Show content to users | Content variable, formatting |
| **Chat Block** | Interactive conversation | System introduction, conversation starters, continuation settings |
| **Generate Asset** | Create PDFs, CSVs, etc. | Content variable, asset type |
| **Terminator** | End the workflow | Email notifications, structured output |

### DataForSEO Endpoints Used

| Endpoint | Purpose | Report Types |
| :--- | :--- | :--- |
| `/v3/backlinks/summary/live` | Get backlink overview | Comprehensive Audit, E-E-A-T, Backlink Profile |
| `/v3/dataforseo_labs/google/competitors_domain/live` | Find competitors | Comprehensive Audit, Competitive Intelligence |
| `/v3/dataforseo_labs/google/ranked_keywords/live` | Get keyword rankings | Comprehensive Audit, Keyword Gap |
| `/v3/on_page/instant_pages` | Analyze on-page SEO | E-E-A-T, Technical Audit |
| `/v3/content_analysis/search/live` | Analyze content quality | E-E-A-T |
| `/v3/serp/google/organic/live` | Get SERP data | Keyword Opportunity, Competitive Intelligence |

### Variable Naming Conventions

*   **User Inputs:** `URL`, `REPORT_TYPE`, `LOCATION_CODE`
*   **API Responses:** `backlinks_data`, `competitors_data`, `ranked_keywords_data`
*   **Generated Content:** `report_content`, `report_pdf`
*   **Chat History:** `chat_history`, `last_message`

---

**Author:** Manus AI  
**Version:** 1.0  
**Last Updated:** February 17, 2026
