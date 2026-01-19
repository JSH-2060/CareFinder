package com.carefinder.dto.chatbot;

public class ChatRequest {

    private String message;

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) { // 🔥 필수
        this.message = message;
    }
}
