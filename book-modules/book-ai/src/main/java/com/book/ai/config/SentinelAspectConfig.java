package com.book.ai.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.alibaba.csp.sentinel.annotation.aspectj.SentinelResourceAspect;

/**
 * Enable {@code @SentinelResource} AOP for model chat.
 *
 * @author book
 */
@Configuration
public class SentinelAspectConfig
{
    @Bean
    public SentinelResourceAspect sentinelResourceAspect()
    {
        return new SentinelResourceAspect();
    }
}
