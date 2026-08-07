package com.book.ai.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.alibaba.csp.sentinel.annotation.SentinelResource;
import com.alibaba.csp.sentinel.slots.block.BlockException;
import com.book.ai.config.AiSentinelProperties;
import com.book.ai.domain.ModelRequest;
import com.book.ai.domain.ModelResponse;
import com.book.common.core.exception.ServiceException;

/**
 * Sentinel-wrapped model chat with configurable retries.
 *
 * @author book
 */
@Service
public class ModelChatService
{
    private static final Logger log = LoggerFactory.getLogger(ModelChatService.class);

    @Autowired
    private ModelAdapterRegistry modelAdapterRegistry;

    @Autowired
    private AiSentinelProperties sentinelProperties;

    @SentinelResource(value = "aiModelChat", fallback = "chatFallback", blockHandler = "chatBlockHandler")
    public ModelResponse chat(String modelKey, ModelRequest request)
    {
        ModelAdapter adapter = modelAdapterRegistry.getAdapter(modelKey);
        int maxRetries = Math.max(0, sentinelProperties.getMaxRetries());
        RuntimeException last = null;
        for (int attempt = 0; attempt <= maxRetries; attempt++)
        {
            try
            {
                return adapter.chat(request);
            }
            catch (RuntimeException e)
            {
                last = e;
                log.warn("model chat failed, modelKey={}, attempt={}/{}", modelKey, attempt + 1, maxRetries + 1,
                        e.getMessage());
                if (attempt < maxRetries)
                {
                    sleepQuietly(sentinelProperties.getRetryIntervalMs());
                }
            }
        }
        if (last instanceof ServiceException)
        {
            throw last;
        }
        throw new ServiceException(modelKey + " call failed after retries: "
                + (last == null ? "unknown" : last.getMessage()));
    }

    public ModelResponse chatFallback(String modelKey, ModelRequest request, Throwable ex)
    {
        String detail = ex == null ? "unknown" : ex.getMessage();
        throw new ServiceException("model call degraded (" + modelKey + "): " + detail);
    }

    public ModelResponse chatBlockHandler(String modelKey, ModelRequest request, BlockException ex)
    {
        throw new ServiceException("model call rate-limited (" + modelKey + "), please retry later");
    }

    private void sleepQuietly(long ms)
    {
        if (ms <= 0)
        {
            return;
        }
        try
        {
            Thread.sleep(ms);
        }
        catch (InterruptedException e)
        {
            Thread.currentThread().interrupt();
        }
    }
}
