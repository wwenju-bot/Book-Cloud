package com.book.ai.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import com.book.ai.config.AiModelProperties;

/**
 * DeepSeek 模型适配器
 *
 * @author book
 */
@Service
public class DeepSeekAdapter extends AbstractOpenAiCompatibleAdapter
{
    @Autowired
    private AiModelProperties modelProperties;

    public DeepSeekAdapter(RestTemplate modelRestTemplate)
    {
        super(modelRestTemplate);
    }

    @Override
    public String getModelKey()
    {
        return "deepseek";
    }

    @Override
    protected AiModelProperties.ModelConfig getModelConfig()
    {
        return modelProperties.getDeepseek();
    }
}
