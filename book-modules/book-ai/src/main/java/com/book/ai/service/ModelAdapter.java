package com.book.ai.service;

import com.book.ai.domain.ModelRequest;
import com.book.ai.domain.ModelResponse;

/**
 * 模型适配器统一接口，每个接入的大模型对应一个实现（DeepSeekAdapter/DoubaoAdapter...）
 *
 * @author book
 */
public interface ModelAdapter
{
    /**
     * 模型标识，如 "deepseek"、"doubao"，需与 ai_model_config.model_key 保持一致
     */
    String getModelKey();

    /**
     * 同步调用模型，阶段1使用；流式调用（Flux&lt;String&gt;）按需在后续阶段引入
     */
    ModelResponse chat(ModelRequest request);
}
