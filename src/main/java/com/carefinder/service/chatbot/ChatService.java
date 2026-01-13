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
        try {
            String intent = intentService.detectIntent(userMessage);
            System.out.println("🧠 DETECTED INTENT = " + intent);

            return switch (intent) {

                case "RECOMMEND" ->
                        medicalChatService.ask(userMessage);

                case "MEDICAL_QNA" ->
                        qnaChatService.ask(userMessage);

                case "SERVICE_INFO" ->
                        serviceInfoChatService.ask(userMessage);

                // ⭐ 핵심 수정 포인트
                default ->
                        new ChatResponse(
                                "증상을 입력하셔야 병원을 추천해드릴 수 있어요 🙂\n" +
                                        "예: \"넘어졌는데 무릎이 아파요\"",
                                null,   // action 없음 → 프론트에서 맵 이동 안 함
                                null,
                                false,
                                intent
                        );
            };

        } catch (Exception e) {
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
