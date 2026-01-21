package com.carefinder.service.chatbot;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

@Service
public class IntentService {

    private final ObjectMapper mapper = new ObjectMapper();
    private final String model;
    private final String apiKey;

    public IntentService(
            @Value("${openai.api.key}") String apiKey,
            @Value("${openai.model}") String model
    ) {
        this.apiKey = apiKey;
        this.model = model;
    }
    //userMessage 사용자가 입력한 값 저장
    // intent == RECOMMEND, MEDICAL_QNA, ETC
    public String detectIntent(String userMessage) throws Exception {

        //intent 뷴류용 파일 읽고 사용자 메시지를 템플릿에 저장
        String prompt = loadPrompt("prompts/intent_prompt.txt")
                .replace("{{USER_MESSAGE}}", userMessage);

        //요청용
        ObjectNode root = mapper.createObjectNode();

        root.put("model", model);

        ArrayNode messages = mapper.createArrayNode();
        messages.add(objectMessage("user", prompt));
        root.set("messages", messages);

        //api 요청
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://api.openai.com/v1/chat/completions"))
                .header("Authorization", "Bearer " + apiKey)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(
                        mapper.writeValueAsString(root)))
                .build();
        //요청 전송 및 응답 수신
        HttpResponse<String> response =
                HttpClient.newHttpClient()
                        .send(request, HttpResponse.BodyHandlers.ofString());

        JsonNode json = mapper.readTree(response.body());

        //챗봇 메시지 추출
        String content = json.path("choices").path(0)
                .path("message").path("content").asText();
        String intent = mapper.readTree(content).path("intent").asText("ETC");


        System.out.println("DETECTED INTENT = " + intent);

        //intent 반환
        return mapper.readTree(content).path("intent").asText("ETC");
    }

    private ObjectNode objectMessage(String role, String content) {
        ObjectNode n = mapper.createObjectNode();
        n.put("role", role);
        n.put("content", content);
        return n;
    }
    //프롬프트 읽어오기
    private String loadPrompt(String path) throws Exception {
        ClassPathResource r = new ClassPathResource(path);
        return new String(r.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
    }
}
