package com.aliparwiz.microgreens.mail;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.nio.charset.StandardCharsets;

/**
 * Sends transactional email when {@link JavaMailSender} is configured ({@code spring.mail.host} set).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EmailService {

    private final ObjectProvider<JavaMailSender> mailSenderProvider;

    @Value("${app.mail.from:noreply@localhost}")
    private String fromAddress;

    @Value("${app.public-api-base-url:http://localhost:8080}")
    private String publicApiBaseUrl;

    @Value("${app.password-reset-web-base:http://localhost:3000}")
    private String passwordResetWebBase;

    public void sendVerificationEmail(String toEmail, String token) {
        String link = publicApiBaseUrl.replaceAll("/$", "") + "/api/auth/verify?token=" + token;
        String html = """
            <html><body>
            <p>Welcome to Microgreens.</p>
            <p>Click below to verify your email address:</p>
            <p><a href="%s">Verify email</a></p>
            <p>If the button does not work, paste this URL into your browser:<br/><span style="word-break:break-all;">%s</span></p>
            </body></html>
            """.formatted(link, link);
        sendHtml(toEmail, "Verify your email", html);
    }

    public void sendPasswordResetEmail(String toEmail, String token) {
        String link = passwordResetWebBase.replaceAll("/$", "") + "/reset-password?token=" + token;
        String html = """
            <html><body>
            <p>You requested a password reset.</p>
            <p>Open the link below in the app or browser to choose a new password:</p>
            <p><a href="%s">Reset password</a></p>
            <p>If you did not request this, you can ignore this message.</p>
            <p style="word-break:break-all;">%s</p>
            </body></html>
            """.formatted(link, link);
        sendHtml(toEmail, "Reset your password", html);
    }

    private void sendHtml(String to, String subject, String htmlBody) {
        JavaMailSender sender = mailSenderProvider.getIfAvailable();
        if (sender == null) {
            log.warn("[MAIL] JavaMailSender not configured (set spring.mail.host); skipping email to {}", to);
            return;
        }
        try {
            MimeMessage message = sender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(
                message,
                MimeMessageHelper.MULTIPART_MODE_NO,
                StandardCharsets.UTF_8.name()
            );
            helper.setFrom(fromAddress);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlBody, true);
            sender.send(message);
            log.info("[MAIL] Sent '{}' to {}", subject, to);
        } catch (MessagingException e) {
            log.error("[MAIL] Failed to send '{}' to {}", subject, to, e);
            throw new IllegalStateException("Failed to send email", e);
        }
    }
}
