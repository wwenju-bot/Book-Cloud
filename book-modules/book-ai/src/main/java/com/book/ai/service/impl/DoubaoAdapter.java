package com.book.ai.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import com.book.ai.config.AiModelProperties;

/**
 * 豆包（火山方舟 Ark）模型适配器
 *
 * @author book
 */
@Service
public class DoubaoAdapter extends AbstractOpenAiCompatibleAdapter
{
    @Autowired
    private AiModelProperties modelProperties;

    public DoubaoAdapter(RestTemplate modelRestTemplate)
    {
        super(modelRestTemplate);
    }

    @Override
    public String getModelKey()
    {
        return "doubao";
    }

    @Override
    protected AiModelProperties.ModelConfig getModelConfig()
    {
        return modelProperties.getDoubao();
    }
}
