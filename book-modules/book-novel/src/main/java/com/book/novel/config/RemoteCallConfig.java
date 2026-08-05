package com.book.novel.config;

import java.time.Duration;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

/**
 * RestTemplate used by book-novel to call other services (currently book-ai) by service name
 * through Nacos discovery + Spring Cloud LoadBalancer, e.g. http://book-ai/chat.
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
                .connectTimeout(Duration.ofSeconds(10))
                .readTimeout(Duration.ofSeconds(90))
                .build();
    }
}
