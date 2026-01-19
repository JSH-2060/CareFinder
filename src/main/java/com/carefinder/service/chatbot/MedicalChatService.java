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
public class MedicalChatService {

    @Value("${openai.api.key}")
    private String apiKey;

    @Value("${openai.model}")
    private String model;

    private final ObjectMapper mapper = new ObjectMapper();

    public ChatResponse ask(String userMessage) {

        try {
            //프롬프트 파일 로드
            String promptTemplate = loadPrompt("prompts/medical_prompt.txt");

            //사용자 메시지 변환
            String prompt = promptTemplate.replace("{{USER_MESSAGE}}", userMessage);

            //OpenAI 요청 JSON 생성
            ObjectNode root = mapper.createObjectNode();
            root.put("model", model);

            ArrayNode messages = mapper.createArrayNode();
            ObjectNode msg = mapper.createObjectNode();
            msg.put("role", "user");
            msg.put("content", prompt);
            messages.add(msg);

            root.set("messages", messages);

            String requestBody = mapper.writeValueAsString(root);

            // OpenAI 요청
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.openai.com/v1/chat/completions"))
                    .header("Authorization", "Bearer " + apiKey)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();

            HttpClient client = HttpClient.newHttpClient();
            HttpResponse<String> response =
                    client.send(request, HttpResponse.BodyHandlers.ofString());

            //확인용
            System.out.println("OpenAI RAW RESPONSE");
            System.out.println(response.body());

            //응답 파싱
            JsonNode res = mapper.readTree(response.body());

            //에러 응답 처리
            if (res.has("error")) {
                String errorMessage = res.path("error")
                        .path("message")
                        .asText("AI 호출 중 오류가 발생했습니다.");

                System.out.println("OpenAI ERROR = " + errorMessage);

                return new ChatResponse(
                        "요청이 많아 잠시 후 다시 시도해주세요.",
                        null,
                        null,
                        false,
                        null
                );
            }

            //첫번째 초이스
            JsonNode choice0 = res.path("choices").path(0);
            if (choice0.isMissingNode()) {
                throw new RuntimeException("choices[0] 없음");
            }

            //gpt 실제 응답 저장
            String content = choice0.path("message").path("content").asText();

            //json 형태로 응답하지 않을경우
            if (content == null || !content.trim().startsWith("{")) {
                throw new RuntimeException("AI 응답이 JSON이 아님:\n" + content);
            }

            JsonNode result = mapper.readTree(content);

            //결과 추출
            String target = result.path("target").asText("human");
            String dept = result.path("dept").asText(null);
            boolean emergency = result.path("emergency").asBoolean(false);
            String summary = result.path("summary").asText("병원을 추천드립니다.");

            //액션 결정
            String action;
            if ("pet".equals(target)) {
                action = "MOVE_VET";
            } else if (emergency) {
                action = "MOVE_EMERGENCY";
            } else {
                action = "MOVE_MAP";
            }

            return new ChatResponse(summary, action, dept, emergency, target);

        } catch (Exception e) {
            e.printStackTrace();
            return new ChatResponse(
                    "증상을 분석하지 못했어요. 다시 시도해주세요.",
                    null,
                    null,
                    false,
                    null
            );
        }
    }

    //프롬프트 파일 읽기
    private String loadPrompt(String path) throws Exception {
        ClassPathResource resource = new ClassPathResource(path);
        return new String(resource.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
    }
}
