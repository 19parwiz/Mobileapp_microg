package com.aliparwiz.microgreens.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class OpenAiChatService {

    private static final String SYSTEM_PROMPT = """
            You are an AI assistant for a microgreens monitoring application.
            Help users understand sensor readings, camera observations, plant health,
            irrigation, lighting, temperature, humidity, pH, EC, and TDS.
            Keep responses practical, concise, and agriculture-focused.
            If the user asks about data you do not have, say so clearly and suggest what to check.
            """;

    private final ObjectMapper objectMapper;

    @Value("${llm.api.key:${openai.api.key:${GROQ_API_KEY:${OPENAI_API_KEY:}}}}")
    private String apiKey;

    @Value("${llm.model:${openai.model:${OPENAI_MODEL:gpt-4o-mini}}}")
    private String model;

    @Value("${llm.base-url:${openai.base-url:https://api.openai.com/v1}}")
    private String baseUrl;

    public ChatResponse chat(ChatRequest request) {
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("LLM API key is not configured. Set llm.api.key, openai.api.key, GROQ_API_KEY, or OPENAI_API_KEY.");
        }

        if (request == null || request.messages() == null || request.messages().isEmpty()) {
            throw new IllegalArgumentException("At least one chat message is required.");
        }

        final List<Map<String, String>> messages = new ArrayList<>();
        messages.add(Map.of("role", "system", "content", SYSTEM_PROMPT));

        for (ChatMessageDto message : request.messages()) {
            if (message == null || message.content() == null || message.content().isBlank()) {
                continue;
            }

            final String role = normalizeRole(message.role());
            messages.add(Map.of(
                    "role", role,
                    "content", message.content().trim()
            ));
        }

        if (messages.size() == 1) {
            throw new IllegalArgumentException("No valid user messages were provided.");
        }

        final Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("model", model);
        payload.put("temperature", 0.4);
        payload.put("messages", messages);

        final RestClient client = RestClient.builder()
            .baseUrl(baseUrl)
                .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .build();

        final String responseBody = client.post()
                .uri("/chat/completions")
                .body(payload)
                .retrieve()
                .body(String.class);

        return parseResponse(responseBody);
    }

    private ChatResponse parseResponse(String responseBody) {
        try {
            final JsonNode root = objectMapper.readTree(responseBody);
            final String assistantMessage = root.path("choices")
                    .path(0)
                    .path("message")
                    .path("content")
                    .asText("")
                    .trim();
            final String responseModel = root.path("model").asText(model);

            if (assistantMessage.isBlank()) {
                throw new IllegalStateException("LLM provider returned an empty response.");
            }

            return new ChatResponse(assistantMessage, responseModel);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to parse LLM provider response: " + e.getMessage(), e);
        }
    }

    private String normalizeRole(String role) {
        if (role == null) {
            return "user";
        }

        return switch (role.trim().toLowerCase()) {
            case "assistant", "system" -> role.trim().toLowerCase();
            default -> "user";
        };
    }
}