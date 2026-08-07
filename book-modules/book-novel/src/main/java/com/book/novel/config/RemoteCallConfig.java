package com.book.novel.config;

import java.time.Duration;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

/**
 * RestTemplate used by book-novel to call book-ai via Nacos + LoadBalancer.
 * Must be longer than book-ai model RestTemplate so upstream waits for LLM finish.
 *
 * @author book
 */
@Configuration
public class RemoteCallConfig
{
    @Bean
    @LoadBalanced
    public RestTemplate aiServiceRestTemplate(RestTemplateBuilder builder)
    {
        return builder
                .connectTimeout(Duration.ofSeconds(15))
                .readTimeout(Duration.ofSeconds(210))
                .build();
    }
}
