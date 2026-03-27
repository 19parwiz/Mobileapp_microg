package com.aliparwiz.microgreens.ai;

import com.aliparwiz.microgreens.ai.dto.AiPredictResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@Slf4j
@Service
public class AiPredictService {

    @Value("${ai.service.url:http://localhost:8000}")
    private String aiServiceUrl;

    public AiPredictResponse predict(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("Image file is required");
        }

        try {
            ByteArrayResource fileResource = new ByteArrayResource(file.getBytes()) {
                @Override
                public String getFilename() {
                    return file.getOriginalFilename() != null
                        ? file.getOriginalFilename()
                        : "upload.jpg";
                }
            };

            log.info("[AI] Forwarding image to AI service. filename='{}', size={} bytes",
                fileResource.getFilename(), file.getSize());

            // RestTemplate multipart encoding is more reliable than RestClient for multipart forwarding.
            RestTemplate restTemplate = new RestTemplate();

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            MultiValueMap<String, Object> multipartBody = new LinkedMultiValueMap<>();
            HttpHeaders partHeaders = new HttpHeaders();
            partHeaders.setContentDisposition(
                ContentDisposition.formData()
                    .name("file")
                    .filename(fileResource.getFilename())
                    .build()
            );
            partHeaders.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            multipartBody.add("file", new HttpEntity<>(fileResource, partHeaders));

            HttpEntity<MultiValueMap<String, Object>> requestEntity =
                new HttpEntity<>(multipartBody, headers);

            ResponseEntity<AiPredictResponse> responseEntity =
                restTemplate.postForEntity(aiServiceUrl + "/predict", requestEntity, AiPredictResponse.class);

            AiPredictResponse response = responseEntity.getBody();

            if (response == null) {
                throw new IllegalStateException("AI service returned an empty response");
            }

            List<String> predictions = response.getPredictions();
            String topPrediction = predictions != null && !predictions.isEmpty()
                ? predictions.get(0)
                : null;

            response.setTopPrediction(topPrediction);
            response.setMessage(
                topPrediction != null
                    ? "Prediction completed successfully"
                    : "No objects detected in the image"
            );

            log.info("[AI] YOLO prediction completed for file='{}'", response.getFilename());
            return response;
        } catch (IOException e) {
            throw new IllegalStateException("Failed to read uploaded image", e);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to call AI service: " + e.getMessage(), e);
        }
    }
}
