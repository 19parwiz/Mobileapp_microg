package com.aliparwiz.microgreens.ai;

import java.util.List;

public record ChatRequest(
        List<ChatMessageDto> messages
) {
}