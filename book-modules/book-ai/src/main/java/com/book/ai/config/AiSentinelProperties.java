package com.book.ai.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * Sentinel / retry knobs for model calls (Nacos book.ai.sentinel.*).
 *
 * @author book
 */
@Configuration
@ConfigurationProperties(prefix = "book.ai.sentinel")
public class AiSentinelProperties
{
    /** Extra retries after first failure (0 = no retry). */
    private int maxRetries = 1;

    /** Sleep millis between retries. */
    private long retryIntervalMs = 800L;

    public int getMaxRetries()
    {
        return maxRetries;
    }

    public void setMaxRetries(int maxRetries)
    {
        this.maxRetries = maxRetries;
    }

    public long getRetryIntervalMs()
    {
        return retryIntervalMs;
    }

    public void setRetryIntervalMs(long retryIntervalMs)
    {
        this.retryIntervalMs = retryIntervalMs;
    }
}
