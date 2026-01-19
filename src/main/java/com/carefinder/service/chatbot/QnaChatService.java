package com.carefinder.service.chatbot;

import com.carefinder.dto.chatbot.ChatResponse;
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
public class QnaChatService {

    @Value("${openai.api.key}")
    private String apiKey;

    @Value("${openai.model}")
    private String model;

    private final ObjectMapper mapper = new ObjectMapper();

    //의료/건강 관련 질문에 대해 답변반환 메서드
    public ChatResponse ask(String userMessage) {

        try {
            //Q&A 프롬프트 로드
            String promptTemplate = loadPrompt("prompts/medical_qna_prompt.txt");

            //사용자 질문 저장
            String prompt = promptTemplate.replace("{{USER_MESSAGE}}", userMessage);

            ObjectNode root = mapper.createObjectNode();
            root.put("model", model);

            ArrayNode messages = mapper.createArrayNode();
            ObjectNode msg = mapper.createObjectNode();
            msg.put("role", "user");
            msg.put("content", prompt);
            messages.add(msg);
            root.set("messages", messages);


            //api 호출
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.openai.com/v1/chat/completions"))
                    .header("Authorization", "Bearer " + apiKey)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(
                            mapper.writeValueAsString(root)))
                    .build();

            HttpResponse<String> response =
                    HttpClient.newHttpClient()
                            .send(request, HttpResponse.BodyHandlers.ofString());

            JsonNode res = mapper.readTree(response.body());
            String content = res.path("choices")
                    .path(0)
                    .path("message")
                    .path("content")
                    .asText("설명을 제공하지 못했어요.");


            return new ChatResponse(
                    content,
                    null,
                    null,
                    false,
                    null
            );

        } catch (Exception e) {
            e.printStackTrace();
            return new ChatResponse(
                    "설명을 제공하지 못했어요. 다시 질문해 주세요.",
                    null,
                    null,
                    false,
                    null
            );
        }
    }

    //프롬프트 로드
    private String loadPrompt(String path) throws Exception {
        ClassPathResource r = new ClassPathResource(path);
        return new String(r.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
    }
}
