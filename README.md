# Call Center Analytics with Snowflake Cortex AISQL

A comprehensive demonstration of Snowflake Cortex AISQL capabilities built for the ficticious Summit Solutions' HR and payroll business use cases. This demo showcases how AI-powered SQL functions can enhance customer support through sentiment analysis, classification, smart filtering, and RAG-powered chatbots.

## 🎯 Overview
This demo illustrates how Summit Solutions can leverage Snowflake's Cortex AISQL suite to:

- Analyze customer sentiment across support calls and cases
- Automatically classify HR/payroll issues for routing and reporting
- Detect compliance risks and escalation needs
- Generate insights from unstructured support data
- Power RAG chatbots with company-specific knowledge

## 📊 Demo Components
### 1. AISQL Functions Demo

- Sentiment Analysis: Track customer satisfaction using SENTIMENT and ENTITY_SENTIMENT
- Classification: Categorize calls/cases with AI_CLASSIFY
- Smart Filtering: Identify escalation needs with AI_FILTER
- Content Generation: Extract insights with AI_COMPLETE
- Similarity Analysis: Connect related interactions with AI_SIMILARITY

### 2. Cortex Search Service

- Knowledge Base: Searchable FAQ content for HR/payroll topics
- Semantic Search: Natural language queries across company documentation
- RAG Integration: Powers intelligent chatbot responses

### 3. Streamlit Chatbot

- Interactive Interface: Professional chat experience for employees
- Real-time Search: Instant FAQ lookups using Cortex Search
- AI-Generated Responses: Contextual answers using company knowledge
- Source Attribution: Shows which FAQs were used for transparency



## 🚀 Quick Start

### 1. Run the Demo Scripts
Execute the SQL scripts in order:

- **ai_sql_demo.sql** - Creates tables and inserts realistic Summit Solutions data + processes transcripts and support cases via AI SQL functions
- **cortex_search_demo.sql** - Creates FAQ knowledge base and search service

### 2. Deploy Streamlit App

- In Snowsight: Projects → Streamlit
- Create new app in the **demo_db.summitsolutions** schema
- Add packages referenced in the **environment_summitsolutions.yml**
- Copy code from **streamlit_app.py**
- Run the app


## 💼 Business Use Cases
### Customer Support Enhancement

- Sentiment Tracking: Monitor satisfaction trends across payroll/benefits calls
- Auto-Classification: Route tickets to appropriate teams (Tax, Benefits, Payroll)
- Escalation Detection: Identify complex compliance issues early
- Response Quality: Generate consistent, accurate responses using company knowledge

### Operational Insights

- Training Identification: Find knowledge gaps in support staff
- Client Experience: Aggregate insights across all customer touchpoints
- Compliance Monitoring: Detect potential legal/regulatory risks
- Performance Analytics: Track resolution times and customer satisfaction

### Self-Service Support

- 24/7 FAQ Assistant: Instant answers to common HR/payroll questions
- Intelligent Search: Natural language queries across company documentation
- Consistent Information: All responses based on official company policies
- Reduced Ticket Volume: Deflect routine inquiries with self-service options
