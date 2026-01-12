package com.carefinder.service.chatbot;

import com.carefinder.dto.chatbot.ChatResponse;
import org.springframework.stereotype.Service;

@Service
public class ChatService {

    private final IntentService intentService;
    private final MedicalChatService medicalChatService;
    private final QnaChatService qnaChatService;
    private final ServiceInfoChatService serviceInfoChatService;

    public ChatService(
            IntentService intentService,
            MedicalChatService medicalChatService,
            QnaChatService qnaChatService,
            ServiceInfoChatService serviceInfoChatService
    ) {
        this.intentService = intentService;
        this.medicalChatService = medicalChatService;
        this.qnaChatService = qnaChatService;
        this.serviceInfoChatService = serviceInfoChatService;
    }

    public ChatResponse ask(String userMessage) {
        try{
        String intent = intentService.detectIntent(userMessage);
        System.out.println("🧠 DETECTED INTENT = " + intent);

        return switch (intent) {
            case "RECOMMEND" -> medicalChatService.ask(userMessage);
            case "MEDICAL_QNA" -> qnaChatService.ask(userMessage);
            case "SERVICE_INFO" -> serviceInfoChatService.ask(userMessage);
            default -> qnaChatService.ask(userMessage);
        };

    } catch (Exception e){
        e.printStackTrace();
        return new ChatResponse(
                "요청을 처리하지 못했어요. 잠시 후 다시 시도해주세요",
                null,
                null,
                false,
                null
        );
    }
}
}
