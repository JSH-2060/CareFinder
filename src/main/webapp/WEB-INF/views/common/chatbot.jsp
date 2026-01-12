<!-- common/chatbot.jsp -->
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<meta charset="UTF-8"/>

<div id="chatbot-fab">💻</div>

<div id="chatbot-panel">
    <div class="chatbot-header">
        AI 상담
        <span id="chatbot-close">✕</span>
    </div>

    <div id="chatbot-messages"></div>

    <div class="chatbot-input">
        <input type="text" id="chatbotInput" placeholder="궁금한 점을 물어보세요" />
        <button id="chatbotSendBtn">전송</button>
    </div>
</div>
