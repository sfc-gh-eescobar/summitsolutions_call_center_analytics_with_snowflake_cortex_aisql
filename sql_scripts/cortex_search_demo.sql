-- =======================================================================================
--      Part 2: Build a Cortex Search service for a Streamlit in Snowflake FAQ Chatbot
-- =======================================================================================


USE ROLE ACCOUNTADMIN;

-- =====================================================
-- WAREHOUSE SETUP (Run this first if needed)
-- =====================================================


CREATE OR REPLACE WAREHOUSE cortex_search_wh WITH
    WAREHOUSE_SIZE='X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;


-- =====================================================
-- CORTEX SEARCH SERVICE FOR FAQ CONTENT
-- =====================================================

-- Step 1: Create FAQ Content Table
-- =====================================================
-- First, let's create a proper FAQ table by aggregating support case insights

USE SCHEMA DEMO_DB.SUMMITSOLUTIONS;

CREATE OR REPLACE TABLE faq_content (
    faq_id VARCHAR(50) PRIMARY KEY,
    case_type VARCHAR(50),
    question TEXT,
    answer TEXT,
    category VARCHAR(50),
    priority VARCHAR(20),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Populate FAQ Content
-- =====================================================
-- Insert realistic FAQ content based on our support cases

INSERT INTO faq_content VALUES
('FAQ_001', 'Payroll_Issue', 'Why is my overtime pay missing from my paycheck?', 
'Overtime pay requires manager approval in our system before it appears on your paycheck. If you worked overtime, make sure your manager has approved those hours in the timesheet system. Once approved, we can process a payroll adjustment and you''ll receive the overtime pay by end of business day. Contact support with your employee ID and the specific dates you worked overtime for immediate assistance.', 
'Payroll', 'High', '2024-01-25 10:00:00'),

('FAQ_002', 'Benefits_Question', 'How do I enroll in health insurance as a new employee?', 
'New employees have 30 days from their start date to enroll in benefits. Log into your employee portal and click "Benefits Enrollment." You''ll see three plan options: Bronze (lower premium, higher deductible), Silver (balanced option), and Gold (higher premium, lower deductible). Your employer typically covers 70-80% of the premium cost. You can also add dental and vision coverage. If you need help choosing, contact our benefits team for a personalized consultation.', 
'Benefits', 'Medium', '2024-01-25 10:30:00'),

('FAQ_003', 'Tax_Compliance', 'How do I update my tax withholdings after getting married?', 
'Log into your employee portal and go to "My Profile" > "Tax Information." Click "Edit" next to your W-4 settings and change your filing status to "Married Filing Jointly." Consider keeping the same number of allowances initially, as both spouses working may require similar withholding. Changes take effect with your next paycheck. You can adjust throughout the year if needed. Contact payroll support if you need guidance on allowance calculations.', 
'Payroll', 'Medium', '2024-01-25 11:00:00'),

('FAQ_004', 'Workers_Comp', 'What should I do if I''m injured at work?', 
'Report any work injury immediately to your supervisor and HR department. Seek medical attention if needed - your safety is the priority. Your company will file a workers compensation claim through Summit Solutions within 24 hours. You''ll receive information about approved medical providers and how to submit medical bills. Workers comp covers medical expenses and may provide wage replacement benefits. A Summit Solutions specialist will guide you through the entire process and ensure you receive proper care.', 
'Compliance', 'Critical', '2024-01-25 11:30:00'),

('FAQ_005', 'Payroll_Issue', 'Why are my state taxes wrong for remote work?', 
'State tax withholding is based on where you physically work, not where your company is located. Update your work location in your employee portal under "Personal Information." If you work in multiple states, contact payroll support as this requires special handling. Our system automatically calculates the correct state taxes once your location is updated. For states with no income tax (like Texas or Florida), no state income tax will be withheld. Changes take effect with the next payroll cycle.', 
'Payroll', 'High', '2024-01-25 12:00:00'),

('FAQ_006', 'Benefits_Question', 'Can I add my newborn to my health insurance?', 
'Yes! Having a baby is a qualifying life event that gives you 30 days to add your child to your health plan. Contact benefits support immediately to add your newborn - coverage will be retroactive to their birth date. You''ll need to provide the baby''s name, date of birth, and Social Security number (when available). Your premium will increase to family coverage, and all pediatric care including well-child visits and vaccinations are covered under your plan.', 
'Benefits', 'High', '2024-01-25 12:30:00'),

('FAQ_007', 'HR_Policy', 'How much paid sick leave do I get?', 
'Paid sick leave varies by state law and company policy. Most states require minimum accrual rates (typically 1 hour per 30-40 hours worked). Check your employee handbook or portal for your specific accrual rate and current balance. Sick leave can typically be used for your own illness, family member care, or medical appointments. Some states allow use for domestic violence situations. Contact HR if you have questions about your sick leave balance or usage policies.', 
'HR Policy', 'Medium', '2024-01-25 13:00:00'),

('FAQ_008', 'Benefits_Question', 'What happens to my health insurance if I leave the company?', 
'You''re eligible for COBRA continuation coverage, which allows you to keep your current health plan for up to 18 months (sometimes longer). You''ll pay the full premium cost (about 102% of the total premium). Summit Solutions automatically sends COBRA election materials within 14 days of your termination. You have 60 days to elect COBRA coverage. Alternatively, you can explore marketplace plans or coverage through a new employer. Contact benefits support to discuss your options.', 
'Benefits', 'Medium', '2024-01-25 13:30:00');

-- Step 3: Enable Change Tracking (Required for Cortex Search)
-- =====================================================
ALTER TABLE faq_content
SET CHANGE_TRACKING = TRUE;

select * from faq_content;
-- Step 4: Create Cortex Search Service
-- =====================================================
-- Create a search service over the FAQ content for natural language queries

CREATE OR REPLACE CORTEX SEARCH SERVICE summitsolutions_faq_search
  ON search_content  -- Reference the aliased column name
  ATTRIBUTES case_type, category, priority, question, answer
  WAREHOUSE = cortex_search_wh
  TARGET_LAG = '1 hour'
  EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
  AS (
    SELECT
        faq_id,
        CONCAT(question, ' ', answer) as search_content,
        question,
        answer,
        case_type,
        category,
        priority,
        created_date
    FROM faq_content
);

-- Step 5: Query the Search Service using SQL
-- =====================================================
-- Example 1: Basic search for payroll questions

SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'summitsolutions_faq_search',
      '{
         "query": "overtime pay missing paycheck",
         "columns": [
            "question",
            "answer",
            "category"
         ],
         "limit": 3
      }'
  )
)['results'] as search_results;

