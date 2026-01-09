package com.carefinder.controller.chatbot;

import com.carefinder.dto.chatbot.ChatResponse;
import com.carefinder.dto.chatbot.ChatRequest;
import com.carefinder.service.chatbot.ChatService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    @PostMapping
    public ChatResponse chat(@RequestBody ChatRequest req) {
        return chatService.ask(req.getMessage());
    }
}
