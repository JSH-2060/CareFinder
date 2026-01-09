package com.carefinder.dto.chatbot;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class ChatResponse {

    private String message;
    private String action;
    private String dept;
    private boolean emergency;
    private String target;
}
