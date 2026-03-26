package com.aliparwiz.microgreens;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.scheduling.annotation.EnableScheduling;

@Slf4j
@SpringBootApplication
@EnableScheduling
public class MicrogreensApplication {

    public static void main(String[] args) {
        ConfigurableApplicationContext context = SpringApplication.run(MicrogreensApplication.class, args);
        Environment env = context.getEnvironment();
        String port = env.getProperty("server.port", "8080");
        String appName = env.getProperty("app.name", "Microgreens backend");
        String version = env.getProperty("app.version", "unknown");

        log.info("[APP] Started {} v{}", appName, version);
        log.info("[APP] Backend ready at http://localhost:{}", port);
    }
}

