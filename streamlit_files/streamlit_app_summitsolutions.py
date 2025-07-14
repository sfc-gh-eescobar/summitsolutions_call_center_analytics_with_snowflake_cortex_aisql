# Summit Solutions FAQ Chatbot - Streamlit in Snowflake
# This creates a chat interface using the Cortex Search service for RAG

import streamlit as st
import json
from snowflake.snowpark.context import get_active_session
from snowflake.core import Root

# Get the current Snowflake session
session = get_active_session()

# Constants for the search service
DB = session.get_current_database()
SCHEMA = session.get_current_schema()
SERVICE = "summitsolutions_faq_search"

# App configuration
st.set_page_config(
    page_title="Summit Solutions FAQ Assistant",
    page_icon="💼",
    layout="wide"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .main-header {
        background: linear-gradient(90deg, #1f4e79 0%, #2980b9 100%);
        padding: 1rem;
        border-radius: 10px;
        margin-bottom: 2rem;
    }
    .main-header h1 {
        color: white;
        text-align: center;
        margin: 0;
    }
    .chat-message {
        padding: 1rem;
        border-radius: 10px;
        margin: 1rem 0;
        border-left: 4px solid #2980b9;
    }
    .user-message {
        background-color: #e3f2fd;
        border-left-color: #1976d2;
    }
    .assistant-message {
        background-color: #f5f5f5;
        border-left-color: #2980b9;
    }
    .search-results {
        background-color: #fff3cd;
        border: 1px solid #ffc107;
        border-radius: 5px;
        padding: 10px;
        margin: 10px 0;
    }
    .faq-item {
        background-color: #f8f9fa;
        border-radius: 5px;
        padding: 10px;
        margin: 5px 0;
        border-left: 3px solid #17a2b8;
    }
</style>
""", unsafe_allow_html=True)

# Header
st.markdown("""
<div class="main-header">
    <h1>💼 Summit Solutions FAQ Assistant</h1>
    <p style="text-align: center; color: white; margin: 0;">
        Get instant answers to your HR, payroll, and benefits questions
    </p>
</div>
""", unsafe_allow_html=True)

# Initialize session state for chat history
if "messages" not in st.session_state:
    st.session_state.messages = []
    st.session_state.messages.append({
        "role": "assistant", 
        "content": "👋 Hi! I'm your Summit Solutions FAQ Assistant. I can help you with questions about payroll, benefits, HR policies, and more. What can I help you with today?"
    })

# Sidebar with information and settings
with st.sidebar:
    st.markdown("### 🔧 Settings")
    
    # Search settings
    max_results = st.slider("Max FAQ results to search", min_value=1, max_value=10, value=3)
    show_sources = st.checkbox("Show source FAQs", value=True)
    
    st.markdown("### 📚 What I can help with:")
    st.markdown("""
    - **Payroll Issues**: Overtime pay, tax withholdings, state taxes
    - **Benefits**: Health insurance, enrollment, life events
    - **HR Policies**: Sick leave, workers compensation
    - **Tax Questions**: W-4 updates, multi-state compliance
    - **General Support**: Account access, process questions
    """)
    
    # Clear chat button
    if st.button("🗑️ Clear Chat History"):
        st.session_state.messages = [st.session_state.messages[0]]  # Keep welcome message
        st.rerun()

# Main chat interface
col1, col2 = st.columns([3, 1])

with col1:
    # Display chat messages
    for message in st.session_state.messages:
        if message["role"] == "user":
            st.markdown(f"""
            <div class="chat-message user-message">
                <strong>🙋 You:</strong><br>
                {message["content"]}
            </div>
            """, unsafe_allow_html=True)
        else:
            st.markdown(f"""
            <div class="chat-message assistant-message">
                <strong>🤖 Assistant:</strong><br>
                {message["content"]}
            </div>
            """, unsafe_allow_html=True)
            
            # Show sources if enabled and available
            if show_sources and "sources" in message:
                with st.expander("📖 Source FAQs Used"):
                    for i, source in enumerate(message["sources"], 1):
                        st.markdown(f"""
                        <div class="faq-item">
                            <strong>FAQ {i}:</strong><br>
                            <strong>Q:</strong> {source['question']}<br>
                            <strong>A:</strong> {source['answer'][:200]}{'...' if len(source['answer']) > 200 else ''}
                        </div>
                        """, unsafe_allow_html=True)

def query_cortex_search_service(query, limit=3):
    """
    Queries the cortex search service using Python SDK
    """
    try:
        # Get the search service using the Python SDK
        root = Root(session)
        cortex_search_service = (
            root.databases[DB]
            .schemas[SCHEMA]
            .cortex_search_services[SERVICE]
        )
        
        # Perform the search
        search_results = cortex_search_service.search(
            query=query,
            columns=["question", "answer", "category", "priority"],
            limit=limit
        )
        
        return search_results.results
    except Exception as e:
        st.error(f"Search error: {str(e)}")
        return []

def generate_ai_response(question, search_results):
    """
    Generate AI response using search results as context
    """
    if not search_results:
        return "I don't have specific information about that topic in our FAQ database. Please contact Summit Solutions support for assistance.", []
    
    # Format context from search results
    context_parts = []
    sources = []
    
    for result in search_results:
        result_dict = dict(result)
        question_text = result_dict.get('question', '')
        answer_text = result_dict.get('answer', '')
        category = result_dict.get('category', '')
        
        context_parts.append(f"Q: {question_text}\nA: {answer_text}")
        sources.append({
            'question': question_text,
            'answer': answer_text,
            'category': category
        })
    
    context = "\n\n".join(context_parts)
    
    # Generate AI response
    try:
        # Create a cleaner prompt without escaped characters
        prompt = f"""Based on the following Summit Solutions FAQ content, provide a helpful and personalized response to this employee question: "{question}"

FAQ Context:
{context}

Please provide a clear, step-by-step response that helps the employee resolve their issue. Format your response with proper paragraphs and bullet points where appropriate. Do not include any escape characters or technical formatting. Write in a friendly, professional tone as if you are a helpful Summit Solutions support representative."""

        # Use proper SQL escaping
        escaped_prompt = prompt.replace("'", "''")
        
        ai_result = session.sql(f"""
        SELECT AI_COMPLETE(
            'claude-3-5-sonnet',
            '{escaped_prompt}'
        ) as response
        """).collect()
        
        if ai_result and len(ai_result) > 0:
            # Clean up the response text
            raw_response = ai_result[0]['RESPONSE']
            
            # Remove common escape characters and fix formatting
            cleaned_response = (raw_response
                              .replace('\\n\\n', '\n\n')  # Fix double newlines
                              .replace('\\n', '\n')       # Fix single newlines
                              .replace('\\"', '"')        # Fix escaped quotes
                              .replace("\\'", "'")        # Fix escaped apostrophes
                              .replace('\\\\', '\\')      # Fix escaped backslashes
                              .strip())                   # Remove leading/trailing whitespace
            
            return cleaned_response, sources
        else:
            return "I'm having trouble generating a response right now. Please try again or contact Summit Solutions support.", []
            
    except Exception as e:
        st.error(f"AI generation error: {str(e)}")
        return "I'm experiencing technical difficulties generating a response. Please contact Summit Solutions support for assistance.", []

# Chat input and processing
user_question = st.chat_input("Ask me anything about Summit Solutions HR, payroll, or benefits...")

if user_question:
    # Add user message to chat history
    st.session_state.messages.append({"role": "user", "content": user_question})
    
    with st.spinner("🔍 Searching our knowledge base..."):
        # Step 1: Search using Python SDK
        search_results = query_cortex_search_service(user_question, max_results)
        
        # Step 2: Generate AI response
        ai_response, sources = generate_ai_response(user_question, search_results)
        
        # Step 3: Add response to chat
        message_data = {
            "role": "assistant", 
            "content": ai_response
        }
        
        if sources:
            message_data["sources"] = sources
            
        st.session_state.messages.append(message_data)
    
    # Rerun to display the new messages
    st.rerun()

# Footer with usage statistics
with col2:
    st.markdown("### 📊 Chat Stats")
    user_messages = len([msg for msg in st.session_state.messages if msg["role"] == "user"])
    st.metric("Questions Asked", user_messages)
    st.metric("Responses Given", len(st.session_state.messages) - user_messages - 1)  # Subtract welcome message
    
    st.markdown("### 🚀 Quick Actions")
    
    # Predefined questions for quick testing
    quick_questions = [
        "How do I update my tax withholdings?",
        "Why is my overtime pay missing?",
        "How do I add my baby to health insurance?",
        "What should I do if I'm injured at work?",
        "How much sick leave do I get?"
    ]
    
    st.markdown("**Try these common questions:**")
    for i, question in enumerate(quick_questions):
        if st.button(f"💬 {question[:30]}...", key=f"quick_{i}", help=question):
            # Add the question to chat and trigger processing
            st.session_state.messages.append({"role": "user", "content": question})
            
            # Process the question immediately
            with st.spinner("🔍 Searching our knowledge base..."):
                # Step 1: Search using Python SDK
                search_results = query_cortex_search_service(question, max_results)
                
                # Step 2: Generate AI response
                ai_response, sources = generate_ai_response(question, search_results)
                
                # Step 3: Add response to chat
                message_data = {
                    "role": "assistant", 
                    "content": ai_response
                }
                
                if sources:
                    message_data["sources"] = sources
                    
                st.session_state.messages.append(message_data)
            
            st.rerun()

# Additional information section
st.markdown("---")
st.markdown("""
### 🔒 Privacy & Security
Your questions and conversations are processed securely within the Summit Solutions Snowflake environment. 
This chatbot uses your company's official FAQ content to provide accurate, up-to-date information.

### 🆘 Need More Help?
If you can't find the answer you're looking for, please contact:
- **Summit Solutions Support**: Available 24/7 for urgent issues
- **Your HR Team**: For company-specific policies
- **Employee Portal**: For account and personal information updates
""")

# Debug section (only show in development)
if st.checkbox("🔧 Show Debug Info", key="debug"):
    st.markdown("### Debug Information")
    st.write("Session State Messages:", len(st.session_state.messages))
    if st.button("Show Raw Messages"):
        st.json(st.session_state.messages)
