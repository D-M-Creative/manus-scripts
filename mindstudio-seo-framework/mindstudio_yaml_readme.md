# MindStudio-Specific YAML Prompts

This document explains the structure and usage of the rewritten YAML prompt files, which are now specifically designed to work within the MindStudio ecosystem.

## Key Changes

The original YAML files were designed for a generic AI agent and made assumptions about the AI being able to call APIs directly. The new versions are tailored for MindStudio's workflow, where data is first fetched via **HTTP Request** blocks and then passed into a **Generate Text** block as variables.

1.  **Variable-Driven Prompts:** The prompts no longer instruct the AI to call APIs. Instead, they expect the API data to be provided in pre-defined variables (e.g., `{{backlinks_data}}`, `{{competitors_data}}`).

2.  **Direct Data Access:** The prompts now include specific dot-notation paths to access the exact data points needed from the JSON responses stored in those variables. For example, instead of asking the AI to "find the domain rank," the prompt directly references `{{backlinks_data.tasks[0].result[0].summary.rank}}`.

3.  **Separation of Concerns:**
    *   The **`Master_Prompt`** is designed to be used in the main **Generate Text** block that creates the final report.
    *   The **`Chat_Mode_Prompt`** is designed to be used in the **System Prompt** of the subsequent **Chat Block**, providing it with the necessary context (both the generated report and the raw data) for interactive Q&A.

4.  **Removed Redundant Prompts:** The individual `_Reasoning` and `_Score` prompts have been consolidated into the single `Master_Prompt`. In MindStudio, it is more efficient to generate the entire report in one pass rather than chaining multiple AI calls for each section.

## How to Use in MindStudio

1.  **Fetch Data:** In your MindStudio workflow, use **HTTP Request** blocks to call the necessary DataForSEO APIs. Save the full JSON response of each call to the corresponding variable name (e.g., save the output of the Backlinks Summary API to `backlinks_data`).

2.  **Generate Report:**
    *   Add a **Generate Text** block after your API calls.
    *   Copy the entire `Master_Prompt` from the relevant YAML file (e.g., `mindstudio_comprehensive_seo_audit.yaml`) and paste it into the prompt field of this block.
    *   Set the **Response Behavior** to `Assign to Variable` and name the variable `report_content`.

3.  **Display Report:**
    *   Add a **Display Content** block after the Generate Text block.
    *   Set the content to `{{report_content}}` to show the generated report to the user.

4.  **Enable Chat Mode:**
    *   Add a **Chat Block** after the Display Content block.
    *   Copy the `Chat_Mode_Prompt` from the YAML file and paste it into the **System Prompt** field of the Chat Block.
    *   This gives the chat session the context of both the report and the raw data, allowing it to answer detailed follow-up questions.

## Example Workflow

Your MindStudio workflow for the Comprehensive SEO Audit should look like this:

1.  **Start Block**
2.  **User Input Block** (Collects `{{URL}}`)
3.  **HTTP Request Block** (`Get Backlinks`) -> saves to `backlinks_data`
4.  **HTTP Request Block** (`Get Competitors`) -> saves to `competitors_data`
5.  **HTTP Request Block** (`Get Ranked Keywords`) -> saves to `ranked_keywords_data`
6.  **Generate Text Block** (uses `Master_Prompt`) -> saves to `report_content`
7.  **Display Content Block** (displays `{{report_content}}`)
8.  **Chat Block** (uses `Chat_Mode_Prompt` in its System Prompt)
9.  **Terminator Block**

By following this structure, you align the powerful, detailed prompts with MindStudio's native workflow capabilities, creating a robust and data-aware AI application.
