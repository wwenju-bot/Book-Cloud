package com.book.ai.config;

import java.time.Duration;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

/**
 * RestTemplate for calling DeepSeek / Doubao APIs.
 * Read timeout must cover long architecture/chapter generations (Doubao often >60s).
 *
 * @author book
 */
@Configuration
public class RestTemplateConfig
{
    @Bean
    public RestTemplate modelRestTemplate(RestTemplateBuilder builder)
    {
        return builder
                .connectTimeout(Duration.ofSeconds(15))
                .readTimeout(Duration.ofSeconds(180))
                .build();
    }
}
