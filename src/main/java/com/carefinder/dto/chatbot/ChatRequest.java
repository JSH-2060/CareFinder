package com.carefinder.dto.chatbot;

public class ChatRequest {

    private String message;

    public ChatRequest() {} // 🔥 필수

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) { // 🔥 필수
        this.message = message;
    }
}
