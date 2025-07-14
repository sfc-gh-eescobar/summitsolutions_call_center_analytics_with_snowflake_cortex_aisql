-- =====================================================
--    Part 1: Processing Call Transcripts with AI SQL
-- =====================================================

USE ROLE ACCOUNTADMIN;

CREATE DATABASE DEMO_DB;
CREATE SCHEMA DEMO_DB.SUMMITSOLUTIONS;

-- =====================================================
-- Snowflake Cortex AISQL Demo: HR & Payroll Support
-- =====================================================

-- 1. CREATE TABLES
-- =====================================================

-- Create call transcripts table for HR/Payroll support calls
CREATE OR REPLACE TABLE call_transcripts (
    call_id VARCHAR(50) PRIMARY KEY,
    client_company_id VARCHAR(50),
    employee_id VARCHAR(50), -- Employee calling from client company
    summitsolutions_agent_id VARCHAR(50),
    call_date TIMESTAMP,
    call_duration_minutes INTEGER,
    call_type VARCHAR(50), -- 'Payroll', 'Benefits', 'HR_Compliance', 'Onboarding', 'General'
    client_tier VARCHAR(20), -- 'Startup', 'Growth', 'Enterprise'
    transcript_text TEXT,
    outcome VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create support cases table for HR/Payroll tickets
CREATE OR REPLACE TABLE support_cases (
    case_id VARCHAR(50) PRIMARY KEY,
    client_company_id VARCHAR(50),
    reporter_email VARCHAR(100), -- Could be HR admin or employee
    summitsolutions_agent_id VARCHAR(50),
    created_date TIMESTAMP,
    case_type VARCHAR(50), -- 'Payroll_Issue', 'Benefits_Question', 'Tax_Compliance', 'Workers_Comp', 'HR_Policy'
    priority VARCHAR(20), -- 'Critical', 'High', 'Medium', 'Low'
    status VARCHAR(30), -- 'Open', 'In_Progress', 'Resolved', 'Closed'
    subject VARCHAR(200),
    description TEXT,
    resolution_notes TEXT,
    resolved_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. INSERT SAMPLE DATA - SUMMITSOLUTIONS SPECIFIC
-- =====================================================

-- Insert realistic Summit Solutions call transcripts
INSERT INTO call_transcripts VALUES
('CALL_001', 'COMP_001', 'EMP_001', 'JW_AGT_001', '2024-01-15 10:30:00', 25, 'Payroll', 'Growth', 
'Agent: Hello, this is Sarah from Summit Solutions support. How can I help you today? Employee: Hi Sarah, I''m calling about my paycheck. I worked 15 hours of overtime last week but I only see my regular 40 hours on my pay stub. I''m really frustrated because I need that overtime money for my rent. Agent: I understand your frustration, let me look into this right away. Can you provide me with your employee ID and the specific dates you worked overtime? Employee: Sure, my ID is EMP_001 and I worked overtime Monday through Wednesday last week, about 5 hours each day. Agent: I''m pulling up your timesheet now. I can see the overtime hours were logged correctly, but it looks like your manager hasn''t approved them in our system yet. That''s why they didn''t appear on your paycheck. Employee: That''s ridiculous! I told my manager about the overtime when I worked it. Why wasn''t it approved? Agent: I understand your frustration. Let me reach out to your manager right now to get this approved. Can you hold for just a moment? Employee: Okay, but I really need this resolved today. Agent: I just spoke with your manager and they''ve approved all 15 hours of overtime. I''m processing a payroll adjustment right now, and you''ll see the overtime pay in your account by end of business today. Employee: Oh wow, thank you so much! I had no idea there was an approval process. Agent: No problem at all. I''m also sending you a quick guide about how overtime approval works so you know for next time. Is there anything else I can help you with today? Employee: No, that''s perfect. Thank you for resolving this so quickly, Sarah!', 
'Resolved', '2024-01-15 10:30:00'),

('CALL_002', 'COMP_002', 'EMP_002', 'JW_AGT_002', '2024-01-16 14:20:00', 18, 'Benefits', 'Startup', 
'Agent: Hi there, this is Mike from Summit Solutions. How can I assist you today? Employee: Hi Mike, I just started at my company last week and I need to enroll in health insurance. I''m totally confused by all the different plans and options. Agent: Congratulations on your new job! I''d be happy to walk you through the health insurance options. Are you looking at the plans in your employee portal right now? Employee: Yes, I see there are three different plans but I don''t understand the difference between them. The numbers are confusing. Agent: Let me break this down for you. The Bronze plan has lower monthly premiums but higher deductibles, meaning you pay less each month but more when you actually use healthcare. The Gold plan is the opposite - higher monthly cost but lower out-of-pocket expenses. Employee: Okay, that makes sense. What about the Silver plan? Agent: The Silver plan is right in the middle - moderate monthly premiums and moderate deductibles. It''s our most popular choice. Can you tell me about your typical healthcare usage? Employee: I''m pretty healthy, maybe see a doctor once or twice a year. But I want to make sure I''m covered if something unexpected happens. Agent: Based on what you''re telling me, the Silver plan might be perfect for you. Your employer covers 80% of the premium, so you''d pay about $95 per month. The deductible is $1,500 and then insurance covers 80% after that. Employee: That sounds reasonable. How do I enroll? Agent: I can help you enroll right now. I''ll walk you through each step in the portal. You''ll also want to consider adding dental and vision coverage - those are really affordable add-ons. Employee: Yes, let''s do that too. This is so much easier than I expected! Agent: Great! I''m glad I could help make this process smooth for you. Summit Solutions is designed to make benefits simple.', 
'Resolved', '2024-01-16 14:20:00'),

('CALL_003', 'COMP_003', 'EMP_003', 'JW_AGT_001', '2024-01-17 09:15:00', 35, 'HR_Compliance', 'Enterprise', 
'Agent: Good morning, this is Sarah from Summit Solutions. How can I help you today? Employee: Hi Sarah, this is Jennifer from ABC Company. I''m the HR manager and we have a situation. One of our employees was injured yesterday and I''ve never dealt with a workers compensation claim before. I''m honestly pretty panicked about this. Agent: I understand this can be overwhelming, but you''ve called the right place. Summit Solutions handles all workers comp claims, so you don''t have to navigate this alone. Can you tell me what happened? Employee: One of our warehouse workers slipped and fell while moving boxes. He hurt his back and had to go to the emergency room. The doctor said he might need physical therapy. Agent: First, I hope your employee is okay. The good news is that as a Summit Solutions client, you''re fully covered for workers comp. I need to walk you through the reporting process step by step. Do you have a few minutes? Employee: Yes, absolutely. I want to make sure we do everything correctly. Agent: Perfect. First, I need you to complete an incident report in your Summit Solutions dashboard. I''ll stay on the line and guide you through it. Then we''ll need to file the official claim with the state and insurance carrier. Employee: Okay, I''m logging into the dashboard now. I see the incident report section. What information do I need? Agent: You''ll need the employee''s basic info, the exact date and time of the incident, a detailed description of what happened, and any witness information. Also, do you have the hospital or doctor''s information where he was treated? Employee: Yes, I have all of that. Let me fill this out... Okay, I''ve completed the incident report. What''s next? Agent: Great job. Now I''m going to connect you with our workers comp specialist, Maria. She''ll handle the claim filing and coordinate with the insurance carrier. She''ll also work directly with your employee to make sure he gets the care he needs. Employee: This is such a relief. I was so worried about doing something wrong and getting the company in trouble. Agent: That''s exactly why you have Summit Solutions. We handle all the compliance and legal requirements so you can focus on supporting your employee. Maria will call you within the next hour. Employee: Thank you so much, Sarah. I feel so much better knowing we have expert support.', 
'Escalated_to_Specialist', '2024-01-17 09:15:00'),

('CALL_004', 'COMP_004', 'EMP_004', 'JW_AGT_003', '2024-01-18 16:45:00', 12, 'Payroll', 'Growth', 
'Agent: Hello, this is David from Summit Solutions payroll support. How can I help you today? Employee: Hi David, I just got married last month and I need to update my tax withholdings. I think I should be withholding less now that I''m married. Agent: Congratulations on your marriage! You''re absolutely right that getting married can change your tax situation. Are you looking to change from single to married filing jointly? Employee: Yes, exactly. My wife and I both work, but we want to file jointly. How do I update this in the system? Agent: I can walk you through this right now. Are you able to log into your employee portal? Employee: Yes, I''m logged in now. Agent: Perfect. Click on the "My Profile" tab, then select "Tax Information." You should see your current W-4 settings there. Employee: Okay, I see it. It currently shows "Single" under filing status. Agent: Great. Click "Edit" next to the tax information section. You''ll be able to change your filing status to "Married Filing Jointly" and adjust your withholding allowances. Employee: I changed it to married, but I''m not sure about the allowances. Should I change that too? Agent: That depends on your combined income. Since you both work, you might want to keep the same number of allowances or even increase withholding slightly to avoid owing taxes. The system will calculate the new withholding amounts automatically. Employee: Okay, I''ll keep the allowances the same for now. When will this take effect? Agent: The changes will take effect with your next paycheck, which should be next Friday. You''ll see the updated withholding amounts on your pay stub. Employee: Perfect, thank you so much for walking me through this, David!', 
'Resolved', '2024-01-18 16:45:00'),

('CALL_005', 'COMP_005', 'EMP_005', 'JW_AGT_002', '2024-01-19 11:30:00', 28, 'Benefits', 'Startup', 
'Agent: Hi there, this is Mike from Summit Solutions benefits team. How can I help you today? Employee: Hi Mike, I just had a baby three days ago and I need to add her to my health insurance plan. I''m not sure how to do this or if I missed any deadlines. Agent: Congratulations on your new baby! That''s wonderful news. You definitely haven''t missed any deadlines. Having a baby is what we call a "qualifying life event" which gives you 30 days to make changes to your benefits. Employee: Oh good, I was worried I was too late. So I have 30 days from when she was born? Agent: Exactly, and since she was born three days ago, you have plenty of time. The great news is that once I help you add her to your plan, her coverage will be effective from her birth date, so she''s covered retroactively. Employee: That''s such a relief. How do I add her to my plan? Agent: I can help you do this right now over the phone, or I can walk you through doing it in your employee portal. Which would you prefer? Employee: Let''s do it over the phone. I''m pretty exhausted from having a newborn and could use the help. Agent: Of course! New parent life is exhausting. I just need some basic information about your daughter. What''s her full name and date of birth? Employee: Her name is Emma Marie Johnson, born January 16th, 2024. Agent: Beautiful name! I''m adding her to your current health plan now. You''re on the Silver plan, correct? This will increase your monthly premium from $95 to $285 for employee plus child coverage. Employee: Yes, that''s fine. Will she be covered for her pediatric appointments? Agent: Absolutely. The Silver plan includes full pediatric coverage including well-child visits, vaccinations, and any sick visits. Your pediatrician visits will just be your normal copay. Employee: This is amazing. I was so stressed about figuring out insurance for her. Agent: I''m so glad I could help! Being a new parent is hard enough without worrying about insurance. Is there anything else I can help you with today? Employee: No, you''ve been incredible. Thank you so much for making this so easy, Mike!', 
'Resolved', '2024-01-19 11:30:00'),

('CALL_006', 'COMP_006', 'EMP_006', 'JW_AGT_001', '2024-01-20 13:20:00', 22, 'General', 'Enterprise', 
'Agent: Good afternoon, this is Sarah from Summit Solutions. How can I help you today? Employee: Hi Sarah, this is Tom Wilson, HR Director at TechCorp. We''re about to onboard 25 new employees next week and I want to make sure we handle this efficiently. This is the largest group we''ve ever hired at once. Agent: That''s exciting growth for your company! I''d be happy to help you plan for a smooth mass onboarding. Have you used our bulk onboarding tools before? Employee: No, we''ve always hired people one at a time. I''m honestly not sure where to start with 25 people. Agent: No problem at all. Let me walk you through our mass onboarding process. First, you''ll want to use our bulk employee upload feature. You can upload all their basic information at once using our Excel template. Employee: That sounds much better than entering everyone individually. What information do I need from each person? Agent: You''ll need their personal details, salary information, start date, department, and manager. I can send you the template right after this call. Once you upload that, the system will automatically generate onboarding packets for each employee. Employee: What about benefits enrollment? That''s what I''m most worried about. Agent: Great question. Each new hire will receive a personalized benefits enrollment link via email. They can complete their enrollment online before their first day. We also recommend scheduling group benefits meetings for the first week. Employee: Can someone from Summit Solutions come present the benefits options to the group? Agent: Absolutely! I can schedule our benefits specialist to do a virtual presentation during their first week. It''s much more efficient than individual calls. Employee: That would be perfect. What about getting them all set up in payroll? Agent: Once you upload their information, they''ll automatically be added to your payroll cycle. Just make sure their start dates align with your payroll periods. I can also schedule a dedicated onboarding session where I''ll walk you through the entire process step-by-step. Employee: Yes, let''s schedule that. I want to make sure we don''t miss anything. Agent: Perfect. I have availability tomorrow at 2 PM or Wednesday at 10 AM. Which works better for you? Employee: Wednesday at 10 AM would be great. Thank you so much, Sarah. I feel much more confident about this now.', 
'Follow_up_Scheduled', '2024-01-20 13:20:00'),

('CALL_007', 'COMP_007', 'EMP_007', 'JW_AGT_003', '2024-01-21 10:15:00', 40, 'Payroll', 'Growth', 
'Agent: Good morning, this is David from Summit Solutions payroll support. How can I help you today? Employee: Hi David, this is Lisa Chen. I''m the payroll administrator at GrowthTech. I''m having issues with state tax calculations for our remote employees. We have people working in different states and I''m getting confused about the tax requirements. Agent: Multi-state payroll can definitely be complex, but you''ve called the right place. Summit Solutions handles all the state tax compliance automatically. Can you tell me which states you''re dealing with? Employee: We have employees in California, Texas, New York, and Florida. Some of them moved during the pandemic and I''m not sure if we''re withholding the right taxes. Agent: Let me explain how this works. When an employee works remotely from a different state than your company location, they typically pay income tax to the state where they''re physically working, not where your company is based. Employee: Okay, but how do I know which state to withhold for? And what about states with no income tax? Agent: Great questions. In our system, each employee can update their work location in their profile. The system then automatically calculates the correct state withholding based on where they''re actually working. For states like Texas and Florida with no income tax, we don''t withhold state income tax. Employee: What about employees who travel between states for work? Agent: That''s where it gets tricky. Generally, if someone works in multiple states during the year, they might need to file returns in each state. But for payroll purposes, we typically withhold based on their primary work location. Employee: This is so complicated. What if I''ve been doing it wrong? Are we going to get in trouble? Agent: Don''t worry, Lisa. First, let me check your current setup. I''m looking at your payroll now and it appears most of your employees have the correct state withholding. There are a few that might need adjustments. Employee: Can you help me fix those? Agent: Absolutely. I see three employees that need address updates. I can walk you through updating their profiles right now, and the correct withholding will start with the next payroll. Employee: What about the payments we already made with wrong withholding? Agent: For any corrections needed, we can process adjustments in the next payroll cycle. The system will calculate the difference and adjust accordingly. Most importantly, Summit Solutions files all the required state tax returns, so you don''t have to worry about compliance. Employee: That''s such a relief. I was losing sleep over this. Agent: I completely understand. Multi-state payroll is one of the most complex parts of HR, but that''s exactly why companies use Summit Solutions. We handle all the compliance requirements so you don''t have to become an expert in tax law for every state. Employee: Thank you so much, David. Can you send me some documentation about how multi-state payroll works? Agent: Of course! I''ll send you our multi-state payroll guide and a checklist for managing remote employees. Is there anything else I can help clarify today?', 
'Resolved', '2024-01-21 10:15:00'),

('CALL_008', 'COMP_008', 'EMP_008', 'JW_AGT_002', '2024-01-22 15:30:00', 15, 'Benefits', 'Startup', 
'Agent: Hi there, this is Mike from Summit Solutions benefits support. How can I help you today? Employee: Hi Mike, I''m really frustrated. I got a letter saying my medical claim was denied, but I thought this procedure was covered by my insurance. Agent: I''m sorry to hear about the denied claim. I''d be happy to help you figure out what happened. Can you tell me what type of procedure it was? Employee: It was an MRI for my back pain. My doctor said I needed it, but the insurance company says it wasn''t pre-authorized. Agent: I see what happened. Let me look at your benefits summary. You''re on our Silver plan, which does cover MRIs, but they require pre-authorization for advanced imaging procedures. Employee: Nobody told me I needed pre-authorization! My doctor just scheduled it and I went. Agent: I understand your frustration. Pre-authorization requirements can be confusing. Let me check when you had the MRI and see what we can do to help. Employee: It was last Friday, January 19th. The bill is for $1,200 and I can''t afford to pay that. Agent: Don''t panic yet. Even though it wasn''t pre-authorized, you still have options. You can file an appeal with the insurance company explaining that it was medically necessary. Employee: How do I do that? This is all so confusing. Agent: I can help you with the appeal process. I''ll need you to get a letter from your doctor explaining why the MRI was medically necessary and why it couldn''t wait for pre-authorization. Employee: My doctor will do that. Then what? Agent: Then you''ll submit the appeal along with the doctor''s letter. I''ll email you the appeal form and walk you through filling it out. The insurance company has 30 days to review appeals. Employee: What if they still deny it? Agent: If the appeal is denied, there''s a second level of appeal. But in my experience, when doctors provide good medical justification, most appeals for necessary procedures get approved. Employee: Okay, that makes me feel better. Can you also connect me with the insurance company to start this process? Agent: Absolutely. I''ll send you the appeal form and the insurance company''s direct number. I''ll also make a note in your file so if you need to call back, we have all the details.', 
'Resolved', '2024-01-22 15:30:00');

-- Insert a call transcript about a specific payroll tax issue ** for AI_SIMILARITY
INSERT INTO call_transcripts VALUES
('CALL_999', 'COMP_999', 'EMP_999', 'JW_AGT_999', '2024-01-25 14:30:00', 20, 'Payroll', 'Growth', 
'Agent: Hello, this is Maria from Summit Solutions payroll support. How can I help you today? Employee: Hi Maria, I''m calling about a serious payroll tax issue. Our company just received a notice from the California Employment Development Department saying we owe $15,000 in unpaid state disability insurance contributions for Q4 2023. We thought Summit Solutions was handling all our California payroll taxes automatically. Agent: I understand your concern about the EDD notice. Let me look into your California SDI contributions immediately. Can you provide me with the notice number? Employee: Yes, the notice number is EDD-2024-0158. It shows we have unpaid SDI contributions for October, November, and December 2023. Agent: I''m pulling up your payroll records for Q4 2023 right now. I can see that your employees were correctly classified as California workers, and SDI was being deducted from their paychecks. Let me check our remittance records to the state. Employee: This is really stressing me out. We''re a small company and $15,000 is a lot of money for us. Agent: I completely understand your stress. Looking at our records, I can see there was a technical issue with our California tax filing system in Q4 2023 that affected a small number of clients. The SDI deductions were collected but not properly remitted to the EDD. Employee: So Summit Solutions made an error? What are you going to do to fix this? Agent: Yes, this was our error, and we take full responsibility. I''m immediately escalating this to our tax compliance team. Summit Solutions will pay the full $15,000 penalty and any associated interest charges. You won''t owe anything. Employee: That''s a relief. How long will this take to resolve? Agent: Our tax team will contact the EDD directly within 24 hours and handle all communications. We''ll also send you a written confirmation that we''re taking care of this. This should be completely resolved within 5 business days. Employee: Thank you so much, Maria. I was really worried we''d have to pay this ourselves.', 
'Resolved', '2024-01-25 14:30:00');


-- Insert realistic Summit Solutions support cases
INSERT INTO support_cases VALUES
('CASE_001', 'COMP_001', 'hr@techstartup.com', 'JW_AGT_001', '2024-01-15 09:00:00', 'Payroll_Issue', 'High', 'Resolved', 
'Payroll processing delayed - urgent', 
'Our payroll was supposed to process yesterday but employees have not received their paychecks. This is causing significant concern among our team. We need immediate assistance to resolve this issue as we have contractual obligations to pay employees on time.', 
'Issue was caused by missing bank account verification. Agent expedited the verification process and processed payroll same day. Client was notified of successful processing and all employees received pay within 2 hours.', 
'2024-01-15 14:30:00', '2024-01-15 09:00:00'),

('CASE_002', 'COMP_002', 'benefits@growthco.com', 'JW_AGT_002', '2024-01-16 08:30:00', 'Benefits_Question', 'Medium', 'Resolved', 
'Multiple employees asking about HSA contribution limits', 
'We have several employees who want to maximize their HSA contributions for 2024. They are asking about the contribution limits and whether they can make changes mid-year. Some are also confused about the difference between HSA and FSA accounts. Can you provide clarification on the current limits and rules?', 
'Provided detailed explanation of 2024 HSA contribution limits ($4,150 individual, $8,300 family, $1,000 additional catch-up for 55+). Explained that contributions can be changed anytime during the year. Sent comprehensive HSA vs FSA comparison guide to HR team.', 
'2024-01-16 11:15:00', '2024-01-16 08:30:00'),

('CASE_003', 'COMP_003', 'admin@techcorp.com', 'JW_AGT_003', '2024-01-17 14:20:00', 'Tax_Compliance', 'Critical', 'Resolved', 
'Year-end tax document questions - W2s and 1099s', 
'We are getting close to tax season and have questions about W2 distribution. We had several employees who were reclassified from contractors to employees mid-year. How should we handle their tax documents? Also, when will W2s be available for our employees to download?', 
'Explained the process for employees who transitioned from 1099 to W2 status mid-year. Confirmed that W2s will be available in employee portals by January 31st. Provided guidance on handling the contractor payments and coordinated with tax compliance specialist for the complex cases.', 
'2024-01-17 16:45:00', '2024-01-17 14:20:00'),

('CASE_004', 'COMP_004', 'payroll@manufacturing.com', 'JW_AGT_001', '2024-01-18 10:15:00', 'Payroll_Issue', 'High', 'Resolved', 
'Overtime calculations incorrect for shift workers', 
'We have employees working rotating shifts and the overtime calculations don''t seem right. Some employees are getting overtime pay when they shouldn''t, and others are not getting overtime when they should. We need to understand how the system calculates overtime for non-standard schedules.', 
'Reviewed shift schedule setup and found that alternative workweek schedules were not properly configured. Updated the system to reflect 4x10 schedule with correct overtime triggers. Processed payroll adjustments for affected employees and provided documentation on managing alternative schedules.', 
'2024-01-18 15:30:00', '2024-01-18 10:15:00'),

('CASE_005', 'COMP_005', 'hr@healthcare.com', 'JW_AGT_002', '2024-01-19 09:45:00', 'Workers_Comp', 'High', 'In_Progress', 
'Workers comp claim - nurse injured by patient', 
'One of our nurses was injured by an aggressive patient during a shift. She sustained injuries to her arm and back. This is a sensitive situation because it involves patient care. We need guidance on how to handle the workers comp claim and what documentation is required.', 
'Initiated workers comp claim and connected with healthcare-specific specialist. Provided guidance on documentation requirements for healthcare worker injuries. Coordinating with risk management team to ensure proper protocols are followed. Claim is being processed with insurance carrier.', 
NULL, '2024-01-19 09:45:00'),

('CASE_006', 'COMP_006', 'benefits@startup.com', 'JW_AGT_003', '2024-01-20 16:30:00', 'Benefits_Question', 'Low', 'Resolved', 
'Employee asking about COBRA continuation coverage', 
'We have an employee who is leaving the company and wants to continue their health insurance through COBRA. They have questions about the cost, duration, and enrollment process. Can you provide details about COBRA administration through Summit Solutions?', 
'Explained COBRA continuation coverage options and costs (102% of premium). Provided timeline for COBRA election (60 days from termination). Confirmed that Summit Solutions administers COBRA automatically and departing employee will receive election materials within required timeframe.', 
'2024-01-20 17:15:00', '2024-01-20 16:30:00'),

('CASE_007', 'COMP_007', 'admin@retailco.com', 'JW_AGT_001', '2024-01-21 11:20:00', 'HR_Policy', 'Medium', 'Open', 
'Questions about paid sick leave compliance in multiple states', 
'We have retail locations in several states and are confused about different paid sick leave requirements. Some states have different accrual rates and usage rules. We want to make sure we are compliant with all applicable laws.', 
'Currently researching state-specific paid sick leave requirements for client locations (CA, NY, WA, OR). Coordinating with compliance team to ensure policies meet all state requirements. Will provide comprehensive policy recommendations by end of week.', 
NULL, '2024-01-21 11:20:00'),

('CASE_008', 'COMP_008', 'finance@techfirm.com', 'JW_AGT_002', '2024-01-22 13:10:00', 'Payroll_Issue', 'Medium', 'Resolved', 
'Commission calculations not matching sales data', 
'Our sales team commissions are not calculating correctly. The amounts in payroll don''t match what our sales manager calculated based on the commission structure. We need to understand how to properly set up commission calculations in the system.', 
'Reviewed commission structure and found that tier-based calculations were not properly configured. Updated commission rules to reflect correct percentages and thresholds. Processed retroactive commission adjustments for affected sales representatives. Provided training on commission setup for future changes.', 
'2024-01-22 16:45:00', '2024-01-22 13:10:00');

-- Insert a support case about the exact same issue ** for AI_SIMILARITY
INSERT INTO support_cases VALUES
('CASE_999', 'COMP_999', 'finance@techcompany999.com', 'JW_AGT_888', '2024-01-25 09:00:00', 'Tax_Compliance', 'Critical', 'Resolved', 
'EDD Notice - Unpaid California SDI contributions Q4 2023', 
'We received an urgent notice from the California Employment Development Department (EDD) today regarding unpaid State Disability Insurance contributions. The notice number is EDD-2024-0158 and shows we owe $15,000 for Q4 2023 covering October, November, and December. We believed Summit Solutions was automatically handling all California payroll tax remittances including SDI. Our employees had the correct SDI deductions taken from their paychecks during this period, but apparently the payments were not sent to the EDD. This is causing significant financial stress for our small company. We need immediate assistance to understand why this happened and how to resolve it. The notice indicates we have 30 days to respond or face additional penalties.', 
'Investigation revealed this was caused by a technical system error in our California tax filing process during Q4 2023 that affected a limited number of clients. SDI contributions were properly deducted from employee paychecks but failed to be remitted to the EDD due to the system malfunction. Summit Solutions took full responsibility for the error. Our tax compliance team immediately contacted the EDD, paid the full $15,000 in unpaid contributions plus all associated penalties and interest. Client was held harmless and received written confirmation. Issue was fully resolved within 3 business days with no cost to the client.', 
'2024-01-25 17:00:00', '2024-01-25 09:00:00');





-- Let's take a quick peak at the two tables

SELECT * FROM call_transcripts;

SELECT * FROM support_cases;



-- 3. SNOWFLAKE CORTEX AISQL EXAMPLES
-- =====================================================

-- Example 1: Basic Sentiment Analysis on Call Transcripts
-- =====================================================
-- Use SENTIMENT for overall numeric sentiment score (-1 to 1)

SELECT 
    call_id,
    call_type,
    client_tier,
    outcome,
    transcript_text,
    SNOWFLAKE.CORTEX.SENTIMENT(transcript_text) as sentiment_score,
    CASE 
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(transcript_text) >= 0.5 THEN 'Positive'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(transcript_text) <= -0.5 THEN 'Negative'
        ELSE 'Neutral'
    END as sentiment_category
FROM call_transcripts
ORDER BY sentiment_score DESC;

-- Example 1B: Entity-Based Sentiment Analysis for Specific Aspects
-- =====================================================
-- Use ENTITY_SENTIMENT to get sentiment on specific HR/payroll aspects
-- response options include: positive, mixed, negative, or unknown

SELECT 
    call_id,
    call_type,
    outcome,
    transcript_text,
    SNOWFLAKE.CORTEX.ENTITY_SENTIMENT(
        transcript_text,
        ['Service Quality', 'Response Time', 'Problem Resolution', 'Agent Helpfulness']
    ) as detailed_sentiment
FROM call_transcripts
WHERE call_type IN ('Payroll', 'Benefits');
-- LIMIT 5;

-- Example 1C: Overall sentiment without specific entities
SELECT 
    call_id,
    call_type,
    SNOWFLAKE.CORTEX.ENTITY_SENTIMENT(transcript_text) as overall_sentiment_detailed
FROM call_transcripts
LIMIT 3;

-- =====================================================
-- Example 2: Classify Call Types using AI_CLASSIFY
-- =====================================================
-- Automatically categorize calls into issue types with proper syntax

-- NOTE:
-- label (Required): The name of the category
-- description (Optional): Describes the category in no more than 25 words
SELECT 
    call_id,
    call_type as original_type,
    transcript_text,
    -- Extract just the label from the returned object (no PARSE_JSON needed)
    AI_CLASSIFY(
        transcript_text,
        ARRAY_CONSTRUCT(
            'Payroll_Urgent', 
            'Benefits_Enrollment', 
            'Tax_Question', 
            'Workers_Compensation', 
            'General_Support',
            'Billing_Issue',
            'Onboarding_Help'
        )
    )['labels'][0]::STRING as ai_classified_type,
    outcome
FROM call_transcripts;

-- Example 3: Multi-label Classification with Enhanced Configuration
-- =====================================================
-- Classify support cases into multiple categories with task description

SELECT * FROM support_cases;

SELECT 
    case_id,
    subject,
    description,
    -- Extract the labels array (no PARSE_JSON needed)
    AI_CLASSIFY(
        description,
        ARRAY_CONSTRUCT(
            'Time_Sensitive',
            'Compliance_Related', 
            'System_Technical',
            'Employee_Facing',
            'Manager_Training_Needed',
            'Documentation_Required'
        ),
        OBJECT_CONSTRUCT(
            'output_mode', 'multi',
            'task_description', 'Classify this HR support case into relevant operational categories'
        )
    )['labels'] as issue_categories
FROM support_cases;

-- Example 4: AI_FILTER for Escalation Detection
-- =====================================================
-- Use AI_FILTER to identify calls that should have been escalated
-- FIlter thru transcripts to determine if any of the calls should have been escalated


-- Method 1: Using PROMPT function (recommended)
SELECT 
    call_id,
    call_type,
    outcome,
    transcript_text,
    AI_FILTER(PROMPT('This call involves a frustrated customer, complex compliance issue, or potential legal concern that should be escalated: {0}', transcript_text)) as should_escalate
FROM call_transcripts
WHERE AI_FILTER(PROMPT('This call involves a frustrated customer, complex compliance issue, or potential legal concern that should be escalated: {0}', transcript_text)) = TRUE;


-- Example 5: Extract Key Information using AI_COMPLETE
-- =====================================================
-- Extract structured information from unstructured call transcripts

-- CREATE TABLE ai_complete_extract_table AS 
SELECT 
    call_id,
    transcript_text,
    AI_COMPLETE(
        model => 'claude-3-5-sonnet',
        prompt => 'Extract the main issue, resolution provided, and customer satisfaction level from this call transcript: ' || transcript_text,
        model_parameters => {
            'temperature': 0,
            'max_tokens': 4096
        },
        response_format => {
            'type': 'json',
            'schema': {
                'type': 'object',
                'properties': {
                    'main_issue': {'type': 'string'},
                    'resolution': {'type': 'string'},
                    'satisfaction_level': {'type': 'string'}
                },
                'required': ['main_issue', 'resolution', 'satisfaction_level']
            }
        }
    ) as extracted_info
FROM call_transcripts
LIMIT 3;

-- SELECT * FROM ai_complete_extract_table;

-- Example 6: Summarize Support Cases by Category
-- =====================================================
-- Use AI_AGG to get insights across multiple support cases

SELECT 
    case_type,
    COUNT(*) as case_count,
    AI_AGG(
        description,
        'Summarize the most common issues and themes across these support cases. Focus on patterns and actionable insights.'
    ) as common_themes
FROM support_cases
GROUP BY case_type;

-- Example 7: Sentiment Analysis Trends by Call Type
-- =====================================================
-- Analyze sentiment patterns across different types of calls

SELECT 
    call_type,
    client_tier,
    COUNT(*) as total_calls,
    AVG(SNOWFLAKE.CORTEX.SENTIMENT(transcript_text)) as avg_sentiment,
    COUNT(CASE WHEN SNOWFLAKE.CORTEX.SENTIMENT(transcript_text) >= 0.5 THEN 1 END) as positive_calls,
    COUNT(CASE WHEN SNOWFLAKE.CORTEX.SENTIMENT(transcript_text) <= -0.5 THEN 1 END) as negative_calls,
    COUNT(CASE WHEN SNOWFLAKE.CORTEX.SENTIMENT(transcript_text) > -0.5 AND SNOWFLAKE.CORTEX.SENTIMENT(transcript_text) < 0.5 THEN 1 END) as neutral_calls
FROM call_transcripts
GROUP BY call_type, client_tier
ORDER BY avg_sentiment DESC;

-- Example 8: AI Join - Connect Related Calls and Cases
-- =====================================================
-- Use AI_SIMILARITY to find support cases that might be related to call transcripts

SELECT 
    ct.call_id,
    ct.client_company_id as call_customer,
    ct.transcript_text,
    sc.case_id,
    sc.client_company_id as case_customer,
    sc.description,
    AI_SIMILARITY(ct.transcript_text, sc.description) as similarity_score
FROM call_transcripts ct
CROSS JOIN support_cases sc
WHERE AI_SIMILARITY(ct.transcript_text, sc.description) > 0.5
ORDER BY similarity_score DESC;


-- Example 9: Compliance Risk Detection
-- =====================================================
-- Use AI_FILTER to identify potential compliance risks in support interactions

SELECT 
    case_id,
    case_type,
    priority,
    AI_FILTER(CONCAT('This case involves potential compliance violations, legal risks, wage and hour issues, discrimination concerns, or safety violations: ', description, ' ', COALESCE(resolution_notes, ''))) as compliance_risk,
    AI_COMPLETE(
        'claude-3-5-sonnet',
        'If this support case involves compliance risks, briefly explain the specific risk areas: ' || description
    ) as risk_explanation
FROM support_cases
WHERE AI_FILTER(CONCAT('This case involves potential compliance violations, legal risks, wage and hour issues, discrimination concerns, or safety violations: ', description, ' ', COALESCE(resolution_notes, ''))) = TRUE;

-- Example 10: Customer Satisfaction Prediction (Updated)
-- =====================================================
-- Predict customer satisfaction using AI_CLASSIFY with enhanced categories

SELECT 
    call_id,
    call_type,
    client_tier,
    outcome,
    transcript_text,
    AI_CLASSIFY(
        transcript_text,
        ARRAY_CONSTRUCT(
            OBJECT_CONSTRUCT('label', 'Highly_Satisfied', 'description', 'Customer is very happy and grateful for excellent service'),
            OBJECT_CONSTRUCT('label', 'Satisfied', 'description', 'Customer is pleased with the resolution and service quality'), 
            OBJECT_CONSTRUCT('label', 'Neutral', 'description', 'Customer is neither particularly happy nor unhappy'),
            OBJECT_CONSTRUCT('label', 'Dissatisfied', 'description', 'Customer is frustrated or unhappy with service or resolution'),
            OBJECT_CONSTRUCT('label', 'Highly_Dissatisfied', 'description', 'Customer is very angry, threatening to leave, or extremely upset')
        ),
        OBJECT_CONSTRUCT(
            'task_description', 'Predict customer satisfaction level based on the tone and outcome of this support interaction'
        )
    ) as satisfaction_prediction_result,
    AI_CLASSIFY(
        transcript_text,
        ARRAY_CONSTRUCT('Highly_Satisfied', 'Satisfied', 'Neutral', 'Dissatisfied', 'Highly_Dissatisfied'),
        OBJECT_CONSTRUCT('task_description', 'Predict customer satisfaction level based on the tone and outcome of this support interaction')
    )['labels'][0]::STRING as predicted_satisfaction,
    SNOWFLAKE.CORTEX.SENTIMENT(transcript_text) as sentiment_score
FROM call_transcripts;

-- Example 11: Multilingual Support (if applicable)
-- =====================================================
-- Translate and analyze non-English support content

SELECT 
    case_id,
    SNOWFLAKE.CORTEX.TRANSLATE(description, 'en', 'es') as description_spanish,
    SNOWFLAKE.CORTEX.TRANSLATE(
        AI_COMPLETE(
            'claude-3-5-sonnet',
            'Provide a brief, professional response to this support case: ' || description
        ),
        'en', 'es'
    ) as suggested_response_spanish
FROM support_cases
WHERE case_type = 'Benefits_Question'
LIMIT 3;


-- Example 14: Knowledge Base Content Generation
-- =====================================================
-- Generate FAQ content based on common support issues

SELECT 
    case_type,
    AI_AGG(
        description,
        'Create FAQ-style content based on these common support issues. Include clear questions and answers.'
    ) as faq_content
FROM support_cases
WHERE status = 'Resolved'
GROUP BY case_type;