-- Example 2: Search with filters for benefits questions only

SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'summitsolutions_faq_search',
      '{
         "query": "health insurance enrollment",
         "columns": [
            "question", 
            "answer",
            "case_type",
            "priority"
         ],
         "filter": {"@eq": {"category": "Benefits"}},
         "limit": 5
      }'
  )
)['results'] as benefits_results;

-- Example 3: Search for tax-related questions

SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'summitsolutions_faq_search',
      '{
         "query": "tax withholding remote work state taxes",
         "columns": [
            "question",
            "answer",
            "case_type"
         ],
         "filter": {"@eq": {"case_type": "Tax_Compliance"}},
         "limit": 2
      }'
  )
)['results'] as tax_results;


-- Example 4: Comprehensive search across all content

SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'summitsolutions_faq_search',
      '{
         "query": "new employee benefits enrollment health insurance",
         "columns": [
            "faq_id",
            "question",
            "answer",
            "category",
            "priority"
         ],
         "limit": 5
      }'
  )
)['results'] as comprehensive_results;

-- =====================================================
-- ADVANCED RAG EXAMPLE - Combine Search + AI_COMPLETE
-- =====================================================

-- Step 5: Create a RAG-powered FAQ Assistant
-- Use Cortex Search to find relevant content, then AI_COMPLETE to generate personalized responses

WITH search_results AS (
  SELECT PARSE_JSON(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'summitsolutions_faq_search',
        '{
           "query": "payroll problem overtime not paid",
           "columns": [
              "question",
              "answer"
           ],
           "limit": 3
        }'
    )
  )['results'] as results
),
context_data AS (
  SELECT LISTAGG(
    'Q: ' || f.value:question::STRING || 
    ' A: ' || f.value:answer::STRING, 
    '\n\n'
  ) WITHIN GROUP (ORDER BY f.value:question::STRING) as context
  FROM search_results,
  LATERAL FLATTEN(input => search_results.results) AS f
)
SELECT 
  AI_COMPLETE(
    'claude-3-5-sonnet',
    'Based on the following Summit Solutions FAQ content, provide a helpful and personalized response to this employee question: "I worked 12 hours of overtime last week but I don''t see it on my paycheck. What should I do?"

FAQ Context:
' || context || '

Please provide a clear, step-by-step response that helps the employee resolve their issue.'
  ) as personalized_response
FROM context_data;
