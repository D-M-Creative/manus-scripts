# MindStudio SEO Agency App Framework

This repository contains the framework and configuration files for building a powerful SEO agency application in MindStudio, leveraging the DataForSEO API.

## Overview

The goal of this project is to create a MindStudio app that allows marketing agencies to generate professional SEO reports for their clients. The app will take a URL as input, allow the user to select from various report types, generate a comprehensive analysis, and then provide an interactive chat interface for drilling down into the data.

## Key Features

*   **Multiple Report Types:** Generate different types of SEO reports, including a comprehensive audit, E-E-A-T analysis, competitor analysis, and more.
*   **DataForSEO Integration:** Leverages the powerful DataForSEO API for in-depth and accurate data.
*   **Interactive Chat:** After a report is generated, users can chat with the AI to ask follow-up questions, request more details, and explore the data conversationally.
*   **Scoring and Recommendations:** Reports include quantitative scores for key SEO areas and actionable recommendations for improvement.
*   **Modular and Expandable:** The framework is designed to be easily expanded with new report types, data sources, and features.

## Files Included

*   `mindstudio_seo_app_architecture.md`: This document provides a detailed overview of the app's architecture, user flow, MindStudio implementation strategy, and future roadmap.
*   `comprehensive_seo_audit.yaml`: The expanded MindStudio prompt configuration for the "Comprehensive SEO Audit" report. This includes the master prompt and the chat mode prompt.
*   `eeat_content_evaluation.yaml`: The expanded MindStudio prompt configuration for the "E-E-A-T Content Evaluation" report.

## How to Use

1.  **Review the Architecture:** Start by reading the `mindstudio_seo_app_architecture.md` file to understand the overall design and concept of the application.
2.  **Import into MindStudio:** These YAML files can be used as a basis for creating your MindStudio application. You will need to create a new MindStudio app and then use the content of these files to configure your prompts and workflows.
3.  **Set up DataForSEO:** Ensure you have a DataForSEO account and that you have configured your API credentials as environment variables, as described in the `dataforseo` skill documentation.
4.  **Implement the Workflows:** In MindStudio, you will need to build out the automation workflows described in the architecture document. This will involve making HTTP requests to the DataForSEO API and parsing the responses.
5.  **Customize and Expand:** Use this framework as a starting point. You can customize the prompts, add new report types, and integrate other data sources to create a unique and powerful tool for your agency.

## Next Steps

*   **Build the MVP:** Start by implementing the "Comprehensive SEO Audit" as the minimum viable product.
*   **Develop the Chat Interface:** The interactive chat mode is a key feature. Focus on creating a seamless experience for data exploration.
*   **Expand Report Types:** Gradually add the other report types outlined in the architecture document.
*   **White-Labeling:** Implement white-labeling features to allow agencies to brand the reports with their own logos and colors.
