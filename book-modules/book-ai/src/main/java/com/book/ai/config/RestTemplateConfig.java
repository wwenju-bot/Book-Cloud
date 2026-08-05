package com.book.ai.config;

import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;

/**
 * 调用 DeepSeek/豆包等外部模型接口使用的 RestTemplate，统一设置连接/读取超时
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
                .connectTimeout(Duration.ofSeconds(10))
                .readTimeout(Duration.ofSeconds(60))
                .build();
    }
}
