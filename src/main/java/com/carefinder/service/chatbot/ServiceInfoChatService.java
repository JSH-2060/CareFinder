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
public class ServiceInfoChatService {

    @Value("${openai.api.key}")
    private String apiKey;

    @Value("${openai.model}")
    private String model;

    private final ObjectMapper mapper = new ObjectMapper();

    public ChatResponse ask(String userMessage) {

        try {
            String promptTemplate = loadPrompt("prompts/service_prompt.txt");
            String prompt = promptTemplate.replace("{{USER_MESSAGE}}", userMessage);

            ObjectNode root = mapper.createObjectNode();
            root.put("model", model);

            ArrayNode messages = mapper.createArrayNode();
            ObjectNode msg = mapper.createObjectNode();
            msg.put("role", "user");
            msg.put("content", prompt);
            messages.add(msg);
            root.set("messages", messages);

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
                    .asText("서비스 정보를 제공하지 못했어요.");

            //이동 없음 / 액션 없음
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
                    "서비스 정보를 불러오지 못했어요. 잠시 후 다시 시도해주세요.",
                    null,
                    null,
                    false,
                    null
            );
        }
    }

    private String loadPrompt(String path) throws Exception {
        ClassPathResource r = new ClassPathResource(path);
        return new String(r.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
    }
}
